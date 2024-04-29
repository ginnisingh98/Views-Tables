--------------------------------------------------------
--  DDL for Package Body OTA_CLASSIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CLASSIC_UPGRADE" AS
/* $Header: otclassicupg.pkb 120.5.12010000.3 2008/08/05 11:41:56 ubhat ship $ */

  DM_COPY_SUFFIX constant varchar2(50) := '***UPG***';
  UPGRADE_NAME       constant varchar2(30) := 'OTCLSUPG';
  LOG_TYPE_I         constant varchar2(30) := 'I';  -- log type is Information
  LOG_TYPE_N         constant varchar2(30) := 'N';  -- log type is Internal
  LOG_TYPE_E         constant varchar2(30) := 'E';  -- log type is Error
  G_PROCESS_DATE     constant date   := sysdate;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_process_date >-----------------------------|
-- ----------------------------------------------------------------------------
function get_process_date (p_upgrade_id in number
                            ,p_upgrade_name in varchar2)
                            return date is
  l_process_date date;
  cursor process_date is
  select max(process_date)
  from ota_upgrade_log
  where upgrade_id = p_upgrade_id
  and upgrade_name = p_upgrade_name
  and  source_primary_key = '-1';
begin
  l_process_date:= null;
  open process_date;
  fetch process_date into l_process_date;
  close process_date;
  if l_process_date is null then
    l_process_date := g_process_date;
  end if;
  return l_process_date;
end;


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
-- |-------------------------< get_lang_code >-----------------------------|
-- ----------------------------------------------------------------------------
function get_lang_code(p_evt_language_id in number,p_tav_language_id in number) return varchar2 is
    l_lang_code fnd_languages.language_code%type;
    cursor c_lang_code is
    select fl.language_code
    from fnd_languages fl
    where fl.language_id = Nvl(p_evt_language_id,p_tav_language_id);

begin
    open c_lang_code;
    fetch c_lang_code into l_lang_code;
    close c_lang_code;

    return l_lang_code;
end;
-- ----------------------------------------------------------------------------
-- |-------------------------< Create_Default_DM >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Create_Default_Dm(p_business_group_id in number,
                            p_dm_id IN OUT NOCOPY Number,
                            p_update_id in number default 1 ) is
l_category_usage_id ota_category_usages.category_usage_id%Type ;
l_object_version_number ota_category_usages.object_version_number%Type ;
l_dm_name ota_category_usages_tl.category%Type;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_course_min_st_dt date;
Cursor csr_check_dm(p_dm in varchar2) is
  Select Ocu.Category_usage_id
  From   Ota_category_usages_vl ocu
  Where  ocu.Business_group_id = p_business_group_id
  and    ocu.Category = p_dm
  and    ocu.Type = 'DM' ;
 l_delivery_mode_id ota_category_usages.category_usage_id%Type;

Begin

  Select lkp.Meaning into l_dm_name
  From   Hr_lookups lkp
  Where  lkp.lookup_type = 'ACTIVITY_CATEGORY'
  And   lkp.lookup_code = 'INCLASS' ;

    Open csr_check_dm(l_dm_name) ;
     Fetch csr_check_dm into l_delivery_mode_id ;
    If csr_check_dm%NOTfound then
    begin
       SELECT MIN(TAV.START_DATE) INTO l_course_min_st_dt
       FROM OTA_ACTIVITY_VERSIONS TAV
       WHERE  NOT EXISTS
              (SELECT ACI.ACTIVITY_VERSION_ID FROM OTA_ACT_CAT_INCLUSIONS ACI,OTA_CATEGORY_USAGES CTU
               WHERE ACI.ACTIVITY_VERSION_ID = TAV.ACTIVITY_VERSION_ID
               AND   ACI.CATEGORY_USAGE_ID = CTU.CATEGORY_USAGE_ID
               AND   CTU.TYPE = 'DM') ;
       If l_course_min_st_dt is NULL then
          l_course_min_st_dt := trunc(sysdate);
       End If;

  	Ota_ctu_ins.ins(
             p_effective_date        => trunc(sysdate)
            ,p_business_group_id     => p_business_group_id --nvl(c_get_act.business_group_id,0)
            ,p_category		     => l_dm_name
    	    ,p_type                  => 'DM'
    	    ,p_parent_cat_usage_id   => NULL
    	    ,p_synchronous_flag	     => 'Y'
    	    ,p_online_flag           => 'N'
            ,p_start_date_active     => l_course_min_st_dt -- trunc(sysdate) -- trunc(c_get_act.Creation_Date)
    	    ,p_category_usage_id     => l_category_usage_id
    	    ,p_object_version_number => l_object_version_number
  	    );
        p_dm_id := l_category_usage_id;
        insert into ota_category_usages_tl
           ( CATEGORY_USAGE_ID,
             LANGUAGE ,
             CATEGORY ,
             DESCRIPTION ,
             SOURCE_LANG )
        select
              l_category_usage_id,
              lkp.language,
              lkp.meaning,
              lkp.meaning,
              lkp.source_lang
       from fnd_lookup_values lkp
       where lkp.lookup_type = 'ACTIVITY_CATEGORY'
       and lkp.lookup_code =   'INCLASS'
       and lkp.security_group_id = 0  -- added for bug#4116886
       and lkp.view_application_id = 3;   -- added for bug#4116886

    exception
    when others then
    p_dm_id:= null;
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Default Delivery Mode for Business group name');

    add_log_entry( p_table_name=>'CREATE_DM'
                  ,p_business_group_id => p_business_group_id
                  ,p_source_primary_key    => p_business_group_id
                  ,p_object_value       => l_dm_name
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       => get_process_date(p_update_id,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );


    end;
    End If;
    Close csr_check_dm;
End Create_Default_Dm;

-- ----------------------------------------------------------------------------
-- |---------------------------< Create_Root_Category >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Create_Root_Category(
   p_business_group_id in Number,
   p_business_group_name in varchar2,
   p_root_cat_usage_id in out NOCOPY Number,
   p_update_id in number default 1 ) IS

Cursor Csr_chk_root_ctg_exists Is
Select ctu.Category_usage_id from ota_Category_usages ctu, ota_Category_usages ct
where ctu.parent_cat_usage_id is NULL
and   ctu.category_usage_id = ct.parent_cat_usage_id
and ctu.business_group_id = p_business_group_id
and ctu.business_group_id = ct.business_group_id
and ctu.type = 'C'
and ct.type = 'C' ;

CURSOR csr_Category_present is
     SELECT ocu.category_usage_id,ocu.start_date_active
     FROM   ota_category_usages ocu
     WHERE  ocu.category = p_business_group_name -- business_group_id AND name is unique
     AND    ocu.business_group_id = p_business_group_id
     AND    type = 'C' ;
l_category_usage_id       ota_category_usages.category_usage_id%Type;
l_parent_cat_usage_id     ota_category_usages.parent_cat_usage_id%Type;
l_start_date              ota_category_usages.start_date_active%Type;
l_object_version_number   ota_category_usages.object_version_number%Type;
l_type Varchar2(1) := 'C' ;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);

Begin
  Open Csr_Chk_root_ctg_exists;
  Fetch Csr_Chk_root_ctg_exists into l_parent_cat_usage_id;

  If Csr_chk_root_ctg_exists%NotFound then
    open csr_category_present ;
    fetch csr_category_present into l_parent_cat_usage_id,l_start_date;

    if csr_category_present%notfound then
    begin

       	Ota_ctu_ins.ins
             (
             p_effective_date        => trunc(sysdate)
            ,p_business_group_id     => p_business_group_id
            ,p_category		         => p_business_group_name
       	    ,p_type                  => l_type
    	    ,p_parent_cat_usage_id   => -1 -- To bypass the ota_ctu_bus.chk_root_cat validation, created the root category with parent_cat_usage_id as '-1'
      	    ,p_synchronous_flag	     => null
      	    ,p_online_flag           => null
            ,p_start_date_active     => l_start_date
      	    ,p_category_usage_id     => l_category_usage_id
            ,p_object_version_number => l_object_version_number
    	    );

      -- To bypass the ota_ctu_bus.chk_root_cat validation, created the root category with parent_cat_usage_id as '-1'
      -- Updating the dummy value to NULL
      Update Ota_category_usages
      Set    Parent_cat_usage_id = Null
      Where  Category_usage_id = l_category_usage_id
      and    Business_group_id = p_business_group_id
      and    Parent_cat_usage_id = -1 ;

      Insert into ota_category_usages_tl
      (Category_usage_Id,
     	Language,
     	Category,
     	Description,
     	Source_Lang,
     	Created_By,
     	Creation_Date,
     	Last_Updated_By,
     	Last_Update_Date,
     	Last_Update_Login )
	Select l_category_usage_id,
     	orgtl.language,
	    orgtl.Name,
    	orgtl.name,
    	orgtl.source_lang,
    	orgtl.Created_By,
    	orgtl.Creation_date,
    	orgtl.Last_Updated_By,
    	orgtl.Last_Update_Date,
    	orgtl.Last_Update_Login
  	From hr_organization_units org, hr_all_organization_units_tl orgtl
    Where orgtl.organization_id  = p_business_group_id
    and   org.organization_id = org.business_group_id
    and   org.organization_id = orgtl.organization_id
    And   Not Exists (Select    '1'
                    From     OTA_CATEGORY_USAGES_TL T
                    Where   T.Category_usage_Id = l_Category_usage_Id
                    And        T.Language = Orgtl.Language ) ;


      	 l_parent_cat_usage_id := l_category_usage_id;
  Exception
    when others then
     l_err_code := SQLCODE;
     l_err_msg  := nvl(substr(SQLERRM,1,2000),'When creating root category');
     l_category_usage_id:= null;

    add_log_entry( p_table_name=>'CREATE_CTU'
                  ,p_business_group_id => p_business_group_id
                  ,p_source_primary_key    => p_business_group_id
                  ,p_object_value       => p_business_group_name
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       => get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );

   end;
   End If;
  Close csr_category_present;
  End If;

  Close Csr_Chk_root_ctg_exists;

      -- There can be only one category exist wih parent_cat_usage_id as NULL
      -- It will be the root category for that BG. And hence updating the
      -- other categories belongs to that BG to have <Business Group Name> Category as Parent.

      Update Ota_category_usages
      Set parent_cat_usage_id = l_parent_cat_usage_id
      Where parent_cat_usage_id is null
      and   Type = 'C'
      and   Business_group_id = p_business_group_id
      and   Category_usage_id <> l_parent_cat_usage_id ;

   p_root_cat_usage_id   := l_parent_cat_usage_id;


End ;
-- ----------------------------------------------------------------------------
-- |---------------------------< upgrade_act_cat_inclusions >-----------------|
-- ----------------------------------------------------------------------------
procedure upgrade_act_cat_inclusions is
begin
  update ota_act_cat_inclusions
  set activity_category = null
  where activity_category is not null
  and     category_usage_id is not null;
end upgrade_act_cat_inclusions;
-- ----------------------------------------------------------------------------
-- |---------------------------< create_delivery_mode >-----------------------|
-- ----------------------------------------------------------------------------
function  create_delivery_mode ( p_name in varchar2
                                ,p_online_flag in varchar2
                                ,p_sync_flag in varchar2
                                ,p_business_group_id in number
                                ,p_start_date in date default null)
                                return number
                                is
  cursor c_duplicate_dm(p_cat_name varchar2,p_bg_id number) is
  select category_usage_id
  from  ota_category_usages_vl
  where category = p_cat_name
  and   type = 'DM'
  and   business_group_id = p_bg_id;

  l_ovn               ota_category_usages.object_version_number%type;
  l_category_usage_id ota_category_usages.category_usage_id%type;

  begin
  open c_duplicate_dm(p_name,p_business_group_id);
  fetch c_duplicate_dm into l_category_usage_id;
  if c_duplicate_dm %notfound then
        Ota_category_usage_api.Create_Category(
             p_effective_date        => trunc(sysdate)
            ,p_business_group_id     => p_business_group_id --nvl(c_get_act.business_group_id,0)
            ,p_category		     => p_name
            ,p_description       => substrb(p_name,1,240)
    	    ,p_type                  => 'DM'
    	    ,p_parent_cat_usage_id   => NULL
    	    ,p_synchronous_flag	     => p_sync_flag
    	    ,p_online_flag           => p_online_flag
            ,p_start_date_active     => p_start_date -- trunc(sysdate) -- trunc(c_get_act.Creation_Date)
    	    ,p_category_usage_id     => l_category_usage_id
    	    ,p_object_version_number => l_ovn
  	    );
   end if;
   close c_duplicate_dm;
   return   l_category_usage_id;
  end create_delivery_mode;

  -- ----------------------------------------------------------------------------
-- |---------------------------< upgrade_online_del_modes >-------------------|
-- ----------------------------------------------------------------------------
procedure upgrade_non_online_attach_dms (p_upgrade_id in number default 1) is

  cursor c_non_online_dms is
      select ctu.category_usage_id
        ,ctu.category
        ,ctu.online_flag
        ,ctu.synchronous_flag
        ,ctu.business_group_id
  from   ota_category_usages_vl    ctu
  where ctu.type ='DM'
  and nvl(ctu.online_flag,'N') = 'N'
  and nvl(ctu.synchronous_flag,'Y')= 'Y'
  and ctu.category in (select lkp.meaning
                             from   hr_lookups lkp
                             where  lkp.lookup_type = 'ACTIVITY_CATEGORY'
                             and    lkp.lookup_code  = 'INCLASS');

  cursor c_online_courses(p_dm_id number) is
  select  tav.activity_version_id
  from   ota_category_usages    ctu
        ,ota_activity_versions  tav
        ,ota_act_cat_inclusions aci
  where aci.category_usage_id   = ctu.category_usage_id
  and   tav.activity_version_id = aci.activity_version_id
  and   ctu.type = 'DM'
  and   tav.rco_id is not null
  and   ctu.category_usage_id = p_dm_id
  and   ( aci.primary_flag = 'Y'
         or not exists(select 1 from ota_act_cat_inclusions aci1
                        where aci1.activity_version_id = tav.activity_version_id
                        and aci1.category_usage_id <> p_dm_id)) ;

  cursor c_online_events(p_act_ver_id number) is
  select count(decode(evt.event_type,'SELFPACED',1,null)) selfpaced_c
        ,count(decode(evt.event_type,'SCHEDULED',1,null)) scheduled_c
  from  ota_events evt
  where evt.activity_version_id = p_act_ver_id;

  l_found number;
  l_online_flag ota_category_usages.online_flag%type;
  l_sync_flag   ota_category_usages.synchronous_flag%type;

  l_sp_count number;
  l_sched_count number;

  l_category_usage_id number;

  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);
 begin

   for c_ol_dms in c_non_online_dms loop
    l_sync_flag := 'Y';
    l_online_flag := 'N';
     for c_ol_tav in c_online_courses(c_ol_dms.category_usage_id) loop
       l_sp_count := -1;
       l_sched_count := -1;
       l_online_flag := 'Y';

       open c_online_events(c_ol_tav.activity_version_id);
       fetch c_online_events into l_sp_count,l_sched_count;

       if c_online_events%found then
        if Nvl(l_sync_flag,'*') <> 'N' then
         if nvl(l_sp_count,-1) > 0 then
          l_sync_flag := 'N';
         elsif l_sched_count > 0 then
          l_sync_flag := 'Y';
         end if;
        end if;
       end if;
       close c_online_events;

       l_category_usage_id := create_delivery_mode(c_ol_dms.category||DM_COPY_SUFFIX,
                                                   l_online_flag,
                                                   l_sync_flag,c_ol_dms.business_group_id);

       delete from ota_act_cat_inclusions
       where activity_version_id = c_ol_tav.activity_version_id
       and   category_usage_id = c_ol_dms.category_usage_id;

       Insert into ota_act_cat_inclusions
	  ( activity_category
	  ,activity_version_id
	  ,category_usage_id
	  ,object_version_number
	  ,primary_flag
	  ) values
	  (null
	  ,c_ol_tav.activity_version_id
	  ,l_category_usage_id
	  ,1
	  ,'Y');

    end loop;

   end loop;
end;
-- ----------------------------------------------------------------------------
-- |---------------------------< upgrade_online_del_modes >-------------------|
-- ----------------------------------------------------------------------------
procedure upgrade_online_del_modes (p_upgrade_id in number default 1) is
  cursor c_online_dms is
  select ctu.category_usage_id
        ,ctu.category
        ,ctu.online_flag
        ,ctu.synchronous_flag
        ,ctu.business_group_id
  from   ota_category_usages_vl    ctu
  where  ctu.type = 'DM'
  and nvl(ctu.online_flag,'N') = 'N'
  and nvl(ctu.synchronous_flag,'Y')= 'Y'
  and  ctu.category not in (select lkp.meaning
                             from   hr_lookups lkp
                             where  lkp.lookup_type = 'ACTIVITY_CATEGORY'
                             and    lkp.lookup_code  = 'INCLASS');

  cursor c_online_courses(p_dm_id number) is
  select tav.activity_version_id
  from   ota_category_usages    ctu
        ,ota_activity_versions  tav
        ,ota_act_cat_inclusions aci
  where aci.category_usage_id   = ctu.category_usage_id
  and   tav.activity_version_id = aci.activity_version_id
  and   ctu.type = 'DM'
  and   tav.rco_id is not null
  and   ctu.category_usage_id = p_dm_id ;



  cursor c_online_events(p_act_ver_id number) is
  select count(decode(evt.event_type,'SELFPACED',1,null)) selfpaced_c
        ,count(decode(evt.event_type,'SCHEDULED',1,null)) scheduled_c
  from  ota_events evt
  where evt.activity_version_id = p_act_ver_id;

  l_found number;
  l_online_flag ota_category_usages.online_flag%type;
  l_sync_flag   ota_category_usages.synchronous_flag%type;

  l_sp_count number;
  l_sched_count number;

  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);


  begin

   for c_ol_dms in c_online_dms loop
     l_sync_flag := 'Y';
     l_online_flag := 'N';
     for c_ol_tav in c_online_courses(c_ol_dms.category_usage_id) loop

       l_sp_count := -1;
       l_sched_count := -1;
       l_online_flag := 'Y';

       open c_online_events(c_ol_tav.activity_version_id);
       fetch c_online_events into l_sp_count,l_sched_count;

       if c_online_events%found then
        if Nvl(l_sync_flag,'*') <> 'N' then
         if nvl(l_sp_count,-1) > 0 then
          l_sync_flag := 'N';
         elsif l_sched_count > 0 then
          l_sync_flag := 'Y';
         end if;
        end if;
       end if;
       close c_online_events;


       begin

       update ota_act_cat_inclusions aci
       set    primary_flag =  decode(category_usage_id, c_ol_dms.category_usage_id,'Y','N') --'N'
       where  aci.activity_version_id = c_ol_tav.activity_version_id
       and    aci.category_usage_id in (select ctu.category_usage_id
                                        from   ota_Category_usages ctu
                                        where  ctu.type = 'DM' ) ;

       exception
     when others then
      l_err_code := SQLCODE;
      l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Default Delivery Mode for Business group name');

      add_log_entry( p_table_name=>'upgrade_attached_online_dms'
                  ,p_business_group_id => null
                  ,p_source_primary_key    => c_ol_dms.category_usage_id
                  ,p_object_value       =>  c_ol_dms.category_usage_id
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_upgrade_id
                  ,p_process_date       =>  get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );
   end;


      end loop;

      update ota_category_usages
      set online_flag = l_online_flag
         ,synchronous_flag =nvl(l_sync_flag,'N')
      where category_usage_id = c_ol_dms.category_usage_id;



   end loop;


 end upgrade_online_del_modes;


-- ----------------------------------------------------------------------------
-- |---------------------------< upgrade_attached_online_dms >----------------|
-- ----------------------------------------------------------------------------
procedure upgrade_attached_online_dms(p_upgrade_id in number default 1) is

  cursor c_online_dms is
  select  ctu.category_usage_id
         ,ctu.category
         ,ctu.business_group_id
  from   ota_category_usages_vl ctu
  where  ctu.online_flag = 'Y'
  and    ctu.type = 'DM';

  cursor c_attach_online_dms(p_dm_id in number)is
  select tav.activity_version_id
          ,aci.primary_flag
  from   ota_activity_versions tav
        ,ota_act_cat_inclusions aci
  where aci.category_usage_id = p_dm_id
  and   tav.activity_version_id = aci.activity_version_id
  and   tav.rco_id is null
  and not exists (select 1 from ota_offerings off
                  where off.activity_version_id = tav.activity_version_id
		  and rownum =1);


  l_activity_version_id  ota_activity_versions.activity_version_id%type;
  l_dm_start_date date;
  l_category_usage_id ota_category_usages.category_usage_id%type;
  l_primary_flag  ota_act_cat_inclusions.primary_flag%type;
  l_found number;

  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);


begin

 for c_ol_dms in c_online_dms loop

  for c_attach_ol_dms in  c_attach_online_dms(c_ol_dms.category_usage_id) loop
    l_activity_version_id := c_attach_ol_dms.activity_version_id;
    l_primary_flag   := c_attach_ol_dms.primary_flag;
    l_category_usage_id := null;
    begin
    l_category_usage_id := create_delivery_mode(c_ol_dms.category||DM_COPY_SUFFIX
                                                  ,'N','Y',c_ol_dms.business_group_id);
   delete from ota_act_cat_inclusions
   where category_usage_id   = c_ol_dms.category_usage_id
   and   activity_version_id = l_activity_version_id;

   Insert into ota_act_cat_inclusions
	( activity_category
	,activity_version_id
	,category_usage_id
	,object_version_number
	,primary_flag
	) values
	(null
	,l_activity_version_id
	,l_category_usage_id
	,1
	,l_primary_flag);
exception
     when others then
      l_err_code := SQLCODE;
      l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Default Delivery Mode for Business group name');

      add_log_entry( p_table_name=>'upgrade_attached_online_dms'
                  ,p_business_group_id => null
                  ,p_source_primary_key    =>l_category_usage_id
                  ,p_object_value       => l_category_usage_id
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_upgrade_id
                  ,p_process_date       =>  get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );
   end;


   end loop;
 end loop;
end upgrade_attached_online_dms;
-- ----------------------------------------------------------------------------
-- |----------------------< upgrade_online_delivery_modes >-------------------|
-- ----------------------------------------------------------------------------
procedure upgrade_online_delivery_modes (p_upgrade_id in number default 1) is
begin
   upgrade_online_del_modes( p_upgrade_id);
   upgrade_non_online_attach_dms( p_upgrade_id);
   upgrade_attached_online_dms( p_upgrade_id);
end upgrade_online_delivery_modes;


procedure create_root_ctg_and_dms is
  Cursor Csr_Category_BG is
  Select ctu.business_group_id
  From   Ota_Category_Usages ctu
  Group by ctu.business_group_id ;

  Cursor Csr_Bg_name(p_bg_id number) is
  Select hou.name Bg_name
  From hr_organization_units hou
  Where hou.business_group_id = p_bg_id
  and   hou.business_group_id = hou.organization_id ;

  l_default_dm Ota_Category_usages_tl.Category_usage_id%Type;
  l_root_cat_usage_id ota_category_usages.category_usage_id%Type;
  l_bg_name hr_organization_units.name%Type ;

 begin

 For Cat_Bg in csr_Category_bg Loop
    Open Csr_bg_name(cat_bg.business_group_id);
    Fetch csr_bg_name into l_bg_name;
    If csr_bg_name%found then
      Create_Root_Category(Cat_bg.Business_group_id,l_Bg_name,l_root_cat_usage_id);
      Create_Default_DM(Cat_bg.business_group_id,l_default_dm);
    End If;
    Close csr_bg_name;
  End Loop;
 end  create_root_ctg_and_dms;

-- ----------------------------------------------------------------------------
-- |---------------------------< Upgrade_Category >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure does the following :
-- 1. Updates ota_booking_deals.category with category_usage_id
-- 2. Updates ota_category_usages.Category with Meaning from
--    lookup table (earlier it stores lookup code)
-- 3. Populates the category translation table ota_category_usages_tl
-- 4. Migrates the customer defined lookup codes(not seeded) from FREQUNCY to
--    OTA_DURATION_UNITS

PROCEDURE Upgrade_Category(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) is

  CURSOR csr_installed_languages is
    SELECT lng.language_code,
           lng.nls_Language
      FROM fnd_languages lng
     WHERE lng.installed_flag in ('I', 'B');




  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE ;
  l_rows_processed number := 0;



  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);
  l_upgrade_id ota_upgrade_log.upgrade_id%Type;
  l_process_date ota_upgrade_log.process_date%Type;

begin

/* In Ota_booking_deals table Category field was the equivalent lookup_code
   for the lookup_type 'ACTIVITY_CATEGORY'. Now Category_usage_id  is being stored in this field
*/
--Should this check be included here?
begin
UPDATE ota_booking_deals tbd
SET tbd.category = (select ocu.category_usage_id
			from ota_category_usages ocu
			where tbd.category = ocu.category
			and tbd.business_group_id = ocu.business_group_id
			and ocu.type = 'D')
Where exists (select ocu.category_usage_id
			from ota_category_usages ocu
			where tbd.category = ocu.category
			and tbd.business_group_id = ocu.business_group_id
			and ocu.type = 'D');
Exception
 when others then
  l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'When Updating Booking deals');

    add_log_entry( p_table_name=>'UPDATE_BOOKING_DEALS'
                  ,p_source_primary_key => 1
                  ,p_object_value => 'No record in Booking Deals record updated with Category Usage id'
                  ,p_message_text   => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );

end;

 ota_mls_utility.set_session_language_code( l_userenv_language_code );

   update  ota_category_usages ocu
        set ocu.category = (SELECT lkp.meaning
                  FROM  hr_lookups lkp
                  WHERE lkp.lookup_code = ocu.category
               	  AND lkp.lookup_type = 'ACTIVITY_CATEGORY')
            ,Synchronous_flag = Decode(Type,'C',NULL,'DM','Y')
            ,Online_Flag = Decode(Type,'C',NULL,'DM','N')
   WHERE category_usage_id between p_start_pkid and p_end_pkid
   AND   exists (SELECT lkp.meaning
                 FROM  hr_lookups lkp
                 WHERE lkp.lookup_code = ocu.category
                 AND lkp.lookup_type = 'ACTIVITY_CATEGORY') ;



 /*
  **
  ** For each installed language insert a new record into the TL table for
  ** each record in the range provided that is present in the base table.
  */

 for c_language in csr_installed_languages loop
  begin
    /*
    ** Set language for iteration....
    */
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */

   Insert into OTA_CATEGORY_USAGES_TL
    (Category_usage_Id,
     Language,
     Category,
     Description,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
  Select
    M.Category_usage_Id,
    L_Current_Language,
    M.Category,
    M.Category,
    L_Userenv_language_code,
    M.Created_By,
    M.Creation_date,
    M.Last_Updated_By,
    M.Last_Update_Date,
    M.Last_Update_Login
  From OTA_CATEGORY_USAGES M
  Where M.Category_usage_id Between P_start_pkid AND P_end_pkid
  And   Not Exists (Select    '1'
                    From     OTA_CATEGORY_USAGES_TL T
                    Where   T.Category_usage_Id = M.Category_usage_Id
                    And        T.Language = L_Current_Language ) ;


--    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;
  Exception
    when others then
     l_err_code := SQLCODE;
     l_err_msg  := nvl(substr(SQLERRM,1,2000),'When creating category TL records');
    add_log_entry( p_table_name         =>'POPULATE_CTU_TL'
                  ,p_source_primary_key => L_current_language
                  ,p_object_value       => 'No Category translated for language'||l_current_language
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME) ;

  end;
  end loop;

   ota_mls_utility.set_session_language_code( l_userenv_language_code );

  Select Nvl(Count(Category_usage_id),0) into l_rows_processed from ota_category_usages
  Where Category_usage_id between p_start_pkid and p_end_pkid ;

  p_rows_processed := l_rows_processed;


Exception
  --
 When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    -- Should be commented?
    raise;

end Upgrade_Category;

-- ----------------------------------------------------------------------------
-- |---------------------< Upgrade_delivery_mode >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure creates the Activity typ for each category exists in
-- Ota_category_usages table.
PROCEDURE Upgrade_Delivery_Mode(p_update_id in number default 1 ) is

CURSOR csr_del_mode is
select ocu.category_usage_id, ocu.type,ocu.business_group_id,ocu.start_date_active,ocu.end_date_active
from ota_category_usages ocu
Where type = 'DM' or parent_cat_usage_id is not null ;
l_course_min_st_dt date;
l_course_max_end_dt date;
l_course_end_dt_has_null Varchar2(1) := 'N' ;
Begin

 For dm in csr_del_mode Loop
  l_course_min_st_dt          := dm.start_date_active;
  l_course_max_end_dt         := dm.end_date_active;

  Select Min(tav.Start_Date),Max(tav.End_date),Max(Decode(tav.End_date,NULL,'Y','N'))
    into l_course_min_st_dt, l_course_max_end_dt,l_course_end_dt_has_null
   From ota_activity_versions tav,ota_act_cat_inclusions aci
   Where tav.activity_version_id = aci.activity_version_id
   and   aci.category_usage_id = dm.category_usage_id;

   If l_course_end_dt_has_null = 'Y' then
     l_course_max_end_dt := NULL ;
   End if;

   if l_course_min_st_dt is null then
     l_course_min_st_dt := least (trunc(sysdate),nvl(dm.end_date_active,trunc(sysdate)));
   end if;

   If l_course_min_st_dt <= nvl(dm.start_date_active,l_course_min_st_dt) then
      Update Ota_Category_Usages
      Set  Start_date_active   = l_course_min_st_dt
      Where Category_usage_id = dm.category_usage_id
      and   Business_group_id = dm.business_group_id ;
   End If;

   If (l_course_max_end_dt is NULL and dm.end_date_active is NOT NULL) or (l_course_max_end_dt > dm.end_date_active) then
      Update Ota_Category_Usages
      Set   End_date_active   = l_course_max_end_dt
      Where Category_usage_id = dm.category_usage_id
      and   Business_group_id = dm.business_group_id ;
   End If;


 End Loop;

End Upgrade_Delivery_Mode ;
-- ----------------------------------------------------------------------------
-- |---------------------< set_primary_category >-----------------------------|
-- ----------------------------------------------------------------------------
-- For courses under p_act_id,
--1) create an act cat inlcusion record with p_category_usage_id,and primary flag
-- = 'Y' if no primary category exist. 'N', Otherwise.
--2) Update the activity_id for activity versions with the activity_id of the
--   corresponding to the primary category.
-- Called from Create_Category_for_Activity and Create_Activity_For_Category.
procedure set_primary_category ( p_act_id in number,p_business_group_id in number
                                ,p_category_usage_id in number
                                ,p_update_id in number default 1) is

CURSOR csr_activity_versions (p_act_id number)is
SELECT tav.activity_version_id
FROM OTA_ACTIVITY_VERSIONS TAV
WHERE tav.activity_id = p_act_id;

CURSOR csr_primary_present (p_act_ver_id number) is
SELECT ctu.category_usage_id
FROM ota_act_cat_inclusions cat,
     ota_category_usages ctu
WHERE ctu.category_usage_id = cat.category_usage_id
AND ctu.type = 'C'
AND cat.primary_flag='Y'
AND cat.activity_version_id = p_act_ver_id;

 cursor csr_equivalent_tad(p_ctu_id number) is
 select activity_id
 from ota_activity_definitions
 where category_usage_id = p_ctu_id;

 CURSOR csr_dup_act_cat (p_act_ver_id number, p_category_usage_id number) is
 SELECT 1
 FROM ota_act_cat_inclusions cat
 WHERE cat.category_usage_id =p_category_usage_id
 AND cat.activity_version_id = p_act_ver_id;


 l_equivalent_tad ota_activity_definitions.activity_id%type;
 l_equivalent_ctu ota_category_usages.category_usage_id%type;
 l_act_ver_id ota_activity_versions.activity_version_id%type;
 l_count number;
 l_err_code varchar2(72);
 l_err_msg  varchar2(2000);

 l_primary_flag varchar2(1);
begin
    for c_get_act_ver in csr_activity_versions(p_act_id) loop

     l_act_ver_id := c_get_act_ver.activity_version_id;
     open csr_primary_present(l_act_ver_id);
     fetch csr_primary_present into l_equivalent_ctu;
     if csr_primary_present%notfound then
        l_primary_flag := 'Y';
     else
        l_primary_flag := 'N';

	  -- If Primary category already exists, fetch the equivalent activity_id
          -- from activity type and set it as activity_id for that course.
	  l_equivalent_tad := -1;
      open csr_equivalent_tad(l_equivalent_ctu);
      fetch  csr_equivalent_tad into l_equivalent_tad;
       if csr_equivalent_tad%found then
        update Ota_Activity_Versions
        set activity_id = l_equivalent_tad
        where activity_version_id =  l_act_ver_id;
       end if;
       close csr_equivalent_tad;

     end if;
     close csr_primary_present;

     open csr_dup_act_cat(l_act_ver_id,p_category_usage_id);
     fetch csr_dup_act_cat into l_count;
     if csr_dup_act_cat%notfound then
   begin
	Insert into ota_act_cat_inclusions
	( activity_category
	,activity_version_id
	,category_usage_id
	,object_version_number
	,primary_flag
	) values
	(null
	,l_act_ver_id
	,p_category_usage_id
	,1
	,l_primary_flag);
    Exception
     When others then
      l_err_code := SQLCODE;
      l_err_msg  := nvl(substr(SQLERRM,1,2000),'When creating Activity Category Associations');

           add_log_entry( p_table_name           => 'CREATE_ACT_CAT_INCLUSIONS'
                         ,p_source_primary_key   => l_act_ver_id
                         ,p_business_group_id    => p_business_group_id
                         ,p_object_value         => 'Course Id : ' || l_act_ver_id
                         ,p_message_text         => l_err_msg
                         ,p_upgrade_id         => p_update_id
                         ,p_process_date       =>  get_process_date(UPGRADE_NAME,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME );

     end;

 elsif csr_dup_act_cat%found and l_primary_flag = 'Y' then

      update ota_act_cat_inclusions
    set primary_flag = 'Y'
    where category_usage_id = p_category_usage_id
    and   activity_version_id = l_act_ver_id;


     end if ;
     close csr_dup_act_cat;

   end loop;
End set_primary_category;
-- ----------------------------------------------------------------------------
-- |---------------------< update_act_ver_bg >-----------------------------|
-- ----------------------------------------------------------------------------

procedure update_act_ver_bg( p_business_group_id in number
                            ,p_activity_id in number)
is
begin

     Update Ota_Activity_Versions
     Set Business_group_id = p_business_group_id
     Where Activity_id = p_activity_id
     and   Business_group_id is NULL ;

end update_act_ver_bg;
-- ----------------------------------------------------------------------------
-- |---------------------< update_tad_cat_usg_id >--------------------------|
-- ----------------------------------------------------------------------------

procedure update_tad_cat_usg_id( p_business_group_id in number
                                ,p_activity_id in number
                                ,p_category_usage_id in number)
is
begin
     Update Ota_activity_Definitions
     Set    Category_usage_id = p_category_usage_id
     Where Business_group_id = p_business_group_id
     and   Activity_id = p_activity_id ;
end update_tad_cat_usg_id;
-- ----------------------------------------------------------------------------
-- |---------------------< Create_Activity_For_Category >---------------------|
-- ----------------------------------------------------------------------------
-- This procedure creates the Activity typ for each category exists in
-- Ota_category_usages table.
PROCEDURE Create_Activity_For_Category(
   p_process_control IN		varchar2,
   p_start_pkid      IN            number,
   p_end_pkid        IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 ) is



CURSOR c_activity_def is
select ocu.category_usage_id, oct.category, ocu.business_group_id,oct.description
from ota_category_usages ocu, ota_category_usages_tl oct
where ocu.category_usage_id = oct.category_usage_id
and   oct.language = Userenv('LANG')
and   ocu.type = 'C'
and ocu.category_usage_id between p_start_pkid  and p_end_pkid
and ocu. category_usage_id not in (select category_usage_id
                                from ota_activity_definitions
                              where category_usage_id is not null) ;

l_object_version_number    number;
l_category_usage_id        number;
l_activity_id	  	   number;
l_category	           ota_category_usages_tl.category%type;
l_business_group_id	   number;
l_description		   ota_category_usages_tl.description%Type;
l_rows_processed number := 0;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);

begin
  For c_activity IN c_activity_def loop

	l_category_usage_id 	:= c_activity.category_usage_id;
	l_category		        := c_activity.category;
	l_business_group_id	    := c_activity.business_group_id;
	l_description		    := c_activity.description;

   Begin
     Select tad.Activity_id   into l_activity_id
     from ota_activity_definitions tad, ota_activity_definitions_tl adt
     Where tad.Business_group_id = l_business_group_id
     and   tad.activity_id = adt.activity_id
     and   adt.Name = l_category
--     and   Category_usage_id is NULL
     Group by Tad.Activity_id ;

   update_tad_cat_usg_id(l_business_group_id, l_activity_id,l_category_usage_id);

   update_act_ver_bg(l_business_group_id, l_activity_id);

   set_primary_category(l_activity_id,l_business_group_id,l_category_usage_id,p_update_id);

  Exception
    When No_data_found then
     begin
      ota_tad_api.Ins
       (
        P_activity_id                 => l_activity_id
       ,P_business_group_id           => l_business_group_id
       ,P_name                        => l_category
       ,p_description		      => l_description
       ,p_multiple_con_versions_flag  => 'Y'
       ,P_object_version_number       => l_object_version_number
       ,p_category_usage_id   	      => l_category_usage_id
       ,P_validate                    => false
       );
     --
     ota_adt_ins.ins_tl
    	(p_effective_date     => sysdate
    	,p_language_code      => USERENV('LANG')
    	,p_activity_id        => l_activity_id
    	,p_name               => l_category
    	,p_description 	=> l_description);

      l_rows_processed := l_rows_processed + 1;
     Exception
           when others then
           l_err_code := SQLCODE;
           l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Activity for category');

           add_log_entry( p_table_name         =>'CREATE_ACT_FOR_CTU'
                         ,p_source_primary_key => l_category_usage_id
                         ,p_business_group_id  => l_business_group_id
                         ,p_object_value       => l_category
                         ,p_message_text       => l_err_msg
                         ,p_upgrade_id         => p_update_id
                         ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
     End;
    End ;

  end loop;



end Create_Activity_for_Category;



-- ----------------------------------------------------------------------------
-- |--------------------< Create_Category_for_Activity >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure does the following
-- 1. Creates a Category for each BG in ota_activity_definitions
--    and ota_category_usages. And this new category will be the
--    parent category for other categories(belongs to that BG).
-- 2. Creates Category for each Activity types, which are not
--    as part of step 3. Attaches the newly created category to
--    Activity versions exist under the equivalent Activity type.
--    If NO primary category specified for that Activity version,
--    then newly created category will be the primary.
PROCEDURE Create_Category_for_Activity(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 )
is

CURSOR csr_activity_type is
SELECT tad.activity_id,tad.business_group_id,
 tad.name , tad.description,tad.Created_By,
 tad.Creation_Date,tad.Last_Updated_By,
 tad.Last_Update_Date,tad.Last_Update_Login,
 Comments
 ,TAD_INFORMATION_CATEGORY
 ,TAD_INFORMATION1
 ,TAD_INFORMATION2
 ,TAD_INFORMATION3
 ,TAD_INFORMATION4
 ,TAD_INFORMATION5
 ,TAD_INFORMATION6
 ,TAD_INFORMATION7
 ,TAD_INFORMATION8
 ,TAD_INFORMATION9
 ,TAD_INFORMATION10
 ,TAD_INFORMATION11
 ,TAD_INFORMATION12
 ,TAD_INFORMATION13
 ,TAD_INFORMATION14
 ,TAD_INFORMATION15
 ,TAD_INFORMATION16
 ,TAD_INFORMATION17
 ,TAD_INFORMATION18
 ,TAD_INFORMATION19
 ,TAD_INFORMATION20
FROM ota_activity_definitions tad, ota_activity_definitions_tl adt
WHERE tad.activity_id between  p_start_pkid AND p_end_pkid
and   tad.activity_id = adt.activity_id
and   adt.language = Userenv('LANG')
AND tad.category_usage_id is null ;


CURSOR csr_installed_languages is
    SELECT lng.language_code,  lng.nls_Language
      FROM fnd_languages lng
     WHERE lng.installed_flag in ('I', 'B');

CURSOR csr_duplicate_category (p_act_name varchar2, p_business_group_id number) is
SELECT ocu.category_usage_id
FROM ota_category_usages ocu, ota_category_usages_tl oct
WHERE oct.category = p_act_name
AND ocu.type ='C'
AND ocu.category_usage_id = oct.category_usage_id
AND ocu.business_group_id = p_business_group_id;


cursor csr_min_start_date(p_act_id number) is
  select min(start_date)
  from ota_activity_versions
  where activity_id = p_act_id;


l_object_version_number    number;
l_category_usage_id        number;
l_type			   varchar2(30) :='C';
l_act_id   		   number;
l_business_group_id        number;
l_business_group_name      varchar2(240);
l_userenv_language_code    FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
l_current_nls_language     VARCHAR2(30);
l_current_language         FND_LANGUAGES.LANGUAGE_CODE%TYPE ;
l_parent_category_usage_id number;
l_count number ;
l_act_name ota_activity_definitions_tl.name%type;
l_act_ver_id number;

l_rows_processed number := 0;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_min_course_start_date date;
 l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();
--l_default_dm Ota_Category_usages_tl.Category_usage_id%Type;
--l_default_dm_name Hr_lookups.Meaning%Type  ;
--l_root_cat_usage_id ota_category_usages.category_usage_id%Type;
--l_bg_name hr_organization_units.name%Type ;
Begin

-- Ignore Category Dff Validation while creating Category from Activity.
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_CATEGORY_USAGES';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

for c_get_act in csr_activity_type loop

  l_act_id 		:= c_get_act.activity_id;
  l_business_group_id   := c_get_act.business_group_id;
  l_act_name  := c_get_act.name;

  Begin
    Select Category_usage_id into l_parent_category_usage_id
    From Ota_category_usages
    Where business_group_id = l_business_group_id
    and   parent_cat_usage_id is NULL
    and   type = 'C';
  Exception
    When Others then
    -- when no_data_found then ?
      l_parent_category_usage_id := NULL;
  End ;


  L_CATEGORY_USAGE_ID := NULL;
  l_object_version_number := NULL;
  open csr_duplicate_category(l_act_name, l_business_group_id);
   fetch csr_duplicate_category into l_category_usage_id;
  if csr_duplicate_category%notfound then

    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    begin

    l_min_course_start_date := null;
     open csr_min_start_date(l_act_id);
     fetch csr_min_start_date into l_min_course_start_date;
     close csr_min_start_date;



    ota_ctu_ins.ins( p_effective_date  =>trunc(sysdate)
          	,p_business_group_id      => l_business_group_id
          	,p_category		  => c_get_act.name
	     	,p_type		          => l_type
	      	,p_parent_cat_usage_id    => l_parent_category_usage_id
		,p_synchronous_flag	  => null
  	      	,p_online_flag            => null
          	,p_start_date_active      => nvl(l_min_course_start_date,trunc(c_get_act.Creation_Date))
  	      	,p_category_usage_id      => l_category_usage_id
  	      	,p_object_version_number  => l_object_version_number
               ,p_comments => c_get_act.comments
                ,P_ATTRIBUTE_CATEGORY     => c_get_act.tad_information_Category
                ,P_ATTRIBUTE1             => c_get_act.tad_information1
                ,P_ATTRIBUTE2             => c_get_act.tad_information2
                ,P_ATTRIBUTE3             => c_get_act.tad_information3
                ,P_ATTRIBUTE4             => c_get_act.tad_information4
                ,P_ATTRIBUTE5             => c_get_act.tad_information5
                ,P_ATTRIBUTE6             => c_get_act.tad_information6
                ,P_ATTRIBUTE7             => c_get_act.tad_information7
                ,P_ATTRIBUTE8             => c_get_act.tad_information8
                ,P_ATTRIBUTE9             => c_get_act.tad_information9
                ,P_ATTRIBUTE10            => c_get_act.tad_information10
                ,P_ATTRIBUTE11            => c_get_act.tad_information11
                ,P_ATTRIBUTE12            => c_get_act.tad_information12
                ,P_ATTRIBUTE13            => c_get_act.tad_information13
                ,P_ATTRIBUTE14            => c_get_act.tad_information14
                ,P_ATTRIBUTE15            => c_get_act.tad_information15
                ,P_ATTRIBUTE16            => c_get_act.tad_information16
                ,P_ATTRIBUTE17            => c_get_act.tad_information17
                ,P_ATTRIBUTE18            => c_get_act.tad_information18
                ,P_ATTRIBUTE19            => c_get_act.tad_information19
                ,P_ATTRIBUTE20            => c_get_act.tad_information20

  	     	);

	Insert into ota_category_usages_tl
		(Category_usage_Id,
     		Language,
     		Category,
     		Description,
 	    	Source_Lang,
     		Created_By,
	     	Creation_Date,
     		Last_Updated_By,
	     	Last_Update_Date,
     		Last_Update_Login )
		Select l_category_usage_id,
  		M.language,
		M.name,
    		M.description,
    		M.source_lang,
    		M.Created_By,
    		M.Creation_date,
    		M.Last_Updated_By,
    		M.Last_Update_Date,
    		M.Last_Update_Login
  		From Ota_activity_definitions_tl M
  		Where M.activity_id = l_act_id ;
   Exception
     when others then
       l_err_code := SQLCODE;
           l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Category for Activity');

           add_log_entry( p_table_name=>'CREATE_CTU_FOR_ACT'
                         ,p_source_primary_key     =>l_act_id
                         ,p_business_group_id => l_business_group_id
                         ,p_object_value       => c_get_act.name
                         ,p_message_text =>l_err_msg
                         ,p_upgrade_id         => p_update_id
                         ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);

   End;
  end if;
  close csr_duplicate_category;

   update_act_ver_bg(l_business_group_id, l_act_id);

  if l_category_usage_id is not null then

   update_tad_cat_usg_id(l_business_group_id, l_act_id,l_category_usage_id);

   set_primary_category(l_act_id,l_business_group_id,l_category_usage_id,p_update_id);

   end if;

  end loop;
   hr_dflex_utility.remove_ignore_df_validation;
   select nvl(count(1),0)
   into l_rows_processed
   from ota_activity_definitions
   where activity_id between p_start_pkid and p_end_pkid;

  p_rows_processed := l_rows_processed;


End Create_Category_for_Activity;


-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Offering >-----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure creates the Offering based on the records exists in ota_events
-- and ota_activity_versions table.
PROCEDURE Create_Offering(
   p_process_control 	IN varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) is

l_dm_id number;
l_act_ver_id number;
l_offering_id number;
l_object_version_number  number;
l_lang_id number := 0;
l_base_lang_id fnd_languages.language_id%Type ;
l_language_id number ;
l_competence_element_id number;
l_parent_offering_id ota_offerings.Offering_id%type;
l_vendor_id number;
l_supplier_id number;
 l_rows_processed number := 0;
l_default_dm ota_category_usages.category_usage_id%Type ;
l_resource_usage_id number;
l_duration_units ota_offerings.duration_units%Type;
l_duration ota_offerings.duration%Type;
l_default_language Fnd_languages.Language_id%Type;

l_language_code fnd_natural_languages.language_code%type;

l_off_dup_lang number;

CURSOR c_get_ids is
 SELECT tav.activity_version_id
  ,tad.BUSINESS_GROUP_ID
  ,tav.version_name
  ,tav.start_date
  ,tav.end_date
  ,tav.duration
  ,tav.description
  ,tav.language_id
  ,tav.duration_units
  ,tav.maximum_attendees
  ,tav.maximum_internal_attendees
  ,tav.minimum_attendees
  ,tav.actual_cost
  ,tav.budget_cost
  ,tav.budget_currency_code
  ,tav.vendor_id
  ,tav.rco_id
 FROM ota_activity_versions_vl  tav,  ota_activity_definitions tad
 WHERE tav.activity_id =tad.activity_id
 AND tav.activity_version_id between p_start_pkid and  p_end_pkid ;

CURSOR c_get_dm(p_act_ver_id number)is
 SELECT aci.CATEGORY_USAGE_ID
 FROM  ota_act_cat_inclusions aci ,
  OTA_CATEGORY_USAGES TCU
 WHERE ACI.CATEGORY_USAGE_ID = TCU.CATEGORY_USAGE_ID
  AND TCU.TYPE = 'DM'
  AND primary_flag = 'Y'
  AND activity_version_id = p_act_ver_id;

CURSOR c_get_dm1(p_act_ver_id number)is
 SELECT aci.CATEGORY_USAGE_ID
 FROM  ota_act_cat_inclusions aci ,
  OTA_CATEGORY_USAGES TCU
 WHERE ACI.CATEGORY_USAGE_ID = TCU.CATEGORY_USAGE_ID
  AND rownum = 1
  AND TCU.TYPE = 'DM'
  And Aci.activity_Version_id = p_act_ver_id;


CURSOR c_get_lang(p_act_ver_id number) is
  SELECT language_id, decode(event_type,'SELFPACED','SELFPACED','SCHEDULED') event_type
 FROM ota_events
 WHERE activity_version_id = p_act_ver_id
 AND   parent_offering_id is NULL
 Group by Language_id , decode(event_type,'SELFPACED','SELFPACED','SCHEDULED');


 CURSOR c_dup_off(p_name varchar, p_act_ver_id number) is
 SELECT Oft.Offering_id FROM ota_offerings off, ota_offerings_tl oft
WHERE off.offering_id = oft.offering_id
AND  oft.name = p_name
AND oft.language = USERENV('LANG')
AND off.activity_version_id = p_act_ver_id;

cursor c_def_dm_for_bg(l_bg_id number) is
Select ocu.category_usage_id from
 Ota_category_usages_vl ocu, hr_lookups lkp
                   Where  Ocu.Category = Meaning
                    and    lkp.Lookup_type = 'ACTIVITY_CATEGORY'
                    and    lkp.lookup_code = 'INCLASS'
                    and    ocu.type        = 'DM'
                    and    ocu.business_group_id = l_bg_id;
  cursor c_dm_name (l_dm_id number) is
      select category
      from ota_category_usages
      where type='DM'
      and category_usage_id = l_dm_id;

        cursor c_get_tav_dms(p_tav_id number) is
    select ctu.category_usage_id,
              ctu.category
    from ota_act_cat_inclusions aci ,
         ota_category_usages_vl ctu
    where aci.activity_version_id = p_tav_id
    and   ctu.category_usage_id   = aci.category_usage_id
    and   ctu.type = 'DM';

cursor c_lang_code_for_langid(p_lang_id number) is
	select b.language_code LanguageCode
	from (
	SELECT fl.language_id, fnl.language_code FROM fnd_languages fl, fnd_natural_languages fnl
	WHERE fl.iso_language_3 = UPPER(fnl.iso_language_3)
	AND fl.iso_territory = fnl.iso_territory ) a,
	 ota_natural_languages_v b
	where a.language_code(+) = b.language_code
	and a.language_id = p_lang_id;

  l_fnd_lang_code fnd_natural_languages.language_code%type;

  l_new_dm_name ota_category_usages.category%type;


-- Changed Table type declaration for 3389869 as multidimesion table declaration is not supported in 8.1.7
--  Type Event_tab is Table of c_get_lang%RowType INDEX BY BINARY_INTEGER;
  Type Event_tab is Table of Ota_Events.Language_id%Type INDEX BY BINARY_INTEGER;
  Offering_RecSet Event_tab;
    Type Event_type_tab is Table of Ota_Events.event_type%Type INDEX BY BINARY_INTEGER;
  Offering_evt_set Event_type_tab;

  l_event_exists Varchar2(1) ;
  l_res_usg_cnt Number(5) ;
  l_cmp_cnt Number(5) ;
  l_evt_language_id Ota_Events.Language_id%Type ;
   l_learning_object_id ota_offerings.learning_object_id%type;
  l_iteration Number(5) ;

l_err_code varchar2(72);
l_err_msg  varchar2(2000);
         b_act_ver_migrated boolean;

Begin

  Select lng.Language_id into l_default_language
  From Fnd_Languages lng
  Where lng.Installed_Flag = 'B' ;

  For ids in c_get_ids loop

    l_act_ver_id:= Ids.activity_version_id;


    -- If NO language specified at course, then initialize it with 'B'ase language
    -- This will be overwritten, if any language specified at Event(Class).
    l_language_id := Nvl(Ids.language_id,l_default_language);
    l_dm_id := null;
    l_iteration := 0;
    l_event_exists := 'N';
    l_res_usg_cnt := 0;
    l_cmp_cnt := 0;
    l_evt_language_id := NULL ;
         b_act_ver_migrated := true;

	 l_learning_object_id := Ids.rco_id;

    if l_learning_object_id is not null then
      l_learning_object_id := -1;
    end if;

    If (ids.duration is Null or ids.duration_units is NULL) then
       l_duration_units := NULL;
       l_duration := NULL;
    Else
       l_duration_units := Ids.Duration_units ;
       l_duration := Ids.Duration ;
    End if;

-- Setting the  dm for the offering to be created.
--1) if there's a dm with primary_flag=Y
--2) else, any DM attached to activity(rowmnum=1)
--3) else, Default DM of the BG
  open c_get_dm(l_act_ver_id);
   fetch c_get_dm into l_dm_id;
     If l_dm_id is null then
     Open c_get_dm1(l_act_ver_id);
       Fetch c_get_dm1 into l_dm_id;
     Close c_get_dm1;
    End if;

    if l_dm_id is null then
      open c_def_dm_for_bg(ids.business_group_id);
      fetch c_def_dm_for_bg into l_dm_id;
      close c_def_dm_for_bg;
    end if;

 Close c_get_dm;


    Open c_get_lang(l_act_ver_id);
    Fetch c_get_lang Bulk COllect into Offering_RecSet,Offering_evt_set ;
--    If c_get_lang%Found then
    l_iteration := Offering_RecSet.Count() ;
    If Nvl(l_iteration,0) > 0 then
      l_event_exists := 'Y' ;
    Else
      l_event_exists := 'N' ;

      Select count(Resource_Usage_id) into l_res_usg_cnt
      From Ota_Resource_Usages
      Where  Activity_Version_id = l_act_ver_id ;
      If Nvl(l_res_usg_cnt,0) = 0 then
        Select count(Competence_element_id) into l_cmp_cnt
        From Per_Competence_Elements
        Where  Type = 'TRAINER'
        and    Object_id = l_act_ver_id ;
      End If;
      If Nvl(l_res_usg_cnt,0) > 0 OR Nvl(l_cmp_cnt,0) > 0 then
        l_iteration := 1 ;
      Else
        l_iteration := 0;
      End If;
    End If;
    Close c_get_lang;
--  For Evt_lang in 1 .. Offering_RecSet.Count() Loop
    For Evt_lang in 1 .. l_iteration Loop

   l_parent_offering_id := NUll ; --4116886
   l_language_id := Nvl(Ids.language_id,l_default_language);
    If l_event_exists = 'Y' then
       -- If language specified at Event level,then use it to create offering
       If Offering_RecSet(Evt_lang) is Not NULL then  -- commented for bug 3389869 .language_id is Not null then
          l_language_id := Offering_RecSet(Evt_lang) ; -- commented for bug 3389869 .language_id ;
          l_evt_language_id := Offering_RecSet(Evt_lang) ; -- commented for bug 3389869 .language_id ;
       Else
          l_evt_language_id := NULL ;
       ENd if;


     if ( Offering_evt_set(evt_lang) = 'SCHEDULED' and ids.rco_id is not null) then
      open c_dm_name(l_dm_id);
      fetch c_dm_name into l_new_dm_name;
      close c_dm_name;
      l_dm_id := create_delivery_mode(l_new_dm_name||DM_COPY_SUFFIX,'Y','N'
                                     ,ids.business_group_id,ids.start_date);
     end if;

    Else
       l_evt_language_id := Null;
    End If;


-- bug#4116886
--      select nvl(count(1),0)
      select Max(offering_id)
--      into l_off_dup_lang
      into l_parent_offering_id
      from ota_offerings
      where language_id = l_language_id
      and   activity_version_id =l_act_ver_id;

   -- enh2733966 fnd_natural_lang support --
   open c_lang_code_for_langid(l_language_id);
   fetch c_lang_code_for_langid into l_fnd_lang_code;
   close c_lang_code_for_langid;
   l_language_code := l_fnd_lang_code;
   -- enh2733966 fnd_natural_lang support --

     --Open c_dup_off(Ids.version_name,l_act_ver_id);
      -- Fetch c_dup_off into l_parent_offering_id ;
 -- 4116886

      --if c_dup_off%notfound and l_off_dup_lang <= 0 then
      if l_parent_offering_id is null then

       begin


        Ota_off_ins.ins(
        p_effective_date             =>trunc(sysdate),
        p_business_group_id          =>nvl(Ids.business_group_id,0),
        p_name                       =>Ids.version_name,
	p_learning_object_id         =>l_learning_object_id,
        p_start_date                 => Ids.Start_date,
        p_activity_version_id        =>l_act_ver_id,
        p_end_date                   =>Ids.end_date,
        p_delivery_mode_id           => l_dm_id,
        p_language_id                => l_language_id,
        p_duration                   => l_duration,
        p_duration_units             => l_duration_units,
        p_maximum_attendees          =>Ids.maximum_attendees,
        p_maximum_internal_attendees =>Ids.maximum_internal_attendees,
        p_minimum_attendees          =>Ids.minimum_attendees,
        p_actual_cost                =>Ids.actual_cost,
        p_budget_cost                =>Ids.budget_cost,
        p_budget_currency_code       =>Ids.budget_currency_code,
        p_offering_id                => l_offering_id,
        p_object_version_number      => l_object_version_number,
        p_vendor_id		     => Ids.vendor_id,
	p_language_code              => l_language_code -- enh2733966 fnd_natural_lang support --
          );

	Insert into ota_offerings_tl
		(offering_Id,
     		Language,
     		name,
     		Description,
     		Source_Lang,
     		Created_By,
     		Creation_Date,
     		Last_Updated_By,
     		Last_Update_Date,
	     	Last_Update_Login )
          Select l_offering_id,
            M.language,
  	    decode(greatest(l_iteration,1) ,1,M.version_name,
            get_offering_name_with_lang(M.version_name,l_language_id,M.language)),
	    M.description,
	    M.source_lang,
	    M.Created_By,
	    M.Creation_date,
	    M.Last_Updated_By,
	    M.Last_Update_Date,
	    M.Last_Update_Login
	  From Ota_activity_versions_tl M
	  Where M.activity_version_id = l_act_ver_id;


  begin
	Insert into ota_resource_usages
      		(resource_usage_id
      		,supplied_resource_id
  		,activity_version_id
	      ,object_version_number
	      ,required_flag
	      ,start_date
	      ,comments
	      ,end_date
	      ,quantity
	      ,resource_type
	      ,role_to_play
	      ,usage_reason
	      ,rud_information_category
	      ,rud_information1
	      ,rud_information2
	      ,rud_information3
	      ,rud_information4
	      ,rud_information5
	      ,rud_information6
	      ,rud_information7
	      ,rud_information8
	      ,rud_information9
	      ,rud_information10
	      ,rud_information11
	      ,rud_information12
	      ,rud_information13
	      ,rud_information14
	      ,rud_information15
	      ,rud_information16
	      ,rud_information17
	      ,rud_information18
	      ,rud_information19
	      ,rud_information20
	      ,offering_id )
	  Select ota_resource_usages_s.nextval
	      ,res.supplied_resource_id
  	      ,l_act_ver_id
	      ,1
	      ,res.required_flag
	      ,res.start_date
	      ,res.comments
	      ,res.end_date
	      ,res.quantity
	      ,res.resource_type
	      ,res.role_to_play
	      ,res.usage_reason
	      ,res.rud_information_category
	      ,res.rud_information1
	      ,res.rud_information2
	      ,res.rud_information3
	      ,res.rud_information4
	      ,res.rud_information5
	      ,res.rud_information6
	      ,res.rud_information7
	      ,res.rud_information8
	      ,res.rud_information9
	      ,res.rud_information10
	      ,res.rud_information11
	      ,res.rud_information12
	      ,res.rud_information13
	      ,res.rud_information14
	      ,res.rud_information15
	      ,res.rud_information16
	      ,res.rud_information17
	      ,res.rud_information18
	      ,res.rud_information19
	      ,res.rud_information20
	      ,l_offering_id
	  From ota_resource_usages res
        where res.activity_version_id =  l_act_ver_id
        and   Offering_id is NULL ;
     Exception

       when others then
         b_act_ver_migrated := false;
         l_err_code := SQLCODE;
         l_err_msg  := nvl(substr(SQLERRM,1,2000),'When Moving resources associated with this Activity');
         add_log_entry( p_table_name=>'MIGRATE_RES_USG'
                  ,p_source_primary_key  => l_act_ver_id ||'|'|| get_lang_code(l_evt_language_id,l_language_id)
                  ,p_business_group_id   => Ids.Business_group_id
                  ,p_object_value        => Ids.Version_name
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
     end;


   begin
	  Insert into PER_COMPETENCE_ELEMENTS
        	(competence_element_id
		,business_group_id
		,object_version_number
		,type
		,competence_id
		,member_competence_set_id
		,proficiency_level_id
		,effective_date_from
		,effective_date_to
		,object_id
		,object_name)
	    SELECT per_competence_elements_s.nextval
 		,nvl(Ids.business_group_id,0)
		,1
		,'OTA_OFFERING'
		,cmp.competence_id
		,cmp.member_competence_set_id
		,cmp.proficiency_level_id
  		,cmp.effective_date_from
  		,cmp.effective_date_to
		,l_offering_id
		,'OTA'
  	    FROM PER_COMPETENCE_ELEMENTS cmp
  	    WHERE cmp.type = 'TRAINER'
  	    AND cmp.object_id = l_act_ver_id
        AND not exists (select 1 from per_competence_elements pce
                        where pce.object_id = l_act_ver_id and type = 'OTA_OFFERING');
       Exception

       when others then
         b_act_ver_migrated := false;
         l_err_code := SQLCODE;
         l_err_msg  := nvl(substr(SQLERRM,1,2000),'When Moving Competencies associated with this Course');
         add_log_entry( p_table_name     => 'MIGRATE_TRN_COMP'
                  ,p_source_primary_key  =>  l_act_ver_id ||'|'|| get_lang_code(l_evt_language_id,l_language_id)
--get_lang_code(case when l_evt_language_id = NULL then l_language_id else l_evt_language_id end)
                  ,p_business_group_id   => Ids.Business_group_id
                  ,p_object_value        => Ids.version_name
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id          => p_update_id
                  ,p_process_date        =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
     end;
  -- Sets the Parent offering id .

        Update Ota_events Evt
        Set Evt.Parent_Offering_id = l_offering_id
        Where Evt.activity_Version_id = Ids.Activity_Version_id
--        and   Nvl(Evt.language_id,0) = Decode(Offering_RecSet(Evt_lang).language_id,NULL,0,l_Language_id)
       and (
            (l_evt_language_id is NULL and Evt.language_id is NULL)
            OR
            Evt.language_id = l_evt_language_id
            )

--	and   Nvl(Evt.language_id,0) = Decode(l_evt_language_id,NULL,Nvl(Evt.language_id,0),l_evt_language_id) commented for bug# 4139874
        and   Evt.business_group_id = Ids.Business_group_id
        and   Parent_Offering_id is NULL ;

	Exception
       when others then
         b_act_ver_migrated := false;
         l_err_code := SQLCODE;
         l_err_msg  := nvl(substr(SQLERRM,1,2000),'When creating Offerings from Activity Versions');
         add_log_entry( p_table_name     => 'CREATE_OFFERING'
                  ,p_source_primary_key  =>  l_act_ver_id ||'|'||  get_lang_code(l_evt_language_id,l_language_id)
                  ,p_business_group_id   => Ids.Business_group_id
                  ,p_object_value        => Ids.version_name
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);

     end;
     else

        Update Ota_events Evt
        Set Evt.Parent_Offering_id = l_parent_offering_id
        Where Evt.activity_Version_id = Ids.Activity_Version_id
--        and   Nvl(Evt.language_id,0) = Decode(l_evt_language_id,NULL,Nvl(Evt.language_id,0),l_evt_language_id) Commented for bug# 4139874
       and (
            (l_evt_language_id is NULL and Evt.language_id is NULL)
            OR
            Evt.language_id = l_evt_language_id
            )

        and   Evt.business_group_id = Ids.Business_group_id
        and   Parent_offering_id is NULL ;
      end if;
      --Close c_dup_off;



   -- End loop;

  End Loop; -- Events loop end here

        -- Deleting all the unreferenced child entities for a particular
      -- activity version id.
      -- Only delete records if migration for activity version is successful.
      -- i.e. No errors encountered during migrating any of the entities.
  if b_act_ver_migrated then
      -- 1) Resource Booking
      delete from ota_resource_usages
      where activity_version_id = l_act_ver_id
      and   offering_id is null;

      --2) Delivery Modes
        -- Add Log entry to record delivery modes
           for csr_dm_list in c_get_tav_dms(l_act_ver_id) loop
             add_log_entry(p_upgrade_id=>p_update_id
                        ,p_table_name =>substr('DM_DEL_INFO'||'|'||ids.activity_version_id,1,30)
                        ,p_source_primary_key => csr_dm_list.category_usage_id
                        ,p_object_value => ids.version_name
                        ,p_message_text        =>csr_dm_list.category
                        ,p_process_date => get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_I
                  	 ,p_upgrade_name       => UPGRADE_NAME);
           end loop;

        -- Delete Delivery Mode
      delete from ota_act_cat_inclusions
      where activity_version_id = l_act_ver_id
      and category_usage_id in (select category_usage_id
                                 from ota_category_usages
                                 where type = 'DM');

      --3) Trainer Competences
      delete from per_competence_elements
      where object_id =  l_act_ver_id
      and   type = 'TRAINER';
    end if;


  End loop; -- Activity Version loop ends here


  Select count(Activity_version_id) into l_rows_processed
  from ota_activity_versions
  Where activity_Version_id between p_start_pkid and p_end_pkid ;

  p_rows_processed := l_rows_processed;

End Create_Offering;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_apps_timezone >---------------------------|
-- ----------------------------------------------------------------------------
function get_apps_timezone(ila_tzone in varchar2) return varchar2 is

   NOT_MAPPED constant varchar2(20) := 'NOT_MAPPED';
   TZ_DEFAULT constant varchar2(20) := null;
   type ila_timezone_type is table of ota_events.timezone%TYPE ;
   type fnd_timezone_type is table of ota_events.timezone%TYPE ;
   ila_timezones ila_timezone_type
      := ila_timezone_type( 'GMT'    -- 'Pacific/Kwajalein'
                           ,'SST'   -- 'Pacific/Midway'
                           ,'HST'   --  NOT_MAPPED
                           ,'AKDT'   --  NOT_MAPPED
                           ,'PDT'   -- 'America/Los_Angeles'
                           ,'MST'   -- 'America/Denver'
                           ,'CST'   -- 'America/Chicago'
                           ,'EST'   -- 'America/New_York'
                           ,'AST'   -- 'Atlantic/Bermuda'
                           ,'NDT'   --  NOT_MAPPED
                           ,'BRST'   -- 'America/Buenos_Aires'
                           ,'GST'   -- NOT_MAPPED
                           ,'AZOST'   -- 'Atlantic/Azores'
                           ,'WEST'   -- 'GMT'
                           ,'CEST'   -- 'Europe/Amsterdam'
                           ,'EET'   -- 'Europe/Athens'
                           ,'EET'   -- 'Africa/Cairo'
                           ,'EET'   -- 'Europe/Riga'
                           ,'EAT'   -- 'Asia/Baghdad'
                           ,'MSD'   -- 'Europe/Moscow'
                           ,'IRST'   -- 'Asia/Tehran'
                           ,'AMST'   -- 'Asia/Muscat'
                           ,'AFT'   -- 'Asia/Kabul'
                           ,'PKT'   -- 'Asia/Karachi'
                           ,'IST'   -- 'Asia/Calcutta'
                           ,'BDT'   -- 'Asia/Almaty'
                           ,'ICT'   -- 'Asia/Bangkok'
                           ,'CST'   -- 'Asia/Hong_Kong'
                           ,'CST'   -- 'Asia/Singapore'
                           ,'PWT'   -- 'Asia/Tokyo'
                           ,'PWT'   -- 'Asia/Seoul'
                           ,'CST'   -- 'Australia/Adelaide'
                           ,'TRUT'   -- 'Australia/Brisbane'
                           ,'TRUT'   -- 'Australia/Melbourne'
                           ,'TRUT'   -- 'Australia/Hobart'
                           ,'MAGST'   -- 'Asia/Magadan'
                           ,'WFT'   -- 'Pacific/Auckland'
                           ,'WFT');  --'Asia/Kamchatka'


-- Mapping between iLearning and Java Timezone codes are as follows :
--ILA     JAVA
--TZ      TZ
--===     ====
--EK	GMT
--MIS	SST
--HAW	HST
--ALA	AKDT
--PST	PDT
--MST	MST
--CST	CST
--EST	EST
--AST	AST
--NWF	NDT
--BBA	BRST
--MAT	GST
--AZO	AZOST
--GMT	WEST
--AMS	CEST
--AIM	EET
--BCP	EET
--HRI	EET
--BKR	EAT
--MSV	MSD
--THE	IRST
--ABT	AMST
--KAB	AFT
--EIK	PKT
--BCD	IST
--ADC	BDT
--BHJ	ICT
--BHU	CST
--SST	CST
--OST	PWT
--SYA	PWT
--ADA	CST
--BGP	TRUT
--CMS	TRUT
--HVL	TRUT
--MSN	MAGST
--AWE	WFT
--FKM	WFT
--

   fnd_timezones fnd_timezone_type
       := fnd_timezone_type
          (  'Pacific/Kwajalein'
            ,'Pacific/Midway'
            ,'HST'
            ,'AKDT'
            ,'America/Los_Angeles'
            ,'America/Denver'
            ,'America/Chicago'
            ,'America/New_York'
            ,'Atlantic/Bermuda'
            ,'NDT'
            ,'America/Buenos_Aires'
            ,'GST'
            ,'Atlantic/Azores'
            ,'GMT'
            ,'Europe/Amsterdam'
            ,'Europe/Athens'
            ,'Africa/Cairo'
            ,'Europe/Riga'
            ,'Asia/Baghdad'
            ,'Europe/Moscow'
            ,'Asia/Tehran'
            ,'Asia/Muscat'
            ,'Asia/Kabul'
            ,'Asia/Karachi'
            ,'Asia/Calcutta'
            ,'Asia/Almaty'
            ,'Asia/Bangkok'
            ,'Asia/Hong_Kong'
            ,'Asia/Singapore'
            ,'Asia/Tokyo'
            ,'Asia/Seoul'
            ,'Australia/Adelaide'
            ,'Australia/Brisbane'
            ,'Australia/Melbourne'
            ,'Australia/Hobart'
            ,'Asia/Magadan'
            ,'Pacific/Auckland'
            ,'Asia/Kamchatka');

   ila_i BINARY_INTEGER;
   fnd_i BINARY_INTEGER;

  retval ota_events.timezone%TYPE := TZ_DEFAULT;

  begin

    if ( ila_tzone is null ) then
      return NULL;
    end if;
    -- Check for iLearning timezone, if match found return
    -- the corresponding FND_TIMEZONE.
     for ila_i in ila_timezones.FIRST..ila_timezones.LAST
      loop
        if (ila_timezones(ila_i) = ila_tzone ) then
          retval := fnd_timezones(ila_i);
          exit;
        end if;
      end loop;

     -- If no match is found check for existance in FND_TIMEZONES
     -- if found, return the the same.
     if ( retval is null ) then
      for fnd_i in fnd_timezones.FIRST..fnd_timezones.LAST
       loop
         if ( fnd_timezones(fnd_i) = ila_tzone ) then
            retval :=  fnd_timezones(fnd_i);
            exit;
         end if;
       end loop;
     end if;

      -- if no match is found in either iLearning timezone and
      -- FND_TIMEZONE or the iLearning Timezone is not mapped
      -- return NULL
      if ( retval = NOT_MAPPED ) then
           retval := TZ_DEFAULT;
     end if;

    return retval;

  end get_apps_timezone;


-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Event_Associations >------------------|
-- ----------------------------------------------------------------------------
Procedure Upgrade_Event_Associations(
                            p_process_control IN  varchar2,
                            p_start_pkid      IN  number,
                            p_end_pkid        IN  number,
                            p_rows_processed  OUT nocopy number,
                            p_update_id in number default 1 ) is

 l_rows_processed number;
begin
   update OTA_EVENT_ASSOCIATIONS
   set    self_enrollment_flag = 'N'
   where  event_association_id between p_start_pkid and  p_end_pkid
   and  self_enrollment_flag is null   -- Bug#6804783
   and   (           customer_id     is not null
           or        job_id          is not null
           or        organization_id is not null
           or        position_id     is not null);


  select nvl(count(event_association_id),0)
  into l_rows_processed
  from OTA_EVENT_ASSOCIATIONS
  where event_association_id between  p_start_pkid  and p_end_pkid ;

  p_rows_processed := l_rows_processed;


end Upgrade_Event_Associations;
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Events >------------------------------|
-- ----------------------------------------------------------------------------
Procedure Upgrade_Events(   p_process_control IN  varchar2,
                            p_start_pkid      IN  number,
                            p_end_pkid        IN  number,
                            p_rows_processed  OUT nocopy number,
                            p_update_id in number default 1 ) is

 l_rows_processed number := 0;
begin
  -- Upgrade OM Events
  -- 1) set book_independent_flag to N iff null
  -- 2) Maximum_internal_attendees to 0 for price basis in 'C' or 'O'
  update OTA_EVENTS
  set    book_independent_flag = nvl(book_independent_flag,'N'),
         Maximum_internal_attendees = Decode(Price_basis,'C',0,'O',0,Maximum_internal_attendees)
  where  event_id between p_start_pkid  and p_end_pkid;


  -- Update TIMEZONE for iLearning imported events to
  -- the corresponding APPS (FND_TIMEZONES_VL) timezone code.
  update OTA_EVENTS
  set    TIMEZONE = get_apps_timezone(timezone)
  where  offering_id is not null --iLearning imported events.
  and event_id between p_start_pkid  and p_end_pkid
  and  TIMEZONE is NOT NULL;

  select nvl(count(event_id),0)
  into l_rows_processed
  from ota_events
  where event_id between  p_start_pkid  and p_end_pkid ;

  p_rows_processed := l_rows_processed;
end Upgrade_Events;

--enh 2733966 --
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Off_Lang_Code >-----------------------|
-- ----------------------------------------------------------------------------
-- This procedure populates Language_code in OTA_OFFERINGS if it is null.

Procedure Upgrade_Off_Lang_Code is

begin
	update ota_offerings a
	set a.language_code=decode(a.language_code, null, (select fnl.language_code
	FROM fnd_languages fl,
	fnd_natural_languages fnl  WHERE
	fl.iso_language_3 = UPPER(fnl.iso_language_3) AND fl.iso_territory =
	fnl.iso_territory and fl.language_id=a.language_id),a.language_code);


end Upgrade_Off_Lang_Code;

--enh 2733966 --
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_LO_Lang_Code >-----------------------|
-- ----------------------------------------------------------------------------
-- This procedure populates Language_code in OTA_LEARNING_OBJECTS if it is null.

Procedure Upgrade_LO_Lang_Code is

begin
	update ota_learning_objects a
	set a.language_code=decode(a.language_code, null, (select fnl.language_code
	FROM fnd_languages fl,
	fnd_natural_languages fnl  WHERE
	fl.iso_language_3 = UPPER(fnl.iso_language_3) AND fl.iso_territory =
	fnl.iso_territory and fl.language_id=a.language_id),a.language_code);

end Upgrade_LO_Lang_Code;

--enh 2733966 --
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Comp_Lang_Code >-----------------------|
-- ----------------------------------------------------------------------------
-- This procedure populates Language_code in OTA_COMPETENCE_LANGUAGES if it is null.

Procedure Upgrade_Comp_Lang_Code is

begin
	update ota_competence_languages a
	set a.language_code=decode(a.language_code, null, (select fnl.language_code
	FROM fnd_languages fl,
	fnd_natural_languages fnl  WHERE
	fl.iso_language_3 = UPPER(fnl.iso_language_3) AND fl.iso_territory =
	fnl.iso_territory and fl.language_id=a.language_id),a.language_code);

end Upgrade_Comp_Lang_Code;

--enh 2733966 --
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Language_Code >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure checks if Language_Code is null in OTA_OFFERINGS, OTA_LEARNING_OBJECTS
-- and OTA_COMPETENCE_LANGUAGES and populate it based on Langauge_Id
Procedure Upgrade_Language_Code is

	  cursor c_exist_off is
      select 1
      from   ota_offerings
      where language_code is null;

      cursor c_exist_lo is
      select 1
      from   ota_learning_objects
      where language_code is null;

      cursor c_exist_comp is
      select 1
      from   ota_competence_languages
      where language_code is null;


      l_exists_off boolean := false;
      l_exists_lo  boolean := false;
      l_exists_comp boolean := false;
	  l_upg_id number;
      l_ret    number ;
      l_err_code varchar2(72);
      l_err_msg  varchar2(2000);

begin
		 l_upg_id := get_next_upgrade_id;

		 add_log_entry( p_table_name          => 'UPG_LANGUAGE_CODE'
                  		,p_source_primary_key => '-1'
                  		,p_object_value       => ''
                  		,p_message_text       => 'Starting LanguageCode upgrade'
                  		,p_upgrade_id         => l_upg_id
                  		,p_process_date       =>  get_process_date(l_upg_id,'UPG_LANGUAGE_CODE')
                  	 	,p_log_type           => LOG_TYPE_N
                  	 	,p_upgrade_name       => 'UPG_LANGUAGE_CODE');

		 open c_exist_off;
         fetch c_exist_off into l_ret;
         if c_exist_off%FOUND then
           l_exists_off := true;
         end if;
         close c_exist_off;

		 if l_exists_off then

		 	begin
			 	upgrade_off_lang_code;
			exception
			when others then

    			l_err_code := SQLCODE;
    			l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When upgrading Language code for OTA_OFFERINGS');

				add_log_entry( p_table_name  => 'UPG_LANGUAGE_CODE'
                  ,p_source_primary_key => '999'
                  ,p_object_value       => 'No Language code updated for OTA_OFFERINGS'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => l_upg_id
                  ,p_process_date       => get_process_date(l_upg_id,'UPG_LANGUAGE_CODE')
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => 'UPG_LANGUAGE_CODE');
			end;


		 end if; -- end offering upgrade




		 open c_exist_lo;
         fetch c_exist_lo into l_ret;
         if c_exist_lo%FOUND then
           l_exists_lo := true;
         end if;
         close c_exist_lo;

		 if l_exists_lo then

		 	begin
			 	upgrade_lo_lang_code;
			exception
			when others then

    			l_err_code := SQLCODE;
    			l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When upgrading Language code for OTA_LEARNING_OBJECTS');

				add_log_entry( p_table_name  => 'UPG_LANGUAGE_CODE'
                  ,p_source_primary_key => '9999'
                  ,p_object_value       => 'No Language code updated for OTA_LEARNING_OBJETCS'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => l_upg_id
                  ,p_process_date       => get_process_date(l_upg_id,'UPG_LANGUAGE_CODE')
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => 'UPG_LANGUAGE_CODE');
			end;


		 end if; -- end learning_objects upgrade


		 open c_exist_comp;
         fetch c_exist_comp into l_ret;
         if c_exist_comp%FOUND then
           l_exists_comp := true;
         end if;
         close c_exist_comp;

         if l_exists_comp then
         	begin
			 	upgrade_comp_lang_code;
			exception
			when others then

    			l_err_code := SQLCODE;
    			l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When upgrading Language code for OTA_COMPETENCE_LANGUAGES');

				add_log_entry( p_table_name  => 'UPG_LANGUAGE_CODE'
                  ,p_source_primary_key => '99999'
                  ,p_object_value       => 'No Language code updated for OTA_COMPETENCE_LANGUAGES'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => l_upg_id
                  ,p_process_date       => get_process_date(l_upg_id,'UPG_LANGUAGE_CODE')
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => 'UPG_LANGUAGE_CODE');
			end;

		 end if;

end Upgrade_Language_Code;


-- ----------------------------------------------------------------------------
-- |--------------------------< Add_Log_Entry >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_log_entry(p_upgrade_id in number
                        ,p_table_name in varchar2
                        ,p_business_group_id in number default null
                        ,p_source_primary_key in varchar2
                        ,p_object_value  in varchar2 default null
                        ,p_message_text  in varchar2 default null
                        ,p_process_date  in date
                	 ,p_log_type     in varchar2 default null
                  	 ,p_upgrade_name in varchar2 default null) is

l_upgrade_id number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);

begin

 Insert into ota_upgrade_log(upgrade_id,table_name,business_group_id,source_primary_key,object_value,message_text,process_date,log_type,upgrade_name)
 Values(p_upgrade_id,p_table_name,p_business_group_id,p_source_primary_key,p_object_value,p_message_text,p_process_date,p_log_type,p_upgrade_name) ;

Exception
 When Others then
    Select Nvl(Max(source_primary_key),0)+1 into l_upgrade_id
    From Ota_Upgrade_Log
    Where Table_name = 'OTA_UPGRADE_LOG' ;

    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When trapping Logging errors');
    Begin
      Insert into ota_upgrade_log(upgrade_id,table_name,business_group_id,source_primary_key,object_value,message_text,process_date,Target_primary_key,log_type,upgrade_name)
      Values(p_upgrade_id,'OTA_UPGRADE_LOG',p_business_group_id,l_upgrade_id,p_table_name,p_message_text,p_process_date,p_source_primary_key,p_log_type,p_upgrade_name) ;
    Exception
      When Dup_val_on_index then
        Null;
    End ;
End;
-- ----------------------------------------------------------------------------
-- |--------------------------< Migrate_Lookup >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure  Migrate_Lookup(p_update_id in number default 1 ) is
l_err_code varchar2(72);
  l_err_msg  varchar2(2000);
begin
-- Migrates User defined lookup codes defined under 'FREQUENCY' to 'OTA_DURATION_UNITS'
--
  begin
  Insert into FND_LOOKUP_VALUES
   (LOOKUP_TYPE,LANGUAGE,LOOKUP_CODE,MEANING,DESCRIPTION,ENABLED_FLAG,START_DATE_ACTIVE,
   END_DATE_ACTIVE,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,SOURCE_LANG,
   SECURITY_GROUP_ID,VIEW_APPLICATION_ID,TERRITORY_CODE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,
   ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
   ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,TAG)
  Select 'OTA_DURATION_UNITS',lkp.LANGUAGE,lkp.LOOKUP_CODE,lkp.MEANING,lkp.DESCRIPTION,lkp.ENABLED_FLAG,lkp.START_DATE_ACTIVE,
   lkp.END_DATE_ACTIVE,lkp.CREATED_BY,lkp.CREATION_DATE,lkp.LAST_UPDATED_BY,lkp.LAST_UPDATE_LOGIN,lkp.LAST_UPDATE_DATE,lkp.SOURCE_LANG,
   lkp.SECURITY_GROUP_ID,lkp.VIEW_APPLICATION_ID,lkp.TERRITORY_CODE,lkp.ATTRIBUTE_CATEGORY,lkp.ATTRIBUTE1,lkp.ATTRIBUTE2,lkp.ATTRIBUTE3,
   lkp.ATTRIBUTE4,lkp.ATTRIBUTE5,lkp.ATTRIBUTE6,lkp.ATTRIBUTE7,lkp.ATTRIBUTE8,lkp.ATTRIBUTE9,lkp.ATTRIBUTE10,lkp.ATTRIBUTE11,lkp.ATTRIBUTE12,
   lkp.ATTRIBUTE13,lkp.ATTRIBUTE14,lkp.ATTRIBUTE15,TAG
  From Fnd_Lookup_values lkp
  Where lkp.Lookup_type = 'FREQUENCY'
  and lkp.created_by not in (1,2)
  and (lkp.Lookup_code,lkp.language)
  not in (Select flk.Lookup_code,flk.language from Fnd_lookup_values flk
          Where flk.Lookup_type = 'OTA_DURATION_UNITS') ;
  Exception
   when others then
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When Migrating Frequency Lookups');
    add_log_entry( p_table_name         => 'MIGRATE_FREQUENCY'
                  ,p_source_primary_key => '  '
                  ,p_object_value       => 'No lookup values migrated for Frequncy'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
   End;
end Migrate_lookup;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_ctg_dm_for_act_bg >---------------------------|
-- ----------------------------------------------------------------------------
Procedure create_ctg_dm_for_act_bg(p_update_id in number default 1 )  is
 Cursor Csr_Activity_Bg is
  Select tad.business_group_id
  From   Ota_Activity_definitions tad
  Group by tad.business_group_id ;

  Cursor Csr_Bg_name(p_bg_id number) is
  Select hou.name Bg_name
  From hr_organization_units hou
  Where hou.business_group_id = p_bg_id
  and   hou.business_group_id = hou.organization_id ;

 l_default_dm Ota_Category_usages_tl.Category_usage_id%Type;
 l_root_cat_usage_id ota_category_usages.category_usage_id%Type;
  l_bg_name hr_organization_units.name%Type ;

begin

 For Act_Bg in csr_Activity_bg Loop
    Open Csr_bg_name(Act_bg.business_group_id);
    Fetch Csr_bg_name into l_bg_name;
    If Csr_bg_name%found then
      --Fetch csr_bg_name into l_bg_name;
      Create_Root_Category(Act_bg.Business_group_id,l_Bg_name,l_root_cat_usage_id);
      Create_Default_DM(Act_bg.business_group_id,l_default_dm);
    End if;
    Close csr_bg_name;
  End Loop;

  Upgrade_delivery_mode;

end create_ctg_dm_for_act_bg;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_offering_name_with_lang >-----------------|
-- ----------------------------------------------------------------------------
function get_offering_name_with_lang(p_off_name    in varchar2,
                                     p_language_id in number,
                                     p_language    in varchar2)
return varchar2 is
MAX_OFFERING_NAME_LEN constant number := 80;
MAX_DATA_TRUNC_LEN    constant number := 10;
cursor c_get_lang_description is
select flt.description
from   fnd_languages fl,
       fnd_languages_tl flt
where  flt.language_code = fl.language_code
and    flt.language     = p_language
and    fl.language_id = p_language_id ;
l_lang_len number;
l_off_name ota_offerings_tl.name%type := p_off_name;
description fnd_languages_tl.description%type;
begin


   open  c_get_lang_description;
   fetch c_get_lang_description into description;
   close c_get_lang_description;

   l_lang_len := length(l_off_name||'-'||description) ;
   If l_lang_len > MAX_OFFERING_NAME_LEN then
      l_lang_len := l_lang_len - MAX_OFFERING_NAME_LEN ;
     If l_lang_len > MAX_DATA_TRUNC_LEN then
        l_lang_len := MAX_DATA_TRUNC_LEN;
     End if;
   End if;

   if( length(l_off_name) = 80 OR length(l_off_name||'-'||description) > 80 )  then
     l_off_name := substrb(l_off_name,1,80-l_lang_len);
   end if;

   l_off_name := substrb(l_off_name||'-'||description,1,80);

   return l_off_name;

end get_offering_name_with_lang;
-- ----------------------------------------------------------------------------
-- |--------------------------< upgrade_root_category_dates >------------------|
-- ----------------------------------------------------------------------------
procedure upgrade_root_category_dates is

cursor min_ctg_start_date(parent_ctg number) is
select nvl(min(start_date_active),trunc(sysdate))
from   ota_category_usages
where  parent_cat_usage_id = parent_ctg
and    type = 'C';

cursor c_root_ctgs is
select category_usage_id,start_date_active
from   ota_category_usages
where  type = 'C'
and    parent_cat_usage_id is null;

l_start_date date;
l_min_start_date date;
begin

  for c_roots in c_root_ctgs
   loop
      open min_ctg_start_date(c_roots.category_usage_id);
      fetch min_ctg_start_date into l_start_date;
      close min_ctg_start_date;

      l_min_start_date := least(nvl(c_roots.start_date_active,l_start_date),l_start_date);

      update ota_category_usages
      set    start_date_active = l_min_start_date
      where  category_usage_id = c_roots.category_usage_id;


   end loop;
end upgrade_root_category_dates;

-- ----------------------------------------------------------------------------
-- |--------------------------< submit_upgrade_report >------------------------|
-- ----------------------------------------------------------------------------
-- Submit an upgrade process
procedure submit_upgrade_report is

  OTA_APPLICATION_ID constant number        := 810;
  OTA_STATUS_INSTALLED constant varchar2(2) := 'I';

  l_usr_id  number;
  l_resp_id  number;
  l_resp_appl_id number;
  l_request_id number := null;
  l_installed fnd_product_installations.status%type;
  cursor csr_ota_installed is
      select fpi.status
      from fnd_product_installations fpi
      where fpi.application_id = OTA_APPLICATION_ID;

  cursor csr_get_resp_details is
      select frp.application_id, frp.responsibility_id
	  from fnd_responsibility frp
	  where frp.responsibility_key='SYSTEM_ADMINISTRATOR';

  cursor csr_get_user_details is
      select fu.user_id
      from fnd_user fu
	  where fu.user_name = 'SYSADMIN';
begin

  /*
    ** The update is required so submit a request for the SYSADMIN user using
    ** the System Administrator responsibility.
    */

    /* Get the required IDs...
    */
    open csr_ota_installed;
    fetch csr_ota_installed into l_installed;
    close csr_ota_installed;

    if ( l_installed = OTA_STATUS_INSTALLED ) then
        open csr_get_user_details;
        fetch csr_get_user_details into l_usr_id;
        close csr_get_user_details;

        open csr_get_resp_details;
        fetch csr_get_resp_details into l_resp_appl_id, l_resp_id;
        close csr_get_resp_details;

        /* Initiate an APPS session as SYSADMIN*/
        fnd_global.apps_initialize(user_id      => l_usr_id,
                                   resp_id      => l_resp_id,
		                	       resp_appl_id => l_resp_appl_id);

        /*Submit the Upgrade Log Request with initial upgrade arguments */
       l_request_id := fnd_request.submit_request(
                                    application => 'OTA',
                                    program => 'OTARPUPG',
			                        argument1 => '1',
			                        argument2 => fnd_date.date_to_canonical(sysdate));
   end if;



end submit_upgrade_report;
-- ----------------------------------------------------------------------------
-- |--------------------------<validate_proc_for_hr_upg  >------------------------|
-- ----------------------------------------------------------------------------
-- Validation procedure for submitting the upgrade report during patch.
 procedure validate_proc_for_hr_upg(do_upg out nocopy varchar2)  is
     OTA_APPLICATION_ID constant number        := 810;
     OTA_STATUS_INSTALLED constant varchar2(2) := 'I';

      l_installed fnd_product_installations.status%type;
      cursor csr_ota_installed is
      select fpi.status
      from fnd_product_installations fpi
      where fpi.application_id = OTA_APPLICATION_ID;

      l_do_submit varchar2(10) := 'FALSE';

begin
    open csr_ota_installed;
    fetch csr_ota_installed into l_installed;
    if ( l_installed =OTA_STATUS_INSTALLED ) then
      l_do_submit := 'TRUE';
    end if;
    close csr_ota_installed;

    do_upg  := l_do_submit;
end validate_proc_for_hr_upg;

-- ----------------------------------------------------------------------------
-- |--------------------------<migrate_tad_dff_contexts  >--------------------|
-- ----------------------------------------------------------------------------

procedure migrate_tad_dff_contexts (p_upgrade_id in number default 1) is
 l_date date;
 Cursor C1 (p_context_code in varchar2)
 is Select fcu.*,fvs.flex_value_set_name
 From Fnd_Descr_Flex_Col_Usage_Vl fcu, fnd_flex_value_sets fvs
 Where fcu.Application_id = 810
 and  fcu.Descriptive_FlexField_Name = 'OTA_ACTIVITY_DEFINITIONS'
 and  fcu.Descriptive_Flex_Context_code = p_context_code
 and  fcu.flex_value_set_id = fvs.flex_value_set_id(+)
 and Not exists (SELECT 'Y'
 From Fnd_Descr_Flex_Col_Usage_Vl cat_fcu
 Where cat_fcu.Application_id = fcu.application_id
 and  cat_fcu.Descriptive_FlexField_Name = 'OTA_CATEGORY_USAGES'
 and  cat_fcu.Descriptive_Flex_Context_code = fcu.Descriptive_Flex_Context_code
 and  cat_fcu.end_user_column_name = fcu.end_user_column_name );

 l_segrec FND_DESCR_FLEX_COLUMN_USAGES%RowType ;

 l_err_code varchar2(72);
l_err_msg  varchar2(2000);

 l_context_exists Varchar2(1) := 'N' ;

 l_context_code FND_DESCR_FLEX_CONTEXTS.descriptive_flex_context_code%Type;
 l_segment_exists Varchar2(1) := 'N' ;

 Cursor Csr_DFF_contexts is Select * from FND_DESCR_FLEX_CONTEXTS_vl
 Where Application_id = 810
 and   Descriptive_FLexfield_Name = 'OTA_ACTIVITY_DEFINITIONS'
 and   Enabled_Flag = 'Y';

 Cursor Csr_Segment_exists(p_context_name in varchar2)  is  SELECT 'Y'
     FROM fnd_descriptive_flexs
     WHERE application_id = 810
     AND descriptive_flexfield_name = p_context_name ;

Begin
 fnd_flex_dsc_api.set_session_mode('seed_data');

 Select Trunc(sysdate) into l_date from dual ;

 For dff_context in Csr_Dff_contexts
 Loop
 begin
  l_context_exists := NULL ;
  Select Max('Y') into l_context_exists
  From FND_DESCR_FLEX_CONTEXTS_vl
  Where Descriptive_Flexfield_name = 'OTA_CATEGORY_USAGES'
  and   Descriptive_Flex_COntext_Code = dff_context.Descriptive_Flex_Context_code ;
  -- If there is a definition already existis and it is a Global context
  -- then NO context will be created but the strucre will be added to the existing one.

  If (NOT (dff_context.Global_Flag = 'Y' OR l_context_exists is NOT NULL)) then

  fnd_flex_dsc_api.create_context(
     appl_short_name => 'OTA' ,
     flexfield_name => 'OTA_CATEGORY_USAGES',
     context_code => Dff_context.Descriptive_flex_context_code,
     context_name => Nvl(dff_context.DESCRiptive_FLEX_CONTEXT_NAME,'*-*'),
     description => dff_context.DESCRIPTION,
     enabled => dff_context.ENABLED_FLAG );

   End If;
   For I in C1 (Dff_context.Descriptive_flex_context_code)
   Loop
     begin
     fnd_flex_dsc_api.create_segment(
      appl_short_name => 'OTA' ,
      flexfield_name => 'OTA_CATEGORY_USAGES', --'Add''l Category Information',
      context_name => Nvl(dff_context.DESCRiptive_FLEX_CONTEXT_NAME,'*-*'),
      name => I.END_USER_COLUMN_NAME,
      column => Replace(I.APPLICATION_COLUMN_NAME,'TAD_INFORMATION','ATTRIBUTE'),
      description => I.DESCRIPTION,
      sequence_number => I.COLUMN_SEQ_NUM,
      enabled => I.ENABLED_FLAG,
      displayed => I.DISPLAY_FLAG,
      value_set => I.flex_value_set_name, --'7 Characters',
      default_type => I.DEFAULT_TYPE,
      default_value => I.DEFAULT_VALUE,
      required => I.REQUIRED_FLAG,
      security_enabled => I.SECURITY_ENABLED_FLAG,
      display_size => I.DISPLAY_SIZE,
      description_size => I.MAXIMUM_DESCRIPTION_LEN,
      concatenated_description_size => I.CONCATENATION_DESCRIPTION_LEN,
      list_of_values_prompt => I.FORM_ABOVE_PROMPT,
      window_prompt => I.FORM_LEFT_PROMPT,
   range => NULL);
   Exception
   when others then
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'migrate_tad_dff_contexts - segments');
    add_log_entry( p_table_name         => 'MIGRATE_TAD_DFF_SEGS'
                  ,p_source_primary_key => substr(dff_context.application_id||'|'||
                                           dff_context.descriptive_flexfield_name||'|'||
                                           I.application_column_name,1,80)
                  ,p_object_value       => 'migrate_tad_dff_contexts'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_upgrade_id
                  ,p_process_date       =>  get_process_date(p_upgrade_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
   End;


   End Loop;
  Exception
   when others then
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'migrate_tad_dff_contexts');
    add_log_entry( p_table_name         => 'MIGRATE_TAD_DFF'
                  ,p_source_primary_key => substr( dff_context.application_id||
                                           dff_context.descriptive_flexfield_name,
                                           1,80)
                  ,p_object_value       => 'migrate_tad_dff_contexts'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_upgrade_id
                  ,p_process_date       =>  get_process_date(p_upgrade_id,UPGRADE_NAME)
                  	 ,p_log_type           => LOG_TYPE_E
                  	 ,p_upgrade_name       => UPGRADE_NAME);
   End;
 End Loop;

End migrate_tad_dff_contexts;
--
-- ----------------------------------------------------------------------------
-- |---------------------< upg_tdb_history_att_flags >-------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will update ota_delegate_bookings table records
--  a. successful_attendance_flag to 'Y' where it is NULL and enrollment status
--         is 'Attended'
--  b. is_history_flag to 'Y' where enrollment status is 'Attended'
--  c. enrollment status to 'Attended' for online classes, if lo has 'Completed' / 'Passed' status.

PROCEDURE upg_tdb_history_att_flags(
   p_process_control IN		varchar2,
   p_start_rowid     IN         rowid,
   p_end_rowid       IN         rowid,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) is

  l_rows_processed number := 0;

  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);
  l_upgrade_id ota_upgrade_log.upgrade_id%Type;
  l_process_date ota_upgrade_log.process_date%Type;

  l_event_id number;
  l_business_group_id number;
  l_learning_object_id ota_learning_objects.learning_object_id%Type ;

  CURSOR c_booking_id IS
  SELECT Booking_id, event_id,content_player_status,business_group_id,object_version_number,
  delegate_person_id,
  contact_id,
  customer_id ,
  delegate_contact_id ,
  organization_id,
  sponsor_person_id,
  sponsor_assignment_id,
  delegate_assignment_id ,
  is_history_flag,
  booking_status_type_id
  FROM   ota_delegate_bookings
  WHERE  BOOKING_STATUS_TYPE_ID in
	 (select booking_status_type_id from ota_booking_status_types
	 where type ='P')
   AND   RowID Between p_start_rowid and p_end_rowid ;

  CURSOR c_learning_object_id IS
  SELECT off.learning_object_id
  FROM ota_events evt, ota_offerings off
  WHERE evt.event_id = l_event_id
  and   evt.parent_offering_id = off.offering_id;

  CURSOR c_less_status(p_user_id in number,p_lo_id in number) IS
  SELECT lesson_status
  FROM ota_performances
  WHERE learning_object_id = p_lo_id
   AND user_id = p_user_id
   AND lesson_status IN ('P', 'C');


  CURSOR c_booking_status_type_id IS
  SELECT booking_status_type_id
  FROM ota_booking_status_types
  WHERE type ='A'
  AND business_group_id = l_business_group_id
  ORDER BY Nvl(Default_flag,'N') Desc;


  l_lo_completed Varchar2(1) := 'N';
  l_lesson_status Varchar2(1);
  l_booking_status_type_id number ;
  l_user_id number;
  l_tfl_ovn number;
  l_fin_line number;
Begin

  UPDATE /*+ ROWID (TDB) */ OTA_DELEGATE_BOOKINGS TDB
  SET    IS_HISTORY_FLAG = Decode(Is_History_flag,NULL,'Y',Is_History_Flag),
         successful_attendance_flag = Decode(successful_attendance_flag,NULL,'Y',successful_attendance_flag)
  WHERE  BOOKING_STATUS_TYPE_ID in
  	(select booking_status_type_id from ota_booking_status_types
  	where type ='A')
  AND    RowID Between p_start_rowid and p_end_rowid ;

  p_rows_processed := SQL%ROWCOUNT;


  For l_c_booking_id in c_booking_id Loop
   Begin
   l_event_id := l_c_booking_id.event_id ;
   l_lo_completed := 'N' ;
   l_learning_object_id := NULL ;
   l_lesson_status := NULL ;
   l_business_group_id := l_c_booking_id.business_group_id;
   l_user_id := l_c_booking_id.delegate_person_id;

   -- Check whether the content is imported from iLearning
   If l_c_booking_id.content_player_status in ('P','C') then
   	l_lo_completed := 'Y' ;
   Else
      -- If not a imported course, check whether its a online/async class
      Open c_learning_object_id;
      Fetch c_learning_object_id into l_learning_object_id;
      Close c_learning_object_id;

      If l_learning_object_id is not null then
        -- pass party id for external learner
            If l_c_booking_id.delegate_person_id is null then
	           l_user_id :=  ota_utility.get_ext_lrnr_party_id(l_c_booking_id.delegate_contact_id);
	    End if;

        -- Check LO attached the offering has record in performance with 'C' or 'P' status.
        Open c_less_status(l_user_id,l_learning_object_id) ;
      	Fetch c_less_status into l_lesson_status ;
      	Close c_less_status ;
      	If l_lesson_status  is not null then
      		l_lo_completed := 'Y' ;
      	End If;
      End If;
   End if ;

   If l_lo_completed = 'Y' then
	 -- Fetch booking_status_type_id for current record BG of type 'Attended'
	 Open C_booking_status_type_id ;
         Fetch C_booking_status_type_id into l_booking_status_type_id;
         Close C_booking_status_type_id ;

	  ota_tdb_api_upd2.Update_Enrollment
  	(
	  p_booking_id => l_c_booking_id.booking_id,
	  p_delegate_person_id  => l_c_booking_id.delegate_person_id,
	  p_contact_id          => l_c_booking_id.contact_id,
	  p_customer_id         => l_c_booking_id.customer_id,
          p_booking_status_type_id => l_booking_status_type_id,
  	  p_business_group_id      => l_c_booking_id.business_group_id,
	  p_event_id               => l_event_id,
  	  p_object_version_number  => l_c_booking_id.object_version_number,
	  p_date_status_changed    => sysdate,
  	  p_successful_attendance_flag   => 'Y',
	  p_tfl_object_version_number    => l_tfl_ovn,
  	  p_finance_line_id              => l_fin_line,
	  p_source_cancel                => NULL,
	  p_override_learner_access => 'Y',
          p_organization_id          => l_c_booking_id.organization_id ,
  	  p_sponsor_person_id        => l_c_booking_id.sponsor_person_id,
	  p_sponsor_assignment_id    => l_c_booking_id.sponsor_assignment_id
	  ) ;

    add_log_entry( p_table_name=>'OTA_DELEGATE_BOOKINGS'
                  ,p_source_primary_key => l_c_booking_id.booking_id
                  ,p_object_value => l_c_booking_id.booking_status_type_id
                  ,p_message_text   => 'Enrollment status updated successfully from '|| l_c_booking_id.booking_status_type_id || '  to  ' || l_booking_status_type_id
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_I
                  ,p_upgrade_name       => UPGRADE_NAME );



   End if;

  Exception
   when others then
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When Updating enrollment status to Attended');

    add_log_entry( p_table_name=>'OTA_DELEGATE_BOOKINGS'
                  ,p_source_primary_key => l_c_booking_id.booking_id
                  ,p_object_value => 'Error When Updating enrollment status to Attended for ID  : ' || l_c_booking_id.booking_id
                  ,p_message_text   => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );

   End ;

  End Loop ;

Exception
 when others then
  l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When Updating Successful attendance and history flag for enrollments');

    add_log_entry( p_table_name=>'OTA_DELEGATE_BOOKINGS'
                  ,p_source_primary_key => 1
                  ,p_object_value => 'Error When Updating Successful attendance and history flag for class enrollments for ID range : ' || p_start_rowid || ' - ' || p_end_rowid
                  ,p_message_text   => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );

end upg_tdb_history_att_flags;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< upgrade_lp_history_flag >--------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will update ota_lp_enrollments table record is_history_flag to 'Y'
-- where learning path enrollment status is 'Completed'

PROCEDURE upgrade_lp_history_flag(
   p_process_control IN		varchar2,
   p_start_rowid     IN         rowid,
   p_end_rowid       IN         rowid,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) is

  l_rows_processed number := 0;

  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);
  l_upgrade_id ota_upgrade_log.upgrade_id%Type;
  l_process_date ota_upgrade_log.process_date%Type;

begin

UPDATE /*+ ROWID (LPE) */  OTA_LP_ENROLLMENTS LPE
SET    IS_HISTORY_FLAG = 'Y'
WHERE  ROWID between p_start_rowid and p_end_rowid
AND    PATH_STATUS_CODE = 'COMPLETED'
AND    COMPLETION_DATE IS NOT NULL
AND    IS_HISTORY_FLAG IS NULL ;

p_rows_processed := SQL%ROWCOUNT;

Exception
 when others then
  l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When Updating history flag for LP enrollments');

    add_log_entry( p_table_name=>'OTA_LP_ENROLLMENTS'
                  ,p_source_primary_key => 1
                  ,p_object_value => 'Error When Updating history flag for LP enrollments for ID range : ' || p_start_rowid || ' - ' || p_end_rowid
                  ,p_message_text   => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       =>  get_process_date(p_update_id,UPGRADE_NAME)
                  ,p_log_type           => LOG_TYPE_E
                  ,p_upgrade_name       => UPGRADE_NAME );

end upgrade_lp_history_flag;

end ota_classic_upgrade;


/
