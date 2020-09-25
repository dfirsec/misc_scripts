import os
import sys

try:
    from tqdm import tqdm
except Exception as e:
    sys.exit("\033[91m[ERROR]\033[0m Please install tqdm: 'pip install tqdm'")


if len(sys.argv) < 2 or not os.path.exists(sys.argv[1]):
    sys.exit("\n\033[91m[ERROR]\033[0m Please include a valid directory, e.g. c:\\")  # nopep8
else:
    base_path = sys.argv[1]

outfile = f"empty_dirs.txt"
exclude = set(['Windows', 'Desktop'])

f = open(outfile, 'w')
try:
    cnt = 0
    for dirpath, dirnames, files in tqdm(os.walk(base_path, topdown=True),
                                         desc="\033[33m> Scanning for empty directories\033[0m",
                                         unit=" files"):
        dirnames[:] = [d for d in dirnames if not d.startswith('.') and d not in exclude]  # nopep8
        if len(files) == 0 and len(dirnames) == 0:
            cnt += 1
            f.write(dirpath + '\n')
    f.close()
    print(f"> Found {cnt:,} emtpy directories.")
    print(f"> Results written to: \033[96m{os.path.abspath(outfile)}\033[0m")
except KeyboardInterrupt:
    f.close()
    os.remove(outfile)  # remove unfinished output file
    sys.exit("\033[92m> Script Terminated!\033[0m")
