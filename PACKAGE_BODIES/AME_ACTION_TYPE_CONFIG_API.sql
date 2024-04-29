--------------------------------------------------------
--  DDL for Package Body AME_ACTION_TYPE_CONFIG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_TYPE_CONFIG_API" AS
/* $Header: ametcapi.pkb 120.2 2005/10/14 04:14 ubhat noship $ */
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
  X_APPLICATION_NAME         in VARCHAR2,
  X_ACTION_TYPE_NAME         in VARCHAR2,
  X_CONFIG_ROWID             out nocopy VARCHAR2,
  X_APPLICATION_ID           out nocopy NUMBER,
  X_ACTION_TYPE_ID           out nocopy NUMBER,
  X_CURRENT_OWNER            out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN              out nocopy NUMBER
) is
  cursor CSR_GET_APPLICATION
  (
    X_APPLICATION_NAME in varchar2
  ) is
   select ACA.APPLICATION_ID
   from   AME_CALLING_APPS ACA
   where ACA.APPLICATION_NAME = X_APPLICATION_NAME
     and sysdate between START_DATE
     and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_ACTION_TYPE
  (
    X_ACTION_TYPE_NAME in varchar2
  ) is
   select ACTION_TYPE_ID
   from   AME_ACTION_TYPES
   where  NAME                  = X_ACTION_TYPE_NAME
     and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_CURRENT_CONFIG
  (
   X_APPLICATION_ID in varchar2,
   X_ACTION_TYPE_ID in varchar2
  ) is
   select ROWID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
     from AME_ACTION_TYPE_CONFIG
    where ACTION_TYPE_ID = X_ACTION_TYPE_ID
      and APPLICATION_ID = X_APPLICATION_ID
	and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);

begin
  X_CURRENT_OVN := 1;
  open CSR_GET_APPLICATION(
    X_APPLICATION_NAME
  );
  fetch CSR_GET_APPLICATION into X_APPLICATION_ID;
  if (CSR_GET_APPLICATION%notfound) then
    X_APPLICATION_ID := null;
  end if;
  close CSR_GET_APPLICATION;

  open CSR_GET_ACTION_TYPE(
    X_ACTION_TYPE_NAME
  );
  fetch CSR_GET_ACTION_TYPE into X_ACTION_TYPE_ID;
  if (CSR_GET_ACTION_TYPE%notfound) then
     X_ACTION_TYPE_ID := null;
  end if;
  close CSR_GET_ACTION_TYPE;

  if (X_ACTION_TYPE_ID is not null)
     and (X_APPLICATION_ID is not null) then
    open CSR_GET_CURRENT_CONFIG(
         X_APPLICATION_ID,
         X_ACTION_TYPE_ID
         );
    fetch CSR_GET_CURRENT_CONFIG into X_CONFIG_ROWID,
                                      X_CURRENT_OWNER,
                                      X_CURRENT_LAST_UPDATE_DATE,
                                      X_CURRENT_OVN;
    if (CSR_GET_CURRENT_CONFIG%notfound) then
       X_CONFIG_ROWID := null;
    end if;
    close CSR_GET_CURRENT_CONFIG;
  end if;
end KEY_TO_IDS;
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
procedure INSERT_ROW (
 X_APPLICATION_ID                  in NUMBER,
 X_ACTION_TYPE_ID                  in NUMBER,
 X_VOTING_REGIME                   in VARCHAR2,
 X_ORDER_NUMBER                    in NUMBER,
 X_CHAIN_ORDERING_MODE             in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
begin
    insert into AME_ACTION_TYPE_CONFIG
    (
     APPLICATION_ID,
     ACTION_TYPE_ID,
     VOTING_REGIME,
     ORDER_NUMBER,
     CHAIN_ORDERING_MODE,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     START_DATE,
     END_DATE,
     OBJECT_VERSION_NUMBER
     ) values (
     X_APPLICATION_ID,
     X_ACTION_TYPE_ID,
     X_VOTING_REGIME,
     X_ORDER_NUMBER,
     X_CHAIN_ORDERING_MODE,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN,
     X_START_DATE,
     AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
     X_OBJECT_VERSION_NUMBER
     );
end INSERT_ROW;
procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_VOTING_REGIME              in VARCHAR2,
  X_ORDER_NUMBER               in NUMBER,
  X_CHAIN_ORDERING_MODE        in VARCHAR2,
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
  update AME_ACTION_TYPE_CONFIG
     set VOTING_REGIME = X_VOTING_REGIME,
         ORDER_NUMBER = X_ORDER_NUMBER,
         CHAIN_ORDERING_MODE = X_CHAIN_ORDERING_MODE,
         CREATED_BY = X_CREATED_BY,
         CREATION_DATE = X_CREATION_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         START_DATE = X_START_DATE,
         END_DATE = X_END_DATE,
         OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
   where ROWID = X_ROWID;
end FORCE_UPDATE_ROW;
procedure UPDATE_ROW (
 X_CONFIG_ROWID                    in VARCHAR2,
 X_END_DATE                        in DATE)
 is
begin
    update AME_ACTION_TYPE_CONFIG set
      END_DATE             = X_END_DATE
    where ROWID            = X_CONFIG_ROWID;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_TYPE_ID in NUMBER
) is
begin
  delete from AME_ACTION_TYPE_CONFIG
  where APPLICATION_ID =   X_APPLICATION_ID
    and ACTION_TYPE_ID = X_ACTION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure LOAD_ROW (
          X_APPLICATION_NAME          in VARCHAR2,
          X_ACTION_TYPE_NAME          in VARCHAR2,
          X_VOTING_REGIME             in VARCHAR2,
          X_ORDER_NUMBER              in VARCHAR2,
          X_CHAIN_ORDERING_MODE       in VARCHAR2,
          X_OWNER                     in VARCHAR2,
          X_LAST_UPDATE_DATE          in VARCHAR2,
          X_CUSTOM_MODE               in VARCHAR2
)
is
  X_ACTION_TYPE_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_CONFIG_ROWID ROWID;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_CURRENT_OVN NUMBER;
begin
  KEY_TO_IDS (
    X_APPLICATION_NAME,
    X_ACTION_TYPE_NAME,
    X_CONFIG_ROWID,
    X_APPLICATION_ID,
    X_ACTION_TYPE_ID,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_CURRENT_OVN
  );
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
   begin
-- the current row was not found insert a new row
   if     (X_APPLICATION_ID is not null)
      and (X_ACTION_TYPE_ID is not null) then
     if (X_CONFIG_ROWID is null) then
       INSERT_ROW (
         X_APPLICATION_ID,
         X_ACTION_TYPE_ID,
         X_VOTING_REGIME,
         X_ORDER_NUMBER,
         X_CHAIN_ORDERING_MODE,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         1
        );
-- the current row was found end date the current row
-- insert a row with the same attribute id
     else
       if X_CUSTOM_MODE = 'FORCE' then
         FORCE_UPDATE_ROW (
             X_CONFIG_ROWID,
             X_VOTING_REGIME,
             X_ORDER_NUMBER,
             X_CHAIN_ORDERING_MODE,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
             X_CURRENT_OVN + 1
            );
       else
         if DO_UPDATE_INSERT
            (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             X_CURRENT_OWNER,
             X_LAST_UPDATE_DATE,
             X_CURRENT_LAST_UPDATE_DATE) then
           UPDATE_ROW (
             X_CONFIG_ROWID,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
           INSERT_ROW (
             X_APPLICATION_ID,
             X_ACTION_TYPE_ID,
             X_VOTING_REGIME,
             X_ORDER_NUMBER,
             X_CHAIN_ORDERING_MODE,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_CURRENT_OVN + 1
            );
         end if;
       end if;
     end if;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_action_type_config_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--
END AME_ACTION_TYPE_CONFIG_API;

/
