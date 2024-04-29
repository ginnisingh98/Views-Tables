--------------------------------------------------------
--  DDL for Package Body PER_STARTUP_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_STARTUP_PERSON_TYPES_PKG" as
/* $Header: pespt01t.pkb 115.21 2003/10/27 07:07:36 skota ship $ */

procedure POPULATE_KEY (
  p_seeded_person_type_key in varchar2,
  p_user_person_type in varchar2,
  p_system_person_type in varchar2) is

  cursor bus_grp is
   select distinct business_group_id
    from  per_person_types;

  cursor person_type is
   select person_type_id
   from per_person_types
   where seeded_person_type_key= p_seeded_person_type_key
   and last_updated_by=1;

l_bus_grp number;
l_user_person_type varchar2(30);
l_system_person_type varchar2(30);
l_updated varchar2(1);
begin
hr_general.g_data_migrator_mode :='Y';

for C1 in bus_grp loop
    l_bus_grp := c1.business_group_id;
    update per_person_types
      set seeded_person_type_key = p_seeded_person_type_key
         ,last_updated_by = 1
         ,last_update_login = 1
         ,created_by =1
         ,last_update_date = sysdate
        where user_person_type = p_user_person_type
     and system_person_type = p_system_person_type
     and business_group_id = l_bus_grp;

if sql%rowcount = 0 then
insert into per_person_types
    (PERSON_TYPE_ID
    ,BUSINESS_GROUP_ID
    ,SEEDED_PERSON_TYPE_KEY
    ,ACTIVE_FLAG
    ,DEFAULT_FLAG
    ,SYSTEM_PERSON_TYPE
    ,USER_PERSON_TYPE
    ,LAST_UPDATED_BY
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN
    ,LAST_UPDATE_DATE
    ,CREATION_DATE)
    Values
    (PER_PERSON_TYPES_S.nextval
    ,C1.business_group_id
    ,p_seeded_person_type_key
    ,'N'
    ,'N'
    ,p_system_person_type
    ,p_user_person_type
    ,1
    ,1
    ,1
    ,sysdate
    ,sysdate);
end if;
end loop;

for c2 in person_type loop

   update per_person_types_tl
   set last_updated_by = 1,
       last_update_login = 1,
       created_by = 1,
       last_update_date = sysdate
   where person_type_id = c2.person_type_id;


   if sql%rowcount = 0 then

       insert into PER_PERSON_TYPES_TL (
       PERSON_TYPE_ID
       ,LANGUAGE
       ,SOURCE_LANG
       ,USER_PERSON_TYPE
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
       ,CREATED_BY
       ,CREATION_DATE
        )select
      c2.person_type_id
      ,l.language_code
      ,userenv('lang')
      ,p_user_person_Type
      ,sysdate
      ,1
      ,1
      ,1
      ,sysdate
      from fnd_languages l
        where L.INSTALLED_FLAG in ('I', 'B');

   end if;
end loop;
hr_general.g_data_migrator_mode :='N';
end;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  X_USER_PERSON_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

begin
hr_general.g_data_migrator_mode :='Y';

  insert into PER_PERSON_TYPES (
   PERSON_TYPE_ID
  ,BUSINESS_GROUP_ID
  ,ACTIVE_FLAG
  ,DEFAULT_FLAG
  ,seeded_person_type_key
  ,SYSTEM_PERSON_TYPE
  ,USER_PERSON_TYPE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,CREATED_BY
  ,CREATION_DATE
   )select
  PER_PERSON_TYPES_S.nextval
 ,business_group_id
 ,'Y'
 ,x_default_flag
 ,x_seeded_person_type_key
 ,x_system_person_type
 ,x_user_person_Type
 ,sysdate
 ,1
 ,1
 ,1
 ,sysdate
 from per_business_groups bg
 where not exists(
   select null
   from per_person_types
   where user_person_type = x_user_person_Type
   and system_person_type = x_system_person_type
   and business_group_id = bg.business_group_id);

  insert into PER_PERSON_TYPES_TL (
  PERSON_TYPE_ID
  ,LANGUAGE
  ,SOURCE_LANG
  ,USER_PERSON_TYPE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,CREATED_BY
  ,CREATION_DATE
   )select
 ppt.person_type_id
 ,l.language_code
 ,userenv('lang')
 ,x_user_person_Type
 ,sysdate
 ,1
 ,1
 ,1
 ,sysdate
 from per_person_types ppt, fnd_languages l
   where L.INSTALLED_FLAG in ('I', 'B')
    and x_seeded_person_type_key = ppt.seeded_person_type_key
    and x_system_person_type = ppt.system_person_type
    and x_user_person_type = ppt.user_person_type
    and not exists (
   	select null
   	from per_person_types_tl
   	where person_type_id = ppt.person_type_id
   	and language = l.language_code);

  insert into PER_STARTUP_PERSON_TYPES_TL (
    seeded_person_type_key,
    USER_PERSON_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    CURRENT_EMP_OR_APL_FLAG,
    CURRENT_EMPLOYEE_FLAG,
    DEFAULT_FLAG,
    SYSTEM_PERSON_TYPE,
    CURRENT_APPLICANT_FLAG,
    LANGUAGE,
    SOURCE_LANG
  ) select
    x_seeded_person_type_key,
    X_USER_PERSON_TYPE,
    SYSDATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_CURRENT_EMP_OR_APL_FLAG,
    X_CURRENT_EMPLOYEE_FLAG,
    X_DEFAULT_FLAG,
    X_SYSTEM_PERSON_TYPE,
    X_CURRENT_APPLICANT_FLAG,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists (
    select null
    from per_startup_person_types_tl
    where seeded_person_type_key = X_SEEDED_PERSON_TYPE_KEY
    and language= l.language_code);

hr_general.g_data_migrator_mode :='N';
end INSERT_ROW;


procedure UPDATE_ROW (
  X_FORCE_MODE in varchar2,
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  X_USER_PERSON_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_count number;
cursor c_ppt is
 select person_type_id from per_person_types
 where SEEDED_PERSON_TYPE_KEY = X_SEEDED_PERSON_TYPE_KEY
  and LAST_UPDATED_BY = 1;

begin
hr_general.g_data_migrator_mode :='Y';

  -- The following update statement always updates the startup person types
  -- Since these rows are seeded rows the who columns are always set accordingly

  update PER_STARTUP_PERSON_TYPES_TL set
    USER_PERSON_TYPE = X_USER_PERSON_TYPE,
    CURRENT_APPLICANT_FLAG = X_CURRENT_APPLICANT_FLAG,
    CURRENT_EMP_OR_APL_FLAG = X_CURRENT_EMP_OR_APL_FLAG,
    CURRENT_EMPLOYEE_FLAG = X_CURRENT_EMPLOYEE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SEEDED_PERSON_TYPE_KEY = X_SEEDED_PERSON_TYPE_KEY
    and userenv('lang') in (LANGUAGE, SOURCE_LANG);

select count(*) into l_count from per_startup_person_types_tl where
  SEEDED_PERSON_TYPE_KEY = X_SEEDED_PERSON_TYPE_KEY
  and language = userenv('lang');

  if l_count =0 then
    raise no_data_found;
  end if;

for C_row in c_ppt loop
  update PER_PERSON_TYPES set
    USER_PERSON_TYPE = X_USER_PERSON_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where person_type_id = c_row.person_type_id
  and last_updated_by = 1;

  update per_person_types_tl set
    USER_PERSON_TYPE = X_USER_PERSON_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where person_type_id = c_row.person_type_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  and last_updated_by = 1;

end loop;
hr_general.g_data_migrator_mode :='N';
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SEEDED_PERSON_TYPE_KEY in VARCHAR2
) is
begin
  delete from PER_STARTUP_PERSON_TYPES_TL
  where SEEDED_PERSON_TYPE_KEY = X_SEEDED_PERSON_TYPE_KEY;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  x_Upload_mode  in varchar2,
  X_SEEDED_PERSON_TYPE_KEY in varchar2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SYSTEM_PERSON_TYPE in VARCHAR2,
  X_CURRENT_APPLICANT_FLAG in VARCHAR2,
  X_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
  X_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
  x_last_update_date in varchar2,
  X_USER_PERSON_TYPE in VARCHAR2
) is
  l_last_update_date date;
  X_ROwID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  l_count number;
  l_force varchar2(1);
begin
  x_last_updated_by := 1;
  x_last_update_login :=1;
  x_created_by :=1;
  x_creation_date := sysdate;
  l_last_update_date := to_date(x_last_update_date,'DD/MM/YYYY');
 if g_firstrun = 'Y' then
   g_firstrun := 'N';
  select count(*) into l_count
    from per_startup_person_types_tl
     where seeded_person_type_key = 'UNKNOWN';
if l_count <> 0 then
     delete from per_startup_person_types_tl;
     data_upgrade;
  end if;
  end if;
if x_upload_mode = 'FORCE' then
l_force :='Y';
else
l_force := 'N';
end if;
  begin
-- The call to validate_upload has been removed so that the update row always
-- gets called. This call will correctly update/insert rows in startup_person
-- types though they have been modified by the user.

    UPDATE_ROW (
      l_force,
      X_SEEDED_PERSON_TYPE_KEY,
      X_DEFAULT_FLAG,
      X_SYSTEM_PERSON_TYPE,
      X_CURRENT_APPLICANT_FLAG,
      X_CURRENT_EMP_OR_APL_FLAG,
      X_CURRENT_EMPLOYEE_FLAG,
      X_USER_PERSON_TYPE,
      l_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN
    );
  exception
    when no_data_found then
      INSERT_ROW (
        X_ROWID,
        X_SEEDED_PERSON_TYPE_KEY,
        X_DEFAULT_FLAG,
        X_SYSTEM_PERSON_TYPE,
        X_CURRENT_APPLICANT_FLAG,
        X_CURRENT_EMP_OR_APL_FLAG,
        X_CURRENT_EMPLOYEE_FLAG,
        X_USER_PERSON_TYPE,
        X_CREATION_DATE,
        X_CREATED_BY,
        l_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN
      );
  end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_SEEDED_PERSON_TYPE_KEY in varchar2,
  X_USER_PERSON_TYPE in VARCHAR2,
  x_last_update_date in varchar2)
is
cursor c_ppt is
 select person_type_id from per_person_types
 where SEEDED_PERSON_TYPE_KEY = X_SEEDED_PERSON_TYPE_KEY
  and LAST_UPDATED_BY = 1;
begin
hr_general.g_data_migrator_mode :='Y';
  -- The following update statement always updates the startup person types
  -- Since these rows are seeded rows the who columns are always set accordingly

  update PER_STARTUP_PERSON_TYPES_TL set
    USER_PERSON_TYPE = X_USER_PERSON_TYPE,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 1,
    LAST_UPDATE_LOGIN =  1,
    SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
  and X_SEEDED_PERSON_TYPE_KEY = SEEDED_PERSON_TYPE_KEY;

for c_row in c_ppt loop

update PER_PERSON_TYPES_TL  set
    USER_PERSON_TYPE = X_USER_PERSON_TYPE,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 1,
    LAST_UPDATE_LOGIN =  1,
    SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
  and person_type_id = c_row.person_type_id
  and last_updated_by = 1;

end loop;
hr_general.g_data_migrator_mode :='N';
end TRANSLATE_ROW;

function validate_upload (
p_Upload_mode           in varchar2,
p_Table_name            in varchar2,
p_new_row_updated_by    in varchar2,
p_new_row_update_date   in date,
p_Table_key_name        in varchar2,
p_table_key_value       in varchar2)
return boolean
is
l_last_updated_by       varchar2(30);
l_last_update_date      date;
l_select_stmt           varchar2(1000);
begin
l_select_stmt := '
select last_updated_by, last_update_date
from ' ||p_table_name||'
where '||p_table_key_name||' = '''||p_table_key_value||'''
';
execute immediate l_select_stmt INTO l_last_updated_by, l_last_update_date;
IF ((p_upload_mode = 'FORCE') OR
      ((l_last_updated_by = 1) AND
      (p_new_row_updated_by <> 1)) OR
      ((l_last_updated_by = p_new_row_updated_by) AND
      (l_last_update_date <= p_new_row_update_date))) then
return true;
else
return false;
end if;

exception
when no_data_found then
  return true;
end validate_upload;

procedure ADD_LANGUAGE
is
begin
hr_general.g_data_migrator_mode :='Y';
  insert into PER_STARTUP_PERSON_TYPES_TL (
    SEEDED_PERSON_TYPE_KEY,
    USER_PERSON_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    CURRENT_EMP_OR_APL_FLAG,
    CURRENT_EMPLOYEE_FLAG,
    DEFAULT_FLAG,
    SYSTEM_PERSON_TYPE,
    CURRENT_APPLICANT_FLAG,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SEEDED_PERSON_TYPE_KEY,
    B.USER_PERSON_TYPE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.CURRENT_EMP_OR_APL_FLAG,
    B.CURRENT_EMPLOYEE_FLAG,
    B.DEFAULT_FLAG,
    B.SYSTEM_PERSON_TYPE,
    B.CURRENT_APPLICANT_FLAG,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_STARTUP_PERSON_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('B','I')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_STARTUP_PERSON_TYPES_TL T
    where T.SEEDED_PERSON_TYPE_KEY = B.SEEDED_PERSON_TYPE_KEY
    and T.LANGUAGE = L.LANGUAGE_CODE);
hr_general.g_data_migrator_mode :='N';
end ADD_LANGUAGE;

/* There is no need to add new person types here. This is a one-off
   Procedure that upgrades the data only once. New system person types
   will be corrected and added when they are just in the ldt. */

PROCEDURE data_upgrade
is
begin
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EXTERNAL'
 ,p_user_person_type       => 'External'
 ,p_system_person_type     => 'OTHER');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'CONTACT'
 ,p_user_person_type       => 'Contact'
 ,p_system_person_type     => 'OTHER');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EMPLOYEE'
 ,p_user_person_type       => 'Employee'
 ,p_system_person_type     => 'EMP');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'APPLICANT'
 ,p_user_person_type       => 'Applicant'
 ,p_system_person_type     => 'APL');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'APL_EX_APL'
 ,p_user_person_type       => 'Applicant and Ex-applicant'
 ,p_system_person_type     => 'APL_EX_APL');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'BENEFICIARY'
 ,p_user_person_type       => 'Beneficiary'
 ,p_system_person_type     => 'BNF');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'DEPENDENT'
 ,p_user_person_type       => 'Dependent'
 ,p_system_person_type     => 'DPNT');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EMP_APL'
 ,p_user_person_type       => 'Employee and Applicant'
 ,p_system_person_type     => 'EMP_APL');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EX_APL'
 ,p_user_person_type       => 'Ex-applicant'
 ,p_system_person_type     => 'EX_APL');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EX_EMP'
 ,p_user_person_type       => 'Ex-employee'
 ,p_system_person_type     => 'EX_EMP');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EX_EMP_APL'
 ,p_user_person_type       => 'Ex-employee and Applicant'
 ,p_system_person_type     => 'EX_EMP_APL');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'FRMR_FMLY_MMBR'
 ,p_user_person_type       => 'Former Family Member'
 ,p_system_person_type     => 'FRMR_FMLY_MMBR');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'FRMR_SPS'
 ,p_user_person_type       => 'Former Spouse'
 ,p_system_person_type     => 'FRMR_SPS');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'PARTICIPANT'
 ,p_user_person_type       => 'Participant'
 ,p_system_person_type     => 'PRTN');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'RETIREE'
 ,p_user_person_type       => 'Retiree'
 ,p_system_person_type     => 'RETIREE');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'SRVNG_FMLY_MMBR'
 ,p_user_person_type       => 'Surviving Family Member'
 ,p_system_person_type     => 'SRVNG_FMLY_MMBR');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'SRVNG_SPS'
 ,p_user_person_type       => 'Surviving Spouse'
 ,p_system_person_type     => 'SRVNG_SPS');
/*PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'EX_CWK'
 ,p_user_person_type       => 'Ex-Contingent Worker'
 ,p_system_person_type     => 'EX_CWK');*/
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'SRVNG_DP'
 ,p_user_person_type       => 'Surviving Domestic Partner'
 ,p_system_person_type     => 'SRVNG_DP');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'SRVNG_DPFM'
 ,p_user_person_type       => 'Surviving Domestic Partner Family Member'
 ,p_system_person_type     => 'SRVNG_DPFM');
PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'FRMR_DP'
 ,p_user_person_type       => 'Former Domestic Partner'
 ,p_system_person_type     => 'FRMR_DP');
/*PER_STARTUP_PERSON_TYPES_PKG.POPULATE_KEY(
  p_seeded_person_type_key => 'CWK'
 ,p_user_person_type       => 'Contingent Worker'
 ,p_system_person_type     => 'CWK');*/
end;
end PER_STARTUP_PERSON_TYPES_PKG;

/
