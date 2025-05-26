-- Active: 1747583851616@@127.0.0.1@5432@wildlife_db
CREATE DATABASE wildlife_db;

-- create rangers table
CREATE TABLE rangers(
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(55) NOT NULL,
    region VARCHAR(100) NOT NULL
);

INSERT INTO rangers (name, region)
VALUES ('Alice Green', 'Northern Hills'),
 ('Bob White','River Delta'), 
 ('Carol King ', 'Mountain Range');
SELECT * FROM rangers;
-- crate species table

CREATE TABLE species(
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,                          
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(55)
         CHECK (conservation_status IN ('Endangered', 'Vulnerable'))
    );

    INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status)
    VALUES ('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
    ('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
    ('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
    ('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered')

    SELECT * FROM species;
-- create sightings table
CREATE TABLE sightings(
    sighting_id SERIAL PRIMARY KEY,
    species_id INT REFERENCES species(species_id) ON DELETE CASCADE,
    ranger_id INT REFERENCES rangers(ranger_id) ON DELETE CASCADE,
    location VARCHAR(100) NOT NULL,
    sighting_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
    );



    INSERT INTO sightings (species_id,ranger_id,location,sighting_time, notes)
    VALUES (1, 1, 'Peak Ridge','2024-05-10 07:45:00', 'Camera trap image captured'),
    (2, 2,'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
    (3, 3,'Bamboo Grove East', '2024-05-15 09:10:00',  'Feeding observed'),
    (1, 2, 'Snowfall Pass','2024-05-18 18:30:00',NULL);


                                                                                                                                                                            
SELECT * FROM sightings;
    

-- Problem 1
INSERT INTO rangers (name, region)
VALUES ('Derek Fox', 'Coastal Plains');
-- Problem 2
SELECT count(DISTINCT species_id) FROM sightings as unique_species_count;           
-- Problem 3
SELECT * FROM sightings WHERE location ILIKE '%pass%';
-- Problem 4
SELECT name, count(*) as total_sightings FROM sightings
JOIN rangers ON sightings.ranger_id = rangers.ranger_id
GROUP BY name
HAVING count(*) > 0
ORDER BY name;

-- Problem 5
SELECT s.common_name
FROM species s
LEFT JOIN sightings sg ON s.species_id = sg.species_id
WHERE sg.species_id IS NULL;


-- Problem 6


CREATE VIEW recent_2_sightings AS
SELECT s.common_name, sg.sighting_time, r.name 
FROM sightings sg
JOIN species s ON sg.species_id = s.species_id
JOIN rangers r ON sg.ranger_id = r.ranger_id
ORDER BY sg.sighting_time DESC
LIMIT 2;

SELECT * FROM recent_2_sightings;

-- Problem 7
UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';


ALTER TABLE species
DROP constraint species_conservation_status;

ALTER TABLE species
ADD CONSTRAINT  species_conservation_status
CHECK (conservation_status IN ('Endangered', 'Vulnerable', 'Historic'));



-- Problem 8
CREATE OR REPLACE FUNCTION get_time_of_day(hour INT) RETURNS TEXT AS $$
BEGIN
    IF hour < 12 THEN RETURN 'Morning';
    ELSIF hour <= 16 THEN RETURN 'Afternoon';
    ELSE RETURN 'Evening';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT 
    sighting_id,
    get_time_of_day(EXTRACT(HOUR FROM sighting_time)::int) AS time_of_day
FROM sightings;




-- Problem 9
DELETE FROM rangers
WHERE ranger_id NOT IN (
    SELECT DISTINCT ranger_id 
    FROM sightings
);


