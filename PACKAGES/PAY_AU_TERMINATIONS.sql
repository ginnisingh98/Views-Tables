--------------------------------------------------------
--  DDL for Package PAY_AU_TERMINATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TERMINATIONS" AUTHID CURRENT_USER AS
/*  $Header: pyauterm.pkh 120.9.12010000.3 2009/09/07 12:16:06 pmatamsr ship $ */
/*
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU terminations version 2
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  ====================================================
**  14-AUG-2000 sclarke  115.0     Created for AU
**  12-SEP-2000 sclarke  115.0     Added processed function
**  27-SEP-2000 sclarke  115.1     Added LSL function
**  04-DEC-2000 sclarke  115.2     Bug 1519569 rounding of deductions on marginal tax
**  15-DEC-2000 sclarke  115.3     Bug 1544503
**
**  ============== Formula Fuctions ====================
**  Package containing addition processing required by
**  terminations module in AU localisatons.
**  28-NOV-2001  nnaresh 115.4     Updated for GSCC Standards
**  04-DEC-2002 Ragovind 115.6     Added NOCOPY for the functions check_rollover, etp_prepost_ratios,
** 				   get_long_service_leave, term_lsl_eligibility_years
**  15-May-2003 Ragovind 115.7     Bug#2819479 - ETP Pre/Post Enhancement
**  23-Jul-2003 Nanuradh 115.8     Bug#2984390 - ETP Pre/post Enhancement - Added an extra parameter p_etp_service_date
**                                 to the function etp_prepost_ratios
**  10-May-2003 Ragovind 115.9     Bug#3263690 - NGE calculation Enhancement.
**  09-AUG-2004 abhkumar 115.10    Bug#2610141 - Legal Employer enhancement changes.
**  08-SEP-2004 abhkumar 115.11    Bug#2610141 - Added a parameter to function calculate_term_asg_nge to support the
**				   versioning of the tax formula.
**  22-APR-2004 ksingla  115.12    Bug#4177679 - Added a new parameter to the function etp_prepost_ratios.
**  05-AUG-2005 abhkumar 115.13    Bug#4538463 - Added a parameter to function calculate_term_asg_nge
**  01-SEP-2005 abhkumar 115.14    Bug#4474896 - Average Earnings Calculation enhancement
**  02-Apr-2006 abhargav 115.15    Bug#5107059 - Added new function get_total_accrual_hours().
**  27-Jun-2006 hnainani 115.16   Bug# 5056831 - Added Function Override_eligibility
**
** 21-Sep-2006  hnainani 115.24    Bug# 5056831  - Removed extra param to Override_eligibility based
**                                              on review comments
** 09-May-2007  priupadh 115.25    Bug# 5956223  Added new function calculate_etp_tax,get_trans_prev_etp
** 16-May-2007  priupadh 115.26    Bug# 5956223  Removed function get_trans_prev_etp, added get_fin_year_end
** 31-May-2007  priupadh 115.27    Bug# 6071863  Added function get_prev_age
** 23-Aug-2007  priupadh 115.28    Bug# 6192381  Added function au_check_trans
** 30-Jul-2009  skshin   115.23    Bug# 8725341  Added Earnings_Leave_Loading balance to c_get_ytd_def_bal_ids cursor
** 07-Sep-2009  pmatamsr 115.24    Bug# 8769345  Added new input parameter to check_rollover function.
*/
  --
  -------------------------------------------------------------------------------------------------
  --
  -- FUNCTION get_long_service_leave
  --
  -- Returns :
  --           1 if function runs successfully
  --           0 otherwise
  --
  -- Purpose : Calculates net amount of long service leave accrual plan and breaks the
  --           amounts into the appropriate time buckets as required for Terminations
  --           tax calculations.  Days suspended is taken into account by using the accrual
  --           fastformula.
  --
  -- In :      p_assignment_id     - assignment which is enrolled in the accrual plan
  --           p_payroll_id        - payroll to which the assignment is enrolled
  --           p_business_group_id
  --           p_effective_date    - date up to which accrual is to be calculated
  --
  -- Out :     p_pre_aug_1978      - net leave amount before from start of accrual plan to 15-AUG-1978
  --           p_post_aug_1978     - net leave amount from 16-AUG-1978 to 17-AUG-1993
  --           p_post_aug_1993     - net leave amount from 18-AUG-1993 until effective_date
  --
  -- Uses :    per_accrual_calc_functions
  --           pay_au_terminations
  --           hr_utility
  --
  ------------------------------------------------------------------------------------------------
  function get_long_service_leave
  (p_assignment_id        in  number
  ,p_payroll_id           in  number
  ,p_business_group_id    in  number
  ,p_effective_date       in  date
  ,p_pre_aug_1978         out NOCOPY number
  ,p_post_aug_1978        out NOCOPY number
  ,p_post_aug_1993        out NOCOPY number
  ) return number;
  --
  --

/* Bug# 5056831 */
--------------------------------------------------------------------------------------
  -- Function  override_elig
  --
  -- Returns 'Y' if the element entry has already been prorated in a payroll
  -- run. Used by the PAYAUTRM form views
  --
  function override_elig
  (p_element_entry_id      number
  ,p_input_value_id       number
  , p_effective_date      date)
  return varchar2;
  --

  --------------------------------------------------------------------------------------
  -- Function processed
  --
  -- Returns 'Y' if the element entry has already been processed in a payroll
  -- run. Used by the PAYAUTRM form views
  --
  function processed
  (p_element_entry_id      number
  ,p_original_entry_id     number
  ,p_processing_type       varchar2
  ,p_entry_type            varchar2
  ,p_effective_date        date)
  return varchar2;
  --
  ---------------------------------------------------------------------
  -- Function get_accrual_plan_by_category
  --
  -- RETURNS: accrual_plan_id if successful, 0 otherwise
  --
  -- PURPOSE: To retrieve accrual plan id for designated category, copy
  --          of hr_au_holidays equivalent except that when no accrual
  --          plan is found return 0, this is to allow for casual employees
  --          who do not have accrual plans and are not supposed to be paid
  --          for such on termination.
  --
  -- IN:      assignment_id
  --          effective_date
  --          accrual plan category - annual leave or long service leave
  -- OUT:
  --
  --
  -- USES:  hr_utility
  --        hr_au_holidays
  --
  function get_accrual_plan_by_category
  (p_assignment_id    in    number
  ,p_effective_date   in    date
  ,p_plan_category    in    varchar2)
  return number;
  --
  ------------------------------------------------------------
  -- Function calculate_marginal_tax
  --
  -- RETURNS: marginal tax deduction for termination
  --
  -- PURPOSE: used by formula function to calculate termination marginal rate tax deduction
  --
  -- IN:        p_date_earned - passed as a context
  --            p_tax_variation_type - tax variation, percentage, marginal, fixed etc
  --            p_tax_variation_amount - holds amount for tax variation type
  --            p_gross_termination_amount - gross termination earnings
  --            p_average_pay - average earnings
  --            p_normal_amount - earnings to be taxed
  --            p_a_variable - variable used in marginal rate formula
  --            p_b_variabel - variable used in marginal rate formula
  --            p_pay_frequency - frequency of payroll used by formula to convert back to period amount
  -- OUT:
  --
  --
  -- USES:  hr_utility
  --        hr_au_holidays
  --
  function calculate_marginal_tax
  (p_date_earned                  in date
  ,p_tax_variation_type          in varchar2
  ,p_tax_variation_amount        in number
  ,p_gross_termination_amount    in number
  ,p_average_pay                 in number
  ,p_a_variable1                 in number
  ,p_b_variable1                 in number
  ,p_a_variable2                 in number
  ,p_b_variable2                 in number
  ,p_pay_freq                    in number
  ,p_tax_scale                   in number
  ) return number;
  --
  ---------------------------------------------------
  --
  -- Function max_etp_tax_free
  --
  -- Calculates the maximum allowable amount of the
  -- ETP payment components which can be free of tax
  --
  -- RETURNS: maximum tax free amount
  --
  -- USES:    hr_utility
  --
  function max_etp_tax_free
  (p_years_of_service           in  number
  ,p_lump_d_tax_free            in  number
  ,p_lump_d_service_increment   in  number
  )
  return number;
  --
  ---------------------------------------------------
  --
  -- Function check_rollover
  --
  -- Checks to see if the user has entered a rollover
  -- amount which will exceed the maximum allowable
  --
  -- RETURNS: 1 if amount is OK
  --          0 if amount exceeds limit
  --          message for error
  --
  -- USES:    hr_utility
  --
  function check_rollover
  (p_rollover_amount            in   number
  ,p_maximum_rollover           in   number
  ,p_message                    out  NOCOPY varchar2
  ,p_etp_component              in   varchar2 default 'Taxable'
  )
  return number;
  --
  --------------------------------------------------
  --
  -- Function etp_prepost_ratios
  --
  -- Calculates the pre 01 July 1983 ratio for calculation of ETP
  -- and the post 30 Jun 1983 ratio for calculation ETP
  --
  -- RETURNS:
  --
  -- IN:      p_assignment_id - assignment
  --          p_hire_date - date employee started work
  --          p_termination_date - date employee ends employment
  --
  -- OUT:     p_pre01jul1983_ratio - ratio to use when calculating the pre 01 July 1983 portion of ETP
  --          p_post30jun1983_ratio - ratio to use when calculating the post 30 June 1983 portion of ETP
  --
  -- USES:    hr_utility
  --
  --
  function etp_prepost_ratios
  (p_assignment_id              in  number
  ,p_hire_date                  in  date
  ,p_termination_date           in  date
  ,p_term_form_called           in  varchar2   -- Bug#2819479
  ,p_pre01jul1983_days          out NOCOPY number
  ,p_post30jun1983_days         out NOCOPY number
  ,p_pre01jul1983_ratio         out NOCOPY number
  ,p_post30jun1983_ratio        out NOCOPY number
  ,p_etp_service_date		out NOCOPY date  /* Bug#2984390 */
  ,p_le_etp_service_date        out NOCOPY date     /* Bug 4177679 */
  )
  return number;


  --
  --------------------------------------------------
  --
  -- Function term_lsl_eligibility_years
  --
  -- gets the number of years a person must have worked
  -- before they become eiligible to recieve payment for
  -- long service leave upon termination of employment
  --
  -- RETURNS: 1 if successful, 0 otherwise
  --
  -- IN:      p_date_earned - context passed in form payroll run
  --          p_accrual_plan_id - id of the particular long service leave accrual plan
  --
  -- OUT:     p_eligibility_years - number of years until eligible
  --
  -- USES:    hr_utility
  --
  --
  function term_lsl_eligibility_years
  (p_date_earned                  in date
  ,p_accrual_plan_id              in number
  ,p_eligibility_years            out NOCOPY number
  )
  return number;
  --

  /*
  Bug#3263690 - NGE calculation Enhancement
  Function Declaration
  */
  function calculate_term_asg_nge
    ( p_assignment_id 		in per_all_assignments_f.assignment_id%TYPE,
      p_business_group_id 	in hr_all_organization_units.organization_id%TYPE,
      p_date_earned 		in date,
      p_tax_unit_id 		in hr_all_organization_units.organization_id%TYPE,
      p_assignment_action_id IN number, /*Bug 4538463*/
      p_payroll_id IN NUMBER, /*Bug 4538463*/
      p_termination_date 	in date,
      p_hire_date 		in date,
      p_period_start_date 	in date,
      p_period_end_date 	in date,
      p_case 			out NOCOPY varchar2,
      p_earnings_standard	out 	NOCOPY number, /*Bug# 4474896*/
      p_pre_tax_spread 	out 	NOCOPY number, /*Bug# 4474896*/
      p_pre_tax_fixed 	out 	NOCOPY number, /*Bug# 4474896*/
      p_pre_tax_prog 	out 	NOCOPY number,  /*Bug# 4474896*/
      p_paid_periods  	out 	NOCOPY number, /*Bug# 4474896*/
      p_use_tax_flag            IN VARCHAR2 --2610141
  ) return number;


  -----------------------------------------------------------------------
  -- Cursor 	   : c_get_ytd_def_bal_ids
  -- Description   : To get the YTD defined balance ids for the balances
  --		     Retro LT 12 Mths Curr Yr Amount
  --                 Retro LT 12 Mths Prev Yr Amount
  --                 Earnings_Total
  -- 		     Earnings_Non_Taxable
  -- 		     Lump Sum E Payments
  -----------------------------------------------------------------------
  CURSOR c_get_ytd_def_bal_ids (c_db_item_suffix IN pay_balance_dimensions.DATABASE_ITEM_SUFFIX%type)
  IS
  SELECT  pdb.defined_balance_id, pbt.balance_name, pbd.DIMENSION_NAME
  FROM pay_balance_types pbt,
         	 pay_balance_dimensions pbd,
         	 pay_defined_balances pdb
      WHERE pbt.balance_name in ( 'Earnings_Standard'
                                 ,'Pre Tax Spread Deductions'
                                 ,'Pre Tax Fixed Deductions'       /*bug 4474896*/
                                 ,'Pre Tax Progressive Deductions'
                                 ,'Earnings_Leave_Loading') /*bug8725341*/
  	AND pbt.balance_type_id = pdb.balance_type_id
  	AND pdb.balance_dimension_id = pbd.balance_dimension_id
  	AND pbd.DATABASE_ITEM_SUFFIX = c_db_item_suffix --2610141
  	AND pbt.legislation_code = 'AU'
  	and pbt.legislation_code = pbd.legislation_code
  	AND pbd.legislation_code = 'AU';


  TYPE g_ytd_tab_bals IS TABLE OF c_get_ytd_def_bal_ids%rowtype INDEX BY BINARY_INTEGER;
  g_ytd_bals g_ytd_tab_bals;

  g_ytd_def_bals_populated  BOOLEAN;

  -- BBR Tables to store YTD balance details
  --
  g_ytd_input_table		pay_balance_pkg.t_balance_value_tab;
  g_ytd_result_table		pay_balance_pkg.t_detailed_bal_out_tab;
  g_ytd_context_table		pay_balance_pkg.t_context_tab;

  -- BBR Tables to store LE YTD balance details
  --
  g_le_ytd_input_table		pay_balance_pkg.t_balance_value_tab;
  g_le_ytd_result_table		pay_balance_pkg.t_detailed_bal_out_tab;
  g_le_ytd_context_table	pay_balance_pkg.t_context_tab;

  /* End of Bug#3263690 - NGE calculation Enhancement Declaration */
/* Bug 5107059 - Function to return the summed accrued hours of all accrual plan of category AU Annual Leave
   attached with the assignment*/
  FUNCTION get_total_accrual_hours
    ( p_assignment_id    IN    NUMBER
     ,p_business_group_id IN NUMBER
     , p_payroll_id IN Number
      ,p_plan_category    IN    VARCHAR2
      ,p_effective_date   IN    DATE
      ) RETURN NUMBER;

  --
  --------------------------------------------------
  --
  -- Function calculate_etp_tax Bug 5956223
  --
  --  Calculate ETP Tax on the ETP amount passed
  --  based on User Tables values
  --
  -- RETURNS: ETP Tax
  --
  -- IN:      p_etp_amount Amount on which tax needs to be calculated
  --          p_trans_etp  Transitional Or Non Transitional ETP or termination type Death
  --                   Values can be (D Death, TRANS Transitional,NONTRANS Non Transitional )
  --          p_death_benefit_type   Beneficiary in Death case is Dependent or Non Dependent
  --          p_over_pres_age    Yes or No
  --          p_tfn_for_non_dependant  In Death case TFN for Non Dependent
 FUNCTION calculate_etp_tax
  (p_business_group_id            IN NUMBER
  ,p_date_paid                    IN DATE
  ,p_etp_amount                   IN NUMBER
  ,p_trans_etp                    IN VARCHAR2
  ,p_death_benefit_type           IN VARCHAR2
  ,p_over_pres_age                IN VARCHAR2
  ,p_tfn_for_non_dependent        IN VARCHAR2
  ,p_medicare_levy                IN NUMBER
  )
  return number;

    --------------------------------------------------
  --
  -- Function get_fin_year_end Bug 5956223
  --
  --  Calculate Financial Year end date based on a given date
  --
  -- RETURNS: Financial Year end date
  -- IN     :  Date
 FUNCTION get_fin_year_end
   (p_date       IN DATE)
   return date;

     --------------------------------------------------
  --
  -- Function get_prev_age Bug 6071863
  --
  --  Get the Preservation Age from User Table ETP_PRESERVATION_AGE
  --  based on Employee's Date of Birth
  --
  -- RETURNS: Preservation Age
  -- IN     :  Date
 FUNCTION get_prev_age
   (p_date_of_birth       IN DATE,p_date_paid  IN DATE)
  RETURN NUMBER ;

    --------------------------------------------------
  --
  -- Function au_check_trans Bug 6192381
  --
  -- Check if there exists a Transitional ETP or not in the current Pay Period .
  --
  -- RETURNS: Preservation Age
  -- IN     :  Assignment Id
  --        :  Date Earned
 FUNCTION au_check_trans
   (p_assignment_id       IN per_all_assignments_f.assignment_id%TYPE,
    p_date_earned         IN DATE
    )
  RETURN VARCHAR2;

end pay_au_terminations;

/
