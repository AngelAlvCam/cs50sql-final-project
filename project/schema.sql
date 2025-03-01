-- Entities
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL,
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
    "name" TEXT NOT NULL,
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
    UNIQUE("album_id", "song_id"),
    PRIMARY KEY("id"),
    FOREIGN KEY("album_id") REFERENCES "albums"("id"),
    FOREIGN KEY("song_id") REFERENCES "songs"("id")
);