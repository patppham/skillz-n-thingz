---
name: local-model
description: Manage local model operations on the headless PC, including installation, configuration, conversion, fine-tuning, and benchmarking.
---

# Local Model Operations Skill

Use this skill when installing, configuring, running, converting, fine-tuning, or benchmarking LLMs on the local headless PC (IP: 192.168.1.100).

---

## 1. Installation & Server Configuration

### Downloading GGUF Models
To download new GGUF models directly to the PC from Hugging Face:
1. SSH into the PC:
   ```bash
   ssh -i ~/.ssh/id_local_pc -o StrictHostKeyChecking=no developer@192.168.1.100
   ```
2. Navigate to the model directory:
   ```powershell
   cd C:\Gemma-Server
   ```
3. Use a PowerShell script or curl to download the GGUF file:
   ```powershell
   Invoke-WebRequest -Uri "https://huggingface.co/lmstudio-community/gemma-2-9b-it-GGUF/resolve/main/gemma-2-9b-it-Q4_K_M.gguf" -OutFile "gemma-2-9b-it-Q4_K_M.gguf"
   ```

### Optimal Server Configurations
When running a model like **Gemma 2 9B** on the GPU (RTX 2080 Ti, 11GB VRAM), use the following configuration flags for llama-server:
- `-c 65536`: Sets context window to 64k (adjust based on VRAM).
- `-ctk q8_0 -ctv q8_0`: Quantizes the key-value cache to 8-bit to double the max context length within VRAM limits.
- `-fa on`: Enables Flash Attention (critical for 8-bit KV cache and performance).
- `-ngl 99`: Offloads all layers to the GPU.
- `--host 0.0.0.0 --port 8080`: Binds the server to the local LAN.

### Spawning the Server Detached
To run `llama-server.exe` in the background so it survives SSH disconnections, start it using Windows Management Instrumentation (`wmic`):
```bash
ssh -i ~/.ssh/id_local_pc -o StrictHostKeyChecking=no developer@192.168.1.100 "wmic process call create 'cmd.exe /c C:\\Gemma-Server\\start_server.bat'"
```

To stop the server:
```bash
ssh -i ~/.ssh/id_local_pc -o StrictHostKeyChecking=no developer@192.168.1.100 "powershell -Command \"Stop-Process -Name llama-server -Force -ErrorAction SilentlyContinue\""
```

### Accessing the Web UI & API
When `llama-server` is running, you can access its built-in playground chat UI or utilize its OpenAI-compatible API:
- **Web UI (Chat Playground):** Go to [http://192.168.1.100:8080/](http://192.168.1.100:8080/) in your browser.
- **OpenAI API Endpoints:**
  - Chat completions: `http://192.168.1.100:8080/v1/chat/completions`
  - Text completions: `http://192.168.1.100:8080/v1/completions`

---

## 2. Fine-Tuning Models

To run PyTorch-based fine-tuning on the RTX 2080 Ti:
1. Ensure Python 3.10+, PyTorch (CUDA-enabled), and dependencies are installed.
2. Recommended libraries: **Unsloth** (maximizes GPU speed) or **Hugging Face PEFT/Lora**.
3. Save the trained adapter (LoRA weights) or export the merged FP16 PyTorch model weights.

### Converting and Quantizing to GGUF
To run your fine-tuned model in `llama-server`, convert and quantize it:
1. **Convert to FP16 GGUF:**
   Using the `convert_hf_to_gguf.py` script:
   ```powershell
   python convert_hf_to_gguf.py C:\Models\my-fine-tuned-model --outfile C:\Gemma-Server\my-model-f16.gguf
   ```
2. **Quantize to Q4_K_M or Q8_0:**
   Use the `llama-quantize` tool:
   ```powershell
   & "C:\Gemma-Server\llama-quantize.exe" C:\Gemma-Server\my-model-f16.gguf C:\Gemma-Server\my-model-Q4_K_M.gguf Q4_K_M
   ```

---

## 3. Benchmarking Local Models

We use `lm-evaluation-harness` to run a comprehensive suite of 19 benchmarks covering reasoning, math, commonsense, natural language inference, and knowledge directly on the PC.

### Prerequisites
1. **Install Python:** Ensure Python 3.10+ is installed. If not present:
   ```powershell
   winget install Python.Python.3.11
   ```
2. **Install lm-eval:** Run the following command in PowerShell:
   ```powershell
   pip install lm-eval[api]
   ```

### Execution
Run the evaluation harness from PowerShell, targeting the local model server:
```powershell
lm_eval --model local-chat-completions --model_args model="gemma-2-9b-it-Q4_0.gguf",base_url="http://localhost:8080/v1",num_concurrent=10 --tasks mmlu,arc_challenge,gsm8k,bbh,truthfulqa,piqa,hellaswag,winogrande,boolq,drop,triviaqa,nq_open,sciq,qnli,gpqa,openbookqa,anli_r1,anli_r2,anli_r3 --apply_chat_template --output_path C:\Gemma-Server\gemma_harness_results.json
```
