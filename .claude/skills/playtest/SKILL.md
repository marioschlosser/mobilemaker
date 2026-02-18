---
name: playtest
description: Analyze iOS game fun and balance through code review, design analysis, and simulator smoke tests. Launches sub-agents to evaluate specific gameplay aspects like progression, economy, and difficulty.
---

# Playtest Skill

## Purpose
Evaluate iOS games through a combination of code review, design analysis, and simulator smoke tests. Directs sub-agents to focus on specific aspects relevant to the current iteration.

## Prerequisites
1. Game project exists with a buildable Xcode project
2. GDD.md documents all systems
3. Unit tests pass (game doesn't crash)

---

## How It Works: Hybrid Playtesting

iOS games can't be played directly by agents the way web games can. Instead, we use a **three-pronged approach**:

1. **Design Analysis** - Review GDD, progression curves, economy spreadsheets
2. **Code Review** - Analyze game logic for balance issues, dominant strategies, dead ends
3. **Simulator Smoke Tests** - Build, run, and capture screenshots via `xcodebuild`

---

## Step 1: Determine Iteration Type (MANDATORY)

Read GDD.md to find current iteration number.

```bash
head -10 {GameName}/GDD.md
```

- **Odd iteration (v1, v3, v5...)** = NEW SYSTEM iteration
- **Even iteration (v2, v4, v6...)** = BALANCE + CONTENT iteration

---

## Step 2: Choose Focus Areas Based on Iteration Type

### For NEW SYSTEM Iterations (Odd: v1, v3, v5...)

| Agent | Focus | Questions to Answer |
|-------|-------|---------------------|
| Generic | Overall design review | Is the game concept fun? Is the core loop satisfying? |
| Targeted | **The new system** | Is it integrated well? Does it create interesting decisions? |

### For BALANCE + CONTENT Iterations (Even: v2, v4, v6...)

| Agent | Focus | Questions to Answer |
|-------|-------|---------------------|
| Generic | Overall balance review | Any dominant strategies? Dead choices? |
| Targeted | **Economy & progression** | Are costs/rewards balanced? Progression pacing right? |

### For REFACTOR Iterations (v5, v10, v15...)

| Agent | Focus | Questions to Answer |
|-------|-------|---------------------|
| Generic | Regression check | Does everything still work after refactoring? |
| Targeted | **Performance** | Frame rate stable? Memory usage reasonable? |

---

## Step 3: Run Simulator Smoke Tests

### Build and Verify

```bash
# Clean build
xcodebuild clean build \
  -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | tail -20

# Run unit tests
xcodebuild test \
  -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "(Test Case|passed|failed|error:)"
```

### Capture Screenshots

```bash
# Boot simulator, install and launch app, take screenshots
xcrun simctl boot "iPhone 16"
xcrun simctl io booted screenshot screenshots/main_screen.png
```

---

## Step 4: Launch Analysis Agents (0, 1, or 2)

All agents use the **haiku** model for cost efficiency. Launch with `run_in_background: true`.

### Agent 1: Generic Tester (Design & Code Review)

Use the GENERIC_PROMPT template. This agent reviews the game design and code for overall fun.

### Agent 2: Targeted Tester (You Customize)

Use the TARGETED_PROMPT template. Focus on your specific question for this iteration.

---

## Prompt Templates

### GENERIC_PROMPT (Agent 1 - model: haiku)

```
You are analyzing the iOS game "{GameName}" for OVERALL FUN and design quality.

IMPORTANT RULES:
- Review the game CODE and DESIGN DOCUMENT, not play the game
- Focus on whether the design is fun, balanced, and engaging
- Look for common mobile game design pitfalls
- Be specific with evidence from the code

SETUP:
1. Read the Game Design Document: {GameName}/GDD.md
2. Read the main game logic files:
   - {GameName}/{GameName}/GameScene.swift (or equivalent)
   - {GameName}/{GameName}/GameModel.swift (or equivalent)
3. Read any test files for context

ANALYSIS AREAS:

1. **Core Loop Quality**
   - Is the core loop clearly defined in code?
   - Does each action feel meaningful (produces visible feedback)?
   - Are there enough varied actions to prevent repetition?
   - Is session length appropriate for mobile (2-5 min satisfying)?

2. **Progression & Pacing**
   - Review unlock conditions: Are they achievable but challenging?
   - Check XP/level curves: Do they follow a good difficulty curve?
   - Look for "dead zones" where nothing new happens for too long
   - Verify early game hooks players within first 30 seconds

3. **Economy Balance** (review the actual numbers in code)
   - For each resource: What are ALL sources and ALL sinks?
   - Are there resources with no sinks (inflation)?
   - Are there resources that drain faster than they replenish (deflation)?
   - Can the player get stuck with no way to progress?

4. **Mobile-Specific Design**
   - Touch targets >= 44pt?
   - UI readable on small screens (iPhone SE)?
   - No precision-dependent mechanics that frustrate on touchscreen?
   - Graceful handling of interruptions (phone call, notification)?

5. **Code Quality for Games**
   - Game state properly separated from rendering?
   - State serialization for save/load?
   - No force-unwraps on dynamic data?
   - Proper memory management (weak references in closures)?

FINAL REPORT:

## Generic Analysis Report

### Overall Fun Rating: [1-10, where 5="okay", 7+="would play again"]

### Core Loop Assessment
- Is it satisfying to repeat? Why/why not?
- Specific code evidence for each point

### Economy Analysis
For each resource found in code:
- Source rate vs sink rate
- Risk of inflation/deflation
- Specific line numbers and values

### Mobile Design Score: [1-10]
- Touch handling quality
- Screen size adaptability
- Session length appropriateness

### Progression Curve Issues
- Specific unlock thresholds that seem too easy/hard
- Dead zones in progression (level ranges with nothing new)

### Top 3 Suggestions (SPECIFIC AND ACTIONABLE)
1. [Specific change with file, line, and suggested values]
2. [Another specific suggestion]
3. [Another specific suggestion]
```

### TARGETED_PROMPT (Agent 2 - You Fill In Focus, model: haiku)

```
You are analyzing the iOS game "{GameName}" with a SPECIFIC FOCUS.

YOUR FOCUS: {focus_area}

SPECIFIC QUESTIONS TO ANSWER:
{focus_questions}

IMPORTANT RULES:
- Review the game CODE and DESIGN DOCUMENT
- Focus specifically on {focus_area}
- Provide evidence from code (file paths, line numbers, actual values)
- Be quantitative where possible

SETUP:
1. Read GDD.md at {GameName}/GDD.md
2. Read relevant game code files
3. Focus your analysis on {focus_area}

ANALYSIS APPROACH:

1. **Read all code related to {focus_area}**
   - Find relevant classes, methods, and constants
   - Map out how the system works end-to-end

2. **Evaluate design quality**
   - Does {focus_area} create interesting decisions?
   - Are there dominant strategies?
   - Are there dead-end choices?

3. **Check integration**
   - How does {focus_area} connect to other systems?
   - Are there missing connections that would make it more interesting?

4. **Review numbers**
   - Are the specific values (costs, rates, thresholds) reasonable?
   - Compare early vs late game values

FINAL REPORT:

## Targeted Analysis Report: {focus_area}

### Focus Area Rating: [1-10]

### System Analysis
2-3 paragraphs covering:
- How the system works (with code references)
- What works well (with specific evidence)
- What doesn't work (with specific evidence)
- Specific values that seem off (file:line, current value, suggested value)

### Answers to Focus Questions
For EACH question:
- Direct answer (yes/no/partially)
- Code evidence (file, line number, relevant code)

### Integration Assessment
- How {focus_area} connects to other systems
- Missing connections that would improve gameplay

### Balance Issues
- Specific numbers that seem wrong
- Comparison of related values (costs vs rewards)

### Top 3 Recommendations (SPECIFIC AND ACTIONABLE)
1. [File:line - specific change with current and suggested values]
2. [Another specific recommendation]
3. [Another specific recommendation]
```

---

## Step 5: Monitor and Collect Results

If agents were launched in background:

1. Wait ~30 seconds
2. Read tail of both output files
3. Print status update to user
4. Repeat until agents complete

---

## Step 6: Synthesize Findings

Combine all data sources:

1. **Simulator test results** - Build success, test pass rate, screenshots
2. **Generic Report** (if launched) - Overall fun and design quality
3. **Targeted Report** (if launched) - Specific focus area analysis

### Preserve Specificity

**Bad synthesis**: "The economy needs work"
**Good synthesis**: "Economy issue in GameModel.swift:142 - gold reward for defeating basic enemy is 50, but cheapest upgrade costs 500. Player needs 10 kills per upgrade with no variation. Suggestion: add gold scaling (line 142: change `50` to `50 + level * 10`) and add bonus gold events."

### Create Prioritized Findings

| Priority | Type | Required Detail |
|----------|------|-----------------|
| Critical | Build failures, crashes | Exact error, file, line |
| High | Design feels unfun or unbalanced | Specific mechanic, suggested fix |
| Medium | Balance issues, unclear mechanics | Current values, suggested values |
| Low | Polish, minor UX issues | What's confusing, suggested fix |

---

## Idle/Passive Rewards Check (Quick Analysis)

Review the game's time-based systems:

1. **Check update loops** - Does the game give rewards for time passing?
2. **Check offline rewards** - What happens when the player returns after being away?
3. **Review energy systems** - Do they gate actions or give free stuff?

**Rule**: Players should only progress by making decisions. Time-gated resources that gate actions are fine. Free rewards that accumulate while idle break the game.

---

## Quick Reference

```
# 1. Build and test
xcodebuild clean build test -project {GameName}.xcodeproj ...

# 2. Decide agent count based on existing analysis
# 0 agents: Recent analysis exists, just synthesize
# 1 agent: Have general analysis, need specific answer
# 2 agents: No recent analysis

# 3. Launch agents with Task tool (haiku model, background)

# 4. Monitor progress, collect results

# 5. Synthesize into prioritized findings with specific code references
```
