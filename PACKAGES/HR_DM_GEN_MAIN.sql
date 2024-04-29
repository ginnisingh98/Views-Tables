--------------------------------------------------------
--  DDL for Package HR_DM_GEN_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_GEN_MAIN" AUTHID CURRENT_USER as
/* $Header: perdmgn.pkh 120.0 2005/05/30 21:17:34 appldev noship $ */
--------------------------------
-- DATA STRUCTURE DEFINITIONS --
--------------------------------
--
-- Table information structure. It stores the various properties of info about
-- the table. Mostly the information is taken from HR_DM_TABLES table.
--    table_id         - Id value of the table. Primary key of HR_DM_TABLES.
--    table_name       - Name of the table
--    datetrack        - 'Y' - for date track table
--                       'N' - for non datetrack table
--    surrogate_primary_key - whether table has a surrogate id column i.e single
--                            column numeric key.
--                          'Y' - table has surrogate id  column
--                          'N' - table does not have surrogate id column
--    surrogate_pk_column_name - Name of the surrogate id column. It will
--                          contain value if surrogate_primary_key value is 'Y'.
--    alias            - Alias of the table. Used in the select statement.
--    short_name       - Short name of the table. Used to define the TUPS/TDS
--                       package name
--    column_hierarchy  -  one or more column has foreign key on own table.
--                         Column hierarchy are derived from HR_DM_HIERARCHIES table
--                         with hierarchy type 'H' defined for this table.
--    table_hierarchy   -  business group_id has to be derived from parent table.
--                         Parents table are derived from HR_DM_HIERARCHIES table
--                         with hierarchy type 'PC' defined for this table.
--    use_non_pk_col_for_chk_row
--                        - one or more column required, other than primary key column
--                        to check whether row exists in the table or not. It is used
--                        by TUPS.
--    resolve_pk         - if 'Y' then add the code in the TUPS to get the latest
--                         ID value.
--    ins_resolve_pk     - If 'Y' then add the code to insert a record into the
--                         hr_dm_resolve_pk table.
--    use_distinct      -  If 'Y' then the TDS download cursor will use 'distinct'
--                         in the select statement. It will be used if it salisfies
--                         all the below conditions
--                            - tables has a  AOL hierarchy i.e hierarchy type = 'A'
--                            - has a table hierarchy  i.e hierarchy type = 'PC'
--                            - does not have 'long' data type.--
--    fk_to_aol_table   -  one or more column has foreign key on AOL table.
--                         Columns are derived from HR_DM_HIERARCHIES table
--                         with hierarchy type 'A' defined for this table.
--    missing_who_info  -  'Y' - if table does not have WHO columns
--                         'N' - if table has WHO columns
--    missing_primary_key  - 'Y' - if table does not have any primary key defined
--                                 in data base. In this case the logical primary
--                                 key is derived from HR_DM_HIERARCHIES table
--                                 with hierarchy type 'P' defined for this table.
--                           'N' - if the table has a primary key defined in database.
--  chk_row_exists_for_non_glb_tbl  - It will contain following value :
--                           'Y' - add the code in the upload procedure of TUPS
--                                 to check that whether row exists in destination
--                                 database for non global data.
--                           'N' - No check is made.
--
--   who_link_alias     - It tells the alias of table to be used to get the WHO
--                        information. It is used for tables which does not have
--                        explicit business group id and business group has to be
--                        derived from the chain of parent tables. It uses this
--                        alias to form the additive migration selection
--                        criteria.
--  derive_sql_download_full  - It contains the where clause for full migration
--                              download cursor.
--  derive_sql_download_add   - It contains the where clause for additive
--                              migration download cursor. It is applicable for
--                              date track table  only.
--  derive_sql_calc_ranges    - It contains the where clause for calculate ranges
--                              cursor.
--  derive_sql_delete_source  - It contains the where clause for delete data from
--                              source table cursor.
--  derive_sql_source_tables  - It stores the list of all tables used in the derive
--                              sql to form the from clause of the cursor of TDS.
--  derive_sql_chk_source_tables - It stores the list of all tables used in the derive
--                              sql to form the from clause of the cursor of
--                              chk_row_exists procedure.
--  derive_sql_chk_row_exists -  It contains the where clause for chk_row_exists procedure
--                              in TUPS
--  global_data               - 'Y' - table contains global data.
--                              'N' - table does not contain global data.
--  upload_table_name         - Name of the table to be uploaded at destination.It
--                              will be same in most of the cases except table like
--                              HR_LOCATIONS which contains global data as well as
--                              business group specific data.
--  use_distinct_download     - 'Y' indicates that distinct should be used for the
--                              download cursor
--  always_check_row          - 'Y' indicates that check_row_exists is always used
--  sequence_name             - name of the sequence to be used if a new id value is
--                              required for insertion into the destination database
--
----------------------------------------------------------------------------------
type t_table_info is record
(
  migration_id                     hr_dm_migrations.migration_id%type,
  table_id                         hr_dm_tables.table_id%type,
  table_name                       hr_dm_tables.table_name%type,
  datetrack                        hr_dm_tables.datetrack%type,
  surrogate_primary_key            varchar2(1),
  surrogate_pk_column_name         hr_dm_tables.surrogate_pk_column_name%type,
  alias                            hr_dm_tables.table_alias%type,
  short_name                       hr_dm_tables.short_name%type,
  column_hierarchy                 varchar2(1),
  table_hierarchy                  varchar2(1),
  use_non_pk_col_for_chk_row       varchar2(1),
  resolve_pk                       varchar2(1),
  ins_resolve_pk                   varchar2(1),
  use_distinct                     varchar2(1),
  fk_to_aol_table                  varchar2(1),
  missing_who_info                 varchar2(1),
  missing_primary_key              varchar2(1),
  chk_row_exists_for_non_glb_tbl   varchar2(1),
  who_link_alias                   hr_dm_tables.who_link_alias%type,
  derive_sql_download_full         hr_dm_tables.derive_sql_download_full%type,
  derive_sql_download_add          hr_dm_tables.derive_sql_download_add%type,
  derive_sql_calc_ranges           hr_dm_tables.derive_sql_calc_ranges%type,
  derive_sql_delete_source         hr_dm_tables.derive_sql_delete_source%type,
  derive_sql_source_tables         hr_dm_tables.derive_sql_source_tables%type,
  derive_sql_chk_source_tables     hr_dm_tables.derive_sql_chk_source_tables%type,
  derive_sql_chk_row_exists        hr_dm_tables.derive_sql_chk_row_exists%type,
  global_data                      hr_dm_tables.global_data%type,
  upload_table_name                hr_dm_tables.upload_table_name%type,
  use_distinct_download            hr_dm_tables.use_distinct_download%type,
  always_check_row                 hr_dm_tables.always_check_row%type,
  sequence_name                    hr_dm_tables.sequence_name%type
);

type t_table_info_tbl is table of t_table_info index by binary_integer;

--
--  This table structure stores the information for the columns which have
--  have a foreign key to the aol table.
--
--    column_name      - Name of the column of the table which has foreign key
--                       on AOL table.
--    parent_table_id  - Table Id (Primary key of HR_DM_TABLES) of the AOL table.
--    parent_table_name  -  Name of the AOL table.
--    parent_table_alias -  Alias of the AOL table.
--    parent_column_name -  Developer key of the AOL table.
--    parent_id_column_name - Primary key of AOL table.

type t_fk_to_aol_columns_info is record
(
  column_name               hr_dm_hierarchies.column_name%type,
  parent_table_id           hr_dm_hierarchies.parent_table_id%type,
  parent_table_name         hr_dm_tables.table_name%type,
  parent_table_alias        hr_dm_tables.table_alias%type,
  parent_column_name        hr_dm_hierarchies.parent_column_name%type,
  parent_id_column_name     hr_dm_hierarchies.parent_id_column_name%type
);

type t_fk_to_aol_columns_tbl is table of t_fk_to_aol_columns_info index by
                                                             binary_integer;
-- ------------------------- post_generate_validate    --------------------------
-- Description:
-- This function is called immediately after Generate phase is marked as
-- completed. It checks following for each table listed in the Generate phase :
--     - If the status of TUPS or TDS pakage is invaild then it
--        - Generates the TUPS/TDS for the table. If it is still invalid
--          i.e TUPS/TDS generator staus is still invalid or any compilation
--          error, then it stops the processing.
--     - If there is no TUPS/TDS package then it Generates the package.
--     - If status of the phase item is other than 'C' then it generates the
--       TUPS/TDS for that table.
-- ------------------------------------------------------------------------
procedure post_generate_validate
(p_migration_id         in   number
);
-- ------------------------- slave_generator_for_tbl    --------------------------
-- Description:
-- It generates TUPS/TDS for a given table.It calls
--     TUPS Generator to generate TUPS for the table
--     Seed the data into data pump for TUPS.
--     TDS Generator to generate TDS for the table.
--
-- ------------------------------------------------------------------------
procedure slave_generator_for_tbl
(
 p_phase_item_id        in   number
);
-- ------------------------- slave_generator ------------------------------
-- Description:
-- It generates TUPS/TDS for all the tables in the Generator phase for the
-- given migration run.
-- It reads the unprocessed table from Phase_Item table.It calls
--     TUPS Generator to generate TUPS for the table
--     Seed the data into data pump for TUPS.
--     TDS Generator to generate TDS for the table.
--  Input Parameters :
--        p_migration_id      - ID of the migration. Primary Key of
--                              HR_DM_MIGRATIONS table.
--        p_concurrent_process - Can have following values :
--                               'Y' - Migration is run as a concurrent process
--                                     so create a log file.
--                               'N' - Migration is not run from concurrent
--                                     process,so don't create a log file.
--       p_last_migration_date - This parameter is added so as to have generic
--                               master program which spawns slave processes.
--                               This process does not use this parameter.
--       p_process_number      - To prevent the locking issue each slave process
--                               will be passed the process number by master.
--                               Main cursor has been modified so as a row is
--                               processed by one process only. This is achieve
--                               by following:
--    MOD (primary_key, total_no_of_threads/slave_processes) + 1 = p_process_number
--
--  Output Parameters
--        errbuf  - buffer for output message (for CM manager)
--
--        retcode - program return code (for CM manager)
--
-- ------------------------------------------------------------------------
procedure slave_generator
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   date,
 p_process_number       in   number
);

-- ------------------------- chk_ins_resolve_pk   ------------------------
-- Description:
-- It checks whether a table has a child table with hierarchy type 'L'.
-- ------------------------------------------------------------------------
function chk_ins_resolve_pk
(
 p_table_id    in    number
) return varchar2;


end hr_dm_gen_main;

 

/
