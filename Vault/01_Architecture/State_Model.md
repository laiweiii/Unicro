---
tags: architecture/core
---
# State Model

State is the single source of truth.

UI must never directly mutate domain state.

State is divided into three layers.

## Domain State

Core business objects.

Example:

[[Note_Domain]]

## Interaction State

UI related state such as:

- editor open
- focus
- selection

## Feedback State

Handles system signals.

See:

[[Feedback_Model]]

Pipeline context:

[[Execution_Pipeline]]