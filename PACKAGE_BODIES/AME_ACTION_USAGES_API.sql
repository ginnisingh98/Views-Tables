--------------------------------------------------------
--  DDL for Package Body AME_ACTION_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_USAGES_API" AS
/* $Header: ameusapi.pkb 120.5 2006/08/23 13:35:07 pvelugul noship $ */
X_AME_INSTALLATION_LEVEL varchar2(255);
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  X_CREATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure KEY_TO_IDS (
  X_RULE_KEY                 in VARCHAR2,
  X_ACTION_TYPE_NAME         in VARCHAR2,
  X_PARAMETER                in VARCHAR2,
  X_RULE_ID                  out nocopy NUMBER,
  X_ACTION_ID                out nocopy NUMBER,
  X_ACTION_USAGE_ROWID       out nocopy VARCHAR2,
  X_ACTION_TYPE_ID           out nocopy NUMBER,
  X_APPROVAL_GROUP_ID        out nocopy NUMBER,
  X_CURRENT_OWNER            out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN              out nocopy NUMBER,
  X_RULE_ROWID               out nocopy VARCHAR2
) is
  cursor CSR_GET_RULE_ID
 (
   X_RULE_KEY      in VARCHAR2
 ) is
  select RULE_ID
    from AME_RULES
   where RULE_KEY = X_RULE_KEY;
  cursor CSR_GET_ACTION_TYPE_ID
  (
    X_ACTION_TYPE_NAME in VARCHAR2
  ) is
   select ACTION_TYPE_ID
   from   AME_ACTION_TYPES
   where  NAME = X_ACTION_TYPE_NAME
            and sysdate between START_DATE
                         and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_ACTION
 (
   X_ACTION_TYPE_ID in NUMBER,
   X_PARAMETER      in VARCHAR2
 ) is
   select ACTION_ID from AME_ACTIONS
   where ACTION_TYPE_ID = X_ACTION_TYPE_ID
     and nvl(PARAMETER,'NULL')      = nvl(X_PARAMETER,'NULL')

     and sysdate between START_DATE
                   and nvl(END_DATE - (1/86400), sysdate);
  cursor CSR_GET_CURRENT_ACTION_USAGE
  (
    X_RULE_ID        in NUMBER,
    X_ACTION_ID      in NUMBER
  ) is select ROWID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
     from AME_ACTION_USAGES
    where RULE_ID   = X_RULE_ID
      and ACTION_ID = X_ACTION_ID
      and sysdate between START_DATE
                         and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_APPROVAL_GROUP_ID
  (
    X_APPROVAL_GROUP_NAME in VARCHAR2
  ) is
   select APPROVAL_GROUP_ID
   from   AME_APPROVAL_GROUPS
   where  NAME = X_APPROVAL_GROUP_NAME
   and    sysdate between START_DATE
                  and nvl(end_date - (1/86400), sysdate);
  cursor CSR_GET_CURRENT_ACTION_USAGE2
  (
    X_RULE_ID        in NUMBER,
    X_ACTION_ID      in NUMBER
  ) is select ROWID
         from AME_RULES
        where RULE_ID   = X_RULE_ID
          and ACTION_ID = X_ACTION_ID
          and sysdate between START_DATE
                         and nvl(END_DATE  - (1/86400), sysdate);
  L_PARAMETER   VARCHAR2(320);
begin
  X_CURRENT_OVN := 1;
  L_PARAMETER := X_PARAMETER;
  open CSR_GET_ACTION_TYPE_ID (
    X_ACTION_TYPE_NAME
  );
  fetch CSR_GET_ACTION_TYPE_ID into X_ACTION_TYPE_ID;
    if (CSR_GET_ACTION_TYPE_ID%notfound) then
      X_ACTION_TYPE_ID := null;
    end if;
  close CSR_GET_ACTION_TYPE_ID;

  if X_ACTION_TYPE_ID is not null
  then
  --
  -- Determine if the action type is one that is based on groups.
  --
  if X_ACTION_TYPE_NAME in (ame_util.preApprovalTypeName
                           ,ame_util.postApprovalTypeName
                           ,ame_util.groupChainApprovalTypeName
                           ) then
    open CSR_GET_APPROVAL_GROUP_ID(X_PARAMETER);
    fetch CSR_GET_APPROVAL_GROUP_ID into X_APPROVAL_GROUP_ID;
    L_PARAMETER := X_APPROVAL_GROUP_ID;
    if (CSR_GET_APPROVAL_GROUP_ID%notfound) then
      L_PARAMETER := X_PARAMETER;
    end if;
    close CSR_GET_APPROVAL_GROUP_ID;
  end if;
  open CSR_GET_ACTION (
    X_ACTION_TYPE_ID,
    L_PARAMETER
  );
  fetch CSR_GET_ACTION into X_ACTION_ID;
    if (CSR_GET_ACTION%notfound) then
       X_ACTION_ID := null;
    end if;
  close CSR_GET_ACTION;
  end if;

  open CSR_GET_RULE_ID(X_RULE_KEY);
  fetch CSR_GET_RULE_ID into X_RULE_ID;
    if (CSR_GET_RULE_ID%notfound) then
      X_RULE_ID := null;
    end if;
  close CSR_GET_RULE_ID;

  if  (X_ACTION_ID is not null)
  and (X_RULE_ID is not null)
  then
  open CSR_GET_CURRENT_ACTION_USAGE (
    X_RULE_ID,
    X_ACTION_ID
  );
  fetch CSR_GET_CURRENT_ACTION_USAGE into X_ACTION_USAGE_ROWID,
                      X_CURRENT_OWNER, X_CURRENT_LAST_UPDATE_DATE, X_CURRENT_OVN;
    if (CSR_GET_CURRENT_ACTION_USAGE%notfound) then
      X_ACTION_USAGE_ROWID := null;
    end if;
  close CSR_GET_CURRENT_ACTION_USAGE;
  open CSR_GET_CURRENT_ACTION_USAGE2 (
    X_RULE_ID,
    X_ACTION_ID
  );
  fetch CSR_GET_CURRENT_ACTION_USAGE2 into X_RULE_ROWID;
    if (CSR_GET_CURRENT_ACTION_USAGE2%notfound) then
      X_RULE_ROWID := null;
    end if;
  close CSR_GET_CURRENT_ACTION_USAGE2;
  end if;

end KEY_TO_IDS;
procedure VALIDATE_RULE_TYPE (X_RULE_KEY in VARCHAR2) is
  cursor CSR_GET_RULE_TYPE(X_RULE_KEY in VARCHAR2) is
  select RULE_TYPE
    from AME_RULES
   where RULE_KEY = X_RULE_KEY
     and sysdate between START_DATE
           and nvl(END_DATE  - (1/86400), sysdate);
  invalidRuleTypeException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  X_RULE_TYPE  integer;
  begin
    open  CSR_GET_RULE_TYPE(X_RULE_KEY);
    fetch CSR_GET_RULE_TYPE
    into  X_RULE_TYPE;
    if CSR_GET_RULE_TYPE%notfound then
      X_RULE_TYPE := null;
    end if;
    close  CSR_GET_RULE_TYPE;
    if  (X_RULE_TYPE not in (ame_util.authorityRuleType
                            ,ame_util.exceptionRuleType
                            ,ame_util.preListGroupRuleType
                            ,ame_util.postListGroupRuleType
                            )) then
             raise invalidRuleTypeException;
    end if;
  exception
    when invalidRuleTypeException then
    errorCode := -20001;
    errorMessage := 'AME is attempting to upload usages for an invalid rule type. ';
    ame_util.runtimeException(packageNameIn => 'ame_action_usages',
                               routineNameIn => 'validate_rule_type',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when others then
    ame_util.runtimeException('ame_action_usages',
                              'validate_rule_type',
                              sqlcode,
                              sqlerrm);
        raise;
end VALIDATE_RULE_TYPE;
function DO_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  return AME_SEED_UTILITY.MERGE_ROW_TEST
    (X_OWNER                     => X_OWNER
    ,X_CURRENT_OWNER             => X_CURRENT_OWNER
    ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
    ,X_CUSTOM_MODE               => X_CUSTOM_MODE
    );
end DO_UPDATE_INSERT;
procedure CHANGE_RULE_ATTR_USE_COUNT(X_RULE_ID ame_action_usages.rule_id%type) as
  CURSOR CSR_GET_ITEM_IDS
  (
    X_RULE_ID in integer
  ) is
   select ACA.APPLICATION_ID
   from   AME_CALLING_APPS ACA,
          AME_RULE_USAGES ARU
   where  ACA.APPLICATION_ID = ARU.ITEM_ID
     and  ARU.RULE_ID = X_RULE_ID
     and  sysdate between ARU.START_DATE
       and nvl(ARU.END_DATE - (1/86400), sysdate);
begin
  for TEMP_APPLICATION_ID in CSR_GET_ITEM_IDS(X_RULE_ID => X_RULE_ID) loop
    AME_SEED_UTILITY.CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID         => X_RULE_ID
                                 ,X_APPLICATION_ID  => TEMP_APPLICATION_ID.APPLICATION_ID
                                 );
  end loop;
end CHANGE_RULE_ATTR_USE_COUNT;
procedure INSERT_ROW (
 X_RULE_ID                         in NUMBER,
 X_ACTION_ID                       in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
  lockHandle varchar2(500);
  returnValue integer;
begin
  DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_ACTION_USAGES.'||X_RULE_ID||X_ACTION_ID
                             ,lockhandle => lockHandle);
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0
                                   ,release_on_commit => true);
  if returnValue = 0  then
  insert into AME_ACTION_USAGES
  (
   RULE_ID,
   ACTION_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
  ) select
   X_RULE_ID,
   X_ACTION_ID,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER
  from sys.dual
  where not exists (select NULL
                    from AME_ACTION_USAGES
                    where RULE_ID   = X_RULE_ID
                      and ACTION_ID = X_ACTION_ID
                      and sysdate between START_DATE
                      and nvl(END_DATE - (1/86400), sysdate));
  CHANGE_RULE_ATTR_USE_COUNT(X_RULE_ID => X_RULE_ID);
  end if;
end INSERT_ROW;

procedure UPDATE_ROW (
 X_ACTION_USAGE_ROWID             in VARCHAR2,
 X_END_DATE                       in DATE)
 is
begin
  update AME_ACTION_USAGES set
   END_DATE             = X_END_DATE
  where ROWID           = X_ACTION_USAGE_ROWID;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_RULE_ID          in NUMBER,
  X_ACTION_ID        in NUMBER
) is
begin
  delete from AME_ACTION_USAGES
  where RULE_ID   = X_RULE_ID
    and ACTION_ID = X_ACTION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_CREATED_BY                 in NUMBER,
  X_CREATION_DATE              in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATE_LOGIN          in NUMBER,
  X_START_DATE                 in DATE,
  X_END_DATE                   in DATE,
  X_OBJECT_VERSION_NUMBER      in NUMBER
) is
begin
  update AME_ACTION_USAGES
     set CREATED_BY = X_CREATED_BY,
         CREATION_DATE = X_CREATION_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         START_DATE = X_START_DATE,
         END_DATE = X_END_DATE,
         OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
   where ROWID = X_ROWID;
end FORCE_UPDATE_ROW;
procedure LOAD_ROW (
          X_RULE_KEY         in VARCHAR2,
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_PARAMETER        in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_ACTION_ID      NUMBER;
  X_ACTION_TYPE_ID NUMBER;
  X_ACTION_USAGE_ROWID ROWID;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_APPROVAL_GROUP_ID NUMBER;
  X_RULE_ID NUMBER:= null;
  X_CURRENT_OVN NUMBER;
  X_RULE_ROWID ROWID;
begin
  X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
  -- if AME 11510 full patch is not applied return
  if X_AME_INSTALLATION_LEVEL is null then
    return;
  end if;
  VALIDATE_RULE_TYPE (X_RULE_KEY);
-- retrieve information for the current row
  KEY_TO_IDS (
  X_RULE_KEY,
  X_ACTION_TYPE_NAME,
  X_PARAMETER,
  X_RULE_ID,
  X_ACTION_ID,
  X_ACTION_USAGE_ROWID,
  X_ACTION_TYPE_ID,
  X_APPROVAL_GROUP_ID,
  X_CURRENT_OWNER,
  X_CURRENT_LAST_UPDATE_DATE,
  X_CURRENT_OVN,
  X_RULE_ROWID
  );
-- obtain who column details
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
   begin
-- the current row was not found insert a new row
   if (X_ACTION_ID is not null)
      and (X_RULE_ID is not null)
      and (X_ACTION_USAGE_ROWID is null and X_RULE_ROWID is null)
   then
     INSERT_ROW (
       X_RULE_ID,
       X_ACTION_ID,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
     AME_SEED_UTILITY.create_parallel_config
       (X_ACTION_TYPE_ID
       ,X_ACTION_TYPE_NAME
       ,X_ACTION_ID
       ,X_APPROVAL_GROUP_ID
       );
   end if;
-- the current row was found end date the current row
-- insert a row with the same action type id
   if (X_ACTION_USAGE_ROWID is not null)
   then
     if X_CUSTOM_MODE = 'FORCE' then
        FORCE_UPDATE_ROW (
          X_ACTION_USAGE_ROWID,
          X_CREATED_BY,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          X_LAST_UPDATED_BY,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          X_LAST_UPDATE_LOGIN,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
          X_CURRENT_OVN + 1);
     end if;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_action_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

END AME_ACTION_USAGES_API;

/
