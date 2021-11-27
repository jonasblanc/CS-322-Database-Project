# Database Project

In this project for the EPFL course CS-322 Introduction to database, we were asked to design, clean the data and populate a SQL database. We received three CSV files containing data about collisions on the road in the USA. The different CSV are explained in details in the [handout](./Handout.pdf). The work was divided in three milestones.

The first milestone was to design the ER schema for the DB and to create the corresponding tables. [Here](./Tables_creation.sql) is the code to create the tables. We explain the choices we made concerning the design of the database in the first section of the [report](./Report.pdf). To work together simultaneously on the same ER diagram, we use [cacoo](https://cacoo.com/). Here is the resulting schema.

<img src="./img/ER Diagram.png"> 

In the second milestone, we had to preprocess the data and to populate the database, then to implement ten SQL queries. We decided to use [jupyter notebooks](./Data_cleaning) to clean the data and create separate CSV files for each table of the DB. Then we implemented the [ten queries](./Queries_milestone_2.sql) requested in the handout. The explanations and results of the queries can be found in the second section of the [report](./Report.pdf).

For the last milestone, [ten more queries](./Queries_milestone_3.sql) were asked and we had to [create indexes](./Index_creation.sql) to speed up six of the ten queries. Again the result can be found in the last section of the [report](./Report.pdf).
