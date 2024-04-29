--------------------------------------------------------
--  DDL for Package Body PAY_US_941_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_941_REPORT" AS
/* $Header: payus941report.pkb 120.7.12010000.8 2010/04/08 12:54:21 vvijayku ship $ */
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

    Name        : pay_us_941_report

    Description : This package is called for the 941 Report to
                  generate the XML file.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    15-APR-2005 pragupta   115.0   3685216  Created
    21-APR-2005 pragupta   115.1   3685216  Created
    18-MAY-2005 pragupta   115.2   3685216  Changes made in order to transit
                                            from RTF to PDF Template. Also
                                            field 14 to be filled additionally
                                            on the report.
    18-OCT-2005 pragupta   115.3   4682231  lv_STATE_ABBR_1 and lv_STATE_ABBR_2
                                            to be nullified.
    27-OCT-2005 pragupta   115.4   4687794  added CDATA section for GRE Name and
                                            address.
    02-DEC-2005 rdhingra   115.5   4769835  Performance changes. Updated Cursor
                                            c_count_asg_processed in procedure
                                            get_941_balances
    06-APR-2006 pragupta   115.8   5117504  introduced tags YEAR1 and YEAR2.
    30-OCT-2006 alikhar    115.9   5479800  Added procedure pay_us_941_report_wrapper
    13-Mar-2009 skpatil    115.11  8267959  Removing addition of XML tags for Cobra values
    25-Mar-2009 skpatil    115.12  8267963  Adding code to submit FND_REQUEST based on
                                            release.
    11-Mar-2010 vvijayku   115.13  9357061  Added code to split number into its integer and
	                                    decimal part. Also modified the XML tag generation
					    to incorporate the integer and decimal values.
    24-Mar-2010 vvijayku   115.14  8772549  Added an exist clause to find the correct number of
                                            employees who have wages in the quarter.
    02-Apr-2010 vvijayku   115.15  8772549  Added code to Ignore the Information type classification
                                            which has Pay Value not equal to 0.
    08-Apr-2010 vvijayku   115.16  9556898  Moved the Splitting of the balance values into integer
                                            and decimal parts out of the IF clause.
  ************************************************************************/
  g_CP_STATUS       VARCHAR2(20);
  g_c_qtr_end_date  DATE;
  g_package         VARCHAR2(100) := 'pay_us_941_report';

    /****************************************************************************
    Name        : SPLIT_NUMBER_INTO_INT_DECIMAL
    Description : This function splits the given number into its integer and
	              decimal part.
    *****************************************************************************/
FUNCTION SPLIT_NUMBER_INTO_INT_DECIMAL                  -- Bug 9357061: Function start.
(
P_NUMBER        IN NUMBER,
P_DEC           IN NUMBER,
P_INTEGER_PART  OUT NOCOPY NUMBER,
P_DECIMAL_PART  OUT NOCOPY VARCHAR2
) RETURN NUMBER AS

ln_pos_dec      NUMBER;
ln_number       NUMBER;

BEGIN
hr_utility.trace ('Entering number splitting function');

ln_number := ROUND(P_NUMBER, p_dec);

ln_pos_dec := INSTR(ln_number,'.');

IF ln_pos_dec > 0 THEN

P_INTEGER_PART := SUBSTR(ln_number, 0 , ln_pos_dec-1);

P_DECIMAL_PART := to_char(SUBSTR(ln_number, ln_pos_dec+1 , p_dec));

ELSIF ln_pos_dec = 0 THEN

P_INTEGER_PART := ln_number;

P_DECIMAL_PART := NULL;

END IF;

hr_utility.trace ('Leaving number splitting function');
RETURN (0);

END SPLIT_NUMBER_INTO_INT_DECIMAL;                      -- Bug 9357061: Function end.

  /* Initialization: Setting session variables etc. */
  PROCEDURE set_session_variables_contexts(
               p_business_group_id IN NUMBER,
               p_tax_unit_id       IN NUMBER,
               p_year              IN VARCHAR2,
               p_qtr               IN VARCHAR2)
  IS
    ld_quarter_start_date date;
    ld_quarter_end_date   date;
  BEGIN

    ld_quarter_start_date := TRUNC(TO_DATE(p_qtr||'-'||p_year,'DD-MM-YYYY'),'Q');
    ld_quarter_end_date   := TO_DATE(p_qtr||'-'||p_year,'DD-MM-YYYY');
    -- Check for the validity of all the balances used by the report
    g_CP_STATUS := pay_us_payroll_utils.check_balance_status(
                        p_start_date        => ld_quarter_start_date,
                        p_business_group_id => p_business_group_id,
                        p_attribute_name    => '941_FED',
                        p_legislation_code  => 'US');

    /* If all the balances used by the report are valid then set session
       variables and contexts */
    IF g_CP_STATUS = 'Y' THEN
       pay_us_balance_view_pkg.set_session_var('GROUP_RB_REPORT','TRUE');
       pay_us_balance_view_pkg.set_session_var('REPORT_TYPE','W2');
       pay_us_balance_view_pkg.set_session_var('GROUP_RB_SDATE',
                                               ld_quarter_start_date);
       pay_us_balance_view_pkg.set_session_var('GROUP_RB_EDATE',
                                               ld_quarter_end_date);
       pay_balance_pkg.set_context(
                 'DATE_EARNED',
                 fnd_date.date_to_canonical(ld_quarter_end_date));
       pay_balance_pkg.set_context(
                 'BALANCE_DATE',
                 fnd_date.date_to_canonical(ld_quarter_end_date));
    END IF;

  EXCEPTION WHEN no_data_found THEN
      RAISE;
  END set_session_variables_contexts;



  PROCEDURE get_941_balances(p_business_group_id IN NUMBER,
                             p_tax_unit_id IN NUMBER,
                             p_year IN VARCHAR2,
                             p_qtr IN VARCHAR2)
  IS

    CURSOR c_gre_info(cp_tax_unit_id NUMBER) IS
      SELECT hou.name,               -- GRE Name
             hoi_ein.org_information1,    -- EIN
             hrl.address_line_1,
             hrl.address_line_2,
             hrl.address_line_3,
             hrl.town_or_city,
             hrl.region_2,
             hrl.postal_code
        FROM hr_organization_units hou,
             hr_organization_information hoi_bg,
             hr_organization_information hoi_ein ,
             hr_locations hrl
       WHERE hou.organization_id = cp_tax_unit_id
         AND hoi_bg.organization_id = hou.organization_id
         and hoi_bg.org_information_context = 'CLASS'
         AND hoi_bg.org_information1 = 'HR_LEGAL'
         AND hoi_ein.organization_id(+) = hou.organization_id
         AND nvl(hoi_ein.org_information_context(+),'Employer Identification')  = 'Employer Identification'
         AND hrl.location_id = hou.location_id;

    l_gre_name       VARCHAR2(240);
    l_gre_EIN        VARCHAR2(150);
    l_ADDRESS        VARCHAR2(720);
    l_ADDRESS_LINE_1 VARCHAR2(240);
    l_ADDRESS_LINE_2 VARCHAR2(240);
    l_ADDRESS_LINE_3 VARCHAR2(240);
    l_CITY           VARCHAR2(30);
    l_STATE          VARCHAR2(120);
    l_ZIP            VARCHAR2(30);
    l_gre_EIN_1      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_2      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_3      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_4      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_5      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_6      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_7      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_8      VARCHAR2(2);       -- Bug 9357061
    l_gre_EIN_9      VARCHAR2(2);       -- Bug 9357061

--******** Employee Count (declarations start)
    CURSOR c_count_asg_processed(cp_tax_unit_id    IN number,
                                  cp_qtr           IN VARCHAR2,
                                  cp_year          IN VARCHAR2) IS
      SELECT /*+ LEADING(ptp)                    -- For Bug 4769835
                 INDEX (ptp PER_TIME_PERIODS_N50)
                 USE_NL(ptp ppa)
                 */
             COUNT(DISTINCT paf.person_id)
        FROM per_time_periods ptp,
             per_assignments_f paf,
             per_assignments_f paf1,
             pay_assignment_actions paa, pay_payroll_actions ppa
       WHERE ptp.end_date >= TO_DATE('01'||TO_CHAR
             (TRUNC(to_date(cp_qtr||'-'||cp_year, 'DD-MM-YYYY'), 'Q'),'MM') ||
              TO_CHAR(to_date(cp_qtr||'-'||cp_year, 'DD-MM-YYYY'),'YYYY'),'DD-MM-YYYY')
         AND ptp.start_date <= TO_DATE('12'||TO_CHAR
         (to_date(cp_qtr||'-'||cp_year, 'DD-MM-YYYY'),'MM') ||
         TO_CHAR(to_date(cp_qtr||'-'||cp_year, 'DD-MM-YYYY'),'YYYY'),'DD-MM-YYYY')
         AND ppa.effective_date >=  ptp.start_date -- For Bug 4769835
         AND ppa.effective_date <= ptp.end_date    -- For Bug 4769835
         AND ppa.payroll_id = ptp.payroll_id       -- For Bug 4769835
         AND ppa.time_period_id = ptp.time_period_id
         AND ppa.action_type IN ('R', 'Q')
         AND ppa.payroll_action_id = paa.payroll_action_id
         AND paf1.assignment_id = paa.assignment_id
         AND paf.person_id = paf1.person_id
         AND paa.run_type_id IS NOT NULL
         AND paa.tax_unit_id = cp_tax_unit_id
         AND paa.action_status = 'C'
	 AND Exists ( Select 'Y'                  -- For Bug 8772549
                        from pay_input_values_f iv,
                             pay_run_result_values rrv,
                             pay_run_results rr,
			     pay_element_classifications ec,
                             pay_element_types_f et
                       where rr.assignment_action_id = paa.assignment_action_id
		         and paa.assignment_id = paf.assignment_id
                         and rr.run_result_id = rrv.run_result_id
                         and nvl(rrv.result_value,'0') <> '0'
                         AND iv.input_value_id = rrv.input_value_id
                         AND iv.name = 'Pay Value'
			 AND et.element_type_id = iv.element_type_id
                         AND ec.classification_id = et.classification_id
                         AND ec.classification_name <> ('Information')
                   );

    ln_emp_count                      NUMBER;
--******** Employee Count (declarations end)

--******** State Abbreviation (declarations start)
/*  CURSOR c_state_abbr(cp_tax_unit_id IN number) IS
      SELECT ORG_INFORMATION1
        FROM HR_ORGANIZATION_INFORMATION_V
       WHERE org_information_context = 'State Tax Rules'
         AND ORGANIZATION_ID = cp_tax_unit_id;
    ln_count_state            NUMBER;
    lv_STATE_ABBR_1           VARCHAR2(1);
    lv_STATE_ABBR_2           VARCHAR2(1);
    lv_STATE_ABBR             VARCHAR2(150);*/
--******** State Abbreviation (declarations end)

--******** Generate Federal Tax Balances (declarations start)
    -- Get details for Total Wages
    -- Cursor to fetch the balance values making use of the BRA
    -- The cursor uses the view pay_us_federal_tax_bal_gre_v which
    -- gets the balance information from the table pay_balance_sets.
    CURSOR c_bal_values (cp_tax_unit_id IN NUMBER) IS
      SELECT d_tax_otd_value,
             d_wage_otd_value,
             d_tax_type
        FROM pay_us_federal_tax_bal_gre_v
       WHERE d_balance_set_name = '941_QTD'
         AND d_tax_unit_id      = cp_tax_unit_id;

    -- Local variables to hold the balance values
    ln_regular_earnings       NUMBER;
    ln_fit_withheld           NUMBER;
    ln_fit_withheld_main      NUMBER;           -- Bug 9357061
    ln_fit_withheld_dec       VARCHAR2(3);      -- Bug 9357061
    ln_medicare_er_taxable    NUMBER;
    ln_medicare_er_taxable_main NUMBER;         -- Bug 9357061
    ln_medicare_er_taxable_dec  VARCHAR2(3);    -- Bug 9357061
    ln_ss_er_taxable          NUMBER;
    ln_ss_er_taxable_main     NUMBER;           -- Bug 9357061
    ln_ss_er_taxable_dec      VARCHAR2(3);      -- Bug 9357061
    ln_eic_advance            NUMBER;
    ln_eic_advance_main       NUMBER;           -- Bug 9357061
    ln_eic_advance_dec        VARCHAR2(3);      -- Bug 9357061
    ln_pretax_dedn            NUMBER;
    ln_fit_non_w2_pretax_dedn NUMBER;
    ln_ss_tips                NUMBER;
    ln_ss_tips_main           NUMBER;           -- Bug 9357061
    ln_ss_tips_dec            VARCHAR2(3);      -- Bug 9357061
    ln_w2_uncoll_med_gtl      NUMBER;
    ln_w2_uncoll_med_tips     NUMBER;
    ln_w2_uncoll_ss_gtl       NUMBER;
    ln_w2_uncoll_ss_tax_tips  NUMBER;
    ln_w2_uncoll_med_ss       NUMBER;
    ln_w2_uncoll_med_ss_main  NUMBER;           -- Bug 9357061
    ln_w2_uncoll_med_ss_dec   VARCHAR(3);       -- Bug 9357061
    ln_supp_earn_nwfit        NUMBER;
    ln_supp_earn_fit          NUMBER;
    ln_pretax_dedn_fit        NUMBER;
    ln_dummy                  NUMBER;

    lv_tax_type               VARCHAR2(50);
    ln_tax                    NUMBER;
    ln_wage                   NUMBER;

    ln_total_wages            NUMBER;
    ln_total_wages_main       NUMBER;           -- Bug 9357061
    ln_total_wages_dec        VARCHAR(3);       -- Bug 9357061
    ln_taxable_ss_wage        NUMBER;
    ln_taxable_ss_wage_main   NUMBER;           -- Bug 9357061
    ln_taxable_ss_wage_dec    VARCHAR2(3);      -- Bug 9357061
    ln_941_box5b              NUMBER;
    ln_941_box5b_main         NUMBER;           -- Bug 9357061
    ln_941_box5b_dec          VARCHAR2(3);      -- Bug 9357061
    ln_taxable_medicare       NUMBER;
    ln_taxable_medicare_main  NUMBER;           -- Bug 9357061
    ln_taxable_medicare_dec   VARCHAR2(3);      -- Bug 9357061
    ln_tot_ss_medicare_tax    NUMBER;
    ln_tot_ss_medicare_tax_main NUMBER;         -- Bug 9357061
    ln_tot_ss_medicare_tax_dec  VARCHAR2(3);    -- Bug 9357061
    ln_tot_tax_bfr_adj        NUMBER;
    ln_tot_tax_bfr_adj_main   NUMBER;           -- Bug 9357061
    ln_tot_tax_bfr_adj_dec    VARCHAR2(3);      -- Bug 9357061

    vCtr                      NUMBER;
	ln_func_value             NUMBER;           -- Bug 9357061
	ln_dec_digits             NUMBER;           -- Bug 9357061

  BEGIN
    vCtr := 0;
	ln_dec_digits := 2;
    -- GRE Info
    OPEN c_gre_info(p_tax_unit_id);
    FETCH c_gre_info
    INTO l_gre_name, l_gre_ein, l_ADDRESS_LINE_1, l_ADDRESS_LINE_2,
         l_ADDRESS_LINE_3, l_CITY, l_STATE, l_ZIP;
    CLOSE c_gre_info;


    l_ADDRESS := l_ADDRESS_LINE_1 || ' '
                 || l_ADDRESS_LINE_2 || ' '
                 || l_ADDRESS_LINE_3;
    IF LENGTH(l_ADDRESS) > 80 THEN
      l_ADDRESS := l_ADDRESS_LINE_1 || ' ' || l_ADDRESS_LINE_2;
      IF LENGTH (l_ADDRESS) > 80 THEN
        l_ADDRESS := l_ADDRESS_LINE_1;
        IF LENGTH (l_ADDRESS) > 80 THEN
          l_ADDRESS := SUBSTR(l_ADDRESS_LINE_1, 1, 80);
        END IF;
      END IF;
    END IF;

    /* Bug 9357061: The Splitting of the EIN begin */

    l_gre_EIN_1 := SUBSTR(l_gre_ein,1,1);
    l_gre_EIN_2 := SUBSTR(l_gre_ein,2,1);
    l_gre_EIN_3 := SUBSTR(l_gre_ein,-7,1);
    l_gre_EIN_4 := SUBSTR(l_gre_ein,-6,1);
    l_gre_EIN_5 := SUBSTR(l_gre_ein,-5,1);
    l_gre_EIN_6 := SUBSTR(l_gre_ein,-4,1);
    l_gre_EIN_7 := SUBSTR(l_gre_ein,-3,1);
    l_gre_EIN_8 := SUBSTR(l_gre_ein,-2,1);
    l_gre_EIN_9 := SUBSTR(l_gre_ein,-1,1);

	/* Bug 9357061: The Splitting of the EIN End */

    -- Employee Count
    OPEN c_count_asg_processed (p_tax_unit_id, p_qtr, p_year);
    FETCH c_count_asg_processed INTO ln_emp_count;
    CLOSE c_count_asg_processed;

    -- State Abbreviation
/*  SELECT count(DISTINCT(ORG_INFORMATION1))
      INTO ln_count_state
      FROM HR_ORGANIZATION_INFORMATION_V
     WHERE org_information_context = 'State Tax Rules'
       AND ORGANIZATION_ID = p_tax_unit_id;

    IF ln_count_state > 1 THEN
      lv_STATE_ABBR_1 := 'M';
      lv_STATE_ABBR_2 := 'U';
    END IF;

    IF ln_count_state = 1 THEN
      OPEN c_state_abbr(p_tax_unit_id);
      FETCH c_state_abbr INTO lv_STATE_ABBR;
      CLOSE c_state_abbr;
      lv_STATE_ABBR_1 := SUBSTR(lv_STATE_ABBR, 1, 1);
      lv_STATE_ABBR_2 := SUBSTR(lv_STATE_ABBR, 2, 1);
    END IF; */

    /***********************************************************
    ** Fetch Balance value
    ***********************************************************/
    g_c_qtr_end_date := TO_DATE(p_qtr||'-'||p_year,'DD-MM-YYYY');
    -- If all the balances being reported are valid then make use of the BRA

    IF g_CP_STATUS = 'Y' THEN

       OPEN c_bal_values(p_tax_unit_id) ;
       LOOP
          FETCH c_bal_values INTO ln_tax, ln_wage, lv_tax_type ;
          EXIT WHEN c_bal_values%NOTFOUND ;

          IF lv_tax_type      = 'FIT' THEN
            ln_total_wages      := NVL(ln_wage,0);
            ln_fit_withheld  := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'MEDICARE' THEN
            ln_medicare_er_taxable  := NVL(ln_wage,0);

          ELSIF lv_tax_type   = 'SS' THEN

            ln_ss_er_taxable := NVL(ln_wage,0);
          ELSIF lv_tax_type   = 'EIC' THEN
            ln_eic_advance    := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'W2_BOX_7' THEN
            ln_ss_tips        := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'W2_UNCOLL_MED_TIPS' THEN
            ln_w2_uncoll_med_tips       := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'W2_UNCOLL_SS_GTL' THEN
            ln_w2_uncoll_ss_gtl         := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'W2_UNCOLL_MED_GTL' THEN
            ln_w2_uncoll_med_gtl        := NVL(ln_tax,0);

          ELSIF lv_tax_type   = 'W2_UNCOLL_SS_TAX_TIPS' THEN
            ln_w2_uncoll_ss_tax_tips    := NVL(ln_tax,0);
          END IF;

       END LOOP;
       CLOSE c_bal_values;
       ln_ss_er_taxable := ln_ss_er_taxable - ln_ss_tips;

    -- Else use the previous group calls to fetch the balance values
    ELSE
       pay_us_taxbal_view_pkg.us_gp_multiple_gre_qtd
           (p_tax_unit_id     => p_tax_unit_id ,
            p_effective_date  => g_c_qtr_end_date,
            p_balance_name1   => 'Regular Earnings',
            p_balance_name2   => 'FIT Withheld',
            p_balance_name3   => 'Medicare ER Taxable',
            p_balance_name4   => 'SS ER Taxable',
            p_balance_name5   => 'EIC Advance',
            p_balance_name6   => 'Pre Tax Deductions',
            p_balance_name7   => 'FIT Non W2 Pre Tax Dedns',
            p_balance_name8   => 'W2 BOX 7',
            p_balance_name9   => 'W2 Uncoll Med GTL',
            p_balance_name10  => 'W2 Uncoll Med Tips',
            p_balance_name11  => 'W2 Uncoll SS GTL',
            p_balance_name12  => 'W2 Uncoll SS Tax Tips',
            p_value1          => ln_regular_earnings,
            p_value2          => ln_fit_withheld,
            p_value3          => ln_medicare_er_taxable,
            p_value4          => ln_ss_er_taxable,
            p_value5          => ln_eic_advance,
            p_value6          => ln_pretax_dedn,
            p_value7          => ln_fit_non_w2_pretax_dedn,
            p_value8          => ln_ss_tips,
            p_value9          => ln_w2_uncoll_med_gtl,
            p_value10         => ln_w2_uncoll_med_tips,
            p_value11         => ln_w2_uncoll_ss_gtl,
            p_value12         => ln_w2_uncoll_ss_tax_tips);

       pay_us_taxbal_view_pkg.us_gp_subject_to_tax_gre_qtd
           (p_balance_name1   => 'Supplemental Earnings for NWFIT',
            p_balance_name2   => 'Supplemental Earnings for FIT',
            p_balance_name3   => 'Pre Tax Deductions for FIT',
            p_balance_name4   => NULL,
            p_balance_name5   => NULL,
            p_effective_date  => g_c_qtr_end_date,
            p_tax_unit_id     => p_tax_unit_id,
            p_value1          => ln_supp_earn_nwfit,
            p_value2          => ln_supp_earn_fit,
            p_value3          => ln_pretax_dedn_fit,
            p_value4          => ln_dummy,
            p_value5          => ln_dummy);


        -- Assign the Fed Wages Tips Balances
        ln_total_wages        := ln_regular_earnings
                               + ln_supp_earn_fit
 	                           + ln_supp_earn_nwfit
                               - ln_pretax_dedn
                               - ln_pretax_dedn_fit
                               - ln_fit_non_w2_pretax_dedn;


        ln_ss_er_taxable    := ln_ss_er_taxable - ln_ss_tips;



    END IF;

    /* Bug 9357061: Splitting of Integer part and Decimal part begin */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_fit_withheld,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_fit_withheld_main,
                            P_DECIMAL_PART  => ln_fit_withheld_dec
                           );


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_ss_tips,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_ss_tips_main,
                            P_DECIMAL_PART  => ln_ss_tips_dec
                           );



		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_total_wages,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_total_wages_main,
                            P_DECIMAL_PART  => ln_total_wages_dec
                           );

                ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_ss_er_taxable,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_ss_er_taxable_main,
                            P_DECIMAL_PART  => ln_ss_er_taxable_dec
                           );


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_medicare_er_taxable,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_medicare_er_taxable_main,
                            P_DECIMAL_PART  => ln_medicare_er_taxable_dec
                           );


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_eic_advance,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_eic_advance_main,
                            P_DECIMAL_PART  => ln_eic_advance_dec
                           );

    /* Bug 9357061: Splitting of Integer part and Decimal part end */



    ln_w2_uncoll_med_ss := ln_w2_uncoll_med_gtl
                               + ln_w2_uncoll_med_tips
                               + ln_w2_uncoll_ss_gtl
                               + ln_w2_uncoll_ss_tax_tips;

    /* Bug 9357061: Splitting of Integer part and Decimal part begin */


	        ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_w2_uncoll_med_ss,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_w2_uncoll_med_ss_main,
                            P_DECIMAL_PART  => ln_w2_uncoll_med_ss_dec
                           );

    /* Bug 9357061: Splitting of Integer part and Decimal part end */

    ln_taxable_ss_wage := NVL(ln_ss_er_taxable,0) * 0.124;
    IF ln_taxable_ss_wage < 0 THEN
       hr_utility.trace('001.'||'Tax Unit ID: '||TO_CHAR(p_tax_unit_id)||
               ' has negative B5A Total Taxable SS Wages.  Please check.');
    END IF;

    /* Bug 9357061: Splitting of Integer part and Decimal part begin */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_taxable_ss_wage,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_taxable_ss_wage_main,
                            P_DECIMAL_PART  => ln_taxable_ss_wage_dec
                           );

    /* Bug 9357061: Splitting of Integer part and Decimal part end */

    ln_941_box5b  := NVL(ln_ss_tips,0) * 0.124;
    IF ln_941_box5b < 0 THEN
        hr_utility.trace('001.'||'Tax Unit ID: '||TO_CHAR(p_tax_unit_id)||
              ' has negative B5B Total Taxable SS Wages.  Please check.');
    END IF;

    /* Bug 9357061: Splitting of Integer part and Decimal part begin */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_941_box5b,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_941_box5b_main,
                            P_DECIMAL_PART  => ln_941_box5b_dec
                           );

    /* Bug 9357061: Splitting of Integer part and Decimal part end */

    ln_taxable_medicare := NVL(ln_medicare_er_taxable,0) * 0.029;
    IF ln_taxable_medicare < 0 THEN
        hr_utility.trace('001.'||'Tax Unit ID: '||TO_CHAR(p_tax_unit_id)||
              ' has negative B5C Taxable Medicare Wages.  Please check.');
    END IF;

    /* Bug 9357061: Splitting of Integer part and Decimal part begin */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_taxable_medicare,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_taxable_medicare_main,
                            P_DECIMAL_PART  => ln_taxable_medicare_dec
                           );

     /* Bug 9357061: Splitting of Integer part and Decimal part end */

    ln_tot_ss_medicare_tax := NVL(ln_taxable_ss_wage,0) +
                              NVL(ln_taxable_medicare,0) +
                              NVL(ln_941_box5b,0);
    IF ln_tot_ss_medicare_tax < 0 THEN
        hr_utility.trace('001.'||'Tax Unit ID: '||TO_CHAR(p_tax_unit_id)||
               ' has negative B5D Total SS Medicare Taxes.  Please check.');
    END IF;

     /* Bug 9357061: Splitting of Integer part and Decimal part begin */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_tot_ss_medicare_tax,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_tot_ss_medicare_tax_main,
                            P_DECIMAL_PART  => ln_tot_ss_medicare_tax_dec
                           );

     /* Bug 9357061: Splitting of Integer part and Decimal part end */

    ln_tot_tax_bfr_adj := ln_fit_withheld + ln_tot_ss_medicare_tax;

     /* Bug 9357061: Splitting of Integer part and Decimal part end */


		ln_func_value := SPLIT_NUMBER_INTO_INT_DECIMAL
		                   (
                            P_NUMBER        => ln_tot_tax_bfr_adj,
			    P_DEC           => ln_dec_digits,
                            P_INTEGER_PART  => ln_tot_tax_bfr_adj_main,
                            P_DECIMAL_PART  => ln_tot_tax_bfr_adj_dec
                           );

     /* Bug 9357061: Splitting of Integer part and Decimal part end */

    -- Following is the code for writing XML data
    vXMLTable.DELETE;
    vCtr := 0;
    vXMLTable(vCtr).xmlstring := '<?xml version="1.0" ?>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '<PAYUS941>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '  '
                                     || '<LIST_G_TAX_UNIT_HEADER>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '    '
                                     || '<G_TAX_UNIT_HEADER>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<YEAR>'
                                     || p_year || '</YEAR>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<YEAR1>'
                                     || p_year || '</YEAR1>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<YEAR2>'
                                     || p_year || '</YEAR2>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN>'
                                     || l_gre_ein || '</EIN>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring                        -- Bug 9357061: XML tags for the Split EIN Digits start.
                                     || '      '
                                     ||'<EIN_1>'
                                     || l_gre_EIN_1 || '</EIN_1>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_2>'
                                     || l_gre_EIN_2 || '</EIN_2>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_3>'
                                     || l_gre_EIN_3 || '</EIN_3>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_4>'
                                     || l_gre_EIN_4 || '</EIN_4>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_5>'
                                     || l_gre_EIN_5 || '</EIN_5>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_6>'
                                     || l_gre_EIN_6 || '</EIN_6>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_7>'
                                     || l_gre_EIN_7 || '</EIN_7>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_8>'
                                     || l_gre_EIN_8 || '</EIN_8>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIN_9>'
                                     || l_gre_EIN_9 || '</EIN_9>';                -- Bug 9357061: XML tags for the Split EIN Digits end.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<gre_name>'
                                     ||'<![CDATA[ '|| l_gre_name || ' ]]>'||'</gre_name>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<ADDRESS1>'
                                     ||'<![CDATA[ '|| l_ADDRESS || ' ]]>'||'</ADDRESS1>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<CITY>'
                                     || l_CITY || '</CITY>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<STATE>'
                                     || l_STATE || '</STATE>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<ZIP>'
                                     || l_ZIP || '</ZIP>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<QTR>'
                                     || p_qtr || '</QTR>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EMP_COUNT>'
                                     || ln_EMP_COUNT || '</EMP_COUNT>';
 /*   IF ln_941_box2 = 0 THEN ln_941_box2 := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B2_TOTAL_WAGES>'
                                     || ln_941_box2
                                     || '</B2_TOTAL_WAGES>';*/
    IF ln_total_wages_main = 0 THEN ln_total_wages_main := NULL; END IF;              -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B2_TOTAL_WAGES>'
                                     || ln_total_wages_main
                                     || '</B2_TOTAL_WAGES>';
    IF ln_total_wages_main <> 0 AND ln_total_wages_dec IS NULL THEN ln_total_wages_dec := '00';END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B2_TOTAL_WAGES_DEC>'
                                     || ln_total_wages_dec
                                     || '</B2_TOTAL_WAGES_DEC>';                      -- Bug 9357061: XML tags for the integer and decimal, end.
    IF ln_supp_earn_fit = 0 THEN ln_supp_earn_fit := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_SUPP_EARN_FIT>'
                                     || ln_supp_earn_fit
                                     || '</FWT_SUPP_EARN_FIT>';
    IF ln_supp_earn_nwfit = 0 THEN ln_supp_earn_nwfit := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_SUPP_EARN_NWFIT>'
                                     || ln_supp_earn_nwfit
                                     || '</FWT_SUPP_EARN_NWFIT>';
    IF ln_pretax_dedn_fit = 0 THEN ln_pretax_dedn_fit := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<PRE_TAX_DED_FOR_FIT>'
                                     || ln_pretax_dedn_fit
                                     || '</PRE_TAX_DED_FOR_FIT>';
    IF ln_regular_earnings = 0 THEN ln_regular_earnings := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_REGULAR_EARNINGS>'
                                     || ln_regular_earnings
                                     || '</FWT_REGULAR_EARNINGS>';
/*    IF ln_fit_withheld = 0 THEN ln_fit_withheld := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_WITHHELD>'
                                     || ln_fit_withheld
                                     || '</FWT_WITHHELD>';*/
    IF ln_fit_withheld_main = 0 THEN ln_fit_withheld_main := NULL; END IF;     -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_WITHHELD>'
                                     || ln_fit_withheld_main
                                     || '</FWT_WITHHELD>';
    IF ln_fit_withheld_main <> 0 AND ln_fit_withheld_dec IS NULL THEN ln_fit_withheld_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<FWT_WITHHELD_DEC>'
                                     || ln_fit_withheld_dec
                                     || '</FWT_WITHHELD_DEC>';                 -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_ss_er_taxable = 0 THEN ln_ss_er_taxable := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE>'
                                     || ln_ss_er_taxable
                                     || '</SS_ER_TAXABLE>';*/
    IF ln_ss_er_taxable_main = 0 THEN ln_ss_er_taxable_main := NULL; END IF;   -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE>'
                                     || ln_ss_er_taxable_main
                                     || '</SS_ER_TAXABLE>';
    IF ln_ss_er_taxable_main <> 0 AND ln_ss_er_taxable_dec IS NULL THEN ln_ss_er_taxable_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_DEC>'
                                     || ln_ss_er_taxable_dec
                                     || '</SS_ER_TAXABLE_DEC>';               -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_941_box5a = 0 THEN ln_941_box5a := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5A_TAXABLE_SS_WAGES>'
                                     || ln_941_box5a
                                     || '</B5A_TAXABLE_SS_WAGES>';*/
    IF ln_taxable_ss_wage_main = 0 THEN ln_taxable_ss_wage_main := NULL; END IF; -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5A_TAXABLE_SS_WAGES>'
                                     || ln_taxable_ss_wage_main
                                     || '</B5A_TAXABLE_SS_WAGES>';
    IF ln_taxable_ss_wage_main <> 0 AND ln_taxable_ss_wage_dec IS NULL THEN ln_taxable_ss_wage_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5A_TAXABLE_SS_WAGES_DEC>'
                                     || ln_taxable_ss_wage_dec
                                     || '</B5A_TAXABLE_SS_WAGES_DEC>';       -- Bug 9357061: XML tags for the integer and decimal, end.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<TAXABLE_SS_TIPS />';
/*    IF ln_ss_tips = 0 THEN ln_ss_tips := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS>'
                                     || ln_ss_tips
                                     || '</SS_ER_TAXABLE_TIPS>';*/
    IF ln_ss_tips_main = 0 THEN ln_ss_tips_main := NULL; END IF;             -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS>'
                                     || ln_ss_tips_main
                                     || '</SS_ER_TAXABLE_TIPS>';
    IF ln_ss_tips_main <> 0 AND ln_ss_tips_dec IS NULL THEN ln_ss_tips_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS_DEC>'
                                     || ln_ss_tips_dec
                                     || '</SS_ER_TAXABLE_TIPS_DEC>';        -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_941_box5b = 0 THEN ln_941_box5b := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS_F>'
                                     || ln_941_box5b
                                     || '</SS_ER_TAXABLE_TIPS_F>';*/
    IF ln_941_box5b_main = 0 THEN ln_941_box5b_main := NULL; END IF;        -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS_F>'
                                     || ln_941_box5b_main
                                     || '</SS_ER_TAXABLE_TIPS_F>';
    IF ln_941_box5b_main <> 0 AND ln_941_box5b_dec IS NULL THEN ln_941_box5b_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<SS_ER_TAXABLE_TIPS_F_DEC>'
                                     || ln_941_box5b_dec
                                     || '</SS_ER_TAXABLE_TIPS_F_DEC>';      -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_medicare_er_taxable = 0 THEN ln_medicare_er_taxable := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<MEDICARE_ER_TAXABLE>'
                                     || ln_medicare_er_taxable
                                     || '</MEDICARE_ER_TAXABLE>';*/
    IF ln_medicare_er_taxable_main = 0 THEN ln_medicare_er_taxable_main := NULL; END IF;  -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<MEDICARE_ER_TAXABLE>'
                                     || ln_medicare_er_taxable_main
                                     || '</MEDICARE_ER_TAXABLE>';
    IF ln_medicare_er_taxable_main <> 0 AND ln_medicare_er_taxable_dec IS NULL THEN ln_medicare_er_taxable_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<MEDICARE_ER_TAXABLE_DEC>'
                                     || ln_medicare_er_taxable_dec
                                     || '</MEDICARE_ER_TAXABLE_DEC>';      -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_941_box5c = 0 THEN ln_941_box5c := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5C_TAXABLE_MEDICARE_WAGES>'
                                     || ln_941_box5c
                                     || '</B5C_TAXABLE_MEDICARE_WAGES>';*/
    IF ln_taxable_medicare_main = 0 THEN ln_taxable_medicare_main := NULL; END IF; -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5C_TAXABLE_MEDICARE_WAGES>'
                                     || ln_taxable_medicare_main
                                     || '</B5C_TAXABLE_MEDICARE_WAGES>';
    IF ln_taxable_medicare_main <> 0 AND ln_taxable_medicare_dec IS NULL THEN ln_taxable_medicare_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5C_TAXABLE_MEDICARE_WAGES_DEC>'
                                     || ln_taxable_medicare_dec
                                     || '</B5C_TAXABLE_MEDICARE_WAGES_DEC>'; -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_941_box5d = 0 THEN ln_941_box5d := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5D_TOTAL_SS_MEDICARE_TAXES>'
                                     || ln_941_box5d
                                     || '</B5D_TOTAL_SS_MEDICARE_TAXES>';*/
    IF ln_tot_ss_medicare_tax_main = 0 THEN ln_tot_ss_medicare_tax_main := NULL; END IF;  -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5D_TOTAL_SS_MEDICARE_TAXES>'
                                     || ln_tot_ss_medicare_tax_main
                                     || '</B5D_TOTAL_SS_MEDICARE_TAXES>';
    IF ln_tot_ss_medicare_tax_main <> 0 AND ln_tot_ss_medicare_tax_dec IS NULL THEN ln_tot_ss_medicare_tax_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B5D_TOTAL_SS_MEDICARE_TAXES_DEC>'
                                     || ln_tot_ss_medicare_tax_dec
                                     || '</B5D_TOTAL_SS_MEDICARE_TAXES_DEC>'; -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_941_box6 = 0 THEN ln_941_box6 := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B6_TOTAL_B3_B5D>'
                                     || ln_941_box6
                                     || '</B6_TOTAL_B3_B5D>';*/
    IF ln_tot_tax_bfr_adj_main = 0 THEN ln_tot_tax_bfr_adj_main := NULL; END IF;   -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B6_TOTAL_B3_B5D>'
                                     || ln_tot_tax_bfr_adj_main
                                     || '</B6_TOTAL_B3_B5D>';
    IF ln_tot_tax_bfr_adj_main <> 0 AND ln_tot_tax_bfr_adj_dec IS NULL THEN ln_tot_tax_bfr_adj_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<B6_TOTAL_B3_B5D_DEC>'
                                     || ln_tot_tax_bfr_adj_dec
                                     || '</B6_TOTAL_B3_B5D_DEC>';   -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_w2_uncoll_med_ss = 0 THEN ln_w2_uncoll_med_ss := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<W2_UNCOLL_MED_SS>'
                                     || ln_w2_uncoll_med_ss
                                     ||  '</W2_UNCOLL_MED_SS>';*/
    IF ln_w2_uncoll_med_ss_main = 0 THEN ln_w2_uncoll_med_ss_main := NULL; END IF;  -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<W2_UNCOLL_MED_SS>'
                                     || ln_w2_uncoll_med_ss_main
                                     ||  '</W2_UNCOLL_MED_SS>';
    IF ln_w2_uncoll_med_ss_main <> 0 AND ln_w2_uncoll_med_ss_dec IS NULL THEN ln_w2_uncoll_med_ss_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<W2_UNCOLL_MED_SS_DEC>'
                                     || ln_w2_uncoll_med_ss_dec
                                     ||  '</W2_UNCOLL_MED_SS_DEC>';   -- Bug 9357061: XML tags for the integer and decimal, end.
/*    IF ln_eic_advance =0 THEN ln_eic_advance := NULL; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIC_ADVANCE>'
                                     || ln_eic_advance
                                     || '</EIC_ADVANCE>';*/
    IF ln_eic_advance_main =0 THEN ln_eic_advance_main := NULL; END IF;  -- Bug 9357061: XML tags for the integer and decimal, start.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIC_ADVANCE>'
                                     || ln_eic_advance_main
                                     || '</EIC_ADVANCE>';
    IF ln_eic_advance_main <> 0 AND ln_eic_advance_dec IS NULL THEN ln_eic_advance_dec := '00'; END IF;
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<EIC_ADVANCE_DEC>'
                                     || ln_eic_advance_dec
                                     || '</EIC_ADVANCE_DEC>';     -- Bug 9357061: XML tags for the integer and decimal, end.
/*  vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<STATE_ABBR_1>'
                                     || lv_STATE_ABBR_1
                                     || '</STATE_ABBR_1>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '      '
                                     ||'<STATE_ABBR_2>'
                                     || lv_STATE_ABBR_2
                                     || '</STATE_ABBR_2>';  */
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '    '
                                     ||'</G_TAX_UNIT_HEADER>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '  '
                                     ||'</LIST_G_TAX_UNIT_HEADER>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '<C_TRACE />';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                     || '</PAYUS941>';
  END get_941_balances;
-- covers 9. Advance earned income credit (CP_EIC_ADVANCE)
-- covers 5d. Total SS  Taxes (C_B5D_TOTAL_SS_MEDICARE_TAXES)
-- covers 5c.(ii) Taxable Medicare wages  (C_B5C_TAXABLE_MEDICARE_WAGES)
-- covers 5c.(i) Taxable Medicare wages  (CP_MEDICARE_ER_TAXABLE)
-- covers 5b.(ii) Taxable SS Tips (CF_SS_ER_TAXABLE_TIPS)
-- covers 5b.(i) Taxable SS Tips (CP_SS_ER_TAXABLE_TIPS)
-- covers 5a.(ii) Taxable SS Wages (C_B5A_TAXABLE_SS_WAGES)
-- covers 5a.(i) Taxable SS Wages (CP_SS_ER_TAXABLE)
-- covers 3. Total IT withheld from Wages, Tips and other compensation
--           (CP_FWT_WITHHELD)
-- covers 2. Wages, tips and other compensation (C_B2_TOTAL_WAGES)
-- covers 1. No. of employees (l_C_emp_count)
--******** Generate Federal Tax Balances (end)
--******** Write to CLOB (start)


  PROCEDURE WritetoCLOB (p_XML OUT NOCOPY CLOB)
  IS
    l_xfdf_string                                              CLOB;
  BEGIN
    hr_utility.set_location('Entered Procedure Write to clob ',100);
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    -- if vXMLTable.count > 0 then
    FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST
    LOOP
       dbms_lob.writeAppend(l_xfdf_string,
                            LENGTH(vXMLTable(ctr_table).xmlstring),
                            vXMLTable(ctr_table).xmlstring );
    END LOOP;
    p_XML := l_xfdf_string;
  EXCEPTION
    WHEN OTHERS THEN
      HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
      HR_UTILITY.RAISE_ERROR;
  END WritetoCLOB;


  PROCEDURE gen_941_report(p_business_group_id IN NUMBER,
                           p_tax_unit_id       IN NUMBER,
                           p_year              IN VARCHAR2,
                           p_qtr               IN VARCHAR2,
                           p_template_name     IN VARCHAR2,
                           p_xml              OUT NOCOPY Clob)
  IS
  BEGIN
    set_session_variables_contexts(
              p_business_group_id,
              p_tax_unit_id,
              p_year,
              p_qtr);
    get_941_balances(
              p_business_group_id,
              p_tax_unit_id,
              p_year,
              p_qtr);
    WritetoCLOB (p_XML);

  END gen_941_report;

  /*****************************************************************************
   Name      : pay_us_941_report_wrapper
   Purpose   : calls procedure gen_941_report, generates xml output and submits
	       xml publisher report to merge the xml output with template.
  *****************************************************************************/
  PROCEDURE pay_us_941_report_wrapper
                  (  errbuf              OUT NOCOPY VARCHAR2,
                     retcode             OUT NOCOPY VARCHAR2,
		     p_business_group_id IN NUMBER,
                     p_tax_unit_id       IN VARCHAR2,
                     p_year              IN NUMBER,
                     p_qtr               IN VARCHAR2,
		     p_valid_template_list IN VARCHAR2,
		     p_appl_short_name   IN VARCHAR2,
                     p_template_name     IN VARCHAR2,
  		     p_effective_date    IN VARCHAR2
                 )
  IS
--bug 8267963
    cursor csr_release is
    select      to_number(substr(PRODUCT_VERSION,1,2))
    from FND_PRODUCT_INSTALLATIONS
    where APPLICATION_ID = 800;

     l_release        NUMBER;
--bug 8267963
     l_xml            CLOB;
     l_req_id         NUMBER;
     l_req_id2        NUMBER;
     l_program        VARCHAR2(100);
     l_errbuf         VARCHAR2(240);
     l_procedure_name VARCHAR2(100);

    BEGIN

      l_procedure_name     := '.pay_us_941_report_wrapper';
      hr_utility.set_location('Entering '|| g_package || l_procedure_name, 10);

      --Bug 8267963
      OPEN csr_release;
      FETCH csr_release INTO l_release;
      CLOSE csr_release;
	-- Bug 8267963

      /* Generate the xml output */
      gen_941_report(p_business_group_id => p_business_group_id,
                     p_tax_unit_id       => p_tax_unit_id,
                     p_year              => p_year,
                     p_qtr               => p_qtr,
                     p_template_name     => 'DUMMY',
                     p_xml               => l_xml);

      FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST
      LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vXMLTable(ctr_table).xmlstring);
      END LOOP;

      /* Submit XML Report Publisher request for the generated xml output*/
      l_req_id := fnd_global.conc_request_id;

      IF  l_req_id > 0 THEN

         l_program := 'XDOREPPB';

	  if(l_release = 12) then

         l_req_id2 := fnd_request.submit_request(
                                  application    => 'XDO',
                                  program        => l_program,
                                  argument1      => 'N',
                                  argument2      => l_req_id,
                                  argument3      => 801,
                                  argument4      => p_template_name,
                                  argument5      => 'en-US',
                                  argument6      => 'N',
                                  argument7      => 'PDF',
                                  argument8      => 'PDF' );

        hr_utility.trace ('Leaving 12'|| l_procedure_name);

        else

         l_req_id2 := fnd_request.submit_request(
                                  application    => 'XDO',
                                  program        => l_program,
                                  argument1      => l_req_id,
                                  argument2      => 801,
                                  argument3      => p_template_name,
                                  argument4      => 'en-US',
                                  argument5      => 'N',
                                  argument6      => 'PDF',
                                  argument7      => 'PDF' );



           hr_utility.trace ('Leaving 11i'|| l_procedure_name);

        end if;

      ELSE

	 fnd_message.retrieve(l_errbuf);

      END IF;

      IF l_req_id2 > 0 THEN

        Commit;

      ELSE

        fnd_message.retrieve(l_errbuf);

      END IF;

    EXCEPTION
      WHEN others THEN
         hr_utility.raise_error;

    hr_utility.set_location('Leaving '|| g_package || l_procedure_name, 20);

  End pay_us_941_report_wrapper ;

END pay_us_941_report;




/
