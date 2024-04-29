--------------------------------------------------------
--  DDL for Package HR_DM_LIBRARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_LIBRARY" AUTHID CURRENT_USER as
/* $Header: perdmlib.pkh 115.11 2003/01/13 19:42:35 mmudigon ship $ */
--------------------------------------------------------------
-- ERROR MESSAGING AND TRACING STUFF AND CONSTANT DEFINATIONS--
---------------------------------------------------------------
--
-- Trace levels.
--
--c_trace_level1 constant number default 1;
--c_trace_level2 constant number default 2;
--g_trace_level number := 0;
--------------------------------
-- DATA STRUCTURE DEFINITIONS --
--------------------------------
-- Migration information structure. Stores the main details of the data
-- migration run
--

type t_data_migration is record
(
  migration_id             hr_dm_migrations.migration_id%type,
  business_group_id        hr_dm_migrations.business_group_id%type,
  migration_type           hr_dm_migrations.migration_type%type,
  source_database          hr_dm_migrations.source_database_instance%type,
  destination_database     hr_dm_migrations.destination_database_instance%type
);
--
-- List Of PL/SQL varchar2 tables
--
type t_varchar2_tbl is table of varchar2(100) index by binary_integer;

--------------------------
-- CONSTANT DEFINITIONS --
--------------------------
c_newline             constant varchar2(500)  := fnd_global.newline;
/*
c_newline               constant varchar(1) default '
';
*/

---------------------------
-- Global PL/SQL tables. --
---------------------------
--
-- Tables to assist in code generation.
--
g_columns_tbl        t_varchar2_tbl;
g_proc_parameter_tbl t_varchar2_tbl;

-- ----------------------- indent -----------------------------------------
-- Description:
-- returns the 'n' blank spaces on a newline.used to indent the procedure
-- statements.
--
-- ------------------------------------------------------------------------

function indent
(
 p_indent_spaces  in number default 0,
 p_newline        in varchar2 default 'Y'
) return varchar2;


-- ------------------------- get_generator_version ------------------------
-- Description:
-- It gets the version number of the Genrator by concatenating the arcs
-- version of Main Generator package, TUPS Generator package and TDS package.
-- It is used by the Main Generator to stamp the generator version for each
-- generated TUPS/TDS and by initialisation program to check whether given
-- TUPS/TDS had been compiled by the latest generator.
--  Input Parameters
--        p_format_output - Whether a formatted output is required or not.
--                          For updating the generator_version field no
--                          formatting is required. Output will be stored as a one large string.
--                          But for TUPs/TDS packages output string is
--                          properly indented. It can have two values :
--                          'Y' - Formatted output is required
--                          'N' - Output string without indentation.
--  Output Parameters
--        p_package_version -  It returns the text string created by the ARCS
-- for the package.
--
-- ------------------------------------------------------------------------
procedure get_generator_version
(
 p_generator_version      out nocopy  varchar2,
 p_format_output          in   varchar2 default 'N'
);
-- ------------------------- get_package_version ------------------------
-- Description:
-- It gets the version number for the given package. Depending upon the
-- version type required it either returns the full header string of the
-- package body or concatenate the File name and Version number of package
-- header and
-- body of the package.
--  Input Parameters :
--        p_package_name   - Name of the stored package whose version number
--                           is required.
--        p_version_type   - It identifies what sort of output version string is
--                           required. It can have following values
--                           SUMMARY - concatenate the File name and Version
--         number of package header and body of the
--         package.
--         the output version string will look as
--         ' hrdmgen.pkh 115.1 : hrdmgen.pkb 115.1 '
--                           FULL    - Full header string from the package
--                                     body
--         is returned.
--         the output version string will look as
--         /* $Header: perdmlib.pkh 115.11 2003/01/13 19:42:35 mmudigon ship $ */
--  Output Parameters
--        p_package_version -  It returns the text string created by the ARCS
-- for the package.
--
--
-- ------------------------------------------------------------------------
procedure get_package_version
(
 p_package_name         in   varchar2,
 p_package_version      out nocopy  varchar2,
 p_version_type         in   varchar2 default 'SUMMARY'
);

-- ------------------------- get_table_info ------------------------
-- Description:
-- It returns the properties of the table for the given id.
--  Input Parameters :
--        p_table_id   - Primary key of the hr_dm_tables.
--  Output Parameters
--        p_table_info -  Various properties of the table is returned in
--                        pl/sql table. The properties are
--                        o  table_id
--                        o  table_name
--                        o  datetrack
--                        o  surrogate_primary_key (Y/N)
--                        o  surrogate_pk_column_name
--                        o  table_alias
--                        o  short_name of the table
--
-- ------------------------------------------------------------------------

procedure get_table_info
(
 p_table_id                in   number,
 p_table_info              out nocopy  hr_dm_gen_main.t_table_info
);

-- ------------------------- check_col_for_fk_on_aol ------------------------
-- Description:
-- It checks whether a given column name exists in the pl/sql table which
-- contains the list of all the columns which have foreign key on AOL table or
-- columns whose id value need to be resolved.
--Input parameters
--  p_fk_to_aol_columns_tbl  - This can contain the list of columns which have
--                             'A' type hierarchy or 'L' type hierarchy.
--  p_column_name            - Name of the column which needs to be searched in
--                             the above list.
-- Out parameters
--  p_index              -  index of list, if it finds the given column in the above
--                         list.
--------------------------------------------------------------------------------
procedure check_col_for_fk_on_aol
(
 p_fk_to_aol_columns_tbl    in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_column_name              in   varchar2,
 p_index                    out nocopy  number
) ;

-- ------------------------- populate_fk_to_aol_cols -----------------------
-- Description:
-- initially this procedure is designed to store the details of from hierarchies
-- table for AOL type hierarchy i.e hierarchy type 'A'. But we added another
-- hierarchy type 'L' for looking up the ID value i.e use the corresponding id
-- value of the parent table at destination for a given column.
-- It populates the PL/SQL table with all columns details stored in a
-- hr_dm_hierarchies table for a given table and hierarchy type.
-- Input Parameters
--     p_hierarchy_type - 'A' - AOL type hierarchy
--                        'L' - lookup type hierarchy.
----------------------------------------------------------------------------
procedure populate_fk_to_aol_cols_info
(
 p_table_info               in   hr_dm_gen_main.t_table_info,
 p_fk_to_aol_columns_tbl    out nocopy  hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_hierarchy_type           in   varchar2 default 'A'
);
-- ------------------------- populate_columns_list ------------------------
-- Description:
-- It populates the PL/SQL table with the list of column. This is to avoid
-- database access getting the column list again.
-- e.g : Table T1 has column col1,col2then the out parameter list will be
-- populated as
-- p_columns_list   = col1 | col2
-- p_parameter_list = p_col1  in number | p_col2 in varchar2
--
-- Input Parameters :
--        p_table_name   - Table name.
-- Output Parameters
--        p_columns_tbl  -  Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of columns of the table.
--        p_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of column name used as a input arguments
--                          in the procedure.
-- ------------------------------------------------------------------------
procedure populate_columns_list
(
 p_table_info              in   hr_dm_gen_main.t_table_info,
 p_fk_to_aol_columns_tbl   in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_columns_tbl             out nocopy  t_varchar2_tbl,
 p_parameter_tbl           out nocopy  t_varchar2_tbl,
 p_aol_columns_tbl         out nocopy  t_varchar2_tbl,
 p_aol_parameter_tbl       out nocopy  t_varchar2_tbl,
 p_missing_who_info        out nocopy  varchar2
);

-- ------------------------- populate_pk_columns_list ------------------------
-- Description:
-- It populates the PL/SQL table with the list of primary key column. This is
-- to avoid database access getting the column list again.
-- e.g : Table T1 has primary key columns pk_col1,pk_col2then the out
-- parameter list will be populated as
-- p_columns_list  =  pk_col1 | pk_col2
-- p_parameter_list = p_pk_col1  in number | p_pk_col2 in varchar2
--
-- Input Parameters :
--        p_table_info   - pl/sql table contains info like table name and
--                         various properties of the table.
-- Output Parameters
--        p_pk_columns_tbl  -  Out pl/sql table type t_varchar2_tbl.
--                             It contains the list ofprimary key columns of
--                             the table.
--        p_pk_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It
--                             contains the list of primary key column name
--                             used as a input arguments in the procedure.
--        p_no_of_pk_columns - Out number of primary key columns in the
--                             primary key.
-- ------------------------------------------------------------------------
procedure populate_pk_columns_list
(
 p_table_info              in   hr_dm_gen_main.t_table_info,
 p_pk_columns_tbl          out nocopy  t_varchar2_tbl,
 p_pk_parameter_tbl        out nocopy  t_varchar2_tbl,
 p_no_of_pk_columns        out nocopy  number
);

-- ------------------------- populate_hierarchy_cols_list ------------------
-- Description:
-- It populates the PL/SQL table with the list of hierarchy column. This is
-- to avoid  database access getting the column list again.
-- e.g : Table T1 has column col1,col2then the out parameter list will be
-- populated as
-- p_hier_columns_list  =  col1 | col2
-- p_hier_parameter_list = p_col1  in number | p_col2 in varchar2
--
-- Input Parameters :
--    p_table_info        - Information about table in PL/SQL Table.
-- Output Parameters
--    p_hier_columns_tbl  -  Out pl/sql table type t_varchar2_tbl. It
--                           contains the list of hierarchy columns in
--                           a table. The list content varies depending
--                           upon the value of p_called_from parameter.
--                           If it is called from
--                           TUPS - it contains only the list of hierarchy
--                                  columns
--                           TDS - it contains the list of hierarchy columns
--                                 and the primary key column names also.
--    p_hier_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It
--                          contains the list of hierarchy columns used
--                          as a input arguments in the procedure.
--    p_called_from        - It can have following values :
--                            TUPS - if this function is called from TUPS
--                                   generator package.
--                            TDS  - if this function is called from TDS
--                                   generator package.
-- ------------------------------------------------------------------------
procedure populate_hierarchy_cols_list
(
 p_table_info              in   hr_dm_gen_main.t_table_info,
 p_hier_columns_tbl        out nocopy  t_varchar2_tbl,
 p_hier_parameter_tbl      out nocopy  t_varchar2_tbl,
 p_called_from             in   varchar2
);

-- ------------------------- get_cols_list_wo_pk_cols -----------------------
-- Description:
-- This procedure returns list of columns of the table which are not the
-- part of primary columns. It is used by TUPS for generating update_dml
-- as we do not want to update the primary key columns.
--  Input parameters :
--    p_columns_tbl     - List of all columns of table.
--    p_pk_columns_tbl  - List of primary key columns of table
--
--  Output Parameter:
--    p_cols_wo_pk_cols_tbl - List of columns of table which are not the
--                            part of primary key.
--
-- It checks whether a given column name exists in the pl/sql table which
-- contains the list of all the columns which have foreign key on AOL table.
-----------------------------------------------------------------------------
procedure get_cols_list_wo_pk_cols
(
 p_columns_tbl            in   hr_dm_library.t_varchar2_tbl,
 p_pk_columns_tbl         in   hr_dm_library.t_varchar2_tbl,
 p_cols_wo_pk_cols_tbl    out nocopy   hr_dm_library.t_varchar2_tbl
);

-- ------------------------- conv_list_to_text ---------------------------
-- Description:
-- It reads the list elements and converts them to varchar2 text in which
-- each element is separated by comma and put into the next line. Each
-- element is padded with the given number of spaces. e.g
-- A list contains col1,col2,col3 as elements.
-- It will put the output as
--   col1,
--   col2,
--   col3
--
-- Note: There is an overloaded version of this function where we require
-- some columns to be prefixed with a different prefix. Changes should
-- be applied to both versions where applicable.
--
-- Input Parameters :
--       p_rpad_spaces    -  Number of blank spaces added before writing the
--                           element on new line.
--       p_pad_first_line -  It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--       p_prefix_col     -  Prefix the element with this value. e.g if
--                           p_prefix_col is 'p_' then all elements will be
--                           prefixed with p_ and our list output will be
--                           p_col1,
--                           p_col2,
--                           p_col3.
--      p_columns_tbl    -   List of the columns or elements which is required
--                           to be changed into text.
--                           It is of pl/sql type  t_varchar2_tbl,
--      p_col_length     -   It adds the spaces after the column name so as
--                           to make the column name length same for each
--                           column by adding the required number of spaces.
--    p_start_terminator     This is put at the begning of the assignment from
--                           the second element onwards. By  default it is ','
--                           but in some cases it can be 'and' especially use
--                           by TUPS for generating where clause for composite
--                           primary keys.
--    p_end_terminator       This is put at the end of the assignment. It is
--                           null most of the time and is used by Date Track
--                           TUPS with composite key to terminate the
--                           assignment with ';'.
-- Returns
--  It returns a string  by putting each element of the table into a newline.
-- ------------------------------------------------------------------------
function conv_list_to_text
(
 p_rpad_spaces      in   number,
 p_pad_first_line   in   varchar2 default 'N',
 p_prefix_col       in   varchar2 default null,
 p_columns_tbl      in   t_varchar2_tbl,
 p_col_length       in   number   default 30,
 p_start_terminator in   varchar2 default ',',
 p_end_terminator   in   varchar2 default null
)
return varchar2;

-- ------------------------- conv_list_to_text ---------------------------
-- Description:
-- It reads the list elements and converts them to varchar2 text in which
-- each element is separated by comma and put into the next line. Each
-- element is padded with the given number of spaces. e.g
-- A list contains col1,col2,col3 as elements.
-- It will put the output as
--   col1,
--   col2,
--   col3
--
-- Note: There is a non-overloaded version of this function. Changes should
-- be applied to both versions where applicable.
--
-- Input Parameters :
--       p_rpad_spaces    -  Number of blank spaces added before writing the
--                           element on new line.
--       p_pad_first_line -  It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--       p_prefix_col     -  Prefix the element with this value. e.g if
--                           p_prefix_col is 'p_' then all elements will be
--                           prefixed with p_ and our list output will be
--                           p_col1,
--                           p_col2,
--                           p_col3.
--      p_columns_tbl    -   List of the columns or elements which is required
--                           to be changed into text.
--                           It is of pl/sql type  t_varchar2_tbl,
--      p_col_length     -   It adds the spaces after the column name so as
--                           to make the column name length same for each
--                           column by adding the required number of spaces.
--    p_start_terminator     This is put at the begning of the assignment from
--                           the second element onwards. By  default it is ','
--                           but in some cases it can be 'and' especially use
--                           by TUPS for generating where clause for composite
--                           primary keys.
--    p_end_terminator       This is put at the end of the assignment. It is
--                           null most of the time and is used by Date Track
--                           TUPS with composite key to terminate the
--                           assignment with ';'.
--    p_overide_tbl          A table which lists which columns should be
--                           prefixed by an alternative to p_prefix_col
--    p_overide_prefix       Prefix to use instead of p_prefix_col
-- Returns
--  It returns a string  by putting each element of the table into a newline.
-- ------------------------------------------------------------------------
function conv_list_to_text
(
 p_rpad_spaces      in   number,
 p_pad_first_line   in   varchar2 default 'N',
 p_prefix_col       in   varchar2 default null,
 p_columns_tbl      in   t_varchar2_tbl,
 p_col_length       in   number   default 30,
 p_start_terminator in   varchar2 default ',',
 p_end_terminator   in   varchar2 default null,
 p_overide_tbl      in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_overide_prefix   in   varchar2 default null
)
return varchar2;

-- ------------------------- get_nvl_arguement ---------------------------
-- Description:
-- It
-- Input Parameters :
--    p_test_with_nvl        Flag to indicate if NVL testing is required, if
--                           so then return value is ''
--    p_table_name           Name of the table
--    p_column_name          Name of the column in the table
--    p_nvl_prefix           Prefix for nvl variable
--    p_nvl_suffix           Suffix for nvl variable
-- Returns
--  <none>
-- ------------------------------------------------------------------------
procedure get_nvl_arguement
(
 p_test_with_nvl           in   varchar2,
 p_table_name              in   varchar2,
 p_column_name             in   varchar2,
 p_nvl_prefix              out nocopy  varchar2,
 p_nvl_suffix              out nocopy  varchar2
);


-- ------------------------- get_func_asg ---------------------------
-- Description:
-- It reads the list columns and returns the parameters list required for
-- inserting the data into data pump batch_lines table or any other TUPS
-- function
-- e.g p_col1 => p_col2,
--     p_col2 => p_col2...
--
-- NOTE: This function is overloaded
--
-- Input Parameters :
--      p_rpad_spaces    -  Number of blank spaces added before writing the
--                           element on new line.
--      p_columns_tbl    -   List of the columns or elements which is required
--                           to be changed into text of parameter assignment.
--                           It is of pl/sql type  t_varchar2_tbl,
--      p_prefix_left_asg - Prefix the left element with this value. e.g if
--                           value is 'p_' then all elements on the left hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           p_col1 => col1,
--                           p_col2 => col2,
--                           p_col3 => col3
--     p_prefix_right_asg - Prefix the right element with this value. e.g if
--                           value is 'p_' then all elements on the right hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           col1 => p_col1,
--                           col2 => p_col2,
--                           col3 => p_col3
--    p_omit_business_group_id  - It is whether to exclude the
--                           business_group_id assignment from the list.
--                           'Y' - does not include business_group_id column
--                                 for parameter assignment. (default value)
--                           'N' - includes business_group_id column for
--                                 parameter assignment.
--    p_comma_on_first_line  - Put the comma in the first element or not.
--                           'Y' - puts the comma before the first element
--                                 parameter assignment.
--                           'N' - does not put comma before the first element
--                                 parameter assignment.
--    p_equality_sign        - By default the equality sign of the parameter
--                             assignment is ' => '. But it can be '=' for
--                             update statement set column assignment.
--    p_pad_first_line   -   It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--    p_left_asg_pad_len  -  It means the length of the left hand parameter
--                           after prefix. e.g p_prefix_left is 'p_' and column
--                           name is 'responsibility_application_id', if the
--                           length is 30 the the left hand parameter will be
--                           'p_responsibility_application_i'.
--    p_right_asg_pad_len    same as above but applied to right hand side
--                           parameter.
--                           parameter.
--    p_start_terminator     This is put at the begning of the assignment from
--                           the second element onwards. By  default it is ','
--                           but in some cases it can be 'and' especially use
--                           by TUPS for generating where clause for composite
--                           primary keys.
--    p_end_terminator       This is put at the end of the assignment. It is
--                           null most of the time and is used by Date Track
--                           TUPS with composite key to terminate the
--                           assignment with ';'.
--    p_test_with_nvl        This is a flag used with the creation of the
--                           chk_row_exists cursor in the TUPS and forces
--                           the comparison to use NVL.
--    p_table_name           Name of the table
--
-- Returns
--  It returns a string  by putting each element of the table into a newline.
--  and sepearting the element assignment by terminator.
-- ------------------------------------------------------------------------

function get_func_asg
(
 p_rpad_spaces             in   number,
 p_columns_tbl             in   t_varchar2_tbl,
 p_prefix_left_asg         in   varchar2 default 'p_',
 p_prefix_right_asg        in   varchar2 default 'p_',
 p_omit_business_group_id  in   varchar2 default 'Y',
 p_comma_on_first_line     in   varchar2 default 'Y',
 p_equality_sign           in   varchar2 default ' => ',
 p_pad_first_line          in   varchar2 default 'Y' ,
 p_left_asg_pad_len        in   number   default 30,
 p_right_asg_pad_len       in   number   default 30,
 p_start_terminator        in   varchar2 default ',' ,
 p_end_terminator          in   varchar2 default null,
 p_test_with_nvl           in   varchar2 default 'N',
 p_table_name              in   varchar2 default null
)
return varchar2;

-- ------------------------- get_func_asg ---------------------------
-- Description:
-- This function is same as get_func_asg but also except the input
-- parameter for pl/sql table which have list of column for resolving
-- pk.
-- It reads the list columns and returns the parameters list required for
-- inserting the data into data pump batch_lines table or any other TUPS
-- function
-- e.g p_col1 => p_col2,
--     p_col2 => p_col2...
--
-- NOTE: This function is overloaded
--
-- Input Parameters :
--      p_rpad_spaces    -  Number of blank spaces added before writing the
--                           element on new line.
--      p_columns_tbl    -   List of the columns or elements which is required
--                           to be changed into text of parameter assignment.
--                           It is of pl/sql type  t_varchar2_tbl,
--      p_prefix_left_asg - Prefix the left element with this value. e.g if
--                           value is 'p_' then all elements on the left hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           p_col1 => col1,
--                           p_col2 => col2,
--                           p_col3 => col3
--     p_prefix_right_asg - Prefix the right element with this value. e.g if
--                           value is 'p_' then all elements on the right hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           col1 => p_col1,
--                           col2 => p_col2,
--                           col3 => p_col3
--    p_omit_business_group_id  - It is whether to exclude the
--                           business_group_id assignment from the list.
--                           'Y' - does not include business_group_id column
--                                 for parameter assignment. (default value)
--                           'N' - includes business_group_id column for
--                                 parameter assignment.
--    p_comma_on_first_line  - Put the comma in the first element or not.
--                           'Y' - puts the comma before the first element
--                                 parameter assignment.
--                           'N' - does not put comma before the first element
--                                 parameter assignment.
--    p_equality_sign        - By default the equality sign of the parameter
--                             assignment is ' => '. But it can be '=' for
--                             update statement set column assignment.
--    p_pad_first_line   -   It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--    p_left_asg_pad_len  -  It means the length of the left hand parameter
--                           after prefix. e.g p_prefix_left is 'p_' and column
--                           name is 'responsibility_application_id', if the
--                           length is 30 the the left hand parameter will be
--                           'p_responsibility_application_i'.
--    p_right_asg_pad_len    same as above but applied to right hand side
--                           parameter.
--                           parameter.
--    p_start_terminator     This is put at the begning of the assignment from
--                           the second element onwards. By  default it is ','
--                           but in some cases it can be 'and' especially use
--                           by TUPS for generating where clause for composite
--                           primary keys.
--    p_end_terminator       This is put at the end of the assignment. It is
--                           null most of the time and is used by Date Track
--                           TUPS with composite key to terminate the
--                           assignment with ';'.
--   p_resolve_pk_columns_tbl The column in this pl/sql table should have
--                           'l_' as prefix in the right hand side assignment.
--                           Thay are lookup columns whose value is derived
--                           from the destination database.
--   p_test_with_nvl         This is a flag used with the creation of the
--                           chk_row_exists cursor in the TUPS and forces
--                           the comparison to use NVL.
--    p_table_name           Name of the table
-- Returns
--  It returns a string  by putting each element of the table into a newline.
--  and sepearting the element assignment by terminator.
-- ------------------------------------------------------------------------
function get_func_asg
(
 p_rpad_spaces             in   number,
 p_columns_tbl             in   t_varchar2_tbl,
 p_prefix_left_asg         in   varchar2 default 'p_',
 p_prefix_right_asg        in   varchar2 default 'p_',
 p_omit_business_group_id  in   varchar2 default 'Y',
 p_comma_on_first_line     in   varchar2 default 'Y',
 p_equality_sign           in   varchar2 default ' => ',
 p_pad_first_line          in   varchar2 default 'Y' ,
 p_left_asg_pad_len        in   number   default 30,
 p_right_asg_pad_len       in   number   default 30,
 p_start_terminator        in   varchar2 default ',' ,
 p_end_terminator          in   varchar2 default null,
 p_resolve_pk_columns_tbl  in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_test_with_nvl           in   varchar2 default 'N',
 p_table_name              in   varchar2 default null
)
return varchar2;

-- ------------------------- get_func_asg_with_dev_key ---------------------------
-- Description:
-- This function is same as the get_func_asg but it replaces the column which
-- have foreign key to AOL table with the corresponding developer key column
-- of the AOL table.
-- It reads the list columns and replaces appropriate column with the developer
-- key column of the AOL table and returns the parameters list required for
-- inserting the data into data pump batch_lines table or any other TUPS
-- function
-- e.g a table has col1,col2 and col1 has a foreign key on aol table and
--     corresponding developer key is col1_dev_key then the output returned is :
--     p_col1_dev_key => l_col1_dev_key,
--     p_col2         => p_col2...
-- Input Parameters :
--      p_rpad_spaces    -  Number of blank spaces added before writing the
--                           element on new line.
--      p_columns_tbl    -   List of the columns or elements which is required
--                           to be changed into text of parameter assignment.
--                           It is of pl/sql type  t_varchar2_tbl,
--      p_prefix_left_asg - Prefix the left element with this value. e.g if
--                           value is 'p_' then all elements on the left hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           p_col1 => col1,
--                           p_col2 => col2,
--                           p_col3 => col3
--     p_prefix_right_asg - Prefix the right element with this value. e.g if
--                           value is 'p_' then all elements on the right hand
--                           side of the assignment will be prefixed with 'p_'
--                           prefixed with p_ and our list output will be
--                           col1 => p_col1,
--                           col2 => p_col2,
--                           col3 => p_col3
--   p_prefix_left_asg_dev_key  - same as p_prefix_left_asg defined above but is
--                           applied only to developer key.
--   p_prefix_right_asg_dev_key  - same as p_prefix_right_asg defined above but
--                           is applied only to developer key.
--    p_omit_business_group_id  - It is whether to exclude the business_group_id
--                           assignment from the list.
--                           'Y' - does not include business_group_id column for
--     parameter assignment. (default value)
--                           'N' - includes business_group_id column for
--     parameter assignment.
--    p_comma_on_first_line  - Put the comma in the first element or not.
--'Y' - puts the comma before the first element
--      parameter assignment.
--'N' - does not put comma before the first element
--      parameter assignment.
--    p_equality_sign        - By default the equality sign of the parameter
-- assignment is ' => '. But it can be '=' for
-- update statement set column assignment.
--    p_pad_first_line   -  It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--    p_left_asg_pad_len  -  It means the length of the left hand parameter
--                           after prefix. e.g p_prefix_left is 'p_' and column
--                           name is 'responsibility_application_id', if the
--                           length is 30 the the left hand parameter will be
--                           'p_responsibility_application_i'.
--    p_right_asg_pad_len    same as above but applied to right hand side
--                           parameter.
--    p_use_aol_id_col       This function is used by TUPS as well as TDS.
--                           TDS uses the developer key  for assignment while
--                           TUPS uses id value. It can have following values
--                           'N' - use id  column for assignment
--                           'Y' - use deveoper key column for assignment
--   p_resolve_pk_columns_tbl The column in this pl/sql table should have
--                           'l_' as prefix in the right hand side assignment.
--
-- Returns
--  It returns a string  by putting each element of the table into a newline.
--
-- ------------------------------------------------------------------------
function get_func_asg_with_dev_key
(
 p_rpad_spaces              in   number,
 p_columns_tbl              in   t_varchar2_tbl,
 p_prefix_left_asg          in   varchar2 default 'p_',
 p_prefix_right_asg         in   varchar2 default 'p_',
 p_prefix_left_asg_dev_key  in   varchar2 default 'p_',
 p_prefix_right_asg_dev_key in   varchar2 default 'l_',
 p_omit_business_group_id   in   varchar2 default 'Y',
 p_comma_on_first_line      in   varchar2 default 'Y',
 p_equality_sign            in   varchar2 default ' => ',
 p_pad_first_line           in   varchar2 default 'Y' ,
 p_left_asg_pad_len         in   number   default 30,
 p_right_asg_pad_len        in   number   default 30,
 p_use_aol_id_col           in   varchar2,
 p_fk_to_aol_columns_tbl    in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_resolve_pk_columns_tbl    in   hr_dm_gen_main.t_fk_to_aol_columns_tbl
)
return varchar2;
-- ------------------------ get_resolved_pk ------------------------------
-- Description: This function is used by TUPS.
-- Checks whether a row exists for a given source id of the table.
-- Input Parameters
--    p_source_id    - Value of the surrogate primary key of the table in
--                     source database
--    p_table_name   - Table name
-- Out Parameters
--    p_destination_id    - Value of the surrogate primary key of the table in
--                          destination database if different from source database
--                          ,otherwise it returns the same id value as source.
--
-- ------------------------------------------------------------------------
procedure get_resolved_pk
( p_table_name       in     varchar2,
  p_source_id        in     number,
  p_destination_id   out nocopy    number
);

-- ------------------------ ins_resolve_pks ---------------------------------
-- Description:
-- Insert a row into hr_dm_resolve_pks table. It will be used by TUPS.
-- Input Parameters
--    p_table_name - Table name
--    p_source_id  - Value of the first primary key column
--    p_destination_id - Value of the second primary key column
-- ------------------------------------------------------------------------
procedure ins_resolve_pks
( p_table_name      in varchar2,
  p_source_id       in number,
  p_destination_id  in number
);

-- ------------------------ ins_dt_delete ---------------------------------
-- Description:
-- Insert a row into hr_dm_deletes table. It will be used by TUPS. If the
-- already exists or for date tracked row on uploading it will store the
-- surrogate_id value.
-- Input Parameters
--    p_id         - Value of the surrogate primary key of the table.
--    p_table_name - Table name
--    p_ins_type   - idetifies the type of operation -
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_pk_column_1 - Value of the first primary key column
--    p_pk_column_2 - Value of the second primary key column
--    p_pk_column_3 - Value of the third primary key column
--    p_pk_column_3 - Value of the fourth primary key column
-- ------------------------------------------------------------------------
procedure ins_dt_delete
( p_id          in number default null,
  p_table_name  in varchar2,
  p_ins_type    in varchar2 ,
  p_pk_column_1 in varchar2 default null,
  p_pk_column_2 in varchar2 default null,
  p_pk_column_3 in varchar2 default null,
  p_pk_column_4 in varchar2 default null
);

-- ------------------------ chk_row_in_dt_delete ----------------------------
-- Description: This function is used by Date Track TUPS
-- Checks whether a row exists for a given id of the table and type.
-- Input Parameters
--    p_id         - Value of the surrogate primary key of the table.
--    p_table_name - Table name
-- Out Parameters
--    p_ins_type -  If a row exists for the table/Id combination then one of
--                  the following value is returned.
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_row_exists - If a row exists for the table/Id combination then it will
--                   have 'Y' ,otherwise 'N' value.
-- ------------------------------------------------------------------------
procedure chk_row_in_dt_delete
( p_id          in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
);
-- ------------------------ chk_row_in_dt_delete_1_pkcol ----------------------
-- Description: This function is used by Date Track table with non surrogate id.
--              The priomary key consists of one column
-- Checks whether a row exists for a given primary key of the table and type.
-- Input Parameters
--    p_pk_column_1  - Value of primary key of the table.
--    p_table_name   - Table name
-- Out Parameters
--    p_ins_type -  If a row exists for the table/Id combination then one of
--                  the following value is returned.
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_row_exists - If a row exists for the table/Id combination then it will
--                   have 'Y' ,otherwise 'N' value.
-- ---------------------------------------------------------------------------
procedure chk_row_in_dt_delete_1_pkcol
( p_pk_column_1 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
);

-- ------------------------ chk_row_in_dt_delete_2_pkcol ---------------------
-- Description: This function is used by Date Track table with non surrogate
--              id.The primary key consists of two columns
-- Checks whether a row exists for a given primary key columns of the table and type.
-- Input Parameters
--    p_pk_column_1  - Value of primary key column 1 of the table.
--    p_pk_column_2  - Value of primary key column 2 of the table.
--    p_table_name   - Table name
-- Out Parameters
--    p_ins_type -  If a row exists for the table/Id combination then one of
--                  the following value is returned.
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_row_exists - If a row exists for the table/Id combination then it will
--                   have 'Y' ,otherwise 'N' value.
-- ------------------------------------------------------------------------
procedure chk_row_in_dt_delete_2_pkcol
( p_pk_column_1 in     number,
  p_pk_column_2 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
);

-- ------------------------ chk_row_in_dt_delete_3_pkcol ---------------------
-- Description: This function is used by Date Track table with non surrogate
--              id. The primary key consists of three columns
-- Checks whether a row exists for a given primary key columns of the table
-- and type.
-- Input Parameters
--    p_pk_column_1  - Value of primary key column 1 of the table.
--    p_pk_column_2  - Value of primary key column 2 of the table.
--    p_pk_column_3  - Value of primary key column 3 of the table.
--    p_table_name   - Table name
-- Out Parameters
--    p_ins_type -  If a row exists for the table/Id combination then one of
--                  the following value is returned.
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_row_exists - If a row exists for the table/Id combination then it will
--                   have 'Y' ,otherwise 'N' value.
-- ------------------------------------------------------------------------
procedure chk_row_in_dt_delete_3_pkcol
( p_pk_column_1 in     number,
  p_pk_column_2 in     number,
  p_pk_column_3 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
);

-- ------------------------ chk_row_in_dt_delete_4_pkcol ---------------------
-- Description: This function is used by Date Track table with non surrogate
--              id. The primary key consists of four columns
-- Checks whether a row exists for a given primary key columns of the table and type.
-- Input Parameters
--    p_pk_column_1  - Value of primary key column 1 of the table.
--    p_pk_column_2  - Value of primary key column 2 of the table.
--    p_pk_column_3  - Value of primary key column 3 of the table.
--    p_pk_column_4  - Value of primary key column 4 of the table.
--    p_table_name   - Table name
-- Out Parameters
--    p_ins_type -  If a row exists for the table/Id combination then one of
--                  the following value is returned.
--                  'D' - for date track. created by the first physical record
--                        uploaded, so as other physical records belonging to
--                        the same logical record can avoid the checks.
--                  'P' - row already exists.
--    p_row_exists - If a row exists for the table/Id combination then it will
--                   have 'Y' ,otherwise 'N' value.
-- ------------------------------------------------------------------------
procedure chk_row_in_dt_delete_4_pkcol
( p_pk_column_1 in     number,
  p_pk_column_2 in     number,
  p_pk_column_3 in     number,
  p_pk_column_4 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
);
-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed. The SQL command is passed to this procedure as a atrring of
-- varchar2.
--
-- ------------------------------------------------------------------------
procedure run_sql( p_sql in varchar2 );
-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed. This procedure uses pl/sql table of varchar2 as an input
-- and hence is suitable to compile very large packages i.e more than
-- 32767 char.
-- ------------------------------------------------------------------------
procedure run_sql(p_package_body    dbms_sql.varchar2s,
                  p_package_index   number );

-- ------------------------ check_compile ---------------------------------
-- Description:
-- Checks whether or not the generated package or view compiled okay.
-- ------------------------------------------------------------------------
procedure check_compile
(
  p_object_name in varchar2,
  p_object_type in varchar2
);

-- ------------------------- get_data_type ------------------------------
-- Description:
-- It gets the data type for a given column of the table.
--  Input Parameters :
--        p_table_name     - Name of the table
--        p_column_name     - Name of the column.
--  Output Parameters
--        p_data_type      -  It returns the data type of the column.
--e.g number or date or varchar2.
--
--
-- ------------------------------------------------------------------------
procedure get_data_type
(
 p_table_name          in   varchar2,
 p_column_name         in   varchar2,
 p_data_type           out nocopy  varchar2
);

-- ------------------------- create_view ----------------------
-- Description: Creates a view based on the passed table, taking
-- into account PC hierarchy.
--
--
--  Input Parameters
--        p_view_name  - name of view to create
--
--        p_table_name - source table name
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

procedure create_view
(
  p_table_info             in   hr_dm_gen_main.t_table_info
);


-- ------------------------- create_stub_views ------------------------
-- Description: Creates dummy views for the hr_dmv type 'tables' to avoid
-- compilation errors during the generate phase, when the correct form of
-- the views will be created.
--
--
--  Input Parameters
--        p_migration_id - current migration
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

procedure create_stub_views(p_migration_id in number);


end hr_dm_library;

 

/
