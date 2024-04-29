--------------------------------------------------------
--  DDL for Package Body PAY_ZA_ELE_TAX_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_ELE_TAX_FILE" AS
/* $Header: PYZAIRPM.pkb 120.0.12010000.1 2009/11/27 10:39:29 dwkrishn noship $ */

G_BUFFER_LINE VARCHAR2(4000);

FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  l_payroll_actions varchar2(4000);
BEGIN
     IF (P_PAYROLL_ACTION_ID is not null) THEN
        C_PAYROLL_ACTION_ID := 'and paa.payroll_action_id = '||P_PAYROLL_ACTION_ID;
        C_ACTION_CONTEXT_ID := 'and pai.action_context_id = '||P_PAYROLL_ACTION_ID;
     ELSE
        l_payroll_actions :=
              '(select ppa.payroll_action_id '||
                 'from pay_payroll_actions ppa '||
                'where ppa.business_group_id = '||P_BUSINESS_GROUP_ID||
                  ' and ppa.action_type = ''X'' '||
                  ' and ppa.report_type = ''ZA_TYE'' '||
                  ' and ppa.action_status = ''C'' '||
                  ' and pay_za_tye_archive_pkg.get_parameter(''TAX_YEAR'',ppa.legislative_parameters)= '||P_TAX_YEAR||
                  ' and pay_za_tye_archive_pkg.get_parameter(''CERT_TYPE'',ppa.legislative_parameters)= '''||P_CERTIFICATE_TYPE||''''||
                  ' and pay_za_tye_archive_pkg.get_parameter(''LEGAL_ENTITY'',ppa.legislative_parameters)= '||P_LEGAL_ENTITY_ID||' ) ';
        C_PAYROLL_ACTION_ID := 'and paa.payroll_action_id in '||l_payroll_actions;
        C_ACTION_CONTEXT_ID := 'and pai.action_context_id in '||l_payroll_actions;
     END IF;
     RETURN true;
END BEFOREREPORT;

PROCEDURE CAL_CTRL_TOTAL(CODE number,VALUE varchar2) IS
BEGIN
    IF (VALUE is not null) THEN
       -- Control Total Code
       CTRL_TOTAL_CODE := CTRL_TOTAL_CODE + CODE;
       -- Control Total Value
       IF (CODE >= 3601 and CODE <= 4497) THEN
          CTRL_TOTAL_VALUE := CTRL_TOTAL_VALUE + VALUE;
          G_BUFFER_LINE := G_BUFFER_LINE||CODE||','||VALUE||',';
       END IF;
    ELSIF (CODE = 9999) THEN
       -- Control Total Code
       CTRL_TOTAL_CODE := CTRL_TOTAL_CODE + CODE;
    END IF;
END CAL_CTRL_TOTAL;

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
                             POSTAL_CODE               varchar2)RETURN varchar2 IS
BEGIN
   CTRL_TOTAL_REC := CTRL_TOTAL_REC + 1;
   CAL_CTRL_TOTAL(2010,TRADE_NAME);
   CAL_CTRL_TOTAL(2015,TEST_LIVE);
   CAL_CTRL_TOTAL(2020,PAYE_NUMBER);
   CAL_CTRL_TOTAL(2022,SDL_NUMBER);
   CAL_CTRL_TOTAL(2024,UIF_NUMBER);
   CAL_CTRL_TOTAL(2025,EMPLOYER_CONTACT_NAME);
   CAL_CTRL_TOTAL(2026,EMPLOYER_CONTACT_PHONE);
   CAL_CTRL_TOTAL(2027,EMPLOYER_EMAIL);
   CAL_CTRL_TOTAL(2028,PAYROLL_SOFTWARE);
   CAL_CTRL_TOTAL(2030,TRANSACTION_YEAR);
   CAL_CTRL_TOTAL(2031,PERIOD_OF_RECONCILIATION);
   CAL_CTRL_TOTAL(2035,TRADE_CLASSIFICATION);
   CAL_CTRL_TOTAL(2061,PHYSICAL_ADD_UNIT_NUM);
   CAL_CTRL_TOTAL(2062,PHYSICAL_ADD_COMPLEX);
   CAL_CTRL_TOTAL(2063,PHYSICAL_ADD_STREET);
   CAL_CTRL_TOTAL(2064,PHYSICAL_ADD_FORM);
   CAL_CTRL_TOTAL(2065,PHYSICAL_ADD_SUBURB);
   CAL_CTRL_TOTAL(2066,PHYSICAL_ADD_CITY);
   CAL_CTRL_TOTAL(2080,POSTAL_CODE);
   CAL_CTRL_TOTAL(9999,null);

   return null;

END EMPLOYER_CTRL_TOTAL;


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
                             BANK_ACC_RELATIONSHIP     varchar2) RETURN varchar2 IS
BEGIN
   CTRL_TOTAL_REC := CTRL_TOTAL_REC + 1;
   CAL_CTRL_TOTAL(3010,CERTIFICATE_NUMBER);
   CAL_CTRL_TOTAL(3015,CERTIFICATE_TYPE);
   CAL_CTRL_TOTAL(3020,NATURE_OF_PERSON);
   CAL_CTRL_TOTAL(3025,YEAR_OF_ASSESSMENT);
   CAL_CTRL_TOTAL(3030,SUR_OR_TRADING_NAME);
   CAL_CTRL_TOTAL(3040,FIRST_TWO_NAMES);
   CAL_CTRL_TOTAL(3050,EMP_INITIALS);
   CAL_CTRL_TOTAL(3060,IDENTITY_NUMBER);
   CAL_CTRL_TOTAL(3070,PASSPORT_NUMBER);
   CAL_CTRL_TOTAL(3075,COUNTRY_OF_ISSUE);
   CAL_CTRL_TOTAL(3080,DATE_OF_BIRTH);
   CAL_CTRL_TOTAL(3100,IT_REF_NUMBER);
   CAL_CTRL_TOTAL(3160,EMP_NUMBER);
   CAL_CTRL_TOTAL(3170,DATE_EMPLOYED_FROM);
   CAL_CTRL_TOTAL(3180,DATE_EMPLOYED_TO);
   CAL_CTRL_TOTAL(3200,PAY_PERIODS_IN_YEAR);
   CAL_CTRL_TOTAL(3210,PAY_PERIODS_IN_WORKED);
   CAL_CTRL_TOTAL(3230,DIRECTIVE_NUMBER1);
   CAL_CTRL_TOTAL(3230,DIRECTIVE_NUMBER2);
   CAL_CTRL_TOTAL(3230,DIRECTIVE_NUMBER3);
   CAL_CTRL_TOTAL(3240,BANK_ACC_TYPE);
   CAL_CTRL_TOTAL(3241,BANK_ACC_NUMBER);
   CAL_CTRL_TOTAL(3242,BANK_BR_NUMBER);
   CAL_CTRL_TOTAL(3243,BANK_NAME);
   CAL_CTRL_TOTAL(3244,BANK_BR_NAME);
   CAL_CTRL_TOTAL(3245,BANK_ACC_NAME);
   CAL_CTRL_TOTAL(3246,BANK_ACC_RELATIONSHIP);
   CAL_CTRL_TOTAL(9999,null);

   return null;
END EMPLOYEE_CTRL_TOTAL;

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
                                  POS_CODE             varchar2) RETURN varchar2 IS

BEGIN
   CAL_CTRL_TOTAL(3125,EMP_EMAIL);
   CAL_CTRL_TOTAL(3135,HOME_PHONE);
   CAL_CTRL_TOTAL(3136,BUS_PHONE);
   CAL_CTRL_TOTAL(3137,FAX_NUMBER);
   CAL_CTRL_TOTAL(3138,CELL_NUMBER);
   CAL_CTRL_TOTAL(3144,BUS_UNIT_NUMBER);
   CAL_CTRL_TOTAL(3145,BUS_COMPLEX);
   CAL_CTRL_TOTAL(3146,BUS_STREET_NUM);
   CAL_CTRL_TOTAL(3147,BUS_FORM);
   CAL_CTRL_TOTAL(3148,BUS_SUBURB);
   CAL_CTRL_TOTAL(3149,BUS_CITY);
   CAL_CTRL_TOTAL(3150,BUS_POSTAL_CODE);
   CAL_CTRL_TOTAL(3211,RES_UNIT_NUMBER);
   CAL_CTRL_TOTAL(3212,RES_COMPLEX);
   CAL_CTRL_TOTAL(3213,RES_STREET_NUM);
   CAL_CTRL_TOTAL(3214,RES_FORM);
   CAL_CTRL_TOTAL(3215,RES_SUBURB);
   CAL_CTRL_TOTAL(3216,RES_CITY);
   CAL_CTRL_TOTAL(3217,RES_POSTAL_CODE);
   CAL_CTRL_TOTAL(3218,POS_RES_ADD_SAME);
   CAL_CTRL_TOTAL(3221,POS_LINE1);
   CAL_CTRL_TOTAL(3222,POS_LINE2);
   CAL_CTRL_TOTAL(3223,POS_LINE3);
   CAL_CTRL_TOTAL(3229,POS_CODE);

   return null;
END EMPLOYEE_CONT_CTRL_TOTAL;

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
                                 INC_VAL13             varchar2) RETURN varchar2 IS
BEGIN
   G_BUFFER_LINE:='';
   CAL_CTRL_TOTAL(INC_CODE1,INC_VAL1);
   CAL_CTRL_TOTAL(INC_CODE2,INC_VAL2);
   CAL_CTRL_TOTAL(INC_CODE3,INC_VAL3);
   CAL_CTRL_TOTAL(INC_CODE4,INC_VAL4);
   CAL_CTRL_TOTAL(INC_CODE5,INC_VAL5);
   CAL_CTRL_TOTAL(INC_CODE6,INC_VAL6);
   CAL_CTRL_TOTAL(INC_CODE7,INC_VAL7);
   CAL_CTRL_TOTAL(INC_CODE8,INC_VAL8);
   CAL_CTRL_TOTAL(INC_CODE9,INC_VAL9);
   CAL_CTRL_TOTAL(INC_CODE10,INC_VAL10);
   CAL_CTRL_TOTAL(INC_CODE11,INC_VAL11);
   CAL_CTRL_TOTAL(INC_CODE12,INC_VAL12);
   CAL_CTRL_TOTAL(INC_CODE13,INC_VAL13);

   return G_BUFFER_LINE;
END EMPLOYEE_INC_CTRL_TOTAL;

FUNCTION EMPLOYEE_GRO_CTRL_TOTAL(NON_TAX_INCOME       varchar2,
                                 RFI_INCOME           varchar2,
                                 NRFI_INCOME          varchar2) RETURN varchar2 IS
BEGIN
   CAL_CTRL_TOTAL(3696,NON_TAX_INCOME);
   CAL_CTRL_TOTAL(3697,RFI_INCOME);
   CAL_CTRL_TOTAL(3698,NRFI_INCOME);

   return null;
END EMPLOYEE_GRO_CTRL_TOTAL;

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
                                 DED_VAL13            varchar2) RETURN varchar2 IS


BEGIN
   G_BUFFER_LINE:='';
   CAL_CTRL_TOTAL(DED_CODE1,DED_VAL1);
   CAL_CTRL_TOTAL(DED_CODE2,DED_VAL2);
   CAL_CTRL_TOTAL(DED_CODE3,DED_VAL3);
   CAL_CTRL_TOTAL(DED_CODE4,DED_VAL4);
   CAL_CTRL_TOTAL(DED_CODE5,DED_VAL5);
   CAL_CTRL_TOTAL(DED_CODE6,DED_VAL6);
   CAL_CTRL_TOTAL(DED_CODE7,DED_VAL7);
   CAL_CTRL_TOTAL(DED_CODE8,DED_VAL8);
   CAL_CTRL_TOTAL(DED_CODE9,DED_VAL9);
   CAL_CTRL_TOTAL(DED_CODE10,DED_VAL10);
   CAL_CTRL_TOTAL(DED_CODE11,DED_VAL11);
   CAL_CTRL_TOTAL(DED_CODE12,DED_VAL12);
   CAL_CTRL_TOTAL(DED_CODE13,DED_VAL13);

   return G_BUFFER_LINE;
END EMPLOYEE_DED_CTRL_TOTAL;

FUNCTION EMPLOYEE_TAX_CTRL_TOTAL(TOTAL_DEDUCTION      varchar2,
                                 SITE                 varchar2,
                                 PAYE                 varchar2,
                                 PAYE_RET_LUM_BEN     varchar2,
                                 UIF_CONTRIBUTION     varchar2,
                                 SDL_CONTRIBUTION     varchar2,
                                 TOT_TAX_UIF_SDL      varchar2,
                                 REASON_CODE_IT3      varchar2) RETURN varchar2 IS
BEGIN
   CAL_CTRL_TOTAL(4497,TOTAL_DEDUCTION);
   CAL_CTRL_TOTAL(4101,SITE);
   CAL_CTRL_TOTAL(4102,PAYE);
   CAL_CTRL_TOTAL(4115,PAYE_RET_LUM_BEN);
   CAL_CTRL_TOTAL(4141,UIF_CONTRIBUTION);
   CAL_CTRL_TOTAL(4142,SDL_CONTRIBUTION);
   CAL_CTRL_TOTAL(4149,TOT_TAX_UIF_SDL);
   CAL_CTRL_TOTAL(4150,REASON_CODE_IT3);

   return null;
END EMPLOYEE_TAX_CTRL_TOTAL;


END PAY_ZA_ELE_TAX_FILE;

/
