--------------------------------------------------------
--  DDL for Package Body AME_ACTION_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_TYPES_API" AS
/* $Header: ameacapi.pkb 120.6 2005/10/14 04:10:32 ubhat noship $ */
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
  X_ACTION_TYPE_NAME         in VARCHAR2,
  X_ACTION_TYPE_ROWID        out nocopy VARCHAR2,
  X_ACTION_TYPE_ID           out nocopy NUMBER,
  X_CURRENT_OWNER            out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN              out nocopy NUMBER
) is
  cursor CSR_GET_CURRENT_ACTION_TYPE
  (
    X_ATTRIBUTE_NAME in VARCHAR2
  ) is
   select ROWID, ACTION_TYPE_ID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
   from   AME_ACTION_TYPES
   where  NAME                  = X_ACTION_TYPE_NAME
     and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);
begin
  X_CURRENT_OVN := 1;
  open CSR_GET_CURRENT_ACTION_TYPE (
    X_ACTION_TYPE_NAME
  );
  fetch CSR_GET_CURRENT_ACTION_TYPE into X_ACTION_TYPE_ROWID, X_ACTION_TYPE_ID,
                                         X_CURRENT_OWNER, X_CURRENT_LAST_UPDATE_DATE, X_CURRENT_OVN;
  if (CSR_GET_CURRENT_ACTION_TYPE%notfound) then
     X_ACTION_TYPE_ID := null;
  end if;
  close CSR_GET_CURRENT_ACTION_TYPE;
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
function DO_TL_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_CREATED_BY in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  if X_CUSTOM_MODE = 'FORCE' then
    return true;
  end if;
  if AME_SEED_UTILITY.IS_SEED_USER(X_CURRENT_CREATED_BY) then
    return true;
  else
    return AME_SEED_UTILITY.TL_MERGE_ROW_TEST
      (X_OWNER                     => X_OWNER
      ,X_CURRENT_OWNER             => X_CURRENT_OWNER
      ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
      ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
      ,X_CUSTOM_MODE               => X_CUSTOM_MODE
      );
  end if;
  return(false);
end DO_TL_UPDATE_INSERT;
procedure INSERT_ROW (
 X_ACTION_TYPE_ID                  in NUMBER,
 X_NAME                            in VARCHAR2,
 X_PROCEDURE_NAME                  in VARCHAR2,
 X_DYNAMIC_DESCRIPTION             in VARCHAR2,
 X_DESCRIPTION_QUERY               in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_DESCRIPTION                     in VARCHAR2,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is

begin

  insert into AME_ACTION_TYPES
  (
   ACTION_TYPE_ID,
   NAME,
   PROCEDURE_NAME,
   DYNAMIC_DESCRIPTION,
   DESCRIPTION_QUERY,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   DESCRIPTION,
   OBJECT_VERSION_NUMBER
  ) values (
   X_ACTION_TYPE_ID,
   X_NAME,
   X_PROCEDURE_NAME,
   X_DYNAMIC_DESCRIPTION,
   X_DESCRIPTION_QUERY,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_DESCRIPTION,
   X_OBJECT_VERSION_NUMBER);

end INSERT_ROW;

procedure INSERT_TL_ROW (
  X_ACTION_TYPE_ID in NUMBER,
  X_USER_ACTION_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER) is
 begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
  insert into AME_ACTION_TYPES_TL
    (ACTION_TYPE_ID
    ,USER_ACTION_TYPE_NAME
    ,DESCRIPTION
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,LANGUAGE
    ,SOURCE_LANG
    ) select X_ACTION_TYPE_ID,
             X_USER_ACTION_TYPE_NAME,
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
                           from AME_ACTION_TYPES_TL T
                          where T.ACTION_TYPE_ID = X_ACTION_TYPE_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);
END INSERT_TL_ROW;

procedure UPDATE_TL_ROW (
  X_ACTION_TYPE_ID in NUMBER,
  X_USER_ACTION_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CUSTOM_MODE in VARCHAR2) is
  X_CURRENT_OWNER  NUMBER;
  X_CURRENT_LAST_UPDATE_DATE DATE;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    select LAST_UPDATED_BY,
           LAST_UPDATE_DATE
       into X_CURRENT_OWNER,
            X_CURRENT_LAST_UPDATE_DATE
       FROM AME_ACTION_TYPES_TL
       WHERE ACTION_TYPE_ID = X_ACTION_TYPE_ID
       AND LANGUAGE = USERENV('LANG');

   if DO_UPDATE_INSERT
     (X_LAST_UPDATED_BY
     ,X_CURRENT_OWNER
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_LAST_UPDATE_DATE)
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_CURRENT_LAST_UPDATE_DATE)
     ,X_CUSTOM_MODE) then
      update AME_ACTION_TYPES_TL
         set USER_ACTION_TYPE_NAME = nvl(X_USER_ACTION_TYPE_NAME,USER_ACTION_TYPE_NAME),
             DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where ACTION_TYPE_ID = X_ACTION_TYPE_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
exception
  when no_data_found then
    null;
end UPDATE_TL_ROW;

procedure UPDATE_ROW (
 X_ACTION_TYPE_ROWID               in VARCHAR2,
 X_END_DATE                        in DATE)
 is
begin
  update AME_ACTION_TYPES set
   END_DATE             = X_END_DATE
  where ROWID           = X_ACTION_TYPE_ROWID;
end UPDATE_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_NAME                       in VARCHAR2,
  X_PROCEDURE_NAME             in VARCHAR2,
  X_DYNAMIC_DESCRIPTION        in VARCHAR2,
  X_DESCRIPTION_QUERY          in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
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
  update AME_ACTION_TYPES
     set NAME = X_NAME,
         PROCEDURE_NAME = X_PROCEDURE_NAME,
         DYNAMIC_DESCRIPTION = X_DYNAMIC_DESCRIPTION,
         DESCRIPTION_QUERY = X_DESCRIPTION_QUERY,
         DESCRIPTION = X_DESCRIPTION,
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

procedure DELETE_ROW (
  X_ACTION_TYPE_ID in NUMBER
) is
begin
  if AME_SEED_UTILITY.MLS_ENABLED then
    delete from AME_ACTION_TYPES_TL
     where ACTION_TYPE_ID = X_ACTION_TYPE_ID;
  end if;
  delete from AME_ACTION_TYPES
  where ACTION_TYPE_ID = X_ACTION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
          X_ACTION_TYPE_NAME    in VARCHAR2,
          X_USER_ACTION_TYPE_NAME in VARCHAR2,
          X_PROCEDURE_NAME      in VARCHAR2,
          X_DESCRIPTION         in VARCHAR2,
          X_DYNAMIC_DESCRIPTION in VARCHAR2,
          X_DESCRIPTION_QUERY   in VARCHAR2,
          X_OWNER               in VARCHAR2,
          X_LAST_UPDATE_DATE    in VARCHAR2,
          X_CUSTOM_MODE         in VARCHAR2
)
is
  X_ACTION_TYPE_ROWID ROWID;
  X_ACTION_TYPE_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_CURRENT_OVN NUMBER;
begin
-- retrieve information for the current row
  KEY_TO_IDS (
    X_ACTION_TYPE_NAME,
    X_ACTION_TYPE_ROWID,
    X_ACTION_TYPE_ID,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_CURRENT_OVN
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
   if X_ACTION_TYPE_ID is null then
     select ame_action_types_s.nextval into X_ACTION_TYPE_ID from dual;
     INSERT_ROW (
       X_ACTION_TYPE_ID,
       X_ACTION_TYPE_NAME,
       X_PROCEDURE_NAME,
       X_DYNAMIC_DESCRIPTION,
       X_DESCRIPTION_QUERY,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_DESCRIPTION,
       1);

       INSERT_TL_ROW
       (X_ACTION_TYPE_ID,
       nvl(X_USER_ACTION_TYPE_NAME,X_ACTION_TYPE_NAME),
       X_DESCRIPTION,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN
       );

-- the current row was found end date the current row
-- insert a row with the same action type id
   else
     if X_CUSTOM_MODE = 'FORCE' then
        FORCE_UPDATE_ROW (
          X_ACTION_TYPE_ROWID,
          X_ACTION_TYPE_NAME,
          X_PROCEDURE_NAME,
          X_DYNAMIC_DESCRIPTION,
          X_DESCRIPTION_QUERY,
          X_DESCRIPTION,
          X_CREATED_BY,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          X_LAST_UPDATED_BY,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          X_LAST_UPDATE_LOGIN,
          to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
          X_CURRENT_OVN + 1);
       UPDATE_TL_ROW
       (X_ACTION_TYPE_ID,
       nvl(X_USER_ACTION_TYPE_NAME,X_ACTION_TYPE_NAME),
       X_DESCRIPTION,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       X_CUSTOM_MODE
       );
     else
        if DO_UPDATE_INSERT
              (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               X_CURRENT_OWNER,
               X_LAST_UPDATE_DATE,
               X_CURRENT_LAST_UPDATE_DATE) then
          UPDATE_ROW (
            X_ACTION_TYPE_ROWID,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
          INSERT_ROW (
            X_ACTION_TYPE_ID,
            X_ACTION_TYPE_NAME,
            X_PROCEDURE_NAME,
            X_DYNAMIC_DESCRIPTION,
            X_DESCRIPTION_QUERY,
            X_CREATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATE_LOGIN,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_DESCRIPTION,
            X_CURRENT_OVN + 1);
           UPDATE_TL_ROW
           (X_ACTION_TYPE_ID,
           nvl(X_USER_ACTION_TYPE_NAME,X_ACTION_TYPE_NAME),
           X_DESCRIPTION,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           X_CUSTOM_MODE
           );
         end if;
      end if;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_action_types_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

procedure LOAD_ROW (
          X_ACTION_TYPE_NAME    in VARCHAR2,
          X_PROCEDURE_NAME      in VARCHAR2,
          X_DESCRIPTION         in VARCHAR2,
          X_OWNER               in VARCHAR2,
          X_LAST_UPDATE_DATE    in VARCHAR2
)
is
begin
null;
end LOAD_ROW;

  procedure TRANSLATE_ROW
    (X_ACTION_TYPE_NAME       in varchar2
    ,X_USER_ACTION_TYPE_NAME  in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    X_CURRENT_OWNER            number;
    X_CURRENT_LAST_UPDATE_DATE varchar2(20);
    X_CURRENT_CREATED_BY       varchar2(100);
    X_ACTION_TYPE_ID           number;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    begin
      select AATTL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(AATTL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(AATTL.CREATED_BY),
             AAT.ACTION_TYPE_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CURRENT_CREATED_BY,
             X_ACTION_TYPE_ID
        from AME_ACTION_TYPES_TL AATTL,
             AME_ACTION_TYPES AAT
       where AAT.NAME = X_ACTION_TYPE_NAME
         and AAT.ACTION_TYPE_ID = AATTL.ACTION_TYPE_ID
         and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate)
         and AATTL.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
         and AATTL.LANGUAGE = userenv('LANG');
      if  DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CURRENT_CREATED_BY        => X_CURRENT_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_ACTION_TYPES_TL AATTL
           set USER_ACTION_TYPE_NAME = nvl(X_USER_ACTION_TYPE_NAME,USER_ACTION_TYPE_NAME),
               DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where AATTL.ACTION_TYPE_ID = X_ACTION_TYPE_ID
           and userenv('LANG') in (AATTL.LANGUAGE,AATTL.SOURCE_LANG);
      end if;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

end AME_ACTION_TYPES_API;

/
