#!/usr/bin/env python3
"""Local heuristic publication scan. Reports locations/categories, never values."""
from pathlib import Path
import re, subprocess, sys
root=Path(__file__).resolve().parents[1]
patterns={
 'private-key':rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
 'service-key':rb'\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{24,}',
 'github-token':rb'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})',
 'aws-access-key':rb'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b',
 'personal-mac-path':rb'/Users/[A-Za-z0-9._-]+/',
}
def scan(label,data):
 findings=[]
 for category,pattern in patterns.items():
  for m in re.finditer(pattern,data):
   line=data[:m.start()].count(b'\n')+1
   findings.append((label,line,category))
 return findings
files=[]
for name in ['README.md','LICENSE','CONTRIBUTING.md','SECURITY.md','CHANGELOG.md','AGENTS.md','VERSION','.gitignore','build.sh','install.sh']:
 p=root/name
 if p.exists(): files.append(p)
for name in ['Source','scripts','tests','docs','.github']:
 files.extend(p for p in (root/name).rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.suffix != '.pyc')
# Include unexpected tracked/untracked publication candidates, not only known folders.
if (root/'.git').exists():
 result=subprocess.run(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=root,capture_output=True,check=True)
 files=sorted(set(files) | {root/name.decode() for name in result.stdout.split(b'\0') if name})
findings=[]
for p in files:
 if p.is_symlink():
  findings.append((str(p.relative_to(root)),1,'symlink-requires-review'))
  continue
 if not p.is_file(): continue
 if p.suffix.lower() not in ['.png','.icns']:
  findings.extend(scan(str(p.relative_to(root)),p.read_bytes()))
# Inspect every reachable historical blob, plus reflogs; never output its content.
git=root/'.git'; objects=0
if git.exists():
 result=subprocess.run(['git','rev-list','--objects','--all','--reflog'],cwd=root,capture_output=True,text=True,check=True)
 for line in result.stdout.splitlines():
  oid=line.split(' ',1)[0]
  kind=subprocess.check_output(['git','cat-file','-t',oid],cwd=root,text=True).strip()
  if kind=='blob':
   objects+=1
   findings.extend(scan('git-blob:'+oid,subprocess.check_output(['git','cat-file','blob',oid],cwd=root)))
for label,line,category in findings: print(f'{label}:{line}: {category}')
print(f'Checked {len(files)} publication files and {objects} historical blobs; {len(findings)} heuristic findings.')
print('This scan is not proof of absence of secrets or a comprehensive vulnerability audit.')
sys.exit(bool(findings))
