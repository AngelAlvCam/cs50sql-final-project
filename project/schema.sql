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
    "name" TEXT NOT NULL,
    "length" NUMERIC NOT NULL,
    "genre" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "artist" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "album" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "year" NUMERIC NOT NULL,
    "release_date" NUMERIC NOT NULL,
    PRIMARY KEY("id")
);