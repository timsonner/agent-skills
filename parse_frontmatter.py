import os
import re

def main():
    skill_files = []
    for root, dirs, files in os.walk('.'):
        if '.git' in root: continue
        for file in files:
            if file == 'SKILL.md':
                skill_files.append(os.path.join(root, file))

    for f in skill_files[:5]:
        with open(f, 'r') as fp:
            content = fp.read()
        print(f"--- {f} ---")
        m = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
        if m:
            print(m.group(1))
        else:
            print("No frontmatter")

if __name__ == "__main__":
    main()
