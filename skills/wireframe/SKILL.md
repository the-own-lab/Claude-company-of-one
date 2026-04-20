---
name: wireframe
description: "Sketch low-fidelity UI wireframes before frontend work. Absorbs the former ui-designer agent's role as a skill. Uses Pencil MCP if available; otherwise produces an ASCII/markdown wireframe."
---

# Wireframe

Before writing a React component, sketch the layout. Saves rework when the layout is wrong.

## When to Use

- Any new page or screen
- Any non-trivial component with multiple states
- Redesigns of existing flows

Skip for: small tweaks (color change, copy edit, single-field addition).

## Two Modes

### Mode 1: Pencil MCP available

If the Pencil MCP server is configured (check for `mcp__pencil__*` tools):

1. Sketch the page layout via Pencil tools
2. Export as SVG / image
3. Reference from the `design-doc`

### Mode 2: Fallback — ASCII / markdown

If Pencil is not available, produce a text wireframe:

```
+---------------------------------------------------+
|  [Logo]              [Search...]      [Sign in]   |
+---------------------------------------------------+
|                                                   |
|   # Page title                                    |
|   Short subtitle or lede.                         |
|                                                   |
|   +-----------------+  +---------------------+    |
|   | Primary action  |  | Secondary action    |    |
|   +-----------------+  +---------------------+    |
|                                                   |
|   [ Content area ]                                |
|                                                   |
+---------------------------------------------------+
```

ASCII is fine. The point is shape + hierarchy, not pixel fidelity.

## What to Capture

- **Layout** — major regions and their relative position
- **Hierarchy** — which element is primary, secondary, tertiary
- **States** — empty, loading, error, filled (sketch each if they differ meaningfully)
- **Responsive** — note mobile behavior if it diverges (stack vs side-by-side)

## What to Ignore

- Colors, fonts, exact spacing — these belong to the component library (`packages/ui`)
- Animations — describe in words, don't try to sketch
- Pixel-perfect alignment — this is a wireframe, not a comp

## Integration

- Output goes into the `design-doc` as an embedded sketch or link
- For implementation, the wireframe is a reference, not a contract — adjust during build when reality intrudes
- If `packages/ui` has a matching primitive, name it next to the sketch (e.g. "use `<Card>` from `packages/ui`")

## Open Question (tracked in spec)

Whether Pencil MCP can be invoked from a skill (rather than an agent) — spike during first real use. If not, this skill produces only ASCII and a future revision may reintroduce a lightweight agent wrapper.

## What This Replaces

The former `ui-designer` agent's wireframing role. The role-specific persona ("senior UX designer") isn't needed for solo-dev wireframes — structure is.
