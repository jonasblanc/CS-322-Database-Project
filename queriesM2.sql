-- Architecture
SELECT
A.X, A.Y, A.X/A.Y 

FROM
(
    SELECT 
        (Q1) AS X,
        (Q2) AS Y
        FROM DUAL 
)A;


--QUERY1--
SELECT EXTRACT(YEAR FROM C.COLLISION_DATE) AS YEAR, COUNT(*) AS NUMBER_COLLISIONS 
FROM COLLISIONS C
GROUP BY EXTRACT(YEAR FROM C.COLLISION_DATE);

--QUERY2--
--REMARK: FETCH FIRST ROWS ONLY is the equivalent to LIMIT IN MySQL
SELECT P.VEHICLE_MAKE, COUNT(*) AS NUMBER_VEHICLE 
FROM PARTIES P
GROUP BY P.VEHICLE_MAKE
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY;

--QUERY3--
SELECT COUNT(*)/(SELECT COUNT(*) FROM COLLISIONS) AS FRACTION_DARK 
FROM COLLISIONS C
WHERE C.LIGHTING_ID IN
    (   SELECT L.ID 
        FROM LIGHTING L
        WHERE LOWER(L.DEFINITION) LIKE '%dark%');

SELECT
A.NUMBER_COLLISIONS_UNDER_DARK, A.TOTAL_NUMBER_COLLISIONS, A.NUMBER_COLLISIONS_UNDER_DARK/A.TOTAL_NUMBER_COLLISIONS AS FRACTION_UNDER_DARK
FROM(   
    SELECT
        (SELECT COUNT(*)
            FROM COLLISIONS C
            WHERE C.LIGHTING_ID IN
                (   SELECT L.ID 
                    FROM LIGHTING L
                    WHERE LOWER(L.DEFINITION) LIKE '%dark%')) AS NUMBER_COLLISIONS_UNDER_DARK,
            (SELECT COUNT(*) FROM COLLISIONS) AS TOTAL_NUMBER_COLLISIONS
    FROM DUAL 
)A;

-- V2
SELECT  
    (
        (SELECT COUNT(*)
        FROM COLLISIONS C
        WHERE C.LIGHTING_ID IN
            (   SELECT L.ID 
                FROM LIGHTING L
                WHERE LOWER(L.DEFINITION) LIKE '%dark%'))
       /(SELECT COUNT(*) FROM COLLISIONS)
   )
AS FRACTION_DARK 
FROM DUAL

--QUERY4--
SELECT COUNT(*) AS NUMBER_COLLISIONS_SNOWY_WEATHER 
FROM COLLISION_WITH_WEATHER CWW
WHERE CWW.WHEATHER_ID IN
    (   SELECT W.ID 
        FROM WEATHER W
        WHERE LOWER(W.DEFINITION) LIKE '%snow%');

--QUERY5--
-- QUESTION: Many post on stackoverflow say to use DATENAME func or DATE_FORMAT but
-- it doesn't seem available here. What to do?
-- Other solution that doesn't seems to exist: DatePart(C.COLLISION_DATE, DP_WEEKDAY)
SELECT TO_CHAR(C.COLLISION_DATE, 'DAY') AS WEEKDAY, COUNT(*) AS NUMBER_COLLISIONS 
FROM COLLISIONS C
GROUP BY TO_CHAR(C.COLLISION_DATE, 'DAY'); --This should extract the day

--QUERY6--
-- HOW TO PUT ALL VALUES NOT IN CWW TO 0?
SELECT W.DEFINITION, COUNT(*) AS NUMBER_COLLISIONS 
FROM WEATHER W, COLLISION_WITH_WEATHER CWW
WHERE W.ID=CWW.WHEATHER_ID
GROUP BY W.DEFINITION --OR GROUPBY CWW.WHEATHER_ID MAYBE, SHOULD BE THE SAME
ORDER BY COUNT(*) DESC;

--QUERY7--
SELECT COUNT(*) AS NUMBER_AT_FAULT_WITH_FIN_REP_LOOSE_MAT 
FROM PARTIES P
WHERE P.AT_FAULT='T'
AND P.FINANCIAL_RESPONSIBILITY_ID IN
    (   SELECT FR.ID 
        FROM FINANCIAL_RESPONSIBILITY FR
        WHERE LOWER(FR.DEFINITION) LIKE '%yes%')
AND P.COLLISION_CASE_ID IN
    (   SELECT COL.CASE_ID 
        FROM COLLISIONS COL
        WHERE COL.CASE_ID IN
            (   SELECT CWRC.CASE_ID 
                FROM COLLISION_WITH_ROAD_CONDITION CWRC
                WHERE CWRC.ROAD_CONDITION_ID IN
                    (   SELECT RC.ID 
                        FROM ROAD_CONDITION RC
                        WHERE LOWER(RC.DEFINITION) LIKE '%loose material%')));

--QUERY8--
--INDIVIDUAL, would it make sense to group them? How?
SELECT MEDIAN(V.VICTIM_AGE) AS MEDIAN FROM VICTIMS V;

SELECT VSP.DEFINITION 
FROM VICTIM_SEATING_POSITION VSP
WHERE VSP.ID IN
    (   SELECT V.VICTIM_SEATING_POSITION_ID 
        FROM VICTIMS V
        GROUP BY V.VICTIM_SEATING_POSITION_ID
        ORDER BY COUNT(*) DESC
        FETCH FIRST 1 ROW ONLY);

-- JOINED
SELECT
A.VICTIM_AGE_MEDIAN, A.MOST_COMMON_VICTIM_SEATING_POSITION 

FROM
(
    SELECT 
        (   SELECT MEDIAN(V.VICTIM_AGE) 
            FROM VICTIMS V) AS VICTIM_AGE_MEDIAN,
        (   SELECT VSP.DEFINITION 
            FROM VICTIM_SEATING_POSITION VSP
            WHERE VSP.ID IN
            (   SELECT V.VICTIM_SEATING_POSITION_ID 
                FROM VICTIMS V
                GROUP BY V.VICTIM_SEATING_POSITION_ID
                ORDER BY COUNT(*) DESC
                FETCH FIRST 1 ROW ONLY)) AS MOST_COMMON_VICTIM_SEATING_POSITION
    FROM DUAL 
)A;


--QUERY9--

-- Not working
SELECT COUNT(*)/(SELECT COUNT(*) FROM VICTIMS V1) AS FRACTION_WITH_BELT 
FROM VICTIMS V2
WHERE V2.ID IN
    (   SELECT VEWSE.VICTIM_ID 
        FROM VICTIM_EQUIPPED_WITH_SAFETY_EQUIPMENT VEWSE
        WHERE VEWSE.SAFETY_EQUIPMENT_ID IN
            (   SELECT SE.ID 
                FROM SAFETY_EQUIPMENT SE
                WHERE LOWER(SE.DEFINITION) LIKE '%belt use%'));

-- Working but inefficient
SELECT
    AVG(CASE WHEN V2.ID IN
        (   SELECT VEWSE.VICTIM_ID 
            FROM VICTIM_EQUIPPED_WITH_SAFETY_EQUIPMENT VEWSE
            WHERE VEWSE.SAFETY_EQUIPMENT_ID IN
                (   SELECT SE.ID 
                    FROM SAFETY_EQUIPMENT SE
                    WHERE LOWER(SE.DEFINITION) LIKE '%belt use%')) THEN 1.0 ELSE 0 END)
AS FRACTION_WITH_BELT
FROM VICTIMS V2;

-- V3 best one
SELECT  
    (
        (SELECT COUNT(*)
        FROM VICTIMS V
        WHERE V.ID IN
            (   SELECT VEWSE.VICTIM_ID 
                FROM VICTIM_EQUIPPED_WITH_SAFETY_EQUIPMENT VEWSE
                WHERE VEWSE.SAFETY_EQUIPMENT_ID IN
                    (   SELECT SE.ID 
                        FROM SAFETY_EQUIPMENT SE
                        WHERE LOWER(SE.DEFINITION) LIKE '%belt use%')))
        / (SELECT COUNT(*) FROM VICTIMS) 
    )
AS FRACTION_WITH_BELT
FROM DUAL;

-- V4 with all participants being victim + party
SELECT  
    (
        (SELECT COUNT(*)
        FROM VICTIMS V
        WHERE V.ID IN
            (   SELECT VEWSE.VICTIM_ID 
                FROM VICTIM_EQUIPPED_WITH_SAFETY_EQUIPMENT VEWSE
                WHERE VEWSE.SAFETY_EQUIPMENT_ID IN
                    (   SELECT SE.ID 
                        FROM SAFETY_EQUIPMENT SE
                        WHERE LOWER(SE.DEFINITION) LIKE '%belt use%')))
        / ((SELECT COUNT(*) FROM VICTIMS) 
        + (SELECT COUNT(*) FROM PARTIES) 
        )
    )
AS FRACTION_WITH_BELT
FROM DUAL;

-- V5
SELECT
A.NUMBER_VICTIM_WITH_BELT / (A.TOTAL_VICTIM + A.TOTAL_PARTIES) AS FRACTION_WITH_BELT

FROM
(
    SELECT 
        (SELECT COUNT(*)
        FROM VICTIMS V
        WHERE V.ID IN
            (   SELECT VEWSE.VICTIM_ID 
                FROM VICTIM_EQUIPPED_WITH_SAFETY_EQUIPMENT VEWSE
                WHERE VEWSE.SAFETY_EQUIPMENT_ID IN
                    (   SELECT SE.ID 
                        FROM SAFETY_EQUIPMENT SE
                        WHERE LOWER(SE.DEFINITION) LIKE '%belt use%'))) AS NUMBER_VICTIM_WITH_BELT,
        (SELECT COUNT(*) FROM VICTIMS) AS TOTAL_VICTIM,
        (SELECT COUNT(*) FROM PARTIES) AS TOTAL_PARTIES
        FROM DUAL 
)A;

--QUERY 10--
-- What about collision with null hour ? Count them as well ?
SELECT EXTRACT(HOUR FROM C.COLLISION_TIME) AS HOUR, COUNT(*)/(  SELECT COUNT(*) FROM COLLISIONS) AS FRACTION_COLLISIONS 
FROM COLLISIONS C
GROUP BY EXTRACT(HOUR FROM C.COLLISION_TIME);

-- TABLE CREATION TRIAL

CREATE TABLE Collisions_J --need to keep escape " and remove ' (problems w/ officer_id)
--collision_date <-> process_date makes it slow
(
    case_id                     char(64),
    collision_date              timestamp(6),
    collision_time              timestamp(6),--null
    --tow_away                    char(1) CHECK (tow_away = 'T' or tow_away = 'F'),
    --type_of_collision_id        char(1) references Type_of_collision (id),
    --collision_severity_id       int not null references Collision_severity (id),
    -- Relations is_judged
    --jurisdiction                int CHECK (0 <= jurisdiction and jurisdiction <= 9999),
    --officer_id                  varchar(10),
    --pcf_violation               int,
    --pcf_violation_subsection    varchar(150),
    process_date                date,
    --hit_and_run_id              char(1) references Hit_and_run (id),
    --primary_collision_factor_id char(1) references Primary_collision_factor (id),
    --pcf_violation_category_id   int references Pcf_violation_category (id),
    -- Relations happens_in
    --county_city_location        int,
    --ramp_intersection_id        int references Ramp_intersection (id),
    --location_type_id            char(1) references Location_type (id),
    --population_id               int references Population (id),
    -- Relations happens_under
   -- lighting_id                 char(1) references Lighting (id),
    --road_surface_id             char(1) references Road_surface (id),
    PRIMARY KEY (case_id)
);

--drop table Collisions_J cascade constraints;