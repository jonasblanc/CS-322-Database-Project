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

--Index creation per table:
CREATE INDEX PARTIES_IDX_PARTY_AGE on PARTIES(PARTY_AGE);
CREATE INDEX PARTIES_IDX_AT_FAULT_PARTY_AGE on PARTIES(AT_FAULT, PARTY_AGE);
CREATE INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID on PARTIES(COLLISION_CASE_ID, STATEWIDE_VEHICLE_TYPE_ID);
CREATE INDEX PARTIES_IDX_ID_VEHICLE_MAKE on PARTIES(ID, VEHICLE_MAKE);
CREATE INDEX PARTIES_IDX_COLLISION_CASE_ID_ID on PARTIES(COLLISION_CASE_ID, ID);
CREATE INDEX PARTIES_IDX_STATEWIDE_VEHICLE_TYPE_ID_VEHICLE_MAKE_VEHICLE_YEAR on PARTIES(STATEWIDE_VEHICLE_TYPE_ID, VEHICLE_MAKE, VEHICLE_YEAR);

CREATE INDEX VICTIMS_IDX_PARTY_ID_VICTIM_DEGREE_OF_INJURY_ID on VICTIMS(PARTY_ID, VICTIM_DEGREE_OF_INJURY_ID);
CREATE INDEX VICTIM_DEGREE_OF_INJURY_IDX_DEFINITION_ID on VICTIM_DEGREE_OF_INJURY(DEFINITION, ID);
CREATE INDEX VICTIMS_IDX_PARTY_ID_VICTIM_AGE on VICTIMS(PARTY_ID, VICTIM_AGE);

CREATE INDEX COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION on COLLISIONS(CASE_ID, COUNTY_CITY_LOCATION);
CREATE INDEX COLLISIONS_IDX_CASE_ID_TYPE_OF_COLLISION_ID on COLLISIONS(CASE_ID, TYPE_OF_COLLISION_ID);

CREATE INDEX ROAD_CONDITION_IDX_DEFINITION_ID on ROAD_CONDITION(DEFINITION, ID);

CREATE INDEX TYPE_OF_COLLISION_IDX_DEFINITION_ID on TYPE_OF_COLLISION(DEFINITION, ID);

CREATE INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID on STATEWIDE_VEHICLE_TYPE(DEFINITION, ID);

DROP INDEX PARTIES_IDX_PARTY_AGE;
DROP INDEX PARTIES_IDX_AT_FAULT_PARTY_AGE;
DROP INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID;
DROP INDEX PARTIES_IDX_ID_VEHICLE_MAKE;
DROP INDEX PARTIES_IDX_COLLISION_CASE_ID_ID;
DROP INDEX PARTIES_IDX_STATEWIDE_VEHICLE_TYPE_ID_VEHICLE_MAKE_VEHICLE_YEAR;

DROP INDEX VICTIMS_IDX_PARTY_ID_VICTIM_DEGREE_OF_INJURY_ID;
DROP INDEX VICTIM_DEGREE_OF_INJURY_IDX_DEFINITION_ID;
DROP INDEX VICTIMS_IDX_PARTY_ID_VICTIM_AGE;

DROP INDEX COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION;
DROP INDEX COLLISIONS_IDX_CASE_ID_TYPE_OF_COLLISION_ID;

DROP INDEX ROAD_CONDITION_IDX_DEFINITION_ID;

DROP INDEX TYPE_OF_COLLISION_IDX_DEFINITION_ID;

DROP INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID;

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
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - access(""TOTAL"".""AGE_RANGE""=""FAULT"".""AGE_RANGE"")"
"   5 - filter(""P"".""PARTY_AGE"" IS NOT NULL AND ""P"".""AT_FAULT""='T')"
"   8 - filter(""P"".""PARTY_AGE"" IS NOT NULL)"

CREATE INDEX PARTIES_IDX_PARTY_AGE on PARTIES(PARTY_AGE);
CREATE INDEX PARTIES_IDX_AT_FAULT_PARTY_AGE on PARTIES(AT_FAULT, PARTY_AGE);

-----------------------------------------------------------------------------------------------------------
| Id  | Operation                | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |                                |   112 |  4256 |  7926   (5)| 00:00:01 |
|   1 |  SORT ORDER BY           |                                |   112 |  4256 |  7926   (5)| 00:00:01 |
|*  2 |   HASH JOIN              |                                |   112 |  4256 |  7925   (5)| 00:00:01 |
|   3 |    VIEW                  |                                |   106 |  2014 |  4463   (4)| 00:00:01 |
|   4 |     HASH GROUP BY        |                                |   106 |   530 |  4463   (4)| 00:00:01 |
|*  5 |      INDEX FAST FULL SCAN| PARTIES_IDX_AT_FAULT_PARTY_AGE |  2808K|    13M|  4393   (2)| 00:00:01 |
|   6 |    VIEW                  |                                |   106 |  2014 |  3461   (6)| 00:00:01 |
|   7 |     HASH GROUP BY        |                                |   106 |   318 |  3461   (6)| 00:00:01 |
|*  8 |      INDEX FAST FULL SCAN| PARTIES_IDX_PARTY_AGE          |  6188K|    17M|  3299   (1)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - access(""TOTAL"".""AGE_RANGE""=""FAULT"".""AGE_RANGE"")"
"   5 - filter(""P"".""PARTY_AGE"" IS NOT NULL AND ""P"".""AT_FAULT""='T')"
"   8 - filter(""P"".""PARTY_AGE"" IS NOT NULL)"



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
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   5 - access(""SWT"".""ID""=""from$_subquery$_006"".""SVT_ID"")"
"       filter(""SWT"".""ID""=""from$_subquery$_006"".""SVT_ID"")"
"   6 - filter(""from$_subquery$_006"".""rowlimit_$$_rownumber""<=5)"
   7 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT(*) DESC )<=5)
"   9 - access(""P"".""COLLISION_CASE_ID""=""CWRC"".""CASE_ID"")"
"  10 - access(""CWRC"".""ROAD_CONDITION_ID""=""RC"".""ID"")"
"  11 - filter(""RC"".""DEFINITION""='Holes, Deep Ruts')"
"  13 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL)"



-- Already index on (CWRC.CASE_ID, CWRC.ROAD_CONDITION_ID)
--Index on: STATEWIDE_VEHICLE_TYPE_ID => no amelioration 
CREATE INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID on PARTIES(COLLISION_CASE_ID, STATEWIDE_VEHICLE_TYPE_ID);
CREATE INDEX ROAD_CONDITION_IDX_DEFINITION_ID on ROAD_CONDITION(DEFINITION, ID);
CREATE INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID on STATEWIDE_VEHICLE_TYPE(DEFINITION, ID);

----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                                                    | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                                                         |     4 |   252 |       | 57576   (1)| 00:00:03 |
|   1 |  SORT ORDER BY             |                                                         |     4 |   252 |       | 57576   (1)| 00:00:03 |
|*  2 |   HASH JOIN                |                                                         |     4 |   252 |       | 57575   (1)| 00:00:03 |
|*  3 |    VIEW                    |                                                         |     5 |   205 |       | 57574   (1)| 00:00:03 |
|*  4 |     WINDOW SORT PUSHED RANK|                                                         |    15 |  2325 |       | 57574   (1)| 00:00:03 |
|   5 |      HASH GROUP BY         |                                                         |    15 |  2325 |       | 57574   (1)| 00:00:03 |
|*  6 |       HASH JOIN            |                                                         |   806K|   119M|    43M| 57535   (1)| 00:00:03 |
|*  7 |        HASH JOIN           |                                                         |   456K|    38M|       |  9952   (1)| 00:00:01 |
|*  8 |         INDEX RANGE SCAN   | ROAD_CONDITION_IDX_DEFINITION_ID                        |     1 |    21 |       |     1   (0)| 00:00:01 |
|   9 |         TABLE ACCESS FULL  | COLLISION_WITH_ROAD_CONDITION                           |  3652K|   233M|       |  9942   (1)| 00:00:01 |
|* 10 |        INDEX FAST FULL SCAN| PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID |  6400K|   408M|       | 21492   (1)| 00:00:01 |
|  11 |    INDEX FULL SCAN         | STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID                |    15 |   330 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - access(""SWT"".""ID""=""from$_subquery$_006"".""SVT_ID"")"
"   3 - filter(""from$_subquery$_006"".""rowlimit_$$_rownumber""<=5)"
   4 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT(*) DESC )<=5)
"   6 - access(""P"".""COLLISION_CASE_ID""=""CWRC"".""CASE_ID"")"
"   7 - access(""CWRC"".""ROAD_CONDITION_ID""=""RC"".""ID"")"
"   8 - access(""RC"".""DEFINITION""='Holes, Deep Ruts')"
"  10 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL)"

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
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - filter(""from$_subquery$_004"".""rowlimit_$$_rownumber""<=10)"
   3 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT(*) DESC )<=10)
"   5 - access(""P"".""ID""=""V"".""PARTY_ID"")"
"   6 - access(""V"".""VICTIM_DEGREE_OF_INJURY_ID""=""VDOI"".""ID"")"
"   7 - filter(""VDOI"".""DEFINITION""='Killed' OR ""VDOI"".""DEFINITION""='Severe Injury')"
"   8 - filter(""V"".""VICTIM_DEGREE_OF_INJURY_ID"">=0 AND ""V"".""VICTIM_DEGREE_OF_INJURY_ID""<=7)"
"   9 - filter(""P"".""VEHICLE_MAKE"" IS NOT NULL)"

CREATE INDEX PARTIES_IDX_ID_VEHICLE_MAKE on PARTIES(ID, VEHICLE_MAKE);
CREATE INDEX VICTIMS_IDX_PARTY_ID_VICTIM_DEGREE_OF_INJURY_ID on VICTIMS(PARTY_ID, VICTIM_DEGREE_OF_INJURY_ID);
CREATE INDEX VICTIM_DEGREE_OF_INJURY_IDX_DEFINITION_ID on VICTIM_DEGREE_OF_INJURY(DEFINITION, ID);

--------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                                            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                                                 |    10 |  1160 |       | 20348   (1)| 00:00:01 |
|   1 |  SORT ORDER BY             |                                                 |    10 |  1160 |       | 20348   (1)| 00:00:01 |
|*  2 |   VIEW                     |                                                 |    10 |  1160 |       | 20347   (1)| 00:00:01 |
|*  3 |    WINDOW SORT PUSHED RANK |                                                 |   209 |  8778 |       | 20347   (1)| 00:00:01 |
|   4 |     HASH GROUP BY          |                                                 |   209 |  8778 |       | 20347   (1)| 00:00:01 |
|*  5 |      HASH JOIN             |                                                 |  1360K|    54M|    53M| 20281   (1)| 00:00:01 |
|*  6 |       HASH JOIN            |                                                 |  1360K|    37M|       |  3023   (2)| 00:00:01 |
|   7 |        INLIST ITERATOR     |                                                 |       |       |       |            |          |
|*  8 |         INDEX RANGE SCAN   | VICTIM_DEGREE_OF_INJURY_IDX_DEFINITION_ID       |     2 |    40 |       |     1   (0)| 00:00:01 |
|*  9 |        INDEX FAST FULL SCAN| VICTIMS_IDX_PARTY_ID_VICTIM_DEGREE_OF_INJURY_ID |  4082K|    35M|       |  3012   (1)| 00:00:01 |
|* 10 |       INDEX FAST FULL SCAN | PARTIES_IDX_ID_VEHICLE_MAKE                     |  6759K|    83M|       |  6592   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - filter(""from$_subquery$_004"".""rowlimit_$$_rownumber""<=10)"
   3 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT(*) DESC )<=10)
"   5 - access(""P"".""ID""=""V"".""PARTY_ID"")"
"   6 - access(""V"".""VICTIM_DEGREE_OF_INJURY_ID""=""VDOI"".""ID"")"
"   8 - access(""VDOI"".""DEFINITION""='Killed' OR ""VDOI"".""DEFINITION""='Severe Injury')"
"   9 - filter(""V"".""VICTIM_DEGREE_OF_INJURY_ID"">=0 AND ""V"".""VICTIM_DEGREE_OF_INJURY_ID""<=7)"
"  10 - filter(""P"".""VEHICLE_MAKE"" IS NOT NULL)"


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
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   3 - filter(COUNT(*)>= (SELECT COUNT(""$vm_col_1"")/2 FROM  (SELECT "
"              ""C"".""COUNTY_CITY_LOCATION"" ""$vm_col_1"" FROM ""COLLISIONS"" ""C"" GROUP BY "
"              ""C"".""COUNTY_CITY_LOCATION"") ""VM_NWVW_1""))"
   6 - filter(COUNT(*)>=10)
"   8 - access(""P"".""COLLISION_CASE_ID""=""C"".""CASE_ID"")"
"   9 - filter(""C"".""COUNTY_CITY_LOCATION"" IS NOT NULL)"
"  10 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL)"


CREATE INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID on PARTIES(COLLISION_CASE_ID, STATEWIDE_VEHICLE_TYPE_ID);
CREATE INDEX COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION on COLLISIONS(CASE_ID, COUNTY_CITY_LOCATION);

------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                                                    | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                                                         |     1 |       |       | 70847   (1)| 00:00:03 |
|   1 |  SORT AGGREGATE              |                                                         |     1 |       |       |            |          |
|   2 |   VIEW                       |                                                         |     1 |       |       | 70847   (1)| 00:00:03 |
|*  3 |    FILTER                    |                                                         |       |       |       |            |          |
|   4 |     HASH GROUP BY            |                                                         |     1 |     2 |       | 70847   (1)| 00:00:03 |
|   5 |      VIEW                    |                                                         |   287 |   574 |       | 70847   (1)| 00:00:03 |
|*  6 |       FILTER                 |                                                         |       |       |       |            |          |
|   7 |        HASH GROUP BY         |                                                         |   287 | 39032 |       | 70847   (1)| 00:00:03 |
|*  8 |         HASH JOIN            |                                                         |  6400K|   830M|   284M| 70679   (1)| 00:00:03 |
|*  9 |          INDEX FAST FULL SCAN| COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION             |  3678K|   242M|       | 11160   (1)| 00:00:01 |
|* 10 |          INDEX FAST FULL SCAN| PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID |  6400K|   408M|       | 21492   (1)| 00:00:01 |
|  11 |     SORT AGGREGATE           |                                                         |     1 |    13 |       |            |          |
|  12 |      VIEW                    | VM_NWVW_1                                               |   540 |  7020 |       | 11251   (1)| 00:00:01 |
|  13 |       SORT GROUP BY          |                                                         |   540 |  2160 |       | 11251   (1)| 00:00:01 |
|  14 |        INDEX FAST FULL SCAN  | COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION             |  3678K|    14M|       | 11158   (1)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   3 - filter(COUNT(*)>= (SELECT COUNT(""$vm_col_1"")/2 FROM  (SELECT ""C"".""COUNTY_CITY_LOCATION"" ""$vm_col_1"" FROM ""COLLISIONS"" ""C"" GROUP "
"              BY ""C"".""COUNTY_CITY_LOCATION"") ""VM_NWVW_1""))"
   6 - filter(COUNT(*)>=10)
"   8 - access(""P"".""COLLISION_CASE_ID""=""C"".""CASE_ID"")"
"   9 - filter(""C"".""COUNTY_CITY_LOCATION"" IS NOT NULL)"
"  10 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL)"



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

Predicate Information (identified by operation id):
---------------------------------------------------

"   1 - filter(MIN(""V"".""VICTIM_AGE"")>100)"
"   3 - access(""V"".""PARTY_ID""=""P"".""ID"")"
"   5 - access(""P"".""COLLISION_CASE_ID""=""C"".""CASE_ID"")"
"   6 - access(""C"".""TYPE_OF_COLLISION_ID""=""TOC"".""ID"")"
"   7 - filter(""TOC"".""DEFINITION""='Vehicle/Pedestrian')"

CREATE INDEX VICTIMS_IDX_PARTY_ID_VICTIM_AGE on VICTIMS(PARTY_ID, VICTIM_AGE);
CREATE INDEX PARTIES_IDX_COLLISION_CASE_ID_ID on PARTIES(COLLISION_CASE_ID, ID);
CREATE INDEX COLLISIONS_IDX_CASE_ID_TYPE_OF_COLLISION_ID on COLLISIONS(CASE_ID, TYPE_OF_COLLISION_ID);
CREATE INDEX TYPE_OF_COLLISION_IDX_DEFINITION_ID on TYPE_OF_COLLISION(DEFINITION, ID);

---------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name                                        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |                                             | 25334 |  3958K|       | 85108   (1)| 00:00:04 |
|*  1 |  FILTER                   |                                             |       |       |       |            |          |
|   2 |   HASH GROUP BY           |                                             | 25334 |  3958K|    82M| 85108   (1)| 00:00:04 |
|*  3 |    HASH JOIN              |                                             |   506K|    77M|    81M| 78263   (1)| 00:00:04 |
|   4 |     INDEX FAST FULL SCAN  | VICTIMS_IDX_PARTY_ID_VICTIM_AGE             |  4082K|    35M|       |  3066   (1)| 00:00:01 |
|*  5 |     HASH JOIN             |                                             |   904K|   130M|    40M| 64157   (1)| 00:00:03 |
|*  6 |      HASH JOIN            |                                             |   456K|    34M|       | 10858   (1)| 00:00:01 |
|*  7 |       INDEX RANGE SCAN    | TYPE_OF_COLLISION_IDX_DEFINITION_ID         |     1 |    13 |       |     1   (0)| 00:00:01 |
|   8 |       INDEX FAST FULL SCAN| COLLISIONS_IDX_CASE_ID_TYPE_OF_COLLISION_ID |  3678K|   235M|       | 10848   (1)| 00:00:01 |
|   9 |      INDEX FAST FULL SCAN | PARTIES_IDX_COLLISION_CASE_ID_ID            |  7286K|   493M|       | 22688   (1)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   1 - filter(MIN(""V"".""VICTIM_AGE"")>100)"
"   3 - access(""V"".""PARTY_ID""=""P"".""ID"")"
"   5 - access(""P"".""COLLISION_CASE_ID""=""C"".""CASE_ID"")"
"   6 - access(""C"".""TYPE_OF_COLLISION_ID""=""TOC"".""ID"")"
"   7 - access(""TOC"".""DEFINITION""='Vehicle/Pedestrian')"


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

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(COUNT(*)>=10)
"   4 - access(""P"".""STATEWIDE_VEHICLE_TYPE_ID""=""SVT"".""ID"")"
"   6 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL AND ""P"".""VEHICLE_YEAR"" IS NOT "
"              NULL AND ""P"".""VEHICLE_MAKE"" IS NOT NULL)"

CREATE INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID on STATEWIDE_VEHICLE_TYPE(DEFINITION, ID);
CREATE INDEX PARTIES_IDX_STATEWIDE_VEHICLE_TYPE_ID_VEHICLE_MAKE_VEHICLE_YEAR on PARTIES(STATEWIDE_VEHICLE_TYPE_ID, VEHICLE_MAKE, VEHICLE_YEAR);

--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                | Name                                                            | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |                                                                 | 12466 |   426K|  6730   (5)| 00:00:01 |
|   1 |  SORT ORDER BY           |                                                                 | 12466 |   426K|  6730   (5)| 00:00:01 |
|*  2 |   FILTER                 |                                                                 |       |       |            |          |
|   3 |    HASH GROUP BY         |                                                                 | 12466 |   426K|  6730   (5)| 00:00:01 |
|*  4 |     HASH JOIN            |                                                                 |  5415K|   180M|  6449   (1)| 00:00:01 |
|   5 |      INDEX FULL SCAN     | STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID                        |    15 |   330 |     1   (0)| 00:00:01 |
|*  6 |      INDEX FAST FULL SCAN| PARTIES_IDX_STATEWIDE_VEHICLE_TYPE_ID_VEHICLE_MAKE_VEHICLE_YEAR |  5415K|    67M|  6434   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter(COUNT(*)>=10)
"   4 - access(""P"".""STATEWIDE_VEHICLE_TYPE_ID""=""SVT"".""ID"")"
"   6 - filter(""P"".""STATEWIDE_VEHICLE_TYPE_ID"" IS NOT NULL AND ""P"".""VEHICLE_YEAR"" IS NOT NULL AND ""P"".""VEHICLE_MAKE"" IS NOT NULL)"
 

Q9: => No success


--Q1
DROP INDEX PARTIES_IDX_PARTY_AGE;
DROP INDEX PARTIES_IDX_AT_FAULT_PARTY_AGE;
--Q2
DROP INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID;
DROP INDEX ROAD_CONDITION_IDX_DEFINITION_ID;
DROP INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID;

--Q3
DROP INDEX PARTIES_IDX_ID_VEHICLE_MAKE;
DROP INDEX VICTIMS_IDX_PARTY_ID_VICTIM_DEGREE_OF_INJURY_ID;
DROP INDEX VICTIM_DEGREE_OF_INJURY_IDX_DEFINITION_ID;
--Q5
--DROP INDEX PARTIES_IDX_COLLISION_CASE_ID_STATEWIDE_VEHICLE_TYPE_ID; --Already in Q2
DROP INDEX COLLISIONS_IDX_CASE_ID_COUNTY_CITY_LOCATION;
--Q7
DROP INDEX VICTIMS_IDX_PARTY_ID_VICTIM_AGE;
DROP INDEX PARTIES_IDX_COLLISION_CASE_ID_ID;
DROP INDEX COLLISIONS_IDX_CASE_ID_TYPE_OF_COLLISION_ID;
DROP INDEX TYPE_OF_COLLISION_IDX_DEFINITION_ID;
--Q8
--DROP INDEX STATEWIDE_VEHICLE_TYPE_IDX_DEFINITION_ID;
DROP INDEX PARTIES_IDX_STATEWIDE_VEHICLE_TYPE_ID_VEHICLE_MAKE_VEHICLE_YEAR;