-- Can be reused for all id / def entites, check for length of definition
CREATE TABLE Party_type(
    id CHAR(1)
    definition CHAR(50)
    PRIMARY KEY(id)
);

CREATE TABLE Party(
    id INTEGER
    hazardous_materials NUMBER(1)
    cellphone_use NUMBER(1)         -- ?
    party_type_id CHAR(1)

    PRIMARY KEY(id)
);