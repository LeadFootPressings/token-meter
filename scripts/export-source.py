#!/usr/bin/env python3
"""Create a local review-only source ZIP from audited Git publication candidates."""
from pathlib import Path
import hashlib, subprocess, zipfile
root=Path(__file__).resolve().parents[1]
subprocess.run(['python3',str(root/'scripts/audit.py')],cwd=root,check=True)
version=(root/'VERSION').read_text().strip()
output=root/'dist'/f'Token-Meter-{version}-source-review.zip'
output.parent.mkdir(exist_ok=True)
if output.exists(): raise SystemExit('Source package exists; archive it before exporting again.')
result=subprocess.run(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=root,capture_output=True,check=True)
files=sorted(set(name.decode() for name in result.stdout.split(b'\0') if name))
if not files: raise SystemExit('No publication candidates found; use the prepared Git workspace.')
for name in files:
 p=root/name
 if p.is_symlink() or not p.is_file(): raise SystemExit(f'Not an ordinary source file: {name}')
 if name.split('/')[0] in ('.local-preparation','build','dist','.git'):
  raise SystemExit(f'Private/generated path must not be tracked: {name}')
with zipfile.ZipFile(output,'x',compression=zipfile.ZIP_DEFLATED) as archive:
 for name in files: archive.write(root/name,'token-meter/'+name)
with zipfile.ZipFile(output) as archive:
 assert archive.testzip() is None
 for name in files: assert archive.read('token-meter/'+name)==(root/name).read_bytes()
sha=hashlib.sha256(output.read_bytes()).hexdigest()
output.with_suffix(output.suffix+'.sha256').write_text(f'{sha}  {output.name}\n')
print(f'Created and verified {len(files)} source files in {output.name}. No publication performed.')
