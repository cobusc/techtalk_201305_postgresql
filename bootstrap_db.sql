DROP TABLE IF EXISTS json_example_1;
CREATE TABLE json_example_1 
(
    a SERIAL PRIMARY KEY,
    b INTEGER NOT NULL DEFAULT 0,
    c TEXT,
    d BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO json_example_1 (b,c) VALUES (1, 'hello');
INSERT INTO json_example_1 (b,d) VALUES (2, TRUE);

DROP TABLE IF EXISTS json_example_2;
CREATE TABLE json_example_2
(
    a SERIAL PRIMARY KEY,
    b JSON,
    c INTEGER[]
);

INSERT INTO json_example_2 (b, c) VALUES ('{"a1": 1, "a2": true, "a3": [1,2,3]}', ARRAY[4,5,6]::INTEGER[]);

CREATE TYPE supported_mime_types AS ENUM ('image/jpeg', 'image/png', 'audio/mpeg', 'video/mp4');

DROP TABLE IF EXISTS playstore_item;
CREATE TABLE playstore_item
(
    id BIGSERIAL PRIMARY KEY,
    mime_type supported_mime_types,
    location_url TEXT NOT NULL,
    metadata HSTORE
);

INSERT INTO playstore_item (mime_type, location_url, metadata) VALUES
('image/jpeg', 'file:///some/dir/a.jpg', hstore('"width"=>"100","height"=>"100","description"=>"A lion"')),
('image/jpeg', 'file:///some/dir/b.jpg', hstore('"width"=>"100","height"=>"100","description"=>"A witch"')),
('image/jpeg', 'file:///some/dir/c.jpg', hstore('"width"=>"100","height"=>"100","description"=>"A wardrobe"')),
('audio/mpeg', 'file:///some/dir/d.mp3', hstore('"artist"=>"AvB","album"=>"Some album","track"=>"1","length"=>"340","genre"=>"trance"')),
('audio/mpeg', 'file:///some/dir/e.mp3', hstore('"artist"=>"AvB","album"=>"Some album","track"=>"2","length"=>"350","genre"=>"trance"')),
('audio/mpeg', 'file:///some/dir/f.mp3', hstore('"artist"=>"Symbol","album"=>"Symbol","length"=>"200"'));





