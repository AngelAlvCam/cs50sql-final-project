-- Get the playlists that "StellarFox" follows
SELECT "playlists"."name", "description", "created_date"
FROM "follows"
JOIN "playlists" ON "follows"."playlist_id" = "playlists"."id"
WHERE "follows"."user_id" = (
    SELECT "id" FROM "users" WHERE "username" = 'StellarFox'
);

-- Get the playlists that a user owns
SELECT "name", "description", "created_date" 
FROM "playlists"
WHERE "user_id" = (
    SELECT "id" FROM "users" WHERE "username" = 'StellarFox'
);

-- Get a list of the artists that a user likes 
SELECT "name", "description" 
FROM "artists"
JOIN "likes" ON "artists"."id" = "likes"."artist_id"
JOIN "users" ON "users"."id" = "likes"."user_id"
WHERE "username" = 'LunarEcho';

-- Get all the albums released by 'Linkin Park'
SELECT "albums"."name", "release_date" 
FROM "albums"
JOIN "releases" ON "releases"."album_id" = "albums"."id"
JOIN "artists" ON "releases"."artist_id" = "artists"."id"
WHERE "artists"."name" = 'Linkin Park'; 

-- Get all the songs in '12:00' album with its details
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
SELECT "songs"."name", "length"
FROM "playlists"
JOIN "contains" ON "playlists"."id" = "contains"."playlist_id"
JOIN "songs" ON "contains"."song_id" = "songs"."id"
WHERE "playlists"."name" = 'K-Pop Vibes';