-- Related entities with party: one to many
CREATE TABLE Movement_preceding_collision
(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Party_drug_physical
(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Party_sobriety
(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Party_type(
    id int not null,
    definition varchar(150),
    PRIMARY KEY(id)
);

CREATE TABLE Statewide_vehicle_type(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY(id)
);

CREATE TABLE Cellphone_use(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY(id)
);


-- Relations with party: Many to many
CREATE TABLE Safety_equipment
(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Other_associated_factor
(
    id char(1) not null,
    definition varchar(150),
    PRIMARY KEY (id)
);

CREATE TABLE Party_equiped_with_safety_equipment(
    party_id int not null,
    safety_equipment_id char(1) not null,
    PRIMARY KEY(party_id, safety_equipment_id),
    FOREIGN KEY (party_id) references Parties(id),
    FOREIGN KEY (safety_equipment_id) references Safety_equipment(id)
);

CREATE TABLE Party_associated_with_safety_other_associated_factor(
    party_id int not null,
    other_associated_factor_id char(1) not null,
    PRIMARY KEY(party_id, safety_equipment_id),
    FOREIGN KEY (party_id) references Parties(id),
    FOREIGN KEY (other_associated_factor_id) references Other_associated_factor(id)
);

-- Parties
CREATE TABLE Parties(
    id int not null,
    -- Atributes
    hazardous_materials char(1),
    party_age int,
    party_sex char(1),
    -- referenced ids
    movement_preceding_collision_id char(1),
    party_drug_physical_id char(1),
    party_sobriety_id char(1),
    party_type_id int,
    statewide_vehicle_type_id char(1),
    vehicle_make varchar(150),
    vehicle_year int,
    cellphone_use_id char(1),
    -- keys
    PRIMARY KEY(id)
    FOREIGN KEY (movement_preceding_collision_id) references Movement_preceding_collision_id(id),
    FOREIGN KEY (party_drug_physical_id) references Party_drug_physical(id),
    FOREIGN KEY (party_sobriety_id) references Party_sobriety(id),
    FOREIGN KEY (party_type_id) references Party_type(id),
    FOREIGN KEY (statewide_vehicle_type_id) references Statewide_vehicle_type(id),
    FOREIGN KEY (cellphone_use_id) references Cellphone_use(id)
);