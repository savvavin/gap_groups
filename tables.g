LoadPackage("wedderga");
LoadPackage("guava");
LoadPackage("meataxe");

BestGroupCodes := function(G, F)
    local R, B, n, mats, M, bases, ideals, i, results, k, gen_mat, code, d, wd,
          dim, best_for_dim, dim_codes, r, idx, output, filename, max_d, best_codes, list_max_d;
    
    R := GroupRing(F, G);
    B := Basis(R);
    n := Length(BasisVectors(B));
    
    mats := List(GeneratorsOfGroup(G), 
                g -> List(BasisVectors(B), 
                         b -> Coefficients(B, b*g)));
    M := GModuleByMats(mats, F);
    bases := MTX.BasesSubmodules(M);
    
    ideals := [];
    for i in [1..Length(bases)] do
        Add(ideals, LeftIdeal(R, 
            List(bases[i], v -> LinearCombination(BasisVectors(B), v))));
    od;

    results := [];
    for i in [1..Length(ideals)] do
        k := Dimension(ideals[i]);
        if k > 0 then
            gen_mat := List(BasisVectors(Basis(ideals[i])), 
                           b -> Coefficients(B, b));
            code := GeneratorMatCode(gen_mat, F);
            d := MinimumDistance(code);
            Add(results, [k, d]);
        fi;
    od;
    
    list_max_d:=[];
    for dim in [1..n] do
        dim_codes := Filtered(results, r -> r[1] = dim);
        
        if Length(dim_codes) > 0 then
            max_d := Maximum(List(dim_codes, r -> r[2]));
            Add(list_max_d, max_d);
        else
            Add(list_max_d, -100);
        fi;
    od;
    
    return list_max_d;
end;

LISTBESTD := [
    [],
    [
        [1],
        [2, 1],
        [3, 2, 1],
        [4, 2, 2, 1],
        [5, 3, 2, 2, 1],
        [6, 4, 3, 2, 2, 1],
        [7, 4, 4, 3, 2, 2, 1],
        [8, 5, 4, 4, 2, 2, 2, 1],
        [9, 6, 4, 4, 3, 2, 2, 2, 1],
        [10, 6, 5, 4, 4, 3, 2, 2, 2, 1],
        [11, 7, 6, 5, 4, 4, 3, 2, 2, 2, 1],
        [12, 8, 6, 6, 4, 4, 4, 3, 2, 2, 2, 1],
        [13, 8, 7, 6, 5, 4, 4, 4, 3, 2, 2, 2, 1],
        [14, 9, 8, 7, 6, 5, 4, 4, 4, 3, 2, 2, 2, 1],
        [15, 10, 8, 8, 7, 6, 5, 4, 4, 4, 3, 2, 2, 2, 1],
        [16, 10, 8, 8, 8, 6, 6, 5, 4, 4, 4, 2, 2, 2, 2, 1]
    ],
    [
        [1],
        [2, 1],
        [3, 2, 1],
        [4, 3, 2, 1],
        [5, 3, 2, 2, 1],
        [6, 4, 3, 2, 2, 1],
        [7, 5, 4, 3, 2, 2, 1],
        [8, 6, 5, 4, 3, 2, 2, 1],
        [9, 6, 6, 5, 4, 3, 2, 2, 1],
        [10, 7, 6, 6, 5, 4, 3, 2, 2, 1],
        [11, 8, 7, 6, 6, 5, 3, 3, 2, 2, 1],
        [12, 9, 8, 6, 6, 6, 4, 3, 3, 2, 2, 1],
        [13, 9, 9, 7, 6, 6, 5, 4, 3, 3, 2, 2, 1],
        [14, 10, 9, 8, 7, 6, 6, 5, 4, 3, 2, 2, 2, 1],
        [15, 11, 9, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 2, 1],
        [16, 12, 10, 9, 9, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1]
    ],
    [
        [1],
        [2, 1],
        [3, 2, 1],
        [4, 3, 2, 1],
        [5, 4, 3, 2, 1],
        [6, 4, 4, 2, 2, 1],
        [7, 5, 4, 3, 2, 2, 1],
        [8, 6, 5, 4, 3, 2, 2, 1],
        [9, 7, 6, 5, 4, 3, 2, 2, 1],
        [10, 8, 6, 6, 5, 4, 3, 2, 2, 1],
        [11, 8, 7, 6, 6, 5, 4, 3, 2, 2, 1],
        [12, 9, 8, 7, 6, 6, 4, 4, 3, 2, 2, 1],
        [13, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [14, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [15, 12, 11, 10, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [16, 12, 12, 11, 9, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1]
    ],
    [
        [1],
        [2, 1],
        [3, 2, 1],
        [4, 3, 2, 1],
        [5, 4, 3, 2, 1],
        [6, 5, 4, 3, 2, 1],
        [7, 5, 4, 3, 2, 2, 1],
        [8, 6, 5, 4, 3, 2, 2, 1],
        [9, 7, 6, 5, 4, 3, 2, 2, 1],
        [10, 8, 7, 6, 5, 4, 3, 2, 2, 1],
        [11, 9, 8, 7, 6, 5, 4, 3, 2, 2, 1],
        [12, 10, 8, 8, 6, 6, 5, 4, 3, 2, 2, 1],
        [13, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [14, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [15, 12, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1],
        [16, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1]
    ]
];

# Функция для сортировки групп: сначала абелевы, потом неабелевы
SortGroupsSimple := function(groups)
    local abelian_groups, nonabelian_groups, G;
    
    abelian_groups := [];
    nonabelian_groups := [];
    
    for G in groups do
        if IsAbelian(G) then
            Add(abelian_groups, G);
        else
            Add(nonabelian_groups, G);
        fi;
    od;
    
    # Сортируем внутри каждой категории по названию
    abelian_groups := SortedList(abelian_groups, function(a,b)
        return StructureDescription(a) < StructureDescription(b);
    end);
    
    nonabelian_groups := SortedList(nonabelian_groups, function(a,b)
        return StructureDescription(a) < StructureDescription(b);
    end);
    
    return [abelian_groups, nonabelian_groups];
end;

# Находит лучшую группу в категории (по количеству совпадений с Best)
FindBestGroupInCategory := function(groups, ORD, NElemsF)
    local best_group, best_score, G, list_max_d, score, k, best_list;
    
    best_group := fail;
    best_score := -1;
    best_list := LISTBESTD[NElemsF][ORD];
    
    for G in groups do
        list_max_d := BestGroupCodes(G, GF(NElemsF));
        score := 0;
        
        for k in [1..Minimum(Length(list_max_d), Length(best_list))] do
            if list_max_d[k] = best_list[k] and list_max_d[k] > 0 then
                score := score + 1;
            fi;
        od;
        
        if score > best_score then
            best_score := score;
            best_group := G;
        fi;
    od;
    
    return [best_group, best_score];
end;

MakeTableSorted := function(ORD, NElemsF)
    local G, F, list_max_d, all_groups, sorted_lists, abelian_groups, nonabelian_groups, 
          group_name, best_list, k, max_name_len, i, num_str, cnt, 
          best_abelian_data, best_nonabelian_data, best_abelian_group, best_abelian_score,
          best_nonabelian_group, best_nonabelian_score, cell_width,
          max_abelian_values, max_nonabelian_values, j,
          maxa_cnt, maxn_cnt, filename, output;

    filename:=Concatenation("D:/MATH/sciencework2026/codes/res_tables/Order", String(ORD), "FieldF(", String(NElemsF), ").txt");
    output:=OutputTextFile(filename, false);
    
    all_groups := AllSmallGroups(ORD);
    sorted_lists := SortGroupsSimple(all_groups);
    abelian_groups := sorted_lists[1];
    nonabelian_groups := sorted_lists[2];
    best_list := LISTBESTD[NElemsF][ORD];
    
    # Находим лучшие группы в каждой категории
    best_abelian_data := FindBestGroupInCategory(abelian_groups, ORD, NElemsF);
    best_abelian_group := best_abelian_data[1];
    best_abelian_score := best_abelian_data[2];
    
    best_nonabelian_data := FindBestGroupInCategory(nonabelian_groups, ORD, NElemsF);
    best_nonabelian_group := best_nonabelian_data[1];
    best_nonabelian_score := best_nonabelian_data[2];
    
    # ВЫЧИСЛЯЕМ MAXA - максимальные значения по столбцам для абелевых групп
    max_abelian_values := List([1..ORD], i -> -100);
    for G in abelian_groups do
        list_max_d := BestGroupCodes(G, GF(NElemsF));
        for k in [1..ORD] do
            if list_max_d[k] > max_abelian_values[k] then
                max_abelian_values[k] := list_max_d[k];
            fi;
        od;
    od;
    
    # ВЫЧИСЛЯЕМ MAXN - максимальные значения по столбцам для неабелевых групп
    max_nonabelian_values := List([1..ORD], i -> -100);
    for G in nonabelian_groups do
        list_max_d := BestGroupCodes(G, GF(NElemsF));
        for k in [1..ORD] do
            if list_max_d[k] > max_nonabelian_values[k] then
                max_nonabelian_values[k] := list_max_d[k];
            fi;
        od;
    od;
    
    # Подсчитываем количество совпадений с Best для MAXA и MAXN
    maxa_cnt := 0;
    maxn_cnt := 0;
    for k in [1..ORD] do
        if max_abelian_values[k] = best_list[k] and max_abelian_values[k] > 0 then
            maxa_cnt := maxa_cnt + 1;
        fi;
        if max_nonabelian_values[k] = best_list[k] and max_nonabelian_values[k] > 0 then
            maxn_cnt := maxn_cnt + 1;
        fi;
    od;
    
    # Находим максимальную длину названия группы
    max_name_len := 4;  # "Best"
    for G in Concatenation(abelian_groups, nonabelian_groups) do
        group_name := StructureDescription(G);
        if Length(group_name) > max_name_len then
            max_name_len := Length(group_name);
        fi;
    od;
    
    # Увеличиваем ширину ячейки для двузначных чисел
    cell_width := 5;  # Было 3, теперь 5
    
    AppendTo(output, " Order: ", ORD, "  |  Field: GF(", NElemsF, ")\n\n");
    
    # Заголовки столбцов
    AppendTo(output, "K");
    for i in [1..max_name_len-1] do AppendTo(output, " "); od;
    AppendTo(output, " ");
    for k in [1..ORD] do
        AppendTo(output, String(k, cell_width));
    od;
    AppendTo(output, "\n");
    
    # Разделительная линия
    for i in [1..max_name_len+1] do AppendTo(output, "-"); od;
    for k in [1..ORD] do 
        for j in [1..cell_width] do AppendTo(output, "-"); od;
    od;
    AppendTo(output, "\n");
    
    # Строка Best
    AppendTo(output, "Best");
    for i in [1..max_name_len-4] do AppendTo(output, " "); od;
    AppendTo(output, " ");
    for k in [1..Length(best_list)] do
        AppendTo(output, String(best_list[k], cell_width));
    od;
    AppendTo(output, "\n");
    
    # Строка MAXA - максимумы по столбцам для абелевых групп
    AppendTo(output, "MAXA");
    for i in [1..max_name_len-4] do AppendTo(output, " "); od;
    AppendTo(output, " ");
    for k in [1..ORD] do
        if max_abelian_values[k] = -100 then
            num_str := "-";
        else
            if max_abelian_values[k] = best_list[k] then
                num_str := Concatenation("!", String(max_abelian_values[k]));
            else
                num_str := String(max_abelian_values[k]);
            fi;
        fi;
        AppendTo(output, String(num_str, cell_width));
    od;
    # Выводим счетчик совпадений с Best для MAXA
    if maxa_cnt > 0 then
        AppendTo(output, "  (", maxa_cnt, "/", ORD);
        if maxa_cnt = ORD then
            AppendTo(output, "★)");
        else
            AppendTo(output, ")");
        fi;
    fi;
    AppendTo(output, "\n");
    
    # Строка MAXN - максимумы по столбцам для неабелевых групп
    AppendTo(output, "MAXN");
    for i in [1..max_name_len-4] do AppendTo(output, " "); od;
    AppendTo(output, " ");
    for k in [1..ORD] do
        if max_nonabelian_values[k] = -100 then
            num_str := "-";
        else
            if max_nonabelian_values[k] = best_list[k] then
                num_str := Concatenation("!", String(max_nonabelian_values[k]));
            else
                num_str := String(max_nonabelian_values[k]);
            fi;
        fi;
        AppendTo(output, String(num_str, cell_width));
    od;
    # Выводим счетчик совпадений с Best для MAXN
    if maxn_cnt > 0 then
        AppendTo(output, "  (", maxn_cnt, "/", ORD);
        if maxn_cnt = ORD then
            AppendTo(output, "★)");
        else
            AppendTo(output, ")");
        fi;
    fi;
    AppendTo(output, "\n");
    
    # Двойная разделительная линия
    for i in [1..max_name_len+1] do AppendTo(output, "="); od;
    for k in [1..ORD] do 
        for j in [1..cell_width] do AppendTo(output, "="); od;
    od;
    AppendTo(output, "\n\n");
    
    # Секция абелевых групп
    if Length(abelian_groups) > 0 then
        AppendTo(output, "ABELIAN GROUPS:\n");
        for i in [1..max_name_len+1] do AppendTo(output, "-"); od;
        for k in [1..ORD] do 
            for j in [1..cell_width] do AppendTo(output, "-"); od;
        od;
        AppendTo(output, "\n");
        
        for G in abelian_groups do
            F := GF(NElemsF);
            list_max_d := BestGroupCodes(G, F);
            group_name := StructureDescription(G);
            
            AppendTo(output, group_name);
            for i in [1..max_name_len - Length(group_name)] do
                AppendTo(output, " ");
            od;
            AppendTo(output, " ");
            
            cnt := 0;
            for k in [1..Length(list_max_d)] do
                if list_max_d[k] > 0 then
                    if list_max_d[k] = best_list[k] then
                        num_str := Concatenation("!", String(list_max_d[k]));
                        cnt := cnt + 1;
                    else
                        num_str := String(list_max_d[k]);
                    fi;
                else
                    num_str := "-";
                fi;
                AppendTo(output, String(num_str, cell_width));
            od;
            
            # Статистика оптимальности
            if cnt > 0 then
                AppendTo(output, "  (", cnt, "/", ORD);
                if cnt = ORD then
                    AppendTo(output, "★)");
                elif cnt = best_abelian_score then
                    AppendTo(output, "*)");
                else
                    AppendTo(output, ")");
                fi;
            fi;
            AppendTo(output, "\n");
        od;
        AppendTo(output, "\n");
    fi;
    
    # Секция неабелевых групп
    if Length(nonabelian_groups) > 0 then
        AppendTo(output, "NON-ABELIAN GROUPS:\n");
        for i in [1..max_name_len+1] do AppendTo(output, "-"); od;
        for k in [1..ORD] do 
            for j in [1..cell_width] do AppendTo(output, "-"); od;
        od;
        AppendTo(output, "\n");
        
        for G in nonabelian_groups do
            F := GF(NElemsF);
            list_max_d := BestGroupCodes(G, F);
            group_name := StructureDescription(G);
            
            AppendTo(output, group_name);
            for i in [1..max_name_len - Length(group_name)] do
                AppendTo(output, " ");
            od;
            AppendTo(output, " ");
            
            cnt := 0;
            for k in [1..Length(list_max_d)] do
                if list_max_d[k] > 0 then
                    if list_max_d[k] = best_list[k] then
                        num_str := Concatenation("!", String(list_max_d[k]));
                        cnt := cnt + 1;
                    else
                        num_str := String(list_max_d[k]);
                    fi;
                else
                    num_str := "-";
                fi;
                AppendTo(output, String(num_str, cell_width));
            od;
            
            # Статистика оптимальности
            if cnt > 0 then
                AppendTo(output, "  (", cnt, "/", ORD);
                if cnt = ORD then
                    AppendTo(output, "★)");
                elif cnt = best_nonabelian_score then
                    AppendTo(output, "*)");
                else
                    AppendTo(output, ")");
                fi;
            fi;
            AppendTo(output, "\n");
        od;
        AppendTo(output, "\n");
    fi;
end;
