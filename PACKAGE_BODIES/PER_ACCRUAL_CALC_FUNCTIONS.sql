--------------------------------------------------------
--  DDL for Package Body PER_ACCRUAL_CALC_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ACCRUAL_CALC_FUNCTIONS" as
/* $Header: peaclcal.pkb 120.6.12010000.5 2009/02/26 13:40:56 sgundoju ship $ */
--
-- Start of fix 3222662
Type g_entry_value is table of
     pay_element_entry_values_f.screen_entry_value%Type
     index by binary_integer;
Type g_add_subtract is table of pay_net_calculation_rules.add_or_subtract%Type
     index by binary_integer;
Type g_effective_date is table of date index by binary_integer;
-- End of 3222662
--
g_package  varchar2(50) := '  per_accrual_calc_functions.';  -- Global package name

/* =====================================================================
   Name    : Calculate_Accrual
   Purpose : Determines whether an assignment is enrolled in a plan, and
	     if so, executes the formula to calculate the accrual for
	     the plan(s).
   ---------------------------------------------------------------------*/
procedure Calculate_Accrual
(P_Assignment_ID                  IN Number
,P_Plan_ID                        IN Number
,P_Payroll_ID                     IN Number
,P_Business_Group_ID              IN Number
,P_Accrual_formula_ID             IN Number
,P_Assignment_Action_ID           IN Number default null
,P_Calculation_Date               IN Date
,P_Accrual_Start_Date             IN Date default null
,P_Accrual_Latest_Balance         IN Number default null
,P_Total_Accrued_PTO              OUT NOCOPY Number
,P_Effective_Start_Date           OUT NOCOPY Date
,P_Effective_End_Date             OUT NOCOPY Date
,P_Accrual_End_date               OUT NOCOPY Date) is
--
/* CHECK VALIDITY OF ABOVE PARAMS */

l_proc        varchar2(72) := g_package||'Calculate_Accrual';
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;

begin
--
  hr_utility.set_location('Entering '||l_proc, 5);
  --
  l_inputs(1).name := 'ASSIGNMENT_ID';
  l_inputs(1).value := p_assignment_id;
  l_inputs(2).name := 'DATE_EARNED';
  l_inputs(2).value := fnd_date.date_to_canonical(p_calculation_date);
  l_inputs(3).name := 'ACCRUAL_PLAN_ID';
  l_inputs(3).value := p_plan_id;
  l_inputs(4).name := 'BUSINESS_GROUP_ID';
  l_inputs(4).value := p_business_group_id;
  l_inputs(5).name := 'PAYROLL_ID';
  l_inputs(5).value := p_payroll_id;
  l_inputs(6).name := 'CALCULATION_DATE';
  l_inputs(6).value := fnd_date.date_to_canonical(p_calculation_date);
  l_inputs(7).name := 'ACCRUAL_START_DATE';
  l_inputs(7).value := fnd_date.date_to_canonical(p_accrual_start_date);
  l_inputs(8).name := 'ASSIGNMENT_ACTION_ID';
  l_inputs(8).value := p_assignment_action_id;
  l_inputs(9).name := 'ACCRUAL_LATEST_BALANCE';
  l_inputs(9).value := p_accrual_latest_balance;

  l_outputs(1).name := 'TOTAL_ACCRUED_PTO';
  l_outputs(2).name := 'EFFECTIVE_START_DATE';
  l_outputs(3).name := 'EFFECTIVE_END_DATE';
  l_outputs(4).name := 'ACCRUAL_END_DATE';

  per_formula_functions.run_formula(p_formula_id => p_accrual_formula_id,
				   p_calculation_date => p_calculation_date,
				   p_inputs => l_inputs,
				   p_outputs => l_outputs);

  -- Bug fix 4004565
  -- Fast formula output p_total_accrued_pto converted to number using
  -- fnd_number.canonical_to_number function

  p_total_accrued_pto := fnd_number.canonical_to_number(l_outputs(1).value);
  p_effective_start_date := fnd_date.canonical_to_date(l_outputs(2).value);
  p_effective_end_date := fnd_date.canonical_to_date(l_outputs(3).value);
  p_accrual_end_date := fnd_date.canonical_to_date(l_outputs(4).value);
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
--
end Calculate_Accrual;

--
/* =====================================================================
   Name    : Get_Accrual
   Purpose :
   Returns : Total Accrual
   ---------------------------------------------------------------------*/
procedure Get_Accrual
(P_Assignment_ID               IN  Number
,P_Calculation_Date            IN  Date
,P_Plan_ID                     IN  Number
,P_Business_Group_ID           IN  Number
,P_Payroll_ID                  IN  Number
,P_Assignment_Action_ID        IN  Number default null
,P_Accrual_Start_Date          IN Date default null
,P_Accrual_Latest_Balance      IN Number default null
,P_Start_Date                  OUT NOCOPY Date
,P_End_Date                    OUT NOCOPY Date
,P_Accrual_End_Date            OUT NOCOPY Date
,P_Accrual                     OUT NOCOPY number) is

l_proc                        varchar2(72) := g_package||'Get_Accrual';
l_accrual_plan_rec            g_accrual_plan_rec_type;
l_accrual_for_plan            number := 0;
l_effective_start_date        date;
l_effective_end_date          date;
l_accrual_end_date            date;
l_enrolled_in_plan            boolean;

begin
--
  hr_utility.set_location('Entering '||l_proc, 5);

  l_accrual_plan_rec := get_accrual_plan(p_plan_id);

  l_Enrolled_In_Plan := check_assignment_enrollment(
				 p_assignment_id
                                ,l_accrual_plan_rec.accrual_plan_element_type_id
                                ,p_calculation_date);

  if l_enrolled_in_plan then
  --
    calculate_accrual(p_assignment_id => p_assignment_id,
                    p_plan_id => p_plan_id,
		    p_payroll_id => p_payroll_id,
		    p_business_group_id => p_business_group_id,
                    p_accrual_formula_id => l_accrual_plan_rec.accrual_formula_id,
                    p_assignment_action_id => p_assignment_action_id,
                    p_calculation_date => p_calculation_date,
                    p_accrual_start_date => p_accrual_start_date,
                    p_accrual_latest_balance => p_accrual_latest_balance,
                    p_total_accrued_pto => l_accrual_for_plan,
                    p_effective_start_date => l_effective_start_date,
                    p_effective_end_date => l_effective_end_date,
		    p_accrual_end_date => l_accrual_end_date
		    );

    --
    -- Set the return values of the out parameters
    --

    p_start_date := l_effective_start_date;
    p_end_date := l_effective_end_date;
    p_accrual_end_date := l_accrual_end_date;
    p_accrual := l_accrual_for_plan;

  --
  else
  --
    p_start_date := null;
    p_end_date := null;
    p_accrual_end_date := null;
    p_accrual := 0;
  --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
--
end Get_Accrual;

--
/* =====================================================================
   Name    : Get_Accrual_Plan
   Purpose :
   Returns : Table of Accrual Plan Details
   ---------------------------------------------------------------------*/
function Get_Accrual_Plan
(P_Plan_ID IN Number) RETURN g_accrual_plan_rec_type is
--
  cursor c_accrual_plan_details is
  select accrual_plan_element_type_id,
	 accrual_formula_id
  from pay_accrual_plans
  where accrual_plan_id = p_plan_id;

  l_proc               varchar2(72) := g_package||'Get_Accrual_Plan';
  l_accrual_plan_rec   g_accrual_plan_rec_type;

begin
--
  hr_utility.set_location('Entering '||l_proc, 5);

 hr_utility.trace('plan_id = '||to_char(p_plan_id));
  open c_accrual_plan_details;
  fetch c_accrual_plan_details into l_accrual_plan_rec.accrual_plan_element_type_id,
				    l_accrual_plan_rec.accrual_formula_id;
  close c_accrual_plan_details;

  hr_utility.set_location('Leaving '||l_proc, 10);

  return l_accrual_plan_rec;
--
end Get_Accrual_Plan;

--

/* =====================================================================
   Name    : Check_Assignment_Enrollment
   Purpose :
   Returns : True if assignment is enrolled, otherwise false.
   ---------------------------------------------------------------------*/
function Check_Assignment_Enrollment
(P_Assignment_ID                  IN  Number
,P_Accrual_Plan_Element_Type_ID   IN  Number
,P_Calculation_Date               IN  Date) return Boolean is

  cursor c_enrolled is
  select 1
  from pay_element_entries_f pee,
       pay_element_links_f pel,
       pay_element_types_f pet
  where pel.element_link_id = pee.element_link_id
  and   pel.element_type_id = pet.element_type_id
  and   pee.assignment_id = p_assignment_id
  and   pet.element_type_id = p_accrual_plan_element_type_id
  and   p_calculation_date between pee.effective_start_date
			   and pee.effective_end_date;

  l_proc        varchar2(72) := g_package||'Check_Assignment_Enrollment';
  l_enrolled    boolean;
  l_dummy       c_enrolled%rowtype;

begin
--
  hr_utility.set_location('Entering '||l_proc, 5);

  open c_enrolled;
  fetch c_enrolled into l_dummy;

  l_enrolled := c_enrolled%found;

  close c_enrolled;

  hr_utility.set_location('Leaving '||l_proc, 10);

  return l_enrolled;
--
end Check_Assignment_Enrollment;
--
/* =====================================================================
   Name    : Get_Carry_Over_Values
   Purpose :
 Returns : Max Carry over and effective date of carry over. Used by
     carry over process.
 ---------------------------------------------------------------------*/
procedure Get_Carry_Over_Values
(P_CO_Formula_ID             IN   Number
,P_Assignment_ID             IN   Number
,P_Accrual_Plan_ID           IN   Number
,P_Business_Group_ID         IN   Number
,P_Payroll_ID                IN   Number
,P_Calculation_Date          IN   Date
,P_Session_Date              IN   Date
,P_Accrual_Term              IN   Varchar2
,P_Effective_Date            OUT NOCOPY  Date
,P_Expiry_Date               OUT NOCOPY  Date
,P_Max_Carry_Over            OUT NOCOPY  Number) is

  l_proc          varchar2(72) := g_package||'Get_Carry_Over_Values';
  l_inputs  ff_exec.inputs_t;
  l_outputs ff_exec.outputs_t;
  l_p_calculation_date date; -- Added for the bug6354665
  l_accrual_start   varchar2(1); -- Added for the bug 6354665

  -- Code change for the bug 6354665 starts here

  CURSOR csr_emp_asg_act is
  select null from
  per_all_assignments_f asg,
  per_periods_of_service pps
  where asg.assignment_id = P_Assignment_ID
  and P_calculation_date between asg.effective_start_date
  and asg.effective_end_date
  and asg.period_of_service_id = pps.period_of_service_id;

  -- Code change for the bug 6354665 ends here

begin
--
  hr_utility.set_location('Entering '||l_proc, 5);



  l_inputs(1).name := 'ASSIGNMENT_ID';
  l_inputs(1).value := p_assignment_id;
  l_inputs(2).name := 'DATE_EARNED';
  l_inputs(2).value := fnd_date.date_to_canonical(P_calculation_date);
  l_inputs(3).name := 'ACCRUAL_PLAN_ID';
  l_inputs(3).value := p_accrual_plan_id;
  l_inputs(4).name := 'PAYROLL_ID';
  l_inputs(4).value := p_payroll_id;
  l_inputs(5).name := 'BUSINESS_GROUP_ID';
  l_inputs(5).value := p_business_group_id;
  l_inputs(6).name := 'CALCULATION_DATE';
  l_inputs(6).value := fnd_date.date_to_canonical(p_calculation_date);
  l_inputs(7).name := 'ACCRUAL_TERM';
  l_inputs(7).value := p_accrual_term;

  l_outputs(1).name := 'MAX_CARRYOVER';
  l_outputs(2).name := 'EFFECTIVE_DATE';
  l_outputs(3).name := 'EXPIRY_DATE';
  l_outputs(4).name := 'PROCESS';

  per_formula_functions.run_formula(p_formula_id => p_co_formula_id,
                                   p_calculation_date => p_calculation_date,
                                   p_inputs => l_inputs,
                                   p_outputs => l_outputs);

  -- Code Change for the bug6354665 starts here

  OPEN  csr_emp_asg_act;
  FETCH csr_emp_asg_act INTO l_accrual_start;
  IF csr_emp_asg_act%NOTFOUND THEN
  l_p_calculation_date := FFFUNC.ADD_DAYS(fnd_date.canonical_to_date(l_outputs(2).value),1);
  -- nvl condition added for the bug 7371746
  l_inputs(2).value := fnd_date.date_to_canonical(nvl(l_p_calculation_date,p_calculation_date));

  per_formula_functions.run_formula(p_formula_id => p_co_formula_id,
                                   p_calculation_date => p_calculation_date,
                                   p_inputs => l_inputs,
                                   p_outputs => l_outputs);
  END IF;
  CLOSE csr_emp_asg_act;

  -- Code Change for the bug6354665 ends here

  if upper(l_outputs(4).value) = 'NO' then
  --
    p_max_carry_over := null;
  --
  else
  --
    -- Bug fix 4004565
    -- Fast formula output converted to number using
    -- fnd_number.canonical_to_number function

    p_max_carry_over := fnd_number.canonical_to_number(l_outputs(1).value);
  --
  end if;

  p_effective_date := fnd_date.canonical_to_date(l_outputs(2).value);
  p_expiry_date    := fnd_date.canonical_to_date(l_outputs(3).value);

  hr_utility.set_location('Leaving '||l_proc, 10);
--
end Get_Carry_Over_Values;
--
/* =====================================================================
   Name    : Get_Absence
   Purpose :
   Returns : Total Absence
   ---------------------------------------------------------------------*/
function Get_Absence
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Calculation_Date               IN  Date
,P_Start_Date                     IN  Date
,p_absence_attendance_type_id     IN  Number default NULL
,p_pto_input_value_id             IN  NUMBER default NULL) return Number is

  l_proc          varchar2(72) := g_package||'Get_Absence';
  l_total_absence number;

   /* NOTE: This cursor has been tuned for the CBO. */

   cursor c_get_total_absence is
   select nvl(sum(nvl(abs.absence_days, abs.absence_hours)), 0)
   from   per_absence_attendances abs,
          per_absence_attendance_types abt,
          pay_net_calculation_rules    ncr
   where  abs.absence_attendance_type_id =
            abt.absence_attendance_type_id
   and    abt.input_value_id = ncr.input_value_id
   and    ((ncr.absence_attendance_type_id is not null
           and  ncr.absence_attendance_type_id =
               abt.absence_attendance_type_id)
           OR (ncr.absence_attendance_type_id is null
               and exists
                    (select 'Y' from pay_accrual_plans
                       where accrual_plan_id = ncr.accrual_plan_id
                        and  ncr.input_value_id = pto_input_value_id)
               ))
   and    exists  (select 'Y'
                           from   per_all_assignments_f paf
                           where paf.assignment_id = p_assignment_id
                             and paf.person_id = abs.person_id)
   and    abs.date_start between p_start_date and p_calculation_date
   and    ncr.accrual_plan_id = p_plan_id;
--
   cursor c_get_abs_per_type is
   select nvl(sum(nvl(abs.absence_days, abs.absence_hours)), 0)
   from   per_absence_attendances abs,
          pay_net_calculation_rules    ncr
   where  ncr.absence_attendance_type_id = p_absence_attendance_type_id
   and    ncr.absence_attendance_type_id = abs.absence_attendance_type_id
   and    exists  (select 'Y'
                           from   per_all_assignments_f paf
                           where paf.assignment_id = p_assignment_id
                             and paf.person_id = abs.person_id)
   and    abs.date_start between p_start_date and p_calculation_date
   and    ncr.accrual_plan_id = p_plan_id;
--
   cursor c_get_abs_per_iv is
   select nvl(sum(nvl(abs.absence_days, abs.absence_hours)), 0)
   from   per_absence_attendances abs,
          per_absence_attendance_types abt
   where  abs.absence_attendance_type_id = abt.absence_attendance_type_id
   and    abt.input_value_id = p_pto_input_value_id
   and    exists ( select 1
                     from per_all_assignments_f asg
                    where asg.assignment_id = p_assignment_id
                      and abs.person_id = asg.person_id
                  )
   and    abs.date_start between p_start_date and p_calculation_date;
--
begin
--
  hr_utility.set_location('Entering '||l_proc, 5);
  --
  if p_absence_attendance_type_id is not null then
    hr_utility.set_location(l_proc, 6);
    open c_get_abs_per_type;
    fetch c_get_abs_per_type into l_total_absence;
    close c_get_abs_per_type;
  elsif p_pto_input_value_id is not null then
    hr_utility.set_location(l_proc, 7);
    open c_get_abs_per_iv;
    fetch c_get_abs_per_iv into l_total_absence;
    close c_get_abs_per_iv;
  else
    hr_utility.set_location(l_proc, 8);
    open c_get_total_absence;
    fetch c_get_total_absence into l_total_absence;
    close c_get_total_absence;
  end if;
  hr_utility.set_location('Leaving '||l_proc, 10);

  return nvl(l_total_absence, 0);
--
end Get_Absence;

--
/* =====================================================================
   Name    : Get_Other_Net_Contribution
   Purpose :
   Returns : Total contribution of other elements.
   ---------------------------------------------------------------------*/
function Get_Other_Net_Contribution
(P_Assignment_ID               IN  Number
,P_Plan_ID                     IN  Number
,P_Calculation_Date            IN  Date
,P_Start_Date                  IN  Date
,P_Input_Value_ID              IN  Number default null) return Number is

  l_proc             varchar2(72) := g_package||'Get_Other_Net_Contribution';
  l_contribution     number := 0;
  -- Start of fix 3222662
  l_limit            natural := 100; -- Limiting the bulk collect, if not limited then bulk collect
                                     -- returns entire rows for the condition, it may affect memory
  l_prev_collect     number  := 0;   -- Cumulative record count till previous fetch
  l_curr_collect     number  := 0;   -- Cumulative record count including the current fetch
  l_diff_collect     number  := 0;   -- To check that, whether the last fetch retrived any new
                                     -- records, if not then to exit from the loop
  g_amount_entries   g_entry_value;
  g_add_sub_entries  g_add_subtract;
  --
  cursor c_get_contribution is
  -- index hint applied for bug 4737028 to avoid bitmap conversion and usage of proper index
  -- index PAY_ELEMENT_ENTRIES_F_N53 is now used in hint to resolve bug 5677610
  -- index PAY_INPUT_VALUES_F_N50 is now used in hint to resolve bug 6621800

  select /*+ index(pee PAY_ELEMENT_ENTRIES_F_N53,iv PAY_INPUT_VALUES_F_N50 )*/ fnd_number.canonical_to_number(pev.screen_entry_value) amount,
-- Bug 4551666, bug6621800
         ncr.add_or_subtract add_or_subtract
    from pay_accrual_plans pap,
         pay_net_calculation_rules ncr,
         pay_element_entries_f pee,
         pay_element_entry_values_f pev,
         pay_input_values_f iv
   where pap.accrual_plan_id  = p_plan_id
     and pee.assignment_id    = p_assignment_id
     and pee.element_entry_id = pev.element_entry_id
     and pev.input_value_id   = ncr.input_value_id
     and pap.accrual_plan_id  = ncr.accrual_plan_id
     and ncr.input_value_id not in
         (pap.co_input_value_id,pap.pto_input_value_id)
     and pev.screen_entry_value is not null
     and ((p_input_value_id is not null and p_input_value_id = ncr.input_value_id)
           or p_input_value_id is null)
     and pev.effective_start_date = pee.effective_start_date
     and pev.effective_end_date = pee.effective_end_date
     and iv.input_value_id = ncr.input_value_id
     and p_calculation_date between iv.effective_start_date and iv.effective_end_date
     and pee.element_type_id = iv.element_type_id
     and exists
        (select /*+ index(piv2 PAY_INPUT_VALUES_F_N50)*/ null  -- bug6621800
          from pay_element_entry_values_f pev1,
               pay_input_values_f piv2
         where pev1.element_entry_id     = pev.element_entry_id
           and pev1.input_value_id       = ncr.date_input_value_id
           and pev1.effective_start_date = pev.effective_start_date
           and pev1.effective_end_date   = pev.effective_end_date
           and ncr.date_input_value_id   = piv2.input_value_id
           and pee.element_type_id       = piv2.element_type_id
           and p_calculation_date between piv2.effective_start_date
           and piv2.effective_end_date
           and fnd_date.canonical_to_date(decode(substr(piv2.uom, 1, 1),'D',
               pev1.screen_entry_value, Null))
               between p_start_date and p_calculation_date);
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 5);
  --
  open c_get_contribution;
  --
     loop
     --
         fetch c_get_contribution bulk collect into
               g_amount_entries, g_add_sub_entries limit l_limit;
               l_prev_collect := l_curr_collect;
               l_curr_collect := c_get_contribution%rowcount;
               l_diff_collect := l_curr_collect - l_prev_collect;
            --
            if l_diff_collect > 0 then
               --
               for i in g_amount_entries.first..g_amount_entries.last loop
                  --
                  l_contribution := l_contribution + (g_amount_entries(i) *
                                    g_add_sub_entries(i));
                  --
               end loop;
               --
            end if;
            --
         -- Exiting, if the present fetch is NOT returning any new rows
         exit when (l_diff_collect = 0);
         --
     --
     end loop;
  --
  close c_get_contribution;
  -- End of fix 3222662
/*
  -- Bug 1570965. The below is commented out because we are interested
  -- in displaying the negative value: it appears on the View Accruals form.
  --
  -- If we are dealing with a single net calculation rule,
  -- we return the absolute value, rather than a potentially
  -- negative one. We are only interested in the negative value
  -- when summing all elements together, so that we get an
  -- accurate result

  if p_input_value_id is not null then
    l_contribution := abs(l_contribution);
  end if;
*/
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
  return nvl(l_contribution, 0);
  --
  --
end Get_Other_Net_Contribution;
--
--
/* =====================================================================
   Name    : Get_Carry_Over
   Purpose :
   Returns : Total Carry Over amount
   ---------------------------------------------------------------------*/
function Get_Carry_Over
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Calculation_Date               IN  Date
,P_Start_Date                     IN  Date) return Number is

  l_proc             varchar2(72) := g_package||'Get_Carry_Over';
  l_carryover        number := 0;
  l_absence          number := 0;
  l_net_absence      number := 0;
-- Bug 4245674 Start
  l_other            number := 0;
  l_net_other        number := 0;
  l_carry_diff       number := 0;
-- Bug 4245674 End
  l_expiry_date      date;
  l_start_date       date := p_start_date;
  l_old_date         date;
  -- Start of fix 3222662
  l_count            number  := 1;
  l_limit            natural := 100; -- Limiting the bulk collect, if not limited then bulk collect
                                     -- returns entire rows for the condition, it may affect memory
  l_prev_collect     number  := 0;   -- Cumulative record count till previous fetch
  l_curr_collect     number  := 0;   -- Cumulative record count including the current fetch
  l_diff_collect     number  := 0;   -- To check that, whether the last fetch retrived any new
                                     -- records, if not then to exit from the loop
  g_carry_over       g_entry_value;
  g_expiry_date      g_effective_date;
  g_carry_over1      g_entry_value;
  g_expiry_date1     g_effective_date;
  --
  cursor c_get_carryover is
  -- index hint applied for bug 4737028 to avoid bitmap conversion and usage of proper index
  select /*+ index(pee PAY_ELEMENT_ENTRIES_F_N53)*/ fnd_number.canonical_to_number(nvl(pev.screen_entry_value, 0)) carryover,
         fnd_date.canonical_to_date(nvl(pev1.screen_entry_value,
                                        p_calculation_date)) expiry_date
    from pay_accrual_plans pap,
         pay_element_entry_values_f pev,
         pay_element_entry_values_f pev1,
         pay_input_values_f piv,
         pay_input_values_f piv1,
         pay_element_entries_f pee
   where pap.accrual_plan_id   = p_plan_id
     and pee.assignment_id     = p_assignment_id
     and pee.element_entry_id  = pev.element_entry_id
     and pee.element_entry_id  = pev1.element_entry_id
     and pev.input_value_id    = pap.co_input_value_id
     and pev1.input_value_id   = pap.co_exp_date_input_value_id
     and pap.co_input_value_id = piv.input_value_id
     and pap.co_exp_date_input_value_id = piv1.input_value_id
     and p_calculation_date between piv.effective_start_date and piv.effective_end_date
     and p_calculation_date between piv1.effective_start_date and piv1.effective_end_date
     and pee.element_type_id = piv.element_type_id
     and pee.element_type_id = piv1.element_type_id
     and exists
           (select null
              from pay_element_entry_values_f pev2,
                   pay_input_values_f piv2
             where pev2.element_entry_id = pev.element_entry_id
               and pev2.input_value_id = pap.co_date_input_value_id
               and pev2.input_value_id = piv2.input_value_id
               and pev2.effective_start_date = pev.effective_start_date
               and pev2.effective_end_date = pev.effective_end_date
               and pap.co_date_input_value_id = piv2.input_value_id
               and pee.element_type_id = piv2.element_type_id
               and p_calculation_date between piv2.effective_start_date
               and piv2.effective_end_date
               and fnd_date.canonical_to_date(decode(substr(piv2.uom, 1, 1),'D',
                     pev2.screen_entry_value, Null)) <=
                     fnd_date.canonical_to_date(nvl(pev1.screen_entry_value,p_calculation_date))
               and fnd_date.canonical_to_date(decode(substr(piv2.uom, 1, 1),'D',
                   pev2.screen_entry_value, Null))
                   between p_start_date and p_calculation_date)
   order by expiry_date;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 5);
  --
  -- Getting entire records into a PL/SQL table
  --
  open c_get_carryover;
     --
     loop
     --
        fetch c_get_carryover bulk collect into g_carry_over1, g_expiry_date1 limit l_limit;
           --
           l_prev_collect := l_curr_collect;
           l_curr_collect := c_get_carryover%rowcount;
           l_diff_collect := l_curr_collect - l_prev_collect;
           --
           if l_diff_collect > 0 then
              --
              for i in g_carry_over1.first..g_carry_over1.last loop
                 -- Setting the index
                 l_count := g_carry_over.count + 1;
                 -- Keeping the cumulated records to a seperate PL/SQL tables
                 g_carry_over(l_count) := g_carry_over1(i);
                 g_expiry_date(l_count) := g_expiry_date1(i);
              end loop;
              --
           end if;
           --
        -- Exiting, if the present fetch is NOT returning any new rows
        exit when (l_diff_collect = 0);
     --
     end loop;
  --
  close c_get_carryover;
  --
  --
-- Bug 4245674 Start
-- Desc : Modified this function to incorporate the Net Calculation rules
--        while calculating the net calculation rules.
--        Added comments throughout the fuction to explain each and every
--        actions.
  l_old_date := p_start_date - 1;
  --
  if g_carry_over.count > 0 then
     --
--  Because although you normally only have one carry over element entry,
--  users can manually add additional carry over entries in by hand.
     for i in g_carry_over.first..g_carry_over.last loop
        --
--  If you have more than one carry over entry and its expiry date is
--  later than the previous element entry, you need to sum any additional
--  absences and other contribution between the the first expiry period
--  and the second and add them to the total.
        if g_expiry_date(i) > l_old_date then
           --
           l_start_date := l_old_date + 1;
           --
           l_absence := get_absence(
                        p_assignment_id => p_assignment_id,
                        p_plan_id => p_plan_id,
                        p_start_date => l_start_date,
                        p_calculation_date => g_expiry_date(i));

           l_absence := l_absence + l_net_absence;

           l_other := get_other_net_contribution(
			     p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
                             p_start_date => l_start_date,
                             p_calculation_date => g_expiry_date(i));
           l_other := l_other + l_net_other;
           --
        else
           --
           l_absence := l_net_absence;
           l_other := l_net_other;
           --
        end if;
        --
        if p_calculation_date <= g_expiry_date(i) then
           --
           l_net_absence := l_absence;
           l_carryover := l_carryover + g_carry_over(i);
           l_net_other := l_other;
           --
--  When the carryover has already expired, we showing the carryover amount
--  to be the amount of absences and other contribution - ie the amount
--  not forfeited.
        else
           --
--  This is for absence to be calculated.
           if g_carry_over(i) <= l_absence then
              --
              l_net_absence := l_absence - g_carry_over(i);
              l_carryover := l_carryover + g_carry_over(i);
              l_carry_diff := 0;
              --
           else
              --
              l_net_absence := 0;
              l_carryover := l_carryover + l_absence;
              l_carry_diff := g_carry_over(i) - l_absence;
              --
           end if;
           --
--  This is for Net Calculation rules to be calculated.
           if l_other > 0 then
              l_net_other := l_other;
           else

              if l_carry_diff <= abs(l_other) then
--  Remaining other is add into net_other.
                 l_net_other := l_other + l_carry_diff;
--  Adding the carryover in the absence and  remaining carryover if the
--  net carryover calculated after absence deduction is less than the
--  net carryover.
                 l_carryover := l_carryover + l_carry_diff;

              else
--  Utilized all the other. If some other remains then add to net
                 l_net_other := 0;
--  Case 1: when the other element is -ve(Subtract), Adding the carryover
--  and -ve of other if the net carryover is greater than other.
--
--  Case 2: when the other element is +ve (Add), If the carryover due to
--  absence is less than the other then what  needs to be done.
--  If the carryover due to absence is more than the other then net
--  carryover is carryover_absence - other
                 l_carryover := l_carryover - l_other;
              end if;

           end if;

        end if;
        --
        l_old_date := g_expiry_date(i);
        --
     end loop;
     --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
  return l_carryover;
  --
  -- End of fix 3222662
  -- Bug 4245674 Ends.
--
end Get_Carry_Over;
--
--
/* =====================================================================
   Name    : Get_Net_Accrual
   Purpose :
   Returns : Total Accrued entitlement
   ---------------------------------------------------------------------*/
procedure Get_Net_Accrual
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Payroll_ID                     IN  Number
,P_Business_Group_ID              IN  Number
,P_Assignment_Action_ID           IN  Number default -1
,P_Calculation_Date               IN  Date
,P_Accrual_Start_Date             IN  Date default null
,P_Accrual_Latest_Balance         IN Number default null
,P_Calling_Point                  IN Varchar2 default 'FRM'
,P_Start_Date                     OUT NOCOPY Date
,P_End_Date                       OUT NOCOPY Date
,P_Accrual_End_Date               OUT NOCOPY Date
,P_Accrual                        OUT NOCOPY Number
,P_Net_Entitlement                OUT NOCOPY Number) is

  l_proc        varchar2(72) := g_package||'Get_Net_Accrual';
  l_absence     number := 0;   --changed for bug 6914353
  l_accrual     number;
  l_other       number := 0;   --changed for bug 6914353
  l_carryover   number;
  l_start_date  date;
  l_end_date    date;
  l_accrual_end_date date;
  l_defined_balance_id number;

  l_atd         date; --added for bug 6418568

  cursor c_get_balance is
  select defined_balance_id
  from pay_accrual_plans
  where accrual_plan_id = p_plan_id;

  --added for bug 6418568
  cursor c_get_atd is
   select nvl(pps.ACTUAL_TERMINATION_DATE,to_date('31/12/4712','dd/mm/yyyy'))
   from per_periods_of_service pps, per_all_assignments_f paaf
   where paaf.person_id = pps.person_id
    and paaf.period_of_service_id = pps.period_of_service_id
    and paaf.Assignment_ID = P_Assignment_ID
    and P_Calculation_Date between paaf.effective_start_date and paaf.effective_end_date;


begin
--
  hr_utility.set_location('Entering '||l_proc, 5);

  --
  -- Pipe the parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ENTERING '||upper(l_proc));
  hr_utility.trace(' for assignment '||to_char(p_assignment_id));
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_assignment_id                  '||
                      to_char(p_assignment_id));
  hr_utility.trace('  p_plan_id                        '||
                      to_char(p_plan_id));
  hr_utility.trace('  p_payroll_id                     '||
                      to_char(p_payroll_id));
  hr_utility.trace('  p_business_group_id              '||
                      to_char(p_business_group_id));
  hr_utility.trace('  p_assignment_action_id           '||
                      to_char(p_assignment_action_id));
  hr_utility.trace('  p_calculation_date               '||
                      to_char(p_calculation_date));
  hr_utility.trace('  p_accrual_start_date             '||
                      to_char(p_accrual_start_date));
  hr_utility.trace('  p_accrual_latest_balance         '||
                      to_char(p_accrual_latest_balance));
  hr_utility.trace('  p_calling_point                  '||
                      p_calling_point);
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  open c_get_balance;
  fetch c_get_balance into l_defined_balance_id;
  close c_get_balance;

  if p_calling_point = 'BP' and
     l_defined_balance_id is not null and
     p_assignment_action_id <> -1 then
  --
    /* Procedure called from batch process, so
       get latest balance. */

    p_net_entitlement := pay_balance_pkg.get_value(
                            p_defined_balance_id => l_defined_balance_id
                           ,p_assignment_action_id => p_assignment_action_id
                            );
  --
  else
  --

    get_accrual(p_assignment_id => p_assignment_id,
                p_plan_id => p_plan_id,
                p_calculation_date => p_calculation_date,
                p_business_group_id => p_business_group_id,
	        p_payroll_id => p_payroll_id,
                p_assignment_action_id => p_assignment_action_id,
                p_accrual_start_date => p_accrual_start_date,
                p_accrual_latest_balance => p_accrual_latest_balance,
                p_start_date => l_start_date,
                p_end_date => l_end_date,
	        p_accrual_end_date => l_accrual_end_date,
                p_accrual => l_accrual);

    --start changes for bug 6418568
    open c_get_atd;
    fetch c_get_atd into l_atd;
    close c_get_atd;

    if l_accrual_end_date is not null then
    --
     l_absence := get_absence(p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
			     p_start_date => l_start_date,
			     p_calculation_date => l_end_date);

     l_other := get_other_net_contribution(
			     p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
                             p_start_date => l_start_date,
                             p_calculation_date => l_end_date
			     );
    else
    --
     if l_atd >= P_Calculation_Date then
	--
      l_absence := get_absence(p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
			     p_start_date => l_start_date,
			     p_calculation_date => l_end_date);

      l_other := get_other_net_contribution(
			     p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
                             p_start_date => l_start_date,
                             p_calculation_date => l_end_date
			     );
	--
     end if;
    --
    end if;
    --end changes for bug 6418568

    l_carryover := get_carry_over(
                             p_assignment_id => p_assignment_id,
                             p_plan_id => p_plan_id,
                             p_start_date => l_start_date,
                             p_calculation_date => l_end_date);

    --
    -- Set up values in the return parameters.
    --
    p_net_entitlement := l_accrual - l_absence + l_other + l_carryover;
    p_accrual := l_accrual;
    p_start_date := l_start_date;
    p_end_date := l_end_date;
    p_accrual_end_date := l_accrual_end_date;
  --
  end if;

  --
  -- Pipe the parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' LEAVING '||upper(l_proc));
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_start_date                     '||
                      to_char(p_start_date));
  hr_utility.trace('  p_end_date                       '||
                      to_char(p_end_date));
  hr_utility.trace('  p_accrual_end_date               '||
                      to_char(p_accrual_end_date));
  hr_utility.trace('  p_accrual                        '||
                      to_char(p_accrual));
  hr_utility.trace('  p_net_entitlement                '||
                      to_char(p_net_entitlement));
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

--
end Get_Net_Accrual;
--
/* =====================================================================
   Name    : get_asg_inactive_days
   Purpose : Gets the number of days in a period where the assignment
             status is not 'Active'.
   Returns : Number of inactive days in the period.
   ---------------------------------------------------------------------*/
FUNCTION get_asg_inactive_days
  (p_assignment_id      IN    NUMBER,
   p_period_sd          IN    DATE,
   p_period_ed          IN    DATE) RETURN NUMBER IS

CURSOR csr_period_asg_status IS
  SELECT asg.effective_start_date,
         asg.effective_end_date,
         ast.per_system_status
  FROM   per_all_assignments_f asg,
         per_assignment_status_types ast
  WHERE  asg.assignment_id = p_assignment_id
  AND  ((asg.effective_start_date BETWEEN p_period_sd AND p_period_ed
  OR     asg.effective_end_date BETWEEN p_period_sd AND p_period_ed)
  OR    (p_period_sd BETWEEN asg.effective_start_date AND asg.effective_end_date))
  AND    asg.assignment_status_type_id = ast.assignment_status_type_id
  AND    ast.per_system_status <> 'ACTIVE_ASSIGN';

  l_proc               VARCHAR2(72) := g_package||'get_loa_days';
  l_assignment_sd      DATE;
  l_assignment_ed      DATE;
  l_assignment_status  per_assignment_status_types.per_system_status%TYPE;
  l_asg_inactive_days  NUMBER       := 0;

BEGIN
--
  hr_utility.set_location('Entering '||l_proc, 10);

  -- Loop each inactive assignment record for the period and count the inactive days
  OPEN csr_period_asg_status;
  LOOP
    FETCH csr_period_asg_status INTO
      l_assignment_sd,
      l_assignment_ed,
      l_assignment_status;
    EXIT WHEN csr_period_asg_status%NOTFOUND;
    -- Count inactive days
    l_asg_inactive_days := l_asg_inactive_days + get_working_days(
      GREATEST(l_assignment_sd, p_period_sd),
      LEAST(l_assignment_ed, p_period_ed));
  END LOOP;
 CLOSE csr_period_asg_status;

  hr_utility.set_location('Leaving '||l_proc, 20);

  RETURN l_asg_inactive_days;

END get_asg_inactive_days;
--
/* =====================================================================
   Name    : get_working_days
   Purpose : Gets the number of working days in a given period.
   Returns : Number of working days in the period.
   ---------------------------------------------------------------------*/
FUNCTION get_working_days
  (p_start_date  IN    DATE,
   p_end_date    IN    DATE) RETURN NUMBER IS

  l_proc          VARCHAR2(72) := g_package||'get_working_days';
  l_working_days  NUMBER       := 0;
  l_curr_date     DATE         := NULL;
  l_curr_day      NUMBER       := 0;
  l_ref_day       NUMBER;
  l_adj_day       NUMBER;
  l_diff_days     NUMBER;

BEGIN
--
  hr_utility.set_location('Entering '||l_proc, 10);

  -- Check for a valid range
  IF p_start_date > p_end_date THEN
    RETURN l_working_days;
  END IF;

  -- Select the day of week for a date known to be a Saturday.
  -- On an instance with NLS_TERRITORY set to AMERICAN, this will
  -- return 7; with NLS_TERRITORY set to POLAND, it will return 6.
  -- Start of 3222662
  l_ref_day := to_number(to_char(to_date('01/01/2000', 'dd/mm/yyyy'), 'D'));
  -- End of 3222662

  hr_utility.trace('l_ref_day = '||to_char(l_ref_day));

  -- A non-zero difference here indicates the week does not begin
  -- on Sunday and provides the adjustment we must consider when
  -- determining whether or not a day is a work day.
  l_diff_days := 7 - l_ref_day;

  hr_utility.trace('l_diff_days = '||to_char(l_diff_days));

  -- Loop each day in period and count working days

  l_curr_date := p_start_date;

  LOOP

    l_curr_day := to_number(to_char(l_curr_date, 'D'));

    hr_utility.trace('l_curr_day = '||to_char(l_curr_day));

    -- Find the adjusted day of week
    -- Start of 3222662
    if mod(l_curr_day+l_diff_days,7) = 0 then
       l_adj_day := 7;
    else
       l_adj_day := mod(l_curr_day+l_diff_days,7);
    end if;
    -- End of 3222662

    hr_utility.trace('l_adj_day = '||to_char(l_adj_day));

    IF l_adj_day > 1 AND l_adj_day < 7 THEN
      l_working_days := l_working_days + 1;
    END IF;
    l_curr_date := l_curr_date + 1;
  EXIT WHEN l_curr_date > p_end_date;
  END LOOP;

  hr_utility.set_location('Leaving '||l_proc, 20);

  RETURN l_working_days;

END get_working_days;
--
--
end per_accrual_calc_functions;

/
