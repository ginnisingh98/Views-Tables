--------------------------------------------------------
--  DDL for Package Body AME_ITEM_CLASS_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITEM_CLASS_USAGES_API" AS
/* $Header: ameiuapi.pkb 120.3 2005/10/14 04:13 ubhat noship $ */
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
  X_ITEM_CLASS_NAME  in VARCHAR2,
  X_APPLICATION_NAME in VARCHAR2,
  X_USAGES_ROWID     out nocopy VARCHAR2,
  X_ITEM_CLASS_ID    out nocopy NUMBER,
  X_APPLICATION_ID   out nocopy NUMBER,
  X_CURRENT_OWNER    out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN  out nocopy VARCHAR2
) is
  cursor CSR_GET_ITEM_CLASS_ID
  (
    X_ITEM_CLASS_NAME in VARCHAR2
  ) is
   select ITEM_CLASS_ID
   from   AME_ITEM_CLASSES
   where  NAME = X_ITEM_CLASS_NAME
	    and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_APPLICATION_ID
  (
    X_APPLICATION_NAME in VARCHAR2
  ) is
   select APPLICATION_ID
   from   AME_CALLING_APPS
   where  APPLICATION_NAME = X_APPLICATION_NAME
	    and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_ITEM_CLASS_USAGE
  (
   X_ITEM_CLASS_ID  in varchar2,
   X_APPLICATION_ID in varchar2
  ) is
   select ROWID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
     from AME_ITEM_CLASS_USAGES
    where ITEM_CLASS_ID  = X_ITEM_CLASS_ID
      and APPLICATION_ID = X_APPLICATION_ID
	    and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);
begin
  X_CURRENT_OVN := 1;
  open CSR_GET_ITEM_CLASS_ID (
    X_ITEM_CLASS_NAME
  );
  fetch CSR_GET_ITEM_CLASS_ID into X_ITEM_CLASS_ID;
  if (CSR_GET_ITEM_CLASS_ID%notfound) then
    X_ITEM_CLASS_ID := null;
  end if;
  close CSR_GET_ITEM_CLASS_ID;

  open CSR_GET_APPLICATION_ID (
    X_APPLICATION_NAME
  );
  fetch CSR_GET_APPLICATION_ID into X_APPLICATION_ID;
  if (CSR_GET_APPLICATION_ID%notfound) then
    X_APPLICATION_ID := null;
  end if;
  close CSR_GET_APPLICATION_ID;

  if (X_APPLICATION_ID is not null) and
     (X_ITEM_CLASS_ID is not null) then
    open CSR_GET_ITEM_CLASS_USAGE (
      X_ITEM_CLASS_ID,
      X_APPLICATION_ID
    );
    fetch CSR_GET_ITEM_CLASS_USAGE into X_USAGES_ROWID,
                                        X_CURRENT_OWNER,
                                        X_CURRENT_LAST_UPDATE_DATE,
                                        X_CURRENT_OVN;
    if (CSR_GET_ITEM_CLASS_USAGE%notfound) then
      X_USAGES_ROWID := null;
    end if;
    close CSR_GET_ITEM_CLASS_USAGE;
  else
    X_USAGES_ROWID := null;
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
 X_ITEM_CLASS_ID                   in NUMBER,
 X_APPLICATION_ID                  in NUMBER,
 X_ITEM_ID_QUERY                   in VARCHAR2,
 X_ITEM_CLASS_ORDER_NUMBER         in NUMBER,
 X_ITEM_CLASS_PAR_MODE             in VARCHAR2,
 X_ITEM_CLASS_SUBLIST_MODE         in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
  is
begin
  insert into AME_ITEM_CLASS_USAGES
  (ITEM_CLASS_ID,
   APPLICATION_ID,
   ITEM_ID_QUERY,
   ITEM_CLASS_ORDER_NUMBER,
   ITEM_CLASS_PAR_MODE,
   ITEM_CLASS_SUBLIST_MODE,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
   ) values (
   X_ITEM_CLASS_ID,
   X_APPLICATION_ID,
   X_ITEM_ID_QUERY,
   X_ITEM_CLASS_ORDER_NUMBER,
   X_ITEM_CLASS_PAR_MODE,
   X_ITEM_CLASS_SUBLIST_MODE,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);

end INSERT_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_ITEM_ID_QUERY              in VARCHAR2,
  X_ITEM_CLASS_ORDER_NUMBER    in NUMBER,
  X_ITEM_CLASS_SUBLIST_MODE    in VARCHAR2,
  X_ITEM_CLASS_PAR_MODE        in VARCHAR2,
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
  update AME_ITEM_CLASS_USAGES
     set ITEM_CLASS_ORDER_NUMBER = X_ITEM_CLASS_ORDER_NUMBER,
         ITEM_ID_QUERY = X_ITEM_ID_QUERY,
         ITEM_CLASS_SUBLIST_MODE = X_ITEM_CLASS_SUBLIST_MODE,
         ITEM_CLASS_PAR_MODE = X_ITEM_CLASS_PAR_MODE,
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
 X_USAGES_ROWID                    in VARCHAR2,
 X_END_DATE                        in DATE)
 is
begin
    update AME_ITEM_CLASS_USAGES set
      END_DATE             = X_END_DATE
    where ROWID            = X_USAGES_ROWID;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ITEM_CLASS_ID in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from AME_ITEM_CLASS_USAGES
  where ITEM_CLASS_ID  = X_ITEM_CLASS_ID
    and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
            X_ITEM_CLASS_NAME    in VARCHAR2,
            X_APPLICATION_NAME   in VARCHAR2,
            X_ITEM_ID_QUERY      in VARCHAR2,
            X_ITEM_CLASS_ORDER_NUMBER in VARCHAR2,
            X_ITEM_CLASS_PAR_MODE in VARCHAR2,
            X_ITEM_CLASS_SUBLIST_MODE in VARCHAR2,
            X_OWNER              in VARCHAR2,
            X_LAST_UPDATE_DATE   in VARCHAR2,
            X_CUSTOM_MODE        in VARCHAR2
)
is
  X_ITEM_CLASS_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_USAGES_ROWID ROWID;
  X_CURRENT_OVN NUMBER;
begin
-- retrieve information for the current row
  KEY_TO_IDS (
    X_ITEM_CLASS_NAME,
    X_APPLICATION_NAME,
    X_USAGES_ROWID,
    X_ITEM_CLASS_ID,
    X_APPLICATION_ID,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_CURRENT_OVN);
-- obtain who column details
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
   begin
-- the current row was not found insert a new row
-- and there is a valid application and valid attribute detected
   if (X_ITEM_CLASS_ID is not null) and
      (X_APPLICATION_ID is not null) then
     if (X_USAGES_ROWID is null) then
       INSERT_ROW (
         X_ITEM_CLASS_ID,
         X_APPLICATION_ID,
         X_ITEM_ID_QUERY,
         X_ITEM_CLASS_ORDER_NUMBER,
         X_ITEM_CLASS_PAR_MODE,
         X_ITEM_CLASS_SUBLIST_MODE,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         1);
     -- the current row was found end date the current row
     -- insert a row with the same attribute id
     else
       if X_CUSTOM_MODE = 'FORCE' then
         FORCE_UPDATE_ROW
           (
           X_USAGES_ROWID,
           X_ITEM_ID_QUERY,
           X_ITEM_CLASS_ORDER_NUMBER,
           X_ITEM_CLASS_PAR_MODE,
           X_ITEM_CLASS_SUBLIST_MODE,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
           X_CURRENT_OVN + 1);
       else
         if DO_UPDATE_INSERT
            (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             X_CURRENT_OWNER,
             X_LAST_UPDATE_DATE,
             X_CURRENT_LAST_UPDATE_DATE) then
           UPDATE_ROW (
             X_USAGES_ROWID,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
           INSERT_ROW (
             X_ITEM_CLASS_ID,
             X_APPLICATION_ID,
             X_ITEM_ID_QUERY,
             X_ITEM_CLASS_ORDER_NUMBER,
             X_ITEM_CLASS_PAR_MODE,
             X_ITEM_CLASS_SUBLIST_MODE,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_CURRENT_OVN + 1);
         end if;
       end if;
     end if;
   end if;
   end;
exception
    when others then
    ame_util.runtimeException('ame_item_class_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;

end LOAD_ROW;

END AME_ITEM_CLASS_USAGES_API;

/
