# Experimental Results

## Unified settings

- Model: Qwen2.5-Omni-3B; language track: English (`en`).
- Original baseline: 4-bit NF4 quantization, greedy decoding, `max_new_tokens=64`.
- Scoring: official scorer with its default mmBERT configuration. BERTScore-F1 is the
  primary metric; P, R, BLEU, ROUGE-L, and Coverage are recorded as well.
- Compare scores only when they use the same split and sample set. `—` means not yet
  evaluated.

## Task 1: Spoken Visual QA (SQA)

Full dev baseline; follow-up experiments test transfer of the Task 2 LoRA adapter.

| Experiment | Track | Split | Subset / N | Prompt | Model / method | Generation | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| Original baseline | en | dev | Full / 1000 | Original | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | 0.735861 | 0.687493 | 0.793918 | 9.4574 | 0.248659 | 1.0 |
| Task 2 LoRA transfer - original prompt | en | — | Full / 1000 | Original | Task 2 LoRA adapter | E3 selected settings | — | — | — | — | — | — |
| Task 2 LoRA transfer - selected prompt | en | — | Full / 1000 | Selected Task 2 prompt | Same Task 2 LoRA adapter | E3 selected settings | — | — | — | — | — | — |

## Task 2: Textual Visual QA (QA)

### Prompt screening

Compare prompts on the same fixed 200-item dev subset selected with seed `42`. The
`official` predictions are taken from the completed full-dev baseline; only the selected
predictions are scored against these 200 items. Screening scores are not directly
comparable to full-dev scores.

| Experiment | Track | Split | Subset / N | Prompt | Model / method | Generation | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| Prompt screen - official | en | dev | Fixed seed 42 / 200 | Original (`official`) | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | — | — | — | — | — | — |
| Prompt screen - expert | en | dev | Fixed seed 42 / 200 | Cultural heritage and everyday traditions expert | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | — | — | — | — | — | — |
| Prompt screen - evidence | en | dev | Fixed seed 42 / 200 | Image evidence, concrete entities, avoid unsupported details | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | — | — | — | — | — | — |

### Core experiments

Evaluate the selected configurations on the full 1000-item dev split. E2 compares
32- and 64-token generation; E3-E5 use the selected E2 generation setting.

| Experiment | Track | Split | Subset / N | Prompt | Model / method | Generation | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| E0 - Original baseline | en | dev | Full / 1000 | Original | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | 0.771132 | 0.727347 | 0.822956 | 11.5305 | 0.286341 | 1.0 |
| E1 - Selected prompt | en | — | Full / 1000 | Selected prompt | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | — | — | — | — | — | — |
| E2-32 - Prompt + decoding | en | — | Full / 1000 | Selected prompt | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 32 tokens | — | — | — | — | — | — |
| E2-64 - Prompt + decoding | en | — | Full / 1000 | Selected prompt | Qwen2.5-Omni-3B, no fine-tuning | 4-bit NF4, greedy, 64 tokens | — | — | — | — | — | — |
| E3 - E2 + QLoRA | en | — | Full / 1000 | Selected prompt | E2 + QLoRA trained on Task 2 English train | E2 selected setting | — | — | — | — | — | — |
| E4 - E2 + BM25 RAG | en | — | Full / 1000 | Selected prompt | E2 + BM25 index of Task 2 train Q&A | E2 selected setting | — | — | — | — | — | — |
| E5 - E3 + BM25 RAG | en | — | Full / 1000 | Selected prompt | E3 + same BM25 index as E4 | E2 selected setting | — | — | — | — | — | — |

The scorer updates a pre-listed row; it does not create new experiment rows automatically.
