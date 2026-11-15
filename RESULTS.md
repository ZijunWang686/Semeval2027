# Experimental Results

## Same-backend control (3B) — 2026-10-21

Fixed 200 paired dev IDs, evidence/32, ms-swift PT for both the 3B base and E3. E3 predictions are extracted from the completed full-dev run. These control results are separate from the full-dev tables below. E7–E8 use the same ms-swift PT backend, so 3B-versus-7B comparisons share the inference implementation; a 7B base no-adapter control has not been run.

| Task | Model | N | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Task 2 QA | Base, no adapter | 200 | 0.806181 | 0.809083 | 0.805495 | 19.1973 | 0.399252 | 1.0 |
| Task 2 QA | E3 adapter | 200 | 0.853217 | 0.860313 | 0.848031 | 30.3449 | 0.505105 | 1.0 |
| Task 1 SQA | Base, no adapter | 200 | 0.799018 | 0.801613 | 0.799155 | 18.567 | 0.383989 | 1.0 |
| Task 1 SQA | E3 adapter | 200 | 0.850415 | 0.857458 | 0.845306 | 29.632 | 0.497709 | 1.0 |

QA F1 difference: **+0.047036**; SQA F1 difference: **+0.051397**, with the adapter under the same inference backend. Both controls are complete. Joint training data preparation is complete: smoke 100+100, small 1000+1000, full 10000+10000; each task has 1000 dev items. Training audio duration: 2.081–12.022 seconds (mean 5.627 seconds).

## Unified settings

- Model: Qwen2.5-Omni-3B for E0–E6; Qwen2.5-Omni-7B for E7–E8. English (`en`), MENA, complete dev split (1,000 items per task).
- Inference: 4-bit NF4 quantization for E0–E6 and BF16 for E7–E8; greedy decoding throughout; no fine-tuning in E0–E2.
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

## E8 — LoRA configuration

| Setting | Value |
|---|---|
| Method | LoRA · BF16 (no quantization) |
| LoRA | Rank **16** · Alpha **32** · Dropout **0.05** |
| Trainable modules | LoRA on language-model linear layers; base weights, vision/audio encoders and aligner frozen |
| Training data | Paired English train · **10,000 QA + 10,000 SQA inputs** |
| Training | Learning rate **1e-4** · effective batch **8** · max_length **4096** · max_pixels **401408** |
| Checkpoint | **checkpoint-3,500** selected as best on a fixed 200-item dev subset |
| Evaluation | **evidence** prompt · **32 tokens** · full dev |

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
| E8: 7B joint BF16 LoRA | evidence | 32 | 0.855884 | 0.868877 | 0.844786 | 26.6315 | 0.507813 | 1.0 |

Selected setting: **evidence + 32 tokens**. E3 uses the same adapter trained on Task 2, without Task 1 training. The E8 configuration is described in the E8 configuration section.

## Task 2 — Textual Visual QA

Input: image + written question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.739426 | 0.691355 | 0.797229 | 9.581 | 0.250891 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757470 | 0.707780 | 0.818002 | 10.6827 | 0.272292 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.771132 | 0.727347 | 0.822956 | 11.5305 | 0.286341 | 1.0 |
| E2: Selected generation setting | evidence | 32 | 0.795018 | 0.789404 | 0.803265 | 19.0826 | 0.376828 | 1.0 |
| E3: E2 + QLoRA | evidence | 32 | 0.848240 | 0.858865 | 0.839549 | 28.7663 | 0.490526 | 1.0 |
| E4: E2 + BGE-M3 RAG | evidence + retrieved context | 32 | 0.795875 | 0.790686 | 0.803606 | 20.3903 | 0.381847 | 1.0 |
| E5: QLoRA + BGE-M3 RAG | evidence + retrieved context | 32 | 0.828100 | 0.833577 | 0.824578 | 25.0248 | 0.435761 | 1.0 |
| E6: Joint QA + SQA QLoRA | evidence | 32 | 0.852181 | 0.863649 | 0.842738 | 29.8649 | 0.500011 | 1.0 |
| E7: 7B QA-only LoRA | evidence | 32 | 0.854924 | 0.866052 | 0.845836 | 30.178 | 0.510845 | 1.0 |
| E8: 7B joint BF16 LoRA | evidence | 32 | 0.855361 | 0.867892 | 0.844675 | 26.957 | 0.509427 | 1.0 |

Selected setting: **evidence + 32 tokens**. The 64-token reference is the E1 evidence row, not a separate run. E7 uses Qwen2.5-Omni-7B with BF16 LoRA (rank 8, alpha 16, 1 epoch, 10,000 Task 2 training items only) and the same evidence/32 inference; it differs from E6 by model size and training data only. E8 uses Qwen2.5-Omni-7B with joint BF16 LoRA (rank 16, alpha 32, 10,000 QA + 10,000 SQA inputs); checkpoint-3,500 was selected as best on a fixed 200-item dev subset.

## Prompt definitions

All variants retain the same Qwen system identity.

- **official:** answer in one or two sentences in the target language; give only the answer.
- **expert:** add expertise in cultural heritage and everyday traditions; retain the same length and language request.
- **evidence:** use visible evidence and relevant cultural knowledge, identify specific entities when supported, and avoid unsupported details; retain the same length and language request.

Exact prompt text and generation arguments are recorded in prediction `.meta.json` files.

## Experiment status

| ID | Setting | Training data | Evaluation | Status |
|---|---|---|---|---|
| E3 | E2 + QLoRA | Task 2 English train (image + written question), 10,000 items | Complete QA and SQA dev | Completed |
| E4 | E2 + BGE-M3 dense RAG | Index built from complete English QA train | Complete QA dev | Completed |
| E5 | E3 + same BGE-M3 dense RAG | Same adapter and index | Complete QA dev | Completed |
| E6 | Joint QA + SQA QLoRA | Paired English train, 10,000 + 10,000 inputs | Complete QA and SQA dev | Completed; both tasks scored 1,000 dev items |
| E7 | 7B QA-only BF16 LoRA | Task 2 English train (image + written question), 10,000 items | Complete QA dev | Completed; full-dev QA scored, 1,000 items |
| E8 | 7B joint BF16 LoRA | Paired English train, 10,000 + 10,000 inputs | Complete QA and SQA dev | Completed; checkpoint-3,500, both tasks scored 1,000 dev items |

The best measured configuration for both tasks is **E8: evidence + 32 tokens + 7B joint BF16 LoRA**, with QA F1=0.855361 and SQA F1=0.855884. Against the previous 3B best (E6: QA 0.852181, SQA 0.850440), E8 improves QA by **+0.003180** and SQA by **+0.005444**. Within the 3B series, E6 improves over E3 by +0.003941 (QA) and +0.005559 (SQA). Adding BGE-M3 RAG to E3 (E5) decreases QA F1 by 0.020140; P, R, BLEU and ROUGE-L also decrease, while Coverage stays 1.0. E4 differs from E2 by +0.000857 F1. E5 exceeds E4 by 0.032225 F1, but their inference backends differ, so this is not an isolated adapter comparison. These results do not identify the cause of the decline or imply that RAG in general cannot help. Task 1 RAG experiments have not been run.

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

## E8 completion — 2026-11-15

Qwen2.5-Omni-7B joint BF16 LoRA, 10,000 QA + 10,000 SQA inputs. **checkpoint-3,500** selected as best on a fixed 200-item dev subset. Full English dev was scored for both tasks, 1,000 items each, with the official mmBERT configuration using a local copy of `jhu-clsp/mmBERT-base`. Predictions and scores: `outputs/E8_7b_full_dev_qa/` and `outputs/E8_7b_full_dev_sqa/`.

## BGE-M3 RAG — completed, 2026-10-25

The main-table E4/E5 rows now designate BGE-M3 dense retrieval. The earlier BM25 runs are preserved below as supplementary retriever comparisons. Results were reported by the user from server scoring outputs; both BGE-M3 runs evaluate the complete 1,000-item English QA dev split.

- Frozen BAAI/bge-m3, snapshot `5617a9f61b028005a4858fdac845db406aefb181`; CLS pooling, L2-normalized 1024-dimensional vectors, exact cosine search, Top-3.
- Corpus: all 10,000 English QA train question–answer pairs; query: dev question only, with no extra retrieval instruction. Dev reference answers are excluded from retrieval and generation inputs.
- The retrieved context and evidence prompt are shared by E4/E5. Greedy decoding, 32 generated tokens, 4-bit NF4. E4 uses the original Thinker backend; E5 uses ms-swift PT with the existing E3 adapter, without additional training.
- Outputs: `outputs/E4_bge_m3_full_dev/` and `outputs/E5_bge_m3_full_dev/`. Implementation: `rag/BGE_M3_GUIDE_ZH.md`.

### Supplementary retriever comparison

All rows use complete English QA dev (N=1,000). Compare retrievers within the same generation setting.

| Setting | Retriever | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|
| E2 + RAG | BM25 | 0.798954 | 0.793805 | 0.806665 | 21.1541 | 0.391034 | 1.0 |
| E2 + RAG (main E4) | BGE-M3 dense | 0.795875 | 0.790686 | 0.803606 | 20.3903 | 0.381847 | 1.0 |
| E3 + RAG | BM25 | 0.829106 | 0.834995 | 0.825139 | 25.044 | 0.441971 | 1.0 |
| E3 + RAG (main E5) | BGE-M3 dense | 0.828100 | 0.833577 | 0.824578 | 25.0248 | 0.435761 | 1.0 |

BGE-M3 minus BM25 F1: −0.003079 without LoRA and −0.001006 with the E3 adapter. Neither retriever improves over E3 without retrieval (0.848240). No paired significance test has been run for the retriever differences. The measured outcome supports the same practical choice: retain E8 without RAG as the final system.
