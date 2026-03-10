# Execution Pipeline

Unicro processes all interactions through a deterministic pipeline.

System pipeline:

[[Intent_Model]]
→ [[Skill_Model]]
→ [[State_Model]]
→ [[Feedback_Model]]

## Steps

1. User action generates [[Intent_Model]]
2. Resolver selects appropriate [[Skill_Model]]
3. Skill mutates [[State_Model]]
4. State change triggers [[Feedback_Model]]
5. UI renders new state

This architecture ensures behavior is predictable and testable.

Related modules:

[[IntentKit]]
[[SkillKit]]
[[StateKit]]
[[FeedbackKit]]
[[FluidKit]]