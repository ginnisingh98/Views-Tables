--------------------------------------------------------
--  DDL for Package Body AME_ACTION_TYPE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_TYPE_USAGES_API" AS
/* $Header: amecuapi.pkb 120.2 2005/10/14 04:12:33 ubhat noship $ */
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
  X_ACTION_TYPE_NAME in VARCHAR2,
  X_RULE_TYPE        in VARCHAR2,
  X_ACTION_USAGE_ROWID out nocopy VARCHAR2,
  X_ACTION_TYPE_ID   out nocopy NUMBER,
  X_CURRENT_OWNER    out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN out nocopy NUMBER
) is
  cursor CSR_GET_ACTION_TYPE_ID
  (
    X_ACTION_TYPE_NAME in VARCHAR2
  ) is
   select ACTION_TYPE_ID
   from   AME_ACTION_TYPES
   where  NAME = X_ACTION_TYPE_NAME
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_CURRENT_ACTION_USAGE
  (
    X_ACTION_TYPE_ID in NUMBER,
    X_RULE_TYPE      in VARCHAR2
  ) is select ROWID,
              LAST_UPDATED_BY,
              to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
              nvl(OBJECT_VERSION_NUMBER,1)
         from AME_ACTION_TYPE_USAGES
    where ACTION_TYPE_ID = X_ACTION_TYPE_ID
      and RULE_TYPE      = X_RULE_TYPE
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);
begin
  X_CURRENT_OVN := 1;
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
  open CSR_GET_CURRENT_ACTION_USAGE (
    X_ACTION_TYPE_ID,
    X_RULE_TYPE
  );
  fetch CSR_GET_CURRENT_ACTION_USAGE into X_ACTION_USAGE_ROWID,
                                          X_CURRENT_OWNER,
                                          X_CURRENT_LAST_UPDATE_DATE,
                                          X_CURRENT_OVN;
    if (CSR_GET_CURRENT_ACTION_USAGE%notfound) then
      X_ACTION_USAGE_ROWID := null;
    end if;
  close CSR_GET_CURRENT_ACTION_USAGE;
  end if;
end KEY_TO_IDS;
function DO_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2)
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
procedure VALIDATE_RULE_TYPE (
     X_RULE_TYPE in NUMBER
) is
  invalidRuleTypeException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  begin
  --ame_util.productionRuleType is not a valid rule type for 1159 ame.
      if  (X_RULE_TYPE <> ame_util.authorityRuleType)
      and (X_RULE_TYPE <> ame_util.exceptionRuleType)
      and (X_RULE_TYPE <> ame_util.listModRuleType)
      and (X_RULE_TYPE <> ame_util.substitutionRuleType)
      and (X_RULE_TYPE <> ame_util.preListGroupRuleType)
      and (X_RULE_TYPE <> ame_util.postListGroupRuleType)
      and (
           (X_RULE_TYPE <> ame_util.productionRuleType
            and X_AME_INSTALLATION_LEVEL is not null)
          or (X_AME_INSTALLATION_LEVEL is null)
         ) then
       raise invalidRuleTypeException;
      end if;
  exception
    when invalidRuleTypeException then
    errorCode := -20001;
    errorMessage := 'OAM is attempting to upload an invalid rule type. ';
    ame_util.runtimeException(packageNameIn => 'ame_action_type_usages_api',
                               routineNameIn => 'validate_rule_type',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when others then
    ame_util.runtimeException('ame_action_type_usages_api',
                         'validate_rule_type',
                         sqlcode,
                         sqlerrm);
        raise;
end VALIDATE_RULE_TYPE;
procedure INSERT_ROW (
 X_ACTION_TYPE_ID                  in NUMBER,
 X_RULE_TYPE                       in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER
 )
 is
begin
  insert into AME_ACTION_TYPE_USAGES
  (
   ACTION_TYPE_ID,
   RULE_TYPE,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
  ) values (
   X_ACTION_TYPE_ID,
   X_RULE_TYPE,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);
end INSERT_ROW;

procedure UPDATE_ROW (
 X_ACTION_USAGE_ROWID             in VARCHAR2,
 X_END_DATE                       in DATE)
 is
begin
  update AME_ACTION_TYPE_USAGES set
   END_DATE            = X_END_DATE
  where ROWID          = X_ACTION_USAGE_ROWID;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_TYPE_ID in NUMBER,
  X_RULE_TYPE      in NUMBER
) is
begin
  delete from AME_ACTION_TYPE_USAGES
  where ACTION_TYPE_ID =   X_ACTION_TYPE_ID
    and RULE_TYPE      =   X_RULE_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_RULE_TYPE        in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_ACTION_USAGE_ROWID ROWID;
  X_ACTION_TYPE_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_CURRENT_OVN NUMBER;
begin
--find current ame installation level
 X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
-- retrieve information for the current row
  KEY_TO_IDS (
    X_ACTION_TYPE_NAME,
    X_RULE_TYPE,
    X_ACTION_USAGE_ROWID,
    X_ACTION_TYPE_ID,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_CURRENT_OVN
  );
  VALIDATE_RULE_TYPE (
    X_RULE_TYPE
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
   if X_ACTION_TYPE_ID is not null then
     if X_ACTION_USAGE_ROWID is null then
       INSERT_ROW (
         X_ACTION_TYPE_ID,
         X_RULE_TYPE,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         1);
     else
-- the current row was found end date the current row
-- insert a row with the same action type id
       if DO_UPDATE_INSERT
          (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE,
           X_CUSTOM_MODE) then
         UPDATE_ROW (
           X_ACTION_USAGE_ROWID,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
         INSERT_ROW (
           X_ACTION_TYPE_ID,
           X_RULE_TYPE,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_CURRENT_OVN + 1);
       end if;
     end if;
   else
-- nothing was found do not process
     null;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_action_types_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
END AME_ACTION_TYPE_USAGES_API;

/
