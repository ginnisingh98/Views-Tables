--------------------------------------------------------
--  DDL for Package Body HR_DM_LIBRARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_LIBRARY" as
/* $Header: perdmlib.pkb 115.29 2004/03/24 08:28:56 mmudigon ship $ */
l_status    varchar2(50);
l_industry  varchar2(50);
l_per_owner     varchar2(30);
l_ben_owner     varchar2(30);
l_pay_owner     varchar2(30);
l_ff_owner     varchar2(30);
l_fnd_owner     varchar2(30);
l_apps_owner     varchar2(30);

l_ret1      boolean := FND_INSTALLATION.GET_APP_INFO ('PAY', l_status,
                                                      l_industry, l_pay_owner);
l_ret2      boolean := FND_INSTALLATION.GET_APP_INFO ('BEN', l_status,
                                                      l_industry, l_ben_owner);
l_ret3      boolean := FND_INSTALLATION.GET_APP_INFO ('FF', l_status,
                                                      l_industry, l_ff_owner);
l_ret4      boolean := FND_INSTALLATION.GET_APP_INFO ('FND', l_status,
                                                      l_industry, l_fnd_owner);
l_ret5      boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);
l_ret6      boolean := FND_INSTALLATION.GET_APP_INFO ('APPS', l_status,
                                                      l_industry, l_apps_owner);

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
) return varchar2 is
  l_spaces     varchar2(100);
begin

  -- if newline parameter is 'Y' then start the indentation from new line.
  if p_newline = 'Y' then
     l_spaces := c_newline || rpad(' ', p_indent_spaces);
  else
     l_spaces := rpad(' ', p_indent_spaces);
  end if;
  return l_spaces;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.indent',
                         '(p_indent_spaces - ' || p_indent_spaces ||
                         ')(p_newline - ' || p_newline || ')',
                         'R');
end indent;


-- ------------------------- get_generator_version ------------------------
-- Description:
-- It gets the version number of the Genrator by concatenating the arcs
-- version of Main Generator package, TUPS Generator package and TDS package.
-- It is used by the Main Generator to stamp the generator version for each
-- generated TUPS/TDS and by initialisation program to check whether given
-- TUPS/TDS had been compiled by the latest generator.
--  Input Parameters
--        p_format_output - Whether a formatted output is required or not.
--                        For updating the generator_version field no
--                        formatting is required. Output will be stored as
--                        a one large string.But for TUPs/TDS packages output
--                        string is properly indented.
--                          It can have two values :
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
)
is
  l_package_version       varchar2(1000);
  l_generator_version     hr_dm_tables.generator_version%type;

  -- ----------------------- indent -----------------------------------------
  -- Description:
  -- returns the 'n' blank spaces on a newline.used to indent the procedure
  -- statements.
  --
  -- ------------------------------------------------------------------------

  function priv_indent
  (
   p_indent_spaces  in number default 8
  ) return varchar2 is
    l_spaces     varchar2(100);
  begin
    l_spaces := c_newline || rpad(' ', p_indent_spaces) || '-  ' ;
    return l_spaces;
  exception
    when others then
       hr_dm_utility.error(SQLCODE,'hr_dm_library.priv_indent',
                           '(none)',
                           'R');
       raise;
  end priv_indent;

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_generator_version'
                        , 5);

  -- get the version of main generator
  get_package_version  ( p_package_name    => 'HR_DM_GEN_MAIN',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
    l_generator_version := priv_indent || l_package_version;
  else
    l_generator_version :=  l_package_version;
  end if;

  -- get the version of Library package
  get_package_version  ( p_package_name    => 'HR_DM_LIBRARY',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent || l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of TUPS generator
  get_package_version  ( p_package_name    => 'HR_DM_GEN_TUPS',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of package which seed TUPS/TDS into data pump.
  get_package_version  ( p_package_name    => 'HR_DM_SEED_DP',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of TDS generator
  get_package_version  ( p_package_name    => 'HR_DM_GEN_TDS',
                         p_package_version => l_package_version);

  if p_format_output = 'Y' then
   l_generator_version := l_generator_version || priv_indent ||
                          l_package_version;
  else
   l_generator_version := l_generator_version || ' :: ' || l_package_version;
  end if;

  -- get the version of package which gets  where clause for implicit
  -- business group.
  get_package_version  ( p_package_name    => 'HR_DM_IMP_BG_WHERE',
                         p_package_version => l_package_version);

  p_generator_version := l_generator_version;

  hr_dm_utility.message('PARA','(p_generator_version - ' ||
                         p_generator_version || ')', 30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_generator_version'
                       , 25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_generator_version',
                       '(p_generator_version - ' || p_generator_version ||
                       ')','R');
     raise;
end get_generator_version;
-- ------------------------- get_package_version ------------------------
-- Description:
-- It gets the version number for the given package. Depending upon the
-- version type required it either returns the full header string of the
-- package body or concatenate the File name and Version number of package
-- header and body of the package.
--  Input Parameters :
--     p_package_name   - Name of the stored package whose version number
--                          is required.
--     p_version_type   - It identifies what sort of output version string
--                        is required. It can have following values
--                       SUMMARY - concatenate the File name and Version
--                           number of package header and body of the package.
--                           the output version string will look as
--                            ' hrdmgen.pkh 115.1 : hrdmgen.pkb 115.1 '
--
--                       FULL    - Full header string from the package body
--                                 is returned.The output version string
--                                 will look as
--      /* $Header: perdmlib.pkb 115.29 2004/03/24 08:28:56 mmudigon ship $ */
--  Output Parameters
--      p_package_version -  It returns the text string created by the ARCS
-- for the package.
--
--
-- ------------------------------------------------------------------------
procedure get_package_version
(
 p_package_name         in   varchar2,
 p_package_version      out nocopy  varchar2,
 p_version_type         in   varchar2 default 'SUMMARY'
)
is
  --cursor to get the package version string
  cursor csr_get_package_version  is
  select pkh.text,
         pkb.text
  from  user_source pkh,
        user_source pkb
  where pkh.name  = upper(p_package_name)
  and   pkh.type  = 'PACKAGE'
  and   pkh.line = 2
  and   pkb.name  = upper(p_package_name)
  and   pkb.type  = 'PACKAGE BODY'
  and   pkb.line = 2;

  l_pkg_header_ver_text      varchar2(2000);
  l_pkg_body_ver_text        varchar2(2000);
  l_pkg_body_ver_text_det    varchar2(2000);

  -- this function extracts the file name and version from the version
  -- string.
  --  Input string :
  --     /* $Header: perdmlib.pkb 115.29 2004/03/24 08:28:56 mmudigon ship $ */
  --  Output return from function is 'perdmlib.pkb 115.5'

  function priv_get_version_from_string (p_version_string varchar2)
  return varchar2 is
  l_start_ptr      number := 0;
  l_end_ptr        number := 0;
  l_return_string  varchar2(100);
  begin
    l_start_ptr     := instr(p_version_string,'per');
    l_end_ptr       := instr(p_version_string,' ',1,4);
    l_return_string := substr(p_version_string,l_start_ptr ,
                              (l_end_ptr - l_start_ptr));
    return l_return_string;
  end  priv_get_version_from_string;

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_package_version', 5);
  hr_dm_utility.message('PARA','(p_package_name - ' || p_package_name ||
   ')', 10);

  open csr_get_package_version;
  fetch csr_get_package_version  into l_pkg_header_ver_text,
          l_pkg_body_ver_text;
  close csr_get_package_version;

  l_pkg_body_ver_text_det := l_pkg_body_ver_text;
  l_pkg_header_ver_text := priv_get_version_from_string(l_pkg_header_ver_text);
  l_pkg_body_ver_text   := priv_get_version_from_string(l_pkg_body_ver_text);

  if p_version_type ='FULL' then
    p_package_version := l_pkg_body_ver_text_det;
  else
    p_package_version := l_pkg_header_ver_text || ' : ' ||
                         l_pkg_body_ver_text;
  end if;

  hr_dm_utility.message('PARA','(p_package_version - ' ||
                         p_package_version || ')', 30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_package_version', 25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_package_version',
                       '(p_package_name - ' || p_package_name ||
                       ')','R');
     raise;
end get_package_version;
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
)
is
  e_fatal_error             exception;
  l_fatal_error_message     varchar2(200);
  l_apps_name               varchar2(30);

  cursor csr_apps_name is
    select ORACLE_USERNAME
    from fnd_oracle_userid
    where ORACLE_ID = 900;

  --cursor to get the data type of column
  cursor csr_get_data_type  is
  select lower(data_type) data_type
  from all_tab_columns
  where table_name = upper(p_table_name)
  and column_name = upper(p_column_name)
  and owner in
  (l_apps_name,
   l_fnd_owner,
   l_ff_owner,
   l_ben_owner,
   l_pay_owner,
   l_per_owner);

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_data_type', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
   ')(p_column_name - ' || p_column_name ||
   ')', 10);


  open csr_apps_name;
  fetch csr_apps_name into l_apps_name;
  close csr_apps_name;

  open csr_get_data_type;
  fetch csr_get_data_type into p_data_type;
  if csr_get_data_type%notfound then
     close csr_get_data_type;
     l_fatal_error_message := 'Could not find data type for (p_table_name - '
     || p_table_name || ')(p_column_name - ' || p_column_name
     || ')';
     raise e_fatal_error;
  end if;
  close csr_get_data_type;

  hr_dm_utility.message('PARA','(p_data_type - ' ||
     p_data_type || ')', 30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_data_type', 25);

exception
when e_fatal_error then
  if csr_get_data_type%isopen then
    close csr_get_data_type;
  end if;
  hr_dm_utility.error(SQLCODE,'hr_dm_library.get_data_type',
                       l_fatal_error_message,'R');

  raise;
when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_data_type',
                       '(p_table_name - ' || p_table_name ||
                       ')(p_column_name - ' || p_column_name ||
                       ')','R');
     raise;
end get_data_type;
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
)
is

--cursor to get the table_info
cursor csr_get_table is
select tbl.table_id
      ,lower(tbl.table_name)  table_name
      ,tbl.datetrack
      ,decode (tbl.surrogate_pk_column_name,NULL,'N',
                                                 'Y') surrogate_primary_key
      ,lower(tbl.surrogate_pk_column_name) surrogate_pk_column_name
      ,lower(tbl.table_alias) table_alias
      ,lower(tbl.short_name) short_name
      ,lower(who_link_alias) who_link_alias
      ,derive_sql_download_full
      ,derive_sql_download_add
      ,derive_sql_calc_ranges
      ,derive_sql_delete_source
      ,derive_sql_source_tables
      ,upper(tbl.global_data) global_data
      ,sequence_name
from  hr_dm_tables tbl
where tbl.table_id = p_table_id;

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_table_info', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_id ||
   ')', 10);
  for csr_get_table_rec in csr_get_table loop
    --
    -- store the information of the table properties into pl/sql record
    --
    p_table_info.table_id                 := csr_get_table_rec.table_id;
    p_table_info.table_name               := csr_get_table_rec.table_name;
    p_table_info.datetrack                := csr_get_table_rec.datetrack;
    p_table_info.surrogate_primary_key    :=
                                     csr_get_table_rec.surrogate_primary_key;
    p_table_info.surrogate_pk_column_name :=
                                  csr_get_table_rec.surrogate_pk_column_name;
    p_table_info.alias                    := csr_get_table_rec.table_alias;
    p_table_info.short_name               := csr_get_table_rec.short_name;
    p_table_info.who_link_alias          := csr_get_table_rec.who_link_alias;
    p_table_info.derive_sql_download_full :=
                                  csr_get_table_rec.derive_sql_download_full;
    p_table_info.derive_sql_download_add :=
                                   csr_get_table_rec.derive_sql_download_add;
    p_table_info.derive_sql_calc_ranges :=
                                    csr_get_table_rec.derive_sql_calc_ranges;
    p_table_info.derive_sql_delete_source :=
                                  csr_get_table_rec.derive_sql_delete_source;
    p_table_info.derive_sql_source_tables :=
                                  csr_get_table_rec.derive_sql_source_tables;
    p_table_info.global_data := csr_get_table_rec.global_data;
    p_table_info.sequence_name := csr_get_table_rec.sequence_name;

  end loop;
  hr_dm_utility.message('INFO',
                        'HR_DM_LIBARARY - get information about tables',
                         15);

  hr_dm_utility.message('PARA','(p_table_info.table_name - ' ||
                         p_table_info.table_name || ')', 30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_table_info', 25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_table_info','(none)'
                         ,'R');
     raise;
end get_table_info;
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
-----------------------------------------------------------------------------
procedure check_col_for_fk_on_aol
(
 p_fk_to_aol_columns_tbl    in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_column_name              in   varchar2,
 p_index                    out nocopy  number
) is
l_index    number := p_fk_to_aol_columns_tbl.first;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.check_col_for_fk_on_aol'
                        , 5);
  hr_dm_utility.message('PARA','(p_column_name - ' || p_column_name || ')'
                        ,10);
  p_index := null;

  if p_fk_to_aol_columns_tbl.exists(1) then
    l_index := p_fk_to_aol_columns_tbl.first;
  else
    l_index := null;
  end if;
  while l_index is not null loop
    if upper(p_fk_to_aol_columns_tbl(l_index).column_name) = upper(p_column_name) then
       p_index := l_index;
       exit;
    end if;
    l_index := p_fk_to_aol_columns_tbl.next(l_index);
  end loop;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - checks whether ' ||
                         'column has FK on AOL table',15);
 -- hr_dm_utility.message('SUMM','HR_DM_LIBARARY - checks whether ' ||
 --                        'column has FK on AOL table',20);
  hr_dm_utility.message('PARA','(p_index - ' || l_index || ')', 30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.check_col_for_fk_on_aol',
                         25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.check_col_for_fk_on_aol',
                         '(none)','R');
     raise;
end check_col_for_fk_on_aol;
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
) is

  cursor csr_get_fk_to_aol_cols is
  select lower(hir.column_name)           column_name,
         hir.parent_table_id              parent_table_id,
         lower(hir.parent_column_name)    parent_column_name,
         lower(hir.parent_id_column_name) parent_id_column_name,
         lower(tbl.table_name)            parent_table_name,
         lower(tbl.table_alias)           parent_table_alias
  from  hr_dm_tables tbl,
        hr_dm_hierarchies hir
  where hir.hierarchy_type = p_hierarchy_type
  and   tbl.table_id = hir.parent_table_id
  and   hir.table_id = (
      select table_id
        from hr_dm_tables
        where table_name = (
            select nvl(upload_table_name, table_name)
              from hr_dm_tables
              where table_id = p_table_info.table_id));

  l_index  number := 1;
begin
  hr_dm_utility.message('ROUT',
                      'entry:hr_dm_library.populate_fk_to_aol_cols_info', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_info.table_id ||
 ')(p_table_name - ' || p_table_info.table_name ||
 ')', 10);
  for csr_get_fk_to_aol_cols_rec in csr_get_fk_to_aol_cols loop
    p_fk_to_aol_columns_tbl(l_index).column_name     :=
 csr_get_fk_to_aol_cols_rec.column_name;
    p_fk_to_aol_columns_tbl(l_index).parent_table_id :=
 csr_get_fk_to_aol_cols_rec.parent_table_id;
    p_fk_to_aol_columns_tbl(l_index).parent_column_name :=
 csr_get_fk_to_aol_cols_rec.parent_column_name;
    p_fk_to_aol_columns_tbl(l_index).parent_id_column_name :=
 csr_get_fk_to_aol_cols_rec.parent_id_column_name;
    p_fk_to_aol_columns_tbl(l_index).parent_table_name :=
 csr_get_fk_to_aol_cols_rec.parent_table_name;
    p_fk_to_aol_columns_tbl(l_index).parent_table_alias :=
 csr_get_fk_to_aol_cols_rec.parent_table_alias;
    l_index := l_index + 1;
  end loop;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - populate list with ' ||
                         'column who have FK on AOL table',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - populate list with ' ||
  --                       'column who have FK on AOL table',20);
  hr_dm_utility.message('PARA','(p_index - ' || l_index || ')', 30);
  hr_dm_utility.message('ROUT',
                        'exit:hr_dm_library.populate_fk_to_aol_cols_info',
                         25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,
                         'hr_dm_library.populate_fk_to_aol_cols_info',
                         '(none)','R');
     raise;
end populate_fk_to_aol_cols_info;

-- ------------------------- populate_columns_list ------------------------
-- Description:
-- It populates the PL/SQL table with the list of column. This is to avoid
-- database access getting the column list again.
-- e.g : Table T1 has column col1,col2then the out parameter list will be
-- populated as
-- p_columns_list  =  col1 | col2
-- p_parameter_list = p_col1  in number | p_col2 in varchar2
--
-- Input Parameters :
--        p_table_info   - pl/sql table contains info like table name and
--                         various properties of the table.
--        p_fk_to_aol_columns_tbl
--                       - pl/sql table which contains the information about
--                         columns which have foreign key to AOL table.
-- Output Parameters
--        p_columns_tbl  - Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of columns of the table.
--        p_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of column name used as a input arguments
--                          in the procedure.
--        p_aol_columns_tbl Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of columns of the table but the columns
--                          which have
--        p_aol_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It contains
--                          the list of column name used as a input arguments
--                          in the procedure.
-- ------------------------------------------------------------------------
procedure populate_columns_list
(
 p_table_info              in      hr_dm_gen_main.t_table_info,
 p_fk_to_aol_columns_tbl   in      hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_columns_tbl             out nocopy     t_varchar2_tbl,
 p_parameter_tbl           out nocopy     t_varchar2_tbl,
 p_aol_columns_tbl         out nocopy     t_varchar2_tbl,
 p_aol_parameter_tbl       out nocopy     t_varchar2_tbl,
 p_missing_who_info        out nocopy     varchar2
)
is

-- used for indexing of pl/sql table.
l_count             number;
l_index             number;
l_missing_who_info  varchar2(1);
l_apps_name         varchar2(30);

cursor csr_apps_name is
select ORACLE_USERNAME
from fnd_oracle_userid
where ORACLE_ID = 900;

-- cursor to get the column name and data type
cursor csr_get_columns is
select distinct lower(column_name) col_name,
       lower(data_type) data_type
from all_tab_columns
where table_name = upper(p_table_info.table_name)
  and column_name <> 'BATCH_ID'
  and data_type <> 'SDO_GEOMETRY'
  and owner in
  (l_apps_name,
   l_fnd_owner,
   l_ff_owner,
   l_ben_owner,
   l_pay_owner,
   l_per_owner);

begin

 hr_dm_utility.message('ROUT','entry:hr_dm_library.populate_columns_list'
                       ,5);
 hr_dm_utility.message('PARA','(p_table_id - ' || p_table_info.table_id ||
 ')(p_table_name - ' || p_table_info.table_name ||
 ')', 10);

 open csr_apps_name;
 fetch csr_apps_name into l_apps_name;
 close csr_apps_name;


 -- initialise the counter.
 l_count := 1;

 -- assume who info i.e last_update column is missing.
 p_missing_who_info := 'Y';
 --
 -- add the column and parameters to the list
 --
 for csr_get_columns_rec in csr_get_columns loop
   --
   -- if the column name is 'last_update_date' then it means that table
   -- contains who column info.
   --
   if csr_get_columns_rec.col_name = 'last_update_date' then
     p_missing_who_info := 'N';
   end if;

   p_columns_tbl(l_count)   := csr_get_columns_rec.col_name;

   p_parameter_tbl(l_count) := rpad('p_' || csr_get_columns_rec.col_name,30)
   || ' in ' ||  csr_get_columns_rec.data_type;

   --
   -- if the table has a foreign key on the aol table then prepare the
   -- column and parameter list wich will replace the id column which
   -- has a foreign key to the developer key name.
   -- e.g user_id column in per_sec_profile_assignments has a foreign key
   -- on AOL table fnd_user. In this list do not store the user_id column
   -- but store the developer key of fnd_user table corresponding to user_id
   -- which is user name in this case.
   --
   if p_table_info.fk_to_aol_table = 'Y' then

      check_col_for_fk_on_aol(p_fk_to_aol_columns_tbl,
                              csr_get_columns_rec.col_name,
                              l_index);
      --
      -- if l_index is null then it means that the column does not have
      -- foreign key on the aol table,other wise it passes the index of
      -- pl/sql table from which the information about aol table and
      -- developer key.
      --
      if l_index is null then
         p_aol_columns_tbl(l_count)   := csr_get_columns_rec.col_name;

         p_aol_parameter_tbl(l_count) :=
                                 rpad('p_' || csr_get_columns_rec.col_name
                                      ,30) || ' in ' ||
                                 csr_get_columns_rec.data_type;
      else
         p_aol_columns_tbl(l_count)   :=
                  p_fk_to_aol_columns_tbl(l_index).parent_column_name;

         p_aol_parameter_tbl(l_count) := rpad('p_' ||
             p_fk_to_aol_columns_tbl(l_index).parent_column_name,30)
             || ' in  varchar2';
      end if;
   end if;
   l_count := l_count + 1;
 end loop;
 l_missing_who_info := p_missing_who_info;
 hr_dm_utility.message('INFO','HR_DM_LIBARARY - populate list with ' ||
                         'all columns of table',15);
 --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - populate list with ' ||
 --                        'all columns of table',20);

 hr_dm_utility.message('PARA','(p_missing_who_info - ' || l_missing_who_info
                         || ')( p_columns_tbl - varchar2 record type )'
                         || ')( p_parameter_tbl - varchar2 record type )'
                         || ')( p_aol_columns_tbl - varchar2 record type )'
                         || ')( p_aol_parameter_tbl - varchar2 record type )'
                         ,30);
 hr_dm_utility.message('ROUT','exit:hr_dm_library.populate_columns_list',
                       25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.populate_columns_list',
                         '(none)','R');
     raise;
end populate_columns_list;

-- ------------------------- populate_pk_columns_list -----------------------
-- Description:
-- It populates the PL/SQL table with the list of primary key column. This is
-- to avoid database access getting the column list again.
-- e.g : Table T1 has primary key columns pk_col1,pk_col2 then the out
-- parameter list will be populated as
-- p_columns_list  =  pk_col1 | pk_col2
-- p_parameter_list = p_pk_col1  in number | p_pk_col2 in varchar2
--
-- Input Parameters :
--        p_table_info   - pl/sql table contains info like table name and
--                         various properties of the table.
-- Output Parameters
--        p_pk_columns_tbl  -  Out pl/sql table type t_varchar2_tbl. It
--                           contains the list ofprimary key columns of the
--                           table.
--        p_pk_parameter_tbl - Out pl/sql table type t_varchar2_tbl. It
--                           contains  the list of primary key column name
--                           used as a input arguments in the procedure.
--        p_no_of_pk_columns - Out number of primary key columns in the
--                            primary key.
-- ------------------------------------------------------------------------
procedure populate_pk_columns_list
(
 p_table_info              in   hr_dm_gen_main.t_table_info,
 p_pk_columns_tbl          out nocopy  t_varchar2_tbl,
 p_pk_parameter_tbl        out nocopy  t_varchar2_tbl,
 p_no_of_pk_columns        out nocopy  number
)
is

-- used for indexing of pl/sql table.
l_count       number;
l_index       number;
l_data_type               varchar2(30);
e_fatal_error             exception;
l_fatal_error_message     varchar2(200);
-- cursor to get the primary column name and data type
cursor csr_get_pk_columns is
select distinct lower(atc.column_name) col_name,
                lower(atc.data_type) data_type,
                acc.position
from all_tab_columns atc,
     all_cons_columns acc,
     all_constraints ac
where ac.table_name = upper(p_table_info.table_name)
and ac.constraint_type = 'P'
and ac.CONSTRAINT_NAME = acc.constraint_name
and ac.owner   = acc.owner
and atc.table_name = acc.table_name
and atc.column_name = acc.column_name
and atc.owner       = acc.owner
and ac.owner in
(l_apps_owner,
 l_fnd_owner,
 l_ff_owner,
 l_ben_owner,
 l_pay_owner,
 l_per_owner)
order by acc.position;

-- get the logical primary key stored in hr_dm_hierarchies table
-- with type 'P'

cursor csr_get_columns is
select lower(column_name) col_name
from hr_dm_hierarchies
where table_id = p_table_info.table_id
and   hierarchy_type = 'P';


begin
  hr_dm_utility.message('ROUT',
                        'entry:hr_dm_library.populate_pk_columns_list', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_info.table_id ||
                          ')(p_table_name - ' || p_table_info.table_name ||
                          ')', 10);


  --
  -- If the table has surrogate id then get the details of primary key from
  -- table info, otherwise, open the cursor to read the columns from the
  -- primary key constraint. Add the primary key column and parameters to
  -- the list.
  --
  if p_table_info.surrogate_primary_key = 'Y' then
     -- initialise the counter.
     l_count := 1;
     p_pk_columns_tbl(l_count)   :=  p_table_info.surrogate_pk_column_name;
     p_pk_parameter_tbl(l_count) := rpad('p_' ||
                    p_table_info.surrogate_pk_column_name,30)  || ' in ' ||
                    'number';
  elsif p_table_info.missing_primary_key = 'Y' then
     l_count := 0;
     --
     -- add the logical prinamry key column and parameters to the list
     --
     for csr_get_columns_rec in csr_get_columns loop
       l_count := l_count + 1;
       -- add logical primary key column to the list.
       p_pk_columns_tbl(l_count)   := csr_get_columns_rec.col_name;
       -- get the data type of the column
       get_data_type ( p_table_name   => p_table_info.table_name,
                       p_column_name  => csr_get_columns_rec.col_name,
                       p_data_type    => l_data_type);

       p_pk_parameter_tbl(l_count) :=
                            rpad('p_' || csr_get_columns_rec.col_name ,30)
                            || ' in  ' || l_data_type;
     end loop;
  else
    l_count := 0;
    -- non surrogate id. get primary key columns.
    for csr_get_pk_columns_rec in csr_get_pk_columns loop
      l_count := l_count + 1;
      p_pk_columns_tbl(l_count)   := csr_get_pk_columns_rec.col_name;
      p_pk_parameter_tbl(l_count) :=
                            rpad('p_' || csr_get_pk_columns_rec.col_name,30)
                            || ' in ' ||  csr_get_pk_columns_rec.data_type;
    end loop;

    -- no primary keys found
    if l_count = 0 then
       l_fatal_error_message := 'Could not find primary key for (' ||
               'p_table_name - ' || p_table_info.table_name || ').'  ||
               'Define the logical' || ' primary key in ' ||
               'HR_DM_HIERARCHIES table.';
       raise e_fatal_error;
    end if;
  end if;

  p_no_of_pk_columns := l_count;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - populate list with ' ||
                         'primary key columns of table',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - populate list with ' ||
  --                       'primary key columns of table',20);

  hr_dm_utility.message('PARA',
                            '(p_no_of_pk_columns - ' || p_no_of_pk_columns
                         || ')( p_pk_columns_tbl - varchar2 record type )'
                         || ')( p_pk_parameter_tbl - varchar2 record type )'
                         ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.populate_pk_columns_list',
                         25);

exception
  when e_fatal_error then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.populate_pk_columns_list',
                       l_fatal_error_message,'R');

     raise;
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.populate_pk_columns_list',
                         '(none)','R');
     raise;
end populate_pk_columns_list;


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
--                          contains the list of hierarchy columns and primary
--                          key columns used as a input arguments in the
--                          procedure.
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
)
is

-- get all parent tables required to get the business group id, if business
-- group id is not there in the table to be downloaded.

cursor csr_get_columns is
          select lower(column_name) col_name
          from hr_dm_hierarchies
          where table_id = p_table_info.table_id
          and   hierarchy_type = 'H';

-- cursor to get the primary column name and data type
cursor csr_get_pk_columns is
select distinct lower(atc.column_name) col_name,
                lower(atc.data_type) data_type,
                acc.position
from all_tab_columns atc,
     all_cons_columns acc,
     all_constraints ac
where ac.table_name = upper(p_table_info.table_name)
and ac.constraint_type = 'P'
and ac.CONSTRAINT_NAME = acc.constraint_name
and ac.owner   = acc.owner
and atc.table_name = acc.table_name
and atc.column_name = acc.column_name
and atc.owner       = acc.owner
and ac.owner in
(l_apps_owner,
 l_fnd_owner,
 l_ff_owner,
 l_ben_owner,
 l_pay_owner,
 l_per_owner)
order by acc.position;

-- used for indexing of pl/sql table.
l_count     number;


begin
  hr_dm_utility.message('ROUT',
                        'entry:hr_dm_library.populate_hierarchy_cols_list', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_info.table_id ||
 ')(p_table_name - ' || p_table_info.table_name ||
 ')(p_called_from -  ' || p_called_from ||
 ')', 10);
 -- initialise the counter.
 l_count := 1;
 --
 -- add the column and parameters to the list
 --
 for csr_get_columns_rec in csr_get_columns loop

   p_hier_columns_tbl(l_count)   := csr_get_columns_rec.col_name;

   p_hier_parameter_tbl(l_count) := rpad('p_' || csr_get_columns_rec.col_name
    ,30)  || ' in  number';
   l_count := l_count + 1;
 end loop;


 -- if the table has a surrogate key then add the surrogate column to the
 --list, otherwise, all the primary key columns for non surrogate id table.

 if p_table_info.surrogate_primary_key = 'Y' then

   -- add primary column to the hierarchy list only if it called from TDS.
   if p_called_from = 'TDS' then
     p_hier_columns_tbl(l_count)   := p_table_info.surrogate_pk_column_name;
   end if;
   p_hier_parameter_tbl(l_count) := rpad('p_' ||
   p_table_info.surrogate_pk_column_name ,30)  || ' in  number';
 else
   for csr_get_pk_columns_rec in csr_get_pk_columns loop
     -- add primary columns to the hierarchy list only if it called from TDS.
     if p_called_from = 'TDS' then
       p_hier_columns_tbl(l_count)   := csr_get_pk_columns_rec.col_name;
     end if;

     p_hier_parameter_tbl(l_count) := rpad('p_' ||
      csr_get_pk_columns_rec.col_name ,30)  || ' in  ' ||
      csr_get_pk_columns_rec.data_type;
     l_count := l_count + 1;
   end loop;
 end if;

  hr_dm_utility.message('INFO','HR_DM_LIBARARY - populate list with ' ||
                         'all columns who have FK on same table table',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - populate list with ' ||
  --                       'all columns who have FK on same table table',20);

  hr_dm_utility.message('PARA','( p_hier_columns_tbl - varchar2 record type )'
                         || ')( p_hier_parameter_tbl - varchar2 record type )'
                         ,30);
  hr_dm_utility.message('ROUT',
                        'exit:hr_dm_library.populate_hierarchy_cols_list',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.populate_hierarchy_cols_list',
                         '(none)','R');
     raise;
end populate_hierarchy_cols_list;

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
 p_cols_wo_pk_cols_tbl    out nocopy  hr_dm_library.t_varchar2_tbl
) is

  l_index   number := p_columns_tbl.first;
  l_count   number := 1;
  --
  -- private function to check whether a given element exists in the list.
  -- This checks whether a given column exists in the primary key column list.
  --

  function private_is_pk_column ( p_column_name   in   varchar2)
                                                          return varchar2 is
  l_index   number := p_pk_columns_tbl.first;
  l_return  varchar2(1) := 'N';
  begin
    while l_index is not null loop
      if p_pk_columns_tbl(l_index) = p_column_name then
         l_return := 'Y';
         exit;
      end if;
      l_index := p_pk_columns_tbl.next(l_index);
    end loop;
    return l_return;
  exception
    when others then
      hr_dm_utility.error(SQLCODE,'hr_dm_library.private_is_pk_column',
                         '( p_column_name = ' || p_column_name || ')','R');
      raise;
  end;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_cols_list_wo_pk_cols'
                        , 5);

  while l_index is not null loop

    -- if the column read is not primary key column then add the
    -- column to out list.

    if private_is_pk_column (p_columns_tbl(l_index)) = 'N' then
      p_cols_wo_pk_cols_tbl(l_count) := p_columns_tbl(l_index);
      l_count := l_count + 1;
    end if;
    l_index := p_columns_tbl.next(l_index);
  end loop;

  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_cols_list_wo_pk_cols',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_cols_list_wo_pk_cols',
                         '(none)','R');
     raise;
end get_cols_list_wo_pk_cols;
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
return varchar2 is

l_out_text     varchar2(20000);
l_list_index   number;
l_count        number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.conv_list_to_text', 5);
  hr_dm_utility.message('PARA','(p_rpad_spaces   - ' || p_rpad_spaces  ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_prefix_col    - ' ||  p_prefix_col ||
 ')(p_col_length  - ' || p_col_length  ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator ||
 ')(p_columns_tbl - varchar2 record type)' , 10);

 -- initialise the variables
 l_list_index := p_columns_tbl.first;
 l_count      := 1;
 --
 -- read all the elements of pl/sql table and append them into text.
 --
 while l_list_index is not null loop
   --
   -- seperate the elements by comma and move it to next line. Put comma
   -- only after first element.
   --
   if l_count = 1 then
    -- if p_pad_first_line = 'Y' then insert space in the first line,otherwise
    -- don't pad the first element.
    if p_pad_first_line = 'Y' then
      --l_out_text := rpad(' ', p_rpad_spaces + 1) || p_prefix_col ||
      l_out_text := rpad(' ', p_rpad_spaces) || p_prefix_col ||
                    rtrim(rpad(p_columns_tbl(l_list_index), p_col_length)) ||
                    p_end_terminator;
    else
      l_out_text := p_prefix_col || rtrim(rpad(p_columns_tbl(l_list_index),
                          p_col_length)) ||
                    p_end_terminator;
    end if;
   else
      l_out_text := l_out_text || c_newline || rpad(' ', p_rpad_spaces) ||
                    p_start_terminator || p_prefix_col ||
                    rtrim(rpad(p_columns_tbl(l_list_index),
           p_col_length)) ||
                    p_end_terminator;
   end if;
   l_list_index := p_columns_tbl.next(l_list_index);
   l_count := l_count + 1;
 end loop;
 l_out_text := rtrim(l_out_text);
 hr_dm_utility.message('INFO','HR_DM_LIBARARY - convert list elements ' ||
                         'into formatted text',15);
 --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - convert list elements ' ||
 --                        'into formatted text',20);

  hr_dm_utility.message('PARA','(l_out_text - formatted text)' ,30);

  hr_dm_utility.message('ROUT','exit:hr_dm_library.conv_list_to_text',
                       25);

 return l_out_text;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.conv_list_to_text',
                         '(none)','R');
     raise;
end conv_list_to_text ;

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
return varchar2 is

l_out_text     varchar2(20000);
l_list_index   number;
l_count        number;
l_prefix       varchar2(30);
l_exc_index    number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.conv_list_to_text', 5);
  hr_dm_utility.message('PARA','(p_rpad_spaces   - ' || p_rpad_spaces  ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_prefix_col    - ' ||  p_prefix_col ||
 ')(p_col_length  - ' || p_col_length  ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator ||
 ')(p_columns_tbl - varchar2 record type' ||
 ')(p_overide_tbl - varchar2 record type' ||
 ')(p_overide_prefix - ' || p_overide_prefix || ')'  , 10);


-- show entries
 l_list_index := p_columns_tbl.first;
 while l_list_index is not null loop
   hr_dm_utility.message('INFO','col_tbl - ' || p_columns_tbl(l_list_index),1);
   l_list_index := p_columns_tbl.next(l_list_index);
 end loop;
 l_exc_index  := p_overide_tbl.first;
 while l_exc_index is not null loop
   hr_dm_utility.message('INFO','exc_tbl - ' || p_overide_tbl(l_exc_index).column_name,1);
   l_exc_index := p_overide_tbl.next(l_exc_index);
 end loop;

 -- initialise the variables
 l_list_index := p_columns_tbl.first;
 l_count      := 1;
 --
 -- read all the elements of pl/sql table and append them into text.
 --
 while l_list_index is not null loop
   --
   -- assume prefix is the default one
   l_prefix := p_prefix_col;
   -- reset exc index
   --
   l_exc_index  := p_overide_tbl.first;
   --
   -- Check if this column is in the exception list
   --
   while l_exc_index is not null loop
     if p_overide_tbl(l_exc_index).column_name = p_columns_tbl(l_list_index) then
       hr_dm_utility.message('INFO',p_columns_tbl(l_list_index) || ' - ' ||
                             p_overide_tbl(l_exc_index).column_name,1);
       l_prefix := p_overide_prefix;
     end if;
     l_exc_index := p_overide_tbl.next(l_exc_index);
   end loop;
   --
   --
   -- seperate the elements by comma and move it to next line. Put comma
   -- only after first element.
   --
   if l_count = 1 then
    -- if p_pad_first_line = 'Y' then insert space in the first line,otherwise
    -- don't pad the first element.
    if p_pad_first_line = 'Y' then
      l_out_text := rpad(' ', p_rpad_spaces) || l_prefix ||
                    rtrim(rpad(p_columns_tbl(l_list_index), p_col_length)) ||
                    p_end_terminator;
    else
      l_out_text := l_prefix || rtrim(rpad(p_columns_tbl(l_list_index),
                          p_col_length)) ||
                    p_end_terminator;
    end if;
   else
      l_out_text := l_out_text || c_newline || rpad(' ', p_rpad_spaces) ||
                    p_start_terminator || l_prefix ||
                    rtrim(rpad(p_columns_tbl(l_list_index), p_col_length)) ||
                    p_end_terminator;
   end if;
   l_list_index := p_columns_tbl.next(l_list_index);
   l_count := l_count + 1;
 end loop;
 l_out_text := rtrim(l_out_text);
 hr_dm_utility.message('INFO','HR_DM_LIBARARY - convert list elements ' ||
                         'into formatted text',15);
 --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - convert list elements ' ||
 --                        'into formatted text',20);

  hr_dm_utility.message('PARA','(l_out_text - formatted text)' ,30);

  hr_dm_utility.message('ROUT','exit:hr_dm_library.conv_list_to_text',
                       25);

 return l_out_text;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.conv_list_to_text',
                         '(none)','R');
     raise;
end conv_list_to_text ;


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
--  The string to be used for the nvl testing
-- ------------------------------------------------------------------------
procedure get_nvl_arguement
(
 p_test_with_nvl           in   varchar2,
 p_table_name              in   varchar2,
 p_column_name             in   varchar2,
 p_nvl_prefix              out nocopy  varchar2,
 p_nvl_suffix              out nocopy  varchar2
) is

l_data_type varchar2(2000);
l_apps_name varchar2(30);
l_nullable  varchar2(1);

cursor csr_apps_name is
select ORACLE_USERNAME
from fnd_oracle_userid
where ORACLE_ID = 900;

cursor csr_data_type is
  select data_type,
         nullable
    from all_tab_columns
    where table_name = upper(p_table_name)
      and column_name = upper(p_column_name)
      and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner);

begin

hr_dm_utility.message('ROUT','entry:hr_dm_library.get_nvl_arguement', 5);
hr_dm_utility.message('PARA','(p_test_with_nvl - ' || p_test_with_nvl ||
  ')(p_table_name - ' || p_table_name ||
  ')(p_column_name - ' ||  p_column_name ||
  ')', 10);

open csr_apps_name;
fetch csr_apps_name into l_apps_name;
close csr_apps_name;

open csr_data_type;
fetch csr_data_type into l_data_type, l_nullable;
close csr_data_type;

-- do we want to add NVL handling?
if (p_test_with_nvl = 'N' or l_nullable = 'N') then
  p_nvl_prefix := '';
  p_nvl_suffix := '';
else
-- set default values
  p_nvl_prefix := 'NVL(';
  p_nvl_suffix := ',''<HRDM null value>'')';
-- test number - one unlikely to be in the database
  if (l_data_type = 'NUMBER') then
    p_nvl_suffix := ',-9924926578)';
  end if;
-- test date - hr_general.start_of_time
  if (l_data_type = 'DATE') then
    p_nvl_prefix := 'NVL(to_char(';
    p_nvl_suffix := ',''YYYY/MM/DD''),''<HRDM null value>'')';
  end if;


end if;

hr_dm_utility.message('INFO','HR_DM_LIBARARY - found nvl arguement',15);
--hr_dm_utility.message('SUMM','HR_DM_LIBARARY - found nvl arguement',20);

hr_dm_utility.message('PARA','(p_nvl_prefix - ' || p_nvl_prefix || ')' ,30);
hr_dm_utility.message('PARA','(p_nvl_suffix - ' || p_nvl_suffix || ')' ,30);
hr_dm_utility.message('ROUT','exit:hr_dm_library.get_nvl_arguement', 25);


exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_nvl_arguement',
                         'Check seed data in Hierarchies / Tables','R');
     raise;

end get_nvl_arguement;


-- ------------------------- get_func_asg ---------------------------
-- Description:
-- It reads the list columns and returns the parameters list required for
-- inserting the data into data pump batch_lines table or any other TUPS
-- function
-- e.g p_col1 => p_col2,
--     p_col2 => p_col2...
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
--                          'Y' - puts the comma before the first element
--                                parameter assignment.
--                          'N' - does not put comma before the first element
--                                parameter assignment.
--    p_equality_sign        - By default the equality sign of the parameter
--                             assignment is ' => '. But it can be '=' for
--                             update statement set column assignment.
--    p_pad_first_line   -  It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--    p_left_asg_pad_len  -  It means the length of the left hand parameter
--                           after prefix. e.g p_prefix_left is 'p_' and
--                           column name is 'responsibility_application_id',
--                           if the length is 30 the left hand parameter will
--                           be 'p_responsibility_application_i'.
--    p_right_asg_pad_len    same as above but applied to right hand side
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
return varchar2 is

l_out_text     varchar2(32767) := null;
l_list_index   number;
l_nvl_left1     varchar2(100);
l_nvl_left2     varchar2(100);
l_nvl_right     varchar2(100);
l_nvl_indent    varchar2(30);

begin
 hr_dm_utility.message('ROUT','entry:hr_dm_library.get_func_asg', 5);
 hr_dm_utility.message('PARA','( p_rpad_spaces - ' ||  p_rpad_spaces ||
  ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
  ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
 ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns' ||
 ')(p_test_with_nvl - ' || p_test_with_nvl || ')', 10);

 -- initialise the variables
 l_list_index := p_columns_tbl.first;

 -- if first line has to be padded then add spaces
 if p_pad_first_line = 'Y' then
   l_out_text :=  rpad(' ', p_rpad_spaces);
 end if;

 -- if comma should not be put in the first element
 if p_comma_on_first_line = 'Y' then
   l_out_text :=  l_out_text || ',';
 else
   l_out_text :=  l_out_text || ' ';
 end if;

 --
 -- if the first column is business group and omit business group flag is
 -- 'Y' then we do not want to include business group column hence get the
 -- next item.
 --
 if (upper(p_columns_tbl(l_list_index)) = 'BUSINESS_GROUP_ID'  and
      p_omit_business_group_id = 'Y')
 then
   l_list_index := p_columns_tbl.next(l_list_index);
 end if;

 l_nvl_left1  := '';
 -- do we want to add NVL handling?
 if (p_test_with_nvl = 'N') then
   l_nvl_indent := '';
 else
   l_nvl_indent := indent(12);
 end if;

 get_nvl_arguement(p_test_with_nvl,
                   p_table_name,
                   p_columns_tbl(l_list_index),
                   l_nvl_left2,
                   l_nvl_right);

 l_out_text := l_out_text ||
   rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
   p_columns_tbl(l_list_index) || l_nvl_right,p_left_asg_pad_len) ||
   l_nvl_indent ||
   p_equality_sign || rtrim(rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_right_asg ||
   p_columns_tbl(l_list_index) || l_nvl_right ,p_right_asg_pad_len))
   || p_end_terminator;


 l_list_index := p_columns_tbl.next(l_list_index);


 --
 -- read all the elements of pl/sql table and append them into text.
 --
 while l_list_index is not null loop
   --
   -- seperate the elements by comma and move it to next line.Do not assign
   -- Business_Group_Id column as data pump knows the value of
   -- business_group_id if the parameter p_omit_business_group_id value is 'Y'
   --
   get_nvl_arguement(p_test_with_nvl,
                     p_table_name,
                     p_columns_tbl(l_list_index),
                     l_nvl_left2,
                     l_nvl_right);


   if (upper(p_columns_tbl(l_list_index)) <> 'BUSINESS_GROUP_ID'  or
      p_omit_business_group_id = 'N')
   then
      l_out_text := l_out_text || c_newline || rpad(' ', p_rpad_spaces) ||
       p_start_terminator ||
       rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
       p_columns_tbl(l_list_index) || l_nvl_right,
       p_left_asg_pad_len) || l_nvl_indent || p_equality_sign ||
       rtrim(rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_right_asg ||
       p_columns_tbl(l_list_index) || l_nvl_right,p_right_asg_pad_len)) ||
       p_end_terminator;
   end if;
   l_list_index := p_columns_tbl.next(l_list_index);
 end loop;

 l_out_text := rtrim(l_out_text);
 hr_dm_utility.message('INFO','HR_DM_LIBARARY - convert list elements ' ||
                         'into formatted text for call to procedure and  ' ||
                         ' named convention used for parameters ',15);
 --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - convert list elements ' ||
 --                       'into formatted text for call to procedure and  ' ||
 --                       ' named convention used for parameters ',20);

 hr_dm_utility.message('PARA','(l_out_text - formatted text for funtion ' ||
                         'assignment )' ,30);
 hr_dm_utility.message('ROUT','exit:hr_dm_library.get_func_asg',
                         25);
 return l_out_text;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_func_asg',
                         '( p_rpad_spaces - ' ||  p_rpad_spaces ||
  ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
  ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
 ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns)','R');
     raise;
end get_func_asg;

-- ------------------------- get_func_asg ---------------------------
-- Description:
-- It reads the list columns and returns the parameters list required for
-- inserting the data into data pump batch_lines table or any other TUPS
-- function
-- e.g p_col1 => p_col2,
--     p_col2 => p_col2...
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
--                          'Y' - puts the comma before the first element
--                                parameter assignment.
--                          'N' - does not put comma before the first element
--                                parameter assignment.
--    p_equality_sign        - By default the equality sign of the parameter
--                             assignment is ' => '. But it can be '=' for
--                             update statement set column assignment.
--    p_pad_first_line   -  It means whether the spaces should be added to
--                           the first element or not.
--                           'Y' - spaces are added to the first element
--                           'N' - spaces are not added to the first element
--    p_left_asg_pad_len  -  It means the length of the left hand parameter
--                           after prefix. e.g p_prefix_left is 'p_' and
--                           column name is 'responsibility_application_id',
--                           if the length is 30 the left hand parameter will
--                           be 'p_responsibility_application_i'.
--    p_right_asg_pad_len    same as above but applied to right hand side
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
--    p_test_with_nvl        This is a flag used with the creation of the
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
 p_resolve_pk_columns_tbl   in   hr_dm_gen_main.t_fk_to_aol_columns_tbl,
 p_test_with_nvl           in   varchar2 default 'N',
 p_table_name              in   varchar2 default null
)
return varchar2 is

l_out_text     varchar2(32767) := null;
l_list_index   number;
l_index        number;
l_nvl_left1    varchar2(100);
l_nvl_left2    varchar2(100);
l_nvl_right    varchar2(100);
l_nvl_indent   varchar2(30);

begin
 hr_dm_utility.message('ROUT','entry:hr_dm_library.get_func_asg', 5);
 hr_dm_utility.message('PARA','( p_rpad_spaces - ' ||  p_rpad_spaces ||
  ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
  ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
 ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns' ||
 ')(p_test_with_nvl - ' || p_test_with_nvl || ')', 10);

 -- initialise the variables
 l_list_index := p_columns_tbl.first;

 -- if first line has to be padded then add spaces
 if p_pad_first_line = 'Y' then
   l_out_text :=  rpad(' ', p_rpad_spaces);
 end if;

 -- if comma should not be put in the first element
 if p_comma_on_first_line = 'Y' then
   l_out_text :=  l_out_text || ',';
 else
   l_out_text :=  l_out_text || ' ';
 end if;

 --
 -- if the first column is business group and omit business group flag is
 -- 'Y' then we do not want to include business group column hence get the
 -- next item.
 --
 if (upper(p_columns_tbl(l_list_index)) = 'BUSINESS_GROUP_ID'  and
      p_omit_business_group_id = 'Y')
 then
   l_list_index := p_columns_tbl.next(l_list_index);
 end if;

 -- check whether this column has a lookup id columns
 check_col_for_fk_on_aol(p_resolve_pk_columns_tbl,
                         p_columns_tbl(l_list_index),
                         l_index);


 -- do we want to add NVL handling?
 l_nvl_left1  := '';
 if (p_test_with_nvl = 'N') then
   l_nvl_indent  := '';
 else
   l_nvl_indent  := indent(12);
 end if;

 get_nvl_arguement(p_test_with_nvl,
                   p_table_name,
                   p_columns_tbl(l_list_index),
                   l_nvl_left2,
                   l_nvl_right);

 if l_index is not null then
   l_out_text := l_out_text ||
    rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
    p_columns_tbl(l_list_index) || l_nvl_right,p_left_asg_pad_len)
    || l_nvl_indent || p_equality_sign || rtrim(rpad(l_nvl_left1 ||
    l_nvl_left2 || 'l_' ||
    p_columns_tbl(l_list_index) || l_nvl_right,p_right_asg_pad_len)) ||
    p_end_terminator;
 else
   l_out_text := l_out_text ||
    rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
    p_columns_tbl(l_list_index) || l_nvl_right,p_left_asg_pad_len)
    || l_nvl_indent || p_equality_sign || rtrim(rpad(l_nvl_left1 ||
    l_nvl_left2 || p_prefix_right_asg ||
    p_columns_tbl(l_list_index) || l_nvl_right,p_right_asg_pad_len)) ||
    p_end_terminator;
 end if;


 l_list_index := p_columns_tbl.next(l_list_index);


 --
 -- read all the elements of pl/sql table and append them into text.
 --
 while l_list_index is not null loop
   --
   -- seperate the elements by comma and move it to next line.Do not assign
   -- Business_Group_Id column as data pump knows the value of
   -- business_group_id if the parameter p_omit_business_group_id value is 'Y'
   --
    get_nvl_arguement(p_test_with_nvl,
                      p_table_name,
                      p_columns_tbl(l_list_index),
                      l_nvl_left2,
                      l_nvl_right);

   if (upper(p_columns_tbl(l_list_index)) <> 'BUSINESS_GROUP_ID'  or
      p_omit_business_group_id = 'N')
   then
     -- check whether this column has a lookup id columns
     check_col_for_fk_on_aol(p_resolve_pk_columns_tbl,
                         p_columns_tbl(l_list_index),
                         l_index);

     if l_index is not null then
       l_out_text := l_out_text ||c_newline || rpad(' ', p_rpad_spaces) ||
        p_start_terminator ||
        rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
        p_columns_tbl(l_list_index) || l_nvl_right,
        p_left_asg_pad_len) || l_nvl_indent || p_equality_sign ||
        rtrim(l_nvl_left1 || l_nvl_left2 || rpad('l_' ||
        p_columns_tbl(l_list_index),p_right_asg_pad_len)) ||
        p_end_terminator;
     else
       l_out_text := l_out_text ||c_newline || rpad(' ', p_rpad_spaces) ||
        p_start_terminator ||
        rpad(l_nvl_left1 || l_nvl_left2 || p_prefix_left_asg ||
        p_columns_tbl(l_list_index) || l_nvl_right,
        p_left_asg_pad_len) || l_nvl_indent || p_equality_sign ||
        rtrim(l_nvl_left1 || l_nvl_left2 || rpad(p_prefix_right_asg ||
        p_columns_tbl(l_list_index),p_right_asg_pad_len)) ||
        p_end_terminator;
     end if;

   end if;
   l_list_index := p_columns_tbl.next(l_list_index);
 end loop;

 l_out_text := rtrim(l_out_text);
 hr_dm_utility.message('INFO','HR_DM_LIBARARY - convert list elements ' ||
                         'into formatted text for call to procedure and  ' ||
                         ' named convention used for parameters ',15);
 --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - convert list elements ' ||
 --                       'into formatted text for call to procedure and  ' ||
 --                       ' named convention used for parameters ',20);

 hr_dm_utility.message('PARA','(l_out_text - formatted text for funtion ' ||
                         'assignment )' ,30);
 hr_dm_utility.message('ROUT','exit:hr_dm_library.get_func_asg',
                         25);
 return l_out_text;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_func_asg',
                         '( p_rpad_spaces - ' ||  p_rpad_spaces ||
  ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
  ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
 ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_start_terminator - ' || p_start_terminator ||
 ')(p_end_terminator - ' || p_end_terminator||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns)','R');
     raise;
end get_func_asg;

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
--                           Thay are lookup columns whose value is derived
--                           from the destination database.
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
return varchar2 is

l_out_text        varchar2(20000) := null;
l_list_index      number;
l_left_parameter  varchar2(100);
l_right_parameter varchar2(100);
l_index           number;
begin
 hr_dm_utility.message('ROUT','entry:hr_dm_library.get_func_asg_with_dev_key', 5);
 hr_dm_utility.message('PARA','( p_rpad_spaces - ' ||  p_rpad_spaces ||
                       ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
                       ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
                       ')(p_prefix_left_asg_dev_key  - ' || p_prefix_left_asg_dev_key  ||
                       ')( p_prefix_right_asg_dev_key - ' ||  p_prefix_right_asg_dev_key ||
                       ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_use_aol_id_col - ' || p_use_aol_id_col ||
 ')(p_fk_to_aol_columns_tbl  - varchar2 record type contains ' ||
 'list of columns who have foreign key on AOL table.)' ||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns)', 10);
 -- initialise the variables
 l_list_index := p_columns_tbl.first;

 -- if first line has to be padded then add spaces
 if p_pad_first_line = 'Y' then
   --l_out_text :=  rpad(' ', p_rpad_spaces + 1);
   l_out_text :=  rpad(' ', p_rpad_spaces);
 end if;

 -- if comma should not be put in the first element
 if p_comma_on_first_line = 'Y' then
   l_out_text :=  l_out_text || ',';
 else
   l_out_text :=  l_out_text || ' ';
 end if;

 --
 -- if the first column is business group and omit business group flag is
 -- 'Y' then we do not want to include business group column hence get the
 -- next item.
 --
 if (upper(p_columns_tbl(l_list_index)) = 'BUSINESS_GROUP_ID'  and
      p_omit_business_group_id = 'Y')
 then
   l_list_index := p_columns_tbl.next(l_list_index);
 end if;

 -- check whether this column has a foreign key on aol table
 check_col_for_fk_on_aol(p_fk_to_aol_columns_tbl,
                         p_columns_tbl(l_list_index),
                         l_index);
 --
 -- if l_index is null then it means that the column does not have foreign
 -- key on the aol table,other wise it passes the index of pl/sql table
 -- from which the information about aol table and developer key.
 --
 if l_index is not null then
    if p_use_aol_id_col = 'N' then
      l_left_parameter  := rpad(p_prefix_left_asg_dev_key ||
       p_fk_to_aol_columns_tbl(l_index).parent_column_name,p_left_asg_pad_len);
      l_right_parameter  := rpad(p_prefix_right_asg_dev_key ||
       p_fk_to_aol_columns_tbl(l_index).parent_column_name,p_right_asg_pad_len);
    else
      l_left_parameter  := rpad(p_prefix_left_asg_dev_key ||
      p_fk_to_aol_columns_tbl(l_index).column_name,p_left_asg_pad_len);
      l_right_parameter  := rpad(p_prefix_right_asg_dev_key ||
      p_fk_to_aol_columns_tbl(l_index).column_name,p_right_asg_pad_len);
    end if;
 else
    -- check whether this column has a lookup id columns
    check_col_for_fk_on_aol(p_resolve_pk_columns_tbl,
                            p_columns_tbl(l_list_index),
                            l_index);

    if l_index is not null then
      l_left_parameter  := rpad('p_' ||
       p_resolve_pk_columns_tbl(l_index).column_name,p_left_asg_pad_len);
      l_right_parameter  := rpad('l_' ||
       p_resolve_pk_columns_tbl(l_index).column_name,p_right_asg_pad_len);
    else
      l_left_parameter  := rpad(p_prefix_left_asg ||
       p_columns_tbl(l_list_index),p_left_asg_pad_len);
      l_right_parameter  := rpad(p_prefix_right_asg ||
        p_columns_tbl(l_list_index),p_right_asg_pad_len);
    end if;
 end if;

 -- if comma should not be put in the first element then add the first element
 -- here only.

 l_out_text := l_out_text || l_left_parameter || p_equality_sign ||
               l_right_parameter;

 l_list_index := p_columns_tbl.next(l_list_index);

 --
 -- read all the elements of pl/sql table and append them into text.
 --
 while l_list_index is not null loop
   --
   -- seperate the elements by comma and move it to next line.Do not assign
   -- Business_Group_Id column as data pump knows the value of
   -- business_group_id if the parameter p_omit_business_group_id value is 'Y'
   --
   if (upper(p_columns_tbl(l_list_index)) <> 'BUSINESS_GROUP_ID'  or
      p_omit_business_group_id = 'N')
   then

     -- check whether this column has a foreign key on aol table
     check_col_for_fk_on_aol(p_fk_to_aol_columns_tbl,
                             p_columns_tbl(l_list_index),
                             l_index);
     --
     -- if l_index is null then it means that the column does not have foreign
     -- key on the aol table,other wise it passes the index of pl/sql table
     -- from which the information about aol table and developer key.
     --
     if l_index is not null then
       if p_use_aol_id_col = 'N' then
         l_left_parameter  := rpad(p_prefix_left_asg_dev_key ||
         p_fk_to_aol_columns_tbl(l_index).parent_column_name,p_left_asg_pad_len);
         l_right_parameter  := rpad(p_prefix_right_asg_dev_key ||
         p_fk_to_aol_columns_tbl(l_index).parent_column_name,p_right_asg_pad_len);
      else
        l_left_parameter  := rpad(p_prefix_left_asg_dev_key ||
         p_fk_to_aol_columns_tbl(l_index).column_name,
         p_left_asg_pad_len);
        l_right_parameter  := rpad(p_prefix_right_asg_dev_key ||
         p_fk_to_aol_columns_tbl(l_index).column_name,
         p_right_asg_pad_len);
      end if;
    else
      -- check whether this column has a lookup id columns
      check_col_for_fk_on_aol(p_resolve_pk_columns_tbl,
                              p_columns_tbl(l_list_index),
                              l_index);

      if l_index is not null then
        l_left_parameter  := rpad('p_' ||
         p_resolve_pk_columns_tbl(l_index).column_name,p_left_asg_pad_len);
        l_right_parameter  := rpad('l_' ||
         p_resolve_pk_columns_tbl(l_index).column_name,p_right_asg_pad_len);
      else
        l_left_parameter  := rpad(p_prefix_left_asg ||
         p_columns_tbl(l_list_index),p_left_asg_pad_len);
        l_right_parameter  := rpad(p_prefix_right_asg ||
          p_columns_tbl(l_list_index),p_right_asg_pad_len);
      end if;
    end if;


    l_out_text := l_out_text || c_newline || rpad(' ', p_rpad_spaces) || ',' ||
                   l_left_parameter || p_equality_sign ||
                   l_right_parameter;
   end if;
   l_list_index := p_columns_tbl.next(l_list_index);
 end loop;
 l_out_text := rtrim(l_out_text);

 hr_dm_utility.message('INFO','HR_DM_LIBARARY - convert list columns with  ' ||
                      'fk to aol table into formatted text for call to  ' ||
                     'procedure and  named convention used for parameters ',15);

 hr_dm_utility.message('PARA','(l_out_text - out nocopy formatted text for function' ||
                         'assignment )' ,30);
 hr_dm_utility.message('ROUT','exit:hr_dm_library.get_func_asg_with_dev_key',
                         25);
 return l_out_text;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_func_asg_with_dev_key',
                         '( p_rpad_spaces - ' ||  p_rpad_spaces ||
                       ')(p_prefix_left_asg  - ' || p_prefix_left_asg  ||
                       ')( p_prefix_right_asg - ' ||  p_prefix_right_asg ||
                       ')(p_prefix_left_asg_dev_key  - ' || p_prefix_left_asg_dev_key  ||
                       ')( p_prefix_right_asg_dev_key - ' ||  p_prefix_right_asg_dev_key ||
                       ')(p_omit_business_group_id - ' || p_omit_business_group_id ||
 ')(p_comma_on_first_line - ' || p_comma_on_first_line ||
 ')(p_equality_sign - ' || p_equality_sign ||
 ')(p_pad_first_line - ' || p_pad_first_line ||
 ')(p_left_asg_pad_len - ' || p_left_asg_pad_len ||
 ')(p_right_asg_pad_len - ' || p_right_asg_pad_len ||
 ')(p_use_aol_id_col - ' || p_use_aol_id_col ||
 ')(p_fk_to_aol_columns_tbl  - varchar2 record type contains ' ||
 'list of columns who have foreign key on AOL table.)' ||
 ')(p_columns_tbl - varchar2 record type contains ' ||
 'list of columns)','R');
     raise;
end get_func_asg_with_dev_key;

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
) is
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.ins_resolve_pks ', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
 ')(p_source_id  - ' || p_source_id  ||
 ')(p_destination_id - ' ||  p_destination_id ||
 ')', 10);

  if (p_table_name is null) then
    l_fatal_error_message := 'Null table name passed to ins_resolve_pks procedure';
    raise e_fatal_error;
  end if;

--hr_data_pump.message('source db is - ' ||
--                     NVL(hr_dm_upload.g_data_migrator_source_db, '<null>'));



  if p_source_id <> p_destination_id then

-- insert row if no matching row is already present

    insert into hr_dm_resolve_pks
    ( resolve_pk_id,
      source_database_instance,
      table_name,
      source_id,
      destination_id
      )
   select
      hr_dm_resolve_pks_s.nextval,
      hr_dm_upload.g_data_migrator_source_db,
      p_table_name,
      p_source_id,
      p_destination_id
   from dual
   where not exists (select null
                     from hr_dm_resolve_pks
                     where source_database_instance =
                                    hr_dm_upload.g_data_migrator_source_db
                       and table_name = p_table_name
                       and source_id = p_source_id);

-- see if a row has been inserted
-- if not, then a row already exists, so we must update it
    if sql%rowcount = 0 then
      update hr_dm_resolve_pks
        set destination_id = p_destination_id
        where source_database_instance =
                                    hr_dm_upload.g_data_migrator_source_db
          and table_name = p_table_name
          and source_id = p_source_id;
    end if;

  end if;

  hr_dm_utility.message('INFO','HR_DM_LIBARARY - insert row into ' ||
                         'hr_dm_resolve_pks table ',15);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.ins_resolve_pks',
                         25);
exception
when e_fatal_error then
  hr_dm_utility.error(SQLCODE,'hr_dm_library.ins_resolve_pks',
                      l_fatal_error_message,'R');
  raise;

  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.ins_resolve_pks',
                         '(none)','R');
     raise;
end ins_resolve_pks;

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
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination

  cursor csr_find_destination_pk is
  select destination_id
  from hr_dm_resolve_pks
  where table_name  = upper(p_table_name)
  and   source_id   = p_source_id
  and source_database_instance = hr_dm_upload.g_data_migrator_source_db;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.get_resolved_pk', 5);
  hr_dm_utility.message('PARA','(p_source_id - ' || p_source_id ||
 ')(p_table_name - ' || p_table_name ||
 ')', 10);

  open csr_find_destination_pk;
  fetch csr_find_destination_pk into p_destination_id ;
  if csr_find_destination_pk%notfound then
    p_destination_id := p_source_id;
  end if;
  close csr_find_destination_pk;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in get_resolved_pk for a given id of a table ',15);

  hr_dm_utility.message('PARA','(p_destination_id - ' || p_destination_id
                         || ')' ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.get_resolved_pk',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.get_resolved_pk',
                         '(none)','R');
     raise;
end get_resolved_pk;
-- ------------------------ ins_dt_delete ---------------------------------
-- Description:
-- Insert a row into hr_dm_deletes table. It will be used by TUPS. If the
-- already exists for date tracked row on uploading it will store the
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
) is
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.ins_dt_delete ', 5);
  hr_dm_utility.message('PARA','(p_id - ' || p_id ||
 ')(p_table_name - ' || p_table_name ||
 ')(p_ins_type - ' || p_ins_type ||
 ')(p_pk_column_1 - ' || p_pk_column_1 ||
 ')(p_pk_column_2 - ' || p_pk_column_2 ||
 ')(p_pk_column_3 - ' || p_pk_column_3 ||
 ')(p_pk_column_4- ' ||  p_pk_column_4 ||
 ')', 10);

  insert into hr_dm_dt_deletes ( dt_delete_id
    ,table_name
    ,data_type
    ,id_value
    ,pk_column_1
    ,pk_column_2
    ,pk_column_3
    ,pk_column_4
    )
 values   ( hr_dm_dt_deletes_s.nextval
    ,p_table_name
    ,p_ins_type
    ,p_id
    ,p_pk_column_1
    ,p_pk_column_2
    ,p_pk_column_3
    ,p_pk_column_4);

  hr_dm_utility.message('INFO','HR_DM_LIBARARY - insert row into ' ||
                         'hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - - insert row into ' ||
  --                       'hr_dm_dt_deletes table ',20);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.ins_dt_delete',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.ins_dt_delete',
                         '(none)','R');
     raise;
end ins_dt_delete;

-- ------------------------ chk_row_in_dt_delete ------------------------------
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
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination
  cursor csr_find_dt_deletes is
  select data_type
  from hr_dm_dt_deletes
  where id_value    = p_id
  and   table_name  = p_table_name
  order by data_type;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.chk_row_in_dt_delete', 5);
  hr_dm_utility.message('PARA','(p_id - ' || p_id ||
 ')(p_table_name - ' || p_table_name ||
 ')', 10);

  open csr_find_dt_deletes;
  fetch csr_find_dt_deletes into l_data_type ;
  if csr_find_dt_deletes%found then
    p_row_exists := 'Y';
    p_ins_type   := l_data_type;
    close csr_find_dt_deletes;
  else
    p_row_exists := 'N';
    p_ins_type   := null;
    close csr_find_dt_deletes;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check whether row exists ' ||
  --                       'in hr_dm_dt_deletes table ',20);

  hr_dm_utility.message('PARA','(p_ins_type - ' || p_ins_type
                         || ')( p_row_exists - ' ||p_row_exists ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.chk_row_in_dt_delete',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.chk_row_in_dt_delete',
                         '(none)','R');
     raise;
end chk_row_in_dt_delete;

-- ------------------------ chk_row_in_dt_delete_1_pkcol ------------------------------
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
-- ------------------------------------------------------------------------
procedure chk_row_in_dt_delete_1_pkcol
( p_pk_column_1 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination
  cursor csr_find_dt_deletes is
  select data_type
  from hr_dm_dt_deletes
  where pk_column_1 = p_pk_column_1
  and   table_name  = p_table_name
  order by data_type;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.chk_row_in_dt_delete_1_pkcol', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
 ')(p_pk_column_1 - ' || p_pk_column_1 ||
 ')', 10);

  open csr_find_dt_deletes;
  fetch csr_find_dt_deletes into l_data_type ;
  if csr_find_dt_deletes%found then
    p_row_exists := 'Y';
    p_ins_type   := l_data_type;
    close csr_find_dt_deletes;
  else
    p_row_exists := 'N';
    p_ins_type   := null;
    close csr_find_dt_deletes;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check whether row exists ' ||
  --                       'in hr_dm_dt_deletes table ',20);

  hr_dm_utility.message('PARA','(p_ins_type - ' || p_ins_type
                         || ')( p_row_exists - ' ||p_row_exists ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.chk_row_in_dt_delete_1_pkcol',
                         25);
 exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.chk_row_in_dt_delete_1_pkcol',
                         '(none)','R');
     raise;
end chk_row_in_dt_delete_1_pkcol;
-- ------------------------ chk_row_in_dt_delete_2_pkcol ------------------------------
-- Description: This function is used by Date Track table with non surrogate id.
--              The primary key consists of two columns
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
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination
  cursor csr_find_dt_deletes is
  select data_type
  from hr_dm_dt_deletes
  where pk_column_1 = p_pk_column_1
  and   pk_column_2 = p_pk_column_2
  and   table_name  = p_table_name
  order by data_type;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.chk_row_in_dt_delete_2_pkcol', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
 ')(p_pk_column_1 - ' || p_pk_column_1 ||
 ')(p_pk_column_2 - ' || p_pk_column_2 ||
 ')', 10);
  open csr_find_dt_deletes;
  fetch csr_find_dt_deletes into l_data_type ;
  if csr_find_dt_deletes%found then
    p_row_exists := 'Y';
    p_ins_type   := l_data_type;
    close csr_find_dt_deletes;
  else
    p_row_exists := 'N';
    p_ins_type   := null;
    close csr_find_dt_deletes;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check whether row exists ' ||
  --                       'in hr_dm_dt_deletes table ',20);

  hr_dm_utility.message('PARA','(p_ins_type - ' || p_ins_type
                         || ')( p_row_exists - ' ||p_row_exists ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.chk_row_in_dt_delete_2_pkcol',
                         25);
 exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.chk_row_in_dt_delete_2_pkcol',
                         '(none)','R');
     raise;
end chk_row_in_dt_delete_2_pkcol;

-- ------------------------ chk_row_in_dt_delete_3_pkcol -----------------------
-- Description: This function is used by Date Track table with non surrogate id.
--              The primary key consists of three columns
-- Checks whether a row exists for a given primary key columns of the table and
-- type.
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
-- ------------------------------------------------------------------------------
procedure chk_row_in_dt_delete_3_pkcol
( p_pk_column_1 in     number,
  p_pk_column_2 in     number,
  p_pk_column_3 in     number,
  p_table_name  in     varchar2,
  p_ins_type    out nocopy    varchar2,
  p_row_exists  out nocopy    varchar2
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination
  cursor csr_find_dt_deletes is
  select data_type
  from hr_dm_dt_deletes
  where pk_column_1 = p_pk_column_1
  and   pk_column_2 = p_pk_column_2
  and   pk_column_3 = p_pk_column_3
  and   table_name  = p_table_name
  order by data_type;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.chk_row_in_dt_delete_3_pkcol', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
 ')(p_pk_column_1 - ' || p_pk_column_1 ||
 ')(p_pk_column_2 - ' || p_pk_column_2 ||
 ')(p_pk_column_3 - ' || p_pk_column_3 ||
 ')', 10);
  open csr_find_dt_deletes;
  fetch csr_find_dt_deletes into l_data_type ;
  if csr_find_dt_deletes%found then
    p_row_exists := 'Y';
    p_ins_type   := l_data_type;
    close csr_find_dt_deletes;
  else
    p_row_exists := 'N';
    p_ins_type   := null;
    close csr_find_dt_deletes;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check whether row exists ' ||
  --                       'in hr_dm_dt_deletes table ',20);

  hr_dm_utility.message('PARA','(p_ins_type - ' || p_ins_type
                         || ')( p_row_exists - ' ||p_row_exists ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.chk_row_in_dt_delete_3_pkcol',
                         25);
 exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.chk_row_in_dt_delete_3_pkcol',
                         '(none)','R');
     raise;
end chk_row_in_dt_delete_3_pkcol;

-- ------------------------ chk_row_in_dt_delete_4_pkcol ------------------------------
-- Description: This function is used by Date Track table with non surrogate id.
--              The primary key consists of four columns
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
) is

  l_data_type      hr_dm_dt_deletes.data_type%type;
  --
  -- cursor to find the row in hr_dm_dt_deletes table for a given id, table and
  -- type combination
  cursor csr_find_dt_deletes is
  select data_type
  from hr_dm_dt_deletes
  where pk_column_1 = p_pk_column_1
  and   pk_column_2 = p_pk_column_2
  and   pk_column_3 = p_pk_column_3
  and   pk_column_4 = p_pk_column_4
  and   table_name  = p_table_name
  order by data_type;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.chk_row_in_dt_delete_4_pkcol', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
 ')(p_pk_column_1 - ' || p_pk_column_1 ||
 ')(p_pk_column_2 - ' || p_pk_column_2 ||
 ')(p_pk_column_3 - ' || p_pk_column_3 ||
 ')(p_pk_column_4 - ' || p_pk_column_4 ||
 ')', 10);
  open csr_find_dt_deletes;
  fetch csr_find_dt_deletes into l_data_type ;
  if csr_find_dt_deletes%found then
    p_row_exists := 'Y';
    p_ins_type   := l_data_type;
    close csr_find_dt_deletes;
  else
    p_row_exists := 'N';
    p_ins_type   := null;
    close csr_find_dt_deletes;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check whether row exists ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check whether row exists ' ||
  --                       'in hr_dm_dt_deletes table ',20);

  hr_dm_utility.message('PARA','(p_ins_type - ' || p_ins_type
                         || ')( p_row_exists - ' ||p_row_exists ,30);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.chk_row_in_dt_delete_4_pkcol',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.chk_row_in_dt_delete_4_pkcol',
                         '(none)','R');
     raise;
end chk_row_in_dt_delete_4_pkcol;
-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed. The SQL command is passed to this procedure as a atrring of
-- varchar2.
--
-- ------------------------------------------------------------------------
procedure run_sql( p_sql in varchar2 )
is
  l_csr_sql integer;
  l_rows    number;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.run_sql', 5);
  hr_dm_utility.message('PARA','(p_sql - varchar2)', 10);
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, p_sql, dbms_sql.native );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - run SQL command - 1',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - run SQL command - 1',20);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.run_sql',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.run_sql',
                         '(none)','R');
     raise;
end run_sql;
-- ------------------------ run_sql ---------------------------------------
-- Description:
-- Runs a SQL statement using the dbms_sql package. No bind variables
-- allowed. This procedure uses pl/sql table of varchar2 as an input
-- and hence is suitable to compile very large packages i.e more than
-- 32767 char.
-- ------------------------------------------------------------------------
procedure run_sql(p_package_body    dbms_sql.varchar2s,
                  p_package_index   number )
is
  l_csr_sql integer;
  l_rows    number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.run_sql', 5);
  hr_dm_utility.message('PARA','(p_package_index - ' || p_package_index ||
  ')' || '(p_package_index - dbms_sql.varchar2s)'
  , 10);
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, p_package_body,1,p_package_index,FALSE, dbms_sql.v7 );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - run SQL command - 2',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - run SQL command - 2',20);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.run_sql',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.run_sql - dbms_sql.varchar2s',
                         '(none)','R');
     raise;
end run_sql;

-- ------------------------ check_compile ---------------------------------
-- Description:
-- Checks whether or not the generated package or view compiled okay.
-- ------------------------------------------------------------------------
procedure check_compile
(
  p_object_name in varchar2,
  p_object_type in varchar2
)
is
  e_invalid_package exception;
  cursor csr_check_compile
  (
    p_object_name in varchar2,
    p_object_type in varchar2
  ) is
  select status
  from   user_objects
  where  upper(object_name) = upper(p_object_name)
  and    upper(object_type) = upper(p_object_type);
  l_status varchar2(64);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_library.check_compile', 5);
  hr_dm_utility.message('PARA','(p_object_name - ' || p_object_name ||
 ')(p_object_type - ' || p_object_type ||
 ')', 10);

  open csr_check_compile( p_object_name, p_object_type );
  fetch csr_check_compile into l_status;
  close csr_check_compile;
  if upper( l_status ) <> 'VALID' then
    raise e_invalid_package;
  end if;
  hr_dm_utility.message('INFO','HR_DM_LIBARARY - check status of the package ' ||
                         'in hr_dm_dt_deletes table ',15);
  --hr_dm_utility.message('SUMM','HR_DM_LIBARARY - check status of the package ' ||
  --                       'in hr_dm_dt_deletes table ',20);
  hr_dm_utility.message('ROUT','exit:hr_dm_library.check_compile',
                         25);

exception
  when e_invalid_package then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.check_compile',
                         'Invalid Status For Package ' || p_object_name ,'R');
     raise;
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_library.check_compile',
                         '(none)','R');
     raise;
end check_compile;




-- ------------------------- create_view ----------------------
-- Description: Creates a view based on the passed table but excluding
-- the business group id (if this column is defined for a table).
--
-- For tables like HR_DMVP%, do not modify the existing view created
-- by the create_stub_views procedure.
--
--
--  Input Parameters
--        p_table_info - table_info
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
procedure create_view (p_table_info in hr_dm_gen_main.t_table_info) is
--

l_string varchar2(32767);
l_columns1 varchar2(32767);
l_columns2 varchar2(32767);
l_column_name varchar2(30);
l_first varchar2(1);
l_value boolean;
l_out_status varchar2(30);
l_out_industry varchar2(30);
l_out_oracle_schema varchar2(30);
l_cr varchar2(10);
l_where varchar2(1);
l_owner varchar2(30);
l_cursor_select_from varchar2(32767);
l_cursor_select_where varchar2(32767);
l_nonnull_table_id number;
l_parent_table_info hr_dm_gen_main.t_table_info;
l_apps_name varchar2(30);

cursor csr_apps_name is
select ORACLE_USERNAME
from fnd_oracle_userid
where ORACLE_ID = 900;

cursor csr_columns is
  select column_name
  from all_tab_columns
  where table_name = upper(p_table_info.upload_table_name)
    and column_name not in ('BUSINESS_GROUP_ID','BATCH_ID')
    and data_type <> 'SDO_GEOMETRY'
    and not (table_name = 'FF_FORMULAS_F' and column_name = 'FORMULA_TEXT')
    and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner)
  order by column_id;

cursor csr_sp_columns is
  select column_name
  from all_tab_columns
  where table_name = upper(p_table_info.upload_table_name)
    and data_type <> 'SDO_GEOMETRY'
    and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner)
  order by column_id;

cursor csr_nonnull_id is
  select table_id
  from hr_dm_tables
  where table_name = upper(p_table_info.upload_table_name);

cursor csr_get_table is
  select distinct parent_table_id
  from  (select table_id,parent_table_id
          from hr_dm_hierarchies
          where hierarchy_type = 'PC')
          start with table_id = l_nonnull_table_id
          connect by prior parent_table_id = table_id;

--
begin
--

hr_dm_utility.message('ROUT','entry:hr_dm_library.create_view', 5);
hr_dm_utility.message('PARA','(p_table_info - record)', 10);

open csr_apps_name;
fetch csr_apps_name into l_apps_name;
close csr_apps_name;


-- check for HR_DMVP% views
-- only process for non-HR_DMVP% views
if substr(p_table_info.table_name, 1,7) <> 'hr_dmvp'  then

-- find out what chr(10) is
  l_cr := fnd_global.local_chr(10);

-- build up column list
  l_first := 'Y';
  hr_dm_utility.message('INFO','creating columns for ' ||
                        p_table_info.table_name,10);
  if p_table_info.table_name <> 'hr_dmvs_hr_locations_all' then
    open csr_columns;
    loop
      fetch csr_columns into l_column_name;
      exit when csr_columns%notfound;
      if (l_first <> 'Y') then
        l_columns1 := l_columns1 || ', ' || l_column_name || l_cr;

        l_columns2 := l_columns2 || ', ' || p_table_info.alias || '.' ||
                     l_column_name || l_cr;
      else
        l_columns1 := '  ' || l_column_name || l_cr;
        l_columns2 := '  ' || p_table_info.alias || '.' || l_column_name || l_cr;
        l_first := 'N';
      end if;
    end loop;
    close csr_columns;
  else
    open csr_sp_columns;
    loop
      fetch csr_sp_columns into l_column_name;
      exit when csr_sp_columns%notfound;
      if (l_first <> 'Y') then
        l_columns1 := l_columns1 || ', ' || l_column_name || l_cr;

        l_columns2 := l_columns2 || ', ' || p_table_info.alias || '.' ||
                     l_column_name || l_cr;
      else
        l_columns1 := '  ' || l_column_name || l_cr;
        l_columns2 := '  ' || p_table_info.alias || '.' || l_column_name || l_cr;
        l_first := 'N';
      end if;
    end loop;
    close csr_sp_columns;
  end if;

-- get from clause

  l_cursor_select_from := p_table_info.upload_table_name ||
                          '  ' || p_table_info.alias;

-- find the table_id for the non-null version of the table
  open csr_nonnull_id;
  fetch csr_nonnull_id into l_nonnull_table_id;
  close csr_nonnull_id;

  hr_dm_utility.message('INFO','table is ' || upper(p_table_info.upload_table_name), 15);
  hr_dm_utility.message('INFO','Parent id is ' || l_nonnull_table_id, 15);

-- if the table to be downloaded has table hierarchy i.e business group id
-- has to be derived from table hierarchy i.e parent tables.
  if p_table_info.table_name <> 'hr_dmvs_hr_locations_all' then
    if p_table_info.table_hierarchy = 'Y' then
      for cst_get_table_rec in csr_get_table loop
-- get the parent table name
        hr_dm_library.get_table_info (cst_get_table_rec.parent_table_id,
                                      l_parent_table_info);
        l_cursor_select_from := l_cursor_select_from || '    ' || ',' ||
            l_parent_table_info.table_name ||'  ' || l_parent_table_info.alias || l_cr;
     end loop;
    end if;

-- get where clause
-- if business_group_id column on table then...
    if p_table_info.table_hierarchy = 'N' then
      l_cursor_select_where := 'where ' ||p_table_info.alias || '.' ||
                               'business_group_id is null';
    else
      hr_dm_imp_bg_where.main (p_table_info   => p_table_info,
                               p_cursor_type  => 'VIEW',
                               p_query_type   => 'MAIN_QUERY',
                               p_where_clause => l_cursor_select_where);
    end if;
  end if;


-- build up command
  l_string := 'create or replace force view ' ||
              upper(p_table_info.table_name) || ' (' || l_cr ||
              l_columns1 || ')' || l_cr ||
              'as select '  || l_cr ||
              l_columns2 ||
              'from ' || l_cursor_select_from || l_cr ||
              l_cursor_select_where;



  hr_dm_utility.message('INFO','View created using ' || l_cr || l_string, 15);

-- find the applsys username
  l_value := fnd_installation.get_app_info ('FND', l_out_status,
                                            l_out_industry,
                                            l_out_oracle_schema);

  ad_ddl.do_ddl(l_out_oracle_schema, 'PER', ad_ddl.create_view,
                  l_string, upper(p_table_info.table_name));

end if;

hr_dm_utility.message('INFO','View created - ' ||
                      upper(p_table_info.table_name), 15);
hr_dm_utility.message('SUMM','View created - ' ||
                      upper(p_table_info.table_name), 20);
hr_dm_utility.message('ROUT','exit:hr_dm_library.create_view', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
exception
when others then
  hr_dm_utility.error(sqlcode,'hr_dm_library.create_view','(none)','R');
  raise;

--
end create_view;
--


-- ------------------------- seed_view_who -------------------------------
-- Description: Seeds AOL hierarchy info for the WHO columns for the
-- views created.
--
--  Input Parameters
--        <none>
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
procedure seed_view_who is
--

cursor csr_table is
  select distinct dm.table_name,
                  dm.table_id
  from hr_dm_tables dm,
       all_tab_columns tc
  where dm.table_name not like 'FND%'
    and dm.table_name like 'HR_DMV%'
    and dm.table_name = tc.table_name
    and tc.column_name = 'CREATED_BY'
    and tc.owner in
      (l_apps_owner,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner);

l_table_name varchar2(30);
l_table_id number;
l_created_table varchar2(30);
l_updated_table varchar2(30);

--
begin
--

hr_dm_utility.message('ROUT','entry:hr_dm_library.seed_view_who', 5);


open csr_table;
loop
  fetch csr_table into l_table_name, l_table_id;
  exit when csr_table%notfound;

-- get parent table ids

  select table_id
  into l_created_table
  from hr_dm_tables
  where table_name = 'HR_DM_FND_USERS_V1';

  select table_id
  into l_updated_table
  from hr_dm_tables
  where table_name = 'HR_DM_FND_USERS_V2';

-- do inserts, if no data already exists

  insert into hr_dm_hierarchies
             ( hierarchy_id
              ,hierarchy_type
              ,sql_order
              ,table_id
              ,column_name
              ,parent_table_id
              ,parent_column_name
              ,parent_id_column_name)
       select  hr_dm_hierarchies_s.nextval
              ,'A'
              ,NULL
              ,l_table_id
              ,'CREATED_BY'
              ,l_created_table
              ,'CREATED_NAME'
              ,'USER_NAME_ID'
       from  dual
       where not exists (select 'x'
                         from hr_dm_hierarchies hir
                         where hir.hierarchy_type = 'A'
                         and hir.table_id = l_table_id
                         and nvl(hir.column_name,'X') = 'CREATED_BY'
                         and nvl(hir.parent_table_id,-99) = l_created_table
                         and nvl(hir.parent_column_name,'X') = 'CREATED_NAME'
                         and nvl(hir.parent_id_column_name,'X') =
                                                               'USER_NAME_ID'
                        );

  insert into hr_dm_hierarchies
             ( hierarchy_id
              ,hierarchy_type
              ,sql_order
              ,table_id
              ,column_name
              ,parent_table_id
              ,parent_column_name
              ,parent_id_column_name)
       select  hr_dm_hierarchies_s.nextval
              ,'A'
              ,NULL
              ,l_table_id
              ,'LAST_UPDATED_BY'
              ,l_updated_table
              ,'UPDATED_NAME'
              ,'USER_NAME_ID'
       from  dual
       where not exists (select 'x'
                         from hr_dm_hierarchies hir
                         where hir.hierarchy_type = 'A'
                         and hir.table_id = l_table_id
                         and nvl(hir.column_name,'X') = 'LAST_UPDATED_BY'
                         and nvl(hir.parent_table_id,-99) = l_updated_table
                         and nvl(hir.parent_column_name,'X') = 'UPDATED_NAME'
                         and nvl(hir.parent_id_column_name,'X') =
                                                               'USER_NAME_ID'
                        );

end loop;
close csr_table;


-- commit data
commit;

hr_dm_utility.message('INFO','Created seed AOL hierarchy info', 15);
hr_dm_utility.message('SUMM','Created seed AOL hierarchy info', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_library.seed_view_who', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
exception
when others then
  hr_dm_utility.error(sqlcode,'hr_dm_library.seed_view_who',
                      'error seed AOL hierarchy info','r');
  raise;

--
end seed_view_who;
--

-- ------------------------- seed_view_null -------------------------------
-- Description: Seeds AOL hierarchy info for the WHO columns for the
-- views created.
--
--  Input Parameters
--        <none>
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
procedure seed_view_null is
--

cursor csr_table is
  select distinct dm.table_name,
                  dm.table_id
  from hr_dm_tables dm,
       all_tab_columns tc1,
       all_tab_columns tc2
  where dm.table_name not like 'FND%'
    and dm.table_name like 'HR_DMV%'
    and dm.table_name = tc1.table_name
    and dm.table_name = tc2.table_name
    and tc1.column_name = 'REQUEST_ID'
    and tc2.column_name = 'PROGRAM_APPLICATION_ID'
    and tc2.owner = tc1.owner
    and tc1.owner in
      (l_apps_owner,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner);

l_table_name varchar2(30);
l_table_id number;

--
begin
--

hr_dm_utility.message('ROUT','entry:hr_dm_library.seed_view_null', 5);


open csr_table;
loop
  fetch csr_table into l_table_name, l_table_id;
  exit when csr_table%notfound;

-- do inserts, if no data already exists

  insert into hr_dm_hierarchies
             ( hierarchy_id
              ,hierarchy_type
              ,sql_order
              ,table_id
              ,column_name
              ,parent_table_id
              ,parent_column_name
              ,parent_id_column_name)
       select  hr_dm_hierarchies_s.nextval
              ,'N'
              ,NULL
              ,l_table_id
              ,'REQUEST_ID'
              ,NULL
              ,NULL
              ,NULL
       from  dual
       where not exists (select 'x'
                         from hr_dm_hierarchies hir
                         where hir.hierarchy_type = 'N'
                         and hir.table_id = l_table_id
                         and nvl(hir.column_name,'X') = 'REQUEST_ID'
                        );

  insert into hr_dm_hierarchies
             ( hierarchy_id
              ,hierarchy_type
              ,sql_order
              ,table_id
              ,column_name
              ,parent_table_id
              ,parent_column_name
              ,parent_id_column_name)
       select  hr_dm_hierarchies_s.nextval
              ,'N'
              ,NULL
              ,l_table_id
              ,'PROGRAM_APPLICATION_ID'
              ,NULL
              ,NULL
              ,NULL
       from  dual
       where not exists (select 'x'
                         from hr_dm_hierarchies hir
                         where hir.hierarchy_type = 'N'
                         and hir.table_id = l_table_id
                         and nvl(hir.column_name,'X') =
                                          'PROGRAM_APPLICATION_ID'
                        );

end loop;
close csr_table;


-- commit data
commit;

hr_dm_utility.message('INFO','Created seed null hierarchy info', 15);
hr_dm_utility.message('SUMM','Created seed null hierarchy info', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_library.seed_view_null', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
exception
when others then
  hr_dm_utility.error(sqlcode,'hr_dm_library.seed_view_null',
                      'error seed null hierarchy info','r');
  raise;

--
end seed_view_null;
--


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


--
procedure create_stub_views(p_migration_id in number) is
--

l_view_name varchar2(30);
l_table_name varchar2(30);
l_string varchar2(32767);
l_value boolean;
l_out_status varchar2(30);
l_out_industry varchar2(30);
l_out_oracle_schema varchar2(30);
l_cr varchar2(10);
l_columns varchar2(32767);
l_column_name varchar2(30);
l_first varchar2(1);
l_apps_name varchar2(30);

cursor csr_apps_name is
select ORACLE_USERNAME
from fnd_oracle_userid
where ORACLE_ID = 900;

cursor csr_view is
  select dmt.table_name,
         dmt.upload_table_name
  from hr_dm_tables dmt,
       hr_dm_phase_items pi,
       hr_dm_phases p
  where p.phase_name = 'G'
    and pi.phase_id = p.phase_id
    and pi.table_name = dmt.table_name
    and pi.status <> 'C'
    and dmt.table_name like 'HR_DMV%'
    and p.migration_id = p_migration_id;

cursor csr_columns is
  select column_name
  from all_tab_columns
  where table_name = l_table_name
    and column_name not in ('BUSINESS_GROUP_ID','BATCH_ID')
    and data_type <> 'SDO_GEOMETRY'
    and not (table_name = 'FF_FORMULAS_F' and column_name = 'FORMULA_TEXT')
    and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner)
  order by column_id;

cursor csr_sp_columns is
  select column_name
  from all_tab_columns
  where table_name = l_table_name
    and data_type <> 'SDO_GEOMETRY'
    and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner)
  order by column_id;

cursor csr_sp2_columns is
  select column_name
  from all_tab_columns
  where table_name = l_table_name
    and column_name <> 'BATCH_ID'
    and owner in
      (l_apps_name,
       l_fnd_owner,
       l_ff_owner,
       l_ben_owner,
       l_pay_owner,
       l_per_owner)
  order by column_id;


--
begin
--

hr_dm_utility.message('ROUT','entry:hr_dm_library.create_stub_views', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id || ')',
                      10);

open csr_apps_name;
fetch csr_apps_name into l_apps_name;
close csr_apps_name;

-- find out what chr(10) is
l_cr := fnd_global.local_chr(10);

-- find which views we need to build
open csr_view;
loop
  fetch csr_view into l_view_name, l_table_name;
  exit when csr_view%notfound;
  if csr_view%found then

-- build up column list
  l_first := 'Y';
  hr_dm_utility.message('INFO','creating columns for ' || l_view_name,10);

  if l_view_name = 'HR_DMVS_HR_LOCATIONS_ALL' then
    open csr_sp_columns;
    loop
      fetch csr_sp_columns into l_column_name;
      exit when csr_sp_columns%notfound;
      if (l_first <> 'Y') then
        l_columns := l_columns || ', ' || l_column_name || l_cr;
      else
        l_columns := '  ' || l_column_name || l_cr;
        l_first := 'N';
      end if;
    end loop;
    close csr_sp_columns;
  elsif l_view_name = 'HR_DMVP_PER_ABS_ATTNDS' then
    l_table_name := 'PER_ABSENCE_ATTENDANCES';
    open csr_sp2_columns;
    loop
      fetch csr_sp2_columns into l_column_name;
      exit when csr_sp2_columns%notfound;
      if (l_first <> 'Y') then
        l_columns := l_columns || ', ' || l_column_name || l_cr;
      else
        l_columns := '  ' || l_column_name || l_cr;
        l_first := 'N';
      end if;
    end loop;
    close csr_sp2_columns;
  else
-- normal case
    open csr_columns;
    loop
      fetch csr_columns into l_column_name;
      exit when csr_columns%notfound;
      if (l_first <> 'Y') then
        l_columns := l_columns || ', ' || l_column_name || l_cr;
      else
        l_columns := '  ' || l_column_name || l_cr;
        l_first := 'N';
      end if;
    end loop;
    close csr_columns;
  end if;



  l_string := 'create or replace force view ' ||
              l_view_name || ' as select ' || l_cr ||
              l_columns || 'from ' || l_table_name;


  hr_dm_utility.message('INFO','Creating view ' || l_view_name, 15);
  hr_dm_utility.message('INFO','View created using ' || l_cr || l_string, 15);

-- find the applsys username
  l_value := fnd_installation.get_app_info ('FND', l_out_status,
                                            l_out_industry,
                                            l_out_oracle_schema);

  ad_ddl.do_ddl(l_out_oracle_schema, 'PER', ad_ddl.create_view,
                  l_string, l_view_name);

  end if;
end loop;
close csr_view;

-- seed AOL hierarchy info for WHO columns
-- for views created which contain WHO columns
seed_view_who;

-- seed null hierarchy info for REQUEST_ID / PROGRAM_APPLICATION_ID columns
-- for views created which contain REQUEST_ID / PROGRAM_APPLICATION_ID columns
seed_view_null;

hr_dm_utility.message('INFO','Created stub views', 15);
hr_dm_utility.message('SUMM','Created stub views', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_library.create_stub_views', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
exception
when others then
  hr_dm_utility.error(sqlcode,'hr_dm_library.create_stub_views',
                      'error creating stub views','r');
  raise;

--
end create_stub_views;
--




end hr_dm_library;

/
