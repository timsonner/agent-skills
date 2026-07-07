import glob
files = glob.glob('pentest/tools/*/SKILL.md')
print(f"Found {len(files)} individual tool files.")
with open('pentest/tools/SKILL.md', 'r') as f:
    master = f.read()

count_in_master = 0
for file in files:
    tool_name = file.split('/')[-2]
    if tool_name.lower() in master.lower():
        count_in_master += 1

print(f"{count_in_master} tools mentioned in master file")
