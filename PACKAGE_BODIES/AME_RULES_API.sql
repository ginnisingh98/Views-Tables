--------------------------------------------------------
--  DDL for Package Body AME_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULES_API" AS
/* $Header: amerlapi.pkb 120.1 2005/10/14 04:13 ubhat noship $ */
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
  X_RULE_ID          in  VARCHAR2,
  X_ACTION_PARAMETER in  VARCHAR2,
  X_ACTION_TYPE_NAME in  VARCHAR2,
  X_ACTION_ID        out nocopy NUMBER,
  X_ACTION_TYPE_ID   out nocopy NUMBER,
  X_USAGE_ROWID      out nocopy VARCHAR2,
  X_RULE_COUNT       out nocopy NUMBER,
  X_CURRENT_USAGE_OWNER out nocopy NUMBER,
  X_CURRENT_USAGE_LUD out nocopy VARCHAR2,
  X_CURRENT_USAGE_OVN out nocopy NUMBER
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
 cursor CSR_GET_ACTION
 (
   X_ACTION_TYPE_ID in NUMBER,
   X_PARAMETER      in VARCHAR2
 ) is
   select ACTION_ID from AME_ACTIONS
    where ACTION_TYPE_ID = X_ACTION_TYPE_ID
      and nvl(PARAMETER,'NULL')      = nvl(X_PARAMETER,'NULL')
      and sysdate between START_DATE
      and nvl(END_DATE  - (1/86400), sysdate);
 cursor CSR_GET_CURRENT_USAGE
 (
   X_RULE_ID      in NUMBER,
   X_ACTION_ID    in NUMBER
 ) is
  select ROWID,
         LAST_UPDATED_BY,
         to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         nvl(OBJECT_VERSION_NUMBER,1)
    from AME_ACTION_USAGES
   where RULE_ID   = X_RULE_ID
     and ACTION_ID = X_ACTION_ID
      and sysdate between START_DATE
      and nvl(END_DATE  - (1/86400), sysdate);
 cursor CSR_GET_RULE_COUNT
 (
   X_RULE_ID      in NUMBER
 ) is
  select COUNT(*)
    from AME_RULES
   where RULE_ID = X_RULE_ID;

begin
  X_CURRENT_USAGE_OVN := 1;
  open CSR_GET_ACTION_TYPE_ID (
    X_ACTION_TYPE_NAME
  );
  fetch CSR_GET_ACTION_TYPE_ID into X_ACTION_TYPE_ID;
    if (CSR_GET_ACTION_TYPE_ID%notfound) then
      X_ACTION_TYPE_ID := null;
    end if;
  close CSR_GET_ACTION_TYPE_ID;
  if X_ACTION_TYPE_ID is not null then
    open CSR_GET_ACTION (
      X_ACTION_TYPE_ID,
      X_ACTION_PARAMETER
    );
    fetch CSR_GET_ACTION into X_ACTION_ID;
    if (CSR_GET_ACTION%notfound) then
      X_ACTION_ID := null;
    end if;
    close CSR_GET_ACTION;
  end if;
  if X_ACTION_ID is not null then
    open CSR_GET_RULE_COUNT (
      X_RULE_ID
    );
    fetch CSR_GET_RULE_COUNT into X_RULE_COUNT;
    close CSR_GET_RULE_COUNT;
    if X_AME_INSTALLATION_LEVEL is not null then
      open CSR_GET_CURRENT_USAGE (
        X_RULE_ID,
        X_ACTION_ID
      );
      fetch CSR_GET_CURRENT_USAGE into X_USAGE_ROWID,
        X_CURRENT_USAGE_OWNER,
        X_CURRENT_USAGE_LUD,
        X_CURRENT_USAGE_OVN;
      close CSR_GET_CURRENT_USAGE;
    end if;
  end if;
end KEY_TO_IDS;

procedure VALIDATE_RULE_TYPE (
     X_RULE_TYPE in NUMBER
) is
  invalidRuleTypeException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  begin
    if  (X_RULE_TYPE <> ame_util.authorityRuleType)
        and (X_RULE_TYPE <> ame_util.exceptionRuleType) then
             raise invalidRuleTypeException;
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
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0
                                   ,release_on_commit => true);
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
                          where ((RULE_ID = X_RULE_ID
                          and sysdate < nvl(END_DATE - (1/86400), sysdate + (1/86400)))
                          or (X_AME_INSTALLATION_LEVEL is not null and RULE_KEY = X_RULE_KEY))
         );
  if sql%found then
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
function DO_USAGE_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2)
return boolean as
begin
  return AME_SEED_UTILITY.MERGE_ROW_TEST
    (X_OWNER                     => X_OWNER
    ,X_CURRENT_OWNER             => X_CURRENT_OWNER
    ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
    ,X_CUSTOM_MODE               => null
    );
end DO_USAGE_UPDATE_INSERT;

procedure INSERT_USAGE_ROW (
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
  end if;

end INSERT_USAGE_ROW;

procedure DELETE_ROW (
  X_RULE_ID  in VARCHAR2
) is
begin
  delete from AME_RULES
  where RULE_ID = X_RULE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure UPDATE_USAGE_ROW (
 X_ACTION_USAGE_ROWID             in VARCHAR2,
 X_END_DATE                       in DATE)
 is
begin
  update AME_ACTION_USAGES set
   END_DATE             = X_END_DATE
  where ROWID           = X_ACTION_USAGE_ROWID;
end UPDATE_USAGE_ROW;

function CREATE_RULE_KEY return VARCHAR2 as
  cursor GET_DBID_CURSOR is
    select to_char(DB.DBID)
    from   V$DATABASE DB, V$INSTANCE INSTANCE
    where  upper(DB.NAME) = upper(INSTANCE.INSTANCE_NAME);
    X_DATABASE_ID VARCHAR2(50);
    X_NEW_RULE_KEY AME_RULES.RULE_KEY%TYPE;
    X_RULE_COUNT NUMBER;
    X_RULE_KEY_ID NUMBER;
  begin
    open GET_DBID_CURSOR;
    fetch GET_DBID_CURSOR
    into X_DATABASE_ID;
    if GET_DBID_CURSOR%NOTFOUND then
    -- This case will never happen, since every instance must be linked to a DB
      X_DATABASE_ID := NULL;
    end if;
    close GET_DBID_CURSOR;
    loop
    -- derive RULE_KEY value
      select AME_RULE_KEYS_S.NEXTVAL into X_RULE_KEY_ID from dual;
      X_NEW_RULE_KEY := X_DATABASE_ID ||':'|| X_RULE_KEY_ID;
      select count(*)
        into X_RULE_COUNT
        from AME_RULES
       where upper(RULE_KEY) = upper(X_NEW_RULE_KEY)
         and rownum < 2;
      if X_RULE_COUNT = 0 then
        exit;
      end if;
    end loop;
    return(X_NEW_RULE_KEY);
    exception
    when others then
    ame_util.runtimeException('ame_rules_api',
                         'create_rule_key',
                         sqlcode,
                         sqlerrm);
    raise;
end CREATE_RULE_KEY;

procedure LOAD_ROW (
          X_RULE_ID          in VARCHAR2,
          X_RULE_TYPE        in VARCHAR2,
          X_ACTION_PARAMETER in VARCHAR2,
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_DESCRIPTION      in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2
)
is
  X_ACTION_TYPE_ID NUMBER;
  X_ACTION_ID  NUMBER;
  X_ACTION_ID2 NUMBER;

  X_CREATED_BY NUMBER;
  X_CURRENT_USAGE_LUD VARCHAR2(19);
  X_CURRENT_USAGE_OWNER NUMBER;
  X_CURRENT_USAGE_OVN  NUMBER;
  X_ITEM_CLASS_ID NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_RULE_COUNT NUMBER:= 0;
  X_RULE_KEY ame_rules.rule_key%type;
  X_USAGE_ROWID ROWID;
begin
  X_AME_INSTALLATION_LEVEL := fnd_profile.value('AME_INSTALLATION_LEVEL');
  KEY_TO_IDS (
    X_RULE_ID,
    X_ACTION_PARAMETER,
    X_ACTION_TYPE_NAME,
    X_ACTION_ID,
    X_ACTION_TYPE_ID,
    X_USAGE_ROWID,
    X_RULE_COUNT,
    X_CURRENT_USAGE_OWNER,
    X_CURRENT_USAGE_LUD,
    X_CURRENT_USAGE_OVN
  );

  VALIDATE_RULE_TYPE (
    X_RULE_TYPE
  );

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

   begin
-- the current row was not found insert a new row
   if (X_ACTION_ID is not null) and (X_RULE_COUNT = 0) then
       -- Initialize X_ITEM_CLASS_ID and X_ACTION_ID2
       X_ACTION_ID2    := X_ACTION_ID;
       X_ITEM_CLASS_ID := null;
       X_RULE_KEY      := 'CHANGE_ME';
       -- when target database is at AME11510, populate X_RULE_KEY,
       -- nullify action_id and set X_ITEM_CLASS_ID = 1
       if X_AME_INSTALLATION_LEVEL is not null then
         X_RULE_KEY   := CREATE_RULE_KEY;
         X_ACTION_ID2 := null;
         X_ITEM_CLASS_ID := 1;
       end if;
       INSERT_ROW (
         X_RULE_ID,
         X_RULE_KEY,
         X_RULE_TYPE,
         X_ACTION_ID2,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_DESCRIPTION,
         X_ITEM_CLASS_ID,
         1);
       -- when target database is at AME11510, populate ame_action_usages table
       if X_AME_INSTALLATION_LEVEL is not null then
        -- insert an ame_action_usages row
         if X_USAGE_ROWID is null then
          INSERT_USAGE_ROW (
            X_RULE_ID,
            X_ACTION_ID,
            X_CREATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATE_LOGIN,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            1);
         else
          if DO_USAGE_UPDATE_INSERT
            (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             X_CURRENT_USAGE_OWNER,
             X_LAST_UPDATE_DATE,
             X_CURRENT_USAGE_LUD) then
             UPDATE_USAGE_ROW (
               X_USAGE_ROWID,
               to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
             INSERT_USAGE_ROW (
               X_RULE_ID,
               X_ACTION_ID,
               X_CREATED_BY,
               to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
               X_LAST_UPDATED_BY,
               to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
               X_LAST_UPDATE_LOGIN,
               to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
               X_CURRENT_USAGE_OVN + 1);
           end if;
         end if;
       end if;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_rules_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--

END AME_RULES_API;

/
