--------------------------------------------------------
--  DDL for Package Body BOM_CSTRPCRE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRPCRE_XMLP_PKG" AS
/* $Header: CSTRPCREB.pls 120.2 2008/01/06 12:59:17 nchinnam noship $ */

  FUNCTION BeforeReport RETURN BOOLEAN IS
  	l_currency		VARCHAR2(15);
  	l_stmt_num              NUMBER;
  BEGIN


      l_stmt_num := 10;
      SELECT cod.organization_name,
             sob.currency_code
      INTO   P_ORG_NAME,
             l_currency
      FROM   cst_organization_definitions cod,
             gl_sets_of_books sob
      WHERE  cod.organization_id = P_ORG_ID
      AND    cod.set_of_books_id = sob.set_of_books_id;

      P_EXCHANGE_RATE := FND_NUMBER.canonical_to_number(P_EXCHANGE_RATE_CHAR);

      l_stmt_num := 20;
      IF l_currency = P_CURRENCY_CODE THEN
      	P_CURRENCY_DSP := P_CURRENCY_CODE;
      ELSE
      	P_CURRENCY_DSP := P_CURRENCY_CODE||' @ '||
          to_char(round(1/P_EXCHANGE_RATE,5))||' '||l_currency;
      END IF;

      l_stmt_num := 30;
      select	nvl(minimum_accountable_unit, power(10,nvl(-precision,0)))
      into	P_ROUND_UNIT
      from fnd_currencies
      where currency_code = P_CURRENCY_CODE;

      l_stmt_num := 40;
      /* (1) Remove the Trace calls Bug No. 4432316 */


    l_stmt_num := 50;

    l_stmt_num := 60;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
              APPL_SHORT_NAME="INV"
              MODE="SELECT"
              OUTPUT=":P_ITEM_SEG"
              DISPLAY="ALL"
              TABLEALIAS="MSI"');*/NULL;

  RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS
    THEN
      --SRW.MESSAGE(999, l_stmt_num ||': '|| sqlerrm);
      --SRW.MESSAGE(999, 'BOM_CSTRPCRE_XMLP_PKG >X     ' || TO_CHAR(sysdate, 'Dy Mon FmDD HH24:MI:SS YYYY'));
      --RAISE SRW.PROGRAM_ABORT;
      NULL;
    RETURN (TRUE);
END;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_EARLIEST_TO_DATE DATE;
    L_LATEST_TO_DATE DATE;
    L_P_TO_DATE DATE;
    L_ENABLE_TRACE VARCHAR(1);
    L_SUMMARIZED_FLAG VARCHAR(1);
    L_PERIOD_OPEN_FLAG NUMBER;
    L_RETURN_STATUS VARCHAR(1);
    L_STMT_NUM NUMBER;
    L_MSG_COUNT NUMBER;
    L_MSG_DATA VARCHAR2(2000);
    L_CSTRPCRE_PROG_ID NUMBER;
    L_OTHER_REQUEST_ID NUMBER;
    L_RETURN_VAL BOOLEAN;
    L_PHASE VARCHAR2(80);
    L_STATUS VARCHAR2(80);
    L_DEV_PHASE VARCHAR2(15);
    L_DEV_STATUS VARCHAR2(15);
    L_MESSAGE VARCHAR2(255);
    SUMMARIZE_ERROR EXCEPTION;
  BEGIN
    L_STMT_NUM := 5;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_STMT_NUM := 10;
    SELECT
      PERIOD_START_DATE,
      SCHEDULE_CLOSE_DATE
    INTO L_EARLIEST_TO_DATE,L_LATEST_TO_DATE
    FROM
      ORG_ACCT_PERIODS
    WHERE ORGANIZATION_ID = P_ORG_ID
      AND ACCT_PERIOD_ID = P_PERIOD_ID;
    L_STMT_NUM := 20;
    IF (P_TO_DATE IS NULL) THEN
      /*SRW.MESSAGE(0
                 ,'Run to date is unspecified. Defaulting to ' || L_LATEST_TO_DATE)*/NULL;
      L_P_TO_DATE := L_LATEST_TO_DATE;
    ELSE
      L_P_TO_DATE := TO_DATE(P_TO_DATE
                            ,'YYYY/MM/DD HH24:MI:SS');
    END IF;
    L_STMT_NUM := 30;
    IF (L_P_TO_DATE < L_EARLIEST_TO_DATE) THEN
      /*SRW.MESSAGE(0
                 ,'Run to date is out of period boundary.')*/NULL;
      /*SRW.MESSAGE(0
                 ,'Adjusting from ' || L_P_TO_DATE || ' to ' || L_EARLIEST_TO_DATE)*/NULL;
      L_P_TO_DATE := L_EARLIEST_TO_DATE;
    END IF;
    L_STMT_NUM := 40;
    IF (L_P_TO_DATE > L_LATEST_TO_DATE) THEN
      /*SRW.MESSAGE(0
                 ,'Run to date is out of period boundary.')*/NULL;
      /*SRW.MESSAGE(0
                 ,'Adjusting from ' || L_P_TO_DATE || ' to ' || L_LATEST_TO_DATE)*/NULL;
      L_P_TO_DATE := L_LATEST_TO_DATE;
    END IF;
    L_STMT_NUM := 50;
    SELECT
      CONCURRENT_PROGRAM_ID
    INTO L_CSTRPCRE_PROG_ID
    FROM
      FND_CONCURRENT_PROGRAMS
    WHERE APPLICATION_ID = 702
      AND CONCURRENT_PROGRAM_NAME = 'CSTRPCRE';
    LOOP
      L_STMT_NUM := 60;
      SELECT
        NVL(SUMMARIZED_FLAG
           ,'N'),
        DECODE(OPEN_FLAG
              ,'N'
              ,0
              ,1),
        DECODE(OPEN_FLAG
              ,'N'
              ,L_LATEST_TO_DATE
              ,L_P_TO_DATE)
      INTO L_SUMMARIZED_FLAG,L_PERIOD_OPEN_FLAG,L_P_TO_DATE
      FROM
        ORG_ACCT_PERIODS
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND ACCT_PERIOD_ID = P_PERIOD_ID;
      L_STMT_NUM := 70;
      SELECT
        MIN(FCR.REQUEST_ID)
      INTO L_OTHER_REQUEST_ID
      FROM
        FND_CONCURRENT_REQUESTS FCR
      WHERE FCR.PROGRAM_APPLICATION_ID = 702
        AND FCR.CONCURRENT_PROGRAM_ID = L_CSTRPCRE_PROG_ID
        AND FCR.ARGUMENT1 = TO_CHAR(P_ORG_ID)
        AND FCR.ARGUMENT5 = TO_CHAR(P_PERIOD_ID)
        AND FCR.PHASE_CODE = 'R'
        AND FCR.ACTUAL_START_DATE = (
        SELECT
          MIN(FCR2.ACTUAL_START_DATE)
        FROM
          FND_CONCURRENT_REQUESTS FCR2
        WHERE FCR2.PROGRAM_APPLICATION_ID = 702
          AND FCR2.CONCURRENT_PROGRAM_ID = L_CSTRPCRE_PROG_ID
          AND FCR2.ARGUMENT1 = TO_CHAR(P_ORG_ID)
          AND FCR2.ARGUMENT5 = TO_CHAR(P_PERIOD_ID)
          AND FCR2.PHASE_CODE = 'R' );
      L_STMT_NUM := 80;
      IF (L_OTHER_REQUEST_ID = P_CONC_REQUEST_ID OR L_PERIOD_OPEN_FLAG = 1 OR L_SUMMARIZED_FLAG = 'Y') THEN
        EXIT;
      ELSE
        L_STMT_NUM := 90;
        /*SRW.MESSAGE(0
                   ,'waiting on summarization request ' || L_OTHER_REQUEST_ID)*/NULL;
        L_RETURN_VAL := FND_CONCURRENT.WAIT_FOR_REQUEST(L_OTHER_REQUEST_ID
                                                       ,10
                                                       ,0
                                                       ,L_PHASE
                                                       ,L_STATUS
                                                       ,L_DEV_PHASE
                                                       ,L_DEV_STATUS
                                                       ,L_MESSAGE);
        IF (L_RETURN_VAL <> TRUE OR L_DEV_STATUS <> 'NORMAL') THEN
          RAISE SUMMARIZE_ERROR;
        END IF;
      END IF;
    END LOOP;
    L_STMT_NUM := 100;
    --P_TO_DATE := L_P_TO_DATE;
    P_TO_DATE1 := L_P_TO_DATE;
    IF (L_SUMMARIZED_FLAG <> 'Y') THEN
      /*SRW.MESSAGE(0
                 ,'calling summarization package')*/NULL;
      CST_ACCOUNTINGPERIOD_PUB.SUMMARIZE_PERIOD(P_API_VERSION => 1.0
                                               ,P_ORG_ID => P_ORG_ID
                                               ,P_PERIOD_ID => P_PERIOD_ID
                                               ,P_TO_DATE => L_P_TO_DATE
                                               ,P_USER_ID => NULL
                                               ,P_LOGIN_ID => NULL
                                               ,P_SIMULATION => L_PERIOD_OPEN_FLAG
                                               ,X_RETURN_STATUS => L_RETURN_STATUS
                                               ,X_MSG_DATA => L_MSG_DATA);
      IF (L_RETURN_STATUS <> '0' AND L_RETURN_STATUS <> '2' AND L_RETURN_STATUS <> '3') THEN
        RAISE SUMMARIZE_ERROR;
      END IF;
      L_STMT_NUM := 110;
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                               ,P_COUNT => L_MSG_COUNT
                               ,P_DATA => L_MSG_DATA);
      L_STMT_NUM := 120;
      IF L_MSG_COUNT > 0 THEN
        FOR i IN 1 .. L_MSG_COUNT LOOP
          L_MSG_DATA := FND_MSG_PUB.GET(I
                                       ,CST_UTILITY_PUB.GET_FALSE);
          /*SRW.MESSAGE(999
                     ,I || '-' || L_MSG_DATA)*/NULL;
        END LOOP;
      END IF;
    END IF;
    L_STMT_NUM := 130;
    IF (L_SUMMARIZED_FLAG = 'Y' OR L_RETURN_STATUS = '2') THEN
      P_SOURCE_TABLE := 'cst_period_close_summary';
      P_CPCS_WHERE := 'CPCS.organization_id = :p_org_id AND
                                            CPCS.acct_period_id  = :p_period_id';
    ELSIF (L_RETURN_STATUS = '3') THEN
      P_SIMULATION := 'Y';
      P_SOURCE_TABLE := 'cst_per_close_summary_temp';
    END IF;
    IF (P_REPORT_TYPE = 1) THEN
      L_STMT_NUM := 140;
      IF (P_SORT_OPTION = 1) THEN
        P_CG_SORT_TEXT := 'ORDER BY cg_name, cg_item';
      ELSIF (P_SORT_OPTION = 2) THEN
        P_CG_SORT_TEXT := 'ORDER BY cg_item, cg_name';
      ELSIF (P_SORT_OPTION = 3) THEN
        P_CG_SORT_TEXT := 'ORDER BY cg_adj_val, cg_name, cg_item';
      ELSIF (P_SORT_OPTION = 4) THEN
        P_CG_SORT_TEXT := 'ORDER BY cg_acc_val, cg_name, cg_item';
      ELSIF (P_SORT_OPTION = 5) THEN
        P_CG_SORT_TEXT := 'ORDER BY cg_onh_val, cg_name, cg_item';
      END IF;
    ELSIF (P_REPORT_TYPE = 2) THEN
      L_STMT_NUM := 150;
      IF (P_SORT_OPTION = 1) THEN
        P_SUB_SORT_TEXT := 'ORDER BY sub_code, sub_item';
      ELSIF (P_SORT_OPTION = 2) THEN
        P_SUB_SORT_TEXT := 'ORDER BY sub_item, sub_code';
      ELSIF (P_SORT_OPTION = 3) THEN
        P_SUB_SORT_TEXT := 'ORDER BY sub_adj_val, sub_code, sub_item';
      ELSIF (P_SORT_OPTION = 4) THEN
        P_SUB_SORT_TEXT := 'ORDER BY sub_acc_val, sub_code, sub_item';
      ELSIF (P_SORT_OPTION = 5) THEN
        P_SUB_SORT_TEXT := 'ORDER BY sub_onh_val, sub_code, sub_item';
      END IF;
    END IF;
    L_STMT_NUM := 160;
    SELECT
      PERIOD_START_DATE,
      PERIOD_NAME
    INTO P_FROM_DATE,P_PERIOD_NAME
    FROM
      ORG_ACCT_PERIODS
    WHERE ORGANIZATION_ID = P_ORG_ID
      AND ACCT_PERIOD_ID = P_PERIOD_ID;
    L_STMT_NUM := 170;
    SELECT
      ENABLE_TRACE
    INTO L_ENABLE_TRACE
    FROM
      FND_CONCURRENT_PROGRAMS
    WHERE CONCURRENT_PROGRAM_NAME = 'CSTRPCRE'
      AND APPLICATION_ID = 702;
    L_STMT_NUM := 180;
    SELECT
      MEANING
    INTO P_NULLSUB
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'CST_PER_CLOSE_MISC'
      AND LOOKUP_CODE = 1;
    RETURN (TRUE);
  EXCEPTION
    WHEN SUMMARIZE_ERROR THEN
      /*SRW.MESSAGE('2000'
                 ,'Failure in summarization package.')*/NULL;
      ROLLBACK;
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'BOM_CSTRPCRE_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                               ,P_COUNT => L_MSG_COUNT
                               ,P_DATA => L_MSG_DATA);
      IF L_MSG_COUNT > 0 THEN
        FOR i IN 1 .. L_MSG_COUNT LOOP
          L_MSG_DATA := FND_MSG_PUB.GET(I
                                       ,CST_UTILITY_PUB.GET_FALSE);
          /*SRW.MESSAGE(999
                     ,I || '-' || L_MSG_DATA)*/NULL;
        END LOOP;
      END IF;
      RETURN (FALSE);
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'BOM_CSTRPCRE_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
      ROLLBACK;
      RETURN (FALSE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRPCRE_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END BOM_CSTRPCRE_XMLP_PKG;


/
