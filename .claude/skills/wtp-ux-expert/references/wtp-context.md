# WTP Domain Context

## User Personas

### Beginner Barista
- Just got first espresso machine
- Overwhelmed by variables (grind, dose, yield, time)
- Needs guidance, not just tracking
- Success = drinkable shot, building confidence
- Risk: information overload, abandonment

### Intermediate Barista
- Understands basics, wants to improve consistency
- Tracks shots but struggles to interpret patterns
- Wants to understand *why* adjustments work
- Success = repeatable good shots, fewer wasted beans
- Risk: plateau frustration, feature complexity

### Advanced Barista
- Deep understanding of extraction theory
- Uses WTP for logging and pattern analysis
- May have multiple grinders, beans in rotation
- Success = fine-tuning, experimentation insights
- Risk: app too basic, missing power features

## Core Concepts

### Shot
Central entity—a single espresso extraction attempt.
- **Inputs**: dose (g), grind setting, bean, water temp
- **Outputs**: yield (g), time (s), calculated ratio
- **Assessment**: taste notes, rating, extraction quality
- Mental model: recipe attempt → outcome → learning

### Bean
Coffee being used—directly affects all parameters.
- Roast date matters (freshness window)
- Origin/roast affects ideal extraction
- Users often rotate multiple beans
- Mental model: ingredient that changes the rules

### Grinder
The adjustment lever—grind size is primary dial-in variable.
- Settings are grinder-specific (not universal)
- Users need per-grinder tracking
- Step vs. stepless affects precision
- Mental model: the main thing I adjust

### Recipe/Target
The goal state—what user is trying to achieve.
- Ratio (dose:yield), target time range
- May vary by bean, preference
- Mental model: the destination

## Key User Journeys

### New Shot Flow
Most frequent action—must be fast and frictionless.
1. User pulls shot (physical action)
2. Logs key data (dose, yield, time)
3. Quick assessment (good/adjust/bad)
4. Gets guidance on next adjustment
- **UX priority**: Speed over completeness. Pre-fill smart defaults.

### Dial-In Session
Multiple shots to find sweet spot for new bean.
1. Log first shot with new bean
2. Get adjustment recommendation
3. Pull adjusted shot, log again
4. Repeat until dialed in
5. Save as recipe/baseline
- **UX priority**: Clear progression, history visible, pattern recognition.

### Review & Learn
Retrospective analysis of past shots.
1. Browse shot history
2. Filter/group by bean, grinder, time
3. Spot patterns and trends
4. Extract insights
- **UX priority**: Visualization, comparison, insight surfacing.

## Domain-Specific UX Considerations

### Time Sensitivity
- Users are mid-workflow (shot just pulled, hands may be wet/dirty)
- Quick entry > comprehensive entry
- Support one-handed operation

### Variable Relationships
- Changes cascade: grind affects time, dose affects yield
- Help users understand cause-effect
- Visualize relationships when possible

### Subjectivity of Taste
- "Good" is personal and contextual
- Avoid implying objective right/wrong
- Support user's own calibration journey

### Equipment Diversity
- Wide range of machines, grinders, accessories
- Don't assume specific equipment features
- Grind settings are relative, not absolute

### Offline-First Reality
- Users may be in kitchens with poor connectivity
- All core features must work offline
- Sync gracefully when connected

### Terminal UI Personality
- Monospace typography, dark theme, typewriter effect
- Contextual messages feel like a knowledgeable barista friend
- Dry, understated tone: "Not bad." / "Disaster. Start from scratch."
- Messages respond to time, context, streaks, milestones
- No excessive enthusiasm or emoji
- Gamification integrates into this voice, not separate

### Learning Curve Respect
- Espresso is already complex—app shouldn't add complexity
- Progressive disclosure: basics first, depth on demand
- Celebrate progress to maintain motivation
