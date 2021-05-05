--Questions:
--          Query 8: What do you mean by vehicle_id



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



--QUERY 4
--FIRST QUERY: NUMBER of uninjured people for every seating position
SELECT VSP.DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES from VICTIM_SEATING_POSITION VSP,
(SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES from VICTIMS V
where V.VICTIM_DEGREE_OF_INJURY_ID in
(SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI
where LOWER(VDOI.DEFINITION) like '%no injury%')
and VICTIM_SEATING_POSITION_ID is not NULL
group by V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
where VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID;

--SECOND QUERY: TOTAL NUMBER of all degree of injuries for every seating position
SELECT VSP.DEFINITION, GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES from VICTIM_SEATING_POSITION VSP,
(SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_ALL_DEGREE_INJURIES from VICTIMS V
where V.VICTIM_DEGREE_OF_INJURY_ID in
(SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI)
and VICTIM_SEATING_POSITION_ID is not NULL
group by V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
where VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID;

--TOGETHER
--QUESTION: HOW TO GET FIRST AND LAST 1 ONLY WITHOUT JOINING WIRH ITSELF AND SORTING ASC/DESC WITH FETCH.
-- ALREADY TRIED WITH ROWNUM BUT DIDN'T SEEM TO WORK
SELECT
DEFINITION, ROUND(NUMBER_NO_INJURIES/NUMBER_ALL_DEGREE_INJURIES, 3) AS SAFTEY_FACTOR
FROM
(
    SELECT
        UNINJURED.DEFINITION AS DEFINITION, UNINJURED.NUMBER_NO_INJURIES, ALL_DEGREES.NUMBER_ALL_DEGREE_INJURIES
        FROM
            (SELECT VSP.DEFINITION as DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES as NUMBER_NO_INJURIES from VICTIM_SEATING_POSITION VSP,
            (SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES from VICTIMS V
            where V.VICTIM_DEGREE_OF_INJURY_ID in
            (SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI
            where LOWER(VDOI.DEFINITION) like '%no injury%')
            and VICTIM_SEATING_POSITION_ID is not NULL
            group by V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
            where VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID) UNINJURED,

            (SELECT VSP.DEFINITION as DEFINITION, GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES as NUMBER_ALL_DEGREE_INJURIES from VICTIM_SEATING_POSITION VSP,
            (SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_ALL_DEGREE_INJURIES from VICTIMS V
            where V.VICTIM_DEGREE_OF_INJURY_ID in
            (SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI)
            and VICTIM_SEATING_POSITION_ID is not NULL
            group by V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
            where VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID) ALL_DEGREES

        WHERE UNINJURED.DEFINITION = ALL_DEGREES.DEFINITION
        ORDER BY NUMBER_NO_INJURIES/NUMBER_ALL_DEGREE_INJURIES DESC
)




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

--Query 8
--Find the vehicles that have participated in at least 10 collisions.
-- Show the vehicle id and number of collisions the vehicle has participated in,
-- sorted according to number of collisions (descending order).

--Query 9
--Find the top-10 (with respect to number of collisions) cities. For each of these cities, show the city
--location and number of collisions.

SELECT COUNTY_CITY_LOCATION, Count(*)
From COLLISIONS C
GROUP BY COUNTY_CITY_LOCATION
--Questions:
--          Query 8: What do you mean by vehicle_id



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



--QUERY 4
--FIRST QUERY: NUMBER of uninjured people for every seating position
SELECT VSP.DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES from VICTIM_SEATING_POSITION VSP,
(SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES from VICTIMS V
where V.VICTIM_DEGREE_OF_INJURY_ID in
(SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI
where LOWER(VDOI.DEFINITION) like '%no injury%')
and VICTIM_SEATING_POSITION_ID is not NULL
group by V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
where VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID;

--SECOND QUERY: TOTAL NUMBER of all degree of injuries for every seating position
SELECT VSP.DEFINITION, GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES from VICTIM_SEATING_POSITION VSP,
(SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_ALL_DEGREE_INJURIES from VICTIMS V
where V.VICTIM_DEGREE_OF_INJURY_ID in
(SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI)
and VICTIM_SEATING_POSITION_ID is not NULL
group by V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
where VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID;

--TOGETHER
--QUESTION: HOW TO GET FIRST AND LAST 1 ONLY WITHOUT JOINING WIRH ITSELF AND SORTING ASC/DESC WITH FETCH.
-- ALREADY TRIED WITH ROWNUM BUT DIDN'T SEEM TO WORK
SELECT
DEFINITION, ROUND(NUMBER_NO_INJURIES/NUMBER_ALL_DEGREE_INJURIES, 3) AS SAFTEY_FACTOR
FROM
(
    SELECT
        UNINJURED.DEFINITION AS DEFINITION, UNINJURED.NUMBER_NO_INJURIES, ALL_DEGREES.NUMBER_ALL_DEGREE_INJURIES
        FROM
            (SELECT VSP.DEFINITION as DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES as NUMBER_NO_INJURIES from VICTIM_SEATING_POSITION VSP,
            (SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES from VICTIMS V
            where V.VICTIM_DEGREE_OF_INJURY_ID in
            (SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI
            where LOWER(VDOI.DEFINITION) like '%no injury%')
            and VICTIM_SEATING_POSITION_ID is not NULL
            group by V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
            where VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID) UNINJURED,

            (SELECT VSP.DEFINITION as DEFINITION, GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES as NUMBER_ALL_DEGREE_INJURIES from VICTIM_SEATING_POSITION VSP,
            (SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_ALL_DEGREE_INJURIES from VICTIMS V
            where V.VICTIM_DEGREE_OF_INJURY_ID in
            (SELECT VDOI.ID from VICTIM_DEGREE_OF_INJURY VDOI)
            and VICTIM_SEATING_POSITION_ID is not NULL
            group by V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
            where VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID) ALL_DEGREES

        WHERE UNINJURED.DEFINITION = ALL_DEGREES.DEFINITION
        ORDER BY NUMBER_NO_INJURIES/NUMBER_ALL_DEGREE_INJURIES DESC
)




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

--Query 8
--Find the vehicles that have participated in at least 10 collisions.
-- Show the vehicle id and number of collisions the vehicle has participated in,
-- sorted according to number of collisions (descending order).

--Query 9
--Find the top-10 (with respect to number of collisions) cities. For each of these cities, show the city
--location and number of collisions.

SELECT  COUNTY_CITY_LOCATION, Count(*) as n_col
From COLLISIONS C
GROUP BY COUNTY_CITY_LOCATION
ORDER BY n_col DESC FETCH NEXT 5 ROWS ONLY

-- WHERE rownum <5

