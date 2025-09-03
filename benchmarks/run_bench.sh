#!/usr/bin/env bash
set -euo pipefail

# Reproducible benchmark runner
# - Prints hardware specs, Dart/Flutter versions
# - Runs tool/benchmark.dart with args
# - Writes JSON and CSV artifacts to benchmarks/out/

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/benchmarks/out"
mkdir -p "$OUT_DIR"

SEED="${SEED:-42}"
ITERATIONS="${ITERATIONS:-80}"
DATASET="${DATASET:-random}"
TS=$(date -u +%Y%m%dT%H%M%SZ)

echo "== System Info =="
uname -a || true
echo "CPU:" && sysctl -n machdep.cpu.brand_string 2>/dev/null || true
echo "Cores:" && sysctl -n hw.ncpu 2>/dev/null || true
echo "Memory (MB):" && (vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+free:\s+(\d+)/ and $free=$1; END { printf("%d\n", $size*$free/1048576) }' 2>/dev/null || true)

echo "== Toolchain =="
dart --version || true
flutter --version || true

echo "== Params =="
echo "Iterations: $ITERATIONS"
echo "Dataset: $DATASET"
echo "Seed: $SEED"

CMD=(dart run "$ROOT_DIR/tool/benchmark.dart" --iterations "$ITERATIONS" --dataset "$DATASET" --seed "$SEED" --json "$OUT_DIR/results-$TS.json" --csv "$OUT_DIR/results-$TS.csv")
echo "> ${CMD[*]}"
"${CMD[@]}"

echo "Artifacts:"
ls -lh "$OUT_DIR" || true
#!/usr/bin/env bash

# Reproducible AlgoMate benchmark runner
# - Logs environment details
# - Runs the Dart benchmark tool
# - Saves human-readable and machine-readable outputs

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> AlgoMate Benchmarks"
echo "Repository: $(basename "$ROOT_DIR")"
echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo "\n==> System"
echo "uname: $(uname -a || true)"
if [[ -f /etc/os-release ]]; then
	echo "OS Release:"
	cat /etc/os-release || true
fi
if [[ -f /proc/cpuinfo ]]; then
	echo "\nCPU Info (first 20 lines):"
	head -n 20 /proc/cpuinfo || true
fi
if command -v sysctl >/dev/null 2>&1; then
	echo "\nCPU (Darwin): $(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)"
	echo "Mem (Darwin bytes): $(sysctl -n hw.memsize 2>/dev/null || true)"
fi

echo "\n==> Dart"
dart --version || true

echo "\n==> Dependencies"
dart pub get

echo "\n==> Running benchmark tool"
echo "(Note: RNG seed is fixed inside tool for reproducibility)"

# Clear previous outputs if exist
rm -f bench_output.txt benchmark_results.json

# Run and tee console output to a file for CI artifact
set +e
dart run tool/benchmark.dart | tee bench_output.txt
STATUS=${PIPESTATUS[0]}
set -e

if [[ $STATUS -ne 0 ]]; then
	echo "Benchmark run failed with status $STATUS" >&2
	exit $STATUS
fi

if [[ ! -f benchmark_results.json ]]; then
	echo "benchmark_results.json not found after run" >&2
	exit 1
fi

echo "\n==> Done"
echo "Console log: $ROOT_DIR/bench_output.txt"
echo "JSON results: $ROOT_DIR/benchmark_results.json"

