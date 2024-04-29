--------------------------------------------------------
--  DDL for Package Body HR_DM_SEED_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_SEED_DP" as
/* $Header: perdmsed.pkb 120.0 2005/05/31 17:14:08 appldev noship $ */

-- -----------------------  seed_api -------------------------------------
-- Description:
-- Create API module information. This tells the data pump that this is the
-- API which will be used for uploading.
-- ------------------------------------------------------------------------
procedure seed_api
(
   p_module_name                in varchar2,
   p_module_type                in varchar2,
   p_module_package             in varchar2,
   p_data_within_business_group in varchar2   default 'Y',
   p_legislation_code           in varchar2   default null
) is
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_seed_dp.seed_api', 5);
  hr_dm_utility.message('PARA','(p_module_name - ' || p_module_name ||
                             ')(p_module_type - ' || p_module_type ||
                             ')(p_module_package - ' || p_module_package ||
                             ')(p_data_within_business_group - ' ||
                                p_data_within_business_group ||
                             ')(p_legislation_code - ' || p_legislation_code ||
                             ')', 10);

   -- Insert if the API module does not
   -- already exist.
   insert into hr_api_modules (
          api_module_id,
          api_module_type,
          module_name,
          data_within_business_group,
          legislation_code,
          module_package)
   select hr_api_modules_s.nextval,
          p_module_type,
          p_module_name,
          p_data_within_business_group,
          p_legislation_code,
          p_module_package
   from   sys.dual
   where  not exists (
          select null
          from   hr_api_modules m
          where  m.module_name     = p_module_name
          and    m.api_module_type = p_module_type);

  hr_dm_utility.message('ROUT','exit:hr_dm_seed_dp.seed_api', 25);
-- error handling
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.seed_api',
                        '(p_module_name - ' || p_module_name ||
                        ')(p_module_type - ' || p_module_type ||
                        ')(p_module_package - ' || p_module_package ||
                        ')(p_data_within_business_group - ' ||
                           p_data_within_business_group ||
                        ')(p_legislation_code - ' || p_legislation_code ||
                        ')','R');
    raise;
end seed_api;

-- ----------------------- insert_dp_parameters --------------------------------
-- Description:
-- Create API module parameter information.
-- ------------------------------------------------------------------------

procedure insert_dp_parameters
(
   p_module_name    in varchar2,
   p_module_type    in varchar2,
   p_parameter_name in varchar2,
   p_mapping_type   in varchar2   default 'NORMAL',
   p_mapping_def    in varchar2   default null,
   p_default_value  in varchar2   default null
) is
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_seed_dp.insert_dp_parameters', 5);
  hr_dm_utility.message('PARA','(p_module_name - ' || p_module_name ||
                             ')(p_module_type - ' || p_module_type ||
                             ')(p_parameter_name - ' || p_parameter_name ||
                             ')(p_mapping_type - ' || p_mapping_type ||
                             ')(p_mapping_def - ' || p_mapping_def ||
                             ')(p_default_value - ' || p_default_value ||
                             ')', 10);
   -- Insert if the API module does not
   -- already exist.
   insert into hr_pump_module_parameters (
          module_name,
          api_module_type,
          api_parameter_name,
          mapping_type,
          mapping_definition,
          default_value)
   select p_module_name,
          p_module_type,
          ltrim(lpad(p_parameter_name,30)),
          p_mapping_type,
          p_mapping_def,
          p_default_value
   from   sys.dual
   where  not exists (
          select null
          from   hr_pump_module_parameters p
          where  p.module_name        = p_module_name
          and    p.api_module_type    = p_module_type
          and    p.api_parameter_name = p_parameter_name);
  hr_dm_utility.message('ROUT','exit:hr_dm_seed_dp.insert_dp_parameters', 25);
-- error handling
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.insert_dp_parameters',
                       '(p_module_name - ' || p_module_name ||
                       ')(p_module_type - ' || p_module_type ||
                       ')(p_parameter_name - ' || p_parameter_name ||
                       ')(p_mapping_type - ' || p_mapping_type ||
                       ')(p_mapping_def - ' || p_mapping_def ||
                       ')(p_default_value - ' || p_default_value ||
                       ')','R');
    raise;
end insert_dp_parameters;
-- ----------------------- seed_id_parameters --------------------------------
-- Description:
-- Create API module parameter information. All the parameters of the module
-- has to be specifically defined in the data pump so as it should use the
-- value of the parameter passed rather than using the lookup keys.
--
-- ------------------------------------------------------------------------

procedure seed_id_parameters
(
   p_module_name    in  varchar2,
   p_module_type    in  varchar2,
   p_columns_tbl    in  hr_dm_library.t_varchar2_tbl
) is
l_list_index   number;
l_column_name  varchar2(30);
begin

  hr_dm_utility.message('ROUT','entry:hr_dm_seed_dp.seed_id_parameters', 5);
  hr_dm_utility.message('PARA','(p_module_name - ' || p_module_name ||
                             ')(p_module_type - ' || p_module_type ||
                             ')', 10);

  -- initialise the variables
  l_list_index := p_columns_tbl.first;

  --
  -- read all the elements of pl/sql table i.e columns of the SQL table.
  -- if the last three characters are  '_id', then we have to seed this
  -- column name into data pump so as it should not use the user key for
  -- this id column.
  --
  while l_list_index is not null loop
    l_column_name := upper(p_columns_tbl(l_list_index));
    --
    -- Do not assign Business_Group_Id column as data pump knows the value of
    -- business_group_id if the parameter p_omit_business_group_id value is 'Y'
    --
    if substr(l_column_name,-3,3) = '_ID'  and
       l_column_name <> 'BUSINESS_GROUP_ID'
    then
      -- insert the row in data pump parameters table for this column.
      insert_dp_parameters ( p_module_name    => p_module_name,
                             p_module_type    => p_module_type,
                             p_parameter_name => 'P_' || l_column_name);

    end if;
    l_list_index := p_columns_tbl.next(l_list_index);
  end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_seed_dp.seed_id_parameters', 25);
-- error handling
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.seed_id_parameters',
                     '(p_module_name - ' || p_module_name ||
                     ')(p_module_type - ' || p_module_type ||
                     ')','R');
    raise;
end seed_id_parameters;
-- ----------------------- seed_data --------------------------------
-- Description:
-- seed the data pump data for a TUPS.
-- Steps required :
--     seed the TUPS upload module for the table.
--     for each ID column of the table call seed_id_parameter table.
--     if table has a column hierarchy then
--        seed the TUPS upload hierarchy data module as well
--
-- Input Parameters :
--           p_table_info  - Information about table.
--           p_columns_tbl - List of all columns of table.
--           p_seed_type   - Type of TUPS to be seeded.Can have following
--                           values :
--                           'NORMAL' - Normal TUPS procedure to upload data.
--                           'HIERARCHY' - TUPS procedure to update the hierarchy
--
-- --------------------------------------------------------------
procedure seed_data
(
 p_table_info      in   hr_dm_gen_main.t_table_info ,
 p_columns_tbl     in   hr_dm_library.t_varchar2_tbl ,
 p_seed_type       in   varchar2
)

is
   l_module_name         varchar2(30);
   l_module_type         varchar2(30);
   l_module_package      varchar2(30);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_seed_dp.seed_data', 5);
  hr_dm_utility.message('PARA','(p_seed_type - ' || p_seed_type ||
                             ')', 10);
   --
   -- initialise the data. set the standatrd TUPS module and
   -- main upload procedure name
   --
   if p_seed_type = 'NORMAL' then
      l_module_name     := upper('u' ||  p_table_info.short_name);
   else
      l_module_name     := upper('h' ||  p_table_info.short_name);
   end if;

   l_module_type     := 'DM';
   l_module_package  := upper('hrdmu_'|| p_table_info.short_name);

   -- seed the TUPS module
   seed_api ( p_module_name    => l_module_name,
              p_module_type    => l_module_type,
              p_module_package => l_module_package);

   -- seed the parameter id
   seed_id_parameters( p_module_name    => l_module_name,
                       p_module_type    => l_module_type,
                       p_columns_tbl    => p_columns_tbl);
   commit;

   -- generate the view and package for the TUPS module seeded
   -- above.

  hr_dm_utility.message('INFO','Calling datapump meta mapper with ' ||
                        'parameters of (l_module_package - ' ||
                        l_module_package || ')(l_module_name - ' ||
                        l_module_name || ')', 15);
  begin
    hr_pump_meta_mapper.generate(l_module_package,
                                  l_module_name);
    exception
      when others then
      hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.seed_data',
                         'Error from hr_pump_meta_mapper.generate'
                         ,'R');
      raise;
  end;
  hr_dm_utility.message('ROUT','exit:hr_dm_seed_dp.seed_data', 25);
-- error handling
exception
when others then
  hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.seed_data',
                              '(p_seed_type - ' || p_seed_type ||
                               ')','R');
  raise;
end seed_data;
-- ----------------------- main --------------------------------
-- Description:
-- Main program which will seed the data pump data for a TUPS.
--   calls seed_data function to seed the data into data pump.
--   if table has a column hierarchy then it seed the column
--   hierarchy function as well.
--  Input Parameters :
--       p_table_info   -  PL/SQL record containing info about
--                         current table.
--       p_columns_tbl  -  List of all columns of the table.
-- --------------------------------------------------------------
procedure main
(
 p_table_info      in   hr_dm_gen_main.t_table_info ,
 p_columns_tbl     in   hr_dm_library.t_varchar2_tbl
)

is
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_seed_dp.main', 5);
  seed_data(p_table_info    =>  p_table_info,
            p_columns_tbl   =>  p_columns_tbl,
            p_seed_type     => 'NORMAL');

  -- if table has a column hierarchy then seed update hierarchical cols
  -- procedure.

  if p_table_info.column_hierarchy = 'Y' then
    seed_data(p_table_info    =>  p_table_info,
              p_columns_tbl   =>  p_columns_tbl,
              p_seed_type     => 'HIERARCHY');
  end if;
  hr_dm_utility.message('ROUT','exit:hr_dm_seed_dp.main', 25);
-- error handling
exception
when others then
  hr_dm_utility.error(SQLCODE,'hr_dm_seed_dp.main','(none)','R');
  raise;
end main;

end hr_dm_seed_dp ;

/
