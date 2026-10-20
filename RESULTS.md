# Experimental Results

## Unified settings

- Model: Qwen2.5-Omni-3B; English (`en`), MENA, complete dev split (1,000 items per task).
- Inference: 4-bit NF4 quantization and greedy decoding; no fine-tuning in E0–E2.
- Scoring: official default mmBERT configuration. BERTScore-F1 is the primary metric.
- E1 compares prompts with a 64-token output cap. E2 uses the selected evidence prompt with a 32-token cap.
- Results below incorporate the user's 2026-10-20 report that full-dev E1/E2 reruns reproduced the previously supplied metric values. Earlier run logs remain in `EXPERIMENT_RESULTS.md`.

## Task 1 — Spoken Visual QA

Input: image + spoken question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.735861 | 0.687493 | 0.793918 | 9.4574 | 0.248659 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757260 | 0.710530 | 0.813587 | 10.642 | 0.273383 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.761837 | 0.716892 | 0.815736 | 11.026 | 0.277395 | 1.0 |
| E2: Selected generation setting | evidence | 32 | 0.786872 | 0.779164 | 0.797733 | 18.2546 | 0.360756 | 1.0 |

Selected setting: **evidence + 32 tokens**. Next: evaluate transfer of the adapter trained on Task 2.

## Task 2 — Textual Visual QA

Input: image + written question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.739426 | 0.691355 | 0.797229 | 9.581 | 0.250891 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757470 | 0.707780 | 0.818002 | 10.6827 | 0.272292 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.771132 | 0.727347 | 0.822956 | 11.5305 | 0.286341 | 1.0 |
| E2: Selected generation setting | evidence | 32 | 0.795018 | 0.789404 | 0.803265 | 19.0826 | 0.376828 | 1.0 |

Selected setting: **evidence + 32 tokens**. The 64-token reference is the E1 evidence row, not a separate run.

## Prompt definitions

All variants retain the same Qwen system identity.

- **official:** answer in one or two sentences in the target language; give only the answer.
- **expert:** add expertise in cultural heritage and everyday traditions; retain the same length and language request.
- **evidence:** use visible evidence and relevant cultural knowledge, identify specific entities when supported, and avoid unsupported details; retain the same length and language request.

Exact prompt text and generation arguments are recorded in prediction `.meta.json` files.

## Remaining experiments

| ID | Setting | Training data | Evaluation | Status |
|---|---|---|---|---|
| E3 | E2 + QLoRA | Complete English QA train, 10,000 items | Complete QA and SQA dev | Training scripts prepared; training pending |
| E4 | E2 + BM25 RAG | Index built from complete English QA train | Complete QA dev | Not run |
| E5 | E3 + same BM25 RAG | Same adapter and index | Complete QA dev | Not run |

Use `scorer/score_json.py` to save scores without automatically overwriting this table. Update the exact experiment row after evaluation.
