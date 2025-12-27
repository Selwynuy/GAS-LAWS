# Project Structure

This document describes the reorganized project structure based on Gas Laws.

## Directory Structure

```
lib/
├── main.dart                          # Application entry point
├── app/                               # Application-level configuration
│   ├── app.dart                       # Root MaterialApp widget
│   └── routes.dart                    # Route definitions and navigation
├── core/                              # Core functionality shared across features
│   ├── constants/
│   │   └── app_constants.dart         # Application-wide constants
│   ├── theme/
│   │   └── app_theme.dart             # Theme configuration
│   └── utils/
│       └── unit_converter.dart        # Unit conversion utilities
├── features/                          # Gas Law-based modules
│   ├── boyles_law/                    # Boyle's Law activities
│   │   ├── activities/
│   │   │   ├── syringe_test/         # Syringe Test activity
│   │   │   │   └── syringe_test_activity.dart
│   │   │   └── scuba_diving/         # Scuba Diving activity
│   │   │       ├── models/
│   │   │       │   └── diving_state.dart
│   │   │       ├── services/
│   │   │       │   └── diving_physics_service.dart
│   │   │       ├── widgets/
│   │   │       │   ├── action_buttons.dart
│   │   │       │   ├── diver_widget.dart
│   │   │       │   ├── graph_widgets.dart
│   │   │       │   ├── lungs_widget.dart
│   │   │       │   └── underwater_background.dart
│   │   │       └── dialogs/
│   │   │           ├── gas_law_calculator_dialog.dart
│   │   │           └── unit_conversion_dialog.dart
│   │   ├── quiz/
│   │   │   └── drag_drop_quiz_screen.dart
│   │   └── screens/
│   │       └── boyles_law_activities_screen.dart
│   ├── charles_law/                   # Charles Law activities
│   │   ├── activities/
│   │   │   ├── balloon_bottle/
│   │   │   │   └── balloon_bottle_activity.dart
│   │   │   └── rubber_boat/
│   │   │       └── rubber_boat_activity.dart
│   │   ├── quiz/
│   │   │   └── drag_drop_quiz_screen.dart
│   │   └── screens/
│   │       └── charles_law_activities_screen.dart
│   ├── combined_gas_law/              # Combined Gas Law activities
│   │   ├── activities/
│   │   │   ├── cryo_sim/
│   │   │   │   └── cryo_sim_activity.dart
│   │   │   └── true_false/
│   │   │       └── true_false_activity.dart
│   │   └── screens/
│   │       └── combined_gas_law_activities_screen.dart
│   ├── settings/                      # Settings feature
│   │   └── screens/
│   │       └── settings_screen.dart
│   └── start/                         # Start/landing screens
│       └── screens/
│           ├── start_screen.dart
│           └── gas_law_selection_screen.dart
└── shared/                            # Shared across features
    ├── models/
    │   └── volume_pressure_point.dart # Shared data models
    └── widgets/
        └── volume_pressure_chart.dart  # Shared widgets
```

## Gas Laws Organization

### 1. Boyle's Law
- **Syringe Test**: Interactive syringe experiment demonstrating pressure-volume relationship
- **Scuba Diving**: Diving simulation showing Boyle's Law in action
- **Drag and Drop Quiz**: Interactive quiz for Boyle's Law

### 2. Charles Law
- **Balloon and Bottle Experiment**: Temperature-volume relationship demonstration
- **Rubber Boat**: Another Charles Law experiment
- **Drag and Drop Quiz**: Interactive quiz for Charles Law

### 3. Combined Gas Law
- **Cryo-sim**: Cryogenic simulation activity
- **True or False**: True/false quiz activity

## Key Improvements

1. **Law-Based Organization**: Code is organized by gas law (boyles_law, charles_law, combined_gas_law) making it easier to locate and maintain related activities.

2. **Activity Structure**: Each activity has its own directory with:
   - Activity screen file
   - Activity-specific models, services, widgets, and dialogs (as needed)

3. **Separation of Concerns**:
   - `activities/`: Individual experiment/activity screens
   - `quiz/`: Quiz screens for each law
   - `screens/`: Activity selection screens
   - `models/`: Data models (activity-specific)
   - `services/`: Business logic and calculations (activity-specific)
   - `widgets/`: Reusable UI components (activity-specific)
   - `dialogs/`: Dialog widgets (activity-specific)

4. **Core Utilities**: Common functionality (constants, theme, utils) is centralized in the `core/` directory.

5. **Shared Resources**: Code used across multiple laws is in the `shared/` directory.

6. **Navigation**: Centralized route definitions in `app/routes.dart` for easier navigation management.

## File Naming Conventions

- Activity screens: `{activity_name}_activity.dart` (e.g., `syringe_test_activity.dart`)
- Activity selection screens: `{law_name}_activities_screen.dart` (e.g., `boyles_law_activities_screen.dart`)
- Models: `{model_name}.dart` (e.g., `diving_state.dart`)
- Services: `{service_name}_service.dart` (e.g., `diving_physics_service.dart`)

## Import Paths

All imports follow the new structure:
- Activity-specific imports use relative paths within the activity
- Core imports: `import '../../../core/...'`
- Shared imports: `import '../../../shared/...'`
- Cross-law imports: `import '../../other_law/...'`
