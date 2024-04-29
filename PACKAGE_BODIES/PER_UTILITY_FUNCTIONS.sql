--------------------------------------------------------
--  DDL for Package Body PER_UTILITY_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_UTILITY_FUNCTIONS" as
/* $Header: peutlfnc.pkb 120.1.12000000.3 2007/04/10 10:21:24 asgugupt noship $ */
--
g_package  varchar2(33) := '  per_utility_functions.';  -- Global package name
--

TYPE global_id_table is TABLE OF number INDEX BY BINARY_INTEGER;

g_element_entries global_id_table;
--
-- 3267975 >>
g_legcode_cache             HR_ORGANIZATION_INFORMATION.org_information9%TYPE;
g_legcode_cached            boolean := FALSE;
--
g_reset_pto_accruals        varchar2(10) := 'FALSE';
g_reset_pto_cache           boolean := false;
--
TYPE number_tbl        is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE prmValue_type_tbl is TABLE OF PAY_ACTION_PARAMETER_VALUES.parameter_value%TYPE
                                   INDEX BY BINARY_INTEGER;
TYPE prmName_type_tbl  is TABLE OF PAY_ACTION_PARAMETER_VALUES.parameter_name%TYPE
                                   INDEX BY BINARY_INTEGER;
--
TYPE action_prm_cache_r is RECORD
(
 parameter_name      prmName_type_tbl,
 parameter_value     prmValue_type_tbl,
 sz                  number
);

g_actionPrm_cache          action_prm_cache_r;
g_actionPrm_cached         boolean := FALSE;
--
--
TYPE varchar_80_tbl is TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
--
TYPE event_group_cache_r is RECORD
(
 event_group_id         number_tbl,
 event_group_name       varchar_80_tbl,
 business_group_id      number_tbl,
 legislation_code       varchar_80_tbl,
 sz                     number
);

g_events_cache          event_group_cache_r;
g_events_cached         boolean := FALSE;
--
--
/* =====================================================================
   Name    : Get_Payroll_Period
   Purpose : To determine the payroll period spanning a given date and
             to set global variables containg the start and end dates and the
             period number
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Payroll_Period
(P_Payroll_ID                     IN  Number
,P_Date_In_Period                 IN  Date) return number IS
--
l_proc        varchar2(72) := g_package||'Get_Payroll_Period';
--
cursor csr_get_payroll_period is
select start_date
,      end_date
,      period_num
from   per_time_periods
where  payroll_id = P_Payroll_ID
and    P_Date_In_Period between start_date and end_date;
--
l_start_date date;
l_end_date   date;
l_period_number number;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   open csr_get_payroll_period;
   fetch csr_get_payroll_period into l_start_date,l_end_date,l_period_number;
   if csr_get_payroll_period%notfound then
      close csr_get_payroll_period;
      hr_utility.set_location('Payroll Period not found '||l_proc, 10);
      l_error := per_formula_functions.raise_error(800, 'HR_52798_PTO_PAYROLL_INVALID');
      return 1;
   end if;
   close csr_get_payroll_period;
   --
   l_error := per_formula_functions.set_date
                 ('PAYROLL_PERIOD_START_DATE',l_start_date);
   l_error := per_formula_functions.set_date
                 ('PAYROLL_PERIOD_END_DATE',l_end_date);
   l_error := per_formula_functions.set_number
                 ('PAYROLL_PERIOD_NUMBER',l_period_number);
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
end Get_Payroll_Period;
--
/* =====================================================================
   Name    : Get_Accrual_Band
   Purpose : To determine the accrual band that spans the specified number of
             years and to set global variables containing the ANNUAL_RATE,
             UPPER_LIMIT and CEILING values.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Accrual_Band
(P_Plan_ID                        IN  Number
,P_Number_Of_Years                IN  Number) return number IS
--
l_proc        varchar2(72) := g_package||'Get_Accrual_Band';
--
--
cursor csr_get_accrual_band is
select annual_rate
,      upper_limit
,      nvl(ceiling, 99999999)
,      nvl(max_carry_over, 99999999)
from   pay_accrual_bands
where  P_Number_Of_Years >= lower_limit
and    P_Number_Of_Years <  upper_limit
and    accrual_plan_id = P_Plan_ID;
--
l_annual_rate number;
l_upper_limit number;
l_ceiling     number;
l_max_carry_over number;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   l_annual_rate := 0;
   l_upper_limit := 0;
   l_ceiling     := 0;
   l_max_carry_over := 0;
   --
   open csr_get_accrual_band;
   fetch csr_get_accrual_band into l_annual_rate,
                                   l_upper_limit,
                                   l_ceiling,
				   l_max_carry_over;
   if csr_get_accrual_band%notfound then
      hr_utility.set_location(l_proc, 10);
      return 1;
   end if;
   close csr_get_accrual_band;
   --
   l_error := per_formula_functions.set_number('ANNUAL_RATE',l_annual_rate);
   l_error := per_formula_functions.set_number('UPPER_LIMIT',l_upper_limit);
   l_error := per_formula_functions.set_number('CEILING'    ,l_ceiling);
   l_error := per_formula_functions.set_number('MAX_CARRY_OVER',l_max_carry_over);
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
exception
   when others then
        hr_utility.set_location(l_proc, 20);
        return 1;
end Get_Accrual_Band;
--
/* =====================================================================
   Name    : Get_Period_Dates
   Purpose : To determine the start and end dates of a period of time that
             spans a given date, which is of a given duration (e.g. Month) and
             which is a mulitple of that duration from a given Start date
             (e.g. 6 months on from 01/01/90)
             The globals PERIOD_START_DATE and PERIOD_END_DATE are populated
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Period_Dates
(P_Date_In_Period                 IN  Date
,P_Period_Unit                    IN  Varchar2
,P_Base_Start_Date                IN  Date
,P_Unit_Multiplier                IN  Number) RETURN Number IS
--
l_proc        varchar2(72) := g_package||'Get_Period_Dates';
--
l_start_date    date;
l_end_date      date;
l_error         number;
l_months        number;
--
begin

   hr_utility.set_location(l_proc, 5);

   if P_Date_In_Period >= P_Base_Start_Date then
   --
     l_start_date := P_Base_Start_Date;
     l_months := P_Unit_Multiplier;

     while true loop
      --
      if p_period_unit = 'M' then
         l_end_date := add_months(P_Base_Start_Date, l_months) - 1;
         l_start_date := add_months(P_Base_Start_Date, (l_months - P_Unit_Multiplier));
         l_months := l_months + P_Unit_Multiplier;
      elsif p_period_unit = 'W' then
         l_end_date := l_start_date + (7*p_unit_multiplier) - 1;
      elsif p_period_unit = 'D' then
	 l_end_date := l_start_date + p_unit_multiplier - 1;
      end if;
      --
      if P_Date_In_Period between l_start_date and l_end_date then
         l_error := per_formula_functions.set_date
                        ('PERIOD_START_DATE',l_start_date);
         l_error := per_formula_functions.set_date
                        ('PERIOD_END_DATE',l_end_date);
         exit;
      else
         l_start_date := l_end_date + 1;
      end if;
     --
     end loop;
   --
   else
   --
     l_end_date := P_Base_Start_Date - 1;
     l_months := P_Unit_Multiplier * -1;

     while true loop
      --
      if p_period_unit = 'M' then
        l_end_date := add_months(P_Base_Start_Date, (l_months + P_Unit_Multiplier)) - 1;
        l_start_date := add_months(P_Base_Start_Date, l_months);
        l_months := l_months - P_Unit_Multiplier;
      elsif p_period_unit = 'W' then
         l_start_date := l_end_date - (7*p_unit_multiplier) + 1;
      elsif p_period_unit = 'D' then
	 l_start_date := l_end_date - p_unit_multiplier + 1;
      end if;
      --
      if P_Date_In_Period between l_start_date and l_end_date then
         l_error := per_formula_functions.set_date
                        ('PERIOD_START_DATE',l_start_date);
         l_error := per_formula_functions.set_date
                        ('PERIOD_END_DATE',l_end_date);
         exit;
      else
         l_end_date := l_start_date - 1;
      end if;
     --
     end loop;
   --
   end if;

   hr_utility.set_location(l_proc, 10);
   return 0;
exception
   when others then
        hr_utility.set_location(l_proc, 15);
        return 1;
end Get_Period_Dates;
--
/* =====================================================================
   Name    : Get_Assignment_Status
   Purpose : To determine assignment status spanning a given date
             The globals ASSIGNMENT_EFFECTIVE_SD, ASSIGNMENT_EFFECTIVE_ED and
             ASSIGNMENT_SYSTEM_STATUS are populated
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Assignment_Status
(P_Assignment_ID                  IN  Number
,P_Effective_Date                 IN  Date) return number IS
--
l_proc        varchar2(72) := g_package||'Get_Assignment_Status';
--
l_effective_start_date date;
l_effective_end_date date;
l_per_system_status varchar2(30);
l_error number;
--
cursor csr_assignment_status IS
select a.effective_start_date
,      a.effective_end_date
,      b.per_system_status
from   per_all_assignments_f a
,      per_assignment_status_types b
where  a.assignment_id = P_Assignment_ID
and    a.assignment_status_type_id = b.assignment_status_type_id
and    P_Effective_Date
        between a.effective_start_date and a.effective_end_date;
--
begin
   hr_utility.set_location(l_proc, 5);
   open csr_assignment_status;
   fetch csr_assignment_status into l_effective_start_date,
                                    l_effective_end_date,
                                    l_per_system_status;
   if csr_assignment_status%notfound then
      close csr_assignment_status;
      --
      hr_utility.set_location(l_proc, 10);
      return 1;
   end if;
   close csr_assignment_status;
   --
   l_error := per_formula_functions.set_date
                   ('ASSIGNMENT_EFFECTIVE_SD',l_effective_start_date);
   l_error := per_formula_functions.set_date
                   ('ASSIGNMENT_EFFECTIVE_ED',l_effective_end_date);
   l_error := per_formula_functions.set_text
                   ('ASSIGNMENT_SYSTEM_STATUS',l_per_system_status);
   --
   hr_utility.set_location(l_proc, 10);
   return 0;
end Get_Assignment_Status;
--
/* =====================================================================
   Name    : Calculate_Payroll_Periods
   Purpose : Calculates number of periods in one year for the payroll
             indicated by payroll_id
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Calculate_Payroll_Periods
(P_Payroll_ID                  IN  Number,
 P_Calculation_Date            IN  Date) return number IS
--
l_proc        varchar2(72) := g_package||'Calculate_Payroll_Periods';
l_periods     number;
l_start_date  date;
l_error       number;
l_max_ed_cur_year date; -- bug 4956943
--
-- Bug 1574928
-- As bi-weekly, weekly and lunar months can have a variable number of periods
-- in a year, these must be calculated based on per_time_periods.
-- They are set to zero and counted later on.

cursor c_count_periods is
select count(*)
from per_time_periods ptp
where ptp.payroll_id = P_Payroll_ID
and ptp.end_date between
to_date('01/01/'||to_char(P_Calculation_Date, 'YYYY'), 'DD/MM/YYYY')
and to_date('31/12/' || to_char(P_Calculation_Date, 'YYYY'), 'DD/MM/YYYY');

cursor c_first_date is
select start_date
from per_time_periods
where payroll_id = p_payroll_id
and end_date = (select min(end_date)
                from per_time_periods
                where payroll_id = p_payroll_id
                and to_char(end_date, 'YYYY') = to_char(p_calculation_date, 'YYYY'));

begin
--
  hr_utility.set_location(l_proc, 5);

  open c_count_periods;
  fetch c_count_periods into l_periods;
  close c_count_periods;

  l_error := per_formula_functions.set_number
                   ('PAYROLL_YEAR_NUMBER_OF_PERIODS',l_periods);

  hr_utility.set_location(l_proc, 10);
  -- START bug 4956943
  select max(end_date)
    into l_max_ed_cur_year
    from per_time_periods
   where payroll_id = p_payroll_id
     and to_char(end_date, 'YYYY') = to_char(p_calculation_date, 'YYYY');
  hr_utility.trace(l_proc || ' '  || l_max_ed_cur_year);

  if l_max_ed_cur_year < p_calculation_date then
    hr_utility.set_location(l_proc, 100);
    select min(start_date)
      into l_start_date
      from per_time_periods
     where payroll_id = p_payroll_id
       and end_date >= p_calculation_date;
  else
  -- END bug 4956943
    open c_first_date;
    fetch c_first_date into l_start_date;
    close c_first_date;
  end if;

  l_error := per_formula_functions.set_date
                   ('PAYROLL_YEAR_FIRST_VALID_DATE', l_start_date);

  hr_utility.set_location(l_proc, 15);

  return 0;
--
end Calculate_Payroll_Periods;
--
/* =====================================================================
   Name    : Get_Start_Date
   Purpose : Calculates the adjusted start date for accruals, by checking
             for element entries attached to an accrual plan which have not
             yet been processed in a payroll run.
   Returns : Effective start date of payroll period.
   ---------------------------------------------------------------------*/
function Get_Start_Date
(P_Assignment_ID               IN  Number,
 P_Accrual_Plan_ID             IN  Number,
 P_Assignment_Action_Id        IN  Number,
 P_Accrual_Start_Date          IN  Date,
 P_Turn_Of_Year_Date           IN  Date) return Date is

l_proc        varchar2(72) := g_package||'Get_Start_Date';
l_date        date;
l_balance_exists number;
l_payroll_id     number;
l_result         number;
/*
   Changes done for Bug 3183291
   ----------------------------
1. Moved pay_element_entries_f pee1 to second last
2. Driving the join to pay_net_calculation_rules through the
   input_value_id (PAY_NET_CALCULATION_RULES_N3) instead of
   ncr.accrual_plan_id (PAY_NET_CALCULATION_RULES_FK1) which is more selective
3. By disabling the Primary Key join to the table the query can be driven off the
   element entry route which is more selective when driving through subsequent tables.
4. Added this predicate to help in the filtering
5. Very poor filter so disabled to drive of the source_id which is more selective
6. Same as above
7. Same as above
*/
/* modified the following cursor to improve performance
cursor c_get_date is
select nvl(min(pee1.effective_start_date), P_Accrual_Start_Date)
from pay_element_links_f pel1,
     pay_input_values_f piv,
     pay_net_calculation_rules ncr,
     pay_accrual_plans pap,
     pay_element_links_f pel2,
     pay_element_entries_f pee1, -- Change (1)
     pay_element_entries_f pee2
where pee1.element_link_id = pel1.element_link_id
and pel1.element_type_id = piv.element_type_id
and piv.input_value_id = ncr.input_value_id
and ncr.accrual_plan_id + 0 = pap.accrual_plan_id -- Change (2)
and pap.accrual_plan_element_type_id = pel2.element_type_id
and pel2.element_link_id = pee2.element_link_id
and pee1.assignment_id = p_assignment_id
and pee2.assignment_id = p_assignment_id
and pap.accrual_plan_id + 0 = p_accrual_plan_id -- Change (3)
and pee1.effective_start_date <= p_accrual_start_date - 1 -- Change (4)
and pee1.effective_end_date between p_turn_of_year_date
                            and p_accrual_start_date - 1
and not exists (select 1
                from pay_run_results prr
                where prr.source_id = pee1.element_entry_id
                and prr.element_type_id + 0 = pel1.element_type_id -- Change (5)
                and prr.status in ('P', 'PA')
                )
and not exists (select 1
                from pay_run_results prr,
                     pay_run_result_values rrv
                where prr.run_result_id = rrv.run_result_id
                and prr.source_id = pee2.element_entry_id
                and prr.element_type_id + 0 = pap.tagging_element_type_id -- Change (6)
                and rrv.result_value = pee1.element_entry_id
               );
*/
-- fix for the bug 5645232
cursor c_get_date is
select  /*+ index(pee1 PAY_ELEMENT_ENTRIES_F_N53) use_nl(ncr)*/
nvl(min(pee1.effective_start_date), P_Accrual_Start_Date)
from
     pay_input_values_f piv,
     pay_net_calculation_rules ncr,
     pay_accrual_plans pap,
     pay_element_entries_f pee1,
     pay_element_entries_f pee2
     where
 pee1.element_type_id = piv.element_type_id
and piv.input_value_id = ncr.input_value_id
and ncr.accrual_plan_id +0 = pap.accrual_plan_id
and pap.accrual_plan_element_type_id = pee1.element_type_id
and pee1.element_type_id = pee2.element_type_id
and pee1.assignment_id = p_assignment_id
and pee2.assignment_id = p_assignment_id
and pap.accrual_plan_id  = p_accrual_plan_id
and pee1.effective_start_date <= p_accrual_start_date
and pee1.effective_end_date between p_turn_of_year_date
                            and p_accrual_start_date
and not exists (select 1
                from pay_run_results prr
                where prr.source_id = pee1.element_entry_id
                and prr.element_type_id + 0 = pee1.element_type_id -- fix new
                and prr.status in ('P', 'PA')
                )
and not exists (select 1
                from pay_run_results prr,
                     pay_run_result_values rrv
                where prr.run_result_id = rrv.run_result_id
                and prr.source_id = pee2.element_entry_id
                and prr.element_type_id + 0 = pap.tagging_element_type_id
                and rrv.result_value = pee1.element_entry_id
               );
-- end of bug 5645232
cursor c_check_balance_exists is
select 1
from pay_element_entries_f pee,
     pay_element_links_f pel,
     pay_accrual_plans pap
where pap.accrual_plan_id = p_accrual_plan_id
and   pee.assignment_id = p_assignment_id
and   pap.accrual_plan_element_type_id = pel.element_type_id
and   pel.element_link_id = pee.element_link_id
and   exists (select 1
              from pay_run_results prr
              where prr.source_id = pee.element_entry_id
              and prr.element_type_id + 0 = pel.element_type_id -- Change (7)
              and prr.status in ('P', 'PA')
              );

begin
--
  hr_utility.set_location(l_proc, 5);

  /*
   * First check that a latest balance actually exists. There will
   * be no balance if no payrolls have yet been run with the new
   * pto system. The balance DBI is set to 0 in this case, so we cannot
   * detect the event with in a FF. In this circumstance, we just want to
   * accrue for the entire plan term, and we set the return date accordingly.
   * If there is a latest balance in existence, continue as normal.
   */

  open c_check_balance_exists;
  fetch c_check_balance_exists into l_balance_exists;

  if c_check_balance_exists%notfound then
  --
    close c_check_balance_exists;
    return P_Turn_Of_Year_Date;
  --
  end if;

  close c_check_balance_exists;

  /*
   * Now check for retrospective element entries
   *
   */

  open c_get_date;
  fetch c_get_date into l_date;
  close c_get_date;

  hr_utility.set_location(l_proc, 10);

  return l_date;
--
end Get_Start_Date;
--
--

/* =====================================================================
   Name    : Get_Element_Entry
   Purpose : Assigns value of element entry id context to a
             global variable.
   Returns : 1
   ---------------------------------------------------------------------*/
function Get_Element_Entry
 (P_Element_Entry_Id            IN  Number,
  P_Assignment_ID               IN  Number,
  P_Assignment_Action_Id        IN  Number) return Number is

/*
   Changes done for Bug 3183291
   ----------------------------
1. Moved pay_element_entries_f pee1 to second last
2. Driving the join to pay_net_calculation_rules through the
   input_value_id (PAY_NET_CALCULATION_RULES_N3) instead of
   ncr.accrual_plan_id (PAY_NET_CALCULATION_RULES_FK1) which is more selective
3. Very poor filter so disabled to drive of the source_id which is more selective
4. Same as above
5. Bulk collect is used to store the values into PL/SQL tables
*/
/*
modified the cursor to improve performance
cursor c_get_element (p_entry_id number,
                      p_effective_date date) is
select distinct pee1.element_entry_id
from pay_element_links_f pel1,
     pay_input_values_f piv,
     pay_net_calculation_rules ncr,
     pay_accrual_plans pap,
     pay_element_links_f pel2,
     pay_element_entries_f pee1,  -- Change (1)
     pay_element_entries_f pee2
where pee1.element_link_id = pel1.element_link_id
and pel1.element_type_id = piv.element_type_id
and piv.input_value_id = ncr.input_value_id
and ncr.accrual_plan_id + 0 = pap.accrual_plan_id -- Change (2)
and pap.accrual_plan_element_type_id = pel2.element_type_id
and pel2.element_link_id = pee2.element_link_id
and pee1.assignment_id = p_assignment_id +
                         decode (pel1.element_link_id, 0, 0, 0)
and pee2.assignment_id = p_assignment_id
and pee1.effective_end_date < p_effective_date
and pee2.element_entry_id = p_entry_id
and not exists (select 1
                from pay_run_results prr
                where prr.source_id = pee1.element_entry_id
                and prr.element_type_id + 0 = pel1.element_type_id -- Change (3)
                and prr.status in ('P', 'PA')
                )
and not exists (select 1
                from pay_run_results prr,
                     pay_run_result_values rrv
                where prr.run_result_id = rrv.run_result_id
                and prr.source_id = pee2.element_entry_id
                and prr.element_type_id + 0 = pap.tagging_element_type_id -- Change (4)
                and rrv.result_value = pee1.element_entry_id
               );
*/
-- fix for the bug 5645232
cursor c_get_element (p_entry_id number,
                      p_effective_date date) is
select  /*+ index(pee1 PAY_ELEMENT_ENTRIES_F_N53)*/
       distinct pee1.element_entry_id
from
     pay_input_values_f piv,
     pay_net_calculation_rules ncr,
     pay_accrual_plans pap,
     pay_element_entries_f pee1,
     pay_element_entries_f pee2
where
 pee1.element_type_id = piv.element_type_id
and piv.input_value_id = ncr.input_value_id
and ncr.accrual_plan_id +0 = pap.accrual_plan_id
and pap.accrual_plan_element_type_id = pee2.element_type_id
and pee1.element_type_id = pee2.element_type_id
and pee1.assignment_id = p_assignment_id
and pee2.assignment_id = p_assignment_id
and pee1.effective_end_date < p_effective_date
and pee2.element_entry_id = p_entry_id
and not exists (select 1
                from pay_run_results prr
                where prr.source_id = pee1.element_entry_id
                and prr.element_type_id + 0 = pee1.element_type_id
                and prr.status in ('P', 'PA')
                )
and not exists (select 1
                from pay_run_results prr,
                     pay_run_result_values rrv
                where prr.run_result_id = rrv.run_result_id
                and prr.source_id = pee2.element_entry_id
                and prr.element_type_id + 0 = pap.tagging_element_type_id
                and rrv.result_value = pee1.element_entry_id
               );

-- end of bug 5645232
--
cursor c_get_date is
select ptp.start_date
from per_time_periods ptp,
     pay_payroll_actions ppa,
     pay_assignment_actions paa
where paa.payroll_action_id = ppa.payroll_action_id
and ppa.time_period_id = ptp.time_period_id
and paa.assignment_action_id = p_assignment_action_id;

-- Bug 3183291 -- Change (5)
--l_retro_entry_id   number;
l_count            number;
l_effective_date   date;
l_limit            natural := 100; -- Limiting the bulk collect, if not limited then bulk collect
                                   -- returns entire rows for the condition, it may affect memory
l_prev_collect     number  := 0;   -- Cumulative record count till previous fetch
l_curr_collect     number  := 0;   -- Cumulative record count including the current fetch
l_diff_collect     number  := 0;   -- To check that, whether the last fetch retrived any new
                                   -- records, if not then to exit from the loop
g_element_entries1 global_id_table;
--
begin
--

  open c_get_date;
  fetch c_get_date into l_effective_date;
  close c_get_date;

  open c_get_element(p_element_entry_id, l_effective_date);
  --
     loop
     --
     -- Change (5)
        fetch c_get_element bulk collect into g_element_entries1 limit l_limit;
           --
           l_prev_collect := l_curr_collect;
           l_curr_collect := c_get_element%rowcount;
           l_diff_collect := l_curr_collect - l_prev_collect;
           --
           if l_diff_collect > 0 then
              --
              for i in g_element_entries1.first..g_element_entries1.last loop
                 --
                 -- Setting the index
                 l_count := g_element_entries.count + 1;
                 -- Keeping the cumulated records into actual PL/SQL table
                 g_element_entries(l_count) := g_element_entries1(i);
                 --
              end loop;
              --
           end if;
           --
        -- Exiting, if the present fetch is NOT returning any new rows
        exit when (l_diff_collect = 0);
     --
     end loop;
  --
  close c_get_element;
  --
  return 1;
--
end Get_Element_Entry;
--
--
/* =====================================================================
   Name    : Get_Retro_Element
   Purpose : Retrieves retrospective elements in order for them to be
             tagged as processed.
             Overloaded version of function for use where element_entry_id
             context is unavailable.
   Returns : Element Entry ID
   ---------------------------------------------------------------------*/
function Get_Retro_Element return Number is

l_retro_entry_id   number;
l_count            number;

begin
--
  l_count := g_element_entries.count;

  if l_count > 0 then
  --
    l_retro_entry_id := g_element_entries(l_count);
    g_element_entries.delete(l_count);
  --
  end if;

  if l_retro_entry_id is null then
    return -1;
  else
    return l_retro_entry_id;
  end if;
--
end Get_Retro_Element;
--
/* =====================================================================
   Name    : Get_Net_Accrual
   Purpose : Wrapper function for per_accrual_calc_functions.get_net_accrual.
             Only returns accrued time figure.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Net_Accrual
(P_Assignment_ID                  IN  Number
,P_Payroll_ID                     IN  Number
,P_Business_Group_ID              IN  Number
,P_Assignment_Action_ID           IN  Number default null
,P_Calculation_Date               IN  Date
,P_Plan_ID                        IN  Number
,P_Accrual_Start_Date             IN  Date default null
,P_Accrual_Latest_Balance         IN  Number default null) return number is

l_proc               varchar2(72) := g_package||'Get_Net_Accrual';
l_start_date         date;
l_end_date           date;
l_accrual_start_date date;
l_accrual_end_date   date;
l_accrual            number;
l_net_entitlement    number;

begin
--
  hr_utility.set_location(l_proc, 5);

  if P_Accrual_Start_Date = hr_api.g_eot then
    -- The accrual start date database item returned null but Fast
    -- Formula defaulted it to the end of time. Re-set it back to null.
    l_accrual_start_date := null;
  else
    l_accrual_start_date := P_Accrual_Start_Date;
  end if;

  per_accrual_calc_functions.get_net_accrual(
                P_Assignment_ID      => P_Assignment_ID
               ,P_Plan_ID            => P_Plan_ID
               ,P_Payroll_ID         => P_Payroll_ID
               ,P_Business_Group_ID  => P_Business_Group_ID
               ,P_Assignment_Action_ID => P_Assignment_Action_ID
               ,P_Calculation_Date   => P_Calculation_Date
               ,P_Accrual_Start_Date => l_accrual_start_date
               ,P_Accrual_Latest_Balance => P_Accrual_Latest_Balance
               ,P_Calling_Point      => 'SQL'
               ,P_Start_Date         => l_start_date
               ,P_End_Date           => l_end_date
               ,P_Accrual_End_Date   => l_accrual_end_date
               ,P_Accrual            => l_accrual
               ,P_Net_Entitlement    => l_net_entitlement);

  hr_utility.set_location(l_proc, 10);

  return round(nvl(l_net_entitlement, 0), 5);
--
end Get_Net_Accrual;
--
--
/* =====================================================================
   Name    : Calculate_Hours_Worked
   Purpose : Calculates the total number of hours worked in a given date
             range.  Moved here to create global version as previously
	     only localised versions existed (Bug 2720878).
   Returns : Number of hours
   ---------------------------------------------------------------------*/
FUNCTION calculate_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS
--
  c_wkdays_per_week	NUMBER(5,2)		:= 5;
  c_wkdays_per_month	NUMBER(5,2)		:= 20;
  c_wkdays_per_year	NUMBER(5,2)		:= 250;

  /* 353434, 368242 : Fixed number width for total hours */
  v_total_hours	NUMBER(15,7) 	:= 0;
  v_wrkday_hours	NUMBER(15,7) 	:= 0;	 -- std hrs/wk divided by 5 workdays/wk
  v_curr_date	DATE			:= NULL;
  v_curr_day	VARCHAR2(3)		:= NULL; -- 3 char abbrev for day of wk.
  v_day_no        NUMBER;
--
BEGIN -- calculate_hours_worked
  --
  -- Check for valid range
  hr_utility.set_location('calculate_hours_worked', 5);
  IF p_range_start > p_range_end THEN
    hr_utility.set_location('calculate_hours_worked', 7);
    RETURN v_total_hours;
  --  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
  --  hr_utility.raise_error;
  END IF;
  --
  --
  IF UPPER(p_std_freq) = 'W' THEN
    v_wrkday_hours := p_std_hrs / c_wkdays_per_week;
  ELSIF UPPER(p_std_freq) = 'M' THEN
    v_wrkday_hours := p_std_hrs / c_wkdays_per_month;
  ELSIF UPPER(p_std_freq) = 'Y' THEN
    v_wrkday_hours := p_std_hrs / c_wkdays_per_year;
  ELSE
    v_wrkday_hours := p_std_hrs;
  END IF;
  --
  v_curr_date := p_range_start;

  hr_utility.set_location('calculate_hours_worked', 10);

           hr_utility.trace('p_range_start is'|| to_char(p_range_start));
           hr_utility.trace('p_range_end is'|| to_char(p_range_end));
  LOOP

    v_day_no := TO_CHAR(v_curr_date, 'D');

    hr_utility.set_location('calculate_hours_worked', 15);

    IF v_day_no > 1 and v_day_no < 7 then

      v_total_hours := v_total_hours + v_wrkday_hours;
      hr_utility.set_location('calculate_hours_worked v_total_hours = ', v_total_hours);
    END IF;
    v_curr_date := v_curr_date + 1;
    EXIT WHEN v_curr_date > p_range_end;
  END LOOP;
  --
           hr_utility.set_location('v_total_hours is', to_number(v_total_hours));
  RETURN v_total_hours;
  --
END calculate_hours_worked;
--
function Get_Payroll_ID
(P_Asg_ID            IN  Number
,P_Payroll_Id        IN  Number
,P_Date_In_Period    IN  Date) return number IS
--
l_proc        varchar2(72) := g_package||'Get_Payroll_ID';
--
cursor csr_get_payroll is
select payroll_id
from   per_all_assignments_f
where  assignment_id = P_asg_ID
and    P_Date_In_Period between effective_start_date
                            and effective_end_date;
--
l_payroll_id number;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   open csr_get_payroll;
   fetch csr_get_payroll into l_payroll_id;
   if csr_get_payroll%notfound then
      close csr_get_payroll;
      hr_utility.set_location('Payroll not found '||l_proc, 10);
      -- Since no payroll found for the assignment, using the context value
      l_payroll_id := P_Payroll_Id;
   elsif l_payroll_id is null then
      close csr_get_payroll;
      hr_utility.set_location('Payroll is null '||l_proc, 12);
      -- Since no payroll found for the assignment, using the context value
      l_payroll_id := P_Payroll_Id;
   end if;
   if csr_get_payroll%isopen then
      close csr_get_payroll;
   end if;
   --
   l_error := per_formula_functions.set_number
                                  ('LATEST_PAYROLL_ID',l_payroll_id);
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
   --
end Get_Payroll_ID;
--
--
function Get_Payroll_Details
(P_payroll_ID		IN  Number
,P_Date_In_Period	IN  Date) return number IS
--
l_proc        varchar2(72) := g_package||'Get_Payroll_Details';
--
cursor csr_get_payroll_period is
select start_date
,      end_date
,      period_num
from   per_time_periods
where  payroll_id = P_Payroll_ID
and    P_Date_In_Period between start_date and end_date;
--
l_start_date date;
l_end_date   date;
l_period_number number;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   open csr_get_payroll_period;
   fetch csr_get_payroll_period into l_start_date,l_end_date,l_period_number;
   if csr_get_payroll_period%notfound then
      close csr_get_payroll_period;
      hr_utility.set_location('Payroll Period not found '||l_proc, 10);
      l_error := per_formula_functions.raise_error(800, 'HR_52798_PTO_PAYROLL_INVALID');
      return 1;
   end if;
   close csr_get_payroll_period;
   --
   l_error := per_formula_functions.set_date
                 ('PAYROLL_PERIOD_START_DATE',l_start_date);
   l_error := per_formula_functions.set_date
                 ('PAYROLL_PERIOD_END_DATE',l_end_date);
   l_error := per_formula_functions.set_number
                 ('PAYROLL_PERIOD_NUMBER',l_period_number);
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
end Get_Payroll_Details;
--
--
--
-- 3267975 >>
/* =====================================================================
   Name    : cache_action_prms
   =====================================================================
   Purpose : Populates the PL/SQL table with the given parameter_name. If
             the table is already cached, the parameter is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_action_prms (p_prm_name in varchar2) is

   cursor csr_get_parameter is
     select parameter_name
           ,parameter_value
       from pay_action_parameters
      where parameter_name = p_prm_name;
--
  l_proc varchar2(80) := g_package||'cache_action_prms';
--
begin
--
   hr_utility.set_location('Entering: '||l_proc,5);

   if NOT g_actionPrm_cached then
     g_actionPrm_cache.sz := 0;
   end if;
--
   for actionPrm_rec in csr_get_parameter loop
--
     g_actionPrm_cache.sz := g_actionPrm_cache.sz + 1;
     g_actionPrm_cache.parameter_name(g_actionPrm_cache.sz) := actionPrm_rec.parameter_name;
     g_actionPrm_cache.parameter_value(g_actionPrm_cache.sz) := actionPrm_rec.parameter_value;
--
   end loop;
--
   g_actionPrm_cached := TRUE;
--
    hr_utility.set_location('Leaving: '||l_proc,88);
--
end cache_action_prms;
/* =====================================================================
   Name    : Get Cache ActionPrm
/* =====================================================================
   Purpose : Gets the event_id from a cached pl/sql table to prevent
             same reads of pay action parameters view.
   Returns : parameter value if found, null otherwise.
   ---------------------------------------------------------------------*/
function get_cache_ActionPrm(p_prm_name        in varchar2)
        return varchar2 is

--
  l_proc varchar2(80) := g_package||'get_cache_ActionPrm';
--
actionPrm_rec    number;
l_prm_value      PAY_ACTION_PARAMETER_VALUES.parameter_value%TYPE;

begin
--
   hr_utility.set_location('Entering: '||l_proc,5);

   for actionPrm_rec in 1..g_actionPrm_cache.sz loop

     if   (g_actionPrm_cache.parameter_name(actionPrm_rec) = p_prm_name)
     then
       l_prm_value := g_actionPrm_cache.parameter_value(actionPrm_rec);
     end if;

   end loop;
--
   hr_utility.set_location('Leaving: '||l_proc,88);
--
   return l_prm_value;
--
end get_cache_ActionPrm;
--
/* ========================================================================
   Name    : Get Action Parameter
   ========================================================================
   Purpose : Gets the Action Parameter from a cached pl/sql table to prevent
             same table scans on pay_action_parameters.
   Returns : parameter value.
   -----------------------------------------------------------------------*/
function get_action_parameter(p_prm_name      in varchar2)
                     return varchar2 is

l_prm_value  PAY_ACTION_PARAMETER_VALUES.parameter_value%TYPE;

begin
--
   if NOT g_actionPrm_cached then
     cache_action_prms (p_prm_name => p_prm_name);
   end if;

   l_prm_value := get_cache_ActionPrm (p_prm_name);

   return l_prm_value;
--
end get_action_parameter;
-- <<
-- 3267975 >>
/* =====================================================================
   Name    : Reset_PTO_Accruals
   =====================================================================
   Purpose : Determines whether the PTO accruals for an assignment
             should be recalculated from the beginning.
             This is based on RESET_PTO_ACCRUALS action parameter
   Returns : 'FALSE' or 'TRUE'
   ---------------------------------------------------------------------*/
function Reset_PTO_Accruals return varchar2 is

--
   l_proc        varchar2(72) := g_package||'Reset_PTO_Accruals';
--
   l_result PAY_ACTION_PARAMETER_VALUES.parameter_value%TYPE := 'N';
--

begin
   hr_utility.set_location('Entering: '||l_proc, 5);

   if NOT g_reset_pto_cache then
       l_result := Get_Action_Parameter('RESET_PTO_ACCRUALS');
       if nvl(l_result,'N') = 'Y' then
           g_reset_pto_accruals := 'TRUE';
       else
           g_reset_pto_accruals := 'FALSE';
       end if;
       g_reset_pto_cache := true;
   end if;
   hr_utility.set_location('Leaving: '||l_proc||' => RESET = '||g_reset_pto_accruals, 88);
   return g_reset_pto_accruals;

end Reset_PTO_Accruals;
-- <<
--
--
-- 3267975 >>
--
/* =====================================================================
   Name    : Get_Legislation
   =====================================================================
   Purpose : Retrieves the legislation code associated with
             business group.
   Returns : Legislation code.
   ---------------------------------------------------------------------*/
function get_legislation (p_business_group_id number)
   return varchar2 is

   cursor csr_getLegCode is
     select legislation_code
       from per_business_groups
       where organization_id = p_business_group_id;
--
  l_proc varchar2(80) := g_package||'get_legislation';
--
  l_legcode  HR_ORGANIZATION_INFORMATION.org_information9%TYPE;
--
begin
   if NOT g_legcode_cached then
       open csr_getLegCode;
       fetch csr_getLegCode into l_legcode;
       close csr_getLegCode;
       --
       g_legcode_cache := l_legcode;
       g_legcode_cached := TRUE;
       --
   end if;
   return g_legcode_cache;
end get_legislation;
--
/* =====================================================================
   Name    : Cache Events
   =====================================================================
   Purpose : Populates the PL/SQL table with the given event_name. If
             the table is already cached, the event is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_events (p_event_name in varchar2) is

  cursor csr_get_events is
  select e.event_group_id,
         e.event_group_name,
         e.business_group_id,
         e.legislation_code
  from   pay_event_groups e
  where  e.event_group_name = p_event_name;
--
  l_proc varchar2(80) := g_package||'cache_events';
--
begin
--

   if NOT g_events_cached then
     g_events_cache.sz := 0;
   end if;
--
   for events_rec in csr_get_events loop
--
     g_events_cache.sz := g_events_cache.sz + 1;
     g_events_cache.event_group_id(g_events_cache.sz) := events_rec.event_group_id;
     g_events_cache.event_group_name(g_events_cache.sz) := events_rec.event_group_name;
     g_events_cache.business_group_id(g_events_cache.sz) := events_rec.business_group_id;
     g_events_cache.legislation_code(g_events_cache.sz) := events_rec.legislation_code;
--
   end loop;
--
   g_events_cached := TRUE;
--
end cache_events;
/* =====================================================================
   Name    : Get Cache Event
/* =====================================================================
   Purpose : Gets the event_id from a cached pl/sql table to prevent
             same reads of PEM tables for each person in the
             payroll run.
   Returns : event_id if found, otherwise 0.
   ---------------------------------------------------------------------*/
function get_cache_event(p_event_name        in varchar2,
                         p_business_group_id in number,
                         p_legislation_code  in varchar2)
   return number is

event_rec    number;
l_event_id   number := 0;

begin
--

   for event_rec in 1..g_events_cache.sz loop

     if   (g_events_cache.event_group_name(event_rec) = p_event_name)
      and (nvl(g_events_cache.business_group_id(event_rec)
             , nvl(p_business_group_id,-1)) = nvl(p_business_group_id,-1))
      and (nvl(g_events_cache.legislation_code(event_rec)
             , nvl(p_legislation_code,'X')) = nvl(p_legislation_code,'X'))
     then
       l_event_id := g_events_cache.event_group_id(event_rec);
     end if;

   end loop;

   return l_event_id;
   -- This will be zero if the event is not in the cached events
--
end get_cache_event;
--
/* ========================================================================
   Name    : Get Event
   ========================================================================
   Purpose : Gets the event_group_id from a cached pl/sql table to prevent
             same table scans on pay_event_groups for each person in the
             payroll run.
   Returns : event_id if found, otherwise null.
   -----------------------------------------------------------------------*/
function get_event(p_event_name      in varchar2,
                   p_business_group_id in number,
                   p_legislation_code  in varchar2)
   return number is

l_event_id   number;

begin
--
   if NOT g_events_cached then
     cache_events (p_event_name => p_event_name);
   end if;

   l_event_id := get_cache_event (
                       p_event_name => p_event_name,
                       p_business_group_id => p_business_group_id,
                       p_legislation_code  => p_legislation_code
                       );

   return l_event_id;
   -- This will be zero if event does not exist
--
end get_event;
--
FUNCTION GET_PER_TERMINATION_DATE
(P_Assignment_id     IN  Number) return NUMBER IS
--
l_proc        varchar2(72) := g_package||'get_payroll_dtrange';
--
cursor csr_get_per_term_date is
  select max(actual_termination_date)
  FROM   per_all_assignments_f asg,
         per_periods_of_service pps
  where  asg.assignment_id = P_Assignment_id
    and  asg.period_of_service_id = pps.period_of_service_id;
--changes for bug 5749588 starts here
cursor csr_get_Asg_term_date is
  select max(EFFECTIVE_END_DATE)
  FROM   per_all_assignments_f asg
  where  asg.assignment_id = P_Assignment_id
  and asg.assignment_type<>'B';
--changes for bug 5749588 ends here

--
l_Per_date date;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   l_Per_date := NULL;
   open csr_get_per_term_date;
   fetch csr_get_per_term_date into l_Per_date;
   close csr_get_per_term_date;
   --
   if l_Per_date is not null THEN
     l_error := per_formula_functions.set_date
                 ('PER_TERMINATION_DATE',l_Per_date);
   else
--changes for bug 5749588 starts here
   open csr_get_Asg_term_date;
   fetch csr_get_Asg_term_date into l_Per_date;
   close csr_get_Asg_term_date;
--changes for bug 5749588 ends here
--   l_Per_date := hr_api.g_eot;
   l_error := per_formula_functions.set_date
                 ('PER_TERMINATION_DATE',l_Per_date);
     hr_utility.set_location(l_proc, 10);
--     return 1;
   end if;
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
end GET_PER_TERMINATION_DATE;
--
--
FUNCTION GET_PAYROLL_DTRANGE
(P_Payroll_ID                     IN  Number) return number IS
--
l_proc        varchar2(72) := g_package||'get_payroll_dtrange';
--
cursor csr_get_payroll_range is
select min(start_date),max(end_date)
from   per_time_periods
where  payroll_id = P_Payroll_ID;
--
l_start_date date;
l_end_date   date;
l_period_number number;
--
l_error number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   open csr_get_payroll_range;
   fetch csr_get_payroll_range into l_start_date,l_end_date;
   close csr_get_payroll_range;
   --
   if l_start_date is not null and l_end_date is not null then
     l_error := per_formula_functions.set_date
                 ('PAYROLL_MAX_START_DATE',l_start_date);
     l_error := per_formula_functions.set_date
                 ('PAYROLL_MAX_END_DATE',l_end_date);
   else
     hr_utility.set_location(l_proc, 10);
     return 1;
   end if;
   --
   hr_utility.set_location(l_proc, 15);
   return 0;
end GET_PAYROLL_DTRANGE;

--
/* =====================================================================
   Name    : Get_Earliest_AsgChange_Date
   =====================================================================
   Purpose : Determines the earliest assignment status change recorded
             by the Payroll Events Model.
   Returns : Date
   ---------------------------------------------------------------------*/
FUNCTION Get_Earliest_AsgChange_Date(p_business_group_id NUMBER
                                    ,p_assignment_id     NUMBER
                                    ,p_event_group       VARCHAR2
                                    ,p_start_date        DATE
                                    ,p_end_date          DATE
                                    ,p_recalc_date       DATE)
   RETURN DATE IS
--
    l_proc        varchar2(72) := g_package||'Get_Earliest_AsgChange_Date';
--

    l_recalc_date DATE;
    l_detailed_output       pay_interpreter_pkg.t_detailed_output_table_type;
    l_proration_dates       pay_interpreter_pkg.t_proration_dates_table_type;
    l_proration_change_type pay_interpreter_pkg.t_proration_type_table_type;
    l_proration_type        pay_interpreter_pkg.t_proration_type_table_type;

    l_event_group_id        pay_event_groups.event_group_id%TYPE;
    l_legislation_code      HR_ORGANIZATION_INFORMATION.org_information9%TYPE;

BEGIN
    hr_utility.set_location('Entering: '||l_proc, 5);

    l_recalc_date := p_recalc_date;
    l_legislation_code := get_legislation(p_business_group_id);

    l_event_group_id := get_event(p_event_group, p_business_group_id, l_legislation_code);

    IF l_event_group_id <> 0 THEN

       pay_interpreter_pkg.entry_affected
        (p_assignment_id         => p_assignment_id
        ,p_mode                  => 'DATE_PROCESSED'
        ,p_event_group_id        => l_event_group_id
        ,p_process_mode          => 'ENTRY_CREATION_DATE'
        ,p_start_date            => p_start_date
        ,p_end_date              => p_end_date
        ,t_detailed_output       => l_detailed_output
        ,t_proration_dates       => l_proration_dates
        ,t_proration_change_type => l_proration_change_type
        ,t_proration_type        => l_proration_type);

       IF l_detailed_output.COUNT <> 0 THEN

           FOR i IN l_detailed_output.FIRST..l_detailed_output.LAST LOOP

               IF l_detailed_output(i).effective_date < l_recalc_date THEN

                   l_recalc_date := l_detailed_output(i).effective_date;

               END IF;

           END LOOP;
       ELSE
           hr_utility.set_location(l_proc, 99);
       END IF;
    END IF;

    hr_utility.set_location('Leaving: '||l_proc, 88);

    RETURN l_recalc_date;

END Get_Earliest_AsgChange_Date;
--
--
--
end per_utility_functions;

/
