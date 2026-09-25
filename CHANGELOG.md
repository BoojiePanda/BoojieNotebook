# Changelog

## 1.0.13 — 2026-09-25

Boojie Notebook has a fresh new button and plays nicely with minimap-button collectors.

- Replaced the old notebook artwork with a crisp black-and-pink **BN** icon using Bellota Bold.
- Updated the AddOns list, settings page, addon window, and minimap button to use the same icon.
- Rebuilt the minimap button with LibDataBroker and LibDBIcon for better compatibility with WindTools and similar button bars.
- Preserved the existing show/hide preference and migrated the old minimap position automatically.
- Removed the obsolete settings icon and retired the custom Blizzard-style minimap-button frame.
- Outsmarted a wonderfully sneaky WindTools filter: it ignores button names containing `Note` so map-note pins stay out of the bar. Unfortunately, `BoojieNotebook` wandered directly into that trap. The internal button ID is now `BoojieBN`, while the name players see remains **Boojie Notebook**.
