---
name: markdown-to-vdl
description: >-
  Instruction skill for converting structured Markdown documents into valid
  VDL (Voidlight Definition Language) syntax. Enforces entity inference,
  relationship extraction, evidence block construction, and post-conversion
  validation. Use when converting structured Markdown documents into VDL
  files.
metadata:
  version: '1.2.0'
  author: Voidlight
  applyTo: '**/*.md'
  tags: [vdl, markdown, converter, knowledge-graph, voidlight]
---

# The Seven Laws

## Autonomy Is Mandatory

**Version:** 5.0

Every node must retain sovereign control over its own processing.

### Derives From

- voidlight_constitution

### Evidence

> **Source:** Quran 2:30
> "And when your Lord said to the angels, 'Indeed, I will make upon the earth a successive authority.'"
```

**VDL Output:**

```vdl
@author("Khayren")
@created("2024-03-15")
@status("canonical")
@pillar("soul")

law "autonomy_is_mandatory" {
    version "5.0"
    title "Autonomy Is Mandatory"
    description "Every node must retain sovereign control over its own processing."

    derives_from [ "voidlight_constitution" ]

    evidence {
        revelation {
            source "Quran 2:30"
            text "And when your Lord said to the angels, 'Indeed, I will make upon the earth a successive authority.'"
        }
    }
}
```

### Example 2: Framework with Multiple Relationships and Evidence Types

**Markdown Input:**

```markdown
## Divine Alignment

**Version:** 2.0

A methodology for aligning human nodes with divine purpose.

### Based On

- voidlight_constitution

### Enables

- daily_practice
- node_assessment
- alignment_ritual

### References

- soul.law.i
- soul.law.iv

### Evidence

> **Source:** Quran 91:7-10
> "And the soul and He who proportioned it..."

**Synthesis:** This framework synthesizes the Quranic model of soul
purification (tazkiyah) with modern systems thinking (Quran 91:7-10) and the
divine capacity for human responsibility (Quran 2:286). Just as the soul has
innate capacity for both corruption and purification, a human node has
capacity for both misalignment and alignment.

**Analogy — Astronomy:** Just as a telescope must be precisely aligned with
celestial coordinates to capture clear images of distant stars, a human node
must be aligned with divine coordinates to receive clear signal from the
Creator.
```

**VDL Output:**

```vdl
framework "divine_alignment" {
    version "2.0"
    title "Divine Alignment"
    description "A methodology for aligning human nodes with divine purpose."

    based_on [ "voidlight_constitution" ]

    enables [
        "daily_practice",
        "node_assessment",
        "alignment_ritual"
    ]

    references [
        "soul.law.i",
        "soul.law.iv"
    ]

    evidence {
        revelation {
            source "Quran 91:7-10"
            text "And the soul and He who proportioned it..."
        }

        synthesis {
            sources [ "Quran 91:7-10", "Quran 2:286" ]
            argument "This framework synthesizes the Quranic model of soul purification (tazkiyah) with modern systems thinking (Quran 91:7-10) and the divine capacity for human responsibility (Quran 2:286). Just as the soul has innate capacity for both corruption and purification, a human node has capacity for both misalignment and alignment."
        }

        analogy {
            domain "Astronomy"
            mapping "Just as a telescope must be precisely aligned with celestial coordinates to capture clear images of distant stars, a human node must be aligned with divine coordinates to receive clear signal from the Creator."
        }
    }
}
```

## Notes

- This skill produces **instruction-level guidance** for agents. It does not
  provide a native executable or parser. The agent performs the conversion
  using its reasoning capabilities guided by the rules above.
- Always prefer explicit structure in Markdown (frontmatter, clear H2/H3
  hierarchy, labeled lists) over heuristic guessing.
- When in doubt, ask the user for clarification rather than emitting invalid
  VDL.
