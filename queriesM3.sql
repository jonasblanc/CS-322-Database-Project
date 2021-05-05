--QUERY 3
SELECT P.VEHICLE_MAKE, COUNT(*) AS NUMBER_OF_VICTIMS_KILLER_OR_WITH_SEVERE_INJURIES from PARTIES P
WHERE P.ID In
(SELECT V.ID from VICTIMS V
where V.VICTIM_DEGREE_OF_INJURY_ID in
(SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI
where (LOWER(VDOI.DEFINITION) LIKE '%killed%' OR LOWER(VDOI.DEFINITION) LIKE '%severe injury%')))
and P.VEHICLE_MAKE is not NULL -- NULL is the 4th more represented, not really interesting
group by P.VEHICLE_MAKE
order by  COUNT(*) DESC
FETCH FIRST 10 ROW ONLY;

--Find all collisions that satisfy the following:
-- the collision was of type pedestrian and all victims were above 100 years
-- For each of the qualifying collisions, show the collision id and the age of the eldest collision
-- victim.

--QUERY 7

-- get all victims >100 in pedestrian collisions
-- SELECT V.ID, V.VICTIM_AGE, V.PARTY_ID
-- FROM VICTIMS V
-- where V.VICTIM_AGE > 100 and V.PARTY_ID in (
--     SELECT P.ID
--     FROM PARTIES P
--     WHERE p.COLLISION_CASE_ID in (
--         SELECT C.CASE_ID
--         FROM COLLISIONS C
--         WHERE C.TYPE_OF_COLLISION_ID = 'G'
--         )
--     );

-- get all victims >100 in pedestrian collisions and show correct attributs
-- SELECT C.CASE_ID, v.VICTIM_AGE
-- FROM VICTIMS V
--    INNER JOIN
--    PARTIES P
--    on V.PARTY_ID = P.ID
--    INNER JOIN
--    COLLISIONS C
--    ON P.COLLISION_CASE_ID = C.CASE_ID
-- WHERE C.TYPE_OF_COLLISION_ID = 'G' and V.VICTIM_AGE < 10;

--------
--use template from this link
--https://stackoverflow.com/questions/612231/how-can-i-select-rows-with-maxcolumn-value-partition-by-another-column-in-mys
--SELECT tt.*
-- FROM topten tt
-- INNER JOIN
--     (SELECT home, MAX(datetime) AS MaxDateTime
--     FROM topten
--     GROUP BY home) groupedtt
-- ON tt.home = groupedtt.home
-- AND tt.datetime = groupedtt.MaxDateTime
--------

-- get oldest victims (from those >100) in pedestrian collisions
-- and show correct attributes
SELECT tt.*
FROM (SELECT C.CASE_ID, v.VICTIM_AGE
FROM VICTIMS V
   INNER JOIN
   PARTIES P
   on V.PARTY_ID = P.ID
   INNER JOIN
   COLLISIONS C
   ON P.COLLISION_CASE_ID = C.CASE_ID
WHERE C.TYPE_OF_COLLISION_ID = 'G' and V.VICTIM_AGE > 100) tt
INNER JOIN
    (SELECT CASE_ID, MAX(VICTIM_AGE) AS MaxDateTime
    FROM (SELECT C.CASE_ID, v.VICTIM_AGE
FROM VICTIMS V
   INNER JOIN
   PARTIES P
   on V.PARTY_ID = P.ID
   INNER JOIN
   COLLISIONS C
   ON P.COLLISION_CASE_ID = C.CASE_ID
WHERE C.TYPE_OF_COLLISION_ID = 'G' and V.VICTIM_AGE > 100)
    GROUP BY CASE_ID) groupedtt
ON tt.CASE_ID = groupedtt.CASE_ID
AND tt.VICTIM_AGE = groupedtt.MaxDateTime
ORDER BY tt.CASE_ID;
--Check if by pedestrian collision they mean type of collision G (vehicle/pedestrian)
--change names tt and groupedtt
--change C.TYPE_OF_COLLISION_ID = 'G' to something nicer
