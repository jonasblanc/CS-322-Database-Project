---------------------Design implementations---------------------
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

-- drop table Victims
-- /
-- drop table Victim_degree_of_injury
-- /
-- drop table Victim_seating_position
-- /
-- drop table Victim_role
-- /
-- drop table Victim_ejected
-- /


CREATE TABLE Victim_degree_of_injury
(
    id int not null CHECK (0<= id and id<=7), -- can we make sure id and def are consistent
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Victim_seating_position
(
    id char(1) , --can we check if id is number or char?
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Victim_role
(
    id int not null CHECK (1<= id and id<=6),
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Victim_ejected
(
    id int CHECK (0<= id and id<=3), --make sure entity is still created if id is null
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Victims
(
    id       int     not null,
    pregnant char(1) not null,
    victim_age int,
    victim_sex char(1),
--- referenced ids--
    party_id int not null,
    victim_degree_of_injury_id int not null,
    victim_seating_position_id char(1),
    victim_role_id int not null,
    victim_ejected_id int,
--     party_id int not null REFERENCES PARTICIPANT (party_id),
    PRIMARY KEY  (id),
    FOREIGN KEY (victim_degree_of_injury_id) references Victim_degree_of_injury(id),
    FOREIGN KEY (victim_seating_position_id) references Victim_seating_position(id),
    FOREIGN KEY (victim_role_id) references Victim_role(id),
    FOREIGN KEY (victim_ejected_id) references Victim_ejected(id)

);

-- NOTE: 2 ways to create a relation

-- E.g 1: Was_Ejected / Victim ejected (c.f Lecture notes 3 slide 28)
--          Step 1: Create entity
--          Step 2: create table for relation and link both tables using foreign keys

-- E.g 1: Victim_seating_position (c.f. https://launchschool.com/books/sql/read/table_relationships one to many paragraph)
-- Create a single table for entity and link using references
