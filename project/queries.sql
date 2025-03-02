-- Insert
-- Import data from CSV files to the database tables
.import --csv --skip 1 data/albums.csv albums
.import --csv --skip 1 data/artists.csv artists
.import --csv --skip 1 data/playlists.csv playlists
.import --csv --skip 1 data/songs.csv songs
.import --csv --skip 1 data/users.csv users

-- Import data from the CSV to the junction tables in the database
.import --csv --skip 1 data/contains.csv contains
.import --csv --skip 1 data/contributes.csv contributes
.import --csv --skip 1 data/follows.csv follows
.import --csv --skip 1 data/includes.csv includes
.import --csv --skip 1 data/likes.csv likes
.import --csv --skip 1 data/releases.csv releases

-- Process NULL values in the releases.csv file
UPDATE "releases"
SET "artist_id" = NULL
WHERE "artist_id" = 'NULL';

-- Queries
-- Get the playlists that "StellarFox" follows
.print "Playlists that the user 'StellarFox' follows"
SELECT "playlists"."name", "description", "created_date"
FROM "follows"
JOIN "playlists" ON "follows"."playlist_id" = "playlists"."id"
WHERE "follows"."user_id" = (
    SELECT "id" FROM "users" WHERE "username" = 'StellarFox'
);

-- Get the playlists that a user owns
.print "Playlists that the user 'StellarFox' owns"
SELECT "name", "description", "created_date" 
FROM "playlists"
WHERE "user_id" = (
    SELECT "id" FROM "users" WHERE "username" = 'StellarFox'
);

-- Get a list of the artists that a user likes 
.print "Artists that the user 'LunarEcho' likes"
SELECT "name", "description" 
FROM "artists"
JOIN "likes" ON "artists"."id" = "likes"."artist_id"
JOIN "users" ON "users"."id" = "likes"."user_id"
WHERE "username" = 'LunarEcho';

-- Get all the albums released by 'Linkin Park'
.print "Albums released by the artist 'Linkin Park'"
SELECT "albums"."name", "release_date" 
FROM "albums"
JOIN "releases" ON "releases"."album_id" = "albums"."id"
JOIN "artists" ON "releases"."artist_id" = "artists"."id"
WHERE "artists"."name" = 'Linkin Park'; 

-- Get all the songs in 'The Matrix Reloaded Sountrack' album with its details
.print "Songs included in the 'The Matrix Reloaded Soundtrack' album"
SELECT "includes"."track", "songs"."name", "songs"."length", "songs"."genre", group_concat("artists"."name", ', ') AS "artists"
FROM "songs"
JOIN "includes" ON "includes"."song_id" = "songs"."id"
JOIN "albums" ON "includes"."album_id" = "albums"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "albums"."name" = 'The Matrix Reloaded Soundtrack'
GROUP BY "songs"."id"
ORDER BY "includes"."track";

-- Get all the songs in '12:00' album with its details
.print "Songs included in the '12:00' album"
SELECT "includes"."track", "songs"."name", "songs"."length", "songs"."genre", group_concat("artists"."name", ', ') AS "artists"
FROM "songs"
JOIN "includes" ON "includes"."song_id" = "songs"."id"
JOIN "albums" ON "includes"."album_id" = "albums"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "albums"."name" = '12:00'
GROUP BY "songs"."id"
ORDER BY "includes"."track";

-- Get all the songs in 'K-Pop Vibes' playlist
.print "Songs contained in the 'K-Pop Vibes' playlist"
SELECT "playlist_order" AS "order", "songs"."name", "length"
FROM "playlists"
JOIN "contains" ON "playlists"."id" = "contains"."playlist_id"
JOIN "songs" ON "contains"."song_id" = "songs"."id"
WHERE "playlists"."name" = 'K-Pop Vibes';