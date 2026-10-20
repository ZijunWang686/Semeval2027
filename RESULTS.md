# Experimental Results

## Settings and reading guide

- Model: Qwen2.5-Omni-3B; English (`en`), MENA, dev.
- Baseline: no training or LoRA; 4-bit NF4, greedy decoding, maximum 64 output tokens.
- Scorer: official default mmBERT configuration. BERTScore-F1 is the primary metric, not accuracy.
- Compare rows within the same task and sample set. Full dev (1000) and screening subset (200) are separate evaluations.
- `—` means not evaluated/reported. Planned experiments are listed separately from measured results.
- This table is curated from reported score JSON/logs. Do not automatically select rows by task alone or by an ambiguous filename.

## Task 1 — Spoken Visual QA

Input: image + spoken question. Output: text answer.

### Full dev — 1000 items

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.735861 | 0.687493 | 0.793918 | 9.4574 | 0.248659 | 1.0 |

### Prompt screening — fixed 200 items

Use exactly the same IDs and order as Task 2's screening manifest. Task 1 predictions and reference answers must come from SQA files.

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Subset of original baseline | official | 64 | 0.741261 | 0.691295 | 0.801783 | 9.7414 | 0.254275 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757260 | 0.710530 | 0.813587 | 10.642 | 0.273383 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.761837 | 0.716892 | 0.815736 | 11.026 | 0.277395 | 1.0 |

Selected prompt: **evidence**, with an F1 increase of 0.020576 over the same-subset E0 (expert: +0.015999). Scores were supplied in server logs on 2026-10-20. These are development screening results, not a significance claim. Later evaluate transfer of the Task 2-trained LoRA adapter with the original and selected prompts.

### Generation screening — same 200 items

| Configuration | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E1 / E2 reference (reused) | evidence | 64 | 0.761837 | 0.716892 | 0.815736 | 11.026 | 0.277395 | 1.0 |
| E2 selected | evidence | 32 | 0.786872 | 0.779164 | 0.797733 | 18.2546 | 0.360756 | 1.0 |

Task 1 selects **evidence / 32 tokens**. F1 increases by **0.025035** over evidence/64 and **0.045611** over the same-subset E0. Precision increases and recall decreases. Full-dev E2 has not yet been evaluated.

## Task 2 — Textual Visual QA

Input: image + written question. Output: text answer.

### Full dev — 1000 items

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Original baseline | official | 64 | 0.739426 | 0.691355 | 0.797229 | 9.581 | 0.250891 | 1.0 |

No modified-prompt full-dev score has been reported yet.

### Prompt screening — fixed 200 items, seed 42

| Experiment | Prompt | Max tokens | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| E0: Subset of original baseline | official | 64 | 0.744010 | 0.694556 | 0.803966 | 9.8523 | 0.255861 | 1.0 |
| E1: Expert prompt | expert | 64 | 0.757470 | 0.707780 | 0.818002 | 10.6827 | 0.272292 | 1.0 |
| E1: Evidence prompt | evidence | 64 | 0.771132 | 0.727347 | 0.822956 | 11.5305 | 0.286341 | 1.0 |

Selected prompt: **evidence**. F1 increases by 0.027122 over the same-subset E0. These are configuration-selection results, not an independent test or a significance claim.

### Generation screening — same 200 items

| Configuration | Prompt | Max tokens | BERTScore-F1 | Status |
|---|---|---:|---:|---|
| E1 / E2 reference | evidence | 64 | 0.771132 | Reused from the prompt experiment; not a new run |
| E2 candidate | evidence | 32 | 0.795018 | Completed; selected for Task 2 |

Task 2 E2 (32 tokens): BERTScore-P **0.789404**, BERTScore-R **0.803265**, BLEU **19.0826**, ROUGE-L **0.376828**, Coverage **1.0**. F1 increases by **0.023886** over evidence/64 and **0.051008** over the same-subset E0. Precision increases while recall decreases compared with evidence/64. This does not establish why the change helped; truncation and answer content have not been inspected. Both tasks now select evidence/32 on the fixed subset.

## Prompt definitions

All variants retain the same Qwen system identity.

- **official:** answer in one or two sentences in the target language; give only the answer.
- **expert:** add expertise in cultural heritage and everyday traditions; retain the same length and language request.
- **evidence:** use visible evidence and relevant cultural knowledge, identify specific entities when supported, and avoid unsupported details; retain the same length and language request.

Exact prompt text and generation arguments for new predictions are stored in their `.meta.json` files.

## Remaining experiment plan

| ID | Setting | Status |
|---|---|---|
| E2 | Selected prompt + generation length selection | Completed on 200 items for both tasks; evidence/32 selected; full-dev confirmation pending |
| E3 | Selected E2 configuration + Task 2 QLoRA | Not trained |
| E4 | Selected E2 configuration + BM25 RAG over train Q&A | Not run |
| E5 | E3 + the same RAG | Not run |

Keep screening comparisons on identical IDs. Record any later full-dev evaluation in the appropriate task's full-dev table. Full dev includes the screening items and is development evaluation, not held-out testing.

## Provenance and correction

Recorded from user-supplied server outputs on 2026-10-20. Task 2 subset files are under `outputs/prompt_dev200/`; Task 1 subset files are under `outputs/prompt_sqa_dev200/`.

An earlier automatic table update incorrectly wrote **0.771132** into Task 2's full-dev E0 row. That number belongs only to **Task 2 / 200 items / evidence / 64 tokens**. The correct full-dev E0 score **0.739426** is restored above. The underlying score JSON files are separate from this Markdown table.
