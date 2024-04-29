--------------------------------------------------------
--  DDL for Package Body PAY_PYAUPYT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYAUPYT_XMLP_PKG" AS
/* $Header: PYAUPYLB.pls 120.0 2007/12/13 12:14:38 amakrish noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      DELETE FROM PAY_ACTION_INFORMATION
       WHERE ACTION_INFORMATION_CATEGORY = 'AU_PAYROLL_TAX_EMPLOYEE_DETAILS'
         AND ACTION_CONTEXT_ID = P_PAYROLL_ACTION_ID_LP;
      DELETE FROM PAY_ACTION_INFORMATION
       WHERE ACTION_INFORMATION_CATEGORY in ( 'AU_PAYROLL_TAX_DGE_DETAILS' , 'AU_PAYROLL_TAX_BALANCE_DETAILS_YTD' )
         AND ACTION_CONTEXT_ID in (
         SELECT
           PAA.ASSIGNMENT_ACTION_ID
         FROM
           PAY_ASSIGNMENT_ACTIONS PAA
         WHERE PAA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID_LP );
      DELETE FROM PAY_ACTION_INFORMATION
       WHERE ACTION_INFORMATION_CATEGORY = 'AU_ARCHIVE_ASG_DETAILS'
         AND ACTION_INFORMATION2 = P_PAYROLL_ACTION_ID_LP;
      DELETE FROM PAY_ASSIGNMENT_ACTIONS PAA
       WHERE PAA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID_LP;
      DELETE FROM PAY_PAYROLL_ACTIONS PPA
       WHERE PPA.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID_LP;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;
    COMMIT;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_BUSINESS_GROUPFORMULA RETURN VARCHAR2 IS
    V_BUSINESS_GROUP HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
  BEGIN
    V_BUSINESS_GROUP := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID_LP);
    RETURN V_BUSINESS_GROUP;
  END CF_BUSINESS_GROUPFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_STATE IS
      SELECT
        MEANING
      FROM
        HR_LOOKUPS
      WHERE LOOKUP_TYPE = 'AU_STATE'
        AND ENABLED_FLAG = 'Y'
        AND LOOKUP_CODE = P_TAX_STATE_LP;
    CURSOR C_TYPE IS
      SELECT
        MEANING
      FROM
        HR_LOOKUPS
      WHERE LOOKUP_TYPE = 'AU_PAYROLL_TAX_REPORT_TYPE'
        AND ENABLED_FLAG = 'Y'
        AND LOOKUP_CODE = P_REPORT_TYPE_LP;
    CURSOR C_LEGAL_EMPLOYER IS
      SELECT
        NAME
      FROM
        HR_AU_LEG_EMP_V
      WHERE ORGANIZATION_ID = P_LEGAL_EMPLOYER_LP;
    CURSOR C_DGE IS
      SELECT
        ORG_INFORMATION3
      FROM
        HR_ORGANIZATION_UNITS HOU,
        HR_ORGANIZATION_INFORMATION HOI
      WHERE HOI.ORGANIZATION_ID = P_LEGAL_EMPLOYER_LP
        AND HOI.ORG_INFORMATION2 = P_TAX_STATE_LP
        AND HOI.ORG_INFORMATION_CONTEXT = 'AU_PAYROLL_TAX_DGE';

 -- pragma autonomous_transaction;

  BEGIN

  select
  SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1))
 ,
  SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
  SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3))
  ,
  SUBSTR(argument4,INSTR(argument4,'=',1)+1,LENGTH(argument4)),
  SUBSTR(argument5,INSTR(argument5,'=',1)+1,LENGTH(argument5)),
  SUBSTR(argument6,INSTR(argument6,'=',1)+1,LENGTH(argument6)),
  SUBSTR(argument7,INSTR(argument7,'=',1)+1,LENGTH(argument7)),
  SUBSTR(argument8,INSTR(argument8,'=',1)+1,LENGTH(argument8)),
  SUBSTR(argument9,INSTR(argument9,'=',1)+1,LENGTH(argument9)),
  SUBSTR(argument10,INSTR(argument10,'=',1)+1,LENGTH(argument10)),
  SUBSTR(argument11,INSTR(argument11,'=',1)+1,LENGTH(argument11)),
  SUBSTR(argument12,INSTR(argument12,'=',1)+1,LENGTH(argument12)),
  SUBSTR(argument13,INSTR(argument13,'=',1)+1,LENGTH(argument13)),
  SUBSTR(argument14,INSTR(argument14,'=',1)+1,LENGTH(argument14)),
  SUBSTR(argument15,INSTR(argument15,'=',1)+1,LENGTH(argument15)),
  SUBSTR(argument16,INSTR(argument16,'=',1)+1,LENGTH(argument16)),
  SUBSTR(argument17,INSTR(argument17,'=',1)+1,LENGTH(argument17))
  into
  P_PAYROLL_ACTION_ID_LP
  ,
  P_BUSINESS_GROUP_ID_LP,
  P_LEGAL_EMPLOYER_LP
  ,
  P_PERIOD_LP_1,
  P_START_DATE_LP_1,
  P_END_DATE_LP_1,
  P_TAX_STATE_LP,
  P_ACT_LP,
  P_QLD_LP,
  P_SA_LP,
  P_TAS_LP,
  P_VIC_LP ,
  P_WA_LP ,
  P_NSW_LP,
  P_NT_LP,
  P_REPORT_TYPE_LP ,
  P_REPORT_NAME_LP

    from FND_CONCURRENT_REQUESTS
where request_id= FND_GLOBAL.conc_request_id;

--insert into log_msg values('ATUL' , 'PYIEBIKA' ,'TEST' , P_BUSINESS_GROUP_ID_LP);

--   commit;
--RAISE_APPLICATION_ERROR(-20001,'P_PERIOD_LP_1 :'|| P_PERIOD_LP_1||','||'P_START_DATE_LP_1 :'|| P_START_DATE_LP_1 ||',' || 'P_END_DATE_LP_1 :'|| P_END_DATE_LP_1) ;
P_PERIOD_LP := TO_DATE(P_PERIOD_LP_1,'YYYY/MM/DD');
FINAL_DATE := TO_CHAR(P_PERIOD_LP,'MON/YYYY');
P_START_DATE := TO_DATE(P_START_DATE_LP_1,'YYYY/MM/DD');
P_END_DATE := TO_DATE(P_END_DATE_LP_1,'YYYY/MM/DD');

    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    IF (P_LEGAL_EMPLOYER_LP IS NOT NULL) THEN
      OPEN C_LEGAL_EMPLOYER;
      FETCH C_LEGAL_EMPLOYER
       INTO
         CP_LEGAL_EMPLOYER;
      CLOSE C_LEGAL_EMPLOYER;
    ELSE
      CP_LEGAL_EMPLOYER := NULL;
    END IF;
    IF (P_TAX_STATE_LP IS NOT NULL) THEN
      OPEN C_STATE;
      FETCH C_STATE
       INTO
         CP_TAX_STATE;
      CLOSE C_STATE;
    ELSE
      CP_TAX_STATE := NULL;
    END IF;
    IF (P_REPORT_TYPE_LP IS NOT NULL) THEN
      OPEN C_TYPE;
      FETCH C_TYPE
       INTO
         CP_REPORT_TYPE;
      CLOSE C_TYPE;
    ELSE
      CP_REPORT_TYPE := NULL;
    END IF;
    IF (P_LEGAL_EMPLOYER_LP IS NOT NULL AND P_TAX_STATE_LP IS NOT NULL) THEN
      OPEN C_DGE;
      FETCH C_DGE
       INTO
         CP_DGE;
      CLOSE C_DGE;
    ELSE
      CP_DGE := NULL;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_LEGISLATION_CODEFORMULA RETURN VARCHAR2 IS
    V_LEGISLATION_CODE HR_ORGANIZATION_INFORMATION.ORG_INFORMATION9%TYPE := NULL;
    CURSOR LEGISLATION_CODE(C_BUSINESS_GROUP_ID IN HR_ORGANIZATION_INFORMATION.ORGANIZATION_ID%TYPE) IS
      SELECT
        ORG_INFORMATION9
      FROM
        HR_ORGANIZATION_INFORMATION
      WHERE ORGANIZATION_ID = C_BUSINESS_GROUP_ID
        AND ORG_INFORMATION9 is not null
        AND ORG_INFORMATION_CONTEXT = 'Business Group Information';
  BEGIN
    OPEN LEGISLATION_CODE(P_BUSINESS_GROUP_ID_LP);
    FETCH LEGISLATION_CODE
     INTO
       V_LEGISLATION_CODE;
    CLOSE LEGISLATION_CODE;
    RETURN V_LEGISLATION_CODE;
  END CF_LEGISLATION_CODEFORMULA;

  FUNCTION CF_CURRENCY_FORMAT_MASKFORMULA(CF_LEGISLATION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    V_CURRENCY_CODE FND_CURRENCIES.CURRENCY_CODE%TYPE;
    V_FORMAT_MASK VARCHAR2(100) := NULL;
    V_FIELD_LENGTH NUMBER(3) := 30;
    CURSOR CURRENCY_FORMAT_MASK(C_TERRITORY_CODE IN FND_CURRENCIES.ISSUING_TERRITORY_CODE%TYPE) IS
      SELECT
        CURRENCY_CODE
      FROM
        FND_CURRENCIES
      WHERE ISSUING_TERRITORY_CODE = C_TERRITORY_CODE;
  BEGIN
    OPEN CURRENCY_FORMAT_MASK(CF_LEGISLATION_CODE);
    FETCH CURRENCY_FORMAT_MASK
     INTO
       V_CURRENCY_CODE;
    CLOSE CURRENCY_FORMAT_MASK;
    IF (V_CURRENCY_CODE IS NOT NULL) THEN
      CP_CURRENCY := '(' || V_CURRENCY_CODE || ')';
    ELSE
      CP_CURRENCY := NULL;
    END IF;
    V_FORMAT_MASK := FND_CURRENCY.GET_FORMAT_MASK(V_CURRENCY_CODE
                                                 ,V_FIELD_LENGTH);
    RETURN V_FORMAT_MASK;
  END CF_CURRENCY_FORMAT_MASKFORMULA;

  FUNCTION CF_STATE_TAXFORMULA(NO_OF_STATES IN NUMBER
                              ,CS_DGE_STATE IN VARCHAR2
                              ,CS_DGE_GROUP_NAME IN VARCHAR2
                              ,STATE_CODE IN VARCHAR2
                              ,CS_STATE_TAXABLE_INCOME IN NUMBER
                              ,LE_TAXABLE_INCOME IN NUMBER
                              ,CS_NO_OF_STATES IN NUMBER
                              ,CS_TOTAL_TAXABLE_INCOME_LE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (P_LEGAL_EMPLOYER_LP IS NOT NULL) THEN
      IF (P_TAX_STATE_LP IS NOT NULL) THEN
        IF (P_TAX_STATE_LP = 'ACT') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_NSW_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'NSW') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_NSW_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'VIC') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_VIC_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'QLD') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_QLD_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'SA') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_SA_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'WA') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_WA_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'TAS') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_TAS_LP
                                             ,-9999)));
        END IF;
        IF (P_TAX_STATE_LP = 'NT') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_NT_LP
                                             ,-9999)));
        END IF;
      ELSE
        IF (STATE_CODE = 'ACT') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_ACT_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'NSW') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_NSW_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'VIC') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_VIC_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'QLD') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_QLD_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'SA') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_SA_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'WA') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_WA_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'TAS') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_TAS_LP
                                             ,-9999)));
        END IF;
        IF (STATE_CODE = 'NT') THEN
          RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(NO_OF_STATES
                                          ,CS_DGE_STATE
                                          ,CS_DGE_GROUP_NAME
                                          ,STATE_CODE
                                          ,CS_STATE_TAXABLE_INCOME
                                          ,LE_TAXABLE_INCOME
                                          ,CP_MESSAGE
                                          ,CP_OT_MESSAGE
                                          ,P_START_DATE
                                          ,P_END_DATE
                                          ,NVL(P_NT_LP
                                             ,-9999)));
        END IF;
      END IF;
    ELSE
      RETURN (PAY_AU_PAYTAX_PKG.GET_TAX(CS_NO_OF_STATES
                                      ,CS_DGE_STATE
                                      ,CS_DGE_GROUP_NAME
                                      ,STATE_CODE
                                      ,CS_STATE_TAXABLE_INCOME
                                      ,CS_TOTAL_TAXABLE_INCOME_LE
                                      ,CP_MESSAGE
                                      ,CP_OT_MESSAGE
                                      ,P_START_DATE
                                      ,P_END_DATE
                                      ,-9999));
    END IF;
  END CF_STATE_TAXFORMULA;

  PROCEDURE SET_FORMAT_MASK IS
  BEGIN
    NULL;
  END SET_FORMAT_MASK;

  FUNCTION CP_OT_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OT_MESSAGE;
  END CP_OT_MESSAGE_P;

  FUNCTION CP_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_MESSAGE;
  END CP_MESSAGE_P;

  FUNCTION CP_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CURRENCY;
  END CP_CURRENCY_P;

  FUNCTION CP_TAX_STATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TAX_STATE;
  END CP_TAX_STATE_P;

  FUNCTION CP_REPORT_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TYPE;
  END CP_REPORT_TYPE_P;

  FUNCTION CP_LEGAL_EMPLOYER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LEGAL_EMPLOYER;
  END CP_LEGAL_EMPLOYER_P;

  FUNCTION CP_DGE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_DGE;
  END CP_DGE_P;

END PAY_PYAUPYT_XMLP_PKG;

/
