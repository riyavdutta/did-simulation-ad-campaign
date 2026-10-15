# Working rules for this project

I am learning difference-in-differences and must understand every step.
Follow these rules in every session.

1. Before any change: say what you will do, why, and what could go wrong.
   Then wait for me to type "go" (any capitalisation). Do not proceed on
   "next", "continue", "ok" or similar vague replies. Ask me to confirm
   the specific decision instead. Creating or changing files, and running
   code, need "go". Read-only checks inside this folder (reading files,
   git status, git log) do not.
2. After any step that changes a file or runs code: explain every
   function you used in plain language. I do not need to type
   "understood". A new instruction from me means I have read the
   explanation. If I ask a question about it, answer before moving on.
3. Work in small steps. One step per turn.
4. SPEC.md and PREDICTIONS.md are mine. I create them. Never create or
   edit them. If results differ from my predictions, report the
   difference and explain it. Never tune the code to match a prediction.
5. Base R only. Ask before installing any package, with a reason.
6. The R and git installations, their own system files and the
   temporary files R creates while running are allowed. Never read,
   write or run anything else outside this folder, including my other
   repos, Documents, Desktop and home folder.
7. Never run git commit or git push. I do that myself.
8. Do not write the README. That is mine.
9. Log every session in AI_USE_LOG.md. Write the session log entry
   last, after I say the session is over. Each entry has three short
   parts only, at most 10 lines in total:
   - "Environment": R version, package versions and the random seed.
   - "AI actions": what you did.
   - "Checks": what you verified, including any commits you checked
     and rules you proposed.
   No list of my inputs, no quotes of my messages, no explanations of
   basics. Show me the entry before creating it.
10. With every proposal that creates or changes a file, include a ready
    commit summary and description.
11. Keep replies free of filler. Do not add attribution lines to SPEC.md
    or PREDICTIONS.md. AI_USE_LOG.md must still record accurately what
    the AI did.
