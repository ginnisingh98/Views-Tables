--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_RULES_PKG" as
/* $Header: amslappb.pls 120.1 2005/06/27 05:37:55 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_APPROVAL_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_APPROVAL_FOR_OBJECT in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_TIMEOUT_DAYS_LOW_PRIO in NUMBER,
  X_TIMEOUT_DAYS_STD_PRIO in NUMBER,
  X_TIMEOUT_DAYS_HIGH_PRIO in NUMBER,
  X_TIMEOUT_DAYS_MEDIUM_PRIO in NUMBER,
  X_MGR_APPROVAL_NEEDED_FLAG in VARCHAR2,
  X_PARENT_OWNER_APPROVAL_FLAG in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_APPROVAL_RULES
   where APPROVAL_RULE_ID = X_APPROVAL_RULE_ID   ;
begin
  insert into AMS_APPROVAL_RULES (
    APPROVAL_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ARC_APPROVAL_FOR_OBJECT,
    APPROVAL_TYPE,
    TIMEOUT_DAYS_LOW_PRIO,
    TIMEOUT_DAYS_STD_PRIO,
    TIMEOUT_DAYS_HIGH_PRIO,
    TIMEOUT_DAYS_MEDIUM_PRIO,
    MGR_APPROVAL_NEEDED_FLAG,
    PARENT_OWNER_APPROVAL_FLAG,
    ACTIVITY_TYPE_CODE
  ) VALUES(
    X_APPROVAL_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_ARC_APPROVAL_FOR_OBJECT,
    X_APPROVAL_TYPE,
    X_TIMEOUT_DAYS_LOW_PRIO,
    X_TIMEOUT_DAYS_STD_PRIO,
    X_TIMEOUT_DAYS_HIGH_PRIO,
    X_TIMEOUT_DAYS_MEDIUM_PRIO,
    X_MGR_APPROVAL_NEEDED_FLAG,
    X_PARENT_OWNER_APPROVAL_FLAG,
    X_ACTIVITY_TYPE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_APPROVAL_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_APPROVAL_FOR_OBJECT in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_TIMEOUT_DAYS_LOW_PRIO in NUMBER,
  X_TIMEOUT_DAYS_STD_PRIO in NUMBER,
  X_TIMEOUT_DAYS_HIGH_PRIO in NUMBER,
  X_TIMEOUT_DAYS_MEDIUM_PRIO in NUMBER,
  X_MGR_APPROVAL_NEEDED_FLAG in VARCHAR2,
  X_PARENT_OWNER_APPROVAL_FLAG in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_APPROVAL_RULES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ARC_APPROVAL_FOR_OBJECT = X_ARC_APPROVAL_FOR_OBJECT,
    APPROVAL_TYPE = X_APPROVAL_TYPE,
    TIMEOUT_DAYS_LOW_PRIO = X_TIMEOUT_DAYS_LOW_PRIO,
    TIMEOUT_DAYS_STD_PRIO = X_TIMEOUT_DAYS_STD_PRIO,
    TIMEOUT_DAYS_HIGH_PRIO = X_TIMEOUT_DAYS_HIGH_PRIO,
    TIMEOUT_DAYS_MEDIUM_PRIO = X_TIMEOUT_DAYS_MEDIUM_PRIO,
    MGR_APPROVAL_NEEDED_FLAG = X_MGR_APPROVAL_NEEDED_FLAG,
    PARENT_OWNER_APPROVAL_FLAG = X_PARENT_OWNER_APPROVAL_FLAG,
    ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPROVAL_RULE_ID = X_APPROVAL_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPROVAL_RULE_ID in NUMBER
) is
begin
  delete from AMS_APPROVAL_RULES
  where APPROVAL_RULE_ID = X_APPROVAL_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure  LOAD_ROW(
  X_APPROVAL_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_APPROVAL_FOR_OBJECT in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_TIMEOUT_DAYS_LOW_PRIO in NUMBER,
  X_TIMEOUT_DAYS_STD_PRIO in NUMBER,
  X_TIMEOUT_DAYS_HIGH_PRIO in NUMBER,
  X_TIMEOUT_DAYS_MEDIUM_PRIO in NUMBER,
  X_MGR_APPROVAL_NEEDED_FLAG in VARCHAR2,
  X_PARENT_OWNER_APPROVAL_FLAG in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
    X_Owner              VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_approval_rule_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    AMS_APPROVAL_RULES
  where  APPROVAL_RULE_ID =  X_APPROVAL_RULE_ID;

cursor c_chk_app_exists is
  select 'x'
  from   AMS_APPROVAL_RULES
  where  APPROVAL_RULE_ID = X_APPROVAL_RULE_ID;

cursor c_get_appruleid is
   select AMS_APPROVAL_RULES_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_app_exists;
 fetch c_chk_app_exists into l_dummy_char;
 if  c_chk_app_exists%notfound
 then
    if X_APPROVAL_RULE_ID is null
    then
      open c_get_appruleid;
      fetch c_get_appruleid into l_APPROVAL_RULE_ID;
      close c_get_appruleid;
    else
       l_APPROVAL_RULE_ID := X_APPROVAL_RULE_ID;
    end if;
    l_obj_verno := 1;

    AMS_APPROVAL_RULES_PKG.INSERT_ROW(
    X_ROWID             =>  l_row_id,
  X_APPROVAL_RULE_ID  =>    l_APPROVAL_RULE_ID ,
  X_OBJECT_VERSION_NUMBER =>  l_obj_verno,
  X_ARC_APPROVAL_FOR_OBJECT  =>   X_ARC_APPROVAL_FOR_OBJECT ,
  X_APPROVAL_TYPE  =>  X_APPROVAL_TYPE,
  X_TIMEOUT_DAYS_LOW_PRIO  =>  X_TIMEOUT_DAYS_LOW_PRIO,
  X_TIMEOUT_DAYS_STD_PRIO  =>   X_TIMEOUT_DAYS_STD_PRIO ,
  X_TIMEOUT_DAYS_HIGH_PRIO  =>  X_TIMEOUT_DAYS_HIGH_PRIO,
  X_TIMEOUT_DAYS_MEDIUM_PRIO  =>  X_TIMEOUT_DAYS_MEDIUM_PRIO,
  X_MGR_APPROVAL_NEEDED_FLAG  =>  X_MGR_APPROVAL_NEEDED_FLAG,
  X_PARENT_OWNER_APPROVAL_FLAG  =>   X_PARENT_OWNER_APPROVAL_FLAG ,
  X_ACTIVITY_TYPE_CODE  =>  X_ACTIVITY_TYPE_CODE,
  X_CREATION_DATE     =>  SYSDATE,
    X_CREATED_BY            =>  l_user_id,
    X_LAST_UPDATE_DATE  =>  SYSDATE,
    X_LAST_UPDATED_BY       =>  l_user_id,
    X_LAST_UPDATE_LOGIN =>  0
  );
   close c_chk_app_exists;
else
   close c_chk_app_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    AMS_APPROVAL_RULES_PKG.UPDATE_ROW(
  X_APPROVAL_RULE_ID  =>    x_APPROVAL_RULE_ID ,
  X_OBJECT_VERSION_NUMBER =>  l_obj_verno + 1,
  X_ARC_APPROVAL_FOR_OBJECT  =>   X_ARC_APPROVAL_FOR_OBJECT ,
  X_APPROVAL_TYPE  =>  X_APPROVAL_TYPE,
  X_TIMEOUT_DAYS_LOW_PRIO  =>  X_TIMEOUT_DAYS_LOW_PRIO,
  X_TIMEOUT_DAYS_STD_PRIO  =>   X_TIMEOUT_DAYS_STD_PRIO ,
  X_TIMEOUT_DAYS_HIGH_PRIO  =>  X_TIMEOUT_DAYS_HIGH_PRIO,
  X_TIMEOUT_DAYS_MEDIUM_PRIO  =>  X_TIMEOUT_DAYS_MEDIUM_PRIO,
  X_MGR_APPROVAL_NEEDED_FLAG  =>  X_MGR_APPROVAL_NEEDED_FLAG,
  X_PARENT_OWNER_APPROVAL_FLAG  =>   X_PARENT_OWNER_APPROVAL_FLAG ,
  X_ACTIVITY_TYPE_CODE  =>  X_ACTIVITY_TYPE_CODE,
    X_LAST_UPDATE_DATE  =>  SYSDATE,
    X_LAST_UPDATED_BY       =>  l_user_id,
    X_LAST_UPDATE_LOGIN =>  0
  );
end if;
END LOAD_ROW;

end AMS_APPROVAL_RULES_PKG;

/
