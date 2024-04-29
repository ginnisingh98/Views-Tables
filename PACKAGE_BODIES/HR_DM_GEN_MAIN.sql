--------------------------------------------------------
--  DDL for Package Body HR_DM_GEN_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_GEN_MAIN" as
/* $Header: perdmgn.pkb 115.21 2004/03/24 08:28:33 mmudigon ship $ */
-- ------------------------- chk_long_column   ------------------------
-- Description:
-- It check whether a table has a long column or not. It reurns
--      'Y'    - if table has a long column
--      'N'    - if table does not have long column
-- ------------------------------------------------------------------------
l_status    varchar2(50);
l_industry  varchar2(50);
l_per_owner     varchar2(30);
l_ben_owner     varchar2(30);
l_pay_owner     varchar2(30);
l_ff_owner     varchar2(30);
l_fnd_owner     varchar2(30);

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
function chk_long_column
(
 p_table_name      varchar2
)
return varchar2 is
  l_dummy        varchar2(1);
  l_return_flag  varchar2(1);
  l_apps_name         varchar2(30);

  cursor csr_apps_name is
  select ORACLE_USERNAME
  from fnd_oracle_userid
  where ORACLE_ID = 900;

  --
  -- cursor to check whether table has column or table hierarchy by checking
  -- the entreries in hr_dm_hierarchy table.

  cursor csr_chk_long_column is
  select 1
  from all_tab_columns
  where table_name = p_table_name
  and   data_type = 'LONG'
  and owner in
  (l_apps_name,
   l_fnd_owner,
   l_ff_owner,
   l_ben_owner,
   l_pay_owner,
   l_per_owner);

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.chk_long_column', 5);
  hr_dm_utility.message('PARA','(p_table_name - ' || p_table_name ||
                             ')', 10);

  open csr_apps_name;
  fetch csr_apps_name into l_apps_name;
  close csr_apps_name;


  open csr_chk_long_column ;
  fetch csr_chk_long_column into l_dummy;
  if csr_chk_long_column%found then
     l_return_flag := 'Y';
  else
     l_return_flag := 'N';
  end if;
  close csr_chk_long_column;

  hr_dm_utility.message('INFO','HR_DM_GEN_MAIN - check whether table has any long column',15);

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.chk_long_column', 25);
  hr_dm_utility.message('PARA','(l_return_flag - ' || l_return_flag || ')' ,30);
  return l_return_flag;
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.chk_long_column',
                         '(none)','R');
    raise;
end chk_long_column;

-- ------------------------- get_hierarchy_info   ------------------------
-- Description:
-- It check whether a table has a hierarchy for a given hierarchy type i.e
-- column hierarchy ('C') or table hierarchy 'T' or logical primary key ('P')
-- It returns  'Y' - if the given hierarchy type exists for the table.
--             'N' - if the given hierarchy type does not exists
-- ------------------------------------------------------------------------
function get_hierarchy_info
(
 p_table_id         number,
 p_hierarchy_type   varchar2
)
return varchar2 is
  l_dummy        varchar2(1);
  l_return_flag  varchar2(1);
  --
  -- cursor to check whether table has column or table hierarchy by checking
  -- the enteries in hr_dm_hierarchy table.

  cursor csr_get_hierarchy_info (p_table_id        number,
                                 p_hierarchy_type  varchar2) is
  select 1
  from hr_dm_hierarchies hir
  where hir.table_id = p_table_id
  and   hir.hierarchy_type = p_hierarchy_type;

  cursor csr_get_lr_info (p_table_id        number,
                          p_hierarchy_type  varchar2) is
  select 1
  from hr_dm_hierarchies hir,
       hr_dm_tables t
  where hir.table_id = t.table_id
    and t.table_name = (
	select nvl(upload_table_name, table_name)
	from hr_dm_tables
	where table_id = p_table_id)
    and   hir.hierarchy_type = p_hierarchy_type;


begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.get_hierarchy_info', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_id ||
                             ')(p_hierarchy_type - ' || p_hierarchy_type ||
                             ')', 10);

  if (p_hierarchy_type = 'R')
    or (p_hierarchy_type = 'L') then

    open csr_get_lr_info (p_table_id,
                         p_hierarchy_type);
    fetch csr_get_lr_info into l_dummy;
    if csr_get_lr_info%found then
       l_return_flag := 'Y';
    else
       l_return_flag := 'N';
    end if;
    close csr_get_lr_info;

  else

    open csr_get_hierarchy_info (p_table_id,
                                 p_hierarchy_type);
    fetch csr_get_hierarchy_info into l_dummy;
    if csr_get_hierarchy_info%found then
       l_return_flag := 'Y';
    else
       l_return_flag := 'N';
    end if;
    close csr_get_hierarchy_info;

  end if;

  hr_dm_utility.message('INFO','HR_DM_GEN_MAIN - get whether a given hierarchy type'||
                        ' is valid for table ' ||
                         'in hr_dm_dt_deletes table ',15);

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.get_hierarchy_info',
                         25);
  hr_dm_utility.message('PARA','(l_return_flag - ' || l_return_flag || ')' ,30);
  return l_return_flag;
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.get_hierarchy_info',
                         '(none)','R');
    raise;
end get_hierarchy_info;

-- ------------------------- chk_ins_resolve_pk   ------------------------
-- Description:
-- It checks whether a table has a child table with hierarchy type 'L'.
-- ------------------------------------------------------------------------
function chk_ins_resolve_pk
(
 p_table_id   in  number
)
return varchar2 is
  l_dummy        varchar2(1);
  l_return_flag  varchar2(1);
  --
  -- cursor to check whether table has column or table hierarchy by checking
  -- the entries in hr_dm_hierarchy table.

  cursor csr_chk_ins_resolve_pk (p_table_id        number) is
  select 1
  from hr_dm_hierarchies hir
  where hir.hierarchy_type = 'L'
    and hir.parent_table_id =  (select table_id
          from hr_dm_tables
          where table_name = (
              select nvl(upload_table_name, table_name)
                from hr_dm_tables
                where table_id = p_table_id));
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.chk_ins_resolve_pk', 5);
  hr_dm_utility.message('PARA','(p_table_id - ' || p_table_id ||
                             ')', 10);

  open csr_chk_ins_resolve_pk (p_table_id);
  fetch csr_chk_ins_resolve_pk into l_dummy;
  if csr_chk_ins_resolve_pk%found then
     l_return_flag := 'Y';
  else
     l_return_flag := 'N';
  end if;
  close csr_chk_ins_resolve_pk;

  hr_dm_utility.message('INFO','HR_DM_GEN_MAIN - get whether a table has child table'||
                        ' with hierarchy type L',15);

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.chk_ins_resolve_pk',
                         25);
  hr_dm_utility.message('PARA','(l_return_flag - ' || l_return_flag || ')' ,30);
  return l_return_flag;
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.chk_ins_resolve_pk',
                         '(none)','R');
    raise;
end chk_ins_resolve_pk;

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
)
is

  l_dummy          varchar2(1);
  l_phase_item_id  number;
  l_tups_package   varchar2(30);
  l_tds_package    varchar2(30);
  l_apps_name      varchar2(30);
  l_text           long;
  l_view_name      varchar2(30);
  e_fatal_error            EXCEPTION;
  l_fatal_error_message    VARCHAR2(200);
  l_view_error     varchar2(1);

  -- cursor to select the tables in Generate phase for the given migration
  cursor csr_get_table is
  select tbl.table_id
      ,upper(tbl.short_name)  short_name
      ,upper(tbl.table_name)  table_name
      ,itm.phase_item_id
      ,phs.phase_id
  from hr_dm_tables tbl,
       hr_dm_phase_items itm,
       hr_dm_phases  phs
  where phs.migration_id = p_migration_id
  and   phs.phase_name   = 'R'
  and   phs.phase_id     = itm.phase_id
  and   itm.table_name   = tbl.table_name;

  -- check whether the staus of the given table in Generate phase is other
  -- than 'Complete'. If yes then it needs re-generating.
  cursor csr_chk_generate_status (p_table_name varchar2)is
  select '1'
  from hr_dm_phase_items itm,
       hr_dm_phases  phs
  where phs.migration_id = p_migration_id
  and   phs.phase_name   = 'G'
  and   phs.phase_id     = itm.phase_id
  and   itm.table_name   = p_table_name
  and   itm.status       = 'C';

  -- check whether package bodu of TUPS/TDS is valid
  cursor csr_chk_package_status is
  select '1'
  from user_objects tups,
       user_objects tds
  where tups.object_name = l_tups_package
  and tups.object_type = 'PACKAGE BODY'
  and tups.status = 'VALID'
  and tds.object_name = l_tds_package
  and tds.object_type = 'PACKAGE BODY'
  and tds.status = 'VALID';

  cursor csr_apps_name is
  select ORACLE_USERNAME
  from fnd_oracle_userid
  where ORACLE_ID = 900;

  cursor csr_view_info is
  select av.view_name,
         av.text,
         itm.phase_item_id
  from all_views av,
       hr_dm_phase_items itm,
       hr_dm_phases  phs
  where phs.migration_id = p_migration_id
  and   phs.phase_name   = 'G'
  and   phs.phase_id     = itm.phase_id
  and   itm.table_name = av.view_name
  and   av.view_name like 'HR_DMV%'
  and av.view_name not like 'HR_DMVP%'
  and av.view_name not like 'HR_DMVS%'
  and av.owner = l_apps_name;



begin
 -- return;
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.post_generate_validate', 5);
  hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')', 10);

  for csr_get_table_rec in csr_get_table loop
     l_phase_item_id := csr_get_table_rec.phase_item_id;

     -- TUPS/TDS package names
     l_tups_package := 'HRDMD_' || upper(csr_get_table_rec.short_name);
     l_tds_package := 'HRDMU_' ||  upper(csr_get_table_rec.short_name);

     -- check for the status of package
     l_dummy := null;
     open csr_chk_package_status;
     fetch csr_chk_package_status into l_dummy;
     close csr_chk_package_status;

     if l_dummy is null then
     --
     -- if the row is not found then it means either TUPS/TDS does not
     -- exist for this table or if they exist then the status is Invalid

     -- try to recompile TDS and TUPS
       execute immediate 'alter package ' || l_tds_package || ' compile';
       execute immediate 'alter package ' || l_tups_package || ' compile';

     -- see if this worked

       open csr_chk_package_status;
       fetch csr_chk_package_status into l_dummy;

       if csr_chk_package_status%notfound then
         -- Need to generate TUPS/TDS again.
          close csr_chk_package_status;
          -- call the package to generate TUPS/TDS for this table
          slave_generator_for_tbl
          ( p_phase_item_id       => csr_get_table_rec.phase_item_id);
       else
          close csr_chk_package_status;
       end if;

    end if;

  end loop;


-- now check HR_DMV% views
-- for inclusion of null business_group check in where clause
  hr_dm_utility.message('INFO','checking HR_DMV% views',12);
  l_view_error := 'N';
  open csr_apps_name;
  fetch csr_apps_name into l_apps_name;
  close csr_apps_name;

  open csr_view_info;
  loop
    fetch csr_view_info into l_view_name,
                             l_text,
                             l_phase_item_id;
    exit when csr_view_info%notfound;

    if instr(l_text, 'business_group_id is null') = 0 then
      l_view_error := 'Y';
      hr_dm_utility.message('INFO','The view ' || l_view_name
                            || ' is missing a business_group_id ' ||
                            'is null clause.',15);
      hr_dm_utility.update_phase_items(p_new_status => 'E',
                                  p_id => l_phase_item_id);
    end if;
  end loop;
  close csr_view_info;

  if l_view_error = 'Y' then
    l_fatal_error_message := 'Errors were found in one or more HR_DMV%' ||
                             'view definitions due to a'
                             || ' missing  business_group_id ' ||
                               'is null clause. Check log files for more'
                             || ' details.';
    raise e_fatal_error;
  end if;


  hr_dm_utility.message('INFO','HR_DM_GEN_MAIN - post generate validation ',15);
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.post_generate_validate',
                         25);

-- error handling
exception
  when e_fatal_error then
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.post_generate_validate',
                        l_fatal_error_message,'R');
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.post_generate_validate',
                        '(none)','R');
  when others then
    -- update status to error
    hr_dm_utility.update_phase_items(p_new_status => 'E',
                                    p_id => l_phase_item_id);
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.post_generate_validate','(none)','R');
end post_generate_validate;

-- ------------------------- slave_generator_for_tbl    --------------------
-- Description:
-- It generates TUPS/TDS for a given table.It calls
--     TUPS Generator to generate TUPS for the table
--     Seed the data into data pump for TUPS.
--     TDS Generator to generate TDS for the table.
--
-- It is called by the post_generate_validate procedure.
--
-- PLEASE COPY THE CHANGES MAKE IN THIS PROCEDURE INTO SLAVE_GENERATOR PROCEDURE
-- DEFINED BELOW.
-- ------------------------------------------------------------------------
procedure slave_generator_for_tbl
(
 p_phase_item_id        in   number
)
is

-- used for indexing of pl/sql table.
l_count      number;

-- stores table properties or info and is passed to the TDS/TUPS generator.
l_table_info   t_table_info;

-- stores columns and column  data info.
l_columns_tbl             hr_dm_library.t_varchar2_tbl;
l_parameters_tbl          hr_dm_library.t_varchar2_tbl;

l_aol_columns_tbl         hr_dm_library.t_varchar2_tbl;
l_aol_parameters_tbl      hr_dm_library.t_varchar2_tbl;

l_fk_to_aol_columns_tbl   t_fk_to_aol_columns_tbl;
l_phase_item_id           hr_dm_phase_items.phase_item_id%type;
l_phase_id                hr_dm_phases.phase_id%type;

l_generator_version       hr_dm_tables.generator_version%type;

l_current_phase_status    varchar2(30);
e_fatal_error             exception;
l_fatal_error_message     varchar2(200);
l_missing_who_info        varchar2(1);

-- cursor to get table for which TUPS/TDS have to be genrated

cursor csr_get_table is
select tbl.table_id
      ,lower(tbl.table_name)  table_name
      ,tbl.datetrack
      ,decode (tbl.surrogate_pk_column_name,NULL,'N','Y') surrogate_primary_key
      ,lower(tbl.surrogate_pk_column_name) surrogate_pk_column_name
      ,lower(tbl.table_alias) table_alias
      ,lower(tbl.short_name) short_name
      ,itm.phase_item_id
      ,lower(tbl.who_link_alias) who_link_alias
      ,tbl.derive_sql_download_full
      ,tbl.derive_sql_download_add
      ,tbl.derive_sql_calc_ranges
      ,tbl.derive_sql_delete_source
      ,tbl.derive_sql_source_tables
      ,tbl.derive_sql_chk_row_exists
      ,tbl.derive_sql_chk_source_tables
      ,tbl.use_distinct_download
      ,tbl.always_check_row
      ,upper(nvl(tbl.global_data,'N')) global_data
      ,phs.migration_id
      ,lower(nvl(tbl.upload_table_name, tbl.table_name)) upload_table_name
      ,sequence_name
from hr_dm_tables tbl,
    hr_dm_phases phs,
     hr_dm_phase_items itm
where itm.phase_item_id  =  p_phase_item_id
and   itm.phase_id       = phs.phase_id
and   itm.table_name     =  tbl.table_name;

cursor csr_get_table_hierarchy is
  select distinct parent_table_id
    from  (select table_id,parent_table_id
             from hr_dm_hierarchies
              where hierarchy_type = 'PC')
              start with table_id = l_table_info.table_id
              connect by prior parent_table_id = table_id;

l_csr_get_table_rec        csr_get_table%rowtype;
l_datetrack                varchar2(1);
l_datetrack_parent         varchar2(1);
l_parent_table_id          number;

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.slave_generator_for_tbl  ', 5);
  hr_dm_utility.message('PARA','(p_phase_item_id  - ' || p_phase_item_id  ||
                             ')', 10);
  -- initialise the counter.
  l_count := 1;
  --
  -- Get the table for which TUPS/TDS has to be generated
  --
  open csr_get_table;
  fetch csr_get_table into l_csr_get_table_rec;
  hr_dm_utility.message('INFO','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,20);

  hr_dm_utility.message('SUMM','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,30);
  l_phase_item_id := l_csr_get_table_rec.phase_item_id;
  --l_phase_id      := l_csr_get_table_rec.phase_id;

  --
  -- get status of generate phase. If phase has error status set by other slave
  -- process then we need to stop the processing of this slave.
  -- if null returned, then assume it is not started.
  --
  l_current_phase_status := nvl(hr_dm_utility.get_phase_status('G',
                                      l_csr_get_table_rec.migration_id),
                               'NS');
   -- if status is error, then raise an exception
  if (l_current_phase_status = 'E') then
    l_fatal_error_message := 'error in generator phase - slave exiting';
    raise e_fatal_error;
  end if;
   -- update status to started
  hr_dm_utility.update_phase_items(p_new_status => 'S',
                                  p_id => l_phase_item_id);
   --
  -- store the information of the table properties into pl/sql record
  --
  l_table_info.table_id                 := l_csr_get_table_rec.table_id;
  l_table_info.table_name               := l_csr_get_table_rec.table_name;
  l_table_info.datetrack                := l_csr_get_table_rec.datetrack;
  l_table_info.surrogate_primary_key    :=
                              l_csr_get_table_rec.surrogate_primary_key;
  l_table_info.surrogate_pk_column_name :=
                            l_csr_get_table_rec.surrogate_pk_column_name;
  l_table_info.alias                    :=  l_csr_get_table_rec.table_alias;
  l_table_info.short_name               :=  l_csr_get_table_rec.short_name;
  l_table_info.who_link_alias           := l_csr_get_table_rec.who_link_alias;
  l_table_info.derive_sql_download_full :=
                              l_csr_get_table_rec.derive_sql_download_full;
  l_table_info.derive_sql_download_add :=
                              l_csr_get_table_rec.derive_sql_download_add;
  l_table_info.derive_sql_calc_ranges :=
                              l_csr_get_table_rec.derive_sql_calc_ranges;
  l_table_info.derive_sql_delete_source :=
                              l_csr_get_table_rec.derive_sql_delete_source;
  l_table_info.derive_sql_source_tables :=
                              l_csr_get_table_rec.derive_sql_source_tables;
  l_table_info.derive_sql_chk_source_tables :=
                               l_csr_get_table_rec.derive_sql_chk_source_tables;
  l_table_info.derive_sql_chk_row_exists :=
                               l_csr_get_table_rec.derive_sql_chk_row_exists;
  l_table_info.global_data := l_csr_get_table_rec.global_data;
  l_table_info.upload_table_name := l_csr_get_table_rec.upload_table_name;
  l_table_info.use_distinct_download := l_csr_get_table_rec.use_distinct_download;
  l_table_info.always_check_row := l_csr_get_table_rec.always_check_row;
  l_table_info.sequence_name := l_csr_get_table_rec.sequence_name;
  --
  -- get info about column hierarchy for the table
  --
  l_table_info.column_hierarchy := get_hierarchy_info(l_table_info.table_id,
                                                      'H');
   --
  -- get info about table hierarchy for the table
  --
  l_table_info.table_hierarchy := get_hierarchy_info(l_table_info.table_id,
                                                      'PC');
  --
  -- get info whether any column in table has a foreign key to AOL table
  --
  l_table_info.fk_to_aol_table := get_hierarchy_info(l_table_info.table_id,
                                                     'A');
  --
  -- get info whether the table has a primary key.
  --
  l_table_info.missing_primary_key := get_hierarchy_info(l_table_info.table_id,
                                                    'P');

  --
  -- get info whether to use columns defined in hr_dm_hierarchy table to form where
  -- cluase of chk_row_exist procedur of TUPS
  --
  l_table_info.use_non_pk_col_for_chk_row := get_hierarchy_info(l_table_info.table_id,
                                                    'R');

  --
  -- get info whether to add the code in upload procedure of TUPS to check for the existence
  -- of row in destination data for non global data table.
  --
  l_table_info.chk_row_exists_for_non_glb_tbl  := get_hierarchy_info(l_table_info.table_id,
                                                    'C');

  --
  -- get info whether to add the code in upload procedure of TUPS to resolve the primary key
  --
  if (l_table_info.column_hierarchy = 'Y') and
     (l_table_info.use_non_pk_col_for_chk_row = 'Y') then
     l_table_info.resolve_pk := 'Y';
  end if;

  if nvl(l_table_info.resolve_pk,'N')  <> 'Y' then
     l_table_info.resolve_pk  := get_hierarchy_info(l_table_info.table_id,
                                                    'L');
  end if;

  --
  -- get the info whether insert into hr_dm_resolve_pk table is allowed or not.
  -- it is allowed if the table has any child table seeded in the hr_dm_hierarchies
  -- table with hierarchy type 'L'.
  --
  l_table_info.ins_resolve_pk := chk_ins_resolve_pk (l_table_info.table_id);

  -- check whether to use distinct clause in the TDS download cursor. It will be used
  -- if it satisfies all the below conditions
  --
  -- (
  --  o tables has a  AOL hierarchy i.e hierarchy type = 'A'
  -- OR
  --  o table has a parent table which is datetracked
  -- )
  -- AND
  -- (
  --  o has a table hierarchy  i.e hierarchy type = 'PC'
  --  o does not have 'long' data type.
  -- )

  -- If the first two conditions are met and table has along data type then show the
  -- error message as distinct clause must be used for table which refrences AOL
  -- data. At present there are no such cases.
  -- In such cases use the derive_sql so as to eliminate the use of distinct clause

  l_table_info.use_distinct := 'N';

  -- test for AOL hierarchy
  if l_table_info.fk_to_aol_table = 'Y' and
     l_table_info.table_hierarchy = 'Y' and
     l_table_info.derive_sql_download_full is null then

     -- check whether table has a long column
     if chk_long_column(l_table_info.table_name) = 'N' then
        l_table_info.use_distinct := 'Y';
     else
        -- cannot use distinct. raise error.
       l_fatal_error_message := 'This table has a AOL type hierarchy and has a long column.' ||
                                'Define the where clause for this table using derive_sql to ' ||
                                'generate this table.';
       raise e_fatal_error;
     end if;
  end if;

  -- test for datetracked parent case
  if l_table_info.table_hierarchy = 'Y' and
     l_table_info.derive_sql_download_full is null then

    -- see if we have a parent which is date tracked
    -- based on code from hr_dm_gen_tds.get_cursor_from_clause
      l_datetrack_parent := 'N';

      open csr_get_table_hierarchy;
      loop
        fetch csr_get_table_hierarchy into l_parent_table_id;
        exit when csr_get_table_hierarchy%notfound;
        select datetrack
          into l_datetrack
          from hr_dm_tables
        where table_id = l_parent_table_id;
        if (l_datetrack = 'Y') then
          l_datetrack_parent := 'Y';
        end if;
      end loop;
      close csr_get_table_hierarchy;

      if (l_datetrack_parent = 'Y') then

       -- check whether table has a long column
       if chk_long_column(l_table_info.table_name) = 'N' then
          l_table_info.use_distinct := 'Y';
       else
          -- cannot use distinct. raise error.
         l_fatal_error_message := 'This table has a datetracked parent and has a long column.' ||
                                  'Define the where clause for this table using derive_sql to ' ||
                                  'generate this table.';
         raise e_fatal_error;
       end if;
     end if;
  end if;

  -- if one or more columns has a foreign key to the AOL table then store the
  -- information about the column and corresponding AOL table e.t.c for each
  -- column.
  if l_table_info.fk_to_aol_table = 'Y' then
    hr_dm_library.populate_fk_to_aol_cols_info
      ( p_table_info            => l_table_info,
        p_fk_to_aol_columns_tbl => l_fk_to_aol_columns_tbl);
  end if;

   -- get the columns and parameter list. store in pl/sql table.
  hr_dm_library.populate_columns_list(l_table_info,
                                      l_fk_to_aol_columns_tbl,
                                      l_columns_tbl,
                                      l_parameters_tbl,
                                      l_aol_columns_tbl,
                                      l_aol_parameters_tbl,
                                      l_missing_who_info);

   l_table_info.missing_who_info := l_missing_who_info;

   hr_dm_utility.message('INFO','   Information about ' ||
                       'l_table_info.table_name :'  ||
             ')(datetrack - ' || l_table_info.datetrack ||
             ')(surrogate_primary_key - ' || l_table_info.surrogate_primary_key ||
             ')(surrogate_pk_column_name - ' || l_table_info.surrogate_pk_column_name ||
             '(global_data - ' || l_table_info.global_data ||
             ')(derive_sql_source_tables - ' || l_table_info.derive_sql_source_tables ||
             ')(who_link_alias  - ' || l_table_info.who_link_alias  ||
             ')(missing_who_info - ' || l_table_info.missing_who_info ||
             ')(fk_to_aol_table - ' || l_table_info.fk_to_aol_table ||
             ')(column_hierarchy - ' || l_table_info.column_hierarchy ||
             ')(table_hierarchy - ' || l_table_info.table_hierarchy,40);


   -- if who columns are not there in the table then check whether the table
   -- has either deive_sql or who-link alias for the where clause. If both
   -- of them are not there then TDS cannot be generated for this table. stop
   -- processing.

   if (l_missing_who_info = 'Y' and
       l_table_info.who_link_alias is null and
       l_table_info.derive_sql_download_full  is  null and
       l_table_info.global_data = 'N')  then
     l_fatal_error_message := 'error in slave generator - ' ||
         l_table_info.table_name || ' does not have WHO column. Either define' ||
         ' where clause for this table or define the WHO link alias. Exiting ' ||
         'slave';
     raise e_fatal_error;
   end if;

  --
  -- Call TUPS genrator to create TUPS for the table
  --
  hr_dm_utility.message('INFO',' Started Generating TUPS  for ' ||
                                                   l_table_info.table_name,50);
  hr_dm_gen_tups.create_tups_pacakge (l_table_info,
                                      l_columns_tbl,
                                      l_parameters_tbl,
                                      l_aol_columns_tbl,
                                      l_aol_parameters_tbl,
                                      l_fk_to_aol_columns_tbl);
   hr_dm_utility.message('INFO',' Successfully Generated TUPS  for ' ||
                                                   l_table_info.table_name,60);
  --
  -- Seed the data for TUPS into data pump table.
  --
  hr_dm_utility.message('INFO',' Started seeding data into ' ||
                         'Data Pump tables for ' || l_table_info.table_name,70);
  hr_dm_seed_dp.main (l_table_info ,
                      l_columns_tbl);
  hr_dm_utility.message('INFO',' Successfully seeded data into ' ||
                         'Data Pump tables for ' || l_table_info.table_name,80);
   --
  -- Call TDS generator to create TDS for the table
  --

   hr_dm_utility.message('INFO',' Started Generating TDS  for ' ||
                                                   l_table_info.table_name,90);
   hr_dm_gen_tds.create_tds_pacakge (l_table_info,
                                     l_columns_tbl,
                                     l_parameters_tbl,
                                     l_aol_columns_tbl,
                                     l_aol_parameters_tbl,
                                     l_fk_to_aol_columns_tbl);
   hr_dm_utility.message('INFO',' Successfully Generated TDS  for ' ||
                                                   l_table_info.table_name,100);

  l_count := l_count + 1;

   -- get generator version used to generated this TUPS/TDS
   hr_dm_library.get_generator_version(l_generator_version);

   --
   -- update the last generated date for TUP/TDS for this table in hr_dm_tables
   --
   update hr_dm_tables
   set last_generated_date = sysdate,
       generator_version   = l_generator_version
   where table_id = l_csr_get_table_rec.table_id;

   -- update status to completed
  hr_dm_utility.update_phase_items(p_new_status => 'C',
                                   p_id => l_phase_item_id);

  hr_dm_utility.message('INFO','Generated TUPS/TDS succesfully  for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,110);

  hr_dm_utility.message('SUMM','Generated TUPS/TDS successfully for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,115);
  close csr_get_table;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.slave_generator_for_tbl',
                         120);

-- error handling
exception
when e_fatal_error then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator_for_tbl',
                       l_fatal_error_message,'R');
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);

  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator_for_tbl','(none)','R');
when others then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator_for_tbl','(none)','R');

end slave_generator_for_tbl ;

-- ------------------------- slave_generator    --------------------------
-- Description:
-- It generates the TUPS/TDS for all the tables in Generate phase for a given
-- migration Id.
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
--        retcode - program return code (for CM manager)
--
-- PLEASE COPY THE CHANGES MAKE IN THIS PROCEDURE INTO SLAVE_GENERATOR_FOR_TBL PROCEDURE
--  DEFINED ABOVE.
-- ------------------------------------------------------------------------
procedure slave_generator
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   date,
 p_process_number       in   number
)
is

-- used for indexing of pl/sql table.
l_count      number;

-- stores table properties or info and is passed to the TDS/TUPS generator.
l_table_info   t_table_info;

-- stores columns and column  data info.
l_columns_tbl             hr_dm_library.t_varchar2_tbl;
l_parameters_tbl          hr_dm_library.t_varchar2_tbl;

l_generator_version       hr_dm_tables.generator_version%type;

l_aol_columns_tbl         hr_dm_library.t_varchar2_tbl;
l_aol_parameters_tbl      hr_dm_library.t_varchar2_tbl;

l_fk_to_aol_columns_tbl   t_fk_to_aol_columns_tbl;
l_phase_item_id           hr_dm_phase_items.phase_item_id%type;
l_phase_id                hr_dm_phases.phase_id%type;

l_current_phase_status    varchar2(30);
e_fatal_error             exception;
e_fatal_error2            exception;
l_fatal_error_message     varchar2(200);
l_missing_who_info        varchar2(1);
l_aol_counter             number;
l_business_group_id       number;
l_no_of_threads           number;

-- get the migration details
cursor csr_migration_info is
select business_group_id
       from hr_dm_migrations
       where migration_id = p_migration_id;


-- cursor to get table for which TUPS/TDS have to be genrated

cursor csr_get_table is
select tbl.table_id
      ,lower(tbl.table_name)  table_name
      ,tbl.datetrack
      ,decode (tbl.surrogate_pk_column_name,NULL,'N','Y') surrogate_primary_key
      ,lower(tbl.surrogate_pk_column_name) surrogate_pk_column_name
      ,lower(tbl.table_alias) table_alias
      ,lower(tbl.short_name) short_name
      ,itm.phase_item_id
      ,phs.phase_id
      ,lower(tbl.who_link_alias) who_link_alias
      ,tbl.derive_sql_download_full
      ,tbl.derive_sql_download_add
      ,tbl.derive_sql_calc_ranges
      ,tbl.derive_sql_delete_source
      ,tbl.derive_sql_source_tables
      ,tbl.derive_sql_chk_row_exists
      ,tbl.derive_sql_chk_source_tables
      ,tbl.use_distinct_download
      ,tbl.always_check_row
      ,upper(nvl(tbl.global_data,'N')) global_data
      ,lower(nvl(tbl.upload_table_name, tbl.table_name)) upload_table_name
      ,sequence_name
from hr_dm_tables tbl,
     hr_dm_phase_items itm,
     hr_dm_phases  phs
where phs.migration_id = p_migration_id
and   phs.phase_name   = 'G'
and   phs.phase_id     = itm.phase_id
and   mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
and   itm.status       = 'NS'
--and   itm.status       in ('NS','E')
and   itm.table_name   = tbl.table_name
and   rownum < 2;
-- for update of itm.status;
/*
for update of itm.status,
              phs.phase_name,
              tbl.table_name;
*/

l_csr_get_table_rec        csr_get_table%rowtype;


cursor csr_get_table_hierarchy is
  select distinct parent_table_id
    from  (select table_id,parent_table_id
             from hr_dm_hierarchies
              where hierarchy_type = 'PC')
              start with table_id = l_table_info.table_id
              connect by prior parent_table_id = table_id;

cursor csr_col_hier
      (p_table_id number) is
   select count(*)
     from hr_dm_hierarchies h
    where h.table_id = p_table_id
      and h.hierarchy_type ='A'
      and h.column_name not in ('CREATED_BY','LAST_UPDATED_BY');

l_datetrack                varchar2(1);
l_datetrack_parent         varchar2(1);
l_parent_table_id          number;




begin

  -- initialize messaging
  if p_concurrent_process = 'Y' then
    hr_dm_utility.message_init;
  end if;

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_main.slave_generator', 5);
  hr_dm_utility.message('PARA','(errbuf - ' || errbuf ||
                             ')(retcode - ' || retcode ||
                             ')(p_migration_id - ' || p_migration_id ||
                             ')(p_concurrent_process - ' || p_concurrent_process ||
                             ')(p_last_migration_date - '|| p_last_migration_date ||
                             ')', 10);

 -- get the business_group_id and migration_type
 open csr_migration_info;
 fetch csr_migration_info into l_business_group_id;
 if csr_migration_info%notfound then
   close csr_migration_info;
   l_fatal_error_message := 'hr_dm_download.main :- Migration Id ' ||
             to_char(p_migration_id) || ' not found.';
   raise e_fatal_error2;
 end if;
 close csr_migration_info;

 l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);

 -- initialise the counter.
 l_count := 1;
 --
 -- Get the table for which TUPS/TDS has to be generated
 --
 loop
   l_phase_item_id := NULL;

   --
   -- get status of generate phase. If phase has error status set by other slave
   -- process then we need to stop the processing of this slave.
   -- if null returned, then assume it is not started.
   --
   l_current_phase_status := nvl(hr_dm_utility.get_phase_status('G',
                                                                p_migration_id),
                                'NS');

   -- if status is error, then raise an exception
   if (l_current_phase_status = 'E') then
     l_fatal_error_message := 'Encountered error in generator phase caused by ' ||
                              'another process - slave exiting';
     raise e_fatal_error2;
   end if;

   open csr_get_table;
   fetch csr_get_table into l_csr_get_table_rec;
   if csr_get_table%notfound then
     close csr_get_table;
     exit;
   end if;

   -- update status to started
   hr_dm_utility.update_phase_items(p_new_status => 'S',
                                   p_id => l_csr_get_table_rec.phase_item_id);

   l_phase_item_id := l_csr_get_table_rec.phase_item_id;
   l_phase_id      := l_csr_get_table_rec.phase_id;

   close csr_get_table;

   hr_dm_utility.message('INFO','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,20);

   hr_dm_utility.message('SUMM','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,30);
   --
   -- store the information of the table properties into pl/sql record
   --
   l_table_info.migration_id             := p_migration_id;
   l_table_info.table_id                 := l_csr_get_table_rec.table_id;
   l_table_info.table_name               := l_csr_get_table_rec.table_name;
   l_table_info.datetrack                := l_csr_get_table_rec.datetrack;
   l_table_info.surrogate_primary_key    :=
                               l_csr_get_table_rec.surrogate_primary_key;
   l_table_info.surrogate_pk_column_name :=
                             l_csr_get_table_rec.surrogate_pk_column_name;
   l_table_info.alias                    :=  l_csr_get_table_rec.table_alias;
   l_table_info.short_name               :=  l_csr_get_table_rec.short_name;

   l_table_info.who_link_alias           := l_csr_get_table_rec.who_link_alias;
   l_table_info.derive_sql_download_full :=
                               l_csr_get_table_rec.derive_sql_download_full;
   l_table_info.derive_sql_download_add :=
                               l_csr_get_table_rec.derive_sql_download_add;
   l_table_info.derive_sql_calc_ranges :=
                               l_csr_get_table_rec.derive_sql_calc_ranges;
   l_table_info.derive_sql_delete_source :=
                               l_csr_get_table_rec.derive_sql_delete_source;
   l_table_info.derive_sql_source_tables :=
                               l_csr_get_table_rec.derive_sql_source_tables;
   l_table_info.derive_sql_chk_source_tables :=
                               l_csr_get_table_rec.derive_sql_chk_source_tables;
   l_table_info.derive_sql_chk_row_exists :=
                               l_csr_get_table_rec.derive_sql_chk_row_exists;

   l_table_info.global_data := l_csr_get_table_rec.global_data;
   l_table_info.upload_table_name := l_csr_get_table_rec.upload_table_name;
   l_table_info.use_distinct_download := l_csr_get_table_rec.use_distinct_download;
   l_table_info.always_check_row := l_csr_get_table_rec.always_check_row;
   l_table_info.sequence_name := l_csr_get_table_rec.sequence_name;

   --
   -- get info about column hierarchy for the table
   --
   l_table_info.column_hierarchy := get_hierarchy_info(l_table_info.table_id,
                                                       'H');

   --
   -- get info about table hierarchy for the table
   --
   l_table_info.table_hierarchy := get_hierarchy_info(l_table_info.table_id,
                                                       'PC');
   --
   -- get info whether any column in table has a foreign key to AOL table
   --
   l_table_info.fk_to_aol_table := get_hierarchy_info(l_table_info.table_id,
                                                       'A');

  --
  -- get info whether the table has a primary key.
  --
  l_table_info.missing_primary_key := get_hierarchy_info(l_table_info.table_id,
                                                    'P');
  --
  -- get info whether to use columns defined in hr_dm_hierarchy table to form where
  -- cluase of chk_row_exist procedur of TUPS
  --
  l_table_info.use_non_pk_col_for_chk_row := get_hierarchy_info(l_table_info.table_id,
                                                    'R');
  --
  -- get info whether to add the code in upload procedure of TUPS to check for the existence
  -- of row in destination data for non global data table.
  --
  l_table_info.chk_row_exists_for_non_glb_tbl  := get_hierarchy_info(l_table_info.table_id,
                                                    'C');

  --
  -- get info whether to add the code in upload procedure of TUPS to resolve the primary key
  --
  if (l_table_info.column_hierarchy = 'Y') and
     (l_table_info.use_non_pk_col_for_chk_row = 'Y') then
     l_table_info.resolve_pk := 'Y';
  end if;

  if nvl(l_table_info.resolve_pk,'N')  <> 'Y' then
     l_table_info.resolve_pk  := get_hierarchy_info(l_table_info.table_id,
                                                    'L');
  end if;
  --
  -- get the info whether insert into hr_dm_resolve_pk table is allowed or not.
  -- it is allowed if the table has any child table seeded in the hr_dm_hierarchies
  -- table with hierarchy type 'L'.
  --
  l_table_info.ins_resolve_pk := chk_ins_resolve_pk(l_table_info.table_id);

  -- check whether to use distinct clause in the TDS download cursor. It will be used
  -- if it satisfies all the below conditions
  --
  -- (
  --  o tables has a  AOL hierarchy i.e hierarchy type = 'A'
  -- OR
  --  o table has a parent table which is datetracked
  -- )
  -- AND
  -- (
  --  o has a table hierarchy  i.e hierarchy type = 'PC'
  --  o does not have 'long' data type.
  -- )

  -- If the first two conditions are met and table has along data type then show the
  -- error message as distinct clause must be used for table which refrences AOL
  -- data. At present there are no such cases.
  -- In such cases use the derive_sql so as to eliminate the use of distinct clause

  l_table_info.use_distinct := 'N';

  if l_table_info.fk_to_aol_table = 'Y' and
     l_table_info.table_hierarchy = 'Y' and
     l_table_info.derive_sql_download_full is null then

     -- check whether table has a long column
     if chk_long_column(l_table_info.table_name) = 'N' then
        l_table_info.use_distinct := 'Y';
     else
        -- cannot use distinct. raise error.
       l_fatal_error_message := 'This table has a AOL type hierarchy and has a long column.' ||
                                'Define the where clause for this table using derive_sql to ' ||
                                'generate this table.';
       raise e_fatal_error;
     end if;
  end if;

  -- test for datetracked parent case
  if l_table_info.table_hierarchy = 'Y' and
     l_table_info.derive_sql_download_full is null then

    -- see if we have a parent which is date tracked
    -- based on code from hr_dm_gen_tds.get_cursor_from_clause
      l_datetrack_parent := 'N';

      open csr_get_table_hierarchy;
      loop
        fetch csr_get_table_hierarchy into l_parent_table_id;
        exit when csr_get_table_hierarchy%notfound;
        select datetrack
          into l_datetrack
          from hr_dm_tables
        where table_id = l_parent_table_id;
        if (l_datetrack = 'Y') then
          l_datetrack_parent := 'Y';

        end if;
      end loop;
      close csr_get_table_hierarchy;

      if (l_datetrack_parent = 'Y') then
       -- check whether table has a long column
       if chk_long_column(l_table_info.table_name) = 'N' then
          l_table_info.use_distinct := 'Y';
       else
          -- cannot use distinct. raise error.
         l_fatal_error_message := 'This table has a datetracked parent and has a long column.' ||
                                  'Define the where clause for this table using derive_sql to ' ||
                                  'generate this table.';
         raise e_fatal_error;
       end if;
     end if;
  end if;

   -- if one or more columns has a foreign key to the AOL table then store the
   -- information about the column and corresponding AOL table e.t.c for each
   -- column.
   if l_table_info.fk_to_aol_table = 'Y' then
     hr_dm_library.populate_fk_to_aol_cols_info
       ( p_table_info            => l_table_info,
         p_fk_to_aol_columns_tbl => l_fk_to_aol_columns_tbl);

     -- if the error below is raised we need to make modifications to
     -- generate_upload_hierarchy (perdmgnu.pkb) to handle 'A' hierarchy
     if l_table_info.column_hierarchy = 'Y' then
        open csr_col_hier
        (l_table_info.table_id);
        fetch csr_col_hier into l_aol_counter;
        close csr_col_hier;
        if (l_aol_counter > 0) then
           l_fatal_error_message := 'AOL column names must be created_by or last_updated_by for a table with H hierarchy.'||
                                    'Other names are not currently handled. Please contact Oracle Support.';
           raise e_fatal_error;
        end if;
     end if;

   end if;

   -- get the columns and parameter list. store in pl/sql table.
   hr_dm_library.populate_columns_list(l_table_info,
                                       l_fk_to_aol_columns_tbl,
                                       l_columns_tbl,
                                       l_parameters_tbl,
                                       l_aol_columns_tbl,
                                       l_aol_parameters_tbl,
                                       l_missing_who_info);


   l_table_info.missing_who_info := l_missing_who_info;

   hr_dm_utility.message('INFO','   Information about ' ||
                      'l_table_info.table_name :'  ||
             ')(datetrack - ' || l_table_info.datetrack ||
             ')(surrogate_primary_key - ' || l_table_info.surrogate_primary_key ||
             ')(surrogate_pk_column_name - ' || l_table_info.surrogate_pk_column_name ||
             '(global_data - ' || l_table_info.global_data ||
             ')(derive_sql_source_tables - ' || l_table_info.derive_sql_source_tables ||
             ')(who_link_alias  - ' || l_table_info.who_link_alias  ||
             ')(missing_who_info - ' || l_table_info.missing_who_info ||
             ')(fk_to_aol_table - ' || l_table_info.fk_to_aol_table ||
             ')(column_hierarchy - ' || l_table_info.column_hierarchy ||
             ')(table_hierarchy - ' || l_table_info.table_hierarchy,40);


   -- if who columns are not there in the table then check whether the table
   -- has either deive_sql or who-link alias for the where clause. If both
   -- of them are not there then TDS cannot be generated for this table. stop
   -- processing.

   if (l_missing_who_info = 'Y' and
       l_table_info.who_link_alias is null and
       l_table_info.derive_sql_download_full  is  null and
       l_table_info.global_data = 'N')  then

     l_fatal_error_message := 'error in slave generator - ' ||
         l_table_info.table_name || ' does not have WHO column. Either define' ||
         ' where clause for this table or define the WHO link alias. Exiting ' ||
         'slave';
     raise e_fatal_error;
   end if;

   --
   -- if the table has 'R' type and 'A' type hierarchy then the table has a unique
   -- constraint and one of the column of the unique constraint has a foreign key
   -- on another table which has a unique constraint. In this case the table must
   -- have surrggate primary key column.
   --
/*

  -- check disabled to enable WHO column migration via A type hierarchy

   if l_table_info.surrogate_pk_column_name is null and
      l_table_info.use_non_pk_col_for_chk_row = 'Y' and
      l_table_info.fk_to_aol_table = 'Y' then

     l_fatal_error_message := 'error in slave generator - ' ||
         l_table_info.table_name || ' does not have surrogate primary column. Define' ||
         ' the surrogate primary key column . Exiting ' ||
         'slave';
     raise e_fatal_error;
   end if;

*/

   -- if the source table is different from destination table then it is assumed
   -- source table is a view which needs to be generated.

   if l_table_info.upload_table_name <> l_table_info.table_name then
     begin

       hr_dm_library.create_view(l_table_info);

     exception
       when others then
        l_fatal_error_message := 'error in hr_dm_utility.create_view - for ' ||
         l_table_info.table_name || '. Exiting slave';
       raise e_fatal_error;
     end;
   end if;

   --
   -- Call TUPS genrator to create TUPS for the table
   --
   hr_dm_utility.message('INFO',' Started Generating TUPS  for ' ||
                                                   l_table_info.table_name,50);

   hr_dm_gen_tups.create_tups_pacakge (l_table_info,
                                       l_columns_tbl,
                                       l_parameters_tbl,
                                       l_aol_columns_tbl,
                                       l_aol_parameters_tbl,
                                       l_fk_to_aol_columns_tbl);

   hr_dm_utility.message('INFO',' Successfully Generated TUPS  for ' ||
                                                   l_table_info.table_name,60);
   --
   -- Seed the data for TUPS into data pump table.
   --
   hr_dm_utility.message('INFO',' Started seeding data into ' ||
                         'Data Pump tables for ' || l_table_info.table_name,70);


   hr_dm_seed_dp.main (l_table_info ,
                       l_columns_tbl);
   hr_dm_utility.message('INFO',' Successfully seeded data into ' ||
                         'Data Pump tables for ' || l_table_info.table_name,80);
   --
   -- Call TDS generator to create TDS for the table
   --
   hr_dm_utility.message('INFO',' Started Generating TDS  for ' ||
                                                   l_table_info.table_name,90);


   hr_dm_gen_tds.create_tds_pacakge (l_table_info,
                                      l_columns_tbl,
                                      l_parameters_tbl,
                                      l_aol_columns_tbl,
                                      l_aol_parameters_tbl,
                                      l_fk_to_aol_columns_tbl);
   hr_dm_utility.message('INFO',' Successfully Generated TDS  for ' ||
                                                   l_table_info.table_name,100);

   l_count := l_count + 1;

   -- get generator version used to generated this TUPS/TDS
   hr_dm_library.get_generator_version(l_generator_version);
   --
   -- update the last generated date for TUP/TDS for this table in hr_dm_tables
   --
   update hr_dm_tables
   set last_generated_date = sysdate,
       generator_version   = l_generator_version
   where table_id = l_csr_get_table_rec.table_id;

   -- update status to completed
   hr_dm_utility.update_phase_items(p_new_status => 'C',
                                    p_id => l_phase_item_id);

   hr_dm_utility.message('INFO','Generated TUPS/TDS succesfully  for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,110);

   hr_dm_utility.message('SUMM','Generated TUPS/TDS successfully for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,120);

 end loop;

 -- set up return values to concurrent manager
 retcode := 0;
 errbuf := 'No errors - examine logfiles for detailed reports.';

 hr_dm_utility.message('ROUT','exit:hr_dm_gen_main.slave_generator',
                        125);
-- error handling
exception
when e_fatal_error then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator',
                       l_fatal_error_message,'R');

  -- if the error is caused because the other process has set the generator phase to 'Error'
  -- then the phase_item_id is 'NULL' , otherwise, the error is caused within this process
  -- while generating TUPS/TDS.

  if l_phase_item_id is not null then
     hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  else
     hr_dm_utility.update_phases(p_new_status => 'E',
                                 p_id => l_phase_id);
  end if;

  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator','(none)','R');
when e_fatal_error2 then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 0;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator',
                       l_fatal_error_message,'R');

  -- if the error is caused because the other process has set the generator phase to 'Error'
  -- then the phase_item_id is 'NULL' , otherwise, the error is caused within this process
  -- while generating TUPS/TDS.

  if l_phase_item_id is not null then
     hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  else
     hr_dm_utility.update_phases(p_new_status => 'E',
                                 p_id => l_phase_id);
  end if;

  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator','(none)','R');
when others then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_gen_main.slave_generator','(none)','R');


end slave_generator ;
end hr_dm_gen_main;

/
