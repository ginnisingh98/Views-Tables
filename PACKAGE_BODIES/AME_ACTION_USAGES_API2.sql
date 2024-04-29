--------------------------------------------------------
--  DDL for Package Body AME_ACTION_USAGES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_USAGES_API2" as
/* $Header: ameasapi.pkb 120.5 2006/08/23 14:07:40 pvelugul noship $ */
  procedure KEY_TO_IDS
    (X_RULE_KEY             in            varchar2
    ,X_ACTION_TYPE_NAME     in            varchar2
    ,X_PARAMETER            in            varchar2
    ,X_PARAMETER_TWO        in            varchar2
    ,X_RULE_ID                 out nocopy number
    ,X_ACTION_ID               out nocopy number
    ,X_ACTION_TYPE_ID          out nocopy number
    ) as
  begin
    begin
      select ARU.RULE_ID
        into X_RULE_ID
        from AME_RULES ARU
       where ARU.RULE_KEY = X_RULE_KEY
         and sysdate between ARU.START_DATE and nvl(ARU.END_DATE - (1/86400),sysdate);
    exception
      when no_data_found then
        raise_application_error(-20001,'Cannot find rule with Rule Key ' || X_RULE_KEY);
    end;

    begin
      select ACT.ACTION_ID,
             ACT.ACTION_TYPE_ID
        into X_ACTION_ID,
             X_ACTION_TYPE_ID
        from AME_ACTIONS ACT,
             AME_ACTION_TYPES AAT
       where ACT.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
         and AAT.NAME = X_ACTION_TYPE_NAME
         and nvl(ACT.PARAMETER,'NULL') = nvl(X_PARAMETER,'NULL')
         and nvl(ACT.PARAMETER_TWO,'NULL') = nvl(X_PARAMETER_TWO,'NULL')
         and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate)
         and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate);
    exception
      when no_data_found then
        raise_application_error(-20001,'Cannot find action with Action type ' || X_ACTION_TYPE_NAME ||
                                       ' and Parameters ' || X_PARAMETER || ',' || X_PARAMETER_TWO);
    end;
  end KEY_TO_IDS;

  procedure VALIDATE_ROW
    (X_RULE_KEY            in varchar2) as
    X_RULE_TYPE       number;
  begin
    begin
      select ARU.RULE_TYPE
        into X_RULE_TYPE
        from AME_RULES ARU
       where ARU.RULE_KEY = X_RULE_KEY
         and sysdate between ARU.START_DATE and nvl(ARU.END_DATE - (1/86400),sysdate);
      if X_RULE_TYPE not in (1,2,5,6,7) then
        raise_application_error(-20001,'AME is attempting to upload usages for an invalid rule type');
      end if;
    exception
      when no_data_found then
        raise_application_error(-20001,'Cannot find rule with Rule Key ' || X_RULE_KEY);
    end;
  end VALIDATE_ROW;

  procedure FORMAT_ROW
    (X_ACTION_TYPE_NAME     in            varchar2
    ,X_PARAMETER            in out nocopy varchar2
    ,X_PARAMETER_TWO        in out nocopy varchar2
    ,X_APPROVAL_GROUP_ID       out nocopy varchar2
    ) as
    L_APPROVAL_GROUP_ID                   number;
  begin
    if X_ACTION_TYPE_NAME in
         ('pre-chain-of-authority approvals'
         ,'post-chain-of-authority approvals'
         ,'approval-group chain of authority') then
      begin
        select AAG.APPROVAL_GROUP_ID
          into L_APPROVAL_GROUP_ID
          from AME_APPROVAL_GROUPS AAG
         where AAG.NAME = X_PARAMETER
           and sysdate between AAG.START_DATE and nvl(AAG.END_DATE - (1/86400),sysdate);
        X_PARAMETER := to_char(L_APPROVAL_GROUP_ID);
        X_PARAMETER_TWO := null;
        X_APPROVAL_GROUP_ID := L_APPROVAL_GROUP_ID;
      exception
        when no_data_found then
          raise_application_error(-20001,'Cannot find approval group ' || X_PARAMETER);
      end;
    end if;
  end FORMAT_ROW;

  procedure CHANGE_RULE_ATTR_USE_COUNT(X_RULE_ID ame_action_usages.rule_id%type) as
    CURSOR CSR_GET_ITEM_IDS
    (
      X_RULE_ID in integer
    ) is
     select ACA.APPLICATION_ID
     from   AME_CALLING_APPS ACA,
            AME_RULE_USAGES ARU
     where  ACA.APPLICATION_ID = ARU.ITEM_ID
       and  ARU.RULE_ID = X_RULE_ID
       and  sysdate between ARU.START_DATE
         and nvl(ARU.END_DATE - (1/86400), sysdate);
  begin
    for TEMP_APPLICATION_ID in CSR_GET_ITEM_IDS(X_RULE_ID => X_RULE_ID) loop
      AME_SEED_UTILITY.CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID         => X_RULE_ID
                                   ,X_APPLICATION_ID  => TEMP_APPLICATION_ID.APPLICATION_ID
                                   );
    end loop;
  end CHANGE_RULE_ATTR_USE_COUNT;

  procedure INSERT_ROW
    (X_ACTION_ID             in number
    ,X_RULE_ID               in number
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
      (LOCKNAME     =>'AME_ACTION_USAGES.'||X_RULE_ID||X_ACTION_ID
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true);

    if X_RETURN_VALUE = 0  then
      insert into AME_ACTION_USAGES
        (ACTION_ID
        ,RULE_ID
        ,START_DATE
        ,END_DATE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER
        ) select X_ACTION_ID,
                 X_RULE_ID,
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
                               from AME_ACTION_USAGES
                              where RULE_ID = X_RULE_ID
                                and ACTION_ID = X_ACTION_ID
                                and sysdate between START_DATE and nvl(END_DATE - (1/86400), sysdate));
      CHANGE_RULE_ATTR_USE_COUNT(X_RULE_ID => X_RULE_ID);
    end if;
  end INSERT_ROW;

  procedure UPDATE_ROW
    (X_ACTION_ID             in number
    ,X_RULE_ID               in number
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
      (LOCKNAME     =>'AME_ACTION_USAGES.'||X_RULE_ID||X_ACTION_ID
      ,LOCKHANDLE   => X_LOCK_HANDLE
      );
    X_RETURN_VALUE := DBMS_LOCK.REQUEST
                        (LOCKHANDLE         => X_LOCK_HANDLE
                        ,TIMEOUT            => 0
                        ,RELEASE_ON_COMMIT  => true
                        );

    if X_RETURN_VALUE = 0  then
      update AME_ACTION_USAGES AAU
         set AAU.END_DATE = X_START_DATE
       where AAU.ACTION_ID = X_ACTION_ID
         and AAU.RULE_ID = X_RULE_ID
         and sysdate between AAU.START_DATE and nvl(AAU.END_DATE - (1/86400),sysdate);

      insert into AME_ACTION_USAGES
        (ACTION_ID
        ,RULE_ID
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
        ,X_RULE_ID
        ,X_START_DATE
        ,X_END_DATE
        ,X_CREATED_BY
        ,X_CREATION_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATE_LOGIN
        ,X_OBJECT_VERSION_NUMBER
        );
    CHANGE_RULE_ATTR_USE_COUNT(X_RULE_ID => X_RULE_ID);
    end if;
  end UPDATE_ROW;

  procedure FORCE_UPDATE_ROW (
    X_ROWID                      in VARCHAR2,
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
    update AME_ACTION_USAGES
       set CREATED_BY = X_CREATED_BY,
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
    (X_RULE_KEY           in varchar2
    ,X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) as
    L_RULE_ID               number;
    L_ACTION_ID             number;
    L_END_DATE              date;
    L_DUMMY                 varchar2(1);
    L_PARAMETER             AME_ACTIONS.PARAMETER%TYPE;
    L_PARAMETER_TWO         AME_ACTIONS.PARAMETER_TWO%TYPE;
    L_ACTION_TYPE_NAME      AME_ACTION_TYPES.NAME%TYPE;
    L_RULE_KEY              AME_RULES.RULE_KEY%TYPE;
    L_OWNER                 varchar2(100);
    L_LAST_UPDATE_DATE      varchar2(19);
    L_OBJECT_VERSION_NUMBER number;
    L_ROWID                 ROWID;
    L_ACTION_TYPE_ID        number;
    L_APPROVAL_GROUP_ID     number;
    L_ACTION_USAGES_COUNT   number;
  begin
    L_RULE_KEY := X_RULE_KEY;
    L_ACTION_TYPE_NAME := X_ACTION_TYPE_NAME;
    L_PARAMETER := X_PARAMETER;
    L_PARAMETER_TWO := X_PARAMETER_TWO;
    L_OWNER := X_OWNER;
    L_LAST_UPDATE_DATE := X_LAST_UPDATE_DATE;
    L_END_DATE := AME_SEED_UTILITY.GET_DEFAULT_END_DATE;

    VALIDATE_ROW
      (X_RULE_KEY             => L_RULE_KEY);

    FORMAT_ROW
      (X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME
      ,X_PARAMETER            => L_PARAMETER
      ,X_PARAMETER_TWO        => L_PARAMETER_TWO
      ,X_APPROVAL_GROUP_ID    => L_APPROVAL_GROUP_ID);

    KEY_TO_IDS
      (X_RULE_KEY             => L_RULE_KEY
      ,X_ACTION_TYPE_NAME     => L_ACTION_TYPE_NAME
      ,X_PARAMETER            => L_PARAMETER
      ,X_PARAMETER_TWO        => L_PARAMETER_TWO
      ,X_RULE_ID              => L_RULE_ID
      ,X_ACTION_ID            => L_ACTION_ID
      ,X_ACTION_TYPE_ID       => L_ACTION_TYPE_ID
      );

    begin
      select nvl(AAU.OBJECT_VERSION_NUMBER,1),
             ROWID
        into L_OBJECT_VERSION_NUMBER,
             L_ROWID
        from AME_ACTION_USAGES AAU
       where AAU.RULE_ID = L_RULE_ID
         and AAU.ACTION_ID = L_ACTION_ID
         and sysdate between AAU.START_DATE and nvl(AAU.END_DATE - (1/86400),sysdate);

      if X_CUSTOM_MODE = 'FORCE' then
        FORCE_UPDATE_ROW
          (X_ROWID                 => L_ROWID
          ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
          ,X_LAST_UPDATE_LOGIN     => 0
          ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
          ,X_END_DATE              => L_END_DATE
          ,X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER + 1
          );
      end if;
    exception
      when no_data_found then
        select count(*)
          into L_ACTION_USAGES_COUNT
          from ame_rules
         where RULE_ID = L_RULE_ID
           and ACTION_ID = L_ACTION_ID
           and sysdate between START_DATE
                         and nvl(END_DATE  - (1/86400), sysdate);

        if L_ACTION_USAGES_COUNT = 0 then
          INSERT_ROW
            (X_ACTION_ID             => L_ACTION_ID
            ,X_RULE_ID               => L_RULE_ID
            ,X_START_DATE            => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_END_DATE              => L_END_DATE
            ,X_CREATED_BY            => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_CREATION_DATE         => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATED_BY       => AME_SEED_UTILITY.OWNER_AS_INTEGER(L_OWNER)
            ,X_LAST_UPDATE_DATE      => AME_SEED_UTILITY.DATE_AS_DATE(L_LAST_UPDATE_DATE)
            ,X_LAST_UPDATE_LOGIN     => 0
            ,X_OBJECT_VERSION_NUMBER => 1
            );
          AME_SEED_UTILITY.CREATE_PARALLEL_CONFIG
            (L_ACTION_TYPE_ID
            ,L_ACTION_TYPE_NAME
            ,L_ACTION_ID
            ,L_APPROVAL_GROUP_ID
            );
        end if;
    end;
  end LOAD_ROW;

  function MERGE_ROW_TEST
    (X_RULE_KEY           in varchar2
    ,X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_UPLOAD_MODE        in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) return boolean as
    X_CURRENT_OWNER              NUMBER;
    X_CURRENT_LAST_UPDATE_DATE   varchar2(19);
  begin
    if X_UPLOAD_MODE = 'NLS' then
      return false;
    else
      begin
        select CUST.OWNER,
               CUST.LAST_UPDATE_DATE
          into X_CURRENT_OWNER,
               X_CURRENT_LAST_UPDATE_DATE
          from (select AAU.LAST_UPDATED_BY OWNER,
                       AME_SEED_UTILITY.DATE_AS_STRING(AAU.LAST_UPDATE_DATE) LAST_UPDATE_DATE
                  from AME_ACTIONS ACT,
                       AME_ACTION_TYPES AAT,
                       AME_RULES ARU,
                       AME_ACTION_USAGES AAU
                 where ACT.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
                   and ACT.ACTION_ID = AAU.ACTION_ID
                   and AAU.RULE_ID = ARU.RULE_ID
                   and AAT.NAME not in
                         ('approval-group chain of authority')
                   and ARU.RULE_TYPE in (1,2,7)
                   and ARU.RULE_KEY = X_RULE_KEY
                   and AAT.NAME = X_ACTION_TYPE_NAME
                   and nvl(ACT.PARAMETER,'NULL') = nvl(X_PARAMETER,'NULL')
                   and nvl(ACT.PARAMETER_TWO,'NULL') = nvl(X_PARAMETER_TWO,'NULL')
                   and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate)
                   and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate)
                   and sysdate between AAU.START_DATE and nvl(AAU.END_DATE - (1/86400),sysdate)
                   and sysdate between ARU.START_DATE and nvl(ARU.END_DATE - (1/86400),sysdate)
                union
                select AAU.LAST_UPDATED_BY OWNER,
                       AME_SEED_UTILITY.DATE_AS_STRING(AAU.LAST_UPDATE_DATE) LAST_UPDATE_DATE
                  from AME_ACTIONS ACT,
                       AME_ACTION_TYPES AAT,
                       AME_RULES ARU,
                       AME_ACTION_USAGES AAU,
                       AME_APPROVAL_GROUPS AAG
                 where ACT.ACTION_TYPE_ID = AAT.ACTION_TYPE_ID
                   and ACT.ACTION_ID = AAU.ACTION_ID
                   and AAU.RULE_ID = ARU.RULE_ID
                   and ACT.PARAMETER = to_char(AAG.APPROVAL_GROUP_ID)
                   and AAT.NAME in
                         ('pre-chain-of-authority approvals'
                         ,'post-chain-of-authority approvals'
                         ,'approval-group chain of authority')
                   and ARU.RULE_TYPE in (1,2,5,6,7)
                   and AAG.IS_STATIC = 'N'
                   and ARU.RULE_KEY = X_RULE_KEY
                   and AAT.NAME = X_ACTION_TYPE_NAME
                   and AAG.NAME = X_PARAMETER
                   and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate)
                   and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate)
                   and sysdate between AAU.START_DATE and nvl(AAU.END_DATE - (1/86400),sysdate)
                   and sysdate between ARU.START_DATE and nvl(ARU.END_DATE - (1/86400),sysdate)
                   and sysdate between AAG.START_DATE and nvl(AAG.END_DATE - (1/86400),sysdate)) CUST;
      exception
        when no_data_found then
          return true;
      end;
    end if;
    return AME_SEED_UTILITY.MERGE_ROW_TEST
             (X_CURRENT_OWNER             => X_CURRENT_OWNER
             ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
             ,X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER)
             ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
             ,X_CUSTOM_MODE               => X_CUSTOM_MODE
             );
  end MERGE_ROW_TEST;

  procedure LOAD_SEED_ROW
    (X_RULE_KEY           in varchar2
    ,X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_UPLOAD_MODE        in varchar2
    ,X_CUSTOM_MODE        in varchar2
    ) as
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;

    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null then
      raise_application_error (-20001,'AME is trying to upload action usages to a 11.5.9 or lower instance');
    end if;

    if X_UPLOAD_MODE = 'NLS' then
      null;
    else
         LOAD_ROW
           (X_RULE_KEY           => X_RULE_KEY
           ,X_ACTION_TYPE_NAME   => X_ACTION_TYPE_NAME
           ,X_PARAMETER          => X_PARAMETER
           ,X_PARAMETER_TWO      => X_PARAMETER_TWO
           ,X_OWNER              => X_OWNER
           ,X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE
           ,X_CUSTOM_MODE        => X_CUSTOM_MODE
           );
    end if;
  end LOAD_SEED_ROW;

end AME_ACTION_USAGES_API2;

/
