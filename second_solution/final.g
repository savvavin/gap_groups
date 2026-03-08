##
# Function: BuildSemisimpleAssembler(M)
# Description: Constructs data for the decomposition
#   M = S1^m1 + ... + Sk^mk (semisimple case) and records explicit block
#   embeddings from each isotypic block into M in the original basis.
# Input:
#   - M: MeatAxe module.
# Output:
#   - Record with decomposition metadata and embedding matrices, including:
#       class_count, classes, total_embedding.
##
BuildSemisimpleAssembler := function(M)
    local F, dimM, hc, classes, entry, rep, n, r, rows, img,
          emb, totalRows, totalEmbedding, block;

    if not MTX.IsMTXModule(M) then
        Error("BuildSemisimpleAssembler: <M> must be a MeatAxe module");
    fi;

    F := MTX.Field(M);
    dimM := MTX.Dimension(M);
    hc := MTX.HomogeneousComponents(M);

    classes := [];
    totalRows := [];
    for entry in hc do
        rep := entry.component[2];

        if not MTX.IsIrreducible(rep) then
            Error("BuildSemisimpleAssembler: module is not semisimple");
        fi;

        n := MTX.Dimension(rep);
        r := 1 + Length(entry.images);
        rows := List(entry.component[1], ShallowCopy);
        for img in entry.images do
            Append(rows, List(img.isomorphism * img.component[1], ShallowCopy));
        od;
        emb := ImmutableMatrix(F, rows);
        Append(totalRows, rows);

        if Length(entry.indices) <> r then
            Error("BuildSemisimpleAssembler: internal multiplicity mismatch");
        fi;

        block := rec(
            simple := rep,
            simple_dimension := n,
            multiplicity := r,
            block_dimension := n * r,
            indices := entry.indices,
            embedding := emb
        );
        Add(classes, block);
    od;

    if Length(totalRows) <> dimM then
        Error("BuildSemisimpleAssembler: internal decomposition size mismatch");
    fi;

    totalEmbedding := ImmutableMatrix(F, totalRows);

    return rec(
        module := M,
        field := F,
        dimension := dimM,
        class_count := Length(classes),
        classes := classes,
        total_embedding := totalEmbedding
    );
end;


##
# Function: AssembleSubmodule(asm, blockBases)
# Description: Builds a concrete submodule of M (in the original basis of M)
#   from block-wise data in coordinates of S1^m1, ..., Sk^mk returned by
#   BuildSemisimpleAssembler.
# Input:
#   - asm: record returned by BuildSemisimpleAssembler(M).
#   - blockBases: list of length asm.class_count; blockBases[i] is either
#       []/fail (zero block) or a matrix/list of rows with
#       asm.classes[i].block_dimension columns.
# Output:
#   - Immutable matrix whose rows form an F-basis of the assembled submodule
#     in ambient coordinates of M; returns [] for the zero submodule.
##
AssembleSubmodule := function(asm, blockBases)
    local F, k, i, b, U, mat, rows;

    if not IsRecord(asm) or not IsBound(asm.class_count) or not IsBound(asm.classes) then
        Error("AssembleSubmodule: <asm> must be output of BuildSemisimpleAssembler");
    fi;
    if not IsList(blockBases) then
        Error("AssembleSubmodule: <blockBases> must be a list");
    fi;

    F := asm.field;
    k := asm.class_count;

    if Length(blockBases) <> k then
        Error("AssembleSubmodule: <blockBases> must have length ", k);
    fi;

    rows := [];
    for i in [1..k] do
        b := asm.classes[i];
        U := blockBases[i];

        if U = fail or (IsList(U) and Length(U) = 0) then
            # zero block
        elif not IsList(U) then
            Error("AssembleSubmodule: block ", i, " must be []/fail or a matrix/list of rows");
        else
            mat := ImmutableMatrix(F, U);
            if NrCols(mat) <> b.block_dimension then
                Error("AssembleSubmodule: block ", i, " must have ", b.block_dimension, " columns");
            fi;
            mat := mat * b.embedding;
            Append(rows, List(mat, ShallowCopy));
        fi;
    od;

    if rows = [] then
        return [];
    fi;

    rows := BaseMat(rows);
    if rows = [] then
        return [];
    fi;

    return ImmutableMatrix(F, rows);
end;
