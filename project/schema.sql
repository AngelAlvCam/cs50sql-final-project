-- Entities
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
    "password"  TEXT NOT NULL,
    "join_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

CREATE TABLE "playlists" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("user_id", "name")
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

CREATE TABLE "songs" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "length" NUMERIC NOT NULL,
    "genre" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "artists" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "albums" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "release_date" NUMERIC NOT NULL,
    PRIMARY KEY("id")
);

-- Relations
-- Relation between "users" and "playlists"
CREATE TABLE "follows" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "playlist_id" INTEGER NOT NULL,
    UNIQUE("user_id", "playlist_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("playlist_id") REFERENCES "playlists"("id")
);

-- Relation between "playlists" and "songs"
CREATE TABLE "contains" (
    "id" INTEGER,
    "playlist_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    "playlist_order" INTEGER NOT NULL,
    UNIQUE("playlist_id", "song_id"),
    UNIQUE("playlist_id", "playlist_order"),
    PRIMARY KEY("id"),
    FOREIGN KEY("playlist_id") REFERENCES "playlists"("id"),
    FOREIGN KEY("song_id") REFERENCES "songs"("id")
);

-- Relation between "users" and "artists"
CREATE TABLE "likes" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "artist_id" INTEGER NOT NULL,
    UNIQUE("user_id", "artist_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id")
);

-- Relation between "artists" and "songs"
CREATE TABLE "contributes" (
    "id" INTEGER,
    "artist_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    UNIQUE("artist_id", "song_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id"),
    FOREIGN KEY("song_id") REFERENCES "songs"("id")
);

-- Relation between "artists" and "album"
-- This table allows "album_id" to be NULL when the a non-specific artist released an album
-- i.e. The Matrix Soundtrack 
CREATE TABLE "releases" (
    "id" INTEGER,
    "artist_id" INTEGER NULL,
    "album_id" INTEGER NOT NULL,
    UNIQUE("artist_id", "album_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id"),
    FOREIGN KEY("album_id") REFERENCES "albums"("id")
);

-- Relation between "albums" and "songs"
CREATE TABLE "includes" (
    "id" INTEGER,
    "album_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    "track" INTEGER NOT NULL,
    UNIQUE("album_id", "song_id"),
    UNIQUE("album_id", "track"),
    PRIMARY KEY("id"),
    FOREIGN KEY("album_id") REFERENCES "albums"("id"),
    FOREIGN KEY("song_id") REFERENCES "songs"("id")
);

-- Useful views
-- View to retrieve how many songs and albums a artist has
CREATE VIEW "artists_stats" AS
SELECT "artists"."name" AS "artist", ifnull("albums_count", 0) AS "albums", ifnull("songs_count", 0) AS "songs"
FROM "artists"
LEFT JOIN (
    SELECT "artist_id", COUNT(DISTINCT "id") AS "albums_count" 
    FROM "releases" 
    GROUP BY "artist_id"
) AS "album_counts" ON "album_counts"."artist_id" = "artists"."id"
LEFT JOIN (
    SELECT "artist_id", COUNT(DISTINCT "id") AS "songs_count" 
    FROM "contributes" 
    GROUP BY "artist_id"
) AS "song_counts" ON "song_counts"."artist_id" = "artists"."id"
ORDER BY "albums" DESC, "songs" DESC, "artist";

-- Songs per genre in the database
-- CREATE INDEX "songs_genre" ON "songs"("genre");
CREATE VIEW "genre_stats" AS
SELECT "genre", count("genre") AS "songs"
FROM "songs"
GROUP BY "genre"
ORDER BY "songs" DESC, "genre";

-- List more popular songs (by songs in playlists)
CREATE VIEW "songs_ranking" AS
SELECT "name", "artists", ifnull("playlists", 0) AS "in_playlists"
FROM "songs"
LEFT JOIN (
    select "song_id", group_concat("artists"."name", ', ') as "artists"
    from "contributes"
    join "artists" on "contributes"."artist_id" = "artists"."id"
    group by "song_id"
) AS "song_artists" ON "songs"."id" = "song_artists"."song_id"
LEFT JOIN (
    SELECT "song_id", count("song_id") AS "playlists"
    FROM "contains"
    GROUP BY "song_id"
) AS "song_playlists" ON "song_artists"."song_id" = "song_playlists"."song_id"
ORDER BY "in_playlists" DESC, "name", "artists";

-- List artists in descending order of popularity (by followers)
CREATE VIEW "artists_ranking" AS
SELECT "name", ifnull("likes_count", 0) AS "followers"
FROM "artists" 
LEFT JOIN (
    SELECT "artist_id", count("artist_id") AS "likes_count"
    FROM "likes"
    GROUP BY "artist_id"
) AS "artists_likes" ON "artists"."id" = "artists_likes"."artist_id"
ORDER BY "followers" DESC;

-- List songs in the database 
CREATE VIEW "song_details" AS
SELECT "includes"."track", "songs"."name", "songs"."length", "songs"."genre", group_concat("artists"."name", ', ') AS "artists"
FROM "songs"
JOIN "includes" ON "includes"."song_id" = "songs"."id"
JOIN "albums" ON "includes"."album_id" = "albums"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "albums"."name" = "12:00"
GROUP BY "songs"."id"
ORDER BY "albums"."name", "includes"."track";