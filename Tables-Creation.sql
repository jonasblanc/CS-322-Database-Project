----------------------------Design implementations---------------------
-- Boolean => char(1)
-- definition => varchar(150)
-- Table_name (First letter upper case then underscores)
-- One-to-Many (Store key in one)
-- No state is null, set key to null
-- In an entity: id is id of current entity, create new attribute table_id for referenced id


--Questions

--victim age/ pregnancy: age of 999 implies that person is not yet born, so that we don't lose information about the age of the mother
-- there would be 2 distinct victims (mother normal age, and yet to be born child age 99)

--in Victims: attribute victim_seating_position_id || seating_position_id
-- merge state: Unknown with blank ? => key == null ?

-- Used in both victimd and parties

--Check for line between collisions and is_implied in

--Check if attributes of is_implied_in are done correctly

--Pcf_violation_subsection: which type?

--County_city_location: which type?

------------------------------------------------------------------------
------------------------------------------------------------------------
-------------------------------Collisions start-------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
CREATE TABLE Weather
(
    id         char(1), -- check if if is one of letter
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Road_surface
(
    id         char(1), -- check if if is one of letter
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Road_condition
(
    id         char(1), -- check if if is one of letter
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Lighting
(
    id         char(1), -- check if if is one of letter
    definition varchar(150) not null,
    PRIMARY KEY (id)
);


CREATE TABLE Collision_with_weather
(
    case_id     char(64) references Collisions (case_id),
    wheather_id char(1) references Weather (id),
    PRIMARY KEY (case_id, wheather_id)
);

CREATE TABLE Collision_with_road_condition
(
    case_id           char(64) references Collisions (case_id),
    road_condition_id char(1) references Road_condition (id),
    PRIMARY KEY (case_id, road_condition_id)
);


CREATE TABLE Type_of_collision
(
    id         char(1), --check char between a & h
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Collision_severity
(
    id         int CHECK (0 <= id and id <= 4),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Hit_and_run
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Primary_collision_factor
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Pcf_violation_category
(
    id         int CHECK ((0 <= id and id <= 24)),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Ramp_intersection
(
    id         int CHECK (1 <= id and id <= 8),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Location_type
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Population
(
    id         int CHECK (0 <= id and id <= 9),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Collisions
(
    case_id                     char(64),
    collision_datetime          timestamp(6),
    tow_away                    char(1) CHECK (tow_away = 'T' or tow_away = 'F'),
    type_of_collision_id        char(1) references Type_of_collision (id),
    collision_severity_id       int not null references Collision_severity (id),
    -- Relations is_judged
    jurisdiction                int CHECK (0 <= jurisdiction and jurisdiction <= 9999),
    officer_id                  varchar(10),
    pcf_violation               int,
    pcf_violation_subsection    varchar(150),
    process_date                date,
    hit_and_run_id              char(1) references Hit_and_run (id),
    primary_collision_factor_id char(1) references Primary_collision_factor (id),
    pcf_violation_category_id   int references Pcf_violation_category (id),
    -- Relations happens_in
    county_city_location        int,
    ramp_intersection_id        int references Ramp_intersection (id),
    location_type_id            char(1) references Location_type (id),
    population_id               int references Population (id),
    -- Relations happens_under
    lighting_id                 char(1) references Lighting (id),
    road_surface_id             char(1) references Road_surface (id),
    PRIMARY KEY (case_id)
);
------------------------------------------------------------------------
------------------------------------------------------------------------
-------------------------------Collisions end---------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

CREATE TABLE Safety_equipment
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

------------------------------------------------------------------------
------------------------------------------------------------------------
----------------------------------Victims start-------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
CREATE TABLE Victim_degree_of_injury
(
    id         int CHECK (0 <= id and id <= 7), -- can we make sure id and def are consistent
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Victim_seating_position
(
    id         int, --can we check if id is number or char?
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Victim_role
(
    id         int CHECK (1 <= id and id <= 6),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Victim_ejected
(
    id         int CHECK (0 <= id and id <= 3), --make sure entity is still created if id is null
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Victims
(
    id                         int,
    victim_age                 int,
    victim_sex                 char(1),
    unborn                     char(1),
--- referenced ids--
    victim_degree_of_injury_id int not null references Victim_degree_of_injury (id),
    victim_seating_position_id int references Victim_seating_position (id),
    victim_role_id             int not null references Victim_role (id),
    victim_ejected_id          int references Victim_ejected (id),
    party_id                   int not null REFERENCES Parties (id),
    PRIMARY KEY (id)
);

CREATE TABLE Victim_equiped_with_safety_equipment
(
    victim_id           int references Victims (id),
    safety_equipment_id char(1) not null references Safety_equipment (id),
    PRIMARY KEY (victim_id, safety_equipment_id)
);
------------------------------------------------------------------------
------------------------------------------------------------------------
----------------------------------Victims end---------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


------------------------------------------------------------------------
------------------------------------------------------------------------
----------------------------------Parties start-------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

-- Related entities with party: one to many
CREATE TABLE Movement_preceding_collision
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Party_drug_physical
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Party_sobriety
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Party_type
(
    id         int,
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Statewide_vehicle_type
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Cellphone_use
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);


-- Relations with party: Many to many
CREATE TABLE Other_associated_factor
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

CREATE TABLE Financial_responsibility
(
    id         char(1),
    definition varchar(150) not null,
    PRIMARY KEY (id)
);

-- Parties
CREATE TABLE Parties
(
    id                              int,
    -- Atributes
    hazardous_materials             char(1),
    party_age                       int,
    party_sex                       char(1),
    -- relation to collision
    collision_case_id               char(64) not null references Collisions (case_id),
    financial_responsibility_id     char(1) references Financial_responsibility (id),
    school_bus_related              char(1),
    at_fault                        char(1)  not null,
    -- referenced ids
    movement_preceding_collision_id char(1) references Movement_preceding_collision (id),
    party_drug_physical_id          char(1) references Party_drug_physical (id),
    party_sobriety_id               char(1) references Party_sobriety (id),
    party_type_id                   int references Party_type (id),
    statewide_vehicle_type_id       char(1) references Statewide_vehicle_type (id),
    vehicle_make                    varchar(150),
    vehicle_year                    int,
    cellphone_use_id                char(1) references Cellphone_use (id),
    -- key
    PRIMARY KEY (id)
);

CREATE TABLE Party_equiped_with_safety_equipment
(
    party_id            int     not null references Parties (id),
    safety_equipment_id char(1) not null references Safety_equipment (id),
    PRIMARY KEY (party_id, safety_equipment_id)
);

CREATE TABLE Party_associated_with_safety_other_associated_factor
(
    party_id                   int     not null references Parties (id),
    other_associated_factor_id char(1) not null references Other_associated_factor (id),
    PRIMARY KEY (party_id, other_associated_factor_id)
);
------------------------------------------------------------------------
------------------------------------------------------------------------
----------------------------------Parties end-------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


-- NOTE: 2 ways to create a relation

-- E.g 1: Was_Ejected / Victim ejected (c.f Lecture notes 3 slide 28)
--          Step 1: Create entity
--          Step 2: create table for relation and link both tables using foreign keys

-- E.g 1: Victim_seating_position (c.f. https://launchschool.com/books/sql/read/table_relationships one to many paragraph)
-- Create a single table for entity and link using references
