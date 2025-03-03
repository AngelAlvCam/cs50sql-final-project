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
SELECT "name" AS "artist", count(DISTINCT "releases"."id") AS "albums", count(DISTINCT "contributes"."id") AS "songs"
FROM "artists"
LEFT JOIN "releases" ON "releases"."artist_id" = "artists"."id"
JOIN "contributes" ON "contributes"."artist_id" = "artists"."id"
GROUP BY "name"
ORDER BY "albums" DESC, "songs" DESC, "name";

-- Songs per genre in the database
CREATE VIEW "genre_stats" AS
SELECT "genre", count(*) AS "songs"
FROM "songs"
GROUP BY "genre"
ORDER BY "songs" DESC, "genre";

-- List more popular songs (by songs in playlists)
CREATE VIEW "songs_ranking" AS
SELECT "songs"."name", group_concat(DISTINCT "artists"."name") AS "artists", count(DISTINCT "playlists"."name") AS "in_playlists"
FROM "songs"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
LEFT JOIN "contains" ON "contains"."song_id" = "songs"."id"
LEFT JOIN "playlists" ON "contains"."playlist_id" = "playlists"."id"
GROUP BY "songs"."name"
ORDER BY "in_playlists" DESC, "songs"."name", "artists";

-- List artists in descending order of popularity (by followers)
CREATE VIEW "artists_ranking" AS
SELECT "name", count("artist_id") AS "followers"
FROM "artists"
LEFT JOIN "likes" ON "likes"."artist_id" = "artists"."id"
GROUP BY "artists"."id"
ORDER BY "followers" DESC, "name";

-- List albums in the database with it's releasers
CREATE VIEW "album_details" AS
SELECT "albums"."name", ifnull(group_concat("artists"."name", ', '), 'Various Artists') AS "artists", "release_date"
FROM "albums"
JOIN "releases" ON "releases"."album_id" = "albums"."id"
LEFT JOIN "artists" ON "releases"."artist_id" = "artists"."id"
GROUP BY "albums"."name"
ORDER BY "release_date", "albums"."name", "artists";

-- List songs in the database 
CREATE VIEW "song_details" AS
SELECT "includes"."track", "songs"."name", "songs"."length", "songs"."genre", group_concat("artists"."name", ', ') AS "artists", "albums"."name" AS "album"
FROM "songs"
JOIN "includes" ON "includes"."song_id" = "songs"."id"
JOIN "albums" ON "includes"."album_id" = "albums"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
GROUP BY "songs"."name"
ORDER BY "albums"."name", "includes"."track";