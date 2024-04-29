--------------------------------------------------------
--  DDL for Package Body AME_APPROVAL_GROUPS_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVAL_GROUPS_LOAD_API" AS
/* $Header: ameagapi.pkb 120.4 2005/10/14 04:10:38 ubhat noship $ */

procedure OWNER_TO_WHO (X_OWNER               in         VARCHAR2
                       ,X_CREATED_BY          out nocopy NUMBER
                       ,X_LAST_UPDATED_BY     out nocopy NUMBER
                       ,X_LAST_UPDATE_LOGIN   out nocopy NUMBER
                       ) is
  begin
  X_CREATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATE_LOGIN := 0;
  end OWNER_TO_WHO;

procedure INSERT_ROW (X_NAME                    in     VARCHAR2
                     ,X_QUERY_STRING            in     VARCHAR2
                     ,X_IS_STATIC               in     VARCHAR2
                     ,X_DESCRIPTION             in     VARCHAR2
                     ,X_CREATED_BY              in     NUMBER
                     ,X_CREATION_DATE           in     DATE
                     ,X_LAST_UPDATED_BY         in     NUMBER
                     ,X_LAST_UPDATE_DATE        in     DATE
                     ,X_LAST_UPDATE_LOGIN       in     NUMBER
                     ,X_START_DATE              in     DATE
                     ,X_OBJECT_VERSION_NUMBER   in     NUMBER
                     ,X_APPROVAL_GROUP_ID       in out nocopy NUMBER
                     )
  is
  begin
    if (X_APPROVAL_GROUP_ID is null) then
      select ame_approval_groups_s.nextval
        into X_APPROVAL_GROUP_ID
        from sys.dual;
    end if;
    insert into AME_APPROVAL_GROUPS
      (APPROVAL_GROUP_ID
      ,NAME
      ,QUERY_STRING
      ,IS_STATIC
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,START_DATE
      ,END_DATE
      ,DESCRIPTION
      ,OBJECT_VERSION_NUMBER
      ) select
       X_APPROVAL_GROUP_ID
      ,X_NAME
      ,X_QUERY_STRING
      ,X_IS_STATIC
      ,X_CREATED_BY
      ,X_CREATION_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATE_LOGIN
      ,X_START_DATE
      ,AME_SEED_UTILITY.GET_DEFAULT_END_DATE
      ,X_DESCRIPTION
      ,X_OBJECT_VERSION_NUMBER
      from  sys.dual
      where not exists (select NULL
                          from AME_APPROVAL_GROUPS
                         where NAME = X_NAME
                           and sysdate between START_DATE
                                 and nvl(END_DATE - (1/86400), sysdate));
  end INSERT_ROW;

procedure INSERT_TL_ROW (
  X_APPROVAL_GROUP_ID in NUMBER,
  X_USER_APPROVAL_GROUP_NAME in VARCHAR2,
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

  insert into AME_APPROVAL_GROUPS_TL
    (APPROVAL_GROUP_ID
    ,USER_APPROVAL_GROUP_NAME
    ,DESCRIPTION
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,LANGUAGE
    ,SOURCE_LANG
    ) select X_APPROVAL_GROUP_ID,
             X_USER_APPROVAL_GROUP_NAME,
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
                           from AME_APPROVAL_GROUPS_TL T
                          where T.APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);
END INSERT_TL_ROW;

procedure KEY_TO_IDS (X_APPROVAL_GROUP_NAME      in  VARCHAR2
                     ,X_APPROVAL_GROUP_ROWID     out nocopy VARCHAR2
                     ,X_APPROVAL_GROUP_ID        out nocopy NUMBER
                     ,X_CURRENT_OWNER            out nocopy NUMBER
                     ,X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2
                     ,X_CURRENT_OVN              out nocopy NUMBER
                     ,X_MAX_START_DATE           out nocopy DATE
                     ) is
  cursor CSR_GET_MAX_START
  (
    X_APPROVAL_GROUP_NAME in VARCHAR2
  ) is
    select max(START_DATE)
      from AME_APPROVAL_GROUPS
     where NAME = X_APPROVAL_GROUP_NAME;

  cursor CSR_GET_CURRENT_APPROVAL_GROUP
  (
    X_APPROVAL_GROUP_NAME in VARCHAR2
  ) is
    select ROWID, APPROVAL_GROUP_ID,
           LAST_UPDATED_BY,
           to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           nvl(OBJECT_VERSION_NUMBER,1)
      from AME_APPROVAL_GROUPS
     where NAME = X_APPROVAL_GROUP_NAME
       and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate)
    for update of END_DATE;

  begin
    X_CURRENT_OVN := 1;
    open CSR_GET_MAX_START(X_APPROVAL_GROUP_NAME);
    fetch CSR_GET_MAX_START into X_MAX_START_DATE;
    if (CSR_GET_MAX_START%notfound) then
      X_MAX_START_DATE := null;
    end if;
    close CSR_GET_MAX_START;
    open CSR_GET_CURRENT_APPROVAL_GROUP(X_APPROVAL_GROUP_NAME);
    fetch CSR_GET_CURRENT_APPROVAL_GROUP into X_APPROVAL_GROUP_ROWID, X_APPROVAL_GROUP_ID,
                                X_CURRENT_OWNER, X_CURRENT_LAST_UPDATE_DATE, X_CURRENT_OVN;
    if (CSR_GET_CURRENT_APPROVAL_GROUP%notfound) then
       X_APPROVAL_GROUP_ID := null;
    end if;
    close CSR_GET_CURRENT_APPROVAL_GROUP;
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

procedure UPDATE_ROW (X_APPROVAL_GROUP_ROWID in VARCHAR2
                     ,X_END_DATE             in DATE
                     ,X_APPROVAL_GROUP_ID    in NUMBER
                     ,X_NAME                 in VARCHAR2
                     ,X_QUERY_STRING         in VARCHAR2
                     ,X_IS_STATIC            in VARCHAR2
                     ,X_CREATED_BY           in NUMBER
                     ,X_CREATION_DATE        in DATE
                     ,X_LAST_UPDATED_BY      in NUMBER
                     ,X_LAST_UPDATE_DATE     in DATE
                     ,X_LAST_UPDATE_LOGIN    in NUMBER
                     ,X_START_DATE           in DATE
                     ,X_DESCRIPTION          in VARCHAR2
                     ,X_OBJECT_VERSION_NUMBER in NUMBER
                     )
is
  L_APPROVAL_GROUP_ID number;
  begin
    L_APPROVAL_GROUP_ID := X_APPROVAL_GROUP_ID;
    update AME_APPROVAL_GROUPS
       set END_DATE = X_END_DATE
     where ROWID = X_APPROVAL_GROUP_ROWID;
    INSERT_ROW (X_NAME                 => X_NAME
               ,X_QUERY_STRING         => X_QUERY_STRING
               ,X_IS_STATIC            => X_IS_STATIC
               ,X_DESCRIPTION          => X_DESCRIPTION
               ,X_CREATED_BY           => X_CREATED_BY
               ,X_CREATION_DATE        => X_CREATION_DATE
               ,X_LAST_UPDATED_BY      => X_LAST_UPDATED_BY
               ,X_LAST_UPDATE_DATE     => X_LAST_UPDATE_DATE
               ,X_LAST_UPDATE_LOGIN    => X_LAST_UPDATE_LOGIN
               ,X_START_DATE           => X_START_DATE
               ,X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER
               ,X_APPROVAL_GROUP_ID    => L_APPROVAL_GROUP_ID
               );
  end UPDATE_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_NAME                       in VARCHAR2,
  X_QUERY_STRING               in VARCHAR2,
  X_IS_STATIC                  in VARCHAR2,
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
  update AME_APPROVAL_GROUPS
     set NAME = X_NAME,
         QUERY_STRING = X_QUERY_STRING,
         IS_STATIC = X_IS_STATIC,
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

procedure POPULATE_APP_GRP_MEMBERS(X_APPROVAL_GROUP_ID    in NUMBER
                                         ,X_QUERY_STRING         in VARCHAR2
                                         )
  is
  begin
    delete from AME_APPROVAL_GROUP_MEMBERS
          where APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID;
    insert into AME_APPROVAL_GROUP_MEMBERS
      (APPROVAL_GROUP_ID
      ,PARAMETER_NAME
      ,PARAMETER
      ,QUERY_STRING
      ,ORDER_NUMBER
      ) select
       X_APPROVAL_GROUP_ID
      ,ame_util.approverOamGroupId
      ,X_APPROVAL_GROUP_ID
      ,X_QUERY_STRING
      ,1
      from sys.dual;
    update AME_APPROVAL_GROUP_MEMBERS
       set QUERY_STRING = X_QUERY_STRING
     where PARAMETER_NAME = ame_util.approverOamGroupId
       and PARAMETER = to_char(X_APPROVAL_GROUP_ID)
       and APPROVAL_GROUP_ID <> X_APPROVAL_GROUP_ID;
  end POPULATE_APP_GRP_MEMBERS;

procedure CREATE_APPROVAL_CONFIG(X_APPROVAL_GROUP_ID       in     NUMBER
                                ,X_CREATED_BY              in     NUMBER
                                ,X_CREATION_DATE           in     DATE
                                ,X_LAST_UPDATED_BY         in     NUMBER
                                ,X_LAST_UPDATE_DATE        in     DATE
                                ,X_LAST_UPDATE_LOGIN       in     NUMBER
                                ,X_START_DATE              in     DATE
                                )
is
  cursor get_active_application is
         select APPLICATION_ID
           from AME_CALLING_APPS
          where sysdate between start_date
            and nvl(end_date - ame_util.oneSecond,sysdate);
  TYPE APPLICATION_ID_TAB is table of NUMBER index by BINARY_INTEGER;
  APPLICATION_ID_LIST APPLICATION_ID_TAB;
  L_ORDER_NUMBER   NUMBER;
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;
    if (AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is not null) and to_number(AME_SEED_UTILITY.AME_INSTALLATION_LEVEL) < 2 then
      open get_active_application;
      fetch get_active_application bulk collect into application_id_list;
      close get_active_application;
      --
      -- Now for each active application, create a config record.
      --
      for indx in 1..APPLICATION_ID_LIST.count
      loop
        --
        -- Obtain the maximum order number allotted for that application_id.
        --
        select nvl(max(order_number),0)+1
          into L_ORDER_NUMBER
          from AME_APPROVAL_GROUP_CONFIG
         where application_id = APPLICATION_ID_LIST(indx)
           and sysdate between start_date
           and nvl(end_date - ame_util.oneSecond,sysdate);
        --
        -- Now insert a row for each application_id.
        --
        insert into AME_APPROVAL_GROUP_CONFIG(
           APPLICATION_ID
          ,APPROVAL_GROUP_ID
          ,VOTING_REGIME
          ,ORDER_NUMBER
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,START_DATE
          ,END_DATE
          ,OBJECT_VERSION_NUMBER
          ) select
           APPLICATION_ID_LIST(indx)
          ,X_APPROVAL_GROUP_ID
          ,ame_util.serializedVoting
          ,L_ORDER_NUMBER
          ,X_CREATED_BY
          ,X_CREATION_DATE
          ,X_LAST_UPDATED_BY
          ,X_LAST_UPDATE_DATE
          ,X_LAST_UPDATE_LOGIN
          ,X_START_DATE
          ,null
          ,1
          from sys.dual;
      end loop;
    end if;
  end CREATE_APPROVAL_CONFIG;

procedure UPDATE_TL_ROW (
  X_APPROVAL_GROUP_ID in NUMBER,
  X_USER_APPROVAL_GROUP_NAME in VARCHAR2,
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
       FROM AME_APPROVAL_GROUPS_TL
       WHERE APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID
       AND LANGUAGE = USERENV('LANG');

   if DO_UPDATE_INSERT
     (X_LAST_UPDATED_BY
     ,X_CURRENT_OWNER
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_LAST_UPDATE_DATE)
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_CURRENT_LAST_UPDATE_DATE)
     ,X_CUSTOM_MODE) then
      update AME_APPROVAL_GROUPS_TL
         set USER_APPROVAL_GROUP_NAME = nvl(X_USER_APPROVAL_GROUP_NAME,USER_APPROVAL_GROUP_NAME),
             DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
exception
  when no_data_found then
    null;
end UPDATE_TL_ROW;

procedure LOAD_ROW(X_APPROVAL_GROUP_NAME  in VARCHAR2
                  ,X_USER_APPROVAL_GROUP_NAME in VARCHAR2
                  ,X_DESCRIPTION          in VARCHAR2
                  ,X_QUERY_STRING         in VARCHAR2
                  ,X_IS_STATIC            in VARCHAR2
                  ,X_OWNER                in VARCHAR2
                  ,X_LAST_UPDATE_DATE     in VARCHAR2
                  ,X_CUSTOM_MODE          in VARCHAR2
                  )
is
  X_APPROVAL_GROUP_ROWID      ROWID;
  X_APPROVAL_GROUP_ID         NUMBER;
  X_CURRENT_OWNER             NUMBER;
  X_CURRENT_LAST_UPDATE_DATE  VARCHAR2(19);
  X_CURRENT_OVN               NUMBER;
  X_MAX_START_DATE            DATE;
  X_CREATED_BY                NUMBER;
  X_LAST_UPDATED_BY           NUMBER;
  X_LAST_UPDATE_LOGIN         NUMBER;
  lockHandle varchar2(500);
  returnValue integer;
  begin
    DBMS_LOCK.ALLOCATE_UNIQUE
      (lockname =>'AME_APPROVAL_GROUPS.'||X_APPROVAL_GROUP_NAME
      ,lockhandle => lockHandle
      );
    returnValue := DBMS_LOCK.REQUEST
      (lockhandle => lockHandle
      ,timeout => 0
      ,release_on_commit => true
      );
    if returnValue = 0  then
      KEY_TO_IDS (
        X_APPROVAL_GROUP_NAME
       ,X_APPROVAL_GROUP_ROWID
       ,X_APPROVAL_GROUP_ID
       ,X_CURRENT_OWNER
       ,X_CURRENT_LAST_UPDATE_DATE
       ,X_CURRENT_OVN
       ,X_MAX_START_DATE
       );
      OWNER_TO_WHO (
         X_OWNER
        ,X_CREATED_BY
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_LOGIN
        );
      begin
        -- the current row was not found insert a new row
        if (X_APPROVAL_GROUP_ID is null)  then
          INSERT_ROW (
             X_APPROVAL_GROUP_NAME
            ,X_QUERY_STRING
            ,X_IS_STATIC
            ,X_DESCRIPTION
            ,X_CREATED_BY
            ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
            ,X_LAST_UPDATED_BY
            ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
            ,X_LAST_UPDATE_LOGIN
            ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
            ,1
            ,X_APPROVAL_GROUP_ID
            );
          INSERT_TL_ROW
            (X_APPROVAL_GROUP_ID
            ,nvl(X_USER_APPROVAL_GROUP_NAME,X_APPROVAL_GROUP_NAME)
            ,X_DESCRIPTION
            ,X_CREATED_BY
            ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
            ,X_LAST_UPDATED_BY
            ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
            ,X_LAST_UPDATE_LOGIN
            );
        --
        -- Create config records.
        --
        CREATE_APPROVAL_CONFIG
          (X_APPROVAL_GROUP_ID => X_APPROVAL_GROUP_ID
          ,X_CREATED_BY        => X_CREATED_BY
          ,X_CREATION_DATE     => to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
          ,X_LAST_UPDATED_BY   => X_LAST_UPDATED_BY
          ,X_LAST_UPDATE_DATE  => to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
          ,X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
          ,X_START_DATE        => to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
          );
        -- the current row was found end date the current row
        -- insert a row with the same attribute id
        else
          if X_CUSTOM_MODE = 'FORCE' then
            FORCE_UPDATE_ROW (
               X_APPROVAL_GROUP_ROWID
              ,X_APPROVAL_GROUP_NAME
              ,X_QUERY_STRING
              ,X_IS_STATIC
              ,X_DESCRIPTION
              ,X_CREATED_BY
              ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
              ,X_LAST_UPDATED_BY
              ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
              ,X_LAST_UPDATE_LOGIN
              ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
              ,AME_SEED_UTILITY.GET_DEFAULT_END_DATE
              ,X_CURRENT_OVN + 1
              );
            UPDATE_TL_ROW
              (X_APPROVAL_GROUP_ID
              ,nvl(X_USER_APPROVAL_GROUP_NAME,X_APPROVAL_GROUP_NAME)
              ,X_DESCRIPTION
              ,X_CREATED_BY
              ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
              ,X_LAST_UPDATED_BY
              ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
              ,X_LAST_UPDATE_LOGIN
              ,X_CUSTOM_MODE
              );
          else
            if DO_UPDATE_INSERT
                (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER)
                ,X_CURRENT_OWNER
                ,X_LAST_UPDATE_DATE
                ,X_CURRENT_LAST_UPDATE_DATE
                )
              and (X_MAX_START_DATE is not null)
              and (to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS') > X_MAX_START_DATE)
              then
                UPDATE_ROW (
                   X_APPROVAL_GROUP_ROWID
                  ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400)
                  ,X_APPROVAL_GROUP_ID
                  ,X_APPROVAL_GROUP_NAME
                  ,X_QUERY_STRING
                  ,X_IS_STATIC
                  ,X_CREATED_BY
                  ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
                  ,X_LAST_UPDATED_BY
                  ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
                  ,X_LAST_UPDATE_LOGIN
                  ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
                  ,X_DESCRIPTION
                  ,X_CURRENT_OVN + 1
                  );
              UPDATE_TL_ROW
                (X_APPROVAL_GROUP_ID
                ,nvl(X_USER_APPROVAL_GROUP_NAME,X_APPROVAL_GROUP_NAME)
                ,X_DESCRIPTION
                ,X_CREATED_BY
                ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
                ,X_LAST_UPDATED_BY
                ,to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
                ,X_LAST_UPDATE_LOGIN
                ,X_CUSTOM_MODE
                );
            end if;
          end if;
        end if;
      end;
      POPULATE_APP_GRP_MEMBERS(X_APPROVAL_GROUP_ID  => X_APPROVAL_GROUP_ID
                              ,X_QUERY_STRING       => X_QUERY_STRING
                              );
    end if;
  exception
    when others then
      ame_util.runtimeException('ame_approval_groups_api'
                               ,'load_row'
                               ,sqlcode
                               ,sqlerrm);
      raise;
  end LOAD_ROW;

procedure DELETE_ROW (X_APPROVAL_GROUP_ID in NUMBER
                     ) is
  begin
    if AME_SEED_UTILITY.MLS_ENABLED then
      delete from AME_APPROVAL_GROUPS_TL
       where APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID;
    end if;
    delete from AME_APPROVAL_GROUPS
    where APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID;
    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

  procedure TRANSLATE_ROW
    (X_APPROVAL_GROUP_NAME    in VARCHAR2
    ,X_USER_APPROVAL_GROUP_NAME in VARCHAR2
    ,X_DESCRIPTION            in VARCHAR2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    X_CURRENT_OWNER            number;
    X_CURRENT_LAST_UPDATE_DATE varchar2(20);
    X_CREATED_BY               varchar2(100);
    X_APPROVAL_GROUP_ID        number;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    begin
      select AAGTL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(AAGTL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(AAGTL.CREATED_BY),
             AAG.APPROVAL_GROUP_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CREATED_BY,
             X_APPROVAL_GROUP_ID
        from AME_APPROVAL_GROUPS_TL AAGTL,
             AME_APPROVAL_GROUPS AAG
       where AAG.NAME = X_APPROVAL_GROUP_NAME
         and sysdate between AAG.START_DATE and nvl(AAG.END_DATE - (1/86400),sysdate)
         and AAGTL.APPROVAL_GROUP_ID = AAG.APPROVAL_GROUP_ID
         and AAGTL.LANGUAGE = userenv('LANG');
      if DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CREATED_BY                => X_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_APPROVAL_GROUPS_TL AAGTL
           set USER_APPROVAL_GROUP_NAME = nvl(X_USER_APPROVAL_GROUP_NAME,USER_APPROVAL_GROUP_NAME),
               DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where AAGTL.APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID
           and userenv('LANG') in (AAGTL.LANGUAGE,AAGTL.SOURCE_LANG);
      end if;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

END AME_APPROVAL_GROUPS_LOAD_API;

/
