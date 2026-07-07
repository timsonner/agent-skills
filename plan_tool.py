import os
import glob
import re

def update_frontmatter():
    skill_files = []
    for root, dirs, files in os.walk('.'):
        if '.git' in root: continue
        for file in files:
            if file == 'SKILL.md':
                skill_files.append(os.path.join(root, file))

    for filepath in skill_files:
        with open(filepath, 'r') as f:
            content = f.read()

        m = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
        if m:
            frontmatter = m.group(1)
            body = m.group(2)

            lines = frontmatter.split('\n')
            new_lines = []
            has_author = False
            has_license = False
            metadata_idx = -1

            for i, line in enumerate(lines):
                if line.startswith('author:'):
                    has_author = True
                elif line.startswith('license:'):
                    has_license = True
                elif line.startswith('metadata:'):
                    metadata_idx = i

            # This is a bit naive, we should use PyYAML but let's just make a simple plan for now.
