-- Get the playlists that "StellarFox" follows
SELECT "name", count("name") AS "followers"
FROM "artists"
JOIN "likes" ON "likes"."artist_id" = "artists"."id"
GROUP BY "name"
ORDER BY "followers" DESC, "name";

-- Get the playlists that a user owns
SELECT "name", "description", "created_date" 
FROM "playlists"
WHERE "user_id" = (
    SELECT "id" FROM "users" WHERE "username" = "StellarFox"
);

-- Get the artists that a user likes
SELECT "name", "description" 
FROM "artists"
JOIN "likes" ON "artists"."id" = "likes"."artist_id"
JOIN "users" ON "users"."id" = "likes"."user_id"
WHERE "username" = 'StellarFox';

-- Get all the albums released by 'Linkin Park'
SELECT "albums"."name", "release_date" 
FROM "albums"
JOIN "releases" ON "releases"."album_id" = "albums"."id"
JOIN "artists" ON "releases"."artist_id" = "artists"."id"
WHERE "artists"."name" = 'Linkin Park'; 

-- Get all the songs in "The Matrix Reloaded Soundtrack" with its details
SELECT "songs"."name", "songs"."length", "songs"."genre", group_concat("artists"."name", ', ') AS "artists"
FROM "songs"
JOIN "includes" ON "includes"."song_id" = "songs"."id"
JOIN "albums" ON "includes"."album_id" = "albums"."id"
JOIN "contributes" ON "contributes"."song_id" = "songs"."id"
JOIN "artists" ON "contributes"."artist_id" = "artists"."id"
WHERE "albums"."name" = 'The Matrix Reloaded Soundtrack'
GROUP BY "songs"."id"
ORDER BY "artists"."name";

-- Get all the songs in '12:00' album