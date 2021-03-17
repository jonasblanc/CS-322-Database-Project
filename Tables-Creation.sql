-- Don't worry about the tables that are commented out

-- CREATE TABLE Party
-- (
--     id                 int NOT NULL,
--     cellphone_use      char(1),
--     hazardous_material char(1),
--     PRIMARY KEY (id)
--
-- );

-- CREATE TABLE Participant
-- (
--     party_id  INT NOT NULL,
--     party_age INT,
--     party_sex char(1),
--     PRIMARY KEY (party_id),
--     FOREIGN KEY (party_id) REFERENCES Party (id) ON DELETE CASCADE
-- );

CREATE TABLE Participant
(
    party_id  INT NOT NULL,
    party_age INT,
    party_sex char(1),
    PRIMARY KEY (party_id)
);

CREATE TABLE Victim
(
    id       INT     NOT NULL,
    pregnant char(1) NOT NULL, --or varchar(q0) depends if we want to store as Y/N or yes no
    party_id INT     NOT NULL REFERENCES PARTICIPANT (party_id),
    PRIMARY KEY (party_id, id)
);

-- NOTE: 2 ways to create a relation

-- E.g 1: Was_Ejected / Victim ejected (c.f Lecture notes 3 slide 28)
--          Step 1: Create entity
--          Step 2: create table for relation and link both tables using foreign keys

-- E.g 1: Victim_seating_position (c.f. https://launchschool.com/books/sql/read/table_relationships one to many paragraph)
-- Create a single table for entity and link using references



CREATE TABLE Victim_Ejected
(
    id         int,
    definition varchar(20),
    PRIMARY KEY (id)
);

CREATE TABLE Was_Ejected
(
    ejected_id int,
    party_id   int not null,-- references Victim (party_id),
    victim_id  int not null, -- references Victim (id),
    PRIMARY KEY (party_id, victim_id),
    FOREIGN KEY (ejected_id) references Victim_Ejected (id),
    FOREIGN KEY (party_id, victim_id) references Victim(party_id, id)
);

CREATE TABLE Victim_Role
(
    id         int,
    definition varchar(50),
    PRIMARY KEY (id)
);

CREATE TABLE Has_Role
(
    role_id int,
    party_id   int not null,
    victim_id  int not null,
    PRIMARY KEY (party_id, victim_id),
    FOREIGN KEY (role_id) references Victim_Role (id),
    FOREIGN KEY (party_id, victim_id) references Victim(party_id, id)
);

CREATE TABLE Victim_Seating_Position
(
    id         char(1),
    definition varchar(50),
    party_id   int not null,
    victim_id  int not null,
    PRIMARY KEY (id),
    FOREIGN KEY (party_id, victim_id) references Victim(party_id, id) ON DELETE CASCADE

);