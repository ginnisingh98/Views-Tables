--------------------------------------------------------
--  DDL for Package PAY_US_INV_DED_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_INV_DED_FORMULAS" AUTHID CURRENT_USER as
/* $Header: pyusgrfm.pkh 120.9.12010000.2 2008/09/23 03:50:30 sudedas ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_inv_ded_formulas

    Description : This package is used by fast formulas of involuntary
                  deduction elements to calculate deduction amounts. Different
                  functions cater to different categories of involuntary
                  deduction.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-APR-2004 sdahiya    115.0            Created.
    14-MAY-2004 sdahiya    115.1   2658290, - Added parameters to base_formula and
                                   2992741    cal_formula_bo.
                                            - Added global PL/SQL table arrears_tab.
                                            - Global variables in replacement of
                                              input values modified to be PL/SQL tables
                                              instead of scalar variables.
    01-JUN-2004 sdahiya    115.2   3549207  - Removed VOLDEDNS_AT_WRIT and VOL_DEDNS_ASG_GRE_LTD
                                              parameters from BASE_FORMULA.
    30-JUN-2004 kvsankar   115.3              Added a new global element GLB_NUM_ELEM
    08-JUL-2004 kvsankar   115.4   3749162    Added a new procedure RESET_GLOBAL_VAR
    09-DEC-2004 kvsankar   115.5   3650283    Added paramters to BASE_FORMULA
                                              and CAL_FORMULA_BO for DCIA category.
    03-JAN-2005 kvsankar   115.6   4079142..  Added the following global variables
                                              for DCIA.
                                                i. GLB_SUPPORT_DI
                                               ii. GLB_OTHER_DI_FLAG
                                              iii. GLB_DCIA_EXIST_FLAG
    03-FEB-2005 kvsankar   115.7              Added a new function GET_CCPA_PROTECTION
                                              which calculates the ccpa_protection
                                              value.
    18-FEB-2005 kvsankar   115.8   4154950    Modified the BASE_FORMULA declaration
                                              to use _ASG dimension instead of _ASG_GRE
                                              becuase of the the Bug fix made to the
                                              'BALANCE_SETUP_FORMULA' for all categories.
                                              The following are the parameters modified: -
                                                i. ACCRUED_ASG_GRE_LTD
                                               ii. ACCRUED_FEES_ASG_GRE_LTD
                                              iii. ASG_GRE_MONTH
                                               iv. ASG_GRE_PTD
    03-MAR-2004 kvsankar   115.9   4104842    Added a new Global variable
                                              GLB_TL_GROSS_EARNINGS.
    24-AUG-2005 kvsankar   115.10  3528349    Modified the function GET_TABLE_VALUE
                                              to include a new parameter.
    16-DEC-2005 kvsankar   115.11  4748532    Added two new Global tables
                                              Added a new parameter 'FEES_ASG_GRE_PTD'
                                              to the BASE_FORMULA
    20-DEC-2005 kvsankar   115.12  4748532    Added aa new Global table
                                              actual_dedn_tab
    06-JAN-2006 kvsankar   115.13  4858720    Added a new parameter 'EIC_ADVANCE_ASG_GRE_RUN'
                                              to
                                               * CAL_FORMULA_BO
                                               * CAL_FORMULA_SS
                                               * CAL_FORMULA_TL
    17-Mar-2006 kvsankar   115.14  5095823    Added a new Global variable
                                              GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN
                                              to sum up the Support Fees
    07-APR-2006 kvsankar   115.15  4858720    Added a new parameter 'EIC_ADVANCE_ASG_GRE_RUN'
                                              to BASE_FORMULA
    12-APR-2006 kvsankar   115.16  5149450    Added a new global variable
                                              'GLB_AMT_NOT_SPEC'
    11-Jul-2006 sudedas    115.17  5295813    Added Global Table mod_dedn_tab.
    06-Aug-2006 sudedas    115.18  4676867    Added new parameters VOL_DEDN_ROTH_ASG_GRE_RUN,
                                              VOL_DEDN_SB_TX_ASG_GRE_RUN and
                                              VOL_DEDN_SB_TX_JD_ASG_GRE_RUN to
                                              BASE_FORMULA, CAL_FORMULA_SS, CAL_FORMULA_BO
    19-Sep-2008 sudedas    115.19  6818016    Base_Formula and Cal_Formula_BO modified to pass
                                              2 parameters NET_ASG_RUN and NET_ASG_PTD.
  *****************************************************************************/

  /****************************************************************************
    Name        : BASE_FORMULA
    Description : This function calculates deduction amount and fees claimed by
                  each involuntary deduction element. It also initializes input
                  values of calculator element. these input values are later sent
                  as indirect inputs.
  *****************************************************************************/

FUNCTION BASE_FORMULA(
    P_CTX_DATE_EARNED                   date,
    P_CTX_ELEMENT_ENTRY_ID              number,
    P_CTX_JURISDICTION_CODE             varchar2,
    P_CTX_ORIGINAL_ENTRY_ID             number,
    ADDITIONAL_ASG_GRE_LTD              IN OUT NOCOPY number,
    REPLACEMENT_ASG_GRE_LTD             IN OUT NOCOPY number,
    ACCRUED_ASG_LTD                     IN OUT NOCOPY number,
    ACCRUED_FEES_ASG_LTD                number,
    FEES_ENTRY_PTD                      IN OUT NOCOPY number,
    FEES_ENTRY_ITD                      IN OUT NOCOPY number,
    FEES_ENTRY_MONTH                    IN OUT NOCOPY number,
    ASG_MONTH                           number,
    ASG_PTD                             number,
    /*VOL_DEDNS_ASG_GRE_LTD               number,*/
    VOL_DED_ASG_GRE_LASTRUN             number,
    PRE_TAX_DED_ASG_GRE_LASTRUN         number,
    ASG_WORK_AT_HOME                    varchar2,
    OVERRIDE_PER_ADR_REGION_2           varchar2,
    OVERRIDE_PER_ADR_REGION_1           varchar2,
    OVERRIDE_PER_ADR_CITY               varchar2,
    OVERRIDE_PER_ADR_POSTAL_CODE        varchar2,
    OVERRIDE_LOC_ADR_REGION_2           varchar2,
    OVERRIDE_LOC_ADR_REGION_1           varchar2,
    OVERRIDE_LOC_ADR_CITY               varchar2,
    OVERRIDE_LOC_ADR_POSTAL_CODE        varchar2,
    AMOUNT                              number,
    JURISDICTION                        IN OUT NOCOPY varchar2,
    DATE_SERVED                         IN OUT NOCOPY date,
    DEDNS_AT_TIME_OF_WRIT               number,
    PAY_EARNED_END_DATE                 date,
    EXEMPT_AMOUNT                       number,
    ARREARS_DATE                        date,
    NUM_DEPS                            number,
    FIL_STAT                            varchar2,
    ALLOWS                              number,
    /*VOLDEDNS_AT_WRIT                    OUT NOCOPY number,*/
    CALC_SUBPRIO                        OUT NOCOPY number,
    REGULAR_EARNINGS_ASG_GRE_RUN        number,
    DI_SUBJ_TAX_JD_ASG_GRE_RUN          number,
    DI_SUBJ_TAX_ASG_GRE_RUN             number,
    TAX_DEDUCTIONS_ASG_GRE_RUN          number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN      number,
    PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN      number,
    PRE_TAX_SUBJ_TX_ASG_GRE_RUN         number,
    ARREARS_OVERRIDE                    number,
    PERCENTAGE                          number,
    MONTHLY_CAP_AMOUNT                  number,
    PERIOD_CAP_AMOUNT                   number,
    GARN_FEE_FEE_RULE                   varchar2,
    GARN_FEE_FEE_AMOUNT                 number,
    GARN_FEE_MAX_FEE_AMOUNT             number,
    ACCRUED_FEES                        number,
    GARN_FEE_PCT_CURRENT                number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT       number,
    TOTAL_OWED                          number,
    GARN_TOTAL_FEES_ASG_GRE_RUN         number,
    GRN_DI_SUBJ_TX_ASG_GRE_RUN          number,
    GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN       number,
    PR_TX_DED_SBJ_TX_ASG_GRE_RN         number,
    PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN      number,
    GARN_EXEMPTION_CALC_RULE            varchar2,
    GARN_TOTAL_DEDNS_ASG_GRE_RUN        number,
    DCIA_DI_SUBJ_TX_ASG_GRE_RUN         number default 0,
    DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN      number default 0,
    PR_TX_DCIA_SB_TX_ASG_GRE_RN         number default 0,
    PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN      number default 0,
    FEES_ASG_GRE_PTD                    number default -9999,
    EIC_ADVANCE_ASG_GRE_RUN             number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN            number  default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN           number  default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN        number  default 0,
    NET_ASG_RUN                          number  default 0,
    NET_ASG_PTD                          number  default 0

) RETURN number;

  /****************************************************************************
    Name        : CAL_FORMULA_SS
    Description : This function performs DI calculation for involuntary
                  deduction elements of type AY/CS/SS. This function also
                  distributes the deducted amount over different elements
                  according to the proration rule defined.
  *****************************************************************************/

FUNCTION CAL_FORMULA_SS
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    GARN_EXEMPTION_CALC_RULE varchar2,
    GARN_EXMPT_DEP_CALC_RULE varchar2,
    GARN_EXEMPTION_DI_PCT number,
    GARN_EXMPT_DI_PCT_IN_ARR number,
    GARN_EXMPT_DI_PCT_DEP number,
    GARN_EXMPT_DI_PCT_DEP_IN_ARR number,
    GARN_EXEMPTION_MIN_WAGE_FACTOR number,
    GARN_EXEMPTION_AMOUNT_VALUE number,
    GARN_EXMPT_DEP_AMT_VAL number,
    GARN_EXMPT_ADDL_DEP_AMT_VAL number,
    GARN_EXEMPTION_PRORATION_RULE varchar2,
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_PCT_CURRENT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE  date,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    ASG_FREQ varchar2,
    REGULAR_EARNINGS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    DI_SUBJ_TAX_JD_ASG_GRE_RUN number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN number,
    DI_SUBJ_TAX_ASG_GRE_RUN number,
    PRE_TAX_SUBJ_TX_ASG_GRE_RUN number,
    PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    JURISDICTION varchar2,
    TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    ARREARS_AMOUNT_BALANCE number,
    SUPPORT_OTHER_FAMILY varchar2,
    ACCRUED_FEES number,
    PTD_FEE_BALANCE number,
    MONTH_FEE_BALANCE number,
    TAX_LEVIES_ASG_GRE_RUN number,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    CHILD_SUPP_COUNT_ASG_GRE_RUN number,
    CHILD_SUPP_TOT_DED_ASG_GRE_RUN IN OUT NOCOPY number,
    CHILD_SUPP_TOT_FEE_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_ITD number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    GARN_FEE_TAKE_FEE_ON_PRORATION varchar2,
    ARREARS_AMT IN OUT NOCOPY number,
    DIFF_DEDN_AMT IN OUT NOCOPY number,
    DIFF_FEE_AMT IN OUT NOCOPY number,
    NOT_TAKEN IN OUT NOCOPY number,
    SF_ACCRUED_FEES IN OUT NOCOPY number,
    STOP_ENTRY IN OUT NOCOPY varchar2,
    TO_COUNT IN OUT NOCOPY number,
    TO_TOTAL_OWED IN OUT NOCOPY number,
    WH_DEDN_AMT IN OUT NOCOPY number,
    WH_FEE_AMT IN OUT NOCOPY number,
    FATAL_MESG IN OUT NOCOPY varchar2,
    MESG  IN OUT NOCOPY varchar2,
    CALC_SUBPRIO OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    TO_ADDL OUT NOCOPY number,
    EIC_ADVANCE_ASG_GRE_RUN number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN            number  default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN           number  default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN        number  default 0

) RETURN number;

  /****************************************************************************
    Name        : CAL_FORMULA_BO
    Description : This function calculates amount to be withheld for BO, CD, G,
                  EL and ER categories.
  *****************************************************************************/

FUNCTION CAL_FORMULA_BO
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    GARN_EXEMPTION_CALC_RULE varchar2,
    GRN_EXMPT_DEP_CALC_RULE varchar2,
    GARN_EXEMPTION_DI_PCT number,
    GARN_EXEMPTION_MIN_WAGE_FACTOR number,
    GARN_EXEMPTION_AMOUNT_VALUE number,
    GRN_EXMPT_DEP_AMT_VAL number,
    GRN_EXMPT_ADDL_DEP_AMT_VAL number,
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_TAKE_FEE_ON_PRORATION varchar2,
    GARN_FEE_PCT_CURRENT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    STATE_MIN_WAGE number,
    ASG_FREQ varchar2,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    GARN_TOTAL_DEDNS_ASG_GRE_RUN number,
    GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN number,
    GROSS_EARNINGS_ASG_GRE_MONTH number,
    GROSS_EARNINGS_ASG_GRE_RUN number,
    REGULAR_EARNINGS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    TAX_LEVIES_ASG_GRE_RUN number,
    GRN_DI_SUBJ_TX_ASG_GRE_RUN number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN number,
    PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN number,
    PR_TX_DED_SBJ_TX_ASG_GRE_RN number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    JURISDICTION varchar2,
    TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    ACCRUED_FEES number,
    PTD_FEE_BALANCE number,
    MONTH_FEE_BALANCE number,
    GARN_EXEMPTION_PRORATION_RULE varchar2,
    CALCD_ARREARS OUT NOCOPY number,
    CALCD_DEDN_AMT OUT NOCOPY number,
    CALCD_FEE OUT NOCOPY number,
    FATAL_MESG OUT NOCOPY varchar2,
    GARN_FEE OUT NOCOPY number,
    MESG OUT NOCOPY varchar2,
    MESG1 OUT NOCOPY varchar2,
    NOT_TAKEN OUT NOCOPY number,
    SF_ACCRUED_FEES OUT NOCOPY number,
    STOP_ENTRY OUT NOCOPY varchar2,
    TO_ADDL OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    TO_TOTAL_OWED OUT NOCOPY number,
    calc_subprio OUT NOCOPY number,
    DCIA_DI_SUBJ_TX_ASG_GRE_RUN number default 0,
    DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN number default 0,
    PR_TX_DCIA_SB_TX_ASG_GRE_RN number default 0,
    PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN number default 0,
    EIC_ADVANCE_ASG_GRE_RUN number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN       number default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN      number default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN   number default 0,
    NET_ASG_RUN                     number  default 0,
    NET_ASG_PTD                     number  default 0

) RETURN number;

  /****************************************************************************
    Name        : CAL_FORMULA_TL
    Description : This function calculates amount to be withheld for TL
                  category.
  *****************************************************************************/
FUNCTION CAL_FORMULA_TL
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    ASG_FREQ varchar2,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    GROSS_EARNINGS_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    NET_ASG_RUN number,
     TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    TAX_LEVIES_ASG_GRE_PTD number,
    CALCD_DEDN_AMT OUT NOCOPY number,
    NOT_TAKEN OUT NOCOPY number,
    TO_ARREARS OUT NOCOPY number,
    TO_TOTAL_OWED OUT NOCOPY number,
    TO_ADDL OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    FATAL_MESG OUT NOCOPY varchar2,
    MESG OUT NOCOPY varchar2,
    CALC_SUBPRIO OUT NOCOPY number,
    STOP_ENTRY OUT NOCOPY varchar2,
    EIC_ADVANCE_ASG_GRE_RUN number default 0
) RETURN number;


  /****************************************************************************
    Name        : ENTRY_SUBPRIORITY
    Description : This function return sub-priority of specified
                  element_entry_id.
  *****************************************************************************/

FUNCTION ENTRY_SUBPRIORITY RETURN number;


  /****************************************************************************
    Name        : CONVERT_PERIOD_TYPE
    Description : This function converts amount according to the time units
                  specified.
  *****************************************************************************/

FUNCTION CONVERT_PERIOD_TYPE
(
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    FED_CRITERIA_PCT_PRD_DI_XMPT number,
    P_FROM_FREQ varchar2,
    P_TO_FREQ varchar2,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    P_ASST_STD_FREQ varchar2
)
RETURN number;

  /****************************************************************************
    Name        : FNC_FEE_CALCULATION
    Description : This function calculates fees amount for different categories
                  of involuntary deductions.
  *****************************************************************************/

FUNCTION FNC_FEE_CALCULATION
(
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_PCT_CURRENT number,
    TOTAL_OWED number,
    PRIMARY_AMOUNT_BALANCE number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PTD_FEE_BALANCE number,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    DEDN_AMT number,
    MONTH_FEE_BALANCE number,
    ACCRUED_FEES number
)
RETURN number;

  /****************************************************************************
    Name        : GET_GARN_LIMIT_MAX_DURATION
    Description : This function returns the maximum duration, in
                  number of days, for which a particular garnishment can be
                  taken in a particular state. The duration is obtained with
                  respect to the 'Date Served' of the garnishment.
  *****************************************************************************/

FUNCTION GET_GARN_LIMIT_MAX_DURATION(PAY_EARNED_START_DATE DATE) RETURN number;

  /****************************************************************************
    Name        : GET_GEOCODE
    Description : This function returns the geocode corresponding to inputs
                  specified.
  *****************************************************************************/


FUNCTION GET_GEOCODE
(
OVERRIDE_ADR_REGION_2 varchar2,
OVERRIDE_ADR_REGION_1 varchar2,
OVERRIDE_ADR_CITY varchar2,
OVERRIDE_ADR_POSTAL_CODE varchar2
) RETURN varchar2;

  /****************************************************************************
    Name        : GARN_CAT
    Description : This function returns garnishment category of the specified
                  element_entry_id.
  *****************************************************************************/

FUNCTION GARN_CAT RETURN varchar2;

  /****************************************************************************
    Name        : GET_TABLE_VALUE
    Description : This function returns the value stored by specified column in
                  the specified table.
  *****************************************************************************/


FUNCTION GET_TABLE_VALUE
(
C_FED_LEVY_EXEMPTION_TABLE varchar2,
C_FED_LEVY_XMPT_TAB_COL varchar2,
FILING_STATUS varchar2,
FILING_STATUS_YEAR date
) RETURN pay_user_column_instances_f.value%TYPE;

  /****************************************************************************
    Name        : GET_CCPA_PROTECTION
    Description : This function returns CCPA Protectiosn value which is then
                  serves as an upper limit of amount that can be deducted.
  *****************************************************************************/


FUNCTION GET_CCPA_PROTECTION
(
TOTAL_DI number,
OTHERS_DI number,
SUPPORT_DI number,
CCPA_PROT_PERC number
) RETURN number;


  /****************************************************************************
    Name        : RESET_GLOBAL_VAR
    Description : This procedure deletes all Global tables created and
                  resets the value of other Global variables.
  *****************************************************************************/

  PROCEDURE RESET_GLOBAL_VAR;


/*------------- CONTEXT DEFINITIONS -----------*/
CTX_BUSINESS_GROUP_ID number;
CTX_PAYROLL_ID number;
CTX_ELEMENT_TYPE_ID number;
CTX_ORIGINAL_ENTRY_ID number;
CTX_DATE_EARNED date;
CTX_JURISDICTION_CODE varchar2(20);
CTX_ELEMENT_ENTRY_ID number;
/*---------------------------------------------*/

l_package_name varchar2(50);

type dedn_tab_type is table of number index by binary_integer;
type varchar2_tab is table of varchar2(10) index by binary_integer;
type date_tab is table of date index by binary_integer;
type bool_tab_type is table of boolean index by binary_integer;

dedn_tab dedn_tab_type;
gar_dedn_tab dedn_tab_type;
fees_tab dedn_tab_type;
arrears_tab dedn_tab_type; /* Bug 2992741 */
actual_dedn_tab dedn_tab_type;
mod_dedn_tab  dedn_tab_type ; /* Bug# 5295813 */

GLB_TOT_WHLD_SUPP_ASG_GRE_RUN number;
GLB_TOT_WHLD_ARR_ASG_GRE_RUN number;
GLB_ALLOW_MULT_DEDN boolean;
GLB_NUM_ELEM number;
GLB_SUPPORT_DI number;
GLB_OTHER_DI_FLAG boolean;
GLB_DCIA_EXIST_FLAG boolean;
GLB_TL_GROSS_EARNINGS number;
GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN number;

/*------ GLOBAL VARIABLES AS REPLACEMENT OF CALCULATOR INPUT VALUES ----*/
GLB_FEES_ASG_GRE_PTD dedn_tab_type;
GLB_BASE_ASG_GRE_PTD dedn_tab_type;
GLB_AMT dedn_tab_type;
GLB_ARREARS_OVERRIDE dedn_tab_type;
GLB_ARREARS_DATE date_tab;
GLB_NUM_DEPS dedn_tab_type;
GLB_FIL_STAT varchar2_tab;
GLB_ALLOWS dedn_tab_type;
GLB_DEDN_OVERRIDE dedn_tab_type;
GLB_PCT dedn_tab_type;
GLB_MTD_BAL dedn_tab_type;
GLB_EXEMPT_AMT dedn_tab_type;
GLB_PTD_CAP_AMT dedn_tab_type;
GLB_PTD_BAL dedn_tab_type;
GLB_TO_ACCRUED_FEES dedn_tab_type;
GLB_MONTH_CAP_AMT dedn_tab_type;
GLB_AMT_NOT_SPEC bool_tab_type;
/*----------------------------------------------------------------------*/


END;


/
