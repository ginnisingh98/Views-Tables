--------------------------------------------------------
--  DDL for Package Body PAY_MX_TAX_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_TAX_FUNCTIONS" as
/* $Header: pymxtxfn.pkb 120.26.12010000.27 2009/11/01 16:52:26 sjawid ship $ */
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
    ----------- ---------  ------  -------  -------------------------------
    23-SEP-2004 sdahiya    115.0            Created.
    29-OCT-2004 sdahiya    115.1            Extended support for partially
                                            subject earnings.
    09-NOV-2004 sdahiya    115.2            Added GET_SS_QUOTA_INFO function
    21-JAN-2005 ardsouza   115.3   4129001  hr_mx_utility.get_gre_from_location
                                            call modified to pass BG.
    21-FEB-2005 sdahiya    115.4            - Modified get_previous_period_bal
                                              to fetch values for any defined
                                              balance passed.
                                            - Renamed
                                              get_isr_partial_subj_earnings to
                                              get_partial_subj_earnings and
                                              modified it to fetch subject wages
                                              for state tax in addition to ISR.
    02-MAR-2005 sdahiya    115.5            Fixed GSCC warning.
    10-MAR-2005 sdahiya    115.6            Renamed GET_SS_QUOTA_INFO to
                                            GET_MX_TAX_INFO.
    12-MAR-2005 ardsouza   115.7            Added GET_MX_EE_HEAD_COUNT and
                                            GET_MX_STATE_TAX_RULES functions.
    18-APR-2005 sdahiya    115.8            Modified GET_PARTIAL_SUBJ_EARNINGS
                                            to accept P_CTX_ELEMENT_TYPE_ID as a
                                            parameter.

                                   4283490  Modified function
                                            GET_PREVIOUS_PERIOD_BAL so that it
                                            returns zero if there is no payroll
                                            action in previous period.
    26-APR-2005 sdahiya    115.7            Created global cache g_isr_balances.
    27-JUN-2005 ardsouza   115.10  4387751  Added 2 overloaded versions of
                                            GET_PARTIAL_SUBJ_EARNINGS - one that
                                            accepts YTD earnings and one both.
                                            Added GET_SUBJ_EARNINGS_FOR_PERIOD,
                                            which accepts PTD earnings.
    26-JUL-2005 ardsouza   115.11  4510115  Handled NO_DATA_FOUND exception if
                                            cache is empty, while defaulting.
    25-OCT-2005 sdahiya    115.12  4656174  Work risk insurance premium should
                                            be fetched from database even
                                            if it is already cached.
    06-DEC-2005 vpandya    115.13           Added following functions:
                                             - CALCULATE_ISR_TAX
    06-JAN-2006 vpandya    115.14           Using get_seniority function for
                                            tax calculation for Amends. Also
                                            added convert_into_monthly_salary.
    13-JAN-2006 ardsouza   115.15  4950628  Corrected Amends exempt amount
                                            calculation.
    29-MAR-2006 ardsouza   115.16           Modified to handle cases where
                                            P_CTX_ASSIGNMENT_ACTION_ID is a
                                            temporary action.
    03-Jul-2006 vpandya    115.17  5360802  Modified CALCULATE_ISR_TAX,
                                            added condition p_credit_to_salary
                                            is zero when Tax Adjustment is run.
    14-Jul-2006 sukukuma   115.18           Added following functions:
                                             - CHECK_EE_SAL_CRITERIA
                                             - CHECK_EE_EMPLOYMENT_CRITERIA
                                             - IS_ASG_EXEMPT_FROM_ISR
                                             - IS_PER_EXEMPT_FROM_ADJ
    20-Jul-2006 sukukuma   115.19           Modified following functions:
                                             - CHECK_EE_SAL_CRITERIA
    14-Nov-2006 sdahiya    115.20           Added overloaded version of
                                            calculate_isr_tax to support subsidy
                                            calculation for Article 141.
    12-Jan-2007 sdahiya    115.21  5757873  Adjustment start and end dates
                                            should be fetched from legal
                                            employer instead of GRE.
    12-Jan-2007 vpandya    115.22  5757873  Changed CHECK_EE_EMPLOYMENT_CRITERIA
                                            getting latest hire date.
    15-Jan-2007 vpandya    115.23  5762654  Changed CHECK_EE_EMPLOYMENT_CRITERIA
                                            getting actual_termination_date and
                                            returning N if it is less then
                                            adjustment end date.
    15-Oct-2007 srikared   115.24  6437992  Added New functions GET_MIN_WAGE,
					                        GET_MX_ECON_ZONE

    25-Oct-2007 vmehta     115.27  6519803  Delete table for balances in
                                            GET_PARTIAL_SUBJ_EARNINGS before
                                            calculating taxes other than ISR
    21-Nov-2007 prechand   115.28  6606767  Changed the function to_number
                                            in the function CALCULATE_ISR_TAX to
					    Fnd_Number.Canonical_to_number
    12-Dec-2007 nragavar   115.29  6487007  ISR 2008 changes
    29-Jan-2008 nragavar   115.33  6779706  Subsidy for Empl paid was getting added
                                            where, not required.
    30-Jan-2008 nragavar   115.34  6782264  changes to get_table_value
    21-Feb-2008 sivanara   115.35  6821377  Changes made to calculte_ISR_TAX to
                                            considered if emp is hired in mid of
					    pay period. Also changes to function
					    CONVERT_INTO_MONTHLY_AVG_SAL
    24-Mar-2008 sivanara   115.36  6852627  Included ISR proration logic
    03-Apr-2008 sivanara   115.38  6926777  Included error message
                                            PAY_MX_INVALID_ISR_NON_WRK_DAY for
					    ISR proration.
    05-May-2008 sivanara   115.39  7027010  Incldued logic for ISR Subject proration
    06-May-2008 sivanara   115.40  7116850  Revert the proration logic as we get
                                            the prorated subject amount for p_subject_amount.
				   6933775  Included logic for projection of prorated
					    ISR subject amount
                                            Added code in procedure CALCULATE_ISR_TAX
					    to consider the first paid period to the
					    employee
    13-Jun-2008 nragavar   115.42  7047220  7047357- leapfroged from 115.40 to 115.42.
                                            this includes changes in 115.41. changes
                                            to cursor csr_get_min_wage.
    03-Jul-2008 sivanara   115.43  7208623  leapfroged again 115.36 to115.43.
                                            For this version the package header
					    version is pymxtxfn.pkh 115.19.
					    This version does not include any
					    part of isr proration fixes.
                                            Version 115.42 to 115.44(whih has
					    ISR proration fix) arcsed
					    on top of this will be done.
    03-Jul-2008 sivanara   115.44           leapfroged from Version 115.42 to 115.44
                                            which has the ISR proration fix that was
					    included in version 115.43
    15-jul-2008 sivanara   115.45  7260970  For ISR Proration added logic to consider the
                                            day factor for calculating the total subject
					    amount from the given prorated amount.
			   115.46  7242481  ISR proration should be considered only for
			                    ARTICLE 113 calculation method.
    04-Aug-2008 nragavar   115.47  7042174  Done changes as part of 10 day payroll frequency.
    04-Aug-2008 sjawid     115.50  7445486  No need to calculate 'credit to salary
                                            for ISR Tax calculation as per Article142.
    02-Dec-2008 sivanara   115.51  7602236  Added logic to CHECK_EE_EMPLOYMENT_CRITERIA
                                   7604298  to consider test case for RE-HIREed employee
				            in the next day immediately after termination.
    02-Dec-2008 sjawid     115.53  7677805  Fixed the issue of incorrect isr tax on weekly
                                            payroll. Modified Subsidy calculation logic.
    27-Jan-2009 vvijayku   115.54  6785206  Periodic tax adjustment changes
                                            added new overloaded funtion isr_tax_calculation
    20-Feb-2009 vvijayku   115.55  8271515  Changed the code so that the Non Working days is
                                            considered correctly while doing Tax Adjustment.
    25-Feb-2009 vvijayku   115.56  8286044  Changed the balance dimensions for the Balances
                                            called for Tax Adjustment from ASG_GRE_YTD/MTD to
					    PER_YTD/MTD.
				   8283620  Modified the ISR Subject balance call for Tax
				            Adjustment
    26-Feb-2009 vvijayku   115.57  8286044  Added a new cursor to take the first hire date of
                                            the employee so that the number of worked days is
					    calculated correctly.
    30-Apr-2009 vvijayku   15.58   8291738  Changed the balance calls from PER_YTD AND PER_MTD
                                            to ASG_MTD and ASG_YTD respectively for the Tax
					    Adjustment process and ASG_GRE_MTD to ASG_MTD for
					    subsidy calculation.
    27-Oct-2009 sjawid     15.59   8438155  Added new cursor csr_get_compute_subsidy_flag in
                                            function CALCULATE_ISR_TAX and added logic to
					    skip the subsidy for employment calculation when
					    user has a value 'No' in 'Compute Subsidy for Employment'
					    at 'MX Statutory Info' in assignment screen.
    27-Oct-2009 sjawid     15.60   8438155  Added nvl function to the cursor
				            csr_get_compute_subsidy_flag in function
					    CALCULATE_ISR_TAX.
    29-Oct-2009 sjawid     15.61   8438155  Multiple style comments found on one line
                                            are removed to remove check_patch errors.
    01-Nov-2009 sjawid     15.62   8932102  The cursor csr_get_payroll_id in Calculate_isr_tax function
                                            has been modified to fetch only payroll_id and
					    removed hire_date reference and a new cursor
					    csr_get_hire_date has been added to fetch hire date.
  *****************************************************************************/

TYPE g_leg_record IS RECORD (
    effective_start_date   pay_mx_legislation_info_f.effective_start_date%TYPE,
    effective_end_date     pay_mx_legislation_info_f.effective_end_date%TYPE,
    jurisdiction_code      pay_mx_legislation_info_f.jurisdiction_code%TYPE,
    legislation_info_type  pay_mx_legislation_info_f.legislation_info_type%TYPE,
    legislation_info1      pay_mx_legislation_info_f.legislation_info1%TYPE,
    legislation_info2      pay_mx_legislation_info_f.legislation_info2%TYPE,
    legislation_info3      pay_mx_legislation_info_f.legislation_info3%TYPE,
    legislation_info4      pay_mx_legislation_info_f.legislation_info4%TYPE,
    legislation_info5      pay_mx_legislation_info_f.legislation_info5%TYPE,
    legislation_info6      pay_mx_legislation_info_f.legislation_info6%TYPE);

TYPE g_isr_balances_rec IS RECORD (
    assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE,
    earnings_amt           NUMBER,
    exempt_amt             NUMBER);

TYPE g_leg_table IS TABLE OF g_leg_record INDEX BY BINARY_INTEGER;
TYPE g_isr_balances_table IS TABLE OF g_isr_balances_rec INDEX BY BINARY_INTEGER;

g_proc_name                 VARCHAR2(50);
g_debug                     BOOLEAN;
g_isr_balances              g_isr_balances_table;
g_pay_mx_legislation_info_f g_leg_table;


  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This function prints debug messages during diagnostics mode.
  *****************************************************************************/

PROCEDURE HR_UTILITY_TRACE(trc_data varchar2) IS
BEGIN
    IF g_debug THEN
        hr_utility.trace(trc_data);
    END IF;
END HR_UTILITY_TRACE;


  /****************************************************************************
    Name        : GET_DEF_BAL_ID
    Description : Function to get the defined_balance_id from a DBI name.
  *****************************************************************************/

FUNCTION GET_DEF_BAL_ID
(
    P_ENTITY_NAME   VARCHAR2
) RETURN NUMBER AS
    l_defined_balance_id NUMBER;
    l_proc_name          VARCHAR2(100);
BEGIN
    l_proc_name := g_proc_name ||'GET_DEF_BAL_ID';
    hr_utility_trace('Entering '||l_proc_name);
    SELECT creator_id
      INTO l_defined_balance_id
      FROM ff_user_entities
     WHERE user_entity_name = p_entity_name
       AND legislation_code = 'MX'
       AND creator_type = 'B';

    RETURN (l_defined_balance_id);
END GET_DEF_BAL_ID;


  /****************************************************************************
    Name        : GET_RANGE_BASIS_VALUE
    Description : This function takes MW/GMW/SAL as parameter and returns the
                  numerical values associated.
  *****************************************************************************/
FUNCTION GET_RANGE_BASIS_VALUE
(
    P_RANGE_BASIS       VARCHAR2,
    P_DAILY_SALARY      NUMBER,
    P_ASACT_ID          NUMBER
) RETURN NUMBER AS

    CURSOR csr_get_asg_info IS
        SELECT paf.soft_coding_keyflex_id,
               paf.location_id,
               ppa.effective_date,
               paf.business_group_id
          FROM per_assignments_f      paf,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa
         WHERE paf.assignment_id        = paa.assignment_id
           AND paa.payroll_action_id    = ppa.payroll_action_id
           AND paa.assignment_action_id = p_asact_id
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

    CURSOR csr_get_asg_info_temp IS
        SELECT paf.soft_coding_keyflex_id,
               paf.location_id,
               ppa.effective_date,
               paf.business_group_id
          FROM per_assignments_f       paf,
               pay_temp_object_actions ptoa,
               pay_payroll_actions     ppa
         WHERE paf.assignment_id         = ptoa.object_id
           AND ptoa.payroll_action_id    = ppa.payroll_action_id
           AND ptoa.object_action_id     = p_asact_id
           AND ptoa.object_type          = 'ASG'
           AND ppa.effective_date  BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date;

    CURSOR csr_get_min_wage (p_gre_id NUMBER, p_effective_date DATE) IS
        SELECT fnd_number.canonical_to_number(plif.legislation_info2)
          FROM pay_mx_legislation_info_f plif,
               hr_organization_units hou,
               hr_organization_information hoi
         WHERE hou.organization_id = hoi.organization_id
           AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
           AND (DECODE (UPPER(p_range_basis),
                'MW', 'MW'||hoi.org_information7) = plif.legislation_info1 OR
               p_range_basis = plif.legislation_info1)
           AND hou.organization_id = p_gre_id
           AND plif.legislation_info_type = 'MX Minimum Wage Information'
           AND p_effective_date BETWEEN hou.date_from
                                    AND NVL(hou.date_to, hr_general.end_of_time)
           AND p_effective_date BETWEEN plif.effective_start_date
                                    AND plif.effective_end_date;

    l_min_wage          NUMBER;
    l_scl_id            NUMBER;
    l_gre_id            hr_organization_units.organization_id%type;
    l_location_id       hr_locations.location_id%type;
    l_business_group_id NUMBER;
    l_effective_date    DATE;
    l_is_ambiguous      BOOLEAN;
    l_missing_gre       BOOLEAN;
    l_proc_name         VARCHAR2(100);

BEGIN
    l_proc_name := g_proc_name ||'GET_RANGE_BASIS_VALUE';
    hr_utility_trace('Entering '||l_proc_name);

    IF p_range_basis = 'SAL' THEN

       RETURN (p_daily_salary);

    END IF;

    IF g_temp_object_actions THEN
        OPEN  csr_get_asg_info_temp;
        FETCH csr_get_asg_info_temp INTO l_scl_id,
                                         l_location_id,
                                         l_effective_date,
                                         l_business_group_id;
        CLOSE csr_get_asg_info_temp;

    ELSE
        OPEN  csr_get_asg_info;
        FETCH csr_get_asg_info INTO l_scl_id,
                                    l_location_id,
                                    l_effective_date,
                                    l_business_group_id;
        CLOSE csr_get_asg_info;

    END IF;

    l_gre_id := hr_mx_utility.get_gre_from_scl (l_scl_id);

    hr_utility_trace('GRE obtained from SCL = "'||l_gre_id||'"');

    IF l_gre_id is null THEN
        l_gre_id := hr_mx_utility.get_gre_from_location(
                                l_location_id,
                                l_business_group_id, -- Bug 4129001
                                l_effective_date,
                                l_is_ambiguous,
                                l_missing_gre);
        hr_utility_trace('GRE obtained from location = "'||l_gre_id||'"');
    END IF;
    /* Obtain (General) Minimum Wage */
    OPEN csr_get_min_wage (l_gre_id, l_effective_date);
        FETCH csr_get_min_wage INTO l_min_wage;
    CLOSE csr_get_min_wage;
    hr_utility_trace('(General) Minimum wage = '||l_min_wage);

    hr_utility_trace('Leaving '||l_proc_name);
    RETURN (l_min_wage);

END GET_RANGE_BASIS_VALUE;


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
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_ASSIGNMENT_ACTION_ID  NUMBER,
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_JURISDICTION_CODE     VARCHAR2,
    P_CTX_ELEMENT_TYPE_ID       NUMBER,
    P_TAX_TYPE                  VARCHAR2,
    P_EARNINGS_AMT              NUMBER,
    P_GROSS_EARNINGS            NUMBER,
    P_DAILY_SALARY              NUMBER,
    P_CLASSIFICATION_NAME       VARCHAR2
)RETURN NUMBER AS

    CURSOR get_ele_class IS
        SELECT pec1.classification_id,
               pec1.classification_name
          FROM pay_element_classifications pec,
               pay_element_classifications pec1, -- Secondary classification
               pay_element_types_f pet,
               pay_sub_classification_rules_f psr
         WHERE pet.classification_id = pec.classification_id
           AND pec.classification_id = pec1.parent_classification_id
           AND pet.element_type_id = psr.element_type_id
           AND psr.classification_id = pec1.classification_id
           AND p_ctx_effective_date BETWEEN pet.effective_start_date
                                        AND pet.effective_end_date
           AND p_ctx_effective_date BETWEEN psr.effective_start_date
                                        AND psr.effective_end_date
           AND pet.element_type_id = p_ctx_element_type_id
           AND pec.legislation_code = 'MX'
           AND pec.classification_name <> 'Employer Liabilities'
           AND pec.business_group_id IS NULL
           AND pec1.legislation_code = 'MX'
           AND pec1.business_group_id IS NULL
           AND p_tax_type = 'ISR'
        UNION
        SELECT pec.classification_id,
               pec.classification_name
          FROM pay_element_classifications pec
         WHERE UPPER(pec.classification_name) = UPPER(p_classification_name)
           AND pec.legislation_code = 'MX'
           AND pec.business_group_id IS NULL
           AND pec.parent_classification_id IS NOT NULL
           AND p_tax_type = 'STATE';

    l_calc_rule           pay_mx_earn_exemption_rules_f.calc_rule%TYPE;
    l_low_exempt_factor   pay_mx_earn_exemption_rules_f.low_exempt_factor%TYPE;
    l_low_range_factor    pay_mx_earn_exemption_rules_f.low_range_factor%TYPE;
    l_low_range_basis     pay_mx_earn_exemption_rules_f.low_range_basis%TYPE;
    l_high_exempt_factor  pay_mx_earn_exemption_rules_f.high_exempt_factor%TYPE;
    l_high_range_factor   pay_mx_earn_exemption_rules_f.high_range_factor%TYPE;
    l_high_range_basis    pay_mx_earn_exemption_rules_f.high_range_basis%TYPE;
    l_classification_name pay_element_classifications.classification_name%TYPE;
    l_classification_id   NUMBER;
    l_counter             NUMBER;
    l_proc_name           VARCHAR2(100);
    l_index               NUMBER;
    l_return_value        NUMBER;
    l_default_value       NUMBER;
    l_dummy               VARCHAR2(1);

BEGIN

    l_proc_name := g_proc_name ||'GET_PARTIAL_SUBJ_EARNINGS';
    hr_utility_trace('Entering '||l_proc_name);

    l_counter := 0;
    l_return_value := 0;

    IF p_earnings_amt > 0 THEN

        /* Perform exempt calculation only if earnings amount is greater
           than zero. */
        OPEN get_ele_class;
        LOOP
            FETCH get_ele_class INTO l_classification_id,
                                     l_classification_name;
            EXIT WHEN get_ele_class%NOTFOUND;

            hr_utility_trace('Element classification name is '
                                                      ||l_classification_name);

            IF l_classification_name LIKE '%:Subject to ISR' THEN
                RETURN (P_EARNINGS_AMT);
            END IF;

            IF g_isr_balances.count() > 0 THEN
               IF g_isr_balances(g_isr_balances.first()).assignment_action_id <>
                  p_ctx_assignment_action_id THEN
                      g_isr_balances.delete();
               END IF;
            END IF;

            l_counter := 0;

            BEGIN
                -- Query to check if the classification is partially subject.
                --
                SELECT ''
                  INTO l_dummy
                  FROM pay_mx_earn_exemption_rules_f pmex
                 WHERE pmex.tax_type = p_tax_type
                   AND DECODE(p_tax_type, 'ISR', p_ctx_jurisdiction_code,
                              pmex.state_code) = p_ctx_jurisdiction_code
                   AND pmex.element_classification_id = l_classification_id
                   AND p_ctx_effective_date BETWEEN pmex.effective_start_date
                                                AND pmex.effective_end_date;

                l_index := l_classification_id;

                IF l_classification_name IN
                ('Supplemental Earnings:Social Foresight Earnings',
                 'Imputed Earnings:Social Foresight Earnings') THEN
                    l_index := 0;
                END IF;

                BEGIN
                l_default_value := nvl(g_isr_balances(l_index).earnings_amt, 0)
                                   + P_EARNINGS_AMT;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_default_value := P_EARNINGS_AMT;
                END;

                l_return_value := get_partial_subj_earnings(
                       p_ctx_effective_date       => P_CTX_EFFECTIVE_DATE,
                       p_ctx_assignment_action_id => P_CTX_ASSIGNMENT_ACTION_ID,
                       p_ctx_business_group_id    => P_CTX_BUSINESS_GROUP_ID,
                       p_ctx_jurisdiction_code    => P_CTX_JURISDICTION_CODE,
                       p_ctx_element_type_id      => P_CTX_ELEMENT_TYPE_ID,
                       p_tax_type                 => P_TAX_TYPE,
                       p_earnings_amt             => P_EARNINGS_AMT,
                       p_ytd_earnings_amt         => l_default_value,
                       p_ptd_earnings_amt         => l_default_value,
                       p_gross_earnings           => P_GROSS_EARNINGS,
                       p_ytd_gross_earnings       => P_GROSS_EARNINGS,
                       p_daily_salary             => P_DAILY_SALARY,
                       p_classification_name      => l_classification_name);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
            END;

        END LOOP;
        CLOSE get_ele_class;
    END IF;

    RETURN (l_return_value);

END GET_PARTIAL_SUBJ_EARNINGS;


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
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_ASSIGNMENT_ACTION_ID  NUMBER,
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_JURISDICTION_CODE     VARCHAR2,
    P_CTX_ELEMENT_TYPE_ID       NUMBER,
    P_TAX_TYPE                  VARCHAR2,
    P_EARNINGS_AMT              NUMBER,
    P_YTD_EARNINGS_AMT          NUMBER,
    P_GROSS_EARNINGS            NUMBER,
    P_YTD_GROSS_EARNINGS        NUMBER,
    P_DAILY_SALARY              NUMBER,
    P_CLASSIFICATION_NAME       VARCHAR2
) RETURN NUMBER AS

    CURSOR get_ele_class IS
        SELECT pec1.classification_id,
               pec1.classification_name
          FROM pay_element_classifications pec,
               pay_element_classifications pec1, -- Secondary classification
               pay_element_types_f pet,
               pay_sub_classification_rules_f psr
         WHERE pet.classification_id = pec.classification_id
           AND pec.classification_id = pec1.parent_classification_id
           AND pet.element_type_id = psr.element_type_id
           AND psr.classification_id = pec1.classification_id
           AND p_ctx_effective_date BETWEEN pet.effective_start_date
                                        AND pet.effective_end_date
           AND p_ctx_effective_date BETWEEN psr.effective_start_date
                                        AND psr.effective_end_date
           AND pet.element_type_id = p_ctx_element_type_id
           AND pec.legislation_code = 'MX'
           AND pec.classification_name <> 'Employer Liabilities'
           AND pec.business_group_id IS NULL
           AND pec1.legislation_code = 'MX'
           AND pec1.business_group_id IS NULL
           AND p_tax_type = 'ISR'
        UNION
        SELECT pec.classification_id,
               pec.classification_name
          FROM pay_element_classifications pec
         WHERE UPPER(pec.classification_name) = UPPER(p_classification_name)
           AND pec.legislation_code = 'MX'
           AND pec.business_group_id IS NULL
           AND pec.parent_classification_id IS NOT NULL
           AND p_tax_type = 'STATE';

    l_calc_rule           pay_mx_earn_exemption_rules_f.calc_rule%type;
    l_low_exempt_factor   pay_mx_earn_exemption_rules_f.low_exempt_factor%type;
    l_low_range_factor    pay_mx_earn_exemption_rules_f.low_range_factor%type;
    l_low_range_basis     pay_mx_earn_exemption_rules_f.low_range_basis%type;
    l_high_exempt_factor  pay_mx_earn_exemption_rules_f.high_exempt_factor%type;
    l_high_range_factor   pay_mx_earn_exemption_rules_f.high_range_factor%type;
    l_high_range_basis    pay_mx_earn_exemption_rules_f.high_range_basis%type;
    l_classification_name pay_element_classifications.classification_name%type;
    l_classification_id   NUMBER;
    l_counter             NUMBER;
    l_proc_name           VARCHAR2(100);
    l_index               NUMBER;
    l_return_value        NUMBER;
    l_default_value       NUMBER;
    l_dummy               VARCHAR2(1);

BEGIN

    l_proc_name := g_proc_name ||'GET_PARTIAL_SUBJ_EARNINGS';
    hr_utility_trace('Entering '||l_proc_name);

    l_counter := 0;
    l_return_value := 0;

    IF p_earnings_amt > 0 THEN

        /* Perform exempt calculation only if earnings amount is greater
           than zero. */
        OPEN get_ele_class;
        LOOP
            FETCH get_ele_class INTO l_classification_id,
                                     l_classification_name;
            EXIT WHEN get_ele_class%NOTFOUND;

            hr_utility_trace('Element classification name is '
                                                      ||l_classification_name);

            IF l_classification_name LIKE '%:Subject to ISR' THEN
                RETURN (P_EARNINGS_AMT);
            END IF;

            IF g_isr_balances.count() > 0 THEN
                IF ((g_isr_balances(g_isr_balances.first()).assignment_action_id <>
                   p_ctx_assignment_action_id) OR p_tax_type <> 'ISR') THEN
                    g_isr_balances.delete();
                END IF;
            END IF;

            l_counter := 0;

            BEGIN
                -- Query to check if the classification is partially subject.
                --
                SELECT ''
                  INTO l_dummy
                  FROM pay_mx_earn_exemption_rules_f pmex
                 WHERE pmex.tax_type = p_tax_type
                   AND DECODE(p_tax_type, 'ISR', p_ctx_jurisdiction_code,
                              pmex.state_code) = p_ctx_jurisdiction_code
                   AND pmex.element_classification_id = l_classification_id
                   AND p_ctx_effective_date BETWEEN pmex.effective_start_date
                                                AND pmex.effective_end_date;

                l_index := l_classification_id;

                IF l_classification_name IN
                ('Supplemental Earnings:Social Foresight Earnings',
                 'Imputed Earnings:Social Foresight Earnings') THEN
                    l_index := 0;
                END IF;

                BEGIN
                l_default_value := nvl(g_isr_balances(l_index).earnings_amt, 0)
                                   + P_EARNINGS_AMT;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_default_value := P_EARNINGS_AMT;
                END;

                l_return_value := get_partial_subj_earnings(
                       p_ctx_effective_date       => P_CTX_EFFECTIVE_DATE,
                       p_ctx_assignment_action_id => P_CTX_ASSIGNMENT_ACTION_ID,
                       p_ctx_business_group_id    => P_CTX_BUSINESS_GROUP_ID,
                       p_ctx_jurisdiction_code    => P_CTX_JURISDICTION_CODE,
                       p_ctx_element_type_id      => P_CTX_ELEMENT_TYPE_ID,
                       p_tax_type                 => P_TAX_TYPE,
                       p_earnings_amt             => P_EARNINGS_AMT,
                       p_ytd_earnings_amt         => P_YTD_EARNINGS_AMT,
                       p_ptd_earnings_amt         => l_default_value,
                       p_gross_earnings           => P_GROSS_EARNINGS,
                       p_ytd_gross_earnings       => P_YTD_GROSS_EARNINGS,
                       p_daily_salary             => P_DAILY_SALARY,
                       p_classification_name      => l_classification_name);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
            END;

        END LOOP;
        CLOSE get_ele_class;
    END IF;

    RETURN (l_return_value);

END GET_PARTIAL_SUBJ_EARNINGS;


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
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_ASSIGNMENT_ACTION_ID  NUMBER,
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_JURISDICTION_CODE     VARCHAR2,
    P_CTX_ELEMENT_TYPE_ID       NUMBER,
    P_TAX_TYPE                  VARCHAR2,
    P_EARNINGS_AMT              NUMBER,
    P_PTD_EARNINGS_AMT          NUMBER,
    P_GROSS_EARNINGS            NUMBER,
    P_YTD_GROSS_EARNINGS        NUMBER,
    P_DAILY_SALARY              NUMBER,
    P_CLASSIFICATION_NAME       VARCHAR2
) RETURN NUMBER AS

    CURSOR get_ele_class IS
        SELECT pec1.classification_id,
               pec1.classification_name
          FROM pay_element_classifications pec,
               pay_element_classifications pec1, -- Secondary classification
               pay_element_types_f pet,
               pay_sub_classification_rules_f psr
         WHERE pet.classification_id = pec.classification_id
           AND pec.classification_id = pec1.parent_classification_id
           AND pet.element_type_id = psr.element_type_id
           AND psr.classification_id = pec1.classification_id
           AND p_ctx_effective_date BETWEEN pet.effective_start_date
                                        AND pet.effective_end_date
           AND p_ctx_effective_date BETWEEN psr.effective_start_date
                                        AND psr.effective_end_date
           AND pet.element_type_id = p_ctx_element_type_id
           AND pec.legislation_code = 'MX'
           AND pec.classification_name <> 'Employer Liabilities'
           AND pec.business_group_id IS NULL
           AND pec1.legislation_code = 'MX'
           AND pec1.business_group_id IS NULL
           AND p_tax_type = 'ISR'
        UNION
        SELECT pec.classification_id,
               pec.classification_name
          FROM pay_element_classifications pec
         WHERE UPPER(pec.classification_name) = UPPER(p_classification_name)
           AND pec.legislation_code = 'MX'
           AND pec.business_group_id IS NULL
           AND pec.parent_classification_id IS NOT NULL
           AND p_tax_type = 'STATE';

    l_calc_rule           pay_mx_earn_exemption_rules_f.calc_rule%TYPE;
    l_low_exempt_factor   pay_mx_earn_exemption_rules_f.low_exempt_factor%TYPE;
    l_low_range_factor    pay_mx_earn_exemption_rules_f.low_range_factor%TYPE;
    l_low_range_basis     pay_mx_earn_exemption_rules_f.low_range_basis%TYPE;
    l_high_exempt_factor  pay_mx_earn_exemption_rules_f.high_exempt_factor%TYPE;
    l_high_range_factor   pay_mx_earn_exemption_rules_f.high_range_factor%TYPE;
    l_high_range_basis    pay_mx_earn_exemption_rules_f.high_range_basis%TYPE;
    l_classification_name pay_element_classifications.classification_name%TYPE;
    l_classification_id   NUMBER;
    l_counter             NUMBER;
    l_proc_name           VARCHAR2(100);
    l_index               NUMBER;
    l_return_value        NUMBER;
    l_default_value       NUMBER;
    l_dummy               VARCHAR2(1);

BEGIN

    l_proc_name := g_proc_name ||'GET_PARTIAL_SUBJ_EARNINGS';
    hr_utility_trace('Entering '||l_proc_name);

    l_counter := 0;
    l_return_value := 0;

    IF p_earnings_amt > 0 THEN

        /* Perform exempt calculation only if earnings amount is greater
           than zero. */
        OPEN get_ele_class;
        LOOP
            FETCH get_ele_class INTO l_classification_id,
                                     l_classification_name;
            EXIT WHEN get_ele_class%NOTFOUND;

            hr_utility_trace('Element classification name is '
                                                      ||l_classification_name);

            IF l_classification_name LIKE '%:Subject to ISR' THEN
                RETURN (P_EARNINGS_AMT);
            END IF;

            IF g_isr_balances.count() > 0 THEN
                IF g_isr_balances(g_isr_balances.first()).assignment_action_id <>
                   p_ctx_assignment_action_id THEN
                    g_isr_balances.delete();
                END IF;
            END IF;

            l_counter := 0;

            BEGIN
                -- Query to check if the classification is partially subject.
                --
                SELECT ''
                  INTO l_dummy
                  FROM pay_mx_earn_exemption_rules_f pmex
                 WHERE pmex.tax_type = p_tax_type
                   AND DECODE(p_tax_type, 'ISR', p_ctx_jurisdiction_code,
                              pmex.state_code) = p_ctx_jurisdiction_code
                   AND pmex.element_classification_id = l_classification_id
                   AND p_ctx_effective_date BETWEEN pmex.effective_start_date
                                                AND pmex.effective_end_date;

                l_index := l_classification_id;

                IF l_classification_name IN
                ('Supplemental Earnings:Social Foresight Earnings',
                 'Imputed Earnings:Social Foresight Earnings') THEN
                    l_index := 0;
                END IF;

                BEGIN
                l_default_value := nvl(g_isr_balances(l_index).earnings_amt, 0)
                                   + P_EARNINGS_AMT;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_default_value := P_EARNINGS_AMT;
                END;

                l_return_value := get_partial_subj_earnings(
                       p_ctx_effective_date       => P_CTX_EFFECTIVE_DATE,
                       p_ctx_assignment_action_id => P_CTX_ASSIGNMENT_ACTION_ID,
                       p_ctx_business_group_id    => P_CTX_BUSINESS_GROUP_ID,
                       p_ctx_jurisdiction_code    => P_CTX_JURISDICTION_CODE,
                       p_ctx_element_type_id      => P_CTX_ELEMENT_TYPE_ID,
                       p_tax_type                 => P_TAX_TYPE,
                       p_earnings_amt             => P_EARNINGS_AMT,
                       p_ytd_earnings_amt         => l_default_value,
                       p_ptd_earnings_amt         => P_PTD_EARNINGS_AMT,
                       p_gross_earnings           => P_GROSS_EARNINGS,
                       p_ytd_gross_earnings       => P_YTD_GROSS_EARNINGS,
                       p_daily_salary             => P_DAILY_SALARY,
                       p_classification_name      => l_classification_name);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
            END;

        END LOOP;
        CLOSE get_ele_class;
    END IF;

    RETURN (l_return_value);

END GET_SUBJ_EARNINGS_FOR_PERIOD;



  /****************************************************************************
    Name        : GET_PARTIAL_SUBJ_EARNINGS
    Description : This function calculates subject earnings for classifications
                  that are fully and partially subject to ISR and state taxes.
  *****************************************************************************/
FUNCTION GET_PARTIAL_SUBJ_EARNINGS
(
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_ASSIGNMENT_ACTION_ID  NUMBER,
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_JURISDICTION_CODE     VARCHAR2,
    P_CTX_ELEMENT_TYPE_ID       NUMBER,
    P_TAX_TYPE                  VARCHAR2,
    P_EARNINGS_AMT              NUMBER,
    P_YTD_EARNINGS_AMT          NUMBER,
    P_PTD_EARNINGS_AMT          NUMBER,
    P_GROSS_EARNINGS            NUMBER,
    P_YTD_GROSS_EARNINGS        NUMBER,
    P_DAILY_SALARY              NUMBER,
    P_CLASSIFICATION_NAME       VARCHAR2
)RETURN NUMBER AS

    CURSOR get_exempt_info (p_classification_id number) IS
        SELECT pmex.calc_rule,
               pmex.low_exempt_factor,
               pmex.low_range_factor,
               pmex.low_range_basis,
               pmex.high_exempt_factor,
               pmex.high_range_factor,
               pmex.high_range_basis
          FROM pay_mx_earn_exemption_rules_f pmex
         WHERE pmex.tax_type = p_tax_type
           AND DECODE(p_tax_type, 'ISR',
                                   p_ctx_jurisdiction_code,
                                   pmex.state_code) = p_ctx_jurisdiction_code
           AND pmex.element_classification_id = p_classification_id
           AND p_ctx_effective_date BETWEEN pmex.effective_start_date
                                        AND pmex.effective_end_date;

    CURSOR get_days_per_period IS
        SELECT TRUNC(ptp.end_date - ptp.start_date) + 1 days,
               ppf.payroll_id,
               paa.tax_unit_id,
               paa.assignment_id
          FROM pay_payrolls_f ppf,
               per_time_periods ptp,
               pay_assignment_actions paa,
               pay_payroll_actions ppa
         WHERE ptp.payroll_id = ppf.payroll_id
           AND ppf.payroll_id = ppa.payroll_id
           AND ppa.payroll_action_id = paa.payroll_action_id
           AND paa.assignment_action_id = p_ctx_assignment_action_id
           AND ppa.effective_date BETWEEN ptp.start_date
                                      AND ptp.end_date
           AND ppa.effective_date BETWEEN ppf.effective_start_date
                                      AND ppf.effective_end_date;

    CURSOR get_days_per_period_temp IS
        SELECT TRUNC(ptp.end_date - ptp.start_date) + 1 days,
               paf.payroll_id,
          --     paa.tax_unit_id,
               paf.assignment_id
          FROM per_assignments_f       paf,
               per_time_periods        ptp,
               pay_temp_object_actions ptoa,
               pay_payroll_actions     ppa
         WHERE ptp.payroll_id           = paf.payroll_id
           AND ppa.payroll_action_id    = ptoa.payroll_action_id
           AND ptoa.object_id           = paf.assignment_id
           AND ptoa.object_type         = 'ASG'
           AND ptoa.object_action_id    = p_ctx_assignment_action_id
           AND ppa.effective_date BETWEEN ptp.start_date
                                      AND ptp.end_date
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

    CURSOR get_person_id ( cp_assignment_id  NUMBER
                          ,cp_effective_date DATE) IS
      SELECT person_id
        FROM per_assignments_f paf
       WHERE paf.assignment_id = cp_assignment_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date;

    l_calc_rule           pay_mx_earn_exemption_rules_f.calc_rule%TYPE;
    l_low_exempt_factor   pay_mx_earn_exemption_rules_f.low_exempt_factor%TYPE;
    l_low_range_factor    pay_mx_earn_exemption_rules_f.low_range_factor%TYPE;
    l_low_range_basis     pay_mx_earn_exemption_rules_f.low_range_basis%TYPE;
    l_high_exempt_factor  pay_mx_earn_exemption_rules_f.high_exempt_factor%TYPE;
    l_high_range_factor   pay_mx_earn_exemption_rules_f.high_range_factor%TYPE;
    l_high_range_basis    pay_mx_earn_exemption_rules_f.high_range_basis%TYPE;
    l_payroll_id          pay_payrolls_f.payroll_id%TYPE;
    l_tax_unit_id         pay_assignment_actions.tax_unit_id%TYPE;
    l_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
    ln_assignment_id      pay_assignment_actions.assignment_id%TYPE;
    ln_person_id          per_all_people_f.person_id%TYPE;
    l_classification_id   NUMBER;
    l_hire_date           DATE;
    l_exempt_amount       NUMBER;
    l_counter             NUMBER;
    l_sf_earnings         NUMBER;
    l_total_earnings      NUMBER;
    gmwa_1                NUMBER;
    gmwa_7                NUMBER;
    x                     NUMBER;
    l_middle              NUMBER;
    l_proc_name           VARCHAR2(100);
    l_days                NUMBER;
    l_days_in_month       NUMBER;
    l_days_in_year        NUMBER;
    l_service_years       NUMBER;
    l_index               NUMBER;
    l_earnings_amt        NUMBER;
    l_low_exempt_limit    NUMBER;
    l_high_exempt_limit   NUMBER;
    l_ytd_excl_current    NUMBER;
    l_ptd_excl_current    NUMBER;

BEGIN

    l_proc_name := g_proc_name ||'GET_PARTIAL_SUBJ_EARNINGS';
    hr_utility_trace('Entering '||l_proc_name);

    hr_utility_trace('Parameters ....');
    hr_utility_trace('P_CTX_EFFECTIVE_DATE = '|| P_CTX_EFFECTIVE_DATE);
    hr_utility_trace('P_CTX_ASSIGNMENT_ACTION_ID = '|| P_CTX_ASSIGNMENT_ACTION_ID);
    hr_utility_trace('P_CTX_BUSINESS_GROUP_ID = '|| P_CTX_BUSINESS_GROUP_ID);
    hr_utility_trace('P_CTX_JURISDICTION_CODE = '|| P_CTX_JURISDICTION_CODE);
    hr_utility_trace('P_CTX_ELEMENT_TYPE_ID = '|| P_CTX_ELEMENT_TYPE_ID);
    hr_utility_trace('P_TAX_TYPE = '|| P_TAX_TYPE);
    hr_utility_trace('P_EARNINGS_AMT = '|| P_EARNINGS_AMT);
    hr_utility_trace('P_YTD_EARNINGS_AMT = '|| P_YTD_EARNINGS_AMT);
    hr_utility_trace('P_PTD_EARNINGS_AMT = '|| P_PTD_EARNINGS_AMT);
    hr_utility_trace('P_GROSS_EARNINGS = '|| P_GROSS_EARNINGS);
    hr_utility_trace('P_YTD_GROSS_EARNINGS = '|| P_YTD_GROSS_EARNINGS);
    hr_utility_trace('P_DAILY_SALARY = '|| P_DAILY_SALARY);
    hr_utility_trace('P_CLASSIFICATION_NAME = '|| P_CLASSIFICATION_NAME);


    l_exempt_amount := 0;
    l_counter := 0;

    IF p_earnings_amt > 0 THEN

           l_counter := 0;

           l_classification_id :=
           pay_mx_utility.get_classification_id(p_classification_name);

           OPEN get_exempt_info(l_classification_id);
           LOOP
             FETCH get_exempt_info INTO l_calc_rule,
                                        l_low_exempt_factor,
                                        l_low_range_factor,
                                        l_low_range_basis,
                                        l_high_exempt_factor,
                                        l_high_range_factor,
                                        l_high_range_basis;
             EXIT WHEN get_exempt_info%NOTFOUND;
             l_counter := l_counter + 1;
             IF l_counter > 1 THEN
                 hr_utility.set_message(801, 'PAY_MX_MULTI_TAX_SEC_CLASS');
                 hr_utility.set_message_token(801,
                                              'ELEMENT_TYPE_ID',
                                              p_ctx_element_type_id);
                 hr_utility.raise_error;
             END IF;

             hr_utility_trace('l_calc_rule = '|| l_calc_rule);
             hr_utility_trace('l_low_exempt_factor = '|| l_low_exempt_factor);
             hr_utility_trace('l_low_range_factor = '|| l_low_range_factor);
             hr_utility_trace('l_low_range_basis = '|| l_low_range_basis);
             hr_utility_trace('l_high_exempt_factor = '|| l_high_exempt_factor);
             hr_utility_trace('l_high_range_factor = '|| l_high_range_factor);
             hr_utility_trace('l_high_range_basis = '|| l_high_range_basis);

             l_index := l_classification_id;

             IF p_classification_name IN
             ('Supplemental Earnings:Social Foresight Earnings',
              'Imputed Earnings:Social Foresight Earnings') THEN
                 l_index := 0;
             END IF;
             --
             BEGIN
             g_isr_balances(l_index).earnings_amt := p_earnings_amt +
                                     g_isr_balances(l_index).earnings_amt;
             g_isr_balances(l_index).assignment_action_id :=
                                             p_ctx_assignment_action_id;
             --
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                g_isr_balances(l_index).earnings_amt := p_earnings_amt;
                g_isr_balances(l_index).assignment_action_id :=
                                                 p_ctx_assignment_action_id;
             --
             END;

             IF g_temp_object_actions THEN

                 OPEN  get_days_per_period_temp;
                 FETCH get_days_per_period_temp INTO l_days,
                                                     l_payroll_id,
                    --                                 l_tax_unit_id,
                                                     ln_assignment_id;
                 CLOSE get_days_per_period_temp;

                 pay_mx_rules.get_main_tax_unit_id(ln_assignment_id,
                                                   p_ctx_effective_date,
                                                   l_tax_unit_id);

             ELSE
                 OPEN  get_days_per_period;
                 FETCH get_days_per_period INTO l_days,
                                                l_payroll_id,
                                                l_tax_unit_id,
                                                ln_assignment_id;
                 CLOSE get_days_per_period;

             END IF;

             hr_utility_trace('Days per period of payroll = '||l_days);

             l_earnings_amt := g_isr_balances(l_index).earnings_amt;

             OPEN  get_person_id( ln_assignment_id, p_ctx_effective_date);
             FETCH get_person_id INTO ln_person_id;
             CLOSE get_person_id;

             -- This represents the Exemption limit applicable on the
             -- Lower Range
             --
             l_low_exempt_limit := l_low_range_factor * get_range_basis_value(
                                                    l_low_range_basis,
                                                    p_daily_salary,
                                                    p_ctx_assignment_action_id);

             l_high_exempt_limit := l_high_range_factor * get_range_basis_value(
                                                    l_high_range_basis,
                                                    p_daily_salary,
                                                    p_ctx_assignment_action_id);

             l_ytd_excl_current := p_ytd_earnings_amt - p_earnings_amt;

             l_ptd_excl_current := p_ptd_earnings_amt - p_earnings_amt;

             -- Get number of days in year
             l_days_in_year := pay_mx_utility.get_days_in_year
                                                      (p_ctx_business_group_id,
                                                       l_tax_unit_id,
                                                       l_payroll_id);
             -- Get number of days in month
	     l_days_in_month := pay_mx_utility.get_days_in_month
                                                      (p_ctx_business_group_id,
                                                       l_tax_unit_id,
                                                       l_payroll_id);

             IF l_calc_rule = 'SINGLE_RANGE_DAILY' THEN

                 l_exempt_amount := LEAST(l_low_exempt_factor * p_earnings_amt,
                                          l_low_exempt_limit);

                 l_exempt_amount := l_exempt_amount -
                                    NVL(g_isr_balances(l_index).exempt_amt, 0);

             ELSIF l_calc_rule = 'SINGLE_RANGE' THEN

                 l_low_exempt_limit := l_low_exempt_limit * l_days;

                 l_exempt_amount :=
                 LEAST(l_low_exempt_factor * p_earnings_amt,
                       l_low_exempt_limit - LEAST(
                                       l_low_exempt_limit,
                                       l_low_exempt_factor * l_ptd_excl_current
                                                 )
                      );

             ELSIF l_calc_rule = 'SINGLE_RANGE_MONTH' THEN   /*7604285*/

                 l_low_exempt_limit := l_low_exempt_limit * l_days_in_month;

                 l_exempt_amount :=
                 LEAST(l_low_exempt_factor * p_earnings_amt,
                       l_low_exempt_limit - LEAST(
                                       l_low_exempt_limit,
                                       l_low_exempt_factor * l_ptd_excl_current
                                                 )
                      );

             ELSIF l_calc_rule = 'SINGLE_RANGE_ANNUAL' THEN

                 l_exempt_amount :=
                            LEAST(l_low_exempt_factor * p_earnings_amt,
                                  l_low_exempt_limit - LEAST(
                                        l_low_exempt_limit,
                                        l_low_exempt_factor * l_ytd_excl_current
                                                            )
                                 );

             ELSIF l_calc_rule = 'SINGLE_RANGE_SENIORITY_ANNUAL' THEN

                 l_service_years := hr_mx_utility.get_seniority(
                       p_business_group_id => p_ctx_business_group_id
                      ,p_tax_unit_id       => l_tax_unit_id
                      ,p_payroll_id        => l_payroll_id
                      ,p_person_id         => ln_person_id
                      ,p_effective_date    => p_ctx_effective_date);

                 -- Bug 4950628 - Corrected the calculation.
                 --
                 l_low_exempt_limit := l_low_exempt_limit * l_service_years;
                 l_exempt_amount :=
                            LEAST(l_low_exempt_factor * p_earnings_amt,
                                  l_low_exempt_limit - LEAST(
                                        l_low_exempt_limit,
                                        l_low_exempt_factor * l_ytd_excl_current
                                                      )
                                 );

             ELSIF l_calc_rule = 'MIN_OF_RANGES' THEN

                 -- For 'MIN_OF_RANGES', we assume that the low_exempt_factor
                 -- equals the high_exempt_factor.
                 --
                 l_low_exempt_limit := l_low_exempt_limit * l_days;
                 l_high_exempt_limit := l_high_exempt_limit * l_days;

                 IF l_low_exempt_limit < l_high_exempt_limit THEN

                     l_exempt_amount :=
                     LEAST(l_low_exempt_factor * p_earnings_amt,
                           l_low_exempt_limit - LEAST(
                                        l_low_exempt_limit,
                                        l_low_exempt_factor * l_ptd_excl_current
                                                     )
                          );
                 ELSE

                     l_exempt_amount :=
                     LEAST(l_high_exempt_factor * p_earnings_amt,
                           l_high_exempt_limit - LEAST(
                                       l_high_exempt_limit,
                                       l_high_exempt_factor * l_ptd_excl_current
                                                      )
                          );

                 END IF;

             ELSIF l_calc_rule = 'DOUBLE_RANGE_TOTAL_EARNINGS' THEN

                 IF p_daily_salary <= l_low_exempt_limit THEN

                     l_exempt_amount := l_low_exempt_factor * p_earnings_amt;

                 ELSE

                     l_high_exempt_limit := l_high_exempt_limit * l_days;

                     l_exempt_amount :=
                     LEAST(l_high_exempt_factor * p_earnings_amt,
                           l_high_exempt_limit - LEAST(
                                       l_high_exempt_limit,
                                       l_high_exempt_factor * l_ptd_excl_current
                                                      )
                          );

                 END IF;

             ELSIF l_calc_rule = 'INCOME_PLUS_EXEMPT_LIMIT' THEN

            ------------------------------------------------------------
            --   Algorithm for SF Exempt earnings:
            --   ---------------------------------
            --       1. Obtain YTD social foresight earnings (SFE).
            --       2. Compute X = 7 * GMWA - YTD gross earnings.
            --
            --       The Table showing the Exempt Portion is as follows:
            --       ==================================================
            --       |  Case                     |   Exempt Portion   |
            --       ==================================================
            --       |  X     < GMWA  < SFE      |   GMWA             |
            --       --------------------------------------------------
            --       |  X     < SFE   < GMWA     |   SFE              |
            --       --------------------------------------------------
            --       |  GMWA  < X     < SFE      |   X                |
            --       --------------------------------------------------
            --       |  GMWA  < SFE   < X        |   SFE              |
            --       --------------------------------------------------
            --       |  SFE   < GMWA  < X        |   SFE              |
            --       --------------------------------------------------
            --       |  SFE   < X     < GMWA     |   SFE              |
            --       --------------------------------------------------
            --
            --       3. Amount exempt from ISR =
            --                        Min ( SFE, Median(x, SFE, 1GMWA) )
            ------------------------------------------------------------

                 -- Step 1
                 l_sf_earnings := p_ytd_earnings_amt;

                 -- Step 2
                 -- Add Gross Earnings to total SF earnings.
                 l_total_earnings := l_sf_earnings +
                                     p_ytd_gross_earnings;

                 -- Step 3
                 gmwa_1 := l_days_in_year * get_range_basis_value(
                                                    'GMW',
                                                    p_daily_salary,
                                                    p_ctx_assignment_action_id);
                 gmwa_7 := gmwa_1 * 7;

                 x := gmwa_7 - p_ytd_gross_earnings;

                 -- Now find the second largest number among
                 -- x, l_sf_earnings and gmwa_1

                 l_middle := least (greatest(x, l_sf_earnings),
                                    greatest(l_sf_earnings, gmwa_1),
                                    greatest(gmwa_1, x)
                                   );

                 l_exempt_amount :=
                 least (l_sf_earnings, l_middle) * l_days / l_days_in_year;

                 l_exempt_amount := l_exempt_amount -
                                    nvl(g_isr_balances(l_index).exempt_amt, 0);

                 g_isr_balances(l_index).exempt_amt :=
                 nvl(g_isr_balances(l_index).exempt_amt, 0) + l_exempt_amount;

                 hr_utility_trace('Subject amount for ' ||
                                  p_classification_name || ' = ' ||
                                  to_char(l_sf_earnings - l_exempt_amount)
                                 );

                 hr_utility_trace('Leaving '||l_proc_name);

                 -- Return the subject amount.
                 RETURN (l_sf_earnings - l_exempt_amount);

             END IF;

           END LOOP;

           CLOSE get_exempt_info;

    END IF;
    --
    IF g_isr_balances.EXISTS(l_index) THEN

        g_isr_balances(l_index).exempt_amt :=
        NVL(g_isr_balances(l_index).exempt_amt, 0) + l_exempt_amount;

    END IF;
    --
    hr_utility_trace('Subject amount for ' ||
                     p_classification_name || ' = ' ||
                     TO_CHAR(p_earnings_amt - l_exempt_amount)
                    );

    hr_utility_trace('Leaving '||l_proc_name);
    --
    IF p_earnings_amt >= l_exempt_amount THEN

        RETURN (p_earnings_amt - l_exempt_amount);

    ELSE

        RETURN (0);

    END IF;
    --
END GET_PARTIAL_SUBJ_EARNINGS;

  /****************************************************************************
    Name        : GET_PREVIOUS_PERIOD_BAL
    Description : This function returns balance values for pay period
                  immediately previous to the period in which passed
                  assignment_action_id lies.
  *****************************************************************************/

FUNCTION GET_PREVIOUS_PERIOD_BAL
(
    P_CTX_ASSIGNMENT_ID         NUMBER,
    P_CTX_ASSIGNMENT_ACTION_ID  NUMBER,
    P_MODE                      VARCHAR2
) RETURN NUMBER AS

    CURSOR get_previous_assact IS
        SELECT paa.assignment_action_id
          FROM pay_assignment_actions paa,
               pay_payroll_actions ppa
         WHERE paa.assignment_id = p_ctx_assignment_id
           AND paa.payroll_action_id = ppa.payroll_action_id
           AND paa.action_sequence =
                 (SELECT max(paa_prev.action_sequence)
                    FROM per_time_periods ptp
                       , pay_payroll_actions ppa1
                       , pay_assignment_actions paa1
                       , per_time_periods ptp_prev
                       , pay_payroll_actions ppa_prev
                       , pay_assignment_actions paa_prev
                  WHERE  paa1.assignment_action_id = p_ctx_assignment_action_id
                    AND  ppa1.payroll_action_id = paa1.payroll_action_id
                    AND  ppa1.effective_date BETWEEN ptp.start_date
                                                 AND ptp.end_date
                    AND  ptp.payroll_id = ppa1.payroll_id
                    AND  ptp_prev.payroll_id = ppa1.payroll_id
                    AND  (ptp.start_date - 1) BETWEEN ptp_prev.start_date
                                                  AND ptp_prev.end_date
                    AND  paa_prev.assignment_id = paa1.assignment_id
                    AND  paa_prev.payroll_action_id = ppa_prev.payroll_action_id
                    AND  ppa_prev.action_type IN ('R', 'Q', 'B')
                    AND  ppa_prev.effective_date BETWEEN ptp_prev.start_date
                                                     AND ptp_prev.end_date);

    l_prev_assact       pay_assignment_actions.assignment_action_id%TYPE;
    l_payroll_id        pay_payroll_actions.payroll_id%TYPE;
    l_balance_value_tab pay_balance_pkg.t_balance_value_tab;
    l_counter           NUMBER;
    l_balance_value     NUMBER;
    l_proc_name         VARCHAR2(100);

BEGIN

    l_proc_name := g_proc_name ||'GET_PREVIOUS_PERIOD_BAL';
    hr_utility_trace('Entering '||l_proc_name);

    l_balance_value := 0;
    OPEN get_previous_assact;
        FETCH get_previous_assact INTO l_prev_assact;
    CLOSE get_previous_assact;

    hr_utility_trace('Previous assignment action id = '||l_prev_assact);

    IF l_prev_assact IS NOT NULL THEN /* Bug 4283490 */
        l_counter := 1;

        l_balance_value_tab(l_counter).defined_balance_id := get_def_bal_id (p_mode);
        l_balance_value_tab(l_counter).balance_value := 0;
        pay_balance_pkg.get_value (
                p_assignment_action_id => l_prev_assact,
                p_defined_balance_lst => l_balance_value_tab,
                p_get_rr_route => FALSE,
                p_get_rb_route => FALSE);
        l_balance_value := l_balance_value_tab(1).balance_value;
    END IF;

    hr_utility_trace('Return value = '||l_balance_value);
    hr_utility_trace('Leaving '||l_proc_name);

    RETURN (l_balance_value);

END GET_PREVIOUS_PERIOD_BAL;


  /****************************************************************************
    Name        : GET_MX_TAX_INFO
    Description : This function returns various parameters required for social
                  security quota and state tax calculation.
  *****************************************************************************/

FUNCTION GET_MX_TAX_INFO
(
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_TAX_UNIT_ID           NUMBER,
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_JURISDICTION_CODE     VARCHAR2,
    P_LEGISLATION_INFO_TYPE     VARCHAR2,
    P_LEGISLATION_INFO1      IN OUT NOCOPY VARCHAR2,
    P_LEGISLATION_INFO2         OUT NOCOPY VARCHAR2,
    P_LEGISLATION_INFO3         OUT NOCOPY VARCHAR2,
    P_LEGISLATION_INFO4         OUT NOCOPY VARCHAR2,
    P_LEGISLATION_INFO5         OUT NOCOPY VARCHAR2,
    P_LEGISLATION_INFO6         OUT NOCOPY VARCHAR2
) RETURN NUMBER AS

    CURSOR csr_get_ss_info IS
        SELECT effective_start_date,
               effective_end_date,
               jurisdiction_code,
               legislation_info_type,
               legislation_info1,
               legislation_info2,
               legislation_info3,
               legislation_info4,
               legislation_info5,
               legislation_info6
          FROM pay_mx_legislation_info_f
         WHERE legislation_info_type = p_legislation_info_type
           AND DECODE(p_legislation_info1,
                      '$Sys_Def$', legislation_info1,
                      p_legislation_info1) = legislation_info1
           AND NVL(jurisdiction_code,
                   p_ctx_jurisdiction_code) = p_ctx_jurisdiction_code
           AND p_ctx_effective_date BETWEEN effective_start_date
                                        AND effective_end_date;

    l_proc_name                 VARCHAR2(100);
    l_exists                    BOOLEAN;
    cntr                        NUMBER;
    ld_start_date               DATE;
    ld_end_date                 DATE;
    lv_jurisdiction             pay_mx_legislation_info_f.jurisdiction_code%type;
    lv_legislation_info_type    pay_mx_legislation_info_f.legislation_info_type%type;
BEGIN
    l_proc_name := g_proc_name ||'GET_MX_TAX_INFO';
    hr_utility_trace('Entering '||l_proc_name);
    l_exists := FALSE;
    cntr := g_pay_mx_legislation_info_f.count();
    hr_utility_trace('Number of cached legislative tax info records = '||cntr);

    IF cntr > 0 THEN /* Check if legislation info exists in cache. */
        FOR cntr IN g_pay_mx_legislation_info_f.first()..g_pay_mx_legislation_info_f.last()
        LOOP
            IF g_pay_mx_legislation_info_f(cntr).legislation_info_type
                                                  = p_legislation_info_type AND
               NVL(g_pay_mx_legislation_info_f(cntr).jurisdiction_code,
                          p_ctx_jurisdiction_code)= p_ctx_jurisdiction_code AND
               (p_legislation_info1 = '$Sys_Def$' OR
                g_pay_mx_legislation_info_f(cntr).legislation_info1
                                                    =  p_legislation_info1) AND
               p_ctx_effective_date BETWEEN
               g_pay_mx_legislation_info_f(cntr).effective_start_date AND
               g_pay_mx_legislation_info_f(cntr).effective_end_date

            THEN

                l_exists := TRUE;
                hr_utility_trace ('Retrieving legislative tax info from cache.');
                /* Copy cache onto out parameters */
                p_legislation_info1 := g_pay_mx_legislation_info_f(cntr).legislation_info1;
                p_legislation_info2 := g_pay_mx_legislation_info_f(cntr).legislation_info2;
                p_legislation_info3 := g_pay_mx_legislation_info_f(cntr).legislation_info3;
                p_legislation_info4 := g_pay_mx_legislation_info_f(cntr).legislation_info4;
                p_legislation_info5 := g_pay_mx_legislation_info_f(cntr).legislation_info5;
                p_legislation_info6 := g_pay_mx_legislation_info_f(cntr).legislation_info6;

                EXIT;
            END IF;
        END LOOP;
    END IF;

    IF cntr = 0 OR (NOT l_exists) THEN
        IF cntr > 0 THEN
            cntr := g_pay_mx_legislation_info_f.last() + 1;
        ELSE
            cntr := 1;
        END IF;
        hr_utility_trace ('Legislative tax info not found in cache. Hitting database now.');

        OPEN csr_get_ss_info;
            FETCH csr_get_ss_info
            INTO g_pay_mx_legislation_info_f(cntr).effective_start_date,
                 g_pay_mx_legislation_info_f(cntr).effective_end_date,
                 g_pay_mx_legislation_info_f(cntr).jurisdiction_code,
                 g_pay_mx_legislation_info_f(cntr).legislation_info_type,
                 g_pay_mx_legislation_info_f(cntr).legislation_info1,
                 g_pay_mx_legislation_info_f(cntr).legislation_info2,
                 g_pay_mx_legislation_info_f(cntr).legislation_info3,
                 g_pay_mx_legislation_info_f(cntr).legislation_info4,
                 g_pay_mx_legislation_info_f(cntr).legislation_info5,
                 g_pay_mx_legislation_info_f(cntr).legislation_info6;
        CLOSE csr_get_ss_info;

        /* Override values fetched by this cursor
        IF p_legislation_info_type = 'MX Social Security Information' THEN
            IF p_legislation_info1 = 'WRI' THEN
                g_pay_mx_legislation_info_f(cntr).legislation_info5 :=
                             hr_mx_utility.get_wrip (
                                 p_business_group_id => p_ctx_business_group_id,
                                 p_tax_unit_id       => p_ctx_tax_unit_id);
            END IF;
        END IF;*/

        /* Copy cache onto out parameters */
        p_legislation_info1 := g_pay_mx_legislation_info_f(cntr).legislation_info1;
        p_legislation_info2 := g_pay_mx_legislation_info_f(cntr).legislation_info2;
        p_legislation_info3 := g_pay_mx_legislation_info_f(cntr).legislation_info3;
        p_legislation_info4 := g_pay_mx_legislation_info_f(cntr).legislation_info4;
        p_legislation_info5 := g_pay_mx_legislation_info_f(cntr).legislation_info5;
        p_legislation_info6 := g_pay_mx_legislation_info_f(cntr).legislation_info6;
    END IF;

    -- Bug 4656174
    IF p_legislation_info_type = 'MX Social Security Information' THEN
        IF p_legislation_info1 = 'WRI' THEN
                hr_utility_trace('Hitting database for WRIP');
                OPEN csr_get_ss_info;
                FETCH csr_get_ss_info
                INTO ld_start_date,
                     ld_end_date,
                     lv_jurisdiction,
                     lv_legislation_info_type,
                     p_legislation_info1,
                     p_legislation_info2,
                     p_legislation_info3,
                     p_legislation_info4,
                     p_legislation_info5,
                     p_legislation_info6;
            CLOSE csr_get_ss_info;
            p_legislation_info5 :=
                         hr_mx_utility.get_wrip (
                             p_business_group_id => p_ctx_business_group_id,
                             p_tax_unit_id       => p_ctx_tax_unit_id);
        END IF;
    END IF;

    hr_utility_trace('p_legislation_info_type = '||p_legislation_info_type);
    hr_utility_trace('p_legislation_info1 = '    ||p_legislation_info1);
    hr_utility_trace('p_legislation_info2 = '    ||p_legislation_info2);
    hr_utility_trace('p_legislation_info3 = '    ||p_legislation_info3);
    hr_utility_trace('p_legislation_info4 = '    ||p_legislation_info4);
    hr_utility_trace('p_legislation_info5 = '    ||p_legislation_info5);
    hr_utility_trace('p_legislation_info6 = '    ||p_legislation_info6);

    hr_utility_trace('Leaving '||l_proc_name);
    RETURN(0);
EXCEPTION WHEN OTHERS THEN
    g_pay_mx_legislation_info_f.DELETE();
    RAISE;
END GET_MX_TAX_INFO;

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
) RETURN NUMBER AS

    l_proc_name           VARCHAR2(100);
    l_row_name            VARCHAR2(300);
    l_legal_employer_name hr_organization_units.name%TYPE;
    l_head_count          NUMBER;
BEGIN

    l_proc_name := g_proc_name || 'GET_MX_EE_HEAD_COUNT';

    hr_utility_trace('Entering ' || l_proc_name);

    l_legal_employer_name := hr_general.decode_organization(
                                       hr_mx_utility.get_legal_employer(
                                                p_ctx_business_group_id,
                                                p_ctx_tax_unit_id)
                                                           );

    hr_utility_trace('Legal Employer Name: ' || l_legal_employer_name);

    l_row_name := l_legal_employer_name || ' (' ||
                p_ctx_jurisdiction_code || ')';


    l_head_count := hruserdt.get_table_value(p_ctx_business_group_id,
                                            'Employee Head Count',
                                            'Number of Employees',
                                             l_row_name,
                                             p_ctx_effective_date);

    RETURN (l_head_count);

END GET_MX_EE_HEAD_COUNT;

  /****************************************************************************
    Name        : GET_MX_STATE_TAX_RULES
    Description : This function returns the data stored at Legal Employer level
                  under "State Tax Rules" Org Info type.
  *****************************************************************************/
FUNCTION GET_MX_STATE_TAX_RULES
(
    P_CTX_BUSINESS_GROUP_ID     NUMBER,
    P_CTX_TAX_UNIT_ID           NUMBER,
    P_CTX_EFFECTIVE_DATE        DATE,
    P_CTX_JURISDICTION_CODE     VARCHAR2
) RETURN VARCHAR2 AS

    -- Get data from hr_organization_information for the given Legal Employer
    --
    CURSOR c_get_rate_data(cp_legal_er_id NUMBER) IS
      SELECT DECODE(pml.legislation_info1,
                    'RANGE', org_information5,
                    'FLAT_RATE', org_information3)
        FROM hr_organization_information hoi,
             pay_mx_legislation_info_f pml
       WHERE hoi.organization_id = cp_legal_er_id
         AND hoi.org_information_context = 'MX_STATE_TAX_RULES'
         AND hoi.org_information1 = p_ctx_jurisdiction_code
         AND pml.jurisdiction_code = hoi.org_information1
         AND pml.legislation_info_type = 'MX State Tax Rate'
         AND p_ctx_effective_date BETWEEN pml.effective_start_date
                                      AND pml.effective_end_date
         AND DECODE(pml.legislation_info1,
                    'RANGE', org_information5,
                    'FLAT_RATE', org_information3) IS NOT NULL;

    l_proc_name           VARCHAR2(100);
    l_legal_er_id         NUMBER;
    l_return_value          VARCHAR2(100);
BEGIN

    l_proc_name := g_proc_name || 'GET_MX_STATE_TAX_RULES';

    hr_utility_trace('Entering ' || l_proc_name);

    l_legal_er_id := hr_mx_utility.get_legal_employer(p_ctx_business_group_id,
                                                      p_ctx_tax_unit_id);

    OPEN c_get_rate_data(l_legal_er_id);
    FETCH c_get_rate_data INTO l_return_value;
    CLOSE c_get_rate_data;

    hr_utility_trace('Leaving ' || l_proc_name);

    RETURN (l_return_value);

END GET_MX_STATE_TAX_RULES;

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

FUNCTION CALCULATE_ISR_TAX
(
    P_PAYROLL_ACTION_ID          NUMBER,
    P_ASSIGNMENT_ACTION_ID       NUMBER,
    P_BUSINESS_GROUP_ID          NUMBER,
    P_ASSIGNMENT_ID              NUMBER,
    P_TAX_UNIT_ID                NUMBER,
    P_DATE_EARNED                DATE,
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
RETURN NUMBER IS
    l_proc_name          VARCHAR2(100);
    ln_isr               NUMBER;
BEGIN
    l_proc_name := g_proc_name ||'CALCULATE_ISR_TAX-2';
    hr_utility_trace('Entering '||l_proc_name);

    ln_isr := pay_mx_tax_functions.calculate_isr_tax(
        p_payroll_action_id          => P_PAYROLL_ACTION_ID,
        p_assignment_action_id       => P_ASSIGNMENT_ACTION_ID,
        p_business_group_id          => p_business_group_id,
        p_assignment_id              => p_assignment_id,
        p_tax_unit_id                => p_tax_unit_id,
        p_date_earned                => p_date_earned,
        p_calc_mode                  => NULL,
        p_subject_amount             => p_subject_amount,
        p_isr_rates_table            => p_isr_rates_table,
        p_subsidy_table              => p_subsidy_table,
        p_credit_to_salary_table     => p_credit_to_salary_table,
        p_isr_calculated             => p_isr_calculated,
        p_isr_creditable_subsidy     => p_isr_creditable_subsidy,
        p_isr_non_creditable_subsidy => p_isr_non_creditable_subsidy,
        p_credit_to_salary           => p_credit_to_salary,
        p_credit_to_salary_paid      => p_credit_to_salary_paid);

    hr_utility_trace('ISR = ' || ln_isr);
    hr_utility_trace('Leaving '||l_proc_name);
    RETURN (ln_isr);
END CALCULATE_ISR_TAX;


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
                  4. ISR changes 2008
                     - ISR Credit to Salary has been used as
                     -     ISR Subsidy for Employment
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
RETURN NUMBER IS

    l_proc_name                VARCHAR2(100);
    ln_fixed_rate              NUMBER;
    ln_marginal_rate           NUMBER;
    ln_lower_limit             NUMBER;
    ln_marginal_tax            NUMBER;

    ln_fixed_subsidy           NUMBER;
    ln_marginal_subsidy        NUMBER;
    ln_subsidy_lower_limit     NUMBER;
    ln_tax_subsidy_percentage  NUMBER;
    ln_total_subsidy           NUMBER;
    ln_payroll_id              NUMBER;

    ln_isr_withheld            NUMBER;
    l_credit_to_salary_table   varchar2(100) := P_CREDIT_TO_SALARY_TABLE;
    ln_def_bal_id              pay_defined_balances.defined_balance_id%TYPE;
    ln_bal_amt                 NUMBER;
    ln_bal_sub                 NUMBER;
    ln_bal_sub_paid            NUMBER;
    ln_isr_subject_mtd         NUMBER;
    l_date_earned              DATE;
    l_date_paid                DATE;
    ln_credit_to_salary_tot    NUMBER;
    ln_credit_to_salary_max    NUMBER;
    ln_credit_to_salary_curr   NUMBER;
    ln_mult_num                NUMBER;
    ln_period_end_mtd          DATE;
    ln_period_start_mtd        DATE;
    ln_max_row                 NUMBER;
    lv_period_type             per_time_periods.period_type%TYPE;
    ln_days_in_a_period        NUMBER;
    ln_days_in_period_sub_empl NUMBER;
    ln_period_number           NUMBER;
    ln_pre_date_paid           NUMBER := 0;
    ld_hire_date               DATE; --added for fix 6821377
    ld_first_pay_date          DATE; --added for fix 6933775
    ln_ISR_subj_adj            NUMBER;
    --ln_pay_period_days         NUMBER;
    ln_worked_days             NUMBER;
    ln_bal_ISR_non_wrkd_days   NUMBER;
    ln_ISR_table_factor        NUMBER;
    ln_ISR_proj_subject        NUMBER;
    ln_le_days_month           NUMBER;
    ln_le_days_year            NUMBER;
    ln_le_id                   hr_all_organization_units.organization_id%TYPE;
    ln_isr_prop_fact           NUMBER;
    ln_le_worked_days             NUMBER;
    l_compute_subsidy_flag     CHAR(1); /*bug#8438155*/
/*    lv_calc_mode               VARCHAR2(20);
    lv_process                 VARCHAR2(20);
    lv_action_type             pay_payroll_actions.action_type%type;

    CURSOR csr_get_process_type IS
        SELECT action_type,
               pay_mx_utility.get_legi_param_val('CALC_MODE',
                                                 legislative_parameters),
               pay_mx_utility.get_legi_param_val('PROCESS',
                                                 legislative_parameters)
          FROM pay_payroll_actions
         WHERE payroll_action_id = p_payroll_action_id;*/

    CURSOR csr_get_payroll_id IS    /* bug#8932102 */
        SELECT payroll_id
          FROM per_assignments
         WHERE assignment_id = P_ASSIGNMENT_ID;

    CURSOR csr_get_hire_date IS    /* bug#8932102 */
        SELECT min(effective_start_date)
          FROM per_all_assignments_f
         WHERE assignment_id = P_ASSIGNMENT_ID
	   AND assignment_type='E';

    CURSOR csr_def_bal_id (p_balance_name     varchar2
                            ,p_db_item_suffix  varchar2) IS
         SELECT  pdb.defined_balance_id
          FROM   pay_defined_balances pdb,
                 pay_balance_dimensions pbd,
                 pay_balance_types pbt
          WHERE  pbd.balance_dimension_id  = pdb.balance_dimension_id
          AND    pbt.balance_type_id = pdb.balance_type_id
          AND    pbd.database_item_suffix = p_db_item_suffix -- '_ASG_GRE_MTD'
          AND    pbt.balance_name = p_balance_name; --'ISR Subsidy for Employment'

    CURSOR csr_date_earned IS
         SELECT ppa.effective_date l_date_paid,
                ptp.end_date l_date_earned
         FROM   per_time_periods ptp,
                pay_payroll_actions ppa
         WHERE  ppa.payroll_action_id = p_payroll_action_id
         AND    ppa.time_period_id = ptp.time_period_id;

    --Added for fix 6933775.
   /*Cursor to get the first pay period start date for the assignment*/
     CURSOR csr_get_first_pay_date IS
     SELECT MIN(ptp.start_date)
     FROM  pay_assignment_actions paa,
           pay_payroll_actions ppa,
           per_time_periods ptp
     WHERE paa.assignment_id = p_assignment_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND ptp.time_period_id = ppa.time_period_id
       AND ppa.action_type IN ('R', 'Q', 'B')
       AND (to_char(l_date_paid,'yyyymm') = to_char(ptp.end_date,'yyyymm')
              OR
              l_date_paid BETWEEN ptp.start_date AND ptp.end_date
            );

    CURSOR csr_get_period_count_in_month IS
       SELECT ROWNUM mult_num
              ,end_date period_end_mtd
              ,start_date period_start_mtd
              ,period_type
       FROM   PER_TIME_PERIODS ptp
       WHERE  payroll_id = ln_payroll_id
       AND    (TO_CHAR(l_date_paid,'yyyymm') = TO_CHAR(end_date,'yyyymm')
              OR
              l_date_paid BETWEEN start_date AND end_date
              )
       AND ld_hire_date <= end_date
       AND start_date >= NVL(ld_first_pay_date,start_date)
       ORDER BY end_date;

    CURSOR csr_get_no_of_days_in_period(p_payroll_id number) IS
       SELECT end_date - start_date +1 period_days
       FROM   PER_TIME_PERIODS ptp
       WHERE  payroll_id = p_payroll_id
       AND    TO_CHAR(l_date_earned,'yyyymmdd') = TO_CHAR(end_date,'yyyymmdd');

    CURSOR csr_get_compute_subsidy_flag IS   /*bug#8438155*/
        SELECT nvl(hsck.SEGMENT11,'Y')
          FROM per_assignments_f      paf,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               hr_soft_coding_keyflex hsck
         WHERE paf.assignment_id        = paa.assignment_id
           AND paa.payroll_action_id    = ppa.payroll_action_id
           AND paa.assignment_action_id = p_assignment_action_id
           AND hsck.soft_coding_keyflex_id= paf.soft_coding_keyflex_id
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

  BEGIN
    l_proc_name := g_proc_name ||'CALCULATE_ISR_TAX';
    hr_utility_trace('Entering '||l_proc_name);
    hr_utility_trace('p_payroll_action_id: '||p_payroll_action_id);
    hr_utility_trace('p_assignment_action_id: '||p_assignment_action_id);
    hr_utility_trace('p_business_group_id: '||p_business_group_id);
    hr_utility_trace('p_assignment_id: '||p_assignment_id);
    hr_utility_trace('p_tax_unit_id: '||p_tax_unit_id);
    hr_utility_trace('p_date_earned: '||
                                     fnd_date.date_to_canonical(p_date_earned));
    hr_utility_trace('p_calc_mode: '||p_calc_mode);
    hr_utility_trace('p_subject_amount: '||p_subject_amount);
    hr_utility_trace('p_isr_rates_table: '||p_isr_rates_table);
    hr_utility_trace('p_subsidy_table: '||p_subsidy_table);
    hr_utility_trace('p_credit_to_salary_table: '||p_credit_to_salary_table);
    hr_utility_trace('l_credit_to_salary_table: '||l_credit_to_salary_table);

    ln_ISR_proj_subject := p_subject_amount;

    OPEN csr_date_earned;
    FETCH csr_date_earned INTO l_date_paid, l_date_earned;
    CLOSE csr_date_earned;

    hr_utility_trace('l_date_earned: '||l_date_earned);
    hr_utility_trace('l_date_paid: '||l_date_paid);

    --Start of Bug Fix 6852627
    /*Calculation for Proration*/

      /*bug#8932102:
      1. Seperated ld_hire_date from cursor csr_get_payroll_id
         and created seperate cursor to fetch ld_hire_date, this is because
         ld_hire_date will be wrong when the per_all_people_f table has
         multiple date effective entries
      2. Table reference per_assignments_f has been changed to per_assignments in
         cursor csr_get_payroll_id to get latest payroll_id for the assignment*/

    OPEN csr_get_payroll_id;   /*bug#8932102 */
      FETCH csr_get_payroll_id INTO ln_payroll_id;
    CLOSE csr_get_payroll_id;

    OPEN csr_get_hire_date;
      FETCH csr_get_hire_date INTO ld_hire_date;
    CLOSE csr_get_hire_date;

    hr_utility_trace('payroll_id '||ln_payroll_id);
    hr_utility_trace('ld_hire_date '||ld_hire_date);
    hr_utility_trace('Getting the actual number of days in pay period ...');

    OPEN csr_get_no_of_days_in_period(ln_payroll_id);
       FETCH  csr_get_no_of_days_in_period INTO ln_days_in_a_period;
    CLOSE csr_get_no_of_days_in_period;

    hr_utility_trace('Number of days in the pay period   : '||ln_days_in_a_period);

    hr_utility_trace('Getting the total number of days in pay period as deifned in GRE/LE...');

    ln_le_id := hr_mx_utility.get_legal_employer(
                                  p_business_group_id => p_business_group_id
                                 ,p_tax_unit_id       => p_tax_unit_id);

    pay_mx_utility.get_no_of_days_for_org( p_business_group_id => p_business_group_id
                                          ,p_org_id            => ln_le_id
                                          ,p_gre_or_le         => 'LE'
                                          ,p_days_month        => ln_le_days_month
                                          ,p_days_year         => ln_le_days_year);

    IF (ln_le_days_month IS NULL OR ln_le_days_month = -999) THEN
       ln_le_days_month := ln_days_in_a_period ;
    END IF;

    /*ln_pay_period_days := pay_mx_utility.get_days_in_pay_period( p_business_group_id
                                                                ,p_tax_unit_id
                                                                ,ln_payroll_id);*/
    hr_utility_trace('Average days in the month at LE :'||to_char(ln_le_days_month));

    OPEN csr_def_bal_id ('ISR Non Working Days','_ASG_GRE_RUN');
     FETCH csr_def_bal_id INTO ln_def_bal_id;
    CLOSE csr_def_bal_id;

    hr_utility_trace('ISR Non Working Days def bal id '||to_char(ln_def_bal_id));
    ln_bal_ISR_non_wrkd_days := pay_balance_pkg.get_value(ln_def_bal_id,
                                                            p_assignment_action_id,
                                                            p_tax_unit_id,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            'TRUE');
    hr_utility_trace('ISR Non Working Days Bal Val '||to_char(ln_bal_ISR_non_wrkd_days));

    hr_utility_trace('Get the factor for proration ln_le_days_month/ln_days_in_a_period ..');
    ln_isr_prop_fact := ln_le_days_month/ln_days_in_a_period;
    hr_utility_trace('ln_isr_prop_fact :' || TO_CHAR(ln_isr_prop_fact));

    hr_utility_trace('getting worked days.. ');
    ln_worked_days := ln_days_in_a_period - nvl(ln_bal_ISR_non_wrkd_days,0);

    ln_le_worked_days :=  (ln_le_days_month - (nvl(ln_bal_ISR_non_wrkd_days,0) *  ln_isr_prop_fact)) ;

    hr_utility_trace('Actual worked days in the period for ISR Tax '||to_char(ln_worked_days));
    hr_utility_trace('worked days for proration in the period for ISR Tax '||to_char(ln_le_worked_days));
    --End of Bug Fix 6852627
    IF to_char(l_date_paid,'yyyymmdd')
       >= to_char(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') AND P_CALC_MODE = 'ARTICLE113' THEN
          hr_utility_trace('ISr Proration in 2008');
        IF nvl(ln_bal_ISR_non_wrkd_days,0) > 0 AND nvl(ln_bal_ISR_non_wrkd_days,0) < ln_days_in_a_period THEN

	   ln_ISR_proj_subject := ROUND(((ln_ISR_proj_subject * ln_le_days_month) / ln_le_worked_days),2);

	   hr_utility_trace('ISR Projected value in the pay period '||to_char(ln_ISR_proj_subject));
        END IF;

    END IF;

    hr_utility_trace('Final Subject amount after proration: '||ln_ISR_proj_subject);
    /* Article 113, 114 and 115 */

    ln_fixed_rate    := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Fixed Rate'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_fixed_rate: '||ln_fixed_rate);

    ln_marginal_rate := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Marginal Rate'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_marginal_rate: '||ln_marginal_rate);

    ln_lower_limit   := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Lower Bound'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_lower_limit: '||ln_lower_limit);

    ln_marginal_tax  := (ln_marginal_rate/100) * (ln_ISR_proj_subject -
                                                  ln_lower_limit);

    hr_utility_trace('ln_marginal_tax: '||ln_marginal_tax);

    p_isr_calculated := ln_fixed_rate + ln_marginal_tax;

    hr_utility_trace('p_isr_calculated: '||p_isr_calculated);

    IF TO_CHAR(l_date_paid,'yyyymmdd')
       < TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN

       /* Subsidy Calculation */
       ln_fixed_subsidy       := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Fixed Rate'
                                    ,TO_CHAR(ln_ISR_proj_subject)));

       hr_utility_trace('ln_fixed_subsidy: '||ln_fixed_subsidy);

       ln_marginal_subsidy    := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Marginal Rate'
                                    ,TO_CHAR(ln_ISR_proj_subject)));

       hr_utility_trace('ln_marginal_subsidy: '||ln_marginal_subsidy);

       ln_subsidy_lower_limit := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Lower Bound'
                                    ,TO_CHAR(ln_ISR_proj_subject)));


       hr_utility_trace('ln_subsidy_lower_limit: '||ln_subsidy_lower_limit);

       ln_tax_subsidy_percentage := hr_mx_utility.get_tax_subsidy_percent(
                                                      p_business_group_id
                                                     ,p_tax_unit_id);

       hr_utility_trace('ln_tax_subsidy_percentage: '||ln_tax_subsidy_percentage);

       /*OPEN csr_get_process_type;
           FETCH csr_get_process_type INTO lv_action_type,
                                           lv_calc_mode,
                                           lv_process;
       CLOSE csr_get_process_type;*/

       IF (p_calc_mode = 'BEST' OR p_calc_mode = 'ARTICLE141') THEN
           -- Calculate subsidy for Article 141
           hr_utility_trace('Calculating subsidy for Article 141 ...');
           ln_total_subsidy := ln_fixed_rate * (ln_fixed_subsidy/100) +
                               (ln_marginal_subsidy/100) *
                               (ln_marginal_rate/100) *
                               (ln_ISR_proj_subject - ln_subsidy_lower_limit);
       ELSE
           ln_total_subsidy := ln_fixed_subsidy +
                                  (ln_marginal_subsidy/100) *
                                  (ln_marginal_rate/100) *
                                  (ln_ISR_proj_subject - ln_subsidy_lower_limit);
       END IF;
       hr_utility_trace('ln_total_subsidy: '||ln_total_subsidy);

       p_isr_creditable_subsidy := (ln_tax_subsidy_percentage/100) *
                                                               ln_total_subsidy;

       hr_utility_trace('p_isr_creditable_subsidy: '||p_isr_creditable_subsidy);

       p_isr_non_creditable_subsidy := ln_total_subsidy - p_isr_creditable_subsidy;

       hr_utility_trace('p_isr_non_creditable_subsidy: '||
                         p_isr_non_creditable_subsidy);

    ELSE
        p_isr_creditable_subsidy := 0;
        p_isr_non_creditable_subsidy := 0;
    END IF; --  end of subsidy calc

    /* Credit To Salary Calculation */

        /* Bug#8438155: created new cursor csr_get_compute_subsidy_flag to fetch
       the value 'Compute Subsidy for Employment' from 'MX Statutory Info'
       If this value is 'N' then below subsidy calculation will be skipped */

        OPEN csr_get_compute_subsidy_flag;
        FETCH csr_get_compute_subsidy_flag into l_compute_subsidy_flag;
        CLOSE csr_get_compute_subsidy_flag;

        hr_utility_trace('l_compute_subsidy_flag '||l_compute_subsidy_flag);
        /*bug7445486  bug#8438155*/
    IF ( p_credit_to_salary_table <> 'NONE' and P_CALC_MODE <>'ARTICLE142' AND l_compute_subsidy_flag <> 'N') THEN

       hr_utility_trace('inside subsidy '||p_credit_to_salary_table|| ' --- '||TO_CHAR(ln_ISR_proj_subject));
       p_credit_to_salary := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_credit_to_salary_table
                                 ,'Amount'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

       P_CREDIT_TO_SALARY := nvl(P_CREDIT_TO_SALARY,0);

       IF TO_CHAR(l_date_paid,'yyyymmdd')
          >= TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN

      /*bug#8932102:
      1. Seperated ld_hire_date from cursor csr_get_payroll_id
         and created seperate cursor to fetch ld_hire_date, this is because
         ld_hire_date will be wrong when the per_all_people_f table has
         multiple date effective entries
      2. Table reference per_assignments_f has been changed to per_assignments in
         cursor csr_get_payroll_id*/


    OPEN csr_get_payroll_id;   /*bug#8932102 */
      FETCH csr_get_payroll_id INTO ln_payroll_id;
    CLOSE csr_get_payroll_id;

    OPEN csr_get_hire_date;
      FETCH csr_get_hire_date INTO ld_hire_date;
    CLOSE csr_get_hire_date;

    hr_utility_trace('payroll_id 2'||ln_payroll_id);
    hr_utility_trace('ld_hire_date 2'||ld_hire_date);

          -- get ISR Subject balance for month

          OPEN csr_def_bal_id ('ISR Subject','_ASG_MTD');
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

          hr_utility_trace('ISR Subject def bal id '||ln_def_bal_id);

          ln_bal_amt := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

          hr_utility_trace('MTD Subject Amt - ln_bal_amt '||to_char(ln_bal_amt));
         /*Get the previous ISR Subject adjusted amount due to proration
           this will have impact only in semi-monthly and weekely payroll*/
          OPEN csr_def_bal_id ('ISR Subject Adjusted','_ASG_MTD');
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

          hr_utility_trace('ISR Subject Adjusted def bal id '||ln_def_bal_id);
          ln_ISR_subj_adj :=  pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 'TRUE');
          hr_utility_trace('ISR Subject Adjusted Amount MTD - ln_ISR_subj_adj'||ln_ISR_subj_adj);
--	  ln_bal_amt := ln_bal_amt + ln_ISR_subj_adj;
--          hr_utility_trace('Actual subject value is ln_bal_amt + ln_ISR_subj_adj  '||ln_bal_amt);
          -- get ISR Subsidy for Employement balance for month
           ln_ISR_subj_adj := ln_ISR_subj_adj + ln_ISR_proj_subject;
           hr_utility_trace('Actual subject value is ln_ISR_subj_adj + ln_ISR_proj_subject  '||ln_ISR_subj_adj);

	   OPEN csr_def_bal_id ('ISR Subsidy for Employment','_ASG_MTD');
            FETCH csr_def_bal_id INTO ln_def_bal_id;
           CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_bal_sub := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

           hr_utility_trace('ISR Sub for Empl Bal Sub '||to_char(ln_bal_sub));

           OPEN csr_def_bal_id ('ISR Subsidy for Employment Paid','_ASG_MTD');
            FETCH csr_def_bal_id INTO ln_def_bal_id;
           CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_bal_sub_paid := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

           hr_utility_trace('ISR Sub for Empl Bal Sub Paid '||to_char(ln_bal_sub_paid));

           if ln_payroll_id is not null then
              select min(period_type)
              into   lv_period_type
              from   pay_payrolls_f
              where  payroll_id = ln_payroll_id;
           end if;

           OPEN csr_get_first_pay_date;
	     FETCH csr_get_first_pay_date INTO ld_first_pay_date;
	   CLOSE csr_get_first_pay_date;

           ln_isr_subject_mtd := CONVERT_INTO_MONTHLY_AVG_SAL (p_business_group_id
                                                           ,p_tax_unit_id
                                                           ,ln_payroll_id
                                                           ,ln_ISR_proj_subject
                                                           ,l_date_paid
							   ,ld_hire_date
							   ,ld_first_pay_date
                                                           ,ln_period_number)
                                + (ln_ISR_subj_adj - ln_ISR_proj_subject);

           hr_utility_trace('ln_isr_subject_mtd  : '||ln_isr_subject_mtd);
           hr_utility_trace('ln_days_in_a_period  : '||ln_days_in_a_period);
           hr_utility_trace('ln_period_number  : '||ln_period_number);

           open csr_get_period_count_in_month;
           loop
              fetch csr_get_period_count_in_month into ln_mult_num,
	                                              ln_period_end_mtd,
						      ln_period_start_mtd,
						      lv_period_type;
             exit when csr_get_period_count_in_month%NOTFOUND;

	     select least(count(*),1)
	     into   ln_pre_date_paid
	     from   pay_payroll_actions ppa,
	            pay_assignment_actions paa,
		    per_time_periods ptp
	     where  ppa.payroll_action_id = paa.payroll_action_id
	     and    ptp.time_period_id = ppa.time_period_id
	     and    paa.assignment_id = p_assignment_id
	     and    to_char(ptp.end_date,'yyyymm') = to_char(l_date_paid,'yyyymm')
	     and    to_char(ppa.effective_date,'yyyymm') < to_char(l_date_paid,'yyyymm')
	     AND    ld_hire_date <= ptp.end_date;

             hr_utility_trace('l_date_paid '||to_char(l_date_paid,'yyyymm'));
             hr_utility_trace('ln_pre_date_paid '||to_char(ln_pre_date_paid));

             IF l_date_paid >= ln_period_start_mtd and
		l_date_paid <= ln_period_end_mtd  then
                ln_period_number := ln_period_number - ln_pre_date_paid;
                hr_utility_trace('Actual ln_period_number '||to_char(ln_period_number));
             end if;

           end loop;
         close csr_get_period_count_in_month;


         IF lv_period_type = 'Semi-Month' THEN
	     ln_days_in_period_sub_empl := 15;
         ELSIF lv_period_type = 'Ten Days' then
            ln_days_in_period_sub_empl := 10;
	 ELSE
            ln_days_in_period_sub_empl :=   ln_days_in_a_period; /*bug 7677805*/
	 END IF ;
	 p_credit_to_salary := FND_NUMBER.canonical_to_number(get_table_value (
                                  p_business_group_id
                                 ,p_credit_to_salary_table
                                 ,'Amount'
                                 ,TO_CHAR(ln_ISR_subj_adj)
                                 ,l_date_paid
                                 ,ln_days_in_a_period
                                 ,ln_period_number
                                 ,lv_period_type));

          hr_utility_trace('Total Subsidy for Empl '||to_char(p_credit_to_salary));

          ln_credit_to_salary_max := p_credit_to_salary;

          P_CREDIT_TO_SALARY := (ln_credit_to_salary_max/30.4) * ln_days_in_period_sub_empl;

          ln_credit_to_salary_curr := P_CREDIT_TO_SALARY;

          hr_utility_trace('Current Period Subsidy for Empl '||to_char(p_credit_to_salary));

          select count(*) max_row
          into   ln_max_row
          from PER_TIME_PERIODS ptp1
          where payroll_id = ln_payroll_id
          and to_char(l_date_paid,'yyyymm') = to_char(end_date,'yyyymm');

          open csr_get_period_count_in_month;
          loop
             fetch csr_get_period_count_in_month into ln_mult_num,
	                                              ln_period_end_mtd,
						      ln_period_start_mtd,
						      lv_period_type;
             exit when csr_get_period_count_in_month%NOTFOUND;
             if ln_period_end_mtd = l_date_earned then

	        if to_char(ln_period_end_mtd,'yyyymm') = to_char(l_date_paid,'yyyymm') and
    		   to_char(ln_period_end_mtd,'yyyymmdd') >= to_char(last_day(l_date_paid),'yyyymmdd') then

                   P_CREDIT_TO_SALARY := least(ln_credit_to_salary_max,
		                         P_CREDIT_TO_SALARY * ln_mult_num );
                   hr_utility_trace('outside/last day of month '||to_char(p_credit_to_salary));
                else
                   P_CREDIT_TO_SALARY := least(ln_credit_to_salary_max,
		                         P_CREDIT_TO_SALARY * (ln_mult_num - ln_pre_date_paid) );
                   hr_utility_trace('With in month '||to_char(p_credit_to_salary));
                end if;

                hr_utility_trace('max allowd Subsidy for Empl '||to_char(p_credit_to_salary));
                 IF l_date_paid >= ln_period_start_mtd AND
		   l_date_paid <= ln_period_end_mtd AND
                   (lv_period_type = 'Calendar Month' OR (lv_period_type = 'Semi-Month' AND ln_period_number = 2)
                   OR (lv_period_type = 'Ten Days' AND ln_period_number = 3))
		THEN
                   P_CREDIT_TO_SALARY := ln_credit_to_salary_max;
                   hr_utility_trace('Final period Subsidy for Empl '||to_char(p_credit_to_salary));
                end if;
                P_CREDIT_TO_SALARY := P_CREDIT_TO_SALARY - ln_bal_sub;
                hr_utility_trace('Subsidy for Empl '||to_char(p_credit_to_salary));
             end if;
          end loop;
          close csr_get_period_count_in_month;
      END IF;
    ELSE
       p_credit_to_salary := 0;
    END IF;

    P_CREDIT_TO_SALARY := nvl(P_CREDIT_TO_SALARY,0);
    hr_utility_trace('p_credit_to_salary: '||p_credit_to_salary);

    /* ISR Withheld Calculation */

    ln_isr_withheld := p_isr_calculated -
                       p_isr_creditable_subsidy -
                       p_credit_to_salary;


    hr_utility_trace('ln_isr_withheld B4: '||ln_isr_withheld);

    /*Incuded the proration logic based on balance ISR Non working days*/
    --Start of Bug fix 6852627
    IF to_char(l_date_paid,'yyyymmdd')
       >= to_char(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') AND P_CALC_MODE = 'ARTICLE113' THEN
      IF nvl(ln_bal_ISR_non_wrkd_days,0) > 0 AND nvl(ln_bal_ISR_non_wrkd_days,0) < ln_days_in_a_period THEN

      hr_utility_trace('-- Non workings days are feeded, need to proproate ISR Tax --');

      hr_utility_trace('Getting the table factor value for ISR Tax calculation');
          ln_ISR_table_factor :=  ROUND(((ln_days_in_a_period * 30.4)/ln_le_days_month),2);

      hr_utility_trace('Factor value for '||lv_period_type||' payroll is '||TO_CHAR(ln_ISR_table_factor));

      hr_utility_trace('Proration logic on ISR Tax for '||TO_CHAR(ln_worked_days)||' working days');

      ln_isr_withheld := (ln_isr_withheld / ln_ISR_table_factor) * ln_worked_days ;

      hr_utility_trace('Prorated ISR with held '||TO_CHAR(ln_isr_withheld));
      hr_utility_trace('Start of ISR Subject proration ');

      ELSIF nvl(ln_bal_ISR_non_wrkd_days,0) < 0  OR nvl(ln_bal_ISR_non_wrkd_days,0) > ln_days_in_a_period THEN
        hr_utility_trace('ISR Non Worked Days value is invalid ');
	hr_utility.set_message(801, 'PAY_MX_INVALID_ISR_NON_WRK_DAY');
	hr_utility.raise_error;

      ELSIF nvl(ln_bal_ISR_non_wrkd_days,0) = ln_days_in_a_period THEN
        ln_isr_withheld := 0;
        p_credit_to_salary_paid := 0;
        p_isr_calculated := 0;
	p_credit_to_salary := 0;

      END IF;
    END IF;
    --End of Bug Fix 6852627

    IF ln_isr_withheld < 0 THEN
       p_credit_to_salary_paid := ABS(ln_isr_withheld);
       ln_isr_withheld := 0;
    ELSE
        p_credit_to_salary_paid := 0;
     END IF;
   /*To feed ISR Subject Adjusted Balance*/
   IF TO_CHAR(l_date_paid,'yyyymmdd')
          >= TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN
      p_isr_creditable_subsidy := ln_ISR_proj_subject;
      hr_utility_trace(' Feeding ISR Subject Adjusted Balance value in 2008 = p_isr_creditable_subsidy'||p_isr_creditable_subsidy);
    END IF;
    hr_utility_trace('p_credit_to_salary_paid: '||p_credit_to_salary_paid);
    hr_utility_trace('ln_isr_withheld Final: '||ln_isr_withheld);
    hr_utility_trace('Leaving '||l_proc_name);

    RETURN ln_isr_withheld;

    EXCEPTION
        WHEN OTHERS THEN
            hr_utility_trace('Exception in '||l_proc_name||': '||SQLERRM);
            RAISE;
END CALCULATE_ISR_TAX;


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
                  4. ISR changes 2008
                     - ISR Credit to Salary has been used as
                     -     ISR Subsidy for Employment
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
RETURN NUMBER IS

    l_proc_name                VARCHAR2(100);
    lv_dimension_type          VARCHAR2 (50);
    lv_proration_table         VARCHAR2 (50);
    ln_fixed_rate              NUMBER;
    ln_marginal_rate           NUMBER;
    ln_lower_limit             NUMBER;
    ln_marginal_tax            NUMBER;

    ln_fixed_subsidy           NUMBER;
    ln_marginal_subsidy        NUMBER;
    ln_subsidy_lower_limit     NUMBER;
    ln_tax_subsidy_percentage  NUMBER;
    ln_total_subsidy           NUMBER;
    ln_payroll_id              NUMBER;

    ln_isr_withheld            NUMBER;
    l_credit_to_salary_table   varchar2(100) := P_CREDIT_TO_SALARY_TABLE;
    ln_def_bal_id              pay_defined_balances.defined_balance_id%TYPE;
    ln_bal_amt                 NUMBER;
    ln_bal_sub                 NUMBER;
    ln_bal_sub_paid            NUMBER;
    tot_subsidy_empl           NUMBER;
    ln_isr_subject_mtd         NUMBER;
    l_date_earned              DATE;
    l_date_paid                DATE;
    ln_credit_to_salary_tot    NUMBER;
    ln_credit_to_salary_max    NUMBER;
    ln_credit_to_salary_curr   NUMBER;
    ln_mult_num                NUMBER;
    ln_period_end_mtd          DATE;
    ln_period_start_mtd        DATE;
    ln_max_row                 NUMBER;
    LN_ISR_SUBSIDY_EMPL_YTD    NUMBER;
    lv_period_type             per_time_periods.period_type%TYPE;
    ln_days_in_a_period        NUMBER;
    ln_days_in_period_sub_empl NUMBER;
    ln_period_number           NUMBER;
    ln_pre_date_paid           NUMBER := 0;
    ld_hire_date               DATE; --added for fix 6821377
    ld_first_pay_date          DATE; --added for fix 6933775
    ln_ISR_subj_adj            NUMBER;
    ln_ISR_subj_adj_ytd        NUMBER;
    ln_ISR_withheld_ytd        NUMBER;
    --ln_pay_period_days         NUMBER;
    ln_worked_days             NUMBER;
    ln_bal_ISR_non_wrkd_days   NUMBER;
    ln_bal_ISR_non_wrkd_days_ytd NUMBER;
    tot_ISR_non_wrkd_days      NUMBER;
    ln_ISR_table_factor        NUMBER;
    ln_ISR_proj_subject        NUMBER;
    ln_le_days_month           NUMBER;
    ln_le_days_year            NUMBER;
    ln_le_id                   hr_all_organization_units.organization_id%TYPE;
    ln_isr_prop_fact           NUMBER;
    ln_le_worked_days          NUMBER;
    ln_days_in_ytd             NUMBER;
    ln_wrkd_days_in_adj_period NUMBER;
    ln_proration_fac           NUMBER;
    tot_sub_basis              NUMBER;
    ln_table_id                NUMBER;
    ln_fixed_rate_ytd          NUMBER;
    ln_lower_bound_ytd         NUMBER;
    ln_marginal_rate_ytd       NUMBER;
    ln_taxable_subject_ytd     NUMBER;
    ln_marginal_tax_ytd        NUMBER;
    ln_total_tax_ytd           NUMBER;
    ln_net_tax_ytd             NUMBER;
    ln_adjusted_tax_ytd        NUMBER;
    ln_ISR_subsidy_paid_ytd    NUMBER;
    ln_no_days_in_month        NUMBER;
    ld_period_start_date       DATE;
    ld_period_end_date         DATE;
    --ln_pro_sub_emp             NUMBER;
    ld_act_hire_date           DATE;
    l_compute_subsidy_flag     CHAR(1); /*bug#8438155*/

/*    lv_calc_mode               VARCHAR2(20);
    lv_process                 VARCHAR2(20);
    lv_action_type             pay_payroll_actions.action_type%type;

    CURSOR csr_get_process_type IS
        SELECT action_type,
               pay_mx_utility.get_legi_param_val('CALC_MODE',
                                                 legislative_parameters),
               pay_mx_utility.get_legi_param_val('PROCESS',
                                                 legislative_parameters)
          FROM pay_payroll_actions
         WHERE payroll_action_id = p_payroll_action_id;*/

    CURSOR csr_get_payroll_id IS    /* bug#8932102 */
        SELECT payroll_id
          FROM per_assignments
         WHERE assignment_id = P_ASSIGNMENT_ID;

    CURSOR csr_get_hire_date IS    /* bug#8932102 */
        SELECT min(effective_start_date)
          FROM per_all_assignments_f
         WHERE assignment_id = P_ASSIGNMENT_ID
	   AND assignment_type='E';

    CURSOR csr_def_bal_id (p_balance_name     varchar2
                            ,p_db_item_suffix  varchar2) IS
         SELECT  pdb.defined_balance_id
          FROM   pay_defined_balances pdb,
                 pay_balance_dimensions pbd,
                 pay_balance_types pbt
          WHERE  pbd.balance_dimension_id  = pdb.balance_dimension_id
          AND    pbt.balance_type_id = pdb.balance_type_id
          AND    pbd.database_item_suffix = p_db_item_suffix -- '_ASG_GRE_MTD'
          AND    pbt.balance_name = p_balance_name; --'ISR Subsidy for Employment'

    CURSOR csr_date_earned IS
         SELECT ppa.effective_date l_date_paid,
                ptp.end_date l_date_earned
         FROM   per_time_periods ptp,
                pay_payroll_actions ppa
         WHERE  ppa.payroll_action_id = p_payroll_action_id
         AND    ppa.time_period_id = ptp.time_period_id;

    --Added for fix 6933775.
   /*Cursor to get the first pay period start date for the assignment*/
     CURSOR csr_get_first_pay_date IS
     SELECT MIN(ptp.start_date)
     FROM  pay_assignment_actions paa,
           pay_payroll_actions ppa,
           per_time_periods ptp
     WHERE paa.assignment_id = p_assignment_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND ptp.time_period_id = ppa.time_period_id
       AND ppa.action_type IN ('R', 'Q', 'B')
       AND (to_char(l_date_paid,'yyyymm') = to_char(ptp.end_date,'yyyymm')
              OR
              l_date_paid BETWEEN ptp.start_date AND ptp.end_date
            );

    CURSOR csr_get_period_count_in_month IS
       SELECT ROWNUM mult_num
              ,end_date period_end_mtd
              ,start_date period_start_mtd
              ,period_type
       FROM   PER_TIME_PERIODS ptp
       WHERE  payroll_id = ln_payroll_id
       AND    (TO_CHAR(l_date_paid,'yyyymm') = TO_CHAR(end_date,'yyyymm')
              OR
              l_date_paid BETWEEN start_date AND end_date
              )
       AND ld_hire_date <= end_date
       AND start_date >= NVL(ld_first_pay_date,start_date)
       ORDER BY end_date;

    CURSOR csr_get_no_of_days_in_period(p_payroll_id NUMBER) IS
       SELECT end_date - start_date +1 period_days
       FROM   PER_TIME_PERIODS ptp
       WHERE  payroll_id = p_payroll_id
       AND    TO_CHAR(l_date_earned,'yyyymmdd') = TO_CHAR(end_date,'yyyymmdd');

    CURSOR csr_get_no_of_days_in_ytd(p_payroll_id NUMBER) IS
       SELECT ptp1.end_date-TRUNC(to_date(ptp.start_date),'YEAR') + 1 period_days , TRUNC(to_date(ptp.start_date),'YEAR'), ptp1.end_date
       FROM PER_TIME_PERIODS ptp, PER_TIME_PERIODS ptp1
       WHERE ptp.period_num = '1'
       AND l_date_earned BETWEEN ptp1.start_date AND ptp1.end_date
       AND ptp.payroll_id = p_payroll_id
       AND ptp1.payroll_id = p_payroll_id
       AND (ptp1.end_date-TRUNC(to_date(ptp.start_date),'YEAR') + 1) BETWEEN '1' AND '379';

    CURSOR csr_get_table_id(p_table_name VARCHAR2) IS
       SELECT user_table_id
       FROM   pay_user_tables
       WHERE  upper(user_table_name) = upper(p_table_name)
       AND    nvl (business_group_id,
                p_business_group_id)   = p_business_group_id
       AND    nvl(legislation_code, 'MX') = 'MX';

    CURSOR csr_get_table_value(p_table_id NUMBER, p_proration_fac NUMBER, p_col_name VARCHAR2, p_row_value NUMBER) IS
       SELECT  CINST.value*p_proration_fac
        FROM    pay_user_tables                    TAB
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_column_instances_f        CINST
        WHERE   TAB.user_table_id                = p_table_id
        AND     C.user_table_id                  = TAB.user_table_id
        AND     nvl (C.business_group_id,
                      p_business_group_id)        = p_business_group_id
        AND     nvl (C.legislation_code,
                     'MX')                       = 'MX'
        AND     upper (C.user_column_name)       = upper (p_col_name)
        AND     CINST.user_column_id             = C.user_column_id
        AND     R.user_table_id                  = TAB.user_table_id
        AND     p_date_earned           BETWEEN R.effective_start_date
        AND     R.effective_end_date
        AND     nvl (R.business_group_id,
                      p_business_group_id)       = p_business_group_id
        AND     nvl (R.legislation_code,
                     'MX')                        = 'MX'
        AND     fnd_number.canonical_to_number (p_row_value)
        BETWEEN fnd_number.canonical_to_number (R.row_low_range_or_name*p_proration_fac)
        AND     fnd_number.canonical_to_number (R.row_high_range*p_proration_fac)
        AND     TAB.user_key_units               = 'N'
        AND     CINST.user_row_id                = R.user_row_id
        AND     p_date_earned           BETWEEN CINST.effective_start_date
        AND     CINST.effective_end_date
        AND     nvl (CINST.business_group_id,
                      p_business_group_id)       = p_business_group_id
        AND     nvl (CINST.legislation_code,
                     'MX')                        = 'MX';

    CURSOR csr_get_no_of_days_in_mtd (p_payroll_id NUMBER) IS
       SELECT end_date-TRUNC(start_date, 'MONTH')+1, end_date, TRUNC(start_date, 'MONTH')
       FROM per_time_periods
       WHERE payroll_id = p_payroll_id
       AND l_date_paid BETWEEN start_date AND end_date;

    CURSOR csr_get_act_hire_date IS
       SELECT MIN(pps.date_start)
       FROM per_periods_of_service pps , per_assignments_f paf
       WHERE paf.assignment_id = P_ASSIGNMENT_ID
       AND pps.person_id = paf.person_id;

    CURSOR csr_get_compute_subsidy_flag IS   /*bug#8438155*/
        SELECT nvl(hsck.SEGMENT11,'Y')
          FROM per_assignments_f      paf,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               hr_soft_coding_keyflex hsck
         WHERE paf.assignment_id        = paa.assignment_id
           AND paa.payroll_action_id    = ppa.payroll_action_id
           AND paa.assignment_action_id = p_assignment_action_id
           AND hsck.soft_coding_keyflex_id= paf.soft_coding_keyflex_id
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

  BEGIN
    l_proc_name := g_proc_name ||'CALCULATE_ISR_TAX';
    hr_utility_trace('Entering '||l_proc_name);
    hr_utility_trace('p_payroll_action_id: '||p_payroll_action_id);
    hr_utility_trace('p_assignment_action_id: '||p_assignment_action_id);
    hr_utility_trace('p_business_group_id: '||p_business_group_id);
    hr_utility_trace('p_assignment_id: '||p_assignment_id);
    hr_utility_trace('p_tax_unit_id: '||p_tax_unit_id);
    hr_utility_trace('p_date_earned: '||
                                     fnd_date.date_to_canonical(p_date_earned));
    hr_utility_trace('p_run_type: '||p_run_type);
    hr_utility_trace('p_calc_mode: '||p_calc_mode);
    hr_utility_trace('p_subject_amount: '||p_subject_amount);
    hr_utility_trace('p_isr_rates_table: '||p_isr_rates_table);
    hr_utility_trace('p_subsidy_table: '||p_subsidy_table);
    hr_utility_trace('p_credit_to_salary_table: '||p_credit_to_salary_table);
    hr_utility_trace('l_credit_to_salary_table: '||l_credit_to_salary_table);

    ln_ISR_proj_subject := p_subject_amount;

    OPEN csr_date_earned;
    FETCH csr_date_earned INTO l_date_paid, l_date_earned;
    CLOSE csr_date_earned;

    hr_utility_trace('l_date_earned: '||l_date_earned);
    hr_utility_trace('l_date_paid: '||l_date_paid);

    --Start of Bug Fix 6852627
    /*Calculation for Proration*/
    OPEN csr_get_payroll_id;   /*bug#8932102 */
      FETCH csr_get_payroll_id INTO ln_payroll_id;
    CLOSE csr_get_payroll_id;

    OPEN csr_get_hire_date;
      FETCH csr_get_hire_date INTO ld_hire_date;
    CLOSE csr_get_hire_date;

    hr_utility_trace('payroll_id '||ln_payroll_id);
    hr_utility_trace('ld_hire_date '||ld_hire_date);

    hr_utility_trace('Getting the actual number of days in pay period ...');

    OPEN csr_get_no_of_days_in_period(ln_payroll_id);
       FETCH  csr_get_no_of_days_in_period INTO ln_days_in_a_period;
    CLOSE csr_get_no_of_days_in_period;

    hr_utility_trace('Number of days in the pay period   : '||ln_days_in_a_period);

    hr_utility_trace('Getting the total number of days in pay period as deifned in GRE/LE...');

    ln_le_id := hr_mx_utility.get_legal_employer(
                                  p_business_group_id => p_business_group_id
                                 ,p_tax_unit_id       => p_tax_unit_id);

    pay_mx_utility.get_no_of_days_for_org( p_business_group_id => p_business_group_id
                                          ,p_org_id            => ln_le_id
                                          ,p_gre_or_le         => 'LE'
                                          ,p_days_month        => ln_le_days_month
                                          ,p_days_year         => ln_le_days_year);

    IF (ln_le_days_month IS NULL OR ln_le_days_month = -999) THEN
       ln_le_days_month := ln_days_in_a_period ;
    END IF;

    /*ln_pay_period_days := pay_mx_utility.get_days_in_pay_period( p_business_group_id
                                                                ,p_tax_unit_id
                                                                ,ln_payroll_id);*/
    hr_utility_trace('Average days in the month at LE :'||to_char(ln_le_days_month));

    OPEN csr_def_bal_id ('ISR Non Working Days','_ASG_GRE_RUN');
     FETCH csr_def_bal_id INTO ln_def_bal_id;
    CLOSE csr_def_bal_id;

    hr_utility_trace('ISR Non Working Days def bal id '||to_char(ln_def_bal_id));
    ln_bal_ISR_non_wrkd_days := pay_balance_pkg.get_value(ln_def_bal_id,
                                                            p_assignment_action_id,
                                                            p_tax_unit_id,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            'TRUE');
    hr_utility_trace('ISR Non Working Days Bal Val '||to_char(ln_bal_ISR_non_wrkd_days));

    hr_utility_trace('Get the factor for proration ln_le_days_month/ln_days_in_a_period ..');
    ln_isr_prop_fact := ln_le_days_month/ln_days_in_a_period;
    hr_utility_trace('ln_isr_prop_fact :' || TO_CHAR(ln_isr_prop_fact));

    hr_utility_trace('getting worked days.. ');
    ln_worked_days := ln_days_in_a_period - nvl(ln_bal_ISR_non_wrkd_days,0);

    ln_le_worked_days :=  (ln_le_days_month - (nvl(ln_bal_ISR_non_wrkd_days,0) *  ln_isr_prop_fact)) ;

    hr_utility_trace('Actual worked days in the period for ISR Tax '||to_char(ln_worked_days));
    hr_utility_trace('worked days for proration in the period for ISR Tax '||to_char(ln_le_worked_days));
    --End of Bug Fix 6852627
    IF to_char(l_date_paid,'yyyymmdd')
       >= to_char(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') AND P_CALC_MODE = 'ARTICLE113' THEN
          hr_utility_trace('ISr Proration in 2008');
        IF nvl(ln_bal_ISR_non_wrkd_days,0) > 0 AND nvl(ln_bal_ISR_non_wrkd_days,0) < ln_days_in_a_period THEN

	   ln_ISR_proj_subject := ROUND(((ln_ISR_proj_subject * ln_le_days_month) / ln_le_worked_days),2);

	   hr_utility_trace('ISR Projected value in the pay period '||to_char(ln_ISR_proj_subject));
        END IF;

    END IF;

    hr_utility_trace('Final Subject amount after proration: '||ln_ISR_proj_subject);
    /* Article 113, 114 and 115 */

    ln_fixed_rate    := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Fixed Rate'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_fixed_rate: '||ln_fixed_rate);

    ln_marginal_rate := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Marginal Rate'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_marginal_rate: '||ln_marginal_rate);

    ln_lower_limit   := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_isr_rates_table
                                 ,'Lower Bound'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

    hr_utility_trace('ln_lower_limit: '||ln_lower_limit);

    ln_marginal_tax  := (ln_marginal_rate/100) * (ln_ISR_proj_subject -
                                                  ln_lower_limit);

    hr_utility_trace('ln_marginal_tax: '||ln_marginal_tax);

    p_isr_calculated := ln_fixed_rate + ln_marginal_tax;

    hr_utility_trace('p_isr_calculated: '||p_isr_calculated);

    IF TO_CHAR(l_date_paid,'yyyymmdd')
       < TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN

       /* Subsidy Calculation */
       ln_fixed_subsidy       := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Fixed Rate'
                                    ,TO_CHAR(ln_ISR_proj_subject)));

       hr_utility_trace('ln_fixed_subsidy: '||ln_fixed_subsidy);

       ln_marginal_subsidy    := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Marginal Rate'
                                    ,TO_CHAR(ln_ISR_proj_subject)));

       hr_utility_trace('ln_marginal_subsidy: '||ln_marginal_subsidy);

       ln_subsidy_lower_limit := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                     p_business_group_id
                                    ,p_subsidy_table
                                    ,'Lower Bound'
                                    ,TO_CHAR(ln_ISR_proj_subject)));


       hr_utility_trace('ln_subsidy_lower_limit: '||ln_subsidy_lower_limit);

       ln_tax_subsidy_percentage := hr_mx_utility.get_tax_subsidy_percent(
                                                      p_business_group_id
                                                     ,p_tax_unit_id);

       hr_utility_trace('ln_tax_subsidy_percentage: '||ln_tax_subsidy_percentage);

       /*OPEN csr_get_process_type;
           FETCH csr_get_process_type INTO lv_action_type,
                                           lv_calc_mode,
                                           lv_process;
       CLOSE csr_get_process_type;*/

       IF (p_calc_mode = 'BEST' OR p_calc_mode = 'ARTICLE141') THEN
           -- Calculate subsidy for Article 141
           hr_utility_trace('Calculating subsidy for Article 141 ...');
           ln_total_subsidy := ln_fixed_rate * (ln_fixed_subsidy/100) +
                               (ln_marginal_subsidy/100) *
                               (ln_marginal_rate/100) *
                               (ln_ISR_proj_subject - ln_subsidy_lower_limit);
       ELSE
           ln_total_subsidy := ln_fixed_subsidy +
                                  (ln_marginal_subsidy/100) *
                                  (ln_marginal_rate/100) *
                                  (ln_ISR_proj_subject - ln_subsidy_lower_limit);
       END IF;
       hr_utility_trace('ln_total_subsidy: '||ln_total_subsidy);

       p_isr_creditable_subsidy := (ln_tax_subsidy_percentage/100) *
                                                               ln_total_subsidy;

       hr_utility_trace('p_isr_creditable_subsidy: '||p_isr_creditable_subsidy);

       p_isr_non_creditable_subsidy := ln_total_subsidy - p_isr_creditable_subsidy;

       hr_utility_trace('p_isr_non_creditable_subsidy: '||
                         p_isr_non_creditable_subsidy);

    ELSE
        p_isr_creditable_subsidy := 0;
        p_isr_non_creditable_subsidy := 0;
    END IF; --  end of subsidy calc

    /* Credit To Salary Calculation */

    /* Bug#8438155: created new cursor csr_get_compute_subsidy_flag to fetch
       the value 'Compute Subsidy for Employment' from 'MX Statutory Info'
       If this value is 'N' then below subsidy calculation will be skipped */

        OPEN csr_get_compute_subsidy_flag;
        FETCH csr_get_compute_subsidy_flag into l_compute_subsidy_flag;
        CLOSE csr_get_compute_subsidy_flag;

        hr_utility_trace('l_compute_subsidy_flag '||l_compute_subsidy_flag);
        /*bug7445486  bug#8438155*/
    IF ( p_credit_to_salary_table <> 'NONE' and P_CALC_MODE <>'ARTICLE142' AND l_compute_subsidy_flag <> 'N') THEN

       hr_utility_trace('inside subsidy '||p_credit_to_salary_table|| ' --- '||TO_CHAR(ln_ISR_proj_subject));
       p_credit_to_salary := FND_NUMBER.canonical_to_number(hruserdt.get_table_value (
                                  p_business_group_id
                                 ,p_credit_to_salary_table
                                 ,'Amount'
                                 ,TO_CHAR(ln_ISR_proj_subject)));

       P_CREDIT_TO_SALARY := nvl(P_CREDIT_TO_SALARY,0);

       IF TO_CHAR(l_date_paid,'yyyymmdd')
          >= TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN

    OPEN csr_get_payroll_id;   /*bug#8932102 */
      FETCH csr_get_payroll_id INTO ln_payroll_id;
    CLOSE csr_get_payroll_id;

    OPEN csr_get_hire_date;
      FETCH csr_get_hire_date INTO ld_hire_date;
    CLOSE csr_get_hire_date;

    hr_utility_trace('payroll_id '||ln_payroll_id);
    hr_utility_trace('ld_hire_date '||ld_hire_date);

          -- get ISR Subject balance for month

          OPEN csr_def_bal_id ('ISR Subject','_ASG_MTD');
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

          hr_utility_trace('ISR Subject def bal id '||ln_def_bal_id);

          ln_bal_amt := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

          hr_utility_trace('MTD Subject Amt - ln_bal_amt '||to_char(ln_bal_amt));
         /*Get the previous ISR Subject adjusted amount due to proration
           this will have impact only in semi-monthly and weekely payroll*/
          OPEN csr_def_bal_id ('ISR Subject Adjusted','_ASG_MTD');
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

          hr_utility_trace('ISR Subject Adjusted def bal id '||ln_def_bal_id);
          ln_ISR_subj_adj :=  pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 'TRUE');
          hr_utility_trace('ISR Subject Adjusted Amount MTD - ln_ISR_subj_adj'||ln_ISR_subj_adj);
--	  ln_bal_amt := ln_bal_amt + ln_ISR_subj_adj;
--          hr_utility_trace('Actual subject value is ln_bal_amt + ln_ISR_subj_adj  '||ln_bal_amt);
          -- get ISR Subsidy for Employement balance for month
           ln_ISR_subj_adj := ln_ISR_subj_adj + ln_ISR_proj_subject;
           hr_utility_trace('Actual subject value is ln_ISR_subj_adj + ln_ISR_proj_subject  '||ln_ISR_subj_adj);

	   OPEN csr_def_bal_id ('ISR Subsidy for Employment','_ASG_MTD');
            FETCH csr_def_bal_id INTO ln_def_bal_id;
           CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_bal_sub := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

           hr_utility_trace('ISR Sub for Empl Bal Sub '||to_char(ln_bal_sub));

           OPEN csr_def_bal_id ('ISR Subsidy for Employment Paid','_ASG_MTD');
            FETCH csr_def_bal_id INTO ln_def_bal_id;
           CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_bal_sub_paid := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

           hr_utility_trace('ISR Sub for Empl Bal Sub Paid '||to_char(ln_bal_sub_paid));

           if ln_payroll_id is not null then
              select min(period_type)
              into   lv_period_type
              from   pay_payrolls_f
              where  payroll_id = ln_payroll_id;
           end if;

           OPEN csr_get_first_pay_date;
	     FETCH csr_get_first_pay_date INTO ld_first_pay_date;
	   CLOSE csr_get_first_pay_date;

           ln_isr_subject_mtd := CONVERT_INTO_MONTHLY_AVG_SAL (p_business_group_id
                                                           ,p_tax_unit_id
                                                           ,ln_payroll_id
                                                           ,ln_ISR_proj_subject
                                                           ,l_date_paid
							   ,ld_hire_date
							   ,ld_first_pay_date
                                                           ,ln_period_number)
                                + (ln_ISR_subj_adj - ln_ISR_proj_subject);

           hr_utility_trace('ln_isr_subject_mtd  : '||ln_isr_subject_mtd);
           hr_utility_trace('ln_days_in_a_period  : '||ln_days_in_a_period);
           hr_utility_trace('ln_period_number  : '||ln_period_number);

           open csr_get_period_count_in_month;
           loop
              fetch csr_get_period_count_in_month into ln_mult_num,
	                                              ln_period_end_mtd,
						      ln_period_start_mtd,
						      lv_period_type;
             exit when csr_get_period_count_in_month%NOTFOUND;

	     select least(count(*),1)
	     into   ln_pre_date_paid
	     from   pay_payroll_actions ppa,
	            pay_assignment_actions paa,
		    per_time_periods ptp
	     where  ppa.payroll_action_id = paa.payroll_action_id
	     and    ptp.time_period_id = ppa.time_period_id
	     and    paa.assignment_id = p_assignment_id
	     and    to_char(ptp.end_date,'yyyymm') = to_char(l_date_paid,'yyyymm')
	     and    to_char(ppa.effective_date,'yyyymm') < to_char(l_date_paid,'yyyymm')
	     AND    ld_hire_date <= ptp.end_date;

             hr_utility_trace('l_date_paid '||to_char(l_date_paid,'yyyymm'));
             hr_utility_trace('ln_pre_date_paid '||to_char(ln_pre_date_paid));

             IF l_date_paid >= ln_period_start_mtd and
		l_date_paid <= ln_period_end_mtd  then
                ln_period_number := ln_period_number - ln_pre_date_paid;
                hr_utility_trace('Actual ln_period_number '||to_char(ln_period_number));
             end if;

           end loop;
         close csr_get_period_count_in_month;


         IF lv_period_type = 'Semi-Month' THEN
	     ln_days_in_period_sub_empl := 15;
         ELSIF lv_period_type = 'Ten Days' then
            ln_days_in_period_sub_empl := 10;
	 ELSE
            ln_days_in_period_sub_empl := ln_days_in_a_period; /*bug 7677805*/
	 END IF ;
	 p_credit_to_salary := FND_NUMBER.canonical_to_number(get_table_value (
                                  p_business_group_id
                                 ,p_credit_to_salary_table
                                 ,'Amount'
                                 ,TO_CHAR(ln_ISR_subj_adj)
                                 ,l_date_paid
                                 ,ln_days_in_a_period
                                 ,ln_period_number
                                 ,lv_period_type));

          hr_utility_trace('Total Subsidy for Empl '||to_char(p_credit_to_salary));

          ln_credit_to_salary_max := p_credit_to_salary;

          P_CREDIT_TO_SALARY := (ln_credit_to_salary_max/30.4) * ln_days_in_period_sub_empl;

          ln_credit_to_salary_curr := P_CREDIT_TO_SALARY;

          hr_utility_trace('Current Period Subsidy for Empl '||to_char(p_credit_to_salary));

          select count(*) max_row
          into   ln_max_row
          from PER_TIME_PERIODS ptp1
          where payroll_id = ln_payroll_id
          and to_char(l_date_paid,'yyyymm') = to_char(end_date,'yyyymm');

          open csr_get_period_count_in_month;
          loop
             fetch csr_get_period_count_in_month into ln_mult_num,
	                                              ln_period_end_mtd,
						      ln_period_start_mtd,
						      lv_period_type;
             exit when csr_get_period_count_in_month%NOTFOUND;
             if ln_period_end_mtd = l_date_earned then

	        if to_char(ln_period_end_mtd,'yyyymm') = to_char(l_date_paid,'yyyymm') and
    		   to_char(ln_period_end_mtd,'yyyymmdd') >= to_char(last_day(l_date_paid),'yyyymmdd') then

                   P_CREDIT_TO_SALARY := least(ln_credit_to_salary_max,
		                         P_CREDIT_TO_SALARY * ln_mult_num );
                   hr_utility_trace('outside/last day of month '||to_char(p_credit_to_salary));
                else
                   P_CREDIT_TO_SALARY := least(ln_credit_to_salary_max,
		                         P_CREDIT_TO_SALARY * (ln_mult_num - ln_pre_date_paid) );
                   hr_utility_trace('With in month '||to_char(p_credit_to_salary));
                end if;

                hr_utility_trace('max allowd Subsidy for Empl '||to_char(p_credit_to_salary));
                 IF l_date_paid >= ln_period_start_mtd AND
		   l_date_paid <= ln_period_end_mtd AND
                   (lv_period_type = 'Calendar Month' OR (lv_period_type = 'Semi-Month' AND ln_period_number = 2)
                   OR (lv_period_type = 'Ten Days' AND ln_period_number = 3))
		THEN
                   P_CREDIT_TO_SALARY := ln_credit_to_salary_max;
                   hr_utility_trace('Final period Subsidy for Empl '||to_char(p_credit_to_salary));
                end if;
                P_CREDIT_TO_SALARY := P_CREDIT_TO_SALARY - ln_bal_sub;
                hr_utility_trace('Subsidy for Empl '||to_char(p_credit_to_salary));
             end if;
          end loop;
          close csr_get_period_count_in_month;
      END IF;
    ELSE
       p_credit_to_salary := 0;
    END IF;

    P_CREDIT_TO_SALARY := nvl(P_CREDIT_TO_SALARY,0);
    hr_utility_trace('p_credit_to_salary: '||p_credit_to_salary);

    /* ISR Withheld Calculation */

    ln_isr_withheld := p_isr_calculated -
                       p_isr_creditable_subsidy -
                       p_credit_to_salary;


    hr_utility_trace('ln_isr_withheld B4: '||ln_isr_withheld);

    /*Incuded the proration logic based on balance ISR Non working days*/
    --Start of Bug fix 6852627
    IF to_char(l_date_paid,'yyyymmdd')
       >= to_char(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') AND P_CALC_MODE = 'ARTICLE113' THEN
      IF nvl(ln_bal_ISR_non_wrkd_days,0) > 0 AND nvl(ln_bal_ISR_non_wrkd_days,0) < ln_days_in_a_period THEN

      hr_utility_trace('-- Non workings days are feeded, need to proproate ISR Tax --');

      hr_utility_trace('Getting the table factor value for ISR Tax calculation');
          ln_ISR_table_factor :=  ROUND(((ln_days_in_a_period * 30.4)/ln_le_days_month),2);

      hr_utility_trace('Factor value for '||lv_period_type||' payroll is '||TO_CHAR(ln_ISR_table_factor));

      hr_utility_trace('Proration logic on ISR Tax for '||TO_CHAR(ln_worked_days)||' working days');

      /*ln_pro_sub_emp := (p_credit_to_salary/ln_ISR_table_factor)* ln_worked_days ;

      hr_utility_trace('Prorated Subsidy For Employment is '||TO_CHAR(ln_pro_sub_emp));*/

      ln_isr_withheld := (ln_isr_withheld / ln_ISR_table_factor) * ln_worked_days ;

      hr_utility_trace('Prorated ISR with held '||TO_CHAR(ln_isr_withheld));
      hr_utility_trace('Start of ISR Subject proration ');

      ELSIF nvl(ln_bal_ISR_non_wrkd_days,0) < 0  OR nvl(ln_bal_ISR_non_wrkd_days,0) > ln_days_in_a_period THEN
        hr_utility_trace('ISR Non Worked Days value is invalid ');
	hr_utility.set_message(801, 'PAY_MX_INVALID_ISR_NON_WRK_DAY');
	hr_utility.raise_error;

      ELSIF nvl(ln_bal_ISR_non_wrkd_days,0) = ln_days_in_a_period THEN
        ln_isr_withheld := 0;
        p_credit_to_salary_paid := 0;
        p_isr_calculated := 0;
	p_credit_to_salary := 0;

      END IF;
    END IF;
    --End of Bug Fix 6852627

    IF ln_isr_withheld < 0 THEN
       p_credit_to_salary_paid := ABS(ln_isr_withheld);
       ln_isr_withheld := 0;
    ELSE
        p_credit_to_salary_paid := 0;
     END IF;
   /*To feed ISR Subject Adjusted Balance*/
   IF TO_CHAR(l_date_paid,'yyyymmdd')
          >= TO_CHAR(fnd_date.canonical_to_date('2008/01/01'),'yyyymmdd') THEN
      p_isr_creditable_subsidy := ln_ISR_proj_subject;
      hr_utility_trace(' Feeding ISR Subject Adjusted Balance value in 2008 = p_isr_creditable_subsidy'||p_isr_creditable_subsidy);
    END IF;
   IF p_run_type = 'ADJTAX' OR p_run_type = 'MTDTAXADJ' THEN

          IF p_run_type = 'ADJTAX' THEN
	  lv_dimension_type := '_ASG_YTD';
	  lv_proration_table := 'isr rates_annual';
	  hr_utility_trace('The Tax Adjustment type is Periodic Tax Adjustment ');
	  ELSIF p_run_type = 'MTDTAXADJ' THEN
	  lv_dimension_type := '_ASG_MTD';
	  lv_proration_table := 'isr rates_month';
	  hr_utility_trace('The Tax Adjustment type is Monthly Tax Adjustment ');
	  END IF;

          OPEN csr_def_bal_id ('ISR Subject',lv_dimension_type);
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

          hr_utility_trace('ISR Subject def bal id '||ln_def_bal_id);
          ln_ISR_subj_adj_ytd :=  pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 'TRUE');
          hr_utility_trace('YTD ISR Subject def bal is '||ln_ISR_subj_adj_ytd);

	  tot_sub_basis := ln_ISR_subj_adj_ytd;

          hr_utility_trace('Total Subject Basis for tax adjustment is '||tot_sub_basis);

          OPEN csr_def_bal_id ('ISR Withheld',lv_dimension_type);
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Withheld def bal id '||to_char(ln_def_bal_id));

           ln_ISR_withheld_ytd := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

	   hr_utility_trace('ISR withheld is '||ln_ISR_withheld_ytd);

          OPEN csr_def_bal_id ('ISR Subsidy for Employment Paid',lv_dimension_type);
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_ISR_subsidy_paid_ytd := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');

	   hr_utility_trace('ISR subsidy for employment paid is '||ln_ISR_subsidy_paid_ytd);

           ln_ISR_withheld_ytd := ln_ISR_withheld_ytd - ln_ISR_subsidy_paid_ytd;
           hr_utility_trace('YTD ISR Sub for Empl Bal Sub Paid '||to_char(ln_ISR_withheld_ytd));
          OPEN csr_def_bal_id ('ISR Subsidy for Employment',lv_dimension_type);
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

           hr_utility_trace('ISR Sub for Empl def bal id '||to_char(ln_def_bal_id));

           ln_ISR_subsidy_empl_ytd := pay_balance_pkg.get_value(ln_def_bal_id,
                                 P_ASSIGNMENT_ACTION_ID,
                                 p_tax_unit_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'TRUE');
          hr_utility_trace('YTD ISR Sub for Empl Bal Sub '||to_char(ln_ISR_subsidy_empl_ytd));
	  /*IF nvl(ln_bal_ISR_non_wrkd_days,0) > 0 AND nvl(ln_bal_ISR_non_wrkd_days,0) < ln_days_in_a_period THEN
          tot_subsidy_empl := ln_ISR_subsidy_empl_ytd + ln_pro_sub_emp;
          ELSE*/
          tot_subsidy_empl := ln_ISR_subsidy_empl_ytd + p_credit_to_salary;
	  --END IF;
          hr_utility_trace('Total Subsidy for Employment '||to_char(tot_subsidy_empl));
          OPEN csr_def_bal_id ('ISR Non Working Days',lv_dimension_type);
          FETCH csr_def_bal_id INTO ln_def_bal_id;
          CLOSE csr_def_bal_id;

         hr_utility_trace('ISR Non Working Days def bal id '||to_char(ln_def_bal_id));
         ln_bal_ISR_non_wrkd_days_ytd := pay_balance_pkg.get_value(ln_def_bal_id,
                                                            p_assignment_action_id,
                                                            p_tax_unit_id,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            'TRUE');
        hr_utility_trace('YTD ISR Non Working Days Bal '||to_char(ln_bal_ISR_non_wrkd_days_ytd));
        tot_ISR_non_wrkd_days := ln_bal_ISR_non_wrkd_days_ytd;
        hr_utility_trace('Total Non Worked days '||to_char(tot_ISR_non_wrkd_days));

        IF p_run_type = 'ADJTAX' THEN
        OPEN csr_get_no_of_days_in_ytd(ln_payroll_id);
        FETCH csr_get_no_of_days_in_ytd INTO ln_days_in_ytd, ld_period_start_date, ld_period_end_date;
        CLOSE csr_get_no_of_days_in_ytd;
        hr_utility_trace('Period Start date is'||to_char(ld_period_start_date));
        hr_utility_trace('Period End date is'||to_char(ld_period_end_date));

	OPEN csr_get_act_hire_date;
	FETCH csr_get_act_hire_date INTO ld_act_hire_date;
	CLOSE csr_get_act_hire_date;

	hr_utility_trace('The actual Hire Date is'||to_char(ld_act_hire_date));

        IF ld_act_hire_date >ld_period_start_date THEN
	ln_days_in_ytd := ld_period_end_date - ld_act_hire_date +1;
        hr_utility_trace('Total days in YTD'||to_char(ln_days_in_ytd));
	END IF;

	IF ln_days_in_ytd > 365 THEN
        ln_days_in_ytd := 365;
	END IF;

	ELSIF p_run_type = 'MTDTAXADJ' THEN
	OPEN csr_get_no_of_days_in_mtd (ln_payroll_id);
	FETCH csr_get_no_of_days_in_mtd INTO ln_days_in_ytd , ld_period_end_date, ld_period_start_date;
	CLOSE csr_get_no_of_days_in_mtd;
        hr_utility_trace('Period Start date is'||to_char(ld_period_start_date));
        hr_utility_trace('Period End date is'||to_char(ld_period_end_date));

	OPEN csr_get_act_hire_date;
	FETCH csr_get_act_hire_date INTO ld_act_hire_date;
	CLOSE csr_get_act_hire_date;

	hr_utility_trace('The actual Hire Date is'||to_char(ld_act_hire_date));

	IF ld_act_hire_date > ld_period_start_date THEN
	ln_days_in_ytd := ld_period_end_date - ld_act_hire_date +1;
        hr_utility_trace('Total days in YTD'||to_char(ln_days_in_ytd));
	END IF;
	END IF;

        ln_wrkd_days_in_adj_period := ln_days_in_ytd - tot_ISR_non_wrkd_days;
        hr_utility_trace('Total Worked days YTD '||to_char(ln_wrkd_days_in_adj_period));

	IF p_run_type = 'ADJTAX' THEN
        ln_proration_fac := ln_wrkd_days_in_adj_period/365;
        hr_utility_trace('Proration factor for YTD adj'||to_char(ln_proration_fac));

	ELSIF p_run_type = 'MTDTAXADJ' THEN
	ln_no_days_in_month := LAST_DAY(ld_period_end_date) - TRUNC(ld_period_end_date, 'MONTH') +1;
        hr_utility_trace('The total number of days in the adjustment month'||to_char(ln_no_days_in_month));
	ln_proration_fac := (ln_wrkd_days_in_adj_period * (30.4/ln_no_days_in_month))/30.4;
        hr_utility_trace('Proration factor for MTD adj'||to_char(ln_proration_fac));
	END IF;

	OPEN csr_get_table_id (lv_proration_table);
	FETCH csr_get_table_id INTO ln_table_id;
	CLOSE csr_get_table_id;

        hr_utility_trace('Table Id is'||to_char(ln_table_id));

        OPEN csr_get_table_value (ln_table_id, ln_proration_fac, 'FIXED RATE', tot_sub_basis);
	FETCH csr_get_table_value INTO ln_fixed_rate_ytd;
	CLOSE csr_get_table_value;
        hr_utility_trace('Fixed Rate is '||to_char(ln_fixed_rate_ytd));

        OPEN csr_get_table_value (ln_table_id, ln_proration_fac, 'LOWER BOUND', tot_sub_basis);
	FETCH csr_get_table_value INTO ln_lower_bound_ytd;
	CLOSE csr_get_table_value;
	hr_utility_trace('Lower Bound value is '||to_char(ln_lower_bound_ytd));

        OPEN csr_get_table_value (ln_table_id, ln_proration_fac, 'MARGINAL RATE', tot_sub_basis);
	FETCH csr_get_table_value INTO ln_marginal_rate_ytd;
	CLOSE csr_get_table_value;

	ln_marginal_rate_ytd := ln_marginal_rate_ytd/ln_proration_fac;
        hr_utility_trace('Marginal Rate is '||to_char(ln_marginal_rate_ytd));

	ln_taxable_subject_ytd := tot_sub_basis-ln_lower_bound_ytd;
        hr_utility_trace('The Difference amount is '||to_char(ln_taxable_subject_ytd));

	ln_marginal_tax_ytd := ln_taxable_subject_ytd * (ln_marginal_rate_ytd/100);
	hr_utility_trace('The Marginal Tax '||to_char(ln_marginal_tax_ytd));

	ln_total_tax_ytd := ln_marginal_tax_ytd + ln_fixed_rate_ytd;
	hr_utility_trace('The Total Tax is '||to_char(ln_total_tax_ytd));

	p_isr_calculated := ln_total_tax_ytd;

	ln_net_tax_ytd := ln_total_tax_ytd - tot_subsidy_empl;
	hr_utility_trace('The Net Tax is '||to_char(ln_net_tax_ytd));

	ln_adjusted_tax_ytd := ln_net_tax_ytd - ln_ISR_withheld_ytd;
	hr_utility_trace('The Adjusted Tax is '||to_char(ln_adjusted_tax_ytd));

	ln_isr_withheld := ROUND(ln_adjusted_tax_ytd,2);

	IF ln_isr_withheld < 0 THEN
	p_credit_to_salary_paid := ABS(ln_isr_withheld);
	ln_isr_withheld := 0;
	ELSE
	p_credit_to_salary_paid := 0;
	END IF;
    END IF;

    hr_utility_trace('p_credit_to_salary_paid: '||p_credit_to_salary_paid);
    hr_utility_trace('ln_isr_withheld Final: '||ln_isr_withheld);
    hr_utility_trace('Leaving '||l_proc_name);

    RETURN ln_isr_withheld;

    EXCEPTION
        WHEN OTHERS THEN
            hr_utility_trace('Exception in '||l_proc_name||': '||SQLERRM);
            RAISE;
END CALCULATE_ISR_TAX;

/****************************************************************************
  Name        : CONVERT_MONTHLY_TO_PERIOD
  Description : This function has
                1. Input Parameters as Contexts:
                   - BUSINESS_GROUP_ID
                   - TAX_UNIT_ID
                   - PAYROLL_ID
                2. Input Parameters as Parameter:
                   - PERIODIC_EARNINGS
*****************************************************************************/

/*FUNCTION CONVERT_MONTHLY_TO_PERIOD ( p_business_group_id   NUMBER
                                    ,p_tax_unit_id         NUMBER
                                    ,p_payroll_id          NUMBER
                                    ,p_periodic_value      NUMBER
                                    ,P_date_earned         DATE)
RETURN NUMBER IS

  ln_periodic_value           NUMBER;
  ln_days_in_a_period         NUMBER;

  CURSOR csr_get_period_count_in_month IS
       select end_date - start_date +1 period_days
       from   PER_TIME_PERIODS ptp
       where  payroll_id = p_payroll_id
       and    to_char(p_date_earned,'yyyymmdd') = to_char(end_date,'yyyymmdd');

BEGIN

  hr_utility_trace('Entering ..CONVERT_MONTHLY_TO_PERIOD');
  hr_utility_trace('p_periodic_value: ' ||p_periodic_value);

  open csr_get_period_count_in_month;
  fetch csr_get_period_count_in_month into ln_days_in_a_period;
  close csr_get_period_count_in_month;

  ln_periodic_value := (p_periodic_value/30.4) * ln_days_in_a_period;

  hr_utility_trace('ln_periodic_value: ' ||ln_periodic_value);
  hr_utility_trace('Leaving ..CONVERT_MONTHLY_TO_PERIOD');

  RETURN ln_periodic_value;

END CONVERT_MONTHLY_TO_PERIOD; /*

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
RETURN NUMBER IS

  ln_periodic_earnings       NUMBER;
  ln_days_in_a_month         NUMBER;
  lv_period_type             pay_all_payrolls_f.period_type%TYPE;

BEGIN

  hr_utility_trace('Entering ..CONVERT_INTO_MONTHLY_SALARY');
  hr_utility_trace('p_periodic_earnings: ' ||p_periodic_earnings);

  SELECT period_type
      INTO lv_period_type
      FROM pay_all_payrolls_f ppf,
           fnd_sessions fs
     WHERE payroll_id = p_payroll_id
       AND fs.effective_date BETWEEN ppf.effective_start_date
                                 AND ppf.effective_end_date
       AND fs.session_id = USERENV('sessionid');

    ln_days_in_a_month := pay_mx_utility.get_days_in_month(
                              p_business_group_id => p_business_group_id
                             ,p_tax_unit_id       => p_tax_unit_id
                             ,p_payroll_id        => p_payroll_id);


    IF lv_period_type = 'Calendar Month' THEN

       ln_periodic_earnings := p_periodic_earnings;

    ELSIF lv_period_type = 'Semi-Month' THEN

       ln_periodic_earnings := (p_periodic_earnings / 15) * ln_days_in_a_month;

    ELSIF lv_period_type = 'Week' THEN

       ln_periodic_earnings := (p_periodic_earnings / 7) * ln_days_in_a_month;

    ELSIF lv_period_type = 'Bi-Week' THEN

       ln_periodic_earnings := (p_periodic_earnings / 14) * ln_days_in_a_month;

    ELSIF lv_period_type = 'Ten Days' THEN

       ln_periodic_earnings := (p_periodic_earnings / 10) * ln_days_in_a_month;


    END IF;

    hr_utility_trace('ln_periodic_earnings: ' ||ln_periodic_earnings);
    hr_utility_trace('Leaving ..CONVERT_INTO_MONTHLY_SALARY');

    RETURN ln_periodic_earnings;

  END CONVERT_INTO_MONTHLY_SALARY;


  /****************************************************************************
    Name        : CHECK_EE_SAL_CRITERIA
    Description : This function returns 'Y' if employee's  annual gross earning
                  is less than 300,000 MXN.
  *****************************************************************************/

FUNCTION CHECK_EE_SAL_CRITERIA
(
    P_CTX_ASSIGNMENT_ID         NUMBER
   ,P_CTX_DATE_EARNED           DATE
) RETURN VARCHAR2 AS

       CURSOR c_defined_balance_id(p_balance_name VARCHAR2
                             ,p_dimension VARCHAR2)
       IS
           SELECT  pdb.defined_balance_id
            FROM   pay_balance_types pbt
                  ,pay_balance_dimensions pbd
                  ,pay_defined_balances pdb
            WHERE  pbt.balance_name=p_balance_name
              AND  pbd.database_item_suffix =p_dimension
              AND  pbt.legislation_code = 'MX'
              AND  pbd.legislation_code = 'MX'
              AND  pbt.balance_type_id = pdb.balance_type_id
              AND  pbd.balance_dimension_id  = pdb.balance_dimension_id;


       CURSOR c_assignment_action_id
       IS
           SELECT  MAX(paa.assignment_action_id)
            FROM   pay_assignment_actions paa
                  ,pay_payroll_actions ppa
            WHERE  paa.assignment_id =P_CTX_ASSIGNMENT_ID
              AND  paa.payroll_action_id=ppa.payroll_action_id
              AND  ppa.action_type in ('R','Q','I')
              AND  ppa.date_earned <=P_CTX_DATE_EARNED;

     l_flag           VARCHAR2(4);
     l_capping_value     VARCHAR(20);
     l_ignore NUMBER;
     l_pkg_value NUMBER;
     l_gross_earning NUMBER;
     l_bal_defined_id NUMBER;
     l_assignment_action_id  pay_assignment_actions.assignment_action_id%type;
BEGIN
     l_flag :='N';
     l_ignore:=0;
     l_gross_earning:=0;
     l_capping_value:=0;
     l_capping_value:='$Sys_Def$';

     hr_utility_trace('Entering ..CHECK_EE_SAL_CRITERIA');
     OPEN c_defined_balance_id('Gross Earnings','_PER_YTD');
     FETCH c_defined_balance_id INTO l_bal_defined_id;
     CLOSE c_defined_balance_id;

     OPEN c_assignment_action_id;
     FETCH c_assignment_action_id INTO l_assignment_action_id;
     CLOSE c_assignment_action_id;

     IF(l_assignment_action_id IS NULL) THEN
          hr_utility_trace('Leaving ..CHECK_EE_SAL_CRITERIA');
          RETURN 'N';
     END IF;

     l_pkg_value:=pay_mx_tax_functions.get_mx_tax_info
			(   P_CTX_BUSINESS_GROUP_ID    => NULL,
			    P_CTX_TAX_UNIT_ID          => NULL,
			    P_CTX_EFFECTIVE_DATE       => P_CTX_DATE_EARNED,
			    P_CTX_JURISDICTION_CODE    => l_ignore,
			    P_LEGISLATION_INFO_TYPE    => 'MX Tax Adjustment Parameters',
			    P_LEGISLATION_INFO1        => l_capping_value,
			    P_LEGISLATION_INFO2	       => l_ignore,
			    P_LEGISLATION_INFO3        => l_ignore,
			    P_LEGISLATION_INFO4        => l_ignore,
			    P_LEGISLATION_INFO5        => l_ignore,
			    P_LEGISLATION_INFO6        => l_ignore
                        );

     l_gross_earning:=pay_balance_pkg.get_value
                           (p_defined_balance_id   =>l_bal_defined_id,
                            p_assignment_action_id =>l_assignment_action_id,
                            p_tax_unit_id          => NULL,
                            p_jurisdiction_code    => NULL,
                            p_source_id            => NULL,
                            p_tax_group            => NULL,
                            p_date_earned          => NULL);

     IF(nvl(l_gross_earning,-1)>l_capping_value) THEN
          l_flag :='N';
     ELSIF (l_gross_earning <> 0) THEN
          l_flag :='Y';
     END IF;
     hr_utility_trace('l_flag: ' ||l_flag);
     hr_utility_trace('Leaving ..CHECK_EE_SAL_CRITERIA');
     RETURN l_flag;

END CHECK_EE_SAL_CRITERIA;


  /****************************************************************************
    Name        : CHECK_EE_EMPLOYMENT_CRITERIA
    Description : This Function return 'Y' if employee is working continously
                  between the given start date and end date
  *****************************************************************************/

FUNCTION CHECK_EE_EMPLOYMENT_CRITERIA
(
    P_CTX_ASSIGNMENT_ID         NUMBER,
    P_CTX_DATE_EARNED           DATE
) RETURN VARCHAR2 AS

       CURSOR csr_get_dates IS
            SELECT fnd_date.canonical_to_date(TO_CHAR(P_CTX_DATE_EARNED,'YYYY')
                            ||'/'||hoi.org_information7),
                   fnd_date.canonical_to_date(TO_CHAR(P_CTX_DATE_EARNED,'YYYY')
                            ||'/'||hoi.org_information8),
                   paf.person_id
              FROM hr_organization_information hoi
                  ,per_assignments_f paf
             WHERE hoi.organization_id =
                       hr_mx_utility.get_legal_employer(paf.business_group_id,
                             per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                    paf.location_id
                                   ,paf.business_group_id
                                   ,paf.soft_coding_keyflex_id
                                   ,p_ctx_date_earned),
                                   p_ctx_date_earned)
               AND hoi.org_information_context = 'MX_TAX_REGISTRATION'
               AND paf.assignment_id           = P_CTX_ASSIGNMENT_ID
               AND P_CTX_DATE_EARNED     BETWEEN paf.effective_start_date
                                             AND paf.effective_end_date;

       CURSOR csr_get_form37_status (p_start_date date,p_end_date date) IS
            SELECT 'N'
              FROM pay_assignment_actions paa
                  ,pay_payroll_actions ppa
             WHERE paa.payroll_action_id=ppa.payroll_action_id
               AND paa.assignment_id =P_CTX_ASSIGNMENT_ID
               AND ppa.report_type='ISR_TAX_FORMAT37'
               AND ppa.date_earned BETWEEN p_start_date AND p_end_date;

   CURSOR c_get_hire_date ( cp_person_id    NUMBER
                           ,cp_effective_date DATE ) IS
     SELECT MAX (pps.date_start), MAX(nvl(actual_termination_date,
                                  fnd_date.canonical_to_date('4712/12/31')))
       FROM per_periods_of_service pps
      WHERE pps.person_id   = cp_person_id
        AND pps.date_start <= cp_effective_date;
 --bug 7604298
  CURSOR c_get_prev_term_date ( cp_person_id    NUMBER
                           ,cp_effective_date DATE ) IS
     SELECT MAX(actual_termination_date)
       FROM per_periods_of_service pps
      WHERE pps.person_id   = cp_person_id
        AND pps.date_start <= cp_effective_date
	AND pps.actual_termination_date IS NOT NULL;


      l_proc_name         VARCHAR2(100);
      l_flag              VARCHAR2(4);
      l_payroll_id        pay_payroll_actions.payroll_id%TYPE;
      l_end_date          DATE;
      l_start_date        DATE;
      l_hire_date         DATE;
      l_termination_date  DATE;
      ln_person_id        NUMBER;
      l_prev_term_date    DATE;

BEGIN
      l_proc_name := g_proc_name ||'CHECK_EE_EMPLOYMENT_CRITERIA';
      hr_utility_trace('Entering '||l_proc_name);
      hr_utility_trace('P_CTX_ASSIGNMENT_ID = ' || p_ctx_assignment_id);

      l_flag       :='N';
      l_start_date := NULL;

      OPEN csr_get_dates;
      FETCH csr_get_dates INTO l_start_date,
                               l_end_date,
                               ln_person_id;
      CLOSE csr_get_dates;


      HR_UTILITY.trace('l_start_date: '||l_start_date);
      HR_UTILITY.trace('l_end_date: '||l_end_date);

      OPEN  c_get_hire_date(ln_person_id,P_CTX_DATE_EARNED);
      FETCH c_get_hire_date INTO l_hire_date, l_termination_date;
      CLOSE c_get_hire_date;

      HR_UTILITY.trace('l_hire_date: '||l_hire_date);
      HR_UTILITY.trace('l_termination_date: '||l_termination_date);

      IF l_hire_date > l_start_date AND l_termination_date >= l_end_date THEN
     /*Added for bug 7604298 to pick up the re-hire employee when re-hire happens in next day*/
       HR_UTILITY.trace('About to check the re-hire condition ');
      OPEN c_get_prev_term_date(ln_person_id,P_CTX_DATE_EARNED);
      FETCH  c_get_prev_term_date INTO l_prev_term_date;
      CLOSE c_get_prev_term_date;
        HR_UTILITY.trace('l_prev_term_date: '||l_prev_term_date);
      IF (l_prev_term_date IS NOT NULL) AND ((l_prev_term_date +1) = l_hire_date) THEN
          hr_utility_trace('Person re-hired in the next day ');
         RETURN ('Y');
      END IF;

         hr_utility_trace('Person hired after ' || l_start_date);
         hr_utility_trace('Leaving '||l_proc_name);
         RETURN ('N');
      END IF;

      IF l_termination_date < l_end_date THEN
         hr_utility_trace('Person terminated before ' || l_end_date );
         hr_utility_trace('Leaving '||l_proc_name);
         RETURN ('N');
      END IF;

      IF l_start_date IS NOT NULL THEN
         OPEN csr_get_form37_status(l_start_date,l_end_date);
         FETCH csr_get_form37_status INTO l_flag;
           IF csr_get_form37_status%NOTFOUND THEN
              CLOSE csr_get_form37_status;
              hr_utility_trace('Leaving '||l_proc_name);
              RETURN 'Y';
           END IF;
         CLOSE csr_get_form37_status;
      END IF;

      hr_utility_trace('l_flag: ' ||l_flag);
      hr_utility_trace('Leaving '||l_proc_name);

      RETURN (l_flag);

END CHECK_EE_EMPLOYMENT_CRITERIA;



  /****************************************************************************
    Name        : IS_ASG_EXEMPT_FROM_ISR
    Description : This function returns Y if an assignment is exempted from ISR
                  calculation
  *****************************************************************************/

FUNCTION IS_ASG_EXEMPT_FROM_ISR
(
    P_CTX_ASSIGNMENT_ID         NUMBER
   ,P_CTX_DATE_EARNED              DATE
) RETURN VARCHAR2 AS

       CURSOR get_isr_entry
       IS
          SELECT  'Y'
            FROM  pay_element_entries_f pee
                 ,pay_element_types_f pet
                 ,pay_element_entry_values_f pev
                 ,pay_input_values_f piv
           WHERE  assignment_id=P_CTX_ASSIGNMENT_ID
             AND  pee.element_type_id=pet.element_type_id
             AND  pev.element_entry_id=pee.element_entry_id
             AND  piv.input_value_id = pev.input_value_id
             AND  pet.element_name = 'Mexico Tax'
             AND  piv.name ='Exempt ISR Tax'
             AND  pev.screen_entry_value='Y'
             AND  P_CTX_DATE_EARNED BETWEEN  pee.effective_start_date AND  pee.effective_end_date
             AND  P_CTX_DATE_EARNED BETWEEN  pev.effective_start_date AND  pev.effective_end_date;



       l_flag              VARCHAR2(4);
       l_value             NUMBER;

BEGIN

       l_flag :='N';
       hr_utility_trace('Entering ..IS_ASG_EXEMPT_FROM_ISR');
       OPEN get_isr_entry;
       FETCH get_isr_entry INTO l_flag;
         IF get_isr_entry%NOTFOUND THEN
              CLOSE get_isr_entry;
              hr_utility_trace('Leaving ..IS_ASG_EXEMPT_FROM_ISR');
              RETURN 'N';
         END IF;
       CLOSE get_isr_entry;

        hr_utility_trace('l_flag: ' ||l_flag);
        hr_utility_trace('Leaving ..IS_ASG_EXEMPT_FROM_ISR');

       RETURN (l_flag);

END IS_ASG_EXEMPT_FROM_ISR;


  /****************************************************************************
    Name        : IS_PER_EXEMPT_FROM_ADJ
    Description : This function returns Y if an assignment is exempted from Tax
                  Adjustment
  *****************************************************************************/

FUNCTION IS_PER_EXEMPT_FROM_ADJ
(
    P_CTX_ASSIGNMENT_ID         NUMBER
   ,P_CTX_DATE_EARNED           DATE
) RETURN VARCHAR2 AS

       CURSOR get_person_id
       IS
           SELECT person_id
             FROM per_all_assignments_f
            WHERE assignment_id=P_CTX_ASSIGNMENT_ID
              AND P_CTX_DATE_EARNED BETWEEN effective_start_date AND effective_end_date;

       CURSOR get_exempt_adjustment(p_person_id per_all_people_f.person_id%TYPE)
       IS
          SELECT pei_information1
            FROM per_people_extra_info
           WHERE person_id = p_person_id
             AND information_type='MX_EMP_TAX_SIGNUP'
             AND P_CTX_DATE_EARNED BETWEEN fnd_date.canonical_to_date(pei_information2)
                                    AND fnd_date.canonical_to_date(pei_information3);

      l_flag           VARCHAR2(4);
      l_person_id      per_all_people_f.person_id%TYPE;
      l_exempt_adj     per_people_extra_info.pei_information1%TYPE;

BEGIN

       l_flag:='N';
       hr_utility_trace('Entering ..IS_PER_EXEMPT_FROM_ADJ');
       OPEN get_person_id;
       FETCH get_person_id INTO l_person_id;
       CLOSE get_person_id;

       OPEN get_exempt_adjustment(l_person_id);
       FETCH get_exempt_adjustment INTO l_exempt_adj;
         IF get_exempt_adjustment%NOTFOUND THEN
             CLOSE get_exempt_adjustment;
	     hr_utility_trace('Leaving ..IS_PER_EXEMPT_FROM_ADJ');
             RETURN 'N';
         END IF;
       CLOSE get_exempt_adjustment;

       IF l_exempt_adj ='Y' THEN
           l_flag:='Y';
       ELSE
           l_flag:='N';
       END IF;

       hr_utility_trace('l_flag: ' ||l_flag);
       hr_utility_trace('Leaving ..IS_PER_EXEMPT_FROM_ADJ');

       RETURN (l_flag);

END IS_PER_EXEMPT_FROM_ADJ;

  /****************************************************************************
    Name        : GET_MX_ECON_ZONE
    Description : This function returns Economy Zone('A', 'B', 'C') for the
		  given tax_unit_id
  *****************************************************************************/

FUNCTION GET_MX_ECON_ZONE
(
    P_CTX_TAX_UNIT_ID           number,
    P_CTX_DATE_EARNED		DATE
) RETURN varchar2 AS

CURSOR get_econ_zone
       IS
        SELECT hoi.org_information7
          FROM hr_organization_units hou,
               hr_organization_information hoi
         WHERE hou.organization_id = hoi.organization_id
           AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
           AND hou.organization_id = P_CTX_TAX_UNIT_ID
           AND P_CTX_DATE_EARNED BETWEEN hou.date_from
                                    AND NVL(hou.date_to, hr_general.end_of_time);

l_econ_zone varchar2(2);

BEGIN


       OPEN get_econ_zone;
       FETCH get_econ_zone INTO l_econ_zone;
       CLOSE get_econ_zone;

       RETURN (l_econ_zone);
END GET_MX_ECON_ZONE;

  /****************************************************************************
    Name        : GET_MIN_WAGE
    Description : This function returns Minimum Wage for the Economy Zone
  *****************************************************************************/

FUNCTION GET_MIN_WAGE
(
    P_CTX_DATE_EARNED		DATE,
    P_TAX_BASIS     		varchar2,
    P_ECON_ZONE			varchar2

) RETURN varchar2 AS

CURSOR get_min_wage
	IS
	SELECT  legislation_info2  FROM PAY_MX_LEGISLATION_INFO_F WHERE
    legislation_info1=
    DECODE(P_ECON_ZONE,'NONE','GMW','MW'||P_ECON_ZONE) AND
    legislation_info_type = 'MX Minimum Wage Information'
    AND P_CTX_DATE_EARNED BETWEEN  effective_start_date AND effective_end_date;

l_min_wage  number;

BEGIN

       hr_utility_trace('Economy Zone '||P_ECON_ZONE);
       OPEN get_min_wage;
       FETCH get_min_wage INTO l_min_wage;
       CLOSE get_min_wage;


       RETURN (l_min_wage);

END GET_MIN_WAGE;

/****************************************************************************
  Name        : CONVERT_INTO_MONTHLY_AVG_SAL
  Description : This function has
                1. Input Parameters as Contexts:
                   - BUSINESS_GROUP_ID
                   - TAX_UNIT_ID
                   - PAYROLL_ID
                2. Input Parameters as Parameter:
                   - SUBJECT_EARNINGS
                   - DATE_EARNED
*****************************************************************************/

FUNCTION CONVERT_INTO_MONTHLY_AVG_SAL ( p_business_group_id   IN  NUMBER
                                      ,p_tax_unit_id          IN  NUMBER
                                      ,p_payroll_id           IN  NUMBER
                                      ,p_subject_earnings     IN  NUMBER
                                      ,P_DATE_EARNED          IN  DATE
				      ,p_hire_date            IN  DATE
				      ,p_first_pay_date       IN  DATE
                                      ,p_period_days          OUT NOCOPY NUMBER)
RETURN NUMBER IS

  ln_subject_earnings        NUMBER;
  ln_days_in_a_month         NUMBER;
  lv_period_type             pay_all_payrolls_f.period_type%TYPE;
  ln_row_count               NUMBER;
  lv_end_date                varchar2(24);
  lv_start_date              varchar2(24);
  ln_time_period_id          number;

  CURSOR csr_get_period_count_in_month IS
       select rownum mult_num,
              to_char(end_date,'yyyymmdd') period_end_mtd,
              to_char(start_date,'yyyymmdd') period_start_mtd,
	      time_period_id
       from   PER_TIME_PERIODS ptp
       where  payroll_id = p_payroll_id
       and    (to_char(p_date_earned,'yyyymm') = to_char(end_date,'yyyymm')
              or
              p_date_earned between start_date and end_date
              )
       AND    p_hire_date <= end_date
       AND   start_date >= NVL(p_first_pay_date,start_date)
       order by end_date;

BEGIN

  hr_utility_trace('Entering ..CONVERT_INTO_MONTHLY_AVG_SAL');
  hr_utility_trace('p_subject_earnings: ' ||p_subject_earnings);
  hr_utility_trace('p_first_pay_date: ' ||to_char(p_first_pay_date));
  hr_utility_trace('p_hire_date: ' ||to_char(p_hire_date));
  hr_utility_trace('p_date_earned: ' ||to_char(P_DATE_EARNED));
  hr_utility_trace('p_payroll_id: ' ||p_payroll_id);
    open csr_get_period_count_in_month;
    loop
       fetch csr_get_period_count_in_month into ln_row_count,
                                                lv_end_date,
						lv_start_date,
						ln_time_period_id;
       exit when csr_get_period_count_in_month%NOTFOUND;

       hr_utility_trace('ln_row_count: ld_end_date' ||
           to_char(ln_row_count) ||' -- '||lv_end_date);

       if to_char(P_DATE_EARNED,'yyyymmdd') <= lv_end_date and
          to_char(P_DATE_EARNED,'yyyymmdd') >= lv_start_date then
          ln_subject_earnings := p_subject_earnings * ln_row_count;
          p_period_days := ln_row_count;
	  hr_utility_trace('p_period_days: ' ||ln_row_count);
       end if;

    end loop;
    close csr_get_period_count_in_month;

    hr_utility_trace('ln_subject_earnings: ' ||ln_subject_earnings);
    hr_utility_trace('Leaving ..CONVERT_INTO_MONTHLY_AVG_SAL');

    RETURN ln_subject_earnings;

END CONVERT_INTO_MONTHLY_AVG_SAL;

function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null,
                          p_period_days       in number,
                          p_period_number     in number,
                          p_period_type       in varchar2)
         return varchar2 is
l_effective_date    date;
l_range_or_match    pay_user_tables.range_or_match%type;
l_table_id          pay_user_tables.user_table_id%type;
l_value             pay_user_column_instances_f.value%type;
ln_period_days      number;
begin
    hr_utility_trace('p_bus_group_id: ' ||p_bus_group_id);
    hr_utility_trace('p_table_name: ' ||p_table_name);
    hr_utility_trace('p_col_name: ' ||p_col_name);
    hr_utility_trace('p_row_value: ' ||p_row_value);
    hr_utility_trace('p_effective_date: ' ||p_effective_date);
    hr_utility_trace('p_period_days: ' ||p_period_days);
    hr_utility_trace('p_period_number: ' ||p_period_number);
    hr_utility_trace('p_period_type: ' ||p_period_type);
    --
    -- Use either the supplied date, or the date from fnd_sessions
    --
    if (p_effective_date is not null) then
        l_effective_date := p_effective_date;
    end if;
    --
    -- get the type of query to be performed, either range or match
    --
    select range_or_match, user_table_id
    into   l_range_or_match, l_table_id
    from   pay_user_tables
    where  upper(user_table_name) = upper(p_table_name)
    and    nvl (business_group_id,
                p_bus_group_id)   = p_bus_group_id
    and    nvl(legislation_code, 'MX') = 'MX';
    --
    hr_utility_trace('l_range_or_match: ' ||l_range_or_match);
    hr_utility_trace('l_table_id: ' ||l_table_id);
    --
    if p_period_type in ('Calendar Month') or
       (p_period_type in ('Semi-Month') and p_period_number = 2) or
       (p_period_type = 'Ten Days' AND p_period_number = 3) then
       ln_period_days := 30.4;
    else
       ln_period_days := least(p_period_days * p_period_number,30.4);
    end if;    --
    hr_utility_trace('ln_period_days: ' ||ln_period_days);
    if (l_range_or_match <> 'M') then       -- matched
        select  /*+ INDEX(C PAY_USER_COLUMNS_FK1)
                    INDEX(R PAY_USER_ROWS_F_FK1)
                    INDEX(CINST PAY_USER_COLUMN_INSTANCES_N1)
                    ORDERED */
                CINST.value
        into    l_value
        from    pay_user_tables                    TAB
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_column_instances_f        CINST
        where   TAB.user_table_id                = l_table_id
        and     C.user_table_id                  = TAB.user_table_id
        and     nvl (C.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (C.legislation_code,
                     'MX')                       = 'MX'
        and     upper (C.user_column_name)       = upper (p_col_name)
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     l_effective_date           between R.effective_start_date
        and     R.effective_end_date
        and     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (R.legislation_code,
                     'MX')                       = 'MX'
        and     fnd_number.canonical_to_number (p_row_value)
        between (fnd_number.canonical_to_number (R.row_low_range_or_name)/30.4) * ln_period_days
        and     (fnd_number.canonical_to_number (R.row_high_range)/30.4) * ln_period_days
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     'MX')                       = 'MX';
        --
        hr_utility_trace('l_value: ' ||l_value);
        return l_value;

    end if;

end get_table_value;

BEGIN
    --hr_utility.trace_on (null, 'MX_IDC');
    g_proc_name := 'PAY_MX_TAX_FUNCTIONS.';
    g_debug := hr_utility.debug_enabled;

END PAY_MX_TAX_FUNCTIONS;

/
