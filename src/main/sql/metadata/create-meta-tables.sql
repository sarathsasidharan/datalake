/*
Enter your meta data model , Create table scripts here
*/
 create table meta_model_tab_1
 (
    id int identity(1,1) not null,
    rel_tab_2_id int not null
    primary key(id)
 )