--------------------------------------------------------
--  DDL for Package HR_DM_SEED_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_SEED_DP" AUTHID CURRENT_USER as
/* $Header: perdmsed.pkh 120.0 2005/05/31 17:14:21 appldev noship $ */
-- ----------------------- main --------------------------------
-- Description:
-- Main program which will seed the data pump data for a TUPS.
-- Steps required :
--     seed the TUPS upload module for the table.
--     for each ID column of the table call seed_id_parameter table.
--     if table has a column hierarchy then
--        seed the TUPS upload hierarchy data module as well
--  Input Parameters :
--       p_table_info   -  PL/SQL record containing info about
--                         current table.
--       p_columns_tbl  -  List of all columns of the table.
-- --------------------------------------------------------------
procedure main
(
 p_table_info      in   hr_dm_gen_main.t_table_info ,
 p_columns_tbl     in   hr_dm_library.t_varchar2_tbl
);
end hr_dm_seed_dp;

 

/
