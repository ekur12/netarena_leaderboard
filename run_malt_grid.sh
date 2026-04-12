#!/bin/bash
set -euo pipefail

TEMPLATE="malt_scenario.template.toml"
TARGET="malt_scenario.toml"

# Toggle this:
# true  -> only print what would happen
# false -> actually git add / commit / push
DRY_RUN=false

MODELS=(
    "openai/moonshotai/Kimi-K2-Thinking"
    "openai/nvidia/nemotron-3-super-120b-a12b"
    "openai/Qwen/Qwen3-Next-80B-A3B-Thinking"
    "openai/Qwen/Qwen3-235B-A22B-Thinking-2507"
    "openai/openai/gpt-oss-120b"
    "openai/meta-llama/Llama-3.3-70B-Instruct"
    "openai/deepseek-ai/DeepSeek-V3-0324"
    "openai/Qwen/Qwen3-30B-A3B-Thinking-2507"
    "openai/Qwen/Qwen3-Coder-480B-A35B-Instruct"
    "openai/Qwen/Qwen3-Coder-30B-A3B-Instruct"
    "openai/Qwen/Qwen3-235B-A22B-Instruct-2507"
    "openai/Qwen/Qwen3-30B-A3B-Instruct-2507"
    "openai/deepseek-ai/DeepSeek-V3.2"
)

MODEL_IDS=(
    "Kimi-K2-Thinking"
    "nemotron-3-super-120b-a12b"
    "Qwen3-Next-80B-A3B-Thinking"
    "Qwen3-235B-A22B-Thinking-2507"
    "gpt-oss-120b"
    "Llama-3.3-70B-Instruct"
    "DeepSeek-V3-0324"
    "Qwen3-30B-A3B-Thinking-2507"
    "Qwen3-Coder-480B-A35B-Instruct"
    "Qwen3-Coder-30B-A3B-Instruct"
    "Qwen3-235B-A22B-Instruct-2507"
    "Qwen3-30B-A3B-Instruct-2507"
    "DeepSeek-V3.2"
)

PROMPTS=(
#   "zeroshot_base"
  "zeroshot_cot"
  "fewshot_base"
  "fewshot_cot"
)

# NUM_QUERIES_LIST=(3)
# NUM_QUERIES_LIST=(4 5)
NUM_QUERIES_LIST=(3 4 5)

for i in "${!MODELS[@]}"; do
  MODEL="${MODELS[$i]}"
  MODEL_ID="${MODEL_IDS[$i]}"

  for PROMPT in "${PROMPTS[@]}"; do
    for NQ in "${NUM_QUERIES_LIST[@]}"; do
      echo "=================================================="
      echo "MODEL      : $MODEL"
      echo "MODEL_ID   : $MODEL_ID"
      echo "PROMPT     : $PROMPT"
      echo "NUM_QUERIES: $NQ"
      echo "=================================================="

      python3 - <<PY
from pathlib import Path

template = Path("$TEMPLATE").read_text()
content = (
    template
    .replace("__MODEL_NAME__", """$MODEL""")
    .replace("__PROMPT_TYPE__", "$PROMPT")
    .replace("__NUM_QUERIES__", "$NQ")
)
Path("$TARGET").write_text(content)
print("Wrote $TARGET")
print("------ GENERATED FILE ------")
print(content)
print("----------------------------")
PY

      COMMIT_MSG="MALT w/ ${MODEL_ID} ${PROMPT} num_queries=${NQ} benchmark"

      if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would run: git add $TARGET"
        echo "[DRY RUN] Would run: git commit -m \"$COMMIT_MSG\""
        echo "[DRY RUN] Would run: git push"
      else
        git add "$TARGET"
        git commit -m "$COMMIT_MSG" || echo "Nothing to commit for $COMMIT_MSG"
        git push
      fi
    done
  done
done