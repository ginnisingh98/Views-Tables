--------------------------------------------------------
--  DDL for Package Body AMS_STATUS_ORDER_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_STATUS_ORDER_RULES_PKG" as
/* $Header: amslstsb.pls 115.4 2002/11/16 01:44:37 dbiswas ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_STATUS_ORDER_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_STATUS_TYPE in VARCHAR2,
  X_CURRENT_STATUS_CODE in VARCHAR2,
  X_NEXT_STATUS_CODE in VARCHAR2,
  X_SHOW_IN_LOV_FLAG in VARCHAR2,
  X_THEME_APPROVAL_FLAG in VARCHAR2,
  X_BUDGET_APPROVAL_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER DEFAULT '530'
) is
  cursor C is select ROWID from AMS_STATUS_ORDER_RULES
    where STATUS_ORDER_RULE_ID = X_STATUS_ORDER_RULE_ID    ;
begin
  insert into AMS_STATUS_ORDER_RULES (
    STATUS_ORDER_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    SYSTEM_STATUS_TYPE,
    CURRENT_STATUS_CODE,
    NEXT_STATUS_CODE,
    SHOW_IN_LOV_FLAG,
    THEME_APPROVAL_FLAG,
    BUDGET_APPROVAL_FLAG,
    APPLICATION_ID
  ) values
  ( X_STATUS_ORDER_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_SYSTEM_STATUS_TYPE,
    X_CURRENT_STATUS_CODE,
    X_NEXT_STATUS_CODE,
    X_SHOW_IN_LOV_FLAG,
    X_THEME_APPROVAL_FLAG,
    X_BUDGET_APPROVAL_FLAG,
    X_APPLICATION_ID
);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_STATUS_ORDER_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_STATUS_TYPE in VARCHAR2,
  X_CURRENT_STATUS_CODE in VARCHAR2,
  X_NEXT_STATUS_CODE in VARCHAR2,
  X_SHOW_IN_LOV_FLAG in VARCHAR2,
  X_THEME_APPROVAL_FLAG in VARCHAR2,
  X_BUDGET_APPROVAL_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER DEFAULT '530'
) is
begin
  update AMS_STATUS_ORDER_RULES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SYSTEM_STATUS_TYPE = X_SYSTEM_STATUS_TYPE,
    CURRENT_STATUS_CODE = X_CURRENT_STATUS_CODE,
    NEXT_STATUS_CODE = X_NEXT_STATUS_CODE,
    SHOW_IN_LOV_FLAG = X_SHOW_IN_LOV_FLAG,
    THEME_APPROVAL_FLAG = X_THEME_APPROVAL_FLAG,
    BUDGET_APPROVAL_FLAG = X_BUDGET_APPROVAL_FLAG,
    STATUS_ORDER_RULE_ID = X_STATUS_ORDER_RULE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    APPLICATION_ID = X_APPLICATION_ID
  where STATUS_ORDER_RULE_ID = X_STATUS_ORDER_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_ORDER_RULE_ID in NUMBER
) is
begin
  delete from AMS_STATUS_ORDER_RULES
  where STATUS_ORDER_RULE_ID = X_STATUS_ORDER_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure  LOAD_ROW(
  X_STATUS_ORDER_RULE_ID  in NUMBER,
  X_SYSTEM_STATUS_TYPE    in VARCHAR2,
  X_CURRENT_STATUS_CODE   in VARCHAR2,
  X_NEXT_STATUS_CODE      in VARCHAR2,
  X_SHOW_IN_LOV_FLAG      in VARCHAR2,
  X_THEME_APPROVAL_FLAG   in VARCHAR2,
  X_BUDGET_APPROVAL_FLAG  in VARCHAR2,
  X_Owner                    VARCHAR2,
  X_APPLICATION_ID in NUMBER DEFAULT '530'
  ) is
  l_user_id     number := 0;
  l_obj_verno   number;
  l_dummy_char  varchar2(1);
  l_row_id      varchar2(100);
  l_sts_id      number;

cursor  c_obj_verno is
  select  object_version_number
  from    AMS_STATUS_ORDER_RULES
  where   status_order_rule_id =  X_STATUS_ORDER_RULE_ID;

cursor c_chk_sts_exists is
  select 'x'
  from   AMS_STATUS_ORDER_RULES
  where  status_order_rule_id = X_STATUS_ORDER_RULE_ID;

cursor c_get_stsid is
   select ams_status_order_rules_s.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_sts_exists;
 fetch c_chk_sts_exists into l_dummy_char;
 if c_chk_sts_exists%notfound
 then
    close c_chk_sts_exists;

    if X_STATUS_ORDER_RULE_ID is null then
        open c_get_stsid;
        fetch c_get_stsid into l_sts_id;
        close c_get_stsid;
    else
        l_sts_id := X_STATUS_ORDER_RULE_ID ;
    end if ;

    l_obj_verno := 1;

 AMS_STATUS_ORDER_RULES_PKG.INSERT_ROW (
  X_ROWID                       => l_row_id ,
  X_STATUS_ORDER_RULE_ID        => l_sts_id,
  X_OBJECT_VERSION_NUMBER       => l_obj_verno,
  X_SYSTEM_STATUS_TYPE          => X_SYSTEM_STATUS_TYPE,
  X_CURRENT_STATUS_CODE         => X_CURRENT_STATUS_CODE,
  X_NEXT_STATUS_CODE            => X_NEXT_STATUS_CODE,
  X_SHOW_IN_LOV_FLAG            => X_SHOW_IN_LOV_FLAG,
  X_THEME_APPROVAL_FLAG         => X_THEME_APPROVAL_FLAG,
  X_BUDGET_APPROVAL_FLAG        => X_BUDGET_APPROVAL_FLAG,
  X_CREATION_DATE               => SYSDATE,
  X_CREATED_BY                  => l_user_id,
  X_LAST_UPDATE_DATE            => SYSDATE,
  X_LAST_UPDATED_BY             => l_user_id,
  X_LAST_UPDATE_LOGIN           => 0,
  X_APPLICATION_ID		=> X_APPLICATION_ID
) ;

else
   close c_chk_sts_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

AMS_STATUS_ORDER_RULES_PKG.UPDATE_ROW(
    X_STATUS_ORDER_RULE_ID		  =>  X_STATUS_ORDER_RULE_ID,
    X_OBJECT_VERSION_NUMBER       => l_obj_verno + 1,
    X_SYSTEM_STATUS_TYPE          => X_SYSTEM_STATUS_TYPE,
    X_CURRENT_STATUS_CODE         => X_CURRENT_STATUS_CODE,
    X_NEXT_STATUS_CODE            => X_NEXT_STATUS_CODE,
    X_SHOW_IN_LOV_FLAG            => X_SHOW_IN_LOV_FLAG,
    X_THEME_APPROVAL_FLAG         => X_THEME_APPROVAL_FLAG,
    X_BUDGET_APPROVAL_FLAG        => X_BUDGET_APPROVAL_FLAG,
    X_LAST_UPDATE_DATE            => SYSDATE,
    X_LAST_UPDATED_BY             => l_user_id,
    X_LAST_UPDATE_LOGIN           => 0,
    X_APPLICATION_ID		  => X_APPLICATION_ID
  );
end if;

END LOAD_ROW ;

end AMS_STATUS_ORDER_RULES_PKG;

/
