LoadPackage("meataxe");
LoadPackage("guava");
Read("D:/MATH/sciencework2026/codes/new_tables/code.g");
Read("D:/MATH/sciencework2026/codes/new_tables/final.g");
Read("D:/MATH/sciencework2026/codes/new_tables/main.g");

# Кэш для результатов MinimumDistance
dist_cache := NewDictionary(0, true);

MinDistanceCached := function(mat, F)
    local key, code, d;
    if not IsMatrix(mat) then return 0; fi;
    key := String(mat);
    d := LookupDictionary(dist_cache, key);
    if d = fail then
        code := GeneratorMatCode(mat, F);
        d := MinimumDistance(code);
        AddDictionary(dist_cache, key, d);
    fi;
    return d;
end;

# ===== Таблица лучших известных расстояний для GF(4) (BKLC) =====
# Источник: https://www.codetables.de/BKLC/Tables_color.php?q=4&n0=1&n1=256&k0=1&k1=256
# Для n=21..32 значения взяты как нижние границы указанных диапазонов.
BEST_4 := [
    # n=1
    [ 1 ],
    # n=2
    [ 2, 1 ],
    # n=3
    [ 3, 2, 1 ],
    # n=4
    [ 4, 3, 2, 1 ],
    # n=5
    [ 5, 4, 3, 2, 1 ],
    # n=6
    [ 6, 4, 4, 2, 2, 1 ],
    # n=7
    [ 7, 5, 4, 3, 2, 2, 1 ],
    # n=8
    [ 8, 6, 5, 4, 3, 2, 2, 1 ],
    # n=9
    [ 9, 7, 6, 5, 4, 3, 2, 2, 1 ],
    # n=10
    [ 10, 8, 6, 6, 5, 4, 3, 2, 2, 1 ],
    # n=11
    [ 11, 8, 7, 6, 6, 5, 4, 3, 2, 2, 1 ],
    # n=12
    [ 12, 9, 8, 7, 6, 6, 4, 4, 3, 2, 2, 1 ],
    # n=13
    [ 13, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=14
    [ 14, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=15
    [ 15, 12, 11, 10, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=16
    [ 16, 12, 12, 11, 9, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=17
    [ 17, 13, 12, 12, 10, 9, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=18
    [ 18, 14, 13, 12, 10, 10, 9, 8, 8, 6, 6, 5, 4, 3, 3, 2, 2, 1 ],
    # n=19
    [ 19, 15, 14, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 3, 3, 2, 2, 1 ],
    # n=20
    [ 20, 16, 15, 13, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 3, 3, 2, 2, 1 ],
    # n=21 (использована нижняя граница диапазона)
    [ 21, 16, 16, 14, 13, 12, 11, 10, 9, 8, 7, 7, 6, 5, 5, 4, 3, 3, 2, 2, 1 ],
    # n=22
    [ 22, 17, 16, 15, 14, 12, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=23
    [ 23, 18, 16, 16, 15, 13, 12, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=24
    [ 24, 19, 17, 16, 16, 14, 13, 12, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=25
    [ 25, 20, 18, 17, 16, 15, 14, 12, 12, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=26
    [ 26, 20, 19, 18, 16, 16, 14, 13, 12, 12, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=27
    [ 27, 21, 20, 19, 17, 16, 15, 14, 13, 12, 12, 12, 11, 10, 9, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=28
    [ 28, 22, 20, 20, 18, 17, 16, 15, 14, 12, 12, 12, 12, 11, 10, 8, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=29
    [ 29, 23, 21, 20, 19, 18, 16, 16, 15, 13, 12, 12, 12, 12, 11, 8, 8, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=30
    [ 30, 24, 22, 21, 20, 18, 17, 16, 16, 14, 13, 12, 12, 12, 12, 9, 8, 8, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=31
    [ 31, 24, 23, 22, 20, 19, 18, 17, 16, 15, 14, 13, 12, 12, 12, 10, 9, 8, 8, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ],
    # n=32
    [ 32, 25, 24, 22, 21, 20, 19, 18, 16, 16, 14, 13, 12, 12, 12, 11, 9, 8, 8, 8, 7, 6, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ]
];

# ===== Таблица лучших известных расстояний для GF(5) (BKLC) =====
# Источник: https://www.codetables.de/BKLC/Tables_color.php?q=5&n0=1&n1=130&k0=1&k1=130
# Для n=1..32. Для диапазонов (например, 9-10) взята нижняя граница.
BEST_5 := [
    # n=1
    [ 1 ],
    # n=2
    [ 2, 1 ],
    # n=3
    [ 3, 2, 1 ],
    # n=4
    [ 4, 3, 2, 1 ],
    # n=5
    [ 5, 4, 3, 2, 1 ],
    # n=6
    [ 6, 5, 4, 3, 2, 1 ],
    # n=7
    [ 7, 5, 4, 3, 2, 2, 1 ],
    # n=8
    [ 8, 6, 5, 4, 3, 2, 2, 1 ],
    # n=9
    [ 9, 7, 6, 5, 4, 3, 2, 2, 1 ],
    # n=10
    [ 10, 8, 7, 6, 5, 4, 3, 2, 2, 1 ],
    # n=11
    [ 11, 9, 8, 7, 6, 5, 4, 3, 2, 2, 1 ],
    # n=12
    [ 12, 10, 8, 8, 6, 6, 5, 4, 3, 2, 2, 1 ],
    # n=13
    [ 13, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=14
    [ 14, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=15
    [ 15, 12, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=16
    [ 16, 13, 12, 11, 9, 8, 8, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=17
    [ 17, 14, 12, 11, 10, 9, 8, 7, 7, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=18
    [ 18, 15, 13, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=19
    [ 19, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=20
    [ 20, 16, 15, 14, 13, 12, 10, 9, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=21
    [ 21, 17, 16, 15, 13, 12, 11, 10, 9, 9, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=22
    [ 22, 18, 17, 16, 14, 13, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=23
    [ 23, 19, 18, 17, 15, 14, 13, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=24
    [ 24, 20, 19, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=25
    [ 25, 20, 20, 19, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=26
    [ 26, 21, 20, 20, 17, 16, 16, 14, 14, 12, 12, 11, 10, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 1 ],
    # n=27
    [ 27, 22, 21, 20, 18, 17, 16, 15, 14, 12, 12, 12, 11, 10, 9, 8, 7, 7, 6, 6, 5, 4, 3, 3, 2, 2, 1 ],
    # n=28
    [ 28, 23, 22, 20, 19, 18, 17, 15, 14, 13, 12, 12, 12, 11, 10, 8, 8, 7, 6, 6, 6, 5, 4, 3, 3, 2, 2, 1 ],
    # n=29
    [ 29, 24, 23, 21, 20, 19, 17, 16, 15, 14, 13, 12, 12, 12, 11, 9, 8, 8, 7, 6, 6, 5, 5, 4, 3, 3, 2, 2, 1 ],
    # n=30
    [ 30, 25, 24, 22, 20, 20, 18, 16, 15, 15, 14, 13, 12, 12, 12, 9, 9, 8, 8, 7, 6, 6, 5, 5, 4, 3, 3, 2, 2, 1 ],
    # n=31
    [ 31, 25, 25, 23, 21, 20, 19, 17, 16, 15, 14, 14, 13, 12, 12, 10, 9, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 3, 2, 2, 1 ],
    # n=32
    [ 32, 26, 25, 24, 22, 21, 20, 18, 16, 16, 15, 14, 14, 12, 12, 11, 10, 9, 9, 8, 8, 7, 6, 6, 5, 4, 4, 3, 2, 2, 2, 1 ]
];

# Получение лучшей известной границы из GUAVA
GetBestBound := function(n, k, q)
    local bounds, val;
    if q = 2 then
        bounds := BoundsMinimumDistance(n, k, GF(2));
        if IsBound(bounds.lowerBound) then
            val := bounds.lowerBound;
            if IsInt(val) then
                return val;
            fi;
        fi;
    elif q = 3 then
        bounds := BoundsMinimumDistance(n, k, GF(3));
        if IsBound(bounds.lowerBound) then
            val := bounds.lowerBound;
            if IsInt(val) then
                return val;
            fi;
        fi;
    elif q = 4 then
        # проверяем, что n в пределах таблицы и k корректно
        if n <= Length(BEST_4) and k <= n then
            return BEST_4[n][k];
        else
            return 0;
        fi;
    elif q = 5 then
        if n <= Length(BEST_5) and k <= n then
            return BEST_5[n][k];
        else
            return 0;
        fi;
    fi;
    return 0;
end;

# Основная функция: для группы G и поля F возвращает список максимальных
# минимальных расстояний для каждой размерности k = 1..|G|.
MaxDistancesForGroup := function(G, F)
    local n, subs, maxDist, mat, k, d, i, total;
    n := Size(G);
    if n mod Characteristic(F) = 0 then
        Error("MaxDistancesForGroup: модулярный случай не поддерживается");
    fi;

    subs := SubmodulesRegularModuleByPrimary(G, F);
    total := Length(subs);

    maxDist := ListWithIdenticalEntries(n, 0);

    for i in [1..total] do
        mat := subs[i];
        if IsMatrix(mat) then
            k := NrRows(mat);
            if k > 0 then
                d := MinDistanceCached(mat, F);
                if d > maxDist[k] then
                    maxDist[k] := d;
                fi;
            fi;
        fi;
    od;

    return maxDist;
end;

# Сбор данных по всем группам порядка n над полем q
CollectData := function(n, q)
    local groups, data, G, F, dists, i, name, abelian;
    F := GF(q);
    groups := AllSmallGroups(n);
    data := [];
    for i in [1..Length(groups)] do
        G := groups[i];
        Print("Processing ", i, "/", Length(groups), ": ", StructureDescription(G), "\n");
        dists := MaxDistancesForGroup(G, F);
        name := StructureDescription(G);
        abelian := IsAbelian(G);
        Add(data, rec(name := name, abelian := abelian, dists := dists));
    od;
    return data;
end;

# Выравнивание строки по правому краю до заданной ширины
RightPad := function(str, width)
    local l;
    l := Length(str);
    if l >= width then return str; fi;
    return Concatenation(ListWithIdenticalEntries(width - l, ' '), str);
end;

# Функция для печати таблицы в файл
PrintGroupTable := function(n, q, data, filename)
    local bestValues, maxA, maxN, i, k, abel, nonabel, entry, cnt, file, valStr,
          best_abelian_cnt, best_nonabelian_cnt, abel_list, nonabel_list;

    # Получаем лучшие известные значения из GUAVA
    bestValues := ListWithIdenticalEntries(n, 0);
    for k in [1..n] do
        bestValues[k] := GetBestBound(n, k, q);
    od;

    # Для каждой группы вычисляем cnt — число совпадений с bestValues
    for entry in data do
        entry.cnt := Number([1..n], k -> entry.dists[k] = bestValues[k] and entry.dists[k] > 0);
    od;

    maxA := ListWithIdenticalEntries(n, 0);
    maxN := ListWithIdenticalEntries(n, 0);

    for entry in data do
        for k in [1..n] do
            if entry.abelian then
                if entry.dists[k] > maxA[k] then
                    maxA[k] := entry.dists[k];
                fi;
            else
                if entry.dists[k] > maxN[k] then
                    maxN[k] := entry.dists[k];
                fi;
            fi;
        od;
    od;

        # Определяем лучшие cnt в каждой категории
    abel_list := Filtered(data, e -> e.abelian);
    if Length(abel_list) > 0 then
        best_abelian_cnt := Maximum(List(abel_list, e -> e.cnt));
    else
        best_abelian_cnt := 0;
    fi;

    nonabel_list := Filtered(data, e -> not e.abelian);
    if Length(nonabel_list) > 0 then
        best_nonabelian_cnt := Maximum(List(nonabel_list, e -> e.cnt));
    else
        best_nonabelian_cnt := 0;
    fi;

    file := OutputTextFile(filename, false);
    if file = fail then
        Print("ОШИБКА: не удалось открыть файл ", filename, "\n");
        return;
    fi;
    Print("Файл ", filename, " успешно открыт\n");
    SetPrintFormattingStatus(file, false);

    # Заголовок
    AppendTo(file, "Order: ", n, "  |  Field: GF(", q, ")\n\n");
    AppendTo(file, "K                   "); # 20 символов (K + 19 пробелов)
    for k in [1..n] do
        AppendTo(file, RightPad(String(k), 4));
    od;
    AppendTo(file, "\n------------------------------------------------------------------\n");

    # Best
    AppendTo(file, "Best                "); # 20 символов
    for k in [1..n] do
        if bestValues[k] = 0 then
            valStr := "-";
        else
            valStr := String(bestValues[k]);
        fi;
        AppendTo(file, RightPad(valStr, 4));
    od;
    AppendTo(file, "\n");

    # MAXA
    AppendTo(file, "MAXA                ");
    for k in [1..n] do
        if maxA[k] = 0 then
            valStr := "-";
        else
            if maxA[k] = bestValues[k] then
                valStr := Concatenation("!", String(maxA[k]));
            else
                valStr := String(maxA[k]);
            fi;
        fi;
        AppendTo(file, RightPad(valStr, 4));
    od;
    cnt := Number([1..n], k -> maxA[k] = bestValues[k] and maxA[k] > 0);
    AppendTo(file, "  (", cnt, "/", n, ")\n");

    # MAXN
    AppendTo(file, "MAXN                ");
    for k in [1..n] do
        if maxN[k] = 0 then
            valStr := "-";
        else
            if maxN[k] = bestValues[k] then
                valStr := Concatenation("!", String(maxN[k]));
            else
                valStr := String(maxN[k]);
            fi;
        fi;
        AppendTo(file, RightPad(valStr, 4));
    od;
    cnt := Number([1..n], k -> maxN[k] = bestValues[k] and maxN[k] > 0);
    AppendTo(file, "  (", cnt, "/", n, ")\n");

    AppendTo(file, "==================================================================\n\n");

    # Разделение и сортировка
    abel := Filtered(data, e -> e.abelian);
    nonabel := Filtered(data, e -> not e.abelian);
    Sort(abel, function(a,b) return a.name < b.name; end);
    Sort(nonabel, function(a,b) return a.name < b.name; end);

    # Абелевы группы
    AppendTo(file, "ABELIAN GROUPS:\n");
    AppendTo(file, "------------------------------------------------------------------\n");
    for entry in abel do
        AppendTo(file, entry.name);
        for i in [1..20 - Length(entry.name)] do
            AppendTo(file, " ");
        od;
        for k in [1..n] do
            if entry.dists[k] = 0 then
                valStr := "-";
            else
                if entry.dists[k] = bestValues[k] then
                    valStr := Concatenation("!", String(entry.dists[k]));
                else
                    valStr := String(entry.dists[k]);
                fi;
            fi;
            AppendTo(file, RightPad(valStr, 4));
        od;
        AppendTo(file, "  (", entry.cnt, "/", n);
        if entry.cnt = n then
            AppendTo(file, "★)");
        elif entry.cnt = best_abelian_cnt then
            AppendTo(file, "*)");
        else
            AppendTo(file, ")");
        fi;
        AppendTo(file, "\n");
    od;

    # Неабелевы группы
    AppendTo(file, "\nNON-ABELIAN GROUPS:\n");
    AppendTo(file, "------------------------------------------------------------------\n");
    for entry in nonabel do
        AppendTo(file, entry.name);
        for i in [1..20 - Length(entry.name)] do
            AppendTo(file, " ");
        od;
        for k in [1..n] do
            if entry.dists[k] = 0 then
                valStr := "-";
            else
                if entry.dists[k] = bestValues[k] then
                    valStr := Concatenation("!", String(entry.dists[k]));
                else
                    valStr := String(entry.dists[k]);
                fi;
            fi;
            AppendTo(file, RightPad(valStr, 4));
        od;
        AppendTo(file, "  (", entry.cnt, "/", n);
        if entry.cnt = n then
            AppendTo(file, "★)");
        elif entry.cnt = best_nonabelian_cnt then
            AppendTo(file, "*)");
        else
            AppendTo(file, ")");
        fi;
        AppendTo(file, "\n");
    od;

    CloseStream(file);
    Print("Таблица сохранена в файл: ", filename, "\n");
end;