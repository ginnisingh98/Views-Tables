--------------------------------------------------------
--  DDL for Package PAY_PAYAUSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYAUSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYAUSOES.pls 120.1 2008/03/26 14:04:31 amakrish noship $ */
  P_BUSINESS_GROUP_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_ASSIGNMENT_ID NUMBER;

  P_LOCATION_ID NUMBER;

  P_ORGANISATION_NAME VARCHAR2(60);

  P_PAYROLL_ACTION_ID NUMBER;

  P_PAYROLL_ID NUMBER;

  P_SORT_ORDER_1 VARCHAR2(32767);

  P_SORT_ORDER_2 VARCHAR2(32767);

  P_SORT_ORDER_3 VARCHAR2(32767);

  P_SORT_ORDER_4 VARCHAR2(32767);

  PRINT_LEAVE_TAKEN VARCHAR2(1) := 'N';

  PRINT_LEAVE_BALANCES VARCHAR2(1) := 'N';

  PRINT_MESSAGES VARCHAR2(1) := 'N';

  CP_ADDRESS_LINE_1 VARCHAR2(60);

  CP_ADDRESS_LINE_2 VARCHAR2(60);

  CP_ADDRESS_LINE_3 VARCHAR2(60);

  CP_POSTAL_CODE VARCHAR2(30);

  CP_TOWN_CITY VARCHAR2(30);

  CP_COUNTRY VARCHAR2(60);

  CP_PRE_TAX_DEDUCTIONS_THIS_PAY NUMBER;

  CP_DIRECT_PAYMENTS_YTD NUMBER;

  CP_TAXABLE_INCOME_YTD NUMBER;

  CP_DIRECT_PAYMENTS_THIS_PAY NUMBER;

  CP_TAXABLE_INCOME_THIS_PAY NUMBER;

  CP_PRE_TAX_DEDUCTIONS_YTD NUMBER;

  CP_NON_TAX_ALLOW_YTD NUMBER;

  CP_GROSS_THIS_PAY NUMBER;

  CP_NON_TAX_ALLOW_THIS_PAY NUMBER;

  CP_OTHER_DEDUCTIONS_THIS_PAY NUMBER;

  CP_TAX_DEDUCTIONS_THIS_PAY NUMBER;

  CP_GROSS_YTD NUMBER;

  CP_OTHER_DEDUCTIONS_YTD NUMBER;

  CP_TAX_DEDUCTIONS_YTD NUMBER;

  CP_START_DATE DATE;

  CP_END_DATE DATE;

  CP_ACCRUAL_END_DATE DATE;

  CP_ACCRUAL NUMBER;

  CP_NET_ENTITLEMENT NUMBER;

  CP_WHERE_CLAUSE VARCHAR2(2000);

  CP_ORDER_BY VARCHAR2(2000);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_CURRENCY_FORMAT_MASKFORMULA RETURN VARCHAR2;

  FUNCTION CF_NET_ACCRUALFORMULA(LEAVE_BALANCE_ABSENCE_TYPE IN VARCHAR2
                                ,ASSIGNMENT_ACTION_ID_LB IN NUMBER
                                ,ASSIGNMENT_ID_LB IN NUMBER
                                ,PAYROLL_ID_LB IN NUMBER
                                ,BUSINESS_GROUP_ID_LB IN NUMBER
                                ,ACCRUAL_PLAN_ID_LB IN NUMBER
                                ,PERIOD_END_DATE IN DATE) RETURN NUMBER;

  PROCEDURE CONSTRUCT_WHERE_CLAUSE;

  PROCEDURE CONSTRUCT_ORDER_BY;

  FUNCTION CF_NET_THIS_PAYFORMULA RETURN NUMBER;

  FUNCTION CF_NET_YTDFORMULA RETURN NUMBER;

  FUNCTION CF_GET_MISCELLANEOUS_VALUESFOR(EXPENSE_CHECK_SEND_TO_ADDRESS IN VARCHAR2
                                         ,PERSON_ID IN NUMBER
                                         ,LOCATION_ID IN NUMBER
                                         ,ASSIGNMENT_ID IN NUMBER
                                         ,ASSIGNMENT_ACTION_ID IN NUMBER
                                         ,DATE_EARNED IN DATE) RETURN NUMBER;

  FUNCTION CF_HOURS_FORMAT_MASKFORMULA RETURN CHAR;

  FUNCTION CF_CHANGE_PRINT_MESSAGESFORMUL(PAY_ADVICE_MESSAGE IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_GRADE_STEPFORMULA(ASSIGNMENT_ID IN NUMBER
                               ,DATE_EARNED IN DATE) RETURN NUMBER;

  FUNCTION CF_CHANGE_PRINT_LEAVE_TAKENFOR RETURN NUMBER;

  FUNCTION CF_CHANGE_PRINT_LEAVE_BALANCES RETURN NUMBER;

  PROCEDURE SET_PRINT_FLAGS;

  --FUNCTION CF_PERIOD_START_DATEFORMULA(ASSIGNMENT_ACTION_ID IN NUMBER) RETURN DATE;
  FUNCTION CF_PERIOD_START_DATEFORMULA(ASSIGNMENT_ACTION_ID_V IN NUMBER) RETURN DATE ;
  FUNCTION CP_ADDRESS_LINE_1_P RETURN VARCHAR2;

  FUNCTION CP_ADDRESS_LINE_2_P RETURN VARCHAR2;

  FUNCTION CP_ADDRESS_LINE_3_P RETURN VARCHAR2;

  FUNCTION CP_POSTAL_CODE_P RETURN VARCHAR2;

  FUNCTION CP_TOWN_CITY_P RETURN VARCHAR2;

  FUNCTION CP_COUNTRY_P RETURN VARCHAR2;

  FUNCTION CP_PRE_TAX_DEDUCTIONS_THIS_PA RETURN NUMBER;

  FUNCTION CP_DIRECT_PAYMENTS_YTD_P RETURN NUMBER;

  FUNCTION CP_TAXABLE_INCOME_YTD_P RETURN NUMBER;

  FUNCTION CP_DIRECT_PAYMENTS_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_TAXABLE_INCOME_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_PRE_TAX_DEDUCTIONS_YTD_P RETURN NUMBER;

  FUNCTION CP_NON_TAX_ALLOW_YTD_P RETURN NUMBER;

  FUNCTION CP_GROSS_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_NON_TAX_ALLOW_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_OTHER_DEDUCTIONS_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_TAX_DEDUCTIONS_THIS_PAY_P RETURN NUMBER;

  FUNCTION CP_GROSS_YTD_P RETURN NUMBER;

  FUNCTION CP_OTHER_DEDUCTIONS_YTD_P RETURN NUMBER;

  FUNCTION CP_TAX_DEDUCTIONS_YTD_P RETURN NUMBER;

  FUNCTION CP_START_DATE_P RETURN DATE;

  FUNCTION CP_END_DATE_P RETURN DATE;

  FUNCTION CP_ACCRUAL_END_DATE_P RETURN DATE;

  FUNCTION CP_ACCRUAL_P RETURN NUMBER;

  FUNCTION CP_NET_ENTITLEMENT_P RETURN NUMBER;

  FUNCTION CP_WHERE_CLAUSE_P RETURN VARCHAR2;

  FUNCTION CP_ORDER_BY_P RETURN VARCHAR2;

END PAY_PAYAUSOE_XMLP_PKG;

/