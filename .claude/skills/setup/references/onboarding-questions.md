# Onboarding Questions

## Instructions for Claude

- Ask each question individually. Wait for the answer.
- Accept any format: short sentence, long text, LinkedIn profile, uploaded file, or "skip".
- No follow-up questions or drill-downs. Extract what you can.
- After each answer: 1 sentence confirmation, then next question.
- If "skip": leave placeholder, user can fill in later.

---

## Question 1: Who are you?

> **Tell me briefly about yourself.**
> Your name, what you do, who you work for. 2-3 sentences are enough — or paste your LinkedIn profile, website bio, or whatever you have.

Extract:
- `{{NAME}}` — First name or full name
- `{{DESCRIPTION}}` — What the person does + for whom (1-2 sentences)

---

## Question 2: What's your business?

> **What do you offer and for whom?**
> Your products/services, your target audience, and: What's your biggest challenge right now?
> If you don't offer anything (e.g., employed or student): tell me briefly what you do professionally and what's on your mind.

Extract:
- `{{OFFERING}}` — Products/services (or: occupation)
- `{{AUDIENCE}}` — For whom (or: in which field)
- `{{CHALLENGE}}` — Biggest current problem/bottleneck

---

## Question 3: Active projects?

> **What are you working on right now?**
> Name 2-3 projects or initiatives that are currently active for you. Per project, just: name + what the goal is.

Extract:
- `{{PROJECTS}}` — List with name + goal per project

---

## After all questions

Say: "Got it, I'm setting up your brain now." — then continue with Phase B (Create vault).
