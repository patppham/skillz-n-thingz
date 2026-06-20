#!/bin/bash

# Default values
BASE_URL="http://192.168.50.110:8080/v1"
MODEL_NAME="gemma-4-E4B-it-Q4_0.gguf"
TASKS="mmlu,arc_challenge,gsm8k,bbh,truthfulqa,piqa,hellaswag,winogrande,boolq,drop,triviaqa,nq_open,sciq,qnli,gpqa,openbookqa,anli_r1,anli_r2,anli_r3"

if [ -z "$1" ]; then
    echo "Usage: $0 <output_json_path> [base_url] [model_name]"
    exit 1
fi

OUTPUT_PATH="$1"
if [ ! -z "$2" ]; then
    BASE_URL="$2"
fi
if [ ! -z "$3" ]; then
    MODEL_NAME="$3"
fi

echo "🚀 Starting lm-evaluation-harness benchmark..."
echo "📍 Model Endpoint: $BASE_URL"
echo "🏷️ Model Name: $MODEL_NAME"
echo "📊 Tasks: $TASKS"

# Detect if virtualenv bin is available relative to script path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_BIN="$SCRIPT_DIR/../../../../scratch/lm_eval_venv/bin/lm_eval"

if [ -f "$VENV_BIN" ]; then
    LM_EVAL_CMD="$VENV_BIN"
    echo "Using local virtual environment: $VENV_BIN"
else
    LM_EVAL_CMD="lm_eval"
    echo "Using system-wide lm_eval command"
fi

# Run the benchmark
# Using local-chat-completions model backend which connects to OpenAI-compatible endpoints
$LM_EVAL_CMD \
    --model local-chat-completions \
    --model_args model="$MODEL_NAME",base_url="$BASE_URL",num_concurrent=10 \
    --tasks "$TASKS" \
    --apply_chat_template \
    --output_path "$OUTPUT_PATH"

echo "✅ Benchmark completed! Results saved to $OUTPUT_PATH"
