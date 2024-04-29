--------------------------------------------------------
--  DDL for Package Body AME_RULES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULES_API2" AS
/* $Header: amereapi.pkb 120.4 2006/07/07 10:14:05 pvelugul noship $ */
duplicateRuleKeyException exception;
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
  X_RULE_KEY         in  VARCHAR2,
  X_ITEM_CLASS_NAME  in  VARCHAR2,
  X_RULE_ID          out nocopy NUMBER,
  X_ITEM_CLASS_ID    out nocopy NUMBER,
  X_CUSTOM_DETECT    out nocopy BOOLEAN
) is
 cursor CSR_GET_ITEM_CLASS_ID
  (
    X_ITEM_CLASS_NAME in VARCHAR2
  ) is
   select ITEM_CLASS_ID
   from   AME_ITEM_CLASSES
   where  NAME = X_ITEM_CLASS_NAME
     and  sysdate between START_DATE
     and  nvl(END_DATE  - (1/86400), sysdate);
 cursor CSR_GET_RULE_ID
 (
   X_RULE_KEY      in VARCHAR2
 ) is
  select RULE_ID, CREATED_BY
    from AME_RULES
   where RULE_KEY = X_RULE_KEY;
X_CREATED_BY number;
X_RULE_ID_2 number;
begin
  open CSR_GET_ITEM_CLASS_ID (
    X_ITEM_CLASS_NAME
  );
  fetch CSR_GET_ITEM_CLASS_ID into X_ITEM_CLASS_ID;
  if (CSR_GET_ITEM_CLASS_ID%notfound) then
    X_ITEM_CLASS_ID := null;
  end if;
  close CSR_GET_ITEM_CLASS_ID;

  open CSR_GET_RULE_ID (
    X_RULE_KEY
  );
-- fetch RULE if there is a match on RULE_KEY
  fetch CSR_GET_RULE_ID into X_RULE_ID,
                             X_CREATED_BY;
    if (CSR_GET_RULE_ID%notfound) then
      X_RULE_ID := null;
    else
      loop
-- detect for custom data only
        if X_CREATED_BY = 1 then
          X_CUSTOM_DETECT := false;
          exit;
        else
          X_CUSTOM_DETECT := true;
        end if;
        fetch CSR_GET_RULE_ID into X_RULE_ID_2,
                                   X_CREATED_BY;
        if (CSR_GET_RULE_ID%notfound) then
          exit;
        end if;
      end loop;
    end if;
  close CSR_GET_RULE_ID;
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

function DO_TL_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CREATED_BY in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2)
return boolean as
begin
    return AME_SEED_UTILITY.TL_MERGE_ROW_TEST
      (X_OWNER                     => X_OWNER
      ,X_CURRENT_OWNER             => X_CURRENT_OWNER
      ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
      ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
      ,X_CUSTOM_MODE               => X_CUSTOM_MODE
      );
end DO_TL_UPDATE_INSERT;

procedure KEY_TO_IDS_2 (
  X_RULE_ID          in          NUMBER,
  X_RULE_KEY         in          VARCHAR2,
  X_ACTION_TYPE_NAME in          VARCHAR2,
  X_PARAMETER        in          VARCHAR2,
  X_ITEM_CLASS_NAME  in          VARCHAR2,
  X_ACTION_ID        out nocopy  NUMBER,
  X_EXISTING_RULE_KEY out nocopy VARCHAR2,
  X_RULE_COUNT       out nocopy  NUMBER,
  X_ITEM_CLASS_ID    out nocopy  NUMBER
) is
 cursor CSR_CHECK_RULE_KEY
 (
   X_RULE_KEY      in VARCHAR2
 ) is
  select RULE_ID
    from AME_RULES
   where RULE_KEY = X_RULE_KEY;
  cursor CSR_RULE_KEY
  (
    X_RULE_ID in NUMBER
  ) is
   select RULE_KEY
   from   AME_RULES
   where  RULE_ID = X_RULE_ID;
 cursor CSR_GET_ITEM_CLASS_ID
  (
    X_ITEM_CLASS_NAME in VARCHAR2
  ) is
   select ITEM_CLASS_ID
   from   AME_ITEM_CLASSES
   where  NAME = X_ITEM_CLASS_NAME
            and sysdate between START_DATE
                         and nvl(END_DATE  - (1/86400), sysdate);
 cursor CSR_GET_RULE_COUNT
 (
   X_RULE_ID   in NUMBER
 ) is
  select COUNT(*)
    from AME_RULES
   where RULE_ID = X_RULE_ID;
 cursor CSR_GET_ACTION_ID is
   select action_id
     from ame_actions        aa,
          ame_action_types   aat
     where aa.parameter = X_PARAMETER
            and aat.name = X_ACTION_TYPE_NAME
            and aat.action_type_id = aa.action_type_id
            and sysdate between aa.start_date and
                  nvl(aa.end_date - (1/86400),sysdate)
            and sysdate between aat.start_date and
                  nvl(aat.end_date - (1/86400),sysdate);
X_RULE_KEY_CHECK NUMBER;
errorCode integer;
errorMessage ame_util.longestStringType;
begin
  if X_AME_INSTALLATION_LEVEL is null then
    X_EXISTING_RULE_KEY:= null;
    X_ITEM_CLASS_ID:= null;
    open CSR_GET_ACTION_ID;
    fetch CSR_GET_ACTION_ID into X_ACTION_ID;
    close CSR_GET_ACTION_ID;
  else
    open CSR_CHECK_RULE_KEY (
      X_RULE_KEY
    );
  -- fetch RULE if there is a match on RULE_KEY
  -- raise an exception
      fetch CSR_CHECK_RULE_KEY into X_RULE_KEY_CHECK;
      if (CSR_CHECK_RULE_KEY%found) then
        raise duplicateRuleKeyException;
      end if;
    close CSR_CHECK_RULE_KEY;
    open CSR_RULE_KEY (
      X_RULE_ID
    );
  -- fetch EXISTING RULE KEY if there is a match on RULE_ID
    fetch CSR_RULE_KEY into X_EXISTING_RULE_KEY;
    if (CSR_RULE_KEY%notfound) then
       X_EXISTING_RULE_KEY := null;
    end if;
    close CSR_RULE_KEY;
  -- get item_class_id
    open CSR_GET_ITEM_CLASS_ID (
      X_ITEM_CLASS_NAME
    );
    fetch CSR_GET_ITEM_CLASS_ID into X_ITEM_CLASS_ID;
    if (CSR_GET_ITEM_CLASS_ID%notfound) then
      X_ITEM_CLASS_ID := null;
    end if;
    close CSR_GET_ITEM_CLASS_ID;
  end if;
  open CSR_GET_RULE_COUNT (
    X_RULE_ID
  );
  fetch CSR_GET_RULE_COUNT
  into X_RULE_COUNT;
  close CSR_GET_RULE_COUNT;
  exception
    when duplicateRuleKeyException then
    errorCode := -20001;
    errorMessage := 'OAM is attempting to upload a duplicate rule key. ';
    ame_util.runtimeException(packageNameIn => 'ame_rules_api2',
                               routineNameIn => 'key_to_ids_2',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise;
    when others then
    ame_util.runtimeException('ame_rules_api2',
                         'key_to_ids_2',
                         sqlcode,
                         sqlerrm);
        raise;
end KEY_TO_IDS_2;

procedure VALIDATE_RULE_TYPE (
     X_RULE_TYPE in NUMBER
) is
  invalidRuleTypeException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  begin
    X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
    if X_AME_INSTALLATION_LEVEL is null then
      if  (X_RULE_TYPE not in (ame_util.authorityRuleType
                              ,ame_util.exceptionRuleType
                              ,ame_util.preListGroupRuleType
                              ,ame_util.postListGroupRuleType
                              )) then
        raise invalidRuleTypeException;
      end if;
    else
      if  (X_RULE_TYPE not in (ame_util.authorityRuleType
                              ,ame_util.exceptionRuleType
                              ,ame_util.preListGroupRuleType
                              ,ame_util.postListGroupRuleType
                              ,ame_util.productionRuleType
                              )) then
        raise invalidRuleTypeException;
      end if;
    end if;
  exception
    when invalidRuleTypeException then
    errorCode := -20001;
    errorMessage := 'OAM is attempting to upload an invalid rule type. ';
    ame_util.runtimeException(packageNameIn => 'ame_rules_api2',
                               routineNameIn => 'validate_rule_type',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when others then
    ame_util.runtimeException('ame_rules_api2',
                         'validate_rule_type',
                         sqlcode,
                         sqlerrm);
        raise;
end VALIDATE_RULE_TYPE;

procedure INSERT_ROW (
 X_RULE_KEY                        in VARCHAR2,
 X_RULE_TYPE                       in NUMBER,
 X_ACTION_ID                       in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_DESCRIPTION                     in VARCHAR2,
 X_ITEM_CLASS_ID                   in NUMBER,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
  lockHandle varchar2(500);
  returnValue integer;
  X_RULE_ID number;
begin

  DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_RULES.'||X_RULE_KEY,lockhandle => lockHandle);
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0, release_on_commit=>true);
  if returnValue = 0  then
    select ame_rules_s.nextval into X_RULE_ID from dual;
    insert into AME_RULES
    (
     RULE_ID,
     RULE_KEY,
     RULE_TYPE,
     ACTION_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     START_DATE,
     END_DATE,
     DESCRIPTION,
     ITEM_CLASS_ID,
     OBJECT_VERSION_NUMBER
    ) select
     X_RULE_ID,
     x_RULE_KEY,
     X_RULE_TYPE,
     X_ACTION_ID,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN,
     X_START_DATE,
     AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
     X_DESCRIPTION,
     X_ITEM_CLASS_ID,
     X_OBJECT_VERSION_NUMBER
     from sys.dual
     where not exists (select NULL
                         from AME_RULES
                        where RULE_KEY = X_RULE_KEY
                         and sysdate between START_DATE
                         and nvl(END_DATE - (1/86400), sysdate));
    if sql%found then
      if not AME_SEED_UTILITY.MLS_ENABLED then
        return;
      end if;
      insert into AME_RULES_TL
        (RULE_ID
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,LANGUAGE
        ,SOURCE_LANG
        ) select X_RULE_ID,
                 X_DESCRIPTION,
                 X_CREATED_BY,
                 X_CREATION_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATE_LOGIN,
                 L.LANGUAGE_CODE,
                 userenv('LANG')
            from FND_LANGUAGES L
           where L.INSTALLED_FLAG in ('I', 'B')
             and not exists (select null
                               from AME_RULES_TL T
                              where T.RULE_ID = X_RULE_ID
                                and T.LANGUAGE = L.LANGUAGE_CODE);
    end if;
  end if;
end INSERT_ROW;

procedure INSERT_ROW_2 (
 X_RULE_ID                         in NUMBER,
 X_RULE_KEY                        in VARCHAR2,
 X_RULE_TYPE                       in NUMBER,
 X_ACTION_ID                       in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_DESCRIPTION                     in VARCHAR2,
 X_ITEM_CLASS_ID                   in NUMBER,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
  lockHandle varchar2(500);
  returnValue integer;
begin
  DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_RULES.'||X_RULE_ID,lockhandle => lockHandle);
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0, release_on_commit=>true);
  if returnValue = 0  then
    insert into AME_RULES
    (
     RULE_ID,
     RULE_KEY,
     RULE_TYPE,
     ACTION_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     START_DATE,
     END_DATE,
     DESCRIPTION,
     ITEM_CLASS_ID,
     OBJECT_VERSION_NUMBER
    ) select
     X_RULE_ID,
     X_RULE_KEY,
     X_RULE_TYPE,
     X_ACTION_ID,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN,
     X_START_DATE,
     AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
     X_DESCRIPTION,
     X_ITEM_CLASS_ID,
     X_OBJECT_VERSION_NUMBER
     from sys.dual
     where not exists (select NULL
                         from AME_RULES
                        where RULE_ID = X_RULE_ID
                          and ((START_DATE - (1/86400)) <= sysdate)
                          and (((END_DATE  - (1/86400)) >= sysdate)
                           or (END_DATE is null)));

    if sql%found then
      if not AME_SEED_UTILITY.MLS_ENABLED then
        return;
      end if;
      insert into AME_RULES_TL
        (RULE_ID
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,LANGUAGE
        ,SOURCE_LANG
        ) select X_RULE_ID,
                 X_DESCRIPTION,
                 X_CREATED_BY,
                 X_CREATION_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATE_LOGIN,
                 L.LANGUAGE_CODE,
                 userenv('LANG')
            from FND_LANGUAGES L
           where L.INSTALLED_FLAG in ('I', 'B')
             and not exists (select null
                               from AME_RULES_TL T
                              where T.RULE_ID = X_RULE_ID
                                and T.LANGUAGE = L.LANGUAGE_CODE);
    end if;
  end if;
end INSERT_ROW_2;

procedure DELETE_ROW (
  X_RULE_KEY in VARCHAR2
) is
begin
  if AME_SEED_UTILITY.MLS_ENABLED then
    delete from AME_RULES_TL
     where RULE_ID in (select RULE_ID
                         from AME_RULES
                        where RULE_KEY = X_RULE_KEY);
  end if;
  delete from AME_RULES
  where RULE_KEY = X_RULE_KEY;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_RULE_KEY         in VARCHAR2,
          X_RULE_ID          in VARCHAR2,
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_PARAMETER        in VARCHAR2,
          X_RULE_TYPE        in VARCHAR2,
          X_DESCRIPTION      in VARCHAR2,
          X_ITEM_CLASS_NAME  in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_ACTION_ID NUMBER      :=null;
  X_CREATED_BY NUMBER;
  X_CUSTOM_DETECT BOOLEAN := false;
  X_EXISTING_RULE_KEY ame_rules.rule_key%type:=null;
  X_ITEM_CLASS_ID NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_RULE_ID_LOAD NUMBER;
  X_RULE_COUNT NUMBER:=0;
  X_RULE_KEY2  VARCHAR2(100);
begin
  X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
  --for pre-AME 11510 do not upload rules if item class does not belong
  --to header or lineitem item class
  if X_AME_INSTALLATION_LEVEL is null then
    if X_ITEM_CLASS_NAME is not null
       and X_ITEM_CLASS_NAME not in(
                                    ame_util.headerItemClassName,
                                    ame_util.lineItemItemClassName
                                   ) then
       return;
    elsif X_ACTION_TYPE_NAME in ('pre-chain-of-authority approvals',
                                 'post-chain-of-authority approvals',
                                 'approval-group chain of authority'
                                ) then
       return;
    end if;
  end if;
  VALIDATE_RULE_TYPE (
    X_RULE_TYPE
  );
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
--the if part of the code executes only for AME 11510
if X_RULE_ID > 0 then
  if X_AME_INSTALLATION_LEVEL is not null then
      X_RULE_ID_LOAD := null;
  -- RULE_ID is POSITIVE - DRIVE OFF RULE_KEY
    KEY_TO_IDS (
      X_RULE_KEY,
      X_ITEM_CLASS_NAME,
      X_RULE_ID_LOAD,
      X_ITEM_CLASS_ID,
      X_CUSTOM_DETECT
    );
  -- the rule row was found matching the RULE_KEY
  -- however it is custom created and will have an '@' sign prepended
  -- insert a new row
  --the following insert does not occur for prior versions of AME 11510
     if AME_SEED_UTILITY.IS_SEED_USER(X_OWNER) and
        (X_RULE_ID_LOAD is not null) and
         X_CUSTOM_DETECT then
         update AME_RULES
         set RULE_KEY = '@' || X_RULE_KEY
         where RULE_KEY = X_RULE_KEY;
         INSERT_ROW (
           X_RULE_KEY,
           X_RULE_TYPE,
           X_ACTION_ID,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_DESCRIPTION,
           X_ITEM_CLASS_ID,
           1);
     end if;
  -- the rule row was not found insert a new row
     if (X_RULE_ID_LOAD is null) then
       INSERT_ROW (
         X_RULE_KEY,
         X_RULE_TYPE,
         X_ACTION_ID,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_DESCRIPTION,
         X_ITEM_CLASS_ID,
         1);
  -- the current row was found end date the current row
  -- do not update or insert
     end if;
   end if;
else --ldt is prior version of AME 11510
-- RULE_ID is NEGATIVE - DRIVE OFF RULE_ID
  KEY_TO_IDS_2 (
    X_RULE_ID,
    X_RULE_KEY,
    X_ACTION_TYPE_NAME,
    X_PARAMETER,
    X_ITEM_CLASS_NAME,
    X_ACTION_ID,
    X_EXISTING_RULE_KEY,
    X_RULE_COUNT,
    X_ITEM_CLASS_ID
  );
-- Populate the Rule Key
   X_RULE_KEY2:= X_RULE_KEY;
-- the current row was not found insert a new row
   if (X_RULE_COUNT = 0) then
     INSERT_ROW_2 (
       X_RULE_ID,
       X_RULE_KEY2,
       X_RULE_TYPE,
       X_ACTION_ID,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_DESCRIPTION,
       X_ITEM_CLASS_ID,
       1);
   end if;
-- a current row is found.
-- the rule key is from an older ldt and
-- must be synchronized with the newer ldt extract from SEED
   if (X_RULE_COUNT > 0) and
      (X_EXISTING_RULE_KEY is not null) and
      (X_EXISTING_RULE_KEY <> X_RULE_KEY) then
       update AME_RULES
       set RULE_KEY = X_RULE_KEY
       where RULE_KEY = X_EXISTING_RULE_KEY
         and RULE_ID  = X_RULE_ID;
   end if;
end if;
exception
    when duplicateRuleKeyException then
      null;
    when others then
    ame_util.runtimeException('ame_rules_api2',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

  procedure TRANSLATE_ROW
    (X_RULE_KEY               in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    X_CURRENT_OWNER            number;
    X_CURRENT_LAST_UPDATE_DATE varchar2(19);
    X_CREATED_BY               varchar2(100);
    X_RULE_ID                  number;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    begin
      select ARUTL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(ARUTL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(ARUTL.CREATED_BY),
             ARU.RULE_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CREATED_BY,
             X_RULE_ID
        from AME_RULES ARU,
             AME_RULES_TL ARUTL
       where ARU.RULE_KEY = X_RULE_KEY
         and sysdate between ARU.START_DATE and nvl(ARU.END_DATE - (1/86400),sysdate)
         and ARUTL.RULE_ID = ARU.RULE_ID
         and ARUTL.LANGUAGE = userenv('LANG');
      if  DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CREATED_BY                => X_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_RULES_TL ARUTL
           set DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where ARUTL.RULE_ID = X_RULE_ID
           and userenv('LANG') in (ARUTL.LANGUAGE,ARUTL.SOURCE_LANG);
      end if;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

END AME_RULES_API2;

/
