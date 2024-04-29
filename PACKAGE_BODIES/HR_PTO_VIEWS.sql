--------------------------------------------------------
--  DDL for Package Body HR_PTO_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PTO_VIEWS" AS
/* $Header: hrptovws.pkb 120.0 2005/05/31 02:22 appldev noship $ */
--
-- Package global variables
--
--
   cursor csr_get_asg_details(cp_assignment_id number, cp_effective_date date) is
      select business_group_id, payroll_id
        from per_all_assignments_f
       where assignment_id = cp_assignment_id
         and cp_effective_date between effective_start_date and effective_end_date;
--
   cursor csr_get_aaid_details(cp_assignment_action_id number) is
      select paa.assignment_id, ppa.business_group_id, ppa.payroll_id
         from pay_assignment_actions paa
             ,pay_payroll_actions    ppa
        where paa.assignment_action_id = cp_assignment_action_id
          and paa.payroll_action_id = ppa.payroll_action_id;
--
-- ---------------------------------------------------------------------- +
-- ---------------------------------------------------------------------- +
-- This includes c/o + other net contribution
--
PROCEDURE Get_pto_ytd_net_entitlement
      (p_assignment_id        number
      ,p_plan_id              number
      ,p_payroll_id           number
      ,p_business_group_id    number
      ,p_assignment_action_id number
      ,p_calculation_date     date
      ,p_net_entitlement      OUT nocopy number
      ,p_last_accrual_date    OUT nocopy date) IS
--
  l_entitlement          number;
  l_assignment_action_id number;
  d1 date;
  d2 date;
  d3 date;
  n1 number;

BEGIN
    -- Here we set a null assignment_action_id to -1 to prevent
    -- an error running the Accrual formula later.

    if p_assignment_action_id is null then
      l_assignment_action_id := -1;
    else
      l_assignment_action_id := p_assignment_action_id;
    end if;
    --
    per_accrual_calc_functions.get_net_accrual(
       P_assignment_id          => p_assignment_id,
       P_plan_id                => p_plan_id,
       P_payroll_id             => p_payroll_id,
       p_business_group_id      => p_business_group_id,
       p_assignment_action_id   => l_assignment_action_id,
       P_calculation_date       => p_calculation_date,
       p_accrual_start_date     => null,
       p_accrual_latest_balance => null,
       p_calling_point          => 'BP',
       P_start_date             => d1,
       P_End_Date               => d2,
       P_Accrual_End_Date       => d3,
       P_accrual                => n1,
       P_net_entitlement        => l_entitlement
       );
   -- set out prms
   p_net_entitlement := l_entitlement;
   p_last_accrual_date := d3;
   --
END Get_pto_ytd_net_entitlement;
-- ---------------------------------------------------------------------- +
-- ---------------------------------------------------------------------- +
PROCEDURE Get_pto_ytd_net_entitlement(
 		     p_assignment_id        number
          ,p_plan_id              number
          ,p_calculation_date     date
          ,p_net_entitlement      OUT nocopy number
          ,p_last_accrual_date    OUT nocopy date) IS
   --
   l_asg_rec csr_get_asg_details%ROWTYPE;
   l_result number;
   --
BEGIN
   open csr_get_asg_details(p_assignment_id,p_calculation_date) ;
   fetch csr_get_asg_details into l_asg_rec;
   close csr_get_asg_details;
   Get_pto_ytd_net_entitlement(
                   p_assignment_id        => p_assignment_id
                  ,p_plan_id              => p_plan_id
                  ,p_payroll_id           => l_asg_rec.payroll_id
                  ,p_business_group_id    => l_asg_rec.business_group_id
                  ,p_assignment_action_id => -1
                  ,p_calculation_date     => p_calculation_date
                  ,p_net_entitlement      => p_net_entitlement
                  ,p_last_accrual_date    => p_last_accrual_date);
   --
END Get_pto_ytd_net_entitlement;
--
-- ---------------------------------------------------------------------- +
-- --------------------<< Get_pto_ytd_gross >>--------------------------- +
-- ---------------------------------------------------------------------- +
-- similar to latest balance but it does not consider the other net contrib
PROCEDURE Get_pto_ytd_gross(p_assignment_id    number
                       ,p_plan_id              number
                       ,p_payroll_id           number
                       ,p_business_group_id    number
                       ,p_assignment_action_id number
                       ,p_calculation_date     date
                       ,p_gross_accruals       OUT nocopy number
                       ,p_last_accrual_date    OUT nocopy date)  IS
--
  l_tot_accrual_hours    number;
  l_assignment_action_id number;
  ln_dummy_num           number;
  ld_dummy_dat           date;
  ld_dummy_dat1          date;
  ld_dummy_dat2          date;

BEGIN

   if p_assignment_action_id is null then
   l_assignment_action_id := -1;
   else
   l_assignment_action_id := p_assignment_action_id;
   end if;

   per_accrual_calc_functions.get_net_accrual (
      p_assignment_id        => p_assignment_id,
      p_plan_id              => p_plan_id,
      p_payroll_id           => p_payroll_id,
      p_business_group_id    => p_business_group_id,
      p_calculation_date     => p_calculation_date,
      p_assignment_action_id => l_assignment_action_id,
      p_accrual              => l_tot_accrual_hours,    -- return this value
      p_net_entitlement      => ln_dummy_num,
      p_end_date             => ld_dummy_dat,
      p_accrual_end_date     => ld_dummy_dat1,
      p_start_date           => ld_dummy_dat2
     );
   -- set OUT prms
   p_gross_accruals    := l_tot_accrual_hours;
   p_last_accrual_date := ld_dummy_dat1;
   --
END Get_pto_ytd_gross;
-- ---------------------------------------------------------------------- +
-- ---------------------------------------------------------------------- +
PROCEDURE Get_pto_ytd_gross(
 		     p_assignment_id        number
          ,p_plan_id              number
          ,p_calculation_date     date
          ,p_gross_accruals       OUT nocopy number
          ,p_last_accrual_date    OUT nocopy date) IS
   --
   l_asg_rec csr_get_asg_details%ROWTYPE;
   l_result number;
   --
BEGIN
   open csr_get_asg_details(p_assignment_id, p_calculation_date);
   fetch csr_get_asg_details into l_asg_rec;
   close csr_get_asg_details;
   Get_pto_ytd_gross(
                   p_assignment_id        => p_assignment_id
                  ,p_plan_id              => p_plan_id
                  ,p_payroll_id           => l_asg_rec.payroll_id
                  ,p_business_group_id    => l_asg_rec.business_group_id
                  ,p_assignment_action_id => -1
                  ,p_calculation_date     => p_calculation_date
                  ,p_gross_accruals       => p_gross_accruals
                  ,p_last_accrual_date    => p_last_accrual_date);
   --
END Get_pto_ytd_gross;
--
-- ---------------------------------------------------------------------- +
-- ---------------------<< Get_pto_ptd_gross >>-------------------------- +
-- ---------------------------------------------------------------------- +
PROCEDURE Get_pto_ptd_gross(p_assignment_id       number
                                  ,p_plan_id              number
                                  ,p_payroll_id           number
                                  ,p_business_group_id    number
                                  ,p_assignment_action_id number
                                  ,p_calculation_date     date
                                  ,p_gross_accruals       OUT nocopy number
                                  ,p_last_accrual_date    OUT nocopy date) IS
--
  l_entitlement          number;
  l_assignment_action_id number;
  l_latest_balance       number;
  l_previous_balance     number;
  acc_end_date date;
  d1 date;
  d2 date;
  d3 date;
  n1 number;

BEGIN
   l_latest_balance := 0;
   --
   if p_assignment_action_id is null then
   l_assignment_action_id := -1;
   else
   l_assignment_action_id := p_assignment_action_id;
   end if;
   --
   per_accrual_calc_functions.get_net_accrual(
    P_assignment_id          => p_assignment_id,
    P_plan_id                => p_plan_id,
    P_payroll_id             => p_payroll_id,
    p_business_group_id      => p_business_group_id,
    p_assignment_action_id   => l_assignment_action_id,
    P_calculation_date       => p_calculation_date,
    p_accrual_start_date     => null,
    p_accrual_latest_balance => null,
    p_calling_point          => 'BP',
    P_start_date             => d1,
    P_End_Date               => d2,
    P_Accrual_End_Date       => d3,
    P_accrual                => l_latest_balance,
    P_net_entitlement        => n1
    );
   --
   acc_end_date := d3; -- this identifies the date when last accrual was calculated
                       -- as of calculation date
   per_accrual_calc_functions.get_net_accrual(
    P_assignment_id          => p_assignment_id,
    P_plan_id                => p_plan_id,
    P_payroll_id             => p_payroll_id,
    p_business_group_id      => p_business_group_id,
    p_assignment_action_id   => l_assignment_action_id,
    P_calculation_date       => acc_end_date -1 ,  -- this will calculate as of previous period
    p_accrual_start_date     => null,
    p_accrual_latest_balance => null,
    p_calling_point          => 'BP',
    P_start_date             => d1,
    P_End_Date               => d2,
    P_Accrual_End_Date       => d3,
    p_accrual                => l_previous_balance,
    P_net_entitlement        => n1
    );
   -- set OUT prms
   p_gross_accruals := l_latest_balance - l_previous_balance;
   p_last_accrual_date := acc_end_date;
   --
END Get_pto_ptd_gross;
-- ---------------------------------------------------------------------- +
-- ---------------------------------------------------------------------- +
PROCEDURE Get_pto_ptd_gross
               (p_assignment_id        number
               ,p_plan_id              number
               ,p_calculation_date     date
               ,p_gross_accruals       OUT nocopy number
               ,p_last_accrual_date    OUT nocopy date) IS
   --
   l_asg_rec csr_get_asg_details%ROWTYPE;
   l_result number;
   --
BEGIN
   open csr_get_asg_details(p_assignment_id,p_calculation_date) ;
   fetch csr_get_asg_details into l_asg_rec;
   close csr_get_asg_details;
   Get_pto_ptd_gross(
                   p_assignment_id        => p_assignment_id
                  ,p_plan_id              => p_plan_id
                  ,p_payroll_id           => l_asg_rec.payroll_id
                  ,p_business_group_id    => l_asg_rec.business_group_id
                  ,p_assignment_action_id => -1
                  ,p_calculation_date     => p_calculation_date
                  ,p_gross_accruals       => p_gross_accruals
                  ,p_last_accrual_date    => p_last_accrual_date);
   --
END Get_pto_ptd_gross;
--
-- ---------------------------------------------------------------------- +
--                        Get_pto_all_plans
-- ---------------------------------------------------------------------- +
FUNCTION Get_pto_all_plans(
            p_person_id           number
           ,p_calculation_date    date)   RETURN g_per_acc_plan_tab_type IS
--
    CURSOR csr_get_plans(cp_person_id number, cp_effective_date date) IS
        select rownum, et.element_name, paf.assignment_id, plan.accrual_plan_id
              ,plan.accrual_plan_name, lookup.meaning UOM
              ,paf.business_group_id, paf.payroll_id
              ,ee.element_entry_id, ee.effective_start_date  ee_start_date
        from pay_element_entries_f ee
            ,pay_element_types_f   et
            ,pay_accrual_plans     plan
            ,per_all_assignments_f paf
            ,per_all_people_f      peo
            ,hr_lookups            lookup
        where peo.person_id = cp_person_id
        and cp_effective_date between peo.effective_start_date
                                  and peo.effective_end_date
        and peo.person_id = paf.person_id
        and paf.effective_start_date between peo.effective_start_date
                                         and peo.effective_end_date
        and ee.assignment_id = paf.assignment_id
        and ee.element_type_id = plan.ACCRUAL_PLAN_ELEMENT_TYPE_ID
        and ee.element_type_id = et.element_type_id
        and ee.effective_start_date between et.effective_start_date
                                        and et.effective_end_date
        and lookup.lookup_type = 'HOURS_OR_DAYS'
        and plan.ACCRUAL_UNITS_OF_MEASURE = lookup_code
        and lookup.enabled_flag = 'Y';
   --
   l_person_plans      HR_PTO_VIEWS.g_per_acc_plan_tab_type;
   l_last_accrual_date date;
   --
BEGIN
 for plans_rec in csr_get_plans(p_person_id, p_calculation_date) loop
    l_person_plans(plans_rec.rownum).plan_id := plans_rec.accrual_plan_id;
    l_person_plans(plans_rec.rownum).plan_name := plans_rec.accrual_plan_name;
    l_person_plans(plans_rec.rownum).UOM := plans_rec.UOM;
    l_person_plans(plans_rec.rownum).assignment_id := plans_rec.assignment_id;
    l_person_plans(plans_rec.rownum).plan_element_entry_id := plans_rec.element_entry_id;
    l_person_plans(plans_rec.rownum).ee_start_date := plans_rec.ee_start_date;
    HR_PTO_VIEWS.Get_pto_ytd_net_entitlement
          (p_assignment_id => plans_rec.assignment_id
          ,p_plan_id              => plans_rec.accrual_plan_id
          ,p_payroll_id           => plans_rec.Payroll_id
          ,p_business_group_id    => plans_rec.business_group_id
          ,p_assignment_action_id => null
          ,p_calculation_date     => p_calculation_date
          ,p_net_entitlement      => l_person_plans(plans_rec.rownum).net_entitlement_ytd
          ,p_last_accrual_date    => l_last_accrual_date);
    --
    HR_PTO_VIEWS.Get_pto_ytd_gross
                (p_assignment_id => plans_rec.assignment_id
                ,p_plan_id              => plans_rec.accrual_plan_id
                ,p_payroll_id           => plans_rec.Payroll_id
                ,p_business_group_id    => plans_rec.business_group_id
                ,p_assignment_action_id => null
                ,p_calculation_date     => p_calculation_date
                ,p_gross_accruals       => l_person_plans(plans_rec.rownum).gross_accruals_ytd
                ,p_last_accrual_date    => l_last_accrual_date);
    --
    HR_PTO_VIEWS.Get_pto_ptd_gross
                (p_assignment_id => plans_rec.assignment_id
                ,p_plan_id              => plans_rec.accrual_plan_id
                ,p_payroll_id           => plans_rec.Payroll_id
                ,p_business_group_id    => plans_rec.business_group_id
                ,p_assignment_action_id => null
                ,p_calculation_date     => p_calculation_date
                ,p_gross_accruals       => l_person_plans(plans_rec.rownum).gross_accruals_ptd
                ,p_last_accrual_date    => l_last_accrual_date);
   --
 END LOOP;
 RETURN l_person_plans;
END Get_pto_all_plans;
--
-- ---------------------------------------------------------------------- +
--                        Get_pto_stored_balance
-- ---------------------------------------------------------------------- +
FUNCTION Get_pto_stored_balance(
           p_assignment_action_id number
          ,p_plan_id              number)    RETURN NUMBER IS
   --
   cursor csr_get_balance is
      select defined_balance_id
      from pay_accrual_plans
      where accrual_plan_id = p_plan_id;
   --
   l_asg_rec csr_get_aaid_details%ROWTYPE;
   l_balance_id pay_accrual_plans.defined_balance_id%TYPE;
   l_result number;
   l_date   date;
   --
BEGIN
   open csr_get_balance;
   fetch csr_get_balance into l_balance_id;
   if csr_get_balance%FOUND and nvl(p_assignment_action_id,-1) <> -1 then
      close csr_get_balance;
      open csr_get_aaid_details(p_assignment_action_id);
      fetch csr_get_aaid_details into l_asg_rec;
      close csr_get_aaid_details;
      Get_pto_ytd_net_entitlement(
                      p_assignment_id        => l_asg_rec.assignment_id
                     ,p_plan_id              => p_plan_id
                     ,p_payroll_id           => l_asg_rec.payroll_id
                     ,p_business_group_id    => l_asg_rec.business_group_id
                     ,p_assignment_action_id => p_assignment_action_id
                     ,p_calculation_date     => NULL
                     ,p_net_entitlement      => l_result
                     ,p_last_accrual_date    => l_date);
      l_result := nvl(l_result,0);
   else
      close csr_get_balance;
      l_result := NULL;
   end if;
   return l_result;
END Get_pto_stored_balance;
--
END HR_PTO_VIEWS;

/
