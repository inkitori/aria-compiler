#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-gcd.aria}"
RETURN_VAR="${2:-}"

case "$(uname -s)" in
	Darwin) NASM_FMT=macho64; SYM_PATCH='s/global main/global _main/; s/^main:/_main:/'; LINK_FLAGS="-arch x86_64";;
	Linux)  NASM_FMT=elf64;   SYM_PATCH='';                                                LINK_FLAGS="";;
	*) echo "unsupported: $(uname -s)" >&2; exit 1;;
esac

[ -f "$INPUT" ] || { echo "no such file: $INPUT" >&2; exit 1; }

mkdir -p build
g++ src/*.cpp -o build/aria 2>/dev/null

[ "$INPUT" = 'gcd.aria' ] || cp -- "$INPUT" 'gcd.aria'
RAW="$(./build/aria 2>&1)"

ASM="$(printf '%s\n' "$RAW" | sed -n '/-----GENERATING ASSEMBLY-----/,$ p' | tail -n +2)"

if [ -n "$RETURN_VAR" ]; then
	OFFSET="$(printf '%s\n' "$RAW" \
		| grep -oE 'Variable\([^)]+\)' \
		| sed 's/Variable(\(.*\))/\1/' \
		| awk '!seen[$0]++' \
		| awk -v t="$RETURN_VAR" '$0 == t { print NR * 8; exit }')"
	[ -n "$OFFSET" ] || { echo "variable '$RETURN_VAR' not found" >&2; exit 1; }
	ASM="$(printf '%s\n' "$ASM" | awk -v inj=$'\tmov\trax, [rbp-'"$OFFSET"$']' '/^\tmov \trsp, rbp$/ { print inj } { print }')"
fi

[ -n "$SYM_PATCH" ] && ASM="$(printf '%s\n' "$ASM" | sed "$SYM_PATCH")"

mkdir -p build
printf '%s\n' "$ASM" > build/out.asm
nasm -f"$NASM_FMT" build/out.asm -o build/out.o
clang $LINK_FLAGS -o build/out build/out.o 2>/dev/null

set +e
./build/out
EXIT=$?
set -e
echo "exit=$EXIT"
