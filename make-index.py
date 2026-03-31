from pathlib import Path

files = [f for f in Path().iterdir() if f.suffix == '.svg']

with open('index.html','w') as f:
    f.write(f'''<!doctype html>
<html>
    <body>
        <ul>''')
    for p in sorted(files, key=lambda p: p.stat().st_mtime,reverse=True):
        f.write(f'''<li><a download href="{p.name}">{p.name}</a></li>''')
    f.write(f'''</ul>
</body>
</html>''')
        
