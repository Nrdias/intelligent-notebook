# UI Component Architecture & Design System Guidelines

## 1. Clean & Generic Naming
- NEVER name widgets, files, or classes after third-party commercial brands (e.g. avoid `SamsungIconButton`, `SamsungColorPaletteDialog`).
- Use clean, domain-agnostic UI component names (e.g. `ToolbarIconButton`, `ColorPaletteDialog`, `PresetPill`).

## 2. Single Widget Per File Rule
- NEVER declare private secondary `Widget` or `CustomPainter` classes inside a main widget file (e.g. do not put `_SamsungIconButton` or `_LivePreviewBox` inside `toolbar.dart`).
- Every component, sub-widget, or custom painter MUST have its own dedicated `.dart` file.

## 3. Design System & Component Scoping
- **Global Design System (`lib/core/presentation/design_system/`)**:
  - Contains reusable, domain-agnostic UI primitives used across multiple features or screens (e.g. `buttons/`, `dialogs/`, `swatches/`, `pills/`, `inputs/`).
- **Feature-Scoped Widgets (`lib/features/<feature_name>/presentation/widgets/`)**:
  - Contains domain-specific components tied to a single feature scope (e.g. `drawing_canvas.dart`, `selection_overlay/`).
- **Folder-based Component Scoping**:
  - If a widget has internal sub-components, painters, or state notifiers/cubits, create a dedicated folder named after the component (e.g. `lib/features/canvas/presentation/widgets/pen_options_popup/`).
