--------------------------------------------------------
--  DDL for Package HR_DM_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_COPY" AUTHID CURRENT_USER AS
/* $Header: perdmcp.pkh 115.9 2002/03/07 08:51:12 pkm ship       $ */

--
----------------------- delete_datapump_tables ----------------------
-- This procedure truncates the following datapump tables
--        hr_pump_batch_header
--        hr_pump_batch_lines
--        hr_pump_requests
--        hr_pump_ranges
--        hr_pump_batch_exceptions
---------------------------------------------------------------------
PROCEDURE delete_datapump_tables ;


----------------------- source_copy ---------------------------------
-- This procedure does some of the tasks of Copy phase in source
-- database. It does the following :
--    o Insert the data migrator packages rows from HR_API_MODULES
--       table into HR_DM_EXP_API_MODULES_V view based on
--       HR_DM_EXP_IMP table.
--    o Insert the current migration row from HR_DM_MIGRATIONS tables
--      into  HR_DM_EXP_MIGRATIONS_V view based on  HR_DM_EXP_IMP table
-- Input Parameters :
--    p_migration_id - Migration Id of the current migration. Primary
--                     key on hr_dm_migrations table.
--    p_last_migration_date - last migration date
-- Called By : Main controller in source database
---------------------------------------------------------------------
PROCEDURE source_copy (p_migration_id number,
                       p_last_migration_date date);


----------------------- destination_copy ---------------------------------
-- This procedure does some of the tasks of Copy phase in destination
-- database. It does the following :
--    o Call procedure delete_datapump_tables to truncate datapump
--      tables at destination.
--    o Delete the data migrator packages rows from HR_API_MODULES table
--      i.e where API_MODULE_TYPE = 'DM'.
--    o Insert the rows into HR_API_MODULES tables from HR_DM_EXP_API_MODULES_V
--      view based on HR_DM_EXP_IMP table
--    o Insert the row into HR_DM_MIGRATION table from HR_DM_EXP_MIGRATIONS_V
--      view based on HR_DM_EXP_IMP table.
-- Input Parameters :
--    p_migration_id - Migration Id of the current migration. Primary
--                     key on hr_dm_migrations table.
-- Called By : Run manually at destination database
---------------------------------------------------------------------
PROCEDURE destination_copy;

--


END hr_dm_copy;

 

/
