--------------------------------------------------------
--  DDL for Package Body PER_ONEBOX_VACBAL_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ONEBOX_VACBAL_ACCRUAL" as
/* $Header: peonebvb.pkb 120.0 2006/06/02 18:02:49 jarthurt noship $ */
cursor get_plan_id_csr(p_person_id in number) is
    select distinct paf.assignment_id,
           pap.accrual_plan_id
    from pay_accrual_plans pap,
         per_assignments_f paf,
         per_people_f ppf,
         pay_element_types_f pet,
         pay_element_entries_f pee,
         pay_element_links_f pel
where pap.accrual_plan_element_type_id = pet.element_type_id
and pel.element_link_id = pee.element_link_id
and pel.element_type_id = pet.element_type_id
and pee.assignment_id = paf.assignment_id
and paf.person_id = ppf.person_id
and ppf.person_id = p_person_id
and pap.accrual_category = 'V'
and sysdate between paf.effective_start_date and paf.effective_end_date
and sysdate between ppf.effective_start_date and ppf.effective_end_date
and sysdate between pee.effective_start_date and pee.effective_end_date
and sysdate between pel.effective_start_date and pel.effective_end_date
and sysdate between pet.effective_start_date and pet.effective_end_date;

function net_balance(p_person_id in number,
                     p_date      in date) return number is
l_net_bal number := 0;
l_total_bal number := 0;
l_accrual_plan_id number := 0;
l_date date;
begin
  for gpi in get_plan_id_csr(p_person_id)
  loop
    HR_PTO_VIEWS.Get_pto_ytd_net_entitlement(
           p_assignment_id        => gpi.assignment_id
          ,p_plan_id              => gpi.accrual_plan_id
          ,p_calculation_date     => p_date
          ,p_net_entitlement      => l_net_bal
          ,p_last_accrual_date    => l_date);
    l_total_bal := l_total_bal + l_net_bal;
  end loop;

  return l_net_bal;
exception
  when OTHERS then
    l_total_bal := -99999;
    return l_total_bal;
end net_balance;

function time_off_taken(p_person_id in number,
                        p_date      in date) return number is
l_time_off number := 0;
l_accrual_plan_id number := 0;
begin
for gpi in get_plan_id_csr(p_person_id)
  loop
    l_time_off := l_time_off + per_accrual_calc_functions.get_absence
    (p_assignment_id    => gpi.assignment_id
    ,p_plan_id          => gpi.accrual_plan_id
    ,p_calculation_date => p_date
    ,p_start_date       => fnd_date.canonical_to_date(substr(fnd_date.date_to_canonical(p_date), 1, 4) || '/01/01 00:00:00'));
  end loop;
  return l_time_off;

exception
  when OTHERS then
    l_time_off := -99999;
    return l_time_off;
end time_off_taken;

end per_onebox_vacbal_accrual;

/
