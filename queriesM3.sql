-- QUERY 1: Done (could be improved/shorter)
-- QUERY 2: Done
-- QUERY 3: Done
-- QUERY 4: Done (uses a view, is it allowed?)
-- QUERY 5: Done
-- QUERY 6: Work in progress: Z
-- QUERY 7: Done CJ
-- QUERY 8: Done CJ
-- QUERY 9: Done CJ
-- QUERY 10: Done CJ


--Questions:
--          Query 8: What do you mean by vehicle_id


--QUERY 1
-- question: * is it possible to use aliases for groupby to avoid copy-pasting cases?
--           * Is it possible to do only 1 query which retrieves at the same time for each category, the number at fault
--             and the total number (at fault + not at fault) by for example using a predicate in the count?
SELECT FAULT.age_range, ROUND(NUMBER_AT_FAULT / TOTAL_NUMBER, 3) as RATIO_AT_FAULT
FROM (SELECT case
                 when P.PARTY_AGE <= 18 then 'Underage'
                 when P.PARTY_AGE between 19 and 21 then 'young 1'
                 when P.PARTY_AGE between 22 and 24 then 'young 2'
                 when P.PARTY_AGE between 24 and 60 then 'adult'
                 when P.PARTY_AGE between 61 and 64 then 'elder 1'
                 when P.PARTY_AGE >= 65 then 'elder 2' end as age_range,
             COUNT(*)                                      AS NUMBER_AT_FAULT
      FROM PARTIES P
      WHERE P.AT_FAULT = 'T'
        and P.PARTY_AGE IS NOT NULL
      group by (case
                    when P.PARTY_AGE <= 18 then 'Underage'
                    when P.PARTY_AGE between 19 and 21 then 'young 1'
                    when P.PARTY_AGE between 22 and 24 then 'young 2'
                    when P.PARTY_AGE between 24 and 60 then 'adult'
                    when P.PARTY_AGE between 61 and 64 then 'elder 1'
                    when P.PARTY_AGE >= 65 then 'elder 2'
          END)) FAULT,

     (SELECT case
                 when P.PARTY_AGE <= 18 then 'Underage'
                 when P.PARTY_AGE between 19 and 21 then 'young 1'
                 when P.PARTY_AGE between 22 and 24 then 'young 2'
                 when P.PARTY_AGE between 24 and 60 then 'adult'
                 when P.PARTY_AGE between 61 and 64 then 'elder 1'
                 when P.PARTY_AGE >= 65 then 'elder 2' end as age_range,
             COUNT(*)                                      AS TOTAL_NUMBER
      FROM PARTIES P
      WHERE P.PARTY_AGE IS NOT NULL
      group by (case
                    when P.PARTY_AGE <= 18 then 'Underage'
                    when P.PARTY_AGE between 19 and 21 then 'young 1'
                    when P.PARTY_AGE between 22 and 24 then 'young 2'
                    when P.PARTY_AGE between 24 and 60 then 'adult'
                    when P.PARTY_AGE between 61 and 64 then 'elder 1'
                    when P.PARTY_AGE >= 65 then 'elder 2'
          END)) TOTAL
WHERE TOTAL.age_range = FAULT.age_range
ORDER BY NUMBER_AT_FAULT / TOTAL_NUMBER DESC;


-- Query 2
SELECT SWT.DEFINITION, STATS_COLLISIONS_HOLE.NUMBER_OF_COLLISION
FROM STATEWIDE_VEHICLE_TYPE SWT,
     (
         SELECT P.STATEWIDE_VEHICLE_TYPE_ID AS SVT_ID, COUNT(*) AS NUMBER_OF_COLLISION
         FROM PARTIES P
         WHERE P.STATEWIDE_VEHICLE_TYPE_ID IS NOT NULL
           AND P.COLLISION_CASE_ID IN
               (SELECT C.CASE_ID
                FROM COLLISIONS C
                WHERE C.CASE_ID IN
                      (SELECT CWRC.CASE_ID
                       FROM COLLISION_WITH_ROAD_CONDITION CWRC
                       WHERE CWRC.ROAD_CONDITION_ID IN
                             (SELECT RC.ID
                              FROM ROAD_CONDITION RC
                              WHERE LOWER(RC.DEFINITION) LIKE '%holes%'
                             )
                      )
               )
         GROUP BY P.STATEWIDE_VEHICLE_TYPE_ID
         ORDER BY COUNT(*) DESC
             FETCH FIRST 5 ROW ONLY
     ) STATS_COLLISIONS_HOLE
WHERE SWT.ID = STATS_COLLISIONS_HOLE.SVT_ID

-- UNNESTED QUERY 2
SELECT SWT.DEFINITION, STATS_COLLISIONS_HOLE.NUMBER_OF_COLLISION
FROM STATEWIDE_VEHICLE_TYPE SWT,
     (  SELECT P.STATEWIDE_VEHICLE_TYPE_ID AS SVT_ID, COUNT(*) AS NUMBER_OF_COLLISION
         FROM PARTIES P, COLLISION_WITH_ROAD_CONDITION CWRC, ROAD_CONDITION RC
         WHERE P.STATEWIDE_VEHICLE_TYPE_ID IS NOT NULL
           AND P.COLLISION_CASE_ID = CWRC.CASE_ID
           AND CWRC.ROAD_CONDITION_ID = RC.ID
           AND LOWER(RC.DEFINITION) LIKE '%holes%'
         GROUP BY P.STATEWIDE_VEHICLE_TYPE_ID
         ORDER BY COUNT(*) DESC
             FETCH FIRST 5 ROW ONLY
     ) STATS_COLLISIONS_HOLE
WHERE SWT.ID = STATS_COLLISIONS_HOLE.SVT_ID;

--QUERY 3
SELECT P.VEHICLE_MAKE, COUNT(*) AS NUMBER_OF_VICTIMS_KILLED_OR_WITH_SEVERE_INJURIES
from PARTIES P
WHERE P.ID In
      (SELECT V.PARTY_ID
       from VICTIMS V
       where V.VICTIM_DEGREE_OF_INJURY_ID in
             (SELECT VDOI.ID
              from VICTIM_DEGREE_OF_INJURY VDOI
              where (LOWER(VDOI.DEFINITION) LIKE '%killed%' OR LOWER(VDOI.DEFINITION) LIKE '%severe injury%')))
  and P.VEHICLE_MAKE is not NULL -- NULL is the 4th more represented, not really interesting
group by P.VEHICLE_MAKE
order by COUNT(*) DESC
    FETCH FIRST 10 ROW ONLY;


-- UNNESTED QUERY 3
SELECT P.VEHICLE_MAKE, COUNT(*) AS NUMBER_OF_VICTIMS_KILLED_OR_WITH_SEVERE_INJURIES
from PARTIES P, VICTIMS V, VICTIM_DEGREE_OF_INJURY VDOI
WHERE P.ID = V.PARTY_ID
  AND V.VICTIM_DEGREE_OF_INJURY_ID = VDOI.ID
  AND (LOWER(VDOI.DEFINITION) LIKE '%killed%' OR LOWER(VDOI.DEFINITION) LIKE '%severe injury%')
  and P.VEHICLE_MAKE is not NULL -- NULL is the 4th more represented, not really interesting
group by P.VEHICLE_MAKE
order by COUNT(*) DESC
    FETCH FIRST 10 ROW ONLY;


--QUERY 4
-- Create a view first to be able to fetch easily the first and last values
CREATE VIEW SEATING_POSITION_TO_SAFETY_FACTOR AS
SELECT UNINJURED.DEFINITION,
       ROUND(UNINJURED.NUMBER_NO_INJURIES / ALL_DEGREES.NUMBER_ALL_DEGREE_INJURIES, 3) AS SAFTEY_FACTOR
FROM (
         SELECT VSP.DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES AS NUMBER_NO_INJURIES
         FROM VICTIM_SEATING_POSITION VSP,
              (
                  SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES
                  FROM VICTIMS V
                  WHERE V.VICTIM_DEGREE_OF_INJURY_ID in (
                      SELECT VDOI.ID
                      FROM VICTIM_DEGREE_OF_INJURY VDOI
                      WHERE LOWER(VDOI.DEFINITION) LIKE '%no injury%')
                    AND VICTIM_SEATING_POSITION_ID is not NULL
                  GROUP BY V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
         WHERE VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID) UNINJURED,

     (
         SELECT VSP.DEFINITION,
                GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES as NUMBER_ALL_DEGREE_INJURIES
         FROM VICTIM_SEATING_POSITION VSP,
              (
                  SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID,
                         COUNT(*)                     AS NUMBER_ALL_DEGREE_INJURIES
                  FROM VICTIMS V
                  WHERE V.VICTIM_DEGREE_OF_INJURY_ID in (
                      SELECT VDOI.ID
                      from VICTIM_DEGREE_OF_INJURY VDOI)
                    AND VICTIM_SEATING_POSITION_ID is not NULL
                  GROUP BY V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
         WHERE VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID) ALL_DEGREES

WHERE UNINJURED.DEFINITION = ALL_DEGREES.DEFINITION;

-- Fetch the first and last values from the view only
--UNNESTED QUERY 4
SELECT * FROM SEATING_POSITION_TO_SAFETY_FACTOR
WHERE SAFTEY_FACTOR = (SELECT MAX(SAFTEY_FACTOR) FROM SEATING_POSITION_TO_SAFETY_FACTOR) OR SAFTEY_FACTOR = (SELECT MIN(SAFTEY_FACTOR) FROM SEATING_POSITION_TO_SAFETY_FACTOR);

CREATE VIEW SEATING_POSITION_TO_SAFETY_FACTOR AS
SELECT UNINJURED.DEFINITION,
       ROUND(UNINJURED.NUMBER_NO_INJURIES / ALL_DEGREES.NUMBER_ALL_DEGREE_INJURIES, 3) AS SAFTEY_FACTOR
FROM (
         SELECT VSP.DEFINITION, SEATING_POSITION_NO_INJURIES.NUMBER_NO_INJURIES as NUMBER_NO_INJURIES
         FROM VICTIM_SEATING_POSITION VSP,
              (
                  SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID, COUNT(*) AS NUMBER_NO_INJURIES
                  FROM VICTIMS V, VICTIM_DEGREE_OF_INJURY VDOI
                  WHERE V.VICTIM_DEGREE_OF_INJURY_ID = VDOI.ID
                    AND LOWER(VDOI.DEFINITION) LIKE '%no injury%'
                    AND V.VICTIM_SEATING_POSITION_ID is not NULL
                  GROUP BY V.VICTIM_SEATING_POSITION_ID) SEATING_POSITION_NO_INJURIES
         WHERE VSP.ID = SEATING_POSITION_NO_INJURIES.VICTIM_SEATING_POSITION_ID) UNINJURED,

     (
         SELECT VSP.DEFINITION,
                GROUPED_SEATING_POSITIONS.NUMBER_ALL_DEGREE_INJURIES as NUMBER_ALL_DEGREE_INJURIES
         FROM VICTIM_SEATING_POSITION VSP,
              (
                  SELECT V.VICTIM_SEATING_POSITION_ID AS VICTIM_SEATING_POSITION_ID,
                         COUNT(*)                     AS NUMBER_ALL_DEGREE_INJURIES
                  FROM VICTIMS V, VICTIM_DEGREE_OF_INJURY VDOI
                  WHERE V.VICTIM_DEGREE_OF_INJURY_ID = VDOI.ID
                    AND VICTIM_SEATING_POSITION_ID is not NULL
                  GROUP BY V.VICTIM_SEATING_POSITION_ID) GROUPED_SEATING_POSITIONS
         WHERE VSP.ID = GROUPED_SEATING_POSITIONS.VICTIM_SEATING_POSITION_ID) ALL_DEGREES

WHERE UNINJURED.DEFINITION = ALL_DEGREES.DEFINITION;

-- Fetch the first and last values from the view only

SELECT * FROM SEATING_POSITION_TO_SAFETY_FACTOR
WHERE SAFTEY_FACTOR = (SELECT MAX(SAFTEY_FACTOR) FROM SEATING_POSITION_TO_SAFETY_FACTOR) OR SAFTEY_FACTOR = (SELECT MIN(SAFTEY_FACTOR) FROM SEATING_POSITION_TO_SAFETY_FACTOR);



-- QUERY 5
-- Half of city == 270
SELECT COUNT(*) AS NUMBER_OF_VEHICLE_TYPE
FROM (SELECT COUNT(*)
      FROM (SELECT P.STATEWIDE_VEHICLE_TYPE_ID AS TYPE, C.COUNTY_CITY_LOCATION, COUNT(*)
            FROM PARTIES P,
                 COLLISIONS C
            WHERE P.COLLISION_CASE_ID = C.CASE_ID
              AND C.COUNTY_CITY_LOCATION IS NOT NULL
            GROUP BY (P.STATEWIDE_VEHICLE_TYPE_ID, C.COUNTY_CITY_LOCATION)
            HAVING COUNT(*) > 10
           ) TYPE_CITY_TO_ACCIDENT_COUNT
      GROUP BY TYPE_CITY_TO_ACCIDENT_COUNT.TYPE
      HAVING COUNT(*) > (SELECT COUNT(UNIQUE (C.COUNTY_CITY_LOCATION)) / 2
                         FROM COLLISIONS C
      )
     ) TYPE_TO_CITY_COUNT;

--Query 6
-- For each of the top-3 most populated cities, show the city location, population, and the bottom-10
-- collisions in terms of average victim age (show collision id and average victim age).
-- SELECT distinct (C.COUNTY_CITY_LOCATION), p.DEFINITION
--     from COLLISIONS C
--     INNER JOIN POPULATION P ON P.ID=C.POPULATION_ID
--     where C.POPULATION_ID in
--         (
--         SELECT  distinct (C.POPULATION_ID)
--         FROM COLLISIONS C --where c.POPULATION_ID is not null
--
--         WHERE INSTR(LOWER(P.DEFINITION), 'over') > 0
--         )
--     FETCH FIRST 3 ROWS ONLY;
--
-- SELECT distinct COUNTY_CITY_LOCATION,POPULATION_ID, avg(v.VICTIM_AGE) OVER (PARTITION BY COUNTY_CITY_LOCATION)
-- FROM COLLISIONS C INNER JOIN PARTIES P on C.CASE_ID = P.COLLISION_CASE_ID inner join VICTIMS V on P.ID = V.PARTY_ID
-- WHERE C.COUNTY_CITY_LOCATION in (
--          SELECT distinct COUNTY_CITY_LOCATION
--          from COLLISIONS C
--                   INNER JOIN POPULATION P ON P.ID = C.POPULATION_ID
--          where C.POPULATION_ID in
--                (
--                    SELECT distinct (C.POPULATION_ID)
--                    FROM COLLISIONS C --where c.POPULATION_ID is not null
--
--                    WHERE INSTR(LOWER(P.DEFINITION), 'over') > 0
--                )
--              FETCH FIRST 3 ROWS ONLY
--      );
--
-- SELECT distinct COUNTY_CITY_LOCATION,POPULATION_ID, avg(v.VICTIM_AGE) OVER (PARTITION BY COUNTY_CITY_LOCATION, c.CASE_ID ) as v_age
-- FROM COLLISIONS C INNER JOIN PARTIES P on C.CASE_ID = P.COLLISION_CASE_ID inner join VICTIMS V on P.ID = V.PARTY_ID
-- WHERE C.COUNTY_CITY_LOCATION in (
--          SELECT distinct COUNTY_CITY_LOCATION
--          from COLLISIONS C
--                   INNER JOIN POPULATION P ON P.ID = C.POPULATION_ID
--          where C.POPULATION_ID in
--                (
--                    SELECT distinct (C.POPULATION_ID)
--                    FROM COLLISIONS C --where c.POPULATION_ID is not null
--
--                    WHERE INSTR(LOWER(P.DEFINITION), 'over') > 0
--                )
--              FETCH FIRST 3 ROWS ONLY
--      )
-- ORDER BY v_age;-- FETCH FIRST 10 rows only;
--
drop view VIEW_TEST;

CREATE VIEW view_test(COUNTY_CITY_LOCATION, POPULATION_ID, V_AGE) as
(
SELECT distinct COUNTY_CITY_LOCATION,
                POPULATION_ID,
                avg(v.VICTIM_AGE) OVER (PARTITION BY C.CASE_ID) as v_age
FROM COLLISIONS C
         INNER JOIN PARTIES on C.CASE_ID = PARTIES.COLLISION_CASE_ID
         inner join VICTIMS V on PARTIES.ID = V.PARTY_ID
WHERE C.COUNTY_CITY_LOCATION in (
    SELECT distinct COUNTY_CITY_LOCATION
    from COLLISIONS C
    INNER JOIN POPULATION P ON P.ID = C.POPULATION_ID
    where C.POPULATION_ID in
          (
              SELECT distinct (C.POPULATION_ID)
              FROM COLLISIONS C --where c.POPULATION_ID is not null
              WHERE INSTR(LOWER(P.DEFINITION), 'over') > 0
          )
        FETCH FIRST 3 ROWS ONLY
)
    );

with rws as (
    SELECT ROW_NUMBER() OVER (PARTITION BY COUNTY_CITY_LOCATION
        ORDER BY V_AGE ASC ) AS Row_Number,
           COUNTY_CITY_LOCATION,
           POPULATION_ID,
           V_AGE
    FROM view_test
)
select Row_Number, COUNTY_CITY_LOCATION,P.DEFINITION, ROUND(V_AGE,2) as "average victim age"
from rws
INNER JOIN POPULATION P ON P.ID = POPULATION_ID
where Row_Number <= 10
order by COUNTY_CITY_LOCATION, V_AGE asc;


--QUERY 7
--Find all collisions that satisfy the following: the collision was of type pedestrian and all victims were above 100 years old.
-- For each of the qualifying collisions, show the collision id and the age of the eldest collision victim.
SELECT C.CASE_ID, MAX(V.VICTIM_AGE) AS AGE_MAX
FROM VICTIMS V, PARTIES P, COLLISIONS C, TYPE_OF_COLLISION TOC
WHERE V.PARTY_ID = P.ID
  AND P.COLLISION_CASE_ID = C.CASE_ID
  AND C.TYPE_OF_COLLISION_ID = TOC.ID
  AND TOC.DEFINITION = 'Vehicle/Pedestrian'
GROUP BY CASE_ID
HAVING MIN(V.VICTIM_AGE) > 100;

--Query 8
-- Find the vehicles that have participated in at least 10 collisions.
-- Show the vehicle id and number of collisions the vehicle has participated in,
-- sorted according to number of collisions (descending order).
SELECT SVT.DEFINITION, P.VEHICLE_MAKE, P.VEHICLE_YEAR, COUNT(*) AS NUMBER_COLLISION
FROM PARTIES P, STATEWIDE_VEHICLE_TYPE SVT
WHERE P.STATEWIDE_VEHICLE_TYPE_ID IS NOT NULL
    AND P.VEHICLE_MAKE IS NOT NULL
    AND P.VEHICLE_YEAR IS NOT NULL
    AND P.STATEWIDE_VEHICLE_TYPE_ID = SVT.ID
GROUP BY (SVT.DEFINITION, P.VEHICLE_MAKE, P.VEHICLE_YEAR)
HAVING COUNT(*) >= 10
ORDER BY COUNT(*) DESC;

--Query 9
--Find the top-10 (with respect to number of collisions) cities. For each of these cities, show the city
--location and number of collisions.

SELECT COUNTY_CITY_LOCATION, COUNT(*) AS NUM_COL
FROM COLLISIONS C
GROUP BY COUNTY_CITY_LOCATION
ORDER BY NUM_COL DESC FETCH FIRST 10 ROWS ONLY;


--Query 10
--Are there more accidents around dawn, dusk, during the day, or during the night?
-- In case lighting information is not available, assume the following: the dawn is between 06:00 and 07:59,
-- and dusk between 18:00 and 19:59 in the period September 1 - March 31; and dawn between 04:00 and 06:00,
-- and dusk between 20:00 and 21:59 in the period April 1 - August 31.
-- The remaining corresponding times are night and day.
-- Display the number of accidents, and to which group it belongs, and make your conclusion based on
-- absolute number of accidents in the given 4 periods.

SELECT CASE WHEN ((EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '20' AND '21')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '18' AND '19')) THEN 'DUSK_COLLISION'
        WHEN ((EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '4' AND '5')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '6' AND '7')) THEN 'DAWN_COLLISIONS'
        WHEN (EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '6' AND '19')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '8' AND '17') THEN 'DAY_COLLISIONS'
        ELSE 'NIGHT_COLLISION'
    END, COUNT(*) AS NUMBER_ACCIDENT
FROM COLLISIONS C
WHERE C.COLLISION_DATE IS NOT NULL
      AND C.COLLISION_TIME IS NOT NULL
GROUP BY (
        CASE WHEN ((EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '20' AND '21')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '18' AND '19')) THEN 'DUSK_COLLISION'
        WHEN ((EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '4' AND '5')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '6' AND '7')) THEN 'DAWN_COLLISIONS'
        WHEN (EXTRACT(MONTH FROM C.COLLISION_DATE) BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '6' AND '19')
         OR (EXTRACT(MONTH FROM C.COLLISION_DATE) NOT BETWEEN '4' AND '8'
          AND EXTRACT(HOUR FROM C.COLLISION_TIME) BETWEEN '8' AND '17') THEN 'DAY_COLLISIONS'
        ELSE 'NIGHT_COLLISION'
    END)
ORDER BY NUMBER_ACCIDENT DESC;
