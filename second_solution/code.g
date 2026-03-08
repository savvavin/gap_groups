##
# Function: AllSubmodulesTest(S, m)
# Description: Enumerates all submodules of the direct sum module S^m
#   via the endomorphism-field model End(S) and subspaces of D^m.
# Input:
#   - S: irreducible MeatAxe module.
#   - m: positive integer multiplicity of the direct sum.
# Output:
#   - List of F-bases, one basis per submodule of S^m.
##
AllSubmodulesTest := function( S, m )
    local F, n, abs_irred, d, D, phi, phi_raw, phi_cache, powers, V, subspaces,
          result, i, e0, x, cent, cent_min, d_vector_to_submodule;

    if not IsInt(m) or m < 1 then
        Error("AllSubmodulesTest: <m> must be a positive integer");
    fi;

    if not IsBound(SMTX) then
        Error("AllSubmodulesTest: SMTX is not available");
    fi;

    F := MTX.Field(S);
    n := MTX.Dimension(S);

    abs_irred := MTX.IsAbsolutelyIrreducible(S);

    # build field D \cong End_A(S)
    if abs_irred then
        D := F;

        # faster computation by hand
        d_vector_to_submodule := function(w)
            local rows, i, l, vec;
            rows := [];

            for i in [1..n] do
                vec := ListWithIdenticalEntries(m * n, Zero(F));
                for l in [1..m] do
                    vec[(l - 1) * n + i] := w[l];
                od;
                Add(rows, vec);
            od;

            return rows;
        end;
    else
        # use SMTX for primitive element and minimal polynomial
        cent := SMTX.CentMat(S);
        cent_min := SMTX.CentMatMinPoly(S);

        if cent = fail or cent_min = fail then
            Error("AllSubmodulesTest: failed to get centralizing field generator from SMTX");
        fi;

        d := Degree(cent_min);
        e0 := cent;
        D := AlgebraicExtension(F, cent_min);

        powers := [IdentityMat(n, F)];
        for i in [2..d] do
            powers[i] := powers[i-1] * e0;
        od;

        # phi maps x in D to an endomorphism matrix on S
        phi_raw := function(x)
            local coeffs, mat, i;
            coeffs := ExtRepOfObj(x);
            mat := NullMat(n, n, F);
            for i in [1..d] do
                if not IsZero(coeffs[i]) then
                    mat := mat + coeffs[i] * powers[i];
                fi;
            od;
            return mat;
        end;

        # cache optimization
        phi_cache := NewDictionary(Zero(D), true, D);

        # for small centralizing fields it is faster to precompute all images
        if Size(D) * n * n <= 2000000 then
            for x in AsList(D) do
                AddDictionary(phi_cache, x, phi_raw(x));
            od;
        fi;

        phi := function(x)
            local mat;
            mat := LookupDictionary(phi_cache, x);
            if mat = fail then
                mat := phi_raw(x);
                AddDictionary(phi_cache, x, mat);
            fi;
            return mat;
        end;

        # default computation
        d_vector_to_submodule := function(w)
            local mats, i;
            mats := List(w, phi);
            return List([1..n], i -> Concatenation(List(mats, mat -> mat[i])));
        end;
    fi;

    # subspaces of D^m
    V := FullRowSpace(D, m);
    
    subspaces := Subspaces(V);
    
    return List(subspaces, 
        W -> Concatenation(List(BasisVectors(CanonicalBasis(W)), d_vector_to_submodule)));
end;
