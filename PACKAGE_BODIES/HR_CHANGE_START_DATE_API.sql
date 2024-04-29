--------------------------------------------------------
--  DDL for Package Body HR_CHANGE_START_DATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CHANGE_START_DATE_API" as
/* $Header: pehirapi.pkb 120.15.12010000.6 2009/11/10 10:57:22 sathkris ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_change_start_date_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_not_supervisor >------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_not_supervisor(p_person_id NUMBER
                              ,p_new_start_date DATE
                              ,p_old_start_date DATE) is
--
l_dummy VARCHAR2(1);
--
cursor supervisor
is
select 'Y'
from per_assignments_f paf
where paf.assignment_type in  ('E','C')
and   paf.supervisor_id = p_person_id
and   p_new_start_date > paf.effective_start_date
and   paf.effective_end_date  >= p_old_start_date ;
--
begin
  open supervisor;
  fetch supervisor into l_dummy;
  if supervisor%FOUND then
    close supervisor;
    fnd_message.set_name('PAY','HR_51031_INV_HIRE_CHG_IS_SUPER');
    app_exception.raise_exception;
  end if;
  close supervisor;
--
end check_not_supervisor;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_pds_pdp >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_pds_pdp(p_person_id NUMBER
                       ,p_new_start_date DATE
                       ,p_old_start_date DATE
                       ,p_type VARCHAR2) is
--
l_dummy VARCHAR2(1);
--
cursor csr_pds_exists is
select 'y' from dual where exists
(select 'x'
from   per_periods_of_service pds
where  pds.person_id = p_person_id
and    pds.date_start = p_old_start_date);
--
cursor csr_pdp_exists is
select 'y' from dual where exists
(select 'x'
from   per_periods_of_placement pdp
where  pdp.person_id = p_person_id
and    pdp.date_start = p_old_start_date);
--
begin
if p_type = 'E' then
  open csr_pds_exists;
  fetch csr_pds_exists into l_dummy;
  if csr_pds_exists%notfound
  and p_old_start_date is not null then
    close csr_pds_exists;
     hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','check_pds_pdp');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  else
    close csr_pds_exists;
  end if;
elsif p_type = 'C' then
  open csr_pdp_exists;
  fetch csr_pdp_exists into l_dummy;
  if csr_pdp_exists%notfound
  and p_old_start_date is not null then
    close csr_pdp_exists;
     hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','check_pds_pdp');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
  else
    close csr_pdp_exists;
  end if;
else
  null;
end if;
--
end check_pds_pdp;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_un_ended_pds_pdp >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_un_ended_pds_pdp(p_person_id NUMBER
                       ,p_new_start_date DATE
--
-- 115.30,115.33 (START)
--
                       ,p_old_start_date DATE
                       ,p_hd_rule_found BOOLEAN
                       ,p_hd_rule_value VARCHAR2
                       ,p_fpd_rule_found BOOLEAN
                       ,p_fpd_rule_value VARCHAR2
--
-- 115.30,115.33 (END)
--
                       ,p_type VARCHAR2) is
--
l_dummy VARCHAR2(1);
--
cursor csr_pds_exists is
select 'y' from dual where exists
(select 'x'
from   per_periods_of_service pds
where  pds.person_id = p_person_id
and    pds.actual_termination_date < p_new_start_date
and    pds.final_process_date >= p_new_start_date);
--
cursor csr_pdp_exists is
select 'y' from dual where exists
(select 'x'
from   per_periods_of_placement pdp
where  pdp.person_id = p_person_id
and    pdp.actual_termination_date < p_new_start_date
and    pdp.final_process_date >= p_new_start_date);
--
-- 115.30 (START)
--
CURSOR csr_inv_new_hd IS
  SELECT null
  FROM   per_periods_of_service
  WHERE  person_id = p_person_id
  AND    p_old_start_date BETWEEN NVL(last_standard_process_date,
                                      actual_termination_date)+1
                          AND final_process_date
  AND    p_new_start_date <= NVL(last_standard_process_date,actual_termination_date);
--
CURSOR csr_overlap (p_start_date DATE) IS
  SELECT null
  FROM   per_periods_of_service
  WHERE  person_id = p_person_id
  AND    csr_overlap.p_start_date BETWEEN NVL(last_standard_process_date,
                                              actual_termination_date)+1
                                  AND NVL(final_process_date,hr_api.g_eot);
--
l_old_start_date_in_range BOOLEAN;
l_new_start_date_in_range BOOLEAN;
--
CURSOR csr_new_start_date IS
  SELECT null
  FROM   per_periods_of_service pds
  WHERE  pds.person_id = p_person_id
  AND    pds.date_start = p_old_start_date
  AND    p_new_start_date BETWEEN pds.actual_termination_date
                          AND pds.final_process_date;
--
-- 115.30 (END)
--
begin
if p_type = 'E' then
  --
  if ( NOT p_fpd_rule_found
       OR
       (p_fpd_rule_found AND nvl(p_fpd_rule_value,'N') = 'N')
     ) then
    --
    -- Rehire before FPD not allowed
    --
    open csr_pds_exists;
    fetch csr_pds_exists into l_dummy;
    if csr_pds_exists%found  then
      close csr_pds_exists;
       hr_utility.set_message('800','PER_289309_ST_DATE_CHG_NOTALWD');
       hr_utility.raise_error;
    else
      close csr_pds_exists;
    end if;
  else
    --
    -- Rehire before FPD allowed
    --
    -- Check if new hire date is before LSPD of prev PDS
    --
    OPEN csr_inv_new_hd;
    FETCH csr_inv_new_hd INTO l_dummy;
    IF csr_inv_new_hd%FOUND THEN
      CLOSE csr_inv_new_hd;
      hr_utility.set_message('800','HR_449762_HD_GT_PREV_PDS');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_inv_new_hd;
    --
    -- Check if old start date overlaps another PDS
    --
    OPEN csr_overlap(p_old_start_date);
    FETCH csr_overlap INTO l_dummy;
    IF csr_overlap%FOUND THEN
      l_old_start_date_in_range := TRUE;
    ELSE
      l_old_start_date_in_range := FALSE;
    END IF;
    CLOSE csr_overlap;
    --
    -- Check if new start date overlaps another PDS
    --
    OPEN csr_overlap(p_new_start_date);
    FETCH csr_overlap INTO l_dummy;
    IF csr_overlap%FOUND THEN
      l_new_start_date_in_range := TRUE;
    ELSE
      l_new_start_date_in_range := FALSE;
    END IF;
    CLOSE csr_overlap;
    --
    -- Check if gaps are being updated top overlaps or vice versa
    --
    IF (l_new_start_date_in_range AND NOT l_old_start_date_in_range)
       OR
       (NOT l_new_start_date_in_range AND l_old_start_date_in_range)
    THEN
      hr_utility.set_message('800','HR_449760_EMP_HD_PDS');
      hr_utility.raise_error;
    END IF;
  end if; -- FPD rule check
  --
  -- Check the new hire date with other dates on PDS
  --
  OPEN csr_new_start_date;
  FETCH csr_new_start_date INTO l_dummy;
  IF csr_new_start_date%FOUND THEN
    CLOSE csr_new_start_date;
    hr_utility.set_message('800','HR_449739_EMP_HD_ATD');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_new_start_date;
  --
elsif p_type = 'C' then
  open csr_pdp_exists;
  fetch csr_pdp_exists into l_dummy;
  if csr_pdp_exists%found then
    close csr_pdp_exists;
     hr_utility.set_message('800','PER_289309_ST_DATE_CHG_NOTALWD');
     hr_utility.raise_error;
  else
    close csr_pdp_exists;
  end if;
else
  null;
end if;
--
end check_un_ended_pds_pdp;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_for_compl_actions >---------------------|
-- ----------------------------------------------------------------------------
--
procedure check_for_compl_actions(p_person_id NUMBER
                                 ,p_old_start_date DATE
                                 ,p_new_start_date DATE
                                 ,p_type VARCHAR2) is
--
-- Bug 4221947. In below cursor, check the payroll actions in between old start
-- date and one day before new start date.
--
cursor csr_compl_actions is
select 'y' from dual where exists
(SELECT NULL
         FROM pay_payroll_actions pac,
              pay_assignment_actions act,
              per_assignments_f asg
         WHERE asg.person_id = p_person_id
           AND act.assignment_id = asg.assignment_id
           AND asg.assignment_type = p_type
           AND pac.payroll_action_id = act.payroll_action_id
           AND pac.action_status = 'C'
           AND ((pac.effective_date BETWEEN p_old_start_date AND (p_new_start_date-1))
            OR  (pac.date_earned BETWEEN p_old_start_date AND (p_new_start_date-1))));
--
l_dummy varchar2(1);
--
begin
open csr_compl_actions;
fetch csr_compl_actions into l_dummy;
if csr_compl_actions%found then
   close csr_compl_actions;
   hr_utility.set_message(801,'HR_51810_EMP_COMPL_ACTIONS');
   hr_utility.raise_error;
else
  close csr_compl_actions;
end if;
--
end check_for_compl_actions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_contig_pds_pdp >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_contig_pds_pdp(p_person_id NUMBER
                              ,p_old_start_date DATE
                              ,p_type VARCHAR2) is
--
l_action_chk VARCHAR2(1) := 'N';
l_prev_end_date DATE;
l_date_start DATE;
l_act_term_date DATE;
--
cursor pds is
select date_start,actual_termination_date
from per_periods_of_service
WHERE PERSON_ID = P_PERSON_ID
ORDER BY date_start;
--
cursor pdp is
select date_start,actual_termination_date
from per_periods_of_placement
WHERE PERSON_ID = P_PERSON_ID
ORDER BY date_start;
--
begin
  l_action_chk := 'N';
  if p_type = 'E' then
      OPEN pds;
      l_prev_end_date := to_date('01/01/0001','DD/MM/YYYY');
      LOOP
         FETCH pds INTO l_date_start,l_act_term_date;
         EXIT WHEN pds%NOTFOUND;
         IF (l_date_start - 1 = l_prev_end_date) AND
            (p_old_start_date = l_date_start) THEN
           l_action_chk := 'Y';
           EXIT;
         END IF;
         l_prev_end_date := l_act_term_date;
      END LOOP;
      CLOSE pds;
  elsif p_type = 'C' then
      OPEN pdp;
      l_prev_end_date := to_date('01/01/0001','DD/MM/YYYY');
      LOOP
         FETCH pdp INTO l_date_start,l_act_term_date;
         EXIT WHEN pdp%NOTFOUND;
         IF (l_date_start - 1 = l_prev_end_date) AND
            (p_old_start_date = l_date_start) THEN
           l_action_chk := 'Y';
           EXIT;
         END IF;
         l_prev_end_date := l_act_term_date;
      END LOOP;
      CLOSE pdp;
  else
     null;
  end if;
  IF l_action_chk = 'Y' THEN
    hr_utility.set_message(801,'HR_51811_EMP_CONTIG_POS');
    hr_utility.raise_error;
  END IF;
--
end check_contig_pds_pdp;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_supe_pay >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_supe_pay(p_pds_or_pdp_id NUMBER
                        ,p_new_start_date DATE
                        ,p_type VARCHAR2) is
l_payroll_id number;
l_supervisor_id number;
l_temp varchar2(1);
--
-- Cannot move start date if there are assignment changes
-- only need to test the first assignment  row
--
cursor assignment_pds is
select a.payroll_id , a.supervisor_id
from   per_assignments_f a,
       per_periods_of_service p
where  a.period_of_service_id = p.period_of_service_id
and    p.period_of_service_id = p_pds_or_pdp_id
and    p_type= 'E'
and    p.date_start = a.effective_start_date;
--
cursor assignment_pdp is
select a.payroll_id , a.supervisor_id
from   per_assignments_f a,
       per_periods_of_placement p
where  a.period_of_placement_date_start = p.date_start
and    a.person_id = p.person_id
and    p.period_of_placement_id = p_pds_or_pdp_id
and    p_type= 'C'
and    p.date_start = a.effective_start_date;
--
begin
  if p_type = 'E' then
    open assignment_pds;
    fetch assignment_pds into l_payroll_id,l_supervisor_id;
    close assignment_pds;
  elsif p_type = 'C' then
    open assignment_pdp;
    fetch assignment_pdp into l_payroll_id,l_supervisor_id;
    close assignment_pdp;
  end if;
--
  if l_payroll_id is not null then   --currently always null for p_type = C
    begin
     select '1' into l_temp
     from  dual
     where exists ( select payroll_id
                    from pay_payrolls_f
                    where payroll_id = l_payroll_id
                    and   p_new_start_date between
                          effective_start_date and effective_end_date
                   );
     exception
       when no_data_found then
        hr_utility.set_message('801','HR_7679_EMP_SUP_PAY_NOT_EXIST');
        hr_utility.raise_error;
    end;
  end if;
  if l_supervisor_id is not null then
    begin
     select '1' into l_temp
     from  dual
     where exists ( select person_id
                    from per_all_people_f -- Fix 3562224
                    where person_id = l_supervisor_id
                    and   ( current_employee_flag = 'Y' OR current_npw_flag = 'Y') -- fix for the bug 9100657
                    and   p_new_start_date between
                          effective_start_date and effective_end_date
                  );
     exception
       when no_data_found then
        hr_utility.set_message('801','HR_7680_EMP_SUP_PAY_NOT_EXIST');
        hr_utility.raise_error;
    end;
  end if;
--
end check_supe_pay;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_sp_placements >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_sp_placements(p_person_id NUMBER
                             ,p_pds_or_pdp_id NUMBER
                             ,p_new_start_date DATE
                             ,p_type VARCHAR2) is
cursor csr_sp_placement_pds is
select 'x' from dual where exists
(select 1
 from per_spinal_point_placements_f sp,
      per_periods_of_service p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_service_id = p.period_of_service_id
 and   p.period_of_service_id = p_pds_or_pdp_id
 and   p_type = 'E'
 and   a.assignment_id = sp.assignment_id
 and   sp.effective_start_date > p.date_start
 -- and   sp.effective_start_date < p_new_start_date); --update for bug 6021004
 and   sp.effective_start_date <= p_new_start_date);
--
cursor csr_sp_placement_pdp is
select 'x' from dual where exists
(select 1
 from per_spinal_point_placements_f sp,
      per_periods_of_placement p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_placement_date_start = p.date_start
 and   p.period_of_placement_id = p_pds_or_pdp_id
 and   p_type = 'C'
 and   a.assignment_id = sp.assignment_id
 and   sp.effective_start_date > p.date_start
 and   sp.effective_start_date < p_new_start_date);
--
l_dummy varchar2(1);
--
begin
 if p_type = 'E' then
    open csr_sp_placement_pds;
    fetch csr_sp_placement_pds into l_dummy;
    if csr_sp_placement_pds%found then
       close csr_sp_placement_pds;
       hr_utility.set_message(801,'HR_6837_EMP_REF_DATE_CHG');
       hr_utility.raise_error;
    else
       close csr_sp_placement_pds;
    end if;
 elsif p_type = 'C' then
    open csr_sp_placement_pdp;
    fetch csr_sp_placement_pdp into l_dummy;
    if csr_sp_placement_pdp%found then
       close csr_sp_placement_pdp;
       hr_utility.set_message(801,'HR_6837_EMP_REF_DATE_CHG');
       hr_utility.raise_error;
    else
       close csr_sp_placement_pdp;
    end if;
 else
    null;
 end if;
--
end check_sp_placements;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_asg_rates >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_asg_rates(p_person_id NUMBER
                         ,p_pds_or_pdp_id NUMBER
                         ,p_new_start_date DATE
                         ,p_type VARCHAR2) is
cursor csr_asg_rates_pdp is
select 'x' from dual where exists
(select 1
 from pay_grade_rules_f pgr,
      per_periods_of_placement p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_placement_date_start = p.date_start
 and   p.period_of_placement_id = p_pds_or_pdp_id
 and   a.assignment_type = p_type
 and   a.assignment_id = pgr.grade_or_spinal_point_id
 and   pgr.rate_type = 'A'
 and   pgr.effective_start_date > p.date_start
 and   pgr.effective_start_date < p_new_start_date);
--
l_dummy varchar2(1);
--
begin
 if p_type = 'C' then
    open csr_asg_rates_pdp;
    fetch csr_asg_rates_pdp into l_dummy;
    if csr_asg_rates_pdp%found then
       close csr_asg_rates_pdp;
       hr_utility.set_message(801,'PER_289851_CWK_ASG_RATE_EXISTS');
       hr_utility.raise_error;
    else
       close csr_asg_rates_pdp;
    end if;
 else
    null;
 end if;
--
end check_asg_rates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_cost_allocation >------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_cost_allocation(p_person_id NUMBER
                               ,p_pds_or_pdp_id NUMBER
                               ,p_new_start_date DATE
                               ,p_type VARCHAR2) is
cursor csr_cost_pds is
select 'x' from dual where exists
(select 1
 from PAY_COST_ALLOCATIONS_F ca,
      per_periods_of_service p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_service_id = p.period_of_service_id
 and   p.period_of_service_id = p_pds_or_pdp_id
 and   p_type = 'E'
 and   a.assignment_id = ca.assignment_id
 and   ca.effective_start_date > p.date_start
 and   ca.effective_start_date < p_new_start_date);
--
cursor csr_cost_pdp is
select 'x' from dual where exists
(select 1
 from PAY_COST_ALLOCATIONS_F ca,
      per_periods_of_placement p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_placement_date_start = p.date_start
 and   p.period_of_placement_id = p_pds_or_pdp_id
 and   p_type = 'C'
 and   a.assignment_id = ca.assignment_id
 and   ca.effective_start_date > p.date_start
 and   ca.effective_start_date < p_new_start_date);
--
l_dummy varchar2(1);
--
begin
 if p_type = 'E' then
    open csr_cost_pds;
    fetch csr_cost_pds into l_dummy;
    if csr_cost_pds%found then
      close csr_cost_pds;
      hr_utility.set_message(801,'HR_7860_EMP_REF_DATE_CHG');
      hr_utility.raise_error;
    else
      close csr_cost_pds;
    end if;
 elsif p_type = 'C' then
    open csr_cost_pdp;
    fetch csr_cost_pdp into l_dummy;
    if csr_cost_pdp%found then
      close csr_cost_pdp;
      hr_utility.set_message(801,'HR_7860_EMP_REF_DATE_CHG');
      hr_utility.raise_error;
    else
      close csr_cost_pdp;
    end if;
 else
    null;
 end if;
--
end check_cost_allocation;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_budget_values >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_budget_values(p_person_id NUMBER
                             ,p_pds_or_pdp_id NUMBER
                             ,p_new_start_date DATE
                             ,p_type VARCHAR2) is
cursor csr_budget_pds is
select 'x' from dual where exists
(select 1
 from per_assignment_budget_values_f bud,
      per_periods_of_service p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_service_id = p.period_of_service_id
 and   p.period_of_service_id = p_pds_or_pdp_id
 and   p_type = 'E'
 and   a.assignment_id = bud.assignment_id
 and   bud.effective_start_date > p.date_start
 and   bud.effective_start_date < p_new_start_date);
--
cursor csr_budget_pdp is
select 'x' from dual where exists
(select 1
 from per_assignment_budget_values_f bud,
      per_periods_of_placement p,
      per_assignments_f a
 where a.person_id = p_person_id
 and   a.period_of_placement_date_start = p.date_start
 and   p.period_of_placement_id = p_pds_or_pdp_id
 and   p_type = 'C'
 and   a.assignment_id = bud.assignment_id
 and   bud.effective_start_date > p.date_start
 and   bud.effective_start_date < p_new_start_date);
--
l_dummy varchar2(1);
--
begin
 if p_type = 'E' then
    open csr_budget_pds;
    fetch csr_budget_pds into l_dummy;
    if csr_budget_pds%found then
      close csr_budget_pds;
      hr_utility.set_message(801,'HR_7860_EMP_REF_DATE_CHG');
      hr_utility.raise_error;
    else
      close csr_budget_pds;
    end if;
 elsif p_type = 'C' then
    open csr_budget_pdp;
    fetch csr_budget_pdp into l_dummy;
    if csr_budget_pdp%found then
      close csr_budget_pdp;
      hr_utility.set_message(801,'HR_7860_EMP_REF_DATE_CHG');
      hr_utility.raise_error;
    else
      close csr_budget_pdp;
    end if;
 else
    null;
 end if;
--
end check_budget_values;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_people_changes >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_people_changes(p_person_id NUMBER
                              ,p_earlier_date DATE
                              ,p_later_date DATE
                              ,p_old_start_date DATE) is
cursor csr_people_change is
select 'x' from dual where exists
(select 1
from per_people_f p
where p.effective_start_date between p_earlier_date and p_later_date
and   p.effective_start_date <> p_old_start_date
and p.person_id = p_person_id
union
select 1
from per_people_f p
where p.effective_start_date = p_old_start_date
and   p.current_applicant_flag = 'Y'
and p.person_id = p_person_id);
-- union added to take care of cases when an employee is made
-- an internal applicant on the hire date itself. (bug 4025645)
--
l_dummy varchar2(1);
--
begin
  open csr_people_change;
  fetch csr_people_change into l_dummy;
  if csr_people_change%found then
    close csr_people_change;
    hr_utility.set_message(801,'HR_6841_EMP_REF_DATE_CHG');
    hr_utility.raise_error;
  else
    close csr_people_change;
  end if;
end check_people_changes;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_user_person_type_changes >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_user_person_type_changes(p_person_id NUMBER
                              ,p_earlier_date DATE
                              ,p_later_date DATE
                              ,p_old_start_date DATE) is
cursor csr_person_type_change is
select 'x' from dual where exists
(select 1
from per_person_type_usages_f ptu,
     per_person_types pt
where ptu.person_id = p_person_id
and ptu.effective_start_date <> p_old_start_date
and ptu.effective_start_date between p_earlier_date and p_later_date
and ptu.person_type_id = pt.person_type_id
and pt.system_person_type ='EMP');
--
l_dummy varchar2(1);
--
begin
  open csr_person_type_change;
  fetch csr_person_type_change into l_dummy;
  if csr_person_type_change%found then
    close csr_person_type_change;
    hr_utility.set_message(800,'PER_289306_PTU_CHG_EXISTS');
    hr_utility.raise_error;
  else
    close csr_person_type_change;
  end if;
end check_user_person_type_changes;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_asg_st_change >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_asg_st_change(p_person_id NUMBER
                             ,p_earlier_date DATE
                             ,p_later_date DATE
                             ,p_type VARCHAR2
                             ,p_old_start_date DATE) is
cursor csr_asg_status is
select 'x' from dual where exists
(select 1
 from per_assignments a
     ,per_assignments_f f
 where f.effective_start_date between  p_earlier_date and p_later_date
 and   f.effective_start_date <> p_old_start_date
 and   f.assignment_id = a.assignment_id
 and   a.assignment_type = p_type
 and   f.assignment_status_type_id <> a.assignment_status_type_id
 and   f.person_id = a.person_id
 and   a.person_id = p_person_id);
--
l_dummy varchar2(1);
--
begin
  open csr_asg_status;
  fetch csr_asg_status into l_dummy;
  if csr_asg_status%found then
    close csr_asg_status;
    hr_utility.set_message(801,'HR_6838_EMP_REF_DATE_CHG');
    hr_utility.raise_error;
  else
    close csr_asg_status;
  end if;
--
end check_asg_st_change;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_asg_change >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_asg_change(p_person_id NUMBER
                         ,p_earlier_date DATE
                         ,p_later_date DATE
                         ,p_old_start_date DATE) is
cursor csr_asg_change is
select 'x' from dual where exists
(select 1
 from per_assignments_f f
 where f.effective_start_date between  p_earlier_date and p_later_date
 and   f.effective_start_date <> p_old_start_date
 and   f.person_id = p_person_id);
--
l_dummy varchar2(1);
--
begin
  open csr_asg_change;
  fetch csr_asg_change into l_dummy;
  if csr_asg_change%found then
    close csr_asg_change;
    hr_utility.set_message(801,'HR_6839_EMP_REF_DATE_CHG');
    hr_utility.raise_error;
  else
    close csr_asg_change;
  end if;
--
end check_asg_change;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_prev_asg >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_prev_asg(p_person_id NUMBER
                        ,p_type VARCHAR2
                        ,p_old_start_date DATE
                        ,p_new_start_date DATE) is
cursor csr_prev_asg is
select 'x' from dual where exists
(select 1
 from per_assignments_f f
 where f.effective_start_date >= p_new_start_date
 and   f.effective_start_date < p_old_start_date
 and   f.assignment_type =p_type
 and   f.person_id = p_person_id);
--
l_dummy varchar2(1);
--
begin
  open csr_prev_asg;
  fetch csr_prev_asg into l_dummy;
  if csr_prev_asg%found then
    close csr_prev_asg;
    hr_utility.set_message(801,'HR_6840_EMP_ENTER_PERIOD');
    hr_utility.raise_error;
  else
    close csr_prev_asg;
  end if;
--
end check_prev_asg;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_recur_ee >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_recur_ee(p_person_id NUMBER
                        ,p_new_start_date DATE
                        ,p_old_start_date DATE
                        ,p_warn_raise IN OUT NOCOPY VARCHAR2) is
--
l_warn VARCHAR2(1);
l_earlier_date DATE;
l_later_date DATE;
--
begin
  l_warn := p_warn_raise;
  if p_new_start_date > p_old_start_date then
    l_earlier_date := p_old_start_date;
    l_later_date   := p_new_start_date;
  else
    l_earlier_date := p_new_start_date;
    l_later_date   := p_old_start_date;
  end if;
  begin
    select 'Y'
    into l_warn
    from dual
    where exists
    (select null
     from pay_element_entries_f ee,
          pay_element_links_f el,
          pay_element_types_f et
     where ee.assignment_id in
       (select assignment_id
        from per_assignments_f asg
        where asg.person_id = p_person_id
        and asg.effective_start_date between l_earlier_date and l_later_date)
     and ee.element_link_id = el.element_link_id
     and el.element_type_id = et.element_type_id
     and et.processing_type = 'R');
    exception when NO_DATA_FOUND then null;
  end;
  p_warn_raise := l_warn;
--
end check_recur_ee;
--

-- changes start for bug 6640794
-- ----------------------------------------------------------------------------
-- |-------------------------< check_ben_enteries >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_ben_enteries(p_person_id number,
                             p_new_start_date date, --Changes done for bug 7481343
                             p_old_start_date date) is  -- Changed for bug 8836797

-- Start changes for bug 8836797
Cursor c_get_bg_id is
 select business_group_id
 from per_all_people_f
 where person_id = p_person_id
 and p_new_start_date between effective_start_date and effective_end_date;

cursor c_ben_non_GSP(cl_business_group_id number, cl_start_date date, cl_end_date date) is
 SELECT 1
 FROM ben_ptnl_ler_for_per bplfp, ben_ler_f blf
 where blf.ler_id = bplfp.ler_id
 and blf.typ_cd <> 'GSP'
 and blf.business_group_id = cl_business_group_id
 and bplfp.business_group_id = cl_business_group_id
 and bplfp.person_id = p_person_id
 and bplfp.LF_EVT_OCRD_DT between cl_start_date and cl_end_date --Changes done for bug 7481343
 and bplfp.ptnl_ler_for_per_stat_cd = 'PROCD';

l_start_date                  Date;
l_end_date                    Date;
l_bg_id                       number;
l_proc                        varchar2(100):=g_package||'check_ben_enteries';
-- End changes for bug 8836797

dummy varchar2(2);

begin

 hr_utility.set_location('Entering:'|| l_proc, 10);

 if p_new_start_date > p_old_start_date then
  l_start_date := p_old_start_date;
  l_end_date := p_new_start_date;
 elsif p_old_start_date > p_new_start_date then
  l_start_date := p_new_start_date;
  l_end_date := p_old_start_date;
 end if;

 open c_get_bg_id;
 fetch c_get_bg_id into l_bg_id;
 close c_get_bg_id;

 open c_ben_non_GSP(l_bg_id, l_start_date, l_end_date);
 fetch c_ben_non_GSP into dummy;

 if c_ben_non_GSP%found then
  close c_ben_non_GSP;
  hr_utility.set_message(800,'PER_449869_PROCD_LE_EXISTS');
  hr_utility.raise_error;
 end if;

 close c_ben_non_GSP;

 hr_utility.set_location('Leaving:'|| l_proc, 10);

end check_ben_enteries;
--changes end for bug 6640794

-- changes start for bug 8836797
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ben_GSP_enteries >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ben_GSP_enteries(p_person_id number,
                                  p_new_start_date date,
                                  p_old_start_date date,
                                  p_effective_date date) is

Cursor Person_Info Is
 Select Asgt.Business_Group_id,
        Asgt.effective_start_date
  from Per_All_Assignments_f Asgt
  Where person_id = p_person_id
  and primary_flag = 'Y'
  and assignment_type = 'E'
  and P_Effective_Date Between Asgt.Effective_Start_Date and Asgt.Effective_End_Date;

cursor c_ben_ptnl_ler_GSP(cl_business_group_id number, cl_start_date date, cl_end_date date) is
 SELECT bplfp.ptnl_ler_for_per_id,
        bplfp.object_version_number
 FROM ben_ptnl_ler_for_per bplfp,
      ben_ler_f blf
 where blf.ler_id = bplfp.ler_id
  and blf.typ_cd = 'GSP'
  and blf.business_group_id = cl_business_group_id
  and bplfp.business_group_id = cl_business_group_id
  and bplfp.person_id = p_person_id
  and bplfp.lf_evt_ocrd_dt between cl_start_date and cl_end_date
  and bplfp.ptnl_ler_for_per_stat_cd = 'PROCD';

cursor c_ben_ler_GSP(cl_business_group_id number, cl_ptnl_ler_for_per_id number) is
 select per_in_ler_id,
        object_version_number
 from ben_per_in_ler
 where business_group_id = cl_business_group_id
  and person_id = p_person_id
  and ptnl_ler_for_per_id = cl_ptnl_ler_for_per_id;

Cursor c_ben_per_elctbl_chc_GSP(cl_business_group_id number, cl_per_in_ler_id number) is
 select bepec.elig_per_elctbl_chc_id,
        bepec.object_version_number
 from ben_elig_per_elctbl_chc bepec, ben_pil_elctbl_chc_popl bpecp
 where bpecp.pil_elctbl_chc_popl_id = bepec.pil_elctbl_chc_popl_id
 and bpecp.business_group_id = cl_business_group_id
 and bepec.business_group_id = cl_business_group_id
 and bepec.per_in_ler_id = cl_per_in_ler_id
 and bpecp.per_in_ler_id = cl_per_in_ler_id;

Cursor c_ben_enrt_rt_GSP(cl_elig_per_elctbl_chc_id number) is
 select enrt_rt_id,
        object_version_number
 from ben_enrt_rt
 where elig_per_elctbl_chc_id = cl_elig_per_elctbl_chc_id;

l_bg_id                       Per_All_Assignments_F.Business_Group_id%TYPE;
l_New_Enrlmt_Dt               Date;
l_start_date                  Date;
l_end_date                    Date;

l_ptnl_ler_for_per_id         Ben_Ptnl_Ler_For_Per.PTNL_LER_FOR_PER_ID%TYPE;
l_Ptnl_Ovn                    Ben_Ptnl_Ler_For_Per.Object_Version_Number%TYPE;

l_per_in_ler_id               Ben_Per_In_Ler.Per_In_Ler_Id%TYPE;
l_procd_dt                    Date;
l_strtd_dt                    Date;
l_voidd_dt                    Date;
L_Pil_Ovn                     Ben_Per_In_Ler.Object_version_Number%TYPE;

L_Elig_Per_Elctbl_Chc_Id      Ben_Elig_Per_Elctbl_Chc.Elig_Per_Elctbl_Chc_Id%TYPE;
l_Elctbl_Ovn                  Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;

l_ENRT_RT_ID                  ben_enrt_rt.ENRT_RT_ID%type;
l_enrt_rt_ovn                 ben_enrt_rt.object_version_number%type;

l_proc                        varchar2(100):= g_package||'.update_ben_GSP_enteries';
begin

 hr_utility.set_location('Entering:'|| l_proc, 10);

 if p_new_start_date > p_old_start_date then
  l_start_date := p_old_start_date;
  l_end_date := p_new_start_date;
 elsif p_old_start_date > p_new_start_date then
  l_start_date := p_new_start_date;
  l_end_date := p_old_start_date;
 end if;

 open Person_Info;
 fetch person_info into l_BG_id ,l_new_Enrlmt_Dt;
 close Person_Info;

 hr_utility.set_location('Processing Person_id '|| P_person_id, 20);

 for l_ben_ptnl_ler_GSP in c_ben_ptnl_ler_GSP(l_bg_id,l_start_date, l_end_date)
 loop
  --
  l_ptnl_ler_for_per_id := l_ben_ptnl_ler_GSP.ptnl_ler_for_per_id;
  l_ptnl_ovn := l_ben_ptnl_ler_GSP.object_version_number;

  for l_ben_ler_GSP in c_ben_ler_GSP(l_bg_id, l_ptnl_ler_for_per_id)
  loop
   --
   l_per_in_ler_id := l_ben_ler_GSP.per_in_ler_id;
   l_pil_ovn := l_ben_ler_GSP.object_version_number;

   for l_ben_per_elctbl_chc_GSP in c_ben_per_elctbl_chc_GSP(l_bg_id, l_per_in_ler_id)
   loop
    --
    l_elig_per_elctbl_chc_id := l_ben_per_elctbl_chc_GSP.elig_per_elctbl_chc_id;
    l_Elctbl_Ovn := l_ben_per_elctbl_chc_GSP.object_version_number;

    for l_ben_enrt_rt_id in c_ben_enrt_rt_GSP(l_elig_per_elctbl_chc_id)
    loop
     --
     l_enrt_rt_id := l_ben_enrt_rt_id.enrt_rt_id;
     l_enrt_rt_ovn := l_ben_enrt_rt_id.object_version_number;

     hr_utility.set_location('Processing BEN Rate:'|| l_enrt_rt_id, 30);

     ben_Enrollment_Rate_api.update_Enrollment_Rate
      (p_enrt_rt_id             => l_enrt_rt_id
      ,p_rt_strt_dt             => l_new_Enrlmt_Dt
      ,p_object_version_number  => l_enrt_rt_ovn
      ,p_effective_date         => l_new_Enrlmt_Dt);
     --
    end loop;

    hr_utility.set_location('Processing Electable Choice:'|| l_elig_per_elctbl_chc_id, 40);

    ben_elig_per_elc_chc_api.update_perf_ELIG_PER_ELC_CHC
     (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id
     ,p_enrt_cvg_strt_dt        => l_new_Enrlmt_Dt
     ,p_ENRT_CVG_STRT_DT_CD     => l_new_Enrlmt_Dt
     ,p_object_version_number   => l_Elctbl_Ovn
     ,p_effective_date          => l_new_Enrlmt_Dt);
    --
   end loop;

   hr_utility.set_location('Processing Person Life Event:'|| l_per_in_ler_id, 50);

   ben_person_life_event_api.update_Person_Life_Event
    (p_per_in_ler_id            => l_per_in_ler_id
    ,p_lf_evt_ocrd_dt           => l_new_Enrlmt_Dt
    ,p_per_in_ler_stat_cd       => 'STRTD'
    ,p_procd_dt                 => l_procd_dt
    ,p_strtd_dt                 => l_strtd_dt
    ,p_voidd_dt                 => l_voidd_dt
    ,p_object_version_number    => L_Pil_Ovn
    ,p_effective_date           => l_new_Enrlmt_Dt);

   Ben_Person_Life_Event_api.update_person_life_event
    (p_per_in_ler_id            =>  l_per_in_ler_id
    ,p_per_in_ler_stat_cd       =>  'PROCD'
    ,p_procd_dt                 =>  l_procd_dt
    ,p_strtd_dt                 =>  l_strtd_dt
    ,p_voidd_dt                 =>  l_voidd_dt
    ,p_object_version_number    =>  l_pil_ovn
    ,P_EFFECTIVE_DATE           =>  l_new_Enrlmt_Dt);
    --
   end loop;

  hr_utility.set_location('Processing Potential Person Life Event:'|| l_per_in_ler_id, 60);

  ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
   (p_ptnl_ler_for_per_id       => l_ptnl_ler_for_per_id
   ,p_lf_evt_ocrd_dt            => l_new_Enrlmt_Dt
   ,p_object_version_number     => l_Ptnl_Ovn
   ,p_effective_date            => l_new_Enrlmt_Dt);
  --
 end loop;

 hr_utility.set_location('Leaving:'|| l_proc, 100);

end update_ben_GSP_enteries;
-- End changes for bug 8836797

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_period >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_period(p_person_id number
                       ,p_old_start_date date
                       ,p_new_start_date date
                       ,p_type VARCHAR2) is
cursor pds is select *
               from per_periods_of_service pds
               where person_id = p_person_id
               and   date_start = p_old_start_date
               for update of date_start nowait;
cursor pdp is select *
               from per_periods_of_placement pdp
               where person_id = p_person_id
               and   date_start = p_old_start_date
               for update of date_start nowait;
--
pds_rec pds%rowtype;
pdp_rec pdp%rowtype;
l_object_version_number number;
--
begin
if p_type = 'E' then
   open pds;
   <<pds_loop>>
   loop
      exit pds_loop when pds%NOTFOUND;
      fetch pds into pds_rec;
   end loop pds_loop;
   if pds%rowcount <>1 then
      close pds;
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_change_start_date_api.update_period');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   else
      close pds;
   end if;
   l_object_version_number := pds_rec.object_version_number;
   per_pds_upd.upd(p_period_of_service_id   => pds_rec.period_of_service_id
                   ,p_date_start            => p_new_start_date
                   ,p_object_version_number => l_object_version_number
                   ,p_effective_date        => p_old_start_date);
elsif p_type = 'C' then
   open pdp;
   <<pdp_loop>>
   loop
      exit pdp_loop when pdp%NOTFOUND;
      fetch pdp into pdp_rec;
   end loop pdp_loop;
   if pdp%rowcount <>1 then
      close pdp;
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_change_start_date_api.update_period');
      hr_utility.set_message_token('STEP','2');
      hr_utility.raise_error;
   else
      close pdp;
   end if;
     update per_periods_of_placement
     set    date_start = p_new_start_date
     where  period_of_placement_id = pdp_rec.period_of_placement_id
     and    date_start = p_old_start_date
     and    person_id = p_person_id;
end if;
--
end update_period;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_spinal_placement >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_spinal_placement(p_person_id number
                                 ,p_old_start_date date
                                 ,p_new_start_date date
                                 ,p_type VARCHAR2) is
cursor csr_ssp is
select placement_id
from   per_spinal_point_placements_f sp
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = p_type
                         and a.effective_start_date = p_old_start_date)
and    sp.effective_start_date = p_old_start_date;
--
l_sp_id per_spinal_point_placements_f.placement_id%TYPE;
--
begin
   open csr_ssp;
   loop
      fetch csr_ssp into l_sp_id;
      exit when csr_ssp%NOTFOUND;
      update per_spinal_point_placements_f
      set effective_start_date = p_new_start_date
      where effective_start_date = p_old_start_date
      and   placement_id = l_sp_id;
      if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PER_SPINAL_POINT_PLACEMENTS_F');
          hr_utility.raise_error;
      end if;
   end loop;
   close csr_ssp;
end update_spinal_placement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_asg_rate >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_asg_rate(p_person_id number
                         ,p_old_start_date date
                         ,p_new_start_date date
                         ,p_type VARCHAR2) is
cursor csr_rate is
select grade_rule_id
from   pay_grade_rules_f pgr
where  grade_or_spinal_point_id in (select a.assignment_id
                                    from per_assignments_f a
                                    where person_id = p_person_id
                                    and a.assignment_type = p_type
                                    and a.effective_start_date = p_old_start_date)
and    pgr.rate_type = 'A'
and    pgr.effective_start_date = p_old_start_date;
--
l_pgr_id pay_grade_rules_f.grade_rule_id%TYPE;
--
begin
   open csr_rate;
   loop
      fetch csr_rate into l_pgr_id;
      exit when csr_rate%NOTFOUND;
      update pay_grade_rules_f
      set effective_start_date = p_new_start_date
      where effective_start_date = p_old_start_date
      and   grade_rule_id = l_pgr_id;
      if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PAY_GRADE_RULES_F');
          hr_utility.raise_error;
      end if;
   end loop;
   close csr_rate;
end update_asg_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cost_allocation >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cost_allocation(p_person_id number
                                ,p_old_start_date date
                                ,p_new_start_date date
                                ,p_type VARCHAR2) is
cursor csr_cost is
select COST_ALLOCATION_ID
from   PAY_COST_ALLOCATIONS_F pca
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = p_type
                         and a.effective_start_date = p_old_start_date)
and    pca.effective_start_date = p_old_start_date;
--
l_ca_id PAY_COST_ALLOCATIONS_F.COST_ALLOCATION_ID%TYPE;
--
begin
   open csr_cost;
   loop
      fetch csr_cost into l_ca_id;
      exit when csr_cost%NOTFOUND;
      update PAY_COST_ALLOCATIONS_F
      set effective_start_date = p_new_start_date
      where effective_start_date = p_old_start_date
      and   COST_ALLOCATION_ID = l_ca_id;
      if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PAY_COST_ALLOCATIONS_F');
          hr_utility.raise_error;
      end if;
  end loop;
  close csr_cost;
end update_cost_allocation;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_asg_budget  >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_asg_budget(p_person_id number
                           ,p_old_start_date date
                           ,p_new_start_date date
                           ,p_type VARCHAR2) is
cursor csr_abv is
select abv.assignment_budget_value_id
from   per_assignment_budget_values_f abv
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = p_type
                         and a.effective_start_date = p_old_start_date)
and    abv.effective_start_date = p_old_start_date;
--
l_abv_id per_assignment_budget_values_f.assignment_budget_value_id%TYPE;
--
begin
  open csr_abv;
  loop
      fetch csr_abv into l_abv_id;
      exit when csr_abv%NOTFOUND;
      update PER_ASSIGNMENT_BUDGET_VALUES_F
      set effective_start_date         = p_new_start_date
      where effective_start_date       = p_old_start_date
      and effective_end_date           >= p_new_start_date
      and   ASSIGNMENT_BUDGET_VALUE_ID = l_abv_id;
      if sql%rowcount <1 then
          null;
      end if;
  end loop;
  close csr_abv;
end update_asg_budget;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_tax >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_tax(p_person_id number
                    ,p_new_start_date date) is
cursor csr_get_bg is
select business_group_id
from   per_people_f
where person_id = p_person_id;
--
l_business_group_id  number;
l_ret_code           number;
l_ret_text    varchar2(240);
--
begin
   open csr_get_bg;
   fetch csr_get_bg into l_business_group_id;
   if csr_get_bg%NOTFOUND then
   close csr_get_bg;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'hr_change_start_date_api.update_tax');
      hr_utility.set_message_token('STEP', '1');
      hr_utility.raise_error;
   end if;
   close csr_get_bg;
   pay_us_emp_dt_tax_rules.default_tax_with_validation
                          (p_assignment_id        => null
                          ,p_person_id            => p_person_id
                          ,p_effective_start_date => p_new_start_date
                          ,p_effective_end_date   => null
                          ,p_session_date         => null
                          ,p_business_group_id    => l_business_group_id
                          ,p_from_form            => 'Person'
                          ,p_mode                 => null
                          ,p_location_id          => null
                          ,p_return_code          => l_ret_code
                          ,p_return_text          => l_ret_text
                          );
end update_tax;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_apl_asg  >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_apl_asg(p_person_id number
                        ,p_old_start_date date
                        ,p_new_start_date date) is
cursor csr_apl_asg is
select assignment_id
from   per_all_assignments_f a
where  a.effective_end_date   = p_old_start_date - 1
and    a.assignment_type      = 'A'
and    a.person_id            = p_person_id;
--
l_assignment_id per_all_assignments_f.assignment_id%TYPE;
--
begin
  open csr_apl_asg;
  loop
    fetch csr_apl_asg into l_assignment_id;
    exit when csr_apl_asg%NOTFOUND;
    update per_assignments_f a
    set   a.effective_end_date   = p_new_start_date - 1
    where  a.effective_end_date   =
             (select max(a2.effective_end_date)
              from   per_assignments_f a2
              where  a2.assignment_id = a.assignment_id
              and    a2.assignment_type = 'A')
    and    a.assignment_id        = l_assignment_id;
    if sql%rowcount <1 then
       hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
       hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
       hr_utility.raise_error;
    end if;
  end loop;
  close csr_apl_asg;
end update_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_apl >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_apl(p_person_id number
                    ,p_old_start_date date
                    ,p_new_start_date date) is
cursor csr_apl is
select application_id
from  per_applications a
where   a.person_id = p_person_id
and     a.date_received =
(select  max(a2.date_received)
from    per_applications a2
where   a2.person_id = a.person_id
and     a2.date_received < p_new_start_date);
--
l_application_id number;
--
begin
  open csr_apl;
  loop
    fetch csr_apl into l_application_id;
    exit when csr_apl%NOTFOUND;
      update  per_applications a1
      set     a1.date_end = p_new_start_date - 1
      where   a1.application_id = l_application_id
      and not exists (select 1
                      from per_people_f peo
                      where peo.person_id = p_person_id
                      and   a1.person_id  = peo.person_id
                      and   peo.effective_start_date = p_old_start_date
                      and   peo.current_applicant_flag = 'Y');
    if sql%rowcount <1 then
       hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
       hr_utility.set_message_token('TABLE','PER_APPLICATIONS');
       hr_utility.raise_error;
    end if;
  end loop;
  close csr_apl;
end update_apl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pay_proposal >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pay_proposal(p_person_id number
                             ,p_old_start_date date
                             ,p_new_start_date date
                             ,p_type VARCHAR2) is
cursor get_pay_proposal
is
select pay_proposal_id
from   per_pay_proposals
where  change_date = p_old_start_date
and exists (select 1
 from   per_assignments_f
 where  person_id = p_person_id
 and per_pay_proposals.assignment_id = per_assignments_f.assignment_id
--  and    primary_flag = 'Y'
 and    effective_start_date = p_new_start_date
 and    assignment_type = p_type);
--
cursor prv_pay_proposals
is
select  count(*)
from per_pay_proposals
where   change_date <= p_new_start_date
and     assignment_id =
   (select assignment_id
   from   per_assignments_f
   where  person_id = p_person_id
   and    primary_flag = 'Y'
   and    effective_start_date = p_new_start_date
   and    assignment_type = p_type);

-- start changes for bug 8267359
cursor get_updtd_proposal_rows
is
select pay_proposal_id
from   per_pay_proposals
where  Last_change_date = p_old_start_date
and exists (select 1
 from   per_assignments_f
 where  person_id = p_person_id
 and per_pay_proposals.assignment_id = per_assignments_f.assignment_id
 and    effective_start_date = p_new_start_date
 and    assignment_type = p_type);
-- end changes for bug 8267359

l_count     NUMBER;
l_dummy  number;
l_pay_proposal_id    number;
--
begin
--
--
  l_count := 0;

  hr_utility.set_location('update_pay_proposal',1);

  open prv_pay_proposals;
  fetch prv_pay_proposals into l_count;
  hr_utility.set_location('update_pay_proposal.count = '||l_count,2);

  if prv_pay_proposals%FOUND then
    close prv_pay_proposals;
  else
    close prv_pay_proposals;
  hr_utility.set_location('update_pay_proposal',10);
  end if;

  if l_count > 1 then
      hr_utility.set_message('800','PER_289794_HISTORIC_SAL_PRPSL');
      hr_utility.raise_error;
  else

  open get_pay_proposal;
  loop
    fetch get_pay_proposal into l_pay_proposal_id;
    exit when get_pay_proposal%NOTFOUND;
--    if get_pay_proposal%FOUND then
--      close get_pay_proposal;
      begin
   hr_utility.set_location('update_pay_proposal.p_new_start_date = '||to_char(p_new_start_date,'DD-MON-YYYY'),40);
   hr_utility.set_location('update_pay_proposal.p_old_start_date = '||to_char(p_old_start_date,'DD-MON-YYYY'),40);
   hr_utility.set_location('update_pay_proposal.p_person_id = '||p_person_id,40);
   hr_utility.set_location('update_pay_proposal.p_type = '||p_type,40);
   hr_utility.set_location('update_pay_proposal.pay_proposal_id = '||l_pay_proposal_id,40);
--
         update per_pay_proposals
         set change_date   = p_new_start_date
         where change_date    = p_old_start_date
         and pay_proposal_id  = l_pay_proposal_id;
/*         and   assignment_id =
         (select assignment_id
          from per_assignments_f
          where person_id = p_person_id
          and   primary_flag = 'Y'
       and   effective_start_date = p_new_start_date
       and   assignment_type = p_type);
*/
   hr_utility.set_location('update_pay_proposal',50);
         if sql%ROWCOUNT <> 1 then
       raise NO_DATA_FOUND;
         end if;
        exception
    when NO_DATA_FOUND then
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Update_row');
      hr_utility.set_message_token('STEP','4');
      hr_utility.raise_error;
        end;
--     else
--       null;
--     end if;
     end loop;
     close get_pay_proposal;

   -- start changes for bug 8267359
   open get_updtd_proposal_rows;
   loop
     fetch get_updtd_proposal_rows into l_pay_proposal_id;
     exit when get_updtd_proposal_rows%NOTFOUND;

     BEGIN
      hr_utility.set_location('update_pay_proposal.pay_proposal_id = '||l_pay_proposal_id,60);
      --
      update per_pay_proposals
      set last_change_date   = p_new_start_date
      where last_change_date    = p_old_start_date
      and pay_proposal_id  = l_pay_proposal_id;

      hr_utility.set_location('update_pay_proposal',70);

      if sql%ROWCOUNT <> 1 then
       raise NO_DATA_FOUND;
      end if;
     exception
      when NO_DATA_FOUND then
       hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','Update_row');
       hr_utility.set_message_token('STEP','4');
       hr_utility.raise_error;
     end;
   end loop;
   close get_updtd_proposal_rows;
   -- end changes for bug 8267359

  end if;
end update_pay_proposal;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< run_alu_ee >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure run_alu_ee(p_person_id number
                    ,p_old_start_date date
                    ,p_new_start_date date
                    ,p_type VARCHAR2) is
cursor csr_get_bg is
select business_group_id
from   per_people_f
where  person_id = p_person_id;
--
cursor ass_cur is
select assignment_id
from   per_all_assignments_f paf
where  paf.person_id       = p_person_id
and    paf.assignment_type = p_type
and    p_new_start_date between
       paf.effective_start_date and paf.effective_end_date;
--
l_business_group_id  number;
l_assignment_id         number; -- assignment_id of employee assignment.
l_validation_start_date date;   -- End date_of Assignment.
l_validation_end_date   date;   -- End date_of Assignment.
l_entries_changed       VARCHAR2(1);
--
begin
   open csr_get_bg;
   fetch csr_get_bg into l_business_group_id;
   if csr_get_bg%NOTFOUND then
   close csr_get_bg;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'hr_change_start_date_api.update_tax');
      hr_utility.set_message_token('STEP', '1');
      hr_utility.raise_error;
   end if;
   close csr_get_bg;
   -- Set the correct validation start and end dates for
   -- the assignments.  These are the same for all
   -- assignments of a multiple assignment person.
if(p_new_start_date > p_old_start_date) then
   -- We have moved the hire date forwards.
   l_validation_start_date := p_old_start_date;
   l_validation_end_date   := (p_new_start_date - 1);
elsif(p_new_start_date < p_old_start_date) then
   -- We have moved the hire date backwards.
   l_validation_start_date := p_new_start_date;
   l_validation_end_date   := (p_old_start_date - 1);
end if;
--
open ass_cur;
loop
  fetch ass_cur into l_assignment_id;
  exit when ass_cur%NOTFOUND;
  hrentmnt.maintain_entries_asg
          (p_assignment_id => l_assignment_id
          ,p_old_payroll_id => 2
          ,p_new_payroll_id => 1
          ,p_business_group_id => l_business_group_id
          ,p_operation => 'HIRE_APPL'  -- 'ASG_CRITERIA' for bug 5547271
          ,p_actual_term_date => NULL
          ,p_last_standard_date => NULL
          ,p_final_process_date => NULL
          ,p_validation_start_date => l_validation_start_date
          ,p_validation_end_date => l_validation_end_date
          ,p_dt_mode => 'CORRECTION'
          ,p_old_hire_date => p_old_start_date
          ,p_entries_changed => l_entries_changed);
    --
    hrentmnt.maintain_entries_asg
            (l_assignment_id
            ,l_business_group_id
            ,'CHANGE_PQC'
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL);
end loop;
close ass_cur;
end run_alu_ee;
--
-- Bug2614732 starts here.
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_probation_end >--------------------------|
-- ----------------------------------------------------------------------------
-- This internal procedure is used to update date_Probation_end
-- of Assignment records when the Person Hire Date is changed.
--
-- If the Person has multiple assignments starting on the same date
-- as Hire date and when the person Hire date is changed, then for
-- each Assignment if the probation detais exists then the
-- date_probation_end will be updated with new date_probation_end.
--
-- When there are datetrack updations on Assignment record then all
-- the records will be updated with new date_probation_end if the
-- assignment updation was not carried on Probation columns.
--
PROCEDURE UPDATE_PROBATION_END(p_person_id number,
                               p_new_effective_date date) IS

--
-- select all the assignments for the person_id starting on the Hire date.
--
Cursor csr_assignments(p_person_id number, p_new_effective_date date) IS
select distinct paf.assignment_id
from   per_assignments_f paf
where  paf.person_id = p_person_id
and    paf.date_probation_end is not null
and    paf.effective_start_date = p_new_effective_date;
--
-- select any datetrack updations on given Assignment_id.
--
Cursor csr_asg_updates(p_assignment_id number, p_new_effective_date date) IS
select paf.effective_start_date
from   per_assignments_f paf
where  paf.assignment_id = p_assignment_id
and    paf.effective_start_date >= p_new_effective_date
order by paf.effective_start_date;
--
-- select the probation details of the Assigment on the given effective date.
--
Cursor csr_probation_details(p_assignment_id number, p_effective_start_date date) IS
select paf.date_probation_end
      ,paf.probation_period
      ,paf.probation_unit
from   per_assignments_f paf
where  paf.assignment_id = p_assignment_id
and    paf.effective_start_date = p_effective_start_date;
--
-- local variables.
--
l_proc                    varchar2(30):='update_probation_end';
l_assignment_id           per_all_assignments_f.assignment_id%type;
l_date_probation_end1     per_all_assignments_f.date_probation_end%type;
l_probation_period1       per_all_assignments_f.probation_period%type;
l_probation_period        per_all_assignments_f.probation_period%type;
l_probation_unit1         per_all_assignments_f.probation_unit%type;
l_probation_unit          per_all_assignments_f.probation_unit%type;
l_new_date_probation_end  per_all_assignments_f.date_probation_end%type;
l_date_probation_end      per_all_assignments_f.date_probation_end%type;
l_new_effective_date      date;
l_new_start_date          date;
l_effective_start_date    date;
--
--
BEGIN
--
hr_utility.set_location('Entering:'|| l_proc, 10);
l_new_effective_date := p_new_effective_date;
l_new_start_date := p_new_effective_date;

FOR assignment_rec in csr_assignments(p_person_id, p_new_effective_date) LOOP
--
  -- for each Assignment of Person loop through.
  --
  l_assignment_id := assignment_rec.assignment_id;
  hr_utility.set_location('Assignment ID: '||l_assignment_id, 20);
  --
  -- Get old probation details.
  --
  open csr_probation_details(l_assignment_id, p_new_effective_date);
  fetch csr_probation_details into l_date_probation_end1, l_probation_period1, l_probation_unit1;
  close csr_probation_details;
  hr_utility.set_location('Old probation details: ', 30);
  hr_utility.set_location('date_probation_end:'||l_date_probation_end1, 30);
  hr_utility.set_location('probation_period: '||l_probation_period1, 30);
  hr_utility.set_location('probation_unit : '||l_probation_unit1, 30);
  --
  l_new_date_probation_end := null;
  --
  -- Get new probation end date.
  --
  hr_assignment.gen_probation_end(
            l_assignment_id,
              l_probation_period1,
              l_probation_unit1,
              l_new_effective_date,
              l_new_date_probation_end);
  --
  -- Update the Assignment updations.
  --
  For asg_update_rec in csr_asg_updates(l_assignment_id, p_new_effective_date) LOOP
  --
    -- for each updation on Assignment record loop through.
    -- check the probation period of updated asg. and If it is update on some other field
    -- then update the probation end date of this asg update.
    --
    l_effective_start_date := asg_update_rec.effective_start_date;
    --
    hr_utility.set_location('Assignment ID: '||l_assignment_id, 40);
    hr_utility.set_location('Effective start date.: '||l_effective_start_date, 40);
    --
    open csr_probation_details(l_assignment_id, l_effective_start_date);
    fetch csr_probation_details into l_date_probation_end, l_probation_period, l_probation_unit;
    if csr_probation_details%found then
    --
      if (l_date_probation_end <> l_date_probation_end1)
        or (l_probation_period <> l_probation_period1)
   or (l_probation_unit <> l_probation_unit1)      then
      --
        null;
        hr_utility.set_location('date probation end is not updated', 50);
      --
      else
      --
        hr_utility.set_location('date probation end is updated', 60);
        update per_assignments_f paf
   set    paf.date_probation_end = l_new_date_probation_end
   where  paf.assignment_id = l_assignment_id
   and    paf.effective_start_date = l_effective_start_date;
      --
      end if;
      close csr_probation_details;
      l_date_probation_end := null;
    --
    end if;
  --
  END LOOP;

--
END LOOP;
--
hr_utility.set_location('Leaving:'|| l_proc, 90);
--
END UPDATE_PROBATION_END;
--
-- Bug 2614732 ends here.
--
-- Fix for bug 3738058 starts here.
--
procedure check_extra_details_of_service(p_person_id number
                                        ,p_old_start_date date
			                    ,p_new_start_date date) is
--
-- Cursor to check for any updates in between old and new start dates.
--
cursor csr_extra_details IS
select 'Y'
from   pqp_assignment_attributes_f paa
      ,per_assignments_f paf
where  paf.person_id = p_person_id
and    paa.assignment_id = paf.assignment_id
and    paf.effective_start_date = trunc(p_old_start_date)
and    ( paa.effective_start_date between p_old_start_date+1 and p_new_start_date
        OR
	 paa.effective_end_date between p_old_start_date and p_new_start_date);
--
l_dummy varchar2(1);
--
begin
--
  open csr_extra_details;
  fetch csr_extra_details into l_dummy;
  if csr_extra_details%found then
     close csr_extra_details;
     hr_utility.set_message(800,'PER_449500_EXTRA_SER_DET_EXIST');
     hr_utility.raise_error;
  end if;
  close csr_extra_details;
--
end check_extra_details_of_service;
--
-- Fix for bug 3738058 ends here.
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_grade_ladder >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Fix for bug 3972548 starts here.
--
--
-- Procedure to check the existance of the grade ladders on new start date.
--
PROCEDURE check_grade_ladder(p_person_id in number
                            ,p_old_start_date in date
                            ,p_new_start_date in date) IS
  --
  l_dummy varchar2(1);
  l_proc  varchar2(72):='hr_change_start_date_api.check_grade_ladder';
  --
  CURSOR csr_asg_records IS
  SELECT GRADE_LADDER_PGM_ID
  FROM   per_all_assignments_f
  WHERE  person_id = p_person_id
  AND    GRADE_LADDER_PGM_ID is not null
  AND    effective_start_date = p_old_start_date;
  --
  CURSOR csr_is_pgm_valid(p_pgm_id number) IS
  SELECT NULL
  FROM   ben_pgm_f pgm
  WHERE  pgm.pgm_id = p_pgm_id
  AND    p_new_start_date between pgm.effective_start_date
         and pgm.effective_end_date;
  --
BEGIN
  --
  -- Check if the affected assignments have any Grade ladder.
  --
  hr_utility.set_location('Entering :'||l_proc, 10);
  --
  FOR asg_rec in csr_asg_records LOOP
    --
    -- Check the grade ladder is valid after the start date is moved.
    --
    hr_utility.set_location('Entering :'||l_proc, 20);
    --
    open csr_is_pgm_valid(asg_rec.GRADE_LADDER_PGM_ID);
    fetch csr_is_pgm_valid into l_dummy;
    IF csr_is_pgm_valid%NOTFOUND THEN
      --
      -- The grade ladder is invalid on the new start date.
      --
      close csr_is_pgm_valid;
      --
      hr_utility.set_message (800,'HR_449567_USD_INVALID_PGM');
      hr_utility.raise_error;
      --
    END IF;
    --
    hr_utility.set_location('Entering :'||l_proc, 30);
    --
    close csr_is_pgm_valid;
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
  --
END check_grade_ladder;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_trigger_hook >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure call_trigger_hook( p_person_id     in number,
                             p_old_start_date in date,
                             p_new_start_date in date
                           )
is
--
cursor get_asg(p_per         in number,
               p_new_st_date in date)
is
select assignment_id, business_group_id
  from per_all_assignments_f
 where person_id = p_per
   and effective_start_date = p_new_st_date;
--
 dt_mode varchar2(30);
--
begin
--
  /* only call this procedure if the start date is earlier */
  if (p_old_start_date > p_new_start_date) then
     dt_mode := 'START_EARLIER';
  else
     dt_mode := 'START_LATER';
  end if;
--
  for asgrec in get_asg(p_person_id, p_new_start_date) loop
--
    PAY_POG_ALL_ASSIGNMENTS_PKG.AFTER_UPDATE
    (
        p_effective_date                         => p_new_start_date
       ,p_datetrack_mode                         => dt_mode
       ,p_validation_start_date                  => null
       ,p_validation_end_date                    => null
       ,P_APPLICANT_RANK                         => null
       ,P_APPLICATION_ID                         => null
       ,P_ASSIGNMENT_CATEGORY                    => null
       ,P_ASSIGNMENT_ID                          => asgrec.assignment_id
       ,P_ASSIGNMENT_NUMBER                      => null
       ,P_ASSIGNMENT_STATUS_TYPE_ID              => null
       ,P_ASSIGNMENT_TYPE                        => null
       ,P_ASS_ATTRIBUTE1                         => null
       ,P_ASS_ATTRIBUTE10                        => null
       ,P_ASS_ATTRIBUTE11                        => null
       ,P_ASS_ATTRIBUTE12                        => null
       ,P_ASS_ATTRIBUTE13                        => null
       ,P_ASS_ATTRIBUTE14                        => null
       ,P_ASS_ATTRIBUTE15                        => null
       ,P_ASS_ATTRIBUTE16                        => null
       ,P_ASS_ATTRIBUTE17                        => null
       ,P_ASS_ATTRIBUTE18                        => null
       ,P_ASS_ATTRIBUTE19                        => null
       ,P_ASS_ATTRIBUTE2                         => null
       ,P_ASS_ATTRIBUTE20                        => null
       ,P_ASS_ATTRIBUTE21                        => null
       ,P_ASS_ATTRIBUTE22                        => null
       ,P_ASS_ATTRIBUTE23                        => null
       ,P_ASS_ATTRIBUTE24                        => null
       ,P_ASS_ATTRIBUTE25                        => null
       ,P_ASS_ATTRIBUTE26                        => null
       ,P_ASS_ATTRIBUTE27                        => null
       ,P_ASS_ATTRIBUTE28                        => null
       ,P_ASS_ATTRIBUTE29                        => null
       ,P_ASS_ATTRIBUTE3                         => null
       ,P_ASS_ATTRIBUTE30                        => null
       ,P_ASS_ATTRIBUTE4                         => null
       ,P_ASS_ATTRIBUTE5                         => null
       ,P_ASS_ATTRIBUTE6                         => null
       ,P_ASS_ATTRIBUTE7                         => null
       ,P_ASS_ATTRIBUTE8                         => null
       ,P_ASS_ATTRIBUTE9                         => null
       ,P_ASS_ATTRIBUTE_CATEGORY                 => null
       ,P_BARGAINING_UNIT_CODE                   => null
       ,P_CAGR_GRADE_DEF_ID                      => null
       ,P_CAGR_ID_FLEX_NUM                       => null
       ,P_CHANGE_REASON                          => null
       ,P_COLLECTIVE_AGREEMENT_ID                => null
       ,P_COMMENTS                               => null
       ,P_COMMENT_ID                             => null
       ,P_CONTRACT_ID                            => null
       ,P_DATE_PROBATION_END                     => null
       ,P_DEFAULT_CODE_COMB_ID                   => null
       ,P_EFFECTIVE_END_DATE                     => null
       ,P_EFFECTIVE_START_DATE                   => p_new_start_date
       ,P_EMPLOYEE_CATEGORY                      => null
       ,P_EMPLOYMENT_CATEGORY                    => null
       ,P_ESTABLISHMENT_ID                       => null
       ,P_FREQUENCY                              => null
       ,P_GRADE_ID                               => null
       ,P_HOURLY_SALARIED_CODE                   => null
       ,P_HOURLY_SALARIED_WARNING                => null
       ,P_INTERNAL_ADDRESS_LINE                  => null
       ,P_JOB_ID                                 => null
       ,P_JOB_POST_SOURCE_NAME                   => null
       ,P_LABOUR_UNION_MEMBER_FLAG               => null
       ,P_LOCATION_ID                            => null
       ,P_MANAGER_FLAG                           => null
       ,P_NORMAL_HOURS                           => null
       ,P_NOTICE_PERIOD                          => null
       ,P_NOTICE_PERIOD_UOM                      => null
       ,P_NO_MANAGERS_WARNING                    => null
       ,P_OBJECT_VERSION_NUMBER                  => null
       ,P_ORGANIZATION_ID                        => null
       ,P_ORG_NOW_NO_MANAGER_WARNING             => null
       ,P_OTHER_MANAGER_WARNING                  => null
       ,P_PAYROLL_ID                             => null
       ,P_PAYROLL_ID_UPDATED                     => null
       ,P_PAY_BASIS_ID                           => null
       ,P_PEOPLE_GROUP_ID                        => null
       ,P_PERF_REVIEW_PERIOD                     => null
       ,P_PERF_REVIEW_PERIOD_FREQUEN             => null
       ,P_PERIOD_OF_SERVICE_ID                  => null
       ,P_PERSON_REFERRED_BY_ID                 => null
       ,P_PLACEMENT_DATE_START                   => null
       ,P_POSITION_ID                            => null
       ,P_POSTING_CONTENT_ID                     => null
       ,P_PRIMARY_FLAG                          => null
       ,P_PROBATION_PERIOD                      => null
       ,P_PROBATION_UNIT                        => null
       ,P_PROGRAM_APPLICATION_ID                => null
       ,P_PROGRAM_ID                            => null
       ,P_PROGRAM_UPDATE_DATE                   => null
       ,P_PROJECT_TITLE                         => null
       ,P_RECRUITER_ID                          => null
       ,P_RECRUITMENT_ACTIVITY_ID               => null
       ,P_REQUEST_ID                            => null
       ,P_SAL_REVIEW_PERIOD                     => null
       ,P_SAL_REVIEW_PERIOD_FREQUEN             => null
       ,P_SET_OF_BOOKS_ID                       => null
       ,P_SOFT_CODING_KEYFLEX_ID                => null
       ,P_SOURCE_ORGANIZATION_ID                => null
       ,P_SOURCE_TYPE                           => null
       ,P_SPECIAL_CEILING_STEP_ID               => null
       ,P_SUPERVISOR_ID                         => null
       ,P_TIME_NORMAL_FINISH                    => null
       ,P_TIME_NORMAL_START                     => null
       ,P_TITLE                                 => null
       ,P_VACANCY_ID                            => null
       ,P_VENDOR_ASSIGNMENT_NUMBER              => null
       ,P_VENDOR_EMPLOYEE_NUMBER                => null
       ,P_VENDOR_ID                             => null
       ,P_WORK_AT_HOME                          => null
       ,P_GRADE_LADDER_PGM_ID                   => null
       ,P_SUPERVISOR_ASSIGNMENT_ID              => null
       ,P_VENDOR_SITE_ID                        => null
       ,P_PO_HEADER_ID                          => null
       ,P_PO_LINE_ID                            => null
       ,P_PROJECTED_ASSIGNMENT_END              => null
       ,P_APPLICANT_RANK_O                      => null
       ,P_APPLICATION_ID_O                      => null
       ,P_ASSIGNMENT_CATEGORY_O                 => null
       ,P_ASSIGNMENT_NUMBER_O                   => null
       ,P_ASSIGNMENT_SEQUENCE_O                 => null
       ,P_ASSIGNMENT_STATUS_TYPE_ID_O           => null
       ,P_ASSIGNMENT_TYPE_O                     => null
       ,P_ASS_ATTRIBUTE1_O                      => null
       ,P_ASS_ATTRIBUTE10_O                     => null
       ,P_ASS_ATTRIBUTE11_O                     => null
       ,P_ASS_ATTRIBUTE12_O                     => null
       ,P_ASS_ATTRIBUTE13_O                     => null
       ,P_ASS_ATTRIBUTE14_O                    => null
       ,P_ASS_ATTRIBUTE15_O                    => null
       ,P_ASS_ATTRIBUTE16_O                    => null
       ,P_ASS_ATTRIBUTE17_O                    => null
       ,P_ASS_ATTRIBUTE18_O                    => null
       ,P_ASS_ATTRIBUTE19_O                    => null
       ,P_ASS_ATTRIBUTE2_O                     => null
       ,P_ASS_ATTRIBUTE20_O                    => null
       ,P_ASS_ATTRIBUTE21_O                    => null
       ,P_ASS_ATTRIBUTE22_O                    => null
       ,P_ASS_ATTRIBUTE23_O                    => null
       ,P_ASS_ATTRIBUTE24_O                    => null
       ,P_ASS_ATTRIBUTE25_O                    => null
       ,P_ASS_ATTRIBUTE26_O                    => null
       ,P_ASS_ATTRIBUTE27_O                    => null
       ,P_ASS_ATTRIBUTE28_O                    => null
       ,P_ASS_ATTRIBUTE29_O                    => null
       ,P_ASS_ATTRIBUTE3_O                     => null
       ,P_ASS_ATTRIBUTE30_O                    => null
       ,P_ASS_ATTRIBUTE4_O                     => null
       ,P_ASS_ATTRIBUTE5_O                     => null
       ,P_ASS_ATTRIBUTE6_O                     => null
       ,P_ASS_ATTRIBUTE7_O                     => null
       ,P_ASS_ATTRIBUTE8_O                     => null
       ,P_ASS_ATTRIBUTE9_O                     => null
       ,P_ASS_ATTRIBUTE_CATEGORY_O             => null
       ,P_BARGAINING_UNIT_CODE_O               => null
       ,P_BUSINESS_GROUP_ID_O                  => asgrec.business_group_id
       ,P_CAGR_GRADE_DEF_ID_O                  => null
       ,P_CAGR_ID_FLEX_NUM_O                   => null
       ,P_CHANGE_REASON_O                      => null
       ,P_COLLECTIVE_AGREEMENT_ID_O            => null
       ,P_COMMENT_ID_O                         => null
       ,P_CONTRACT_ID_O                        => null
       ,P_DATE_PROBATION_END_O                 => null
       ,P_DEFAULT_CODE_COMB_ID_O               => null
       ,P_EFFECTIVE_END_DATE_O                 => null
       ,P_EFFECTIVE_START_DATE_O               => p_old_start_date
       ,P_EMPLOYEE_CATEGORY_O                  => null
       ,P_EMPLOYMENT_CATEGORY_O                => null
       ,P_ESTABLISHMENT_ID_O                   => null
       ,P_FREQUENCY_O                          => null
       ,P_GRADE_ID_O                           => null
       ,P_HOURLY_SALARIED_CODE_O               => null
       ,P_INTERNAL_ADDRESS_LINE_O              => null
       ,P_JOB_ID_O                             => null
       ,P_JOB_POST_SOURCE_NAME_O               => null
       ,P_LABOUR_UNION_MEMBER_FLAG_O           => null
       ,P_LOCATION_ID_O                        => null
       ,P_MANAGER_FLAG_O                       => null
       ,P_NORMAL_HOURS_O                       => null
       ,P_NOTICE_PERIOD_O                      => null
       ,P_NOTICE_PERIOD_UOM_O                  => null
       ,P_OBJECT_VERSION_NUMBER_O              => null
       ,P_ORGANIZATION_ID_O                    => null
       ,P_PAYROLL_ID_O                         => null
       ,P_PAY_BASIS_ID_O                       => null
       ,P_PEOPLE_GROUP_ID_O                    => null
       ,P_PERF_REVIEW_PERIOD_O                 => null
       ,P_PERF_REVIEW_PERIOD_FREQUEN_O         => null
       ,P_PERIOD_OF_SERVICE_ID_O               => null
       ,P_PERSON_ID_O                          => p_person_id
       ,P_PERSON_REFERRED_BY_ID_O              => null
       ,P_PLACEMENT_DATE_START_O               => null
       ,P_POSITION_ID_O                        => null
       ,P_POSTING_CONTENT_ID_O                 => null
       ,P_PRIMARY_FLAG_O                       => null
       ,P_PROBATION_PERIOD_O                   => null
       ,P_PROBATION_UNIT_O                     => null
       ,P_PROGRAM_APPLICATION_ID_O             => null
       ,P_PROGRAM_ID_O                         => null
       ,P_PROGRAM_UPDATE_DATE_O                => null
       ,P_PROJECT_TITLE_O                      => null
       ,P_RECRUITER_ID_O                       => null
       ,P_RECRUITMENT_ACTIVITY_ID_O            => null
       ,P_REQUEST_ID_O                         => null
       ,P_SAL_REVIEW_PERIOD_O                    => null
       ,P_SAL_REVIEW_PERIOD_FREQUEN_O            => null
       ,P_SET_OF_BOOKS_ID_O                      => null
       ,P_SOFT_CODING_KEYFLEX_ID_O               => null
       ,P_SOURCE_ORGANIZATION_ID_O               => null
       ,P_SOURCE_TYPE_O                          => null
       ,P_SPECIAL_CEILING_STEP_ID_O              => null
       ,P_SUPERVISOR_ID_O                        => null
       ,P_TIME_NORMAL_FINISH_O                   => null
       ,P_TIME_NORMAL_START_O                    => null
       ,P_TITLE_O                                => null
       ,P_VACANCY_ID_O                           => null
       ,P_VENDOR_ASSIGNMENT_NUMBER_O             => null
       ,P_VENDOR_EMPLOYEE_NUMBER_O               => null
       ,P_VENDOR_ID_O                            => null
       ,P_WORK_AT_HOME_O                         => null
       ,P_GRADE_LADDER_PGM_ID_O                  => null
       ,P_SUPERVISOR_ASSIGNMENT_ID_O             => null
       ,P_VENDOR_SITE_ID_O                       => null
       ,P_PO_HEADER_ID_O                         => null
       ,P_PO_LINE_ID_O                           => null
       ,P_PROJECTED_ASSIGNMENT_END_O             => null
      );
   end loop;
--
end call_trigger_hook;
--
-- Fix for bug 3972548 ends here.
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_start_date >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_start_date
  (p_validate                      in     boolean
  ,p_person_id                     in     number
  ,p_old_start_date                in     date
  ,p_new_start_date                in     date
  ,p_update_type                   in     varchar2
  ,p_applicant_number              in     varchar2
  ,p_warn_ee                       out nocopy    varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
cursor csr_pds
is
select period_of_service_id
from per_periods_of_service
where person_id = p_person_id
and date_start = p_old_start_date;
--
cursor csr_pdp
is
select period_of_placement_id
from per_periods_of_placement
where person_id = p_person_id
and date_start = p_old_start_date;
--
-- 115.30,115.33 (START)
--
CURSOR csr_legislation
  (p_person_id      IN per_all_people_f.person_id%TYPE
  ,p_effective_date IN DATE
  ) IS
  SELECT bus.legislation_code
  FROM   per_people_f per
        ,per_business_groups bus
  WHERE  per.person_id = csr_legislation.p_person_id
  AND    per.business_group_id+0 = bus.business_group_id
  AND    csr_legislation.p_effective_date BETWEEN per.effective_start_date
                                          AND per.effective_end_date;
--
l_legislation_code per_business_groups.legislation_code%TYPE;
l_hd_rule_value     pay_legislation_rules.rule_mode%TYPE;
l_hd_rule_found     BOOLEAN;
l_fpd_rule_value    pay_legislation_rules.rule_mode%TYPE;
l_fpd_rule_found    BOOLEAN;
--
-- 115.30,115.33 (END)
--
l_proc      varchar2(30):='update_start_date';
l_pds_or_pdp_id     per_periods_of_placement.period_of_placement_id%TYPE;
l_old_start_date DATE;
l_new_start_date DATE;
l_earlier_date DATE;
l_later_date DATE;
l_system_person_type per_person_types.system_person_type%TYPE;
l_warn_ee varchar2(1) := 'N';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'person_id'
    ,p_argument_value   => p_person_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'old_start_date'
    ,p_argument_value   => p_old_start_date );
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'new_start_date'
    ,p_argument_value   => p_new_start_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'update_type'
    ,p_argument_value   => p_update_type);
  --
  -- Issue a savepoint
  --
  savepoint update_start_date;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_old_start_date := trunc(p_old_start_date);
  l_new_start_date := trunc(p_new_start_date);
  --
  -- Initialise local variables
  --
  if p_update_type = 'E' then
    open csr_pds;
    fetch csr_pds into l_pds_or_pdp_id;
    close csr_pds;
    l_system_person_type := 'EMP';
  elsif p_update_type = 'C' then
    open csr_pdp;
    fetch csr_pdp into l_pds_or_pdp_id;
    close csr_pdp;
    l_system_person_type := 'CWK';
  else
     hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','update_start_date');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_change_start_date_bk1.update_start_date_b
        (p_person_id          => p_person_id
        ,p_old_start_date     => l_old_start_date
        ,p_new_start_date     => l_new_start_date
        ,p_update_type        => p_update_type
        ,p_applicant_number   => p_applicant_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_start_date'
        ,p_hook_type   => 'BP'
        );
  end;
--
-- 115.30,115.33 (START)
--
  --
  -- Get Legislation
  --
  OPEN csr_legislation(p_person_id
                      ,p_old_start_date
                      );
  FETCH csr_legislation INTO l_legislation_code;
  CLOSE csr_legislation;
  --
  -- Check if amend hire date beyond PAY actions is allowed
  --
  pay_core_utils.get_legislation_rule('AMEND_HIRE_WITH_PAYACT'
                                     ,l_legislation_code
                                     ,l_hd_rule_value
                                     ,l_hd_rule_found
                                     );
  --
  -- Check if rehire before FPD is allowed
  --
  pay_core_utils.get_legislation_rule('REHIRE_BEFORE_FPD'
                                     ,l_legislation_code
                                     ,l_fpd_rule_value
                                     ,l_fpd_rule_found
                                     );
--
-- 115.30,115.33 (END)
--
  --
  -- Validation in addition to Row Handlers
  --
IF l_old_start_date = l_new_start_date then
    --
    NULL;                -- do nothing as hire dates have not actually changed.
    hr_utility.set_location(l_proc, 25);
    --
ELSE
--
  check_not_supervisor(p_person_id       => p_person_id
                      ,p_new_start_date  => l_new_start_date
                      ,p_old_start_date  => l_old_start_date
                      );
  hr_utility.set_location(l_proc, 30);
  --
  check_pds_pdp(p_person_id       => p_person_id
               ,p_new_start_date  => l_new_start_date
               ,p_old_start_date  => l_old_start_date
               ,p_type            => p_update_type
               );
  hr_utility.set_location(l_proc, 40);
  --
  check_un_ended_pds_pdp(p_person_id       => p_person_id
               ,p_new_start_date  => l_new_start_date
--
-- 115.30 (START)
--
               ,p_old_start_date  => l_old_start_date
               ,p_hd_rule_found   => l_hd_rule_found
               ,p_hd_rule_value   => l_hd_rule_value
               ,p_fpd_rule_found  => l_fpd_rule_found
               ,p_fpd_rule_value  => l_fpd_rule_value
--
-- 115.30 (END)
--
               ,p_type            => p_update_type
               );
  hr_utility.set_location(l_proc, 45);
  check_contig_pds_pdp(p_person_id => p_person_id
                      ,p_old_start_date => l_old_start_date
                      ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 50);
  --
  check_supe_pay(p_pds_or_pdp_id => l_pds_or_pdp_id
                ,p_new_start_date => l_new_start_date
                ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 60);
  --
  -- Fix for bug 3972548 starts here.
  --
  check_grade_ladder(p_person_id
                    ,l_old_start_date
  		    ,l_new_start_date);
  --
  hr_utility.set_location(l_proc, 65);
  --
  -- Fix for bug 3972548 ends here.
  --
  if l_new_start_date > l_old_start_date then
      l_earlier_date := l_old_start_date;
      l_later_date := l_new_start_date;
      --
--
-- 115.30 (START)
--
      --
      -- Check if amend hire date with PAY actions is enabled
      --
      if ( p_update_type = 'C'
           OR
           ( p_update_type = 'E'
             AND
             ( nvl(fnd_profile.value('HR_MV_HIRE_SKIP_ACT_VALIDATION'),'N') = 'N'
               OR
               NOT l_hd_rule_found
               OR
               (l_hd_rule_found AND nvl(l_hd_rule_value,'N') = 'N')
             )
           )
         ) THEN
        --
        -- Disallow change hire date beyond PAY actions.
        -- Retaining validation
        --
--
-- 115.30 (END)
--
      check_for_compl_actions(p_person_id  => p_person_id
                             ,p_old_start_date => l_old_start_date
                             ,p_new_start_date => l_new_start_date
                             ,p_type => p_update_type);
      hr_utility.set_location(l_proc, 70);
--
-- 115.30 (START)
--
      else
        --
        -- The hire date is allowed to change beyond PAY actions.
        -- Invoke other team routines to handle this via new hook.
        --
        per_pds_utils.check_move_hire_date(p_person_id  => p_person_id
                                          ,p_old_start_date => l_old_start_date
                                          ,p_new_start_date => l_new_start_date
                                          ,p_type => p_update_type);
        --
        hr_utility.set_location(l_proc, 75);
      end if;
--
-- 115.30 (END)
--
      --
      check_sp_placements(p_person_id => p_person_id
                         ,p_pds_or_pdp_id => l_pds_or_pdp_id
                         ,p_new_start_date => l_new_start_date
                         ,p_type => p_update_type);
      hr_utility.set_location(l_proc, 80);
      --
      check_asg_rates(p_person_id => p_person_id
                     ,p_pds_or_pdp_id => l_pds_or_pdp_id
                     ,p_new_start_date => l_new_start_date
                     ,p_type => p_update_type);
      hr_utility.set_location(l_proc, 85);
      --
      check_cost_allocation(p_person_id => p_person_id
                           ,p_pds_or_pdp_id => l_pds_or_pdp_id
                           ,p_new_start_date => l_new_start_date
                           ,p_type => p_update_type);
      hr_utility.set_location(l_proc, 90);
      --
      check_budget_values(p_person_id => p_person_id
                         ,p_pds_or_pdp_id => l_pds_or_pdp_id
                         ,p_new_start_date => l_new_start_date
                         ,p_type => p_update_type);
      hr_utility.set_location(l_proc, 95);
      --
      check_people_changes(p_person_id => p_person_id
                          ,p_earlier_date => l_earlier_date
                          ,p_later_date => l_later_date
                          ,p_old_start_date => l_old_start_date);
      hr_utility.set_location(l_proc, 100);
      --
      check_asg_st_change(p_person_id => p_person_id
                         ,p_earlier_date => l_earlier_date
                         ,p_later_date => l_later_date
                         ,p_type => p_update_type
                         ,p_old_start_date => l_old_start_date);
      hr_utility.set_location(l_proc, 110);
      --
      check_asg_change(p_person_id => p_person_id
                     ,p_earlier_date => l_earlier_date
                     ,p_later_date => l_later_date
                     ,p_old_start_date => l_old_start_date);
      --
      -- Bug 3006094. Check if there are any person type changes
      -- between old and new hire dates.
      --
      check_user_person_type_changes(p_person_id => p_person_id
                          ,p_earlier_date => l_earlier_date
                          ,p_later_date => l_later_date
                          ,p_old_start_date => l_old_start_date);
      hr_utility.set_location(l_proc, 115);
      --
      -- Fix for bug 3738058 starts here.
      --
      check_extra_details_of_service(p_person_id => p_person_id
                                    ,p_old_start_date => l_old_start_date
			                ,p_new_start_date => l_new_start_date);
      --
      hr_utility.set_location(l_proc, 117);
      --
      -- Fix for bug 3738058 ends here.
      --
  else
      l_later_date := l_old_start_date;
      l_earlier_date := l_new_start_date;
      --
      check_people_changes(p_person_id => p_person_id
                          ,p_earlier_date => l_earlier_date
                          ,p_later_date => l_later_date
                          ,p_old_start_date => l_old_start_date);
      hr_utility.set_location(l_proc, 120);
      --
      check_asg_change(p_person_id => p_person_id
                      ,p_earlier_date => l_earlier_date
                      ,p_later_date => l_later_date
                      ,p_old_start_date => l_old_start_date);
      hr_utility.set_location(l_proc, 130);
      --
      check_prev_asg(p_person_id => p_person_id
                    ,p_type => p_update_type
                    ,p_old_start_date => l_old_start_date
                    ,p_new_start_date => l_new_start_date);
      hr_utility.set_location(l_proc, 140);
      --
  end if;
  --
  check_recur_ee(p_person_id => p_person_id
                ,p_new_start_date => l_new_start_date
                ,p_old_start_date => l_old_start_date
                ,p_warn_raise => l_warn_ee);
  hr_utility.set_location(l_proc, 150);
  --
  --changes start for bug 6640794

  check_ben_enteries(p_person_id => p_person_id
                    ,p_new_start_date => l_new_start_date  --Changes done for Bug 7481343
                    ,p_old_start_date => l_old_start_date); --changed for bug 8836797

  --changes end for bug 6640794

  -- Process Logic: now we must update the relevant records in line with the new start date
  --
  -- Fix for bug 3390731 starts here. update the start_date with min(effective_start_date).
  --
  update per_people_f p
  set p.effective_start_date = decode(p.effective_start_date
                              ,l_old_start_date,l_new_start_date,p.effective_start_date)
     ,p.effective_end_date = decode(p.effective_end_date
                              ,l_old_start_date-1,l_new_start_date-1,p.effective_end_date)
     ,p.original_date_of_hire = decode(p.original_date_of_hire
                                 ,l_old_start_date, l_new_start_date,p.original_date_of_hire)
  where p.person_id = p_person_id;
  if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
      hr_utility.set_message_token('TABLE','PER_ALL_PEOPLE_F');
      hr_utility.raise_error;
  end if;
  --
  update per_people_f p
  set p.start_date = (select min(ppf.effective_start_date)
                      from   per_people_f ppf
           where ppf.person_id = p_person_id)
  where p.person_id = p_person_id;
  --
  -- Fix for bug 3390731 ends here.
  --
  update_period(p_person_id => p_person_id
               ,p_old_start_date => l_old_start_date
               ,p_new_start_date => l_new_start_date
               ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 160);
  --
  -- Update the addresses that start at the old hire date
  -- Providing that addresses end date either equal to new start date or greater than it.
  --
  update per_addresses a
  set    a.date_from = l_new_start_date
  where  a.date_from = l_old_start_date
  and    nvl(a.date_to,l_new_start_date) >= l_new_start_date
  and    a.person_id = p_person_id;
  --
  hr_utility.set_location(l_proc, 170);
  --
  update pay_personal_payment_methods_f p
  set    p.effective_start_date = l_new_start_date
  where  p.effective_start_date = l_old_start_date
  and    p.effective_end_date >= l_new_start_date
  and    exists
    (select 1
    from per_assignments_f a
    where p.assignment_id = a.assignment_id
    and   a.assignment_type = p_update_type
    and   a.person_id = p_person_id);
  --
  hr_utility.set_location(l_proc, 180);
  --
  update_spinal_placement(p_person_id  => p_person_id
                         ,p_old_start_date => l_old_start_date
                         ,p_new_start_date => l_new_start_date
                         ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 190);
  --
  update_asg_rate(p_person_id => p_person_id
                 ,p_old_start_date => l_old_start_date
                 ,p_new_start_date => l_new_start_date
                 ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 190);
  --
  update_cost_allocation(p_person_id => p_person_id
                        ,p_old_start_date => l_old_start_date
                        ,p_new_start_date => l_new_start_date
                        ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 200);
  --
  update_asg_budget(p_person_id => p_person_id
                   ,p_old_start_date => l_old_start_date
                   ,p_new_start_date => l_new_start_date
                   ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 210);
  --
  --first update ALL matching cases of the period_of_placement_date_start for integrity
  --
  if p_update_type='C' then
    update per_assignments_f a
    set    a.period_of_placement_date_start = l_new_start_date
    where  a.period_of_placement_date_start = l_old_start_date
    and    a.assignment_type      = p_update_type
    and    a.person_id            = p_person_id;
    if sql%rowcount <1 then
       hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
       hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
       hr_utility.raise_error;
    end if;
  end if;
  --
  update per_assignments_f a
  set    a.effective_start_date = l_new_start_date
  where  a.effective_start_date = l_old_start_date
  and    a.assignment_type      = p_update_type
  and    a.person_id            = p_person_id;
  if sql%rowcount <1 then
     hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
     hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
     hr_utility.raise_error;
  end if;
--
-- 115.32 115.34 (START)
--
-- Update the EED for ASG records immediately before the updated ESD
--
  UPDATE per_assignments_f A
     SET A.effective_end_date = (l_new_start_date - 1)
   WHERE A.effective_end_date = (l_old_start_date - 1)
     AND (l_new_start_date - 1) >= A.effective_start_date
     AND A.assignment_type    = p_update_type
     AND A.person_id          = p_person_id;
--
-- 115.32 115.34 (END)
--
  call_trigger_hook(p_person_id => p_person_id,
                    p_old_start_date => l_old_start_date,
                    p_new_start_date => l_new_start_date
                   );
--
  --
  -- Bug 2614732 starts here.
  --
  update_probation_end( p_person_id, l_new_start_date);
  --
  -- Bug 2614732 ends here.
  --
  hr_utility.set_location(l_proc, 220);
  --
  -- Fix for bug 3738058 starts here.
  --
  update pqp_assignment_attributes_f paa
  set    paa.effective_start_date   = l_new_start_date
  where  paa.effective_start_date = l_old_start_date
  and    paa.assignment_id in
          (select paf.assignment_id
           from   per_assignments_f paf
           where  paf.effective_start_date = l_new_start_date
           and    paf.person_id = p_person_id);
  --
  -- Fix for bug 3738058 ends here.
  --
  hr_contract_api.maintain_contracts
                 (p_person_id => p_person_id
                 ,p_new_start_date => l_new_start_date
                 ,p_old_start_date => l_old_start_date);
  hr_utility.set_location(l_proc, 230);
  --
  update_tax(p_person_id => p_person_id
            ,p_new_start_date => l_new_start_date);
  hr_utility.set_location(l_proc, 240);
  --
  if p_applicant_number is not null then
     update_apl_asg(p_person_id => p_person_id
                   ,p_old_start_date => l_old_start_date
                   ,p_new_start_date => l_new_start_date);
     hr_utility.set_location(l_proc, 250);
     --
     update_apl(p_person_id => p_person_id
               ,p_old_start_date => l_old_start_date
               ,p_new_start_date => l_new_start_date);
     hr_utility.set_location(l_proc, 260);
     --
  end if;
  --
  hr_utility.set_location(l_proc, 270);
  --
  hr_per_type_usage_internal.change_hire_date_ptu
         (p_date_start           => l_new_start_date
         ,p_old_date_start       => l_old_start_date
         ,p_person_id            => p_person_id
         ,p_system_person_type   => l_system_person_type
         );
  hr_utility.set_location(l_proc, 280);
  --
  update_pay_proposal(p_person_id => p_person_id
                     ,p_old_start_date => l_old_start_date
                     ,p_new_start_date => l_new_start_date
                     ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 290);

  -- Start changes for bug 8836797
  update_ben_GSP_enteries(p_person_id => p_person_id
                          ,p_new_start_date => l_new_start_date
                          ,p_old_start_date => l_old_start_date
                          ,p_effective_date => l_new_start_date);
  -- End changes for bug 8836797
  --
  if p_update_type = 'E' then
--
-- 115.30 (START)
--
    if ( nvl(fnd_profile.value('HR_MV_HIRE_SKIP_ACT_VALIDATION'),'N') = 'N'
         OR
         NOT l_hd_rule_found
         OR
         (l_hd_rule_found AND nvl(l_hd_rule_value,'N') = 'N')
       )
    then
      --
      -- Change Hire Date past PAY actions not allowed
      --
--
-- 115.30 (END)
--
    run_alu_ee(p_person_id => p_person_id
              ,p_old_start_date => l_old_start_date
              ,p_new_start_date => l_new_start_date
              ,p_type => p_update_type);
  hr_utility.set_location(l_proc, 300);
--
-- 115.30 (START)
--
    else
      --
      -- Change Hire Date past PAY actions allowed
      -- Invoke equivalent new routine from PAY team.
      --
      per_pds_utils.hr_run_alu_ee(p_person_id => p_person_id
                                 ,p_old_start_date => l_old_start_date
                                 ,p_new_start_date => l_new_start_date
                                 ,p_type => p_update_type);
      --
      hr_utility.set_location(l_proc, 305);
    end if;
--
-- 115.30 (END)
--
  --
    if l_new_start_date < l_old_start_date then
      per_people12_pkg.maintain_coverage
                      (p_person_id => p_person_id
                      ,p_type => 'EMP'
                      );
      hr_utility.set_location(l_proc, 310);
    end if;
  end if;
--
END IF;     -- end of check that old and new start dates are actually different
  --
  -- Call After Process User Hook
  --
  begin
    hr_change_start_date_bk1.update_start_date_a
        (p_person_id          => p_person_id
        ,p_old_start_date     => l_old_start_date
        ,p_new_start_date     => l_new_start_date
        ,p_update_type        => p_update_type
        ,p_applicant_number   => p_applicant_number
             ,p_warn_ee            => l_warn_ee
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_start_date'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 310);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_warn_ee := l_warn_ee;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 500);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_start_date;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_warn_ee := 'N';
    hr_utility.set_location(' Leaving:'||l_proc, 600);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_start_date;
    --
    -- set in out parameters and set out parameters
    --
    p_warn_ee := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 700);
    raise;
end update_start_date;
--
end hr_change_start_date_api;

/
