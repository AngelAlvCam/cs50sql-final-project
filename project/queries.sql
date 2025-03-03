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
SELECT "name", "release_date"
FROM "album_details"
WHERE "artists" LIKE "%linkin park%";

-- Get all the albums released by 'Twice'
.print "Albums released by the artist 'Twice'"
SELECT "name", "release_date"
FROM "album_details"
WHERE "artists" LIKE "%twice%";

-- Get all the songs in 'The Matrix Reloaded Sountrack' album with its details
.print "Songs included in the 'The Matrix Reloaded Soundtrack' album"
SELECT "track", "name", "length", "artists", "genre"
FROM "song_details"
WHERE "album" = 'The Matrix Reloaded Soundtrack';

-- Get all the songs in '12:00' album with its details
.print "Songs included in the '12:00' album"
SELECT "track", "name", "length", "artists", "genre"
FROM "song_details"
WHERE "album" = '12:00';

-- Get the top 10 songs
.print "Top 10 popular songs"
SELECT * FROM "songs_ranking" LIMIT 10;

-- Get the top 3 artists by popularity
.print "Top 5 most followed artists"
SELECT * FROM "artists_ranking" LIMIT 5;

-- Get all the songs in 'K-Pop Vibes' playlist
.print "Songs contained in the 'K-Pop Vibes' playlist"
SELECT "playlist_order" AS "order", "songs"."name", "length", group_concat("artists"."name", ', ') AS "artists"
FROM "playlists"
JOIN "contains" ON "contains"."playlist_id" = "playlists"."id"
JOIN "songs" ON "contains"."song_id" = "songs"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "playlists"."name" = 'K-Pop Vibes'
GROUP BY "songs"."name"
ORDER BY "order";

-- Get all the songs in 'Rap Rock Fusion' playlist
.print "Songs contained in the 'Rap Rock Fusion' playlist"
SELECT "playlist_order" AS "order", "songs"."name", "length", group_concat("artists"."name", ', ') AS "artists"
FROM "playlists"
JOIN "contains" ON "contains"."playlist_id" = "playlists"."id"
JOIN "songs" ON "contains"."song_id" = "songs"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "playlists"."name" = 'Rap Rock Fusion'
GROUP BY "songs"."name"
ORDER BY "order";

-- How many songs and albums 'Linkin Park' has in the database? 
.print "Number of songs and albums that the artist 'Linkin Park' has in the database"
SELECT * FROM "artists_stats" WHERE "artist" = "Linkin Park" ;

-- How many songs in the database are 'K-pop'? 
.print "Number of 'K-Pop' songs in the database"
SELECT * FROM "genre_stats" WHERE "genre" = 'K-pop';