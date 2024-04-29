--------------------------------------------------------
--  DDL for Package Body WIP_WIPUTACS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPUTACS_XMLP_PKG" AS
/* $Header: WIPUTACSB.pls 120.1 2008/01/31 12:53:43 npannamp noship $ */
  FUNCTION LIMIT_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(120);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND WT.transaction_date >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')' || ' AND WT.transaction_date < TO_DATE(''' || TO_CHAR(P_TO_DATE + 1
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND WT.transaction_date >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND WT.transaction_date < TO_DATE(''' || TO_CHAR(P_TO_DATE + 1
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_DATES;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

	select FC.precision Precision into mprecision
	from org_organization_definitions OOD
	 ,        gl_code_combinations L
	 ,    fnd_currencies FC
	where OOD.organization_id = P_Organization_Id
	  and FC.currency_code = P_Currency_Code
	and L.chart_of_accounts_id(+) = decode(1,2,ood.organization_id,P_STRUCT_NUM)
	and L.code_combination_id(+) = NVL(P_Account,-1);

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('
                      FND FLEXSQL
                      CODE="GL#"
                      NUM=":P_STRUCT_NUM"
                      APPL_SHORT_NAME="SQLGL"
                      OUTPUT=":P_FLEXDATA"
                      TABLEALIAS="L"
                      MODE="SELECT"
                      DISPLAY="ALL"
                    ')*/NULL;
      IF (P_PROJECT_ID IS NOT NULL) THEN
        P_PROJECT_WHERE := 'WT.PROJECT_ID =' || P_PROJECT_ID;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(MCAT) >X')*/NULL;
        RAISE;
    END;
    LP_FROM_DATE:=to_char(P_FROM_DATE,'DD-MON-YYYY');
    LP_TO_DATE:=to_char(P_TO_DATE,'DD-MON-YYYY');
    RETURN TRUE;
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_SUBTITLE_CURRENCYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || P_CURRENCY_CODE || ')');
  END C_SUBTITLE_CURRENCYFORMULA;

  FUNCTION C_ACCT_DESCRIPFORMULA(C_FLEXDATA IN VARCHAR2
                                ,ACCOUNT IN VARCHAR2
                                ,C_ACCT_DESCRIP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(C_FLEXDATA)*/NULL;
      /*SRW.REFERENCE(ACCOUNT)*/NULL;
      RETURN (C_ACCT_DESCRIP);
    END;
    RETURN NULL;
  END C_ACCT_DESCRIPFORMULA;

  FUNCTION C_FLEX_SORTFORMULA(C_FLEXDATA IN VARCHAR2
                             ,ACCOUNT IN VARCHAR2
                             ,C_ACCT_DESCRIP IN VARCHAR2
                             ,C_FLEX_SORT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(C_FLEXDATA)*/NULL;
      /*SRW.REFERENCE(ACCOUNT)*/NULL;
      /*SRW.REFERENCE(C_ACCT_DESCRIP)*/NULL;
      RETURN (C_FLEX_SORT);
    END;
    RETURN NULL;
  END C_FLEX_SORTFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_ACCOUNT IS NOT NULL THEN
      P_LIMIT_ACCOUNTS := 'and wa.reference_account = :P_Account';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

FUNCTION GET_PRECISION(QTY_PRECISION IN NUMBER) RETURN VARCHAR2 is
begin

if qty_precision = 0 then return('999G999G999G990');

elsif qty_precision = 1 then return('999G999G999G990D0');

elsif qty_precision = 3 then return('999G999G999G990D000');

elsif qty_precision = 4 then return('999G999G999G990D0000');

elsif qty_precision = 5 then return('999G999G999G990D00000');

elsif qty_precision = 6 then  return('999G999G999G990D000000');

else return('999G999G999G990D00');

end if;

end;

END WIP_WIPUTACS_XMLP_PKG;


/
