--------------------------------------------------------
--  DDL for Package Body XTR_XTRTMBLT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTRTMBLT_XMLP_PKG" AS
/* $Header: XTRTMBLTB.pls 120.1 2007/12/28 13:01:56 npannamp noship $ */
  FUNCTION CF_SET_PARAFORMULA RETURN VARCHAR2 IS
  BEGIN
    SELECT
      SUBSTR(USER
            ,1
            ,10)
    INTO
      CP_PARA
    FROM
      DUAL;
    RETURN (CP_PARA);
  END CF_SET_PARAFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_DMMY_NUM NUMBER;
    L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    CURSOR GET_LANGUAGE_DESC IS
      SELECT
        ITEM_NAME,
        SUBSTR(TEXT
              ,1
              ,100) LANG_NAME
      FROM
        XTR_SYS_LANGUAGES_VL
      WHERE MODULE_NAME = 'XTRTMBLT';
  BEGIN
    BEGIN
      COMPANY_NAME_HEADER := CEP_STANDARD.GET_WINDOW_SESSION_TITLE;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('XTR'
                            ,'XTR_LOOKUP_ERR');
        L_MESSAGE := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR(-20101
                               ,NULL);
    END;
    FOR c IN GET_LANGUAGE_DESC LOOP
      IF C.ITEM_NAME = 'Z1ACCT_MGR' THEN
        Z1ACCT_MGR := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1AS_AT' THEN
        Z1AS_AT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1BALANCES_FROM' THEN
        Z1BALANCES_FROM := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1COMPANY' THEN
        Z1COMPANY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1DEAL_SUBTYPE' THEN
        Z1DEAL_SUBTYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1NAME' THEN
        Z1NAME := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1OVERDUES_ONLY' THEN
        Z1OVERDUES_ONLY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PARAMETERS' THEN
        Z1PARAMETERS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PARTY_CODE' THEN
        Z1PARTY_CODE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PRODUCT' THEN
        Z1PRODUCT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2ACCRUED' THEN
        Z2ACCRUED := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CCY' THEN
        Z2CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CODE' THEN
        Z2CODE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2COMMENCE' THEN
        Z2COMMENCE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CPARTY' THEN
        Z2CPARTY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2END_OF_REPORT' THEN
        Z2END_OF_REPORT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST' THEN
        Z2INTEREST := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2MATURITY' THEN
        Z2MATURITY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2NUMBER' THEN
        Z2NUMBER := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PRINCIPAL_BALANCE' THEN
        Z2PRINCIPAL_BALANCE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2RECENT_ROLLOVER' THEN
        Z2RECENT_ROLLOVER := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REF' THEN
        Z2REF := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2TOTALS' THEN
        Z2TOTALS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PAGE' THEN
        Z2PAGE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'REPORT_DATE' THEN
        REPORT_DATE := C.LANG_NAME;
      END IF;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
   a date;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    SELECT
      CP.USER_CONCURRENT_PROGRAM_NAME
    INTO
      REPORT_SHORT_NAME
    FROM
      FND_CONCURRENT_PROGRAMS_VL CP,
      FND_CONCURRENT_REQUESTS CR
    WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
      AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
      AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
  REPORT_SHORT_NAME := SUBSTR(REPORT_SHORT_NAME,1,INSTR(REPORT_SHORT_NAME,' (XML)'));
  if p_as_of_date is not null then
   a := to_date(substr(p_as_of_date, 1, 10), 'YYYY/MM/DD');
  else
   a := trunc(sysdate);
  end if;
  lp_as_of_date := nvl(to_char(to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY'),trunc(sysdate));
  /*las_at_date2  := to_date(lp_as_of_date,'YYYY/MM/DD HH24:MI:SS');  --Bug 3312910*/
  as_at_date2 := a;
  --as_at_date2 := to_date(a,'YYYY/MM/DD HH24:MI:SS');


    COMPANY2 := P_COMPANY;
    CPARTY_CODE2 := P_CPARTY;
    CPARTY_NAME2 := P_CPARTY_NAME;
    PRODUCT_TYPE2 := P_PRODUCT_TYPE;
    BALANCES_FROM2 := P_BALANCES_FROM;
    ACCOUNT_MANAGER2 := P_ACCOUNT_MANAGER;
    OVERDUE_ONLY2 := P_OVERDUE_AMOUNTS_ONLY;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CP_PARA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARA;
  END CP_PARA_P;

END XTR_XTRTMBLT_XMLP_PKG;


/