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
    "description" TEXT NOT NULL,
    "created_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

CREATE TABLE "songs" (
    "id" INTEGER,
    "name" TEXT,
    "length" NUMERIC,
    "genre" TEXT,
    PRIMARY KEY("id")
);

CREATE TABLE "artist" (
    "id" INTEGER,
    "name" TEXT,
    "description" TEXT,
    PRIMARY KEY("id")
);

CREATE TABLE "album" (
    "id" INTEGER,
    "name" TEXT,
    "year" NUMERIC,
    "release_date" NUMERIC,
    PRIMARY KEY("id")
);