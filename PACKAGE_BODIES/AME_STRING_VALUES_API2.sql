--------------------------------------------------------
--  DDL for Package Body AME_STRING_VALUES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_STRING_VALUES_API2" AS
/* $Header: amesaapi.pkb 120.1 2005/10/14 04:14 ubhat noship $ */

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
  X_CONDITION_KEY       in  VARCHAR2,
  X_STRING_VALUE        in  VARCHAR2,
  X_CONDITION_ID        out nocopy NUMBER,
  X_STRING_VALUE_ROW    out nocopy VARCHAR2
) is
   cursor CSR_GET_CONDITION_ID
   (
     X_CONDITION_KEY    in VARCHAR2
   ) is
    select CONDITION_ID
    from   AME_CONDITIONS
    where  CONDITION_KEY        = X_CONDITION_KEY;

   cursor CSR_GET_STRING_VALUE_ROW
   (
      X_CONDITION_ID  in NUMBER,
      X_STRING_VALUE  in VARCHAR2
   ) is
    select 'FOUND'
    from   AME_STRING_VALUES
    where  CONDITION_ID = X_CONDITION_ID
      and  STRING_VALUE = X_STRING_VALUE;
begin
  open CSR_GET_CONDITION_ID (
    X_CONDITION_KEY
  );
  fetch CSR_GET_CONDITION_ID into X_CONDITION_ID;
  if (CSR_GET_CONDITION_ID%notfound) then
     X_CONDITION_ID := null;
  end if;
  close CSR_GET_CONDITION_ID;

  if X_CONDITION_ID is not null then
    open CSR_GET_STRING_VALUE_ROW (
      X_CONDITION_ID, X_STRING_VALUE
      );
    fetch CSR_GET_STRING_VALUE_ROW into X_STRING_VALUE_ROW;
      if (CSR_GET_STRING_VALUE_ROW%notfound) then
        X_STRING_VALUE_ROW := 'NOTFOUND';
      end if;
    close CSR_GET_STRING_VALUE_ROW;
  end if;
end KEY_TO_IDS;

procedure KEY_TO_IDS_2 (
  X_CONDITION_ID        in  NUMBER,
  X_STRING_VALUE        in  VARCHAR2,
  X_STRING_VALUE_COUNT  out nocopy NUMBER
) is
   cursor CSR_GET_STRING_VALUE_COUNT
   (
      X_CONDITION_ID  in NUMBER,
      X_STRING_VALUE  in VARCHAR2
   ) is
    select COUNT(*)
    from   AME_STRING_VALUES
    where  CONDITION_ID = X_CONDITION_ID
      and  STRING_VALUE = X_STRING_VALUE;
begin
  if X_CONDITION_ID is not null then
    open CSR_GET_STRING_VALUE_COUNT (X_CONDITION_ID, X_STRING_VALUE);
    fetch CSR_GET_STRING_VALUE_COUNT into X_STRING_VALUE_COUNT;
    close CSR_GET_STRING_VALUE_COUNT;
  end if;
end KEY_TO_IDS_2;

procedure INSERT_ROW (
 X_CONDITION_ID                    in NUMBER,
 X_STRING_VALUE                    in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is

begin

  insert into AME_STRING_VALUES
  (
    CONDITION_ID,
    STRING_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER
  ) values (
   X_CONDITION_ID,
   X_STRING_VALUE,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);

end INSERT_ROW;

procedure DELETE_ROW (
  X_CONDITION_ID in NUMBER
) is
begin
  delete from AME_STRING_VALUES
  where CONDITION_ID = X_CONDITION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_CONDITION_KEY    in VARCHAR2,
          X_CONDITION_ID     in VARCHAR2,
          X_STRING_VALUE     in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_ATTRIBUTE_ID      NUMBER;
  X_CONDITION_ID_LOAD NUMBER := null;
  X_CREATED_BY        NUMBER;
  X_LAST_UPDATED_BY   NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_STRING_VALUE_COUNT NUMBER;
  X_STRING_VALUE_ROW  VARCHAR2(20);
begin
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
if X_CONDITION_ID > 0 then
-- drive off CONDITION_KEY
  X_CONDITION_ID_LOAD := null;
  KEY_TO_IDS (
    X_CONDITION_KEY,
    X_STRING_VALUE,
    X_CONDITION_ID_LOAD,
    X_STRING_VALUE_ROW
  );
-- the current row was not found but there is a corresponding
-- condition insert a new row
   if     (X_STRING_VALUE_ROW = 'NOTFOUND') then
     INSERT_ROW (
       X_CONDITION_ID_LOAD,
       X_STRING_VALUE,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
   end if;
else
-- drive off CONDITION_ID
  KEY_TO_IDS_2 (
    X_CONDITION_ID,
    X_STRING_VALUE,
    X_STRING_VALUE_COUNT
  );
-- the current row was not found but there is a corresponding
-- condition insert a new row
   if     (X_STRING_VALUE_COUNT = 0)
      and (X_CONDITION_ID is not null) then
     INSERT_ROW (
       X_CONDITION_ID,
       X_STRING_VALUE,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
   end if;
end if;
exception
    when others then
    ame_util.runtimeException('ame_string_values_api2',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--
END AME_STRING_VALUES_API2;

/
