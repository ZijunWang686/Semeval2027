# Experimental Results

## Same-backend control — 2026-10-21

Fixed 200 paired dev IDs, evidence/32, ms-swift PT for both base and E3. E3 predictions are extracted from the completed full-dev run. These control results are separate from the full-dev tables below.

| Task | Model | N | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Task 2 QA | Base, no adapter | 200 | 0.806181 | 0.809083 | 0.805495 | 19.1973 | 0.399252 | 1.0 |
| Task 2 QA | E3 adapter | 200 | 0.853217 | 0.860313 | 0.848031 | 30.3449 | 0.505105 | 1.0 |
| Task 1 SQA | Base, no adapter | 200 | 0.799018 | 0.801613 | 0.799155 | 18.567 | 0.383989 | 1.0 |
| Task 1 SQA | E3 adapter | 200 | 0.850415 | 0.857458 | 0.845306 | 29.632 | 0.497709 | 1.0 |

QA F1 difference: **+0.047036**; SQA F1 difference: **+0.051397**, with the adapter under the same inference backend. Both controls are complete. Joint training data preparation is complete: smoke 100+100, small 1000+1000, full 10000+10000; each task has 1000 dev items. Training audio duration: 2.081–12.022 seconds (mean 5.627 seconds).

## Unified settings

- Model: Qwen2.5-Omni-3B; English (`en`), MENA, complete dev split (1,000 items per task).
- Inference: 4-bit NF4 quantization and greedy decoding; no fine-tuning in E0–E2.
- Scoring: official default mmBERT configuration. BERTScore-F1 is the primary metric.
- E1 compares prompts with a 64-token output cap. E2 uses the selected evidence prompt with a 32-token cap.
- Results below incorporate the user's 2026-10-20 report that full-dev E1/E2 reruns reproduced the previously supplied metric values. Earlier run logs remain in `EXPERIMENT_RESULTS.md`.

## E3 — LoRA configuration

| Setting | Value |
|---|---|
| Method | QLoRA · 4-bit NF4 · BF16 compute |
| LoRA | Rank **8** · Alpha **16** · Dropout **0.05** |
| Training data | Task 2 English train (image + written question) · **10,000 items** |
| Training | **1 epoch** · Learning rate **1e-4** |
| Batch | **1** × gradient accumulation **8** = effective batch **8** |
| Trainable modules | LoRA on language-model linear layers; base weights, vision/audio encoders and aligner frozen |
| Evaluation | Same adapter for both tasks · **evidence** prompt · **32 tokens** · full dev |

## Task 1 — Spoken Visual QA

Input: image + spoken question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.735861 | 0.687493 | 0.793918 | 9.4574 | 0.248659 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757260 | 0.710530 | 0.813587 | 10.642 | 0.273383 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.761837 | 0.716892 | 0.815736 | 11.026 | 0.277395 | 1.0 |
| E2: Selected generation setting | evidence | 32 | 0.786872 | 0.779164 | 0.797733 | 18.2546 | 0.360756 | 1.0 |
| E3: Task 2 QLoRA transfer | evidence | 32 | 0.844881 | 0.852787 | 0.838761 | 28.1671 | 0.480965 | 1.0 |
| E6: Joint QA + SQA QLoRA | evidence | 32 | 0.850440 | 0.860882 | 0.841915 | 29.3847 | 0.496957 | 1.0 |

Selected setting: **evidence + 32 tokens**. E3 uses the same adapter trained on Task 2, without Task 1 training.

## Task 2 — Textual Visual QA

Input: image + written question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.739426 | 0.691355 | 0.797229 | 9.581 | 0.250891 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757470 | 0.707780 | 0.818002 | 10.6827 | 0.272292 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.771132 | 0.727347 | 0.822956 | 11.5305 | 0.286341 | 1.0 |
| E2: Selected generation setting | evidence | 32 | 0.795018 | 0.789404 | 0.803265 | 19.0826 | 0.376828 | 1.0 |
| E3: E2 + QLoRA | evidence | 32 | 0.848240 | 0.858865 | 0.839549 | 28.7663 | 0.490526 | 1.0 |
| E4: E2 + BM25 RAG | evidence + retrieved context | 32 | 0.798954 | 0.793805 | 0.806665 | 21.1541 | 0.391034 | 1.0 |
| E5: QLoRA + BM25 RAG | evidence + retrieved context | 32 | 0.829106 | 0.834995 | 0.825139 | 25.044 | 0.441971 | 1.0 |
| E6: Joint QA + SQA QLoRA | evidence | 32 | 0.852181 | 0.863649 | 0.842738 | 29.8649 | 0.500011 | 1.0 |

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
| E3 | E2 + QLoRA | Task 2 English train (image + written question), 10,000 items | Complete QA and SQA dev | Completed |
| E4 | E2 + BM25 RAG | Index built from complete English QA train | Complete QA dev | Completed |
| E5 | E3 + same BM25 RAG | Same adapter and index | Complete QA dev | Completed |
| E6 | Joint QA + SQA QLoRA | Paired English train, 10,000 + 10,000 inputs | Complete QA and SQA dev | Completed; both tasks scored 1,000 dev items |

The best measured configuration for both tasks is **E6: evidence + 32 tokens + joint QLoRA**, with QA F1=0.852181 and SQA F1=0.850440. Relative to E3, QA improves by 0.003941 and SQA by 0.005559. Adding BM25 RAG to that pipeline (E5) decreases F1 by 0.019134; P, R, BLEU and ROUGE-L also decrease, while Coverage stays 1.0. E5 exceeds E4 by 0.030152 F1. These results do not identify the cause of the decline or imply that RAG in general cannot help. Task 1 RAG experiments have not been run.

Use `scorer/score_json.py` to save scores without automatically overwriting this table. Update the exact experiment row after evaluation.

## E3 training completion — 2026-10-20

Reported server logs: 1 epoch, 1,250 optimizer steps; train_loss=0.92660885; eval_loss=0.89726317; eval_token_acc=0.72892836. Total reported train_runtime=9327.4219 seconds (about 2 h 35 min, including validation), memory metric=19.05 GiB.

Last and best adapter checkpoint: `/root/rivermind-data/mmcqa-runs/E3_qa_qlora/v0-20261020-083644/checkpoint-1250`.

Validation ran twice at completion with the same reported loss. These loss/token metrics are not answer-generation BERTScore or QA accuracy.

E3 complete-dev generation and official scoring completed for both tasks. Predictions and scores are under `outputs/E3_qlora_full_dev/`. QA ran first, followed by SQA. Both scored 1,000 items with Coverage=1.0. QA inference reported 3091.697 seconds (about 51.5 minutes), 0.32345 samples/s.

E3 uses the ms-swift PT inference backend with the trained adapter; E0–E2 used the repository's bare-Thinker inference script. The observed E3–E2 F1 differences are +0.053222 (QA) and +0.058009 (SQA). The inference implementation also changed, so these are pipeline comparisons rather than an isolated adapter-only ablation.

## E6 completion — 2026-10-21

User-reported official score JSON: complete English dev, 1,000 items per task, no empty answers. Scores are under `outputs/E6_joint_full_dev/`. Joint training used 10,000 QA + 10,000 SQA inputs, a fresh adapter, and max_length=4096; evaluation retained max_length=8192 and evidence/32 as in E3. The smoke run completed; the optional 2,000-item stage was skipped in favor of full training. The comparison measures the joint training configuration, including more optimizer steps and the changed training length cap; Paired-bootstrap results are reported below.

## E6 vs E3 — paired bootstrap

User-reported server results: 1,000 paired question IDs per task, official pinned mmBERT per-item F1, 10,000 percentile bootstrap replicates, seed=42. Differences are E6 minus E3.

| Task | Mean F1 difference | 95% percentile CI |
|---|---:|---|
| QA | +0.0039410243 | [0.0018392816, 0.0060341334] |
| SQA | +0.0055590364 | [0.0032848944, 0.0078314553] |

Both intervals exclude zero and support an improvement on this dev set. These intervals quantify question-sampling uncertainty for the fitted models, not variability across training seeds. Outputs: `outputs/E6_joint_full_dev/qa_bootstrap.json` and `sqa_bootstrap.json`, with paired per-item scores in corresponding `.items.jsonl` files.
