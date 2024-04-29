--------------------------------------------------------
--  DDL for Package Body JE_JENOGEIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_JENOGEIS_XMLP_PKG" AS
/* $Header: JENOGEISB.pls 120.2 2008/01/11 08:04:05 abraghun noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    EXECUTE IMMEDIATE
      'alter session set NLS_TERRITORY = AMERICA';
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        BEGIN
          /*SRW.MESSAGE(100
                     ,'Foundation is not initialised')*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        END;
    END;
    DECLARE
      XXNO_REQUEST_ID1 NUMBER;
      COAID NUMBER;
      SOBNAME VARCHAR2(30);
      FUNCTCURR VARCHAR2(15);
      ERRBUF VARCHAR2(132);
    BEGIN
      JG_INFO.JG_GET_SET_OF_BOOKS_INFO(P_LEDGER_ID
                                      ,COAID
                                      ,SOBNAME
                                      ,FUNCTCURR
                                      ,ERRBUF);
      IF (ERRBUF IS NOT NULL) THEN
        /*SRW.MESSAGE('00'
                   ,ERRBUF)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      SELECT
        PRECISION
      INTO PRECISION
      FROM
        FND_CURRENCIES
      WHERE CURRENCY_CODE = FUNCTCURR;
      STRUCT_NUM := COAID;
      SET_OF_BOOKS_NAME := SOBNAME;
      FUNC_CURRENCY := FUNCTCURR;
      P_GEI_VIEW;
      P_INSERT_PERIOD_NAME(P_PERIOD_NAME
                          ,P_INCOME
                          ,P_EXPENSE);
      IF P_FINAL = 'Y' THEN
        XXNO_REQUEST_ID1 := FND_REQUEST.SUBMIT_REQUEST('JE'
                                                      ,'JENOGEIR'
                                                      ,'Norwegian GEI Spool S-Report'
                                                      ,''
                                                      ,FALSE
                                                      ,P_FILENAME
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,NULL
                                                      ,'N'
                                                      ,CHR(0)
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,'');
        COMMIT;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE P_GEI_VIEW IS
  BEGIN
    DECLARE
      V_ACTUAL_FLAG GL_BALANCES.ACTUAL_FLAG%TYPE;
      V_AUT_TYPE_SEGMENTS GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
      V_STRENG VARCHAR2(900);
      C_PEKER INTEGER;
      V_ACCOUNT_SEGMENTS GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
      V_DETAIL_TEMPLATE GL_CODE_COMBINATIONS.TEMPLATE_ID%TYPE;
    BEGIN
      V_AUT_TYPE_SEGMENTS := NULL;
      V_ACCOUNT_SEGMENTS := NULL;
      V_AUT_TYPE_SEGMENTS := FND_PROFILE.VALUE('JENO_GEI_AUT_TYPE');
      V_ACCOUNT_SEGMENTS := REPLACE(FND_PROFILE.VALUE('JENO_GEI_ACCOUNT_SEGMENT')
                                   ,'-'
                                   ,'||');
      V_DETAIL_TEMPLATE := FND_PROFILE.VALUE('JENO_GEI_DETAIL_TEMPL');
      V_STRENG := 'create or replace view je_no_gei_sreport_v as select gcc.' || V_AUT_TYPE_SEGMENTS || ' authority_type ,gbs.period_name period,gbs.actual_flag,
                  ' || V_ACCOUNT_SEGMENTS || ' account_number,(gbs.period_net_dr - gbs.period_net_cr) balance,gbs.template_id, gbs.period_num, gbs.period_year from gl_code_combinations gcc,
		  gl_balances gbs, gl_sets_of_books gso where gbs.code_combination_id = gcc.code_combination_id
                  and gbs.ledger_id = gso.set_of_books_id and gso.currency_code = gbs.currency_code and gbs.template_id = ' || V_DETAIL_TEMPLATE;
      EXECUTE IMMEDIATE
        V_STRENG;
    END;
  END P_GEI_VIEW;

  PROCEDURE P_INS_ASCII(P_LINE_NUMBER IN JE_NO_GEI_ASCIIS_T.LINE_NUMBER%TYPE
                       ,P_TEXT IN JE_NO_GEI_ASCIIS_T.TEXT%TYPE) IS
  BEGIN
    INSERT INTO JE_NO_GEI_ASCIIS_T(LINE_NUMBER,TEXT)
    VALUES   (P_LINE_NUMBER
      ,P_TEXT);
  EXCEPTION
    WHEN OTHERS THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END P_INS_ASCII;

  PROCEDURE P_INSERT_PERIOD_NAME(P_PERIOD_NAME IN GL_BALANCES.PERIOD_NAME%TYPE
                                ,P_ACCOUNT_INCOME IN GL_BALANCES.PERIOD_NET_DR%TYPE
                                ,P_ACCOUNT_EXPENSE IN GL_BALANCES.PERIOD_NET_DR%TYPE) IS
    TMP_PERIOD_NUM VARCHAR2(2);
    TMP_PERIOD VARCHAR2(6);
    TMP_TEXT VARCHAR2(34);
    T_ORDER_NUMBER VARCHAR2(35);
    REF_NUM VARCHAR2(4);
    BALANCE_SUM GL_BALANCES.PERIOD_NET_DR%TYPE;
    T_CLOS GL_PERIOD_STATUSES.CLOSING_STATUS%TYPE;
    TMP_NUMBER NUMBER(34);
    T_PERIOD_YEAR GL_PERIOD_STATUSES.PERIOD_YEAR%TYPE;
    T_PERIOD_NUM GL_PERIOD_STATUSES.PERIOD_NUM%TYPE;
    T_SUM_INCOME GL_BALANCES.PERIOD_NET_DR%TYPE;
    T_SUM_EXPENSE GL_BALANCES.PERIOD_NET_DR%TYPE;
    T_LINE_NUMBER JE_NO_GEI_ASCIIS_T.LINE_NUMBER%TYPE;
    T_TEXT JE_NO_GEI_ASCIIS_T.TEXT%TYPE;
    T_SET_OF_BOOKS GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
    T_DETAIL_TEMPL GL_BALANCES.TEMPLATE_ID%TYPE;
    T_INCOME_ACCOUNT GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
    T_EXPENSE_ACCOUNT GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
    PERIOD_NOT_GUILTY EXCEPTION;
    CURSOR PART_1_CUR IS
      SELECT
        JUG.AUTHORITY_TYPE AUT_TYPE,
        JUG.ACCOUNT_NUMBER ACCOUNT,
        SUM(NVL(JUG.BALANCE
               ,0)) BALANCE
      FROM
        JE_NO_GEI_SREPORT_V JUG
      WHERE JUG.PERIOD_NUM <= T_PERIOD_NUM
        AND JUG.PERIOD_YEAR = T_PERIOD_YEAR
        AND NVL(JUG.BALANCE
         ,0) <> 0
        AND JUG.TEMPLATE_ID = T_DETAIL_TEMPL
        AND JUG.ACTUAL_FLAG = 'A'
      GROUP BY
        JUG.AUTHORITY_TYPE,
        JUG.ACCOUNT_NUMBER;
    PART_1_CUR_REC PART_1_CUR%ROWTYPE;
    CURSOR PART_2_CUR IS
      SELECT
        JUG.AUTHORITY_TYPE AUT_TYPE,
        JUG.ACCOUNT_NUMBER ACCOUNT,
        SUM(NVL(JUG.BALANCE
               ,0)) BALANCE
      FROM
        JE_NO_GEI_SREPORT_V JUG
      WHERE JUG.PERIOD_NUM > 12
        AND JUG.PERIOD_YEAR = T_PERIOD_YEAR
        AND NVL(JUG.BALANCE
         ,0) <> 0
        AND JUG.TEMPLATE_ID = T_DETAIL_TEMPL
        AND JUG.ACTUAL_FLAG = 'A'
      GROUP BY
        JUG.AUTHORITY_TYPE,
        JUG.ACCOUNT_NUMBER;
    PART_2_CUR_REC PART_2_CUR%ROWTYPE;
  BEGIN
    T_DETAIL_TEMPL := FND_PROFILE.VALUE('JENO_GEI_DETAIL_TEMPL');
    T_LINE_NUMBER := 0;
    REF_NUM := NULL;
    BEGIN
      T_SET_OF_BOOKS := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      SELECT
        CLOSING_STATUS,
        PERIOD_YEAR,
        PERIOD_NUM
      INTO T_CLOS,T_PERIOD_YEAR,T_PERIOD_NUM
      FROM
        GL_PERIOD_STATUSES,
        GL_SETS_OF_BOOKS
      WHERE GL_PERIOD_STATUSES.PERIOD_NAME = P_PERIOD_NAME
        AND GL_PERIOD_STATUSES.APPLICATION_ID = '101'
        AND GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID = T_SET_OF_BOOKS
        AND GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID = GL_PERIOD_STATUSES.SET_OF_BOOKS_ID;
      IF T_PERIOD_NUM > 13 THEN
        /*SRW.MESSAGE('100'
                   ,'Period is invalid.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('100'
                   ,'Unable to derive closing_st')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      IF T_CLOS = 'P' THEN
        /*SRW.MESSAGE('100'
                   ,'Period is closed.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    END;
    BEGIN
      DELETE FROM JE_NO_GEI_ASCIIS_T;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('101'
                   ,'Cant delete from JE_NO_GEI_ASCII_S.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := NULL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'H1  ';
      T_TEXT := REF_NUM || 'S';
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('102'
                   ,'Unable to derive type of report')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := T_TEXT || LPAD(FND_PROFILE.VALUE('JENO_GEI_ACCOUNTANT_PROFILE')
                    ,9
                    ,'0');
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('103'
                   ,'Unable to find ACCOUNTANT_NUMBER.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      TMP_PERIOD_NUM := TO_CHAR(T_PERIOD_NUM);
      TMP_PERIOD := T_PERIOD_YEAR || LPAD(TMP_PERIOD_NUM
                        ,2
                        ,'0');
      IF TMP_PERIOD > TO_CHAR(SYSDATE
             ,'YYYYMM') THEN
        RAISE PERIOD_NOT_GUILTY;
      ELSE
        T_TEXT := T_TEXT || TMP_PERIOD;
      END IF;
    EXCEPTION
      WHEN PERIOD_NOT_GUILTY THEN
        /*SRW.MESSAGE('104'
                   ,'Period must be earlier or equal to ' || TO_CHAR(SYSDATE
                          ,'YYYYMM') || '( present date)')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      WHEN OTHERS THEN
        /*SRW.MESSAGE('104'
                   ,'Unable to derive valid period')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := T_TEXT || TO_CHAR(SYSDATE
                       ,'YYYYMMDDHH24MI');
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('105'
                   ,'Unable to derive SYSDATE')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      SELECT
        JE_NO_GEI_CONTROLS_S.NEXTVAL
      INTO TMP_NUMBER
      FROM
        DUAL;
      TMP_TEXT := TO_CHAR(TMP_NUMBER);
      T_ORDER_NUMBER := '1' || LPAD(TMP_TEXT
                            ,34
                            ,'0');
      T_TEXT := T_TEXT || T_ORDER_NUMBER;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('106'
                   ,'Unable to derive order_number')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := T_TEXT || LPAD(FND_PROFILE.VALUE('JENO_GEI_ACC_CENT_PROFILE')
                    ,9
                    ,'0');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('107'
                   ,'Unable to derive Central unit')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      IF T_PERIOD_NUM = 13 THEN
        OPEN PART_2_CUR;
        LOOP
          FETCH PART_2_CUR
           INTO PART_2_CUR_REC;
          EXIT WHEN PART_2_CUR%NOTFOUND;
          BEGIN
            T_TEXT := NULL;
            T_LINE_NUMBER := T_LINE_NUMBER + 1;
            REF_NUM := 'S1  ';
            T_TEXT := REF_NUM || SUBSTR(PART_2_CUR_REC.AUT_TYPE
                            ,1
                            ,2) || RPAD(PART_2_CUR_REC.ACCOUNT
                          ,10
                          ,' ');
          EXCEPTION
            WHEN OTHERS THEN
              IF (PART_2_CUR%ISOPEN) THEN
                CLOSE PART_2_CUR;
              END IF;
              /*SRW.MESSAGE('108'
                         ,'Unable to derive Account')*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
          BEGIN
            T_TEXT := T_TEXT || TO_CHAR(PART_2_CUR_REC.BALANCE
                             ,'S099999999999999.99');
            P_INS_ASCII(T_LINE_NUMBER
                       ,T_TEXT);
          EXCEPTION
            WHEN OTHERS THEN
              IF (PART_2_CUR%ISOPEN) THEN
                CLOSE PART_2_CUR;
              END IF;
              /*SRW.MESSAGE('109'
                         ,'Unable to derive amount')*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
        END LOOP;
        CLOSE PART_2_CUR;
      ELSE
        OPEN PART_1_CUR;
        LOOP
          FETCH PART_1_CUR
           INTO PART_1_CUR_REC;
          EXIT WHEN PART_1_CUR%NOTFOUND;
          BEGIN
            T_TEXT := NULL;
            T_LINE_NUMBER := T_LINE_NUMBER + 1;
            REF_NUM := 'S1  ';
            T_TEXT := REF_NUM || SUBSTR(PART_1_CUR_REC.AUT_TYPE
                            ,1
                            ,2) || RPAD(PART_1_CUR_REC.ACCOUNT
                          ,10
                          ,' ');
          EXCEPTION
            WHEN OTHERS THEN
              IF (PART_1_CUR%ISOPEN) THEN
                CLOSE PART_1_CUR;
              END IF;
              /*SRW.MESSAGE('108'
                         ,'Unable to derive Account')*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
          BEGIN
            T_TEXT := T_TEXT || TO_CHAR(PART_1_CUR_REC.BALANCE
                             ,'S099999999999999.99');
            P_INS_ASCII(T_LINE_NUMBER
                       ,T_TEXT);
          EXCEPTION
            WHEN OTHERS THEN
              IF (PART_1_CUR%ISOPEN) THEN
                CLOSE PART_1_CUR;
              END IF;
              /*SRW.MESSAGE('110'
                         ,'Unable to derive amount')*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
        END LOOP;
        CLOSE PART_1_CUR;
      END IF;
    END;
    BEGIN
      T_TEXT := NULL;
      SELECT
        SUM(NVL(BALANCE
               ,0))
      INTO BALANCE_SUM
      FROM
        JE_NO_GEI_SREPORT_V
      WHERE PERIOD = P_PERIOD_NAME;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S2  ';
      T_TEXT := REF_NUM || TO_CHAR(BALANCE_SUM
                       ,'S099999999999999.99');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('111'
                   ,'Unable to derive balance sum')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := NULL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.1';
      T_TEXT := REF_NUM || REPLACE(TO_CHAR(P_ACCOUNT_INCOME
                               ,'S099999999999999.99')
                       ,' '
                       ,'');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('112'
                   ,'Unable to derive Income BANK')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_INCOME_ACCOUNT := FND_PROFILE.VALUE('JENO_GEI_INCOME_ACCOUNT');
      T_TEXT := NULL;
      SELECT
        NVL(SUM(BALANCE)
           ,0)
      INTO T_SUM_INCOME
      FROM
        JE_NO_GEI_SREPORT_V JUG
      WHERE JUG.PERIOD_NUM <= T_PERIOD_NUM
        AND JUG.PERIOD_YEAR = T_PERIOD_YEAR
        AND JUG.ACCOUNT_NUMBER = T_INCOME_ACCOUNT
        AND JUG.TEMPLATE_ID = T_DETAIL_TEMPL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.2';
      T_TEXT := REF_NUM || TO_CHAR(T_SUM_INCOME
                       ,'S099999999999999.99');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('113'
                   ,'Unable to derive Income GL')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := NULL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.3';
      T_TEXT := REF_NUM || TO_CHAR((T_SUM_INCOME + P_ACCOUNT_INCOME)
                       ,'S099999999999999.99');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('115'
                   ,'Unable to derive Difference in income')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := NULL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.4';
      T_TEXT := REF_NUM || REPLACE(TO_CHAR(P_ACCOUNT_EXPENSE
                               ,'S099999999999999.99')
                       ,' '
                       ,'');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('115'
                   ,'Unable to derive Expense')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_EXPENSE_ACCOUNT := FND_PROFILE.VALUE('JENO_GEI_EXPENSE_ACCOUNT');
      T_TEXT := NULL;
      SELECT
        NVL(SUM(BALANCE)
           ,0)
      INTO T_SUM_EXPENSE
      FROM
        JE_NO_GEI_SREPORT_V JUG
      WHERE JUG.PERIOD_NUM <= T_PERIOD_NUM
        AND JUG.PERIOD_YEAR = T_PERIOD_YEAR
        AND JUG.ACCOUNT_NUMBER = T_EXPENSE_ACCOUNT
        AND JUG.TEMPLATE_ID = T_DETAIL_TEMPL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.5';
      T_TEXT := REF_NUM || TO_CHAR(T_SUM_EXPENSE
                       ,'S099999999999999.99');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('116'
                   ,'Unable to derive Expense GL')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      T_TEXT := NULL;
      T_LINE_NUMBER := T_LINE_NUMBER + 1;
      REF_NUM := 'S3.6';
      T_TEXT := REF_NUM || TO_CHAR((T_SUM_EXPENSE + P_ACCOUNT_EXPENSE)
                       ,'S099999999999999.99');
      P_INS_ASCII(T_LINE_NUMBER
                 ,T_TEXT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('117'
                   ,'Unable to derive BANK')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        DBMS_SESSION.SET_SQL_TRACE(FALSE);
    END;
    BEGIN
      INSERT INTO JE_NO_GEI_CONTROLS
        (ORDER_NUMBER
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN)
      VALUES   (TO_NUMBER(T_ORDER_NUMBER)
        ,FND_GLOBAL.USER_ID
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,SYSDATE
        ,FND_GLOBAL.LOGIN_ID);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('118'
                   ,'Unable to assign values to JE_NO_GEI_CONTROLS')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    COMMIT;
  END P_INSERT_PERIOD_NAME;

  FUNCTION CF_DATEFORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      V_DATE DATE;
    BEGIN
      SELECT
        FND_DATE.DATE_TO_CHARDATE(SYSDATE)
      INTO V_DATE
      FROM
        DUAL;
      RETURN (V_DATE);
    END;
  END CF_DATEFORMULA;

  FUNCTION CF_REPORT_TITLEFORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_APPLICATION_VL AP
      WHERE AP.APPLICATION_ID = CP.APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_NAME = 'JENOGEIS'
        AND AP.APPLICATION_SHORT_NAME = 'JE';
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_REPORT_NAME := 'S-Report';
        RETURN ('S-Report');
    END;
  END CF_REPORT_TITLEFORMULA;

  FUNCTION STRUCT_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN STRUCT_NUM;
  END STRUCT_NUM_P;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SET_OF_BOOKS_NAME;
  END SET_OF_BOOKS_NAME_P;

  FUNCTION SELECT_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_ALL;
  END SELECT_ALL_P;

  FUNCTION WHERE_FLEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_FLEX;
  END WHERE_FLEX_P;

  FUNCTION ORDERBY_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORDERBY_ACCT;
  END ORDERBY_ACCT_P;

  FUNCTION PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN PRECISION;
  END PRECISION_P;

  FUNCTION FUNC_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FUNC_CURRENCY;
  END FUNC_CURRENCY_P;

END JE_JENOGEIS_XMLP_PKG;




/
