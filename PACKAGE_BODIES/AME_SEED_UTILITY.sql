--------------------------------------------------------
--  DDL for Package Body AME_SEED_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_SEED_UTILITY" as
/* $Header: ameseedutility.pkb 120.5 2008/04/11 05:29:46 prasashe noship $ */
  procedure INIT_AME_INSTALLATION_LEVEL as
  begin
   AME_INSTALLATION_LEVEL := FND_PROFILE.VALUE('AME_INSTALLATION_LEVEL');
  end INIT_AME_INSTALLATION_LEVEL;

  function OWNER_AS_STRING
    (X_LAST_UPDATED_BY   in number
    ) return varchar2 as
  begin
    return FND_LOAD_UTIL.OWNER_NAME(X_LAST_UPDATED_BY);
  end OWNER_AS_STRING;

  function OWNER_AS_INTEGER
    (X_LAST_UPDATED_BY   in varchar2
    ) return number as
  begin
    return FND_LOAD_UTIL.OWNER_ID(X_LAST_UPDATED_BY);
  end OWNER_AS_INTEGER;

  function DATE_AS_STRING
    (X_LAST_UPDATE_DATE  in date
    ) return varchar2 as
  begin
    return to_char(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS');
  end DATE_AS_STRING;

  function DATE_AS_DATE
    (X_LAST_UPDATE_DATE  in varchar2
    ) return date as
  begin
    return to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS');
  end DATE_AS_DATE;

  function IS_SEED_USER
    (X_USER    in VARCHAR2
    ) return boolean as
    L_USER_ID INTEGER;
  begin
    L_USER_ID := FND_LOAD_UTIL.OWNER_ID(X_USER);
    if L_USER_ID in (1,2,120,121) then
      return true;
    else
      return false;
    end if;
  end IS_SEED_USER;

  function SEED_USER_ID return integer as
  begin
    return 1;
  end SEED_USER_ID;

  function SEED_USER_NAME return varchar2 as
  begin
    return FND_LOAD_UTIL.OWNER_NAME(1);
  end SEED_USER_NAME;

  function MERGE_ROW_TEST
    (X_CURRENT_OWNER              in number
    ,X_CURRENT_LAST_UPDATE_DATE   in varchar2
    ,X_OWNER                      in number
    ,X_LAST_UPDATE_DATE           in varchar2
    ,X_CUSTOM_MODE                in varchar2
    ) return boolean as
  begin
    if X_CUSTOM_MODE = 'FORCE' then
      return true;
    end if;
    if X_LAST_UPDATE_DATE = X_CURRENT_LAST_UPDATE_DATE then
      return false;
    end if;
    return FND_LOAD_UTIL.UPLOAD_TEST
      (P_FILE_ID              => X_OWNER
      ,P_FILE_LUD             => DATE_AS_DATE     (X_LAST_UPDATE_DATE)
      ,P_DB_ID                => X_CURRENT_OWNER
      ,P_DB_LUD               => DATE_AS_DATE     (X_CURRENT_LAST_UPDATE_DATE)
      ,P_CUSTOM_MODE          => X_CUSTOM_MODE
      );
  end MERGE_ROW_TEST;

  function TL_MERGE_ROW_TEST
    (X_CURRENT_OWNER              in number
    ,X_CURRENT_LAST_UPDATE_DATE   in varchar2
    ,X_OWNER                      in number
    ,X_LAST_UPDATE_DATE           in varchar2
    ,X_CUSTOM_MODE                in varchar2
    ) return boolean as
  begin
    return FND_LOAD_UTIL.UPLOAD_TEST
      (P_FILE_ID              => X_OWNER
      ,P_FILE_LUD             => DATE_AS_DATE     (X_LAST_UPDATE_DATE)
      ,P_DB_ID                => X_CURRENT_OWNER
      ,P_DB_LUD               => DATE_AS_DATE     (X_CURRENT_LAST_UPDATE_DATE)
      ,P_CUSTOM_MODE          => X_CUSTOM_MODE
      );
  end TL_MERGE_ROW_TEST;

  function GET_DEFAULT_END_DATE return date as
  begin
    INIT_AME_INSTALLATION_LEVEL;
    if AME_INSTALLATION_LEVEL is not null and to_number(AME_INSTALLATION_LEVEL) >= 2 then
      return END_OF_TIME;
    else
      return null;
    end if;
  end GET_DEFAULT_END_DATE;

  function CALCULATE_USE_COUNT(X_ATTRIBUTE_ID ame_attribute_usages.attribute_id%type
                              ,X_APPLICATION_ID ame_attribute_usages.application_id%type) return integer as
    cursor RULE_CURSOR(X_APPLICATION_ID  in integer) is
    select  AME_RULE_USAGES.RULE_ID, AME_RULES.ACTION_ID
      from AME_RULES, AME_RULE_USAGES
     where AME_RULES.RULE_ID =  AME_RULE_USAGES.RULE_ID
       and AME_RULE_USAGES.ITEM_ID = X_APPLICATION_ID
       and ((sysdate between AME_RULES.START_DATE
              and nvl(AME_RULES.END_DATE - (1/86400), sysdate))
        or (sysdate < AME_RULES.START_DATE
              and AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,
                            AME_RULES.START_DATE + (1/86400))))
       and ((sysdate between AME_RULE_USAGES.START_DATE
       and nvl(AME_RULE_USAGES.END_DATE - (1/86400), sysdate))
        or (sysdate < AME_RULE_USAGES.START_DATE
       and AME_RULE_USAGES.START_DATE < nvl(AME_RULE_USAGES.END_DATE,
                            AME_RULE_USAGES.START_DATE + (1/86400))));
      RULE_COUNT integer;
      TEMP_COUNT integer;
      NEW_USE_COUNT integer;
  begin
    NEW_USE_COUNT := 0;
    for TEMPRULE in RULE_CURSOR(X_APPLICATION_ID => X_APPLICATION_ID) loop
      select count(*)
      into TEMP_COUNT
      from AME_CONDITIONS,
           AME_CONDITION_USAGES
      where
       AME_CONDITIONS.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
       AME_CONDITIONS.CONDITION_ID = AME_CONDITION_USAGES.CONDITION_ID and
       AME_CONDITION_USAGES.RULE_ID = TEMPRULE.RULE_ID and
       sysdate between AME_CONDITIONS.START_DATE and
                 nvl(AME_CONDITIONS.END_DATE - (1/86400), sysdate) and
       ((sysdate between AME_CONDITION_USAGES.START_DATE and
             nvl(AME_CONDITION_USAGES.END_DATE - (1/86400), sysdate)) or
        (sysdate < AME_CONDITION_USAGES.START_DATE and
         AME_CONDITION_USAGES.START_DATE < nvl(AME_CONDITION_USAGES.END_DATE,
                            AME_CONDITION_USAGES.START_DATE + (1/86400))));
      if(TEMP_COUNT > 0) then
        NEW_USE_COUNT := NEW_USE_COUNT + 1;
      else
        if(TEMPRULE.ACTION_ID is null) then
           -- action_id is already migrated from ame_rules to ame_action_usages
          select count(*)
          into TEMP_COUNT
          from
            AME_MANDATORY_ATTRIBUTES,
            AME_ACTIONS,
            AME_ACTION_USAGES
          where
           AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
           AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
           AME_ACTIONS.ACTION_ID = AME_ACTION_USAGES.ACTION_ID and
           AME_ACTION_USAGES.RULE_ID = TEMPRULE.RULE_ID and
           sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE and
                     nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate) and
           sysdate between AME_ACTIONS.START_DATE and
                     nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate) and
           ((sysdate between AME_ACTION_USAGES.START_DATE and
                      nvl(AME_ACTION_USAGES.END_DATE - (1/86400), sysdate)) or
            (sysdate < AME_ACTION_USAGES.START_DATE and
             AME_ACTION_USAGES.START_DATE < nvl(AME_ACTION_USAGES.END_DATE,
                                AME_ACTION_USAGES.START_DATE + (1/86400))));
        else
          select count(*)
          into TEMP_COUNT
          from
            AME_MANDATORY_ATTRIBUTES,
            AME_ACTIONS,
            AME_RULES
          where
           AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
           AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
           AME_ACTIONS.ACTION_ID = AME_RULES.ACTION_ID and
           AME_RULES.RULE_ID = TEMPRULE.RULE_ID and
           sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE and
                     nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate) and
           sysdate between AME_ACTIONS.START_DATE and
                     nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate) and
           ((sysdate between AME_RULES.START_DATE and
                      nvl(AME_RULES.END_DATE - (1/86400), sysdate)) or
            (sysdate < AME_RULES.START_DATE and
             AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,
                                AME_RULES.START_DATE + (1/86400))));
        end if;
        if(TEMP_COUNT > 0) then
           NEW_USE_COUNT := NEW_USE_COUNT + 1;
        end if;
      end if;
    end loop;
  return(NEW_USE_COUNT);
  exception
    when others then
      ame_util.runtimeException('ame_seed_utility',
                                'calculate_use_count',
                                sqlcode,
                                sqlerrm);
      raise;
      return(null);
  end CALCULATE_USE_COUNT;

  function MLS_ENABLED return boolean as
  begin
    INIT_AME_INSTALLATION_LEVEL;
    if AME_INSTALLATION_LEVEL is not null and to_number(AME_INSTALLATION_LEVEL) >= 2 then
      return true;
    else
      return false;
    end if;
  end MLS_ENABLED;

  function USER_ID_OF_SEED_USER return integer as
  begin
    return FND_LOAD_UTIL.OWNER_ID(P_NAME => SEED_USER_NAME);
  end;

  procedure CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID ame_rule_usages.rule_id%type
                                         ,X_APPLICATION_ID ame_rule_usages.item_id%type) is
    cursor GET_USED_ATTRIBUTES (X_RULE_ID ame_rule_usages.rule_id%type) is
      select AME_CONDITIONS.ATTRIBUTE_ID
      from  AME_CONDITIONS,
        AME_CONDITION_USAGES
      where
        AME_CONDITIONS.CONDITION_TYPE in (AME_UTIL.ORDINARYCONDITIONTYPE,
                                          AME_UTIL.EXCEPTIONCONDITIONTYPE) and
        AME_CONDITION_USAGES.RULE_ID = X_RULE_ID and
        AME_CONDITION_USAGES.CONDITION_ID = AME_CONDITIONS.CONDITION_ID and
        (AME_CONDITIONS.START_DATE <= sysdate and
          (AME_CONDITIONS.END_DATE is null or sysdate < AME_CONDITIONS.END_DATE)) and
        ((sysdate between AME_CONDITION_USAGES.START_DATE and
             nvl(AME_CONDITION_USAGES.END_DATE - (1/86400), sysdate)) or
         (sysdate < AME_CONDITION_USAGES.START_DATE and
          AME_CONDITION_USAGES.START_DATE < nvl(AME_CONDITION_USAGES.END_DATE,
                           AME_CONDITION_USAGES.START_DATE + (1/86400))))
        union
        select AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID
        from AME_MANDATORY_ATTRIBUTES,
         AME_ACTION_USAGES,
         AME_ACTIONS
        where
         AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
         AME_ACTIONS.ACTION_ID = AME_ACTION_USAGES.ACTION_ID and
         AME_ACTION_USAGES.RULE_ID = X_RULE_ID and
         (AME_MANDATORY_ATTRIBUTES.START_DATE <= sysdate and
         (AME_MANDATORY_ATTRIBUTES.END_DATE is null or sysdate < AME_MANDATORY_ATTRIBUTES.END_DATE)) and
         ((sysdate between AME_ACTION_USAGES.START_DATE and
             nvl(AME_ACTION_USAGES.END_DATE - (1/86400), sysdate)) or
           (sysdate < AME_ACTION_USAGES.START_DATE and
           AME_ACTION_USAGES.START_DATE < nvl(AME_ACTION_USAGES.END_DATE,AME_ACTION_USAGES.START_DATE
                                                   + (1/86400)))) and
          (AME_ACTIONS.START_DATE <= sysdate and
          (AME_ACTIONS.END_DATE is null or sysdate < AME_ACTIONS.END_DATE))
        union
        select AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID
        from AME_MANDATORY_ATTRIBUTES,
         AME_RULES,
         AME_ACTIONS
        where
         AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
         AME_ACTIONS.ACTION_ID = AME_RULES.ACTION_ID and
         AME_RULES.ACTION_ID is not null and
         AME_RULES.RULE_ID = X_RULE_ID and
         (AME_MANDATORY_ATTRIBUTES.START_DATE <= sysdate and
         (AME_MANDATORY_ATTRIBUTES.END_DATE is null or sysdate < AME_MANDATORY_ATTRIBUTES.END_DATE)) and
         ((sysdate between AME_RULES.START_DATE and
             nvl(AME_RULES.END_DATE - (1/86400), sysdate)) or
          (sysdate < AME_RULES.START_DATE and
           AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,AME_RULES.START_DATE
                                                   + (1/86400)))) and
          (AME_ACTIONS.START_DATE <= sysdate and
          (AME_ACTIONS.END_DATE is null or sysdate < AME_ACTIONS.END_DATE));
    ATTRIBUTE_IDS_LIST ame_util.idList;
    X_USE_COUNT ame_attribute_usages.use_count%type;
  begin
    for ATTRIBUTE_REC in GET_USED_ATTRIBUTES(X_RULE_ID => X_RULE_ID) loop
      -- calculate use count
      X_USE_COUNT := CALCULATE_USE_COUNT(ATTRIBUTE_REC.ATTRIBUTE_ID, X_APPLICATION_ID);
      -- update ame_attribute_usages
      update AME_ATTRIBUTE_USAGES
      set  USE_COUNT = X_USE_COUNT
      where
       ATTRIBUTE_ID = ATTRIBUTE_REC.ATTRIBUTE_ID and
       APPLICATION_ID = X_APPLICATION_ID and
       sysdate between START_DATE and
                 nvl(END_DATE - (1/86400), sysdate);
    end loop;
  end CHANGE_ATTRIBUTE_USAGES_COUNT;

  PROCEDURE CREATE_PARALLEL_CONFIG
    (X_ACTION_TYPE_ID IN INTEGER
    ,X_ACTION_TYPE_NAME IN VARCHAR2
    ,X_ACTION_ID IN INTEGER
    ,X_APPROVAL_GROUP_ID IN INTEGER
    ) AS
    CURSOR GROUP_ACTION_TYPE_CURSOR IS
      SELECT NULL
        FROM AME_ACTION_TYPES
       WHERE SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE)
         AND ACTION_TYPE_ID = X_ACTION_TYPE_ID
         AND NAME IN ('PRE-CHAIN-OF-AUTHORITY APPROVALS'
                     ,'POST-CHAIN-OF-AUTHORITY APPROVALS'
                     ,'APPROVAL-GROUP CHAIN OF AUTHORITY');
    CURSOR APPLICATION_USING_RULE_CURSOR IS
      SELECT DISTINCT
             ACA.APPLICATION_ID,
             ACA.START_DATE,
             ACA.END_DATE,
             ACA.CREATED_BY,
             ACA.CREATION_DATE
        FROM AME_CALLING_APPS ACA,
             AME_RULES AR,
             AME_RULE_USAGES ARU,
             AME_ACTION_USAGES AAU
       WHERE ACA.APPLICATION_ID = ARU.ITEM_ID
         AND ARU.RULE_ID = AR.RULE_ID
         AND AR.RULE_ID = AAU.RULE_ID
         AND AAU.ACTION_ID = X_ACTION_ID
         AND SYSDATE BETWEEN ACA.START_DATE AND NVL(ACA.END_DATE,SYSDATE)
         AND (SYSDATE BETWEEN AR.START_DATE AND NVL(AR.END_DATE,SYSDATE) OR
              AR.START_DATE > SYSDATE AND NVL(AR.END_DATE,AR.START_DATE + (1/86400)) < AR.START_DATE)
         AND (SYSDATE BETWEEN ARU.START_DATE AND NVL(ARU.END_DATE,SYSDATE) OR
              ARU.START_DATE > SYSDATE AND NVL(ARU.END_DATE,ARU.START_DATE + (1/86400)) < ARU.START_DATE)
         AND (SYSDATE BETWEEN AAU.START_DATE AND NVL(AAU.END_DATE,SYSDATE) OR
              AAU.START_DATE > SYSDATE AND NVL(AAU.END_DATE,AAU.START_DATE + (1/86400)) < AAU.START_DATE);
    CURSOR MAX_AT_ORDER_NUMBER_CURSOR(C_APPLICATION_ID INTEGER) IS
      SELECT MAX(ORDER_NUMBER) + 1
        FROM AME_ACTION_TYPE_CONFIG
       WHERE APPLICATION_ID = C_APPLICATION_ID
         AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);
    CURSOR MAX_AG_ORDER_NUMBER_CURSOR(C_APPLICATION_ID INTEGER) IS
      SELECT MAX(ORDER_NUMBER) + 1
        FROM AME_APPROVAL_GROUP_CONFIG
       WHERE APPLICATION_ID = C_APPLICATION_ID
         AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);
    CURSOR COA_ACTION_TYPE_CURSOR IS
      SELECT NULL
        FROM AME_ACTION_TYPE_USAGES
       WHERE ACTION_TYPE_ID = X_ACTION_TYPE_ID
         AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE)
         AND RULE_TYPE = AME_UTIL.AUTHORITYRULETYPE;
    X_DUMMY VARCHAR2(10);
    X_ORDER_NUMBER INTEGER;
    X_GROUP_BASED_ACTION VARCHAR2(1);
    X_VOTING_REGIME VARCHAR2(1);
    X_ACTION_TYPE_ORDER_NUMBER INTEGER;
    X_APPLICATION_ID INTEGER;
    X_ACA_START_DATE DATE;
    X_ACA_END_DATE DATE;
    X_ACA_CREATED_BY INTEGER;
    X_ACA_CREATION_DATE DATE;
    LOCKHANDLE VARCHAR2(500);
    RETURNVALUE INTEGER;
  BEGIN
    INIT_AME_INSTALLATION_LEVEL;
    IF AME_INSTALLATION_LEVEL IS NULL OR TO_NUMBER(AME_INSTALLATION_LEVEL)  < 2 THEN
      RETURN;
    END IF;
    OPEN COA_ACTION_TYPE_CURSOR;
    FETCH COA_ACTION_TYPE_CURSOR INTO X_VOTING_REGIME;
    IF COA_ACTION_TYPE_CURSOR%NOTFOUND THEN
      X_VOTING_REGIME := NULL;
    ELSE
      X_VOTING_REGIME := AME_UTIL.SERIALIZEDVOTING;
    END IF;
    CLOSE COA_ACTION_TYPE_CURSOR;

    OPEN GROUP_ACTION_TYPE_CURSOR;
    FETCH GROUP_ACTION_TYPE_CURSOR INTO X_DUMMY;
    IF GROUP_ACTION_TYPE_CURSOR%FOUND THEN
      X_GROUP_BASED_ACTION := 'Y';
    ELSE
      X_GROUP_BASED_ACTION := 'N';
    END IF;
    CLOSE GROUP_ACTION_TYPE_CURSOR;

    OPEN APPLICATION_USING_RULE_CURSOR;
    LOOP
      FETCH APPLICATION_USING_RULE_CURSOR
       INTO X_APPLICATION_ID,
            X_ACA_START_DATE,
            X_ACA_END_DATE,
            X_ACA_CREATED_BY,
            X_ACA_CREATION_DATE;
      EXIT WHEN APPLICATION_USING_RULE_CURSOR%NOTFOUND;
      BEGIN
        SELECT NULL
          INTO X_DUMMY
          FROM AME_ACTION_TYPE_CONFIG
         WHERE ACTION_TYPE_ID = X_ACTION_TYPE_ID
           AND APPLICATION_ID = X_APPLICATION_ID
           AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          OPEN MAX_AT_ORDER_NUMBER_CURSOR(X_APPLICATION_ID);
          FETCH MAX_AT_ORDER_NUMBER_CURSOR INTO X_ORDER_NUMBER;
          IF MAX_AT_ORDER_NUMBER_CURSOR%NOTFOUND THEN
            X_ORDER_NUMBER := 1;
          END IF;
          CLOSE MAX_AT_ORDER_NUMBER_CURSOR;
          IF X_ORDER_NUMBER IS NULL THEN
            X_ORDER_NUMBER := 1;
          END IF;
          SELECT DECODE (X_ACTION_TYPE_NAME,
                         AME_UTIL.PREAPPROVALTYPENAME, 1,
                         AME_UTIL.DYNAMICPREAPPROVER, 2,
                         AME_UTIL.ABSOLUTEJOBLEVELTYPENAME, 1,
                         AME_UTIL.RELATIVEJOBLEVELTYPENAME, 2,
                         AME_UTIL.SUPERVISORYLEVELTYPENAME, 3,
                         AME_UTIL.POSITIONTYPENAME, 4,
                         AME_UTIL.POSITIONLEVELTYPENAME, 5,
                         AME_UTIL.MANAGERFINALAPPROVERTYPENAME, 6,
                         AME_UTIL.FINALAPPROVERONLYTYPENAME, 7,
                         AME_UTIL.LINEITEMJOBLEVELTYPENAME, 8,
                         AME_UTIL.DUALCHAINSAUTHORITYTYPENAME, 9,
                         AME_UTIL.GROUPCHAINAPPROVALTYPENAME, 10,
                         AME_UTIL.NONFINALAUTHORITY, 1,
                         AME_UTIL.FINALAUTHORITYTYPENAME, 2,
                         AME_UTIL.SUBSTITUTIONTYPENAME, 1,
                         AME_UTIL.POSTAPPROVALTYPENAME, 1,
                         AME_UTIL.DYNAMICPOSTAPPROVER, 2,
                         X_ORDER_NUMBER)
            INTO X_ACTION_TYPE_ORDER_NUMBER
            FROM DUAL;
          DBMS_LOCK.ALLOCATE_UNIQUE (LOCKNAME =>'AME_ACTION_TYPE_CONFIG.'||X_APPLICATION_ID||X_ACTION_TYPE_ID
                                     ,LOCKHANDLE => LOCKHANDLE);
          RETURNVALUE := DBMS_LOCK.REQUEST(LOCKHANDLE => LOCKHANDLE,TIMEOUT => 0
                                           ,RELEASE_ON_COMMIT => TRUE);
          IF RETURNVALUE = 0  THEN
            INSERT INTO AME_ACTION_TYPE_CONFIG
              (APPLICATION_ID
              ,ACTION_TYPE_ID
              ,VOTING_REGIME
              ,ORDER_NUMBER
              ,CHAIN_ORDERING_MODE
              ,START_DATE
              ,END_DATE
              ,CREATED_BY
              ,CREATION_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ,OBJECT_VERSION_NUMBER
              ) SELECT X_APPLICATION_ID
                      ,X_ACTION_TYPE_ID
                      ,X_VOTING_REGIME
                      ,X_ACTION_TYPE_ORDER_NUMBER
                      ,AME_UTIL.SERIALCHAINSMODE
                      ,X_ACA_START_DATE
                      ,X_ACA_END_DATE
                      ,X_ACA_CREATED_BY
                      ,X_ACA_CREATION_DATE
                      ,X_ACA_CREATED_BY
                      ,X_ACA_CREATION_DATE
                      ,0
                      ,1
                 FROM DUAL
                WHERE NOT EXISTS (SELECT NULL
                                    FROM AME_ACTION_TYPE_CONFIG
                                   WHERE ACTION_TYPE_ID = X_ACTION_TYPE_ID
                                     AND APPLICATION_ID = X_APPLICATION_ID
                                     AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE - (1/86400),SYSDATE));
        END IF;
      END;
      IF X_GROUP_BASED_ACTION = 'Y' THEN
        BEGIN
          SELECT NULL
            INTO X_DUMMY
            FROM AME_APPROVAL_GROUP_CONFIG
           WHERE SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE)
             AND APPLICATION_ID = X_APPLICATION_ID
             AND APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            OPEN MAX_AG_ORDER_NUMBER_CURSOR(X_APPLICATION_ID);
            FETCH MAX_AG_ORDER_NUMBER_CURSOR INTO X_ORDER_NUMBER;
            IF MAX_AG_ORDER_NUMBER_CURSOR%NOTFOUND THEN
              X_ORDER_NUMBER := 1;
            END IF;
            IF X_ORDER_NUMBER IS NULL THEN
              X_ORDER_NUMBER := 1;
            END IF;
            CLOSE MAX_AG_ORDER_NUMBER_CURSOR;
            DBMS_LOCK.ALLOCATE_UNIQUE (LOCKNAME =>'AME_APPROVAL_GROUP_CONFIG.'||X_APPLICATION_ID||X_APPROVAL_GROUP_ID
                                       ,LOCKHANDLE => LOCKHANDLE);
            RETURNVALUE := DBMS_LOCK.REQUEST(LOCKHANDLE => LOCKHANDLE,TIMEOUT => 0
                                             ,RELEASE_ON_COMMIT => TRUE);
            IF RETURNVALUE = 0  THEN
              INSERT INTO AME_APPROVAL_GROUP_CONFIG
                (APPLICATION_ID
                ,APPROVAL_GROUP_ID
                ,VOTING_REGIME
                ,ORDER_NUMBER
                ,START_DATE
                ,END_DATE
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
                ,OBJECT_VERSION_NUMBER
                ) SELECT X_APPLICATION_ID
                        ,X_APPROVAL_GROUP_ID
                        ,AME_UTIL.ORDERNUMBERVOTING
                        ,X_ORDER_NUMBER
                        ,X_ACA_START_DATE
                        ,X_ACA_END_DATE
                        ,X_ACA_CREATED_BY
                        ,X_ACA_CREATION_DATE
                        ,X_ACA_CREATED_BY
                        ,X_ACA_CREATION_DATE
                        ,0
                        ,1
                   FROM DUAL
                  WHERE NOT EXISTS (SELECT NULL
                                      FROM AME_APPROVAL_GROUP_CONFIG
                                     WHERE APPROVAL_GROUP_ID = X_APPROVAL_GROUP_ID
                                       AND APPLICATION_ID = X_APPLICATION_ID
                                       AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE - (1/86400),SYSDATE));
          END IF;
        END;
      END IF;
    END LOOP;
    CLOSE APPLICATION_USING_RULE_CURSOR;
  END CREATE_PARALLEL_CONFIG;

end AME_SEED_UTILITY;

/
