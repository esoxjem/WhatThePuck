# Gamification for WTP

## Philosophy

Gamification in WTP should feel like **encouragement from a knowledgeable barista friend**, not a slot machine. The terminal aesthetic enables personality-rich feedback that feels earned and authentic.

### Core Principles
- **Celebrate mastery, not just activity** — Reward getting better, not just showing up
- **Respect the craft** — Espresso is already rewarding; amplify that, don't replace it
- **No dark patterns** — No artificial scarcity, manufactured urgency, or guilt mechanics
- **Offline-first** — All motivation systems work without connectivity
- **Subtle > loud** — Terminal messages, not confetti explosions

## Intrinsic Motivation Systems

### Progress Visualization

**Dial-in Journey**
Show movement toward dialed-in state:
```
[▓▓▓▓▓▓▓▓░░] 80% dialed in
Getting close. Time is consistent now.
```

**Skill Progression**
Track understanding, not just volume:
- Shots logged → Patterns recognized → Adjustments mastered
- "You've learned how grind affects this roast level."

**Personal Bests**
Surface achievements naturally:
- Longest streak of shots in target ratio
- Fastest dial-in for a new bean
- Most consistent extraction times

### Mastery Feedback

**Contextual Insight Messages**
The terminal is perfect for this:
```
Your last 5 shots averaged 1:2.1.
That's your tightest ratio spread this month.
```

**Cause-Effect Recognition**
When patterns emerge:
```
Finer grind + same dose = longer time.
You're getting the hang of this.
```

**Milestone Acknowledgment**
Quiet recognition:
```
50 shots with Silver Oak.
You know this bean now.
```

### Autonomy Support

**No Forced Engagement**
- Never guilt for not logging ("You haven't logged in 3 days!")
- Welcome back without judgment
- "Morning. Ready when you are."

**User-Defined Goals**
- Let users set their own targets
- "Trying for 1:2 this week? I'll track it."

**Choice Architecture**
- Recommendations, not mandates
- "Let's try 18g next" — suggestion, not requirement

## Extrinsic Motivation Systems

### Achievement Framework

**Design Principles**
- Achievements should teach or celebrate genuine progress
- Hidden achievements for discovery delight
- No achievements for basic expected behavior

**Achievement Categories**

*Consistency*
- "Steady Hand" — 5 shots within ±0.5g yield variance
- "Clockwork" — 10 shots within ±2s time variance
- "Dialed" — Hit target ratio 7 days running

*Exploration*
- "Bean Counter" — Logged shots with 10 different beans
- "Grind Whisperer" — Used full range of grinder settings
- "Ratio Explorer" — Tried ratios from 1:1.5 to 1:3

*Mastery*
- "Quick Study" — Dialed in a new bean in ≤3 shots
- "Palate Trust" — Made adjustment based on taste, nailed it
- "Seasonal" — Logged shots across all four seasons

*Milestones*
- "First Pull" — Log your first shot
- "Century" — 100 shots logged
- "Thousand" — 1,000 shots logged

**Terminal-Native Achievement Display**
```
> ACHIEVEMENT UNLOCKED
> "Steady Hand"
> 5 shots. Tight grouping.
> You've got control.
```

### Streak Systems

**Ethical Streak Design**
- Streaks celebrate consistency, don't punish breaks
- Grace periods for weekends/travel
- "Streak paused" not "Streak lost"

**Types**
- Daily logging streak (with grace)
- Consecutive good shots
- Days with a bean before it goes stale

**Terminal Presentation**
```
Day 12.
Still going.
```

Not:
```
🔥🔥🔥 12 DAY STREAK! Don't break it! 🔥🔥🔥
```

### Milestone Moments

**Contextual Celebration**
Tie milestones to meaning:
```
Shot 100.
You've wasted maybe 2kg of beans learning.
Worth it.
```

**Bean-Specific**
```
Last shot with this bag.
Started sour, ended sweet.
Good run.
```

**Temporal**
```
One year of WhatThePuck.
412 shots. 23 beans. 
You've changed.
```

## Terminal Message Integration

### Message Triggers for Gamification

**Achievement Earned**
- Interrupt normal flow briefly
- Return to standard messaging after acknowledgment

**Streak Update**
- Passive mention in daily greeting
- Not every interaction

**Milestone Approaching**
- Gentle anticipation building
- "Shot 99. One more for a century."

**Personal Best**
- Surface when broken
- "New record. Tightest ratio spread: ±0.05"

### Tone Guidelines

**Do**
- Understated pride: "Not bad."
- Dry humor: "Disaster. Start from scratch." (already in app)
- Factual acknowledgment: "That's 7 in a row."

**Don't**
- Excessive enthusiasm: "AMAZING JOB!!! 🎉"
- Guilt: "You haven't logged a shot in 3 days..."
- Pressure: "Don't break your streak!"

### Message Examples by Context

**Morning, streak active**
```
Day 8.
Coffee's waiting.
```

**After good shot, approaching milestone**
```
Shot 99.
Tomorrow's a big one.
```

**Achievement unlocked**
```
> UNLOCKED: "Quick Study"
> Dialed in 3 shots.
> Some beans just click.
```

**Returned after break**
```
Been a minute.
No judgment. Let's dial in.
```

**Personal best broken**
```
Tightest spread yet.
You're more consistent than last month.
```

## Anti-Patterns to Avoid

### Dark Patterns
- ❌ Loss aversion: "You'll lose your streak!"
- ❌ Artificial scarcity: "Limited time achievement!"
- ❌ Social pressure: "Your friends have logged more shots"
- ❌ Variable rewards: Randomized/gambling mechanics
- ❌ Guilt messaging: Negative framing for inactivity

### Hollow Gamification
- ❌ Points for everything (inflation)
- ❌ Badges without meaning
- ❌ Leaderboards (comparing personal journeys)
- ❌ Achievements for basic app usage
- ❌ Daily login rewards (manufactured engagement)

### Breaking Immersion
- ❌ Cartoon characters/mascots
- ❌ Confetti/particle effects
- ❌ Sound effects for every action
- ❌ Pop-up modals interrupting flow
- ❌ Gamification that contradicts terminal aesthetic

## Implementation Considerations

### Data Requirements
- Shot history with timestamps
- Bean tracking with bag lifecycle
- Grind setting history per grinder
- User-defined goals/targets

### State Management
- Streak state with grace period logic
- Achievement progress tracking
- Personal best records
- Milestone counters

### Offline Behavior
- All gamification works offline
- Achievements unlock locally
- Sync metadata when connected
- No server-dependent rewards
