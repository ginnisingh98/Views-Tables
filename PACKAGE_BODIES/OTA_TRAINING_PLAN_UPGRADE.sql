--------------------------------------------------------
--  DDL for Package Body OTA_TRAINING_PLAN_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRAINING_PLAN_UPGRADE" AS
/* $Header: ottplpupg.pkb 120.1 2007/12/26 16:57:40 pekasi noship $ */

 -- LP_MAP_UPGRADE_ID     constant number(2) := -2;
  OTA_MIG_FAIL_ID       constant number(2) := -1;
  LP_MAP_TABLE_NAME_E   constant varchar2(30) := 'OTA_LP_ENROLLMENTS';
  LP_MAP_TABLE_NAME_M   constant varchar2(30) := 'OTA_LEARNING_PATH_MEMBERS';
  LP_MAP_TABLE_NAME_M_E constant varchar2(30) := 'OTA_LP_MEMBER_ENROLLMENTS';
  LP_UPGRADE_NAME       constant varchar2(30) := 'OTLPUPG';
  LP_LOG_TYPE_I         constant varchar2(30) := 'I'; -- log type is Infornation
  LP_LOG_TYPE_N         constant varchar2(30) := 'N';  -- log type is Internal
  LP_LOG_TYPE_E         constant varchar2(30) := 'E';-- log type is Error



Cursor csr_get_date_completed(p_activity_version_id IN NUMBER, p_person_id IN NUMBER
,p_contact_id in number) IS
SELECT min(date_status_changed)
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE evt.activity_version_id=p_activity_version_id
   AND evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND (tdb.delegate_person_id = p_person_id or tdb.delegate_person_id = p_contact_id)
   AND bst.type = 'A';


-- ----------------------------------------------------------------------------
-- |--------------------------< migrate_dff_contexts  >-----------------------|
-- ----------------------------------------------------------------------------

procedure migrate_dff_contexts (
p_source_table in varchar2, p_destination_table in varchar2,p_source_field
 in varchar2, p_destination_field in varchar2,p_update_id in number) is

 l_date date;
 l_segrec FND_DESCR_FLEX_COLUMN_USAGES%RowType ;
 l_err_code varchar2(72);
 l_err_msg  varchar2(2000);
 l_context_code FND_DESCR_FLEX_CONTEXTS.descriptive_flex_context_code%Type;
 l_segment_exists Varchar2(1) := 'N' ;
 l_context_exists Varchar2(1) := 'N' ;

 Cursor C1 (p_context_code in varchar2	,p_source_table in varchar2
		, p_destination_table in varchar2) IS
 Select fcu.*,fvs.flex_value_set_name
 From Fnd_Descr_Flex_Col_Usage_Vl fcu, fnd_flex_value_sets fvs
 Where fcu.Application_id = 810
 and  fcu.Descriptive_FlexField_Name = p_source_table
 and  fcu.Descriptive_Flex_Context_code = p_context_code
 and  fcu.flex_value_set_id = fvs.flex_value_set_id(+)
 and Not exists (SELECT 'Y'
 From Fnd_Descr_Flex_Col_Usage_Vl cat_fcu
 Where cat_fcu.Application_id = fcu.application_id
 and  cat_fcu.Descriptive_FlexField_Name = p_destination_table
 and  cat_fcu.Descriptive_Flex_Context_code = fcu.Descriptive_Flex_Context_code
 and  cat_fcu.end_user_column_name = fcu.end_user_column_name );

 Cursor Csr_DFF_contexts (p_source_table in varchar2)is
    Select *
    from FND_DESCR_FLEX_CONTEXTS_vl
    Where Application_id = 810
    and   Descriptive_FLexfield_Name = p_source_table
    and   Enabled_Flag = 'Y';

 Cursor Csr_Segment_exists(p_context_name in varchar2)  is
     SELECT 'Y'
     FROM fnd_descriptive_flexs
     WHERE application_id = 810
     AND descriptive_flexfield_name = p_context_name ;

Begin
 fnd_flex_dsc_api.set_session_mode('seed_data');
 --p_upgrade_id := g_update_id;
 Select Trunc(sysdate) into l_date from dual ;

 For dff_context in Csr_Dff_contexts(p_source_table)
 Loop
 begin
  l_context_exists := NULL ;
  Select Max('Y') into l_context_exists
  From FND_DESCR_FLEX_CONTEXTS_vl
  Where Descriptive_Flexfield_name = p_destination_table
  and   Descriptive_Flex_COntext_Code = dff_context.Descriptive_Flex_Context_code ;
  -- If there is a definition already existis and it is a Global context
  -- then NO context will be created but the strucre will be added to the existing one.

  If (NOT (dff_context.Global_Flag = 'Y' OR l_context_exists is NOT NULL)) then

  fnd_flex_dsc_api.create_context(
     appl_short_name => 'OTA' ,
     flexfield_name => p_destination_table,
     context_code => Dff_context.Descriptive_flex_context_code,
     context_name => Nvl(dff_context.DESCRiptive_FLEX_CONTEXT_NAME,'*-*'),
     description => dff_context.DESCRIPTION,
     enabled => dff_context.ENABLED_FLAG );

   End If;
   For I in C1 (Dff_context.Descriptive_flex_context_code,p_source_table
		, p_destination_table)
   Loop
     begin
     fnd_flex_dsc_api.create_segment(
      appl_short_name => 'OTA' ,
      flexfield_name => p_destination_table, --'Add''l Category Information',
      context_name => Nvl(dff_context.DESCRiptive_FLEX_CONTEXT_NAME,'*-*'),
      name => I.END_USER_COLUMN_NAME,
      column => Replace(I.APPLICATION_COLUMN_NAME,p_source_field,p_destination_field),
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
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'migrate_dff_contexts - segments');
    ota_classic_upgrade.add_log_entry( p_table_name         => 'MIGRATE_'||p_source_table
                  ,p_source_primary_key => substr(dff_context.application_id||'|'||
                                           dff_context.descriptive_flexfield_name||'|'||
                                           I.application_column_name,1,80)
                  ,p_object_value       => 'migrate_dff_contexts'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME  );
   End;


   End Loop;
  Exception
   when others then
    l_err_code := SQLCODE;
    l_err_msg  := nvl(substr(SQLERRM,1,2000),'migrate_dff_contexts');
    ota_classic_upgrade.add_log_entry( p_table_name         => 'MIGRATE_'||p_source_table
                  ,p_source_primary_key => substr( dff_context.application_id||
                                           dff_context.descriptive_flexfield_name,
                                           1,80)
                  ,p_object_value       => 'migrate_dff_contexts'
                  ,p_message_text       => l_err_msg
                  ,p_upgrade_id         => p_update_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME );
   End;
 End Loop;

End migrate_dff_contexts;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_lp_enr_map >-----------------------------|
-- ----------------------------------------------------------------------------
function get_status(p_status in varchar2) return
 varchar2 is
l_new_status varchar2(30);

begin
    if p_status = 'OTA_PLANNED' then
        l_new_status := 'PLANNED';
    elsif p_status = 'OTA_AWAITING_APPROVAL' then
        l_new_status := 'AWAITING_APPROVAL';
    elsif p_status = 'OTA_COMPLETED' then
        l_new_status := 'COMPLETED';
    else
        l_new_status := p_status;
    end if;

  return l_new_status;
end get_status;


-- ----------------------------------------------------------------------------
-- |---------------------------< get_lp_enr_map >-----------------------------|
-- ----------------------------------------------------------------------------
function get_lp_enr_map(p_training_plan_id in number
        ,p_source_id in number,p_source_function in varchar2
        ,p_assignment_id in number) return number
is
l_concat varchar2(255);
l_ret number(10);
cursor  csr_get_pk(p_concat varchar2) is
 select target_primary_key

    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_E
 --   and   upgrade_id =  LP_MAP_UPGRADE_ID
    and   source_primary_key = p_concat;

begin
  l_concat :=p_training_plan_id|| p_source_id||p_source_function|| p_assignment_id;
  open csr_get_pk(l_concat);
  fetch csr_get_pk into l_ret;
  if csr_get_pk%notfound then
    l_ret := OTA_MIG_FAIL_ID;
  end if;
 /*
  begin
    select nvl(target_primary_key,OTA_MIG_FAIL_ID)
    into l_ret
    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_E
 --   and   upgrade_id =  LP_MAP_UPGRADE_ID
    and   source_primary_key = l_concat;

  exception
    when no_data_found then
      l_ret := OTA_MIG_FAIL_ID;
  end;
  */

  return l_ret;
end get_lp_enr_map;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_lp_mem_map >-----------------------------|
-- ----------------------------------------------------------------------------
function get_lp_mem_map (p_training_plan_id in number,p_activity_version_id in number
                    ,p_completion_target_date date)
return number is
l_concat varchar2(80);
l_ret number;

cursor csr_get_pk(p_concat varchar2) is
    select target_primary_key
    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_M
--    and   upgrade_id =  LP_MAP_UPGRADE_ID
    and   source_primary_key = p_concat;

begin
  l_concat :=p_training_plan_id || p_activity_version_id || to_char(p_completion_target_date,'DDMMRRRR');

  open csr_get_pk(l_concat);
  fetch csr_get_pk into l_ret;
  if csr_get_pk%notfound then
    l_ret := OTA_MIG_FAIL_ID;
  end if;
 /*  begin
   select nvl(target_primary_key,OTA_MIG_FAIL_ID)
    into l_ret
    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_M
--    and   upgrade_id =  LP_MAP_UPGRADE_ID
    and   source_primary_key = l_concat;

  exception
    when no_data_found then
      l_ret := OTA_MIG_FAIL_ID;
  end;
  */

  return l_ret;

end get_lp_mem_map;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_lp_mem_enr_map >-----------------------------|
-- ----------------------------------------------------------------------------
function get_lp_mem_enr_map(p_training_plan_member_id in number) return number
is

l_ret number(10);
cursor csr_get_pk(p_training_plan_member_id varchar2)is
select target_primary_key
    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_M_E
    and   source_primary_key = p_training_plan_member_id;
begin
  open csr_get_pk(p_training_plan_member_id);
  fetch csr_get_pk into l_ret;
  if csr_get_pk%notfound then
    l_ret := OTA_MIG_FAIL_ID;
  end if;
  /*
  begin
    select nvl(target_primary_key,OTA_MIG_FAIL_ID)
    into l_ret
    from ota_upgrade_log
    where table_name =  LP_MAP_TABLE_NAME_M_E
--    and   upgrade_id =  LP_MAP_UPGRADE_ID
    and   source_primary_key = p_training_plan_member_id;

  exception
    when no_data_found then
      l_ret := OTA_MIG_FAIL_ID;
  end;*/

  return l_ret;
end get_lp_mem_enr_map;


-- ----------------------------------------------------------------------------
-- |---------------------------< set_lp_enr_map >-----------------------------|
-- ----------------------------------------------------------------------------

procedure set_lp_enr_map (p_upgrade_id in number
        ,p_training_plan_id in number
        ,p_new_lp_enr_id in number
        ,p_source_id in number
        ,p_source_function in varchar2
        ,p_assignment_id in number) is

  cursor c_exists (p_concat in varchar2) is
  select 1
  from ota_upgrade_log
  where table_name =  LP_MAP_TABLE_NAME_E
--  and   upgrade_id =  LP_MAP_UPGRADE_ID
  and   source_primary_key = p_concat;


  l_dummy number;
  l_concat varchar2(255);

  begin
    l_concat := p_training_plan_id||p_source_id || p_source_function || p_assignment_id;

    open c_exists(l_concat);
    fetch c_exists into l_dummy;

    if c_exists%found then
      update ota_upgrade_log
      set target_primary_key = p_new_lp_enr_id
      where  table_name =  LP_MAP_TABLE_NAME_E
--      and   upgrade_id =  LP_MAP_UPGRADE_ID
      and   source_primary_key = l_concat;
    else
      insert into ota_upgrade_log(upgrade_id,table_name,source_primary_key,target_primary_key
      ,log_type,upgrade_name)
         values (p_upgrade_id,LP_MAP_TABLE_NAME_E,l_concat,p_new_lp_enr_id
                  ,LP_LOG_TYPE_N,LP_UPGRADE_NAME);
    end if;
    close c_exists;
  end  set_lp_enr_map;

-- ----------------------------------------------------------------------------
-- |---------------------------< set_lp_mem_map >-----------------------------|
-- ----------------------------------------------------------------------------

procedure set_lp_mem_map (p_upgrade_id in number
        ,p_training_plan_id in number
        ,p_activity_versions_id number
        ,p_completion_target_date date
        ,p_new_lp_mem_id in number) is
  cursor c_exists (l_concat in varchar2) is
  select 1
  from ota_upgrade_log
  where table_name =  LP_MAP_TABLE_NAME_M
--  and   upgrade_id =  LP_MAP_UPGRADE_ID
  and   source_primary_key = l_concat;

  l_concat varchar2(80);
  l_dummy number;

  begin
    l_concat := p_training_plan_id || p_activity_versions_id ||to_char(p_completion_target_date,'DDMMRRRR') ;
    open c_exists(l_concat);
    fetch c_exists into l_dummy;

    if c_exists%found then
      update ota_upgrade_log
      set target_primary_key = p_new_lp_mem_id
      where  table_name =  LP_MAP_TABLE_NAME_M
--      and   upgrade_id =  LP_MAP_UPGRADE_ID
      and   source_primary_key = l_concat;
    else
      insert into ota_upgrade_log(upgrade_id,table_name,source_primary_key,target_primary_key
       ,log_type,upgrade_name)
      values (p_upgrade_id,LP_MAP_TABLE_NAME_M,l_concat,p_new_lp_mem_id,LP_LOG_TYPE_N,LP_UPGRADE_NAME);
    end if;
    close c_exists;
  end  set_lp_mem_map;

-- ----------------------------------------------------------------------------
-- |--------------------------< set_lp_mem_enr_map >--------------------------|
-- ----------------------------------------------------------------------------

procedure set_lp_mem_enr_map (p_upgrade_id in number,p_training_plan_member_id in number
        ,p_new_lp_mem_enr_id in number) is
  cursor c_exists (p_training_plan_member_id in varchar2) is
  select 1
  from ota_upgrade_log
  where table_name =  LP_MAP_TABLE_NAME_M_E
--  and   upgrade_id =  LP_MAP_UPGRADE_ID
  and   source_primary_key = p_training_plan_member_id;


  l_dummy number;

  begin
    open c_exists(p_training_plan_member_id);
    fetch c_exists into l_dummy;

    if c_exists%found then
      update ota_upgrade_log
      set target_primary_key = p_new_lp_mem_enr_id
      where  table_name =  LP_MAP_TABLE_NAME_M_E
    --  and   upgrade_id =  LP_MAP_UPGRADE_ID
      and   source_primary_key = p_training_plan_member_id;
    else
      insert into ota_upgrade_log(upgrade_id,table_name,source_primary_key,target_primary_key
       ,log_type,upgrade_name)
      values (p_upgrade_id,LP_MAP_TABLE_NAME_M_E,p_training_plan_member_id,p_new_lp_mem_enr_id
      ,LP_LOG_TYPE_N,LP_UPGRADE_NAME);
    end if;
    close c_exists;
  end  set_lp_mem_enr_map;


-- ----------------------------------------------------------------------------
-- |--------------------------< is_lp_enr_migrated >--------------------------|
-- ----------------------------------------------------------------------------
function is_lp_enr_migrated (p_training_plan_id in number
        ,p_source_id in number,p_source_function in varchar2
        ,p_assignment_id in number) return boolean is
l_ret boolean ;
l_new_id  number;
begin
  l_ret := false;
  l_new_id := get_lp_enr_map(p_training_plan_id, p_source_id, p_source_function
                ,p_assignment_id);
  if l_new_id <> OTA_MIG_FAIL_ID then
   l_ret := true;
  end if;
  return l_ret;
end is_lp_enr_migrated;
-- ----------------------------------------------------------------------------
-- |------------------------< is_lp_mem_migrated >----------------------------|
-- ----------------------------------------------------------------------------
function is_lp_mem_migrated (p_training_plan_id in number, p_activity_version_id number
, p_completion_target_date date)
return boolean is

l_ret boolean;
l_new_id number;
begin
  l_ret := false;
  l_new_id := get_lp_mem_map(p_training_plan_id,p_activity_version_id
            ,p_completion_target_date);
  if l_new_id <> OTA_MIG_FAIL_ID then
     l_ret := true;
  end if;
  return l_ret;
end is_lp_mem_migrated;
-- ----------------------------------------------------------------------------
-- |------------------------< is_lp_mem_enr_migrated >----------------------------|
-- ----------------------------------------------------------------------------
function is_lp_mem_enr_migrated (p_training_plan_member_id in number)
return boolean is

l_ret boolean;
l_new_id number;
begin
  l_ret := false;
  l_new_id := get_lp_mem_enr_map(p_training_plan_member_id);
  if l_new_id <> OTA_MIG_FAIL_ID then
     l_ret := true;
  end if;
  return l_ret;
end is_lp_mem_enr_migrated;
-- ----------------------------------------------------------------------------
-- |---------------------< populate_path_source_code >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE populate_path_source_code is

begin


UPDATE ota_learning_paths
SET path_source_code ='CATALOG'
,display_to_learner_flag = 'Y'
WHERE path_source_code IS null;

UPDATE ota_learning_paths lps
SET public_flag = (SELECT decode(count(tea.learning_path_id),0,'Y','N')
                FROM ota_event_associations tea
                WHERE  lps.learning_path_id = tea.learning_path_id)
WHERE lps.public_flag IS NULL
AND lps.path_source_code = 'CATALOG';

end populate_path_source_code;

-- ----------------------------------------------------------------------------
-- |-------------------------< create_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
Procedure create_learning_path
        (p_name                     in varchar
        ,p_business_group_id        in number
        ,p_start_date_active        in date
        ,p_end_date_active          in date
        ,p_description              in varchar
        ,p_path_source_code         in varchar
        ,p_person_id                in number
        ,p_contact_id               in number default null
        ,p_table_name               in varchar
        ,p_upgrade_id               in number
        ,p_learning_path_id         IN OUT NOCOPY Number
        ,p_object_version_number    IN OUT NOCOPY Number
        ,p_source_function_code     in varchar
        ,p_assignment_id            in number
        ,p_source_id                in number
        ,p_display_to_learner_flag  in varchar
        ,p_training_plan_id         in number
) is

l_learning_path_id number;
l_object_version_number number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);

cursor csr_get_dup_lps_rec(p_name in varchar2, p_business_group_id in number
, p_person_id in number, p_contact_id in number) IS
SELECT lps.learning_path_id
FROM ota_learning_paths lps, ota_learning_paths_tl lpst
where lps.learning_path_id = lpst.learning_path_id
and lpst.language = userenv('LANG')
and lpst.name = p_name
and lps.business_group_id = p_business_group_id
and (lps.person_id = p_person_id OR lps.contact_id = p_contact_id);

l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LEARNING_PATHS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

    open csr_get_dup_lps_rec(p_name,p_business_group_id, p_person_id, p_contact_id);
    fetch csr_get_dup_lps_rec into l_learning_path_id;
    if csr_get_dup_lps_rec%notfound then
      Begin
       ota_learning_path_api.create_learning_path(
        p_effective_date             => trunc(sysdate)
        ,p_path_name                 => p_name
        ,p_duration                  => null
        ,p_duration_units            => null
        ,p_business_group_id         => p_business_group_id
        ,p_start_date_active         => p_start_date_active
        ,p_end_date_active           => p_end_date_active
        ,p_description               => p_description
        ,p_path_source_code          => p_path_source_code
        ,p_person_id                 => p_person_id
        ,p_contact_id                => p_contact_id
        ,p_learning_path_id          => l_learning_path_id
        ,p_object_version_number     => l_object_version_number
        ,p_source_function_code      => p_source_function_code
        ,p_assignment_id             => p_assignment_id
        ,p_source_id                 => p_source_id
        ,p_display_to_learner_flag   => p_display_to_learner_flag
	,p_public_flag		     => 'N'
        );


      Exception
      when others then
       l_err_code := SQLCODE;
       l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path for Training Plan ');

           ota_classic_upgrade.add_log_entry( p_table_name=>p_table_name
                         ,p_source_primary_key  => p_training_plan_id || p_business_group_id
                         ,p_business_group_id   => p_business_group_id
                         ,p_object_value        => p_name
                         ,p_message_text        => l_err_msg
                         ,p_upgrade_id          => p_upgrade_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPGRADE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                         ,p_log_type            => LP_LOG_TYPE_E
                         ,p_upgrade_name        => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());
      end;
     end if;
     close csr_get_dup_lps_rec;
     p_learning_path_id         := l_learning_path_id;
     p_object_version_number    := l_object_version_number;
     hr_dflex_utility.remove_ignore_df_validation;
End create_learning_path;

-- ----------------------------------------------------------------------------
-- |---------------------------< create_lp_sections >----------------------|
-- ----------------------------------------------------------------------------
Procedure create_lp_sections
        (p_section_name             in varchar
        ,p_description              in varchar default null
        ,p_section_sequence         in number
        ,p_completion_type_code     in varchar
        ,p_business_group_id        in varchar
        ,p_table_name               in varchar
        ,p_upgrade_id               in number
        ,p_learning_path_id         in number
        ,p_learning_path_section_id IN OUT NOCOPY Number
        ,p_object_version_number    IN OUT NOCOPY Number


) is

l_learning_path_section_id number;
l_object_version_number number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_number  number;

cursor csr_get_dup_lpc_rec(p_learning_path_id in number,p_section_name in varchar) is
select lpc.learning_path_section_id
from ota_lp_sections_tl lpct,ota_lp_sections lpc
where lpc.learning_path_section_id = lpct.learning_path_section_id
and lpct.language=userenv('LANG')
and lpc.learning_path_id  = p_learning_path_id
and lpct.name        = p_section_name ;

l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LP_SECTIONS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

    open csr_get_dup_lpc_rec(p_learning_path_id, p_section_name);
    fetch csr_get_dup_lpc_rec into l_learning_path_section_id;
    if csr_get_dup_lpc_rec%notfound then
        begin
               ota_lp_section_api.create_lp_section(
                p_effective_date              => trunc(sysdate)
                ,p_learning_path_section_id   => l_learning_path_section_id
                ,p_learning_path_id           => p_learning_path_id
                ,p_section_name               => p_section_name  --ota_lp_sections_tl
                ,p_description                => p_description  -- ota_lp_sections_tl
                ,p_section_sequence           => p_section_sequence
                ,p_completion_type_code       => p_completion_type_code
                ,p_business_group_id          => p_business_group_id
                ,p_object_version_number      => l_object_version_number
                );
             Exception
             when others then
               l_err_code := SQLCODE;
               l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path Sections ');

               ota_classic_upgrade.add_log_entry( p_table_name=>p_table_name
                  ,p_source_primary_key  => p_business_group_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_object_value        => p_section_name
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id          => p_upgrade_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPGRADE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());

             End;
        end if;
        close csr_get_dup_lpc_rec;
        p_learning_path_section_id := l_learning_path_section_id;
        hr_dflex_utility.remove_ignore_df_validation;
End create_lp_sections;

-- ----------------------------------------------------------------------------
-- |---------------------< create_learning_path_members >---------------------|
-- ----------------------------------------------------------------------------

Procedure create_learning_path_members(
                    p_business_group_id         IN number
                    ,p_learning_path_id         in number
                    ,p_activity_version_id      in number
                    ,p_course_sequence          in number
                    ,p_completion_target_date   in date
                    ,p_learning_path_section_id in number
                    ,p_table_name               in varchar
                    ,p_upgrade_id                in number
                    ,p_learning_path_member_id  IN OUT NOCOPY Number
                    ,p_object_version_number    IN OUT NOCOPY Number
                    ,p_training_plan_member_id  in number
                    ,p_training_plan_id         in number
                    ) is


l_learning_path_member_id number;
l_object_version_number number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_number  number;


l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LEARNING_PATH_MEMBERS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);



        if not is_lp_mem_migrated(p_learning_path_id, p_activity_version_id
                        ,p_completion_target_date) then
          begin
                 -- p_course_sequence := p_course_sequence + 1;
                  ota_lp_member_api.create_learning_path_member(
                    p_effective_date              => trunc(sysdate)
                    ,p_business_group_id          => p_business_group_id
                    ,p_learning_path_id           => p_learning_path_id
                    ,p_activity_version_id        => p_activity_version_id
                    ,p_course_sequence            => p_course_sequence
                    ,p_learning_path_section_id   => p_learning_path_section_id
                    ,p_learning_path_member_id    => l_learning_path_member_id
                    ,p_object_version_number      => l_object_version_number
                    );
          set_lp_mem_map(p_upgrade_id,p_learning_path_id,p_activity_version_id
                ,p_completion_target_date,l_learning_path_member_id);
          Exception
          when others then
                l_err_code := SQLCODE;
                l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path Member for Training Plan Member');
                --p_course_sequence := p_course_sequence-1;
                ota_classic_upgrade.add_log_entry( p_table_name=>p_table_name
                  ,p_source_primary_key  => p_training_plan_member_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_object_value        => p_activity_version_id
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id          => p_upgrade_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPGRADE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());

        End;
    else
      l_learning_path_member_id := get_lp_mem_map(p_learning_path_id
                    , p_activity_version_id,p_completion_target_date);
    end if;

    p_learning_path_member_id    := l_learning_path_member_id;
    p_object_version_number      := l_object_version_number;

    hr_dflex_utility.remove_ignore_df_validation;
END create_learning_path_members;

-- ----------------------------------------------------------------------------
-- |---------------------< create_lp_member_enrollment >---------------------|
-- ----------------------------------------------------------------------------

Procedure create_lp_member_enrollment(
                        p_lp_member_enrollment_id  IN OUT NOCOPY Number
                        ,p_lp_enrollment_id        in number
                        ,p_learning_path_section_id in number
                        ,p_learning_path_member_id in number
                        ,p_member_status_code      in varchar
                        ,p_completion_target_date  in date
                        ,p_creator_person_id        in number  --bug 3984648
                      --  ,p_completion_date         in date
                        ,p_business_group_id       in number
                   --     ,p_person_id               in number
                        ,p_activity_version_id     in number
                  --      ,p_contact_id              in number
                        ,p_table_name              in varchar
                        ,p_upgrade_id               in number
                        ,p_object_version_number   IN OUT NOCOPY Number
                        ,p_training_plan_member_id in number
                        ,p_attribute_category       IN VARCHAR2
                        ,p_attribute1               IN VARCHAR2
                        ,p_attribute2               IN VARCHAR2
                        ,p_attribute3               IN VARCHAR2
                        ,p_attribute4               IN VARCHAR2
                        ,p_attribute5               IN VARCHAR2
                        ,p_attribute6               IN VARCHAR2
                        ,p_attribute7               IN VARCHAR2
                        ,p_attribute8               IN VARCHAR2
                        ,p_attribute9               IN VARCHAR2
                        ,p_attribute10               IN VARCHAR2
                        ,p_attribute11              IN VARCHAR2
                        ,p_attribute12               IN VARCHAR2
                        ,p_attribute13               IN VARCHAR2
                        ,p_attribute14               IN VARCHAR2
                        ,p_attribute15               IN VARCHAR2
                        ,p_attribute16               IN VARCHAR2
                        ,p_attribute17               IN VARCHAR2
                        ,p_attribute18               IN VARCHAR2
                        ,p_attribute19               IN VARCHAR2
                        ,p_attribute20               IN VARCHAR2
                        ,p_attribute21               IN VARCHAR2
                        ,p_attribute22               IN VARCHAR2
                        ,p_attribute23               IN VARCHAR2
                        ,p_attribute24               IN VARCHAR2
                        ,p_attribute25               IN VARCHAR2
                        ,p_attribute26               IN VARCHAR2
                        ,p_attribute27               IN VARCHAR2
                        ,p_attribute28               IN VARCHAR2
                        ,p_attribute29               IN VARCHAR2
                        ,p_attribute30               IN VARCHAR2
                        ) is

 l_date_status_changed date;
l_lp_member_enrollment_id number;
l_object_version_number number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_number  number;

l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LP_MEMBER_ENROLLMENTS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);


    if not  is_lp_mem_enr_migrated(p_training_plan_member_id) then
        l_date_status_changed := null;


              begin
                    ota_lp_member_enrollment_api.create_lp_member_enrollment(
                        p_effective_date            => trunc(sysdate)
                        ,p_lp_member_enrollment_id  => l_lp_member_enrollment_id
                        ,p_lp_enrollment_id         => p_lp_enrollment_id
                        ,p_learning_path_section_id => p_learning_path_section_id
                        ,p_learning_path_member_id  => p_learning_path_member_id
                        ,p_member_status_code       => get_status(p_member_status_code)
                        ,p_completion_target_date   => p_completion_target_date
             --           ,p_completion_date          => l_date_status_changed
                        ,p_business_group_id        => p_business_group_id
                        ,p_object_version_number    => p_object_version_number
                        ,p_creator_person_id        => p_creator_person_id  -- bug no 3984648
		        ,p_attribute_category         => p_attribute_category
			,p_attribute1                => p_attribute1
			,p_attribute2                => p_attribute2
			,p_attribute3                => p_attribute3
			,p_attribute4                => p_attribute4
			,p_attribute5                => p_attribute5
			,p_attribute6                => p_attribute6
			,p_attribute7                => p_attribute7
			,p_attribute8                => p_attribute8
			,p_attribute9                => p_attribute9
			,p_attribute10               => p_attribute10
			,p_attribute11               => p_attribute11
			,p_attribute12                => p_attribute12
			,p_attribute13                => p_attribute13
			,p_attribute14                => p_attribute14
		        ,p_attribute15                => p_attribute15
		        ,p_attribute16                => p_attribute16
		        ,p_attribute17                => p_attribute17
		        ,p_attribute18                => p_attribute18
		        ,p_attribute19                => p_attribute19
		        ,p_attribute20                => p_attribute20
		        ,p_attribute21                => p_attribute21
		        ,p_attribute22                => p_attribute22
		        ,p_attribute23                => p_attribute23
		        ,p_attribute24                => p_attribute24
		        ,p_attribute25                => p_attribute25
		        ,p_attribute26                => p_attribute26
		        ,p_attribute27                => p_attribute27
		        ,p_attribute28                => p_attribute28
		        ,p_attribute29                => p_attribute29
		        ,p_attribute30                => p_attribute30
			);

                    set_lp_mem_enr_map(p_upgrade_id
                                ,p_training_plan_member_id,l_lp_member_enrollment_id);




                Exception
                when others then
                    l_err_code := SQLCODE;
                    l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path Member Enrollment for Training Plan Member');

                    ota_classic_upgrade.add_log_entry( p_table_name=>p_table_name
                         ,p_source_primary_key  => p_training_plan_member_id
               		 ,p_business_group_id   => p_business_group_id
	                 ,p_object_value        => p_learning_path_member_id
        	         ,p_message_text        => l_err_msg
                	 ,p_upgrade_id          => p_upgrade_id
	                 ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPGRADE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
        	         ,p_log_type           => LP_LOG_TYPE_E
                	 ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());

                         l_lp_member_enrollment_id := -1;

                End;
      else
      l_lp_member_enrollment_id := get_lp_mem_enr_map(p_training_plan_member_id);
     end if;
     --close csr_get_dup_lpme_rec;
     p_lp_member_enrollment_id  := l_lp_member_enrollment_id;
     hr_dflex_utility.remove_ignore_df_validation;
end create_lp_member_enrollment;


-- ----------------------------------------------------------------------------
-- |-------------------------< create_lp_enrollment >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_lp_enrollment(p_name   in varchar2
            ,p_learning_path_id         in number
            ,p_Completion_target_date   in date
            ,p_Person_id                in number
            ,p_Contact_id               in number default null
            ,p_path_status_code         in varchar2
            ,p_creator_person_id        in number
            ,p_business_group_id        in number
            ,p_enrollment_source_code   in varchar2
            ,p_lp_enrollment_id         IN OUT NOCOPY Number
            ,p_object_version_number    IN OUT NOCOPY Number
            ,p_table_name               in varchar
            ,p_upgrade_id               in number
            ,p_training_plan_id         IN number
            ,p_source_id                IN number DEFAULT NULL
            ,p_source_function          IN varchar2 DEFAULT NULL
            ,p_assignment_id            IN number DEFAULT NULL
            ,p_attribute_category       IN VARCHAR2
            ,p_attribute1               IN VARCHAR2
            ,p_attribute2               IN VARCHAR2
            ,p_attribute3               IN VARCHAR2
            ,p_attribute4               IN VARCHAR2
            ,p_attribute5               IN VARCHAR2
            ,p_attribute6               IN VARCHAR2
            ,p_attribute7               IN VARCHAR2
            ,p_attribute8               IN VARCHAR2
            ,p_attribute9               IN VARCHAR2
            ,p_attribute10              IN VARCHAR2
            ,p_attribute11              IN VARCHAR2
            ,p_attribute12              IN VARCHAR2
            ,p_attribute13              IN VARCHAR2
            ,p_attribute14              IN VARCHAR2
            ,p_attribute15              IN VARCHAR2
            ,p_attribute16              IN VARCHAR2
            ,p_attribute17              IN VARCHAR2
            ,p_attribute18              IN VARCHAR2
            ,p_attribute19              IN VARCHAR2
            ,p_attribute20              IN VARCHAR2
            ,p_attribute21              IN VARCHAR2
            ,p_attribute22              IN VARCHAR2
            ,p_attribute23              IN VARCHAR2
            ,p_attribute24              IN VARCHAR2
            ,p_attribute25              IN VARCHAR2
            ,p_attribute26              IN VARCHAR2
            ,p_attribute27              IN VARCHAR2
            ,p_attribute28              IN VARCHAR2
            ,p_attribute29              IN VARCHAR2
            ,p_attribute30              IN VARCHAR2
) is

l_lp_enrollment_id number;
l_object_version_number number;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_number  number;

--
l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LP_ENROLLMENTS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);


        if  not is_lp_enr_migrated(p_training_plan_id
                ,p_source_id, p_source_function, p_assignment_id) then
          begin
     --     ota_lp_enrollment_api.create_lp_enrollment(
            ota_lpe_ins.ins(
            p_effective_date              => trunc(sysdate)
            ,p_learning_path_id           => p_learning_path_id
            ,p_Completion_target_date     => p_Completion_target_date
            ,p_Person_id                  => p_Person_id
            ,p_Contact_id                 => p_Contact_id
            ,p_path_status_code           => get_status(p_path_status_code)
            ,p_Creator_person_id          => p_creator_person_id
            ,p_business_group_id          => p_business_group_id
            ,p_Enrollment_source_code     => p_Enrollment_source_code
            ,p_lp_enrollment_id           => l_lp_enrollment_id
            ,p_object_version_number      => l_object_version_number
            ,p_attribute_category         => p_attribute_category
            ,p_attribute1                => p_attribute1
            ,p_attribute2                => p_attribute2
            ,p_attribute3                => p_attribute3
            ,p_attribute4                => p_attribute4
            ,p_attribute5                => p_attribute5
            ,p_attribute6                => p_attribute6
            ,p_attribute7                => p_attribute7
            ,p_attribute8                => p_attribute8
            ,p_attribute9                => p_attribute9
            ,p_attribute10               => p_attribute10
            ,p_attribute11               => p_attribute11
            ,p_attribute12                => p_attribute12
            ,p_attribute13                => p_attribute13
            ,p_attribute14                => p_attribute14
            ,p_attribute15                => p_attribute15
            ,p_attribute16                => p_attribute16
            ,p_attribute17                => p_attribute17
            ,p_attribute18                => p_attribute18
            ,p_attribute19                => p_attribute19
            ,p_attribute20                => p_attribute20
            ,p_attribute21                => p_attribute21
            ,p_attribute22                => p_attribute22
            ,p_attribute23                => p_attribute23
            ,p_attribute24                => p_attribute24
            ,p_attribute25                => p_attribute25
            ,p_attribute26                => p_attribute26
            ,p_attribute27                => p_attribute27
            ,p_attribute28                => p_attribute28
            ,p_attribute29                => p_attribute29
            ,p_attribute30                => p_attribute30

            );

          set_lp_enr_map(p_upgrade_id,p_training_plan_id,l_lp_enrollment_id, p_source_id, p_source_function
                ,p_assignment_id);
          Exception
          when others then
           l_err_code := SQLCODE;
           l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path Enrollments for Training Plan ');

           ota_classic_upgrade.add_log_entry( p_table_name=>p_table_name
                  ,p_source_primary_key  => p_training_plan_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_object_value        => p_name
                  ,p_message_text        => l_err_msg
                  ,p_upgrade_id          => p_upgrade_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPGRADE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());

           End;

     else
      l_lp_enrollment_id := get_lp_enr_map(p_training_plan_id,p_source_id, p_source_function
                ,p_assignment_id);
     end if;
    -- close csr_get_dup_lpe_rec;
     p_lp_enrollment_id := l_lp_enrollment_id;
     hr_dflex_utility.remove_ignore_df_validation;
end create_lp_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< upg_cat_lp_to_section >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upg_cat_lp_to_section (
   p_process_control    IN		varchar2,
   p_start_pkid         IN            number,
   p_end_pkid           IN            number,
   p_rows_processed     OUT    nocopy number,
   p_update_id          IN  number default 1    --CONC_UPGRADE_ID
   ) IS
/*
	Upgrade existing catalog learning paths to have sections
*/
l_learning_path_id	        number;
l_object_version_number     number;
l_learning_path_section_id  number;
l_number                    number;
l_err_code                  varchar2(72);
l_err_msg                   varchar2(2000);
l_rows_processed            number;
l_upgrade_id                number;


CURSOR csr_get_lp IS
 SELECT lps.learning_path_id, lpst.name , lps.business_group_id
 FROM ota_learning_paths lps, ota_learning_paths_tl lpst
 WHERE lpst.learning_path_id = lps.learning_path_id
 AND lpst.language = USERENV('LANG')
 AND lps.path_source_code = 'CATALOG'
 AND lps.learning_path_id between p_start_pkid and p_end_pkid;



cursor csr_get_dup_lpc_rec(p_learning_path_id in number,p_section_name in varchar) is
select lpc.learning_path_section_id
from ota_lp_sections_tl lpct,ota_lp_sections lpc
where lpc.learning_path_section_id = lpct.learning_path_section_id
and lpct.language=userenv('LANG')
and lpc.learning_path_id  = p_learning_path_id
and lpct.name        = p_section_name ;

l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();



BEGIN


 --	Update path_source_code_code_code to CATALOG and display_to_learner_flag to 'Y'
 -- for existing data in ota_learning_paths
l_upgrade_id := null;

    select max(upgrade_id) INTO l_upgrade_id
    from   ota_upgrade_log
    where upgrade_name = LP_UPGRADE_NAME;

    if l_upgrade_id is null then
        ota_classic_upgrade.add_log_entry( p_table_name=> 'DUMMY'
                         ,p_source_primary_key  =>  1
                         ,p_business_group_id   => null
                         ,p_object_value        => null
                         ,p_message_text        => 'Starting LP Upgrade'
                         ,p_upgrade_id          => 1
                         ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                         ,p_log_type           => LP_LOG_TYPE_N
                         ,p_upgrade_name         => LP_UPGRADE_NAME );

        commit;
    end if;
 FOR lp_rec IN csr_get_lp  LOOP
    l_learning_path_id := lp_rec.learning_path_id;
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'OTA_LP_SECTIONS';
    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

    open csr_get_dup_lpc_rec(l_learning_path_id, lp_rec.name);
    fetch csr_get_dup_lpc_rec into l_learning_path_section_id;
    if csr_get_dup_lpc_rec%notfound then

    --Create a New Learning Path Section
	l_learning_path_section_id := null;
     begin
        ota_lpc_ins.ins(
        p_effective_date            => trunc(sysdate)
        ,p_section_sequence         => 1
        ,p_completion_type_code     => 'M'
        ,p_business_group_id        => lp_rec.business_group_id
        ,p_learning_path_id         => l_learning_path_id
        ,p_learning_path_section_id => l_learning_path_section_id
        ,p_object_version_number    => l_object_version_number);


        Insert into ota_lp_sections_tl
      	(learning_path_section_id,
     		Language,
     		name,
     		Description,
     		Source_Lang,
     		Created_By,
     		Creation_Date,
     		Last_Updated_By,
     		Last_Update_Date,
	     	Last_Update_Login )
          Select l_learning_path_section_id,
            M.language,
  	        M.name,
	        M.description,
    	    M.source_lang,
	        M.Created_By,
	        M.Creation_date,
    	    M.Last_Updated_By,
	        M.Last_Update_Date,
	        M.Last_Update_Login
    	  From Ota_learning_paths_tl M
	      Where M.learning_path_id = l_learning_path_id;

     Exception
          when others then
               l_err_code := SQLCODE;
               l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When creating Learning Path Sections for Training Plan ');

               ota_classic_upgrade.add_log_entry( p_table_name=> 'CREATE_LPC_FOR_TPS_FOR_CAT'
                         ,p_source_primary_key  => lp_rec.business_group_id
                         ,p_business_group_id   => lp_rec.business_group_id
                         ,p_object_value        => lp_rec.name
                         ,p_message_text        => l_err_msg
                         ,p_upgrade_id          => p_update_id
                  ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                  ,p_log_type           => LP_LOG_TYPE_E
                  ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());

      End;
    end if;
    close csr_get_dup_lpc_rec;
    hr_dflex_utility.remove_ignore_df_validation;




     if l_learning_path_section_id is not null then
           UPDATE ota_learning_path_members
           SET learning_path_section_id = l_learning_path_section_id  --//Section_id returned from create call
           where learning_path_id = l_learning_path_id;
     end if;



 END LOOP;


 Select nvl(count(1),0)
   into l_rows_processed
   from ota_learning_paths
   where learning_path_id between p_start_pkid and p_end_pkid;

  p_rows_processed := l_rows_processed;
END upg_cat_lp_to_section;

-- ----------------------------------------------------------------------------
-- |--------------------< upg_tp_for_lrnr_and_mgr_to_lp >---------------------|
-- ----------------------------------------------------------------------------
procedure upg_tp_for_lrnr_and_mgr_to_lp (p_process_control 	IN varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
  p_update_id in number default 1
    ) is

l_training_plan_id          number;
l_object_version_number     number;
l_learning_path_id          number;
l_lp_enrollment_id          number;
l_learning_path_section_id  number;
l_learning_path_member_id   number;
l_lp_member_enrollment_id   number;
l_total_comp                number;
l_completed_comp            number;
l_seq                       number;
l_Completion_date           date;
l_number                    number;
l_err_code                  varchar2(72);
l_err_msg                   varchar2(2000);
l_rows_processed            number;
l_end_date                  date;

l_member_status_code ota_lp_member_enrollments.member_status_code%type;
l_old_status 	     ota_lp_member_enrollments.member_status_code%type;
l_max_date_status_changed ota_delegate_bookings.date_status_changed%type;
l_date_status_changed ota_delegate_bookings.date_status_changed%type;
--
CURSOR csr_get_tp IS
 SELECT tps.training_plan_id, tps.business_group_id,
     tps.name, tps.description,
     tps.START_DATE, tps.end_date,
     tps.plan_source, tps.plan_status_type_id
   -- Source_Function_Code,
     , tps.person_id, tps.contact_id
     ,tps.ATTRIBUTE_CATEGORY,tps.ATTRIBUTE1
    ,tps.ATTRIBUTE2 ,tps.ATTRIBUTE3
    ,tps.ATTRIBUTE4 ,tps.ATTRIBUTE5
    ,tps.ATTRIBUTE6 ,tps.ATTRIBUTE7
    ,tps.ATTRIBUTE8 ,tps.ATTRIBUTE9
    ,tps.ATTRIBUTE10 ,tps.ATTRIBUTE11
    ,tps.ATTRIBUTE12 ,tps.ATTRIBUTE13
    ,tps.ATTRIBUTE14 ,tps.ATTRIBUTE15
    ,tps.ATTRIBUTE16 ,tps.ATTRIBUTE17
    ,tps.ATTRIBUTE18 ,tps.ATTRIBUTE19
    ,tps.ATTRIBUTE20 ,tps.ATTRIBUTE21
    ,tps.ATTRIBUTE22 ,tps.ATTRIBUTE23
    ,tps.ATTRIBUTE24 ,tps.ATTRIBUTE25
    ,tps.ATTRIBUTE26 ,tps.ATTRIBUTE27
    ,tps.ATTRIBUTE28 ,tps.ATTRIBUTE29
    ,tps.ATTRIBUTE30 ,tps.creator_person_id
 FROM ota_training_plans tps
 WHERE tps.plan_source NOT IN ('TALENT_MGMT','CATALOG')
 AND (tps.PERSON_ID is not NULL OR contact_id is not null)
 AND tps.learning_path_id is null
 AND tps.training_plan_id between p_start_pkid AND p_end_pkid;
--
CURSOR csr_get_tpm(p_training_plan_id NUMBER) IS
SELECT tpm.training_plan_member_id, tpm.business_group_id
        ,tpm.activity_version_id
        ,tpm.member_status_type_id, tpm.target_completion_date
        ,tpm.ATTRIBUTE_CATEGORY ,tpm.ATTRIBUTE1
        ,tpm.ATTRIBUTE2 ,tpm.ATTRIBUTE3
        ,tpm.ATTRIBUTE4 ,tpm.ATTRIBUTE5
        ,tpm.ATTRIBUTE6 ,tpm.ATTRIBUTE7
        ,tpm.ATTRIBUTE8 ,tpm.ATTRIBUTE9
        ,tpm.ATTRIBUTE10 ,tpm.ATTRIBUTE11
        ,tpm.ATTRIBUTE12 ,tpm.ATTRIBUTE13
        ,tpm.ATTRIBUTE14 ,tpm.ATTRIBUTE15
        ,tpm.ATTRIBUTE16 ,tpm.ATTRIBUTE17
        ,tpm.ATTRIBUTE18 ,tpm.ATTRIBUTE19
        ,tpm.ATTRIBUTE20 ,tpm.ATTRIBUTE21
        ,tpm.ATTRIBUTE22 ,tpm.ATTRIBUTE23
        ,tpm.ATTRIBUTE24 ,tpm.ATTRIBUTE25
        ,tpm.ATTRIBUTE26 ,tpm.ATTRIBUTE27
        ,tpm.ATTRIBUTE28 ,tpm.ATTRIBUTE29
        ,tpm.ATTRIBUTE30
FROM ota_training_plan_members tpm
WHERE tpm.training_plan_id = p_training_plan_id;
--

BEGIN

  FOR tp_rec IN csr_get_tp  LOOP

    l_learning_path_id          := null;
    l_lp_enrollment_id          := null;
    l_learning_path_section_id  := null;

    if to_char(tp_rec.end_date,'dd/mm/rrrr') = '31/12/4712' then
        l_end_date := null;
    else
        l_end_date := tp_rec.end_date;
    end if;
    --  Create learning paths from training plans
    create_learning_path(p_name  => tp_rec.name
        ,p_business_group_id     => tp_rec.business_group_id
        ,p_start_date_active     => tp_rec.start_date
        ,p_end_date_active       => l_end_date
        ,p_description           => tp_rec.description
        ,p_path_source_code      => tp_rec.PLAN_SOURCE

        ,p_person_id             => tp_rec.person_id
        ,p_contact_id            => tp_rec.contact_id
        ,p_table_name            => 'CREATE_LPS_FOR_TPS_LRNR_AND_MGR'
        ,p_upgrade_id             => p_update_id
        ,p_learning_path_id      => l_learning_path_id
        ,p_object_version_number => l_object_version_number
        ,p_source_function_code  => null
        ,p_assignment_id         => null
        ,p_source_id             => null
        ,p_display_to_learner_flag => 'Y'
        ,p_training_plan_id      => tp_rec.training_plan_id);

--Create a learning path section
    if l_learning_path_id is not null then
        create_lp_sections(
        p_section_name          =>   tp_rec.name
        ,p_description          =>   tp_rec.description
        ,p_section_sequence     =>   1
        ,p_completion_type_code =>   'M'
        ,p_business_group_id    =>   tp_rec.business_group_id
        ,p_table_name           =>   'CREATE_LPC_FOR_TPS_LRNR_AND_MGR'
        ,p_upgrade_id            =>   p_update_id
        ,p_learning_path_id     =>   l_learning_path_id
        ,p_learning_path_section_id => l_learning_path_section_id
        ,p_object_version_number    => l_object_version_number);



--Create a learning path enrollments
        if l_learning_path_section_id is not null then
        create_lp_enrollment(p_name     => tp_rec.name
            ,p_learning_path_id           => l_learning_path_id
            ,p_Completion_target_date     => l_end_date
            ,p_Person_id                  => tp_rec.person_id
             ,p_Contact_id                 => tp_rec.contact_id
            ,p_path_status_code           => tp_rec.plan_status_type_id
            ,p_Creator_person_id          => tp_rec.creator_person_id
            ,p_business_group_id          => tp_rec.business_group_id
            ,p_Enrollment_source_code     => tp_rec.plan_source
            ,p_lp_enrollment_id           => l_lp_enrollment_id
            ,p_object_version_number      => l_object_version_number
            ,p_table_name                 => 'CREATE_LPE_FOR_TPS_LRNR_AND_MGR'
            ,p_upgrade_id                  => p_update_id
            ,p_training_plan_id           => tp_rec.training_plan_id
            ,p_attribute_category         => tp_rec.attribute_category
            ,p_attribute1                => tp_rec.attribute1
            ,p_attribute2                => tp_rec.attribute2
            ,p_attribute3                => tp_rec.attribute3
            ,p_attribute4                => tp_rec.attribute4
            ,p_attribute5                => tp_rec.attribute5
            ,p_attribute6                => tp_rec.attribute6
            ,p_attribute7                => tp_rec.attribute7
            ,p_attribute8                => tp_rec.attribute8
            ,p_attribute9                => tp_rec.attribute9
            ,p_attribute10               => tp_rec.attribute10
            ,p_attribute11               => tp_rec.attribute11
            ,p_attribute12                => tp_rec.attribute12
            ,p_attribute13                => tp_rec.attribute13
            ,p_attribute14                => tp_rec.attribute14
            ,p_attribute15                => tp_rec.attribute15
            ,p_attribute16                => tp_rec.attribute16
            ,p_attribute17                => tp_rec.attribute17
            ,p_attribute18                => tp_rec.attribute18
            ,p_attribute19                => tp_rec.attribute19
            ,p_attribute20                => tp_rec.attribute20
            ,p_attribute21                => tp_rec.attribute21
            ,p_attribute22                => tp_rec.attribute22
            ,p_attribute23                => tp_rec.attribute23
            ,p_attribute24                => tp_rec.attribute24
            ,p_attribute25                => tp_rec.attribute25
            ,p_attribute26                => tp_rec.attribute26
            ,p_attribute27                => tp_rec.attribute27
            ,p_attribute28                => tp_rec.attribute28
            ,p_attribute29                => tp_rec.attribute29
            ,p_attribute30                => tp_rec.attribute30
);


        l_total_comp := 0;
        l_completed_comp := 0;
        l_seq :=0;
        --Create learning path components for the learning path created above
        FOR tpm_rec IN csr_get_tpm(tp_rec.training_plan_id)
        LOOP
            l_learning_path_member_id   := null;
            l_lp_member_enrollment_id   := null;
            l_seq := l_seq + 1;
            l_member_status_code := tpm_rec.member_status_type_id;
            l_date_status_changed := null;

            if l_lp_enrollment_id is not null then

                 create_learning_path_members(
                    p_business_group_id           => tpm_rec.business_group_id
                    ,p_learning_path_id           => l_learning_path_id
                    ,p_activity_version_id        => tpm_rec.activity_version_id
                    ,p_course_sequence            => l_seq
                    ,p_completion_target_date     => tpm_rec.target_completion_date
                    ,p_learning_path_section_id   => l_learning_path_section_id
                    ,p_learning_path_member_id    => l_learning_path_member_id
                    ,p_object_version_number      => l_object_version_number
                    ,p_table_name                 => 'CREATE_LPM_FOR_TPM_LRNR_AND_MGR'
                    ,p_upgrade_id                  => p_update_id
                    ,p_training_plan_member_id    => tpm_rec.training_plan_member_id
                    ,p_training_plan_id           => tp_rec.training_plan_id);

--Create a record in table ota_lp_member_enrollments
                if l_learning_path_member_id is not null then
                    create_lp_member_enrollment(
                        p_lp_member_enrollment_id  => l_lp_member_enrollment_id
                        ,p_lp_enrollment_id        => l_lp_enrollment_id
                        ,p_learning_path_section_id=> l_learning_path_section_id
                        ,p_learning_path_member_id => l_learning_path_member_id
                        ,p_member_status_code      => tpm_rec.member_status_type_id
                        ,p_completion_target_date  => tpm_rec.target_completion_date
                     --   ,p_completion_date         => l_date_status_changed
                        ,p_business_group_id       => tpm_rec.business_group_id
                        ,p_creator_person_id        => tp_rec.creator_person_id  -- bug no 3984648
                     --   ,p_person_id               => tp_rec.person_id
                        ,p_activity_version_id     => tpm_rec.activity_version_id
                      --  ,p_contact_id              => tp_rec.contact_id
                        ,p_table_name              => 'CREATE_LPME_FOR_TPM_LRNR_AND_MGR'
                        ,p_upgrade_id               => p_update_id
                        ,p_object_version_number   => l_object_version_number
                        ,p_training_plan_member_id      => tpm_rec.training_plan_member_id
                        ,p_attribute_category         => tpm_rec.attribute_category
                        ,p_attribute1                => tp_rec.attribute1
                        ,p_attribute2                => tpm_rec.attribute2
                        ,p_attribute3                => tpm_rec.attribute3
            		,p_attribute4                => tpm_rec.attribute4
            		,p_attribute5                => tpm_rec.attribute5
            		,p_attribute6                => tpm_rec.attribute6
            		,p_attribute7                => tpm_rec.attribute7
		        ,p_attribute8                => tpm_rec.attribute8
            		,p_attribute9                => tpm_rec.attribute9
            		,p_attribute10               => tpm_rec.attribute10
            		,p_attribute11               => tpm_rec.attribute11
            		,p_attribute12                => tpm_rec.attribute12
            		,p_attribute13                => tpm_rec.attribute13
            		,p_attribute14                => tpm_rec.attribute14
            		,p_attribute15                => tpm_rec.attribute15
            		,p_attribute16                => tpm_rec.attribute16
            		,p_attribute17                => tpm_rec.attribute17
            		,p_attribute18                => tpm_rec.attribute18
            		,p_attribute19                => tpm_rec.attribute19
            		,p_attribute20                => tpm_rec.attribute20
            		,p_attribute21                => tpm_rec.attribute21
           		,p_attribute22                => tpm_rec.attribute22
            		,p_attribute23                => tpm_rec.attribute23
            		,p_attribute24                => tpm_rec.attribute24
            		,p_attribute25                => tpm_rec.attribute25
            		,p_attribute26                => tpm_rec.attribute26
            		,p_attribute27                => tpm_rec.attribute27
            		,p_attribute28                => tpm_rec.attribute28
            		,p_attribute29                => tpm_rec.attribute29
            		,p_attribute30                => tpm_rec.attribute30);
               end if;
            end if;
          END LOOP;



        end if;
      end if;

  END LOOP;
   Select nvl(count(1),0)
   into l_rows_processed
   from ota_training_plans
   where training_plan_id between p_start_pkid and p_end_pkid;

  p_rows_processed := l_rows_processed;
end upg_tp_for_lrnr_and_mgr_to_lp;



-- ----------------------------------------------------------------------------
-- |---------------------< upg_tp_to_lp_for_talent_mgmt >---------------------|
-- ----------------------------------------------------------------------------
procedure upg_tp_to_lp_for_talent_mgmt (
   p_process_control 	IN varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 --CONC_UPGRADE_ID
   ) is


l_training_plan_id          number;
l_object_version_number     number;
l_learning_path_id          number;
l_lp_enrollment_id          number;
l_learning_path_section_id  number;
l_learning_path_member_id   number;
l_lp_member_enrollment_id   number;
l_total_comp                number;
l_completed_comp            number;
l_flag                      boolean;
l_seq                       number;
l_Completion_date           date;
l_err_code                  varchar2(72);
l_err_msg                   varchar2(2000);
l_number                    number;
l_count                     number;
l_rows_processed            number;
l_end_date                  date;
l_member_status_type_flag   boolean;
l_status_code               ota_lp_enrollments.path_status_code%type;
l_status_type_id            varchar2(30);
l_old_status 	            ota_lp_member_enrollments.member_status_code%type;
l_max_date_status_changed   ota_delegate_bookings.date_status_changed%type;
l_date_status_changed       ota_delegate_bookings.date_status_changed%type;
l_name                      varchar2(80);
l_lang_len                  number;
MAX_NAME_LEN                constant number := 80;
MAX_DATA_TRUNC_LEN          constant number := 10;
l_display_to_learner_flag   ota_learning_paths.display_to_learner_flag%type;
l_member_status_code        ota_lp_member_enrollments.member_status_code%type;
--



cursor csr_get_talent_mgmt_comb is
SELECT distinct Tpm.source_id,Tpm.source_function, Tpm.assignment_id, tps.person_id
FROM ota_training_plans tps,Ota_training_plan_members tpm
WHERE PLAN_SOURCE = 'TALENT_MGMT'
AND tpm.training_plan_id = tps.training_plan_id
AND tps.PERSON_ID is not NULL;


cursor csr_get_talent_mgmt_rec (p_source_id in number
        ,p_source_function in varchar2, p_assignment_id in number, p_person_id IN NUMBER) is
SELECT tps.training_plan_id,
	Tps.name,
	Tps.description,
	Tps.business_group_id,
	Tps.start_date,
	Tps.end_date,
	Tps.Plan_status_type_id,
	Tps.creator_person_id,
	Tps.plan_source,
	Tpm.training_plan_member_id,
	Tpm.activity_version_id,
	Tpm.target_completion_date,
	Tpm.cancellation_reason,
	Tpm.member_status_type_id,
	Tps.person_id,
    Tps.contact_id,
	Tpm.assignment_id,
	Tpm.source_id,
	Tpm.source_function,
	Tpm.creator_person_id tpm_creator
    ,tpm.ATTRIBUTE_CATEGORY tpm_ATTRIBUTE_CATEGORY
    ,tpm.ATTRIBUTE1 tpm_ATTRIBUTE1
    ,tpm.ATTRIBUTE2 tpm_ATTRIBUTE2
    ,tpm.ATTRIBUTE3 tpm_ATTRIBUTE3
    ,tpm.ATTRIBUTE4 tpm_ATTRIBUTE4
    ,tpm.ATTRIBUTE5 tpm_ATTRIBUTE5
    ,tpm.ATTRIBUTE6 tpm_ATTRIBUTE6
    ,tpm.ATTRIBUTE7 tpm_ATTRIBUTE7
    ,tpm.ATTRIBUTE8 tpm_ATTRIBUTE8
    ,tpm.ATTRIBUTE9 tpm_ATTRIBUTE9
    ,tpm.ATTRIBUTE10 tpm_ATTRIBUTE10
    ,tpm.ATTRIBUTE11 tpm_ATTRIBUTE11
    ,tpm.ATTRIBUTE12 tpm_ATTRIBUTE12
    ,tpm.ATTRIBUTE13 tpm_ATTRIBUTE13
    ,tpm.ATTRIBUTE14 tpm_ATTRIBUTE14
    ,tpm.ATTRIBUTE15 tpm_ATTRIBUTE15
    ,tpm.ATTRIBUTE16 tpm_ATTRIBUTE16
    ,tpm.ATTRIBUTE17 tpm_ATTRIBUTE17
    ,tpm.ATTRIBUTE18 tpm_ATTRIBUTE18
    ,tpm.ATTRIBUTE19 tpm_ATTRIBUTE19
    ,tpm.ATTRIBUTE20 tpm_ATTRIBUTE20
    ,tpm.ATTRIBUTE21 tpm_ATTRIBUTE21
    ,tpm.ATTRIBUTE22 tpm_ATTRIBUTE22
    ,tpm.ATTRIBUTE23 tpm_ATTRIBUTE23
    ,tpm.ATTRIBUTE24 tpm_ATTRIBUTE24
    ,tpm.ATTRIBUTE25 tpm_ATTRIBUTE25
    ,tpm.ATTRIBUTE26 tpm_ATTRIBUTE26
    ,tpm.ATTRIBUTE27 tpm_ATTRIBUTE27
    ,tpm.ATTRIBUTE28 tpm_ATTRIBUTE28
    ,tpm.ATTRIBUTE29 tpm_ATTRIBUTE29
    ,tpm.ATTRIBUTE30 tpm_ATTRIBUTE30
    ,tps.ATTRIBUTE_CATEGORY tps_ATTRIBUTE_CATEGORY
    ,tps.ATTRIBUTE1 tps_attribute1
    ,tps.ATTRIBUTE2 tps_attribute2
    ,tps.ATTRIBUTE3 tps_attribute3
    ,tps.ATTRIBUTE4 tps_attribute4
    ,tps.ATTRIBUTE5 tps_attribute5
    ,tps.ATTRIBUTE6 tps_attribute6
    ,tps.ATTRIBUTE7 tps_attribute7
    ,tps.ATTRIBUTE8 tps_attribute8
    ,tps.ATTRIBUTE9 tps_attribute9
    ,tps.attribute10 tps_attribute10
    ,tps.attribute11 tps_attribute11
    ,tps.attribute12 tps_attribute12
    ,tps.attribute13 tps_attribute13
    ,tps.ATTRIBUTE14 tps_attribute14
    ,tps.ATTRIBUTE15 tps_attribute15
    ,tps.ATTRIBUTE16 tps_attribute16
    ,tps.ATTRIBUTE17 tps_attribute17
    ,tps.ATTRIBUTE18 tps_attribute18
    ,tps.ATTRIBUTE19 tps_attribute19
    ,tps.ATTRIBUTE20 tps_attribute20
    ,tps.ATTRIBUTE21 tps_attribute21
    ,tps.ATTRIBUTE22 tps_attribute22
    ,tps.ATTRIBUTE23 tps_attribute23
    ,tps.ATTRIBUTE24 tps_attribute24
    ,tps.ATTRIBUTE25 tps_attribute25
    ,tps.ATTRIBUTE26 tps_attribute26
    ,tps.ATTRIBUTE27 tps_attribute27
    ,tps.ATTRIBUTE28 tps_attribute28
    ,tps.ATTRIBUTE29 tps_attribute29
    ,tps.ATTRIBUTE30 tps_ATTRIBUTE30
FROM ota_training_plans tps, Ota_training_plan_members tpm
WHERE tps.PLAN_SOURCE = 'TALENT_MGMT'
AND tps.PERSON_ID = p_person_id
--AND PERSON_ID is not NULL
AND tpm.training_plan_id = tps.training_plan_id
AND tpm.source_function = p_source_function
AND (tpm.source_id is null or tpm.source_id = p_source_id)
AND (tpm.assignment_id is  null or tpm.assignment_id = p_assignment_id)
order by tpm.training_plan_member_id ;

cursor csr_member_status (p_source_id in number
        ,p_source_function in varchar2, p_assignment_id in number, p_person_id IN NUMBER) is
SELECT decode(member_status_type_id, 'OTA_PLANNED', 0,'ACTIVE', 0, 'OTA_AWAITING_APPROVAL',0, 'OTA_COMPLETED',1,
  'CANCELLED',2) top_status
FROM Ota_training_plan_members tpm, ota_training_plans tps
WHERE tps.training_plan_id = tpm.training_plan_id
AND tpm.source_function = p_source_function
AND (tpm.source_id is null or tpm.source_id = p_source_id)
AND (tpm.assignment_id is  null or tpm.assignment_id = p_assignment_id)
AND tps.person_id = p_person_id
order by top_status;

--
--

BEGIN

  FOR talent_mgmt_comb IN csr_get_talent_mgmt_comb  LOOP
    l_flag  := true;
    l_count := 0;
    l_total_comp := 0;
    l_completed_comp := 0;

/*
    open csr_member_status(talent_mgmt_comb.source_id
        ,talent_mgmt_comb.source_function, talent_mgmt_comb.assignment_id);
    fetch csr_member_status into l_status_type_id;
    if csr_member_status%notfound then
        l_status_code := 'CANCELLED';
    end if;
    close csr_member_status;
*/
    FOR talent_mgmt_rec IN csr_get_talent_mgmt_rec(talent_mgmt_comb.source_id
        ,talent_mgmt_comb.source_function, talent_mgmt_comb.assignment_id, talent_mgmt_comb.person_id) LOOP
       l_count := l_count + 1;



        --Create learning paths from training plans
        --For the first record in this loop, create a learning path and a record in ota_lp_enrollments
	  if l_flag then
      l_status_code := talent_mgmt_rec.plan_status_type_id;
      FOR lpm_rec IN csr_member_status(talent_mgmt_comb.source_id
        ,talent_mgmt_comb.source_function, talent_mgmt_comb.assignment_id,talent_mgmt_comb.person_id) LOOP
        IF lpm_rec.top_status = 1 THEN
            l_status_code := 'OTA_COMPLETED';
        ELSIF lpm_rec.top_status = 2 THEN
            l_status_code := 'CANCELLED';
        END IF;
        EXIT;
      END LOOP;
        l_learning_path_id := null;
        l_learning_path_section_id := null;
        l_lp_enrollment_id := null;

        if talent_mgmt_rec.end_date = hr_api.g_eot then
            l_end_date := null;
        else
            l_end_date := talent_mgmt_rec.end_date;
        end if;
        /* For Suitability Matching records, Name of LP is picked from Lookup */
        If talent_mgmt_comb.source_function = 'SUITABILITY' then
        /*    l_name := ota_utility.Get_lookup_meaning
                               (p_lookup_type    => 'OTA_PLAN_COMPONENT_SOURCE',
                                p_lookup_code    => talent_mgmt_comb.source_function,
                                p_application_id => 810);
        */
              l_name := 'Suitability Matching Recommended Courses';
        Else
            l_name :=  talent_mgmt_rec.name;
            l_lang_len := length(talent_mgmt_rec.name || '-' || talent_mgmt_rec.training_plan_member_id) ;
            If l_lang_len > MAX_NAME_LEN then
                l_lang_len := l_lang_len - MAX_NAME_LEN ;
                If l_lang_len > MAX_DATA_TRUNC_LEN then
                    l_lang_len := MAX_DATA_TRUNC_LEN;
                End if;
            End if;
            if( length(talent_mgmt_rec.name) = 80 OR length(talent_mgmt_rec.name||'-'||talent_mgmt_rec.training_plan_member_id) > 80 )  then
                l_name := substrb(talent_mgmt_rec.name,1,80-l_lang_len);
            end if;

            l_name := substrb(l_name||'-'||talent_mgmt_rec.training_plan_member_id,1,80);
        End if;



        if talent_mgmt_comb.source_function = 'APPRAISAL' and
            talent_mgmt_rec.member_status_type_id = 'OTA_AWAITING_APPROVAL' then
            l_status_code   := 'AWAITING_APPROVAL';
            --l_member_status_code := 'AWAITING_APPROVAL';
            l_display_to_learner_flag := 'N';
        else
           -- l_member_status_code := talent_mgmt_rec.member_status_type_id;
            l_display_to_learner_flag := 'Y';
        end if;
        create_learning_path(p_name  =>  l_name
        ,p_business_group_id     => talent_mgmt_rec.business_group_id
        ,p_start_date_active     => talent_mgmt_rec.start_date
        ,p_end_date_active       => l_end_date
        ,p_description           => talent_mgmt_rec.description
        ,p_path_source_code      => 'TALENT_MGMT'
        ,p_person_id             => talent_mgmt_rec.person_id
        ,p_table_name            => 'CREATE_LPS_FOR_TPS_TALENT_MGMT'
        ,p_upgrade_id             => p_update_id
        ,p_learning_path_id      => l_learning_path_id
        ,p_object_version_number => l_object_version_number
        ,p_source_function_code  => talent_mgmt_comb.source_function
        ,p_assignment_id         => talent_mgmt_comb.assignment_id
        ,p_source_id             => talent_mgmt_comb.source_id
        ,p_display_to_learner_flag =>l_display_to_learner_flag
        ,p_training_plan_id         => talent_mgmt_rec.training_plan_id
        );

        if l_learning_path_id is not null then

            create_lp_sections(
                p_section_name          =>   l_name
                ,p_description          =>   talent_mgmt_rec.description
                ,p_section_sequence     =>   1
                ,p_completion_type_code =>   'M'
                ,p_business_group_id    =>   talent_mgmt_rec.business_group_id
                ,p_table_name           =>   'CREATE_LPC_FOR_TPS_TALENT_MGMT'
                ,p_upgrade_id            =>   p_update_id
                ,p_learning_path_id     =>   l_learning_path_id
                ,p_learning_path_section_id => l_learning_path_section_id
                ,p_object_version_number    => l_object_version_number);

            if l_learning_path_section_id is not null then
                create_lp_enrollment(p_name     => talent_mgmt_rec.name
                    ,p_learning_path_id         => l_learning_path_id
                    ,p_Completion_target_date   => l_end_date
                    ,p_Person_id                => talent_mgmt_rec.person_id
                    ,p_path_status_code         => l_status_code
                    ,p_Creator_person_id        => talent_mgmt_rec.creator_person_id
                    ,p_business_group_id        => talent_mgmt_rec.business_group_id
                    ,p_Enrollment_source_code   => talent_mgmt_rec.plan_source
                    ,p_lp_enrollment_id         => l_lp_enrollment_id
                    ,p_object_version_number    => l_object_version_number
                    ,p_table_name               => 'CREATE_LPE_FOR_TPS_TALENT_MGMT'
                    ,p_upgrade_id                => p_update_id
                    ,p_training_plan_id         => talent_mgmt_rec.training_plan_id
                    ,p_source_id                => talent_mgmt_comb.source_id
                    ,p_source_function          => talent_mgmt_comb.source_function
                    ,p_assignment_id            => talent_mgmt_comb.assignment_id
                    ,p_attribute_category       => talent_mgmt_rec.tps_attribute_category
                    ,p_attribute1               => talent_mgmt_rec.tps_attribute1
                    ,p_attribute2               => talent_mgmt_rec.tps_attribute2
                    ,p_attribute3               => talent_mgmt_rec.tps_attribute3
                    ,p_attribute4               => talent_mgmt_rec.tps_attribute4
                    ,p_attribute5               => talent_mgmt_rec.tps_attribute5
                    ,p_attribute6               => talent_mgmt_rec.tps_attribute6
                    ,p_attribute7               => talent_mgmt_rec.tps_attribute7
                    ,p_attribute8               => talent_mgmt_rec.tps_attribute8
                    ,p_attribute9               => talent_mgmt_rec.tps_attribute9
                    ,p_attribute10              => talent_mgmt_rec.tps_attribute10
                    ,p_attribute11              => talent_mgmt_rec.tps_attribute11
                    ,p_attribute12              => talent_mgmt_rec.tps_attribute12
                    ,p_attribute13              => talent_mgmt_rec.tps_attribute13
                    ,p_attribute14              => talent_mgmt_rec.tps_attribute14
                    ,p_attribute15              => talent_mgmt_rec.tps_attribute15
                    ,p_attribute16              => talent_mgmt_rec.tps_attribute16
                    ,p_attribute17              => talent_mgmt_rec.tps_attribute17
                    ,p_attribute18              => talent_mgmt_rec.tps_attribute18
                    ,p_attribute19              => talent_mgmt_rec.tps_attribute19
                    ,p_attribute20              => talent_mgmt_rec.tps_attribute20
                    ,p_attribute21              => talent_mgmt_rec.tps_attribute21
                    ,p_attribute22              => talent_mgmt_rec.tps_attribute22
                    ,p_attribute23              => talent_mgmt_rec.tps_attribute23
                    ,p_attribute24              => talent_mgmt_rec.tps_attribute24
                    ,p_attribute25              => talent_mgmt_rec.tps_attribute25
                    ,p_attribute26              => talent_mgmt_rec.tps_attribute26
                    ,p_attribute27              => talent_mgmt_rec.tps_attribute27
                    ,p_attribute28              => talent_mgmt_rec.tps_attribute28
                    ,p_attribute29              => talent_mgmt_rec.tps_attribute29
                    ,p_attribute30              => talent_mgmt_rec.tps_attribute30
                    );
              end if;
           end if;

       end if;
       l_flag := false;
       l_learning_path_member_id := null;
       l_lp_member_enrollment_id := null;

        if l_learning_path_id is not null and l_learning_path_section_id is not null
                        and l_lp_enrollment_id is not null then

            create_learning_path_members(
                    p_business_group_id           => talent_mgmt_rec.business_group_id
                    ,p_learning_path_id           => l_learning_path_id
                    ,p_activity_version_id        => talent_mgmt_rec.activity_version_id
                    ,p_course_sequence            => l_count
                    ,p_completion_target_date     => talent_mgmt_rec.target_completion_date
                    ,p_learning_path_section_id   => l_learning_path_section_id
                    ,p_learning_path_member_id    => l_learning_path_member_id
                    ,p_object_version_number      => l_object_version_number
                    ,p_table_name                 => 'CREATE_LPM_FOR_TPM_TALENT_MGMT'
                    ,p_upgrade_id                  => p_update_id
                    ,p_training_plan_member_id    => talent_mgmt_rec.training_plan_member_id
                    ,p_training_plan_id           => talent_mgmt_rec.training_plan_id  );

            if l_learning_path_member_id is not null then
            if talent_mgmt_rec.member_status_type_id = 'OTA_AWAITING_APPROVAL'
			    /* AND talent_mgmt_rec.source_function = 'SUITABILITY' */ then
    			l_member_status_code := 'OTA_PLANNED';
	       	else
		      	l_member_status_code := talent_mgmt_rec.member_status_type_id;
    		end if;

                create_lp_member_enrollment(
                        p_lp_member_enrollment_id  => l_lp_member_enrollment_id
                        ,p_lp_enrollment_id        => l_lp_enrollment_id
                        ,p_learning_path_section_id=> l_learning_path_section_id
                        ,p_learning_path_member_id => l_learning_path_member_id
                        ,p_member_status_code      => l_member_status_code                        ,p_completion_target_date  => talent_mgmt_rec.target_completion_date
                       -- ,p_completion_date         => l_date_status_changed
                        ,p_creator_person_id        => talent_mgmt_rec.creator_person_id  -- bug no 3984648
                       ,p_business_group_id       => talent_mgmt_rec.business_group_id
                   --     ,p_person_id               => talent_mgmt_rec.person_id
                        ,p_activity_version_id     => talent_mgmt_rec.activity_version_id
                       -- ,p_contact_id              => talent_mgmt_rec.contact_id
                        ,p_table_name              => 'CREATE_LPME_FOR_TPM_TALENT_MGMT'
                        ,p_upgrade_id               => p_update_id
                        ,p_object_version_number   => l_object_version_number
                        ,p_training_plan_member_id => talent_mgmt_rec.training_plan_member_id
                        ,p_attribute_category         => talent_mgmt_rec.tpm_attribute_category
                        ,p_attribute1                => talent_mgmt_rec.tpm_attribute1
                        ,p_attribute2                => talent_mgmt_rec.tpm_attribute2
                        ,p_attribute3                => talent_mgmt_rec.tpm_attribute3
                        ,p_attribute4                => talent_mgmt_rec.tpm_attribute4
                        ,p_attribute5                => talent_mgmt_rec.tpm_attribute5
                        ,p_attribute6                => talent_mgmt_rec.tpm_attribute6
                        ,p_attribute7                => talent_mgmt_rec.tpm_attribute7
                        ,p_attribute8                => talent_mgmt_rec.tpm_attribute8
                        ,p_attribute9                => talent_mgmt_rec.tpm_attribute9
                        ,p_attribute10               => talent_mgmt_rec.tpm_attribute10
                        ,p_attribute11               => talent_mgmt_rec.tpm_attribute11
                        ,p_attribute12                => talent_mgmt_rec.tpm_attribute12
                        ,p_attribute13                => talent_mgmt_rec.tpm_attribute13
                        ,p_attribute14                => talent_mgmt_rec.tpm_attribute14
                        ,p_attribute15                => talent_mgmt_rec.tpm_attribute15
                        ,p_attribute16                => talent_mgmt_rec.tpm_attribute16
                        ,p_attribute17                => talent_mgmt_rec.tpm_attribute17
                        ,p_attribute18                => talent_mgmt_rec.tpm_attribute18
                        ,p_attribute19                => talent_mgmt_rec.tpm_attribute19
                        ,p_attribute20                => talent_mgmt_rec.tpm_attribute20
                        ,p_attribute21                => talent_mgmt_rec.tpm_attribute21
                        ,p_attribute22                => talent_mgmt_rec.tpm_attribute22
                        ,p_attribute23                => talent_mgmt_rec.tpm_attribute23
                        ,p_attribute24                => talent_mgmt_rec.tpm_attribute24
                        ,p_attribute25                => talent_mgmt_rec.tpm_attribute25
                        ,p_attribute26                => talent_mgmt_rec.tpm_attribute26
                        ,p_attribute27                => talent_mgmt_rec.tpm_attribute27
                        ,p_attribute28                => talent_mgmt_rec.tpm_attribute28
                        ,p_attribute29                => talent_mgmt_rec.tpm_attribute29
                        ,p_attribute30                => talent_mgmt_rec.tpm_attribute30  );

             end if;
            end if;


        END LOOP;


    END LOOP;

    Select nvl(count(1),0)
    into l_rows_processed
    from ota_training_plans
    where training_plan_id between p_start_pkid and p_end_pkid;

    p_rows_processed := l_rows_processed;
end upg_tp_to_lp_for_talent_mgmt;
-- ----------------------------------------------------------------------------
-- |---------------------------< upg_enrol_to_cat_lp  >-----------------------|
-- ----------------------------------------------------------------------------
Procedure upg_enrol_to_cat_lp(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 --CONC_UPGRADE_ID
) IS

l_learning_path_id          number;
l_target_completion_date    date;
l_lp_enrollment_id          number;
l_lp_member_enrollment_id   number;
l_object_version_number     number;
l_completed_comp            number;
L_total_comp                number;
l_completion_date           date;
l_rows_processed            number;
l_end_date                  date;

l_member_status_code ota_lp_member_enrollments.member_status_code%type;
l_old_status 	     ota_lp_member_enrollments.member_status_code%type;
l_max_date_status_changed ota_delegate_bookings.date_status_changed%type;
l_date_status_changed ota_delegate_bookings.date_status_changed%type;
l_err_code                  varchar2(72);
l_err_msg                   varchar2(2000);

CURSOR csr_get_tp IS
 SELECT tp.training_plan_id, tp.end_date, tp.person_id,tp.name
    , tp.learning_path_id,tp.plan_status_type_id, tp.business_group_id
    , tp.plan_source, tp.contact_id
    ,tp.ATTRIBUTE_CATEGORY,tp.ATTRIBUTE1
    ,tp.ATTRIBUTE2 ,tp.ATTRIBUTE3
    ,tp.ATTRIBUTE4 ,tp.ATTRIBUTE5
    ,tp.ATTRIBUTE6 ,tp.ATTRIBUTE7
    ,tp.ATTRIBUTE8 ,tp.ATTRIBUTE9
    ,tp.ATTRIBUTE10 ,tp.ATTRIBUTE11
    ,tp.ATTRIBUTE12 ,tp.ATTRIBUTE13
    ,tp.ATTRIBUTE14 ,tp.ATTRIBUTE15
    ,tp.ATTRIBUTE16 ,tp.ATTRIBUTE17
    ,tp.ATTRIBUTE18 ,tp.ATTRIBUTE19
    ,tp.ATTRIBUTE20 ,tp.ATTRIBUTE21
    ,tp.ATTRIBUTE22 ,tp.ATTRIBUTE23
    ,tp.ATTRIBUTE24 ,tp.ATTRIBUTE25
    ,tp.ATTRIBUTE26 ,tp.ATTRIBUTE27
    ,tp.ATTRIBUTE28 ,tp.ATTRIBUTE29
    ,tp.ATTRIBUTE30 ,tp.creator_person_id
 FROM ota_training_plans tp
 WHERE tp.PLAN_SOURCE in ('CATALOG','MANAGER')
 AND tp.learning_path_id is not null
 AND (tp.PERSON_ID is not NULL OR tp.contact_id is not null)
 AND  tp.training_plan_id between p_start_pkid and p_end_pkid;



CURSOR csr_get_tpm(p_training_plan_id NUMBER) IS
 SELECT  tpm.training_plan_member_id
        ,tpm.member_status_type_id
        ,tpm.activity_version_id
	    ,tpm.target_completion_date
        ,tpm.business_group_id
      	,Lpm.learning_path_member_id
 	    ,Lpm.learning_path_section_id
        ,tpm.ATTRIBUTE_CATEGORY ,tpm.ATTRIBUTE1
        ,tpm.ATTRIBUTE2 ,tpm.ATTRIBUTE3
        ,tpm.ATTRIBUTE4 ,tpm.ATTRIBUTE5
        ,tpm.ATTRIBUTE6 ,tpm.ATTRIBUTE7
        ,tpm.ATTRIBUTE8 ,tpm.ATTRIBUTE9
        ,tpm.ATTRIBUTE10 ,tpm.ATTRIBUTE11
        ,tpm.ATTRIBUTE12 ,tpm.ATTRIBUTE13
        ,tpm.ATTRIBUTE14 ,tpm.ATTRIBUTE15
        ,tpm.ATTRIBUTE16 ,tpm.ATTRIBUTE17
        ,tpm.ATTRIBUTE18 ,tpm.ATTRIBUTE19
        ,tpm.ATTRIBUTE20 ,tpm.ATTRIBUTE21
        ,tpm.ATTRIBUTE22 ,tpm.ATTRIBUTE23
        ,tpm.ATTRIBUTE24 ,tpm.ATTRIBUTE25
        ,tpm.ATTRIBUTE26 ,tpm.ATTRIBUTE27
        ,tpm.ATTRIBUTE28 ,tpm.ATTRIBUTE29
        ,tpm.ATTRIBUTE30
 FROM ota_training_plan_members tpm,
  	    ota_training_plans tp,
	    ota_learning_path_members lpm,
        ota_learning_paths lps
 WHERE tp.training_plan_id   = p_training_plan_id
 AND lpm.activity_version_id = tpm.activity_version_id
 AND lps.path_source_code    in ('CATALOG','MANAGER')
 AND lps.learning_path_id    = lpm.learning_path_id
 AND tp.training_plan_id     = tpm.training_plan_id
 AND tp.learning_path_id     = lps.learning_path_id;

BEGIN

    FOR tp_rec IN csr_get_tp LOOP
        l_lp_enrollment_id := null;
        l_max_date_status_changed   := null;
        --completion_target_date := tp_rec.end_date; (if tp_rec.end_date is 31-Dec-4712 then completion_target_date is set to null)
        if tp_rec.end_date = hr_api.g_eot then
		    l_end_date := null;
        else
		    l_end_date := tp_rec.end_date;
	    end if;
	--Create a record in ota_lp_enrollments

    	create_lp_enrollment(p_name       => tp_rec.name
            ,p_learning_path_id           => tp_rec.learning_path_id
            ,p_Completion_target_date     => l_end_date
            ,p_Person_id                  => tp_rec.person_id
            ,p_Contact_id                 => tp_rec.contact_id
            ,p_path_status_code           => tp_rec.plan_status_type_id
            ,p_Creator_person_id          => tp_rec.creator_person_id
            ,p_business_group_id          => tp_rec.business_group_id
            ,p_Enrollment_source_code     => tp_rec.plan_source
            ,p_lp_enrollment_id           => l_lp_enrollment_id
            ,p_object_version_number      => l_object_version_number
            ,p_table_name                 => 'CREATE_LPE_FOR_TPS_ENROL_TO_CAT'
            ,p_upgrade_id                  => p_update_id
            ,p_training_plan_id           => tp_rec.training_plan_id
            ,p_attribute_category         => tp_rec.attribute_category
            ,p_attribute1                => tp_rec.attribute1
            ,p_attribute2                => tp_rec.attribute2
            ,p_attribute3                => tp_rec.attribute3
            ,p_attribute4                => tp_rec.attribute4
            ,p_attribute5                => tp_rec.attribute5
            ,p_attribute6                => tp_rec.attribute6
            ,p_attribute7                => tp_rec.attribute7
            ,p_attribute8                => tp_rec.attribute8
            ,p_attribute9                => tp_rec.attribute9
            ,p_attribute10               => tp_rec.attribute10
            ,p_attribute11               => tp_rec.attribute11
            ,p_attribute12                => tp_rec.attribute12
            ,p_attribute13                => tp_rec.attribute13
            ,p_attribute14                => tp_rec.attribute14
            ,p_attribute15                => tp_rec.attribute15
            ,p_attribute16                => tp_rec.attribute16
            ,p_attribute17                => tp_rec.attribute17
            ,p_attribute18                => tp_rec.attribute18
            ,p_attribute19                => tp_rec.attribute19
            ,p_attribute20                => tp_rec.attribute20
            ,p_attribute21                => tp_rec.attribute21
            ,p_attribute22                => tp_rec.attribute22
            ,p_attribute23                => tp_rec.attribute23
            ,p_attribute24                => tp_rec.attribute24
            ,p_attribute25                => tp_rec.attribute25
            ,p_attribute26                => tp_rec.attribute26
            ,p_attribute27                => tp_rec.attribute27
            ,p_attribute28                => tp_rec.attribute28
            ,p_attribute29                => tp_rec.attribute29
            ,p_attribute30                => tp_rec.attribute30);

	    FOR tpm_rec IN csr_get_tpm(tp_rec.training_plan_id) LOOP
            l_lp_member_enrollment_id := null;
            if tpm_rec.target_completion_date = hr_api.g_eot then
		    l_target_completion_date := null;
            else
	    	    l_target_completion_date := tpm_rec.target_completion_date;
	        end if;
            l_member_status_code := tpm_rec.member_status_type_id;
            l_date_status_changed := null;

             create_lp_member_enrollment(
                        p_lp_member_enrollment_id    => l_lp_member_enrollment_id
                        ,p_lp_enrollment_id          => l_lp_enrollment_id
                        ,p_learning_path_section_id  => tpm_rec.learning_path_section_id
                        ,p_learning_path_member_id   => tpm_rec.learning_path_member_id
                        ,p_member_status_code        => tpm_rec.member_status_type_id
                        ,p_completion_target_date    => l_target_completion_date
                   --     ,p_completion_date         => l_date_status_changed
                        ,p_business_group_id         => tpm_rec.business_group_id
                   --    ,p_person_id               => tp_rec.person_id
                        ,p_creator_person_id        => tp_rec.creator_person_id  -- bug no 3984648
                        ,p_activity_version_id       => tpm_rec.activity_version_id
                    --    ,p_contact_id              => tp_rec.contact_id
                        ,p_table_name                => 'CREATE_LPME_FOR_TPM_ENROL_TO_CAT'
                        ,p_upgrade_id                => p_update_id
                        ,p_object_version_number     => l_object_version_number
                        ,p_training_plan_member_id   => tpm_rec.training_plan_member_id
                        ,p_attribute_category        => tpm_rec.attribute_category
                        ,p_attribute1                => tp_rec.attribute1
                        ,p_attribute2                => tpm_rec.attribute2
                        ,p_attribute3                => tpm_rec.attribute3
                        ,p_attribute4                => tpm_rec.attribute4
                        ,p_attribute5                => tpm_rec.attribute5
                        ,p_attribute6                => tpm_rec.attribute6
			,p_attribute7                => tpm_rec.attribute7
		        ,p_attribute8                => tpm_rec.attribute8
		        ,p_attribute9                => tpm_rec.attribute9
	                ,p_attribute10               => tpm_rec.attribute10
			,p_attribute11               => tpm_rec.attribute11
			,p_attribute12               => tpm_rec.attribute12
			,p_attribute13               => tpm_rec.attribute13
			,p_attribute14               => tpm_rec.attribute14
			,p_attribute15               => tpm_rec.attribute15
			,p_attribute16               => tpm_rec.attribute16
			,p_attribute17               => tpm_rec.attribute17
			,p_attribute18               => tpm_rec.attribute18
			,p_attribute19               => tpm_rec.attribute19
			,p_attribute20               => tpm_rec.attribute20
			,p_attribute21               => tpm_rec.attribute21
			,p_attribute22               => tpm_rec.attribute22
			,p_attribute23               => tpm_rec.attribute23
			,p_attribute24               => tpm_rec.attribute24
			,p_attribute25               => tpm_rec.attribute25
			,p_attribute26               => tpm_rec.attribute26
			,p_attribute27               => tpm_rec.attribute27
			,p_attribute28               => tpm_rec.attribute28
			,p_attribute29               => tpm_rec.attribute29
			,p_attribute30               => tpm_rec.attribute30);



         END LOOP;

    END LOOP;
    Select nvl(count(1),0)
    into l_rows_processed
    from ota_training_plans
    where training_plan_id between p_start_pkid and p_end_pkid;

    p_rows_processed := l_rows_processed;
end upg_enrol_to_cat_lp;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_enrollment_status >-----------------------|
-- ----------------------------------------------------------------------------
-- Updating the status of ota_lp_enrollments and ota_lp_member_enrollments table.
/*
PROCEDURE update_enrollment_status is
begin
    UPDATE ota_lp_enrollments
    SET path_status_code = 'COMPLETED'
    where path_status_code = 'OTA_COMPLETED';


    UPDATE ota_lp_member_enrollments
    SET member_status_code = decode(member_status_code,'OTA_COMPLETED','COMPLETED'
        ,'OTA_PLANNED','PLANNED','OTA_AWAITING_APPROVAL','AWAITING_APPROVAL'
        ,member_status_code);


end update_enrollment_status;
*/
-- ----------------------------------------------------------------------------
-- |----------------------------< is_path_complete >--------------------------|
-- ----------------------------------------------------------------------------

FUNCTION  is_path_complete(p_lp_enrollment_id in number) return varchar2
IS
 CURSOR csr_member_status is
  SELECT decode(member_status_code, 'PLANNED', 0,'ACTIVE', 0, 'AWAITING_APPROVAL',0, 'COMPLETED',1,
  'CANCELLED',2) top_status
  FROM ota_lp_member_enrollments lpme
WHERE lpme.lp_enrollment_id = p_lp_enrollment_id
ORDER BY top_status;
 l_is_complete varchar2(1) := 'F';
begin
  FOR lpme_rec IN  csr_member_status LOOP
    IF lpme_rec.top_status = 1 THEN
      l_is_complete := 'S';
    END IF;
  EXIT;
  END LOOP;
  return l_is_complete;
end is_path_complete;
-- ----------------------------------------------------------------------------
-- |----------------------------< remove_date_rest >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE remove_date_rest (
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1
   ) IS

l_lp_enrollment_id  number;
l_learning_path_id  number;
l_tpm_changed       boolean;
l_lpm_status_changed boolean;
l_member_status_code ota_lp_member_enrollments.member_status_code%type;
l_old_status 	     ota_lp_member_enrollments.member_status_code%type;
l_max_date_status_changed ota_delegate_bookings.date_status_changed%type;
l_date_status_changed ota_delegate_bookings.date_status_changed%type;
l_dummy number;
l_status  ota_booking_status_types.type%type;
l_rows_processed            number;
l_completion_date           date;
l_lpm_enrollment_id         number;
l_completed_courses         number;
l_flex_val                  varchar2(2000);
l_lp_object_version_number  number;
l_lp_completion_date_old    date;
l_err_code varchar2(72);
l_err_msg  varchar2(2000);
l_source_function_code ota_learning_paths.source_function_code%type;



CURSOR csr_get_lpe(p_path_status_code IN VARCHAR2) is
  SELECT lpe.learning_path_id, lpe.lp_enrollment_id, lpe.person_id, lpe.contact_id
  ,lpe.completion_date
  ,lpe.object_version_number
  FROM ota_lp_enrollments lpe
  WHERE lpe.path_status_code = p_path_status_code
 and lpe.lp_enrollment_id between p_start_pkid and p_end_pkid;
/*
-- Get all the Learning Path Components that are in Active or Planned Status.
CURSOR csr_get_lpme(p_lp_enrollment_id in number) IS
  SELECT lpm.activity_version_id, lpme.lp_member_enrollment_id, lpme.member_status_code,
   lpme.object_version_number
  FROM ota_lp_member_enrollments lpme,ota_learning_path_members lpm
  WHERE lpme.learning_path_member_id = lpm.learning_path_member_id
   AND lpme.lp_enrollment_id = p_lp_enrollment_id
--   AND  lpm.learning_path_id = p_learning_path_id
   AND lpme.member_status_code IN ('PLANNED','ACTIVE');

CURSOR csr_get_status(p_activity_version_id IN NUMBER, p_person_id IN NUMBER
,p_contact_id in number) IS
SELECT DECODE(bst.type,'C','Z',bst.type) status
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE evt.activity_version_id=p_activity_version_id
   AND evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND ((p_person_id is not null and tdb.delegate_person_id = p_person_id )
   or (p_contact_id is not null and tdb.delegate_contact_id = p_contact_id))
   and rownum=1
 ORDER BY status;

*/

cursor csr_get_member_status(P_LP_ENROLLMENT_ID IN NUMBER) is
SELECT 1 from ota_lp_member_enrollments lpme
WHERE lpme.member_status_code in ('ACTIVE','PLANNED')
AND lpme.LP_ENROLLMENT_ID = P_LP_ENROLLMENT_ID;

cursor csr_get_completed_lpms is
SELECT lpme.lp_member_enrollment_id
FROM ota_lp_member_enrollments lpme
WHERE lpme.member_status_code  = 'COMPLETED'
AND lpme.LP_ENROLLMENT_ID between p_start_pkid and p_end_pkid;
--
cursor csr_get_lpm_completion_date(p_lpm_enrollment_id IN NUMBER) IS
  SELECT trunc(min(nvl(tdb.date_status_changed,tdb.date_booking_placed))) completion_date
  FROM ota_delegate_bookings tdb,
       ota_lp_member_enrollments lpme,
       ota_learning_path_members lpm,
       ota_lp_enrollments lpe,
       ota_events evt,
       ota_booking_status_types bst
  WHERE tdb.event_id = evt.event_id
    AND evt.activity_version_id = lpm.activity_version_id
    AND tdb.booking_status_type_id = bst.booking_status_type_id
    AND bst.type = 'A'
    AND lpe.lp_enrollment_id = lpme.lp_enrollment_id
    AND lpme.learning_path_member_id = lpm.learning_path_member_id
    AND ((lpe.person_id IS NOT NULL AND lpe.person_id = tdb.delegate_person_id)
         OR (lpe.contact_id IS NOT NULL AND lpe.contact_id = tdb.delegate_contact_id))
    AND lpme.lp_member_enrollment_id = p_lpm_enrollment_id;

  cursor csr_get_lp_completion_info(p_lp_enrollment_id IN NUMBER) IS
   SELECT trunc(max(lpme.completion_date)) completion_date,
          count(lpme.lp_member_enrollment_id) completed_courses
   FROM ota_lp_member_enrollments lpme
   WHERE lpme.member_status_code = 'COMPLETED'
   AND lpme.lp_enrollment_id = p_lp_enrollment_id;

  Cursor csr_get_attrib_personal_tps is
    SELECT 1
    FROM ota_training_plans tps
    WHERE (tps.PERSON_ID is not NULL OR tps.contact_id is not null)
    and (tps.ATTRIBUTE_CATEGORY||tps.ATTRIBUTE1||tps.ATTRIBUTE2||tps.ATTRIBUTE3||tps.ATTRIBUTE4||
    tps.ATTRIBUTE5||tps.ATTRIBUTE6||tps.ATTRIBUTE7 ||tps.ATTRIBUTE9||tps.ATTRIBUTE10||tps.ATTRIBUTE11||
    tps.ATTRIBUTE12||tps.ATTRIBUTE13||tps.ATTRIBUTE14||tps.ATTRIBUTE15||tps.ATTRIBUTE16 ||
    tps.ATTRIBUTE17||tps.ATTRIBUTE18||tps.ATTRIBUTE19||tps.ATTRIBUTE20||tps.ATTRIBUTE21 ||
    tps.ATTRIBUTE22||tps.ATTRIBUTE23||tps.ATTRIBUTE24 ||tps.ATTRIBUTE25||tps.ATTRIBUTE26||
    tps.ATTRIBUTE27||tps.ATTRIBUTE28||tps.ATTRIBUTE29||tps.ATTRIBUTE30) is not null
    AND ROWNUM=1;

  Cursor csr_get_attrib_personal_tpm is
    SELECT 1
    FROM ota_training_plan_members tpm, ota_training_plans tps
    WHERE (tps.PERSON_ID is not NULL OR contact_id is not null)
    AND (TPM.ATTRIBUTE_CATEGORY||TPM.ATTRIBUTE1||TPM.ATTRIBUTE2||TPM.ATTRIBUTE3||TPM.ATTRIBUTE4||
    TPM.ATTRIBUTE5||TPM.ATTRIBUTE6||TPM.ATTRIBUTE7 ||TPM.ATTRIBUTE9||TPM.ATTRIBUTE10||TPM.ATTRIBUTE11||
    TPM.ATTRIBUTE12||TPM.ATTRIBUTE13||TPM.ATTRIBUTE14||TPM.ATTRIBUTE15||TPM.ATTRIBUTE16 ||
    TPM.ATTRIBUTE17||TPM.ATTRIBUTE18||TPM.ATTRIBUTE19||TPM.ATTRIBUTE20||TPM.ATTRIBUTE21 ||
    TPM.ATTRIBUTE22||TPM.ATTRIBUTE23||TPM.ATTRIBUTE24 ||TPM.ATTRIBUTE25||TPM.ATTRIBUTE26||
    TPM.ATTRIBUTE27||TPM.ATTRIBUTE28||TPM.ATTRIBUTE29|| TPM.ATTRIBUTE30) IS NOT NULL
    AND tps.training_plan_id = tpm.training_plan_id
    AND ROWNUM=1;

    CURSOR GET_SOURCE_FUNCTION_CODE (P_LP_ENROLLMENT_ID IN VARCHAR2)
    IS
    SELECT LPS.SOURCE_FUNCTION_CODE
    FROM OTA_LEARNING_PATHS LPS, OTA_LP_ENROLLMENTS LPE
    WHERE LPE.LEARNING_PATH_ID = LPS.LEARNING_PATH_ID
    AND LPE.LP_ENROLLMENT_ID = P_LP_ENROLLMENT_ID
    AND LPS.SOURCE_FUNCTION_CODE = 'SUITABILITY';


BEGIN

    /* update the enrollment status of ota_lp_enrollments and ota_lp_member_enrollments */
  --update_enrollment_status;

   update ota_lp_enrollments lpe
   set lpe.no_of_mandatory_courses = (select count(lpme.learning_path_member_id)
                                      from ota_lp_member_enrollments lpme
                                      where lpme.lp_enrollment_id = lpe.lp_enrollment_id);





  FOR lpe_rec IN csr_get_lpe('ACTIVE') LOOP
    l_lp_enrollment_id:= lpe_rec.lp_enrollment_id;
    OPEN GET_SOURCE_FUNCTION_CODE(l_lp_enrollment_id);
    FETCH GET_SOURCE_FUNCTION_CODE INTO L_SOURCE_FUNCTION_CODE;
    IF  GET_SOURCE_FUNCTION_CODE%NOTFOUND THEN
      if is_path_complete(p_lp_enrollment_id => l_lp_enrollment_id) = 'S' THEN
           UPDATE ota_lp_enrollments
	       SET path_status_code = 'COMPLETED'
           , completion_date = to_date('31/12/4712','DD/MM/RRRR')
           WHERE lp_enrollment_id = l_lp_enrollment_id;
      end if;
    END IF;
    CLOSE GET_SOURCE_FUNCTION_CODE;

  end loop;

  FOR lpm_rec IN csr_get_completed_lpms LOOP
    l_lpm_enrollment_id := lpm_rec.lp_member_enrollment_id;
    OPEN csr_get_lpm_completion_date(l_lpm_enrollment_id);
    FETCH csr_get_lpm_completion_date INTO l_completion_date;
    IF csr_get_lpm_completion_date%FOUND THEN
        UPDATE ota_lp_member_enrollments
        SET completion_date = l_completion_date
        WHERE lp_member_enrollment_id = l_lpm_enrollment_id;
    END IF;
    CLOSE  csr_get_lpm_completion_date;
  END LOOP;


  FOR lpe_rec IN csr_get_lpe('COMPLETED') LOOP
    l_lp_enrollment_id := lpe_rec.lp_enrollment_id;
    l_lp_completion_date_old := lpe_rec.completion_date;
    l_lp_object_version_number := lpe_rec.object_version_number;
    OPEN csr_get_lp_completion_info(l_lp_enrollment_id);
    FETCH csr_get_lp_completion_info INTO l_completion_date, l_completed_courses;
    IF csr_get_lp_completion_info%FOUND THEN
        IF to_char(l_lp_completion_date_old,'DD/MM/RRRR')  = '31/12/4712' then
            begin
                 ota_lp_enrollment_api.update_lp_enrollment
                (p_effective_date => trunc(sysdate)
                ,p_lp_enrollment_id => l_lp_enrollment_id
                ,p_path_status_code => 'COMPLETED'
                ,p_no_of_completed_courses => nvl(l_completed_courses,0)
                ,p_completion_date => l_completion_date
                ,p_object_version_number => l_lp_object_version_number);

            exception
            when others then
                l_err_code := SQLCODE;
                l_err_msg  := nvl(substr(SQLERRM,1,2000),'Error When updating Learning Path Enrollments ');
                --p_course_sequence := p_course_sequence-1;
                ota_classic_upgrade.add_log_entry( p_table_name=>'UPDATE_LP_ENROLLMENTS'
                         ,p_source_primary_key  => l_lp_enrollment_id
                         ,p_business_group_id   => l_lp_enrollment_id
                         ,p_object_value        => l_lp_object_version_number
                         ,p_message_text        => l_err_msg
                         ,p_upgrade_id          => p_update_id
                         ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                         ,p_log_type             => LP_LOG_TYPE_E
                         ,p_upgrade_name         => LP_UPGRADE_NAME );--ota_classic_upgrade.get_process_date());



            end;

        else
            UPDATE ota_lp_enrollments
            SET completion_date = l_completion_date
           ,no_of_completed_courses = nvl(l_completed_courses,0)
            WHERE lp_enrollment_id = l_lp_enrollment_id;
        end if;
    END IF;
    CLOSE  csr_get_lp_completion_info;
  END LOOP;

  FOR lpe_rec IN csr_get_lpe('ACTIVE') LOOP
    OPEN csr_get_lp_completion_info(lpe_rec.lp_enrollment_id);
    FETCH csr_get_lp_completion_info INTO l_completion_date, l_completed_courses;
    IF csr_get_lp_completion_info%FOUND THEN
        UPDATE ota_lp_enrollments
        SET no_of_completed_courses = nvl(l_completed_courses,0)
        WHERE lp_enrollment_id = lpe_rec.lp_enrollment_id;
    END IF;
    CLOSE  csr_get_lp_completion_info;
   END LOOP;

   FOR lpe_rec IN csr_get_lpe('CANCELLED') LOOP
    OPEN csr_get_lp_completion_info(lpe_rec.lp_enrollment_id);
    FETCH csr_get_lp_completion_info INTO l_completion_date, l_completed_courses;
    IF csr_get_lp_completion_info%FOUND THEN
        UPDATE ota_lp_enrollments
        SET no_of_completed_courses = nvl(l_completed_courses,0)
        WHERE lp_enrollment_id = lpe_rec.lp_enrollment_id;
    END IF;
    CLOSE  csr_get_lp_completion_info;
   END LOOP;
          /* Path status code for Sutibality matching records should be 'ACTIVE' */
    UPDATE OTA_LP_ENROLLMENTS
    SET PATH_STATUS_CODE = 'ACTIVE',
    COMPLETION_DATE = NULL
    WHERE LP_ENROLLMENT_ID IN (SELECT LPE.LP_ENROLLMENT_ID
                            FROM OTA_LP_ENROLLMENTS LPE, OTA_LEARNING_PATHS LPS
                            WHERE LPE.LEARNING_PATH_ID = LPS.LEARNING_PATH_ID
                            AND LPS.SOURCE_FUNCTION_CODE = 'SUITABILITY' );



  /* Create DFF context for LPE from personal TPS */
  Open  csr_get_attrib_personal_tps;
  Fetch csr_get_attrib_personal_tps into l_flex_val;
  if l_flex_val is not null then
      migrate_dff_contexts('OTA_TRAINING_PLANS','OTA_LP_ENROLLMENTS','ATTRIBUTE','ATTRIBUTE',p_update_id);
  end if;
  Close csr_get_attrib_personal_tps;
  /* Create DFF context for LPME from personal TPM */
  Open  csr_get_attrib_personal_tpm;
  Fetch csr_get_attrib_personal_tpm into l_flex_val;
  if l_flex_val is not null then
      migrate_dff_contexts('OTA_TRAINING_PLAN_MEMBERS','OTA_LP_MEMBER_ENROLLMENTS','ATTRIBUTE','ATTRIBUTE',p_update_id);
   end if;
  Close csr_get_attrib_personal_tpm;
    SELECT nvl(count(1),0)
    INTO l_rows_processed
    FROM ota_lp_enrollments lpe
    WHERE lpe.lp_enrollment_id between p_start_pkid and p_end_pkid;

  p_rows_processed := l_rows_processed;

  ota_classic_upgrade.add_log_entry( p_table_name=> 'DUMMY'
                         ,p_source_primary_key  => p_update_id
                         ,p_business_group_id   => null
                         ,p_object_value        => null
                         ,p_message_text        => 'Done with LP upgrade'
                         ,p_upgrade_id          => p_update_id
                        ,p_process_date       => ota_classic_upgrade.get_process_date(P_UPDATE_ID,LP_UPGRADE_NAME)--trunc(sysdate)
                        ,p_log_type           => LP_LOG_TYPE_N
                        ,p_upgrade_name         => LP_UPGRADE_NAME );

END REMOVE_DATE_REST;

END OTA_TRAINING_PLAN_UPGRADE;






/
