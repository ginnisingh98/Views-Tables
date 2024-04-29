--------------------------------------------------------
--  DDL for Package HR_DM_GEN_TDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_GEN_TDS" AUTHID CURRENT_USER as
/* $Header: perdmgnd.pkh 120.0 2005/05/31 17:08:44 appldev noship $ */
-- ------------------------- create_tds_pacakge ------------------------
-- Description:  Create the TDS package and relevant procedures for the table.
-- Input Parameters :
--   p_table_info  - Information about table for which TDS to be generated. Info
--                  like Datetrack, Global Data, Surrogate Primary key etc about
--                  the table is passed as a record type.
--   p_columns_tbl - All the columns of the table stored as a list.
--   p_parameters_tbl - All the columns of the table stored with data type are
--                   stored as a list. e.g p_business_group_id   number
--                   This is used to create the procedure parameter list for
--                   TDS procedure.
--   p_aol_columns_tbl  -  All the columns of the table which have foreign key to
--                    AOL table are stored as a list.
--   p_aol_parameters_tbl - All the columns of the table which have foreign key to
--                    AOL table are stored with data type as a list. This is
--                    used as a parameter list for the procedure generated to
--                    get the  AOL developer key for the given ID value
--                    e.g p_user_id  number
--   p_fk_to_aol_columns_tbl  - It stores the list of all the columns which have
--                   foreign on AOL table and corresponding name of the AOL
--                   table.
-- ------------------------------------------------------------------------
procedure create_tds_pacakge
(
 p_table_info             in   hr_dm_gen_main.t_table_info,
 p_columns_tbl            in   hr_dm_library.t_varchar2_tbl,
 p_parameters_tbl         in   hr_dm_library.t_varchar2_tbl,
 p_aol_columns_tbl        in   hr_dm_library.t_varchar2_tbl,
 p_aol_parameters_tbl     in   hr_dm_library.t_varchar2_tbl,
 p_fk_to_aol_columns_tbl  in   hr_dm_gen_main.t_fk_to_aol_columns_tbl
);

-- ----------------------- get_cursor_from_clause -------------------------
-- Description:
-- Get the list of all the tables required to get the download from clause.
-- if the business group_id field does not exist in the table to be downloaded
-- then it is derived from the table hierarchy table.
-- ------------------------------------------------------------------------
procedure get_cursor_from_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_from_clause      out nocopy    varchar2 ,
  p_lpad_spaces      in     number default 2
);
end hr_dm_gen_tds;

 

/
