--------------------------------------------------------
--  DDL for Package Body AP_APXT7CMT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXT7CMT_XMLP_PKG" AS
/* $Header: APXT7CMTB.pls 120.0 2007/12/27 08:34:29 vjaganat noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION
    INTO BASE_CURR,PREC,MIN_AU,DESCR
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    IF (GET_COMBINED_FLAG <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('8'
                 ,'After Get_combined_flag')*/NULL;
    END IF;
    IF (DELETE_AP_1099_TAPE_DATA <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('9'
                 ,'After delete_ap_1099_tape_data')*/NULL;
    END IF;
    IF (INSERT_AP_1099_TAPE_DATA <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('10'
                 ,'After insert_ap_1099_tape_data')*/NULL;
    END IF;
    IF (PERFORM_STATE_TESTS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('11'
                 ,'After perform_state_tests')*/NULL;
    END IF;
    IF (PERFORM_FEDERAL_LIMIT_UPDATES <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('10.1'
                 ,'After perform_federal_reporting_updates')*/NULL;
    END IF;
    IF (CLEAR_REGION_TOTALS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('12'
                 ,'After clear_region_totals')*/NULL;
    END IF;
    IF (UPDATE_STATE_TOTALS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('13'
                 ,'After update_state_totals')*/NULL;
    END IF;
    IF (GET_TRANSMITTER_INFO <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('14'
                 ,'After get_transmitter_info')*/NULL;
    END IF;
    IF (TYPE_SEL <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('15'
                 ,'After type_sel')*/NULL;
    END IF;
    IF (GET_FIRST_NAME <> TRUE) THEN
      /*SRW.MESSAGE('16'
                 ,'Problem After get_first_name')*/NULL;
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('16'
                 ,'After get_first_name')*/NULL;
    END IF;
    IF (GET_ADDRESS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF (P_DEBUG_SWITCH in ('y','Y')) THEN
      /*SRW.MESSAGE('17'
                 ,'After get_address')*/NULL;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_VOID AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NA AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    SELECT
      LY.MEANING,
      LN.MEANING,
      L1.DISPLAYED_FIELD,
      L2.DISPLAYED_FIELD,
      L3.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_VOID,NLS_NA
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES L1,
      AP_LOOKUP_CODES L2,
      AP_LOOKUP_CODES L3
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND L1.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L1.LOOKUP_CODE = 'ALL'
      AND L2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND L2.LOOKUP_CODE = 'VOID'
      AND L3.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L3.LOOKUP_CODE = 'NA';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    C_NLS_VOID := NLS_VOID;
    C_NLS_NA := NLS_NA;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
    BEGIN
      C_REPORT_START_DATE := SYSDATE;
      C_SPACE := ' ';
      C_DOUBLE_SPACE := '  ';
      C_RECORD_SEQUENCE := 2;
      IF P_FILE_INDICATOR = 'C' THEN
        C_INDICATOR_STATUS := 'G';
      ELSE
        C_INDICATOR_STATUS := ' ';
      END IF;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT Martin 1')*/NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('3'
                   ,'After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (CUSTOM_INIT <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('13'
                   ,'After Custom_Init')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.BREAK*/NULL;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      CLOSING_FAILURE EXCEPTION;
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('20'
                   ,'After SRWEXIT')*/NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMBINED_FLAG RETURN BOOLEAN IS
    L_SOB_ID NUMBER;
    L_COMBINED_FLAG VARCHAR2(1);
  BEGIN
    IF P_SET_OF_BOOKS_ID IS NOT NULL THEN
      L_SOB_ID := P_SET_OF_BOOKS_ID;
      SELECT
        DECODE(COMBINED_FILING_FLAG
              ,'Y'
              ,'1'
              ,' ')
      INTO L_COMBINED_FLAG
      FROM
        AP_SYSTEM_PARAMETERS
      WHERE SET_OF_BOOKS_ID = L_SOB_ID;
      C_COMBINED_FLAG := L_COMBINED_FLAG;
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMBINED_FLAG;

  FUNCTION GET_TIN RETURN BOOLEAN IS
    L_TAX_ENTITY_ID NUMBER;
    L_TIN VARCHAR2(20);
  BEGIN
    IF P_TAX_ENTITY_ID IS NOT NULL THEN
      L_TAX_ENTITY_ID := P_TAX_ENTITY_ID;
      SELECT
        REPLACE(REPLACE(TAX_IDENTIFICATION_NUM
                       ,'#'
                       ,'\#')
               ,'.'
               ,'\.')
      INTO L_TIN
      FROM
        AP_REPORTING_ENTITIES
      WHERE TAX_ENTITY_ID = L_TAX_ENTITY_ID;
      C_TIN := L_TIN;
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_TIN;

  FUNCTION DELETE_AP_1099_TAPE_DATA RETURN BOOLEAN IS
  BEGIN
    DELETE FROM AP_1099_TAPE_DATA;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END DELETE_AP_1099_TAPE_DATA;

  FUNCTION INSERT_AP_1099_TAPE_DATA RETURN BOOLEAN IS
    L_SOB_ID NUMBER;
    L_TAX_ENTITY_ID NUMBER;
  BEGIN
    IF P_TAX_ENTITY_ID IS NOT NULL AND P_SET_OF_BOOKS_ID IS NOT NULL THEN
      L_TAX_ENTITY_ID := P_TAX_ENTITY_ID;
      L_SOB_ID := P_SET_OF_BOOKS_ID;
      AP_1099_UTILITIES_PKG.INSERT_1099_DATA(P_CALLING_MODULE => 'ELECTRONIC MEDIA'
                                            ,P_SOB_ID => L_SOB_ID
                                            ,P_TAX_ENTITY_ID => L_TAX_ENTITY_ID
                                            ,P_COMBINED_FLAG => C_COMBINED_FLAG
                                            ,P_START_DATE => P_START_YEAR_DATE
                                            ,P_END_DATE => P_END_YEAR_DATE
                                            ,P_VENDOR_ID => NULL
                                            ,P_QUERY_DRIVER => P_QUERY_DRIVER
                                            ,P_MIN_REPORTABLE_FLAG => NULL
                                            ,P_FEDERAL_REPORTABLE_FLAG => NULL
                                            ,P_REGION => NULL);
      SELECT
        count(*)
      INTO C_NUMBER_OF_B_RECS
      FROM
        AP_1099_TAPE_DATA;
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END INSERT_AP_1099_TAPE_DATA;

  FUNCTION PERFORM_STATE_TESTS RETURN BOOLEAN IS
  BEGIN
    UPDATE
      AP_1099_TAPE_DATA
    SET
      REGION_CODE = ''
    WHERE ROWID not in (
      SELECT
        TD.ROWID
      FROM
        AP_1099_TAPE_DATA TD,
        AP_INCOME_TAX_REGIONS ITR
      WHERE ITR.REGION_CODE = TD.REGION_CODE
        AND NVL(ITR.INACTIVE_DATE
         ,TO_DATE(P_END_YEAR_DATE
                ,'DD-MON-RR') + 1) > TO_DATE(P_END_YEAR_DATE
             ,'DD-MON-RR')
        AND ( ( ITR.REPORTING_LIMIT_METHOD_CODE = 'FEDERAL'
        AND ( NVL(MISC1
         ,0) + NVL(MISC3
         ,0) + NVL(MISC6
         ,0) + NVL(MISC7
         ,0) + NVL(MISC9
         ,0) + NVL(MISC10
         ,0) >= P_FEDERAL_REPORTING_LIMIT
      OR NVL(MISC2
         ,0) >= 10
      OR NVL(MISC8
         ,0) >= 10
      OR ( NVL(MISC15AT
         ,0) + NVL(MISC15ANT
         ,0) ) >= P_FEDERAL_REPORTING_LIMIT
      OR NVL(MISC13
         ,0) + NVL(MISC14
         ,0) + NVL(MISC5
         ,0) > 0
      OR NVL(MISC15B
         ,0) > 0 ) )
      OR ( ITR.REPORTING_LIMIT_METHOD_CODE = 'SUM'
        AND ( NVL(MISC1
         ,0) + NVL(MISC2
         ,0) + NVL(MISC3
         ,0) + NVL(MISC5
         ,0) + NVL(MISC6
         ,0) + NVL(MISC7
         ,0) + NVL(MISC8
         ,0) + NVL(MISC9
         ,0) + NVL(MISC10
         ,0) + NVL(MISC13
         ,0) + NVL(MISC14
         ,0) + NVL(MISC15AT
         ,0) + NVL(MISC15ANT
         ,0) + NVL(MISC15B
         ,0) ) >= NVL(ITR.REPORTING_LIMIT
         ,0) )
      OR ( ITR.REPORTING_LIMIT_METHOD_CODE = 'INDIVIDUAL'
        AND ( NVL(MISC1
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC2
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC3
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC5
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC6
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC7
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC8
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC9
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC13
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC14
         ,0) >= ITR.REPORTING_LIMIT
      OR ( NVL(MISC15AT
         ,0) + NVL(MISC15ANT
         ,0) >= ITR.REPORTING_LIMIT )
      OR NVL(MISC15B
         ,0) >= ITR.REPORTING_LIMIT
      OR NVL(MISC10
         ,0) >= NVL(ITR.REPORTING_LIMIT
         ,0) ) ) ) );
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END PERFORM_STATE_TESTS;

  FUNCTION C_ERROR_DUMMYFORMULA(ERROR_TEXT IN VARCHAR2
                               ,VENDOR_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF ERROR_TEXT IS NOT NULL THEN
      C_ERROR_VENDOR := VENDOR_NAME;
      C_ERROR_REASON := ERROR_TEXT;
    END IF;
    RETURN NULL;
  END C_ERROR_DUMMYFORMULA;

  FUNCTION CLEAR_REGION_TOTALS RETURN BOOLEAN IS
  BEGIN
    UPDATE
      AP_INCOME_TAX_REGIONS
    SET
      CONTROL_TOTAL1 = 0
      ,CONTROL_TOTAL2 = 0
      ,CONTROL_TOTAL3 = 0
      ,CONTROL_TOTAL4 = 0
      ,CONTROL_TOTAL5 = 0
      ,CONTROL_TOTAL6 = 0
      ,CONTROL_TOTAL7 = 0
      ,CONTROL_TOTAL8 = 0
      ,CONTROL_TOTAL9 = 0
      ,CONTROL_TOTAL10 = 0
      ,CONTROL_TOTAL13 = 0
      ,CONTROL_TOTAL14 = 0
      ,CONTROL_TOTAL15A = 0
      ,CONTROL_TOTAL15B = 0
      ,NUM_OF_PAYEES = 0;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CLEAR_REGION_TOTALS;

  FUNCTION UPDATE_STATE_TOTALS RETURN BOOLEAN IS
    L_STATE_TOTAL1 NUMBER;
    L_STATE_TOTAL2 NUMBER;
    L_STATE_TOTAL3 NUMBER;
    L_STATE_TOTAL4 NUMBER;
    L_STATE_TOTAL5 NUMBER;
    L_STATE_TOTAL6 NUMBER;
    L_STATE_TOTAL7 NUMBER;
    L_STATE_TOTAL8 NUMBER;
    L_STATE_TOTAL9 NUMBER;
    L_STATE_TOTAL10 NUMBER;
    L_STATE_TOTAL13 NUMBER;
    L_STATE_TOTAL14 NUMBER;
    L_STATE_TOTAL15A NUMBER;
    L_STATE_TOTAL15B NUMBER;
    L_STATE_NUM_OF_PAYEES NUMBER;
    L_REGION_CODE_NUM NUMBER;
    CURSOR DETERMINE_STATE_TOTALS IS
      SELECT
        SUM(MISC1),
        SUM(MISC2),
        SUM(MISC3),
        SUM(MISC4),
        SUM(MISC5),
        SUM(MISC6),
        ( SUM(MISC7) + SUM(MISC15B) + SUM(MISC15AT) ),
        SUM(MISC8),
        SUM(MISC9),
        SUM(MISC10),
        SUM(MISC13),
        SUM(MISC14),
        ( SUM(MISC15AT) + SUM(MISC15ANT) ),
        ( SUM(MISC15B) + SUM(MISC15AT) ),
        count(*),
        REGION_CODE
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        REGION_CODE;
  BEGIN
    OPEN DETERMINE_STATE_TOTALS;
    LOOP
      FETCH DETERMINE_STATE_TOTALS
       INTO L_STATE_TOTAL1,L_STATE_TOTAL2,
       L_STATE_TOTAL3,L_STATE_TOTAL4,L_STATE_TOTAL5,L_STATE_TOTAL6,L_STATE_TOTAL7,L_STATE_TOTAL8,
       L_STATE_TOTAL9,L_STATE_TOTAL10,L_STATE_TOTAL13,L_STATE_TOTAL14,L_STATE_TOTAL15A,L_STATE_TOTAL15B,
       L_STATE_NUM_OF_PAYEES,L_REGION_CODE_NUM;
      EXIT WHEN DETERMINE_STATE_TOTALS%NOTFOUND;
      UPDATE
        AP_INCOME_TAX_REGIONS
      SET
        CONTROL_TOTAL1 = L_STATE_TOTAL1
        ,CONTROL_TOTAL2 = L_STATE_TOTAL2
        ,CONTROL_TOTAL3 = L_STATE_TOTAL3
        ,CONTROL_TOTAL4 = L_STATE_TOTAL4
        ,CONTROL_TOTAL5 = L_STATE_TOTAL5
        ,CONTROL_TOTAL6 = L_STATE_TOTAL6
        ,CONTROL_TOTAL7 = L_STATE_TOTAL7
        ,CONTROL_TOTAL8 = L_STATE_TOTAL8
        ,CONTROL_TOTAL9 = L_STATE_TOTAL9
        ,CONTROL_TOTAL10 = L_STATE_TOTAL10
        ,CONTROL_TOTAL13 = L_STATE_TOTAL13
        ,CONTROL_TOTAL14 = L_STATE_TOTAL14
        ,CONTROL_TOTAL15A = L_STATE_TOTAL15A
        ,CONTROL_TOTAL15B = L_STATE_TOTAL15B
        ,NUM_OF_PAYEES = L_STATE_NUM_OF_PAYEES
      WHERE REGION_CODE = L_REGION_CODE_NUM;
    END LOOP;
    CLOSE DETERMINE_STATE_TOTALS;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END UPDATE_STATE_TOTALS;

  FUNCTION GET_TRANSMITTER_INFO RETURN BOOLEAN IS
  BEGIN
    SELECT
      RPAD(' '
          ,80),
      RPAD(' '
          ,40),
      RPAD(' '
          ,40)
    INTO C_TRANSMITTER_NAME,C_TRANSMITTER_ADDRESS,C_TRANSMITTER_CSZ
    FROM
      SYS.DUAL;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_TRANSMITTER_INFO;

  FUNCTION GET_FIRST_NAME RETURN BOOLEAN IS
  BEGIN
    SELECT
      RPAD(' '
          ,40),
      '0',
      SUBSTR(REPLACE(REPLACE(TAX_IDENTIFICATION_NUM
                            ,'-'
                            ,'')
                    ,' '
                    ,'')
            ,1
            ,9),
      TO_CHAR(TO_DATE(P_START_YEAR_DATE
                     ,'DD-MON-RR')
             ,'YYYY')
    INTO C_SECOND_NAME,C_TRANSFER_FLAG,C_EIN,C_PAYMENT_YEAR
    FROM
      AP_REPORTING_ENTITIES
    WHERE TAX_ENTITY_ID = P_TAX_ENTITY_ID;
    IF TO_NUMBER(TO_CHAR(TO_DATE(P_END_YEAR_DATE
                             ,'DD-MON-RR')
                     ,'YYYY')) + 1 < TO_NUMBER(TO_CHAR(SYSDATE
                     ,'YYYY')) THEN
      C_PRIOR_YEAR_DATA := 'P';
    ELSE
      C_PRIOR_YEAR_DATA := ' ';
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_FIRST_NAME;

  FUNCTION GET_ADDRESS RETURN BOOLEAN IS
  BEGIN
    SELECT
      DECODE(P_ADDRESS_CHOICE
            ,'ADDRESS1'
            ,RPAD(HR.ADDRESS_LINE_1
                ,40)
            ,'LOCATION'
            ,HR.LOCATION_CODE
            ,'REP_ENTITY'
            ,RE.ENTITY_NAME
            ,RPAD(HR.ADDRESS_LINE_1
                ,40)),
      DECODE(P_ADDRESS_CHOICE
            ,'ADDRESS1'
            ,RPAD(HR.ADDRESS_LINE_2 || ' ' || HR.ADDRESS_LINE_3
                ,40)
            ,'LOCATION'
            ,RPAD(HR.ADDRESS_LINE_1 || ' ' || HR.ADDRESS_LINE_2
                ,40)
            ,'REP_ENTITY'
            ,RPAD(HR.ADDRESS_LINE_1 || ' ' || HR.ADDRESS_LINE_2
                ,40)
            ,RPAD(HR.ADDRESS_LINE_2 || ' ' || HR.ADDRESS_LINE_3
                ,40)),
      RPAD(HR.TOWN_OR_CITY
          ,40),
      RPAD(HR.REGION_2
          ,2),
      RPAD(SUBSTR(REPLACE(REPLACE(HR.POSTAL_CODE
                                 ,'-'
                                 ,'')
                         ,' '
                         ,'')
                 ,1
                 ,9)
          ,9)
    INTO C_FIRST_NAME,C_ADDRESS,C_CITY,C_STATE,C_ZIP
    FROM
      HR_LOCATIONS HR,
      AP_REPORTING_ENTITIES RE
    WHERE HR.LOCATION_ID = RE.LOCATION_ID
      AND RE.TAX_ENTITY_ID = P_TAX_ENTITY_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_ADDRESS;

  FUNCTION TYPE_SEL RETURN BOOLEAN IS
    L_INC1 NUMBER := 0;
    L_INC2 NUMBER := 0;
    L_INC3 NUMBER := 0;
    L_INC4 NUMBER := 0;
    L_INC5 NUMBER := 0;
    L_INC6 NUMBER := 0;
    L_INC7 NUMBER := 0;
    L_INC8 NUMBER := 0;
    L_INC9 NUMBER := 0;
    L_INC10 NUMBER := 0;
    L_INC13 NUMBER := 0;
    L_INC14 NUMBER := 0;
    L_INC15A NUMBER := 0;
    L_INC15B NUMBER := 0;
    L_MAIN1 NUMBER := 0;
    L_MAIN2 NUMBER := 0;
    L_MAIN3 NUMBER := 0;
    L_MAIN4 NUMBER := 0;
    L_MAIN5 NUMBER := 0;
    L_MAIN6 NUMBER := 0;
    L_MAIN7 NUMBER := 0;
    L_MAIN8 NUMBER := 0;
    L_MAIN9 NUMBER := 0;
    L_MAIN10 VARCHAR2(1) := '0';
    L_MAIN13 VARCHAR2(1) := '0';
    L_MAIN14 VARCHAR2(1) := '0';
    L_MAIN15A VARCHAR2(1) := '0';
    L_MAIN15B VARCHAR2(1) := '0';
    CURSOR VENDOR_SELECT IS
      SELECT
        DECODE(SUM(MISC1)
              ,0
              ,0
              ,1),
        DECODE(SUM(MISC2)
              ,0
              ,0
              ,2),
        DECODE(SUM(MISC3)
              ,0
              ,0
              ,3),
        DECODE(SUM(MISC4)
              ,0
              ,0
              ,4),
        DECODE(SUM(MISC5)
              ,0
              ,0
              ,5),
        DECODE(SUM(MISC6)
              ,0
              ,0
              ,6),
        DECODE(SUM(MISC7 + MISC15AT + MISC15B)
              ,0
              ,0
              ,7),
        DECODE(SUM(MISC8)
              ,0
              ,0
              ,8),
        DECODE(SUM(MISC9)
              ,0
              ,0
              ,9),
        DECODE(SUM(MISC10)
              ,0
              ,0
              ,10),
        DECODE(SUM(MISC13)
              ,0
              ,0
              ,13),
        DECODE(SUM(MISC14)
              ,0
              ,0
              ,14),
        DECODE(SUM(MISC15AT + MISC15ANT)
              ,0
              ,0
              ,151),
        DECODE(SUM(MISC15B + MISC15AT)
              ,0
              ,0
              ,152)
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC1
             ,0)) + SUM(NVL(MISC3
             ,0)) + SUM(NVL(MISC6
             ,0)) + SUM(NVL(MISC7
             ,0)) + SUM(NVL(MISC9
             ,0)) + SUM(NVL(MISC10
             ,0)) >= P_FEDERAL_REPORTING_LIMIT
      OR SUM(NVL(MISC2
             ,0)) >= 10
      OR SUM(NVL(MISC8
             ,0)) >= 10
      OR SUM(NVL(MISC15AT
             ,0)) + SUM(NVL(MISC15ANT
             ,0)) >= P_FEDERAL_REPORTING_LIMIT
      OR SUM(NVL(MISC13
             ,0)) + SUM(NVL(MISC14
             ,0)) + SUM(NVL(MISC5
             ,0)) > 0
      OR SUM(NVL(MISC15B
             ,0)) > 0
      UNION
      SELECT
        DECODE(SUM(MISC1)
              ,0
              ,0
              ,1),
        DECODE(SUM(MISC2)
              ,0
              ,0
              ,2),
        DECODE(SUM(MISC3)
              ,0
              ,0
              ,3),
        DECODE(SUM(MISC4)
              ,0
              ,0
              ,4),
        DECODE(SUM(MISC5)
              ,0
              ,0
              ,5),
        DECODE(SUM(MISC6)
              ,0
              ,0
              ,6),
        DECODE(SUM(MISC7 + MISC15AT + MISC15B)
              ,0
              ,0
              ,7),
        DECODE(SUM(MISC8)
              ,0
              ,0
              ,8),
        DECODE(SUM(MISC9)
              ,0
              ,0
              ,9),
        DECODE(SUM(MISC10)
              ,0
              ,0
              ,10),
        DECODE(SUM(MISC13)
              ,0
              ,0
              ,13),
        DECODE(SUM(MISC14)
              ,0
              ,0
              ,14),
        DECODE(SUM(MISC15AT + MISC15ANT)
              ,0
              ,0
              ,151),
        DECODE(SUM(MISC15B + MISC15AT)
              ,0
              ,0
              ,152)
      FROM
        AP_1099_TAPE_DATA
      WHERE REGION_CODE is not null
      GROUP BY
        VENDOR_ID;
  BEGIN
    OPEN VENDOR_SELECT;
    LOOP
      FETCH VENDOR_SELECT
       INTO L_INC1,L_INC2,L_INC3,L_INC4,L_INC5,L_INC6,L_INC7,L_INC8,L_INC9,L_INC10,L_INC13,L_INC14,L_INC15A,L_INC15B;
      EXIT WHEN VENDOR_SELECT%NOTFOUND;
      IF L_INC1 = 1 THEN
        L_MAIN1 := 1;
      END IF;
      IF L_INC2 = 2 THEN
        L_MAIN2 := 2;
      END IF;
      IF L_INC3 = 3 THEN
        L_MAIN3 := 3;
      END IF;
      IF L_INC4 = 4 THEN
        L_MAIN4 := 4;
      END IF;
      IF L_INC5 = 5 THEN
        L_MAIN5 := 5;
      END IF;
      IF L_INC6 = 6 THEN
        L_MAIN6 := 6;
      END IF;
      IF L_INC7 = 7 THEN
        L_MAIN7 := 7;
      END IF;
      IF L_INC8 = 8 THEN
        L_MAIN8 := 8;
      END IF;
      IF L_INC9 = 9 THEN
        L_MAIN9 := 9;
      END IF;
      IF L_INC10 = 10 THEN
        L_MAIN10 := 'A';
      END IF;
      IF L_INC13 = 13 THEN
        L_MAIN13 := 'B';
      END IF;
      IF L_INC14 = 14 THEN
        L_MAIN14 := 'C';
      END IF;
      IF L_INC15A = 151 THEN
        L_MAIN15A := 'D';
      END IF;
      IF L_INC15B = 152 THEN
        L_MAIN15B := 'E';
      END IF;
    END LOOP;
    CLOSE VENDOR_SELECT;
    SELECT
      DECODE(L_MAIN1
            ,1
            ,'1'
            ,'') || DECODE(L_MAIN2
            ,2
            ,'2'
            ,'') || DECODE(L_MAIN3
            ,3
            ,'3'
            ,'') || DECODE(L_MAIN4
            ,4
            ,'4'
            ,'') || DECODE(L_MAIN5
            ,5
            ,'5'
            ,'') || DECODE(L_MAIN6
            ,6
            ,'6'
            ,'') || DECODE(L_MAIN7
            ,7
            ,'7'
            ,'') || DECODE(L_MAIN8
            ,8
            ,'8'
            ,'') || DECODE(L_MAIN10
            ,'A'
            ,'A'
            ,'') || DECODE(L_MAIN13
            ,'B'
            ,'B'
            ,'') || DECODE(L_MAIN14
            ,'C'
            ,'C'
            ,'') || DECODE(L_MAIN15A
            ,'D'
            ,'D'
            ,'') || DECODE(L_MAIN15B
            ,'E'
            ,'E'
            ,'')
    INTO C_AMOUNT_INDICATOR
    FROM
      SYS.DUAL;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END TYPE_SEL;

  FUNCTION C_LAST_FILING_FLAGFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_LAST_FILING_YN = 'Y' THEN
      RETURN '1';
    ELSE
      RETURN ' ';
    END IF;
    RETURN NULL;
  END C_LAST_FILING_FLAGFORMULA;

  FUNCTION C_TEST_INDICATORFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TEST_YN = 'Y' THEN
      RETURN 'T';
    ELSE
      RETURN ' ';
    END IF;
    RETURN NULL;
  END C_TEST_INDICATORFORMULA;

  FUNCTION C_MTFIFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_OUTPUT_TYPE in ('DISKETTE','ELECTRONIC') THEN
      RETURN '  ';
    ELSE
      RETURN 'LS';
    END IF;
  END C_MTFIFORMULA;

  FUNCTION C_FOREIGN_PAYER_FLAGFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_FOREIGN_PAYER_YN = 'Y' THEN
      RETURN '1';
    ELSE
      RETURN ' ';
    END IF;
    RETURN NULL;
  END C_FOREIGN_PAYER_FLAGFORMULA;

  FUNCTION C_A_RECORDFORMULA(C_LAST_FILING_FLAG IN VARCHAR2
                            ,C_FOREIGN_PAYER_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    L_ORIGINAL VARCHAR2(1);
    L_REPLACEMENT VARCHAR2(1);
    L_CORRECTION VARCHAR2(1);
  BEGIN
    IF UPPER(P_FILE_INDICATOR) = 'R' THEN
      L_REPLACEMENT := '1';
    ELSIF UPPER(P_FILE_INDICATOR) = 'C' THEN
      L_CORRECTION := '1';
    ELSE
      L_ORIGINAL := '1';
    END IF;
    RETURN ('A' || RPAD(C_PAYMENT_YEAR
               ,4) || RPAD(' '
               ,6) || RPAD(NVL(C_EIN
                   ,' ')
               ,9) || RPAD(NVL(UPPER(P_NAME_CONTROL)
                   ,' ')
               ,4) || RPAD(NVL(UPPER(C_LAST_FILING_FLAG)
                   ,' ')
               ,1) || RPAD(NVL(UPPER(C_COMBINED_FLAG)
                   ,' ')
               ,1) || 'A' || RPAD(NVL(C_AMOUNT_INDICATOR
                   ,' ')
               ,12) || RPAD(' '
               ,8) || RPAD(NVL(L_ORIGINAL
                   ,' ')
               ,1) || RPAD(NVL(L_REPLACEMENT
                   ,' ')
               ,1) || RPAD(NVL(L_CORRECTION
                   ,' ')
               ,1) || RPAD(' '
               ,1) || RPAD(NVL(C_FOREIGN_PAYER_FLAG
                   ,' ')
               ,1) || RPAD(NVL(UPPER(C_FIRST_NAME)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_SECOND_NAME)
                   ,' ')
               ,40) || RPAD(NVL(C_TRANSFER_FLAG
                   ,' ')
               ,1) || RPAD(NVL(UPPER(C_ADDRESS)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_CITY)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_STATE)
                   ,' ')
               ,2) || RPAD(NVL(UPPER(C_ZIP)
                   ,' ')
               ,9) || RPAD(NVL(TO_CHAR(P_TELEPHONE_NUMBER)
                   ,' ')
               ,15) || RPAD(' '
               ,260) || '00000002' || RPAD(' '
               ,240));
  END C_A_RECORDFORMULA;

  FUNCTION C_B_RECORDFORMULA(PAYEE_NAME_CONTROL IN VARCHAR2
                            ,TIN_TYPE IN VARCHAR2
                            ,EIN IN VARCHAR2
                            ,VENDOR_ID IN NUMBER
                            ,MISC1 IN NUMBER
                            ,MISC2 IN NUMBER
                            ,MISC3 IN NUMBER
                            ,MISC4 IN NUMBER
                            ,MISC5 IN NUMBER
                            ,MISC6 IN NUMBER
                            ,MISC7 IN NUMBER
                            ,MISC8 IN NUMBER
                            ,MISC10 IN NUMBER
                            ,MISC13 IN NUMBER
                            ,MISC14 IN NUMBER
                            ,MISC15A IN NUMBER
                            ,MISC15B IN NUMBER
                            ,FOREIGN_PAYEE_FLAG IN VARCHAR2
                            ,TAX_REPORTING_NAME IN VARCHAR2
                            ,VENDOR_NAME IN VARCHAR2
                            ,VENDOR_LINE IN VARCHAR2
                            ,VENDOR_CITY IN VARCHAR2
                            ,VENDOR_STATE IN VARCHAR2
                            ,VENDOR_ZIP IN VARCHAR2
                            ,REGION_CODE IN VARCHAR2
                            ,MISC9 IN NUMBER) RETURN VARCHAR2 IS
    TEMP_REC VARCHAR2(1000);
  BEGIN
    C_RECORD_SEQUENCE := C_RECORD_SEQUENCE + 1;
    TEMP_REC := ('B' || RPAD(C_PAYMENT_YEAR
                    ,4) || C_INDICATOR_STATUS || RPAD(NVL(UPPER(PAYEE_NAME_CONTROL)
                        ,' ')
                    ,4) || RPAD(NVL(TIN_TYPE
                        ,' ')
                    ,1) || RPAD(NVL(EIN
                        ,' ')
                    ,9) || RPAD(NVL(TO_CHAR(VENDOR_ID)
                        ,' ')
                    ,20) || RPAD(' '
                    ,4) || RPAD(' '
                    ,10) || TO_CHAR(MISC1 * 100
                       ,'fm000000000000') || TO_CHAR(MISC2 * 100
                       ,'fm000000000000') || TO_CHAR(MISC3 * 100
                       ,'fm000000000000') || TO_CHAR(MISC4 * 100
                       ,'fm000000000000') || TO_CHAR(MISC5 * 100
                       ,'fm000000000000') || TO_CHAR(MISC6 * 100
                       ,'fm000000000000') || TO_CHAR(MISC7 * 100
                       ,'fm000000000000') || TO_CHAR(MISC8 * 100
                       ,'fm000000000000') || RPAD('0'
                    ,12
                    ,'0') || TO_CHAR(MISC10 * 100
                       ,'fm000000000000') || TO_CHAR(MISC13 * 100
                       ,'fm000000000000') || TO_CHAR(MISC14 * 100
                       ,'fm000000000000') || TO_CHAR(MISC15A * 100
                       ,'fm000000000000') || TO_CHAR(MISC15B * 100
                       ,'fm000000000000') || RPAD(' '
                    ,24) || RPAD(NVL(FOREIGN_PAYEE_FLAG
                        ,' ')
                    ,1) || RPAD(UPPER(NVL(TAX_REPORTING_NAME
                              ,VENDOR_NAME))
                    ,40) || RPAD(NVL(UPPER(C_SECOND_NAME)
                        ,' ')
                    ,40) || RPAD(' '
                    ,40) || RPAD(NVL(UPPER(VENDOR_LINE)
                        ,' ')
                    ,40) || RPAD(' '
                    ,40) || RPAD(NVL(VENDOR_CITY
                        ,' ')
                    ,40) || RPAD(NVL(VENDOR_STATE
                        ,' ')
                    ,2) || RPAD(NVL(VENDOR_ZIP
                        ,' ')
                    ,9) || ' ' || TO_CHAR(C_RECORD_SEQUENCE
                       ,'fm00000000') || RPAD(' '
                    ,36) || RPAD(' '
                    ,1) || RPAD(' '
                    ,2) || RPAD(' '
                    ,1) || RPAD(' '
                    ,99) || RPAD(' '
                    ,16) || RPAD(' '
                    ,60) || RPAD(' '
                    ,12) || RPAD(' '
                    ,12) || RPAD(NVL(REGION_CODE
                        ,' ')
                    ,2));
    IF (NVL(MISC2
       ,0) < 0 OR NVL(MISC3
       ,0) < 0 OR NVL(MISC4
       ,0) < 0 OR NVL(MISC5
       ,0) < 0 OR NVL(MISC6
       ,0) < 0 OR NVL(MISC7
       ,0) < 0 OR NVL(MISC8
       ,0) < 0 OR NVL(MISC9
       ,0) < 0 OR NVL(MISC10
       ,0) < 0 OR NVL(MISC13
       ,0) < 0 OR NVL(MISC14
       ,0) < 0 OR NVL(MISC15A
       ,0) < 0 OR NVL(MISC15B
       ,0) < 0) THEN
      RETURN NULL;
    ELSE
      RETURN (TEMP_REC);
    END IF;
  END C_B_RECORDFORMULA;

  FUNCTION C_C_RECORDFORMULA(C_NUM_OF_PAYEES IN NUMBER
                            ,C_TOTAL1 IN NUMBER
                            ,C_TOTAL2 IN NUMBER
                            ,C_TOTAL3 IN NUMBER
                            ,C_TOTAL4 IN NUMBER
                            ,C_TOTAL5 IN NUMBER
                            ,C_TOTAL6 IN NUMBER
                            ,C_TOTAL7 IN NUMBER
                            ,C_TOTAL8 IN NUMBER
                            ,C_TOTAL10 IN NUMBER
                            ,C_TOTAL13 IN NUMBER
                            ,C_TOTAL14 IN NUMBER
                            ,C_TOTAL15A IN NUMBER
                            ,C_TOTAL15B IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('C' || TO_CHAR(C_NUM_OF_PAYEES
                  ,'fm00000000') || RPAD(' '
               ,6) || TO_CHAR(C_TOTAL1 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL2 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL3 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL4 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL5 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL6 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL7 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL8 * 100
                  ,'fm000000000000000000') || RPAD('0'
               ,18
               ,'0') || TO_CHAR(C_TOTAL10 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL13 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL14 * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL15A * 100
                  ,'fm000000000000000000') || TO_CHAR(C_TOTAL15B * 100
                  ,'fm000000000000000000') || RPAD(' '
               ,232) || TO_CHAR(C_NUM_OF_PAYEES + 3
                  ,'fm00000000') || RPAD(' '
               ,241));
  END C_C_RECORDFORMULA;

  FUNCTION C_F_RECORDFORMULA(C_NUM_OF_PAYEES IN NUMBER
                            ,C_NUM_OF_K_RECORDS IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('F' || '00000001' || RPAD('0'
               ,21
               ,'0') || RPAD(' '
               ,19) || TO_CHAR(C_NUM_OF_PAYEES
                  ,'fm00000000') || RPAD(' '
               ,442) || TO_CHAR((NVL(C_NUM_OF_PAYEES
                      ,0) + NVL(C_NUM_OF_K_RECORDS
                      ,0) + 4)
                  ,'fm00000000') || RPAD(' '
               ,241));
  END C_F_RECORDFORMULA;

  FUNCTION C_T_RECORDFORMULA(C_TEST_INDICATOR IN VARCHAR2
                            ,C_FOREIGN_PAYER_FLAG IN VARCHAR2
                            ,C_NUM_OF_PAYEES IN NUMBER
                            ,C_MTFI IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('T' || RPAD(C_PAYMENT_YEAR
               ,4) || RPAD(C_PRIOR_YEAR_DATA
               ,1) || RPAD(NVL(C_EIN
                   ,' ')
               ,9) || RPAD(NVL(P_TCC
                   ,' ')
               ,5) || RPAD(NVL(P_REPLACEMENT_ALPHA_CHARACTER
                   ,' ')
               ,2) || RPAD(' '
               ,5) || RPAD(NVL(C_TEST_INDICATOR
                   ,' ')
               ,1) || RPAD(NVL(C_FOREIGN_PAYER_FLAG
                   ,' ')
               ,1) || RPAD(NVL(UPPER(C_FIRST_NAME)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_SECOND_NAME)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_FIRST_NAME)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_SECOND_NAME)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_ADDRESS)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_CITY)
                   ,' ')
               ,40) || RPAD(NVL(UPPER(C_STATE)
                   ,' ')
               ,2) || RPAD(NVL(UPPER(C_ZIP)
                   ,' ')
               ,9) || RPAD(' '
               ,15) || TO_CHAR(C_NUM_OF_PAYEES
                  ,'fm00000000') || RPAD(NVL(UPPER(P_CONTACT_NAME)
                   ,' ')
               ,40) || RPAD(NVL(TO_CHAR(P_TELEPHONE_NUMBER)
                   ,' ')
               ,15) || RPAD(NVL(P_CONTACT_EMAIL
                   ,' ')
               ,35) || RPAD(NVL(C_MTFI
                   ,' ')
               ,2) || RPAD(NVL(P_ELECTRONIC_FILE_NAME
                   ,' ')
               ,15) || RPAD(' '
               ,89) || '00000001' || RPAD(' '
               ,10) || RPAD('V'
               ,1) || RPAD('ORACLE USA INC'
               ,40) || RPAD('500 ORACLE PARKWAY'
               ,40) || RPAD('REDWOOD SHORES'
               ,40) || RPAD('CA'
               ,2) || RPAD('94065'
               ,9) || RPAD('PAYABLES PRODUCT MANAGER'
               ,40) || RPAD('6505067000'
               ,15) || RPAD('APNEWS_US@ORACLE.COM'
               ,20) || RPAD(''
               ,24));
  END C_T_RECORDFORMULA;

  FUNCTION C_K_RECORDFORMULA(NUM_OF_PAYEES IN NUMBER
                            ,CONTROL_TOTAL1 IN NUMBER
                            ,CONTROL_TOTAL2 IN NUMBER
                            ,CONTROL_TOTAL3 IN NUMBER
                            ,CONTROL_TOTAL5 IN NUMBER
                            ,CONTROL_TOTAL6 IN NUMBER
                            ,CONTROL_TOTAL7 IN NUMBER
                            ,CONTROL_TOTAL8 IN NUMBER
                            ,CONTROL_TOTAL10 IN NUMBER
                            ,CONTROL_TOTAL13 IN NUMBER
                            ,CONTROL_TOTAL14 IN NUMBER
                            ,CONTROL_TOTAL15A IN NUMBER
                            ,CONTROL_TOTAL15B IN NUMBER
                            ,K_REGION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    C_RECORD_SEQUENCE := C_RECORD_SEQUENCE + 1;
    RETURN ('K' || TO_CHAR(NUM_OF_PAYEES
                  ,'fm00000000') || RPAD(' '
               ,6) || TO_CHAR(CONTROL_TOTAL1 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL2 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL3 * 100
                  ,'fm000000000000000000') || RPAD('0'
               ,18
               ,'0') || TO_CHAR(CONTROL_TOTAL5 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL6 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL7 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL8 * 100
                  ,'fm000000000000000000') || RPAD('0'
               ,18
               ,'0') || TO_CHAR(CONTROL_TOTAL10 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL13 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL14 * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL15A * 100
                  ,'fm000000000000000000') || TO_CHAR(CONTROL_TOTAL15B * 100
                  ,'fm000000000000000000') || RPAD(' '
               ,232) || TO_CHAR(C_RECORD_SEQUENCE + 1
                  ,'fm00000000') || RPAD(' '
               ,199) || RPAD(' '
               ,18) || RPAD(' '
               ,18) || RPAD(' '
               ,4) || RPAD(K_REGION_CODE
               ,2));
  END C_K_RECORDFORMULA;

  FUNCTION CF_NEGATIVE_MISCFORMULA(MISC2 IN NUMBER
                                  ,MISC3 IN NUMBER
                                  ,MISC4 IN NUMBER
                                  ,MISC5 IN NUMBER
                                  ,MISC6 IN NUMBER
                                  ,MISC7 IN NUMBER
                                  ,MISC8 IN NUMBER
                                  ,MISC9 IN NUMBER
                                  ,MISC10 IN NUMBER
                                  ,MISC13 IN NUMBER
                                  ,MISC14 IN NUMBER
                                  ,MISC15A IN NUMBER
                                  ,MISC15B IN NUMBER
                                  ,ERROR_TEXT IN VARCHAR2
                                  ,VENDOR_NAME IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (NVL(MISC2
       ,0) < 0 OR NVL(MISC3
       ,0) < 0 OR NVL(MISC4
       ,0) < 0 OR NVL(MISC5
       ,0) < 0 OR NVL(MISC6
       ,0) < 0 OR NVL(MISC7
       ,0) < 0 OR NVL(MISC8
       ,0) < 0 OR NVL(MISC9
       ,0) < 0 OR NVL(MISC10
       ,0) < 0 OR NVL(MISC13
       ,0) < 0 OR NVL(MISC14
       ,0) < 0 OR NVL(MISC15A
       ,0) < 0 OR NVL(MISC15B
       ,0) < 0) AND ERROR_TEXT IS NULL THEN
      C_ERROR_REASON := 'Negative MISC total';
      C_ERROR_VENDOR := VENDOR_NAME;
    END IF;
    RETURN NULL;
  END CF_NEGATIVE_MISCFORMULA;

  FUNCTION PERFORM_FEDERAL_LIMIT_UPDATES RETURN BOOLEAN IS
  BEGIN
    UPDATE
      AP_1099_TAPE_DATA
    SET
      MISC2 = 0
    WHERE VENDOR_ID in (
      SELECT
        VENDOR_ID
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC2
             ,0)) < 10 );
    UPDATE
      AP_1099_TAPE_DATA
    SET
      MISC8 = 0
    WHERE VENDOR_ID in (
      SELECT
        VENDOR_ID
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC8
             ,0)) < 10 );
    UPDATE
      AP_1099_TAPE_DATA
    SET
      MISC15ANT = 0
      ,MISC15AT = 0
    WHERE VENDOR_ID in (
      SELECT
        VENDOR_ID
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC15ANT
             ,0) + NVL(MISC15AT
             ,0)) < P_FEDERAL_REPORTING_LIMIT );
    UPDATE
      AP_1099_TAPE_DATA
    SET
      MISC7 = 0
    WHERE VENDOR_ID in (
      SELECT
        VENDOR_ID
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC7
             ,0)) < P_FEDERAL_REPORTING_LIMIT );
    UPDATE
      AP_1099_TAPE_DATA
    SET
      MISC1 = 0
      ,MISC3 = 0
      ,MISC6 = 0
      ,MISC7 = 0
      ,MISC9 = 0
      ,MISC10 = 0
    WHERE VENDOR_ID in (
      SELECT
        VENDOR_ID
      FROM
        AP_1099_TAPE_DATA
      GROUP BY
        VENDOR_ID
      HAVING SUM(NVL(MISC1
             ,0)) + SUM(NVL(MISC3
             ,0)) + SUM(NVL(MISC6
             ,0)) + SUM(NVL(MISC7
             ,0)) + SUM(NVL(MISC9
             ,0)) + SUM(NVL(MISC10
             ,0)) < P_FEDERAL_REPORTING_LIMIT
        AND SUM(NVL(MISC15B
             ,0)) > 0 );
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END PERFORM_FEDERAL_LIMIT_UPDATES;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ALL;
  END C_NLS_ALL_P;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_VOID;
  END C_NLS_VOID_P;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NA;
  END C_NLS_NA_P;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_REPORT_START_DATE;
  END C_REPORT_START_DATE_P;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;

  FUNCTION APPLICATIONS_TEMPLATE_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN APPLICATIONS_TEMPLATE_REPORT;
  END APPLICATIONS_TEMPLATE_REPORT_P;

  FUNCTION C_COMBINED_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMBINED_FLAG;
  END C_COMBINED_FLAG_P;

  FUNCTION C_FIRST_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FIRST_NAME;
  END C_FIRST_NAME_P;

  FUNCTION C_ADDRESS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ADDRESS;
  END C_ADDRESS_P;

  FUNCTION C_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATA_EXISTS;
  END C_DATA_EXISTS_P;

  FUNCTION C_TRANSMITTER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TRANSMITTER_NAME;
  END C_TRANSMITTER_NAME_P;

  FUNCTION C_TRANSMITTER_ADDRESS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TRANSMITTER_ADDRESS;
  END C_TRANSMITTER_ADDRESS_P;

  FUNCTION C_TRANSMITTER_CSZ_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TRANSMITTER_CSZ;
  END C_TRANSMITTER_CSZ_P;

  FUNCTION C_SECOND_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SECOND_NAME;
  END C_SECOND_NAME_P;

  FUNCTION C_TRANSFER_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TRANSFER_FLAG;
  END C_TRANSFER_FLAG_P;

  FUNCTION C_EIN_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EIN;
  END C_EIN_P;

  FUNCTION C_PAYMENT_YEAR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PAYMENT_YEAR;
  END C_PAYMENT_YEAR_P;

  FUNCTION C_TIN_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TIN;
  END C_TIN_P;

  FUNCTION C_AMOUNT_INDICATOR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_AMOUNT_INDICATOR;
  END C_AMOUNT_INDICATOR_P;

  FUNCTION C_ERROR_VENDOR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERROR_VENDOR;
  END C_ERROR_VENDOR_P;

  FUNCTION C_ERROR_REASON_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERROR_REASON;
  END C_ERROR_REASON_P;

  FUNCTION C_SPACE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SPACE;
  END C_SPACE_P;

  FUNCTION C_DOUBLE_SPACE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DOUBLE_SPACE;
  END C_DOUBLE_SPACE_P;

  FUNCTION C_NUMBER_OF_B_RECS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NUMBER_OF_B_RECS;
  END C_NUMBER_OF_B_RECS_P;

  FUNCTION C_PRIOR_YEAR_DATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PRIOR_YEAR_DATA;
  END C_PRIOR_YEAR_DATA_P;

  FUNCTION C_CITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CITY;
  END C_CITY_P;

  FUNCTION C_STATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATE;
  END C_STATE_P;

  FUNCTION C_ZIP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ZIP;
  END C_ZIP_P;

  FUNCTION C_INDICATOR_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INDICATOR_STATUS;
  END C_INDICATOR_STATUS_P;

END AP_APXT7CMT_XMLP_PKG;



/
