Q1 => Improvement
Q2 => Improvement
Q3 => Improvement
Q4
Q5 => Improvement
Q6
Q7 => Improvement
Q8 => Improvement
Q9 => No success
Q10

Q1: => Improvement

---------------------------------------------------------------------------------
| Id  | Operation             | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |         |   112 |  4256 | 60028   (1)| 00:00:03 |
|   1 |  SORT ORDER BY        |         |   112 |  4256 | 60028   (1)| 00:00:03 |
|*  2 |   HASH JOIN           |         |   112 |  4256 | 60027   (1)| 00:00:03 |
|   3 |    VIEW               |         |   106 |  2014 | 29997   (1)| 00:00:02 |
|   4 |     HASH GROUP BY     |         |   106 |   530 | 29997   (1)| 00:00:02 |
|*  5 |      TABLE ACCESS FULL| PARTIES |  2808K|    13M| 29927   (1)| 00:00:02 |
|   6 |    VIEW               |         |   106 |  2014 | 30030   (1)| 00:00:02 |
|   7 |     HASH GROUP BY     |         |   106 |   318 | 30030   (1)| 00:00:02 |
|*  8 |      TABLE ACCESS FULL| PARTIES |  6188K|    17M| 29868   (1)| 00:00:02 |
---------------------------------------------------------------------------------

CREATE INDEX IDX on PARTIES(PARTY_AGE, AT_FAULT);
CREATE INDEX IDX2 on PARTIES(PARTY_AGE);

---------------------------------------------------------------------------------
| Id  | Operation                | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |      |   112 |  4256 |  7926   (5)| 00:00:01 |
|   1 |  SORT ORDER BY           |      |   112 |  4256 |  7926   (5)| 00:00:01 |
|*  2 |   HASH JOIN              |      |   112 |  4256 |  7925   (5)| 00:00:01 |
|   3 |    VIEW                  |      |   106 |  2014 |  4463   (4)| 00:00:01 |
|   4 |     HASH GROUP BY        |      |   106 |   530 |  4463   (4)| 00:00:01 |
|*  5 |      INDEX FAST FULL SCAN| IDX  |  2808K|    13M|  4393   (2)| 00:00:01 |
|   6 |    VIEW                  |      |   106 |  2014 |  3461   (6)| 00:00:01 |
|   7 |     HASH GROUP BY        |      |   106 |   318 |  3461   (6)| 00:00:01 |
|*  8 |      INDEX FAST FULL SCAN| IDX2 |  6188K|    17M|  3299   (1)| 00:00:01 |
---------------------------------------------------------------------------------


Q2: => Improvement

-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name                          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                               |     4 |   252 |       | 65994   (1)| 00:00:03 |
|   1 |  SORT ORDER BY                |                               |     4 |   252 |       | 65994   (1)| 00:00:03 |
|   2 |   MERGE JOIN                  |                               |     4 |   252 |       | 65993   (1)| 00:00:03 |
|   3 |    TABLE ACCESS BY INDEX ROWID| STATEWIDE_VEHICLE_TYPE        |    15 |   330 |       |     2   (0)| 00:00:01 |
|   4 |     INDEX FULL SCAN           | SYS_C00207107                 |    15 |       |       |     1   (0)| 00:00:01 |
|*  5 |    SORT JOIN                  |                               |     5 |   205 |       | 65991   (1)| 00:00:03 |
|*  6 |     VIEW                      |                               |     5 |   205 |       | 65990   (1)| 00:00:03 |
|*  7 |      WINDOW SORT PUSHED RANK  |                               |    15 |  2325 |       | 65990   (1)| 00:00:03 |
|   8 |       HASH GROUP BY           |                               |    15 |  2325 |       | 65990   (1)| 00:00:03 |
|*  9 |        HASH JOIN              |                               |   806K|   119M|    43M| 65951   (1)| 00:00:03 |
|* 10 |         HASH JOIN             |                               |   456K|    38M|       |  9954   (1)| 00:00:01 |
|* 11 |          TABLE ACCESS FULL    | ROAD_CONDITION                |     1 |    21 |       |     3   (0)| 00:00:01 |
|  12 |          TABLE ACCESS FULL    | COLLISION_WITH_ROAD_CONDITION |  3652K|   233M|       |  9942   (1)| 00:00:01 |
|* 13 |         TABLE ACCESS FULL     | PARTIES                       |  6400K|   408M|       | 29906   (1)| 00:00:02 |
-----------------------------------------------------------------------------------------------------------------------

-- Already index on (CWRC.CASE_ID, CWRC.ROAD_CONDITION_ID)
--Index on: STATEWIDE_VEHICLE_TYPE_ID => no amelioration 
CREATE INDEX IDX on PARTIES(COLLISION_CASE_ID, STATEWIDE_VEHICLE_TYPE_ID);
CREATE INDEX IDX2 on ROAD_CONDITION(ID, DEFINITION);

-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name                          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                               |     4 |   252 |       | 57578   (1)| 00:00:03 |
|   1 |  SORT ORDER BY                |                               |     4 |   252 |       | 57578   (1)| 00:00:03 |
|   2 |   MERGE JOIN                  |                               |     4 |   252 |       | 57577   (1)| 00:00:03 |
|   3 |    TABLE ACCESS BY INDEX ROWID| STATEWIDE_VEHICLE_TYPE        |    15 |   330 |       |     2   (0)| 00:00:01 |
|   4 |     INDEX FULL SCAN           | SYS_C00207107                 |    15 |       |       |     1   (0)| 00:00:01 |
|*  5 |    SORT JOIN                  |                               |     5 |   205 |       | 57575   (1)| 00:00:03 |
|*  6 |     VIEW                      |                               |     5 |   205 |       | 57574   (1)| 00:00:03 |
|*  7 |      WINDOW SORT PUSHED RANK  |                               |    15 |  2325 |       | 57574   (1)| 00:00:03 |
|   8 |       HASH GROUP BY           |                               |    15 |  2325 |       | 57574   (1)| 00:00:03 |
|*  9 |        HASH JOIN              |                               |   806K|   119M|    43M| 57535   (1)| 00:00:03 |
|* 10 |         HASH JOIN             |                               |   456K|    38M|       |  9952   (1)| 00:00:01 |
|* 11 |          INDEX SKIP SCAN      | IDX2                          |     1 |    21 |       |     1   (0)| 00:00:01 |
|  12 |          TABLE ACCESS FULL    | COLLISION_WITH_ROAD_CONDITION |  3652K|   233M|       |  9942   (1)| 00:00:01 |
|* 13 |         INDEX FAST FULL SCAN  | IDX                           |  6400K|   408M|       | 21492   (1)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------------

Q3: => Improvement

-------------------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name                    | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |                         |    10 |  1160 |       | 45925   (1)| 00:00:02 |
|   1 |  SORT ORDER BY            |                         |    10 |  1160 |       | 45925   (1)| 00:00:02 |
|*  2 |   VIEW                    |                         |    10 |  1160 |       | 45924   (1)| 00:00:02 |
|*  3 |    WINDOW SORT PUSHED RANK|                         |   209 |  8778 |       | 45924   (1)| 00:00:02 |
|   4 |     HASH GROUP BY         |                         |   209 |  8778 |       | 45924   (1)| 00:00:02 |
|*  5 |      HASH JOIN            |                         |  1360K|    54M|    53M| 45858   (1)| 00:00:02 |
|*  6 |       HASH JOIN           |                         |  1360K|    37M|       |  5283   (2)| 00:00:01 |
|*  7 |        TABLE ACCESS FULL  | VICTIM_DEGREE_OF_INJURY |     2 |    40 |       |     3   (0)| 00:00:01 |
|*  8 |        TABLE ACCESS FULL  | VICTIMS                 |  4082K|    35M|       |  5269   (1)| 00:00:01 |
|*  9 |       TABLE ACCESS FULL   | PARTIES                 |  6759K|    83M|       | 29909   (1)| 00:00:02 |
-------------------------------------------------------------------------------------------------------------

CREATE INDEX IDX on PARTIES(ID, VEHICLE_MAKE);
CREATE INDEX IDX2 on VICTIMS(VICTIM_DEGREE_OF_INJURY_ID, PARTY_ID);
CREATE INDEX IDX3 on VICTIM_DEGREE_OF_INJURY(ID, DEFINITION);

-------------------------------------------------------------------------------------------
| Id  | Operation                  | Name | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |      |    10 |  1160 |       | 20346   (1)| 00:00:01 |
|   1 |  SORT ORDER BY             |      |    10 |  1160 |       | 20346   (1)| 00:00:01 |
|*  2 |   VIEW                     |      |    10 |  1160 |       | 20345   (1)| 00:00:01 |
|*  3 |    WINDOW SORT PUSHED RANK |      |   209 |  8778 |       | 20345   (1)| 00:00:01 |
|   4 |     HASH GROUP BY          |      |   209 |  8778 |       | 20345   (1)| 00:00:01 |
|*  5 |      HASH JOIN             |      |  1360K|    54M|    53M| 20279   (1)| 00:00:01 |
|*  6 |       HASH JOIN            |      |  1360K|    37M|       |  3021   (2)| 00:00:01 |
|*  7 |        INDEX FULL SCAN     | IDX3 |     2 |    40 |       |     1   (0)| 00:00:01 |
|*  8 |        INDEX FAST FULL SCAN| IDX2 |  4082K|    35M|       |  3010   (1)| 00:00:01 |
|*  9 |       INDEX FAST FULL SCAN | IDX  |  6759K|    83M|       |  6592   (1)| 00:00:01 |
-------------------------------------------------------------------------------------------

Q5: => Improvement

------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |            |     1 |       |       | 87192   (1)| 00:00:04 |
|   1 |  SORT AGGREGATE           |            |     1 |       |       |            |          |
|   2 |   VIEW                    |            |     1 |       |       | 87192   (1)| 00:00:04 |
|*  3 |    FILTER                 |            |       |       |       |            |          |
|   4 |     HASH GROUP BY         |            |     1 |     2 |       | 87192   (1)| 00:00:04 |
|   5 |      VIEW                 |            |   287 |   574 |       | 87192   (1)| 00:00:04 |
|*  6 |       FILTER              |            |       |       |       |            |          |
|   7 |        HASH GROUP BY      |            |   287 | 39032 |       | 87192   (1)| 00:00:04 |
|*  8 |         HASH JOIN         |            |  6400K|   830M|   284M| 87024   (1)| 00:00:04 |
|*  9 |          TABLE ACCESS FULL| COLLISIONS |  3678K|   242M|       | 19090   (1)| 00:00:01 |
|* 10 |          TABLE ACCESS FULL| PARTIES    |  6400K|   408M|       | 29906   (1)| 00:00:02 |
|  11 |     SORT AGGREGATE        |            |     1 |    13 |       |            |          |
|  12 |      VIEW                 | VM_NWVW_1  |   540 |  7020 |       | 19182   (1)| 00:00:01 |
|  13 |       SORT GROUP BY       |            |   540 |  2160 |       | 19182   (1)| 00:00:01 |
|  14 |        TABLE ACCESS FULL  | COLLISIONS |  3678K|    14M|       | 19088   (1)| 00:00:01 |
------------------------------------------------------------------------------------------------

CREATE INDEX IDX on PARTIES(COLLISION_CASE_ID, STATEWIDE_VEHICLE_TYPE_ID);
CREATE INDEX IDX2 on COLLISIONS(CASE_ID, COUNTY_CITY_LOCATION);

--------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |       |       | 70847   (1)| 00:00:03 |
|   1 |  SORT AGGREGATE              |           |     1 |       |       |            |          |
|   2 |   VIEW                       |           |     1 |       |       | 70847   (1)| 00:00:03 |
|*  3 |    FILTER                    |           |       |       |       |            |          |
|   4 |     HASH GROUP BY            |           |     1 |     2 |       | 70847   (1)| 00:00:03 |
|   5 |      VIEW                    |           |   287 |   574 |       | 70847   (1)| 00:00:03 |
|*  6 |       FILTER                 |           |       |       |       |            |          |
|   7 |        HASH GROUP BY         |           |   287 | 39032 |       | 70847   (1)| 00:00:03 |
|*  8 |         HASH JOIN            |           |  6400K|   830M|   284M| 70679   (1)| 00:00:03 |
|*  9 |          INDEX FAST FULL SCAN| IDX2      |  3678K|   242M|       | 11160   (1)| 00:00:01 |
|* 10 |          INDEX FAST FULL SCAN| IDX       |  6400K|   408M|       | 21492   (1)| 00:00:01 |
|  11 |     SORT AGGREGATE           |           |     1 |    13 |       |            |          |
|  12 |      VIEW                    | VM_NWVW_1 |   540 |  7020 |       | 11251   (1)| 00:00:01 |
|  13 |       SORT GROUP BY          |           |   540 |  2160 |       | 11251   (1)| 00:00:01 |
|  14 |        INDEX FAST FULL SCAN  | IDX2      |  3678K|    14M|       | 11158   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------------

Q6:
--=> Wait to have a final version

Q7: => Improvement

----------------------------------------------------------------------------------------------------
| Id  | Operation              | Name              | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |                   | 25334 |  3958K|       |   102K  (1)| 00:00:05 |
|*  1 |  FILTER                |                   |       |       |       |            |          |
|   2 |   HASH GROUP BY        |                   | 25334 |  3958K|    82M|   102K  (1)| 00:00:05 |
|*  3 |    HASH JOIN           |                   |   506K|    77M|    81M| 95864   (1)| 00:00:04 |
|   4 |     TABLE ACCESS FULL  | VICTIMS           |  4082K|    35M|       |  5259   (1)| 00:00:01 |
|*  5 |     HASH JOIN          |                   |   904K|   130M|    40M| 79565   (1)| 00:00:04 |
|*  6 |      HASH JOIN         |                   |   456K|    34M|       | 19082   (1)| 00:00:01 |
|*  7 |       TABLE ACCESS FULL| TYPE_OF_COLLISION |     1 |    13 |       |     3   (0)| 00:00:01 |
|   8 |       TABLE ACCESS FULL| COLLISIONS        |  3678K|   235M|       | 19069   (1)| 00:00:01 |
|   9 |      TABLE ACCESS FULL | PARTIES           |  7286K|   493M|       | 29872   (1)| 00:00:02 |
----------------------------------------------------------------------------------------------------

CREATE INDEX IDX on VICTIMS(PARTY_ID, VICTIM_AGE);
CREATE INDEX IDX2 on PARTIES(COLLISION_CASE_ID, ID);
CREATE INDEX IDX3 on COLLISIONS(CASE_ID, TYPE_OF_COLLISION_ID);
CREATE INDEX IDX4 on TYPE_OF_COLLISION(ID, DEFINITION);

------------------------------------------------------------------------------------------
| Id  | Operation                 | Name | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |      | 25334 |  3958K|       | 85108   (1)| 00:00:04 |
|*  1 |  FILTER                   |      |       |       |       |            |          |
|   2 |   HASH GROUP BY           |      | 25334 |  3958K|    82M| 85108   (1)| 00:00:04 |
|*  3 |    HASH JOIN              |      |   506K|    77M|    81M| 78263   (1)| 00:00:04 |
|   4 |     INDEX FAST FULL SCAN  | IDX  |  4082K|    35M|       |  3066   (1)| 00:00:01 |
|*  5 |     HASH JOIN             |      |   904K|   130M|    40M| 64157   (1)| 00:00:03 |
|*  6 |      HASH JOIN            |      |   456K|    34M|       | 10858   (1)| 00:00:01 |
|*  7 |       INDEX SKIP SCAN     | IDX4 |     1 |    13 |       |     1   (0)| 00:00:01 |
|   8 |       INDEX FAST FULL SCAN| IDX3 |  3678K|   235M|       | 10848   (1)| 00:00:01 |
|   9 |      INDEX FAST FULL SCAN | IDX2 |  7286K|   493M|       | 22688   (1)| 00:00:01 |
------------------------------------------------------------------------------------------

Q8: => Improvement

------------------------------------------------------------------------------------------------
| Id  | Operation             | Name                   | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |                        |  8935 |   305K| 30218   (2)| 00:00:02 |
|   1 |  SORT ORDER BY        |                        |  8935 |   305K| 30218   (2)| 00:00:02 |
|*  2 |   FILTER              |                        |       |       |            |          |
|   3 |    HASH GROUP BY      |                        |  8935 |   305K| 30218   (2)| 00:00:02 |
|*  4 |     HASH JOIN         |                        |  5415K|   180M| 29936   (1)| 00:00:02 |
|   5 |      TABLE ACCESS FULL| STATEWIDE_VEHICLE_TYPE |    15 |   330 |     3   (0)| 00:00:01 |
|*  6 |      TABLE ACCESS FULL| PARTIES                |  5415K|    67M| 29919   (1)| 00:00:02 |
------------------------------------------------------------------------------------------------

CREATE INDEX IDX on STATEWIDE_VEHICLE_TYPE(ID, DEFINITION);
CREATE INDEX IDX2 on PARTIES(STATEWIDE_VEHICLE_TYPE_ID, VEHICLE_MAKE, VEHICLE_YEAR);

---------------------------------------------------------------------------------
| Id  | Operation                | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |      | 12466 |   426K|  6730   (5)| 00:00:01 |
|   1 |  SORT ORDER BY           |      | 12466 |   426K|  6730   (5)| 00:00:01 |
|*  2 |   FILTER                 |      |       |       |            |          |
|   3 |    HASH GROUP BY         |      | 12466 |   426K|  6730   (5)| 00:00:01 |
|*  4 |     HASH JOIN            |      |  5415K|   180M|  6449   (1)| 00:00:01 |
|   5 |      INDEX FULL SCAN     | IDX  |    15 |   330 |     1   (0)| 00:00:01 |
|*  6 |      INDEX FAST FULL SCAN| IDX2 |  5415K|    67M|  6434   (1)| 00:00:01 |
---------------------------------------------------------------------------------

Q9: => No success
