--------------------------------------------------------
--  DDL for Package Body AME_CONFIG_VARS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONFIG_VARS_API" as
/* $Header: amecvapi.pkb 120.6 2005/11/14 06:03 sbadiger noship $ */
  procedure KEY_TO_IDS
    (X_APPLICATION_SHORT_NAME   in            varchar2
    ,X_TRANSACTION_TYPE_ID      in            varchar2
    ,X_APPLICATION_ID              out nocopy number
    ) as
  begin
    if X_APPLICATION_SHORT_NAME is null then
      if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is not null and to_number(AME_SEED_UTILITY.AME_INSTALLATION_LEVEL) >= 2 then
        X_APPLICATION_ID := 0;
      else
        X_APPLICATION_ID := null;
      end if;
    else
      begin
        select ACA.APPLICATION_ID
          into X_APPLICATION_ID
          from AME_CALLING_APPS ACA,
               FND_APPLICATION_VL FAV
         where FAV.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
           and FAV.APPLICATION_ID = ACA.FND_APPLICATION_ID
           and ((ACA.TRANSACTION_TYPE_ID is null and X_TRANSACTION_TYPE_ID is null) or
                 ACA.TRANSACTION_TYPE_ID = X_TRANSACTION_TYPE_ID)
           and sysdate between ACA.START_DATE and nvl(ACA.END_DATE - (1/86400),sysdate);
      exception
        when no_data_found then
          raise_application_error(-20001,'AME Transaction Type ' || X_APPLICATION_SHORT_NAME || ',' || X_TRANSACTION_TYPE_ID || ' not found');
      end;
    end if;
  end KEY_TO_IDS;

  procedure FORMAT_ROW
    (X_VARIABLE_NAME            in            varchar2
    ,X_VARIABLE_VALUE           in out nocopy varchar2
    ) as
  begin
    if X_VARIABLE_NAME = 'rulePriorityModes' then
      if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is not null and
         instrb(X_VARIABLE_VALUE,':',1,7) = 0 then
        X_VARIABLE_VALUE := 'disabled:' || X_VARIABLE_VALUE || ':disabled';
      elsif AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null and instrb(X_VARIABLE_VALUE,':',1,7) > 0 then
        X_VARIABLE_VALUE := substrb(X_VARIABLE_VALUE, instrb(X_VARIABLE_VALUE,':', 1, 1)+1);
        X_VARIABLE_VALUE := substrb(X_VARIABLE_VALUE, 1, instrb(X_VARIABLE_VALUE,':',1,6)-1);
      end if;
    end if;
  end FORMAT_ROW;

  function CHK_UPDATE
    (X_VARIABLE_NAME       in varchar2
    ,X_VARIABLE_VALUE      in varchar2
    ,X_APPLICATION_ID      in number
    ) return boolean as
    X_CURRENT_VARIABLE_VALUE  AME_CONFIG_VARS.VARIABLE_VALUE%TYPE;
  begin
    select ACV.VARIABLE_VALUE
      into X_CURRENT_VARIABLE_VALUE
      from AME_CONFIG_VARS ACV
     where ACV.VARIABLE_NAME = X_VARIABLE_NAME
       and ((ACV.APPLICATION_ID is null and X_APPLICATION_ID is null) or
           ACV.APPLICATION_ID = X_APPLICATION_ID)
       and sysdate between ACV.START_DATE and nvl(ACV.END_DATE - (1/86400),sysdate);
    if X_VARIABLE_NAME = 'productionFunctionality' then
      if X_CURRENT_VARIABLE_VALUE = X_VARIABLE_VALUE then
        return true;
      elsif X_CURRENT_VARIABLE_VALUE in ('approver','transaction') then
        if X_VARIABLE_VALUE = 'all' then
          return true;
        else
          return false;
        end if;
      else
        return true;
      end if;
    elsif X_VARIABLE_NAME in ('allowAllApproverTypes'
                             ,'allowFyiNotifications'
                             ,'allowAllItemClassRules') then
      if X_CURRENT_VARIABLE_VALUE = 'yes' and
         X_VARIABLE_VALUE <> X_CURRENT_VARIABLE_VALUE then
        return false;
      else
        return true;
      end if;
    end if;
    return true;
  end CHK_UPDATE;

  procedure INSERT_ROW
    (X_VARIABLE_NAME         in varchar2
    ,X_USER_CONFIG_VAR_NAME  in varchar2
    ,X_APPLICATION_ID        in number
    ,X_VARIABLE_VALUE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    ) as
    X_LOCK_HANDLE             varchar2(500);
    X_RETURN_VALUE            number;
  begin
    DBMS_LOCK.ALLOCATE_UNIQUE
      (LOCKNAME     =>'AME_CONFIG_VARS.'||X_VARIABLE_NAME||X_APPLICATION_ID
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      insert into AME_CONFIG_VARS
        (VARIABLE_NAME
        ,VARIABLE_VALUE
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,START_DATE
        ,END_DATE
        ,APPLICATION_ID
        ,OBJECT_VERSION_NUMBER
        ) select X_VARIABLE_NAME,
                 X_VARIABLE_VALUE,
                 X_DESCRIPTION,
                 X_CREATED_BY,
                 X_CREATION_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATE_LOGIN,
                 X_START_DATE,
                 X_END_DATE,
                 X_APPLICATION_ID,
                 X_OBJECT_VERSION_NUMBER
            from dual where not exists (select null
                                          from AME_CONFIG_VARS
                                         where VARIABLE_NAME = X_VARIABLE_NAME
                                           and (((APPLICATION_ID is null or APPLICATION_ID = 0)
                                           and   (X_APPLICATION_ID is null or X_APPLICATION_ID = 0))
                                            or  (APPLICATION_ID = X_APPLICATION_ID))
                                           and sysdate between START_DATE and nvl(END_DATE - (1/86400), sysdate));

      if not AME_SEED_UTILITY.MLS_ENABLED then
        return;
      end if;
    if(X_APPLICATION_ID = 0 or X_APPLICATION_ID = null) then
      insert into AME_CONFIG_VARS_TL
        (VARIABLE_NAME
        ,USER_CONFIG_VAR_NAME
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,LANGUAGE
        ,SOURCE_LANG
        ) select X_VARIABLE_NAME,
                 nvl(X_USER_CONFIG_VAR_NAME,X_VARIABLE_NAME),
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
                               from AME_CONFIG_VARS_TL T
                              where T.VARIABLE_NAME = X_VARIABLE_NAME
                                and T.LANGUAGE = L.LANGUAGE_CODE);
    end if;
    end if;
  end INSERT_ROW;

  procedure UPDATE_ROW
    (X_VARIABLE_NAME         in varchar2
    ,X_USER_CONFIG_VAR_NAME  in varchar2
    ,X_APPLICATION_ID        in number
    ,X_VARIABLE_VALUE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    ) as
    X_LOCK_HANDLE             varchar2(500);
    X_RETURN_VALUE            number;
  begin

    DBMS_LOCK.ALLOCATE_UNIQUE
      (LOCKNAME     =>'AME_CONFIG_VARS.'||X_VARIABLE_NAME||to_char(nvl(X_APPLICATION_ID,0))
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      update AME_CONFIG_VARS ACV
         set ACV.END_DATE = X_START_DATE
       where ACV.VARIABLE_NAME = X_VARIABLE_NAME
         and ((ACV.APPLICATION_ID is null and X_APPLICATION_ID is null) or
             ACV.APPLICATION_ID = X_APPLICATION_ID)
         and sysdate between ACV.START_DATE and nvl(ACV.END_DATE - (1/86400),sysdate);

      insert into AME_CONFIG_VARS
        (VARIABLE_NAME
        ,APPLICATION_ID
        ,VARIABLE_VALUE
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
        (X_VARIABLE_NAME
        ,X_APPLICATION_ID
        ,X_VARIABLE_VALUE
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
    if(X_APPLICATION_ID = 0 or X_APPLICATION_ID = null) then
      update AME_CONFIG_VARS_TL
         set USER_CONFIG_VAR_NAME = nvl(X_USER_CONFIG_VAR_NAME,USER_CONFIG_VAR_NAME),
             DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where VARIABLE_NAME = X_VARIABLE_NAME
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
     end if;
    end if;
  end UPDATE_ROW;

  procedure FORCE_UPDATE_ROW (
    X_ROWID                      in VARCHAR2,
    X_VARIABLE_NAME              in VARCHAR2,
    X_USER_CONFIG_VAR_NAME       in VARCHAR2,
    X_APPLICATION_ID             in Number,
    X_VARIABLE_VALUE             in VARCHAR2,
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
    update AME_CONFIG_VARS
       set VARIABLE_VALUE = X_VARIABLE_VALUE,
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

    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
   if(X_APPLICATION_ID = 0 or X_APPLICATION_ID = null) then
    update AME_CONFIG_VARS_TL
       set USER_CONFIG_VAR_NAME = nvl(X_USER_CONFIG_VAR_NAME,USER_CONFIG_VAR_NAME),
           DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
           SOURCE_LANG = userenv('LANG'),
           LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
           LAST_UPDATED_BY = X_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN = 0
     where VARIABLE_NAME = X_VARIABLE_NAME
       and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
  end FORCE_UPDATE_ROW;

  procedure LOAD_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_VARIABLE_VALUE         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    L_VARIABLE_NAME           AME_CONFIG_VARS.VARIABLE_NAME%TYPE;
    L_APPLICATION_SHORT_NAME  FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
    L_TRANSACTION_TYPE_ID     AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;
    L_APPLICATION_ID          number;
    L_VARIABLE_VALUE          AME_CONFIG_VARS.VARIABLE_VALUE%TYPE;
    L_USER_CONFIG_VAR_NAME    AME_CONFIG_VARS_TL.USER_CONFIG_VAR_NAME%TYPE;
    L_DESCRIPTION             AME_CONFIG_VARS_TL.DESCRIPTION%TYPE;
    L_OWNER                   varchar2(100);
    L_LAST_UPDATE_DATE        varchar2(19);
    L_END_DATE                date;
    L_DUMMY                   varchar2(1);
    L_OBJECT_VERSION_NUMBER   number;
    L_ROWID                   ROWID;
  begin
    L_VARIABLE_NAME := X_VARIABLE_NAME;
    L_APPLICATION_SHORT_NAME := X_APPLICATION_SHORT_NAME;
    L_TRANSACTION_TYPE_ID := X_TRANSACTION_TYPE_ID;
    L_VARIABLE_VALUE := X_VARIABLE_VALUE;
    L_USER_CONFIG_VAR_NAME := X_USER_CONFIG_VAR_NAME;
    L_DESCRIPTION := X_DESCRIPTION;
    L_OWNER := X_OWNER;
    L_LAST_UPDATE_DATE := X_LAST_UPDATE_DATE;
    L_END_DATE := AME_SEED_UTILITY.GET_DEFAULT_END_DATE;

    KEY_TO_IDS
      (X_APPLICATION_SHORT_NAME    => L_APPLICATION_SHORT_NAME
      ,X_TRANSACTION_TYPE_ID       => L_TRANSACTION_TYPE_ID
      ,X_APPLICATION_ID            => L_APPLICATION_ID
      );
    FORMAT_ROW
      (X_VARIABLE_NAME             => L_VARIABLE_NAME
      ,X_VARIABLE_VALUE            => L_VARIABLE_VALUE
      );
    begin
      select nvl(ACV.OBJECT_VERSION_NUMBER,1),
             ROWID
        into L_OBJECT_VERSION_NUMBER,
             L_ROWID
        from AME_CONFIG_VARS ACV
       where ACV.VARIABLE_NAME = L_VARIABLE_NAME
         and ((ACV.APPLICATION_ID is null and L_APPLICATION_ID is null) or
             ACV.APPLICATION_ID = L_APPLICATION_ID)
         and sysdate between ACV.START_DATE and nvl(ACV.END_DATE - (1/86400),sysdate);

      if CHK_UPDATE
          (X_VARIABLE_NAME   => L_VARIABLE_NAME
          ,X_VARIABLE_VALUE  => L_VARIABLE_VALUE
          ,X_APPLICATION_ID  => L_APPLICATION_ID) then
        if X_CUSTOM_MODE = 'FORCE' then
          FORCE_UPDATE_ROW
            (X_ROWID                 => L_ROWID
            ,X_VARIABLE_NAME         => L_VARIABLE_NAME
            ,X_USER_CONFIG_VAR_NAME  => L_USER_CONFIG_VAR_NAME
            ,X_APPLICATION_ID        => L_APPLICATION_ID
            ,X_VARIABLE_VALUE        => L_VARIABLE_VALUE
            ,X_DESCRIPTION           => L_DESCRIPTION
            ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATE_LOGIN     => 0
            ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_END_DATE              => L_END_DATE
            ,X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
            );
        else
          UPDATE_ROW
            (X_VARIABLE_NAME         => L_VARIABLE_NAME
            ,X_USER_CONFIG_VAR_NAME  => L_USER_CONFIG_VAR_NAME
            ,X_APPLICATION_ID        => L_APPLICATION_ID
            ,X_VARIABLE_VALUE        => L_VARIABLE_VALUE
            ,X_DESCRIPTION           => L_DESCRIPTION
            ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_END_DATE              => L_END_DATE
            ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATE_LOGIN     => 0
            ,X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
            );
        end if;
      end if;
    exception
      when no_data_found then
        INSERT_ROW
          (X_VARIABLE_NAME         => L_VARIABLE_NAME
          ,X_USER_CONFIG_VAR_NAME  => L_USER_CONFIG_VAR_NAME
          ,X_APPLICATION_ID        => L_APPLICATION_ID
          ,X_VARIABLE_VALUE        => L_VARIABLE_VALUE
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
    (X_VARIABLE_NAME          in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ) as
    L_DUMMY                      varchar2(1);
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    begin
      select null
        into L_DUMMY
        from AME_CONFIG_VARS_TL ACVTL
       where ACVTL.VARIABLE_NAME = X_VARIABLE_NAME
         and ACVTL.LANGUAGE = userenv('LANG');

      update AME_CONFIG_VARS_TL ACVTL
         set USER_CONFIG_VAR_NAME = nvl(X_USER_CONFIG_VAR_NAME,ACVTL.USER_CONFIG_VAR_NAME),
             DESCRIPTION = nvl(X_DESCRIPTION,ACVTL.DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             LAST_UPDATE_LOGIN = 0
       where ACVTL.VARIABLE_NAME = X_VARIABLE_NAME
         and userenv('LANG') in (ACVTL.LANGUAGE,ACVTL.SOURCE_LANG);
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

  function MERGE_ROW_TEST
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) return boolean as
    X_CURRENT_OWNER              NUMBER;
    X_CREATED_BY                 varchar2(100);
    X_CURRENT_LAST_UPDATE_DATE   varchar2(19);
  begin
    if X_UPLOAD_MODE = 'NLS' then
      begin
        select ACVTL.LAST_UPDATED_BY,
               AME_SEED_UTILITY.DATE_AS_STRING(ACVTL.LAST_UPDATE_DATE),
               AME_SEED_UTILITY.OWNER_AS_STRING(ACVTL.CREATED_BY)
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE,
               X_CREATED_BY
          from AME_CONFIG_VARS_TL ACVTL
         where ACVTL.VARIABLE_NAME = X_VARIABLE_NAME
           and ACVTL.LANGUAGE = userenv('LANG');
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
        if X_APPLICATION_SHORT_NAME is not null then
          select ACV.LAST_UPDATED_BY,
                 AME_SEED_UTILITY.DATE_AS_STRING(ACV.LAST_UPDATE_DATE)
            into X_CURRENT_OWNER,
                 X_CURRENT_LAST_UPDATE_DATE
            from AME_CONFIG_VARS ACV,
                 AME_CALLING_APPS ACA,
                 FND_APPLICATION_VL FAV
           where FAV.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
             and FAV.APPLICATION_ID = ACA.FND_APPLICATION_ID
             and ((ACA.TRANSACTION_TYPE_ID is null and X_TRANSACTION_TYPE_ID is null) or
                  ACA.TRANSACTION_TYPE_ID = X_TRANSACTION_TYPE_ID)
             and ACV.APPLICATION_ID = ACA.APPLICATION_ID
             and ACV.VARIABLE_NAME = X_VARIABLE_NAME
             and sysdate between ACV.START_DATE and nvl(ACV.END_DATE - (1/86400),sysdate)
             and sysdate between ACA.START_DATE and nvl(ACA.END_DATE - (1/86400),sysdate);
        else
          select ACV.LAST_UPDATED_BY,
                 AME_SEED_UTILITY.DATE_AS_STRING(ACV.LAST_UPDATE_DATE)
            into X_CURRENT_OWNER,
                 X_CURRENT_LAST_UPDATE_DATE
            from AME_CONFIG_VARS ACV
           where (ACV.APPLICATION_ID is null or ACV.APPLICATION_ID = 0)
             and ACV.VARIABLE_NAME = X_VARIABLE_NAME
             and sysdate between ACV.START_DATE and nvl(ACV.END_DATE - (1/86400),sysdate);
        end if;
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
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_VARIABLE_VALUE         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    X_ATTRIBUTE_VALUE         varchar2(10);
    X_APPLICATION_NAME        AME_CALLING_APPS.APPLICATION_NAME%TYPE;
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;

    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is not null and
       X_VARIABLE_NAME = 'useWorkflow' then
      if X_VARIABLE_VALUE = 'yes' then
        X_ATTRIBUTE_VALUE := 'true';
      else
        X_ATTRIBUTE_VALUE := 'false';
      end if;
      begin
        select ACA.APPLICATION_NAME
          into X_APPLICATION_NAME
          from AME_CALLING_APPS ACA,
               FND_APPLICATION_VL FAV
         where FAV.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
           and FAV.APPLICATION_ID = ACA.FND_APPLICATION_ID
           and ((X_TRANSACTION_TYPE_ID is null and ACA.TRANSACTION_TYPE_ID is null) or
                X_TRANSACTION_TYPE_ID = ACA.TRANSACTION_TYPE_ID)
           and sysdate between ACA.START_DATE and nvl(ACA.END_DATE - (1/86400),sysdate);
      exception
        when no_data_found then
          X_APPLICATION_NAME := X_APPLICATION_SHORT_NAME;
      end;
      AME_ATTRIBUTE_USAGES_API.LOAD_SEED_ROW
        (X_ATTRIBUTE_NAME     => 'USE_WORKFLOW'
        ,X_APPLICATION_NAME   => X_APPLICATION_NAME
        ,X_QUERY_STRING       => X_ATTRIBUTE_VALUE
        ,X_USER_EDITABLE      => 'Y'
        ,X_IS_STATIC          => 'Y'
        ,X_USE_COUNT          => 0
        ,X_VALUE_SET_NAME     => null
        ,X_OWNER              => X_OWNER
        ,X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE
        ,X_UPLOAD_MODE        => X_UPLOAD_MODE
        ,X_CUSTOM_MODE        => X_CUSTOM_MODE
        );
      return;
    end if;

    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      if X_VARIABLE_NAME in ('allowAllApproverTypes'
                            ,'allowFyiNotifications'
                            ,'allowAllItemClassRules'
                            ,'productionFunctionality') then
        return;
      elsif X_VARIABLE_NAME = 'repeatedApprovers' and
            X_VARIABLE_VALUE not in ('ONCE_PER_TRANSACTION'
                                    ,'ONCE_PER_SUBLIST'
                                    ,'ONCE_PER_GROUP_OR_CHAIN') then
        return;
      end if;
    elsif AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is not null and to_number(AME_SEED_UTILITY.AME_INSTALLATION_LEVEL) >= 2 then
      if X_VARIABLE_NAME in ('helpPath'
                            ,'htmlPath'
                            ,'imagePath'
                            ,'portalUrl') then
        return;
      end if;
    end if;

    if MERGE_ROW_TEST
         (X_VARIABLE_NAME           => X_VARIABLE_NAME
         ,X_APPLICATION_SHORT_NAME  => X_APPLICATION_SHORT_NAME
         ,X_TRANSACTION_TYPE_ID     => X_TRANSACTION_TYPE_ID
         ,X_OWNER                   => X_OWNER
         ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
         ,X_UPLOAD_MODE             => X_UPLOAD_MODE
         ,X_CUSTOM_MODE             => X_CUSTOM_MODE
         ) then
      if X_UPLOAD_MODE = 'NLS' then
        TRANSLATE_ROW
          (X_VARIABLE_NAME           => X_VARIABLE_NAME
          ,X_USER_CONFIG_VAR_NAME    => X_USER_CONFIG_VAR_NAME
          ,X_DESCRIPTION             => X_DESCRIPTION
          ,X_OWNER                   => X_OWNER
          ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
          );
      else
        LOAD_ROW
          (X_VARIABLE_NAME           => X_VARIABLE_NAME
          ,X_APPLICATION_SHORT_NAME  => X_APPLICATION_SHORT_NAME
          ,X_TRANSACTION_TYPE_ID     => X_TRANSACTION_TYPE_ID
          ,X_USER_CONFIG_VAR_NAME    => X_USER_CONFIG_VAR_NAME
          ,X_VARIABLE_VALUE          => X_VARIABLE_VALUE
          ,X_DESCRIPTION             => X_DESCRIPTION
          ,X_OWNER                   => X_OWNER
          ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
          ,X_CUSTOM_MODE             => X_CUSTOM_MODE
          );
      end if;
    end if;
  end LOAD_SEED_ROW;

  procedure DELETE_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_ID         in number
    ) as
  begin
    delete from AME_CONFIG_VARS
     where VARIABLE_NAME = X_VARIABLE_NAME
       and nvl(APPLICATION_ID,0) = nvl(X_APPLICATION_ID,0);
    if sql%notfound then
      raise no_data_found;
    end if;
    if AME_SEED_UTILITY.MLS_ENABLED then
      delete from AME_CONFIG_VARS_TL
      where VARIABLE_NAME = X_VARIABLE_NAME;
    end if;
  end DELETE_ROW;

end AME_CONFIG_VARS_API;

/
