--------------------------------------------------------
--  DDL for Package Body AME_ITEM_CLASSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITEM_CLASSES_API" AS
/* $Header: ameicapi.pkb 120.11 2006/09/21 15:09:00 pvelugul noship $ */
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
  X_ITEM_CLASS_NAME          in VARCHAR2,
  X_ITEM_CLASS_ID            out nocopy NUMBER,
  X_ITEM_CLASS_ROWID         out nocopy VARCHAR2,
  X_CURRENT_OWNER            out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN              out nocopy NUMBER
) is
  cursor CSR_GET_CURRENT_ITEM_CLASS
  (
    X_ITEM_CLASS_NAME in VARCHAR2
  ) is
   select ROWID,
          ITEM_CLASS_ID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
   from   AME_ITEM_CLASSES
   where  NAME                  = X_ITEM_CLASS_NAME
     and  sysdate between START_DATE
            and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_MAX_ITEM_CLASS_ID is
   select nvl(max(ITEM_CLASS_ID),4)
   from   AME_ITEM_CLASSES
   where  ITEM_CLASS_ID > 4;
  L_ITEM_CLASS_ID NUMBER;
begin
  X_CURRENT_OVN := 1;
  open CSR_GET_CURRENT_ITEM_CLASS (
    X_ITEM_CLASS_NAME
  );
  fetch CSR_GET_CURRENT_ITEM_CLASS into X_ITEM_CLASS_ROWID,
                                        L_ITEM_CLASS_ID,
                                        X_CURRENT_OWNER,
                                        X_CURRENT_LAST_UPDATE_DATE,
                                        X_CURRENT_OVN;
  if (CSR_GET_CURRENT_ITEM_CLASS%notfound) then
    X_ITEM_CLASS_ROWID := null;
    select decode(X_ITEM_CLASS_NAME
                 ,'header',1
                 ,'line item',2
                 ,'cost center',3
                 ,'project code',4
                 ,ame_item_classes_s.nextVal)
      into X_ITEM_CLASS_ID
      from dual;
  else
    X_ITEM_CLASS_ID := L_ITEM_CLASS_ID;
  end if;
  close CSR_GET_CURRENT_ITEM_CLASS;
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
                   X_CREATED_BY in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  if X_CUSTOM_MODE = 'FORCE' then
    return true;
  end if;
  if AME_SEED_UTILITY.IS_SEED_USER(X_CREATED_BY) then
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
 X_ITEM_CLASS_ID                   in NUMBER,
 X_ITEM_CLASS_NAME                 in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
begin
  insert into AME_ITEM_CLASSES
  (
   ITEM_CLASS_ID,
   NAME,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER)
   values (
   X_ITEM_CLASS_ID,
   X_ITEM_CLASS_NAME,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);
end INSERT_ROW;

procedure INSERT_TL_ROW
  (X_ITEM_CLASS_ID  IN NUMBER
  ,X_USER_ITEM_CLASS_NAME IN VARCHAR2
  ,X_CREATED_BY IN NUMBER
  ,X_CREATION_DATE IN DATE
  ,X_LAST_UPDATED_BY IN NUMBER
  ,X_LAST_UPDATE_DATE IN DATE
  ,X_LAST_UPDATE_LOGIN IN NUMBER
  ) AS
BEGIN
  if not AME_SEED_UTILITY.MLS_ENABLED then
    return;
  end if;

  insert into AME_ITEM_CLASSES_TL
    (ITEM_CLASS_ID
    ,USER_ITEM_CLASS_NAME
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,LANGUAGE
    ,SOURCE_LANG
    ) select X_ITEM_CLASS_ID,
             X_USER_ITEM_CLASS_NAME,
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
                           from AME_ITEM_CLASSES_TL T
                          where T.ITEM_CLASS_ID = X_ITEM_CLASS_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);
END INSERT_TL_ROW;

procedure UPDATE_TL_ROW (
  X_ITEM_CLASS_ID in NUMBER,
  X_USER_ITEM_CLASS_NAME in VARCHAR2,
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
       FROM AME_ITEM_CLASSES_TL
       WHERE ITEM_CLASS_ID = X_ITEM_CLASS_ID
       AND LANGUAGE = USERENV('LANG');

   if DO_UPDATE_INSERT
     (X_LAST_UPDATED_BY
     ,X_CURRENT_OWNER
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_LAST_UPDATE_DATE)
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_CURRENT_LAST_UPDATE_DATE)
     ,X_CUSTOM_MODE) then
      update AME_ITEM_CLASSES_TL
         set USER_ITEM_CLASS_NAME = nvl(X_USER_ITEM_CLASS_NAME,USER_ITEM_CLASS_NAME),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where ITEM_CLASS_ID = X_ITEM_CLASS_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
exception
  when no_data_found then
    null;
end UPDATE_TL_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_ITEM_CLASS_NAME            in VARCHAR2,
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
  update AME_ITEM_CLASSES
     set NAME = X_ITEM_CLASS_NAME,
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
 X_ITEM_CLASS_ROWID              in VARCHAR2,
 X_END_DATE                      in DATE)
 is
begin
  update AME_ITEM_CLASSES set
   END_DATE             = X_END_DATE
  where ROWID           = X_ITEM_CLASS_ROWID;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_ITEM_CLASS_ID in NUMBER
) is
begin
  if AME_SEED_UTILITY.MLS_ENABLED then
    delete from AME_ITEM_CLASSES_TL
      where ITEM_CLASS_ID = X_ITEM_CLASS_ID;
  end if;
  delete from AME_ITEM_CLASSES
  where ITEM_CLASS_ID = X_ITEM_CLASS_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure LOAD_ROW (
          X_ITEM_CLASS_NAME  in VARCHAR2,
          X_USER_ITEM_CLASS_NAME in VARCHAR2,
          X_ITEM_CLASS_ID    in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_ITEM_CLASS_COUNT NUMBER;
  X_ITEM_CLASS_ROWID ROWID;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_CURRENT_OVN NUMBER;
  L_ITEM_CLASS_ID NUMBER;
  X_LOCK_HANDLE             varchar2(500);
  X_RETURN_VALUE            number;
begin
-- retrieve information for the current row
  DBMS_LOCK.ALLOCATE_UNIQUE
    (LOCKNAME     =>'AME_ITEM_CLASSES.'||X_ITEM_CLASS_NAME
    ,LOCKHANDLE   => X_LOCK_HANDLE
    );
  X_RETURN_VALUE := DBMS_LOCK.REQUEST
                      (LOCKHANDLE         => X_LOCK_HANDLE
                      ,TIMEOUT            => 0
                      ,RELEASE_ON_COMMIT  => true);
  if X_RETURN_VALUE = 0  then
    -- retrieve information for the current row
    KEY_TO_IDS (
      X_ITEM_CLASS_NAME,
      L_ITEM_CLASS_ID,
      X_ITEM_CLASS_ROWID,
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
     if X_ITEM_CLASS_ROWID is null then
       INSERT_ROW (
         L_ITEM_CLASS_ID,
         X_ITEM_CLASS_NAME,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         1);
       INSERT_TL_ROW
         (L_ITEM_CLASS_ID,
         nvl(X_USER_ITEM_CLASS_NAME,X_ITEM_CLASS_NAME),
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
         FORCE_UPDATE_ROW
           (X_ITEM_CLASS_ROWID,
            X_ITEM_CLASS_NAME,
            X_CREATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATED_BY,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            X_LAST_UPDATE_LOGIN,
            to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
            X_CURRENT_OVN + 1
           );
          UPDATE_TL_ROW
            (L_ITEM_CLASS_ID,
             nvl(X_USER_ITEM_CLASS_NAME,X_ITEM_CLASS_NAME),
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
              X_ITEM_CLASS_ROWID,
              to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
            INSERT_ROW (
              L_ITEM_CLASS_ID,
              X_ITEM_CLASS_NAME,
              X_CREATED_BY,
              to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
              X_LAST_UPDATED_BY,
              to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
              X_LAST_UPDATE_LOGIN,
              to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
              X_CURRENT_OVN + 1);
            UPDATE_TL_ROW
            (L_ITEM_CLASS_ID,
             nvl(X_USER_ITEM_CLASS_NAME,X_ITEM_CLASS_NAME),
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
  end if;
exception
    when others then
    ame_util.runtimeException('ame_item_classes_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

  procedure TRANSLATE_ROW
    (X_ITEM_CLASS_NAME        in varchar2
    ,X_USER_ITEM_CLASS_NAME   in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    L_ITEM_CLASS_ID           integer;
    X_CURRENT_OWNER            NUMBER;
    X_CURRENT_LAST_UPDATE_DATE varchar2(20);
    X_CREATED_BY               varchar2(100);
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    begin
      select AICTL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(AICTL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(AICTL.CREATED_BY),
             AICTL.ITEM_CLASS_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CREATED_BY,
             L_ITEM_CLASS_ID
        from AME_ITEM_CLASSES_TL AICTL,
             AME_ITEM_CLASSES AIC
       where AICTL.ITEM_CLASS_ID = AIC.ITEM_CLASS_ID
         and AIC.NAME = X_ITEM_CLASS_NAME
         and sysdate between AIC.START_DATE and nvl(AIC.END_DATE - (1/86400),sysdate)
         and AICTL.LANGUAGE = userenv('LANG');

      if  DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CREATED_BY                => X_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_ITEM_CLASSES_TL AICTL
           set USER_ITEM_CLASS_NAME = nvl(X_USER_ITEM_CLASS_NAME,AICTL.USER_ITEM_CLASS_NAME),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where AICTL.ITEM_CLASS_ID = L_ITEM_CLASS_ID
           and userenv('LANG') in (AICTL.LANGUAGE,AICTL.SOURCE_LANG);
      END IF;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;
END AME_ITEM_CLASSES_API;

/
