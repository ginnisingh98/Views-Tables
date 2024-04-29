--------------------------------------------------------
--  DDL for Package Body AME_PRODUCTION_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_PRODUCTION_ACTIONS_API" as
/* $Header: amepaapi.pkb 120.1 2005/10/14 04:13 ubhat noship $ */
  procedure KEY_TO_IDS
    (X_ACTION_TYPE_NAME   in            varchar2
    ,X_ACTION_TYPE_ID        out nocopy number
    ) as
  begin
    begin
      select AAT.ACTION_TYPE_ID
        into X_ACTION_TYPE_ID
        from AME_ACTION_TYPES AAT
       where AAT.NAME = X_ACTION_TYPE_NAME
         and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate);
    exception
      when no_data_found then
        raise_application_error(-20001,'AME Action Type ' || X_ACTION_TYPE_NAME || ' not found');
    end;
  end KEY_TO_IDS;

  procedure VALIDATE_ROW
    (X_ACTION_TYPE_NAME    in varchar2
    ) as
  begin
    if X_ACTION_TYPE_NAME <> 'production rule' then
      raise_application_error(-20001,'AME is trying to upload an unsupported production action');
    end if;
  end VALIDATE_ROW;

  procedure INSERT_ROW
    (X_ACTION_TYPE_ID         in number
    ,X_PARAMETER              in varchar2
    ,X_PARAMETER_TWO          in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_START_DATE             in date
    ,X_END_DATE               in date
    ,X_CREATED_BY             in number
    ,X_CREATION_DATE          in date
    ,X_LAST_UPDATED_BY        in number
    ,X_LAST_UPDATE_DATE       in date
    ,X_LAST_UPDATE_LOGIN      in number
    ,X_OBJECT_VERSION_NUMBER  in number
    ) as
    X_ACTION_ID                  number;
  begin
    select AME_ACTIONS_S.NEXTVAL
      into X_ACTION_ID
      from dual;

    insert into AME_ACTIONS
      (ACTION_ID
      ,ACTION_TYPE_ID
      ,PARAMETER
      ,PARAMETER_TWO
      ,DESCRIPTION
      ,START_DATE
      ,END_DATE
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,OBJECT_VERSION_NUMBER
      ) select X_ACTION_ID,
               X_ACTION_TYPE_ID,
               X_PARAMETER,
               X_PARAMETER_TWO,
               X_DESCRIPTION,
               X_START_DATE,
               X_END_DATE,
               X_CREATED_BY,
               X_CREATION_DATE,
               X_LAST_UPDATED_BY,
               X_LAST_UPDATE_DATE,
               X_LAST_UPDATE_LOGIN,
               X_OBJECT_VERSION_NUMBER
          from dual
         where not exists (select null
                             from AME_ACTIONS
                            where ACTION_TYPE_ID = X_ACTION_TYPE_ID
                              and PARAMETER = X_PARAMETER
                              and PARAMETER_TWO = X_PARAMETER_TWO
                              and sysdate between START_DATE and nvl(END_DATE - (1/86400), sysdate));

    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    insert into AME_ACTIONS_TL
      (ACTION_ID
      ,DESCRIPTION
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,LANGUAGE
      ,SOURCE_LANG
      ) select X_ACTION_ID,
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
                             from AME_ACTIONS_TL T
                            where T.ACTION_ID = X_ACTION_ID
                              and T.LANGUAGE = L.LANGUAGE_CODE);

  end INSERT_ROW;

  procedure UPDATE_ROW
    (X_ACTION_ID             in number
    ,X_ACTION_TYPE_ID        in number
    ,X_PARAMETER             in varchar2
    ,X_PARAMETER_TWO         in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    ) as
    X_LOCK_HANDLE             varchar2(500);
    X_RETURN_VALUE            number;
  begin

    DBMS_LOCK.ALLOCATE_UNIQUE
      (LOCKNAME     =>'AME_ACTIONS.'||X_ACTION_ID
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      update AME_ACTIONS ACT
         set ACT.END_DATE = X_START_DATE
       where ACT.ACTION_ID = X_ACTION_ID
         and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate);

      insert into AME_ACTIONS
        (ACTION_ID
        ,ACTION_TYPE_ID
        ,PARAMETER
        ,PARAMETER_TWO
        ,DESCRIPTION
        ,START_DATE
        ,END_DATE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER
        ) values
        (X_ACTION_ID
        ,X_ACTION_TYPE_ID
        ,X_PARAMETER
        ,X_PARAMETER_TWO
        ,X_DESCRIPTION
        ,X_START_DATE
        ,X_END_DATE
        ,X_CREATED_BY
        ,X_CREATION_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATE_LOGIN
        ,X_OBJECT_VERSION_NUMBER
        );

      if not AME_SEED_UTILITY.MLS_ENABLED then
        return;
      end if;

      update AME_ACTIONS_TL
         set DESCRIPTION = X_DESCRIPTION,
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where ACTION_ID = X_ACTION_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
    end if;
  end UPDATE_ROW;

  procedure FORCE_UPDATE_ROW (
    X_ROWID                      in VARCHAR2,
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
    update AME_ACTIONS
       set DESCRIPTION = X_DESCRIPTION,
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

  procedure LOAD_ROW
    (X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_DESCRIPTION        in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) as
    L_ACTION_TYPE_ID         number;
    L_ACTION_ID              number;
    L_END_DATE               date;
    L_PARAMETER              AME_ACTIONS.PARAMETER%TYPE;
    L_PARAMETER_TWO          AME_ACTIONS.PARAMETER_TWO%TYPE;
    L_DESCRIPTION            AME_ACTIONS_TL.DESCRIPTION%TYPE;
    L_ACTION_TYPE_NAME       AME_ACTION_TYPES.NAME%TYPE;
    L_OWNER                  varchar2(100);
    L_LAST_UPDATE_DATE       varchar2(19);
    L_OBJECT_VERSION_NUMBER  number;
    L_ROWID                  ROWID;
  begin
    L_ACTION_TYPE_NAME := X_ACTION_TYPE_NAME;
    L_PARAMETER := X_PARAMETER;
    L_PARAMETER_TWO := X_PARAMETER_TWO;
    L_DESCRIPTION := X_DESCRIPTION;
    L_OWNER := X_OWNER;
    L_LAST_UPDATE_DATE := X_LAST_UPDATE_DATE;
    L_END_DATE := AME_SEED_UTILITY.GET_DEFAULT_END_DATE;

    VALIDATE_ROW
      (X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME);

    KEY_TO_IDS
      (X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME
      ,X_ACTION_TYPE_ID       => L_ACTION_TYPE_ID
      );

    begin
      select ACT.ACTION_ID,
             nvl(ACT.OBJECT_VERSION_NUMBER,1),
             ACT.ROWID
        into L_ACTION_ID,
             L_OBJECT_VERSION_NUMBER,
             L_ROWID
        from AME_ACTIONS ACT
       where ACT.ACTION_TYPE_ID = L_ACTION_TYPE_ID
         and ACT.PARAMETER = L_PARAMETER
         and ACT.PARAMETER_TWO = L_PARAMETER_TWO
         and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate);

      if X_CUSTOM_MODE = 'FORCE' then
        FORCE_UPDATE_ROW
          (X_ROWID                 => L_ROWID
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_LAST_UPDATE_LOGIN     => 0
          ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_END_DATE              => L_END_DATE
          ,X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER + 1
          );
      else
        UPDATE_ROW
          (X_ACTION_ID             => L_ACTION_ID
          ,X_ACTION_TYPE_ID        => L_ACTION_TYPE_ID
          ,X_PARAMETER             => L_PARAMETER
          ,X_PARAMETER_TWO         => L_PARAMETER_TWO
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_END_DATE              => L_END_DATE
          ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_LAST_UPDATE_LOGIN     => 0
          ,X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER + 1
          );
      end if;
    exception
      when no_data_found then
        INSERT_ROW
          (X_ACTION_TYPE_ID        => L_ACTION_TYPE_ID
          ,X_PARAMETER             => L_PARAMETER
          ,X_PARAMETER_TWO         => L_PARAMETER_TWO
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_END_DATE              => L_END_DATE
          ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATE_LOGIN     => 0
          ,X_OBJECT_VERSION_NUMBER => 1
          );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW
    (X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_DESCRIPTION        in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ) as
    L_ACTION_TYPE_ID      number;
    L_ACTION_ID           number;
    L_PARAMETER           AME_ACTIONS.PARAMETER%TYPE;
    L_PARAMETER_TWO       AME_ACTIONS.PARAMETER_TWO%TYPE;
    L_DESCRIPTION         AME_ACTIONS_TL.DESCRIPTION%TYPE;
    L_ACTION_TYPE_NAME    AME_ACTION_TYPES.NAME%TYPE;
    L_OWNER               varchar2(100);
    L_LAST_UPDATE_DATE    varchar2(19);
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    L_ACTION_TYPE_NAME := X_ACTION_TYPE_NAME;
    L_PARAMETER := X_PARAMETER;
    L_PARAMETER_TWO := X_PARAMETER_TWO;
    L_DESCRIPTION := X_DESCRIPTION;
    L_OWNER := X_OWNER;
    L_LAST_UPDATE_DATE := X_LAST_UPDATE_DATE;

    VALIDATE_ROW
      (X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME);

    KEY_TO_IDS
      (X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME
      ,X_ACTION_TYPE_ID       => L_ACTION_TYPE_ID
      );

    begin
      select ACT.ACTION_ID
        into L_ACTION_ID
        from AME_ACTIONS_TL ACTTL,
             AME_ACTIONS ACT
       where ACT.ACTION_TYPE_ID = L_ACTION_TYPE_ID
         and ACT.ACTION_ID = ACTTL.ACTION_ID
         and ACT.PARAMETER = L_PARAMETER
         and ACT.PARAMETER_TWO = L_PARAMETER_TWO
         and ACTTL.LANGUAGE = userenv('LANG')
         and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate);

      update AME_ACTIONS_TL ACTTL
         set DESCRIPTION = nvl(L_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER),
             LAST_UPDATE_LOGIN = 0
       where ACTTL.ACTION_ID = L_ACTION_ID
         and userenv('LANG') in (ACTTL.LANGUAGE,ACTTL.SOURCE_LANG);
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

  function MERGE_ROW_TEST
    (X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_UPLOAD_MODE        in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) return boolean as
    X_CURRENT_OWNER              NUMBER;
    X_CREATED_BY                 varchar2(100);
    X_CURRENT_LAST_UPDATE_DATE   varchar2(19);
  begin
    if X_UPLOAD_MODE = 'NLS' then
      begin
        select ACTTL.LAST_UPDATED_BY,
               AME_SEED_UTILITY.DATE_AS_STRING(ACTTL.LAST_UPDATE_DATE),
               AME_SEED_UTILITY.OWNER_AS_STRING(ACTTL.CREATED_BY)
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE,
               X_CREATED_BY
          from AME_ACTIONS_TL ACTTL,
               AME_ACTIONS ACT,
               AME_ACTION_TYPES AAT
         where ACT.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
           and ACTTL.ACTION_ID = ACT.ACTION_ID
           and AAT.NAME = X_ACTION_TYPE_NAME
           and ACT.PARAMETER = X_PARAMETER
           and ACT.PARAMETER_TWO = X_PARAMETER_TWO
           and ACTTL.LANGUAGE = userenv('LANG')
           and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate)
           and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate);
        if AME_SEED_UTILITY.IS_SEED_USER(X_CREATED_BY) then
          return true;
        else
          return AME_SEED_UTILITY.TL_MERGE_ROW_TEST
                   (X_CURRENT_OWNER             => X_CURRENT_OWNER
                   ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
                   ,X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER)
                   ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
                   ,X_CUSTOM_MODE               => X_CUSTOM_MODE
                   );
        end if;
      exception
        when no_data_found then
          return true;
      end;
    else
      begin
        select ACT.LAST_UPDATED_BY,
               AME_SEED_UTILITY.DATE_AS_STRING(ACT.LAST_UPDATE_DATE)
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE
          from AME_ACTIONS ACT,
               AME_ACTION_TYPES AAT
         where ACT.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
           and AAT.NAME = X_ACTION_TYPE_NAME
           and ACT.PARAMETER = X_PARAMETER
           and ACT.PARAMETER_TWO = X_PARAMETER_TWO
           and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate)
           and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate);
        return AME_SEED_UTILITY.MERGE_ROW_TEST
                 (X_CURRENT_OWNER             => X_CURRENT_OWNER
                 ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
                 ,X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER)
                 ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
                 ,X_CUSTOM_MODE               => X_CUSTOM_MODE
                 );
      exception
        when no_data_found then
          return true;
      end;
    end if;
  end MERGE_ROW_TEST;

  procedure LOAD_SEED_ROW
    (X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_DESCRIPTION        in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_UPLOAD_MODE        in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) as
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;

    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      raise_application_error (-20001,'AME is trying to upload production actions to a 11.5.9 or lower instance');
    end if;

    if MERGE_ROW_TEST
         (X_ACTION_TYPE_NAME   => X_ACTION_TYPE_NAME
         ,X_PARAMETER          => X_PARAMETER
         ,X_PARAMETER_TWO      => X_PARAMETER_TWO
         ,X_OWNER              => X_OWNER
         ,X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE
         ,X_UPLOAD_MODE        => X_UPLOAD_MODE
         ,X_CUSTOM_MODE        => X_CUSTOM_MODE
         ) then
      if X_UPLOAD_MODE = 'NLS' then
        TRANSLATE_ROW
          (X_ACTION_TYPE_NAME   => X_ACTION_TYPE_NAME
          ,X_PARAMETER          => X_PARAMETER
          ,X_PARAMETER_TWO      => X_PARAMETER_TWO
          ,X_DESCRIPTION        => X_DESCRIPTION
          ,X_OWNER              => X_OWNER
          ,X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE
          );
      else
        LOAD_ROW
          (X_ACTION_TYPE_NAME   => X_ACTION_TYPE_NAME
          ,X_PARAMETER          => X_PARAMETER
          ,X_PARAMETER_TWO      => X_PARAMETER_TWO
          ,X_DESCRIPTION        => X_DESCRIPTION
          ,X_OWNER              => X_OWNER
          ,X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE
          ,X_CUSTOM_MODE        => X_CUSTOM_MODE
          );
      end if;
    end if;
  end LOAD_SEED_ROW;

  procedure DELETE_ROW
    (X_ACTION_ID              in number
    ) as
  begin
    if AME_SEED_UTILITY.MLS_ENABLED then
      delete from AME_ACTIONS_TL
      where ACTION_ID = X_ACTION_ID;
    end if;
    delete from AME_ACTIONS
     where ACTION_ID = X_ACTION_ID;
    if sql%notfound then
      raise no_data_found;
    end if;
  end DELETE_ROW;

end AME_PRODUCTION_ACTIONS_API;

/
