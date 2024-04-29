--------------------------------------------------------
--  DDL for Package PAY_ZA_ELE_TAX_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_ELE_TAX_FILE" AUTHID CURRENT_USER AS
/* $Header: PYZAIRPM.pkh 120.0.12010000.1 2009/11/27 10:38:17 dwkrishn noship $ */

P_BUSINESS_GROUP_ID number;
P_CERTIFICATE_TYPE  varchar2(30);
P_TAX_YEAR          number;
P_LEGAL_ENTITY_ID      number;
P_PAYROLL_ACTION_ID number;
P_TEST_RUN          varchar2(10);

C_ACTION_CONTEXT_ID varchar2(2000):=' ';
C_PAYROLL_ACTION_ID varchar2(2000):=' ';

CTRL_TOTAL_REC        number:=0;
CTRL_TOTAL_CODE       number:=0;
CTRL_TOTAL_VALUE      number:=0;


FUNCTION BEFOREREPORT return boolean;

FUNCTION EMPLOYER_CTRL_TOTAL(TRADE_NAME                varchar2,
                             TEST_LIVE                 varchar2,
                             PAYE_NUMBER               varchar2,
                             SDL_NUMBER                varchar2,
                             UIF_NUMBER                varchar2,
                             EMPLOYER_CONTACT_NAME     varchar2,
                             EMPLOYER_CONTACT_PHONE    varchar2,
                             EMPLOYER_EMAIL            varchar2,
                             PAYROLL_SOFTWARE          varchar2,
                             TRANSACTION_YEAR          varchar2,
                             PERIOD_OF_RECONCILIATION  varchar2,
                             TRADE_CLASSIFICATION      varchar2,
                             PHYSICAL_ADD_UNIT_NUM     varchar2,
                             PHYSICAL_ADD_COMPLEX      varchar2,
                             PHYSICAL_ADD_STREET       varchar2,
                             PHYSICAL_ADD_FORM         varchar2,
                             PHYSICAL_ADD_SUBURB       varchar2,
                             PHYSICAL_ADD_CITY         varchar2,
                             POSTAL_CODE               varchar2) RETURN varchar2;

FUNCTION EMPLOYEE_CTRL_TOTAL(CERTIFICATE_NUMBER        varchar2,
                             CERTIFICATE_TYPE          varchar2,
                             NATURE_OF_PERSON          varchar2,
                             YEAR_OF_ASSESSMENT        varchar2,
                             SUR_OR_TRADING_NAME       varchar2,
                             FIRST_TWO_NAMES           varchar2,
                             EMP_INITIALS              varchar2,
                             IDENTITY_NUMBER           varchar2,
                             PASSPORT_NUMBER           varchar2,
                             COUNTRY_OF_ISSUE          varchar2,
                             DATE_OF_BIRTH             varchar2,
                             IT_REF_NUMBER             varchar2,
                             EMP_NUMBER                varchar2,
                             DATE_EMPLOYED_FROM        varchar2,
                             DATE_EMPLOYED_TO          varchar2,
                             PAY_PERIODS_IN_YEAR       varchar2,
                             PAY_PERIODS_IN_WORKED     varchar2,
                             DIRECTIVE_NUMBER1         varchar2,
                             DIRECTIVE_NUMBER2         varchar2,
                             DIRECTIVE_NUMBER3         varchar2,
                             BANK_ACC_TYPE             varchar2,
                             BANK_ACC_NUMBER           varchar2,
                             BANK_BR_NUMBER            varchar2,
                             BANK_NAME                 varchar2,
                             BANK_BR_NAME              varchar2,
                             BANK_ACC_NAME             varchar2,
                             BANK_ACC_RELATIONSHIP     varchar2) RETURN varchar2;
FUNCTION EMPLOYEE_CONT_CTRL_TOTAL(EMP_EMAIL            varchar2,
                                  HOME_PHONE           varchar2,
                                  BUS_PHONE            varchar2,
                                  FAX_NUMBER           varchar2,
                                  CELL_NUMBER          varchar2,
                                  BUS_UNIT_NUMBER      varchar2,
                                  BUS_COMPLEX          varchar2,
                                  BUS_STREET_NUM       varchar2,
                                  BUS_FORM             varchar2,
                                  BUS_SUBURB           varchar2,
                                  BUS_CITY             varchar2,
                                  BUS_POSTAL_CODE      varchar2,
                                  RES_UNIT_NUMBER      varchar2,
                                  RES_COMPLEX          varchar2,
                                  RES_STREET_NUM       varchar2,
                                  RES_FORM             varchar2,
                                  RES_SUBURB           varchar2,
                                  RES_CITY             varchar2,
                                  RES_POSTAL_CODE      varchar2,
                                  POS_RES_ADD_SAME     varchar2,
                                  POS_LINE1            varchar2,
                                  POS_LINE2            varchar2,
                                  POS_LINE3            varchar2,
                                  POS_CODE             varchar2) RETURN varchar2;

FUNCTION EMPLOYEE_INC_CTRL_TOTAL(INC_CODE1             varchar2,
                                 INC_VAL1              varchar2,
                                 INC_CODE2             varchar2,
                                 INC_VAL2              varchar2,
                                 INC_CODE3             varchar2,
                                 INC_VAL3              varchar2,
                                 INC_CODE4             varchar2,
                                 INC_VAL4              varchar2,
                                 INC_CODE5             varchar2,
                                 INC_VAL5              varchar2,
                                 INC_CODE6             varchar2,
                                 INC_VAL6              varchar2,
                                 INC_CODE7             varchar2,
                                 INC_VAL7              varchar2,
                                 INC_CODE8             varchar2,
                                 INC_VAL8              varchar2,
                                 INC_CODE9             varchar2,
                                 INC_VAL9              varchar2,
                                 INC_CODE10            varchar2,
                                 INC_VAL10             varchar2,
                                 INC_CODE11            varchar2,
                                 INC_VAL11             varchar2,
                                 INC_CODE12            varchar2,
                                 INC_VAL12             varchar2,
                                 INC_CODE13            varchar2,
                                 INC_VAL13             varchar2) RETURN varchar2;

FUNCTION EMPLOYEE_GRO_CTRL_TOTAL(NON_TAX_INCOME       varchar2,
                                 RFI_INCOME           varchar2,
                                 NRFI_INCOME          varchar2) RETURN varchar2;

FUNCTION EMPLOYEE_DED_CTRL_TOTAL(DED_CODE1            varchar2,
                                 DED_VAL1             varchar2,
                                 DED_CODE2            varchar2,
                                 DED_VAL2             varchar2,
                                 DED_CODE3            varchar2,
                                 DED_VAL3             varchar2,
                                 DED_CODE4            varchar2,
                                 DED_VAL4             varchar2,
                                 DED_CODE5            varchar2,
                                 DED_VAL5             varchar2,
                                 DED_CODE6            varchar2,
                                 DED_VAL6             varchar2,
                                 DED_CODE7            varchar2,
                                 DED_VAL7             varchar2,
                                 DED_CODE8            varchar2,
                                 DED_VAL8             varchar2,
                                 DED_CODE9            varchar2,
                                 DED_VAL9             varchar2,
                                 DED_CODE10           varchar2,
                                 DED_VAL10            varchar2,
                                 DED_CODE11           varchar2,
                                 DED_VAL11            varchar2,
                                 DED_CODE12           varchar2,
                                 DED_VAL12            varchar2,
                                 DED_CODE13           varchar2,
                                 DED_VAL13            varchar2) RETURN varchar2;

FUNCTION EMPLOYEE_TAX_CTRL_TOTAL(TOTAL_DEDUCTION      varchar2,
                                 SITE                 varchar2,
                                 PAYE                 varchar2,
                                 PAYE_RET_LUM_BEN     varchar2,
                                 UIF_CONTRIBUTION     varchar2,
                                 SDL_CONTRIBUTION     varchar2,
                                 TOT_TAX_UIF_SDL      varchar2,
                                 REASON_CODE_IT3      varchar2) RETURN varchar2;

END PAY_ZA_ELE_TAX_FILE;

/
