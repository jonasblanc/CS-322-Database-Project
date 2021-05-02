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
FROM VICTIMS V2

--QUERY 10--
-- What about collision with null hour ? Count them as well ?
SELECT EXTRACT(HOUR FROM C.COLLISION_DATE) AS HOUR, COUNT(*)/(  SELECT COUNT(*) FROM COLLISIONS) AS FRACTION_COLLISIONS 
FROM COLLISIONS C
GROUP BY EXTRACT(HOUR FROM C.COLLISION_DATE);
