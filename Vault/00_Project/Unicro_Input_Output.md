---
tags: architecture/project  
---
# Unicro Input / Output

Unicro behaves like a behavioral operating layer.

## Input

All interactions must be converted into structured intent.

Sources of intent:

- UI interaction
- Gesture
- Shortcut
- Automation
- Future AI agent

Intent structure is defined in:

[[Intent_Model]]

## Output

Unicro produces deterministic state mutation and feedback signals.

Output surfaces include:

- Domain state changes
- Interaction state changes
- Feedback state signals
- UI projection

State structure:

[[State_Model]]

Feedback handling:

[[Feedback_Model]]

Full system flow:

[[Execution_Pipeline]]