--------------------------------------------------------
--  DDL for Package Body AME_CONDITION_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONDITION_USAGES_API" AS
/* $Header: amecsapi.pkb 120.1 2005/10/14 04:12:25 ubhat noship $ */

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
  X_RULE_ID          in  NUMBER,
  X_CONDITION_ID     in  NUMBER,
  X_CONDITION_USAGE_COUNT  out nocopy NUMBER
  ) is
  cursor CSR_GET_COND_USAGE_COUNT
  (
    X_CONDITION_ID in NUMBER,
    X_RULE_ID      in NUMBER
  ) is
  select COUNT(*)
    from AME_CONDITION_USAGES
   where CONDITION_ID = X_CONDITION_ID
     and RULE_ID = X_RULE_ID;

  X_ATTRIBUTE_ID NUMBER;

begin

  if (X_CONDITION_ID is not null) and
     (X_RULE_ID is not null) then
    open CSR_GET_COND_USAGE_COUNT (
      X_CONDITION_ID,
      X_RULE_ID
    );
    fetch CSR_GET_COND_USAGE_COUNT into X_CONDITION_USAGE_COUNT;
    close CSR_GET_COND_USAGE_COUNT;
  end if;

end KEY_TO_IDS;

procedure KEY_TO_IDS_3 (
  X_RULE_KEY         in  NUMBER,
  X_CONDITION_ID     in  NUMBER,
  X_RULE_ID          out nocopy NUMBER,
  X_CONDITION_USAGE_COUNT out nocopy NUMBER
  ) is
  cursor CSR_GET_COND_USAGE_COUNT
  (
    X_CONDITION_ID in NUMBER,
    X_RULE_ID      in NUMBER
  ) is
  select COUNT(*)
    from AME_CONDITION_USAGES
   where CONDITION_ID = X_CONDITION_ID
     and RULE_ID = X_RULE_ID;
  cursor CSR_GET_RULE_ID
  (
   X_RULE_KEY      in VARCHAR2
  ) is
  select RULE_ID
    from AME_RULES
   where RULE_KEY = X_RULE_KEY;
  X_ATTRIBUTE_ID NUMBER;
begin
  open CSR_GET_RULE_ID (
      X_RULE_KEY
  );
  fetch CSR_GET_RULE_ID into X_RULE_ID;
      if (CSR_GET_RULE_ID%notfound) then
        X_RULE_ID := null;
      end if;
  close CSR_GET_RULE_ID;
  if (X_CONDITION_ID is not null) and
     (X_RULE_ID is not null) then
    open CSR_GET_COND_USAGE_COUNT (
      X_CONDITION_ID,
      X_RULE_ID
    );
    fetch CSR_GET_COND_USAGE_COUNT into X_CONDITION_USAGE_COUNT;
    close CSR_GET_COND_USAGE_COUNT;
  end if;
end KEY_TO_IDS_3;


procedure INSERT_ROW (
 X_RULE_ID                         in NUMBER,
 X_CONDITION_ID                    in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is

begin

  insert into AME_CONDITION_USAGES
  (
   RULE_ID,
   CONDITION_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
  ) values (
   X_RULE_ID,
   X_CONDITION_ID,
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
  X_RULE_ID in NUMBER,
  X_CONDITION_ID in NUMBER)
is
begin
  delete from AME_CONDITION_USAGES
  where RULE_ID      = X_RULE_ID
    and CONDITION_ID = X_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_RULE_ID          in VARCHAR2,
          X_CONDITION_ID     in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2
)
is
  X_CONDITION_ID_LOAD NUMBER;
  X_CONDITION_USAGE VARCHAR2(20);
  X_CONDITION_USAGE_COUNT NUMBER := 0;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_RULE_ID_LOAD NUMBER;
begin
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
if X_RULE_ID < 0 then
-- Drive off CONDITION_ID and RULE_ID
    KEY_TO_IDS (
      X_RULE_ID,
      X_CONDITION_ID,
      X_CONDITION_USAGE_COUNT
    );
-- the current row was not found insert a new row
    if (X_CONDITION_USAGE_COUNT = 0) then
      INSERT_ROW (
        X_RULE_ID,
        X_CONDITION_ID,
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
    ame_util.runtimeException('ame_condition_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--
END AME_CONDITION_USAGES_API;

/
