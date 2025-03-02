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