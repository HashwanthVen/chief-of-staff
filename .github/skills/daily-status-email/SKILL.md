---
name: 'create-daily-status-email'
description: 'Generate a daily status email for your manager with action items and key meetings, pulling context from WorkIQ (Outlook, Teams, Calendar). Automatically sends to the configured recipient.'
---

# Daily Status Email Generator

Generate a professional daily status email summarizing your accomplishments, action items, and
key meetings. **Auto-sends to the configured recipient after generation.**

---

## When to Use

- `"Generate my daily status email"`
- `"Draft status update for my manager"`
- `"What did I accomplish today?"`
- `"Create end-of-day status report"`
- `"Daily status for [date]"`

---

## How to Execute

### Step 1: Gather Context from WorkIQ

```
Use: workiq/ask_work_iq
Query: "What meetings did I have today? Include attendees and any notes."

Use: workiq/ask_work_iq
Query: "What important emails did I send or receive today?"

Use: workiq/ask_work_iq
Query: "What were my Teams conversations about today?"
```

### Step 2: Synthesize Action Items

For each significant activity:
1. **What was accomplished** -- Specific deliverable or decision
2. **Who was involved** -- Key stakeholders
3. **What's next** -- Committed follow-ups or deadlines

### Step 3: Synthesize Meeting Summary

For each meeting:
1. **Meeting name** -- Calendar title
2. **Attendees** -- All participants
3. **Follow-Up Tasks** -- Action items, decisions, next steps

### Step 4: Generate Email

Use the output template below. Read `config/user-context.yaml` for recipient and subject prefix.

### Step 5: Review and Send

Review for quality, then send via:
```
Use: mcp_mailtools/SendEmailWithAttachments
Parameters:
  to: ["<recipient from config/user-context.yaml>"]
  subject: "<subjectPrefix>: Daily Status Update as of [MM/DD/YYYY]"
  body: [Generated email content in HTML format]
```

---

## Output Template

```markdown
To: <recipient from config/user-context.yaml>
Subject: <subjectPrefix>: Daily Status Update as of [MM/DD/YYYY]

## Tasks Completed

• [Concise task with outcome and next steps]
• [Task with stakeholders and timeline]

## Key Meetings

| Meeting | Key Participants | Follow-Up Tasks |
|---------|------------------|-----------------|
| [Meeting Name] | [Name1], [Name2] | [Task]; [Decision] |
```

---

## Writing Guidelines

- **Lead with the action verb** (Finalized, Investigated, Resolved, Agreed, Confirmed)
- **Include context** -- What problem was solved, what decision was made
- **Name stakeholders** -- Who you coordinated with
- **State outcome** -- What was delivered or committed
- **Mention timeline** -- When it will be done (if applicable)

**Good:** Finalized schema updates for eligibility reports, agreeing to rename confusing fields. Committed to complete changes in the current sprint.

**Bad:** Worked on schema stuff for reports.
