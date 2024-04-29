--------------------------------------------------------
--  DDL for Package PAY_MX_TAX_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_TAX_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pymxtxfn.pkh 120.12.12010000.4 2009/01/27 11:35:28 sjawid ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
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

    Name        : pay_mx_tax_functions

    Description : This package contains various formula function definitions
                  for Mexican tax calculation.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-SEP-2004 sdahiya    115.0            Created.
    29-OCT-2004 sdahiya    115.1            Modified definition of function
                                            get_isr_partial_subj_earnings.
    09-NOV-2004 sdahiya    115.2            Added GET_SS_QUOTA_INFO
                                            function
    21-FEB-2005 sdahiya    115.3            Renamed
                                            get_isr_partial_subj_earnings
                                            to get_partial_subj_earnings.
    10-MAR-2005 sdahiya    115.4            Renamed GET_SS_QUOTA_INFO to
                                            GET_MX_TAX_INFO.
    12-MAR-2005 ardsouza   115.5            Added GET_MX_EE_HEAD_COUNT and
                                            GET_MX_STATE_TAX_RULES
                                            functions.
    18-APR-2005 sdahiya    115.6            Modified
                                            GET_PARTIAL_SUBJ_EARNINGS to
                                            accept P_CTX_ELEMENT_TYPE_ID
                                            as a parameter.
    27-JUN-2005 ardsouza   115.7   4387751  Added 2 overloaded versions of
                                            GET_PARTIAL_SUBJ_EARNINGS -
                                            one that accepts YTD earnings
                                            and one both. Added
                                            GET_SUBJ_EARNINGS_FOR_PERIOD,
                                            which accepts PTD earnings.
   06-Dec-2005  vpandya    115.8            Added following functions:
                                             - CALCULATE_ISR_TAX
   10-Jan-2006  vpandya    115.9            Added following functions:
                                             - CONVERT_INTO_MONTHLY_SALARY
   29-Mar-2006  ardsouza   115.10           Added g_temp_object_actions global
                                            variable.
   14-Jul-2006  sukukuma   115.11           Added following functions:
                                             - CHECK_EE_SAL_CRITERIA
                                             - CHECK_EE_EMPLOYMENT_CRITERIA
                                             - IS_ASG_EXEMPT_FROM_ISR
                                             - IS_PER_EXEMPT_FROM_ADJ
   14-Nov-2006  sdahiya    115.12           Added overloaded version of
                                            calculate_isr_tax to support subsidy
                                            calculation for Article 141.
   15-Oct-2007 srikared   115.13  6437992  Added New functions GET_MIN_WAGE,
					    GET_MX_ECON_ZONE
   12-Dec-2007 nragavar   115.15  6487007  Added new function
                                            CONVERT_MONTHLY_TO_PERIOD and
                                            CONVERT_INTO_MONTHLY_AVG_SAL
   30-Jan-2008 nragavar   115.18  6782264  Modified get_table_value function

   21-Feb-2008 sivanara   115.35  6821377  Adde new parameter p_hire_date
                                           to function CONVERT_INTO_MONTHLY_AVG_SAL
   04-Jun-2008 sivanara   115.36  6933775  Adde new parameter p_first_paid_date
                                           to function CONVERT_INTO_MONTHLY_AVG_SAL
  *****************************************************************************/

--****************************************************************************
-- Name        : GET_PARTIAL_SUBJ_EARNINGS
-- Description : This function calls another overloaded function, which returns
--               the portion of earnings that are partially subject to State
--               Tax and both fully and partially subject to ISR.
--               Both the YTD and PTD Earnings are defaulted to the
--               secondary classification earnings for the current run, which is
--               maintained in the PL-SQL table.
--****************************************************************************
FUNCTION GET_PARTIAL_SUBJ_EARNINGS
(
    P_CTX_EFFECTIVE_DATE        date,
    P_CTX_ASSIGNMENT_ACTION_ID  number,
    P_CTX_BUSINESS_GROUP_ID     number,
    P_CTX_JURISDICTION_CODE     varchar2,
    P_CTX_ELEMENT_TYPE_ID       number,
    P_TAX_TYPE                  varchar2,
    P_EARNINGS_AMT              number,
    P_GROSS_EARNINGS            number,
    P_DAILY_SALARY              number,
    P_CLASSIFICATION_NAME       varchar2
)RETURN NUMBER;


--****************************************************************************
-- Name        : GET_PARTIAL_SUBJ_EARNINGS
-- Description : This function calls another overloaded function, which returns
--               the portion of earnings that are partially subject to State
--               Tax and both fully and partially subject to ISR.
--               The PTD Earnings are defaulted to the secondary classification
--               earnings for the current run, which is maintained in the PL-SQL
--               table.
--****************************************************************************
FUNCTION GET_PARTIAL_SUBJ_EARNINGS
(
    P_CTX_EFFECTIVE_DATE        date,
    P_CTX_ASSIGNMENT_ACTION_ID  number,
    P_CTX_BUSINESS_GROUP_ID     number,
    P_CTX_JURISDICTION_CODE     varchar2,
    P_CTX_ELEMENT_TYPE_ID       number,
    P_TAX_TYPE                  varchar2,
    P_EARNINGS_AMT              number,
    P_YTD_EARNINGS_AMT          number,
    P_GROSS_EARNINGS            number,
    P_YTD_GROSS_EARNINGS        number,
    P_DAILY_SALARY              number,
    P_CLASSIFICATION_NAME       varchar2
)RETURN NUMBER;


--******************************************************************************
-- Name        : GET_SUBJ_EARNINGS_FOR_PERIOD
-- Description : This function calls another overloaded function, which returns
--               the portion of earnings that are partially subject to State
--               Tax and both fully and partially subject to ISR.
--               The YTD Earnings are defaulted to the secondary classification
--               earnings for the current run, which is maintained in the PL-SQL
--               table.
--******************************************************************************
FUNCTION GET_SUBJ_EARNINGS_FOR_PERIOD
(
    P_CTX_EFFECTIVE_DATE        date,
    P_CTX_ASSIGNMENT_ACTION_ID  number,
    P_CTX_BUSINESS_GROUP_ID     number,
    P_CTX_JURISDICTION_CODE     varchar2,
    P_CTX_ELEMENT_TYPE_ID       number,
    P_TAX_TYPE                  varchar2,
    P_EARNINGS_AMT              number,
    P_PTD_EARNINGS_AMT          number,
    P_GROSS_EARNINGS            number,
    P_YTD_GROSS_EARNINGS        number,
    P_DAILY_SALARY              number,
    P_CLASSIFICATION_NAME       varchar2
)RETURN NUMBER;


  /****************************************************************************
    Name        : GET_PARTIAL_SUBJ_EARNINGS
    Description : This function calculates subject earnings for classifications
                  that are fully and partially subject to ISR and state taxes.
  *****************************************************************************/
FUNCTION GET_PARTIAL_SUBJ_EARNINGS
(
    P_CTX_EFFECTIVE_DATE        date,
    P_CTX_ASSIGNMENT_ACTION_ID  number,
    P_CTX_BUSINESS_GROUP_ID     number,
    P_CTX_JURISDICTION_CODE     varchar2,
    P_CTX_ELEMENT_TYPE_ID       number,
    P_TAX_TYPE                  varchar2,
    P_EARNINGS_AMT              number,
    P_YTD_EARNINGS_AMT          number,
    P_PTD_EARNINGS_AMT          number,
    P_GROSS_EARNINGS            number,
    P_YTD_GROSS_EARNINGS        number,
    P_DAILY_SALARY              number,
    P_CLASSIFICATION_NAME       varchar2
)RETURN NUMBER;


  /****************************************************************************
    Name        : GET_PREVIOUS_PERIOD_BAL
    Description : This function returns balance values for pay period
                  immediately previous to the period in which passed
                  assignment_action_id lies.
  *****************************************************************************/

FUNCTION GET_PREVIOUS_PERIOD_BAL
(
    P_CTX_ASSIGNMENT_ID         number,
    P_CTX_ASSIGNMENT_ACTION_ID  number,
    P_MODE                      varchar2
) RETURN NUMBER;


  /****************************************************************************
    Name        : GET_MX_TAX_INFO
    Description : This function returns various parameters required for social
                  security quota and state tax calculation.
  *****************************************************************************/

FUNCTION GET_MX_TAX_INFO
(
    P_CTX_BUSINESS_GROUP_ID     number,
    P_CTX_TAX_UNIT_ID           number,
    P_CTX_EFFECTIVE_DATE        date,
    P_CTX_JURISDICTION_CODE     varchar2,
    P_LEGISLATION_INFO_TYPE     varchar2,
    P_LEGISLATION_INFO1      in out nocopy varchar2,
    P_LEGISLATION_INFO2         out nocopy varchar2,
    P_LEGISLATION_INFO3         out nocopy varchar2,
    P_LEGISLATION_INFO4         out nocopy varchar2,
    P_LEGISLATION_INFO5         out nocopy varchar2,
    P_LEGISLATION_INFO6         out nocopy varchar2
) RETURN NUMBER;


  /****************************************************************************
    Name        : GET_MX_EE_HEAD_COUNT
    Description : This function returns the Employee Headcount used for
                  Employer State Tax rate computation.
  *****************************************************************************/
FUNCTION GET_MX_EE_HEAD_COUNT
(
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_TAX_UNIT_ID           NUMBER,
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_JURISDICTION_CODE     VARCHAR2
) RETURN NUMBER;

  /****************************************************************************
    Name        : GET_MX_STATE_TAX_RULES
    Description : This function returns the data stored at legal Employer level
                  under "State Tax Rules" Org Info type.
  *****************************************************************************/

FUNCTION GET_MX_STATE_TAX_RULES
(
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_TAX_UNIT_ID           NUMBER,
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_JURISDICTION_CODE     VARCHAR2
) RETURN VARCHAR2;

  /****************************************************************************
    Name        : CALCULATE_ISR_TAX
    Description : This function has
                  1. Input Parameters as Contexts:
                     - BUSINESS_GROUP_ID
                     - ASSIGNMENT_ID
                     - TAX_UNIT_ID
                     - DATE_EARNED
                  2. Input Parameters as Parameter:
                     - SUBJECT_AMOUNT
                     - ISR_RATES_TABLE
                     - SUBSIDY_TABLE
                     - CREDIT_TO_SALARY_TABLE
                  3. Returns following data for give subject amount:
                     - ISR_WITHHELD (Return Value)
                     - ISR_CALCULATED (Output Parameter)
                     - ISR_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_NON_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY_PAID (Output Parameter)
  *****************************************************************************/

  FUNCTION CALCULATE_ISR_TAX (
                     P_PAYROLL_ACTION_ID          NUMBER
                    ,P_ASSIGNMENT_ACTION_ID       NUMBER
                    ,p_business_group_id          NUMBER
                    ,p_assignment_id              NUMBER
                    ,p_tax_unit_id                NUMBER
                    ,p_date_earned                DATE
                    ,p_subject_amount             NUMBER
                    ,p_isr_rates_table            VARCHAR2
                    ,p_subsidy_table              VARCHAR2
                    ,p_credit_to_salary_table     VARCHAR2
                    ,p_isr_calculated             OUT NOCOPY NUMBER
                    ,p_isr_creditable_subsidy     OUT NOCOPY NUMBER
                    ,p_isr_non_creditable_subsidy OUT NOCOPY NUMBER
                    ,p_credit_to_salary           OUT NOCOPY NUMBER
                    ,p_credit_to_salary_paid      OUT NOCOPY NUMBER)
  RETURN NUMBER;

  /****************************************************************************
    Name        : CALCULATE_ISR_TAX
    Description : This function has
                  1. Input Parameters as Contexts:
                     - PAYROLL_ACTION_ID
                     - ASSIGNMENT_ACTION_ID
                     - BUSINESS_GROUP_ID
                     - ASSIGNMENT_ID
                     - TAX_UNIT_ID
                     - DATE_EARNED
                  2. Input Parameters as Parameter:
                     - SUBJECT_AMOUNT
                     - ISR_RATES_TABLE
                     - SUBSIDY_TABLE
                     - CREDIT_TO_SALARY_TABLE
                  3. Returns following data for give subject amount:
                     - ISR_WITHHELD (Return Value)
                     - ISR_CALCULATED (Output Parameter)
                     - ISR_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_NON_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY_PAID (Output Parameter)
  *****************************************************************************/

FUNCTION CALCULATE_ISR_TAX
(
    P_PAYROLL_ACTION_ID          NUMBER,
    P_ASSIGNMENT_ACTION_ID       NUMBER,
    P_BUSINESS_GROUP_ID          NUMBER,
    P_ASSIGNMENT_ID              NUMBER,
    P_TAX_UNIT_ID                NUMBER,
    P_DATE_EARNED                DATE,
    P_CALC_MODE                  VARCHAR2,
    P_SUBJECT_AMOUNT             NUMBER,
    P_ISR_RATES_TABLE            VARCHAR2,
    P_SUBSIDY_TABLE              VARCHAR2,
    P_CREDIT_TO_SALARY_TABLE     VARCHAR2,
    P_ISR_CALCULATED             OUT NOCOPY NUMBER,
    P_ISR_CREDITABLE_SUBSIDY     OUT NOCOPY NUMBER,
    P_ISR_NON_CREDITABLE_SUBSIDY OUT NOCOPY NUMBER,
    P_CREDIT_TO_SALARY           OUT NOCOPY NUMBER,
    P_CREDIT_TO_SALARY_PAID      OUT NOCOPY NUMBER
)
RETURN NUMBER;

  /****************************************************************************
    Name        : CALCULATE_ISR_TAX
    Description : This function has
                  1. Input Parameters as Contexts:
                     - PAYROLL_ACTION_ID
                     - ASSIGNMENT_ACTION_ID
                     - BUSINESS_GROUP_ID
                     - ASSIGNMENT_ID
                     - TAX_UNIT_ID
                     - DATE_EARNED
                  2. Input Parameters as Parameter:
                     - RUN TYPE
                     - CALCULATION MODE
                     - SUBJECT_AMOUNT
                     - ISR_RATES_TABLE
                     - SUBSIDY_TABLE
                     - CREDIT_TO_SALARY_TABLE
                  3. Returns following data for give subject amount:
                     - ISR_WITHHELD (Return Value)
                     - ISR_CALCULATED (Output Parameter)
                     - ISR_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_NON_CREDITABLE_SUBSIDY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY (Output Parameter)
                     - ISR_CREDIT_TO_SALARY_PAID (Output Parameter)
  *****************************************************************************/

FUNCTION CALCULATE_ISR_TAX
(
    P_PAYROLL_ACTION_ID          NUMBER,
    P_ASSIGNMENT_ACTION_ID       NUMBER,
    P_BUSINESS_GROUP_ID          NUMBER,
    P_ASSIGNMENT_ID              NUMBER,
    P_TAX_UNIT_ID                NUMBER,
    P_DATE_EARNED                DATE,
    P_RUN_TYPE                   VARCHAR2,
    P_CALC_MODE                  VARCHAR2,
    P_SUBJECT_AMOUNT             NUMBER,
    P_ISR_RATES_TABLE            VARCHAR2,
    P_SUBSIDY_TABLE              VARCHAR2,
    P_CREDIT_TO_SALARY_TABLE     VARCHAR2,
    P_ISR_CALCULATED             OUT NOCOPY NUMBER,
    P_ISR_CREDITABLE_SUBSIDY     OUT NOCOPY NUMBER,
    P_ISR_NON_CREDITABLE_SUBSIDY OUT NOCOPY NUMBER,
    P_CREDIT_TO_SALARY           OUT NOCOPY NUMBER,
    P_CREDIT_TO_SALARY_PAID      OUT NOCOPY NUMBER
)
RETURN NUMBER;

  /****************************************************************************
    Name        : CONVERT_INTO_MONTHLY_SALARY
    Description : This function has
                  1. Input Parameters as Contexts:
                     - BUSINESS_GROUP_ID
                     - TAX_UNIT_ID
                     - PAYROLL_ID
                  2. Input Parameters as Parameter:
                     - PERIODIC_EARNINGS
  *****************************************************************************/

  FUNCTION CONVERT_INTO_MONTHLY_SALARY ( p_business_group_id   NUMBER
                                        ,p_tax_unit_id         NUMBER
                                        ,p_payroll_id          NUMBER
                                        ,p_periodic_earnings   NUMBER)
  RETURN NUMBER;


  /****************************************************************************
    Name        : CHECK_EE_SAL_CRITERIA
    Description : This function returns 'Y' if employee's  annual gross earning
                  is less than 300,000 MXN.
  *****************************************************************************/

FUNCTION CHECK_EE_SAL_CRITERIA(P_CTX_ASSIGNMENT_ID         NUMBER
                              ,P_CTX_DATE_EARNED           DATE)
RETURN VARCHAR2;


  /****************************************************************************
    Name        : CHECK_EE_EMPLOYMENT_CRITERIA
    Description : This Function return 'Y' if employee is working continously
                  between the given start date and end date
  *****************************************************************************/

FUNCTION CHECK_EE_EMPLOYMENT_CRITERIA(P_CTX_ASSIGNMENT_ID         NUMBER
                                     ,P_CTX_DATE_EARNED           DATE)
RETURN VARCHAR2;


  /****************************************************************************
    Name        : IS_ASG_EXEMPT_FROM_ISR
    Description : This function returns Y if an assignment is exempted from ISR
                  calculation
  *****************************************************************************/

FUNCTION IS_ASG_EXEMPT_FROM_ISR(P_CTX_ASSIGNMENT_ID         NUMBER
                               ,P_CTX_DATE_EARNED           DATE)
RETURN VARCHAR2;


  /****************************************************************************
    Name        : IS_PER_EXEMPT_FROM_ADJ
    Description : This function returns Y if an assignment is exempted from Tax
                  Adjustment
  *****************************************************************************/

FUNCTION IS_PER_EXEMPT_FROM_ADJ(P_CTX_ASSIGNMENT_ID         NUMBER
                                ,P_CTX_DATE_EARNED           DATE)
RETURN VARCHAR2;


  /****************************************************************************
    Name        : GET_MX_ECON_ZONE
    Description : This function returns Economy Zone('A', 'B', 'C') for the
		  given tax_unit_id
  *****************************************************************************/

FUNCTION GET_MX_ECON_ZONE
(
    P_CTX_TAX_UNIT_ID           number,
    P_CTX_DATE_EARNED		DATE
) RETURN varchar2;

  /****************************************************************************
    Name        : GET_MIN_WAGE
    Description : This function returns Minimum Wage for the Economy Zone
  *****************************************************************************/

FUNCTION GET_MIN_WAGE
(
    P_CTX_DATE_EARNED		DATE,
    P_TAX_BASIS			varchar2,
    P_ECON_ZONE			varchar2

) RETURN varchar2;


  g_temp_object_actions  BOOLEAN;

  /****************************************************************************
    Name        : CONVERT_MONTHLY_TO_PERIOD
    Description : This function returns monthly isr table value converted to
                  pay period actual number of days value.
  *****************************************************************************/


/*FUNCTION CONVERT_MONTHLY_TO_PERIOD ( p_business_group_id   NUMBER
                                    ,p_tax_unit_id         NUMBER
                                    ,p_payroll_id          NUMBER
                                    ,p_periodic_value      NUMBER
                                    ,p_date_earned         DATE)
RETURN NUMBER; */

  /****************************************************************************
    Name        : CONVERT_INTO_MONTHLY_AVG_SAL
    Description : This function returns period isr subject value converted to
                  monthly subject.
  *****************************************************************************/

FUNCTION CONVERT_INTO_MONTHLY_AVG_SAL ( p_business_group_id   NUMBER
                                       ,p_tax_unit_id         NUMBER
                                       ,p_payroll_id          NUMBER
                                       ,p_subject_earnings    NUMBER
                                       ,P_DATE_EARNED         DATE
				       ,p_hire_date           DATE
				       ,p_first_pay_date      DATE
                                       ,p_period_days         out NOCOPY NUMBER)
RETURN NUMBER;

function get_table_value (p_bus_group_id      number,
                          p_table_name        varchar2,
                          p_col_name          varchar2,
                          p_row_value         varchar2,
                          p_effective_date    date  default null,
                          p_period_days       number,
                          p_period_number     number,
                          p_period_type       varchar2)
return varchar2;

END;


/
