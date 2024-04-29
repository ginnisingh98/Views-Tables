--------------------------------------------------------
--  DDL for Package Body PAY_PAYRP940_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRP940_XMLP_PKG" AS
/* $Header: PAYUS940B.pls 120.1 2008/03/18 06:27:35 srikrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  --  HR_STANDARD.EVENT('BEFORE REPORT');
    C_GAZ_START_DATE := TO_DATE('01-01-' || P_TAX_YEAR
                               ,'DD-MM-YYYY');
    C_BUSINESS_GROUP_NAME := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    IF P_TAX_UNIT_ID IS NOT NULL THEN
      C_TAX_UNIT :=  HR_US_REPORTS.GET_ORG_NAME(P_TAX_UNIT_ID
                                ,P_BUSINESS_GROUP_ID);
    END IF;
    SELECT
      DECODE(COUNT(PAA.ASSIGNMENT_ID)
            ,0
            ,'F'
            ,'T')
    INTO P_FLAG
    FROM
      PAY_ASSIGNMENT_ACTIONS PAA,
      PAY_PAYROLL_ACTIONS PACT
    WHERE PACT.EFFECTIVE_DATE <= TO_DATE('31-12-' || P_TAX_YEAR
           ,'DD-MM-YYYY')
      AND PACT.EFFECTIVE_DATE >= TO_DATE('01-01-' || P_TAX_YEAR
           ,'DD-MM-YYYY')
      AND PACT.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND PACT.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
      AND PACT.ACTION_TYPE in ( 'R' , 'Q' , 'I' , 'V' , 'B' )
      AND PAA.TAX_UNIT_ID = P_TAX_UNIT_ID;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_TRACEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TRACE = 'Y' THEN
      EXECUTE IMMEDIATE
        'ALTER SESSION SET SQL_TRACE=TRUE';
    END IF;
    RETURN NULL;
  END C_TRACEFORMULA;

  FUNCTION C_STATE_EINFORMULA(TAX_UNIT_ID IN NUMBER
                             ,STATE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CURSOR MY_CURSOR IS
        SELECT
          ORG_INFORMATION2
        FROM
          HR_ORGANIZATION_INFORMATION
        WHERE ORGANIZATION_ID = TAX_UNIT_ID
          AND ORG_INFORMATION_CONTEXT = 'State Tax Rules'
          AND ORG_INFORMATION1 = STATE_CODE;
      STATE_ID VARCHAR2(25);
    BEGIN
      OPEN MY_CURSOR;
      FETCH MY_CURSOR
       INTO STATE_ID;
      CLOSE MY_CURSOR;
      IF STATE_ID IS NOT NULL THEN
        RETURN (STATE_ID);
      ELSE
        RETURN ('NO STATE EIN');
      END IF;
    END;
    RETURN NULL;
  END C_STATE_EINFORMULA;

  FUNCTION C_TOTAL_PAYMENTSFORMULA(TAX_UNIT_ID IN NUMBER
                                  ,C_GAZ_END_DATE IN DATE) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURSOR C_GET_FED_VALUES(P_TAX_UNIT_ID IN NUMBER) IS
        SELECT
          D_TAX_OTD_VALUE,
          D_WAGE_OTD_VALUE,
          D_FORMAT_CODE
        FROM
          PAY_US_FEDERAL_TAX_BAL_GRE_V
        WHERE D_BALANCE_SET_NAME = '940_FED_YTD'
          AND D_TAX_UNIT_ID = P_TAX_UNIT_ID;
      L_REDUCED_SUBJ_WHABLE NUMBER;
      L_GROSS_EARNINGS NUMBER;
      L_REGULAR_EARNINGS NUMBER;
      L_PRE_TAX NUMBER;
      L_FUTA_TAXABLE NUMBER;
      L_VALUE2 NUMBER;
      L_VALUE3 NUMBER;
      L_VALUE4 NUMBER;
      L_VALUE7 NUMBER;
      L_VALUE8 NUMBER;
      L_VALUE9 NUMBER;
      L_VALUE10 NUMBER;
      LL_VALUE5 NUMBER;
      L_SUPP_EARN NUMBER;
      L_PRE_TAX_FUTA NUMBER;
      L_FORMAT_CODE VARCHAR2(1);
      L_TAX_OTD_VALUE NUMBER;
      L_WAGE_OTD_VALUE NUMBER;
    BEGIN
      IF CP_940_FED_STATUS <> 'Y' THEN
        PAY_US_TAXBAL_VIEW_PKG.US_GP_MULTIPLE_GRE_YTD(P_TAX_UNIT_ID => TAX_UNIT_ID
                                                     ,P_EFFECTIVE_DATE => C_GAZ_END_DATE
                                                     ,P_BALANCE_NAME1 => 'Gross Earnings'
                                                     ,P_BALANCE_NAME2 => NULL
                                                     ,P_BALANCE_NAME3 => 'Regular Earnings'
                                                     ,P_BALANCE_NAME4 => NULL
                                                     ,P_BALANCE_NAME5 => 'Pre Tax Deductions'
                                                     ,P_BALANCE_NAME6 => 'FUTA Taxable'
                                                     ,P_BALANCE_NAME7 => NULL
                                                     ,P_BALANCE_NAME8 => NULL
                                                     ,P_BALANCE_NAME9 => NULL
                                                     ,P_BALANCE_NAME10 => NULL
                                                     ,P_VALUE1 => L_GROSS_EARNINGS
                                                     ,P_VALUE2 => L_VALUE2
                                                     ,P_VALUE3 => L_REGULAR_EARNINGS
                                                     ,P_VALUE4 => L_VALUE4
                                                     ,P_VALUE5 => L_PRE_TAX
                                                     ,P_VALUE6 => L_FUTA_TAXABLE
                                                     ,P_VALUE7 => L_VALUE7
                                                     ,P_VALUE8 => L_VALUE8
                                                     ,P_VALUE9 => L_VALUE9
                                                     ,P_VALUE10 => L_VALUE10);
        PAY_US_TAXBAL_VIEW_PKG.US_GP_SUBJECT_TO_TAX_GRE_YTD(P_BALANCE_NAME1 => 'Supplemental Earnings for FUTA'
                                                           ,P_BALANCE_NAME2 => NULL
                                                           ,P_BALANCE_NAME3 => NULL
                                                           ,P_BALANCE_NAME4 => 'Pre Tax Deductions for FUTA'
                                                           ,P_BALANCE_NAME5 => NULL
                                                           ,P_EFFECTIVE_DATE => C_GAZ_END_DATE
                                                           ,P_TAX_UNIT_ID => TAX_UNIT_ID
                                                           ,P_VALUE1 => L_SUPP_EARN
                                                           ,P_VALUE2 => L_VALUE2
                                                           ,P_VALUE3 => L_VALUE3
                                                           ,P_VALUE4 => L_PRE_TAX_FUTA
                                                           ,P_VALUE5 => LL_VALUE5);
        L_REDUCED_SUBJ_WHABLE := (L_REGULAR_EARNINGS + L_SUPP_EARN) - (L_PRE_TAX - L_PRE_TAX_FUTA);
      ELSE
        OPEN C_GET_FED_VALUES(TAX_UNIT_ID);
        LOOP
          FETCH C_GET_FED_VALUES
           INTO L_TAX_OTD_VALUE,L_WAGE_OTD_VALUE,L_FORMAT_CODE;
          EXIT WHEN C_GET_FED_VALUES%NOTFOUND;
          IF L_FORMAT_CODE = '1' THEN
            L_GROSS_EARNINGS := L_WAGE_OTD_VALUE;
          ELSIF L_FORMAT_CODE = '2' THEN
            L_FUTA_TAXABLE := L_TAX_OTD_VALUE;
            L_REDUCED_SUBJ_WHABLE := L_WAGE_OTD_VALUE;
          ELSE
            L_REDUCED_SUBJ_WHABLE := 0;
            L_FUTA_TAXABLE := 0;
            L_GROSS_EARNINGS := 0;
          END IF;
        END LOOP;
        CLOSE C_GET_FED_VALUES;
      END IF;
      CP_EXEMPT_PAYMENTS := L_GROSS_EARNINGS - L_REDUCED_SUBJ_WHABLE;
      IF CP_EXEMPT_PAYMENTS = 0 THEN
        CP_EXEMPT_PAYMENTS := NULL;
      END IF;
      IF CP_EXEMPT_PAYMENTS < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Exempt Payments.  Please check.')*/NULL;
      END IF;
      CP_EXCESS_PAYMENTS := L_REDUCED_SUBJ_WHABLE - L_FUTA_TAXABLE;
      IF CP_EXCESS_PAYMENTS = 0 THEN
        CP_EXCESS_PAYMENTS := NULL;
      END IF;
      IF CP_EXCESS_PAYMENTS < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Excess Payments.  Please check.')*/NULL;
      END IF;
      IF L_GROSS_EARNINGS < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Total Payments.  Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Total Payments Bal Result' || TO_CHAR(L_GROSS_EARNINGS))*/NULL;
      END IF;
      RETURN (L_GROSS_EARNINGS);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('001'
                   ,'No data found in ' || TO_CHAR(TAX_UNIT_ID) || ' for Total Payments')*/NULL;
    END;
    RETURN NULL;
  END C_TOTAL_PAYMENTSFORMULA;

  FUNCTION C_GROSS_FUTA_TAXFORMULA(C_TOTAL_TAXABLE_WAGES IN NUMBER
                                  ,TAX_UNIT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      L_BAL_RESULT := NVL(C_TOTAL_TAXABLE_WAGES
                         ,0) * 0.062;
      IF L_BAL_RESULT = 0 THEN
        L_BAL_RESULT := NULL;
      END IF;
      IF L_BAL_RESULT < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Gross FUTA Tax.  Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Gross FUTA Tax Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_GROSS_FUTA_TAXFORMULA;

  FUNCTION C_MAXIMUM_CREDITFORMULA(C_TOTAL_TAXABLE_WAGES IN NUMBER
                                  ,TAX_UNIT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      L_BAL_RESULT := NVL(C_TOTAL_TAXABLE_WAGES
                         ,0) * 0.054;
      IF L_BAL_RESULT = 0 THEN
        L_BAL_RESULT := NULL;
      END IF;
      IF L_BAL_RESULT < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Maximum Credit.      Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Maximum Credit Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_MAXIMUM_CREDITFORMULA;

  FUNCTION C_TAXABLE_PAYROLLFORMULA(C_GAZ_END_DATE IN DATE
                                   ,TAX_UNIT_ID IN NUMBER
                                   ,JURISDICTION_CODE IN VARCHAR2
                                   ,VALUE IN NUMBER
                                   ,STATE_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
      L_NY_BAL_RESULT NUMBER;
      L_VALUE2 NUMBER;
      L_VALUE3 NUMBER;
      L_VALUE4 NUMBER;
      L_VALUE5 NUMBER;
      L_VALUE6 NUMBER;
      L_VALUE7 NUMBER;
    BEGIN
      IF CP_940_STATE_STATUS <> 'Y' THEN
        PAY_US_TAXBAL_VIEW_PKG.US_GP_GRE_JD_YTD(P_BALANCE_NAME1 => 'SUI ER Taxable'
                                               ,P_BALANCE_NAME2 => NULL
                                               ,P_BALANCE_NAME3 => NULL
                                               ,P_BALANCE_NAME4 => NULL
                                               ,P_BALANCE_NAME5 => NULL
                                               ,P_BALANCE_NAME6 => NULL
                                               ,P_BALANCE_NAME7 => NULL
                                               ,P_EFFECTIVE_DATE => C_GAZ_END_DATE
                                               ,P_TAX_UNIT_ID => TAX_UNIT_ID
                                               ,P_STATE_CODE => JURISDICTION_CODE
                                               ,P_VALUE1 => L_BAL_RESULT
                                               ,P_VALUE2 => L_VALUE2
                                               ,P_VALUE3 => L_VALUE3
                                               ,P_VALUE4 => L_VALUE4
                                               ,P_VALUE5 => L_VALUE5
                                               ,P_VALUE6 => L_VALUE6
                                               ,P_VALUE7 => L_VALUE7);
        /*SRW.MESSAGE('777'
                   ,'Balances are not valid. ')*/NULL;
      ELSE
        L_BAL_RESULT := VALUE;
      END IF;
      IF L_BAL_RESULT < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' in ' || STATE_CODE || ' has negative Total Payroll.  Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Taxable Payroll Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('789'
                   ,'No data found in ' || TO_CHAR(TAX_UNIT_ID) || ' for Taxable Payroll')*/NULL;
    END;
    RETURN NULL;
  END C_TAXABLE_PAYROLLFORMULA;

  FUNCTION C_TOTAL_EXEMPT_PAYMENTSFORMULA(TAX_UNIT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      L_BAL_RESULT := NVL(CP_EXEMPT_PAYMENTS
                         ,0) + NVL(CP_EXCESS_PAYMENTS
                         ,0);
      IF L_BAL_RESULT = 0 THEN
        L_BAL_RESULT := NULL;
      END IF;
      IF L_BAL_RESULT < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Total Exempt Payments.  Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Total Exempt Payments Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_TOTAL_EXEMPT_PAYMENTSFORMULA;

  FUNCTION C_TOTAL_TAXABLE_WAGESFORMULA(C_TOTAL_PAYMENTS IN NUMBER
                                       ,C_TOTAL_EXEMPT_PAYMENTS IN NUMBER
                                       ,TAX_UNIT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      L_BAL_RESULT := NVL(C_TOTAL_PAYMENTS
                         ,0) - NVL(C_TOTAL_EXEMPT_PAYMENTS
                         ,0);
      IF L_BAL_RESULT = 0 THEN
        L_BAL_RESULT := NULL;
      END IF;
      IF L_BAL_RESULT < 0 THEN
        /*SRW.MESSAGE('001'
                   ,'Tax Unit ID: ' || TO_CHAR(TAX_UNIT_ID) || ' has negative Total Taxable Wages.  Please check.')*/NULL;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Total Taxable Wages Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_TOTAL_TAXABLE_WAGESFORMULA;

  FUNCTION C_EXPERIENCE_RATE_1FORMULA(TAX_UNIT_ID IN NUMBER
                                     ,STATE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CURSOR MY_CURSOR IS
        SELECT
          ORG_INFORMATION6,
          ORG_INFORMATION7
        FROM
          HR_ORGANIZATION_INFORMATION
        WHERE ORGANIZATION_ID = TAX_UNIT_ID
          AND ORG_INFORMATION_CONTEXT = 'State Tax Rules'
          AND ORG_INFORMATION1 = STATE_CODE;
      EXP_RATE_1 VARCHAR2(25);
      EXP_RATE_2 VARCHAR2(25);
    BEGIN
      OPEN MY_CURSOR;
      FETCH MY_CURSOR
       INTO EXP_RATE_1,EXP_RATE_2;
      CLOSE MY_CURSOR;
      C_EXPERIENCE_RATE2 := EXP_RATE_2;
      IF EXP_RATE_1 IS NOT NULL THEN
        RETURN (EXP_RATE_1);
      ELSE
        RETURN ('N/A');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('789'
                   ,'No data found in ' || TO_CHAR(TAX_UNIT_ID) || ' for Experience Rate 1')*/NULL;
    END;
    RETURN NULL;
  END C_EXPERIENCE_RATE_1FORMULA;

  FUNCTION C_CONTRIBUTIONSFORMULA(C_TAXABLE_PAYROLL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      L_BAL_RESULT := NVL(C_TAXABLE_PAYROLL
                         ,0) * 0.054;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Contributions Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_CONTRIBUTIONSFORMULA;

  FUNCTION C_CONTRIBUTIONS_PAYABLEFORMULA(C_EXPERIENCE_RATE_1 IN VARCHAR2
                                         ,C_TAXABLE_PAYROLL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BAL_RESULT NUMBER;
    BEGIN
      IF C_EXPERIENCE_RATE_1 <> 'N/A' THEN
        IF C_EXPERIENCE_RATE_1 > 0 THEN
          L_BAL_RESULT := NVL(C_TAXABLE_PAYROLL
                             ,0) * (NVL(C_EXPERIENCE_RATE_1
                             ,0) * 0.01);
        ELSE
          L_BAL_RESULT := 0;
        END IF;
      ELSE
        L_BAL_RESULT := 0;
      END IF;
      IF P_DEBUG = 'Y' THEN
        /*SRW.MESSAGE('789'
                   ,'Contributions Payable Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
      END IF;
      RETURN (L_BAL_RESULT);
    END;
    RETURN NULL;
  END C_CONTRIBUTIONS_PAYABLEFORMULA;

  FUNCTION C_ADDITIONAL_CREDITFORMULA(C_TAXABLE_PAYROLL IN NUMBER
                                     ,CF_COMPUTATION_RATE IN NUMBER) RETURN NUMBER IS
    L_BAL_RESULT NUMBER;
  BEGIN
    L_BAL_RESULT := NVL(C_TAXABLE_PAYROLL * CF_COMPUTATION_RATE
                       ,0);
    IF P_DEBUG = 'Y' THEN
      /*SRW.MESSAGE('789'
                 ,'Contributions Payable Bal Result' || TO_CHAR(L_BAL_RESULT))*/NULL;
    END IF;
    RETURN (L_BAL_RESULT);
  END C_ADDITIONAL_CREDITFORMULA;

  FUNCTION C_GAZ_END_DATEFORMULA RETURN DATE IS
  BEGIN
    DECLARE
      L_END_DATE DATE;
    BEGIN
      L_END_DATE := TO_DATE('31-12-' || P_TAX_YEAR
                           ,'DD-MM-YYYY');
      RETURN (L_END_DATE);
    END;
    RETURN NULL;
  END C_GAZ_END_DATEFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CP_EXEMPT_PAYMENTSFORMULA RETURN NUMBER IS
  BEGIN
    RETURN NULL;
  END CP_EXEMPT_PAYMENTSFORMULA;

  FUNCTION CP_EXCESS_PAYMENTSFORMULA RETURN NUMBER IS
  BEGIN
    RETURN NULL;
  END CP_EXCESS_PAYMENTSFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_START_DATE DATE;
    L_END_DATE DATE;
    L_STATUS VARCHAR2(1);
  BEGIN
    L_START_DATE := TO_DATE('01-01-' || P_TAX_YEAR
                           ,'DD-MM-YYYY');
    L_END_DATE := TO_DATE('31-12-' || P_TAX_YEAR
                         ,'DD-MM-YYYY');
    CP_940_FED_STATUS := PAY_US_PAYROLL_UTILS.CHECK_BALANCE_STATUS(L_START_DATE
                                                                  ,P_BUSINESS_GROUP_ID
                                                                  ,'940_FED');
    CP_940_STATE_STATUS := PAY_US_PAYROLL_UTILS.CHECK_BALANCE_STATUS(L_START_DATE
                                                                    ,P_BUSINESS_GROUP_ID
                                                                    ,'940_STATE');
    IF CP_940_STATE_STATUS = 'Y' OR CP_940_FED_STATUS = 'Y' THEN
      PAY_BALANCE_PKG.SET_CONTEXT('BALANCE_DATE'
                                 ,FND_DATE.DATE_TO_CANONICAL(L_END_DATE));
      PAY_BALANCE_PKG.SET_CONTEXT('DATE_EARNED'
                                 ,FND_DATE.DATE_TO_CANONICAL(L_END_DATE));
      PAY_US_BALANCE_VIEW_PKG.SET_SESSION_VAR('GROUP_RB_REPORT'
                                             ,'TRUE');
      PAY_US_BALANCE_VIEW_PKG.SET_SESSION_VAR('GROUP_RB_SDATE'
                                             ,L_START_DATE);
      PAY_US_BALANCE_VIEW_PKG.SET_SESSION_VAR('GROUP_RB_EDATE'
                                             ,L_END_DATE);
    END IF;
    CP_SELECT_COL1 := NULL;
    CP_SELECT_COL2 := NULL;
    CP_WHERE_CLAUSE := ' ';
    CP_FROM_TABLE := ' ';
    IF CP_940_STATE_STATUS = 'Y' THEN
      CP_SELECT_COL1 := 'v.d_wage_otd_value ';
      CP_SELECT_COL2 := 'v.d_tax_unit_id ';
      CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || 'and   psr.jurisdiction_code = v.d_state_code ' || ' ';
      CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || 'and   v.d_balance_set_name = ''940_STATE_YTD'' ' || ' ';
      CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || 'and   v.d_tax_type =  ''SUI'' ';
      CP_FROM_TABLE := 'pay_us_state_tax_bal_gre_v';
    ELSE
      CP_SELECT_COL1 := '1 ';
      CP_SELECT_COL2 := 'v.tax_unit_id ';
      CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || 'and   psr.jurisdiction_code = v.state_code ';
      CP_FROM_TABLE := 'pay_us_tax_unit_states_v ';
    END IF;
    IF P_TAX_YEAR = '2005' THEN
      CP_NY_REDUCTION_RATE := 0.006;
    ELSIF P_TAX_YEAR = '2004' THEN
      CP_NY_REDUCTION_RATE := 0.003;
    ELSE
      CP_NY_REDUCTION_RATE := 0.0;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
--    HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_NY_WAGESFORMULA(TAX_UNIT_ID IN NUMBER
                            ,C_GAZ_END_DATE IN DATE) RETURN NUMBER IS
    L_NY_VALUE NUMBER;
    L_STATE_CODE VARCHAR2(2);
    L_VALUE2 NUMBER;
    L_VALUE3 NUMBER;
    L_VALUE4 NUMBER;
    L_VALUE5 NUMBER;
    L_VALUE6 NUMBER;
    L_VALUE7 NUMBER;
    L_TEMP NUMBER;
    CURSOR GET_NY_WAGE IS
      SELECT
        DISTINCT
        SUBSTR(D_STATE_CODE
              ,1
              ,2),
        D_WAGE_OTD_VALUE
      FROM
        PAY_US_STATE_TAX_BAL_GRE_V
      WHERE D_STATE_CODE = '33-000-0000'
        AND D_BALANCE_SET_NAME = '940_STATE_YTD'
        AND D_TAX_TYPE = 'FUTA'
        AND D_TAX_UNIT_ID = TAX_UNIT_ID;
  BEGIN
    IF NVL(P_STATE_CODE
       ,'NY') = 'NY' THEN
      IF CP_940_STATE_STATUS <> 'Y' THEN
        PAY_US_TAXBAL_VIEW_PKG.US_GP_GRE_JD_YTD(P_BALANCE_NAME1 => 'FUTA Taxable'
                                               ,P_BALANCE_NAME2 => NULL
                                               ,P_BALANCE_NAME3 => NULL
                                               ,P_BALANCE_NAME4 => NULL
                                               ,P_BALANCE_NAME5 => NULL
                                               ,P_BALANCE_NAME6 => NULL
                                               ,P_BALANCE_NAME7 => NULL
                                               ,P_EFFECTIVE_DATE => C_GAZ_END_DATE
                                               ,P_TAX_UNIT_ID => TAX_UNIT_ID
                                               ,P_STATE_CODE => '33-000-0000'
                                               ,P_VALUE1 => L_NY_VALUE
                                               ,P_VALUE2 => L_VALUE2
                                               ,P_VALUE3 => L_VALUE3
                                               ,P_VALUE4 => L_VALUE4
                                               ,P_VALUE5 => L_VALUE5
                                               ,P_VALUE6 => L_VALUE6
                                               ,P_VALUE7 => L_VALUE7);
      ELSE
        OPEN GET_NY_WAGE;
        FETCH GET_NY_WAGE
         INTO L_STATE_CODE,L_NY_VALUE;
        IF GET_NY_WAGE%NOTFOUND THEN
          CLOSE GET_NY_WAGE;
          RETURN 0;
        END IF;
        CLOSE GET_NY_WAGE;
      END IF;
      RETURN L_NY_VALUE;
    ELSE
      RETURN 0;
    END IF;
  END C_NY_WAGESFORMULA;

  FUNCTION C_NY_RATEFORMULA(C_NY_WAGES IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF C_NY_WAGES <> 0 THEN
      RETURN C_NY_WAGES * CP_NY_REDUCTION_RATE;
    ELSE
      RETURN 0;
    END IF;
  END C_NY_RATEFORMULA;

  FUNCTION CF_FUTA_TAX_BEF_ADJFORMULA(C_TOTAL_TAXABLE_WAGES IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_TOTAL_TAXABLE_WAGES * .008);
  END CF_FUTA_TAX_BEF_ADJFORMULA;

  FUNCTION CF_COMPUTATION_RATEFORMULA(C_EXPERIENCE_RATE_1 IN VARCHAR2) RETURN NUMBER IS
    L_EXP_RATE NUMBER;
    L_COMP_RATE NUMBER;
  BEGIN
    IF C_EXPERIENCE_RATE_1 <> 'N/A' THEN
      L_EXP_RATE := TO_NUMBER(C_EXPERIENCE_RATE_1) * .01;
      IF L_EXP_RATE < .054 THEN
        L_COMP_RATE := 0.054 - L_EXP_RATE;
        IF P_DEBUG = 'Y' THEN
          /*SRW.MESSAGE('11'
                     ,' l_exp_rate = || ' || L_EXP_RATE)*/NULL;
          /*SRW.MESSAGE('11'
                     ,' l_comp_rate = || ' || L_COMP_RATE)*/NULL;
        END IF;
        RETURN L_COMP_RATE;
      ELSE
        RETURN 0;
      END IF;
    END IF;
    RETURN 0;
  END CF_COMPUTATION_RATEFORMULA;

  FUNCTION CF_LINE_9FORMULA(TAX_UNIT_ID IN NUMBER
                           ,C_GAZ_END_DATE IN DATE
                           ,C_TOTAL_TAXABLE_WAGES IN NUMBER) RETURN NUMBER IS
    L_SUI_ER_SUBJ NUMBER;
    L_SUI_ER_TAXABLE NUMBER;
    L_LINE_9 NUMBER := 0;
    L_VALUE2 NUMBER;
    L_VALUE3 NUMBER;
    L_VALUE4 NUMBER;
    L_VALUE5 NUMBER;
    L_VALUE6 NUMBER;
    L_VALUE7 NUMBER;
    L_VALUE8 NUMBER;
    L_VALUE9 NUMBER;
    L_VALUE10 NUMBER;
  BEGIN
    PAY_US_TAXBAL_VIEW_PKG.US_GP_MULTIPLE_GRE_YTD(P_TAX_UNIT_ID => TAX_UNIT_ID
                                                 ,P_EFFECTIVE_DATE => C_GAZ_END_DATE
                                                 ,P_BALANCE_NAME1 => 'SUI ER Subj Whable'
                                                 ,P_BALANCE_NAME2 => NULL
                                                 ,P_BALANCE_NAME3 => NULL
                                                 ,P_BALANCE_NAME4 => NULL
                                                 ,P_BALANCE_NAME5 => NULL
                                                 ,P_BALANCE_NAME6 => NULL
                                                 ,P_BALANCE_NAME7 => NULL
                                                 ,P_BALANCE_NAME8 => NULL
                                                 ,P_BALANCE_NAME9 => NULL
                                                 ,P_BALANCE_NAME10 => NULL
                                                 ,P_VALUE1 => L_SUI_ER_SUBJ
                                                 ,P_VALUE2 => L_VALUE2
                                                 ,P_VALUE3 => L_VALUE3
                                                 ,P_VALUE4 => L_VALUE4
                                                 ,P_VALUE5 => L_VALUE5
                                                 ,P_VALUE6 => L_VALUE6
                                                 ,P_VALUE7 => L_VALUE7
                                                 ,P_VALUE8 => L_VALUE8
                                                 ,P_VALUE9 => L_VALUE9
                                                 ,P_VALUE10 => L_VALUE10);
    IF L_SUI_ER_SUBJ = 0 THEN
      L_LINE_9 := C_TOTAL_TAXABLE_WAGES * .054;
    END IF;
    RETURN L_LINE_9;
  END CF_LINE_9FORMULA;

  FUNCTION CP_EXEMPT_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXEMPT_PAYMENTS;
  END CP_EXEMPT_PAYMENTS_P;

  FUNCTION CP_EXCESS_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXCESS_PAYMENTS;
  END CP_EXCESS_PAYMENTS_P;

  FUNCTION C_EXPERIENCE_RATE2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EXPERIENCE_RATE2;
  END C_EXPERIENCE_RATE2_P;

  FUNCTION C_TAX_UNIT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TAX_UNIT;
  END C_TAX_UNIT_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_GAZ_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_GAZ_START_DATE;
  END C_GAZ_START_DATE_P;

  FUNCTION GET_BUDGET(P_BUDGET_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUDGET(:P_BUDGET_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUDGET_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_BUDGET;

  FUNCTION GET_BUDGET_VERSION(P_BUDGET_ID IN NUMBER
                             ,P_BUDGET_VERSION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUDGET_VERSION(:P_BUDGET_ID, :P_BUDGET_VERSION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUDGET_ID);
    STPROC.BIND_I(P_BUDGET_VERSION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_BUDGET_VERSION;

  PROCEDURE GET_ORGANIZATION(P_ORGANIZATION_ID IN NUMBER
                            ,P_ORG_NAME OUT NOCOPY VARCHAR2
                            ,P_ORG_TYPE OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_ORGANIZATION(:P_ORGANIZATION_ID, :P_ORG_NAME, :P_ORG_TYPE); end;');
    STPROC.BIND_I(P_ORGANIZATION_ID);
    STPROC.BIND_O(P_ORG_NAME);
    STPROC.BIND_O(P_ORG_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ORG_NAME);
    STPROC.RETRIEVE(3
                   ,P_ORG_TYPE);*/
		   NULL;
  END GET_ORGANIZATION;

  FUNCTION GET_JOB(P_JOB_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_JOB(:P_JOB_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_JOB_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_JOB;

  FUNCTION GET_POSITION(P_POSITION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_POSITION(:P_POSITION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_POSITION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_POSITION;

  FUNCTION GET_GRADE(P_GRADE_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_GRADE(:P_GRADE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_GRADE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_GRADE;

  FUNCTION GET_STATUS(P_BUSINESS_GROUP_ID IN NUMBER
                     ,P_ASSIGNMENT_STATUS_TYPE_ID IN NUMBER
                     ,P_LEGISLATION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_STATUS(:P_BUSINESS_GROUP_ID, :P_ASSIGNMENT_STATUS_TYPE_ID, :P_LEGISLATION_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.BIND_I(P_ASSIGNMENT_STATUS_TYPE_ID);
    STPROC.BIND_I(P_LEGISLATION_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_STATUS;

  FUNCTION GET_ABS_TYPE(P_ABS_ATT_TYPE_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_ABS_TYPE(:P_ABS_ATT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ABS_ATT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_ABS_TYPE;

  PROCEDURE GET_TIME_PERIOD(P_TIME_PERIOD_ID IN NUMBER
                           ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                           ,P_START_DATE OUT NOCOPY DATE
                           ,P_END_DATE OUT NOCOPY DATE) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_TIME_PERIOD(:P_TIME_PERIOD_ID, :P_PERIOD_NAME, :P_START_DATE, :P_END_DATE); end;');
    STPROC.BIND_I(P_TIME_PERIOD_ID);
    STPROC.BIND_O(P_PERIOD_NAME);
    STPROC.BIND_O(P_START_DATE);
    STPROC.BIND_O(P_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_PERIOD_NAME);
    STPROC.RETRIEVE(3
                   ,P_START_DATE);
    STPROC.RETRIEVE(4
                   ,P_END_DATE);*/
		   NULL;
  END GET_TIME_PERIOD;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUSINESS_GROUP(:P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_BUSINESS_GROUP;

  FUNCTION COUNT_ORG_SUBORDINATES(P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_ORGANIZATION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.COUNT_ORG_SUBORDINATES(:P_ORG_STRUCTURE_VERSION_ID, :P_PARENT_ORGANIZATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.BIND_I(P_PARENT_ORGANIZATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END COUNT_ORG_SUBORDINATES;

  FUNCTION COUNT_POS_SUBORDINATES(P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_POSITION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.COUNT_POS_SUBORDINATES(:P_POS_STRUCTURE_VERSION_ID, :P_PARENT_POSITION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_POS_STRUCTURE_VERSION_ID);
    STPROC.BIND_I(P_PARENT_POSITION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END COUNT_POS_SUBORDINATES;

  PROCEDURE GET_ORGANIZATION_HIERARCHY(P_ORGANIZATION_STRUCTURE_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_NAME OUT NOCOPY VARCHAR2
                                      ,P_ORG_VERSION OUT NOCOPY NUMBER
                                      ,P_VERSION_START_DATE OUT NOCOPY DATE
                                      ,P_VERSION_END_DATE OUT NOCOPY DATE) IS
  BEGIN
  /*  STPROC.INIT('begin HR_REPORTS.GET_ORGANIZATION_HIERARCHY(:P_ORGANIZATION_STRUCTURE_ID, :P_ORG_STRUCTURE_VERSION_ID, :P_ORG_STRUCTURE_NAME, :P_ORG_VERSION, :P_VERSION_START_DATE, :P_VERSION_END_DATE); end;');
    STPROC.BIND_I(P_ORGANIZATION_STRUCTURE_ID);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.BIND_O(P_ORG_STRUCTURE_NAME);
    STPROC.BIND_O(P_ORG_VERSION);
    STPROC.BIND_O(P_VERSION_START_DATE);
    STPROC.BIND_O(P_VERSION_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_ORG_STRUCTURE_NAME);
    STPROC.RETRIEVE(4
                   ,P_ORG_VERSION);
    STPROC.RETRIEVE(5
                   ,P_VERSION_START_DATE);
    STPROC.RETRIEVE(6
                   ,P_VERSION_END_DATE);*/NULL;
  END GET_ORGANIZATION_HIERARCHY;

  PROCEDURE GET_POSITION_HIERARCHY(P_POSITION_STRUCTURE_ID IN NUMBER
                                  ,P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                  ,P_POS_STRUCTURE_NAME OUT NOCOPY VARCHAR2
                                  ,P_POS_VERSION OUT NOCOPY NUMBER
                                  ,P_VERSION_START_DATE OUT NOCOPY DATE
                                  ,P_VERSION_END_DATE OUT NOCOPY DATE) IS
  BEGIN
   /* STPROC.INIT('begin HR_REPORTS.GET_POSITION_HIERARCHY(:P_POSITION_STRUCTURE_ID, :P_POS_STRUCTURE_VERSION_ID, :P_POS_STRUCTURE_NAME, :P_POS_VERSION, :P_VERSION_START_DATE, :P_VERSION_END_DATE); end;');
    STPROC.BIND_I(P_POSITION_STRUCTURE_ID);
    STPROC.BIND_I(P_POS_STRUCTURE_VERSION_ID);
    STPROC.BIND_O(P_POS_STRUCTURE_NAME);
    STPROC.BIND_O(P_POS_VERSION);
    STPROC.BIND_O(P_VERSION_START_DATE);
    STPROC.BIND_O(P_VERSION_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_POS_STRUCTURE_NAME);
    STPROC.RETRIEVE(4
                   ,P_POS_VERSION);
    STPROC.RETRIEVE(5
                   ,P_VERSION_START_DATE);
    STPROC.RETRIEVE(6
                   ,P_VERSION_END_DATE);*/NULL;
  END GET_POSITION_HIERARCHY;

  FUNCTION GET_LOOKUP_MEANING(P_LOOKUP_TYPE IN VARCHAR2
                             ,P_LOOKUP_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := HR_REPORTS.GET_LOOKUP_MEANING(:P_LOOKUP_TYPE, :P_LOOKUP_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_LOOKUP_TYPE);
    STPROC.BIND_I(P_LOOKUP_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_LOOKUP_MEANING;

  FUNCTION PERSON_MATCHING_SKILLS(P_PERSON_ID IN NUMBER
                                 ,P_JOB_POSITION_ID IN NUMBER
                                 ,P_JOB_POSITION_TYPE IN VARCHAR2
                                 ,P_MATCHING_LEVEL IN VARCHAR2
                                 ,P_NO_OF_ESSENTIAL IN NUMBER
                                 ,P_NO_OF_DESIRABLE IN NUMBER) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
   /* STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := HR_REPORTS.PERSON_MATCHING_SKILLS(:P_PERSON_ID, :P_JOB_POSITION_ID, :P_JOB_POSITION_TYPE, :P_MATCHING_LEVEL, :P_NO_OF_ESSENTIAL, :P_NO_OF_DESIRABLE); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.BIND_I(P_JOB_POSITION_ID);
    STPROC.BIND_I(P_JOB_POSITION_TYPE);
    STPROC.BIND_I(P_MATCHING_LEVEL);
    STPROC.BIND_I(P_NO_OF_ESSENTIAL);
    STPROC.BIND_I(P_NO_OF_DESIRABLE);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(7
                   ,X0);*/
    RETURN NULL;
  END PERSON_MATCHING_SKILLS;

  FUNCTION GET_PAYROLL_NAME(P_SESSION_DATE IN DATE
                           ,P_PAYROLL_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := HR_REPORTS.GET_PAYROLL_NAME(:P_SESSION_DATE, :P_PAYROLL_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_PAYROLL_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_PAYROLL_NAME;

  FUNCTION GET_ELEMENT_NAME(P_SESSION_DATE IN DATE
                           ,P_ELEMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := HR_REPORTS.GET_ELEMENT_NAME(:P_SESSION_DATE, :P_ELEMENT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_ELEMENT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_ELEMENT_NAME;

  PROCEDURE GEN_PARTIAL_MATCHING_LEXICAL(P_CONCATENATED_SEGMENTS IN VARCHAR2
                                        ,P_ID_FLEX_NUM IN NUMBER
                                        ,P_MATCHING_LEXICAL IN OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GEN_PARTIAL_MATCHING_LEXICAL(:P_CONCATENATED_SEGMENTS, :P_ID_FLEX_NUM, :P_MATCHING_LEXICAL); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_ID_FLEX_NUM);
    STPROC.BIND_IO(P_MATCHING_LEXICAL);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_MATCHING_LEXICAL);*/NULL;
  END GEN_PARTIAL_MATCHING_LEXICAL;

  PROCEDURE GET_ATTRIBUTES(P_CONCATENATED_SEGMENTS IN VARCHAR2
                          ,P_NAME IN VARCHAR2
                          ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                          ,P_VALUE1 OUT NOCOPY VARCHAR2
                          ,P_VALUE2 OUT NOCOPY VARCHAR2
                          ,P_VALUE3 OUT NOCOPY VARCHAR2
                          ,P_VALUE4 OUT NOCOPY VARCHAR2
                          ,P_VALUE5 OUT NOCOPY VARCHAR2
                          ,P_VALUE6 OUT NOCOPY VARCHAR2
                          ,P_VALUE7 OUT NOCOPY VARCHAR2
                          ,P_VALUE8 OUT NOCOPY VARCHAR2
                          ,P_VALUE9 OUT NOCOPY VARCHAR2
                          ,P_VALUE10 OUT NOCOPY VARCHAR2
                          ,P_VALUE11 OUT NOCOPY VARCHAR2
                          ,P_VALUE12 OUT NOCOPY VARCHAR2
                          ,P_VALUE13 OUT NOCOPY VARCHAR2
                          ,P_VALUE14 OUT NOCOPY VARCHAR2
                          ,P_VALUE15 OUT NOCOPY VARCHAR2
                          ,P_VALUE16 OUT NOCOPY VARCHAR2
                          ,P_VALUE17 OUT NOCOPY VARCHAR2
                          ,P_VALUE18 OUT NOCOPY VARCHAR2
                          ,P_VALUE19 OUT NOCOPY VARCHAR2
                          ,P_VALUE20 OUT NOCOPY VARCHAR2
                          ,P_VALUE21 OUT NOCOPY VARCHAR2
                          ,P_VALUE22 OUT NOCOPY VARCHAR2
                          ,P_VALUE23 OUT NOCOPY VARCHAR2
                          ,P_VALUE24 OUT NOCOPY VARCHAR2
                          ,P_VALUE25 OUT NOCOPY VARCHAR2
                          ,P_VALUE26 OUT NOCOPY VARCHAR2
                          ,P_VALUE27 OUT NOCOPY VARCHAR2
                          ,P_VALUE28 OUT NOCOPY VARCHAR2
                          ,P_VALUE29 OUT NOCOPY VARCHAR2
                          ,P_VALUE30 OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_ATTRIBUTES(:P_CONCATENATED_SEGMENTS, :P_NAME, :P_SEGMENTS_USED, :P_VALUE1, :P_VALUE2, :P_VALUE3, :P_VALUE4, :P_VALUE5, :P_VALUE6,
:P_VALUE7, :P_VALUE8, :P_VALUE9, :P_VALUE10, :P_VALUE11, :P_VALUE12, :P_VALUE13, :P_VALUE14, :P_VALUE15, :P_VALUE16,
:P_VALUE17, :P_VALUE18, :P_VALUE19, :P_VALUE20, :P_VALUE21, :P_VALUE22, :P_VALUE23, :P_VALUE24, :P_VALUE25, :P_VALUE26, :P_VALUE27, :P_VALUE28, :P_VALUE29, :P_VALUE30); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_NAME);
    STPROC.BIND_O(P_SEGMENTS_USED);
    STPROC.BIND_O(P_VALUE1);
    STPROC.BIND_O(P_VALUE2);
    STPROC.BIND_O(P_VALUE3);
    STPROC.BIND_O(P_VALUE4);
    STPROC.BIND_O(P_VALUE5);
    STPROC.BIND_O(P_VALUE6);
    STPROC.BIND_O(P_VALUE7);
    STPROC.BIND_O(P_VALUE8);
    STPROC.BIND_O(P_VALUE9);
    STPROC.BIND_O(P_VALUE10);
    STPROC.BIND_O(P_VALUE11);
    STPROC.BIND_O(P_VALUE12);
    STPROC.BIND_O(P_VALUE13);
    STPROC.BIND_O(P_VALUE14);
    STPROC.BIND_O(P_VALUE15);
    STPROC.BIND_O(P_VALUE16);
    STPROC.BIND_O(P_VALUE17);
    STPROC.BIND_O(P_VALUE18);
    STPROC.BIND_O(P_VALUE19);
    STPROC.BIND_O(P_VALUE20);
    STPROC.BIND_O(P_VALUE21);
    STPROC.BIND_O(P_VALUE22);
    STPROC.BIND_O(P_VALUE23);
    STPROC.BIND_O(P_VALUE24);
    STPROC.BIND_O(P_VALUE25);
    STPROC.BIND_O(P_VALUE26);
    STPROC.BIND_O(P_VALUE27);
    STPROC.BIND_O(P_VALUE28);
    STPROC.BIND_O(P_VALUE29);
    STPROC.BIND_O(P_VALUE30);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_SEGMENTS_USED);
    STPROC.RETRIEVE(4
                   ,P_VALUE1);
    STPROC.RETRIEVE(5
                   ,P_VALUE2);
    STPROC.RETRIEVE(6
                   ,P_VALUE3);
    STPROC.RETRIEVE(7
                   ,P_VALUE4);
    STPROC.RETRIEVE(8
                   ,P_VALUE5);
    STPROC.RETRIEVE(9
                   ,P_VALUE6);
    STPROC.RETRIEVE(10
                   ,P_VALUE7);
    STPROC.RETRIEVE(11
                   ,P_VALUE8);
    STPROC.RETRIEVE(12
                   ,P_VALUE9);
    STPROC.RETRIEVE(13
                   ,P_VALUE10);
    STPROC.RETRIEVE(14
                   ,P_VALUE11);
    STPROC.RETRIEVE(15
                   ,P_VALUE12);
    STPROC.RETRIEVE(16
                   ,P_VALUE13);
    STPROC.RETRIEVE(17
                   ,P_VALUE14);
    STPROC.RETRIEVE(18
                   ,P_VALUE15);
    STPROC.RETRIEVE(19
                   ,P_VALUE16);
    STPROC.RETRIEVE(20
                   ,P_VALUE17);
    STPROC.RETRIEVE(21
                   ,P_VALUE18);
    STPROC.RETRIEVE(22
                   ,P_VALUE19);
    STPROC.RETRIEVE(23
                   ,P_VALUE20);
    STPROC.RETRIEVE(24
                   ,P_VALUE21);
    STPROC.RETRIEVE(25
                   ,P_VALUE22);
    STPROC.RETRIEVE(26
                   ,P_VALUE23);
    STPROC.RETRIEVE(27
                   ,P_VALUE24);
    STPROC.RETRIEVE(28
                   ,P_VALUE25);
    STPROC.RETRIEVE(29
                   ,P_VALUE26);
    STPROC.RETRIEVE(30
                   ,P_VALUE27);
    STPROC.RETRIEVE(31
                   ,P_VALUE28);
    STPROC.RETRIEVE(32
                   ,P_VALUE29);
    STPROC.RETRIEVE(33
                   ,P_VALUE30);*/NULL;
  END GET_ATTRIBUTES;

  PROCEDURE GET_SEGMENTS(P_CONCATENATED_SEGMENTS IN VARCHAR2
                        ,P_ID_FLEX_NUM IN NUMBER
                        ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                        ,P_VALUE1 OUT NOCOPY VARCHAR2
                        ,P_VALUE2 OUT NOCOPY VARCHAR2
                        ,P_VALUE3 OUT NOCOPY VARCHAR2
                        ,P_VALUE4 OUT NOCOPY VARCHAR2
                        ,P_VALUE5 OUT NOCOPY VARCHAR2
                        ,P_VALUE6 OUT NOCOPY VARCHAR2
                        ,P_VALUE7 OUT NOCOPY VARCHAR2
                        ,P_VALUE8 OUT NOCOPY VARCHAR2
                        ,P_VALUE9 OUT NOCOPY VARCHAR2
                        ,P_VALUE10 OUT NOCOPY VARCHAR2
                        ,P_VALUE11 OUT NOCOPY VARCHAR2
                        ,P_VALUE12 OUT NOCOPY VARCHAR2
                        ,P_VALUE13 OUT NOCOPY VARCHAR2
                        ,P_VALUE14 OUT NOCOPY VARCHAR2
                        ,P_VALUE15 OUT NOCOPY VARCHAR2
                        ,P_VALUE16 OUT NOCOPY VARCHAR2
                        ,P_VALUE17 OUT NOCOPY VARCHAR2
                        ,P_VALUE18 OUT NOCOPY VARCHAR2
                        ,P_VALUE19 OUT NOCOPY VARCHAR2
                        ,P_VALUE20 OUT NOCOPY VARCHAR2
                        ,P_VALUE21 OUT NOCOPY VARCHAR2
                        ,P_VALUE22 OUT NOCOPY VARCHAR2
                        ,P_VALUE23 OUT NOCOPY VARCHAR2
                        ,P_VALUE24 OUT NOCOPY VARCHAR2
                        ,P_VALUE25 OUT NOCOPY VARCHAR2
                        ,P_VALUE26 OUT NOCOPY VARCHAR2
                        ,P_VALUE27 OUT NOCOPY VARCHAR2
                        ,P_VALUE28 OUT NOCOPY VARCHAR2
                        ,P_VALUE29 OUT NOCOPY VARCHAR2
                        ,P_VALUE30 OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_SEGMENTS(:P_CONCATENATED_SEGMENTS, :P_ID_FLEX_NUM, :P_SEGMENTS_USED, :P_VALUE1, :P_VALUE2, :P_VALUE3, :P_VALUE4, :P_VALUE5,
:P_VALUE6, :P_VALUE7, :P_VALUE8, :P_VALUE9, :P_VALUE10, :P_VALUE11, :P_VALUE12, :P_VALUE13, :P_VALUE14, :P_VALUE15, :P_VALUE16, :P_VALUE17, :P_VALUE18, :P_VALUE19,
:P_VALUE20, :P_VALUE21, :P_VALUE22, :P_VALUE23, :P_VALUE24, :P_VALUE25, :P_VALUE26, :P_VALUE27, :P_VALUE28, :P_VALUE29, :P_VALUE30); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_ID_FLEX_NUM);
    STPROC.BIND_O(P_SEGMENTS_USED);
    STPROC.BIND_O(P_VALUE1);
    STPROC.BIND_O(P_VALUE2);
    STPROC.BIND_O(P_VALUE3);
    STPROC.BIND_O(P_VALUE4);
    STPROC.BIND_O(P_VALUE5);
    STPROC.BIND_O(P_VALUE6);
    STPROC.BIND_O(P_VALUE7);
    STPROC.BIND_O(P_VALUE8);
    STPROC.BIND_O(P_VALUE9);
    STPROC.BIND_O(P_VALUE10);
    STPROC.BIND_O(P_VALUE11);
    STPROC.BIND_O(P_VALUE12);
    STPROC.BIND_O(P_VALUE13);
    STPROC.BIND_O(P_VALUE14);
    STPROC.BIND_O(P_VALUE15);
    STPROC.BIND_O(P_VALUE16);
    STPROC.BIND_O(P_VALUE17);
    STPROC.BIND_O(P_VALUE18);
    STPROC.BIND_O(P_VALUE19);
    STPROC.BIND_O(P_VALUE20);
    STPROC.BIND_O(P_VALUE21);
    STPROC.BIND_O(P_VALUE22);
    STPROC.BIND_O(P_VALUE23);
    STPROC.BIND_O(P_VALUE24);
    STPROC.BIND_O(P_VALUE25);
    STPROC.BIND_O(P_VALUE26);
    STPROC.BIND_O(P_VALUE27);
    STPROC.BIND_O(P_VALUE28);
    STPROC.BIND_O(P_VALUE29);
    STPROC.BIND_O(P_VALUE30);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_SEGMENTS_USED);
    STPROC.RETRIEVE(4
                   ,P_VALUE1);
    STPROC.RETRIEVE(5
                   ,P_VALUE2);
    STPROC.RETRIEVE(6
                   ,P_VALUE3);
    STPROC.RETRIEVE(7
                   ,P_VALUE4);
    STPROC.RETRIEVE(8
                   ,P_VALUE5);
    STPROC.RETRIEVE(9
                   ,P_VALUE6);
    STPROC.RETRIEVE(10
                   ,P_VALUE7);
    STPROC.RETRIEVE(11
                   ,P_VALUE8);
    STPROC.RETRIEVE(12
                   ,P_VALUE9);
    STPROC.RETRIEVE(13
                   ,P_VALUE10);
    STPROC.RETRIEVE(14
                   ,P_VALUE11);
    STPROC.RETRIEVE(15
                   ,P_VALUE12);
    STPROC.RETRIEVE(16
                   ,P_VALUE13);
    STPROC.RETRIEVE(17
                   ,P_VALUE14);
    STPROC.RETRIEVE(18
                   ,P_VALUE15);
    STPROC.RETRIEVE(19
                   ,P_VALUE16);
    STPROC.RETRIEVE(20
                   ,P_VALUE17);
    STPROC.RETRIEVE(21
                   ,P_VALUE18);
    STPROC.RETRIEVE(22
                   ,P_VALUE19);
    STPROC.RETRIEVE(23
                   ,P_VALUE20);
    STPROC.RETRIEVE(24
                   ,P_VALUE21);
    STPROC.RETRIEVE(25
                   ,P_VALUE22);
    STPROC.RETRIEVE(26
                   ,P_VALUE23);
    STPROC.RETRIEVE(27
                   ,P_VALUE24);
    STPROC.RETRIEVE(28
                   ,P_VALUE25);
    STPROC.RETRIEVE(29
                   ,P_VALUE26);
    STPROC.RETRIEVE(30
                   ,P_VALUE27);
    STPROC.RETRIEVE(31
                   ,P_VALUE28);
    STPROC.RETRIEVE(32
                   ,P_VALUE29);
    STPROC.RETRIEVE(33
                   ,P_VALUE30);*/NULL;
  END GET_SEGMENTS;

  PROCEDURE GET_DESC_FLEX(P_APPL_SHORT_NAME IN VARCHAR2
                         ,P_DESC_FLEX_NAME IN VARCHAR2
                         ,P_TABLE_ALIAS IN VARCHAR2
                         ,P_TITLE OUT NOCOPY VARCHAR2
                         ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                         ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_DESC_FLEX(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,P_TITLE);
    STPROC.RETRIEVE(5
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(6
                   ,P_COLUMN_EXPR);*/NULL;
  END GET_DESC_FLEX;

  PROCEDURE GET_DESC_FLEX_CONTEXT(P_APPL_SHORT_NAME IN VARCHAR2
                                 ,P_DESC_FLEX_NAME IN VARCHAR2
                                 ,P_TABLE_ALIAS IN VARCHAR2
                                 ,P_TITLE OUT NOCOPY VARCHAR2
                                 ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                                 ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_DESC_FLEX_CONTEXT(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,P_TITLE);
    STPROC.RETRIEVE(5
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(6
                   ,P_COLUMN_EXPR);*/NULL;
  END GET_DESC_FLEX_CONTEXT;

  PROCEDURE GET_DVLPR_DESC_FLEX(P_APPL_SHORT_NAME IN VARCHAR2
                               ,P_DESC_FLEX_NAME IN VARCHAR2
                               ,P_DESC_FLEX_CONTEXT IN VARCHAR2
                               ,P_TABLE_ALIAS IN VARCHAR2
                               ,P_TITLE OUT NOCOPY VARCHAR2
                               ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                               ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_REPORTS.GET_DVLPR_DESC_FLEX(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_DESC_FLEX_CONTEXT, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_DESC_FLEX_CONTEXT);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(5
                   ,P_TITLE);
    STPROC.RETRIEVE(6
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(7
                   ,P_COLUMN_EXPR);*/NULL;
  END GET_DVLPR_DESC_FLEX;

  FUNCTION GET_PERSON_NAME(P_SESSION_DATE IN DATE
                          ,P_PERSON_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_REPORTS.GET_PERSON_NAME(:P_SESSION_DATE, :P_PERSON_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_PERSON_NAME;

  FUNCTION GET_SALARY(P_BUSINESS_GROUP_ID IN NUMBER
                     ,P_ASSIGNMENT_ID IN NUMBER
                     ,P_REPORT_DATE IN DATE) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_SALARY(:P_BUSINESS_GROUP_ID, :P_ASSIGNMENT_ID, :P_REPORT_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_REPORT_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_SALARY;

  PROCEDURE GET_NEW_HIRE_CONTACT(P_PERSON_ID IN NUMBER
                                ,P_BUSINESS_GROUP_ID IN NUMBER
                                ,P_REPORT_DATE IN DATE
                                ,P_CONTACT_NAME OUT NOCOPY VARCHAR2
                                ,P_CONTACT_TITLE OUT NOCOPY VARCHAR2
                                ,P_CONTACT_PHONE OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_US_REPORTS.GET_NEW_HIRE_CONTACT(:P_PERSON_ID, :P_BUSINESS_GROUP_ID, :P_REPORT_DATE, :P_CONTACT_NAME, :P_CONTACT_TITLE, :P_CONTACT_PHONE); end;');
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.BIND_I(P_REPORT_DATE);
    STPROC.BIND_O(P_CONTACT_NAME);
    STPROC.BIND_O(P_CONTACT_TITLE);
    STPROC.BIND_O(P_CONTACT_PHONE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,P_CONTACT_NAME);
    STPROC.RETRIEVE(5
                   ,P_CONTACT_TITLE);
    STPROC.RETRIEVE(6
                   ,P_CONTACT_PHONE);*/
NULL;
  END GET_NEW_HIRE_CONTACT;

  PROCEDURE GET_ADDRESS(P_LOCATION_ID IN NUMBER
                       ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin HR_US_REPORTS.GET_ADDRESS(:P_LOCATION_ID, :P_ADDRESS); end;');
    STPROC.BIND_I(P_LOCATION_ID);
    STPROC.BIND_O(P_ADDRESS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ADDRESS);*/NULL;
  END GET_ADDRESS;

  PROCEDURE GET_EMPLOYEE_ADDRESS(P_PERSON_ID IN NUMBER
                                ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_US_REPORTS.GET_EMPLOYEE_ADDRESS(:P_PERSON_ID, :P_ADDRESS); end;');
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.BIND_O(P_ADDRESS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ADDRESS);*/NULL;
  END GET_EMPLOYEE_ADDRESS;

  PROCEDURE GET_COUNTY_ADDRESS(P_LOCATION_ID IN NUMBER
                              ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_US_REPORTS.GET_COUNTY_ADDRESS(:P_LOCATION_ID, :P_ADDRESS); end;');
    STPROC.BIND_I(P_LOCATION_ID);
    STPROC.BIND_O(P_ADDRESS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ADDRESS);*/NULL;
  END GET_COUNTY_ADDRESS;

  PROCEDURE GET_ACTIVITY(P_ESTABLISHMENT_ID IN NUMBER
                        ,P_ACTIVITY OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_US_REPORTS.GET_ACTIVITY(:P_ESTABLISHMENT_ID, :P_ACTIVITY); end;');
    STPROC.BIND_I(P_ESTABLISHMENT_ID);
    STPROC.BIND_O(P_ACTIVITY);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ACTIVITY);*/NULL;
  END GET_ACTIVITY;

  FUNCTION GET_CONSOLIDATION_SET(P_CONSOLIDATION_SET_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_CONSOLIDATION_SET(:P_CONSOLIDATION_SET_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_CONSOLIDATION_SET_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_CONSOLIDATION_SET;

  FUNCTION GET_PAYMENT_TYPE_NAME(P_PAYMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_PAYMENT_TYPE_NAME(:P_PAYMENT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_PAYMENT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_PAYMENT_TYPE_NAME;

  FUNCTION GET_ELEMENT_TYPE_NAME(P_ELEMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_ELEMENT_TYPE_NAME(:P_ELEMENT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ELEMENT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_ELEMENT_TYPE_NAME;

  FUNCTION GET_TAX_UNIT(P_TAX_UNIT_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_TAX_UNIT(:P_TAX_UNIT_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_UNIT_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_TAX_UNIT;

  FUNCTION GET_PERSON_NAME(P_PERSON_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_PERSON_NAME(:P_PERSON_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_PERSON_NAME;

  FUNCTION GET_PAYROLL_ACTION(P_PAYROLL_ACTION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_PAYROLL_ACTION(:P_PAYROLL_ACTION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_PAYROLL_ACTION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_PAYROLL_ACTION;

  FUNCTION GET_LEGISLATION_CODE(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_LEGISLATION_CODE(:P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_LEGISLATION_CODE;

  FUNCTION GET_DEFINED_BALANCE_ID(P_BALANCE_NAME IN VARCHAR2
                                 ,P_DIMENSION_SUFFIX IN VARCHAR2
                                 ,P_BUSINESS_GROUP_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_DEFINED_BALANCE_ID(:P_BALANCE_NAME, :P_DIMENSION_SUFFIX, :P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BALANCE_NAME);
    STPROC.BIND_I(P_DIMENSION_SUFFIX);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_DEFINED_BALANCE_ID;

  FUNCTION GET_STARTUP_DEFINED_BALANCE(P_REPORTING_NAME IN VARCHAR2
                                      ,P_DIMENSION_SUFFIX IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_STARTUP_DEFINED_BALANCE(:P_REPORTING_NAME, :P_DIMENSION_SUFFIX); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_REPORTING_NAME);
    STPROC.BIND_I(P_DIMENSION_SUFFIX);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_STARTUP_DEFINED_BALANCE;

  FUNCTION GET_DEFINED_BALANCE_BY_TYPE(P_BOX_NUM IN VARCHAR2
                                      ,P_DIMENSION_SUFFIX IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_DEFINED_BALANCE_BY_TYPE(:P_BOX_NUM, :P_DIMENSION_SUFFIX); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BOX_NUM);
    STPROC.BIND_I(P_DIMENSION_SUFFIX);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_DEFINED_BALANCE_BY_TYPE;

  FUNCTION GET_BEN_CLASS_NAME(P_SESSION_DATE IN DATE
                             ,P_BENEFIT_CLASSIFICATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_BEN_CLASS_NAME(:P_SESSION_DATE, :P_BENEFIT_CLASSIFICATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_BENEFIT_CLASSIFICATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_BEN_CLASS_NAME;

  FUNCTION GET_COBRA_QUALIFYING_EVENT(P_QUALIFYING_EVENT IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_COBRA_QUALIFYING_EVENT(:P_QUALIFYING_EVENT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_QUALIFYING_EVENT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_COBRA_QUALIFYING_EVENT;

  FUNCTION GET_COBRA_STATUS(P_COBRA_STATUS IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_COBRA_STATUS(:P_COBRA_STATUS); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_COBRA_STATUS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_COBRA_STATUS;

  FUNCTION GET_EST_TAX_UNIT(P_STARTING_ORG_ID IN NUMBER
                           ,P_ORG_STRUCTURE_VERSION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_EST_TAX_UNIT(:P_STARTING_ORG_ID, :P_ORG_STRUCTURE_VERSION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_STARTING_ORG_ID);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_EST_TAX_UNIT;

  FUNCTION GET_ORG_HIERARCHY_NAME(P_ORG_STRUCTURE_VERSION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_ORG_HIERARCHY_NAME(:P_ORG_STRUCTURE_VERSION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_ORG_HIERARCHY_NAME;

  FUNCTION GET_STATE_NAME(P_STATE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_STATE_NAME(:P_STATE_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_STATE_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
        RETURN NULL;
  END GET_STATE_NAME;

  FUNCTION GET_ORG_NAME(P_ORGANIZATION_ID IN NUMBER
                       ,P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_ORG_NAME(:P_ORGANIZATION_ID, :P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ORGANIZATION_ID);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_ORG_NAME;

  FUNCTION GET_CAREER_PATH_NAME(P_CAREER_PATH_ID IN NUMBER
                               ,P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_CAREER_PATH_NAME(:P_CAREER_PATH_ID, :P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_CAREER_PATH_ID);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_CAREER_PATH_NAME;

  FUNCTION GET_AAP_ORG_ID(P_AAP_NAME IN VARCHAR2
                         ,P_BUSINESS_GROUP_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
  /*  STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_AAP_ORG_ID(:P_AAP_NAME, :P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_AAP_NAME);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_AAP_ORG_ID;

  PROCEDURE GET_ADDRESS_31(P_LOCATION_ID IN NUMBER
                          ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
/*    STPROC.INIT('begin HR_US_REPORTS.GET_ADDRESS_31(:P_LOCATION_ID, :P_ADDRESS); end;');
    STPROC.BIND_I(P_LOCATION_ID);
    STPROC.BIND_O(P_ADDRESS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ADDRESS);*/NULL;
  END GET_ADDRESS_31;

  FUNCTION GET_LOCATION_CODE(P_LOCATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := HR_US_REPORTS.GET_LOCATION_CODE(:P_LOCATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_LOCATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END GET_LOCATION_CODE;

  PROCEDURE GET_ADDRESS_3LINES(P_PERSON_ID IN NUMBER
                              ,P_EFFECTIVE_DATE IN DATE
                              ,P_ADDR_LINE1 OUT NOCOPY VARCHAR2
                              ,P_ADDR_LINE2 OUT NOCOPY VARCHAR2
                              ,P_CITY_STATE_ZIP OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin HR_US_REPORTS.GET_ADDRESS_3LINES(:P_PERSON_ID, :P_EFFECTIVE_DATE, :P_ADDR_LINE1, :P_ADDR_LINE2, :P_CITY_STATE_ZIP); end;');
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.BIND_I(P_EFFECTIVE_DATE);
    STPROC.BIND_O(P_ADDR_LINE1);
    STPROC.BIND_O(P_ADDR_LINE2);
    STPROC.BIND_O(P_CITY_STATE_ZIP);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_ADDR_LINE1);
    STPROC.RETRIEVE(4
                   ,P_ADDR_LINE2);
    STPROC.RETRIEVE(5
                   ,P_CITY_STATE_ZIP);*/NULL;
  END GET_ADDRESS_3LINES;

  FUNCTION US_TAX_BALANCE_REP(P_ASG_LOCK IN BOOLEAN
                             ,P_TAX_BALANCE_CATEGORY IN VARCHAR2
                             ,P_TAX_TYPE IN VARCHAR2
                             ,P_EE_OR_ER IN VARCHAR2
                             ,P_TIME_TYPE IN VARCHAR2
                             ,P_ASG_TYPE IN VARCHAR2
                             ,P_GRE_ID_CONTEXT IN NUMBER
                             ,P_JD_CONTEXT IN VARCHAR2
                             ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                             ,P_ASSIGNMENT_ID IN NUMBER
                             ,P_VIRTUAL_DATE IN DATE
                             ,P_PAYROLL_ACTION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
  /*  STPROC.INIT('declare X0P_ASG_LOCK BOOLEAN; begin X0P_ASG_LOCK := sys.diutil.int_to_bool(:P_ASG_LOCK); :X0 :=
  PAY_US_TAX_BALS_PKG.US_TAX_BALANCE_REP(X0P_ASG_LOCK, :P_TAX_BALANCE_CATEGORY, :P_TAX_TYPE, :P_EE_OR_ER,
  :P_TIME_TYPE, :P_ASG_TYPE, :P_GRE_ID_CONTEXT, :P_JD_CONTEXT, :P_ASSIGNMENT_ACTION_ID, :P_ASSIGNMENT_ID, :P_VIRTUAL_DATE, :P_PAYROLL_ACTION_ID); end;');
    STPROC.BIND_I(P_ASG_LOCK);
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_BALANCE_CATEGORY);
    STPROC.BIND_I(P_TAX_TYPE);
    STPROC.BIND_I(P_EE_OR_ER);
    STPROC.BIND_I(P_TIME_TYPE);
    STPROC.BIND_I(P_ASG_TYPE);
    STPROC.BIND_I(P_GRE_ID_CONTEXT);
    STPROC.BIND_I(P_JD_CONTEXT);
    STPROC.BIND_I(P_ASSIGNMENT_ACTION_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_VIRTUAL_DATE);
    STPROC.BIND_I(P_PAYROLL_ACTION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);*/
    RETURN NULL;
  END US_TAX_BALANCE_REP;

  FUNCTION US_TAX_BALANCE_REP(P_ASG_LOCK IN BOOLEAN
                             ,P_TAX_BALANCE_CATEGORY IN VARCHAR2
                             ,P_TAX_TYPE IN VARCHAR2
                             ,P_EE_OR_ER IN VARCHAR2
                             ,P_TIME_TYPE IN VARCHAR2
                             ,P_ASG_TYPE IN VARCHAR2
                             ,P_GRE_ID_CONTEXT IN NUMBER
                             ,P_JD_CONTEXT IN VARCHAR2
                             ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                             ,P_ASSIGNMENT_ID IN NUMBER
                             ,P_VIRTUAL_DATE IN DATE) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('declare X0P_ASG_LOCK BOOLEAN; begin X0P_ASG_LOCK := sys.diutil.int_to_bool(:P_ASG_LOCK); :X0 := PAY_US_TAX_BALS_PKG.US_TAX_BALANCE_REP(X0P_ASG_LOCK,
:P_TAX_BALANCE_CATEGORY, :P_TAX_TYPE, :P_EE_OR_ER, :P_TIME_TYPE, :P_ASG_TYPE, :P_GRE_ID_CONTEXT, :P_JD_CONTEXT, :P_ASSIGNMENT_ACTION_ID, :P_ASSIGNMENT_ID, :P_VIRTUAL_DATE); end;');
    STPROC.BIND_I(P_ASG_LOCK);
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_BALANCE_CATEGORY);
    STPROC.BIND_I(P_TAX_TYPE);
    STPROC.BIND_I(P_EE_OR_ER);
    STPROC.BIND_I(P_TIME_TYPE);
    STPROC.BIND_I(P_ASG_TYPE);
    STPROC.BIND_I(P_GRE_ID_CONTEXT);
    STPROC.BIND_I(P_JD_CONTEXT);
    STPROC.BIND_I(P_ASSIGNMENT_ACTION_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_VIRTUAL_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);*/
    RETURN NULL;
  END US_TAX_BALANCE_REP;

  FUNCTION US_TAX_BALANCE(P_TAX_BALANCE_CATEGORY IN VARCHAR2
                         ,P_TAX_TYPE IN VARCHAR2
                         ,P_EE_OR_ER IN VARCHAR2
                         ,P_TIME_TYPE IN VARCHAR2
                         ,P_ASG_TYPE IN VARCHAR2
                         ,P_GRE_ID_CONTEXT IN NUMBER
                         ,P_JD_CONTEXT IN VARCHAR2
                         ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                         ,P_ASSIGNMENT_ID IN NUMBER
                         ,P_VIRTUAL_DATE IN DATE) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := PAY_US_TAX_BALS_PKG.US_TAX_BALANCE(:P_TAX_BALANCE_CATEGORY, :P_TAX_TYPE, :P_EE_OR_ER, :P_TIME_TYPE, :P_ASG_TYPE, :P_GRE_ID_CONTEXT, :P_JD_CONTEXT, :P_ASSIGNMENT_ACTION_ID, :P_ASSIGNMENT_ID, :P_VIRTUAL_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_BALANCE_CATEGORY);
    STPROC.BIND_I(P_TAX_TYPE);
    STPROC.BIND_I(P_EE_OR_ER);
    STPROC.BIND_I(P_TIME_TYPE);
    STPROC.BIND_I(P_ASG_TYPE);
    STPROC.BIND_I(P_GRE_ID_CONTEXT);
    STPROC.BIND_I(P_JD_CONTEXT);
    STPROC.BIND_I(P_ASSIGNMENT_ACTION_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_VIRTUAL_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END US_TAX_BALANCE;

  FUNCTION US_TAX_BALANCE(P_TAX_BALANCE_CATEGORY IN VARCHAR2
                         ,P_TAX_TYPE IN VARCHAR2
                         ,P_EE_OR_ER IN VARCHAR2
                         ,P_TIME_TYPE IN VARCHAR2
                         ,P_ASG_TYPE IN VARCHAR2
                         ,P_GRE_ID_CONTEXT IN NUMBER
                         ,P_JD_CONTEXT IN VARCHAR2
                         ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                         ,P_ASSIGNMENT_ID IN NUMBER
                         ,P_VIRTUAL_DATE IN DATE
                         ,P_PAYROLL_ACTION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := PAY_US_TAX_BALS_PKG.US_TAX_BALANCE(:P_TAX_BALANCE_CATEGORY, :P_TAX_TYPE, :P_EE_OR_ER, :P_TIME_TYPE, :P_ASG_TYPE,
   :P_GRE_ID_CONTEXT, :P_JD_CONTEXT, :P_ASSIGNMENT_ACTION_ID, :P_ASSIGNMENT_ID, :P_VIRTUAL_DATE, :P_PAYROLL_ACTION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_BALANCE_CATEGORY);
    STPROC.BIND_I(P_TAX_TYPE);
    STPROC.BIND_I(P_EE_OR_ER);
    STPROC.BIND_I(P_TIME_TYPE);
    STPROC.BIND_I(P_ASG_TYPE);
    STPROC.BIND_I(P_GRE_ID_CONTEXT);
    STPROC.BIND_I(P_JD_CONTEXT);
    STPROC.BIND_I(P_ASSIGNMENT_ACTION_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_VIRTUAL_DATE);
    STPROC.BIND_I(P_PAYROLL_ACTION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN NULL;
  END US_TAX_BALANCE;

  FUNCTION US_TAX_BALANCE(P_TAX_BALANCE_CATEGORY IN VARCHAR2
                         ,P_TAX_TYPE IN VARCHAR2
                         ,P_EE_OR_ER IN VARCHAR2
                         ,P_TIME_TYPE IN VARCHAR2
                         ,P_ASG_TYPE IN VARCHAR2
                         ,P_GRE_ID_CONTEXT IN NUMBER
                         ,P_JD_CONTEXT IN VARCHAR2
                         ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                         ,P_ASSIGNMENT_ID IN NUMBER
                         ,P_VIRTUAL_DATE IN DATE
                         ,P_PAYROLL_ACTION_ID IN NUMBER
                         ,P_ASG_LOCK IN BOOLEAN) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('declare X0P_ASG_LOCK BOOLEAN; begin X0P_ASG_LOCK := sys.diutil.int_to_bool(:P_ASG_LOCK); :X0 := PAY_US_TAX_BALS_PKG.US_TAX_BALANCE(
:P_TAX_BALANCE_CATEGORY, :P_TAX_TYPE, :P_EE_OR_ER, :P_TIME_TYPE, :P_ASG_TYPE, :P_GRE_ID_CONTEXT, :P_JD_CONTEXT, :P_ASSIGNMENT_ACTION_ID, :P_ASSIGNMENT_ID,
:P_VIRTUAL_DATE, :P_PAYROLL_ACTION_ID, X0P_ASG_LOCK); end;');
    STPROC.BIND_I(P_ASG_LOCK);
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_TAX_BALANCE_CATEGORY);
    STPROC.BIND_I(P_TAX_TYPE);
    STPROC.BIND_I(P_EE_OR_ER);
    STPROC.BIND_I(P_TIME_TYPE);
    STPROC.BIND_I(P_ASG_TYPE);
    STPROC.BIND_I(P_GRE_ID_CONTEXT);
    STPROC.BIND_I(P_JD_CONTEXT);
    STPROC.BIND_I(P_ASSIGNMENT_ACTION_ID);
    STPROC.BIND_I(P_ASSIGNMENT_ID);
    STPROC.BIND_I(P_VIRTUAL_DATE);
    STPROC.BIND_I(P_PAYROLL_ACTION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);*/
    RETURN NULL;
  END US_TAX_BALANCE;

function R_State1FormatTrigger(C_EXPERIENCE_RATE_1 IN varchar2,
				c_experience_rate2  IN Varchar2,
				C_TAXABLE_PAYROLL IN varchar2)  return boolean is
l_exp1 number := 0;
l_exp2 number := 0;
begin
if c_experience_rate_1 = 'N/A' then
   l_exp1 := 0;
else
   l_exp1 := nvl(to_number(c_experience_rate_1),0);
end if;

if (c_experience_rate2 = 'N/A' or c_experience_rate2 is null) then
   l_exp2 := 0;
else
   l_exp2 := nvl(to_number(c_experience_rate2),0);
end if;
if (l_exp1 > 5.4) or (l_exp2 > 5.4) then
  return (FALSE);
end if;

If c_taxable_payroll = 0 or c_taxable_payroll IS NULL then
	return(FALSE);
else
	return(TRUE);
end if;


  return (TRUE);

end;
END PAY_PAYRP940_XMLP_PKG;

/
