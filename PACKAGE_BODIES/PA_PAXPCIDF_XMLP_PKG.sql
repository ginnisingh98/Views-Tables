--------------------------------------------------------
--  DDL for Package Body PA_PAXPCIDF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPCIDF_XMLP_PKG" AS
/* $Header: PAXPCIDFB.pls 120.0 2008/01/02 11:41:35 krreddy noship $ */
  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
      ORG_NAME HR_ORGANIZATION_UNITS.NAME%TYPE;
      MEMBER_NAME VARCHAR2(240);
      ROLE_TYPE VARCHAR2(80);
      REL_STAT VARCHAR2(10);
      ENTER_PARAM VARCHAR2(80);
      NDF VARCHAR2(80);
      INV_STAT VARCHAR2(30);
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND GETPROFILE
                    NAME="PA_DEBUG_MODE"
                    FIELD=":p_debug_mode"
                    PRINT_ERROR="N"')*/NULL;
      P_RULE_OPTIMIZER := FND_PROFILE.VALUE('PA_RULE_BASED_OPTIMIZER');
      IF (P_START_ORGANIZATION_ID IS NULL AND PROJECT_MEMBER IS NULL) THEN
        BEGIN
          SELECT
            MEANING
          INTO ENTER_PARAM
          FROM
            PA_LOOKUPS
          WHERE LOOKUP_TYPE = 'ENTER VALUE'
            AND LOOKUP_CODE = 'ENTER_ORG_MGR';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'Start ORg Not found ')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'Start ORG  ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_ENTER := ENTER_PARAM;
      IF INVOICE_STATUS IS NOT NULL THEN
        BEGIN
          SELECT
            INITCAP(INVOICE_STATUS)
          INTO INV_STAT
          FROM
            DUAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'Invoice Status No Data Found')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'InvStatus    ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_INVOICE_STAT := INV_STAT;
      IF INCLUDE_RELEASED_STATUS IS NOT NULL THEN
        BEGIN
          SELECT
            MEANING
          INTO REL_STAT
          FROM
            FND_LOOKUPS
          WHERE LOOKUP_TYPE = 'YES_NO'
            AND LOOKUP_CODE = INCLUDE_RELEASED_STATUS;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'Include Released   Not found  ')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'Incl.Rel  ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_RELEASED := REL_STAT;
      IF P_START_ORGANIZATION_ID IS NOT NULL THEN
        BEGIN
          SELECT
            SUBSTR(NAME
                  ,1
                  ,60)
          INTO ORG_NAME
          FROM
            HR_ORGANIZATION_UNITS
          WHERE ORGANIZATION_ID = P_START_ORGANIZATION_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'start org name  not found ')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'start orgname   ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_START_ORG := ORG_NAME;
      IF PROJECT_MEMBER IS NOT NULL THEN
        BEGIN
          SELECT
            FULL_NAME
          INTO MEMBER_NAME
          FROM
            PER_PEOPLE_F
          WHERE PERSON_ID = PROJECT_MEMBER
            AND sysdate between EFFECTIVE_START_DATE
            AND NVL(EFFECTIVE_END_DATE
             ,SYSDATE + 1)
            AND ( CURRENT_NPW_FLAG = 'Y'
          OR CURRENT_EMPLOYEE_FLAG = 'Y' )
            AND DECODE(CURRENT_NPW_FLAG
                ,'Y'
                ,NPW_NUMBER
                ,EMPLOYEE_NUMBER) IS NOT NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'Project Member Name not found   ')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'ProjectMember  ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_PROJECT_MEMBER := MEMBER_NAME;
      IF PROJECT_ROLE_TYPE IS NOT NULL THEN
        BEGIN
          SELECT
            MEANING
          INTO ROLE_TYPE
          FROM
            PA_PROJECT_ROLE_TYPES
          WHERE PROJECT_ROLE_TYPE = PROJECT_ROLE_TYPE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE(2
                       ,'RoleType   not found')*/NULL;
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'RoleType   ' || SQLERRM)*/NULL;
        END;
      END IF;
      C_ROLE_TYPE := ROLE_TYPE;
      IF INVOICE_AMOUNT_RANGE IS NOT NULL THEN
        IF INVOICE_AMOUNT_RANGE = 'All' THEN
          LOW_RANGE := -9999999999999.99;
          HIGH_RANGE := 9999999999999.99;
        ELSIF INVOICE_AMOUNT_RANGE = 'Amount1' THEN
          LOW_RANGE := -9999999999999.99;
          HIGH_RANGE := 24999.99;
        ELSIF INVOICE_AMOUNT_RANGE = 'Amount2' THEN
          LOW_RANGE := 25000.00;
          HIGH_RANGE := 99999.99;
        ELSIF INVOICE_AMOUNT_RANGE = 'Amount3' THEN
          LOW_RANGE := 100000.00;
          HIGH_RANGE := 9999999999999.99;
        END IF;
      END IF;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (GET_START_ORG <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      BEGIN
        SELECT
          MEANING
        INTO NDF
        FROM
          PA_LOOKUPS
        WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
          AND LOOKUP_TYPE = 'MESSAGE';
        C_NO_DATA_FOUND := NDF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          /*SRW.MESSAGE(2
                     ,'MEANING not found ')*/NULL;
        WHEN OTHERS THEN
          /*SRW.MESSAGE(2
                     ,'Meaning  ' || SQLERRM)*/NULL;
      END;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT
          MEANING
        INTO NDF
        FROM
          PA_LOOKUPS
        WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
          AND LOOKUP_TYPE = 'MESSAGE';
        C_NO_DATA_FOUND := NDF;
        C_DUMMY_DATA := 1;
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    LCREATION_DATE_FROM:=to_char(CREATION_DATE_FROM,'DD-MON-YY');
    LCREATION_DATE_TO:=to_char(CREATION_DATE_TO,'DD-MON-YY');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    SELECT
      GL.NAME
    INTO L_NAME
    FROM
      GL_SETS_OF_BOOKS GL,
      PA_IMPLEMENTATIONS PI
    WHERE GL.SET_OF_BOOKS_ID = PI.SET_OF_BOOKS_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(2
                 ,'GetCompanyName ' || SQLERRM)*/NULL;
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION GET_START_ORG RETURN BOOLEAN IS
    C_START_ORGANIZATION_ID NUMBER;
  BEGIN
    SELECT
      DECODE(P_START_ORGANIZATION_ID
            ,NULL
            ,START_ORGANIZATION_ID
            ,P_START_ORGANIZATION_ID)
    INTO C_START_ORGANIZATION_ID
    FROM
      PA_IMPLEMENTATIONS;
    INSERT INTO PA_ORG_REPORTING_SESSIONS
      (START_ORGANIZATION_ID
      ,SESSION_ID)
    VALUES   (C_START_ORGANIZATION_ID
      ,USERENV('SESSIONID'));
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(2
                 ,'getstartorg   ' || SQLERRM)*/NULL;
      RETURN (FALSE);
  END GET_START_ORG;

  FUNCTION G_PROJECT_ORGANIZATIONGROUPFIL RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_START_ORGANIZATION_ID IS NULL THEN
        IF PROJECT_MEMBER IS NULL THEN
          RETURN (FALSE);
        ELSE
          RETURN (TRUE);
        END IF;
      ELSE
        RETURN (TRUE);
      END IF;
    END;
    RETURN (TRUE);
  END G_PROJECT_ORGANIZATIONGROUPFIL;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      ROLLBACK;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_CURRENCY_CODEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (PA_MULTI_CURRENCY.GET_ACCT_CURRENCY_CODE);
  END CF_CURRENCY_CODEFORMULA;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION LOW_RANGE_P RETURN NUMBER IS
  BEGIN
    RETURN LOW_RANGE;
  END LOW_RANGE_P;

  FUNCTION HIGH_RANGE_P RETURN NUMBER IS
  BEGIN
    RETURN HIGH_RANGE;
  END HIGH_RANGE_P;

  FUNCTION C_START_ORG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_START_ORG;
  END C_START_ORG_P;

  FUNCTION C_PROJECT_MEMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PROJECT_MEMBER;
  END C_PROJECT_MEMBER_P;

  FUNCTION C_ROLE_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ROLE_TYPE;
  END C_ROLE_TYPE_P;

  FUNCTION C_RELEASED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_RELEASED;
  END C_RELEASED_P;

  FUNCTION C_ENTER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ENTER;
  END C_ENTER_P;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_DATA_FOUND;
  END C_NO_DATA_FOUND_P;

  FUNCTION C_DUMMY_DATA_P RETURN NUMBER IS
  BEGIN
    RETURN C_DUMMY_DATA;
  END C_DUMMY_DATA_P;

  FUNCTION C_INVOICE_STAT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INVOICE_STAT;
  END C_INVOICE_STAT_P;

END PA_PAXPCIDF_XMLP_PKG;


/