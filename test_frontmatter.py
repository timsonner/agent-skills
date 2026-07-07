import os
import re

def update_frontmatter(content):
    m = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
    if not m:
        return content
    front = m.group(1).split('\n')
    body = m.group(2)

    new_front = []

    # Remove existing author and license anywhere in frontmatter
    for line in front:
        if line.strip().startswith('author:'):
            continue
        if line.strip().startswith('license:'):
            continue
        new_front.append(line)

    final_front = []
    inserted = False
    for line in new_front:
        final_front.append(line)
        if line.startswith('description:') and not inserted:
            final_front.append('author: Tim Sonner')
            final_front.append('license: MIT')
            inserted = True

    if not inserted:
        final_front.insert(1, 'author: Tim Sonner') # after name if it was at index 0?
        final_front.insert(2, 'license: MIT')

    return '---\n' + '\n'.join(final_front) + '\n---\n' + body

test_str = """---
name: test
description: A test skill
metadata:
  author: someone
  license: apache
---
# Test"""

print(update_frontmatter(test_str))
