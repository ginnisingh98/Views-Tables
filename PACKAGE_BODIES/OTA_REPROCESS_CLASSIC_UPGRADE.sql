--------------------------------------------------------
--  DDL for Package Body OTA_REPROCESS_CLASSIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_REPROCESS_CLASSIC_UPGRADE" as
/* $Header: otreprocclsupg.pkb 120.0.12000000.2 2007/02/13 14:03:30 vkkolla noship $ */
    -- List processes

    MIGRATE_LOOKUP         constant varchar2(50) := 'MIGRATE_LOOKUP';
    UPGRADE_CATEGORY       constant varchar2(50) := 'UPGRADE_CATEGORY';
    CATEGORY_TO_ACTIVITY   constant varchar2(50) := 'CATEGORY_TO_ACTIVITY';
    ACTIVITY_TO_CATEGORY   constant varchar2(50) := 'ACTIVITY_TO_CATEGORY';
    CREATE_OFFERINGS       constant varchar2(50) := 'CREATE_OFFERINGS';
    UPG_EVENT_ASSOCIATIONS constant varchar2(50) := 'UPG_EVENT_ASSOCIATIONS';
    UPG_EVENTS             constant varchar2(50) := 'UPG_EVENTS';

    CONC_UPGRADE_ID constant number := get_next_upgrade_id ;
    l_request_id number;

    ORACLE_USER_NAME constant fnd_oracle_userid.oracle_username%type
                                  := get_ota_schema;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_next_upgrade_id >--------------------------|
-- ----------------------------------------------------------------------------
function get_next_upgrade_id
return number is
  l_upgrade_id number;
  begin
    select nvl(max(upgrade_id),1)
    into   l_upgrade_id
    from   ota_upgrade_log ;

    return l_upgrade_id +1 ;

  end  get_next_upgrade_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_ota_schema >------------------------------|
-- ----------------------------------------------------------------------------
function get_ota_schema return varchar2 is
  OTA_APP_SHORT_NAME constant varchar2(10) := 'OTA';
  l_status   fnd_product_installations.status%type;
  l_industry fnd_product_installations.industry%type;
  l_schema   FND_ORACLE_USERID.oracle_username%type := null;

  l_found    boolean;
begin
     l_found := fnd_installation.get_app_info( OTA_APP_SHORT_NAME
                                   ,l_status
                                   ,l_industry
                                   ,l_schema );
      if l_found then
         return l_schema;
      else
         return null;
      end if;
end  get_ota_schema;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_upgrade_name >-----------------------------|
-- ----------------------------------------------------------------------------
function get_upgrade_name(proc_name in varchar2,upg_id in number)
return varchar2 is
  begin
    return   proc_name||upg_id;
  end  get_upgrade_name;
-- ----------------------------------------------------------------------------
-- |---------------------< get_conc_date_param >------------------------------|
-- ----------------------------------------------------------------------------
function get_conc_date_param(upg_id in number) return date is
cursor c_upg_date is
     select process_date
     from ota_upgrade_log
     where upgrade_id = upg_id;

    l_ret date;
  begin
    open c_upg_date;
    fetch   c_upg_date into l_ret;
    close c_upg_date;

    return l_ret;
 end   get_conc_date_param;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_errors >---------------------------------|
-- ----------------------------------------------------------------------------
function check_errors(upg_id in number) return boolean is
     cursor c_any_errors is
     select 1
     from ota_upgrade_log
     where upgrade_id = upg_id
     and   log_type = 'E';

     l_ret boolean := false;
     l_local number;
   begin
    open c_any_errors;
    fetch  c_any_errors   into l_local;
    if  c_any_errors%found then
     l_ret := true;
    end if;
    close c_any_errors;

    return l_ret;
  end check_errors;
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_upgrade >--------------------------------|
-- ----------------------------------------------------------------------------
procedure submit_upgrade (p_procedure in varchar2, p_upg_name in varchar2,
                          p_table_name in varchar2,p_primary_col in varchar2) is

  l_errbuf  varchar2(1000);
  l_retcode number;
 begin
    ota_data_upgrader_util.submitUpgradeProcessSingle(
             errbuf            => l_errbuf,
             retcode           => l_retcode,
             p_process_number  => '1',                  -- This worker
             p_max_number_proc => '1',                  -- Total workers
             p_process_to_call => p_procedure,
             p_upgrade_type    => 'AD_LGE_TBL_UPG',
             p_process_ctrl    => null,
             p_param1          => ORACLE_USER_NAME,                      -- table owner
             p_param2          => p_table_name,   -- table name
             p_param3          => p_primary_col,    -- PK id column
             p_param4          => p_upg_name,                      -- Update name
             p_param5          => '200',                      -- batchsize
             p_param6          => CONC_UPGRADE_ID,   -- Concurrent upgrade id;
             p_param7          => null,
             p_param8          => null,
             p_param9          => null,
             p_param10         => null);
 end submit_upgrade;

-- ----------------------------------------------------------------------------
-- |-------------------------< write_log >------------------------------------|
-- ----------------------------------------------------------------------------
procedure write_log (msg in varchar2) is
  begin
   fnd_file.put_line(fnd_file.OUTPUT,msg);
  end write_log;

/*
    Functions determining whether upgrade on a particular entity is required.
*/
-- ----------------------------------------------------------------------------
-- |-------------------------< do_migrate_lookup >-----------------------------|
-- ----------------------------------------------------------------------------
 function do_migrate_lookup return boolean is
      cursor c_exist is
      select 1
      From Fnd_Lookup_values
      Where Lookup_type = 'FREQUENCY'
      and created_by not in (1,2)
      and (Lookup_code,language)
      not in (Select Lookup_code,language from Fnd_lookup_values
      Where Lookup_type = 'OTA_DURATION_UNITS')
      and rownum = 1 ;

      l_exists boolean := false;
      l_ret    number ;
   begin
       open c_exist;
       fetch c_exist into l_ret;
       if c_exist%FOUND then
         l_exists := true;
       end if;
       close c_exist;

       return l_exists;
 end   do_migrate_lookup;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_upgrade_category >--------------------------|
-- ----------------------------------------------------------------------------
 function do_upgrade_category return boolean is
      cursor c_exist is
      select 1
      from ota_category_usages ocu
      where ocu.category = (SELECT lkp.meaning
                  FROM  hr_lookups lkp
                  WHERE lkp.lookup_code = ocu.category
               	  AND lkp.lookup_type = 'ACTIVITY_CATEGORY')
            or not exists  (select 1
                       from ota_category_usages_tl oct
                       where oct.category_usage_id = ocu.category_usage_id)
      and rownum  = 1 ;

      l_exists boolean := false;
      l_ret    number ;
   begin
       open c_exist;
       fetch c_exist into l_ret;
       if c_exist%FOUND then
         l_exists := true;
       end if;
       close c_exist;

       return l_exists;
 end   do_upgrade_category;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_create_ctg_for_tad >------------------------|
-- ----------------------------------------------------------------------------
 function do_create_ctg_for_tad return boolean is
      cursor c_exist is
      select 1
      FROM ota_activity_definitions tad
      WHERE tad.category_usage_id is null
      AND   rownum = 1 ;

      l_exists boolean := false;
      l_ret    number ;
     begin
       open c_exist;
       fetch c_exist into l_ret;
       if c_exist%FOUND then
         l_exists := true;
       end if;
       close c_exist;

       return l_exists;
 end   do_create_ctg_for_tad;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_create_tad_for_ctg >------------------------|
-- ----------------------------------------------------------------------------
 function do_create_tad_for_ctg return boolean is
      cursor c_exist is
      select 1
      from     ota_category_usages ocu
      where    ocu.type = 'C'
      and      not exists (select category_usage_id
                                         from ota_activity_definitions tad
                                         where tad.category_usage_id is not null
                                         and tad.category_usage_id = ocu.category_usage_id)
      and rownum = 1 ;

      l_exists boolean := false;
      l_ret    number ;
   begin
       open c_exist;
       fetch c_exist into l_ret;
       if c_exist%FOUND then
         l_exists := true;
       end if;
       close c_exist;

       return l_exists;
 end   do_create_tad_for_ctg;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_create_offerings >--------------------------|
-- ----------------------------------------------------------------------------
-- Select Query is wrong.
 function do_create_offerings return boolean is
      cursor c_exist is
      select 1
      FROM ota_activity_versions  tav
      WHERE
            not exists (select 1 from ota_offerings off where off.activity_version_id = tav.activity_version_id )
      and   ( exists    (select 1 from ota_events evt where evt.activity_version_id = tav.activity_version_id )
      or    ( exists    (select 1 from ota_resource_usages rud where rud.activity_version_id = tav.activity_version_id)
            and not exists (select 1 from ota_resource_usages rud1 where rud1.activity_version_id= tav.activity_version_id
                             and rud1.offering_id is null))
      or    ( exists     ( select 1 from per_competence_elements where object_id = tav.activity_version_id and type = 'TRAINER')
      and not exists (select 1 from per_competence_elements where object_id = tav.activity_version_id and type = 'OTA_OFFERING')))
      and rownum =1;

      cursor c_exist_0 is
      select 1
      from   ota_events
      where  parent_offering_id is null
      and rownum = 1 ;

      l_exists boolean := false;
      l_ret    number ;
   begin
       open  c_exist_0;
       fetch c_exist_0 into l_ret;
       if c_exist_0%FOUND then
         l_exists := true;
       end if;
       close c_exist_0;

       if l_exists <> true then
         open c_exist;
         fetch c_exist into l_ret;
         if c_exist%FOUND then
           l_exists := true;
         end if;
         close c_exist;
       end if;

       return l_exists;
 end   do_create_offerings;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_upgrade_evt_assoc >-------------------------|
-- ----------------------------------------------------------------------------
 function do_upgrade_evt_assoc return boolean is
      cursor c_exist is
      select 1
      from ota_event_associations
      where nvl(self_enrollment_flag,'Y') <> 'N'
      and   (           customer_id     is not null
           or        job_id          is not null
           or        organization_id is not null
           or        position_id     is not null)
     and rownum = 1;

      l_exists boolean := false;
      l_ret    number ;
   begin
       open c_exist;
       fetch c_exist into l_ret;
       if c_exist%FOUND then
         l_exists := true;
       end if;
       close c_exist;

       return l_exists;
 end   do_upgrade_evt_assoc;
-- ----------------------------------------------------------------------------
-- |-------------------------< do_upgrade_evt >------------------------------|
-- ----------------------------------------------------------------------------
 function do_upgrade_evt return boolean is
      cursor c_exist is
      select 1
      from   ota_events
      where line_id is not null
      and   (    nvl(book_independent_flag,'Y') <> 'N'
              or nvl(Maximum_internal_attendees,0) <> 0)
      and rownum = 1 ;

      l_exists boolean := false;
      l_ret    number ;
   begin
         open c_exist;
         fetch c_exist into l_ret;
         if c_exist%FOUND then
           l_exists := true;
         end if;
         close c_exist;

       return l_exists;
 end   do_upgrade_evt;



-- ----------------------------------------------------------------------------
-- |-------------------< check_offering_event_link >--------------------------|
-- ----------------------------------------------------------------------------
 function check_offering_event_link return boolean is
      cursor csr_off_evt_link is
      select evt.event_id,evt.activity_version_id evt_act_Ver_id, off.activity_version_id,evt.parent_offering_id
      from   ota_events evt, ota_offerings off
      where  evt.parent_offering_id = off.offering_id
      and    evt.activity_version_id <> off.activity_version_id ;

      cursor csr_off_evt_lang is
      select evt.event_id,evt.activity_version_id evt_act_Ver_id, off.activity_version_id,evt.parent_offering_id,evt.language_id evt_lang, off.language_id off_lang
      from   ota_events evt, ota_offerings off
      where  evt.parent_offering_id = off.offering_id
      and    evt.language_id <> off.language_id ;


      l_exists boolean := false;
      l_ret    number ;
   begin
   -- Check if any event attached to a offering belongs to a different course. If any found remove the link.
         for l_off_evt_link in csr_off_evt_link loop
	   l_exists := TRUE;
	   Update ota_events
	   set parent_offering_id = Null
	   Where  event_id = l_off_evt_link.event_id
	   and    parent_offering_id = l_off_evt_link.parent_offering_id ;
	  end loop;

   -- Check if any event attached to a offering of differnt language. If any found remove the link.
         for l_off_evt_lang in csr_off_evt_lang loop
	   l_exists := TRUE;
	   Update ota_events
	   set parent_offering_id = Null
	   Where  event_id = l_off_evt_lang.event_id
	   and    parent_offering_id = l_off_evt_lang.parent_offering_id ;
	  end loop;


       return l_exists;
 end   check_offering_event_link;

-- ----------------------------------------------------------------------------
-- |-------------------------< upgrade_request >------------------------------|
-- ----------------------------------------------------------------------------
-- Procedure called on concurrent request submission.
-- Two parameters are required by the Concurrent Manager.
-- This procedure checks if upgrade is required for an entity, and if so
-- submits a large table update for the entity.
 procedure upgrade_request(aSqlerrm      IN OUT NOCOPY  VARCHAR2,
                           aSqlcode      IN OUT NOCOPY  number) is

    l_upgrade_done  boolean := false;
  begin

     write_log('Starting Reprocess OTA Upgrade Concurrent Process ');

      INSERT INTO OTA_UPGRADE_LOG (
                           UPGRADE_ID,
                           TABLE_NAME,
                           SOURCE_PRIMARY_KEY,
                           OBJECT_VALUE,
                           BUSINESS_GROUP_ID,
                           PROCESS_DATE,
                           MESSAGE_TEXT,
                           TARGET_PRIMARY_KEY,
			   LOG_TYPE,
			   UPGRADE_NAME)
			   VALUES
			   (CONC_UPGRADE_ID,
                             'DUMMY',
			    '-1',
			    null,
			    null,
			    sysdate,
			    'Starting Reprocess OTA Classic Data Upgrade',
			    null,
			    'N',
			    'OTCLSUPG');

     write_log('Checking for mismatch between offering and events table');
     if check_offering_Event_link then
	write_log('There is a mismatch between offering and events table. This proces will correct them');
     end if;


    -- 1) Migrate Lookups
     if do_migrate_lookup then
       write_log('Migrating Lookup:FREQUENCY');
       l_upgrade_done := true;
       ota_classic_upgrade.migrate_lookup;
     end if;
    -- 2) Upgrade Category
     if do_upgrade_category then
       write_log('Upgrading Category definitions');
       l_upgrade_done := true;
       submit_upgrade( 'ota_classic_upgrade.upgrade_category'
                      ,get_upgrade_name(UPGRADE_CATEGORY,CONC_UPGRADE_ID)
                      ,'OTA_CATEGORY_USAGES'
                      ,'CATEGORY_USAGE_ID');
     end if;

           -- Upgrade Act cat Inclusions
      ota_classic_upgrade.upgrade_act_cat_inclusions;

      -- Upgrade Online delivery modes
      ota_classic_upgrade.upgrade_online_delivery_modes(CONC_UPGRADE_ID);

      --  Create root dms and categories for BGS
        ota_classic_upgrade.create_root_ctg_and_dms;

      ota_classic_upgrade.create_ctg_dm_for_act_bg(CONC_UPGRADE_ID);


     --3) Create Category for Activity
     if do_create_ctg_for_tad then
        write_log('Creating category for activity');
        l_upgrade_done := true;
        submit_upgrade( 'ota_classic_upgrade.create_category_for_activity'
                      ,get_upgrade_name(ACTIVITY_TO_CATEGORY,CONC_UPGRADE_ID)
                      ,'OTA_ACTIVITY_DEFINITIONS'
                      ,'ACTIVITY_ID');
     end if;



     -- 4) Create Activity for Category
     if do_create_tad_for_ctg then
          write_log('Creating activity for category');
       l_upgrade_done := true;
        submit_upgrade( 'ota_classic_upgrade.create_activity_for_category'
                      ,get_upgrade_name(CATEGORY_TO_ACTIVITY,CONC_UPGRADE_ID)
                      ,'OTA_CATEGORY_USAGES'
                      ,'CATEGORY_USAGE_ID');
     end if;

     ota_classic_upgrade.upgrade_root_category_dates;

     --5) Create Offerings
     if do_create_offerings then
        write_log('Creating Offerings');
	l_upgrade_done := true;
        submit_upgrade( 'ota_classic_upgrade.create_offering'
                      ,get_upgrade_name(CREATE_OFFERINGS,CONC_UPGRADE_ID)
                      ,'OTA_ACTIVITY_VERSIONS'
                      ,'ACTIVITY_VERSION_ID');

         update ota_offerings
         set learning_object_id = null
         where learning_object_id = -1;
     end if;

     -- 6) Upgrade Event Associations
     if do_upgrade_evt_assoc then
       write_log (' Upgrading event Associations');
       l_upgrade_done := true;
        submit_upgrade( 'ota_classic_upgrade.upgrade_event_associations'
                      ,get_upgrade_name(UPG_EVENT_ASSOCIATIONS,CONC_UPGRADE_ID)
                      ,'OTA_EVENT_ASSOCIATIONS'
                      ,'EVENT_ASSOCIATION_ID');

     end if;

     -- 7) Upgrade Events
     if do_upgrade_evt then
       write_log (' Upgrading Events');
       l_upgrade_done := true;
        submit_upgrade( 'ota_classic_upgrade.upgrade_events'
                      ,get_upgrade_name(UPG_EVENTS,CONC_UPGRADE_ID)
                      ,'OTA_EVENTS'
                      ,'EVENT_ID');
     end if;

     -- 2733966
     -- 8) Populate Language_code column in OTA_Offerings, OTA_Learning_Objects and
	 --    OTA_Competence_languages if it is null.
     ota_classic_upgrade.upgrade_language_code;


     if l_upgrade_done then
       if check_errors(CONC_UPGRADE_ID) then
         write_log('Errors have been encountered during this Upgrade process' );
         write_log('Correct the errors and Re-run this concurrent request' );
         write_log('To check for errors run the Upgrade Log Report with the following parameters:');
         write_log('Upgrade Id: '||CONC_UPGRADE_ID);
         write_log('Date        '||get_conc_date_param(CONC_UPGRADE_ID));

         /*Submit the Upgrade Log Request with initial upgrade arguments */
       l_request_id := fnd_request.submit_request(
                                    application => 'OTA',
                                    program => 'OTARPUPG',
			            argument1 => CONC_UPGRADE_ID,
			            argument2 => fnd_date.date_to_canonical(sysdate));
      else
        write_log('Upgrade Completed Successfully');
        write_log('There is no further need to run this concurrent request');

      end if;
     else
         write_log('No Upgrade is required');
     end if;


  end upgrade_request;

end    ota_reprocess_classic_upgrade;

/
