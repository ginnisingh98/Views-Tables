--------------------------------------------------------
--  DDL for Package Body PAY_FR_SICKNESS_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_SICKNESS_CALC" AS
/* $Header: pyfrsick.pkb 120.0 2005/05/29 05:10:20 appldev noship $ */

-----------------------------------------------------------------------
-- Date                 Author          Comments
-- 17-9-02              Aditya T.       Initial version of package with programs reqd by                                Absence report and IJSS calc
-- 24-9-02              ASNELL          Added stubs for function calls
-- 30-9-02              Satyajit        Added procedure Calculate_Sickness_Deduction
--                                      and function Get_Open_Days
-- 30-9-02              ASNELL          modified stub calls
-- 07-10-02             ABhaduri        Modified functions for IJSS and
--                                      g_overlap declaration
-- 08-10-02             ABhaduri        Added procedure Get_abs_print_flg
--                                      For checking validity and eligibility
--                                      absences from the report.
-- 08-10-02             ASNELL          Added function get sickness_skip
-- 09-10-02             jrhodes         Completed calc_sickness
--                                       get_sickness_skip
--                                       compare_guarantee
--                                      Get_backdated_payments
--                                      get_Reference_salary
-- 09-10-02 115.11       jrhodes        Completed calc_ijss_gross
--                                      Included temproray FR_ROLLING_BALANCE
-- 09-10-02 115.12       jrhodes        Completed FR_ROLLING_BALANCE
-- 09-10-02 115.13      jrhodes         Changed message name
-- 10-10-02             asnell           added get_gi_payments_audit
-- 11-10-02 115.18      autiwari        Complete version of CALC_LEGAL_GI
-- 11-10-02 115.18      jheer           Initial version of Get_GI_BANDS_audit
--                                         (uses Band_overlaps)
--                                      Compliant with header ver 115.13
-- 14-10-02 115.19      jheer           Added procedure "Enter" and "Leave" trace statements.
-- 14-10-02 115.20      autiwari        Added private function Get_GI_ref_salary_divisor
--                                      Modified Sickness_Calc for No_G(corrected index and removed call to IJSS_Gross)
-- 14-10-02 115.22      vsjain          Changes in calc_legal after testing
-- 14-10-02 115.23      asnell          added get_ben cusor to calc_cagr_gi
-- 15-10-02 115.24      autiwari        Completed procedure Calc_CAGR_GI
--                                      Added private function Use_GI_bands
--                                      Modifications to Calc_LEGAL_GI
--                                      (population of cagr_id and type in g_coverages
--                                       and band usage uses Use_GI_Bands and l_bands table)
--                                      Asnell: Added function Get_CAGR_reference_salary
-- 16-10-02 115.25      autiwari        Minor fixes to Use_GI_Bands and Calc_IJSS_Gross
-- 16-10-02 115.26      asnell          wrong input name in get_gi_payments_audit
-- 16-10-02 115.28      autiwari        Redundant declarations removed
--                                      Calc_CAGR_GI--changed date_to passed to Bands_audit
-- 17-10-02 115.29      autiwari        Calc_CAGR_GI--Asnell:Changed cursor 'get_ben'
--                                      and related conditional logic to get_benefits
--                                      Calc_IJSS--Commented out Null Ref Salary error mssgs
-- 18-10-02 115.30      autiwari        Calc_IJSS--Debugging changes
--                                      G_overlap population only when absence is eligible
--                                      Logic to modify End_date(p_end_date)
--                                      Balance get_value calls changed to date mode
-- 22-10-02 115.33      autiwari        Calc_CAGR_GI - Modified to correct NET for g_coverages
--                                        (to include pymnt for non-absence days)
-- 24-10-02 115.36      abhaduri        Modified get abs_print_flg to
--                                      return the last absence date.
-- 25-10-02 115.38      autiwari        Modified Calc_Cagr_Gi after debugging
-- 30-10-02 115.41      autiwari        Modified Calc_IJSS: Refined Eligibility checking to daily
-- 05-11-02 115.46      autiwari        Revoked 115.45 changes and corrected Get_sickness_skip to
--                                       return correct previous duration (spclly long absences)
-- 06-11-02 115.51      autiwari        Modified Calc_IJSS for retrieving rates throughout the absence duration
--                                      when duration crosses the boundary days for bug #2651295
--                                      Replaced local UDT function with hruserdt
-- 07-11-02 115.52      autiwari        Bugfix 2659924:Commented out IJSS Ineligibility Mssg
--                                              PAY_75021_ABS_INELIG_FOR_IJSS
-- 07-11-02 115.57      autiwari        Bugfix 2651568:Zero divisor for ppl hired on 1st day of mth
-- 08-11-02 115.60      autiwari        Bugfix 2661851:2nd absence in period has incorrect days processed in guarantee
-- 11-11-02 115.61      jheer           Bugfix 2662162: corrected input value names for bands in band_overlaps
--                                      altered rolling year calculation so that it does not add 1
-- 12-11-02 115.63      jheer           Bugfix 2662195 The dates being passed to the get_gi_bands routine were incorrect.

-- 29-11-02 115.70      kavenkat        Bug:2683421:Created a private procedure absence_not_processed to raise error
--                                      Bug:2683421:if unrocessed sickness absence exists.
-- 02-12-02 115.71      kavenkat        Closed the cursor.
-- 04-12-02 115.72      kavenkat        Bug:2683421:Removed the payroll id check in the cursor csr_absence_not_processsed.
-- 11-12-02 115.73      kavenkat        Bug:2706983:Introduced by 2683421.Errors for multiple absences in a pay period.
-- 24-12-02 115.76      abhaduri        Modifications for CPAM processing
--                                      Added 3 new functions/procedures.
--                                      Modified existing func/procs.
-- 21-01-03 115.79      abhaduri        Modified get_sickness_cpam_ijss
--                                      for bug 2751760.
-- 12-02-03 115.79      asnell          added FR_MAP_IJSS_REFERENCE_SALARY to get_reference_salary
--                                      added maternity extensions processing
--                                      fixes for bug 2763291 max ijss
-- 26-02-03 115.81      abhaduri        Modified absence_not_processed
--                                      for bug 2791833 to check for
--                                      payments for absences with IJSS
--                                      estimate as 'N'.
-- 26-03-03 115.82      abhaduri        Incorporated review comments.
--                                      Removed joins with pay_element_links
--                                      and element entries.
-- 04-08-03 115.83      asnell          chenges for retro sickness
-- 05-08-03 115.84      asnell          added concatenated_input / result
--                                      functions to help report retro
--                                      results
-- 04-09-03 115.98      asnell          changed csr_get_entry_processed to not
--                                      check action status as the action may
--                                      still be processing
-- 03-11-03 115.100     asnell 3227237  when fetching results ensure status is
--                                      checked as retro no longer deletes
--                                      rolled back results.
-- 09-12-03 115.101     asnell 3274341  retro for audit on a seperate element
--                                      so fetch extended to look for results of
--                                      FR_SICKNESS_GI_INFO_RETRO
-- 17-12-03 115.101     asnell 3221356  performance bug for 11.5.10 remove redundent
--                                      join to element_links in csr_get_CPAM_results
--                                      change to get_sickness_cpam_skip to use
--                                      person_id index
-- 23-12-03 115.102     asnell 3331014  removed rule hint from get_gi_bands_audit
-- 31-03-04 115.105   autiwari 3545189  Assigning context PAYROLL_ACTION_ID and ELEMENT_TYPE_ID
--                                      to deduction_formula in Get_sickness_deduction
-- 06-05-04 115.107    aparkes 3594040  Removed MJC from cursor in
--                                      get_gi_bands_audit()
--                                      More changes for bug 3274341 (further
--                                      to those in 115.104)
-- 07-05-04 115.108    aparkes          workaround inconsistency in pl/sql vs.
--                                      sql in 8.1.7.4
-- 21-06-04 115.109    abhaduri         Modifeid calc_sickness procedure to
--                                      pass values to partial and unpaid days
--                                      balances.
-- 09-08-04 115.110   abhaduri          Modified 'IJSS_Eligibility_Working_hours
--                                      function, substituted the value of new
--                                      balance FR_ACTUAL_HRS_WORKED_IJSS
--                                      for working time changes.
-----------------------------------------------------------------------
-- PACKAGE GLOBALS
g_ijss_refsal_defbal_id number;
g_map_refsal_defbal_id number;

g_gi_info_element_type_id pay_element_types_f.element_type_id%type;
g_gi_info_absence_id_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_guarantee_type_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_guarantee_id_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_gi_payment_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_net_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_ijss_gross_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_adjustment_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_best_method_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_start_date_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_end_date_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_band1_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_band2_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_band3_iv_id pay_input_values_f.input_value_id%type;
g_gi_info_band4_iv_id pay_input_values_f.input_value_id%type;

g_gi_i_r_element_type_id pay_element_types_f.element_type_id%type;
g_gi_i_r_absence_id_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_guarantee_type_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_guarantee_id_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_gi_payment_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_net_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_ijss_gross_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_adjustment_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_best_method_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_start_date_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_end_date_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_band1_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_band2_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_band3_iv_id pay_input_values_f.input_value_id%type;
g_gi_i_r_band4_iv_id pay_input_values_f.input_value_id%type;

g_ben_element_type_id pay_element_types_f.element_type_id%type;
g_ben_absence_id_iv_id pay_input_values_f.input_value_id%type;
g_ben_guarantee_id_iv_id pay_input_values_f.input_value_id%type;
g_ben_guarantee_type_iv_id pay_input_values_f.input_value_id%type;
g_ben_waiting_days_iv_id pay_input_values_f.input_value_id%type;
g_ben_duration_iv_id pay_input_values_f.input_value_id%type;
g_ben_band1_iv_id pay_input_values_f.input_value_id%type;
g_ben_band1_rate_iv_id pay_input_values_f.input_value_id%type;
g_ben_band2_iv_id pay_input_values_f.input_value_id%type;
g_ben_band2_rate_iv_id pay_input_values_f.input_value_id%type;
g_ben_band3_iv_id pay_input_values_f.input_value_id%type;
g_ben_band3_rate_iv_id pay_input_values_f.input_value_id%type;
g_ben_band4_iv_id pay_input_values_f.input_value_id%type;
g_ben_band4_rate_iv_id pay_input_values_f.input_value_id%type;
g_ben_balance_iv_id pay_input_values_f.input_value_id%type;

-- Used for LEGI and CAGR
TYPE bands_rec IS RECORD
 (band_payment  NUMBER,
  band_rate     NUMBER,
  band_days     NUMBER,
  band_from_dt  DATE,
  band_to_dt    DATE);

TYPE t_bands IS TABLE OF bands_rec INDEX BY BINARY_INTEGER;
l_bands         t_bands;


--
g_package  varchar2(33) := '  PAY_FR_SICKNESS_CALC.';
--

--
-- PUBLIC FUNCTIONS
--
-- Parameter p_long_absence denotes if the absence has a duration more than 180 calendar days
-- For Absence report, this parameter will always be FALSE as only normal case is considered
--
FUNCTION IJSS_Eligibility_Working_hours(
P_Legislation_code      IN      Varchar2 := 'FR',
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_start_date    IN      Date,
P_long_absence          IN      Boolean)
RETURN Varchar2 IS
--
l_bal_date_to Date;
l_bal_date_from Date;
l_ref_from_date Date;
l_rolling_hrs_bal Number;
l_ref_hrs Number;
l_hire_date Date;

l_proc               varchar2(72) := g_package||'IJSS_Eligibility_Working_hours';

-- Cursor to retrieve person's hiredate
Cursor csr_hiredate IS
   SELECT papf.original_date_of_hire
   FROM per_all_people_f papf,
        per_all_assignments_f pasg
   WHERE pasg.assignment_id = p_assignment_id
   AND pasg.Business_group_id= p_business_group_id
   AND p_absence_start_date BETWEEN pasg.effective_start_date and pasg.effective_end_date
   AND papf.person_id = pasg.person_id
   AND papf.Business_group_id=p_Business_group_id
   AND p_absence_start_date BETWEEN papf.effective_start_date and papf.effective_end_date;

-- Cursor for fetching global value
Cursor csr_global_value(c_global_name VARCHAR2,c_date_earned DATE) IS
   SELECT global_value
   FROM ff_globals_f
   WHERE global_name = c_global_name
   AND legislation_code = 'FR'
   AND c_date_earned BETWEEN effective_start_date AND effective_end_date;
--
BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Setting up reference dates required while calculating eligibility
  -- Get last day of previous calendar month
  l_bal_date_to := LAST_DAY(ADD_MONTHS(p_absence_start_date,-1)) ;
  IF NOT(p_long_absence) THEN   --Absence shorter than 180 days
     -- function calculates Working hours contributions over last 3 months
     -- 1st day of 3 calendar months prior to above date
     l_bal_date_from := TRUNC(ADD_MONTHS(p_absence_start_date, -3), 'MONTH');
     l_ref_from_date := l_bal_date_from;
     -- Get rolling balances
     l_rolling_hrs_bal := FR_ROLLING_BALANCE
                                         (p_assignment_id,
                                          'FR_ACTUAL_HRS_WORKED_IJSS',-- name modified for time analysis changes
                                          l_bal_date_from,
                                          l_bal_date_to);
     -- IF hire_date of person lies between the l_bal_date_to and l_bal_date_from dates
     --    factor the above balance up for 90 days, using the 30 day calendar period.
     OPEN csr_hiredate;
     FETCH csr_hiredate INTO l_hire_date;
     CLOSE csr_hiredate;
     IF l_hire_date > l_bal_date_from AND (l_bal_date_to - l_hire_date +1) <> 0 THEN --Bug #2651568
        l_rolling_hrs_bal := (l_rolling_hrs_bal/(l_bal_date_to - l_hire_date +1)) * 90 ;
     END IF;
     --
     -- Fetch reference contributions from global
     OPEN csr_global_value ('FR_WORKING_HOURS_MINIMUM_FOR_IJSS',l_ref_from_date);
     FETCH csr_global_value INTO l_ref_hrs;
     CLOSE csr_global_value;
     --
     IF l_rolling_hrs_bal < l_ref_hrs THEN
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;
  ELSE
     -- For absences longer than 180 days,
     -- function calculates working hours balance over last 12 calendar mths
     -- 1st day of 12 calendar months prior to above date
     l_bal_date_from := TRUNC(ADD_MONTHS(p_absence_start_date,-12), 'MONTH');
     l_ref_from_date := TRUNC(l_bal_date_from,'YEAR');
     -- Get rolling balances
     l_rolling_hrs_bal := FR_ROLLING_BALANCE
                                           (p_assignment_id,
                                            'FR_ACTUAL_HRS_WORKED_IJSS',-- name modified for time analysis changes
                                            l_bal_date_from,
                                            l_bal_date_to);
     -- IF hire_date of person lies between the l_bal_date_to and l_bal_date_from dates
     -- factor the above balance up for 360 days, using the 30 day calendar period.
     OPEN csr_hiredate;
     FETCH csr_hiredate INTO l_hire_date;
     CLOSE csr_hiredate;
     IF l_hire_date > l_bal_date_from AND (l_bal_date_to - l_hire_date +1) <> 0 THEN --Bug #2651568
        l_rolling_hrs_bal := (l_rolling_hrs_bal/ (l_bal_date_to - l_hire_date +1)) * 360;
     END IF;
     --
     -- Fetch reference contributions from global
     OPEN csr_global_value ('FR_WORKING_HOURS_MINIMUM_FOR_IJSS',l_ref_from_date);
     FETCH csr_global_value INTO l_ref_hrs;
     CLOSE csr_global_value;
     l_ref_hrs := 4 * l_ref_hrs;
     --
     IF l_rolling_hrs_bal < l_ref_hrs THEN    -- Also, working hours check for 12 mths
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;
  END IF;

hr_utility.set_location(' Leaving:'||l_proc, 70);

END IJSS_Eligibility_Working_hours;
--

FUNCTION IJSS_Eligibility_SMID(
P_Legislation_code      IN      Varchar2 := 'FR',
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_start_date    IN      Date,
P_long_absence          IN      Boolean)
RETURN Number IS
--
l_bal_date_to Date;
l_bal_date_from Date;
l_rolling_SMID_balance Number;
l_hire_date Date;
o_hire_date Date;

l_proc               varchar2(72) := g_package||'IJSS_Eligibility_SMID';

-- Cursor to retrive person's hiredate
Cursor csr_hiredate IS
   SELECT papf.original_date_of_hire
   FROM per_all_people_f papf,
        per_all_assignments_f pasg
   WHERE pasg.assignment_id = p_assignment_id
   AND pasg.Business_group_id= p_Business_group_id
   AND p_absence_start_date BETWEEN pasg.effective_start_date and pasg.effective_end_date
   AND papf.person_id = pasg.person_id
   AND papf.Business_group_id=p_Business_group_id
   AND p_absence_start_date BETWEEN papf.effective_start_date and papf.effective_end_date;
--
BEGIN

  --hr_utility.trace_on(NULL,'REQID');
  hr_utility.set_location(' Entering'||l_proc, 10);

  -- Setting up reference dates required while calculating eligibility
  -- Get last day of previous calendar month
  l_bal_date_to := LAST_DAY(ADD_MONTHS(p_Absence_start_date,-1)) ;
  IF NOT(p_long_absence)  THEN   --Absence shorter than 180 days
     -- function calculates SMID contributions over last 6 months
     -- 1st day of 6 calendar months prior to above date
     l_bal_date_from := TRUNC(ADD_MONTHS(p_Absence_start_date,-6), 'MONTH');
     -- Get rolling balances
     l_rolling_SMID_balance := FR_ROLLING_BALANCE
                                            (p_assignment_id,
                                             'FR_EE_SMID',
                                             l_bal_date_from,
                                             l_bal_date_to);

     -- IF hire_date of person lies between the l_bal_date_to and l_bal_date_from dates
     --    factor the above balance up for 180 days, using the 30 day calendar period.
     OPEN csr_hiredate;
     FETCH csr_hiredate INTO l_hire_date;
     CLOSE csr_hiredate;

     IF (l_hire_date > l_bal_date_from) AND (l_bal_date_to - l_hire_date +1) <> 0 THEN --Bug #2651568

                l_rolling_SMID_balance := round((l_rolling_SMID_balance/(l_bal_date_to - l_hire_date +1)) * 180, 2);
     END IF;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 20);
     RETURN l_rolling_SMID_balance;
  ELSE
     -- For absences longer than 180 days,
     -- function calculates SMID contributions over last 12 calendar mths
     -- 1st day of 12 calendar months prior to above date
     l_bal_date_from := TRUNC(ADD_MONTHS(P_Absence_start_date,-12), 'MONTH');
     -- Fetch SMID contributions over the reference period
     l_rolling_SMID_balance     := FR_ROLLING_BALANCE
                                               (p_assignment_id,
                                               'FR_EE_SMID',
                                               l_bal_date_from,
                                               l_bal_date_to);

     -- IF hire_date of person lies between the l_bal_date_to and l_bal_date_from dates
     --    factor the above balance up for 360 days, using the 30 day calendar period.
     OPEN csr_hiredate;
     FETCH csr_hiredate INTO l_hire_date;
     CLOSE csr_hiredate;
     IF l_hire_date > l_bal_date_from AND (l_bal_date_to - l_hire_date +1) <> 0 THEN --Bug #2651568
        l_rolling_SMID_balance := round((l_rolling_SMID_balance/(l_bal_date_to - l_hire_date +1)) * 360, 2);
     END IF;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 30);
     RETURN l_rolling_SMID_balance;
  END IF;
  --hr_utility.trace_off;
END IJSS_Eligibility_SMID;
--

-- Returns Amount of salary for a period
-- Sickness needs (Gross Salary - Professional Reductions)
-- Maternity needs (Gross Salary - New balance [Statutory deductions
--                      +Conventional deductions+CSG-Non mandatory])
FUNCTION Get_Reference_salary(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Period_end_date       IN      Date,
P_Absence_category      IN      Varchar2)
RETURN Number IS
--
cursor c_get_defined_balance(p_balance_name varchar2) is
select db.defined_balance_id
from pay_defined_balances db
,    pay_balance_dimensions bd
,    pay_balance_types bt
where db.balance_type_id = bt.balance_type_id
and   db.balance_dimension_id = bd.balance_dimension_id
and   bt.balance_name = p_balance_name
and   bt.legislation_code = 'FR'
and   bd.database_item_suffix = '_ASG_PTD'
and   bd.legislation_code = 'FR';
--
l_balance_value number;
l_defined_balance_id number;
l_target_net number;

l_proc               varchar2(72) := g_package||'Get_Reference_salary';

--
begin

begin

   hr_utility.set_location('Entering:'|| l_proc,10);
if p_absence_category = 'S' then

-- Check if g_ijss_refsal_defined_balance_id has been set,
-- if not fetch defined_balance_id for
-- FR_SICKNESS_IJSS_REFERENCE_SALARY_ASG_PTD and set
-- g_ijss_refsal_defbal_id
--
  if g_ijss_refsal_defbal_id is not null then
     l_defined_balance_id := g_ijss_refsal_defbal_id;
  else
     open c_get_defined_balance('FR_SICKNESS_IJSS_REFERENCE_SALARY');
     fetch c_get_defined_balance into l_defined_balance_id;
     close c_get_defined_balance;
     --
     g_ijss_refsal_defbal_id := l_defined_balance_id;
  end if;
  --
-- Fetch the value using core balance user exit in date mode:
  BEGIN
    l_balance_value :=
       pay_balance_pkg.get_value(l_defined_balance_id
                              ,p_assignment_id
                              ,p_period_end_date);

    hr_utility.set_location(' Leaving:'||l_proc, 70);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN  --Bug #2659884
      l_balance_value := 0;
  END;
end if;
if p_absence_category in ( 'M', 'FR_ADOPTION','FR_PATERNITY') then

-- Check if g_map_refsal_defined_balance_id has been set,
-- if not fetch defined_balance_id for
-- FR_MAP_IJSS_REFERENCE_SALARY
--
  if g_map_refsal_defbal_id is null then
     open c_get_defined_balance('FR_MAP_IJSS_REFERENCE_SALARY');
     fetch c_get_defined_balance into g_map_refsal_defbal_id;
     close c_get_defined_balance;
     --
  end if;
  --
-- Fetch the value using core balance user exit in date mode:
  BEGIN
    l_balance_value :=
       pay_balance_pkg.get_value(g_map_refsal_defbal_id
                              ,p_assignment_id
                              ,p_period_end_date);

    hr_utility.set_location(' Leaving:'||l_proc, 72);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_balance_value := 0;
  END;
end if;
  return l_balance_value;

end get_Reference_salary;


  return l_balance_value;

end get_Reference_salary;
--
--
-- Returns Amount received as backdated retro payments for the previous calendar year
-- Or for the calendar year before previous in a period,
-- Depending on the parameter 'calendar_year_before' either '1' or '2'
--
PROCEDURE Get_backdated_payments(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Period_end_date       IN      Date,
P_Absence_category      IN      Varchar2 default 'S',
p_payment_backyr_1      OUT NOCOPY Number,
p_payment_backyr_2      OUT NOCOPY Number)  IS
--
l_start_of_year_1 date;
l_start_of_year_2 date;
l_end_of_years date;
l_balance_name varchar2(50);
l_pymt_yr1 number;
l_pymt_yr2 number;
--
cursor c_get_payment(c_balance_name varchar2,
                     c_start_yr1 date,
                     c_start_yr2 date,
                     c_end_yrs date) is
select sum(decode(trunc(spact.effective_date,'YYYY'),c_start_yr1,fnd_number.canonical_to_number(TARGET.result_value))) pymt_yr1,
       sum(decode(trunc(spact.effective_date,'YYYY'),c_start_yr2,fnd_number.canonical_to_number(TARGET.result_value))) pymt_yr2
from   pay_run_result_values   TARGET
,      pay_balance_feeds_f     FEED
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_payroll_actions     PACT
,      pay_balance_types      bal
--
,      pay_assignment_actions sasact
,      pay_payroll_actions    spact
,      pay_entry_process_details proc
where  ASSACT.assignment_id = P_Assignment_id
and    BAL.balance_name = c_balance_name
and    BAL.balance_type_id = FEED.balance_type_id
and    FEED.balance_type_id +0
         = bal.balance_type_id + DECODE(TARGET.input_value_id,null,0,0)
and    FEED.input_value_id     = TARGET.input_value_id
and    nvl(TARGET.result_value,'0') <> '0'
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date
       between FEED.effective_start_date and FEED.effective_end_date
and    RR.status in ('P','PA')
and    PACT.action_type <> 'V'
and    NOT EXISTS
       (SELECT NULL
        FROM pay_payroll_actions     RPACT
        ,    pay_assignment_actions  RASSACT
        ,    pay_action_interlocks   RINTLK
        where ASSACT.assignment_action_id = RINTLK.locked_action_id
        and   RINTLK.locking_action_id = RASSACT.assignment_action_id
        and   RPACT.payroll_action_id = RASSACT.payroll_action_id
        and   RPACT.action_type = 'V' )
and    PACT.effective_date
    between trunc(p_period_end_date,'MM')
        and last_day(p_period_end_date)
--
   and   sasact.payroll_action_id = spact.payroll_action_id
   and   spact.effective_date between c_start_yr2 and c_end_yrs
   and   proc.source_asg_action_id = sasact.assignment_action_id
   and   rr.element_entry_id = proc.element_entry_id
   and   proc.retro_component_id is not null
group by trunc(spact.effective_date,'YYYY');
--
--
l_proc               varchar2(72) := g_package||'Get_backdated_payments';

begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  -- Select the apt balance name (bug#3779780)
  IF P_Absence_category = 'S' THEN
     --
     l_balance_name := 'FR_SICKNESS_IJSS_REFERENCE_SALARY';
     --
  ELSE
     --
     l_balance_name := 'FR_MAP_IJSS_REFERENCE_SALARY';
     --
  END IF;
  --
  l_start_of_year_1 := add_months(trunc(p_period_end_date,'YYYY'), -12);
  l_start_of_year_2 := add_months(l_start_of_year_1, -12);
  l_end_of_years := add_months(l_start_of_year_1,12) -1;
  --
  Open c_get_payment(l_balance_name,
                     l_start_of_year_1,
                     l_start_of_year_2,
                     l_end_of_years);
  Fetch c_get_payment into l_pymt_yr1 ,l_pymt_yr2;
  Close c_get_payment;
  --
  p_payment_backyr_1 := nvl(l_pymt_yr1,0);
  p_payment_backyr_2 := nvl(l_pymt_yr2,0);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end get_backdated_payments;
--
-- GET_OPEN_DAYS
-- Returns open days between two dates

FUNCTION Get_Open_Days
                (p_start_date         IN  Date,
                 p_end_date           IN  Date ) RETURN Number is


l_proc               varchar2(72) := g_package||'Get_Open_Days';

l_calendar_days         Number;
l_open_days             Number;

BEGIN
l_proc               := g_package||'Get_open_days';
hr_utility.set_location('Entering:'|| l_proc,10);

l_calendar_days := p_end_date - p_start_date + 1;

l_open_days     := l_calendar_days - CEIL ((l_calendar_days - mod(to_number(to_char(p_end_date,'J'))+1,7))/ 7);

hr_utility.set_location(' Leaving:'||l_proc, 70);

RETURN  l_open_days;

END Get_Open_days;


-- CALC_SICKNESS_DEDUCTION
-- fires legislative or user formula as indicated on the establishment
-- to calculate the deduction for sickness absence

PROCEDURE Calculate_Sickness_Deduction
(p_absence_start_date IN date,
 p_absence_end_date   IN date,
 p_asg                IN pay_fr_sick_pay_processing.t_asg,
 p_absence_arch       IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch) IS

/* declare local variables */

l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;

l_proc               varchar2(72) := g_package||'calculate_sickness_deduction';

BEGIN

l_proc               := g_package||'Calculate_Sickness_Deduction';
hr_utility.set_location('Entering:'|| l_proc,10);

--hr_utility.trace_on(null, 'SRJ01');
--hr_utility.set_location('Starting', 100);

        /* Raise error if deduction formula is not set */

        IF p_asg.deduct_formula is null then

--hr_utility.set_location('In l_deduction_formula is null', 100);

        fnd_message.set_name ('PAY', 'PY_75027_SICK_DEDUCT_FF_NULL');
        fnd_message.raise_error;

        END IF;

        /* set context value before calling fast formula */

--hr_utility.set_location('set context value before calling fast formula', 100);

        pay_balance_pkg.set_context('ASSIGNMENT_ID'
                                   , p_asg.assignment_id);
        pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID'
                                   , p_asg.assignment_action_id);
        pay_balance_pkg.set_context('DATE_EARNED'
                     , fnd_date.date_to_canonical(p_absence_arch.date_earned));
        pay_balance_pkg.set_context('BUSINESS_GROUP_ID'
                                   , p_asg.business_group_id);
        pay_balance_pkg.set_context('PAYROLL_ID'
                                   , p_asg.payroll_id);
        pay_balance_pkg.set_context('ELEMENT_ENTRY_ID'
                                   , p_absence_arch.element_entry_id);

        /* Get input paramaters for fast formula */

        ff_exec.init_formula(p_asg.deduct_formula
                            , p_absence_arch.date_earned
                            , l_inputs
                            , l_outputs);

        For i in 1..l_inputs.count Loop
          IF    l_inputs(i).name = 'DEDUCTION_START_DATE' THEN
                l_inputs(i).value := fnd_date.date_to_canonical(p_absence_start_date);
          ELSIF l_inputs(i).name = 'DEDUCTION_END_DATE' THEN
                l_inputs(i).value:= fnd_date.date_to_canonical(p_absence_end_date);
          ELSIF l_inputs(i).name = 'ASG_ACTION_START_DATE' THEN
                -- condition added for CPAM payment process
                IF g_absence_calc.initiator = 'CPAM' THEN
                   l_inputs(i).value:= fnd_date.date_to_canonical(g_absence_calc.abs_ptd_start_date);
                ELSE
                   l_inputs(i).value:= fnd_date.date_to_canonical(p_asg.action_start_date);
                END IF;
                --
          ELSIF l_inputs(i).name = 'ASG_ACTION_END_DATE' THEN
                -- condition added for CPAM payment process
                IF g_absence_calc.initiator = 'CPAM' THEN
                   l_inputs(i).value:= fnd_date.date_to_canonical(g_absence_calc.abs_ptd_end_date);
                ELSE
                   l_inputs(i).value:= fnd_date.date_to_canonical(p_asg.action_end_date);
                END IF;
                --
          ELSIF l_inputs(i).name = 'REFERENCE_SALARY' THEN
                l_inputs(i).value:= p_asg.ded_ref_salary;
          ELSIF l_inputs(i).name = 'ASSIGNMENT_ID' THEN
                l_inputs(i).value:= p_asg.assignment_id;
          ELSIF l_inputs(i).name = 'DATE_EARNED' THEN
                l_inputs(i).value:= fnd_date.date_to_canonical(p_absence_arch.date_earned);
          ELSIF l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' THEN
                l_inputs(i).value:= p_asg.assignment_action_id;
          ELSIF l_inputs(i).name = 'BUSINESS_GROUP_ID' THEN
                l_inputs(i).value:= p_asg.business_group_id;
          ELSIF l_inputs(i).name = 'PAYROLL_ID' THEN
                l_inputs(i).value:= p_asg.payroll_id;
          ELSIF l_inputs(i).name = 'PAYROLL_ACTION_ID' THEN
                l_inputs(i).value:= p_asg.payroll_action_id;
          ELSIF l_inputs(i).name = 'ELEMENT_TYPE_ID' THEN
                l_inputs(i).value:= p_asg.element_type_id;
          ELSIF l_inputs(i).name = 'ELEMENT_ENTRY_ID' THEN
                l_inputs(i).value:= p_absence_arch.element_entry_id;
          END IF;
        END Loop;


        /* define output values for fast formula */

        l_outputs(1).name := 'L_SICKNESS_DEDUCTION';
        l_outputs(2).name :=  'L_RATE_NUMBER_OF_DAYS'; --NUMBER_OF_DAYS';
        l_outputs(3).name := 'L_DAILY_RATE_D'; --'DAILY_RATE';




        /* run formula and get outputs */

        per_formula_functions.run_formula
        (p_formula_id => p_asg.deduct_formula
        ,p_calculation_date => p_absence_arch.date_earned
        ,p_inputs => l_inputs
        ,p_outputs => l_outputs);


        p_absence_arch.sick_deduction := l_outputs(1).value;
        p_absence_arch.sick_deduction_rate := l_outputs(2).value;
        p_absence_arch.sick_deduction_base := l_outputs(3).value;

hr_utility.set_location(' Leaving:'||l_proc, 70);

--hr_utility.trace_off;


END Calculate_Sickness_Deduction;

-- CALC_IJSS
-- calculates IJSS gross and net and populates on the g_overlap table
PROCEDURE Calc_IJSS(
p_business_group_id     IN  Number,
p_assignment_id         IN  Number,
p_absence_id            IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date,
p_absence_duration      IN  Number,
p_work_inc_class        IN  Varchar2) is

l_delay_days number :=0;
l_total_abs_duration number;
l_hol_exist number;
l_ijss_calculate varchar2(3);
l_inelig_date date;
l_end_date    date;
l_parent_abs_id number;
l_abs_detail_id number;
l_person_id number;
l_orig_hiredate date;
l_this_abs_start_date date;
l_abs_start_date date;
l_count_abs_days number;
l_total_overlap_rows Number;
l_short_term_elig varchar2(3);
l_long_term_elig varchar2(3);
l_message varchar2(50);
l_ref_start_dt date;
l_ref_end_dt date;
l_current_ref_start_dt date;
l_date_earned date;
l_period_ref_sal number :=0;
l_total_ref_sal_bal number :=0;
l_ref_sal_bal_id number;
l_assignment_action_id number;
l_count_ref_periods number :=1;
l_monthly_ss_ceiling number;
l_ann_ss_ceiling number;
l_ijss_rate number;
l_ijss_daily_ref_sal number;
l_max_rate number;
l_max_daily_sal number;
l_min_rate number;
l_min_daily_sal number;
l_ann_min_pension number;
l_ijss_daily_gross number;
l_ijss_daily_net number;
l_ijss_net_rate number;
l_count_ijss_loop number :=1;
l_dependent_count number;
l_incr_period number;
l_elig_for_IJSS varchar2(1) := 'N';
l_range_loop_count number :=1;
l_maternity_related varchar2(1) := 'N';

TYPE l_boundary_rec IS RECORD(l_boundary_value number);
TYPE l_boundary_table IS TABLE OF l_boundary_rec INDEX BY BINARY_INTEGER;
l_lower_range_value l_boundary_table;


l_proc               varchar2(72) := g_package||'calc_ijss';

--Cursor for determining linked or standalone absences
Cursor csr_abs_ids IS
   SELECT pabs.person_id person,
          pabs.abs_information1 parent_abs,
          papf.original_date_of_hire hiredate,
          pabs.date_start abs_start
    FROM per_absence_attendances pabs,
         per_all_people_f papf
      WHERE pabs.absence_attendance_id = p_absence_id
       AND pabs.business_group_id = p_business_group_id
       AND pabs.abs_information_category ='FR_S'
       AND papf.person_id = pabs.person_id
       AND papf.business_group_id = p_business_group_id
       AND p_start_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

-- cursor for finding absence details
Cursor csr_abs_detail(c_absence_id NUMBER) IS
   SELECT pabs.date_start abs_start_date,
          pabs.abs_information8 ijss_cal,
          nvl(fnd_date.canonical_to_date(pabs.abs_information7),hr_general.end_of_time) elig_dt
    FROM per_absence_attendances pabs
      WHERE pabs.absence_attendance_id = c_absence_id
       AND pabs.business_group_id = p_business_group_id
       AND pabs.abs_information_category ='FR_S';

-- Cursor for finding holidays within the date range
Cursor csr_holidays(c_hol_date varchar2, c_person_id Number) IS
   SELECT count(*)
   FROM per_absence_attendances pabs_hol,
        per_absence_attendance_types pabt
   WHERE pabs_hol.person_id = c_person_id
    AND pabs_hol.business_group_id = p_business_group_id
    AND c_hol_date BETWEEN pabs_hol.date_start AND pabs_hol.date_end
    AND pabt.absence_attendance_type_id = pabs_hol.absence_attendance_type_id
    AND pabt.absence_category in ('FR_MAIN_HOLIDAY','FR_ADDITIONAL_HOLIDAY','FR_RTT_HOLIDAY') ;

-- check if a maternity absence exists within 48 hours of this sickness
Cursor csr_maternity(c_sick_start_date date, c_person_id Number) IS
   SELECT nvl(min('Y'),'N') maternity_related
   FROM per_absence_attendances pabs,
        per_absence_attendance_types pabt
   WHERE pabs.person_id = c_person_id
    AND (c_sick_start_date - 3 ) BETWEEN pabs.date_start AND pabs.date_end
    AND pabt.absence_attendance_type_id = pabs.absence_attendance_type_id
    AND pabt.absence_category = 'M';

-- Cursor to find the defined balance id
-- of reference salary
Cursor csr_ref_bal_id IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
   WHERE  pdb.balance_type_id = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
   AND    pbt.balance_name = 'FR_SICKNESS_IJSS_REFERENCE_SALARY'
   AND    pbd.database_item_suffix = '_ASG_PTD'
   AND    pdb.legislation_code = 'FR';

-- Cursor for fetching global value
Cursor csr_global_value(c_global_name VARCHAR2,c_date_earned DATE) IS
   SELECT global_value
   FROM ff_globals_f
   WHERE global_name = c_global_name
   AND legislation_code = 'FR'
   AND c_date_earned BETWEEN effective_start_date AND effective_end_date;

-- Cursor for selecting no. of depedents on a person
-- as on the parent absence date
Cursor csr_dependent(c_person_id NUMBER,c_abs_start_date DATE) IS
SELECT count(*)
FROM per_contact_relationships
WHERE person_id = c_person_id
AND business_group_id = p_business_group_id
AND c_abs_start_date BETWEEN nvl(date_start, hr_general.start_of_time) and nvl(date_end, hr_general.end_of_time)
AND dependent_flag ='Y';
-- Cursor defined as part of bug #2651295
-- for fetching boundary values of rows of UDT
Cursor csr_row_value(c_table_name VARCHAR2, c_effective_date DATE) IS
SELECT row_low_range_or_name
FROM pay_user_tables put, pay_user_rows_f purf
WHERE put.user_table_name = c_table_name
AND put.user_table_id = purf.user_table_id
AND c_effective_date between effective_start_date and effective_end_date;
--
--
BEGIN
l_proc                := g_package||'calc_ijss';
-- hr_utility.trace_off;
hr_utility.set_location('Entering:'|| l_proc,10);
--
  OPEN csr_abs_ids;
  FETCH csr_abs_ids INTO l_person_id,l_parent_abs_id,l_orig_hiredate,l_this_abs_start_date;
  CLOSE csr_abs_ids;

  -- Assign values for linked and standalone absences
  IF l_parent_abs_id IS NOT NULL THEN
     l_abs_detail_id := l_parent_abs_id;
  ELSE
     l_abs_detail_id := p_absence_id;
  END IF;

  OPEN csr_abs_detail(l_abs_detail_id);
  FETCH csr_abs_detail INTO l_abs_start_date,l_ijss_calculate,l_inelig_date;
  CLOSE csr_abs_detail;

  l_end_date := p_end_date;

  -- Fix for "Bug #2661851 and 2665751: 2ND Absence in period has incorrect days processed in guarantee"
  hr_utility.set_location(' Current count '||g_overlap.COUNT,20);
  IF (g_overlap.COUNT <> 0) THEN
     g_overlap.DELETE;
     hr_utility.set_location(' Modified count '||g_overlap.COUNT,20);
  END IF;

  -- Determining if IJSS for the absence is to be estimated
  IF l_ijss_calculate = 'Y' THEN
     -- IJSS is to be estimated
     -- (a) check for ineligibility date
     IF (l_inelig_date <= p_start_date) THEN
        hr_utility.set_location('PAY_75022_ABS_MARKED_INELIG',20);
        -- Fix for "Bug #2659924: SICKNESS DEDUCTION NOT PROCESSED WHEN IJSS ELIGIBILITY NOT MET "
        --fnd_message.set_name ('PAY', 'PAY_75022_ABS_MARKED_INELIG');
        --fnd_message.raise_error;
     ELSE
        -- If Ineligible for IJSS Date(on parent absence) is before the absence end date,
        --   IJSS to be estimated only for the restricted days
        IF (l_inelig_date <= p_end_date) THEN
          l_end_date := l_inelig_date - 1;
        END IF;

        -- (b)Check for working hours
        -- and SMID contributions eligibility
        -- Pass suitable(parent/self) absence id and date
        IJSS_Eligibility_Check(P_legislation_code        => 'FR',
                               P_business_group_id       => p_business_group_id,
                               P_assignment_id           => p_assignment_id,
                               P_absence_id              => l_abs_detail_id,
                               P_abs_start_date          => l_abs_start_date,
                               P_short_term_eligibility  => l_short_term_elig,
                               P_long_term_eligibility   => l_long_term_elig,
                               P_Message                 => l_message);

        hr_utility.set_location(' Short term IJSS Eligibility?'||l_short_term_elig,20);
        hr_utility.set_location(' Long term IJSS Eligibility? '||l_long_term_elig,20);
        -- finding the number of rows to be populated
        -- in g_overlap table for this absence period
        l_total_overlap_rows := trunc(l_end_date - p_start_date) +1;

        l_total_abs_duration := l_total_overlap_rows + p_absence_duration;
        hr_utility.set_location(' Prevs absence durn '||p_absence_duration,30);
        hr_utility.set_location(' Total absence durn '||l_total_abs_duration,30);
        -- Eligibility needs to be checked as soon as the absence crosses the 180 day mark
        -- In case eligibility is lost when the absence becomes longer than 180(ie. else if 2)
        --   i) if in this processing period, only the eligible part of the absence should be processed
        --  ii) if not, error should be returned
        --
        IF (l_total_abs_duration <= 180 AND l_short_term_elig = 'Y') THEN
          l_elig_for_IJSS := 'Y';
        ELSIF (l_total_abs_duration > 180 AND l_long_term_elig = 'Y') THEN
          l_elig_for_IJSS := 'Y';
        ELSIF (l_total_abs_duration > 180 AND l_long_term_elig = 'N') THEN
          IF (p_absence_duration <= 180) THEN
            -- absence has become longer than 180 days in this processing period
            --   and not eligible for IJSS anymore
            --   i) so check short term eligibility
            IF (l_short_term_elig = 'Y') THEN
              l_end_date := p_start_date + (180 - p_absence_duration);
              -- Repeat check for "Ineligible for IJSS Date"
              IF (l_inelig_date <= l_end_date) THEN
                l_end_date := l_inelig_date - 1;
              END IF;
              l_total_overlap_rows := trunc(l_end_date - p_start_date) +1;
              l_elig_for_IJSS := 'Y';
              hr_utility.set_location(' Modified end date to '||l_end_date||' as absence does not have long eligibility',20);
            ELSE  -- ii)
              hr_utility.set_location('PAY_75021_ABS_INELIG_FOR_IJSS',40);
              -- Fix for "Bug #2659924: SICKNESS DEDUCTION NOT PROCESSED WHEN IJSS ELIGIBILITY NOT MET "

              --fnd_message.set_name ('PAY', 'PAY_75021_ABS_INELIG_FOR_IJSS');
              --fnd_message.raise_error;
            END IF;
          END IF;
        ELSE
          hr_utility.set_location('PAY_75021_ABS_INELIG_FOR_IJSS',50);
          -- Fix for "Bug #2659924: Sickness deduction not processed when ijss eligibility not met "

          --fnd_message.set_name ('PAY', 'PAY_75021_ABS_INELIG_FOR_IJSS');
          --fnd_message.raise_error;
        END IF;


        IF l_elig_for_IJSS = 'Y' THEN

           -- Only when the absence is to be estimated and eligible,
           --    populate the g_overlap with the dates (possibly restricted)

           hr_utility.set_location('Calculation '||l_elig_for_IJSS,20);
           hr_utility.set_location(' Total rows to be in overlap table:'||to_char(l_total_overlap_rows),20);

           -- Populate g_overlap table with absence dates
           --   index being the actual day of the absence

           FOR l_count_abs_days in (p_absence_duration + 1)..(p_absence_duration + l_total_overlap_rows)
           LOOP
             IF l_count_abs_days = p_absence_duration + 1 THEN
                g_overlap(l_count_abs_days).Absence_day := p_start_date;
             ELSE
                g_overlap(l_count_abs_days).Absence_day := g_overlap(l_count_abs_days-1).Absence_day +1;
             END IF;

             -- (2) check for holidays
             --
             OPEN csr_holidays(g_overlap(l_count_abs_days).Absence_day,l_person_id);
             FETCH csr_holidays INTO l_hol_exist;
             CLOSE csr_holidays;
             IF l_hol_exist >0 THEN
               g_overlap(l_count_abs_days).Holiday :='H';
             END IF;
             --
             hr_utility.set_location(to_char(l_count_abs_days)||'th row and Date:'
                                     ||to_char(g_overlap(l_count_abs_days).Absence_day)||
                                     ' Hols? '||g_overlap(l_count_abs_days).Holiday,20);
             --
           END LOOP;

           -- continue with IJSS estimation
           -- Get the defined balance id of 'FR_SICKNESS_IJSS_REFERENCE_SALARY'
           -- of '_ASG_PTD' dimension
           OPEN csr_ref_bal_id;
           FETCH csr_ref_bal_id INTO l_ref_sal_bal_id;
           CLOSE csr_ref_bal_id;
           --
           IF p_work_inc_class ='N' OR p_work_inc_class IS NULL THEN
               -- for non-occupational sickness
               l_ref_start_dt := add_months(trunc(l_abs_start_date,'MONTH'),-3);
               l_ref_end_dt := last_day(add_months(l_abs_start_date, -1));
               FOR l_count_ref_periods IN 1..3 LOOP
                   l_incr_period := l_count_ref_periods -1;
                   l_date_earned := add_months(last_day(l_ref_start_dt), l_incr_period);
                   l_period_ref_sal := Get_reference_salary(P_Business_group_id => p_business_group_id,
                                                            P_Assignment_id     => p_assignment_id,
                                                            P_Period_end_date   => l_date_earned,
                                                            P_Absence_category  => 'S');
                   /*
                   -- find the assignment_action_id for each period
                   OPEN csr_assignment_actions(l_date_earned);
                   FETCH csr_assignment_actions INTO l_assignment_action_id;
                   CLOSE csr_assignment_actions;
                   -- find the balance value for each period
                            hr_utility.set_location(' REF SAL BAL id :'||l_ref_sal_bal_id,40);
                            hr_utility.set_location(' REF SAL ASAC id :'||l_assignment_action_id,40);
                   l_period_ref_sal :=pay_balance_pkg.get_value(l_ref_sal_bal_id,
                                                                         l_assignment_action_id);
                   */
                   -- limit the total balance value to SS ceiling
                   OPEN csr_global_value('FR_MONTHLY_SS_CEILING',l_date_earned);
                   FETCH csr_global_value INTO l_monthly_ss_ceiling;
                   CLOSE csr_global_value;

                   IF l_monthly_ss_ceiling < l_period_ref_sal THEN
                      l_period_ref_sal := l_monthly_ss_ceiling;
                   END IF;
                   --
                   -- Check for new hires
                   l_current_ref_start_dt := trunc(l_date_earned, 'MONTH');
                   IF l_orig_hiredate > l_current_ref_start_dt THEN
                      IF l_orig_hiredate > l_date_earned THEN
                         -- reference salary for this period is nil
                         l_period_ref_sal := 0 ;
                      ELSE
                         -- prorate reference salary
                         l_period_ref_sal := (l_period_ref_sal/(l_date_earned - l_orig_hiredate +1)) * 30;
                      END IF;
                   END IF;
                   hr_utility.set_location('reference period :'||to_char(l_current_ref_start_dt),40);
                   l_total_ref_sal_bal := l_total_ref_sal_bal+ l_period_ref_sal;
                   hr_utility.set_location('total ref salary'||to_char(l_total_ref_sal_bal),40);
               END LOOP;
               -- Check for null reference salary
               -- Error commented out, do need to reconsider it later
               /*
               IF l_total_ref_sal_bal = 0 THEN
                fnd_message.set_name ('PAY', 'PAY_75020_IJSS_NULL_REF_SAL');
                fnd_message.raise_error;
               END IF;
               */

               -- get the daily reference salary
               l_ijss_daily_ref_sal := l_total_ref_sal_bal/90;
               --
               -- get the delay days and

--            if sickness is within 48 hrs of a maternity absence then no delay is required
--            look for maternity absence
              OPEN csr_maternity(l_abs_start_date,l_person_id);
              FETCH csr_maternity INTO l_maternity_related;
              CLOSE csr_maternity;
               hr_utility.trace('  l_maternity_related:'||(l_maternity_related));
               -- subtract the ones already covered in the previous period or
               -- previous linked/parent absence
               if l_maternity_related = 'N' then
                  l_delay_days := hruserdt.get_table_value(p_business_group_id,
                                     'FR_IJSS_NON_OCCUP_RATES_MAX','Delay',
                                      p_absence_duration+1,l_ref_start_dt);
               else l_delay_days := 0;
               end if;
               hr_utility.set_location('  Delay Days :'||to_char(l_delay_days),22);
               -- Get the no. of dependents on parent absence start date
               OPEN csr_dependent(l_person_id,l_abs_start_date);
               FETCH csr_dependent INTO l_dependent_count;
               CLOSE csr_dependent;
               -- get the annual minimal invalidity pension
               OPEN csr_global_value('FR_MINIMAL_INVALIDITY_PENSION',p_start_date);
               FETCH csr_global_value INTO l_ann_min_pension;
               CLOSE csr_global_value;
               -- get the maximum daily salary
               l_ann_ss_ceiling := 12 * l_monthly_ss_ceiling;
               -- get the value of ijss net rate
               OPEN csr_global_value('FR_IJSS_NET_RATE',p_start_date);
               FETCH csr_global_value INTO l_ijss_net_rate;
               CLOSE csr_global_value;
               -- Calculate IJSS and
               -- Populate the g_overlap table with ijss values
               -- Find the boundary values from the rows of UDT
               OPEN csr_row_value ('FR_IJSS_NON_OCCUP_RATES_MAX',l_abs_start_date);
               LOOP
                  FETCH csr_row_value INTO l_lower_range_value(l_range_loop_count);
                  l_range_loop_count := l_range_loop_count +1;
                  IF csr_row_value%NOTFOUND THEN
                     EXIT;
                  END IF;
               END LOOP;
               CLOSE csr_row_value;

               FOR l_count_ijss_loop IN (p_absence_duration+1)..(p_absence_duration+l_total_overlap_rows) LOOP
                    -- code added for bug#2651295
                    -- Use the boundary values for retrieving rates
                    -- (i) check for duration every time
                    --l_incr_abs_duration:= g_overlap(l_count_ijss_loop).Absence_Day - l_this_abs_start_date +1;
                    IF l_count_ijss_loop = p_absence_duration+1 OR -- first time
                       l_count_ijss_loop = l_lower_range_value(2).l_boundary_value OR
                       l_count_ijss_loop = l_lower_range_value(3).l_boundary_value THEN
                       -- (ii) retrieve rates if required
                       -- according to the number of dependents
                       hr_utility.set_location('Absence duration boundary for non-occup :'||to_char(l_count_ijss_loop),22);
                       IF l_dependent_count<3 THEN
                          l_ijss_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Rate for others (%)',l_count_ijss_loop,l_abs_start_date);
                          l_max_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Max for others - Related to annual SS ceiling',l_count_ijss_loop,l_abs_start_date);
                          l_min_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Min for others:Factor of global minimal invalidity pension',l_count_ijss_loop,l_abs_start_date);
                       ELSE
                          l_ijss_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Rate for 3 dependents or more (%)',l_count_ijss_loop,l_abs_start_date);
                          l_max_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Max for 3 dependents or more - Related to annual SS ceiling',l_count_ijss_loop,l_abs_start_date);
                          l_min_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_NON_OCCUP_RATES_MAX','Min for 3 dependents or more:Factor of global minimal invalidity pension',l_count_ijss_loop,l_abs_start_date);
                       END IF;
                    END IF;
                    hr_utility.set_location('ijss rate:'||to_char(l_ijss_rate)||' max rate:'||to_char(l_max_rate)||' min rate:'||to_char(l_min_rate),22);
                    -- (iii) calculate IJSS
                    -- get minimum daily salary
                    l_min_daily_sal := l_ann_min_pension * l_min_rate;
                    l_max_daily_sal := l_ann_ss_ceiling * l_max_rate;
                    -- limit the daily ref salary by the minimum and maximum value
                    l_ijss_daily_gross := l_ijss_daily_ref_sal * l_ijss_rate/100;
                    -- Cap IJSS to maximum
                    IF l_ijss_daily_gross > l_max_daily_sal THEN
                      l_ijss_daily_gross := l_max_daily_sal;
                    ELSE
                      l_ijss_daily_gross := l_ijss_daily_gross;
                    END IF;
                    -- Minimum IJSS for absences with duration more than 6 months
                    IF l_count_ijss_loop > 180 THEN
                      IF l_ijss_daily_gross < l_min_daily_sal THEN
                        l_ijss_daily_gross := l_min_daily_sal;
                      ELSE
                        l_ijss_daily_gross := l_ijss_daily_gross;
                      END IF;
                    END IF;

                    l_ijss_daily_net := l_ijss_daily_gross * (100 - l_ijss_net_rate)/100;

                    --
                    IF l_count_ijss_loop > l_delay_days AND
                       g_overlap(l_count_ijss_loop).Absence_Day < l_inelig_date
                     THEN
                       g_overlap(l_count_ijss_loop).IJSS_Gross:= l_ijss_daily_gross;
                       g_overlap(l_count_ijss_loop).IJSS_Net:= l_ijss_daily_net;
                    ELSE
                       -- populate IJSS payment columns as '0'
                       -- for days either less than delay days or
                       -- after the ineligibility date
                       g_overlap(l_count_ijss_loop).IJSS_Gross:= 0;
                       g_overlap(l_count_ijss_loop).IJSS_Net := 0;
                    END IF;
                    --
                    hr_utility.set_location('Cnt of pymnts:'||to_char(l_count_ijss_loop)||
                                            ' Gross Pymnt:'||substr(to_char(g_overlap(l_count_ijss_loop).IJSS_Gross),1,10)||
                                            ' Net Pymnt:'||substr(to_char(g_overlap(l_count_ijss_loop).IJSS_Net),1,10),30);
                    --
               END LOOP;
           ELSE
              -- for occupational sickness
               l_ref_start_dt := add_months(trunc(l_abs_start_date,'MONTH'),-1);
               l_ref_end_dt := last_day(add_months(l_abs_start_date, -1));

               l_date_earned := last_day(l_ref_start_dt);
               l_total_ref_sal_bal := Get_reference_salary(
                                        P_Business_group_id     => p_business_group_id,
                                        P_Assignment_id         => p_assignment_id,
                                        P_Period_end_date       => l_date_earned,
                                        P_Absence_category      => 'S');
               /*
               -- find the assignment_action_id for this period
               OPEN csr_assignment_actions(l_date_earned);
               FETCH csr_assignment_actions INTO l_assignment_action_id;
               CLOSE csr_assignment_actions;
               -- find the balance value for this period
               hr_utility.set_location(' OCCUP ',40);
               hr_utility.set_location(' REF SAL BAL id :'||l_ref_sal_bal_id,40);
               hr_utility.set_location(' REF SAL ASAC id :'||l_assignment_action_id,40);
               l_total_ref_sal_bal := pay_balance_pkg.get_value(l_ref_sal_bal_id,
                                                                l_assignment_action_id);
               */
               -- Check for new hires
               IF l_orig_hiredate > l_ref_start_dt THEN
                  IF l_orig_hiredate > l_date_earned THEN
                     -- reference salary for this period is nil
                     l_period_ref_sal := 0 ;
                  ELSE
                     -- prorate reference salary
                     l_period_ref_sal := (l_period_ref_sal/(l_date_earned - l_orig_hiredate +1)) * 30;
                  END IF;
               END IF;
               -- Check for null reference salary
               -- Error commented out, do need to reconsider it later
               /*
               IF l_total_ref_sal_bal = 0 THEN
                 fnd_message.set_name ('PAY', 'PAY_75020_IJSS_NULL_REF_SAL');
                 fnd_message.raise_error;
               END IF;
               */
               -- get the daily reference salary
               l_ijss_daily_ref_sal := l_total_ref_sal_bal/30;
               -- Getting the annual SS ceiling
               OPEN csr_global_value('FR_MONTHLY_SS_CEILING',p_start_date);
               FETCH csr_global_value INTO l_monthly_ss_ceiling;
               CLOSE csr_global_value;
               l_ann_ss_ceiling := 12 * l_monthly_ss_ceiling;
               --
               -- get the value of ijss net rate
               OPEN csr_global_value('FR_IJSS_NET_RATE',p_start_date);
               FETCH csr_global_value INTO l_ijss_net_rate;
               CLOSE csr_global_value;
               -- Calculate IJSS and populate g_overlap table with ijss values:
               -- Find the boundary values from the rows of UDT
               OPEN csr_row_value ('FR_IJSS_OCCUP_RATES_MAX',l_abs_start_date);
               LOOP
                   FETCH csr_row_value INTO l_lower_range_value(l_range_loop_count);
                   l_range_loop_count := l_range_loop_count +1;
                   IF csr_row_value%NOTFOUND THEN
                       EXIT;
                   END IF;
               END LOOP;
               CLOSE csr_row_value;

               l_delay_days := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_OCCUP_RATES_MAX','Delay',p_absence_duration+1,l_ref_start_dt);


               FOR l_count_ijss_loop IN (p_absence_duration+1)..(p_absence_duration+l_total_overlap_rows) LOOP
                   --
                   -- code added for bug#2651295
                   -- Use the boundary values for retrieving rates
                   -- (i) check for duration every time
                   --l_incr_abs_duration:= g_overlap(l_count_ijss_loop).Absence_Day - l_this_abs_start_date +1;
                   IF l_count_ijss_loop =p_absence_duration+1 OR -- first time
                      l_count_ijss_loop = l_lower_range_value(2).l_boundary_value THEN
                      -- (ii) retrieve rates if required
                      hr_utility.set_location('Absence duration boundary for occup :'||to_char(l_count_ijss_loop),22);
                      l_ijss_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_OCCUP_RATES_MAX','Rate (%)',l_count_ijss_loop,l_abs_start_date);
                      l_max_rate := hruserdt.get_table_value(p_business_group_id,'FR_IJSS_OCCUP_RATES_MAX','Max - Related to annual SS ceiling',l_count_ijss_loop,l_abs_start_date);
                   END IF;
                   hr_utility.set_location('ijss rate:'||to_char(l_ijss_rate)||' max rate:'||to_char(l_max_rate),22);
                   -- (iii) calculate IJSS
                   -- the maximum daily salary
                   l_ijss_daily_gross := l_ijss_daily_ref_sal * l_ijss_rate/100;
                     -- Cap IJSS to maximum
                   IF l_ijss_daily_gross > l_max_daily_sal THEN
                       l_ijss_daily_gross := l_max_daily_sal;
                     ELSE
                       l_ijss_daily_gross := l_ijss_daily_gross;
                   END IF;
                   l_ijss_daily_net := l_ijss_daily_gross * (100 - l_ijss_net_rate)/100;

                   --
                   IF l_count_ijss_loop > l_delay_days AND
                      g_overlap(l_count_ijss_loop).Absence_Day < l_inelig_date
                    THEN
                      g_overlap(l_count_ijss_loop).IJSS_Gross:= l_ijss_daily_gross;
                      g_overlap(l_count_ijss_loop).IJSS_Net:= l_ijss_daily_net;
                   ELSE
                      -- populate IJSS payment columns as '0'
                      -- for days either less than delay days or
                      -- after the ineligibility date
                      g_overlap(l_count_ijss_loop).IJSS_Gross:= 0;
                      g_overlap(l_count_ijss_loop).IJSS_Net := 0;
                   END IF;
                   --
                    hr_utility.set_location('Cnt of pymnts:'||to_char(l_count_ijss_loop)||
                                            ' Grss Pymnt:'||substr(to_char(g_overlap(l_count_ijss_loop).IJSS_Gross),1,10)||
                                            ' Net Pymnt:'||substr(to_char(g_overlap(l_count_ijss_loop).IJSS_Net),1,10),30);
                   --
               END LOOP;
           END IF;  -- Work Incident check
           --
        ELSE
          hr_utility.set_location('PAY_75021_ABS_INELIG_FOR_IJSS',60);
           -- Fix for "Bug #2659924:
           --fnd_message.set_name ('PAY', 'PAY_75021_ABS_INELIG_FOR_IJSS');
           --fnd_message.raise_error;
        END IF; -- Absence Eligibility check
     END IF;    -- 'Ineligible IJSS date' on parent absence check

  ELSE
     null; -- to be coded in the next phase of FR payroll
     -- IJSS is not to be estimated, find Actual IJSS

  END IF;       -- IJSS Estimation flag check

  hr_utility.set_location(' Leaving:'||l_proc, 70);


END Calc_IJSS;
--
-- Checks for IJSS eligibility
PROCEDURE IJSS_Eligibility_Check(
P_legislation_code       IN     Varchar2,
P_business_group_id      IN     Number,
P_assignment_id          IN     Number,
P_absence_id             IN     Number,
P_abs_start_date         IN     Date,
P_short_term_eligibility OUT NOCOPY Varchar2,
P_long_term_eligibility  OUT NOCOPY Varchar2,
P_Message                OUT NOCOPY Varchar2)
IS
--
l_smid_6_mths Number;
l_smid_12_mths Number;
l_plus_200_hrs Varchar2(3);
l_plus_800_hrs Varchar2(3);
l_short_term_elig_flg Varchar2(3);
l_long_term_elig_flg Varchar2(3);
l_ref_bal_date_from Date;
l_smic_multiplier Number;
l_smic_hourly_rate Number;
l_smid_rate Number;
l_global_smic_ded Number;

-- Cursor to retrieve eligibility segment details
Cursor csr_elig_details IS
   SELECT abs_information9 SMID_6,
          abs_information10 SMID_12,
          abs_information11 hrs_200,
          abs_information12 hrs_800
   FROM per_absence_Attendances
   WHERE absence_Attendance_id = p_absence_id
   AND business_group_id = p_business_group_id
   AND abs_information_category ='FR_S';

-- Cursor for fetching global value
Cursor csr_global_value(c_global_name VARCHAR2,c_date_earned DATE) IS
   SELECT global_value
   FROM ff_globals_f
   WHERE global_name = c_global_name
   AND legislation_code = 'FR'
   AND c_date_earned BETWEEN effective_start_date AND effective_end_date;
--
l_proc               varchar2(72) := g_package||' IJSS_Eligibility_Check';
--
BEGIN

l_proc                := g_package||'IJSS_Eligibility_Check';

hr_utility.set_location('Entering:'|| l_proc,10);

-- Check for stored eligibility on DDF segment of absence
  OPEN csr_elig_details;
  FETCH csr_elig_details INTO l_smid_6_mths,l_smid_12_mths,l_plus_200_hrs,l_plus_800_hrs;
  CLOSE csr_elig_details;

  -- Derive values of the variables
  IF l_plus_200_hrs IS NULL THEN
     l_plus_200_hrs :=  IJSS_Eligibility_Working_hours
                               (P_legislation_code   => 'FR',
                                P_business_group_id  => p_business_group_id,
                                P_assignment_id      => p_assignment_id,
                                P_absence_start_date => p_abs_start_date,
                                P_long_absence  => FALSE    );
  END IF;
  IF l_plus_800_hrs IS NULL THEN
     l_plus_800_hrs :=  IJSS_Eligibility_Working_hours
                               (P_legislation_code   => 'FR',
                                P_business_group_id  => p_business_group_id,
                                P_assignment_id      => p_assignment_id,
                                P_absence_start_date => p_abs_start_date,
                                P_long_absence  => TRUE    );
  END IF;

  -- Determine short term eligibility
  IF l_plus_200_hrs = 'Y'  THEN
     l_short_term_elig_flg := 'Y';
  ELSE
     -- Derive SMID values from function if not entered
     IF l_smid_6_mths IS NULL THEN
        l_smid_6_mths := IJSS_Eligibility_SMID
                                  (P_legislation_code   => 'FR',
                                   P_business_group_id  => p_business_group_id,
                                   P_assignment_id      => p_assignment_id,
                                   P_absence_start_date => p_abs_start_date,
                                   P_long_absence       => FALSE    );
     END IF;
     -- Perform SMID contributions check
     -- Fetch reference contributions from global
     -- as of 1st day of reference period
     l_ref_bal_date_from:= TRUNC(ADD_MONTHS(p_abs_start_date,-6), 'MONTH');
     --
     OPEN csr_global_value('FR_IJSS_SMIC_MULTIPLIER',l_ref_bal_date_from);
     FETCH csr_global_value INTO l_smic_multiplier;
     CLOSE csr_global_value;
     --
     OPEN csr_global_value('FR_HOURLY_SMIC_RATE',l_ref_bal_date_from);
     FETCH csr_global_value INTO l_smic_hourly_rate;
     CLOSE csr_global_value;
     --
     l_smid_rate := hruserdt.get_table_value(p_business_group_id,'FR_CONTRIBUTION_RATES','Value (EUR)','EE_SMID',l_ref_bal_date_from);
     --
     l_global_smic_ded := l_smic_multiplier *  l_smic_hourly_rate * l_smid_rate / 100;
     IF l_smid_6_mths > l_global_smic_ded THEN
        l_short_term_elig_flg := 'Y';
     ELSE
        l_short_term_elig_flg:= 'N';
     END IF;
  END IF;

  -- Determine long term eligibility only when the absence is eligible short term
  IF l_short_term_elig_flg ='Y' THEN
     --
     IF l_plus_800_hrs = 'Y'  THEN
        l_long_term_elig_flg := 'Y';
     ELSE
        -- Derive SMID values from function if not entered
        IF l_smid_12_mths IS NULL THEN
           l_smid_12_mths := IJSS_Eligibility_SMID
                                  (P_legislation_code   => 'FR',
                                   P_business_group_id  => p_business_group_id,
                                   P_assignment_id      => p_assignment_id,
                                   P_absence_start_date => p_abs_start_date,
                                   P_long_absence       => TRUE    );
        END IF;
        -- Perform SMID contributions check
        -- Fetch reference contributions from global as of
        -- 1st day of the year preceding the reference period
        l_ref_bal_date_from:= TRUNC(ADD_MONTHS(P_abs_start_date,-12), 'YEAR');
        --
        OPEN csr_global_value('FR_IJSS_SMIC_MULTIPLIER',l_ref_bal_date_from);
        FETCH csr_global_value INTO l_smic_multiplier;
        CLOSE csr_global_value;
        --
        OPEN csr_global_value('FR_HOURLY_SMIC_RATE',l_ref_bal_date_from);
        FETCH csr_global_value INTO l_smic_hourly_rate;
        CLOSE csr_global_value;
        --
        l_smid_rate := hruserdt.get_table_value(p_business_group_id,'FR_CONTRIBUTION_RATES','Value (EUR)','EE_SMID',l_ref_bal_date_from);
        --
        l_global_smic_ded := 2 * (l_smic_multiplier *  l_smic_hourly_rate * l_smid_rate / 100);
        IF l_smid_12_mths > l_global_smic_ded THEN
           l_long_term_elig_flg := 'Y';
        ELSE
           l_long_term_elig_flg := 'N';
        END IF;
        --
     END IF;
  END IF;
  P_short_term_eligibility := l_short_term_elig_flg;
  P_long_term_eligibility := l_long_term_elig_flg;

hr_utility.set_location(' Leaving:'||l_proc, 70);

END IJSS_Eligibility_Check;
--

PROCEDURE Get_abs_print_flg(p_business_group_id  IN Number,
                           p_parent_abs_id  IN Number,
                           p_period_end_date IN Date, -- for subrogation date
                           p_person_id IN number,
                           p_abs_duration OUT NOCOPY Number,-- for eligibility
                           p_invalid_start_date OUT NOCOPY Date, -- for comparison
                           p_subr_start_date OUT NOCOPY Date,
                           p_subr_end_date OUT NOCOPY Date,
                           p_last_absence_date OUT NOCOPY Date, -- for printing subrogation
                           p_maternity_related OUT NOCOPY Varchar2)
IS
  --

  l_proc               varchar2(72) := g_package||'Get_abs_print_flg';

  l_prev_end_dt Date;
  l_invalid_start_dt Date := NULL;
  l_abs_duration Number:=0;
  l_subr_start_date Date;
  l_subr_end_date Date;
  l_absence_start_date Date;

  -- Cursor fetching absence details
  Cursor csr_abs_details IS
     SELECT date_start, date_end,absence_attendance_id,abs_information2
     FROM per_absence_attendances
     WHERE person_id = p_person_id
     AND ( absence_attendance_id = p_parent_abs_id
     OR abs_information1 = to_char(p_parent_abs_id))
     AND business_group_id = p_business_group_id
     AND abs_information_category  = 'FR_S'
     ORDER BY date_start ;
  --
  -- Cursor for subrogation details
    Cursor csr_subr_details IS
         SELECT date_start, date_end,abs_information2
         FROM per_absence_attendances
         WHERE person_id = p_person_id
         AND (absence_attendance_id = p_parent_abs_id
         OR abs_information1 = to_char(p_parent_abs_id))
         AND business_group_id = p_business_group_id
         AND abs_information_category  = 'FR_S'
         AND date_start <= p_period_end_date
        ORDER BY date_start desc;

-- check if a maternity absence exists within 48 hours of this sickness
Cursor csr_maternity(c_sick_start_date date, c_person_id Number) IS
   SELECT nvl(min('Y'),'N') maternity_related
   FROM per_absence_attendances pabs,
        per_absence_attendance_types pabt
   WHERE pabs.person_id = c_person_id
    AND (c_sick_start_date - 3 ) BETWEEN pabs.date_start AND pabs.date_end
    AND pabt.absence_attendance_type_id = pabs.absence_attendance_type_id
    AND pabt.absence_category = 'M';

  --
BEGIN
  --
    -- fetch all absences linked to this absence
    hr_utility.set_location('Entering:'|| l_proc,10);

l_absence_start_date := null; -- initialize start of parent absence

    FOR abs_details IN csr_abs_details LOOP
       if l_absence_start_date is null then
          l_absence_start_date := abs_details.date_start;
       end if;
       -- If this is not the parent absence
       IF abs_details.absence_attendance_id <> p_parent_abs_id THEN
        -- (a)check for absence validity
        IF abs_details.date_start - l_prev_end_dt > 2 THEN
           -- populate the invalid start date variable
           l_invalid_start_dt := abs_details.date_start;
           EXIT;
        ELSE
           l_invalid_start_dt := hr_general.end_of_time;
        END IF;
       END IF;
       l_prev_end_dt := abs_details.date_end;
       -- (b) add up the duration
       l_abs_duration := l_abs_duration + round(abs_details.date_end - abs_details.date_start+1);
       -- (c) set the last valid absence date for printing absence
       p_last_absence_date := abs_details.date_end;
    END LOOP;
    -- populate OUT parameters
    p_abs_duration := l_abs_duration;
    p_invalid_start_date := l_invalid_start_dt;
    -- Get subrogation dates
    FOR subr_details in csr_subr_details LOOP
       -- (c) populate the subrogation dates if flag is 'Y'
       IF subr_details.abs_information2 = 'Y' THEN
        l_subr_start_date := subr_details.date_start;
        IF l_subr_end_date IS NULL THEN
           l_subr_end_date := subr_details.date_end;
        END IF;
       ELSE
          IF l_subr_end_date IS NOT NULL THEN
            EXIT;
          END IF;
       END IF;
    END LOOP;
    -- populate subrogation OUT parameters
    p_subr_start_date := l_subr_start_date;
    p_subr_end_date:= l_subr_end_date;

--  is the absence maternity related?
              OPEN csr_maternity(l_absence_start_date,p_person_id);
              FETCH csr_maternity INTO p_maternity_related;
              CLOSE csr_maternity;


    hr_utility.set_location(' Leaving:'||l_proc, 70);
END Get_abs_print_flg;
--
-- get_sickness_skip
FUNCTION Get_Sickness_skip(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
P_action_start_date     IN      Date,
P_action_end_date       IN      Date)
RETURN Varchar2 IS
--
-- Populate the g_absence_calc structure for the element being processed
--
-- fetch the estimate flag from the parent absence
-- if its Y then return N for nor no skip else Y
--
cursor c_get_absence is
select paa.absence_attendance_id
,      to_number(paa.abs_information1) parent_absence_id
,      paa.date_start
,      paa.date_end
,      paa.date_end - paa.date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      paa.abs_information2 subrogated
,      paa.abs_information8 estimated
,      nvl(inc.inc_information1,'N') work_incident
,      paa.person_id
,      paa.business_group_id
from per_absence_attendances paa
,    pay_element_entries_f pee
,    per_work_incidents inc
where pee.element_entry_id = p_element_entry_id
and   paa.absence_attendance_id = pee.creator_id
and   pee.creator_type = 'A'
and   decode(paa.abs_information_category,'FR_S',to_number(paa.abs_information6),null) = inc.incident_id(+);
--
cursor c_get_entry_dates is
select min(effective_start_date)
,      max(effective_end_date)
from pay_element_entries_f
where element_entry_id = p_element_entry_id;
--
cursor c_get_parent_absence(p_absence_attendance_id number) is
select paa.absence_attendance_id
,      0 parent_absence_id
,      paa.date_start
,      paa.date_end
,      paa.date_end - paa.date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      paa.abs_information2 subrogated
,      paa.abs_information8 estimated
,      nvl(inc.inc_information1,'N') work_incident
,      paa.person_id
,      paa.business_group_id
from per_absence_attendances paa
,    per_work_incidents inc
where paa.absence_attendance_id = p_absence_attendance_id
and   paa.abs_information6 = to_char(inc.incident_id(+));
--
cursor c_get_child_absence(p_parent_absence_id number
                          ,p_max_end_date date
                          ,p_person_id    number
                          ,p_business_group_id number) is
select absence_attendance_id
,      to_number(abs_information1) parent_absence_id
,      date_start
,      date_end
,      date_end - date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      null subrogated
,      null estimated
,      null work_incident
,      person_id
,      business_group_id
from per_absence_attendances
where abs_information1 = to_char(p_parent_absence_id)
and   date_end <= p_max_end_date
and   person_id = p_person_id
and   business_group_id = p_business_group_id
order by date_start;
--
TYPE t_absence is RECORD
(absence_attendance_id number
,parent_absence_id number
,date_start date
,date_end date
,duration number
,effective_start_date date
,effective_end_date date
,subrogated varchar2(30)
,estimated varchar2(30)
,work_incident varchar2(30)
,person_id number
,business_group_id number
);
--
abs_rec t_absence;
parent_abs_rec t_absence;
--
l_duration number := 0;
l_absence_start_date date;
l_absence_end_date date;

l_proc               varchar2(72) := g_package||'Get_Sickness_skip';

--
procedure check_gap(p_absence_end_date date
                   ,p_absence_start_date date) is

l_proc               varchar2(72) := g_package||'check_gap';

begin
   hr_utility.set_location('Entering:'|| l_proc,10);
   if p_absence_start_date - p_absence_end_date - 1 > 2 then
             fnd_message.set_name ('PAY', 'PAY_75031_INVALID_LINK_ABS');
             fnd_message.raise_error;
   end if;
   hr_utility.set_location(' Leaving:'||l_proc, 70);
end check_gap;
--
begin
--
-- Fetch absence attendance id corresponding to the element entry
--
   l_proc               := g_package||'get_sickness_skip';
   hr_utility.set_location('Entering:'|| l_proc,10);

   open c_get_absence;
   fetch c_get_absence into abs_rec;
   close c_get_absence;
   --
   open c_get_entry_dates;
   fetch c_get_entry_dates into abs_rec.effective_start_date,
                                abs_rec.effective_end_date;
   close c_get_entry_dates;
   --
   -- Was there any part of the current absence
   --  that was processed in some other (prorated) period??
   --  If yes, that contributes to the duration
   IF (abs_rec.date_start >= p_action_start_date) THEN
     l_duration := 0;
   ELSE
     l_duration := p_action_start_date - abs_rec.date_start ;
   END IF;

   if abs_rec.parent_absence_id is not null then
      --
      -- get the parent absence details
      --
      open c_get_parent_absence(abs_rec.parent_absence_id);
      fetch c_get_parent_absence into parent_abs_rec;
      close c_get_parent_absence;
      --
      l_duration := parent_abs_rec.duration;
      --
      l_absence_end_date := parent_abs_rec.date_end;
      --
      -- get the child absences up to but not including the
      -- orginiating absence
      --
      for a in c_get_child_absence(parent_abs_rec.absence_attendance_id
                                  ,abs_rec.date_start - 1, parent_abs_rec.person_id,parent_abs_rec.business_group_id) loop
          --
          l_absence_start_date := a.date_start;
          --
          -- check length of time between linked absences
          --
          check_gap(l_absence_end_date,l_absence_start_date);
          --
          l_absence_end_date := a.date_end;
          l_duration := l_duration + a.duration;

          hr_utility.set_location(' In Sickness Skip and duration ='||l_duration,60);
      end loop;


      --
      -- check length of time between initiating absence and last absence
      -- processed
      --
      check_gap(l_absence_end_date,abs_rec.date_start);
   else
      parent_abs_rec := abs_rec;
   end if;
   --
   g_absence_calc.element_entry_id := p_element_entry_id;
   g_absence_calc.date_earned := p_date_earned;
   g_absence_calc.id := abs_rec.absence_attendance_id;
   g_absence_calc.effective_start_date := abs_rec.effective_start_date;
   g_absence_calc.effective_end_date := abs_rec.effective_end_date;
   g_absence_calc.ijss_subrogated := abs_rec.subrogated;
   g_absence_calc.ijss_estimated := parent_abs_rec.estimated;
   g_absence_calc.parent_absence_id := parent_abs_rec.absence_attendance_id;
   g_absence_calc.parent_absence_start_date
                     := parent_abs_rec.date_start;
   g_absence_calc.work_incident := parent_abs_rec.work_incident;
   g_absence_calc.prior_linked_absence_duration := l_duration;
   hr_utility.set_location(' In Sickness Skip and final duration ='||g_absence_calc.prior_linked_absence_duration,65);
--
   if g_absence_calc.ijss_estimated = 'Y' then
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'N';
   else
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'Y';
   end if;
END get_sickness_skip;



FUNCTION Get_Sickness_skip_result
RETURN Varchar2 IS
l_proc VARCHAR2(72)  := g_package||'Get_Sickness_Skip_result';
BEGIN

   if g_absence_calc.ijss_estimated = 'Y' then
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'N';
   else
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'Y';
   end if;

END;
--
-----------------------------------------------------------------
-- Function to compare the best net guarantee and to return the
-- adjustment to previous paymnts if the best method changes
-----------------------------------------------------------------
PROCEDURE Compare_Guarantee
(p_absence_arch IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch
,p_coverages    IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages) IS
--
total_net number;
best_net number;
best_net_index number;
prev_best_net_index number;
prev_payment number := 0;
prev_ijss number := 0;
best_payment number := 0;
best_ijss number := 0;
gi_adjustment number := 0;
gross_ijss_adjustment number := 0;
--
l_proc               varchar2(72) := g_package||'Compare_Guarantee';
begin
--
  hr_utility.set_location('Entering:'|| l_proc,10);

  for i in p_coverages.first..p_coverages.last loop
      -- identify the total guarantee
      total_net := nvl(p_coverages(i).net,0) + nvl(p_coverages(i).previous_net,0);
  hr_utility.trace('in p_coverages i:'||to_char(i)|| ' total_net:'||to_char(total_net));
      --
      -- if the total guarantee is better than the currently identified best
      -- then reset the current best
      --
      -- if it is the same as the current best and was the previous best method
      -- then use the previous best method
      --
      if total_net > best_net or best_net is null then
         best_net := total_net;
         best_net_index := i;
      elsif total_net = best_net then
         if p_coverages(i).best_method = 'P' then
            best_net_index := i;
         end if;
      end if;
      --
      if p_coverages(i).best_method = 'P' then
         prev_best_net_index := i;
      end if;
      --
  end loop;
  --
  -- Calculate the previous best GI payment and IJSS payment
  --
  if prev_best_net_index is not null then
     prev_payment := p_coverages(prev_best_net_index).previous_gi_payment +
                     p_coverages(prev_best_net_index).previous_sick_adj;
     prev_ijss := p_coverages(prev_best_net_index).previous_ijss_gross;
     --
     p_coverages(prev_best_net_index).best_method := '';
  end if;
  --
  -- Calculate the current best GI payment and IJSS payment
  --
  best_payment := p_coverages(best_net_index).previous_gi_payment +
                  p_coverages(best_net_index).previous_sick_adj;
  best_ijss := p_coverages(best_net_index).previous_ijss_gross;
     --
  --
  -- Store the adjustments required for HI payment and IJSS payment
  --
  p_absence_arch.gi_adjustment := best_payment - prev_payment;
  p_absence_arch.gross_ijss_adjustment := best_ijss - prev_ijss;
  --
  -- Set the best method flag
  --
  p_coverages(best_net_index).best_method := 'Y';
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end compare_guarantee;
--
PROCEDURE Calc_IJSS_Gross
(p_IJSS_Gross_Start_Date IN Date
,p_IJSS_Gross_End_Date IN Date
,p_coverage_idx  IN Number
,p_coverages IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages
,p_absence_arch IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch) IS
--
TYPE t_ijss_gross_rec IS RECORD
(Gross number
,Rate number
,Start_Date date
,End_Date date
,Number_of_days number);
--
TYPE t_ijss_gross IS TABLE OF t_ijss_gross_rec INDEX BY BINARY_INTEGER;

Cursor csr_global_value(c_global_name VARCHAR2,c_date_earned DATE) IS
   SELECT global_value
   FROM ff_globals_f
   WHERE global_name = c_global_name
   AND legislation_code = 'FR'
   AND c_date_earned BETWEEN effective_start_date AND effective_end_date;

--
l_ijss_gross t_ijss_gross;
l_current_rate number := -1;
j number := 0;
l_ijss_net_rate number := 0;
l_ijss_net_for_guarantee1 number := 0;
l_ijss_net_for_guarantee2 number := 0;
--
l_proc               varchar2(72) := g_package||'Calc_IJSS_Gross';
begin
  hr_utility.set_location('Entering:'|| l_proc,10);
  l_ijss_gross(1).Gross := 0;
  l_ijss_gross(2).Gross := 0;
  l_ijss_gross(1).Number_of_days := 0;
  l_ijss_gross(2).Number_of_days := 0;
  --
  for i in g_overlap.first..g_overlap.last loop
     if g_overlap(i).absence_day >= p_IJSS_Gross_Start_Date and
        g_overlap(i).absence_day <= p_IJSS_Gross_End_Date and
        g_overlap(i).IJSS_Gross > 0 then
        --
        if g_overlap(i).IJSS_Gross <> l_current_rate then
           l_current_rate := g_overlap(i).IJSS_Gross;
           j := j+1;
        end if;
        --
        if l_ijss_gross(j).Rate is null then
           l_ijss_gross(j).Rate := g_overlap(i).IJSS_Gross;
           l_ijss_gross(j).Start_Date := g_overlap(i).Absence_day;
        end if;
        --
        l_ijss_gross(j).Gross :=
               l_ijss_gross(j).Gross + g_overlap(i).IJSS_Gross;
        l_ijss_gross(j).End_Date := g_overlap(i).Absence_day;
        l_ijss_gross(j).Number_of_days := l_ijss_gross(j).Number_of_days + 1;
        --
     end if;
  end loop;

               OPEN csr_global_value('FR_IJSS_NET_RATE',p_IJSS_Gross_Start_Date);
               FETCH csr_global_value INTO l_ijss_net_rate;
               CLOSE csr_global_value;

  if l_ijss_gross(1).Rate is not null then
     p_coverages(p_coverage_idx).IJSS_Gross1 :=
                l_ijss_gross(1).Gross;
     p_coverages(p_coverage_idx).IJSS_Gross_rate1 :=
                l_ijss_gross(1).Rate;
     p_coverages(p_coverage_idx).IJSS_from_date1 :=
                l_ijss_gross(1).Start_Date;
     p_coverages(p_coverage_idx).IJSS_to_date1 :=
                l_ijss_gross(1).End_Date;
     p_coverages(p_coverage_idx).IJSS_Gross_days1 :=
                l_ijss_gross(1).Number_of_days;

 IF g_absence_calc.initiator <> 'CPAM' THEN

     l_ijss_net_for_guarantee1 := nvl(p_coverages(p_coverage_idx).IJSS_Gross1,0) * ((100 - l_ijss_net_rate)/100);
     p_coverages(p_coverage_idx).ijss_net_adjustment := (nvl(p_absence_arch.ijss_net,0) + nvl(p_absence_arch.ijss_payment,0) - l_ijss_net_for_guarantee1) ;

 END IF;

  end if;
  if l_ijss_gross(2).Rate is not null then
     p_coverages(p_coverage_idx).IJSS_Gross2 :=
                l_ijss_gross(2).Gross;
     p_coverages(p_coverage_idx).IJSS_Gross_rate2 :=
                l_ijss_gross(2).Rate;
     p_coverages(p_coverage_idx).IJSS_from_date2 :=
                l_ijss_gross(2).Start_Date;
     p_coverages(p_coverage_idx).IJSS_to_date2 :=
                l_ijss_gross(2).End_Date;
     p_coverages(p_coverage_idx).IJSS_Gross_days2 :=
                l_ijss_gross(2).Number_of_days;

 IF g_absence_calc.initiator <> 'CPAM' THEN

l_ijss_net_for_guarantee2 := nvl(p_coverages(p_coverage_idx).IJSS_Gross2,0) *((100 - l_ijss_net_rate)/100);
     p_coverages(p_coverage_idx).ijss_net_adjustment := nvl(p_coverages(p_coverage_idx).ijss_net_adjustment,0) - l_ijss_net_for_guarantee2;

 END IF;

  end if;
  --
   hr_utility.set_location(' Leaving:'||l_proc, 70);
end;
--

-- +********************************************************************+
-- |                        PRIVATE PROCEDURE                           |
-- +********************************************************************+
------------------------------------------------------------------------
--Bug:2683421
--Procedure absence_not_processed
--This Procedure will raise error if any of the sickness absences
--was not processed prior to this absence.
--
--This will be called from calc_sicknes procedure
------------------------------------------------------------------------

Procedure absence_not_processed
          ( p_asg                  In pay_fr_sick_pay_processing.t_asg
           ,p_sickness_start_date  In Date
          ) As

-- Added another parameters to fetch IJSS estimation flag
-- and absence start date
-- Cursor for getting sickness element entries
Cursor csr_get_sickness_entries Is
Select peef.element_entry_id,
       peef.effective_start_date,
       peef.effective_end_date,
       peef.assignment_id,
       ceil(months_between(peef.effective_end_date,peef.effective_start_date)) Period,
       --
       paa.date_start                Abs_start_date,
       paa.date_end                  Abs_end_date,
       nvl(paa.abs_information8,'N') IJSS_estimate
 from
   pay_element_entries_f   peef
  ,pay_element_links_f     pelf
  ,pay_element_types_f     petf
  ,per_absence_attendances paa
 where peef.assignment_id = p_asg.assignment_id
   and peef.element_link_id = pelf.element_link_id
   and pelf.element_type_id = petf.element_type_id
   and p_asg.action_start_date between pelf.effective_start_date and pelf.effective_end_date
   and petf.element_name    = 'FR_SICKNESS_INFORMATION'
   and p_asg.action_start_date between petf.effective_start_date and petf.effective_end_date
   and peef.effective_start_date < trunc(p_sickness_start_date,'MONTH')
   and paa.absence_attendance_id = peef.creator_id
   -- added clause for selecting within a year
   and paa.date_start >= add_months(p_asg.action_start_date, -12)
   and peef.creator_type = 'A' ;
--

-- Cursor for getting processed sickness elements' run results
Cursor csr_get_entry_processed(c_element_entry_id Number,
                               c_assignment_id Number,
                               c_period Date) Is
-- AS 5/9/3 commented out some date and status criteria here as error was being raised incorrectly
Select  'Y'
          from pay_payroll_actions    ppa
              ,pay_assignment_actions paa
              ,pay_run_results        prr
         where ppa.payroll_id + 0          = p_asg.payroll_id
--           and ppa.date_earned          < trunc(p_sickness_start_date,'MONTH')
--           and to_char(ppa.date_earned,'MON-YYYY') = to_char(c_period,'MON-YYYY')
           and paa.assignment_id + 0       = c_assignment_id
           and ppa.payroll_action_id    = paa.payroll_action_id
           and ppa.action_type          in ('R','Q')
           and prr.status in ('P','PA')
--           and paa.action_status        = 'C'
           and paa.assignment_action_id = prr.assignment_action_id
           and prr.source_id            = c_element_entry_id;

-- Cursor for getting CPAM element run results
Cursor csr_get_CPAM_results(c_abs_start_date DATE,
                            c_abs_end_date DATE) is
Select min(fnd_date.canonical_to_date(prrv_pst.result_value))  Pmt_start_dt,
       max(fnd_date.canonical_to_date(prrv_pet.result_value))  Pmt_end_dt,
       piv_pst.input_value_id      pmt_start_input_id,
       piv_pet.input_value_id      pmt_end_input_id
       --
   From pay_run_result_values  prrv_pst,
        pay_run_result_values  prrv_pet,
        pay_input_values_f     piv_pst,
        pay_input_values_f     piv_pet,
        pay_run_results        prr_pst,
        pay_run_results        prr_pet,
        pay_element_types_f    peltf,
        pay_assignment_actions pact,
        pay_payroll_actions    ppac
        --
  Where prrv_pst.result_value between fnd_date.date_to_canonical(c_abs_start_date) and fnd_date.date_to_canonical(c_abs_end_date)
    and prrv_pet.result_value between fnd_date.date_to_canonical(c_abs_start_date) and fnd_date.date_to_canonical(c_abs_end_date)
    --
    and prrv_pst.input_value_id = piv_pst.input_value_id
    and prrv_pst.run_result_id = prr_pst.run_result_id
    --
    and peltf.element_name = 'FR_SICKNESS_CPAM_PROCESS'
    and c_abs_start_date between peltf.effective_start_date and peltf.effective_end_date
    and piv_pst.element_type_id =  peltf.element_type_id
    and piv_pst.name = 'Payment From Date'
    and c_abs_start_date between piv_pst.effective_start_date and piv_pst.effective_end_date
    ----
    and prr_pst.element_type_id = peltf.element_type_id
    and prr_pst.assignment_action_id = pact.assignment_action_id
    ----
    and pact.assignment_id = p_asg.assignment_id
    and pact.action_status ='C'
    and prr_pst.status in ('P','PA')
    and prr_pet.status in ('P','PA')
    and pact.payroll_action_id = ppac.payroll_action_id
    and ppac.action_type in ('R','Q')
    and ppac.payroll_id = p_asg.payroll_id
    and ppac.date_earned between c_abs_start_date and p_asg.action_end_date
    --
    and prrv_pet.input_value_id = piv_pet.input_value_id
    and prrv_pet.run_result_id = prr_pet.run_result_id
    --
    and piv_pet.element_type_id = peltf.element_type_id
    and piv_pet.name = 'Payment To Date'
    and c_abs_start_date between piv_pet.effective_start_date and piv_pet.effective_end_date
    --
    and prr_pet.element_type_id = peltf.element_type_id
    and prr_pet.assignment_action_id = pact.assignment_action_id
  group by piv_pst.input_value_id,piv_pet.input_value_id;
--
-- Cursor for getting CPAM element entries
Cursor csr_get_cpam_entries(c_pst_input_value_id NUMBER,
                            c_pet_input_value_id NUMBER,
                            c_prev_pmt_end_dt DATE,
                            c_abs_end_date DATE)IS
--
Select peval_pst.screen_entry_value pmt_start_date,
       peval_pet.screen_entry_value pmt_end_date
       --
 from pay_element_entry_values_f peval_pst,
      pay_element_entry_values_f peval_pet,
      pay_element_entries_f  pentf,
      pay_element_links_f    plink,
      pay_element_types_f    peltf
      --
 where pentf.assignment_id = p_asg.assignment_id
   and pentf.element_link_id = plink.element_link_id
   and pentf.effective_start_date between p_asg.action_start_date and p_asg.action_end_date
   and plink.element_type_id = peltf.element_type_id
   and peltf.element_name = 'FR_SICKNESS_CPAM_PROCESS'
   and p_asg.action_start_date between peltf.effective_start_date and peltf.effective_end_date
   and p_asg.action_start_date between plink.effective_start_date and plink.effective_end_date
   and peval_pst.element_entry_id = pentf.element_entry_id
   and peval_pst.input_value_id = c_pst_input_value_id
   and peval_pet.element_entry_id = pentf.element_entry_id
   and peval_pet.input_value_id = c_pet_input_value_id
   and peval_pst.screen_entry_value > fnd_date.date_to_canonical(c_prev_pmt_end_dt)
   and peval_pet.screen_entry_value <= fnd_date.date_to_canonical(c_abs_end_date)
   and p_asg.action_end_date between peval_pst.effective_start_date and peval_pst.effective_end_date
   and p_asg.action_end_date between peval_pet.effective_start_date and peval_pet.effective_end_date;
--
l_entry_rec          csr_get_sickness_entries%RowType;
l_temp               Varchar2(2);
l_payment_Start_date Date;
l_payment_end_date   Date;
l_pmt_start_id       Number;
l_pmt_end_id         Number;
l_prev_pmt_end_dt    Date;

l_date Date;

Begin


FOR l_entry_rec In csr_get_sickness_entries LOOP
   -- added extra condition for checkin IJSS estimate flag
   IF l_entry_rec.IJSS_estimate = 'Y' THEN
      -- check if absence has been processed
      --
      FOR i in 1..l_entry_rec.period LOOP

          l_date := add_months(l_entry_rec.effective_start_date,i-1);

          If l_date < p_sickness_start_date Then

       hr_utility.trace('pre csr_get_entry_processed. l_entry_rec.element_entry_id:'||to_char(l_entry_rec.element_entry_id)|| ' l_entry_rec.assignment_id:'||to_char(l_entry_rec.assignment_id)|| ' l_date:'||to_char(l_date));
            Open csr_get_entry_processed(l_entry_rec.element_entry_id,l_entry_rec.assignment_id,l_date);
            Fetch csr_get_entry_processed Into l_temp;

                If csr_get_entry_processed%NotFound Then
                   Close csr_get_entry_processed;
                   fnd_message.set_name('PAY', 'PAY_75043_SICK_NOT_PROCESSED');
                   fnd_message.set_token('START_DATE',to_char(l_entry_rec.Abs_start_date,'DD/MM/YYYY'));
                   fnd_message.set_token('END_DATE',to_char(l_entry_rec.Abs_end_date,'DD/MM/YYYY'));
                   fnd_message.raise_error;
                End If;
            Close csr_get_entry_processed;
          END IF;
      END LOOP;
   ELSE
      -- Check if absence has been paid off
      -- Find CPAM element run results corresponding to this absence
      OPEN csr_get_CPAM_results(l_entry_rec.Abs_start_date, l_entry_rec.Abs_end_date);
      FETCH csr_get_CPAM_results INTO l_payment_Start_date,
                                      l_payment_end_date,
                                      l_pmt_start_id ,
                                      l_pmt_end_id;
      CLOSE csr_get_CPAM_results;
      --
      IF l_payment_Start_date IS NULL -- no payment
        OR l_payment_end_date < l_entry_rec.Abs_end_date -- incomplete payment
      THEN
          l_prev_pmt_end_dt := nvl(l_payment_end_date,l_entry_rec.Abs_start_date-1);
          -- Check for element entries of this period
          FOR cpam_entry_rec IN csr_get_cpam_entries(l_pmt_start_id,
                                                     l_pmt_end_id,
                                                     l_prev_pmt_end_dt,
                                                     l_entry_rec.Abs_end_date) LOOP
              --
              IF fnd_date.canonical_to_date(cpam_entry_rec.pmt_start_date) = l_prev_pmt_end_dt +1
                 OR fnd_date.canonical_to_date(cpam_entry_rec.pmt_start_date) = l_entry_rec.Abs_start_date THEN
                 --
                 IF fnd_date.canonical_to_date(cpam_entry_rec.pmt_end_date) = l_entry_rec.Abs_end_date THEN
                    EXIT;
                 END IF;
                 l_prev_pmt_end_dt := fnd_date.canonical_to_date(cpam_entry_rec.pmt_end_date);
              ELSE
                 fnd_message.set_name('PAY', 'PAY_75043_SICK_NOT_PROCESSED');
                 fnd_message.set_token('START_DATE',to_char(l_entry_rec.Abs_start_date,'DD/MM/YYYY'));
                 fnd_message.set_token('END_DATE',to_char(l_entry_rec.Abs_end_date,'DD/MM/YYYY'));
                 fnd_message.raise_error;
              END IF;
          END LOOP;
      END IF;
   END IF;

END LOOP;

If csr_get_entry_processed%IsOpen Then
   Close csr_get_entry_processed;
End If;

End absence_not_processed;
--
PROCEDURE Calc_Sickness(
P_mode          IN OUT NOCOPY VARCHAR2 ,
p_asg           IN OUT NOCOPY pay_fr_sick_pay_processing.t_asg,
p_absence_arch  IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch,
p_coverages     IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages) IS
--
-- cursor added for CPAM payment
-- to get period start and end dates for absence being processed
cursor csr_abs_period_dates (c_business_group_id number
                              ,c_payroll_id        number
                              ,c_payroll_action_id number
                              ,c_payment_start_date date
                              ,c_payment_end_date   date) is
select PTP.start_date,
       PTP.end_date
  from pay_payroll_actions PPA,
       per_time_periods    PTP
 where ppa.payroll_action_id = c_payroll_action_id
   and ppa.business_group_id = c_business_group_id
   and ppa.payroll_id        = c_payroll_id
   and ppa.payroll_id  = ptp.payroll_id
   and c_payment_start_date between ptp.start_date and ptp.end_date
   and c_payment_end_date  between ptp.start_date and ptp.end_date ;
--
l_work_inc_class varchar2(30);
l_first_day date;
l_net number := 0;
l_index number;
-- declared for calculating paid days
l_total_days number;
l_idx_coverages number;
l_idx_bm number;
--
l_proc               varchar2(72) := g_package||'Calc_Sickness';
begin
 hr_utility.set_location('Entering:'|| l_proc,10);
 if p_mode = 'I' then
    -- Code added for CPAM payment processing
    IF g_absence_calc.initiator = 'CPAM' THEN
       -- get the absence period dates
       OPEN csr_abs_period_dates (p_asg.business_group_id
                                   ,p_asg.payroll_id
                                   ,p_asg.payroll_action_id
                                   ,g_absence_calc.effective_start_date
                                   ,g_absence_calc.effective_end_date);
       FETCH csr_abs_period_dates into g_absence_calc.abs_ptd_start_date
                                        ,g_absence_calc.abs_ptd_end_date;
       CLOSE csr_abs_period_dates;
       --
       p_absence_arch.sick_deduct_start_date := greatest(g_absence_calc.effective_start_date
                                                        ,g_absence_calc.abs_ptd_start_date);
       p_absence_arch.sick_deduct_end_date := least(g_absence_calc.effective_end_date
                                                   ,g_absence_calc.abs_ptd_end_date);
       Get_CPAM_ref_salary( p_asg.business_group_id,
                            p_asg.assignment_id,
                            p_asg);
       --Check for unprocessed sickness absences.
       absence_not_processed(p_asg,p_absence_arch.sick_deduct_start_date);

       IF g_absence_calc.work_incident = 'N' THEN
         l_work_inc_class := 'N';
       ELSE
         l_work_inc_class := 'O';
       END IF;
       --
       -- Calling procedure to populate g_overlap table
       Get_sickness_CPAM_IJSS(
       p_business_group_id => p_asg.business_group_id,
       p_assignment_id     => p_asg.assignment_id,
       p_absence_id        => g_absence_calc.ID,
       p_start_date        => p_absence_arch.sick_deduct_start_date,
       p_end_date          => p_absence_arch.sick_deduct_end_date ,
       p_work_inc_class    => l_work_inc_class);
       --
    ELSE
       p_absence_arch.sick_deduct_start_date := greatest(g_absence_calc.effective_start_date
                                                        ,p_asg.action_start_date);
       --
       p_absence_arch.sick_deduct_end_date := least(g_absence_calc.effective_end_date
                                                   ,p_asg.action_end_date
                                                   ,p_absence_arch.date_earned);

       --Check For unprossed sickness absences.
       absence_not_processed(p_asg,p_absence_arch.sick_deduct_start_date);
       --
       -- Call calculate_IJSS to populate g_overlap table
       --
       if g_absence_calc.work_incident = 'N' then
          l_work_inc_class := 'N';
       else
          l_work_inc_class := 'O';
       end if;
       --
       Calc_IJSS
       (p_business_group_id     => p_asg.business_group_id
       ,p_assignment_id         => p_asg.assignment_id
       ,p_absence_id            => g_absence_calc.ID
       ,p_start_date            => p_absence_arch.sick_deduct_start_date
       ,p_end_date              => p_absence_arch.sick_deduct_end_date
       ,p_absence_duration      => g_absence_calc.prior_linked_absence_duration
       ,p_work_inc_class        => l_work_inc_class);
        --
    END IF;
    --
    Calculate_Sickness_Deduction
   (p_absence_start_date => p_absence_arch.sick_deduct_start_date
   ,p_absence_end_date   => p_absence_arch.sick_deduct_end_date
   ,p_asg                => p_asg
   ,p_absence_arch       => p_absence_arch);

   p_absence_arch.ijss_estimated    := g_absence_calc.IJSS_estimated;
   p_absence_arch.parent_absence_id := g_absence_calc.parent_absence_id;

--
   --
   -- Calculate the sum of the IJSS_Net values for the days to be paid
   --
  hr_utility.set_location(' 1st row in g_overlap='||g_overlap.first||' and last row='||g_overlap.last,20);
  if g_overlap.count > 0 THEN

   for i in g_overlap.first..g_overlap.last loop
       l_net := l_net + g_overlap(i).IJSS_Net;
       --
       hr_utility.set_location(' Date of row(idx='||g_overlap.first||')in g_overlap='||g_overlap(i).absence_day,40);
       if g_overlap(i).Holiday is null then
          if l_first_day is null then
             l_first_day := g_overlap(i).absence_day;
          end if;
       end if;
   end loop;
   --

   if l_first_day is not null then
      hr_utility.set_location(' For GIs,start date='||l_first_day||' and end date='||g_overlap(g_overlap.last).Absence_day,50);
      g_absence_calc.IJSS_payment_start_date := l_first_day;
      g_absence_calc.IJSS_payment_end_date
                     := g_overlap(g_overlap.last).Absence_day;

      --
      if g_absence_calc.ijss_subrogated = 'Y' then
         p_absence_arch.ijss_payment := l_net;
      else
         p_absence_arch.ijss_net := l_net;
      end if;
      --
      Calc_LEGAL_GI
      (p_asg                   => p_asg
      ,p_coverages             => p_coverages
      ,p_absence_arch          => p_absence_arch);
      --
      Calc_CAGR_GI
      (p_asg                   => p_asg
      ,p_coverages             => p_coverages
      ,p_absence_arch          => p_absence_arch);
      --
   end if;
 end if;
   --
   -- Populate a row for No Guarantee always
   --
   l_index := nvl(p_coverages.LAST, 0) + 1;
   p_coverages(l_index).g_type
        := pay_fr_sick_pay_processing.get_guarantee_id('NO_G');

   --
 else -- p_mode = 'C'
   Compare_Guarantee
   (p_absence_arch          => p_absence_arch
   ,p_coverages             => p_coverages);
 end if;
 -- Added for calculating paid days
 -- Find total days
 l_total_days := p_absence_arch.sick_deduct_end_date - p_absence_arch.sick_deduct_start_date +1;
 hr_utility.set_location('Total Days: '||l_total_days, 22);

 -- Find the best method row in p_coverages
 FOR l_idx_coverages IN p_coverages.FIRST..p_coverages.LAST LOOP
    hr_utility.set_location('Index for p_coverages: '||l_idx_coverages, 22);
    hr_utility.set_location('Best Method Flag for Index Number '||l_idx_coverages||' is: '||p_coverages(l_idx_coverages).BEST_METHOD, 22);
    IF p_coverages(l_idx_coverages).BEST_METHOD ='Y' THEN
       l_idx_bm := l_idx_coverages;
       EXIT;
    ELSE
       l_idx_bm := -1;
    END IF;
 END LOOP;
 hr_utility.set_location('Idx for best method: '||l_idx_bm, 22);

 -- Check g_type, overlapping it with the g_guarantee_type_lookups
 IF l_idx_bm <> -1 THEN
    IF p_coverages(l_idx_bm).g_type <> -1 AND
       p_coverages(l_idx_bm).g_type = pay_fr_sick_pay_processing.get_guarantee_id('GN') THEN
       hr_utility.set_location('Calculations when guarantee is GN', 22);
       p_absence_arch.partial_paid_days := 0;
       p_absence_arch.unpaid_days := l_total_days - (p_coverages(l_idx_bm).gi_days1 + p_coverages(l_idx_bm).gi_days2);
    ELSE
       hr_utility.set_location('Calculations when guarantee is NOT GN', 22);
       p_absence_arch.partial_paid_days := p_coverages(l_idx_bm).gi_days1 + p_coverages(l_idx_bm).gi_days2;
       p_absence_arch.unpaid_days := l_total_days - p_absence_arch.partial_paid_days;
    END IF;
 END IF;
 --
 hr_utility.set_location(' Leaving:'||l_proc, 70);
end calc_sickness;
--
-----------------------------------------------------------------------
-- Function FR_ROLLING_BALANCE
-- function to return rolling balance values
----------------------------------------------------------------------
Function fr_rolling_balance (p_assignment_id in number,
                             p_balance_name in varchar2,
                             p_balance_start_date in date,
                             p_balance_end_date in date) return number
IS
Cursor csr_def_bal_id IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
   WHERE  pdb.balance_type_id = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
   AND    pbt.balance_name = p_balance_name
   AND    pbd.database_item_suffix = '_ASG_PTD'
   AND    pdb.legislation_code = 'FR';
--
l_defined_balance_id number;
l_start number := to_char(p_balance_start_date,'J');
l_end number := to_char(p_balance_end_date,'J');
i number        := 0;
l_value number  := 0;
l_proc               varchar2(72) := g_package||'fr_rolling_balance';
BEGIN
   hr_utility.set_location('Entering:'|| l_proc,10);
   open csr_def_bal_id;
   fetch csr_def_bal_id into l_defined_balance_id;
   close csr_def_bal_id;
   --
   while add_months(p_balance_start_date,i) <= p_balance_end_date loop
       BEGIN
         l_value := l_value +
                         pay_balance_pkg.get_value
                         (l_defined_balance_id
                         ,p_assignment_id
                         ,add_months(p_balance_start_date,i+1)-1);

       EXCEPTION
         WHEN NO_DATA_FOUND THEN  --Bug #2651568
           l_value := 0;
       END;
       i := i + 1;
       hr_utility.set_location(' BAL VAL='||l_value, 60);
     end loop;
     hr_utility.set_location(' FINAL BAL VAL='||l_value, 60);
   hr_utility.set_location(' Leaving:'||l_proc, 70);
   return l_value;
END;
-----------------------------------------------------------------------------
--  SET_GLOBAL_IDS
--  cache the id's for sudit elements and inputs
-----------------------------------------------------------------------------
PROCEDURE SET_GLOBAL_IDS(p_effective_date in DATE) is
l_proc               varchar2(72) := g_package||'SET_GLOBAL_IDS';
begin
  hr_utility.set_location('Entering:'|| l_proc,10);
        select max(e.element_type_id)
              ,max(decode(i.name,'Parent Absence ID',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee Type',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee ID',i.input_value_id,null))
              ,max(decode(i.name,'GI Payment',i.input_value_id,null))
              ,max(decode(i.name,'Net',i.input_value_id,null))
              ,max(decode(i.name,'Adjustment',i.input_value_id,null))
              ,max(decode(i.name,'IJSS Gross',i.input_value_id,null))
              ,max(decode(i.name,'Best Method',i.input_value_id,null))
              ,max(decode(i.name,'Band1',i.input_value_id,null))
              ,max(decode(i.name,'Band2',i.input_value_id,null))
              ,max(decode(i.name,'Band3',i.input_value_id,null))
              ,max(decode(i.name,'Band4',i.input_value_id,null))
              ,max(decode(i.name,'Payment Start Date',i.input_value_id,null))
              ,max(decode(i.name,'Payment End Date',i.input_value_id,null))
             into    g_gi_info_element_type_id
              ,g_gi_info_absence_id_iv_id
              ,g_gi_info_guarantee_type_iv_id
              ,g_gi_info_guarantee_id_iv_id
              ,g_gi_info_gi_payment_iv_id
              ,g_gi_info_net_iv_id
              ,g_gi_info_adjustment_iv_id
              ,g_gi_info_ijss_gross_iv_id
              ,g_gi_info_best_method_iv_id
              ,g_gi_info_band1_iv_id
              ,g_gi_info_band2_iv_id
              ,g_gi_info_band3_iv_id
              ,g_gi_info_band4_iv_id
              ,g_gi_info_start_date_iv_id
              ,g_gi_info_end_date_iv_id
             from pay_element_types_f e,
                  pay_input_values_f i
             where e.element_name = 'FR_SICKNESS_GI_INFO'
             and e.legislation_code = 'FR'
             and e.element_type_id = i.element_type_id
             and p_effective_date between e.effective_start_date and e.effective_end_date
             and p_effective_date between i.effective_start_date and i.effective_end_date;

        select max(e.element_type_id)
              ,max(decode(i.name,'Parent Absence ID',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee Type',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee ID',i.input_value_id,null))
              ,max(decode(i.name,'GI Payment',i.input_value_id,null))
              ,max(decode(i.name,'Net',i.input_value_id,null))
              ,max(decode(i.name,'Adjustment',i.input_value_id,null))
              ,max(decode(i.name,'IJSS Gross',i.input_value_id,null))
              ,max(decode(i.name,'Best Method',i.input_value_id,null))
              ,max(decode(i.name,'Band1',i.input_value_id,null))
              ,max(decode(i.name,'Band2',i.input_value_id,null))
              ,max(decode(i.name,'Band3',i.input_value_id,null))
              ,max(decode(i.name,'Band4',i.input_value_id,null))
              ,max(decode(i.name,'Payment Start Date',i.input_value_id,null))
              ,max(decode(i.name,'Payment End Date',i.input_value_id,null))
             into    g_gi_i_r_element_type_id
              ,g_gi_i_r_absence_id_iv_id
              ,g_gi_i_r_guarantee_type_iv_id
              ,g_gi_i_r_guarantee_id_iv_id
              ,g_gi_i_r_gi_payment_iv_id
              ,g_gi_i_r_net_iv_id
              ,g_gi_i_r_adjustment_iv_id
              ,g_gi_i_r_ijss_gross_iv_id
              ,g_gi_i_r_best_method_iv_id
              ,g_gi_i_r_band1_iv_id
              ,g_gi_i_r_band2_iv_id
              ,g_gi_i_r_band3_iv_id
              ,g_gi_i_r_band4_iv_id
              ,g_gi_i_r_start_date_iv_id
              ,g_gi_i_r_end_date_iv_id
             from pay_element_types_f e,
                  pay_input_values_f i
             where e.element_name = 'FR_SICKNESS_GI_INFO_RETRO'
             and e.legislation_code = 'FR'
             and e.element_type_id = i.element_type_id
             and p_effective_date between e.effective_start_date and e.effective_end_date
             and p_effective_date between i.effective_start_date and i.effective_end_date;

  hr_utility.set_location('Leaving:'|| l_proc,90);

end SET_GLOBAL_IDS;
--
-----------------------------------------------------------------------
-- GET_GI_PAYMENTS_AUDIT
-- fetch results from element FR_SICKNESS_GI_INFO for a particular
-- absence and guarantee
-----------------------------------------------------------------------
--
PROCEDURE Get_GI_Payments_Audit
        (p_GI_id                IN      Number,
         p_asg                  IN      pay_fr_sick_pay_processing.t_asg,
         p_parent_absence_id    IN      Number,
         p_current_date         IN      Date,
         p_GI_Previous_Net OUT NOCOPY   Number,
         p_GI_Previous_Payment OUT NOCOPY       Number,
         p_GI_Previous_Adjustment OUT NOCOPY    Number,
         p_GI_Previous_IJSS_Gross OUT NOCOPY    Number,
         p_GI_Best_Method        OUT NOCOPY     Varchar2) IS

cursor get_audit( p_parent_absence_id varchar2,
                  p_guarantee_id varchar2,
                  p_assignment_id number,
                  p_parent_absence_start_date date) is
-- fetch audit  results for this absence
-- Net Payment Adjustment IJSS Gross Best Method for each Guarantee ID
select /*+ORDERED */
  assact.action_sequence action_sequence,
  nvl(sum(decode(target.input_value_id,
    g_gi_info_net_iv_id,fnd_number.canonical_to_number(target.result_value),
    g_gi_i_r_net_iv_id, fnd_number.canonical_to_number(target.result_value),
    0)),0) previous_net,
  nvl(sum(decode(target.input_value_id,
    g_gi_info_gi_payment_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    g_gi_i_r_gi_payment_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    0)),0) previous_payment,
  nvl(sum(decode(target.input_value_id,
    g_gi_info_adjustment_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    g_gi_i_r_adjustment_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    0)),0) previous_adjustment,
  nvl(sum(decode(target.input_value_id,
    g_gi_info_ijss_gross_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    g_gi_i_r_ijss_gross_iv_id,
    fnd_number.canonical_to_number(target.result_value),
    0)),0) previous_IJSS_gross,
  max(decode(target.input_value_id,
    g_gi_info_end_date_iv_id,
    fnd_date.canonical_to_date(target.result_value),
    g_gi_i_r_end_date_iv_id,
    fnd_date.canonical_to_date(target.result_value),
    null)) payment_end_date,
  max(decode(target.input_value_id,
    g_gi_info_best_method_iv_id,target.result_value,
    g_gi_i_r_best_method_iv_id, target.result_value,null)) best_method,
  nvl(ee.creator_id,0)        retro_asg_action,
  epd.adjustment_type         retro_adj_type
from  pay_assignment_actions    assact
     ,pay_payroll_actions       pact
     ,pay_run_results           rr
     ,pay_run_result_values     guarantee_id
     ,pay_run_result_values     parent_absence_id
     ,pay_run_result_values     target
     ,pay_entry_process_details epd
     ,pay_element_entries_f     ee
where assact.assignment_id              = p_assignment_id
  and assact.payroll_action_id          = pact.payroll_action_id
  and pact.action_type                 in ('R', 'Q', 'B')
  and pact.date_earned                 >= p_parent_absence_start_date
  and assact.assignment_action_id       = rr.assignment_action_id
  and rr.element_type_id               in (g_gi_info_element_type_id,
                                           g_gi_i_r_element_type_id)
  and rr.status                        in ('P','PA')
  and epd.element_entry_id(+)           = rr.element_entry_id
  and epd.retro_component_id(+)        is not null
  and ee.element_entry_id(+)            = epd.element_entry_id
  and target.run_result_id              = rr.run_result_id
  and target.input_value_id            in (g_gi_info_net_iv_id,
                                           g_gi_i_r_net_iv_id,
                                           g_gi_info_gi_payment_iv_id,
                                           g_gi_i_r_gi_payment_iv_id,
                                           g_gi_info_adjustment_iv_id,
                                           g_gi_i_r_adjustment_iv_id,
                                           g_gi_info_ijss_gross_iv_id,
                                           g_gi_i_r_ijss_gross_iv_id,
                                           g_gi_info_end_date_iv_id,
                                           g_gi_i_r_end_date_iv_id,
                                           g_gi_info_best_method_iv_id,
                                           g_gi_i_r_best_method_iv_id)
  and target.result_value              is not null
  and parent_absence_id.run_result_id   = rr.run_result_id
  and parent_absence_id.input_value_id in (g_gi_info_absence_id_iv_id,
                                           g_gi_i_r_absence_id_iv_id)
  and parent_absence_id.result_value    = p_parent_absence_id
  and guarantee_id.run_result_id        = rr.run_result_id
  and guarantee_id.input_value_id      in (g_gi_info_guarantee_id_iv_id,
                                           g_gi_i_r_guarantee_id_iv_id)
  and guarantee_id.result_value         = p_guarantee_id
  and NOT EXISTS
       (SELECT 1
        FROM pay_payroll_actions     RPACT
        ,    pay_assignment_actions  RASSACT
        ,    pay_action_interlocks   RINTLK
        where ASSACT.assignment_action_id = RINTLK.locked_action_id
        and   RINTLK.locking_action_id = RASSACT.assignment_action_id
        and   RPACT.payroll_action_id = RASSACT.payroll_action_id
        and   RPACT.action_type = 'V' )
group by assact.action_sequence, rr.run_result_id,
         ee.creator_id,epd.adjustment_type
order by 1,6,8,9 desc;

-- previous_net, previous_payment, previous_adjustment, previous_IJSS_gross, best_method
l_previous_net number;
l_previous_payment number;
l_previous_adjustment number;
l_previous_IJSS_gross number;
l_best_method varchar2(1);

l_proc               varchar2(72) := g_package||'Get_GI_Payments_Audit';

begin
hr_utility.set_location('Entering:'|| l_proc,10);
begin
  -- fetch ids of element_type and its inputs
  if g_gi_info_element_type_id is null then
     set_global_ids(p_effective_date => p_current_date);
  END IF;

             hr_utility.set_location('Entering:'||l_proc||' g_gi_info_element_type_id:'||
                                      to_char(g_gi_info_element_type_id),10);

end;
--
begin
-- fetch the audit payments for this absence and guarantee
-- previous_net, previous_payment, previous_adjustment, previous_IJSS_gross, best_method

          for a in  get_audit(fnd_number.number_to_canonical( p_parent_absence_id),
                              fnd_number.number_to_canonical(p_gi_id),
                              p_asg.assignment_id,
                              nvl(g_absence_calc.parent_absence_start_date,
                                  to_date('01/01/0001','dd/mm/yyyy'))) loop

	       p_gi_previous_net := a.previous_net + p_gi_previous_net;
               p_gi_previous_payment := a.previous_payment + p_gi_previous_payment;
               p_gi_previous_adjustment := a.previous_adjustment + p_gi_previous_adjustment;
               p_gi_previous_ijss_gross := a.previous_ijss_gross + p_gi_previous_ijss_gross;
-- the cursor is ordered so that the last row retrieved is the one that records the last
-- best_method - in normal runs thats the last action but in the case of retros also take
-- payment date and whether its a contra result into account
               if a.best_method = 'Y' then p_gi_best_method := 'P';
                  else p_gi_best_method := '';
                  end if;
           end loop;

           hr_utility.set_location('Leaving :'|| l_proc, 90);
end;
--
hr_utility.set_location(' Leaving:'||l_proc, 70);
end get_gi_payments_audit;


PROCEDURE Band_Overlaps
(p_ov_band1_days IN OUT NOCOPY NUMBER,
 p_ov_band2_days IN OUT NOCOPY NUMBER,
 p_ov_band3_days IN OUT NOCOPY NUMBER,
 p_ov_band4_days IN OUT NOCOPY NUMBER,
 p_ov_gi_id      IN NUMBER,
 p_date_from     IN DATE,
 p_date_to       IN DATE,
 p_asg           IN      pay_fr_sick_pay_processing.t_asg)
IS

l_proc               varchar2(72) := g_package||'Band_Overlaps';
l_ov_gi_id_chr  varchar2(100) := to_char(p_ov_gi_id);
l_date_from_chr varchar2(20)  := fnd_date.date_to_canonical(p_date_from);

l_overlap_band1_days number := 0;
l_overlap_band2_days number := 0;
l_overlap_band3_days number := 0;
l_overlap_band4_days number := 0;

l_payment_end_date   date;

l_number_of_days_to_add_back number :=0;

      -- We now have the band usage from the start of the period upto the parent_absence_start_date
      -- From this we need to find if there were any overlapping absences during the start of the period            -- ( l_date_from ).
      --
      -- E.g. if the parent_absence_start_date is 15-FEB-2002 and we are using a rolling year, we go back to
      -- the 15-FEB-2001. At this point we have all the band usage between the 15-FEB-2001 and 15-FEB-2002 but
      -- but this also includes any band usage from the 10-FEB-2001 to the 15-FEB-2001 which we need to remove      -- from the band usage totals from th previous statement.


--                      15-FEB-2001                             15-FEB-2002
--         |________________|_______________________________________|
--              |--------------------|
--             10-FEB               20-FEB

--
--       The following statement will find the result id for the overlap if one exists.
--
BEGIN
      hr_utility.set_location('Entering:'|| l_proc,10);
      select /*+ORDERED*/
          fnd_date.canonical_to_date(rrv_end.result_value) payment_end_date
         ,nvl(sum(decode(target.input_value_id,
                         g_gi_info_band1_iv_id,target.result_value,
                         g_gi_i_r_band1_iv_id, target.result_value,0)),0)
         ,nvl(sum(decode(target.input_value_id,
                         g_gi_info_band2_iv_id,target.result_value,
                         g_gi_i_r_band2_iv_id, target.result_value,0)),0)
         ,nvl(sum(decode(target.input_value_id,
                         g_gi_info_band3_iv_id,target.result_value,
                         g_gi_i_r_band3_iv_id, target.result_value,0)),0)
         ,nvl(sum(decode(target.input_value_id,
                         g_gi_info_band4_iv_id,target.result_value,
                         g_gi_i_r_band4_iv_id, target.result_value,0)),0)
      INTO     l_payment_end_date
              ,l_overlap_band1_days
              ,l_overlap_band2_days
              ,l_overlap_band3_days
              ,l_overlap_band4_days
      from pay_assignment_actions  assact,
           pay_payroll_actions     pact,
           pay_run_results         rr,
           pay_run_result_values   rrv_end,
           pay_run_result_values   rrv_start,
           pay_run_result_values   rrv_guarantee,
           pay_run_result_values   target
      where assact.assignment_id           = P_asg.assignment_id
      and   assact.action_status           = 'C'
      and   assact.payroll_action_id       = pact.payroll_action_id
      and   pact.action_type              in ('R','Q','B','V')
      and   assact.assignment_action_id    = rr.assignment_action_id
      and   rr.element_type_id            in (g_gi_info_element_type_id,
                                              g_gi_i_r_element_type_id)
      and   rr.status                     in ('P','PA')
      and   rr.run_result_id               = rrv_start.run_result_id
      and   rrv_start.input_value_id      in (g_gi_info_start_date_iv_id,
                                              g_gi_i_r_start_date_iv_id )
      and   rrv_start.result_value         < l_date_from_chr
      and   rr.run_result_id               = rrv_end.run_result_id
      and   rrv_end.input_value_id        in (g_gi_info_end_date_iv_id,
                                              g_gi_i_r_end_date_iv_id)
      and   rrv_end.result_value          >= l_date_from_chr
      and   rr.run_result_id               = rrv_guarantee.run_result_id
      and   rrv_guarantee.input_value_id  in (g_gi_info_guarantee_id_iv_id,
                                              g_gi_i_r_guarantee_id_iv_id )
      and   rrv_guarantee.result_value     = l_ov_gi_id_chr
      and   target.run_result_id           = rr.run_result_id
      and   target.input_value_id         in (g_gi_info_band1_iv_id,
                                              g_gi_info_band2_iv_id,
                                              g_gi_info_band3_iv_id,
                                              g_gi_info_band4_iv_id,
                                              g_gi_i_r_band1_iv_id,
                                              g_gi_i_r_band2_iv_id,
                                              g_gi_i_r_band3_iv_id,
                                              g_gi_i_r_band4_iv_id)
      and   target.result_value           is not null
      group by fnd_date.canonical_to_date(rrv_end.result_value);

      p_ov_band1_days := p_ov_band1_days - l_overlap_band1_days;
      p_ov_band2_days := p_ov_band2_days - l_overlap_band2_days;
      p_ov_band3_days := p_ov_band3_days - l_overlap_band3_days;
      p_ov_band4_days := p_ov_band4_days - l_overlap_band4_days;

      --
      -- Now add the relevant part back in
      --
      l_number_of_days_to_add_back := (l_payment_end_date - p_date_from) + 1;
      hr_utility.trace('pymt end date = ' || l_payment_end_date || ' p_date_from = ' || p_date_from);
      hr_utility.trace('Band_Overlaps - number Of days to add back = ' || l_number_of_days_to_add_back);
      --
      -- For the overlap find which bands were used and how many days were used, starting with
      -- the highest band.
      --

      IF l_number_of_days_to_add_back <= l_overlap_band4_days THEN
         p_ov_band4_days := p_ov_band4_days + l_number_of_days_to_add_back;
         l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band4_days;
      ELSE
         p_ov_band4_days := p_ov_band4_days - l_overlap_band4_days;
         l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band4_days;
      END IF;

      IF l_number_of_days_to_add_back > 0 THEN
         IF l_number_of_days_to_add_back <= l_overlap_band3_days THEN
            p_ov_band3_days := p_ov_band3_days + l_number_of_days_to_add_back;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band3_days;
         ELSE
            p_ov_band3_days := p_ov_band3_days - l_overlap_band3_days;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band3_days;
         END IF;
      END IF;

      IF l_number_of_days_to_add_back > 0 THEN
         IF l_number_of_days_to_add_back <= l_overlap_band2_days THEN
            p_ov_band2_days := p_ov_band2_days + l_number_of_days_to_add_back;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band2_days;
         ELSE
            p_ov_band2_days := p_ov_band2_days - l_overlap_band2_days;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band2_days;
         END IF;
      END IF;

      IF l_number_of_days_to_add_back > 0 THEN
         IF l_number_of_days_to_add_back <= l_overlap_band1_days THEN
            p_ov_band1_days := p_ov_band1_days + l_number_of_days_to_add_back;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band1_days;
         ELSE
            p_ov_band1_days := p_ov_band1_days - l_overlap_band1_days;
            l_number_of_days_to_add_back := l_number_of_days_to_add_back - l_overlap_band1_days;
         END IF;
      END IF;


     hr_utility.set_location(' Leaving:'||l_proc, 70);

  Exception
     When no_data_found THEN
        hr_utility.trace (' band_overlaps  - no data found');

     when others then
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      Raise;


  END Band_Overlaps;

-----------------------------------------------------------------------
-- GET_GI_BANDS_AUDIT
-- fetch results(bands) from element FR_SICKNESS_GI_INFO for a particular
-- guarantee over the Rolling/Calendar Year
-- Uses Band_overlaps from above
-----------------------------------------------------------------------
PROCEDURE Get_GI_Bands_Audit
        (p_GI_id                IN      Number,
         p_asg                  IN      pay_fr_sick_pay_processing.t_asg,
         p_date_to              IN      Date,
         p_band_expiry_duration IN      Varchar2,
         p_band1_days    OUT NOCOPY Number,
         p_band2_days    OUT NOCOPY Number,
         p_band3_days    OUT NOCOPY Number,
         p_band4_days    OUT NOCOPY Number) IS

  cursor csr_get_band_usage(p_gi_id_chr     varchar2,
                            p_date_from_chr varchar2,
                            p_date_to_chr   varchar2) is
  -- No need to explicitly convert these fetched result values to number as
  -- they are integer values
  select /*+ ORDERED */
    nvl(sum(decode(target.input_value_id,
                   g_gi_info_band1_iv_id,target.result_value,
                   g_gi_i_r_band1_iv_id, target.result_value,0)),0)
   ,nvl(sum(decode(target.input_value_id,
                   g_gi_info_band2_iv_id,target.result_value,
                   g_gi_i_r_band2_iv_id, target.result_value,0)),0)
   ,nvl(sum(decode(target.input_value_id,
                   g_gi_info_band3_iv_id,target.result_value,
                   g_gi_i_r_band3_iv_id, target.result_value,0)),0)
   ,nvl(sum(decode(target.input_value_id,
                   g_gi_info_band4_iv_id,target.result_value,
                   g_gi_i_r_band4_iv_id, target.result_value,0)),0)
  from  pay_assignment_actions  assact
       ,pay_payroll_actions     pact
       ,pay_run_results         rr
       ,pay_run_result_values   guarantee_id
       ,pay_run_result_values   payment_date
       ,pay_run_result_values   target
  where assact.assignment_id = p_asg.assignment_id
  and assact.payroll_action_id = pact.payroll_action_id
  and pact.action_type in ('R', 'Q', 'V', 'B')
  and assact.assignment_action_id = rr.assignment_action_id
  and rr.element_type_id in (g_gi_info_element_type_id,
                             g_gi_i_r_element_type_id)
  and rr.run_result_id   =  target.run_result_id
  and rr.status in ('P','PA')
  and target.result_value is not null
  and target.input_value_id in (g_gi_info_band1_iv_id,
                                g_gi_info_band2_iv_id,
                                g_gi_info_band3_iv_id,
                                g_gi_info_band4_iv_id,
                                g_gi_i_r_band1_iv_id,
                                g_gi_i_r_band2_iv_id,
                                g_gi_i_r_band3_iv_id,
                                g_gi_i_r_band4_iv_id)
  and rr.run_result_id = guarantee_id.run_result_id
  and guarantee_id.input_value_id in (g_gi_info_guarantee_id_iv_id,
                                      g_gi_i_r_guarantee_id_iv_id)
  and guarantee_id.result_value = p_gi_id_chr
  and rr.run_result_id = payment_date.run_result_id
  and payment_date.input_value_id in (g_gi_info_end_date_iv_id,
                                      g_gi_i_r_end_date_iv_id)
  and payment_date.result_value between p_date_from_chr and p_date_to_chr;
--
l_date_from date;
l_date_to   date;
l_total_band1_days number := 0;
l_total_band2_days number := 0;
l_total_band3_days number := 0;
l_total_band4_days number := 0;
l_id               number;
l_from_dt_id       number;

l_proc               varchar2(72) := g_package||'Get_GI_Bands_Audit';

--

BEGIN

  hr_utility.set_location('Entering:'|| l_proc,10);

  -- If p_band_expiry_duration = 'Y' (rolling year) then go back to the
  -- equivalent day last year + 1 day, the date to becomes the parent absence
  -- start date - 1 day
  -- Else
  -- set the l_date_from = the first day of the current year
  --   go back to the start of the current year. The date to is the same.

     IF p_band_expiry_duration = 'RY' THEN
        l_date_from := add_months(g_absence_calc.parent_absence_start_date,-12);  -- add_months(p_date_to,-12);
        l_date_to   := p_date_to - 1;
     ELSE
        l_date_from := trunc(p_date_to,'YYYY');
        l_date_to   := p_date_to - 1;
     END IF;


  if g_gi_info_element_type_id is null then
    set_global_ids(p_effective_date => l_date_to);
  end if;
  -- Now get the Band usage over the period
  open csr_get_band_usage(fnd_number.number_to_canonical(p_gi_id),
                          fnd_date.date_to_canonical(l_date_from),
                          fnd_date.date_to_canonical(l_date_to));
  fetch csr_get_band_usage into
          l_total_band1_days
         ,l_total_band2_days
         ,l_total_band3_days
         ,l_total_band4_days;
  close csr_get_band_usage;

  -- Check for any overlap days if there has been any band usage over the year
      IF  l_total_band1_days <> 0
      OR  l_total_band2_days <> 0
      OR  l_total_band3_days <> 0
      OR  l_total_band4_days <> 0 THEN
          Band_Overlaps( p_ov_band1_days => l_total_band1_days,
                         p_ov_band2_days => l_total_band2_days,
                         p_ov_band3_days => l_total_band3_days,
                         p_ov_band4_days => l_total_band4_days,
                         p_ov_gi_id      => p_gi_id,
                         p_date_from     => l_date_from,
                         p_date_to       => l_date_to,
                         p_asg           => p_asg );
      ELSE
        p_band1_days := 0;
        p_band2_days := 0;
        p_band3_days := 0;
        p_band4_days := 0;
      END IF;

      -- assign out variables
      p_band1_days := l_total_band1_days;
      p_band2_days := l_total_band2_days;
      p_band3_days := l_total_band3_days;
      p_band4_days := l_total_band4_days;

      hr_utility.set_location(' Leaving:'||l_proc, 70);

      exception when no_data_found THEN  -- return zeros as no band usage
         hr_utility.trace ('get_gi_bands_audit - no band usage');
         p_band1_days := 0;
         p_band2_days := 0;
         p_band3_days := 0;
         p_band4_days := 0;

     when others then
      hr_utility.set_location('get_gi_bands audit',20);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      Raise;

END Get_GI_Bands_Audit;
--

-- ----------------------------------------------------------------------
-- Common internal function to use up bands and calculate payments for GI
-- Output is broken down by band and written to l_bands pl/sql table
--
PROCEDURE Use_GI_Bands(p_band_name              IN      NUMBER,
                       p_band_avail_days        IN      NUMBER,
                       p_band_prcnt             IN      NUMBER,
                       p_GI_ref_sal             IN      NUMBER,
                       p_band_start_date        IN OUT NOCOPY   DATE,
                       p_for_days               IN OUT NOCOPY NUMBER) IS
--
  l_proc                varchar2(72) := g_package||'Use_GI_bands';

  l_band_curr_days      PLS_INTEGER;
  l_band_idx            PLS_INTEGER     := p_band_name;
  l_band_rate           NUMBER;
--
BEGIN
  hr_utility.set_location(' Entering:'||l_proc, 10);

  IF (p_for_days >= p_band_avail_days) THEN
    l_band_curr_days    := p_band_avail_days ;
    p_for_days          := p_for_days - l_band_curr_days;
  ELSE
    l_band_curr_days    := p_for_days;
    p_for_days          := p_for_days - l_band_curr_days; -- 0
  END IF;

  l_band_rate           := p_GI_ref_sal * (p_band_prcnt/100);

  IF (nvl(l_band_rate,0) > 0) THEN
    -- Write to pl-sql table l_bands
    l_bands(l_band_idx).band_rate       := l_band_rate;
    l_bands(l_band_idx).band_payment    := l_band_rate * l_band_curr_days;
    l_bands(l_band_idx).band_from_dt    := p_band_start_date;
    l_bands(l_band_idx).band_to_dt      := p_band_start_date + (l_band_curr_days - 1);
    l_bands(l_band_idx).band_days       := l_band_curr_days;

    hr_utility.set_location('  Populating l_Bands for current GI for band:'||l_band_idx, 11) ;
    hr_utility.set_location('   l_Bands rate   :'||l_bands(l_band_idx).band_rate, 11) ;
    hr_utility.set_location('   l_Bands days   :'||l_bands(l_band_idx).band_days, 11) ;
    hr_utility.set_location('   l_Bands payment:'||l_bands(l_band_idx).band_payment, 11) ;
    hr_utility.set_location('   l_Bands from   :'||l_bands(l_band_idx).band_from_dt, 11) ;
    hr_utility.set_location('   l_Bands to     :'||l_bands(l_band_idx).band_to_dt, 11) ;



  END IF;
  -- Absence date moved on for lower Band utilisations
  p_band_start_date     := p_band_start_date + l_band_curr_days;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
END Use_GI_bands;
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Common internal function to get daily rate divisor for GI balances
-- Use this function to incorporate 'Unpaid days' logic at a later time
--
FUNCTION Get_GI_ref_salary_divisor(
        p_start_date    IN      DATE,
        p_end_date      IN      DATE)
RETURN NUMBER IS

l_proc  varchar2(72) := g_package||'Get_GI_ref_sal_divisor';
l_days  NUMBER;

BEGIN
  hr_utility.set_location(' Entering:'||l_proc, 10);
  --
  IF p_start_date IS NOT NULL
    AND p_end_date IS NOT NULL
    AND (p_end_date >= p_start_date) THEN
    l_days := (p_end_date - p_start_date) + 1;
  ELSE
    l_days := 0;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  RETURN l_days;
END;

--------------********************--------------
-- CALC_LEGAL_GI
-- Calculate Legal Guaranteed Income
PROCEDURE Calc_LEGAL_GI(
   p_asg                IN pay_fr_sick_pay_processing.t_asg,
   p_coverages          IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages,
   p_absence_arch       IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch ) IS

--
l_assgt_id              NUMBER          := p_asg.assignment_id;
l_business_group_id     NUMBER          := p_asg.business_group_id;
l_gi_start_date         DATE            := g_absence_calc.IJSS_payment_start_date;
l_gi_end_date           DATE            := g_absence_calc.IJSS_payment_end_date;
l_parent_absence_id     NUMBER          := g_absence_calc.parent_absence_id;
l_work_incident_type    VARCHAR2(30)    := g_absence_calc.work_incident;
l_abs_duration          NUMBER          := g_absence_calc.prior_linked_absence_duration;
l_parent_absence_start_date             DATE := g_absence_calc.parent_absence_start_date;
l_svc_in_years          NUMBER(9,4);


l_legi_id               Number          :=-9999;
l_legi_code             PLS_Integer;

l_waiting_days          PLS_Integer     :=0;
l_curr_waiting_days     PLS_Integer     :=0;

l_B1_days               PLS_Integer     :=0;
l_B2_days               PLS_Integer     :=0;
l_B1_rate               NUMBER  :=0;
l_B2_rate               NUMBER  :=0;
l_B1_prcnt              NUMBER  :=0;
l_B2_prcnt              NUMBER  :=0;


l_B1_used_days          PLS_Integer     :=0;
l_B2_used_days          PLS_Integer     :=0;
l_B1_avail_days         PLS_Integer     :=0;
l_B2_avail_days         PLS_Integer     :=0;
l_B3_used_days          PLS_Integer     :=0;
l_B4_used_days          PLS_Integer     :=0;

l_for_days              PLS_Integer     :=0;

l_idx                   PLS_Integer;

l_GI_previous_net               NUMBER;
l_GI_previous_payment           NUMBER;
l_GI_previous_adjustment        NUMBER;
l_GI_previous_IJSS_gross        NUMBER;
l_GI_best_method                VARCHAR2(1);

l_ref_sal_divisor       NUMBER;
l_LEGI_ref_sal          NUMBER;
l_LEGI_daily_ref_sal    NUMBER;

l_IJSS_gross_from_date  DATE;
l_IJSS_gross_to_date    DATE;


l_proc               varchar2(72) := g_package||'Calc_LEGAL_GI';

BEGIN

   hr_utility.set_location('Entering:'|| l_proc,10);
   hr_utility.set_location('Entering:'|| l_proc || l_gi_start_date,10);
   hr_utility.set_location('Entering:'|| l_proc|| l_gi_end_date,10);

   -- Get Service period(in years) of the person
   BEGIN
     SELECT TRUNC((MONTHS_BETWEEN(paa.date_start,
                                  decode(ps.adjusted_svc_date,NULL, ps.date_start, ps.adjusted_svc_date)
                                 )/12), 4)
            --paa.date_start
      INTO l_svc_in_years
           --l_parent_absence_start_date
     FROM per_absence_attendances paa,
          per_periods_of_service ps,
          per_all_assignments_f pas
     WHERE ps.person_id                 = pas.person_id
      AND  pas.assignment_id            = l_assgt_id
      AND  paa.absence_attendance_id    = l_parent_absence_id
      AND  paa.person_id                = pas.person_id
      AND  l_parent_absence_start_date between pas.effective_start_date and pas.effective_end_date ;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_svc_in_years := 0;
   END;

   -- Waiting days check
   l_waiting_days := hruserdt.get_table_value(l_business_group_id,
                        'FR_LEGI_WAITING_DAYS',
                        'DAYS_DELAY',
                        l_work_incident_type,
                        l_parent_absence_start_date);

   hr_utility.set_location(' IN '|| l_proc ||' and previous duration '||l_abs_duration,20);
   hr_utility.set_location('   and waiting days='||l_waiting_days,20);
   -- Any waiting days still to be used
   l_curr_waiting_days  := l_waiting_days - l_abs_duration;
   IF l_curr_waiting_days <= 0 THEN     -- Absence duration has exhausted waiting days
     l_curr_waiting_days:= 0;
   ELSE
     -- Modify start_date for calculating LEGI
     l_gi_start_date    := l_gi_start_date + l_curr_waiting_days;
   END IF;

   -- Get Bands information from Range UDT
   l_B1_days := hruserdt.get_table_value(l_business_group_id,
                         'FR_LEGI_RATE_BANDS',
                         'DAYS_AT_HIGH_RATE',
                         l_svc_in_years,
                         l_parent_absence_start_date);

   l_B2_days := hruserdt.get_table_value(l_business_group_id,
                         'FR_LEGI_RATE_BANDS',
                         'DAYS_AT_LOW_RATE',
                         l_svc_in_years,
                         l_parent_absence_start_date);

   l_B1_prcnt := hruserdt.get_table_value(l_business_group_id,
                         'FR_LEGI_RATE_BANDS',
                         'HIGH_RATE(%)',
                         l_svc_in_years,
                         l_parent_absence_start_date);

   l_B2_prcnt := hruserdt.get_table_value(l_business_group_id,
                         'FR_LEGI_RATE_BANDS',
                         'LOW_RATE(%)',
                         l_svc_in_years,
                         l_parent_absence_start_date);

   --
   -- Get Bands used over the Rolling year
   --
   Get_GI_Bands_Audit
        (p_GI_id                => l_legi_id,
         p_asg                  => p_asg,
         p_date_to              => l_gi_start_date,
         p_band_expiry_duration => 'RY',
         p_band1_days           => l_B1_used_days,
         p_band2_days           => l_B2_used_days,
         p_band3_days           => l_B3_used_days,
         p_band4_days           => l_B4_used_days);

   --
   -- Get Previous payments made for the absence under LEGI
   --
   Get_GI_Payments_Audit
   (p_GI_id                     => l_legi_id,
    p_asg                       => p_asg,
    p_parent_absence_id         => l_parent_absence_id,
    p_Current_date              => l_gi_start_date,
    p_GI_Previous_Net           => l_GI_previous_net,
    p_GI_Previous_Payment       => l_GI_previous_payment,
    p_GI_Previous_Adjustment    => l_GI_previous_adjustment,
    p_GI_Previous_IJSS_Gross    => l_GI_previous_IJSS_gross,
    p_GI_Best_Method            => l_GI_best_method);

   -- Get index for g_coverages table
   l_idx := nvl(p_coverages.LAST, 0) + 1;

   -- Get numeric code for the Guarantee type from global table g_guarantee_lookup_types in the PAY_FR_SICK_PAY_PROCESSING package
   -- This should use a common function for both LEGI and CAGR
   -- For LEGI, the code returned would have a value of 20
   l_legi_code  := PAY_FR_SICK_PAY_PROCESSING.Get_guarantee_id('LE');

   -- Only if values are not null, should a row be populated in g_coverages for the current GI
   IF nvl(l_GI_previous_net,0) > 0
   OR nvl(l_GI_previous_payment,0)  > 0
   OR nvl(l_GI_previous_Adjustment,0)  > 0
   OR nvl(l_GI_previous_IJSS_Gross,0)  > 0
   OR l_GI_Best_method IS NOT NULL THEN
      p_coverages(l_idx).cagr_id                := l_legi_id;
      p_coverages(l_idx).g_type                 := l_legi_code;

      p_coverages(l_idx).previous_net           := l_GI_previous_net;
      p_coverages(l_idx).previous_gi_payment    := l_GI_previous_payment;
      p_coverages(l_idx).previous_sick_adj      := l_GI_previous_adjustment;
      p_coverages(l_idx).previous_IJSS_Gross    := l_GI_previous_IJSS_Gross;
      p_coverages(l_idx).best_method            := l_GI_best_method;

   END IF;

   -- Calculate available days
   L_B1_avail_days := l_B1_days - l_B1_used_days;
   L_B2_avail_days := l_B2_days - l_B2_used_days;

   -- Calculate Daily Ref Salary for LEGI
   -- A global held in Pay_fr_sick_pay_processing p_asg.lg_ref_salary holds the Balance value
   -- 'FR_SICKNESS_LEGAL_GUARANTEE_REFERENCE_SALARY_ASG_PRO_RUN'
   -- and proration dates p_asg.action_start_date and p_asg.action_end_date
   -- Raising an error if the reference salary is null
   l_LEGI_ref_sal       := p_asg.lg_ref_salary;

   IF l_LEGI_ref_sal IS NULL THEN
     fnd_message.set_name ('PAY', 'PAY_75039_LEGI_NULL_REF_SALARY');
     fnd_message.raise_error;
   END IF;

   -- Added condition for CPAM processing
   IF g_absence_calc.initiator = 'CPAM' THEN
      l_ref_sal_divisor := Get_GI_ref_salary_divisor(
                           p_start_date    => g_absence_calc.abs_ptd_start_date,
                           p_end_date      => g_absence_calc.abs_ptd_end_date);
   ELSE
      l_ref_sal_divisor := Get_GI_ref_salary_divisor(
                           p_start_date    => p_asg.action_start_date,
                           p_end_date      => p_asg.action_end_date);
   END IF;
   --

   l_LEGI_daily_ref_sal := l_LEGI_ref_sal/l_ref_sal_divisor;


   -- Calculate LEGI payments for the current absence days passed
   --
   l_for_days   := l_gi_end_date - l_gi_start_date + 1;

   -- LEGI has 2 Bands, use if available and if needed
   IF (l_B1_avail_days > 0) AND (l_for_days >0) THEN
     Use_GI_Bands(p_band_name           => 1,
                  p_band_avail_days     => l_B1_avail_days,
                  p_band_prcnt          => l_B1_prcnt,
                  p_GI_ref_sal          => l_LEGI_daily_ref_sal,
                  p_band_start_date     => l_gi_start_date,
                  p_for_days            => l_for_days);
   END IF;
   IF (l_B2_avail_days > 0) AND (l_for_days >0) THEN
     Use_GI_Bands(p_band_name           => 2,
                  p_band_avail_days     => l_B2_avail_days,
                  p_band_prcnt          => l_B2_prcnt,
                  p_GI_ref_sal          => l_LEGI_daily_ref_sal,
                  p_band_start_date     => l_gi_start_date,
                  p_for_days            => l_for_days);
   END IF;

   -- Populating g_coverages with the band values from l_bands
   IF l_bands.COUNT > 0 THEN
     p_coverages(l_idx).cagr_id         := l_legi_id;
     p_coverages(l_idx).g_type          := l_legi_code;

     FOR i IN l_bands.FIRST..l_bands.LAST              -- i contains Band Numbers(index of l_bands)
     LOOP
       --l_first_band := l_bands.FIRST;
       IF l_IJSS_gross_from_date IS NULL THEN   -- Only for 1st row in l_bands
         l_IJSS_gross_from_date          := l_bands(i).band_from_dt;
         p_coverages(l_idx).gi_from_date1:= l_bands(i).band_from_dt;
       END IF;

       l_IJSS_gross_to_date               := l_bands(i).band_to_dt;

       IF (i = l_bands.FIRST) THEN
         p_coverages(l_idx).gi_to_date1  := l_bands(i).band_to_dt;
         p_coverages(l_idx).gi_payment1  := l_bands(i).band_payment;
         p_coverages(l_idx).gi_rate1     := l_bands(i).band_rate;
         p_coverages(l_idx).gi_days1     := l_bands(i).band_days;
       ELSE
         p_coverages(l_idx).gi_from_date2:= l_bands(i).band_from_dt;
         p_coverages(l_idx).gi_to_date2  := l_bands(i).band_to_dt;
         p_coverages(l_idx).gi_payment2  := l_bands(i).band_payment;
         p_coverages(l_idx).gi_rate2     := l_bands(i).band_rate;
         p_coverages(l_idx).gi_days2     := l_bands(i).band_days;
       END IF;

       IF i = 1 THEN
         p_coverages(l_idx).band1       := l_bands(i).band_days;
       ELSIF i = 2 THEN
         p_coverages(l_idx).band2       := l_bands(i).band_days;
       END IF;

     END LOOP;
   END IF;      -- l_bands.COUNT check

   l_bands.DELETE;  -- Clearing the l_bands table of the current GI rows

   -- Populating IJSS_Gross values in G_coverages for LEGI overlap days
   IF (l_IJSS_gross_from_date IS NOT NULL)
    AND (l_IJSS_gross_to_date IS NOT NULL) THEN
      Calc_IJSS_Gross(p_IJSS_Gross_Start_Date   =>  l_IJSS_gross_from_date
                     ,p_IJSS_Gross_End_Date     =>  l_IJSS_gross_to_date
                     ,p_coverage_idx            =>  l_idx
                     ,p_coverages               =>  p_coverages
                     ,p_absence_arch            =>  p_absence_arch);
   END IF;

hr_utility.set_location(' Leaving:'||l_proc, 70);

EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('calc_legal_GI',100);
   hr_utility.trace(SQLCODE);
   hr_utility.trace(SQLERRM);
   Raise;

END Calc_LEGAL_GI;


-----------------------------------------------------------------------
-- Function Get_CAGR_reference_salary
-- function to return balance value
----------------------------------------------------------------------
Function Get_CAGR_reference_salary (
                             p_balance_name in varchar2,
                             p_gi_type in varchar2,
                             p_asg in pay_fr_sick_pay_processing.t_asg) return number
IS
Cursor csr_def_bal_id IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types_tl pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
   WHERE  pdb.balance_type_id = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
   AND    pbt.balance_name = p_balance_name
   AND    pbd.dimension_name = 'Assignment Proration Run To Date'
   AND    (( pdb.legislation_code = 'FR') or
           (pdb.business_group_id = p_asg.business_group_id));
--
l_defined_balance_id number;
l_value number;
l_proc               varchar2(72) := g_package||'get_ref_sal';

BEGIN
-- for Net guarantee ref_sal is FR_SICKNESS_TARGET_NET_ASG_PRO_RUN
-- this is fetched in FR_SICKNESS_CONTROL and passed to p_asg.base_net
-- for Gross guarantee ref_sal is part of the terms of the guarantee
-- recorded on element FR_SICK_BENEFIT.balance_name. The ASG_PRO_RUN
-- dimension of this balance is calculated for the current action.
-- a daily rate is found by deviding by the number of days in the run
-- proration period ( or full period if not prorated ).

   hr_utility.set_location('Entering:'|| l_proc,10);

   if p_gi_type in ('CA_N','GN') then -- { net guarantee
      l_value := p_asg.base_net;

   else -- gross guarantee

     hr_utility.set_location(' Entering:'|| l_proc,20);
     begin
       open csr_def_bal_id;
       fetch csr_def_bal_id into l_defined_balance_id;
         if csr_def_bal_id%notfound THEN
            hr_utility.trace('Defined balance not found:' || p_balance_name||'_ASG_PRO_RUN');
                hr_utility.set_message (801, 'PAY_75042_DEF_BAL_MISSING');
                hr_utility.set_message_token('BALANCE_NAME',p_balance_name);
                hr_utility.raise_error;
         end if;
       close csr_def_bal_id;
     end;
     --
     hr_utility.set_location(' Entering:'|| l_proc,30);
     -- Added condition for CPAM processing
     IF g_absence_calc.initiator = 'CPAM' THEN
        l_value := pay_balance_pkg.get_value
                         (l_defined_balance_id
                         ,p_asg.assignment_id
                         ,g_absence_calc.abs_ptd_end_date);
     ELSE
        l_value := pay_balance_pkg.get_value
                         (l_defined_balance_id
                          ,p_asg.assignment_action_id);
     END IF;
     --
     hr_utility.trace('cagr_balance_value:'||to_char(l_value));

   end if; -- }
   -- balance is fr prorated period, divide by number of days in prorated period
   -- to get daily rate
   hr_utility.set_location(' starting:'||l_proc, 40);

   -- Added condition for CPAM processing
   IF g_absence_calc.initiator = 'CPAM' THEN
       l_value := l_value / Get_GI_ref_salary_divisor(
                                 p_start_date  =>g_absence_calc.abs_ptd_start_date,
                                 p_end_date    =>g_absence_calc.abs_ptd_end_date);
   ELSE
       l_value := l_value / Get_GI_ref_salary_divisor(
                                 p_start_date    => p_asg.action_start_date,
                                 p_end_date      => p_asg.action_end_date);
   END IF;
   --
   hr_utility.set_location('Leaving:'||l_proc, 70);

   return l_value;

END Get_CAGR_reference_salary;
-----------------------------------------------------------------------

--------------********************--------------
-- CALC_CAGR_GI
-- Calculate Legal Guaranteed Income

PROCEDURE Calc_CAGR_GI
   (p_asg               IN pay_fr_sick_pay_processing.t_asg
   ,p_coverages         IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages
   ,p_absence_arch      IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch) is

--
l_proc                  varchar2(72)    := g_package||'calc_cagr_gi';

l_assgt_id              NUMBER          := p_asg.assignment_id;
l_business_group_id     NUMBER          := p_asg.business_group_id;
l_gi_start_date         DATE            ;  -- Dates set internally to ensure proper input for each GI
l_gi_end_date           DATE            ;
l_parent_absence_id     NUMBER          := g_absence_calc.parent_absence_id;
l_abs_duration          NUMBER          := g_absence_calc.prior_linked_absence_duration;
l_parent_absence_start_date             DATE := g_absence_calc.parent_absence_start_date;

l_gi_id                 NUMBER;
l_gi_code               PLS_Integer;

l_curr_waiting_days     PLS_Integer     :=0;

l_B1_used_days          PLS_Integer     :=0;
l_B2_used_days          PLS_Integer     :=0;
l_B3_used_days          PLS_Integer     :=0;
l_B4_used_days          PLS_Integer     :=0;

l_B1_avail_days         PLS_Integer     :=0;
l_B2_avail_days         PLS_Integer     :=0;
l_B3_avail_days         PLS_Integer     :=0;
l_B4_avail_days         PLS_Integer     :=0;

l_for_days              PLS_Integer     :=0;
l_present_days          PLS_Integer     :=0;

l_idx                   PLS_Integer;
l_GI_previous_net               NUMBER;
l_GI_previous_payment           NUMBER;
l_GI_previous_adjustment        NUMBER;
l_GI_previous_IJSS_gross        NUMBER;
l_GI_best_method                VARCHAR2(1);

l_CAGR_daily_ref_sal    NUMBER;

l_IJSS_gross_from_date  DATE;
l_IJSS_gross_to_date    DATE;

l_net                   NUMBER  :=0;
l_min_net               NUMBER  :=0;

cursor get_ben (p_assignment_id number,
                --p_absence_id number,
                --p_parent_absence_id number,
                p_effective_date date ) IS
-- fetch FR_SICK_BENEFIT element entries that are relate to this absence as of the end
-- date of the absence
        select ENT.element_entry_id
               ,fnd_number.canonical_to_number(G.screen_entry_value) guarantee_id
               ,max(decode(ENT_PT.input_value_id,g_ben_guarantee_type_iv_id,ENT_PT.screen_entry_value,null)) guarantee_type
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_waiting_days_iv_id,ENT_PT.screen_entry_value,null))) waiting_days
               ,max(decode(ENT_PT.input_value_id,g_ben_duration_iv_id,ENT_PT.screen_entry_value,null)) duration
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band1_iv_id,ENT_PT.screen_entry_value,null))) band1
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band1_rate_iv_id,ENT_PT.screen_entry_value,null))) b1_rate
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band2_iv_id,ENT_PT.screen_entry_value,null))) band2
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band2_rate_iv_id,ENT_PT.screen_entry_value,null))) b2_rate
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band3_iv_id,ENT_PT.screen_entry_value,null))) band3
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band3_rate_iv_id,ENT_PT.screen_entry_value,null))) b3_rate
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band4_iv_id,ENT_PT.screen_entry_value,null))) band4
               ,fnd_number.canonical_to_number(max(decode(ENT_PT.input_value_id,g_ben_band4_rate_iv_id,ENT_PT.screen_entry_value,null))) b4_rate
               ,max(decode(ENT_PT.input_value_id,g_ben_balance_iv_id,ENT_PT.screen_entry_value,null)) balance
                from   pay_element_entry_values_f       ENT_PT
                      ,pay_element_entry_values_f       G
                      ,pay_element_entries_f            ENT
                      ,pay_element_links_f              EL
                where ENT_PT.element_entry_id = ENT.element_entry_id
                and   G.element_entry_id = ENT.element_entry_id
                and   G.input_value_id = g_ben_guarantee_id_iv_id
                and   ENT.assignment_id = p_assignment_id
                and   EL.element_type_id = g_ben_element_type_id
                and   EL.element_link_id = ENT.element_link_id
                and   p_effective_date between
                        EL.effective_start_date and EL.effective_end_date
                and   p_effective_date between
                        ENT.effective_start_date and ENT.effective_end_date
                and   ENT.effective_start_date = ENT_PT.effective_start_date
                and   ENT.effective_end_date = ENT_PT.effective_end_date
                and   ENT.effective_start_date = G.effective_start_date
                and   ENT.effective_end_date = G.effective_end_date
                group by fnd_number.canonical_to_number(G.screen_entry_value), ENT.element_entry_id
                order by 2,1;

l_guarantee_id          number;
l_effective_end_date    date;


BEGIN
  hr_utility.set_location('Entering:'|| l_proc,10);

  BEGIN

    -- fetch ids of element_type and its inputs
    IF g_ben_element_type_id is null then
    hr_utility.set_location(' Entering:'|| l_proc,20);
        select max(e.element_type_id)
              ,max(decode(i.name,'Absence ID',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee ID',i.input_value_id,null))
              ,max(decode(i.name,'Guarantee Type',i.input_value_id,null))
              ,max(decode(i.name,'Waiting Days',i.input_value_id,null))
              ,max(decode(i.name,'Band Expiry Duration',i.input_value_id,null))
              ,max(decode(i.name,'Band1',i.input_value_id,null))
              ,max(decode(i.name,'Band1 Rate',i.input_value_id,null))
              ,max(decode(i.name,'Band2',i.input_value_id,null))
              ,max(decode(i.name,'Band2 Rate',i.input_value_id,null))
              ,max(decode(i.name,'Band3',i.input_value_id,null))
              ,max(decode(i.name,'Band3 Rate',i.input_value_id,null))
              ,max(decode(i.name,'Band4',i.input_value_id,null))
              ,max(decode(i.name,'Band4 Rate',i.input_value_id,null))
              ,max(decode(i.name,'Balance Name',i.input_value_id,null))
             into    g_ben_element_type_id
              ,g_ben_absence_id_iv_id
              ,g_ben_guarantee_id_iv_id
              ,g_ben_guarantee_type_iv_id
              ,g_ben_waiting_days_iv_id
              ,g_ben_duration_iv_id
              ,g_ben_band1_iv_id
              ,g_ben_band1_rate_iv_id
              ,g_ben_band2_iv_id
              ,g_ben_band2_rate_iv_id
              ,g_ben_band3_iv_id
              ,g_ben_band3_rate_iv_id
              ,g_ben_band4_iv_id
              ,g_ben_band4_rate_iv_id
              ,g_ben_balance_iv_id
             from pay_element_types_f e,
                  pay_input_values_f i
             where e.element_name = 'FR_SICK_BENEFIT'
             and e.legislation_code = 'FR'
             and e.element_type_id = i.element_type_id
             and g_absence_calc.IJSS_payment_start_date between e.effective_start_date and e.effective_end_date
             and g_absence_calc.IJSS_payment_start_date between i.effective_start_date and i.effective_end_date;
    hr_utility.set_location(' Entering:'|| l_proc ||' g_ben_absence_id_iv_id '||g_ben_absence_id_iv_id,25);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Exception in '||l_proc,10);
       hr_utility.trace(SQLCODE);
       hr_utility.trace(SQLERRM);
       Raise;

  END;
  -----------------------------------------------------------------------------
  -- fetch Sickness Benefit element entries that are for this absence
  -- for child absences 2 posibilities exist: all benefits can be recorded
  -- against that child absence for the duration of the child absence or
  -- all benefits can be recorded against the parent for the duration of
  -- all the linked absences.

  BEGIN

  hr_utility.set_location(' Entering:'|| l_proc,30);
  l_guarantee_id := 0;
  l_effective_end_date := g_absence_calc.IJSS_payment_end_date; --g_absence_calc.effective_end_date;

  hr_utility.trace('  Ensuring parameters populated for getting CAGR terms');
  hr_utility.trace('  p_asg.assignment_id:'||to_char(p_asg.assignment_id));
  hr_utility.trace('  p_absence_arch.ID:'||to_char(p_absence_arch.ID));
  hr_utility.trace('  l_parent_absence_id:'||to_char(l_parent_absence_id));
  hr_utility.trace('  l_effective_end_date:'||to_char(l_effective_end_date));

  -- Absence ids removed as not used within the cursor, bug #2647436
  FOR l_ben in get_ben(   p_asg.assignment_id,
                                  l_effective_end_date)
  LOOP
    hr_utility.set_location(' Entering:'|| l_proc,35);
    -- check if this guarantee has already been processed if so do nothing
    -- (the element is defined a multiple entries allowed but there shouldn't
    -- be more than 1 entry for the same guarantee so ignore the duplicate )

    IF l_guarantee_id <> l_ben.guarantee_id THEN --  {process
       l_guarantee_id := l_ben.guarantee_id;

       hr_utility.set_location('  IN:'|| l_proc,40);


       -- Setting input dates for GI to be calculated for each GI
       l_gi_start_date          := g_absence_calc.IJSS_payment_start_date;
       l_gi_end_date            := g_absence_calc.IJSS_payment_end_date;

       hr_utility.set_location('  Initial GI_START:'|| l_gi_start_date,40);
       hr_utility.set_location('  IN '|| l_proc ||' and previous duration='||l_abs_duration,40);
       hr_utility.set_location('   and waiting days='||l_ben.waiting_days,40);
       -- Check for waiting days
       l_curr_waiting_days      := nvl(l_ben.waiting_days,0) - l_abs_duration;
       IF l_curr_waiting_days <= 0 THEN         -- Absence duration has exhausted waiting days
         l_curr_waiting_days:= 0;
       ELSE
         -- Modify start_date for calculating GI
         l_gi_start_date        := l_gi_start_date + l_curr_waiting_days;
       END IF;

       hr_utility.set_location('  Modified GI_START:'|| l_gi_start_date,40);
       hr_utility.set_location('  GI_END           :'|| l_gi_end_date,40);
       --
       -- Get Bands used over the Rolling year
       --
       Get_GI_Bands_Audit
                (p_GI_id                => l_ben.guarantee_id,
                 p_asg                  => p_asg,
                 p_date_to              => l_gi_start_date, -- Rolling year starts from actual GI date being processed
                 p_band_expiry_duration => l_ben.duration,
                 p_band1_days           => l_B1_used_days,
                 p_band2_days           => l_B2_used_days,
                 p_band3_days           => l_B3_used_days,
                 p_band4_days           => l_B4_used_days);

       --
       -- Get Previous payments made for the absence under LEGI
       --
       Get_GI_Payments_Audit
                (p_GI_id                        => l_ben.guarantee_id,
                 p_asg                          => p_asg,
                 p_parent_absence_id            => l_parent_absence_id,
                 p_Current_date                 => l_gi_start_date,
                 p_GI_Previous_Net              => l_GI_previous_net,
                 p_GI_Previous_Payment          => l_GI_previous_payment,
                 p_GI_Previous_Adjustment       => l_GI_previous_adjustment,
                 p_GI_Previous_IJSS_Gross       => l_GI_previous_IJSS_gross,
                 p_GI_Best_Method               => l_GI_best_method);

            -- Get index for g_coverages table
            l_idx := nvl(p_coverages.LAST, 0) + 1;

       hr_utility.set_location('  IN:'|| l_proc,45);
       --
       -- Get numeric code for the Guarantee type from global table g_guarantee_lookup_types
       -- in the PAY_FR_SICK_PAY_PROCESSING package.
       -- Using a common function for both LEGI and CAGR

       l_gi_code        := PAY_FR_SICK_PAY_PROCESSING.Get_guarantee_id(l_ben.guarantee_type);

      -- Get Daily Reference Salary for guarantee
       l_CAGR_daily_ref_sal := Get_CAGR_reference_salary(
                                        p_balance_name  => l_ben.balance,
                                        p_gi_type       => l_ben.guarantee_type,
                                        p_asg           => p_asg);

       hr_utility.set_location('  IN:'|| l_proc,50);

       -- Calculate GI payments for the current absence days passed
       --
       l_for_days       := l_gi_end_date - l_gi_start_date + 1;

       -- Setting Net for days the person was actually present
     IF g_absence_calc.initiator = 'CPAM' THEN

        l_present_days   := nvl(( (p_absence_arch.sick_deduct_start_date - g_absence_calc.abs_ptd_start_date) + (g_absence_calc.abs_ptd_end_date - p_absence_arch.sick_deduct_end_date )),0) ;

      ELSE
        l_present_days   := nvl(( (p_absence_arch.sick_deduct_start_date - p_asg.action_start_date )+ (p_asg.action_end_date - p_absence_arch.sick_deduct_end_date )),0) ;
     END IF;

       l_net            := (l_CAGR_daily_ref_sal * l_present_days)  + nvl(p_asg.sick_net,0) - nvl(p_asg.base_net,0) ;

         l_min_net := nvl(p_absence_arch.ijss_net,0)+ nvl(p_absence_arch.ijss_payment,0) + l_net;
       -- Only if values are not null, should a row be populated in g_coverages for the current GI
       IF nvl(l_GI_previous_net,0) > 0
        OR nvl(l_GI_previous_payment,0)  > 0
        OR nvl(l_GI_previous_Adjustment,0)  > 0
        OR nvl(l_GI_previous_IJSS_Gross,0)  > 0
        OR l_GI_Best_method IS NOT NULL THEN
          p_coverages(l_idx).cagr_id            := l_ben.guarantee_id;
          p_coverages(l_idx).g_type             := l_gi_code;

          p_coverages(l_idx).previous_net       := l_GI_previous_net;
          p_coverages(l_idx).previous_gi_payment:= l_GI_previous_payment;
          p_coverages(l_idx).previous_sick_adj  := l_GI_previous_adjustment;
          p_coverages(l_idx).previous_IJSS_Gross:= l_GI_previous_IJSS_Gross;
          p_coverages(l_idx).best_method        := l_GI_best_method;

          IF l_ben.guarantee_type IN ('GN','CA_N') THEN
             p_coverages(l_idx).net                := nvl(l_min_net,0);
          END IF;
       END IF;


       -- Calculate available days
       l_B1_avail_days := l_ben.band1 - l_B1_used_days;
       l_B2_avail_days := l_ben.band2 - l_B2_used_days;
       l_B3_avail_days := l_ben.band3 - l_B3_used_days;
       l_B4_avail_days := l_ben.band4 - l_B4_used_days;

       -- Get Daily Reference Salary for guarantee
       l_CAGR_daily_ref_sal := Get_CAGR_reference_salary(
                                        p_balance_name  => l_ben.balance,
                                        p_gi_type       => l_ben.guarantee_type,
                                        p_asg           => p_asg);


       hr_utility.set_location('  IN:'|| l_proc,50);

       hr_utility.set_location('  Ensuring parameters set to enter Use_GI_Bands', 55);
       hr_utility.set_location('  For_days      '|| l_for_days, 55);
       hr_utility.set_location('  B1_avail_days '|| l_b1_avail_days, 55);
       hr_utility.set_location('  Ben cursor: B1_rate '|| l_ben.b1_rate,55);
       hr_utility.set_location('  B2_avail_days '|| l_b2_avail_days,55);
       hr_utility.set_location('  Ben cursor: B2_rate '|| l_ben.b2_rate, 55);

       -- Use available bands for current absence
       -- Outputs are populated in table l_bands
       IF (l_B1_avail_days > 0) AND (l_for_days >0) THEN
         Use_GI_Bands(p_band_name               => 1,
                    p_band_avail_days   => l_B1_avail_days,
                    p_band_prcnt        => l_ben.b1_rate,
                    p_GI_ref_sal        => l_CAGR_daily_ref_sal,
                    p_band_start_date   => l_gi_start_date,
                    p_for_days          => l_for_days);
       END IF;

       IF (l_B2_avail_days > 0) AND (l_for_days >0) THEN
         Use_GI_Bands(p_band_name               => 2,
                    p_band_avail_days   => l_B2_avail_days,
                    p_band_prcnt        => l_ben.b2_rate,
                    p_GI_ref_sal        => l_CAGR_daily_ref_sal,
                    p_band_start_date   => l_gi_start_date,
                    p_for_days          => l_for_days);
       END IF;
       IF (l_B3_avail_days > 0) AND (l_for_days >0) THEN
         Use_GI_Bands(p_band_name               => 3,
                    p_band_avail_days   => l_B3_avail_days,
                    p_band_prcnt        => l_ben.b3_rate,
                    p_GI_ref_sal        => l_CAGR_daily_ref_sal,
                    p_band_start_date   => l_gi_start_date,
                    p_for_days          => l_for_days);
       END IF;
       IF (l_B4_avail_days > 0) AND (l_for_days >0) THEN
         Use_GI_Bands(p_band_name               => 4,
                    p_band_avail_days   => l_B4_avail_days,
                    p_band_prcnt        => l_ben.b4_rate,
                    p_GI_ref_sal        => l_CAGR_daily_ref_sal,
                    p_band_start_date   => l_gi_start_date,
                    p_for_days          => l_for_days);
       END IF;


       -- Reading l_bands table to populate g_coverages
       -- Depending on the type of CAGR,certain columns of g_coverages need to be populated
       --
       -- Max of 2 rows will be populated in l_bands
       --   as there can only be 1 GI band completely used up in a period
       --   and hence only 1 crossover of bands
       --
       hr_utility.set_location('  l_Bands count '||l_bands.COUNT||' 1st: '||l_bands.FIRST||' last: '||l_bands.LAST, 52) ;

       IF l_bands.COUNT > 0 THEN
         p_coverages(l_idx).cagr_id     := l_ben.guarantee_id;
         p_coverages(l_idx).g_type      := l_gi_code;

         FOR i IN l_bands.FIRST..l_bands.LAST          -- i contains Band Numbers(index of l_bands)
         LOOP
           hr_utility.set_location('  In l_Bands for band'||i, 55) ;
           hr_utility.set_location('   rate   '||l_bands(i).band_rate, 55) ;
           hr_utility.set_location('   days   '||l_bands(i).band_days, 55) ;
           hr_utility.set_location('   paymnt '||l_bands(i).band_payment, 55) ;
           hr_utility.set_location('   Existing l_net for GI '||l_net, 55) ;

           --l_first_band := l_bands.FIRST;
           --IF l_IJSS_gross_from_date IS NULL THEN
           IF (i = l_bands.FIRST) THEN           -- Only for 1st row in l_bands
             l_IJSS_gross_from_date          := l_bands(i).band_from_dt;
             p_coverages(l_idx).gi_from_date1:= l_bands(i).band_from_dt;
           END IF;

           hr_utility.set_location('   Gross from   :'||l_bands(i).band_from_dt, 11) ;
           hr_utility.set_location('   Gross to     :'||l_bands(i).band_to_dt, 11) ;

           l_IJSS_gross_to_date           := l_bands(i).band_to_dt;

           IF (i = l_bands.FIRST) THEN
             p_coverages(l_idx).gi_to_date1  := l_bands(i).band_to_dt;
           ELSE
             p_coverages(l_idx).gi_from_date2:= l_bands(i).band_from_dt;
             p_coverages(l_idx).gi_to_date2  := l_bands(i).band_to_dt;
           END IF;

           IF i = 1 THEN
             p_coverages(l_idx).band1   := l_bands(i).band_days;
           ELSIF i = 2 THEN
             p_coverages(l_idx).band2   := l_bands(i).band_days;
           ELSIF i = 3 THEN
             p_coverages(l_idx).band3   := l_bands(i).band_days;
           ELSIF i = 4 THEN
             p_coverages(l_idx).band4   := l_bands(i).band_days;
           END IF;

           hr_utility.set_location('  Populating g_covg from each row in l_bands for CAGR id '||p_coverages(l_idx).cagr_id, 60);
           hr_utility.set_location('  GITYPE:'|| p_coverages(l_idx).g_type||' IDX:'|| l_idx ||' NET:'|| p_coverages(l_idx).net,60);

           IF l_ben.guarantee_type IN ('GN','CA_N') THEN
             -- For net CAGRs, net(includes amt for present days) is summed across bands and populated
             p_coverages(l_idx).net     := l_net + l_bands(i).band_payment;
             l_net                      := l_net + l_bands(i).band_payment;

           ELSE
             -- For Gross CAGRs, payments are populated broken across bands
             IF (i = l_bands.FIRST) THEN
                p_coverages(l_idx).gi_payment1   := l_bands(i).band_payment;
                p_coverages(l_idx).gi_rate1      := l_bands(i).band_rate;
                p_coverages(l_idx).gi_days1      := l_bands(i).band_days;
             ELSE
                p_coverages(l_idx).gi_payment2   := l_bands(i).band_payment;
                p_coverages(l_idx).gi_rate2      := l_bands(i).band_rate;
                p_coverages(l_idx).gi_days2      := l_bands(i).band_days;
             END IF;

           END IF;      -- guarantee_type check

           hr_utility.set_location('  GITYPE:'|| p_coverages(l_idx).g_type ||' IDX:'|| l_idx||' NET:'|| p_coverages(l_idx).net,60);

         END LOOP;

       END IF;          -- l_bands.COUNT check

       l_bands.DELETE;  -- Clearing the l_bands table of the current CAGI

       -- Calculate and populate IJSS Gross overlaps in g_coverages table for the current CAGR
       IF (l_IJSS_gross_from_date IS NOT NULL)
       AND (l_IJSS_gross_to_date IS NOT NULL) THEN
         Calc_IJSS_Gross(p_IJSS_Gross_Start_Date        =>  l_IJSS_gross_from_date
                        ,p_IJSS_Gross_End_Date          =>  l_IJSS_gross_to_date
                        ,p_coverage_idx                 =>  l_idx
                        ,p_coverages                    =>  p_coverages
                        ,p_absence_arch                 =>  p_absence_arch);

            IF l_ben.guarantee_type IN ('GN','CA_N') THEN
                p_coverages(l_idx).net := nvl(p_coverages(l_idx).net,0) + nvl(p_coverages(l_idx).ijss_net_adjustment,0);
hr_utility.set_location('  GITYPE:'|| p_coverages(l_idx).net,60);
           END IF;

       END IF;


    END IF; -- }new guarantee row

  END LOOP;

  hr_utility.set_location('Leaving:'||l_proc, 90);

END;

  EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('Exception in '||l_proc,100);
     hr_utility.trace(SQLCODE);
     hr_utility.trace(SQLERRM);
     Raise;

END CALC_CAGR_GI;
--------------********************--------------
-- Addded functions for CPAM processing
--
-- Function for the Skip formula function
FUNCTION get_sickness_cpam_skip(
p_business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
P_payment_start_date    IN      Date,
P_payment_end_date      IN      Date,
--P_subrogated            IN      Varchar2,  Bug#2977789
P_net_daily_rate        IN      Number,
P_gross_daily_rate      IN      Number) RETURN Varchar2 IS

--
-- Populate the g_absence_calc structure for the element being processed
--
cursor c_get_absence is
select pabs.absence_attendance_id
,      to_number(pabs.abs_information1) parent_absence_id
,      pabs.date_start
,      pabs.date_end
,      pabs.date_end - pabs.date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      nvl(abs_information2, 'Y') subrogated
,      nvl(pabs.abs_information8, 'N') estimated
,      nvl(pwi.inc_information1,'N') work_incident
from   per_absence_attendances pabs,
       per_all_assignments_f pasg,
       per_absence_attendance_types pabt,
       per_work_incidents pwi
where  pabs.business_group_id = p_business_group_id
  and  pabs.abs_information_category ='FR_S'
  and  pabs.date_start <= p_payment_start_date
  and  pabs.date_end   >= p_payment_end_date
  and  decode(pabs.abs_information_category,'FR_S',to_number(pabs.abs_information6)) = pwi.incident_id(+)
  and  pabs.person_id = pwi.person_id(+)
  and  pabs.absence_Attendance_type_id = pabt.absence_attendance_type_id
  and  pabt.absence_category = 'S'
  and  pabs.date_start between pasg.effective_start_date and pasg.effective_end_date
  and  pasg.primary_flag = 'Y'
  and  pasg.person_id = pabs.person_id
  and  pasg.assignment_id = p_assignment_id;
--
cursor c_get_parent_absence(p_absence_attendance_id number) is
select paa.absence_attendance_id
,      0 parent_absence_id
,      paa.date_start
,      paa.date_end
,      paa.date_end - paa.date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      nvl(abs_information2, 'Y') subrogated
,      nvl(paa.abs_information8,'N') estimated
,      nvl(inc.inc_information1,'N') work_incident
from per_absence_attendances paa
,    per_work_incidents inc
where paa.absence_attendance_id = p_absence_attendance_id
and   paa.abs_information6 = to_char(inc.incident_id(+));
--
cursor c_get_child_absence(p_parent_absence_id number
                          ,p_max_end_date date) is
select a.absence_attendance_id
,      to_number(a.abs_information1) parent_absence_id
,      a.date_start
,      a.date_end
,      a.date_end - a.date_start + 1 duration
,      null effective_start_date
,      null effective_end_date
,      null estimated
,      null work_incident
from per_absence_attendances a,
per_absence_attendances p
where a.abs_information1 = to_char(p_parent_absence_id)
and   p.absence_attendance_id = p_parent_absence_id
and   a.person_id = p.person_id
and   a.date_end <= p_max_end_date
order by a.date_start;
--
TYPE t_absence is RECORD
(absence_attendance_id number
,parent_absence_id number
,date_start date
,date_end date
,duration number
,effective_start_date date
,effective_end_date date
,subrogated varchar2(30)
,estimated varchar2(30)
,work_incident varchar2(30)
);
--
abs_rec t_absence;
parent_abs_rec t_absence;
--
l_duration number := 0;
l_absence_start_date date;
l_absence_end_date date;
l_proc  varchar2(72) := g_package||'Get_Sickness_cpam_skip';

--
procedure check_gap(p_absence_end_date date
                   ,p_absence_start_date date) is
l_proc               varchar2(72) := g_package||'check_gap';

begin



  if p_absence_start_date - p_absence_end_date - 1 > 2
  then
     fnd_message.set_name ('PAY', 'PAY_75031_INVALID_LINK_ABS');
     fnd_message.raise_error;
   end if;
end check_gap;
--
begin
--
-- Fetch absence detail as per the element entry
--
   l_proc               := g_package||'get_sickness_cpam_skip';
   open c_get_absence;
   fetch c_get_absence into abs_rec;
   close c_get_absence;
   -- If there was any part of the current absence
   --  that was processed in some other period
   --  then that contributes to the duration

   IF (abs_rec.date_start >= p_payment_start_date) THEN
       l_duration := 0;
   ELSE
       l_duration := p_payment_start_date - abs_rec.date_start ;
   END IF;

   if abs_rec.parent_absence_id is not null then
      --
      -- get the parent absence details
      --
      open c_get_parent_absence(abs_rec.parent_absence_id);
      fetch c_get_parent_absence into parent_abs_rec;
      close c_get_parent_absence;
      --
      l_duration := parent_abs_rec.duration;
      l_absence_end_date := parent_abs_rec.date_end;

      --
      -- get the child absences up to but not including
      -- the orginiating absence
      --
      for a in c_get_child_absence(parent_abs_rec.absence_attendance_id,abs_rec.date_start - 1) loop

          l_absence_start_date := a.date_start;
          -- check length of time between linked absences
          check_gap(l_absence_end_date,l_absence_start_date);
          --
          l_absence_end_date := a.date_end;
          l_duration := l_duration + a.duration;
      end loop;
      --
      -- check length of time between initiating absence
      -- and last absence processed
      check_gap(l_absence_end_date,abs_rec.date_start);
   else
      parent_abs_rec := abs_rec;
   end if;
   --
   g_absence_calc.element_entry_id := p_element_entry_id;
   g_absence_calc.date_earned := p_date_earned;
   g_absence_calc.id := abs_rec.absence_attendance_id;
   g_absence_calc.ijss_estimated := parent_abs_rec.estimated;
   g_absence_calc.parent_absence_id := parent_abs_rec.absence_attendance_id;
   g_absence_calc.parent_absence_start_date := parent_abs_rec.date_start;
   g_absence_calc.work_incident := parent_abs_rec.work_incident;
   g_absence_calc.prior_linked_absence_duration := l_duration;
   g_absence_calc.effective_start_date := p_payment_start_date;
   g_absence_calc.effective_end_date := p_payment_end_date;
   g_absence_calc.ijss_subrogated := abs_rec.subrogated;
   g_absence_calc.ijss_net_daily_rate  := P_net_daily_rate;
   g_absence_calc.ijss_gross_daily_rate  := P_gross_daily_rate;
   g_absence_calc.initiator  := 'CPAM';
   --
   if g_absence_calc.ijss_estimated = 'Y' then
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'Y';
   else
        hr_utility.set_location(' Leaving:'||l_proc, 70);
        return 'N';
   end if;
END get_sickness_cpam_skip;
--
-- Procedure for reference salary balances
PROCEDURE Get_CPAM_Ref_salary(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_arch          IN OUT NOCOPY pay_fr_sick_pay_processing.t_asg)

IS
--
cursor c_get_defined_balance(p_balance_name VARCHAR2) is
select db.defined_balance_id
from pay_defined_balances db
,    pay_balance_dimensions bd
,    pay_balance_types bt
where db.balance_type_id = bt.balance_type_id
and   db.balance_dimension_id = bd.balance_dimension_id
and   bt.balance_name = p_balance_name
and   bt.legislation_code = 'FR'
and   bd.database_item_suffix = '_ASG_PTD'
and   bd.legislation_code = 'FR';
--
l_defined_balance_id number;
l_proc               varchar2(72) := g_package||'Get_cpam_Ref_salary';

BEGIN
  open c_get_defined_balance('FR_SICKNESS_DEDUCTION_REFERENCE_SALARY');
  fetch c_get_defined_balance into l_defined_balance_id;
  close c_get_defined_balance;
  --
  P_Absence_arch.ded_ref_salary := Nvl(pay_balance_pkg.get_value(
                                       P_DEFINED_BALANCE_ID => l_defined_balance_id
                                      ,P_ASSIGNMENT_ID => p_assignment_id
                                      ,P_VIRTUAL_DATE => g_absence_calc.abs_ptd_end_date),0);
  open c_get_defined_balance('FR_SICKNESS_LEGAL_GUARANTEE_REFERENCE_SALARY');
  fetch c_get_defined_balance into l_defined_balance_id;
  close c_get_defined_balance;
  --
  P_Absence_arch.lg_ref_salary := Nvl(pay_balance_pkg.get_value(
                                       P_DEFINED_BALANCE_ID => l_defined_balance_id
                                      ,P_ASSIGNMENT_ID => p_assignment_id
                                      ,P_VIRTUAL_DATE => g_absence_calc.abs_ptd_end_date),0);
--
EXCEPTION
WHEN OTHERS THEN
   P_absence_arch.ded_ref_salary :=0;
   P_absence_arch.lg_ref_salary :=0;
--
END Get_CPAM_Ref_salary;
--
-- Procedure for getting IJSS value as entered in cpam
--
PROCEDURE get_sickness_CPAM_IJSS(
p_business_group_id     IN  Number,
p_assignment_id         IN  Number,
p_absence_id            IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date,
p_work_inc_class        IN  Varchar2) IS
--
l_total_process_days number;
l_total_days number;
--
-- Cursor for finding holidays within the date range
Cursor csr_holidays(c_hol_date varchar2) IS
   SELECT 'H'
   FROM per_absence_attendances pabs_hol,
        per_absence_attendance_types pabt,
        per_absence_attendances pabs_sick
   WHERE pabs_sick.absence_attendance_id = p_absence_id
    AND pabs_sick.business_group_id = p_business_group_id
    AND pabs_hol.person_id = pabs_sick.person_id
    AND pabs_hol.business_group_id = p_business_group_id
    AND c_hol_date BETWEEN pabs_hol.date_start AND pabs_hol.date_end
    AND pabt.absence_attendance_type_id = pabs_hol.absence_attendance_type_id
    AND pabt.absence_category in ('FR_MAIN_HOLIDAY','FR_ADDITIONAL_HOLIDAY','FR_RTT_HOLIDAY') ;
--
BEGIN

  IF (g_overlap.COUNT <> 0) THEN
     g_overlap.DELETE;
     hr_utility.set_location(' Modified count '||g_overlap.COUNT,20);
  END IF;

  -- find the number of rows of the global table
  l_total_process_days := p_end_date - p_start_date +1;

  FOR l_total_days in 1..l_total_process_days LOOP
     -- Populate absence days
     IF l_total_days = 1 THEN
        g_overlap(1).absence_day := g_absence_calc.effective_start_date;
     ELSE
        g_overlap(l_total_days).absence_day := g_overlap(l_total_days -1).absence_day +1;
     END IF;
     -- Populate holidays
     OPEN csr_holidays(g_overlap(l_total_days).absence_day);
     FETCH csr_holidays INTO g_overlap(l_total_days).holiday;
     CLOSE csr_holidays;
      -- Populate IJSS values:
      -- Removed and modified code for bug 2751760
      g_overlap(l_total_days).IJSS_Gross := g_absence_calc.ijss_gross_daily_rate;
      g_overlap(l_total_days).IJSS_Net := g_absence_calc.ijss_net_daily_rate;
      --
  END LOOP;
END get_sickness_cpam_ijss;

-----------------------------------------------------------------------------
--  CONCATENATED_INPUTS
--  returns a string that is a concatenation of the entry values for a given
--  element entry. For use in reports when presenting the inputs for an
--  entry on a single line of information.
-----------------------------------------------------------------------------

FUNCTION concatenated_inputs(
            p_element_entry_id in number
           ,p_effective_date in DATE
           ,p_delimiter in varchar2 default '|'
           )
RETURN varchar2 is

CURSOR ele_input(p_element_entry_id in NUMBER
                 ,p_effective_date in DATE) is
   select name,
          uom,
          substr(screen_entry_value,1,10) screen_entry_value
   from   pay_element_entry_values_f ev,
          pay_input_values_f i
   where  ev.element_entry_id = p_element_entry_id
   and    ev.input_value_id + 0 = i.input_value_id
   and    p_effective_date between
          ev.effective_start_date and ev.effective_end_date
   and    p_effective_date between
          i.effective_start_date and i.effective_end_date
   order by display_sequence;


l_length_value NUMBER;
l_concatenated_input varchar2(240);
l_name pay_input_values_f.name%TYPE;


BEGIN

l_concatenated_input := p_delimiter ;
for l_count in ele_input(p_element_entry_id, p_effective_date) loop

    l_concatenated_input := substr(l_concatenated_input ||
                            ' '||
                            l_count.screen_entry_value ||
                            ' '||p_delimiter , 1,240);
    end loop;
return l_concatenated_input;
end concatenated_inputs;
-----------------------------------------------------------------------------
FUNCTION concatenated_result_values(
            p_run_result_id in number
           ,p_delimiter in varchar2 default '|'
           )
RETURN varchar2 is

CURSOR ele_input_res(p_run_result_id in NUMBER) is
   select name,
          uom,
          substr(result_value,1,10) result_value
   from   pay_run_result_values rv,
          pay_input_values_f i
   where  rv.run_result_id = p_run_result_id
   and    rv.input_value_id + 0 = i.input_value_id
   order by display_sequence;


l_length_value NUMBER;
l_concatenated_input varchar2(240);
l_name pay_input_values_f.name%TYPE;


BEGIN

l_concatenated_input := p_delimiter ;
for l_count in ele_input_res(p_run_result_id) loop

    l_concatenated_input := substr(l_concatenated_input ||
                            ' '||
                            l_count.result_value ||
                            ' '||p_delimiter , 1,240);
    end loop;
return l_concatenated_input;
end concatenated_result_values;

-----------------------------------------------------------------------------
--  CONCATENATED_INPUT_NAMES
--  returns a string that is a concatenation of the input names for a given
--  element type. For use in reports when providing a key to interpret
--  concatenated_inputs string.
-----------------------------------------------------------------------------
FUNCTION concatenated_input_names(
            p_element_type_id in number
           ,p_effective_date in DATE
           ,p_delimiter in varchar2 default '|'
           )
RETURN varchar2 is

CURSOR ele_input_name(p_element_type_id in NUMBER
                 ,p_effective_date in DATE) is
   select name,
          uom
   from
          pay_input_values_f i
   where  i.element_type_id = p_element_type_id
   and    p_effective_date between
          i.effective_start_date and i.effective_end_date
   order by display_sequence;


l_length_value NUMBER;
l_concatenated_input_name varchar2(240);
l_name pay_input_values_f.name%TYPE;


BEGIN

l_concatenated_input_name := p_delimiter ;
for l_count in ele_input_name(p_element_type_id, p_effective_date) loop

    l_concatenated_input_name := substr(l_concatenated_input_name ||
                            ' '||
                            l_count.name ||
                            ' '||p_delimiter , 1,240);
    end loop;
return l_concatenated_input_name;
end concatenated_input_names;
--
END PAY_FR_SICKNESS_CALC;

/
