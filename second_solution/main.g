Read("D:/MATH/sciencework2026/codes/new_tables/code.g");
Read("D:/MATH/sciencework2026/codes/new_tables/final.g");

##
# Function: GaussianBinomial(n, k, q)
# Description: Computes the q-binomial coefficient [n choose k]_q, i.e. the
#   number of k-dimensional subspaces of F_q^n.
# Input:
#   - n: non-negative integer.
#   - k: integer in [0..n].
#   - q: integer > 1.
# Output:
#   - Integer value of [n choose k]_q.
##
GaussianBinomial := function(n, k, q)
    local kk, i, num, den;

    if not IsInt(n) or n < 0 then
        Error("GaussianBinomial: <n> must be a non-negative integer");
    fi;
    if not IsInt(k) or k < 0 or k > n then
        Error("GaussianBinomial: <k> must satisfy 0 <= k <= n");
    fi;
    if not IsInt(q) or q <= 1 then
        Error("GaussianBinomial: <q> must be an integer > 1");
    fi;

    kk := Minimum(k, n - k);
    if kk = 0 then
        return 1;
    fi;

    num := 1;
    den := 1;
    for i in [0..kk - 1] do
        num := num * (q^(n - i) - 1);
        den := den * (q^(kk - i) - 1);
    od;

    return num / den;
end;

##
# Function: ExpectedBlockSubmoduleCount(simple, multiplicity)
# Description: Computes the number of submodules of simple^multiplicity using
#   the endomorphism-field model and q-binomial coefficients.
# Input:
#   - simple: irreducible MeatAxe module S.
#   - multiplicity: non-negative integer m.
# Output:
#   - Integer number of submodules of S^m.
##
ExpectedBlockSubmoduleCount := function(simple, multiplicity)
    local qD, e, d, total;

    if not MTX.IsMTXModule(simple) then
        Error("ExpectedBlockSubmoduleCount: <simple> must be a MeatAxe module");
    fi;
    if not MTX.IsIrreducible(simple) then
        Error("ExpectedBlockSubmoduleCount: <simple> must be irreducible");
    fi;
    if not IsInt(multiplicity) or multiplicity < 0 then
        Error("ExpectedBlockSubmoduleCount: <multiplicity> must be a non-negative integer");
    fi;

    e := MTX.DegreeFieldExt(simple);
    qD := Size(MTX.Field(simple))^e;

    total := 0;
    for d in [0..multiplicity] do
        total := total + GaussianBinomial(multiplicity, d, qD);
    od;

    return total;
end;

##
# Function: ExpectedSubmoduleCountFromAssembler(asm)
# Description: Computes expected total number of submodules by multiplying block
#   counts over all primary components.
# Input:
#   - asm: record returned by BuildSemisimpleAssembler(M).
# Output:
#   - Integer expected total number of submodules.
##
ExpectedSubmoduleCountFromAssembler := function(asm)
    if not IsRecord(asm) or not IsBound(asm.class_count) or not IsBound(asm.classes) then
        Error("ExpectedSubmoduleCountFromAssembler: <asm> must be output of BuildSemisimpleAssembler");
    fi;

    return Product(List(asm.classes,
        c -> ExpectedBlockSubmoduleCount(c.simple, c.multiplicity)));
end;

##
# Function: RegularPrimaryData(G, F)
# Description: Builds the regular G-module over F and its semisimple
#   primary/isotypic decomposition data used for submodule enumeration.
# Input:
#   - G: finite group.
#   - F: finite field.
# Output:
#   - Record with fields:
#       module: regular module M,
#       asm: output of BuildSemisimpleAssembler(M).
##
RegularPrimaryData := function(G, F)
    local M, asm;

    if Size(G) mod Characteristic(F) = 0 then
        Error("RegularPrimaryData: modular case is not supported (regular module may be non-semisimple)");
    fi;

    M := RegularModule(G, F)[2];
    asm := BuildSemisimpleAssembler(M);

    return rec(module := M, asm := asm);
end;

##
# Function: ExpectedSubmoduleCountRegularModuleByPrimary(G, F)
# Description: Computes the expected number of regular-module submodules from
#   primary decomposition data via q-binomial coefficients.
# Input:
#   - G: finite group.
#   - F: finite field.
# Output:
#   - Integer expected total number of submodules.
##
ExpectedSubmoduleCountRegularModuleByPrimary := function(G, F)
    return ExpectedSubmoduleCountFromAssembler(RegularPrimaryData(G, F).asm);
end;

##
# Function: LiftBlockSubmodulesToAmbient(asm, i, subs)
# Description: Lifts submodules of the i-th primary block S_i^{m_i} from block
#   coordinates to row vectors in the ambient basis of M.
# Input:
#   - asm: record returned by BuildSemisimpleAssembler(M).
#   - i: block index in [1..asm.class_count].
#   - subs: list of block submodules (as returned by AllSubmodulesTest).
# Output:
#   - List of ambient row-bases (lists of rows); empty block submodule stays [].
##
LiftBlockSubmodulesToAmbient := function(asm, i, subs)
    local F, emb;

    F := asm.field;
    emb := asm.classes[i].embedding;

    return List(subs, function(U)
        local mat;
        if Length(U) = 0 then
            return [];
        fi;
        mat := ImmutableMatrix(F, U) * emb;
        return List(mat, ShallowCopy);
    end);
end;

##
# Function: CombineAmbientBlockSubmodules(F, byBlockAmbient)
# Description: Forms all sums of one chosen ambient submodule from each block
#   list and returns the resulting submodules.
# Input:
#   - F: finite field of the ambient module.
#   - byBlockAmbient: list of lists; byBlockAmbient[i] contains ambient row-bases
#       for submodules coming from block i.
# Output:
#   - List of submodules in ambient coordinates; each non-zero entry is an
#     immutable matrix over F, the zero submodule is represented by [].
##
CombineAmbientBlockSubmodules := function(F, byBlockAmbient)
    local result, nBlocks, recBuild;

    result := [];
    nBlocks := Length(byBlockAmbient);

    recBuild := function(pos, rows)
        local B;
        if pos > nBlocks then
            if Length(rows) = 0 then
                Add(result, []);
            else
                Add(result, ImmutableMatrix(F, rows));
            fi;
            return;
        fi;

        for B in byBlockAmbient[pos] do
            if Length(B) = 0 then
                recBuild(pos + 1, rows);
            else
                recBuild(pos + 1, Concatenation(rows, B));
            fi;
        od;
    end;

    recBuild(1, []);
    return result;
end;

##
# Function: SubmodulesFromAssembler(asm)
# Description: Enumerates all submodules from precomputed decomposition data by
#   computing block submodules and combining them in ambient coordinates.
# Input:
#   - asm: record returned by BuildSemisimpleAssembler(M).
# Output:
#   - List of all submodules of M in ambient coordinates.
##
SubmodulesFromAssembler := function(asm)
    local byBlockAmbient, i, c;

    byBlockAmbient := [];
    for i in [1..asm.class_count] do
        c := asm.classes[i];
        Add(byBlockAmbient,
            LiftBlockSubmodulesToAmbient(
                asm,
                i,
                AllSubmodulesTest(c.simple, c.multiplicity)
            )
        );
    od;

    return CombineAmbientBlockSubmodules(asm.field, byBlockAmbient);
end;

##
# Function: SubmodulesRegularModuleByPrimary(G, F)
# Description: Enumerates all submodules of the regular G-module over F by
#   decomposing into primary (isotypic) components and combining block-wise
#   submodules.
# Input:
#   - G: finite group.
#   - F: finite field.
# Output:
#   - List of F-bases (matrices/row lists), one for each submodule of the
#     regular module in its original ambient basis.
##
SubmodulesRegularModuleByPrimary := function(G, F)
    local data;

    data := RegularPrimaryData(G, F);
    return SubmodulesFromAssembler(data.asm);
end;

##
# Function: PrintRegularModuleSubmodulesByPrimary(G, F)
# Description: Prints decomposition metadata and the full list of submodules
#   of the regular G-module over F.
# Input:
#   - G: finite group.
#   - F: finite field.
# Output:
#   - Same list as SubmodulesRegularModuleByPrimary(G, F).
##
PrintRegularModuleSubmodulesByPrimary := function(G, F)
    local data, M, asm, i, subs, expected;

    data := RegularPrimaryData(G, F);
    M := data.module;
    asm := data.asm;

    Print("Group: ", StructureDescription(G), "\n");
    Print("Field: GF(", Size(F), ")\n");
    Print("Regular module dimension: ", MTX.Dimension(M), "\n");
    Print("Primary components: ", asm.class_count, "\n");
    for i in [1..asm.class_count] do
        Print("  #", i,
            ": dim(S)=", asm.classes[i].simple_dimension,
            ", multiplicity=", asm.classes[i].multiplicity,
            ", block_dim=", asm.classes[i].block_dimension,
            "\n");
    od;

    expected := ExpectedSubmoduleCountFromAssembler(asm);
    Print("Expected submodules (q-binomial product): ", expected, "\n");

    #subs := SubmodulesFromAssembler(asm);
    #Print("Total submodules: ", Length(subs), "\n");
    # Print(subs, "\n");

    #return subs;
end;

# Example:
#G := SymmetricGroup(4);
#F := GF(5);
#subs := PrintRegularModuleSubmodulesByPrimary(G, F);
