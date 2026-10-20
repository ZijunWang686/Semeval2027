# Experimental Results

All scores should be computed on the same split for a fair comparison. The scorer fills
in the split and metrics automatically when it writes a score. `—` means the experiment
has not been scored yet.

## Task 1: Spoken Visual QA (SQA)

| Experiment | Track | Split | Prompt | Model | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| Original baseline | en | dev | Original | Original model | 0.735861 | 0.687493 | 0.793918 | 9.4574 | 0.248659 | 1.0 |
| Prompt only | en | — | Modified | Original model | — | — | — | — | — | — |
| LoRA only | en | — | Original | Original model + LoRA | — | — | — | — | — | — |
| Prompt + LoRA | en | — | Modified | Original model + LoRA | — | — | — | — | — | — |

## Task 2: Textual Visual QA (QA)

| Experiment | Track | Split | Prompt | Model | BERTScore-F1 | BERTScore-P | BERTScore-R | BLEU | ROUGE-L | Coverage |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| Original baseline | en | dev | Original | Original model | 0.739426 | 0.691355 | 0.797229 | 9.581 | 0.250891 | 1.0 |
| Prompt only | en | — | Modified | Original model | — | — | — | — | — | — |
| LoRA only | en | — | Original | Original model + LoRA | — | — | — | — | — | — |
| Prompt + LoRA | en | — | Modified | Original model + LoRA | — | — | — | — | — | — |

Replace `—` with the score after evaluating that experiment, and record the exact split
(for example, `dev` or `devtest`) in the Split column. Keep the model and prompt setup
consistent with the experiment name.
