```mermaid
---
title: ER Diagram
---
erDiagram
    USER }o--o{ ARTIST : likes
    USER }o--o{ PLAYLIST : follows
    USER ||--o{ PLAYLIST : owns
    PLAYLIST }o--o{ SONG : contains
    ALBUM }|--|{ SONG : includes
    ARTIST }o--|{ ALBUM: releases
    SONG }|--|{ ARTIST : contributes
```