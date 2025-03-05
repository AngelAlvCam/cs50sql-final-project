-- Entities
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
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

-- Trigger to automatically 'follow' a playlist created by a user.
CREATE TRIGGER "follow_own_playlist"
AFTER INSERT ON "playlists"
FOR EACH ROW
BEGIN
    INSERT INTO "follows" ("user_id", "playlist_id")
    VALUES (NEW."user_id", "NEW"."id");
END;

-- Trigger to prevent a user to unfollow its own playlists
CREATE TRIGGER "unfollow_playlist"
BEFORE DELETE ON "follows"
FOR EACH ROW
WHEN (
    SELECT "user_id"
    FROM "playlists"
    WHERE "id" = OLD."playlist_id"
) = OLD."user_id"
BEGIN
    SELECT raise(abort, 'Cannot unfollow owns playlist');
END;

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
    UNIQUE("song_id", "artist_id"),
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

-- Indexes
CREATE INDEX "albums_name" ON "albums"("name");
CREATE INDEX "playlists_name" ON "playlists"("name");
CREATE INDEX "songs_genre" ON "songs"("genre");
CREATE INDEX "contains_song_id" ON "contains"("song_id");
-- CREATE INDEX "songs_name" ON "songs"("name");
CREATE INDEX "likes_artist_id" ON "likes"("artist_id");
CREATE INDEX "contributes_artist_id" ON "contributes"("artist_id");

-- Useful views
-- View to retrieve how many songs and albums a artist has
CREATE VIEW "artists_stats" AS
SELECT "artists"."name" AS "artist", count(DISTINCT "song_id") AS "songs", count(DISTINCT "album_id") AS "albums"
FROM "artists"
LEFT JOIN "contributes" ON "contributes"."artist_id" = "artists"."id"
LEFT JOIN "releases" ON "releases"."artist_id" = "artists"."id"
GROUP BY "artists"."id"
ORDER BY "albums" DESC, "songs" DESC;

-- Songs per genre in the database
CREATE VIEW "genre_stats" AS
SELECT "genre", count("genre") AS "songs"
FROM "songs"
GROUP BY "genre"
ORDER BY "songs" DESC, "genre";

-- List more popular songs (by songs in playlists)
CREATE VIEW "songs_ranking" AS
SELECT "songs"."name", group_concat(DISTINCT "artists"."name") AS "artists", count(DISTINCT "contains"."playlist_id") AS "in_playlists"
FROM "songs"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
LEFT JOIN "contains" ON "contains"."song_id" = "songs"."id"
GROUP BY "songs"."id"
ORDER BY "in_playlists" DESC, "artists", "songs"."name";

-- List artists in descending order of popularity (by followers)
CREATE VIEW "artists_ranking" AS
SELECT "artists"."name", count("artist_id") AS "followers"
FROM "artists"
LEFT JOIN "likes" ON "artists"."id" = "likes"."artist_id"
GROUP BY "artists"."id"
ORDER BY "followers" DESC, "artists"."name";