--------------------------------------------------------
--  DDL for Package Body AME_CONDITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONDITIONS_API" AS
/* $Header: amecoapi.pkb 120.3 2006/03/15 01:23 pvelugul noship $ */

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
  X_CONDITION_ID     in  VARCHAR2,
  X_ATTRIBUTE_NAME   in  VARCHAR2,
  X_CONDITION_COUNT  out nocopy NUMBER,
  X_ATTRIBUTE_ID     out nocopy NUMBER
) is
  cursor CSR_GET_ATTRIBUTE
  (
    X_ATTRIBUTE_NAME in VARCHAR2
  ) is
   select ATTRIBUTE_ID
   from   AME_ATTRIBUTES
 where NAME = X_ATTRIBUTE_NAME
   and sysdate between START_DATE
   and nvl(END_DATE-(1/86400), sysdate);

  cursor CSR_IS_ATTRIBUTE_SEED
  (
    X_ATTRIBUTE_ID in VARCHAR2
  ) is
   select C.CREATED_BY
   from   AME_ATTRIBUTES C
   where  C.START_DATE =
    (select min(A.START_DATE) from AME_ATTRIBUTES A
      where A.ATTRIBUTE_ID = C.ATTRIBUTE_ID)
   and    C.ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  cursor CSR_GET_CURRENT_CONDITION
  (
    X_CONDITION_ID    in VARCHAR2
  ) is
   select COUNT(*)
   from   AME_CONDITIONS
   where  CONDITION_ID        = X_CONDITION_ID;
  X_CREATED_BY NUMBER;
begin
  open CSR_GET_ATTRIBUTE(
    X_ATTRIBUTE_NAME
    );
  fetch CSR_GET_ATTRIBUTE into X_ATTRIBUTE_ID;
  if (CSR_GET_ATTRIBUTE%notfound) then
     X_ATTRIBUTE_ID := null;
  end if;
  close CSR_GET_ATTRIBUTE;

  if X_ATTRIBUTE_ID is not null then
    open CSR_IS_ATTRIBUTE_SEED(
      X_ATTRIBUTE_ID
      );
    fetch CSR_IS_ATTRIBUTE_SEED into X_CREATED_BY;
    if (CSR_IS_ATTRIBUTE_SEED%notfound) OR (X_CREATED_BY <> AME_SEED_UTILITY.SEED_USER_ID)
      then
      X_CREATED_BY := null;
    end if;
    close CSR_IS_ATTRIBUTE_SEED;
  end if;

  if X_ATTRIBUTE_ID is not null
  then
  open CSR_GET_CURRENT_CONDITION (
    X_CONDITION_ID
  );
  fetch CSR_GET_CURRENT_CONDITION into X_CONDITION_COUNT;
  close CSR_GET_CURRENT_CONDITION;
  end if;
end KEY_TO_IDS;

procedure VALIDATE_CONDITION(
                     X_CONDITION_TYPE in VARCHAR2,
                     X_ATTRIBUTE_NAME in VARCHAR2,
                     X_PARAMETER_ONE  in VARCHAR2,
                     X_PARAMETER_TWO  in VARCHAR2,
                     X_PARAMETER_THREE in VARCHAR2,
                     X_INCLUDE_UPPER_LIMIT in VARCHAR2,
                     X_INCLUDE_LOWER_LIMIT in VARCHAR2
) is
  invalidConditionTypeException exception;
  invalidCondAttrTypeException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  X_ATTRIBUTE_TYPE varchar2(20);
  X_PARAMETER_ONE_DATE date;
  X_PARAMETER_TWO_DATE date;
  X_PARAMETER_ONE_NUMBER number;
  X_PARAMETER_TWO_NUMBER number;
  begin
    select ATTRIBUTE_TYPE
      into X_ATTRIBUTE_TYPE
      from AME_ATTRIBUTES
     where NAME = X_ATTRIBUTE_NAME
		   and sysdate between START_DATE
		     and nvl(END_DATE-(1/86400), sysdate);

    if X_CONDITION_TYPE not in
       (ame_util.ordinaryConditionType , ame_util.exceptionConditionType) then
       raise invalidConditionTypeException;
    end if;

    if X_ATTRIBUTE_TYPE = ame_util.booleanAttributeType then
      if     (X_PARAMETER_ONE not in
             (ame_util.booleanAttributeTrue, ame_util.booleanAttributeFalse))
          or (X_PARAMETER_ONE is null)
          or (X_PARAMETER_TWO is not null)
          or (X_PARAMETER_THREE is not null)
          or (X_INCLUDE_UPPER_LIMIT is not null)
          or (X_INCLUDE_LOWER_LIMIT is not null) then
         errorMessage :=
         'OAM is attempting to upload an invalid boolean attribute condition.';
         raise invalidCondAttrTypeException;
      end if;
    end if;

    if X_ATTRIBUTE_TYPE = ame_util.numberAttributeType then
       if    (X_INCLUDE_LOWER_LIMIT is not null
             and (X_INCLUDE_LOWER_LIMIT not in
             (ame_util.booleanTrue,ame_util.booleanFalse)))
          or (X_INCLUDE_UPPER_LIMIT is not null
             and (X_INCLUDE_UPPER_LIMIT not in
             (ame_util.booleanTrue,ame_util.booleanFalse))) then
         errorMessage :=
         'OAM is attempting to upload an invalid number attribute condition.';
         raise invalidCondAttrTypeException;
       end if;
       if X_PARAMETER_ONE is not null then
         select to_number(X_PARAMETER_ONE)
           into X_PARAMETER_ONE_NUMBER
           from dual;
       end if;
       if X_PARAMETER_TWO is not null then
         select to_number(X_PARAMETER_TWO)
           into X_PARAMETER_TWO_NUMBER
           from dual;
       end if;
    end if;

    if X_ATTRIBUTE_TYPE = ame_util.currencyAttributeType then
       if  (X_INCLUDE_LOWER_LIMIT is not null
             and (X_INCLUDE_LOWER_LIMIT not in
                 (ame_util.booleanTrue,ame_util.booleanFalse)))
          or (X_INCLUDE_UPPER_LIMIT is not null
             and (X_INCLUDE_UPPER_LIMIT not in
                 (ame_util.booleanTrue,ame_util.booleanFalse)))
          or X_PARAMETER_THREE is null then
         errorMessage :=
         'OAM is attempting to upload an invalid currency attribute condition.';
         raise invalidCondAttrTypeException;
       end if;
       if X_PARAMETER_ONE is not null then
         select to_number(X_PARAMETER_ONE)
           into X_PARAMETER_ONE_NUMBER
           from dual;
       end if;
       if X_PARAMETER_TWO is not null then
         select to_number(X_PARAMETER_TWO)
           into X_PARAMETER_TWO_NUMBER
           from dual;
       end if;
    end if;

    if X_ATTRIBUTE_TYPE = ame_util.dateAttributeType then
       if    (X_INCLUDE_LOWER_LIMIT is not null
             and (X_INCLUDE_LOWER_LIMIT not in
                 (ame_util.booleanTrue,ame_util.booleanFalse)))
          or (X_INCLUDE_UPPER_LIMIT is not null
             and (X_INCLUDE_UPPER_LIMIT not in
                 (ame_util.booleanTrue,ame_util.booleanFalse))) then
         errorMessage :=
         'OAM is attempting to upload an invalid date attribute condition.';
         raise invalidCondAttrTypeException;
       end if;
       if X_PARAMETER_ONE is not null then
          select to_date(X_PARAMETER_ONE,'YYYY:MM:DD:HH24:MI:SS')
            into X_PARAMETER_ONE_DATE
            from dual;
       end if;
       if X_PARAMETER_TWO is not null then
          select to_date(X_PARAMETER_TWO,'YYYY:MM:DD:HH24:MI:SS')
            into X_PARAMETER_TWO_DATE
            from dual;
       end if;
    end if;

    if X_ATTRIBUTE_TYPE = ame_util.stringAttributeType then
       if    (X_PARAMETER_ONE is not null)
          or (X_PARAMETER_TWO is not null)
          or (X_PARAMETER_THREE is not null)
          or (X_INCLUDE_LOWER_LIMIT is not null)
          or (X_INCLUDE_UPPER_LIMIT is not null) then
         errorMessage :=
         'OAM is attempting to upload an invalid string attribute condition.';
         raise invalidCondAttrTypeException;
       end if;
    end if;
  exception
    when invalidConditionTypeException then
    errorMessage :=
    'OAM is attempting to upload an invalid condition type.';
    errorCode := -20001;
    ame_util.runtimeException(packageNameIn => 'ame_conditions_api',
                               routineNameIn => 'validate_condition',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when invalidCondAttrTypeException then
    errorCode := -20001;
    ame_util.runtimeException(packageNameIn => 'ame_conditions_api',
                               routineNameIn => 'validate_condition',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when invalid_number then
    errorMessage :=
    'OAM is attempting to upload an invalid number or currency attribute condition.';
    errorCode := -20001;
    ame_util.runtimeException(packageNameIn => 'ame_conditions_api',
                               routineNameIn => 'validate_condition',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);

    when others then
    ame_util.runtimeException('ame_conditions_api',
                         'validate_condition',
                         sqlcode,
                         sqlerrm);
    raise;
end VALIDATE_CONDITION;

procedure INSERT_ROW (
 X_CONDITION_ID                    in NUMBER,
 X_CONDITION_KEY                   in VARCHAR2,
 X_CONDITION_TYPE                  in VARCHAR2,
 X_ATTRIBUTE_ID                    in NUMBER,
 X_PARAMETER_ONE                   in VARCHAR2,
 X_PARAMETER_TWO                   in VARCHAR2,
 X_PARAMETER_THREE                 in VARCHAR2,
 X_INCLUDE_UPPER_LIMIT             in VARCHAR2,
 X_INCLUDE_LOWER_LIMIT             in VARCHAR2,
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
  if X_AME_INSTALLATION_LEVEL is not null then
    DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_CONDITIONS.'||X_CONDITION_ID,lockhandle => lockHandle);
  else
    DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_CONDITIONS.'||X_CONDITION_ID,lockhandle => lockHandle);
  end if;
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0,release_on_commit => true);
  if returnValue = 0  then
    insert into AME_CONDITIONS
    (
      CONDITION_ID,
      CONDITION_KEY,
      CONDITION_TYPE,
      ATTRIBUTE_ID,
      PARAMETER_ONE,
      PARAMETER_TWO,
      PARAMETER_THREE,
      INCLUDE_UPPER_LIMIT,
      INCLUDE_LOWER_LIMIT,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      START_DATE,
      END_DATE,
      OBJECT_VERSION_NUMBER
    ) select
     X_CONDITION_ID,
     X_CONDITION_KEY,
     X_CONDITION_TYPE,
     X_ATTRIBUTE_ID,
     X_PARAMETER_ONE,
     X_PARAMETER_TWO,
     X_PARAMETER_THREE,
     X_INCLUDE_UPPER_LIMIT,
     X_INCLUDE_LOWER_LIMIT,
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
                       from AME_CONDITIONS
                          where ((CONDITION_ID = X_CONDITION_ID
                          and sysdate < nvl(END_DATE - (1/86400), sysdate + (1/86400)))
                          or (X_AME_INSTALLATION_LEVEL is not null and CONDITION_KEY = X_CONDITION_KEY))
         );
  end if;
end INSERT_ROW;

procedure DELETE_ROW (
  X_CONDITION_ID in NUMBER
) is
begin
  delete from AME_CONDITIONS
  where CONDITION_ID = X_CONDITION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

function CREATE_CONDITION_KEY return VARCHAR2 as
    cursor GET_DBID_CURSOR is
      select to_char(DB.DBID)
      from   V$DATABASE DB,
             V$INSTANCE INSTANCE
      where  upper(DB.NAME) = upper(INSTANCE.INSTANCE_NAME);
      X_DATABASE_ID VARCHAR2(50);
      X_NEW_CONDITION_KEY AME_CONDITIONS.CONDITION_KEY%TYPE;
      X_CONDITION_COUNT NUMBER;
      X_CONDITION_KEY_ID NUMBER;
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
      -- derive CONDITION_KEY value
        select AME_CONDITION_KEYS_S.NEXTVAL into X_CONDITION_KEY_ID from dual;
      X_NEW_CONDITION_KEY := X_DATABASE_ID ||':'|| X_CONDITION_KEY_ID;
      select count(*)
        into X_CONDITION_COUNT
        from AME_CONDITIONS
       where upper(CONDITION_KEY) = upper(X_NEW_CONDITION_KEY)
         and rownum < 2;
      if X_CONDITION_COUNT = 0 then
        exit;
      end if;
      end loop;
      return(X_NEW_CONDITION_KEY);
      exception
      when others then
      ame_util.runtimeException('ame_conditions_api',
                              'create_condition_key',
                              sqlcode,
                              sqlerrm);
      raise;
end CREATE_CONDITION_KEY;

procedure LOAD_ROW (
          X_CONDITION_ID        in VARCHAR2,
          X_CONDITION_TYPE      in VARCHAR2,
          X_ATTRIBUTE_NAME      in VARCHAR2,
          X_PARAMETER_ONE       in VARCHAR2,
          X_PARAMETER_TWO       in VARCHAR2,
          X_PARAMETER_THREE     in VARCHAR2,
          X_INCLUDE_UPPER_LIMIT in VARCHAR2,
          X_INCLUDE_LOWER_LIMIT in VARCHAR2,
          X_OWNER               in VARCHAR2,
          X_LAST_UPDATE_DATE    in VARCHAR2
)
is
  X_ATTRIBUTE_ID       NUMBER;
  X_CONDITION_COUNT    NUMBER :=0;
  X_CONDITION_KEY      VARCHAR2(100);
  X_CREATED_BY         NUMBER;
  X_LAST_UPDATED_BY    NUMBER;
  X_LAST_UPDATE_LOGIN  NUMBER;
begin
  -- Check whether the target database is at AME11510 or not
  X_AME_INSTALLATION_LEVEL:=fnd_profile.value('AME_INSTALLATION_LEVEL');
  KEY_TO_IDS (
    X_CONDITION_ID,
    X_ATTRIBUTE_NAME,
    X_CONDITION_COUNT,
    X_ATTRIBUTE_ID
  );
  VALIDATE_CONDITION(
    X_CONDITION_TYPE,
    X_ATTRIBUTE_NAME,
    X_PARAMETER_ONE,
    X_PARAMETER_TWO,
    X_PARAMETER_THREE,
    X_INCLUDE_UPPER_LIMIT,
    X_INCLUDE_LOWER_LIMIT
  );
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
   begin
-- the current row was not found insert a new row
   if (X_ATTRIBUTE_ID is not null) and (X_CONDITION_COUNT = 0) then
     if X_AME_INSTALLATION_LEVEL is not null then
       X_CONDITION_KEY := CREATE_CONDITION_KEY;
     else
       X_CONDITION_KEY := 'CHANGE_ME';
     end if;
     INSERT_ROW (
       X_CONDITION_ID,
       X_CONDITION_KEY,
       X_CONDITION_TYPE,
       X_ATTRIBUTE_ID,
       X_PARAMETER_ONE,
       X_PARAMETER_TWO,
       X_PARAMETER_THREE,
       X_INCLUDE_UPPER_LIMIT,
       X_INCLUDE_LOWER_LIMIT,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
   end if;
  -- the current row was found end date the current row
  -- do not update or insert.
  end;
exception
    when others then
    ame_util.runtimeException('ame_conditions_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--
END AME_CONDITIONS_API;

/
