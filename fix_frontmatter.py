import os
import re
import sys
import yaml

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    m = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
    if not m:
        return False

    frontmatter_text = m.group(1)
    body = m.group(2)

    try:
        data = yaml.safe_load(frontmatter_text)
        if not isinstance(data, dict):
            return False
    except yaml.YAMLError:
        # Fallback to simple regex parsing/editing if YAML fails to parse correctly due to formatting
        return False

    # The requirement is: "specifically author and license. we should do MIT and Tim Sonner as author"

    # We want these fields at the top level of the frontmatter if they exist, or insert them.
    # We will remove them if they are incorrectly placed inside metadata maybe?
    # Actually just set them at root level.
    data['author'] = 'Tim Sonner'
    data['license'] = 'MIT'

    # If they are in metadata we can remove them to avoid duplication.
    if 'metadata' in data and isinstance(data['metadata'], dict):
        if 'author' in data['metadata']:
            del data['metadata']['author']
        if 'license' in data['metadata']:
            del data['metadata']['license']

    # Serialize back to yaml
    # We want to preserve the order somewhat, but pyyaml doesn't preserve order of dicts well by default in older versions,
    # though in python 3.7+ dicts preserve order. We'll dump it nicely.
    new_frontmatter = yaml.dump(data, sort_keys=False, default_flow_style=False, allow_unicode=True)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('---\n')
        f.write(new_frontmatter)
        f.write('---')
        # make sure to preserve newline after frontmatter
        if not body.startswith('\n'):
            f.write('\n')
        f.write(body)

    return True

def main():
    skill_files = []
    for root, dirs, files in os.walk('.'):
        if '.git' in root: continue
        for file in files:
            if file == 'SKILL.md':
                skill_files.append(os.path.join(root, file))

    for filepath in skill_files:
        process_file(filepath)

if __name__ == "__main__":
    main()
