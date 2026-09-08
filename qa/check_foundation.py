"""Check the foundation artifacts and synthetic scenario, without app claims."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = ['README.md', 'docs/product.md', 'docs/architecture.md', 'docs/design.md',
            'docs/privacy.md', 'docs/ai-state-model.md', 'docs/video.md']
for name in required:
    assert (root / name).is_file(), name
sources = list(root.glob('*.md')) + [p for folder in ['docs', 'design', 'film', 'qa'] for p in (root / folder).glob('*.md')]
for source in sources:
    if '.git' in source.parts:
        continue
    for target in re.findall(r'\]\(([^)]+)\)', source.read_text()):
        if '://' in target or target.startswith('#'):
            continue
        assert (source.parent / target.split('#')[0]).exists(), (source, target)
fixtures = json.loads((root / 'design/fixtures.json').read_text())
assert fixtures['synthetic'] is True
assert len({t['id'] for t in fixtures['transactions']}) == 12
assert all(t['currency'] == 'EUR' for t in fixtures['transactions'])
assert sum(t['amountMinor'] for t in fixtures['transactions']) == 7400
assert fixtures['transactions'][-1]['amountMinor'] == 620
assert fixtures['scenario']['potentialMinor'] == [7400*m for m in [1, 6, 12]]
assert fixtures['scenario']['potentialMinor'][-1] < fixtures['plan']['targetMinor']

def luminance(h):
    rgb = [int(h[i:i+2], 16)/255 for i in (1, 3, 5)]
    linear = [v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4 for v in rgb]
    return sum(a*b for a, b in zip(linear, [.2126, .7152, .0722]))

def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi+.05)/(lo+.05)

colors = json.loads((root / 'design/tokens.json').read_text())['colors']
for mode, i in [('light', 0), ('dark', 1)]:
    for text in ['ink', 'secondary', 'accent', 'danger']:
        ratio = contrast(colors[text][i], colors['canvas'][i])
        assert ratio >= 4.5, (mode, text, ratio)
        print(f'{mode}: {text}/canvas {ratio:.2f}:1')
print('PASS: required docs, local links, synthetic arithmetic and proposed text contrast')
print('Runtime app not tested; separate design and video checks are documented in qa/local-production.md')
