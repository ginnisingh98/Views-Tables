--------------------------------------------------------
--  DDL for Package HR_DM_GEN_TUPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_GEN_TUPS" AUTHID CURRENT_USER as
/* $Header: perdmgnu.pkh 115.9 2002/10/01 18:23:13 mmudigon ship $ */
-- ------------------------- create_tups_pacakge ------------------------
-- Description:  Create the TUPS package and relevant procedures for the table.
-- Input Parameters :
--   p_table_info  - Information about table for which TUPS to be generated. Info
--                  like Datetrack, Global Data, Surrogate Primary key etc about
--                  the table is passed as a record type.
--   p_columns_tbl - All the columns of the table stored as a list.
--   p_parameters_tbl - All the columns of the table stored with data type are
--                   stored as a list. e.g p_business_group_id   number
--                   This is used to create the procedure parameter list for
--                   TUPS procedure.
--   p_aol_columns_tbl  -  All the columns of the table which have foreign key to
--                    AOL table are stored as a list.
--   p_aol_parameters_tbl - All the columns of the table which have foreign key to
--                    AOL table are stored with data type as a list. This is
--                    used as a parameter list for the procedure generated to
--                    get the ID value for the given AOL developer key.
--                    e.g p_user_id  number
--   p_fk_to_aol_columns_tbl  - It stores the list of all the columns which have
--                   foreign on AOL table and corresponding name of the AOL
--                   table.
-- ------------------------------------------------------------------------
procedure create_tups_pacakge
(
 p_table_info             in   hr_dm_gen_main.t_table_info ,
 p_columns_tbl            in   hr_dm_library.t_varchar2_tbl,
 p_parameters_tbl         in   hr_dm_library.t_varchar2_tbl,
 p_aol_columns_tbl        in   hr_dm_library.t_varchar2_tbl,
 p_aol_parameters_tbl     in   hr_dm_library.t_varchar2_tbl,
 p_fk_to_aol_columns_tbl  in   hr_dm_gen_main.t_fk_to_aol_columns_tbl
);
end hr_dm_gen_tups;

 

/
