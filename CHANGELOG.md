# Changelog

## [0.2.0] - 2025-07-31

### Added
- 🔍 Introduced new **row-wise diagnosis engine** with strict matching rules for pulp/periapical/etiology logic
- 🧠 Diagnosis results are now returned as a **list of possible scenarios**, not just a single outcome
- 🎯 Frontend (`diagnosis_result.dart`) now displays **multiple diagnosis cards**, each representing one matching rule
- ✅ Added `results` field to `VisitHistory` model and serializer for better frontend compatibility

### Changed
- 🔁 Refactored answer matching to prevent false matches (e.g., Normal Pulp with Hypersensitive Cold Test)
- 🗂 Column mappings updated to match user-facing labels (e.g., "Cold Test", "Sinus Tract", etc.)
- 🔐 Improved filtering for `Possibility != "No"` in Excel sheet
- 🧪 Revised test class to use frontend-style keys and verify structured diagnosis output

### Fixed
- 🐞 Bug where invalid diagnosis combinations could appear due to column-based filtering
- 🚫 Eliminated matching across rows (e.g., mixed etiology from one row and pulp dx from another)

---

