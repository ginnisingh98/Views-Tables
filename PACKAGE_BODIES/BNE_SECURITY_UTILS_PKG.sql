--------------------------------------------------------
--  DDL for Package Body BNE_SECURITY_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_SECURITY_UTILS_PKG" as
/* $Header: bnesecutilsb.pls 120.2.12010000.4 2013/12/31 18:12:17 amgonzal ship $ */




--------------------------------------------------------------------------------
--  FUNCTION:           SPLIT_STRING                                         --
--                                                                            --
--  DESCRIPTION:        Replacement for                                       --
--                      DBMS_UTILITIES.DBMS_UTILITY.COMMA_TO_TABLE            --
--                      With support for multibyte characters                 --
--                                                                            --
--  PARAMETERS: FUNCTION_CODE:     VARCHAR2                                   --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-jan-2011  DRAYCHA  Created                                            --
--------------------------------------------------------------------------------

PROCEDURE SPLIT_STRING(VAL IN VARCHAR2, v_count OUT NOCOPY BINARY_INTEGER, v_tab OUT NOCOPY DBMS_UTILITY.UNCL_ARRAY) IS

  I INT := 0;

  VAL_TABLE DBMS_UTILITY.UNCL_ARRAY;
  X VARCHAR(1 char);
  TEMP VARCHAR(500) := '';
  TAB_INDEX INT := 1;
BEGIN

  FOR I IN 1..LENGTH(VAL) LOOP
    X := SUBSTR(VAL, I, 1);
    IF X = ',' THEN
      VAL_TABLE(TAB_INDEX) := TEMP;
      TEMP := '';
      TAB_INDEX := TAB_INDEX + 1;
    ELSE
      TEMP := CONCAT(TEMP,X);
    END IF;
  END LOOP;

  VAL_TABLE(TAB_INDEX) := TEMP;
  VAL_TABLE(TAB_INDEX+1) := '';

  v_count := TAB_INDEX;
  v_tab := VAL_TABLE;
END;


--------------------------------------------------
-- Check a comma separated list of form functions.
-- This routine will check that all form functions
-- exist in the FND_FORM_FUNCTIONS table
--------------------------------------------------
   PROCEDURE CHECK_FUNCTION_EXISTANCE (
    P_SECURITY_VALUE in VARCHAR2
  )
  IS
    v_tab       DBMS_UTILITY.UNCL_ARRAY;
    v_count     BINARY_INTEGER;
    v_list      VARCHAR2(32000);
    v_funcCount INTEGER;
  BEGIN
    v_list := P_SECURITY_VALUE;
    SPLIT_STRING(v_list, v_count, v_tab);
    FOR i IN v_tab.FIRST .. v_tab.LAST -1
    LOOP
      select count(*)
      into v_funcCount
      from FND_FORM_FUNCTIONS
      WHERE FUNCTION_NAME = trim(v_tab(i));

      if v_funcCount = 0 then
        RAISE_APPLICATION_ERROR( -20000,'The supplied function: ' || trim(v_tab(i))|| ' is invalid.');
     end if;
    END LOOP;
  END CHECK_FUNCTION_EXISTANCE;

--------------------------------------------------
-- Check the existance of the specified object in
-- the Web ADI tables.
--------------------------------------------------
  PROCEDURE CHECK_OBJECT_EXISTANCE (
    P_APPLICATION_ID IN NUMBER,
    P_OBJECT_CODE    IN VARCHAR2,
    P_OBJECT_TYPE    IN VARCHAR2
  )
  IS
    VV_DUMMY                 BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
  BEGIN
    --  For different object types, check if object code exists
    IF P_OBJECT_TYPE = 'INTEGRATOR' THEN
      BEGIN
         SELECT INTEGRATOR_CODE
         INTO   VV_DUMMY
         FROM   BNE_INTEGRATORS_B
         WHERE  INTEGRATOR_CODE = P_OBJECT_CODE
         AND    APPLICATION_ID = P_APPLICATION_ID;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR( -20000,'The supplied Object Code: ' || P_OBJECT_CODE|| ' is invalid. Integrator does not exist');
      END;
    ELSIF P_OBJECT_TYPE = 'COMPONENT' THEN
      BEGIN
         SELECT COMPONENT_CODE
         INTO   VV_DUMMY
         FROM   BNE_COMPONENTS_B
         WHERE  COMPONENT_CODE = P_OBJECT_CODE
         AND    APPLICATION_ID = P_APPLICATION_ID;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR( -20000,'The supplied Object Code: ' || P_OBJECT_CODE|| ' is invalid. Component does not exist');
      END;
    ELSIF P_OBJECT_TYPE = 'CONTENT' THEN
      BEGIN
         SELECT CONTENT_CODE
         INTO   VV_DUMMY
         FROM   BNE_CONTENTS_B
         WHERE  CONTENT_CODE = P_OBJECT_CODE
         AND    APPLICATION_ID = P_APPLICATION_ID;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR( -20000,'The supplied Object Code: ' || P_OBJECT_CODE|| ' is invalid. Content does not exist');
      END;
    END IF;
  END CHECK_OBJECT_EXISTANCE;

--------------------------------------------------------------------------------
--  PROCEDURE:           ADD_OBJECT_RULES                                     --
--                                                                            --
--  DESCRIPTION:         Adds security rules for a BNE object e.g. an Integrator
--                       to BNE_SECURED_OBJECT and BNE_SECURITY_RULES         --
--                                                                            --
--  PARAMETERS: P_APPLICATION_ID: Application ID of Object                    --
--              P_OBJECT_CODE: Name of object                                 --
--              P_OBJECT_TYPE: Currently support Object types of 'INTEGRATOR',--
--                 'CONTENT' and 'COMPONENT'.  It is recommended only 'INTEGRATOR'
--                 objects are secured against initially.  Please refer to the--
--                 Web ADI team if you have a stand alone component that needs--
--                 securing.                                                  --
--                 The P_APPLICATION_ID:P_OBJECT_CODE should refer            --
--                 to a record in BNE_INTEGRATORS_B table                     --
--              P_SECURITY_CODE: UNIQUE KEY                                   --
--              P_SECURITY_TYPE: Currently support Security type of 'FUNCTION'--
--              P_SECURITY_VALUE: When Security Type = 'FUNCTION', value is   --
--                  a comma separated list of functions                       --
--              P_USER_ID: User ID                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-Aug-2004  Kdobinso  Created                                            --
--  25-Aug-2004  dagroves  Added more parameter checks                        --
--------------------------------------------------------------------------------
  PROCEDURE ADD_OBJECT_RULES (
    P_APPLICATION_ID in NUMBER,
    P_OBJECT_CODE    in VARCHAR2,
    P_OBJECT_TYPE    in VARCHAR2,
    P_SECURITY_CODE  in VARCHAR2,
    P_SECURITY_TYPE  in VARCHAR2,
    P_SECURITY_VALUE in VARCHAR2,
    P_USER_ID        in NUMBER)
  IS
    VV_OBJECT_TYPE           BNE_SECURED_OBJECTS.OBJECT_TYPE%TYPE;
    VV_SECURITY_TYPE         BNE_SECURITY_RULES.SECURITY_TYPE%TYPE;
    VV_SECURITY_VALUE        BNE_SECURITY_RULES.SECURITY_VALUE%TYPE;
    VN_OBJECT_VERSION_NUMBER CONSTANT NUMBER := 1;
    VR_ROW_ID                ROWID;
  BEGIN

  VV_OBJECT_TYPE    := UPPER(P_OBJECT_TYPE);
  VV_SECURITY_TYPE  := UPPER(P_SECURITY_TYPE);
  VV_SECURITY_VALUE := UPPER(TRIM(P_SECURITY_VALUE));

  IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) THEN
    RAISE_APPLICATION_ERROR(-20000,'The supplied application id: ' || P_APPLICATION_ID || ' is invalid.');
  END IF;

  IF NOT VV_OBJECT_TYPE IN ('INTEGRATOR','CONTENT','COMPONENT') THEN
    RAISE_APPLICATION_ERROR( -20000,'The supplied Object type is invalid. We support the following object types: INTEGRATOR, CONTENT, COMPONENT');
  END IF;

  IF NOT VV_SECURITY_TYPE IN ('FUNCTION', 'SELF_SECURED') THEN
    RAISE_APPLICATION_ERROR( -20000,'The supplied Security type is invalid. We support the following security types: FUNCTION');
  END IF;

  IF P_OBJECT_CODE IS NULL THEN
    RAISE_APPLICATION_ERROR( -20000,'Value required for Object Code');
  END IF;

  IF P_SECURITY_CODE IS NULL THEN
    RAISE_APPLICATION_ERROR( -20000,'Value required for Security Code');
  END IF;


  IF VV_SECURITY_VALUE IS NULL OR LENGTH(TRIM(VV_SECURITY_VALUE)) = 0 THEN
    RAISE_APPLICATION_ERROR( -20000,'Value required for Security Value');
  END IF;

  CHECK_OBJECT_EXISTANCE (P_APPLICATION_ID, P_OBJECT_CODE, VV_OBJECT_TYPE);

  -- Check security value.
  IF P_SECURITY_TYPE = 'FUNCTION'
  THEN
    CHECK_FUNCTION_EXISTANCE(VV_SECURITY_VALUE);
  END IF;

  BNE_SECURITY_RULES_PKG.INSERT_ROW( VR_ROW_ID,
                     P_APPLICATION_ID,
                     P_SECURITY_CODE,
                     VN_OBJECT_VERSION_NUMBER,
                     VV_SECURITY_TYPE,
                     VV_SECURITY_VALUE,
                     SYSDATE,
                     P_USER_ID,
                     SYSDATE,
                     P_USER_ID,
                     0);

  BNE_SECURED_OBJECTS_PKG.INSERT_ROW( VR_ROW_ID,
                    P_APPLICATION_ID,
                    P_OBJECT_CODE,
                    VV_OBJECT_TYPE,
                    VN_OBJECT_VERSION_NUMBER,
                    P_APPLICATION_ID,
                    P_SECURITY_CODE,
                    SYSDATE,
                    P_USER_ID,
                    SYSDATE,
                    P_USER_ID,
                    0 );
  END ADD_OBJECT_RULES;

--------------------------------------------------------------------------------
--  PROCEDURE:           UPDATE_OBJECT_RULES                                  --
--                                                                            --
--  DESCRIPTION:         Updates security rules for a BNE object e.g. an Integrator
--                       from BNE_SECURED_OBJECT and BNE_SECURITY_RULES       --
--                                                                            --
--  PARAMETERS: P_OBJECT_APP_ID:   BNE_SECURED_OBJECT.APPLICATION_ID          --
--              P_OBJECT_CODE:     BNE_SECURED_OBJECT.OBJECT_CODE             --
--              P_OBJECT_TYPE:     BNE_SECURED_OBJECT.OBJECT_TYPE             --
--              P_SECURITY_APP_ID: BNE_SECURITY_RULES.APPLICATION_ID          --
--              P_SECURITY_CODE:   BNE_SECURITY_RULES.SECURITY_CODE           --
--              P_SECURITY_TYPE:   BNE_SECURITY_RULES.SECURITY_TYPE           --
--              P_SECURITY_VALUE:  BNE_SECURITY_RULES.SECURITY_VALUE          --
--              P_USER_ID:         User ID                                    --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-Aug-2004  Kdobinso  Created                                            --
--  25-Aug-2004  dagroves  Added more parameter checks                        --
--------------------------------------------------------------------------------
PROCEDURE UPDATE_OBJECT_RULES (
  P_OBJECT_APP_ID   in NUMBER,
  P_OBJECT_CODE     in VARCHAR2,
  P_OBJECT_TYPE     in VARCHAR2,
  P_SECURITY_APP_ID in NUMBER,
  P_SECURITY_CODE   in VARCHAR2,
  P_SECURITY_TYPE   in VARCHAR2,
  P_SECURITY_VALUE  in VARCHAR2,
  P_USER_ID         in NUMBER)
IS
  VN_OBJECT_VERSION_NUMBER CONSTANT NUMBER := 1;
BEGIN

    IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_OBJECT_APP_ID) THEN
      RAISE_APPLICATION_ERROR(-20000,'The supplied application id: ' || P_OBJECT_APP_ID || ' is invalid.');
    END IF;

    IF NOT P_SECURITY_TYPE IN ('FUNCTION', 'SELF_SECURED') THEN
      RAISE_APPLICATION_ERROR( -20000,'The supplied Security type is invalid. We support the following security types: FUNCTION');
    END IF;

    IF P_OBJECT_CODE IS NULL THEN
      RAISE_APPLICATION_ERROR( -20000,'Value required for Object Code');
    END IF;

    IF P_SECURITY_CODE IS NULL THEN
      RAISE_APPLICATION_ERROR( -20000,'Value required for Security Code');
    END IF;

    IF NOT P_OBJECT_TYPE IN ('INTEGRATOR','CONTENT','COMPONENT') THEN
      RAISE_APPLICATION_ERROR( -20000,'The supplied Object type is invalid. We support the following object types: INTEGRATOR, CONTENT, COMPONENT');
    END IF;

    IF P_SECURITY_VALUE IS NULL OR LENGTH(TRIM(P_SECURITY_VALUE)) = 0 THEN
      RAISE_APPLICATION_ERROR( -20000,'Value required for Security Value');
    END IF;

    CHECK_OBJECT_EXISTANCE (P_OBJECT_APP_ID, P_OBJECT_CODE, P_OBJECT_TYPE);

    -- Check security value.
    IF P_SECURITY_TYPE = 'FUNCTION'
    THEN
      CHECK_FUNCTION_EXISTANCE(P_SECURITY_VALUE);
    END IF;

     BNE_SECURED_OBJECTS_PKG.UPDATE_ROW( P_OBJECT_APP_ID,
                       P_OBJECT_CODE,
                       P_OBJECT_TYPE,
                       VN_OBJECT_VERSION_NUMBER,
                       P_SECURITY_APP_ID,
                       P_SECURITY_CODE,
                       SYSDATE,
                       P_USER_ID,
                       0 );

     BNE_SECURITY_RULES_PKG.UPDATE_ROW( P_SECURITY_APP_ID,
                      P_SECURITY_CODE,
                      VN_OBJECT_VERSION_NUMBER,
                      P_SECURITY_TYPE,
                      P_SECURITY_VALUE,
                      SYSDATE,
                      P_USER_ID ,
                      0 );

  END UPDATE_OBJECT_RULES;


--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_OBJECT_RULES                                  --
--                                                                            --
--  DESCRIPTION:         Deletes security rules for a BNE object e.g. an Integrator
--                       from BNE_SECURED_OBJECT and BNE_SECURITY_RULES       --
--                                                                            --
--  PARAMETERS: P_OBJECT_APP_ID:   BNE_SECURED_OBJECT.APPLICATION_ID          --
--              P_OBJECT_CODE:     BNE_SECURED_OBJECT.OBJECT_CODE             --
--              P_OBJECT_TYPE:     BNE_SECURED_OBJECT.OBJECT_TYPE             --
--              P_SECURITY_APP_ID: BNE_SECURITY_RULES.APPLICATION_ID          --
--              P_SECURITY_CODE:   BNE_SECURITY_RULES.SECURITY_CODE           --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-Aug-2004  Kdobinso  Created                                            --
--------------------------------------------------------------------------------
  PROCEDURE DELETE_OBJECT_RULES (
    P_OBJECT_APP_ID in NUMBER,
    P_OBJECT_CODE in VARCHAR2,
    P_OBJECT_TYPE in VARCHAR2,
    P_SECURITY_APP_ID in NUMBER,
    P_SECURITY_CODE in VARCHAR2) IS
    VV_SECURITY_CODE BNE_SECURITY_RULES.SECURITY_CODE%type;
  BEGIN

     BEGIN
       SELECT SECURITY_RULE_CODE
       INTO VV_SECURITY_CODE
       FROM BNE_SECURED_OBJECTS
       WHERE APPLICATION_ID = P_OBJECT_APP_ID
       AND OBJECT_CODE = P_OBJECT_CODE
       AND OBJECT_TYPE = P_OBJECT_TYPE
       AND SECURITY_RULE_APP_ID = P_SECURITY_APP_ID;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE_APPLICATION_ERROR( -20000,'No record exists in BNE_SECURED_OBJECT with key ' || P_OBJECT_APP_ID|| ':' || P_OBJECT_CODE || ' WHERE OBJECT_TYPE = ' || P_OBJECT_TYPE);
     END;

     IF P_SECURITY_CODE <> VV_SECURITY_CODE THEN
             RAISE_APPLICATION_ERROR( -20000,'The supplied security code ' || P_SECURITY_CODE || ' does not match security referenced by ' || P_OBJECT_APP_ID || ':' || P_OBJECT_CODE || ' in BNE_SECURED_OBJECT');
     END IF;

     BNE_SECURED_OBJECTS_PKG.DELETE_ROW( P_OBJECT_APP_ID, P_OBJECT_CODE, P_OBJECT_TYPE );
     BNE_SECURITY_RULES_PKG.DELETE_ROW( P_SECURITY_APP_ID, P_SECURITY_CODE );

  END DELETE_OBJECT_RULES;

--------------------------------------------------------------------------------
--  FUNCTION:           FUNCTION_TEST                                         --
--                                                                            --
--  DESCRIPTION:        Finds out if a security function is or not accessible --
--                      via the current FND Context                           --
--                                                                            --
--  PARAMETERS: FUNCTION_CODE:     VARCHAR2                                   --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-jan-2011  AMGONZAL  Created                                            --
--------------------------------------------------------------------------------
FUNCTION FUNCTION_TEST(function_code in varchar2)
return varchar2 is
  BOOL_RETURN BOOLEAN;
  CHAR_RETURN VARCHAR2(30);
BEGIN
  BOOL_RETURN := FND_FUNCTION.TEST( function_code);
  IF BOOL_RETURN THEN
    CHAR_RETURN := 'Allowed';
  ELSE
    CHAR_RETURN := 'Denied';
  END IF;
  return CHAR_RETURN;
END FUNCTION_TEST;


END BNE_SECURITY_UTILS_PKG;

/
