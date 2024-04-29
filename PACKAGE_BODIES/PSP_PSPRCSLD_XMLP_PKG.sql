--------------------------------------------------------
--  DDL for Package Body PSP_PSPRCSLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPRCSLD_XMLP_PKG" AS
/* $Header: PSPRCSLDB.pls 120.4 2007/10/29 07:27:47 amakrish noship $ */
  FUNCTION CF_ASSIGNMENT_NUMBERFORMULA(ASSIGNMENT_ID IN NUMBER) RETURN VARCHAR2 IS
    X_ASSIGNMENT_NUMBER VARCHAR2(30);
  BEGIN
    SELECT
      ASSIGNMENT_NUMBER
    INTO X_ASSIGNMENT_NUMBER
    FROM
      PER_ASSIGNMENTS_F
    WHERE ASSIGNMENT_ID = CF_ASSIGNMENT_NUMBERFORMULA.ASSIGNMENT_ID
      AND ASSIGNMENT_TYPE = 'E'
      AND ROWNUM < 2;
    RETURN (X_ASSIGNMENT_NUMBER);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_ASSIGNMENT_NUMBERFORMULA;

  FUNCTION CF_ELEMENT_NAMEFORMULA(ELEMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2 IS
    X_ELEMENT_NAME PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
  BEGIN
    RETURN (PSP_GENERAL.GET_ELEMENT_NAME(ELEMENT_TYPE_ID
                                       ,TRUNC(SYSDATE)));
  END CF_ELEMENT_NAMEFORMULA;

  FUNCTION CF_PERSON_NAMEFORMULA(PERSON_ID IN NUMBER) RETURN VARCHAR2 IS
    X_PERSON_NAME VARCHAR2(240);
    X_END_DATE DATE;
  BEGIN
    SELECT
      END_DATE
    INTO X_END_DATE
    FROM
      PER_TIME_PERIODS
    WHERE TIME_PERIOD_ID = P_TIME_PERIOD_ID;
    SELECT
      FULL_NAME
    INTO X_PERSON_NAME
    FROM
      PER_PEOPLE_F
    WHERE PERSON_ID = CF_PERSON_NAMEFORMULA.PERSON_ID
      AND X_END_DATE BETWEEN EFFECTIVE_START_DATE
      AND EFFECTIVE_END_DATE;
    RETURN (X_PERSON_NAME);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no data found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
  END CF_PERSON_NAMEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN

    SELECT
      START_DATE
    INTO P_START_DATE
    FROM
      PER_TIME_PERIODS
    WHERE TIME_PERIOD_ID = P_TIME_PERIOD_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      /*SRW.MESSAGE(1
                 ,'Start Date not found for the selected time period id')*/NULL;
      RETURN (FALSE);
    WHEN TOO_MANY_ROWS THEN
      /*SRW.MESSAGE(2
                 ,'Too many rows found for the selected time period id')*/NULL;
      RETURN (FALSE);
    WHEN OTHERS THEN
      /*SRW.MESSAGE(3
                 ,'Others exception raised')*/NULL;
      RETURN (FALSE);
  END AFTERPFORM;

  FUNCTION CF_MISMATCH_ELTFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END CF_MISMATCH_ELTFORMULA;

  FUNCTION CF_MISMATCH_ASSGFORMULA(SUM_DL_D_ASSG IN NUMBER
                                  ,SUM_SL_D_ASSG IN NUMBER
                                  ,SUM_DL_C_ASSG IN NUMBER
                                  ,SUM_SL_C_ASSG IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF SUM_DL_D_ASSG <> SUM_SL_D_ASSG OR SUM_DL_C_ASSG <> SUM_SL_C_ASSG THEN
      RETURN ('Mismatch');
    END IF;
    RETURN NULL;
  END CF_MISMATCH_ASSGFORMULA;

  FUNCTION CF_MISMATCH_PERSONFORMULA(SUM_DL_D_PERSON IN NUMBER
                                    ,SUM_SL_D_PERSON IN NUMBER
                                    ,SUM_DL_C_PERSON IN NUMBER
                                    ,SUM_SL_C_PERSON IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF SUM_DL_D_PERSON <> SUM_SL_D_PERSON OR SUM_DL_C_PERSON <> SUM_SL_C_PERSON THEN
      RETURN ('Mismatch');
    END IF;
    RETURN NULL;
  END CF_MISMATCH_PERSONFORMULA;

  FUNCTION CF_MISMATCH_REPORTFORMULA(SUM_DL_D_TOTAL IN NUMBER
                                    ,SUM_SL_D_TOTAL IN NUMBER
                                    ,SUM_DL_C_TOTAL IN NUMBER
                                    ,SUM_SL_C_TOTAL IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF SUM_DL_D_TOTAL <> SUM_SL_D_TOTAL OR SUM_DL_C_TOTAL <> SUM_SL_C_TOTAL THEN
      RETURN ('Mismatch');
    END IF;
    RETURN NULL;
  END CF_MISMATCH_REPORTFORMULA;

  FUNCTION CF_ORGFORMULA RETURN VARCHAR2 IS
    X_ORG_NAME HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
    X_ORG_ID VARCHAR2(15);
  BEGIN
    GET('PSP_ORG_REPORT'
       ,X_ORG_ID);
    IF X_ORG_ID IS NOT NULL THEN
      SELECT
        NAME
      INTO X_ORG_NAME
      FROM
        HR_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = TO_NUMBER(X_ORG_ID);
      RETURN (X_ORG_NAME);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('Organization Defined in Profile Not Found');
  END CF_ORGFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_SOURCE_TYPEFORMULA RETURN VARCHAR2 IS
    X_SOURCE_TYPE VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO X_SOURCE_TYPE
    FROM
      PSP_LOOKUPS
    WHERE LOOKUP_TYPE = 'PSP_SOURCE_TYPE'
      AND LOOKUP_CODE = P_SOURCE_TYPE;
    RETURN (X_SOURCE_TYPE);
  END CF_SOURCE_TYPEFORMULA;

  FUNCTION CF_TIME_PERIODFORMULA RETURN VARCHAR2 IS
    X_TIME_PERIOD VARCHAR2(35);
  BEGIN
    IF P_TIME_PERIOD_ID IS NOT NULL THEN
      SELECT
        PERIOD_NAME
      INTO X_TIME_PERIOD
      FROM
        PER_TIME_PERIODS
      WHERE TIME_PERIOD_ID = P_TIME_PERIOD_ID;
      RETURN (X_TIME_PERIOD);
    END IF;
    RETURN NULL;
  END CF_TIME_PERIODFORMULA;

  FUNCTION CF_CHARGING_INSTRUCTIONSFORMUL(GLCCID IN NUMBER
                                         ,PROJECT_ID IN NUMBER
                                         ,TASK_ID IN NUMBER
                                         ,AWARD_ID IN NUMBER
                                         ,EXP_ORG_ID IN NUMBER
                                         ,EXPENDITURE_TYPE IN VARCHAR2) RETURN CHAR IS
    V_RETCODE NUMBER;
    L_CHART_OF_ACCTS VARCHAR2(20);
    GL_FLEX_VALUES VARCHAR2(2000);
    L_PROJECT_NAME VARCHAR2(30);
    L_AWARD_NUMBER VARCHAR2(15);
    L_TASK_NUMBER VARCHAR2(25);
    L_ORG_NAME HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
    L_POETA VARCHAR2(360);
  BEGIN
    IF GLCCID IS NOT NULL THEN
      V_RETCODE := PSP_GENERAL.FIND_CHART_OF_ACCTS(TO_NUMBER(P_SET_OF_BOOKS_ID)
                                                  ,L_CHART_OF_ACCTS);
      GL_FLEX_VALUES := FND_FLEX_EXT.GET_SEGS(APPLICATION_SHORT_NAME => 'SQLGL'
                                             ,KEY_FLEX_CODE => 'GL#'
                                             ,STRUCTURE_NUMBER => TO_NUMBER(L_CHART_OF_ACCTS)
                                             ,COMBINATION_ID => GLCCID);
      RETURN (GL_FLEX_VALUES);
    ELSE
      IF PROJECT_ID IS NOT NULL THEN
        SELECT
          NAME
        INTO L_PROJECT_NAME
        FROM
          PA_PROJECTS_ALL
        WHERE PROJECT_ID = CF_CHARGING_INSTRUCTIONSFORMUL.PROJECT_ID;
        SELECT
          TASK_NUMBER
        INTO L_TASK_NUMBER
        FROM
          PA_TASKS
        WHERE TASK_ID = CF_CHARGING_INSTRUCTIONSFORMUL.TASK_ID;
        IF AWARD_ID IS NOT NULL THEN
          BEGIN
            SELECT
              AWARD_NUMBER
            INTO L_AWARD_NUMBER
            FROM
              GMS_AWARDS_ALL
            WHERE AWARD_ID = CF_CHARGING_INSTRUCTIONSFORMUL.AWARD_ID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              SELECT
                DEFAULT_DIST_AWARD_NUMBER
              INTO L_AWARD_NUMBER
              FROM
                GMS_IMPLEMENTATIONS
              WHERE DEFAULT_DIST_AWARD_ID = CF_CHARGING_INSTRUCTIONSFORMUL.AWARD_ID
                AND AWARD_DISTRIBUTION_OPTION = 'Y';
          END;
        ELSE
          L_AWARD_NUMBER := '';
        END IF;
        SELECT
          NAME
        INTO L_ORG_NAME
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE ORGANIZATION_ID = EXP_ORG_ID;
        L_POETA := L_PROJECT_NAME || ' ' || L_TASK_NUMBER || ' ' || L_AWARD_NUMBER || ' ' || L_ORG_NAME || ' ' || EXPENDITURE_TYPE;
      ELSE
        L_POETA := '';
      END IF;
      RETURN (L_POETA);
    END IF;
  END CF_CHARGING_INSTRUCTIONSFORMUL;

  FUNCTION CF_CURRENCY_FORMATFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    RETURN (FND_CURRENCY.GET_FORMAT_MASK(CURRENCY_CODE
                                       ,30));
  END CF_CURRENCY_FORMATFORMULA;

  FUNCTION CF_CURRENCY_CODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    RETURN ('(' || CURRENCY_CODE || ')');
  END CF_CURRENCY_CODEFORMULA;

  FUNCTION CF_SUM_SL_D_TOTAL_DSPFORMULA(CS_SUM_SL_D_TOTAL IN NUMBER
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_SUM_SL_D_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_SUM_SL_D_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_SL_D_TOTAL_DSPFORMULA;

  FUNCTION CF_SUM_SL_C_TOTAL_DSPFORMULA(CS_SUM_SL_C_TOTAL IN NUMBER
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_SUM_SL_C_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_SUM_SL_C_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_SL_C_TOTAL_DSPFORMULA;

  FUNCTION CF_SUM_DL_D_TOTAL_DSPFORMULA(CS_SUM_DL_D_TOTAL IN NUMBER
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_SUM_DL_D_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_SUM_DL_D_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_D_TOTAL_DSPFORMULA;

  FUNCTION CF_SUM_DL_C_TOTAL_DSPFORMULA(CS_SUM_DL_C_TOTAL IN NUMBER
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_SUM_DL_C_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_SUM_DL_C_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_C_TOTAL_DSPFORMULA;

  FUNCTION CF_MISMATCH_REPORT_DSPFORMULA(CS_SUM_DL_D_TOTAL IN NUMBER
                                        ,CS_SUM_SL_D_TOTAL IN NUMBER
                                        ,CS_SUM_DL_C_TOTAL IN NUMBER
                                        ,CS_SUM_SL_C_TOTAL IN NUMBER) RETURN CHAR IS
  BEGIN
    IF CS_SUM_DL_D_TOTAL <> CS_SUM_SL_D_TOTAL OR CS_SUM_DL_C_TOTAL <> CS_SUM_SL_C_TOTAL THEN
      RETURN ('Mismatch');
    END IF;
    RETURN NULL;
  END CF_MISMATCH_REPORT_DSPFORMULA;

  FUNCTION CF_SUM_DL_D_PERSON_DSPFORMULA(SUM_DL_D_PERSON IN NUMBER
                                        ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SUM_DL_D_PERSON)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SUM_DL_D_PERSON
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_D_PERSON_DSPFORMULA;

  FUNCTION CF_SUM_DL_C_PERSON_DSPFORMULA(SUM_DL_C_PERSON IN NUMBER
                                        ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SUM_DL_C_PERSON)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SUM_DL_C_PERSON
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_C_PERSON_DSPFORMULA;

  FUNCTION CF_SL_DEBIT_AMOUNT_DSPFORMULA(SL_DEBIT_AMOUNT IN NUMBER
                                        ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SL_DEBIT_AMOUNT)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SL_DEBIT_AMOUNT
                  ,CF_CURRENCY_FORMAT));
  END CF_SL_DEBIT_AMOUNT_DSPFORMULA;

  FUNCTION CF_SL_CREDIT_AMOUNT_DSPFORMULA(SL_CREDIT_AMOUNT IN NUMBER
                                         ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SL_CREDIT_AMOUNT)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SL_CREDIT_AMOUNT
                  ,CF_CURRENCY_FORMAT));
  END CF_SL_CREDIT_AMOUNT_DSPFORMULA;

  FUNCTION CF_SUM_DL_D_ASSG_DSPFORMULA(SUM_DL_D_ASSG IN NUMBER
                                      ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SUM_DL_D_ASSG)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SUM_DL_D_ASSG
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_D_ASSG_DSPFORMULA;

  FUNCTION CF_SUM_DL_C_ASSG_DSPFORMULA(SUM_DL_C_ASSG IN NUMBER
                                      ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SUM_DL_C_ASSG)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(SUM_DL_C_ASSG
                  ,CF_CURRENCY_FORMAT));
  END CF_SUM_DL_C_ASSG_DSPFORMULA;

  FUNCTION CF_DL_CREDIT_AMOUNT_DSPFORMULA(DL_CREDIT_AMOUNT IN NUMBER
                                         ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(DL_CREDIT_AMOUNT)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(DL_CREDIT_AMOUNT
                  ,CF_CURRENCY_FORMAT));
  END CF_DL_CREDIT_AMOUNT_DSPFORMULA;

  FUNCTION CF_DL_DEBIT_AMOUNT_DSPFORMULA(DL_DEBIT_AMOUNT IN NUMBER
                                        ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(DL_DEBIT_AMOUNT)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(DL_DEBIT_AMOUNT
                  ,CF_CURRENCY_FORMAT));
  END CF_DL_DEBIT_AMOUNT_DSPFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  PROCEDURE PUT(NAME IN VARCHAR2
               ,VAL IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_PROFILE.PUT(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(VAL);
    STPROC.EXECUTE;*/null;

  END PUT;

  FUNCTION DEFINED(NAME IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    /* STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.DEFINED(:NAME); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);
    RETURN X0;*/ null;
  END DEFINED;

  PROCEDURE GET(NAME IN VARCHAR2
               ,VAL OUT NOCOPY VARCHAR2) IS
  BEGIN
 /*   STPROC.INIT('begin FND_PROFILE.GET(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(VAL);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,VAL);*/
    FND_PROFILE.GET(NAME,VAL);
  END GET;

  FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := FND_PROFILE.VALUE(:NAME); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/ null;
  END VALUE;

  FUNCTION SAVE_USER(X_NAME IN VARCHAR2
                    ,X_VALUE IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    /* STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE_USER(:X_NAME, :X_VALUE); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,X0);
    RETURN X0;*/ null;
  END SAVE_USER;

  FUNCTION SAVE(X_NAME IN VARCHAR2
               ,X_VALUE IN VARCHAR2
               ,X_LEVEL_NAME IN VARCHAR2
               ,X_LEVEL_VALUE IN VARCHAR2
               ,X_LEVEL_VALUE_APP_ID IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    /* STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE(:X_NAME, :X_VALUE, :X_LEVEL_NAME, :X_LEVEL_VALUE, :X_LEVEL_VALUE_APP_ID); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_I(X_LEVEL_NAME);
    STPROC.BIND_I(X_LEVEL_VALUE);
    STPROC.BIND_I(X_LEVEL_VALUE_APP_ID);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(6
                   ,X0);
    RETURN X0;*/ null;
  END SAVE;

  PROCEDURE GET_SPECIFIC(NAME_Z IN VARCHAR2
                        ,USER_ID_Z IN NUMBER
                        ,RESPONSIBILITY_ID_Z IN NUMBER
                        ,APPLICATION_ID_Z IN NUMBER
                        ,VAL_Z OUT NOCOPY VARCHAR2
                        ,DEFINED_Z OUT NOCOPY BOOLEAN) IS
  BEGIN
    /* STPROC.INIT('declare DEFINED_Z BOOLEAN; begin DEFINED_Z := sys.diutil.int_to_bool(:DEFINED_Z);
    FND_PROFILE.GET_SPECIFIC(:NAME_Z, :USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :VAL_Z, DEFINED_Z);
    :DEFINED_Z := sys.diutil.bool_to_int(DEFINED_Z); end;');
    STPROC.BIND_O(DEFINED_Z);
    STPROC.BIND_I(NAME_Z);
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_O(VAL_Z);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,DEFINED_Z);
    STPROC.RETRIEVE(6
                   ,VAL_Z);*/ null;
  END GET_SPECIFIC;

  FUNCTION VALUE_SPECIFIC(NAME IN VARCHAR2
                         ,USER_ID IN NUMBER
                         ,RESPONSIBILITY_ID IN NUMBER
                         ,APPLICATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /* STPROC.INIT('begin :X0 := FND_PROFILE.VALUE_SPECIFIC(:NAME, :USER_ID, :RESPONSIBILITY_ID, :APPLICATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(USER_ID);
    STPROC.BIND_I(RESPONSIBILITY_ID);
    STPROC.BIND_I(APPLICATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/ null;
  END VALUE_SPECIFIC;

  PROCEDURE INITIALIZE(USER_ID_Z IN NUMBER
                      ,RESPONSIBILITY_ID_Z IN NUMBER
                      ,APPLICATION_ID_Z IN NUMBER
                      ,SITE_ID_Z IN NUMBER) IS
  BEGIN
    /* STPROC.INIT('begin FND_PROFILE.INITIALIZE(:USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :SITE_ID_Z); end;');
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_I(SITE_ID_Z);
    STPROC.EXECUTE;*/ null;
  END INITIALIZE;

  PROCEDURE PUTMULTIPLE(NAMES IN VARCHAR2
                       ,VALS IN VARCHAR2
                       ,NUM IN NUMBER) IS
  BEGIN
    /* STPROC.INIT('begin FND_PROFILE.PUTMULTIPLE(:NAMES, :VALS, :NUM); end;');
    STPROC.BIND_I(NAMES);
    STPROC.BIND_I(VALS);
    STPROC.BIND_I(NUM);
    STPROC.EXECUTE;*/ null;
  END PUTMULTIPLE;

END PSP_PSPRCSLD_XMLP_PKG;

/
