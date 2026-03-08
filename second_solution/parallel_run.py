import subprocess
import os
import multiprocessing
import time
import re

# ===== НАСТРОЙКИ =====
GAP_ROOT = r"C:\Program Files\GAP-4.15.1"
GAP_EXE = os.path.join(GAP_ROOT, "runtime", "opt", "gap-4.15.1", "gap.exe")
DLL_DIR = os.path.join(GAP_ROOT, "runtime", "bin")

PRINT2_PATH = r"D:/MATH/sciencework2026/codes/new_tables/print2.g"
EXPORT_DIR = r"D:/MATH/sciencework2026/codes/new_tables/export"
TEMP_DIR = os.path.join(EXPORT_DIR, "temp")

MAX_WORKERS = min(multiprocessing.cpu_count(), 8)
TIMEOUT = 1800 #7200

# ===== ПРОВЕРКА =====
for path in [GAP_EXE, DLL_DIR, PRINT2_PATH]:
    if not os.path.exists(path):
        raise FileNotFoundError(f"❌ {path} не найден")

os.makedirs(EXPORT_DIR, exist_ok=True)
os.makedirs(TEMP_DIR, exist_ok=True)

# Читаем print2.g один раз
with open(PRINT2_PATH, "r", encoding="utf-8") as f:
    PRINT2_CONTENT = f.read()

# ===== КЭШ ДЛЯ КОЛИЧЕСТВА ГРУПП =====
group_counts = {}

def get_group_count(n):
    if n in group_counts:
        return group_counts[n]
    script = f'Print(Length(AllSmallGroups({n}))); QUIT;\n'
    env = os.environ.copy()
    env["PATH"] = DLL_DIR + ";" + env.get("PATH", "")
    cmd = [GAP_EXE, "-b", "-q"]
    proc = subprocess.run(
        cmd,
        input=script,
        text=True,
        encoding='utf-8',
        errors='replace',
        capture_output=True,
        env=env,
        creationflags=subprocess.CREATE_NO_WINDOW
    )
    output = proc.stdout + proc.stderr
    match = re.search(r'\b(\d+)\b', output)
    if match:
        cnt = int(match.group(1))
        group_counts[n] = cnt
        return cnt
    else:
        print(f"⚠️ Could not parse group count for n={n}. Output: {output}")
        group_counts[n] = 0
        return 0

# ===== ФУНКЦИЯ ДЛЯ ОБРАБОТКИ ОДНОЙ ГРУППЫ =====
def process_one_group(n, q, idx):
    temp_file = os.path.join(TEMP_DIR, f"temp_{n}_{q}_{idx}.txt").replace("\\", "/")
    log_file = os.path.join(TEMP_DIR, f"log_{n}_{q}_{idx}.txt").replace("\\", "/")
    print(f"[START] Ord{n} F{q}")
    gap_script = PRINT2_CONTENT + f"""

groups := AllSmallGroups({n});
if {idx} > Length(groups) then
    Print("Error: index out of range\\n");
    QUIT;
fi;
G := groups[{idx}];
dists := MaxDistancesForGroup(G, GF({q}));
PrintTo("{temp_file}", StructureDescription(G), "\\n", IsAbelian(G), "\\n", dists, "\\n");
QUIT;
"""

    env = os.environ.copy()
    env["PATH"] = DLL_DIR + ";" + env.get("PATH", "")
    cmd = [GAP_EXE, "-b", "-q"]
    try:
        proc = subprocess.run(
            cmd,
            input=gap_script,
            text=True,
            encoding='utf-8',
            errors='replace',
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            timeout=TIMEOUT,
            creationflags=subprocess.CREATE_NO_WINDOW,
            check=False
        )
        with open(log_file, "w", encoding="utf-8") as f:
            f.write(f"Return code: {proc.returncode}\n")
            f.write("--- stdout ---\n")
            f.write(proc.stdout if proc.stdout else "")
            f.write("--- stderr ---\n")
            f.write(proc.stderr if proc.stderr else "")

        if proc.returncode != 0:
            print(f"[ERROR] group {n}/{q}/{idx} returned {proc.returncode}")
            with open(log_file, "r", encoding="utf-8") as lf:
                print(lf.read())
            return False

        if os.path.exists(temp_file):
            return True
        else:
            print(f"[ERROR] group {n}/{q}/{idx} did not create {temp_file}")
            with open(log_file, "r", encoding="utf-8") as lf:
                print(lf.read())
            return False
        print(f"[DONE] Ord{n} F{q}")
    except subprocess.TimeoutExpired:
        print(f"[ERROR] group {n}/{q}/{idx} timed out after {TIMEOUT}s")
        return False
    except Exception as e:
        print(f"[ERROR] group {n}/{q}/{idx}: {e}")
        return False

# ===== СБОР РЕЗУЛЬТАТОВ И СОХРАНЕНИЕ ТАБЛИЦЫ =====
def collect_and_save(n, q, num_groups):
    data = []
    for idx in range(1, num_groups + 1):
        temp_file = os.path.join(TEMP_DIR, f"temp_{n}_{q}_{idx}.txt")
        if not os.path.exists(temp_file):
            print(f"[WARN] Missing temp file for {n}/{q}/{idx}")
            continue
        with open(temp_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
            if len(lines) < 3:
                print(f"[WARN] Incomplete temp file for {n}/{q}/{idx}")
                continue
            name = lines[0].strip()
            abelian = (lines[1].strip() == "true")
            dists_str = lines[2].strip().strip('[]')
            dists = [int(x) for x in dists_str.split(',') if x.strip()] if dists_str else []
            data.append({"name": name, "abelian": abelian, "dists": dists})
        os.remove(temp_file)

    if not data:
        print(f"⚠️ No data for n={n}, q={q}")
        return

    field_dir = os.path.join(EXPORT_DIR, f"F{q}")
    os.makedirs(field_dir, exist_ok=True)
    outfile = os.path.join(field_dir, f"Ord{str(n).zfill(2)}.txt").replace("\\", "/")

    data_str = "data := [\n"
    for entry in data:
        data_str += f'  rec(name := "{entry["name"]}", abelian := {str(entry["abelian"]).lower()}, dists := {entry["dists"]}),\n'
    data_str += "];\n"

    gap_script = PRINT2_CONTENT + "\n" + data_str + f"""
Print("Calling PrintGroupTable for n={n}, q={q}, outfile={outfile}\\n");
if IsBound(PrintGroupTable) then
    Print("PrintGroupTable is bound\\n");
else
    Print("PrintGroupTable is NOT bound\\n");
fi;
PrintGroupTable({n}, {q}, data, "{outfile}");
Print("PrintGroupTable finished\\n");
QUIT;
"""
    env = os.environ.copy()
    env["PATH"] = DLL_DIR + ";" + env.get("PATH", "")
    proc = subprocess.run(
        [GAP_EXE, "-b", "-q"],
        input=gap_script,
        text=True,
        encoding='utf-8',
        errors='replace',
        capture_output=True,
        env=env,
        creationflags=subprocess.CREATE_NO_WINDOW
    )
    if proc.returncode != 0 or not os.path.exists(outfile):
        print(f"[ERROR] Failed to generate table for n={n}, q={q}")
        print("--- stdout ---")
        print(proc.stdout)
        print("--- stderr ---")
        print(proc.stderr)
    else:
        print(f"[!OK!] Table saved Ord{n} F{q}: {outfile}")

# ===== ОСНОВНАЯ ФУНКЦИЯ =====
def main():
    print(f"Using up to {MAX_WORKERS} parallel workers")
    print(f"GAP: {GAP_EXE}")
    print(f"Print2.g: {PRINT2_PATH}")
    print(f"Export dir: {EXPORT_DIR}")

    # Собираем все допустимые пары (n,q) и формируем список задач
    tasks = []
    for n in range(2, 33):
        cnt = get_group_count(n)
        if cnt == 0:
            continue
        for q in [2, 3, 4, 5]:
            char = 2 if q==4 else q
            if n % char == 0:
                continue
            for idx in range(1, cnt + 1):
                tasks.append((n, q, idx))

    total_tasks = len(tasks)
    print(f"Total tasks: {total_tasks}")

    start_time = time.time()
    with multiprocessing.Pool(processes=MAX_WORKERS) as pool:
        results = pool.starmap(process_one_group, tasks)
    elapsed = time.time() - start_time
    print(f"All group computations finished in {elapsed:.2f}s")

    # Сбор результатов и сохранение таблиц
    for n in range(2, 33):
        cnt = group_counts.get(n, 0)
        if cnt == 0:
            continue
        for q in [2, 3, 4, 5]:
            char = 2 if q==4 else q
            if n % char == 0:
                continue
            collect_and_save(n, q, cnt)

    print("\nAll tasks completed.")

if __name__ == "__main__":
    main()