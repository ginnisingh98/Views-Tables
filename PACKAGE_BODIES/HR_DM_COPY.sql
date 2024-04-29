--------------------------------------------------------
--  DDL for Package Body HR_DM_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_COPY" as
/* $Header: perdmcp.pkb 115.18 2002/03/07 08:51:10 pkm ship       $ */

--
---------------------------- get_schema -----------------------------
-- This function identifies the scema name used for the passed product
--  Input Parameters
--        p_product - product
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        schema name for passed product

---------------------------------------------------------------------
--
FUNCTION get_schema(p_product IN VARCHAR2) RETURN VARCHAR2 IS
--

l_value BOOLEAN;
l_out_status VARCHAR2(30);
l_out_industry VARCHAR2(30);
l_out_oracle_schema VARCHAR2(30);


--
BEGIN
--

l_value := FND_INSTALLATION.GET_APP_INFO (p_product, l_out_status,
                                          l_out_industry, l_out_oracle_schema);


RETURN(l_out_oracle_schema);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  RAISE;

--
END get_schema;
--



--
----------------------- delete_datapump_tables ----------------------
-- This procedure truncates the following datapump tables
--        hr_pump_batch_headers
--        hr_pump_batch_lines
--        hr_pump_requests
--        hr_pump_ranges
--        hr_pump_batch_exceptions
--        hr_pump_batch_line_user_keys
---------------------------------------------------------------------
procedure delete_datapump_tables is

l_schema varchar2(30);

begin

hr_dm_utility.message('ROUT','entry:hr_dm_copy.delete_datapump_tables', 5);

-- get schema for PER
l_schema := get_schema('PER');


-- disable foreign keys so we can do the truncates
-- hr_pump_batch_lines
begin
  execute immediate 'alter table ' || l_schema ||
      '.HR_PUMP_BATCH_LINE_USER_KEYS ' ||
      ' disable constraint HR_PUMP_BATCH_LINE_USER_KE_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_BATCH_LINE_USER_KE_FK1 - disable', 5);
end;
-- hr_pump_batch_headers
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_BATCH_LINES ' ||
    ' disable constraint HR_PUMP_BATCH_LINES_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_BATCH_LINES_FK1 - disable', 5);
end;
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_RANGES ' ||
    ' disable constraint HR_PUMP_RANGES_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_RANGES_FK1 - disable', 5);
end;
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_REQUESTS ' ||
    ' disable constraint HR_PUMP_REQUESTS_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_REQUESTS_FK1 - disable', 5);
end;



  -- truncate datapump tables. call run_sql procedure to run
  -- 'truncate ddl' command.
hr_dm_utility.message('INFO','Truncating table hr_pump_requests',10);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_requests');

hr_dm_utility.message('INFO','Truncating table hr_pump_ranges',15);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_ranges');

hr_dm_utility.message('INFO',
             'Truncating table hr_pump_batch_exceptions',20);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_batch_exceptions');

hr_dm_utility.message('INFO',
             'Truncating table hr_pump_batch_line_user_keys',25);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_batch_line_user_keys');

hr_dm_utility.message('INFO','Truncating table hr_pump_batch_lines',26);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_batch_lines');

hr_dm_utility.message('INFO',
             'Truncating table hr_pump_batch_headers',30);
hr_dm_library.run_sql('truncate table ' || l_schema ||
                      '.hr_pump_batch_headers');


-- enable foreign keys so we can do the truncates
-- hr_pump_batch_lines
-- disable foreign keys so we can do the truncates
-- hr_pump_batch_lines
begin
  execute immediate 'alter table ' || l_schema ||
      '.HR_PUMP_BATCH_LINE_USER_KEYS ' ||
      ' enable constraint HR_PUMP_BATCH_LINE_USER_KE_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_BATCH_LINE_USER_KE_FK1 - enable', 5);
end;
-- hr_pump_batch_headers
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_BATCH_LINES ' ||
    ' enable constraint HR_PUMP_BATCH_LINES_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_BATCH_LINES_FK1 - enable', 5);
end;
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_RANGES ' ||
    ' enable constraint HR_PUMP_RANGES_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_RANGES_FK1 - enable', 5);
end;
begin
  execute immediate 'alter table ' || l_schema ||
    '.HR_PUMP_REQUESTS ' ||
    ' enable constraint HR_PUMP_REQUESTS_FK1';
  exception
    when others then
      hr_dm_utility.message('INFO',
        'Problem with constraint HR_PUMP_REQUESTS_FK1 - enable', 5);
end;


hr_dm_utility.message('ROUT','exit:hr_dm_copy.delete_datapump_tables', 35);



exception
when others then
  hr_dm_utility.error(SQLCODE,'hr_dm_copy.delete_datapump_tables',
                       '(none)','R');
  raise;
end delete_datapump_tables;


----------------------- source_copy ---------------------------------
-- This procedure does some of the tasks of Copy phase in source
-- database. It does the following :
--    o Insert the data migrator packages rows from HR_API_MODULES
--       table into HR_DM_EXP_API_MODULES_V view based on
--       HR_DM_EXP_IMPS table.
--    o Insert the current migration row from HR_DM_MIGRATIONS tables
--      into  HR_DM_EXP_MIGRATIONS_V view based on  HR_DM_EXP_IMPS table
--    o Inserts the rows for the business_group_id being copied
--      from HR_ALL_ORGANIZATION_UNITS, HR_ORGANIZATION_INFORMATION,
--      HR_ALL_ORGANIZATION_UNITS_TL, HR_LOCATIONS_ALL and
--      HR_LOCATIONS_ALL_TL into HR_DM_EXP_IMPS for a FW migration
--    o Copy the values for the ID_FLEX_STRUCTURE_NAME from the table
--      HR_ORGANIZATION_INFORMATION into HR_DM_EXP_IMPS for a FW migration
-- Input Parameters :
--    p_migration_id - Migration Id of the current migration. Primary
--                     key on hr_dm_migrations table.
--    p_last_migration_date - last migration date
-- Called By : Main controller in source database
---------------------------------------------------------------------
procedure source_copy (p_migration_id number,
                       p_last_migration_date date) is

l_business_group_id number;
l_migration_type varchar2(30);
l_org_information4 varchar2(30);
l_org_information5 varchar2(30);
l_org_information6 varchar2(30);
l_org_information7 varchar2(30);
l_org_information8 varchar2(30);
l_org_information14 varchar2(30);
l_up_phase_used    varchar2(30);


cursor csr_mig_info is
  select business_group_id,
         migration_type
  from hr_dm_migrations
  where migration_id = p_migration_id;

CURSOR csr_phase_rule IS
  SELECT pr.phase_name
    FROM hr_dm_phase_rules pr,
         hr_dm_migrations m
    WHERE m.migration_type = pr.migration_type
      AND pr.phase_name = 'UP'
      AND m.migration_id = p_migration_id;



begin
  hr_dm_utility.message('ROUT','entry:hr_dm_copy.source_copy', 5);
  hr_dm_utility.message('PARA','(p_migration_id  - ' || p_migration_id  ||
                               ')', 10);


-- insert data migrator packages rows from HR_API_MODULES i.e
-- where API_MODULE_TYPE = 'DM' into HR_DM_EXP_API_MODULES_V.
-- only when datapump will be used on the destination

  open csr_phase_rule;
  fetch csr_phase_rule into l_up_phase_used;
  close csr_phase_rule;

  if (l_up_phase_used = 'UP') then
    hr_dm_utility.message('INFO','Inserting row into hr_dm_exp_api_modules_v',15);
    insert into hr_dm_exp_api_modules_v  (exp_imp_id
                                         ,table_name
                                         ,api_module_id
                                         ,api_module_type
                                         ,module_name
                                         ,data_within_business_group
                                         ,legislation_code
                                         ,module_package
                                         ,last_update_date
                                         ,last_updated_by
                                         ,last_update_login
                                         ,created_by
                                         ,creation_date )
                                 select   hr_dm_exp_imps_s.nextval
                                         ,'HR_API_MODULES'
                                         ,api_module_id
                                         ,api_module_type
                                         ,module_name
                                         ,data_within_business_group
                                         ,legislation_code
                                         ,module_package
                                         ,to_char(last_update_date,'YYYYMMDD HH24:MI:SS')
                                         ,last_updated_by
                                         ,last_update_login
                                         ,created_by
                                         ,to_char(creation_date,'YYYYMMDD HH24:MI:SS')
                                 from hr_api_modules ai
                                 where api_module_type = 'DM'
                                   and not exists (select null
                                       from hr_dm_exp_api_modules_v v
                                       where v.api_module_id = ai.api_module_id);
  end if;


  -- Insert the current migration row from HR_DM_MIGRATIONS tables
  -- into  HR_DM_EXP_MIGRATIONS_V view based on  HR_DM_EXP_IMPS table

  hr_dm_utility.message('INFO','Inserting row into hr_dm_exp_migrations_v',20);
  insert into hr_dm_exp_migrations_v  ( exp_imp_id
                                       ,table_name
                                       ,migration_id
                                       ,source_database_instance
                                       ,destination_database_instance
                                       ,migration_type
                                       ,application_id
                                       ,business_group_id
                                       ,business_group_name
                                       ,migration_start_date
                                       ,migration_end_date
                                       ,status
                                       ,effective_date
                                       ,migration_count
                                       ,selective_migration_criteria
                                       ,active_group
                                       ,last_update_date
                                       ,last_updated_by
                                       ,last_update_login
                                       ,created_by
                                       ,creation_date )
                               select   hr_dm_exp_imps_s.nextval
                                       ,'HR_DM_MIGRATIONS'
                                       ,migration_id
                                       ,source_database_instance
                                       ,destination_database_instance
                                       ,migration_type
                                       ,application_id
                                       ,business_group_id
                                       ,business_group_name
                                       ,migration_start_date
                                       ,migration_end_date
                                       ,'NS'
                                       ,effective_date
                                       ,migration_count
                                       ,selective_migration_criteria
                                       ,active_group
                                       ,to_char(last_update_date,'YYYYMMDD HH24:MI:SS')
                                       ,last_updated_by
                                       ,last_update_login
                                       ,created_by
                                       ,to_char(creation_date,'YYYYMMDD HH24:MI:SS')
                               from hr_dm_migrations dm
                               where migration_id = p_migration_id
                                   and not exists (select null
                                       from hr_dm_exp_migrations_v v
                                       where v.migration_id = dm.migration_id);


-- find the business_group_id and migration type for the current migration
  open csr_mig_info;
  fetch csr_mig_info into l_business_group_id, l_migration_type;
  close csr_mig_info;

-- only perform for an FW migration

  if (l_migration_type = 'FW') then

    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_HR_LOC_ALL_V',15);
    insert into HR_DM_EXP_HR_LOC_ALL_V (
      EXP_IMP_ID,
      TABLE_NAME,
      LOCATION_ID,
      LOCATION_CODE,
      BUSINESS_GROUP_ID,
      DESCRIPTION,
      SHIP_TO_LOCATION_ID,
      SHIP_TO_SITE_FLAG,
      RECEIVING_SITE_FLAG,
      BILL_TO_SITE_FLAG,
      IN_ORGANIZATION_FLAG,
      OFFICE_SITE_FLAG,
      DESIGNATED_RECEIVER_ID,
      INVENTORY_ORGANIZATION_ID,
      TAX_NAME,
      INACTIVE_DATE,
      STYLE,
      ADDRESS_LINE_1,
      ADDRESS_LINE_2,
      ADDRESS_LINE_3,
      TOWN_OR_CITY,
      COUNTRY,
      POSTAL_CODE,
      REGION_1,
      REGION_2,
      REGION_3,
      TELEPHONE_NUMBER_1,
      TELEPHONE_NUMBER_2,
      TELEPHONE_NUMBER_3,
      LOC_INFORMATION13,
      LOC_INFORMATION14,
      LOC_INFORMATION15,
      LOC_INFORMATION16,
      LOC_INFORMATION17,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      ENTERED_BY,
      TP_HEADER_ID,
      ECE_TP_LOCATION_CODE,
      OBJECT_VERSION_NUMBER)
      select
      hr_dm_exp_imps_s.nextval,
      'HR_LOCATIONS_ALL',
      LOCATION_ID,
      LOCATION_CODE,
      BUSINESS_GROUP_ID,
      DESCRIPTION,
      SHIP_TO_LOCATION_ID,
      SHIP_TO_SITE_FLAG,
      RECEIVING_SITE_FLAG,
      BILL_TO_SITE_FLAG,
      IN_ORGANIZATION_FLAG,
      OFFICE_SITE_FLAG,
      DESIGNATED_RECEIVER_ID,
      INVENTORY_ORGANIZATION_ID,
      TAX_NAME,
      to_char(INACTIVE_DATE,'YYYYMMDD HH24:MI:SS'),
      STYLE,
      ADDRESS_LINE_1,
      ADDRESS_LINE_2,
      ADDRESS_LINE_3,
      TOWN_OR_CITY,
      COUNTRY,
      POSTAL_CODE,
      REGION_1,
      REGION_2,
      REGION_3,
      TELEPHONE_NUMBER_1,
      TELEPHONE_NUMBER_2,
      TELEPHONE_NUMBER_3,
      LOC_INFORMATION13,
      LOC_INFORMATION14,
      LOC_INFORMATION15,
      LOC_INFORMATION16,
      LOC_INFORMATION17,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS'),
      ENTERED_BY,
      TP_HEADER_ID,
      ECE_TP_LOCATION_CODE,
      OBJECT_VERSION_NUMBER
    from HR_LOCATIONS_ALL
    where BUSINESS_GROUP_ID = l_business_group_id
      or BUSINESS_GROUP_ID is null;

-- remove entries for HR_LOCATIONS_ALL in the table hr_pump_batch lines
-- that match the where clause used to migrate via HR_DM_EXP_IMPS table
-- Note that the view already matches the where clause
    hr_dm_utility.message('INFO','Removing HR_LOCATIONS_ALL rows from hr_pump_batch_lines',15);
-- use dynamic sql to avoid compiliation errors where the data pump views
-- have not yet been created
  execute immediate 'delete HRDPV_UHR_LOCATIONS_ALL';

    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_HR_LOC_ALL_TL_V',15);
    insert into HR_DM_EXP_HR_LOC_ALL_TL_V (
      EXP_IMP_ID,
      TABLE_NAME,
      LOCATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      LOCATION_CODE,
      DESCRIPTION,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
      select
      hr_dm_exp_imps_s.nextval,
      'HR_LOCATIONS_ALL_TL',
      LOCATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      LOCATION_CODE,
      DESCRIPTION,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_LOCATIONS_ALL_TL
    where LOCATION_ID in (
      select LOCATION_ID
        from HR_LOCATIONS_ALL
        where BUSINESS_GROUP_ID = l_business_group_id)
      or LOCATION_ID in (
      select LOCATION_ID
        from HR_LOCATIONS_ALL
        where BUSINESS_GROUP_ID is null);

-- remove entries for HR_LOCATIONS_ALL_TL in the table hr_pump_batch lines
-- that match the where clause used to migrate via HR_DM_EXP_IMPS table
    hr_dm_utility.message('INFO','Removing HR_LOCATIONS_ALL_TL rows from hr_pump_batch_lines',15);
-- use dynamic sql to avoid compiliation errors where the data pump views
-- have not yet been created
  execute immediate 'delete HRDPV_UHR_LOCATIONS_ALL_TL ' ||
                    'where p_LOCATION_ID in ( ' ||
                    '  select to_char(LOCATION_ID) ' ||
                    '    from HR_LOCATIONS_ALL ' ||
                    '    where BUSINESS_GROUP_ID = ' ||
                    l_business_group_id || ')';
  execute immediate 'delete HRDPV_UHR_LOCATIONS_ALL_TL ' ||
                    'where p_LOCATION_ID in ( ' ||
                    '  select to_char(LOCATION_ID) ' ||
                    '    from HR_LOCATIONS_ALL ' ||
                    '    where BUSINESS_GROUP_ID is null' || ')';


    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_ALL_ORG_UNITS_V',15);
-- the comments column has been removed as it is a long data type
    insert into HR_DM_EXP_ALL_ORG_UNITS_V (
      EXP_IMP_ID,
      TABLE_NAME,
      ORGANIZATION_ID,
      BUSINESS_GROUP_ID,
      COST_ALLOCATION_KEYFLEX_ID,
      LOCATION_ID,
      SOFT_CODING_KEYFLEX_ID,
      DATE_FROM,
      NAME,
      DATE_TO,
      INTERNAL_EXTERNAL_FLAG,
      INTERNAL_ADDRESS_LINE,
      TYPE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
      select
      hr_dm_exp_imps_s.nextval,
      'HR_ALL_ORGANIZATION_UNITS',
      ORGANIZATION_ID,
      BUSINESS_GROUP_ID,
      COST_ALLOCATION_KEYFLEX_ID,
      LOCATION_ID,
      SOFT_CODING_KEYFLEX_ID,
      to_char(DATE_FROM,'YYYYMMDD HH24:MI:SS'),
      NAME,
      to_char(DATE_TO,'YYYYMMDD HH24:MI:SS'),
      INTERNAL_EXTERNAL_FLAG,
      INTERNAL_ADDRESS_LINE,
      TYPE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      to_char(PROGRAM_UPDATE_DATE,'YYYYMMDD HH24:MI:SS'),
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_ALL_ORGANIZATION_UNITS
    where BUSINESS_GROUP_ID = l_business_group_id;

-- remove entries for HR_ALL_ORGANIZATION_UNITS in the table hr_pump_batch lines
-- that match the where clause used to migrate via HR_DM_EXP_IMPS table
-- Note that the view already matches the where clause
    hr_dm_utility.message('INFO','Removing HR_ALL_ORGANIZATION_UNITS rows from hr_pump_batch_lines',15);
-- use dynamic sql to avoid compiliation errors where the data pump views
-- have not yet been created
    execute immediate 'delete HRDPV_UHR_ALL_ORGANIZATONUNITS';

    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_ORG_INFO_V',15);
    insert into HR_DM_EXP_ORG_INFO_V (
      EXP_IMP_ID,
      TABLE_NAME,
      ORG_INFORMATION_ID,
      ORG_INFORMATION_CONTEXT,
      ORGANIZATION_ID,
      ORG_INFORMATION1,
      ORG_INFORMATION10,
      ORG_INFORMATION11,
      ORG_INFORMATION12,
      ORG_INFORMATION13,
      ORG_INFORMATION14,
      ORG_INFORMATION15,
      ORG_INFORMATION16,
      ORG_INFORMATION17,
      ORG_INFORMATION18,
      ORG_INFORMATION19,
      ORG_INFORMATION2,
      ORG_INFORMATION20,
      ORG_INFORMATION3,
      ORG_INFORMATION4,
      ORG_INFORMATION5,
      ORG_INFORMATION6,
      ORG_INFORMATION7,
      ORG_INFORMATION8,
      ORG_INFORMATION9,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
    select
      hr_dm_exp_imps_s.nextval,
      'HR_ORGANIZATION_INFORMATION',
      ORG_INFORMATION_ID,
      ORG_INFORMATION_CONTEXT,
      ORGANIZATION_ID,
      ORG_INFORMATION1,
      ORG_INFORMATION10,
      ORG_INFORMATION11,
      ORG_INFORMATION12,
      ORG_INFORMATION13,
      ORG_INFORMATION14,
      ORG_INFORMATION15,
      ORG_INFORMATION16,
      ORG_INFORMATION17,
      ORG_INFORMATION18,
      ORG_INFORMATION19,
      ORG_INFORMATION2,
      ORG_INFORMATION20,
      ORG_INFORMATION3,
      ORG_INFORMATION4,
      ORG_INFORMATION5,
      ORG_INFORMATION6,
      ORG_INFORMATION7,
      ORG_INFORMATION8,
      ORG_INFORMATION9,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      to_char(PROGRAM_UPDATE_DATE,'YYYYMMDD HH24:MI:SS'),
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_ORGANIZATION_INFORMATION
    where ORGANIZATION_ID in (
      select ORGANIZATION_ID
        from HR_ALL_ORGANIZATION_UNITS
        where BUSINESS_GROUP_ID = l_business_group_id);

-- remove entries for HR_ORGANIZATION_INFORMATION in the table hr_pump_batch lines
-- that match the where clause used to migrate via HR_DM_EXP_IMPS table
    hr_dm_utility.message('INFO','Removing HR_ALL_ORGANIZATION_UNITS rows from hr_pump_batch_lines',15);
-- use dynamic sql to avoid compiliation errors where the data pump views
-- have not yet been created
  execute immediate 'delete HRDPV_UHR_ORGANIZATNINFORMATON ' ||
                    '  where p_ORGANIZATION_ID in ( ' ||
                    '    select to_char(ORGANIZATION_ID) ' ||
                    '      from HR_ALL_ORGANIZATION_UNITS ' ||
                    '      where BUSINESS_GROUP_ID = ' ||
                    l_business_group_id || ')';

    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_ALL_ORG_UNITS_TL_V',15);
    insert into HR_DM_EXP_ALL_ORG_UNITS_TL_V (
      EXP_IMP_ID,
      TABLE_NAME,
      ORGANIZATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      NAME,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
    select
      hr_dm_exp_imps_s.nextval,
      'HR_ALL_ORGANIZATION_UNITS_TL',
      ORGANIZATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      NAME,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_ALL_ORGANIZATION_UNITS_TL
    where ORGANIZATION_ID in (
      select ORGANIZATION_ID
        from HR_ALL_ORGANIZATION_UNITS
        where BUSINESS_GROUP_ID = l_business_group_id);

-- remove entries for HR_ALL_ORGANIZATION_UNITS_TL in the table hr_pump_batch lines
-- that match the where clause used to migrate via HR_DM_EXP_IMPS table
    hr_dm_utility.message('INFO','Removing HR_ALL_ORGANIZATION_UNITS_TL rows from hr_pump_batch_lines',15);
-- use dynamic sql to avoid compiliation errors where the data pump views
-- have not yet been created
  execute immediate 'delete HRDPV_UHR_ALL_ORGANZTNUNITS_TL ' ||
                    '  where p_ORGANIZATION_ID in ( ' ||
                    '    select to_char(ORGANIZATION_ID) ' ||
                    '      from HR_ALL_ORGANIZATION_UNITS ' ||
                    '      where BUSINESS_GROUP_ID = ' ||
                    l_business_group_id || ')';

    end if;


-- copy the flex structure info
-- only perform for an FW  or A migration
  if (l_migration_type in ('FW', 'A')) then

-- copy across the ID_FLEX_STRUCTURE_NAMEs for the current business group
    hr_dm_utility.message('INFO','copy across the ID_FLEX_STRUCTURE_NAMEs',15);

    select ID_FLEX_STRUCTURE_NAME
      into l_org_information4
      from fnd_id_flex_structures_vl
      where id_flex_num = (select org_information4
                             from hr_organization_information
                             where org_information_context =
                                                  'Business Group Information'
                               and organization_id = l_business_group_id)
        and ID_FLEX_CODE = 'GRD';
    select ID_FLEX_STRUCTURE_NAME
      into l_org_information5
      from fnd_id_flex_structures_vl
      where id_flex_num = (select org_information5
                             from hr_organization_information
                             where org_information_context =
                                                  'Business Group Information'
                               and organization_id = l_business_group_id)
        and ID_FLEX_CODE = 'GRP';
    select ID_FLEX_STRUCTURE_NAME
      into l_org_information6
      from fnd_id_flex_structures_vl
      where id_flex_num = (select org_information6
                             from hr_organization_information
                             where org_information_context =
                                                  'Business Group Information'
                               and organization_id = l_business_group_id)
        and ID_FLEX_CODE = 'JOB';
    select ID_FLEX_STRUCTURE_NAME
      into l_org_information7
      from fnd_id_flex_structures_vl
      where id_flex_num = (select org_information7
                             from hr_organization_information
                             where org_information_context =
                                                  'Business Group Information'
                               and organization_id = l_business_group_id)
        and ID_FLEX_CODE = 'COST';
    select ID_FLEX_STRUCTURE_NAME
      into l_org_information8
      from fnd_id_flex_structures_vl
      where id_flex_num = (select org_information8
                             from hr_organization_information
                             where org_information_context =
                                                  'Business Group Information'
                               and organization_id = l_business_group_id)
        and ID_FLEX_CODE = 'POS';
    select SECURITY_GROUP_KEY
      into l_org_information14
      from fnd_security_groups_vl
      where security_group_id = (select org_information14
                                   from hr_organization_information
                                   where org_information_context =
                                                  'Business Group Information'
                                     and organization_id = l_business_group_id);

    insert into hr_dm_exp_hr_org_inf_flx_v (
      EXP_IMP_ID,
      TABLE_NAME,
      ORG_INFORMATION4,
      ORG_INFORMATION5,
      ORG_INFORMATION6,
      ORG_INFORMATION7,
      ORG_INFORMATION8,
      ORG_INFORMATION14)
    select
      hr_dm_exp_imps_s.nextval,
      'HR_ORG_INF_FLX',
      l_org_information4,
      l_org_information5,
      l_org_information6,
      l_org_information7,
      l_org_information8,
      l_org_information14
    from dual;

  end if;


-- copy the ben_batch_parameter info
-- only perform for an FW  or A migration

  if (l_migration_type in ('FW', 'A')) then

    hr_dm_utility.message('INFO','Inserting row(s) into HR_DM_EXP_BEN_BATCH_PARAS_V',15);
    insert into HR_DM_EXP_BEN_BATCH_PARAS_V (
      EXP_IMP_ID,
      TABLE_NAME,
      BATCH_PARAMETER_ID,
      BATCH_EXE_CD,
      THREAD_CNT_NUM,
      MAX_ERR_NUM,
      CHUNK_SIZE,
      BUSINESS_GROUP_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      OBJECT_VERSION_NUMBER)
    select
      hr_dm_exp_imps_s.nextval,
      'BEN_BATCH_PARAMETER',
      batch_parameter_id,
      batch_exe_cd,
      thread_cnt_num,
      max_err_num,
      chunk_size,
      business_group_id,
      to_char(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_char(creation_date,'YYYYMMDD HH24:MI:SS'),
      object_version_number
    from BEN_BATCH_PARAMETER
    where business_group_id = l_business_group_id
      and batch_exe_cd = 'HRDM'
      and last_update_date >= nvl(p_last_migration_date,
                                  last_update_date);

-- remove entry for data migrator from the batch lines table
  execute immediate 'delete HRDPV_UBEN_BATCH_PARAMETER ' ||
                    '  where p_batch_exe_cd = ''HRDM''';

  end if;

  commit;
  hr_dm_utility.message('ROUT','exit:hr_dm_copy.source_copy', 25);
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_copy.source_copy',
                         '(none)','R');
    raise;
end source_copy;

----------------------- destination_copy ---------------------------------
-- This procedure does some of the tasks of Copy phase in source
-- database. It does the following :
-- o Call procedure delete_datapump_tables to truncate datapump tables
--   at destination.
-- o Delete the data migrator packages rows from HR_API_MODULES table
--   i.e  API_MODULE_TYPE ='DM'.
-- o Insert the rows into HR_API_MODULES tables from HR_DM_EXP_IMP table
-- o Insert the row into HR_DM_MIGRATION table from HR_DM_EXP_IMP table
-- o Inserts the rows for the business_group_id being copied
--   from HR_DM_EXP_IMPS into HR_ALL_ORGANIZATION_UNITS,
--   HR_ORGANIZATION_INFORMATION, HR_ALL_ORGANIZATION_UNITS_TL
--   HR_LOCATIONS_ALL and HR_LOCATIONS_ALL_TL
--   (for an FW migration only)
-- o Update the row in the HR_DM_MIGRATIONS table to show that the business
--   group has been created (for an FW migration only)
-- Called By : Run manually.
---------------------------------------------------------------------
procedure destination_copy is

l_migration_type         varchar2(30);
l_migration_id           number;
l_business_group_id      number;
l_exist_bgroup_id        number;
e_fatal_error            exception;
l_source                 varchar2(30);
l_destination            varchar2(30);
l_migration_type_meaning varchar2(100);
l_business_group_name    hr_dm_migrations.business_group_name%type;
l_migration_start_date   date;
l_cr                     varchar2(10);
l_database_location      varchar2(30);
l_up_phase_used          varchar2(30);
l_batch_exe_cd           varchar2(30);
l_thread_cnt_num         number;
l_max_err_num            number;
l_chunk_size             number;
l_object_version_number  number;
l_batch_parameter_id     number;
l_schema 		 varchar2(30);


cursor csr_mig_info is
  select migration_type,
         business_group_id,
         source_database_instance,
         destination_database_instance,
         hr_general.decode_lookup('HR_DM_MIGRATION_TYPE',migration_type),
         business_group_name,
         migration_start_date
    from hr_dm_exp_migrations_v;

cursor csr_bg_check is
  select business_group_id
    from per_business_groups
  where business_group_id = l_business_group_id;

cursor csr_database is
  select upper(name)
    from v$database;

cursor csr_phase_rule is
  select phase_name
    from hr_dm_phase_rules
    where migration_type = l_migration_type
      and phase_name = 'UP';

cursor csr_batch_info is
  select
    batch_exe_cd,
    thread_cnt_num,
    max_err_num,
    chunk_size,
    object_version_number
  from HR_DM_EXP_BEN_BATCH_PARAS_V
  where (business_group_id = to_char(l_business_group_id))
    and (batch_exe_cd = 'HRDM');

cursor csr_batch_info_db is
  select
    batch_parameter_id
  from ben_batch_parameter
  where (business_group_id = l_business_group_id)
    and (batch_exe_cd = 'HRDM');

begin

-- set up data output
hr_utility.set_trace_options('TRACE_DEST:DBMS_OUTPUT');
hr_utility.trace_on;

-- get schema for PER
l_schema := get_schema('PER');


l_cr := fnd_global.local_chr(10);

-- check if migration is possible

-- find the migration type for the current migration
  open csr_mig_info;
  fetch csr_mig_info into l_migration_type,
                          l_business_group_id,
                          l_source,
                          l_destination,
                          l_migration_type_meaning,
                          l_business_group_name,
                          l_migration_start_date;
  close csr_mig_info;

-- find the database we are on now
  open csr_database;
  loop
    fetch csr_database into l_database_location;
    exit when csr_database%notfound;
  end loop;
  close csr_database;


-- display information about the migration
  hr_utility.trace(l_cr);
  hr_utility.trace('HR Data Migrator');
  hr_utility.trace(l_cr);
  hr_utility.trace('Migration details');
  hr_utility.trace('Type           : ' || l_migration_type_meaning);
  hr_utility.trace('Source         : ' || l_source);
  hr_utility.trace('Destination    : ' || l_destination);
  hr_utility.trace('Business group : ' || l_business_group_name);
  hr_utility.trace('Start Date     : ' || l_migration_start_date);
  hr_utility.trace(l_cr);


-- do some validation
  hr_utility.trace('Validating migration...');
  hr_utility.trace(l_cr);

-- make sure we are on the destination database
  if (upper(l_destination) <> l_database_location) then
    hr_utility.trace('Invalid migration :');
    hr_utility.trace(l_cr);
    hr_utility.trace('This is not the destination database.');
    hr_utility.trace('Current database     : ' || l_database_location);
    hr_utility.trace('Destination database : ' || l_destination);
    hr_utility.trace('This migration can not proceed on this database.');
    hr_utility.trace(l_cr);
    raise e_fatal_error;
  end if;



-- see if the business group already exists
  open csr_bg_check;
  fetch csr_bg_check into l_exist_bgroup_id;
  close csr_bg_check;

  if (l_exist_bgroup_id is null) and
     (l_migration_type <> 'FW') then
-- For a non-FW migration the business group must exist
    hr_utility.trace('Invalid migration :');
    hr_utility.trace(l_cr);
    hr_utility.trace('For a non-FW migration the business group must exist.');
    hr_utility.trace('This migration can not proceed.');
    hr_utility.trace(l_cr);
    raise e_fatal_error;
  end if;

  if (l_exist_bgroup_id is not null) and
     (l_migration_type = 'FW') then
-- For an FW migration the business group must not exist
    hr_utility.trace('Invalid migration :');
    hr_utility.trace(l_cr);
    hr_utility.trace('For an FW migration the business group must not exist.');
    hr_utility.trace('This migration can not proceed.');
    hr_utility.trace(l_cr);
    raise e_fatal_error;
  end if;

  hr_utility.trace('Migration passed validation checks.');
  hr_utility.trace(l_cr);

  hr_utility.trace('Importing migration details...');
  hr_utility.trace(l_cr);
  hr_utility.trace('  Truncating hr_dm_dt_deletes');
  hr_dm_library.run_sql('truncate table ' || l_schema ||
                        '.hr_dm_dt_deletes');

  hr_utility.trace('  Setting g_data_migrator_mode to Y');
  hr_general.g_data_migrator_mode:='Y';


-- import API details only if we are using datapump

  open csr_phase_rule;
  fetch csr_phase_rule into l_up_phase_used;
  close csr_phase_rule;

  if (l_up_phase_used = 'UP') then

    hr_utility.trace('Importing API details...');
    hr_utility.trace('(Errors may be seen if contraint does not exist).');
    hr_utility.trace(l_cr);

-- disable constraint on HR_PUMP_BATCH_LINES
-- so we can delete from HR_API_MODULES
    hr_utility.trace('  Disabling constraint - HR_PUMP_BATCH_LINES_FK2');
    begin
      execute immediate 'alter table ' || l_schema ||
      '.HR_PUMP_BATCH_LINES ' ||
      ' disable constraint HR_PUMP_BATCH_LINES_FK2';
      exception
        when others then
          hr_utility.trace('Error whilst disabling constraint');
          hr_utility.trace(sqlerrm(sqlcode));
    end;


    hr_utility.trace('  Call delete hr_api_modules');
-- delete data migrator packages rows from HR_API_MODULES.
    delete hr_api_modules
      where api_module_type = 'DM';


    hr_utility.trace('  Updating hr_api_modules');
-- Insert the rows into HR_API_MODULES tables from HR_DM_EXP_API_MODULES_V
-- table.

    insert into hr_api_modules ( api_module_id
                                ,api_module_type
                                ,module_name
                                ,data_within_business_group
                                ,legislation_code
                                ,module_package
                                ,last_update_date
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,creation_date )
                        select  api_module_id
                                ,api_module_type
                                ,module_name
                                ,data_within_business_group
                                ,legislation_code
                                ,module_package
                                ,to_date(last_update_date,'YYYYMMDD HH24:MI:SS')
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,to_date(creation_date,'YYYYMMDD HH24:MI:SS')
                        from hr_dm_exp_api_modules_v;


-- now re-enable constraint on HR_PUMP_BATCH_LINES
    hr_utility.trace('Enabling constraint - HR_PUMP_BATCH_LINES_FK2');
    begin
      execute immediate 'alter table ' || l_schema ||
      '.HR_PUMP_BATCH_LINES ' ||
      ' enable constraint HR_PUMP_BATCH_LINES_FK2';
      exception
        when others then
          hr_utility.trace('Error whilst enabling constraint');
          hr_utility.trace(sqlerrm(sqlcode));
    end;

  end if;


     hr_utility.trace('call insert into hr_dm_migrations');
  -- Insert the current migration row from HR_DM_MIGRATIONS tables
  -- into  HR_DM_EXP_MIGRATIONS_V view based on  HR_DM_EXP_IMPS table

  select hr_dm_migrations_s.nextval
    into l_migration_id
    from dual;

  insert into hr_dm_migrations ( migration_id
                                ,source_database_instance
                                ,destination_database_instance
                                ,migration_type
                                ,application_id
                                ,business_group_id
                                ,business_group_name
                                ,migration_start_date
                                ,migration_end_date
                                ,status
                                ,effective_date
                                ,migration_count
                                ,selective_migration_criteria
                                ,active_group
                                ,last_update_date
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,creation_date )
                        select   l_migration_id
                                ,source_database_instance
                                ,destination_database_instance
                                ,migration_type
                                ,application_id
                                ,business_group_id
                                ,business_group_name
                                ,migration_start_date
                                ,migration_end_date
                                ,status
                                ,effective_date
                                ,migration_count
                                ,selective_migration_criteria
                                ,active_group
                                ,to_date(last_update_date,'YYYYMMDD HH24:MI:SS')
                                ,last_updated_by
                                ,last_update_login
                                ,created_by
                                ,to_date(creation_date,'YYYYMMDD HH24:MI:SS')
                        from hr_dm_exp_migrations_v;




-- only perform for an FW migration

  if (l_migration_type = 'FW') then

    hr_utility.trace('Creating business group.');

    insert into HR_LOCATIONS_ALL (
      LOCATION_ID,
      LOCATION_CODE,
      BUSINESS_GROUP_ID,
      DESCRIPTION,
      SHIP_TO_LOCATION_ID,
      SHIP_TO_SITE_FLAG,
      RECEIVING_SITE_FLAG,
      BILL_TO_SITE_FLAG,
      IN_ORGANIZATION_FLAG,
      OFFICE_SITE_FLAG,
      DESIGNATED_RECEIVER_ID,
      INVENTORY_ORGANIZATION_ID,
      TAX_NAME,
      INACTIVE_DATE,
      STYLE,
      ADDRESS_LINE_1,
      ADDRESS_LINE_2,
      ADDRESS_LINE_3,
      TOWN_OR_CITY,
      COUNTRY,
      POSTAL_CODE,
      REGION_1,
      REGION_2,
      REGION_3,
      TELEPHONE_NUMBER_1,
      TELEPHONE_NUMBER_2,
      TELEPHONE_NUMBER_3,
      LOC_INFORMATION13,
      LOC_INFORMATION14,
      LOC_INFORMATION15,
      LOC_INFORMATION16,
      LOC_INFORMATION17,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      last_update_date,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      creation_date,
      ENTERED_BY,
      TP_HEADER_ID,
      ECE_TP_LOCATION_CODE,
      OBJECT_VERSION_NUMBER)
      select
      LOCATION_ID,
      LOCATION_CODE,
      BUSINESS_GROUP_ID,
      DESCRIPTION,
      SHIP_TO_LOCATION_ID,
      SHIP_TO_SITE_FLAG,
      RECEIVING_SITE_FLAG,
      BILL_TO_SITE_FLAG,
      IN_ORGANIZATION_FLAG,
      OFFICE_SITE_FLAG,
      DESIGNATED_RECEIVER_ID,
      INVENTORY_ORGANIZATION_ID,
      TAX_NAME,
      to_date(INACTIVE_DATE,'YYYYMMDD HH24:MI:SS'),
      STYLE,
      ADDRESS_LINE_1,
      ADDRESS_LINE_2,
      ADDRESS_LINE_3,
      TOWN_OR_CITY,
      COUNTRY,
      POSTAL_CODE,
      REGION_1,
      REGION_2,
      REGION_3,
      TELEPHONE_NUMBER_1,
      TELEPHONE_NUMBER_2,
      TELEPHONE_NUMBER_3,
      LOC_INFORMATION13,
      LOC_INFORMATION14,
      LOC_INFORMATION15,
      LOC_INFORMATION16,
      LOC_INFORMATION17,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      to_date(creation_date,'YYYYMMDD HH24:MI:SS'),
      ENTERED_BY,
      TP_HEADER_ID,
      ECE_TP_LOCATION_CODE,
      OBJECT_VERSION_NUMBER
      from HR_DM_EXP_HR_LOC_ALL_V dmv
      where not exists (select null
                        from HR_LOCATIONS_ALL tb
                        where dmv.location_id = tb.LOCATION_ID);

    insert into HR_LOCATIONS_ALL_TL (
      LOCATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      LOCATION_CODE,
      DESCRIPTION,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
      select
      LOCATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      LOCATION_CODE,
      DESCRIPTION,
      to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      to_date(creation_date,'YYYYMMDD HH24:MI:SS')
      from HR_DM_EXP_HR_LOC_ALL_TL_V dmv
      where not exists (select null
                        from HR_LOCATIONS_ALL_TL tb
                        where dmv.location_id = tb.LOCATION_ID);




-- the comments column has been removed
    insert into HR_ALL_ORGANIZATION_UNITS (
      ORGANIZATION_ID,
      BUSINESS_GROUP_ID,
      COST_ALLOCATION_KEYFLEX_ID,
      LOCATION_ID,
      SOFT_CODING_KEYFLEX_ID,
      DATE_FROM,
      NAME,
      DATE_TO,
      INTERNAL_EXTERNAL_FLAG,
      INTERNAL_ADDRESS_LINE,
      TYPE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
      select
      ORGANIZATION_ID,
      BUSINESS_GROUP_ID,
      COST_ALLOCATION_KEYFLEX_ID,
      LOCATION_ID,
      SOFT_CODING_KEYFLEX_ID,
      to_date(DATE_FROM,'YYYYMMDD HH24:MI:SS'),
      NAME,
      to_date(DATE_TO,'YYYYMMDD HH24:MI:SS'),
      INTERNAL_EXTERNAL_FLAG,
      INTERNAL_ADDRESS_LINE,
      TYPE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      to_date(PROGRAM_UPDATE_DATE,'YYYYMMDD HH24:MI:SS'),
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_date(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_DM_EXP_ALL_ORG_UNITS_V;

    insert into HR_ORGANIZATION_INFORMATION (
      ORG_INFORMATION_ID,
      ORG_INFORMATION_CONTEXT,
      ORGANIZATION_ID,
      ORG_INFORMATION1,
      ORG_INFORMATION10,
      ORG_INFORMATION11,
      ORG_INFORMATION12,
      ORG_INFORMATION13,
      ORG_INFORMATION14,
      ORG_INFORMATION15,
      ORG_INFORMATION16,
      ORG_INFORMATION17,
      ORG_INFORMATION18,
      ORG_INFORMATION19,
      ORG_INFORMATION2,
      ORG_INFORMATION20,
      ORG_INFORMATION3,
      ORG_INFORMATION4,
      ORG_INFORMATION5,
      ORG_INFORMATION6,
      ORG_INFORMATION7,
      ORG_INFORMATION8,
      ORG_INFORMATION9,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
    select
      ORG_INFORMATION_ID,
      ORG_INFORMATION_CONTEXT,
      ORGANIZATION_ID,
      ORG_INFORMATION1,
      ORG_INFORMATION10,
      ORG_INFORMATION11,
      ORG_INFORMATION12,
      ORG_INFORMATION13,
      ORG_INFORMATION14,
      ORG_INFORMATION15,
      ORG_INFORMATION16,
      ORG_INFORMATION17,
      ORG_INFORMATION18,
      ORG_INFORMATION19,
      ORG_INFORMATION2,
      ORG_INFORMATION20,
      ORG_INFORMATION3,
      ORG_INFORMATION4,
      ORG_INFORMATION5,
      ORG_INFORMATION6,
      ORG_INFORMATION7,
      ORG_INFORMATION8,
      ORG_INFORMATION9,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      to_date(PROGRAM_UPDATE_DATE,'YYYYMMDD HH24:MI:SS'),
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_date(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_DM_EXP_ORG_INFO_V;

    insert into HR_ALL_ORGANIZATION_UNITS_TL (
      ORGANIZATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      NAME,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE)
    select
      ORGANIZATION_ID,
      LANGUAGE,
      SOURCE_LANG,
      NAME,
      to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
      last_updated_by,
      last_update_login,
      created_by,
      to_date(creation_date,'YYYYMMDD HH24:MI:SS')
    from HR_DM_EXP_ALL_ORG_UNITS_TL_V;

    update hr_dm_migrations
      set business_group_created = 'Y'
      where migration_id = l_migration_id;


  end if;

-- copy the ben_batch_parameter info
-- only perform for an FW  or A migration

  if (l_migration_type in ('FW', 'A')) then
    hr_utility.trace('Importing BEN_BATCH_PARAMETER information.');

    open csr_batch_info;
    fetch csr_batch_info into
      l_batch_exe_cd,
      l_thread_cnt_num,
      l_max_err_num,
      l_chunk_size,
      l_object_version_number;

    if csr_batch_info%found then
-- data exists from the source database,
-- so check if we need to update or insert

      open csr_batch_info_db;
      fetch csr_batch_info_db into l_batch_parameter_id;

      if csr_batch_info_db%found then
-- do an update
        update BEN_BATCH_PARAMETER
          set batch_exe_cd = l_batch_exe_cd,
              thread_cnt_num =  l_thread_cnt_num,
              max_err_num = l_max_err_num,
              chunk_size = l_chunk_size,
              object_version_number = l_object_version_number
          where (business_group_id = l_business_group_id)
            and (batch_exe_cd = 'HRDM');
      else
-- do an insert
        insert into BEN_BATCH_PARAMETER (
          BATCH_PARAMETER_ID,
          BATCH_EXE_CD,
          THREAD_CNT_NUM,
          MAX_ERR_NUM,
          CHUNK_SIZE,
          BUSINESS_GROUP_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATED_BY,
          CREATION_DATE,
          OBJECT_VERSION_NUMBER)
        select
          batch_parameter_id,
          batch_exe_cd,
          thread_cnt_num,
          max_err_num,
          chunk_size,
          business_group_id,
          to_date(last_update_date,'YYYYMMDD HH24:MI:SS'),
          last_updated_by,
          last_update_login,
          created_by,
          to_date(creation_date,'YYYYMMDD HH24:MI:SS'),
          object_version_number
        from HR_DM_EXP_BEN_BATCH_PARAS_V;

      end if;

    end if;

  end if;

  commit;

  hr_utility.trace(l_cr);
  hr_utility.trace('Process completed sucessfully.');
  hr_utility.trace(l_cr);


-- stop user seeing the error when an invalid migration
-- has been detected
  exception
    when e_fatal_error then
      null;



end destination_copy;


end hr_dm_copy;

/
