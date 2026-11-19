# Experimental Results

## Unified settings

- Model: Qwen2.5-Omni-3B for E0–E6; Qwen2.5-Omni-7B for E7–E8. English (`en`), MENA, complete dev split (1,000 items per task).
- Inference: 4-bit NF4 quantization for E0–E6 and BF16 for E7–E8; greedy decoding throughout; no fine-tuning in E0–E2.
- Scoring: official default mmBERT configuration. BERTScore-F1 is the primary metric.
- E1 compares prompts with a 64-token output cap. E2 uses the selected evidence prompt with a 32-token cap.
- Results below incorporate the user's 2026-10-20 report that full-dev E1/E2 reruns reproduced the previously supplied metric values. Earlier run logs remain in `EXPERIMENT_RESULTS.md`.

## E3 — LoRA configuration

| Setting           | Value                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------- |
| Method            | QLoRA · 4-bit NF4 · BF16 compute                                                             |
| LoRA              | Rank **8** · Alpha **16** · Dropout **0.05**                                                 |
| Training data     | Task 2 English train (image + written question) · **10,000 items**                           |
| Training          | **1 epoch** · Learning rate **1e-4**                                                         |
| Batch             | **1** × gradient accumulation **8** = effective batch **8**                                  |
| Trainable modules | LoRA on language-model linear layers; base weights, vision/audio encoders and aligner frozen |
| Evaluation        | Same adapter for both tasks · **evidence** prompt · **32 tokens** · full dev                 |

## E8 — LoRA configuration

| Setting           | Value                                                                                                      |
| ----------------- | ---------------------------------------------------------------------------------------------------------- |
| Method            | LoRA · BF16 (no quantization)                                                                              |
| LoRA              | Rank **16** · Alpha **32** · Dropout **0.05**                                                              |
| Trainable modules | LoRA on language-model linear layers; base weights, vision/audio encoders and aligner frozen               |
| Training data     | Paired English train · **10,000 QA + 10,000 SQA inputs**                                                   |
| Training          | **3 epoch** · Learning rate **1e-4** · effective batch **8** · max_length **4096** · max_pixels **401408** |
| Checkpoint        | **checkpoint-3,500** selected as best on a fixed 200-item dev subset                                       |
| Evaluation        | **evidence** prompt · **48 tokens** · full dev                                                             |

## Task 1 — Spoken Visual QA

Input: image + spoken question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment                      | Prompt   | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R |    BLEU | ROUGE-L | Coverage |
| ------------------------------- | -------- | ---------: | -----------: | ----------: | ----------: | ------: | ------: | -------: |
| E0: Original baseline           | official |         64 |       0.7359 |      0.6875 |      0.7939 |  9.4574 |  0.2487 |      1.0 |
| E1: Expert prompt               | expert   |         64 |       0.7573 |      0.7105 |      0.8136 |  10.642 |  0.2734 |      1.0 |
| E1: Evidence prompt             | evidence |         64 |       0.7618 |      0.7169 |      0.8157 |  11.026 |  0.2774 |      1.0 |
| E2: Selected generation setting | evidence |         32 |       0.7869 |      0.7792 |      0.7977 | 18.2546 |  0.3608 |      1.0 |
| E3: Task 2 QLoRA transfer       | evidence |         32 |       0.8449 |      0.8528 |      0.8388 | 28.1671 |  0.4810 |      1.0 |
| E6: Joint QA + SQA QLoRA        | evidence |         32 |       0.8504 |      0.8609 |      0.8419 | 29.3847 |  0.4970 |      1.0 |
| E8: 7B joint BF16 LoRA          | evidence |         32 |       0.8559 |      0.8689 |      0.8448 | 26.6315 |  0.5078 |      1.0 |
| E9: 7B joint BF16 LoRA          | evidence |         48 |       0.8599 |      0.8678 |      0.8535 | 28.2168 |  0.5104 |      1.0 |

Selected setting: **evidence + 48 tokens** (E9). E3 uses the same adapter trained on Task 2, without Task 1 training. The E8/E9 configuration is described in the E8 configuration section.

## Task 2 — Textual Visual QA

Input: image + written question. Output: text answer. All rows below use the full English dev split, N=1,000.

| Experiment                      | Prompt                       | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R |    BLEU | ROUGE-L | Coverage |
| ------------------------------- | ---------------------------- | ---------: | -----------: | ----------: | ----------: | ------: | ------: | -------: |
| E0: Original baseline           | official                     |         64 |       0.7394 |      0.6914 |      0.7972 |   9.581 |  0.2509 |      1.0 |
| E1: Expert prompt               | expert                       |         64 |       0.7575 |      0.7078 |      0.8180 | 10.6827 |  0.2723 |      1.0 |
| E1: Evidence prompt             | evidence                     |         64 |       0.7711 |      0.7273 |      0.8230 | 11.5305 |  0.2863 |      1.0 |
| E2: Selected generation setting | evidence                     |         32 |       0.7950 |      0.7894 |      0.8033 | 19.0826 |  0.3768 |      1.0 |
| E3: E2 + QLoRA                  | evidence                     |         32 |       0.8482 |      0.8589 |      0.8395 | 28.7663 |  0.4905 |      1.0 |
| E4: E2 + BGE-M3 RAG             | evidence + retrieved context |         32 |       0.7959 |      0.7907 |      0.8036 | 20.3903 |  0.3818 |      1.0 |
| E5: QLoRA + BGE-M3 RAG          | evidence + retrieved context |         32 |       0.8281 |      0.8336 |      0.8246 | 25.0248 |  0.4358 |      1.0 |
| E6: Joint QA + SQA QLoRA        | evidence                     |         32 |       0.8522 |      0.8636 |      0.8427 | 29.8649 |  0.5000 |      1.0 |
| E7: 7B QA-only LoRA             | evidence                     |         32 |       0.8549 |      0.8661 |      0.8458 |  30.178 |  0.5108 |      1.0 |
| E8: 7B joint BF16 LoRA          | evidence                     |         32 |       0.8554 |      0.8679 |      0.8447 |  26.957 |  0.5094 |      1.0 |
| E9: 7B joint BF16 LoRA          | evidence                     |         48 |       0.8597 |      0.8673 |      0.8536 | 28.5358 |  0.5122 |      1.0 |

Selected setting: **evidence + 48 tokens** (E9). The 64-token reference is the E1 evidence row, not a separate run. E7 uses Qwen2.5-Omni-7B with BF16 LoRA (rank 8, alpha 16, 1 epoch, 10,000 Task 2 training items only) and the same evidence/32 inference; it differs from E6 by model size and training data only. E8 uses Qwen2.5-Omni-7B with joint BF16 LoRA (rank 16, alpha 32, 10,000 QA + 10,000 SQA inputs); checkpoint-3,500 was selected as best on a fixed 200-item dev subset. E9 is E8 with the output cap raised from 32 to 48 tokens.

## Prompt definitions

All variants retain the same Qwen system identity.

- **official:** answer in one or two sentences in the target language; give only the answer.
- **expert:** add expertise in cultural heritage and everyday traditions; retain the same length and language request.
- **evidence:** use visible evidence and relevant cultural knowledge, identify specific entities when supported, and avoid unsupported details; retain the same length and language request.

Exact prompt text and generation arguments are recorded in prediction `.meta.json` files.

## Experiment status

| ID | Setting                    | Training data                                                 | Evaluation              | Status                                                         |
| -- | -------------------------- | ------------------------------------------------------------- | ----------------------- | -------------------------------------------------------------- |
| E3 | E2 + QLoRA                 | Task 2 English train (image + written question), 10,000 items | Complete QA and SQA dev | Completed                                                      |
| E4 | E2 + BGE-M3 dense RAG      | Index built from complete English QA train                    | Complete QA dev         | Completed                                                      |
| E5 | E3 + same BGE-M3 dense RAG | Same adapter and index                                        | Complete QA dev         | Completed                                                      |
| E6 | Joint QA + SQA QLoRA       | Paired English train, 10,000 + 10,000 inputs                  | Complete QA and SQA dev | Completed; both tasks scored 1,000 dev items                   |
| E7 | 7B QA-only BF16 LoRA       | Task 2 English train (image + written question), 10,000 items | Complete QA dev         | Completed; full-dev QA scored, 1,000 items                     |
| E8 | 7B joint BF16 LoRA         | Paired English train, 10,000 + 10,000 inputs                  | Complete QA and SQA dev | Completed; checkpoint-3,500, both tasks scored 1,000 dev items |
| E9 | E8 + 48-token cap          | E8 checkpoint-3,500                                           | Complete QA and SQA dev | Completed; 48 tokens, both tasks scored 1,000 dev items        |

The best measured configuration for both tasks is **E9: evidence + 48 tokens + 7B joint BF16 LoRA**, with QA F1=0.859674 and SQA F1=0.859885. Against the 32-token E8 (QA 0.855361, SQA 0.855884), raising the cap to 48 tokens improves QA by **+0.004313** and SQA by **+0.004001**; P is essentially unchanged (−0.000575 QA, −0.001060 SQA) while R rises materially (+0.008960 QA, +0.008746 SQA), confirming the 32-token cap was truncating answers and the extra tokens add real content. BLEU rises +1.58 and ROUGE-L +0.0026 on both tasks, ruling out BERTScore-only noise. Within the 3B series, E6 improves over E3 by +0.003941 (QA) and +0.005559 (SQA). Adding BGE-M3 RAG to E3 (E5) decreases QA F1 by 0.020140; P, R, BLEU and ROUGE-L also decrease, while Coverage stays 1.0. E4 differs from E2 by +0.000857 F1. E5 exceeds E4 by 0.032225 F1, but their inference backends differ, so this is not an isolated adapter comparison. These results do not identify the cause of the decline or imply that RAG in general cannot help. Task 1 RAG experiments have not been run.


Use `scorer/score_json.py` to save scores without automatically overwriting this table. Update the exact experiment row after evaluation.

## E3 training completion — 2026-10-20

Reported server logs: 1 epoch, 1,250 optimizer steps; train_loss=0.92660885; eval_loss=0.89726317; eval_token_acc=0.72892836. Total reported train_runtime=9327.4219 seconds (about 2 h 35 min, including validation), memory metric=19.05 GiB.

Last and best adapter checkpoint: `/root/rivermind-data/mmcqa-runs/E3_qa_qlora/v0-20261020-083644/checkpoint-1250`.

Validation ran twice at completion with the same reported loss. These loss/token metrics are not answer-generation BERTScore or QA accuracy.

E3 complete-dev generation and official scoring completed for both tasks. Predictions and scores are under `outputs/E3_qlora_full_dev/`. QA ran first, followed by SQA. Both scored 1,000 items with Coverage=1.0. QA inference reported 3091.697 seconds (about 51.5 minutes), 0.32345 samples/s.

E3 uses the ms-swift PT inference backend with the trained adapter; E0–E2 used the repository's bare-Thinker inference script. The observed E3–E2 F1 differences are +0.053222 (QA) and +0.058009 (SQA). The inference implementation also changed, so these are pipeline comparisons rather than an isolated adapter-only ablation.

## E6 completion — 2026-10-21

User-reported official score JSON: complete English dev, 1,000 items per task, no empty answers. Scores are under `outputs/E6_joint_full_dev/`. Joint training used 10,000 QA + 10,000 SQA inputs, a fresh adapter, and max_length=4096; evaluation retained max_length=8192 and evidence/32 as in E3. The smoke run completed; the optional 2,000-item stage was skipped in favor of full training. The comparison measures the joint training configuration, including more optimizer steps and the changed training length cap; Paired-bootstrap results are reported below.

## Same-backend control (3B) — 2026-10-21

Fixed 200 paired dev IDs, evidence/32, ms-swift PT for both the 3B base and E3. E3 predictions are extracted from the completed full-dev run. These control results are separate from the full-dev tables below. E7–E8 use the same ms-swift PT backend, so 3B-versus-7B comparisons share the inference implementation; a 7B base no-adapter control has not been run.

| Task | Model | N | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |  
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|  
| Task 2 QA | Base, no adapter | 200 | 0.806181 | 0.809083 | 0.805495 | 19.1973 | 0.399252 | 1.0 |  
| Task 2 QA | E3 adapter | 200 | 0.853217 | 0.860313 | 0.848031 | 30.3449 | 0.505105 | 1.0 |  
| Task 1 SQA | Base, no adapter | 200 | 0.799018 | 0.801613 | 0.799155 | 18.567 | 0.383989 | 1.0 |  
| Task 1 SQA | E3 adapter | 200 | 0.850415 | 0.857458 | 0.845306 | 29.632 | 0.497709 | 1.0 |

QA F1 difference: **+0.047036**; SQA F1 difference: **+0.051397**, with the adapter under the same inference backend. Both controls are complete. Joint training data preparation is complete: smoke 100+100, small 1000+1000, full 10000+10000; each task has 1000 dev items. Training audio duration: 2.081–12.022 seconds (mean 5.627 seconds).

## E6 vs E3 — paired bootstrap

User-reported server results: 1,000 paired question IDs per task, official pinned mmBERT per-item F1, 10,000 percentile bootstrap replicates, seed=42. Differences are E6 minus E3.

| Task | Mean F1 difference | 95% percentile CI            |
| ---- | -----------------: | ---------------------------- |
| QA   |      +0.0039410243 | [0.0018392816, 0.0060341334] |
| SQA  |      +0.0055590364 | [0.0032848944, 0.0078314553] |

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

| Setting            | Retriever    | BERTScore-F1 | BERTScore-P | BERTScore-R |    BLEU |  ROUGE-L | Coverage |
| ------------------ | ------------ | -----------: | ----------: | ----------: | ------: | -------: | -------: |
| E2 + RAG           | BM25         |     0.798954 |    0.793805 |    0.806665 | 21.1541 | 0.391034 |      1.0 |
| E2 + RAG (main E4) | BGE-M3 dense |     0.795875 |    0.790686 |    0.803606 | 20.3903 | 0.381847 |      1.0 |
| E3 + RAG           | BM25         |     0.829106 |    0.834995 |    0.825139 |  25.044 | 0.441971 |      1.0 |
| E3 + RAG (main E5) | BGE-M3 dense |     0.828100 |    0.833577 |    0.824578 | 25.0248 | 0.435761 |      1.0 |

BGE-M3 minus BM25 F1: −0.003079 without LoRA and −0.001006 with the E3 adapter. Neither retriever improves over E3 without retrieval (0.848240). No paired significance test has been run for the retriever differences. The measured outcome supports the same practical choice: retain E8 without RAG as the final system.

## Next steps and analysis — 2026-11-15

### Checkpoint plateau

Fixed 200-item dev subset, E8 (7B joint BF16 LoRA, evidence/32, greedy):

| Checkpoint   |     2000 |     3000 |     3500 |     4000 |
| ------------ | -------: | -------: | -------: | -------: |
| BERTScore-F1 | 0.859418 | 0.855334 | 0.861116 | 0.858747 |

There is no monotonic trend from step 2,000 to 4,000; the spread (about ±0.003) is at the level of evaluation noise, and step 4,000 is 0.0024 below step 3,500. Training was stopped and **checkpoint-3,500** retained. The gain over the one-epoch 7B QA-only run (E7, QA 0.854924) comes mainly from doubled data and joint training, not from additional epochs.

### Generation-length diagnosis — completed

E8 QA has BERTScore-P 0.867892 > R 0.844675, so the 32-token cap was suspected of truncating answers. A cap/decoding sweep was run on the fixed 200-item dev subset (same checkpoint-3,500, greedy decoding) to separate hard truncation from under-informative-but-complete answers:

| Setting                                   | BERTScore-F1 | BERTScore-P | BERTScore-R |    BLEU |  ROUGE-L |
| ----------------------------------------- | -----------: | ----------: | ----------: | ------: | -------: |
| 32 tokens, greedy (baseline)              |     0.861116 |    0.872323 |    0.851614 | 28.8006 | 0.530654 |
| 48 tokens, greedy                         | **0.865436** |    0.871523 |    0.860769 | 30.0986 | 0.533245 |
| 48 tokens, greedy, repetition_penalty 1.1 |     0.855281 |    0.857612 |    0.854303 | 27.5140 | 0.512264 |
| 64 tokens, greedy                         |     0.865588 |    0.871507 |    0.861102 | 30.1357 | 0.532969 |

The 32→48 change raises R from ~0.845 to 0.861 with P essentially unchanged, confirming that the 32-token cap was truncating answers and that the extra tokens carry real information (not padding). The 200-item gain is **+0.0043 F1** and **+2.58 BLEU**, and this is confirmed on the full 1,000-item dev (see below).

- **48 tokens + greedy is the retained setting.** Going from 48→64 tokens adds only +0.00015 F1 (and ROUGE-L dips slightly), i.e. zero marginal return; 48 fully resolves the truncation, so the cap is not increased further.
- **repetition_penalty 1.1 is harmful** (−0.0101 F1, mean output ~23.5 words): the penalty shortens generations and undoes the recall gain. It is discarded.
- Beam search remains deferred; the truncation question is now closed.

The length bottleneck is resolved. The remaining P>R gap is therefore answer completeness/content rather than length.


## Cross-Lingual Evaluation — planned（2026.11.19）

Final frozen model: **E8** (Qwen2.5-Omni-7B + checkpoint-3500, joint BF16 LoRA), zero-shot, fixed inference (BF16, evidence prompt, greedy, 48 tokens, same LoRA adapter). No further training.

Design rationale: a base-model control is required to attribute any cross-lingual benefit to the English joint LoRA rather than to the underlying model. Only one control group is added — the raw Qwen2.5-Omni-7B Base (no adapter) on all tracks — using the identical prompt, 48-token cap, inference backend, and decoding parameters. The 3B baseline is not re-run with the fixed settings: it is not on the 7B cross-lingual axis and the official 3B numbers already exist. The Base-versus-E8 difference reflects the entire joint-LoRA configuration (training objective, rank, data), not a single isolated mechanism.

Scale: 16 non-English tracks × 2 tasks (QA image+text, SQA image+speech). The MENA set (English, MSA, ARZ, AJP) shares question IDs and enables same-question controlled comparison; other tracks differ in language, culture, imagery, and question distribution, so not every score gap is attributable to language alone. SQA dev audio is synthetic speech; real-human recordings appear only in the official test split, so synthetic-speech transfer must be kept distinct from real-speech robustness.

### Raw scores (fill in)

Each cell is BERTScore-F1 (report P/R/BLEU/ROUGE-L in the per-track score JSON). Two rows per language: Base (no adapter) and E8.

| Track                   | Task     | Base F1 | E8 F1 | E8 P | E8 R | E8 BLEU | E8 ROUGE-L |
| ----------------------- | -------- | ------: | ----: | ---: | ---: | ------: | ---------: |
| English (MENA)          | QA       |       — |     — |    — |    — |       — |          — |
| English (MENA)          | SQA      |       — |     — |    — |    — |       — |          — |
| MSA                     | QA       |       — |     — |    — |    — |       — |          — |
| MSA                     | SQA      |       — |     — |    — |    — |       — |          — |
| ARZ                     | QA       |       — |     — |    — |    — |       — |          — |
| ARZ                     | SQA      |       — |     — |    — |    — |       — |          — |
| AJP                     | QA       |       — |     — |    — |    — |       — |          — |
| AJP                     | SQA      |       — |     — |    — |    — |       — |          — |
| … (remaining 12 tracks) | QA / SQA |       — |     — |    — |    — |       — |          — |

### English–target gap (fill in)

Gap_l = F1_English(E8) − F1_l(E8), per task.

| Track | QA Gap | SQA Gap |
| ----- | -----: | ------: |
| MSA   |      — |       — |
| ARZ   |      — |       — |
| AJP   |      — |       — |
| …     |      — |       — |

### Adapter gain (fill in)

Gain_l = F1_l(E8) − F1_l(Base), per task. Flag positive transfer vs negative transfer.

| Track | QA Gain | SQA Gain | Direction |
| ----- | ------: | -------: | --------- |
| MSA   |       — |        — | —         |
| ARZ   |       — |        — | —         |
| AJP   |       — |        — | —         |
| …     |       — |        — | —         |

### Language-family grouping (optional)

Arabic variants · South Asian · European · African — analyze transfer behavior by family.
# 论文大纲与实验规划

## 一、论文结构

| 章节 | 内容 | 对应实验 |
| :--- | :--- | :--- |
| **1. Introduction** | 研究背景、挑战、研究动机与贡献 | 整体研究 |
| **2. Task and Dataset** | MMCQA 任务、QA/SQA、数据集与语言分布 | 官方数据集 |
| **3. Methodology** | Evidence-aware Prompting、LoRA 适配、联合训练框架 | E1–E8 |
| **4. Experimental Setup** | 3B/7B 模型、训练参数、推理配置、评价指标 | E0–E9 |
| **5. Main Experimental Results** | Prompt 消融、QLoRA、联合训练、模型规模对比、RAG | E0–E8 |
| **6. Generation Length Optimization** | 输出长度对比与优化 | E9：48 tokens |
| **7. Zero-Shot Cross-Lingual Evaluation** | 原始 7B Base 与 E8 在16种非英语语言上的对比 | 待完成 |
| **8. Error Analysis and Discussion** | 语言迁移差异、文化知识缺失、视觉错误、幻觉 | 待完成 |
| **9. Conclusion** | 研究总结、局限性与未来工作 | 全部实验 |

---

## 二、实验编号整理

* **E0–E2**：官方基线与 Prompt 消融。
* **E3**：Task 2 QLoRA 及跨任务迁移。
* **E4–E5**：RAG 消融。
* **E6**：3B Joint QLoRA。
* **E7**：7B QA-only LoRA。
* **E8**：7B Joint BF16 LoRA。
* **E9**：E8 + 48-token 生成长度优化。

---

## 三、论文核心贡献

建议归纳为以下三个方面：

1. **Prompt 与模型适配**：提出 Evidence-aware Prompting 和跨任务联合 LoRA 适配方法。
2. **系统性实验分析**：深入研究 RAG、模型规模、生成长度及联合训练对模型性能的影响。
3. **跨语言泛化评测**：通过原始 7B Base 与 E8 的对照，系统评估英语训练的多模态模型在 16 种非英语语言上的零样本迁移能力。
