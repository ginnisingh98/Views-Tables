--------------------------------------------------------
--  DDL for Package Body AME_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATTRIBUTES_API" as
/* $Header: ameatapi.pkb 120.5.12010000.2 2008/12/26 11:01:04 prasashe ship $ */
  procedure VALIDATE_ROW
    (X_ATTRIBUTE_TYPE         in varchar2) as
  begin
    if X_ATTRIBUTE_TYPE not in ('boolean'
                               ,'number'
                               ,'string'
                               ,'currency'
                               ,'date') then
      raise_application_error (-20001,'AME is trying to upload a attribute of invalid type ' || X_ATTRIBUTE_TYPE);
    end if;
  end VALIDATE_ROW;

  procedure KEY_TO_IDS
    (X_ATTRIBUTE_NAME    in            varchar2
    ,X_ORIG_SYSTEM       in            varchar2
    ,X_ITEM_CLASS_NAME   in            varchar2
    ,X_LINE_ITEM         in out nocopy varchar2
    ,X_APPROVER_TYPE_ID     out nocopy number
    ,X_ITEM_CLASS_ID        out nocopy number
    ) as
    L_ORIG_SYSTEM                      AME_APPROVER_TYPES.ORIG_SYSTEM%TYPE;
  begin
    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      X_APPROVER_TYPE_ID := null;
      X_ITEM_CLASS_ID := 0;
      if X_ITEM_CLASS_NAME is not null then
        if X_ITEM_CLASS_NAME = 'header' then
          X_LINE_ITEM := 'N';
        else
          X_LINE_ITEM := 'Y';
        end if;
      end if;
    else
      if X_ORIG_SYSTEM is null then
        if X_ATTRIBUTE_NAME in ('FIRST_STARTING_POINT_PERSON_ID',
                                'JOB_LEVEL_NON_DEFAULT_STARTING_POINT_PERSON_ID',
                                'LINE_ITEM_STARTING_POINT_PERSON_ID',
                                'SECOND_STARTING_POINT_PERSON_ID',
                                'SUPERVISORY_NON_DEFAULT_STARTING_POINT_PERSON_ID',
                                'TOP_SUPERVISOR_PERSON_ID',
                                'TRANSACTION_REQUESTOR_PERSON_ID') then
          L_ORIG_SYSTEM := 'PER';
        elsif X_ATTRIBUTE_NAME in ('TRANSACTION_REQUESTOR_USER_ID') then
          L_ORIG_SYSTEM := 'FND_USR';
        else
          L_ORIG_SYSTEM := null;
        end if;
      else
        L_ORIG_SYSTEM := X_ORIG_SYSTEM;
      end if;
      if L_ORIG_SYSTEM is null then
        X_APPROVER_TYPE_ID := null;
      else
        begin
          select AAT.APPROVER_TYPE_ID
            into X_APPROVER_TYPE_ID
            from AME_APPROVER_TYPES AAT
           where AAT.ORIG_SYSTEM = L_ORIG_SYSTEM
             and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate);
        exception
          when no_data_found then
            X_APPROVER_TYPE_ID := null;
        end;
      end if;
      if X_ITEM_CLASS_NAME is null and X_LINE_ITEM is not null then
        if X_LINE_ITEM = 'Y' then
          begin
            X_LINE_ITEM := null;
            select AIC.ITEM_CLASS_ID
              into X_ITEM_CLASS_ID
              from AME_ITEM_CLASSES AIC
             where AIC.NAME = 'line item'
               and sysdate between AIC.START_DATE and nvl(AIC.END_DATE - (1/86400),sysdate);
          exception
            when no_data_found then
              X_ITEM_CLASS_ID := 2;
          end;
        else
          begin
            X_LINE_ITEM := null;
            select AIC.ITEM_CLASS_ID
              into X_ITEM_CLASS_ID
              from AME_ITEM_CLASSES AIC
             where AIC.NAME = 'header'
               and sysdate between AIC.START_DATE and nvl(AIC.END_DATE - (1/86400),sysdate);
          exception
            when no_data_found then
              X_ITEM_CLASS_ID := 1;
          end;
        end if;
      else
        begin
          X_LINE_ITEM := null;
          select AIC.ITEM_CLASS_ID
            into X_ITEM_CLASS_ID
            from AME_ITEM_CLASSES AIC
           where AIC.NAME = X_ITEM_CLASS_NAME
             and sysdate between AIC.START_DATE and nvl(AIC.END_DATE - (1/86400),sysdate);
        exception
          when no_data_found then
            X_ITEM_CLASS_ID := 1;
        end;
      end if;
    end if;
  end KEY_TO_IDS;

  procedure FORMAT_KEY
    (X_ATTRIBUTE_NAME         in out nocopy varchar2
    ) as
  begin
    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      if X_ATTRIBUTE_NAME = 'EVALUATE_PRIORITIES_PER_ITEM' then
        X_ATTRIBUTE_NAME := 'EVALUATE_PRIORITIES_PER_LINE_ITEM';
      elsif X_ATTRIBUTE_NAME = 'USE_RESTRICTIVE_ITEM_EVALUATION' then
        X_ATTRIBUTE_NAME := 'USE_RESTRICTIVE_LINE_ITEM_EVALUATION';
      end if;
    else
      if X_ATTRIBUTE_NAME = 'EVALUATE_PRIORITIES_PER_LINE_ITEM' then
        X_ATTRIBUTE_NAME := 'EVALUATE_PRIORITIES_PER_ITEM';
      elsif X_ATTRIBUTE_NAME = 'USE_RESTRICTIVE_LINE_ITEM_EVALUATION' then
        X_ATTRIBUTE_NAME := 'USE_RESTRICTIVE_ITEM_EVALUATION';
      end if;
    end if;
  end FORMAT_KEY;

  procedure INSERT_ROW
    (X_ATTRIBUTE_NAME        in varchar2
    ,X_ATTRIBUTE_TYPE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_LINE_ITEM             in varchar2
    ,X_ITEM_CLASS_ID         in number
    ,X_APPROVER_TYPE_ID      in number
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    ) as
    X_ATTRIBUTE_ID            number;
    X_LOCK_HANDLE             varchar2(500);
    X_RETURN_VALUE            number;
  begin
    DBMS_LOCK.ALLOCATE_UNIQUE
      (LOCKNAME     =>'AME_ATTRIBUTES.'||X_ATTRIBUTE_NAME
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      select AME_ATTRIBUTES_S.NEXTVAL
        into X_ATTRIBUTE_ID
        from dual;

      insert into AME_ATTRIBUTES
        (ATTRIBUTE_ID
        ,NAME
        ,ATTRIBUTE_TYPE
        ,DESCRIPTION
        ,LINE_ITEM
        ,ITEM_CLASS_ID
        ,APPROVER_TYPE_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,START_DATE
        ,END_DATE
        ,OBJECT_VERSION_NUMBER
        ) select X_ATTRIBUTE_ID,
                 X_ATTRIBUTE_NAME,
                 X_ATTRIBUTE_TYPE,
                 X_DESCRIPTION,
                 X_LINE_ITEM,
                 X_ITEM_CLASS_ID,
                 X_APPROVER_TYPE_ID,
                 X_CREATED_BY,
                 X_CREATION_DATE,
                 X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_DATE,
                 X_LAST_UPDATE_LOGIN,
                 X_START_DATE,
                 X_END_DATE,
                 X_OBJECT_VERSION_NUMBER
            from dual where not exists (select null
                                          from AME_ATTRIBUTES
                                         where NAME = X_ATTRIBUTE_NAME
                                           and sysdate between START_DATE and nvl(END_DATE - (1/86400), sysdate));

      if not AME_SEED_UTILITY.MLS_ENABLED then
        return;
      end if;

      insert into AME_ATTRIBUTES_TL
        (ATTRIBUTE_ID
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,LANGUAGE
        ,SOURCE_LANG
        ) select X_ATTRIBUTE_ID,
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
                               from AME_ATTRIBUTES_TL T
                              where T.ATTRIBUTE_ID = X_ATTRIBUTE_ID
                                and T.LANGUAGE = L.LANGUAGE_CODE);
    end if;
  end INSERT_ROW;

  procedure UPDATE_ROW
    (X_ATTRIBUTE_ID          in number
    ,X_ATTRIBUTE_NAME        in varchar2
    ,X_ATTRIBUTE_TYPE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_LINE_ITEM             in varchar2
    ,X_ITEM_CLASS_ID         in number
    ,X_APPROVER_TYPE_ID      in number
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
    l_current_start_date      date;
  begin

    DBMS_LOCK.ALLOCATE_UNIQUE
      (LOCKNAME     =>'AME_ATTRIBUTES.'||X_ATTRIBUTE_ID
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      begin
        select START_DATE
          into l_current_start_date
          from AME_ATTRIBUTES
         where ATTRIBUTE_ID = X_ATTRIBUTE_ID
           and sysdate between START_DATE and nvl(END_DATE-(1/86400),sysdate);
        if l_current_start_date >= X_CREATION_DATE then
          return;
        end if;
      exception
        when others then
         null;
      end;
      begin
        update AME_ATTRIBUTES AA
           set AA.END_DATE = X_START_DATE
         where AA.ATTRIBUTE_ID = X_ATTRIBUTE_ID
           and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate);
      exception
        when DUP_VAL_ON_INDEX then
           update AME_ATTRIBUTES AA
              set END_DATE = X_START_DATE - (1/86400)
            where AA.ATTRIBUTE_ID = X_ATTRIBUTE_ID
              and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate);
      end;

      insert into AME_ATTRIBUTES
        (ATTRIBUTE_ID
        ,NAME
        ,ATTRIBUTE_TYPE
        ,DESCRIPTION
        ,LINE_ITEM
        ,ITEM_CLASS_ID
        ,APPROVER_TYPE_ID
        ,START_DATE
        ,END_DATE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER
        ) values
        (X_ATTRIBUTE_ID
        ,X_ATTRIBUTE_NAME
        ,X_ATTRIBUTE_TYPE
        ,X_DESCRIPTION
        ,X_LINE_ITEM
        ,X_ITEM_CLASS_ID
        ,X_APPROVER_TYPE_ID
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

      update AME_ATTRIBUTES_TL
         set DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where ATTRIBUTE_ID = X_ATTRIBUTE_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
    end if;
  end UPDATE_ROW;

  procedure FORCE_UPDATE_ROW (
    X_ROWID                      in VARCHAR2,
    X_ATTRIBUTE_ID               in number,
    X_ATTRIBUTE_TYPE             in varchar2,
    X_DESCRIPTION                in varchar2,
    X_LINE_ITEM                  in varchar2,
    X_ITEM_CLASS_ID              in number,
    X_APPROVER_TYPE_ID           in number,
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
    update AME_ATTRIBUTES
       set ATTRIBUTE_TYPE = X_ATTRIBUTE_TYPE,
           DESCRIPTION = X_DESCRIPTION,
           LINE_ITEM = X_LINE_ITEM,
           ITEM_CLASS_ID = X_ITEM_CLASS_ID,
           APPROVER_TYPE_ID = X_APPROVER_TYPE_ID,
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

    update AME_ATTRIBUTES_TL
       set DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
           SOURCE_LANG = userenv('LANG'),
           LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
           LAST_UPDATED_BY = X_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN = 0
     where ATTRIBUTE_ID = X_ATTRIBUTE_ID
       and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
  end FORCE_UPDATE_ROW;

  procedure LOAD_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_ATTRIBUTE_TYPE         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_LINE_ITEM              in varchar2
    ,X_ORIG_SYSTEM            in varchar2
    ,X_ITEM_CLASS_NAME        in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    L_ATTRIBUTE_NAME          AME_ATTRIBUTES.NAME%TYPE;
    L_ATTRIBUTE_TYPE          AME_ATTRIBUTES.ATTRIBUTE_TYPE%TYPE;
    L_DESCRIPTION             AME_ATTRIBUTES_TL.DESCRIPTION%TYPE;
    L_LINE_ITEM               AME_ATTRIBUTES.LINE_ITEM%TYPE;
    L_ORIG_SYSTEM             AME_APPROVER_TYPES.ORIG_SYSTEM%TYPE;
    L_ITEM_CLASS_NAME         AME_ITEM_CLASSES.NAME%TYPE;
    L_ITEM_CLASS_ID           number;
    L_APPROVER_TYPE_ID        number;
    L_ATTRIBUTE_ID            number;
    L_OWNER                   varchar2(100);
    L_LAST_UPDATE_DATE        varchar2(19);
    L_END_DATE                date;
    L_DUMMY                   varchar2(1);
    L_OBJECT_VERSION_NUMBER   number;
    L_ROWID                   ROWID;
  begin
    L_ATTRIBUTE_NAME := X_ATTRIBUTE_NAME;
    L_ATTRIBUTE_TYPE := X_ATTRIBUTE_TYPE;
    L_DESCRIPTION := X_DESCRIPTION;
    L_LINE_ITEM := X_LINE_ITEM;
    L_ORIG_SYSTEM := X_ORIG_SYSTEM;
    L_ITEM_CLASS_NAME := X_ITEM_CLASS_NAME;
    L_OWNER := X_OWNER;
    L_LAST_UPDATE_DATE := X_LAST_UPDATE_DATE;
    L_END_DATE := AME_SEED_UTILITY.GET_DEFAULT_END_DATE;

    VALIDATE_ROW
      (X_ATTRIBUTE_TYPE     => L_ATTRIBUTE_TYPE);

    KEY_TO_IDS
      (X_ATTRIBUTE_NAME            => L_ATTRIBUTE_NAME
      ,X_ORIG_SYSTEM               => L_ORIG_SYSTEM
      ,X_ITEM_CLASS_NAME           => L_ITEM_CLASS_NAME
      ,X_LINE_ITEM                 => L_LINE_ITEM
      ,X_APPROVER_TYPE_ID          => L_APPROVER_TYPE_ID
      ,X_ITEM_CLASS_ID             => L_ITEM_CLASS_ID
      );

    begin
      select AA.ATTRIBUTE_ID,
             nvl(AA.OBJECT_VERSION_NUMBER,1),
             ROWID
        into L_ATTRIBUTE_ID,
             L_OBJECT_VERSION_NUMBER,
             L_ROWID
        from AME_ATTRIBUTES AA
       where AA.NAME = X_ATTRIBUTE_NAME
         and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate);

      if X_CUSTOM_MODE = 'FORCE' then
        FORCE_UPDATE_ROW
          (X_ROWID                 => L_ROWID
          ,X_ATTRIBUTE_ID          => L_ATTRIBUTE_ID
          ,X_ATTRIBUTE_TYPE        => L_ATTRIBUTE_TYPE
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_LINE_ITEM             => L_LINE_ITEM
          ,X_ITEM_CLASS_ID         => L_ITEM_CLASS_ID
          ,X_APPROVER_TYPE_ID      => L_APPROVER_TYPE_ID
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
          (X_ATTRIBUTE_ID          => L_ATTRIBUTE_ID
          ,X_ATTRIBUTE_NAME        => L_ATTRIBUTE_NAME
          ,X_ATTRIBUTE_TYPE        => L_ATTRIBUTE_TYPE
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_LINE_ITEM             => L_LINE_ITEM
          ,X_APPROVER_TYPE_ID      => L_APPROVER_TYPE_ID
          ,X_ITEM_CLASS_ID         => L_ITEM_CLASS_ID
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
          (X_ATTRIBUTE_NAME        => L_ATTRIBUTE_NAME
          ,X_ATTRIBUTE_TYPE        => L_ATTRIBUTE_TYPE
          ,X_DESCRIPTION           => L_DESCRIPTION
          ,X_LINE_ITEM             => L_LINE_ITEM
          ,X_APPROVER_TYPE_ID      => L_APPROVER_TYPE_ID
          ,X_ITEM_CLASS_ID         => L_ITEM_CLASS_ID
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
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ) as
    X_ATTRIBUTE_ID               number;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    begin
      select AA.ATTRIBUTE_ID
        into X_ATTRIBUTE_ID
        from AME_ATTRIBUTES_TL AATL,
             AME_ATTRIBUTES AA
       where AA.NAME = X_ATTRIBUTE_NAME
         and AA.ATTRIBUTE_ID = AATL.ATTRIBUTE_ID
         and AATL.LANGUAGE = userenv('LANG')
         and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate);

      update AME_ATTRIBUTES_TL AATL
         set DESCRIPTION = nvl(X_DESCRIPTION,AATL.DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             LAST_UPDATE_LOGIN = 0
       where AATL.ATTRIBUTE_ID = X_ATTRIBUTE_ID
         and userenv('LANG') in (AATL.LANGUAGE,AATL.SOURCE_LANG);
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

  function MERGE_ROW_TEST
    (X_ATTRIBUTE_NAME          in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) return boolean as
    X_CURRENT_OWNER              NUMBER;
    X_CURRENT_LAST_UPDATE_DATE   varchar2(19);
    X_CREATED_BY                 varchar2(100);
  begin
    if X_UPLOAD_MODE = 'NLS' then
      begin
        select AATL.LAST_UPDATED_BY,
               AME_SEED_UTILITY.DATE_AS_STRING(AATL.LAST_UPDATE_DATE),
               AME_SEED_UTILITY.OWNER_AS_STRING(AATL.CREATED_BY)
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE,
               X_CREATED_BY
          from AME_ATTRIBUTES_TL AATL,
               AME_ATTRIBUTES AA
         where AATL.ATTRIBUTE_ID = AA.ATTRIBUTE_ID
           and AA.NAME = X_ATTRIBUTE_NAME
           and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate)
           and AATL.LANGUAGE = userenv('LANG');
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
        select AA.LAST_UPDATED_BY,
               AME_SEED_UTILITY.DATE_AS_STRING(AA.LAST_UPDATE_DATE)
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE
          from AME_ATTRIBUTES AA
         where AA.NAME = X_ATTRIBUTE_NAME
           and sysdate between AA.START_DATE and nvl(AA.END_DATE - (1/86400),sysdate);
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
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_ATTRIBUTE_TYPE         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_LINE_ITEM              in varchar2
    ,X_ORIG_SYSTEM            in varchar2
    ,X_ITEM_CLASS_NAME        in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    L_ATTRIBUTE_NAME          AME_ATTRIBUTES.NAME%TYPE;
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;

    L_ATTRIBUTE_NAME := X_ATTRIBUTE_NAME;

    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      if X_ITEM_CLASS_NAME is not null and
         X_ITEM_CLASS_NAME not in ('header'
                                  ,'line item') then
        return;
      end if;
      if X_ATTRIBUTE_NAME in ('USE_WORKFLOW'
                             ,'REJECTION_RESPONSE'
                             ,'REPEAT_SUBSTITUTIONS'
                             ,'NON_DEFAULT_STARTING_POINT_POSITION_ID'
                             ,'NON_DEFAULT_POSITION_STRUCTURE_ID'
                             ,'TRANSACTION_REQUESTOR_POSITION_ID'
                             ,'TOP_POSITION_ID') then
        return;
      end if;
    end if;

    FORMAT_KEY
      (X_ATTRIBUTE_NAME             => L_ATTRIBUTE_NAME);

    if MERGE_ROW_TEST
         (X_ATTRIBUTE_NAME          => L_ATTRIBUTE_NAME
         ,X_OWNER                   => X_OWNER
         ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
         ,X_UPLOAD_MODE             => X_UPLOAD_MODE
         ,X_CUSTOM_MODE             => X_CUSTOM_MODE
         ) then
      if X_UPLOAD_MODE = 'NLS' then
        TRANSLATE_ROW
          (X_ATTRIBUTE_NAME          => L_ATTRIBUTE_NAME
          ,X_DESCRIPTION             => X_DESCRIPTION
          ,X_OWNER                   => X_OWNER
          ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
          );
      else
        LOAD_ROW
          (X_ATTRIBUTE_NAME           => L_ATTRIBUTE_NAME
          ,X_ATTRIBUTE_TYPE           => X_ATTRIBUTE_TYPE
          ,X_DESCRIPTION              => X_DESCRIPTION
          ,X_LINE_ITEM                => X_LINE_ITEM
          ,X_ORIG_SYSTEM              => X_ORIG_SYSTEM
          ,X_ITEM_CLASS_NAME          => X_ITEM_CLASS_NAME
          ,X_OWNER                    => X_OWNER
          ,X_LAST_UPDATE_DATE         => X_LAST_UPDATE_DATE
          ,X_CUSTOM_MODE              => X_CUSTOM_MODE
          );
      end if;
    end if;
  end LOAD_SEED_ROW;

  procedure DELETE_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ) as
  begin
    if AME_SEED_UTILITY.MLS_ENABLED then
      delete from AME_ATTRIBUTES_TL
      where ATTRIBUTE_ID in (select ATTRIBUTE_ID
                               from AME_ATTRIBUTES
                              where NAME = X_ATTRIBUTE_NAME);
    end if;
    delete from AME_ATTRIBUTES
     where NAME = X_ATTRIBUTE_NAME;
    if sql%notfound then
      raise no_data_found;
    end if;
  end DELETE_ROW;

end AME_ATTRIBUTES_API;

/
