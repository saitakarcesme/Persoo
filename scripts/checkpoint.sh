#!/bin/zsh
# Usage: ./scripts/checkpoint.sh 'kayit duzenleme' path/to/file ...
set -euo pipefail
root="${0:A:h:h}"
cd "$root"
if (( $# < 2 )); then
  print -u2 'Kullanim: scripts/checkpoint.sh "kisa aciklama" dosya ...'
  exit 2
fi
summary="$1"
shift
if (( ${#summary} > 55 )); then
  print -u2 'Commit aciklamasini 55 karakterden kisa tut.'
  exit 2
fi
if ! git diff --cached --quiet; then
  print -u2 'Once mevcut staged degisiklikleri incele; betik onlari commit etmez.'
  exit 2
fi
for item in "$@"; do
  if [[ -d "$item" ]]; then
    print -u2 "Klasor yerine tek tek dosya belirt: $item"
    exit 2
  fi
  case "$item" in
    .env|*/.env|.env.*|*/.env.*|*.pem|*.key|*.p12|*.m4a|*.mp4|*.mov|*devices.json*|*inbox.json*)
      print -u2 "Ozel veri veya uretilmis dosya engellendi: $item"
      exit 2 ;;
  esac
done
git add -- "$@"
git diff --cached --check
git diff --cached --stat
if git diff --cached --quiet; then
  print 'Degisiklik yok; bos checkpoint olusturulmadi.'
  exit 0
fi
git commit --quiet -m "checkpoint: $summary"
git log -1 --format='%h %s'
