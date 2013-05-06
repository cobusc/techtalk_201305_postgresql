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


CREATE TYPE supported_mime_types ENUM ('image/jpeg', 'image/png', 'audio/mp3', 'video/mpg');


DROP TABLE IF EXISTS playstore_item;
CREATE TABLE playstore_item
(
    id BIGSERIAL PRIMARY KEY,
    data BLOB,
    mime_type supported_mime_types,
    metadata HSTORE
);


