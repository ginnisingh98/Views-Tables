--------------------------------------------------------
--  DDL for Package Body PAY_GB_TAX_CREDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_TAX_CREDIT_PKG" AS
/* $Header: pygbtaxc.pkb 120.1.12000000.2 2007/05/17 14:14:52 kthampan noship $ */

--
-- Private declarations
--

g_package VARCHAR2(31) := 'PAY_GB_TAX_CREDIT_PKG';

FUNCTION Get_Input_Value_Id(
             p_name in VARCHAR2,
             p_effective_date in DATE
          ) RETURN NUMBER is
l_input_value_id PAY_INPUT_VALUES_F.input_value_id%TYPE;

BEGIN

  SELECT ipv.input_value_id INTO l_input_value_id
  FROM   PAY_INPUT_VALUES_F ipv,
         PAY_ELEMENT_TYPES_F ele
  WHERE  ele.element_name = 'Tax Credit'
  AND    ipv.name = p_name
  AND    ele.element_type_id = ipv.element_type_id
  AND    p_effective_date between ele.effective_start_date
                              and ele.effective_end_date
  AND    p_effective_date between ipv.effective_start_date
                              and ipv.effective_end_date;

RETURN l_input_value_id;

END Get_Input_Value_Id;

--
-- Public Declarations
--

FUNCTION Get_Element_Link_Id(
            p_assignment_id in NUMBER
              ) RETURN number is

Cursor c_effective_date is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('sessionid');

Cursor c_element_type is
   select element_type_id
   from   pay_element_types
   where  element_name = 'Tax Credit';

l_element_link_id  PAY_ELEMENT_LINKS_F.ELEMENT_LINK_ID%TYPE;
l_element_id       PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
l_create_warning   BOOLEAN;
l_effective_date   DATE;

BEGIN

Open  c_effective_date;
Fetch c_effective_date into l_effective_date;
Close c_effective_date;

Open  c_element_type;
Fetch c_element_type into l_element_id;
Close c_element_type;

l_element_link_id := hr_entry_api.get_link(
                           p_assignment_id,
                           l_element_id,
                           l_effective_date);
RETURN l_element_link_id;

END Get_Element_Link_Id;
--
--
--
PROCEDURE Check_Start_date(p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                           p_element_entry_id in PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE,
                           p_start_date in DATE,
                           p_element_name in VARCHAR2 default 'Tax Credit',
                           p_message out nocopy VARCHAR2) is
--
-- Note: Checks for errors first, then for warnings
-- finding one error stops validation, so user may get a succession of
-- different error messages as the date is entered.
--
cursor c_tax_credit_overlap(p_asg in NUMBER,
                            p_element_entry_id in NUMBER,
                            p_start_date in DATE,
                            p_ele in VARCHAR2
                           ) is
  Select 'Y'
  FROM   pay_element_entry_values_f eev1,
         pay_element_entry_values_f eev2,
         pay_element_entry_values_f eev3,
         pay_element_entries_f ent,
         pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_input_values_f ipv3,
         pay_element_links_f lnk,
         pay_element_types_f ele
  where  ele.element_name = p_ele
    and  ele.element_type_id = lnk.element_type_id
    and  ent.element_link_id = lnk.element_link_id
    and  ent.assignment_id = p_asg
    and  ipv1.element_type_id = ele.element_type_id
    and  ipv2.element_type_id = ele.element_type_id
    and  ipv3.element_type_id = ele.element_type_id
    and  ipv1.name = 'Start Date'
    and  ipv2.name = 'End Date'
    and  ipv3.name = 'Stop Date'
    and  ipv1.input_value_id = eev1.input_value_id
    and  ipv2.input_value_id = eev2.input_value_id
    and  ipv3.input_value_id = eev3.input_value_id
    and  eev1.element_entry_id = ent.element_entry_id
    and  eev2.element_entry_id = ent.element_entry_id
    and  eev3.element_entry_id = ent.element_entry_id
    and  (ent.element_entry_id <> p_element_entry_id
          or p_element_entry_id is null)
    and  eev1.screen_entry_value <= fnd_date.date_to_canonical(p_start_date)
    and  (eev3.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
      OR (eev3.screen_entry_value is NULL
          and  (eev2.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
                OR eev2.screen_entry_value is NULL )))
          and  p_start_date between
               eev1.effective_start_date and eev1.effective_end_date
          and  p_start_date between
               eev2.effective_start_date and eev2.effective_end_date
          and  p_start_date between
               eev3.effective_start_date and eev3.effective_end_date
          and  p_start_date between
               ent.effective_start_date and ent.effective_end_date
          and  p_start_date between
               lnk.effective_start_date and lnk.effective_end_date
          and  p_start_date between
               ele.effective_start_date and ele.effective_end_date
          and  p_start_date between
               ipv1.effective_start_date and ipv1.effective_end_date
          and  p_start_date between
               ipv2.effective_start_date and ipv2.effective_end_date
          and  p_start_date between
               ipv3.effective_start_date and ipv3.effective_end_date;

cursor c_student_loan_overlap(p_asg in NUMBER,
                            p_element_entry_id in NUMBER,
                            p_start_date in DATE,
                            p_ele in VARCHAR2
                           ) is
  Select 'Y'
  FROM   pay_element_entry_values_f eev1,
         pay_element_entry_values_f eev2,
         pay_element_entries_f ent,
         pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_element_links_f lnk,
         pay_element_types_f ele
  where  ele.element_name = p_ele
    and  ele.element_type_id = lnk.element_type_id
    and  ent.element_link_id = lnk.element_link_id
    and  ent.assignment_id = p_asg
    and  ipv1.element_type_id = ele.element_type_id
    and  ipv2.element_type_id = ele.element_type_id
    and  ipv1.name = 'Start Date'
    and  ipv2.name = 'End Date'
    and  ipv1.input_value_id = eev1.input_value_id
    and  ipv2.input_value_id = eev2.input_value_id
    and  eev1.element_entry_id = ent.element_entry_id
    and  eev2.element_entry_id = ent.element_entry_id
    and  (ent.element_entry_id <> p_element_entry_id
          or p_element_entry_id is null)
    and  eev1.screen_entry_value <= fnd_date.date_to_canonical(p_start_date)
    and  (eev2.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
      OR (eev2.screen_entry_value is NULL));

cursor c_tax_credit_starting(p_asg in NUMBER,
                             p_element_entry_id in NUMBER,
                             p_start_date in DATE,
                             p_ele in VARCHAR2) is
  Select 'Y'
  FROM   pay_element_entry_values_f eev1,
         pay_element_entry_values_f eev2,
         pay_element_entry_values_f eev3,
         pay_element_entries_f ent,
         pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_input_values_f ipv3,
         pay_element_links_f lnk,
         pay_element_types_f ele
  where  ele.element_name = p_ele
    and  ele.element_type_id = lnk.element_type_id
    and  ent.element_link_id = lnk.element_link_id
    and  ent.assignment_id = p_asg
    and  ipv1.element_type_id = ele.element_type_id
    and  ipv2.element_type_id = ele.element_type_id
    and  ipv3.element_type_id = ele.element_type_id
    and  ipv1.name = 'Start Date'
    and  ipv2.name = 'End Date'
    and  ipv3.name = 'Stop Date'
    and  ipv1.input_value_id = eev1.input_value_id
    and  ipv2.input_value_id = eev2.input_value_id
    and  ipv3.input_value_id = eev3.input_value_id
    and  eev1.element_entry_id = ent.element_entry_id
    and  eev2.element_entry_id = ent.element_entry_id
    and  eev3.element_entry_id = ent.element_entry_id
    and  (ent.element_entry_id <> p_element_entry_id
          or p_element_entry_id is null)
    and  eev1.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
    and  (eev3.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
      OR (eev3.screen_entry_value is NULL
          and  (eev2.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
                OR eev2.screen_entry_value is NULL )));

cursor c_student_loan_starting(p_asg in NUMBER,
                             p_element_entry_id in NUMBER,
                             p_start_date in DATE,
                             p_ele in VARCHAR2) is
  Select 'Y'
  FROM   pay_element_entry_values_f eev1,
         pay_element_entry_values_f eev2,
         pay_element_entries_f ent,
         pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_element_links_f lnk,
         pay_element_types_f ele
  where  ele.element_name = p_ele
    and  ele.element_type_id = lnk.element_type_id
    and  ent.element_link_id = lnk.element_link_id
    and  ent.assignment_id = p_asg
    and  ipv1.element_type_id = ele.element_type_id
    and  ipv2.element_type_id = ele.element_type_id
    and  ipv1.name = 'Start Date'
    and  ipv2.name = 'End Date'
    and  ipv1.input_value_id = eev1.input_value_id
    and  ipv2.input_value_id = eev2.input_value_id
    and  eev1.element_entry_id = ent.element_entry_id
    and  eev2.element_entry_id = ent.element_entry_id
    and  (ent.element_entry_id <> p_element_entry_id
          or p_element_entry_id is null)
    and  eev1.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
    and  (eev2.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
      OR (eev2.screen_entry_value is NULL));

cursor c_tax_credit_prior_to_runs(p_asg in NUMBER
                                  ) is
   select 'Y'
   from   per_time_periods ptp,
          pay_payroll_actions ppa,
          pay_assignment_actions paa,
          per_all_assignments_f asg
   where  asg.assignment_id = p_asg
     and  asg.payroll_id = ppa.payroll_id
     and  paa.assignment_id = asg.assignment_id
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  ptp.time_period_id = ppa.time_period_id
     and  ppa.action_type = 'R'
     and  ppa.action_status='C'
     and  ptp.end_date > p_start_date;

cursor c_terminated(p_asg in NUMBER) is
   select actual_termination_date,
          last_standard_process_date,
          final_process_date
   from   per_periods_of_service pos,
          fnd_sessions ses,
          per_all_assignments_f asg
   where  asg.assignment_id = p_asg
     and  ses.session_id = userenv('sessionid')
     and  ses.effective_date between asg.effective_start_date and asg.effective_end_date
     and  asg.person_id = pos.person_id
     and  ses.effective_date between pos.date_start and pos.last_standard_process_date
     and  pos.actual_termination_date is not null;

cursor c_periods_left(p_asg in NUMBER,
                      p_termination_date in DATE) is
   select count(*)
    from   per_time_periods ptp,
           per_all_assignments_f asg
    where  asg.assignment_id = p_asg
      and  asg.payroll_id = ptp.payroll_id
      and  ptp.end_date <= p_termination_date
      and  ptp.end_date >= p_start_date;

l_dummy VARCHAR2(2);
l_actual_termination_date DATE;
l_last_standard_process_date DATE;
l_final_process_date DATE;
l_date_to_check DATE;
l_periods_left NUMBER;
l_periods_within_check NUMBER := 3;




BEGIN

p_message := 'Passed';

if p_element_name = 'Tax Credit' then
open c_tax_credit_overlap(p_assignment_id, p_element_entry_id, p_start_date,p_element_name);
fetch c_tax_credit_overlap into l_dummy;

if c_tax_credit_overlap%FOUND then
   close c_tax_credit_overlap;
   p_message := 'HR_78002_TXC_TAXCREDIT_OVERLAP';
else
--
-- Nothing overlapping, continue with other validation
--
   close c_tax_credit_overlap;
--
-- Check that the start date of the entry is not before the latest
-- payroll run, in which case the tax credit will not be processed
--
open c_tax_credit_prior_to_runs(p_assignment_id);
fetch c_tax_credit_prior_to_runs into l_dummy;

if c_tax_credit_prior_to_runs%FOUND then
   close c_tax_credit_prior_to_runs;
   p_message := 'HR_78004_TXC_BEFORE_PAYROLL';
else
   close c_tax_credit_prior_to_runs;
--
-- No Runs exist, continue with other validation
--
--
-- Check to see if a tax credit is starting in the future, in which case,
-- the user must supply an end date before the start date of the future tax
-- credit
--
open c_tax_credit_starting(p_assignment_id, p_element_entry_id, p_start_date,p_element_name);
fetch c_tax_credit_starting into l_dummy;

if c_tax_credit_starting%FOUND then
   close c_tax_credit_starting;
      p_message := 'HR_78003_TXC_TAXCREDIT_START';
else
--
-- Nothing starting, continue with other validation
--
   close c_tax_credit_starting;

open c_terminated(p_assignment_id);
fetch c_terminated into l_actual_termination_date,
                        l_last_standard_process_date,
                        l_final_process_date;
if c_terminated%FOUND then
--
-- Employee has been terminated
-- Work out which date to check
--
   close c_terminated;
   if l_last_standard_process_date is not null then
      l_date_to_check := l_last_standard_process_date;
   else
      l_date_to_check := l_actual_termination_date;
   end if;
--
-- Count the remaining periods
--
   open c_periods_left(p_assignment_id, l_date_to_check);
   fetch c_periods_left into l_periods_left;
   if c_periods_left%NOTFOUND then
   --
   -- Shouldn't be possible!
   --
      null;
   end if;
   close c_periods_left;
   if l_periods_left < l_periods_within_check then
      p_message := 'HR_78005_TXC_TOO_FEW_PERIODS';
   end if;

else
  close c_terminated;

end if; -- Check for termination (Warning)
end if; -- Starting check (Warning)
end if; -- Payroll after Start Date check (Error)
end if; -- Overlap check (Error)

elsif p_element_name = 'Student Loan' then
--
-- Do validation for student loan Start Date
--
open c_student_loan_overlap(p_assignment_id, p_element_entry_id, p_start_date,p_element_name);
fetch c_student_loan_overlap into l_dummy;

if c_student_loan_overlap%FOUND then
   close c_student_loan_overlap;
   p_message := 'HR_78024_SLC_START_OVERLAP';
else
--
-- Nothing overlapping, continue with other validation
--
   close c_student_loan_overlap;
--
-- Check that the start date of the entry is not before the latest
-- payroll run, in which case the tax credit will not be processed
--
open c_tax_credit_prior_to_runs(p_assignment_id);
fetch c_tax_credit_prior_to_runs into l_dummy;

if c_tax_credit_prior_to_runs%FOUND then
   close c_tax_credit_prior_to_runs;
   p_message := 'HR_78025_SLC_START_PROCESSED';
else
   close c_tax_credit_prior_to_runs;
--
-- No Runs exist, continue with other validation
--
--
-- Check to see if a tax credit is starting in the future, in which case,
-- the user must supply an end date before the start date of the future tax
-- credit
--
open c_student_loan_starting(p_assignment_id, p_element_entry_id, p_start_date,p_element_name);
fetch c_student_loan_starting into l_dummy;

if c_student_loan_starting%FOUND then
   close c_student_loan_starting;
   p_message := 'HR_78026_SLC_START_NO_END';
else
--
-- Nothing starting, continue with other validation
--
   close c_student_loan_starting;
end if; -- check for student loan starting
end if; -- check for student loan prior to processing
end if; -- check for student loan overlap

end if; -- Which element type, tax credit or student loan
--
END Check_Start_Date;

PROCEDURE Check_End_Or_Stop_Date(p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                         p_element_entry_id in PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE,
                         p_end_date in DATE,
                         p_start_date in DATE,
                         p_element_name in PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
                         p_message out nocopy VARCHAR2) is

CURSOR c_end_after_start_date(p_asg in NUMBER,
                            p_element_entry_id in NUMBER,
                            p_end_date in DATE,
                            p_start_date in DATE,
                            p_ele in VARCHAR2
                           ) is
  Select 'Y'
  FROM   pay_element_entry_values_f eev1,
         pay_element_entry_values_f eev2,
         pay_element_entry_values_f eev3,
         pay_element_entries_f ent,
         pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_input_values_f ipv3,
         pay_element_links_f lnk,
         pay_element_types_f ele
  where  ele.element_name = p_ele
    and  ele.element_type_id = lnk.element_type_id
    and  ent.element_link_id = lnk.element_link_id
    and  ent.assignment_id = p_asg
    and  ipv1.element_type_id = ele.element_type_id
    and  ipv2.element_type_id = ele.element_type_id
    and  ipv3.element_type_id = ele.element_type_id
    and  ipv1.name = 'Start Date'
    and  ipv2.name = 'End Date'
    and  ipv3.name = 'Stop Date'
    and  ipv1.input_value_id = eev1.input_value_id
    and  ipv2.input_value_id = eev2.input_value_id
    and  ipv3.input_value_id = eev3.input_value_id
    and  eev1.element_entry_id = ent.element_entry_id
    and  eev2.element_entry_id = ent.element_entry_id
    and  eev3.element_entry_id = ent.element_entry_id
    and  (ent.element_entry_id <> p_element_entry_id
          or p_element_entry_id is null)
    and  eev1.screen_entry_value <= fnd_date.date_to_canonical(p_end_date)
    and  (eev3.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
      OR (eev3.screen_entry_value is NULL
          and  (eev2.screen_entry_value >= fnd_date.date_to_canonical(p_start_date)
                OR eev2.screen_entry_value is NULL )))
          and  p_start_date between
               eev1.effective_start_date and eev1.effective_end_date
          and  p_start_date between
               eev2.effective_start_date and eev2.effective_end_date
          and  p_start_date between
               eev3.effective_start_date and eev3.effective_end_date
          and  p_start_date between
               ent.effective_start_date and ent.effective_end_date
          and  p_start_date between
               lnk.effective_start_date and lnk.effective_end_date
          and  p_start_date between
               ele.effective_start_date and ele.effective_end_date
          and  p_start_date between
               ipv1.effective_start_date and ipv1.effective_end_date
          and  p_start_date between
               ipv2.effective_start_date and ipv2.effective_end_date
          and  p_start_date between
               ipv3.effective_start_date and ipv3.effective_end_date;

CURSOR c_before_a_payroll_run(p_asg in NUMBER
                                  ) is
   select 'Y'
   from   per_time_periods ptp,
          pay_payroll_actions ppa,
          per_all_assignments_f asg
   where  asg.assignment_id = p_asg
     and  asg.payroll_id = ppa.payroll_id
     and  ptp.time_period_id = ppa.time_period_id
     and  ppa.action_type = 'R'
     and  ppa.action_status='C'
     and  ptp.end_date > p_end_date;


l_dummy VARCHAR2(2);

BEGIN

p_message := 'Passed';

open c_end_after_start_date(p_assignment_id,
                            p_element_entry_id,
                            p_end_date,
                            p_start_date,
                            p_element_name);

fetch c_end_after_start_date into l_dummy;

if c_end_after_start_date%FOUND then
  close c_end_after_start_date;
  if p_element_name = 'Tax Credit' then
     p_message := 'HR_78008_TXC_END_DATE_OVERLAP';
  elsif p_element_name = 'Student Loan' then
     p_message := 'HR_78027_SLC_END_DATE_OVERLAP';
  end if;
else
  close c_end_after_start_date;
--
-- End Date Not overlapping, continue with other validation
--
open c_before_a_payroll_run(p_assignment_id);
fetch c_before_a_payroll_run into l_dummy;
if c_before_a_payroll_run%FOUND then
  close c_before_a_payroll_run;
  if p_element_name = 'Tax Credit' then
     p_message := 'HR_78017_TXC_ENDDATE_BEF_PROC';
  elsif p_element_name = 'Student Loan' then
     p_message := 'HR_78028_SLC_END_BEF_PROC';
  end if;
else
  close c_before_a_payroll_run;
end if;
--
-- Currently not before a payroll run, continue with other validation
--
end if; -- End date overlapping


END Check_End_Or_Stop_Date;

PROCEDURE Check_Delete_Possible(
                       p_datetrack_mode in VARCHAR2,
                       p_effective_date in DATE,
                       p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                       p_start_date in DATE,
                       p_end_date in DATE,
                       p_message out nocopy VARCHAR2) is

cursor c_purge_allowed(p_asg in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE) is
   select max(effective_date)
   from   pay_payroll_actions ppa,
          pay_assignment_actions paa,
          per_all_assignments_f asg
   where  asg.assignment_id = p_asg
     and  asg.assignment_id = paa.assignment_id
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  asg.payroll_id = ppa.payroll_id
     and  ppa.action_type = 'R'
     and  ppa.action_status='C';

cursor c_end_date_allowed(p_asg in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                          p_date in DATE) is
   select /*+ ORDERED
              INDEX(ptp PER_TIME_PERIODS_PK) */ 'Y'
   from   per_all_assignments_f asg,
          pay_payroll_actions ppa,
          per_time_periods ptp
   where  asg.assignment_id = p_asg
     and  asg.payroll_id = ppa.payroll_id
     and  ptp.time_period_id = ppa.time_period_id
     and  ppa.action_type = 'R'
     and  ppa.action_status='C'
     and  ptp.end_date > p_date;

l_purge_date DATE;
l_dummy VARCHAR2(2);

BEGIN

p_message := 'Passed';

--
-- If the datetrack mode is purge, then see if there are any
-- processed entries, perhaps ought to check through entries
-- that these have been processed, but I think it is enough
-- just to check for later payroll runs.
--

if p_datetrack_mode = 'ZAP' then

open c_purge_allowed(p_assignment_id);
fetch c_purge_allowed into l_purge_date;

  if c_purge_allowed%FOUND then
    close c_purge_allowed;
    if p_start_date < l_purge_date then
       p_message := 'HR_78014_TXC_NO_PURGE';
    end if;
  else
    close c_purge_allowed;
  end if;

elsif p_datetrack_mode = 'DELETE' then

open c_end_date_allowed(p_assignment_id, p_effective_date);
fetch c_end_date_allowed into l_dummy;

  if c_end_date_allowed%FOUND then
    close c_end_date_allowed;
    p_message := 'HR_78015_TXC_NO_END_DATE';
  else
    close c_end_date_allowed;
  end if;

end if;

End Check_Delete_Possible;


Procedure Check_Daily_Rate(
               p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
               p_start_date in DATE,
               p_message out nocopy VARCHAR2
               ) is

cursor c_processed(p_asg in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                          p_date in DATE) is
   select 'Y'
   from   pay_payroll_actions ppa,
          per_all_assignments_f asg
   where  asg.assignment_id = p_asg
     and  asg.payroll_id = ppa.payroll_id
     and  ppa.action_type = 'R'
     and  ppa.action_status='C'
     and  ppa.effective_date > p_date;


l_dummy VARCHAR2(2);

BEGIN

p_message := 'Passed';

open c_processed(p_assignment_id, p_start_date);
fetch c_processed into l_dummy;

if c_processed%FOUND then
   close c_processed;
   p_message := 'HR_78016_TXC_DAILY_RATE_PROC';
else
   close c_processed;
end if;

END Check_Daily_Rate;

PROCEDURE Fetch_Balances(
            p_assignment_id in PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE,
            p_element_entry_id in PAY_RUN_RESULTS.SOURCE_ID%TYPE,
            p_itd_balance   OUT NOCOPY NUMBER,
            p_ptd_balance   OUT NOCOPY NUMBER
             ) is

cursor c_balance_id is
  select balance_type_id
  from   pay_balance_types
  where  balance_name = 'Tax Credit';

cursor c_itd_asgact(p_asg in NUMBER,
                    p_ent_id in NUMBER) is
 select prr.assignment_action_id,
        prr.source_id
 from   pay_run_results prr,
        pay_element_types_f ele
 where  prr.assignment_action_id in (
 SELECT to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                  paa.assignment_action_id),16))
 FROM   pay_assignment_actions paa,
        pay_payroll_actions    ppa,
        per_time_periods       ptp,
        fnd_sessions           ses
 WHERE  paa.assignment_id = p_asg
 AND    ses.session_id = userenv('sessionid')
 AND    ppa.payroll_action_id = paa.payroll_action_id
 AND    ses.effective_date between ptp.start_date and ptp.end_date
 AND    ppa.time_period_id = ptp.time_period_id
 AND    ppa.action_type in ('R', 'Q', 'I', 'V', 'B'))
 AND    prr.element_type_id = ele.element_type_id
 AND    ele.element_name = 'Tax Credit'
 AND    prr.source_id = p_ent_id;

-- BUG 3221422 Changed Query for improving performance
cursor c_ptd_asgact(p_asg in NUMBER,
                    p_ent in NUMBER) is
select prr.assignment_action_id,
         prr.source_id
  from   pay_run_results prr,
         pay_element_types_f ele
  where  prr.assignment_action_id in (
  select to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                   paa.assignment_action_id),16))
  from   pay_assignment_actions paa,
         pay_payroll_actions    ppa,
         fnd_sessions           ses,
         per_time_periods       ptp,
         per_all_assignments    per
  where  paa.assignment_id = p_asg
  and    ses.session_id = userenv('sessionid')
  and    ptp.payroll_id = ppa.payroll_id
  and    ses.effective_date between ptp.start_date and ptp.end_date
  and    ppa.effective_date between ptp.start_date and ptp.end_date
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
  and    ppa.payroll_id = per.payroll_id
  and    paa.assignment_id = per.assignment_id
  and    ses.effective_date between per.effective_start_date and per.effective_end_date)
  and    prr.element_type_id = ele.element_type_id
  and    ele.element_name = 'Tax Credit'
  and    prr.source_id = p_ent;

l_proc VARCHAR(72) := g_package||'.FETCH_BALANCES';
l_itd_action_id PAY_ASSIGNMENT_ACTIONS.assignment_action_id%TYPE;
l_itd_source_id PAY_RUN_RESULTS.source_id%TYPE;
l_ptd_action_id PAY_ASSIGNMENT_ACTIONS.assignment_action_id%TYPE;
l_ptd_source_id PAY_RUN_RESULTS.source_id%TYPE;
l_balance_type_id PAY_BALANCE_TYPES.balance_type_id%TYPE;
l_effective_date DATE;

BEGIN

hr_utility.set_location('Entering..'||l_proc,10);

open c_balance_id;
fetch c_balance_id into l_balance_type_id;
close c_balance_id;

open c_ptd_asgact(p_assignment_id,p_element_entry_id);
fetch c_ptd_asgact into l_ptd_action_id,l_ptd_source_id;

if c_ptd_asgact%NOTFOUND then
   p_ptd_balance := NULL;
   close c_ptd_asgact;
else
   p_ptd_balance := hr_gbbal.calc_element_ptd_bal(
                      l_ptd_action_id,
                      l_balance_type_id,
                      l_ptd_source_id);
   close c_ptd_asgact;
end if;

open c_itd_asgact(p_assignment_id,p_element_entry_id);
fetch c_itd_asgact into l_itd_action_id,l_itd_source_id;

if c_itd_asgact%NOTFOUND then
   p_itd_balance := NULL;
   close c_itd_asgact;
else
   p_itd_balance := hr_gbbal.calc_element_itd_bal(
                      l_itd_action_id,
                      l_balance_type_id,
                      l_itd_source_id);
   close c_itd_asgact;
end if;

hr_utility.set_location('leaving..'||l_proc,20);

END Fetch_Balances;


PROCEDURE Create_Tax_Credit(
            p_effective_date in DATE
           ,p_business_group_id in NUMBER
           ,p_assignment_id in NUMBER
           ,p_element_link_id in NUMBER
           ,p_reference in VARCHAR2
           ,p_start_date in VARCHAR2
           ,p_end_date in VARCHAR2
           ,p_daily_amount in VARCHAR2
           ,p_total_amount in VARCHAR2
           ,p_stop_date in VARCHAR2
           ,p_reference_ipv_id in NUMBER
           ,p_start_date_ipv_id in NUMBER
           ,p_end_date_ipv_id in NUMBER
           ,p_daily_amount_ipv_id in NUMBER
           ,p_total_amount_ipv_id in NUMBER
           ,p_stop_date_ipv_id in NUMBER
           ,p_from in DATE
           ,p_to in DATE
           ,p_effective_start_date out nocopy DATE
           ,p_effective_end_date out nocopy DATE
           ,p_element_entry_id out nocopy NUMBER
           ,p_object_version_number out nocopy NUMBER) is

l_create_warning BOOLEAN;

BEGIN

py_element_entry_api.create_element_entry(
 P_VALIDATE                  =>FALSE,
 P_EFFECTIVE_DATE            =>p_effective_date,
 P_BUSINESS_GROUP_ID         =>p_business_group_id,
 P_ORIGINAL_ENTRY_ID         =>NULL,
 P_ASSIGNMENT_ID             =>p_assignment_id,
 P_ELEMENT_LINK_ID           =>p_element_link_id,
 P_ENTRY_TYPE                =>'E',
 P_COST_ALLOCATION_KEYFLEX_ID=>NULL,
 P_UPDATING_ACTION_ID        =>NULL,
 P_COMMENT_ID                =>NULL,
 P_REASON                    =>NULL,
 P_TARGET_ENTRY_ID           =>NULL,
 P_SUBPRIORITY               =>NULL,
 P_DATE_EARNED               =>NULL,
 P_PERSONAL_PAYMENT_METHOD_ID=>NULL,
 P_ATTRIBUTE_CATEGORY        =>NULL,
 P_ATTRIBUTE1                =>NULL,
 P_ATTRIBUTE2                =>NULL,
 P_ATTRIBUTE3                =>NULL,
 P_ATTRIBUTE4                =>NULL,
 P_ATTRIBUTE5                =>NULL,
 P_ATTRIBUTE6                =>NULL,
 P_ATTRIBUTE7                =>NULL,
 P_ATTRIBUTE8                =>NULL,
 P_ATTRIBUTE9                =>NULL,
 P_ATTRIBUTE10               =>NULL,
 P_ATTRIBUTE11               =>NULL,
 P_ATTRIBUTE12               =>NULL,
 P_ATTRIBUTE13               =>NULL,
 P_ATTRIBUTE14               =>NULL,
 P_ATTRIBUTE15               =>NULL,
 P_ATTRIBUTE16               =>NULL,
 P_ATTRIBUTE17               =>NULL,
 P_ATTRIBUTE18               =>NULL,
 P_ATTRIBUTE19               =>NULL,
 P_ATTRIBUTE20               =>NULL,
 P_INPUT_VALUE_ID1           =>Get_Input_Value_Id('Reference',
                                            p_effective_date),
 P_INPUT_VALUE_ID2           =>Get_Input_Value_Id('Start Date',
                                            p_effective_date),
 P_INPUT_VALUE_ID3           =>Get_Input_Value_Id('End Date',
                                            p_effective_date),
 P_INPUT_VALUE_ID4           =>Get_Input_Value_Id('Daily Amount',
                                            p_effective_date),
 P_INPUT_VALUE_ID5           =>Get_Input_Value_Id('Total Amount',
                                            p_effective_date),
 P_INPUT_VALUE_ID6           =>Get_Input_Value_Id('Stop Date',
                                            p_effective_date),
 P_INPUT_VALUE_ID7           =>NULL,
 P_INPUT_VALUE_ID8           =>NULL,
 P_INPUT_VALUE_ID9           =>NULL,
 P_INPUT_VALUE_ID10          =>NULL,
 P_INPUT_VALUE_ID11          =>NULL,
 P_INPUT_VALUE_ID12          =>NULL,
 P_INPUT_VALUE_ID13          =>NULL,
 P_INPUT_VALUE_ID14          =>NULL,
 P_INPUT_VALUE_ID15          =>NULL,
 P_ENTRY_VALUE1              =>p_reference,
 P_ENTRY_VALUE2              =>p_start_date,
 P_ENTRY_VALUE3              =>p_end_date,
 P_ENTRY_VALUE4              =>p_daily_amount,
 P_ENTRY_VALUE5              =>p_total_amount,
 P_ENTRY_VALUE6              =>p_stop_date,
 P_ENTRY_VALUE7              =>NULL,
 P_ENTRY_VALUE8              =>NULL,
 P_ENTRY_VALUE9              =>NULL,
 P_ENTRY_VALUE10             =>NULL,
 P_ENTRY_VALUE11             =>NULL,
 P_ENTRY_VALUE12             =>NULL,
 P_ENTRY_VALUE13             =>NULL,
 P_ENTRY_VALUE14             =>NULL,
 P_ENTRY_VALUE15             =>NULL,
 P_EFFECTIVE_START_DATE      =>p_effective_start_date,
 P_EFFECTIVE_END_DATE        =>p_effective_end_date,
 P_ELEMENT_ENTRY_ID          =>p_element_entry_id,
 P_OBJECT_VERSION_NUMBER     =>p_object_version_number,
 P_CREATE_WARNING            =>l_create_warning);

END Create_Tax_Credit;

PROCEDURE Delete_Tax_Credit(
            p_datetrack_mode in VARCHAR2
           ,p_element_entry_id in NUMBER
           ,p_effective_date in DATE
           ,p_object_version_number in NUMBER) IS

 l_object_version_number NUMBER;
 l_effective_start_date DATE;
 l_effective_end_date DATE;
 l_delete_warning BOOLEAN;

BEGIN

l_object_version_number := p_object_version_number;

py_element_entry_api.delete_element_entry(
    p_validate => FALSE,
    p_datetrack_delete_mode => p_datetrack_mode,
    p_effective_date => p_effective_date,
    p_element_entry_id => p_element_entry_id,
    p_object_version_number => l_object_version_number,
    p_effective_start_date => l_effective_start_date,
    p_effective_end_date => l_effective_end_date,
    p_delete_warning => l_delete_warning
    );

END Delete_Tax_Credit;
--
-- Update_Tax_Credit process
--
PROCEDURE Update_Tax_Credit(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_reference in VARCHAR2
           ,p_start_date in VARCHAR2
           ,p_end_date in VARCHAR2
           ,p_daily_amount in VARCHAR2
           ,p_total_amount in VARCHAR2
           ,p_stop_date in VARCHAR2
           ,p_reference_ipv_id in NUMBER
           ,p_start_date_ipv_id in NUMBER
           ,p_end_date_ipv_id in NUMBER
           ,p_daily_amount_ipv_id in NUMBER
           ,p_total_amount_ipv_id in NUMBER
           ,p_stop_date_ipv_id in NUMBER
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date) is

l_update_warning BOOLEAN;

BEGIN

py_element_entry_api.update_element_entry(
    p_validate => FALSE,
    p_datetrack_update_mode => p_datetrack_update_mode,
    p_effective_date => p_effective_date,
    p_business_group_id => p_business_group_id,
    p_element_entry_id => p_element_entry_id,
    p_object_version_number => p_object_version_number,
    P_INPUT_VALUE_ID1           =>Get_Input_Value_Id('Reference',
                                               p_effective_date),
    P_INPUT_VALUE_ID2           =>Get_Input_Value_Id('Start Date',
                                               p_effective_date),
    P_INPUT_VALUE_ID3           =>Get_Input_Value_Id('End Date',
                                               p_effective_date),
    P_INPUT_VALUE_ID4           =>Get_Input_Value_Id('Daily Amount',
                                               p_effective_date),
    P_INPUT_VALUE_ID5           =>Get_Input_Value_Id('Total Amount',
                                               p_effective_date),
    P_INPUT_VALUE_ID6           =>Get_Input_Value_Id('Stop Date',
                                               p_effective_date),
    P_ENTRY_VALUE1              =>p_reference,
    P_ENTRY_VALUE2              =>p_start_date,
    P_ENTRY_VALUE3              =>p_end_date,
    P_ENTRY_VALUE4              =>p_daily_amount,
    P_ENTRY_VALUE5              =>p_total_amount,
    P_ENTRY_VALUE6              =>p_stop_date,
    P_EFFECTIVE_START_DATE      =>p_effective_start_date,
    P_EFFECTIVE_END_DATE        =>p_effective_end_date,
    P_UPDATE_WARNING            =>l_update_warning);
--
-- Done the update
--
END Update_Tax_Credit;

END PAY_GB_TAX_CREDIT_PKG;

/
