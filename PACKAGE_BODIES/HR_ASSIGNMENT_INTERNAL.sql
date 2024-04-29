--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_INTERNAL" as
/* $Header: peasgbsi.pkb 120.27.12010000.5 2009/03/20 07:19:41 varanjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_assignment_internal.';
--
-- Start of 3335915
g_debug boolean := hr_utility.debug_enabled;
-- End of 3335915
-- ----------------------------------------------------------------------------
-- |---------------------< get_max_asg_fut_change_end_dt >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the maximum end date of any future assignment
--   changes that exist after the effective date.
--
-- Prerequisites:
--   It is already known that the assignment exists as of the effective date.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                 Yes number
--   p_effective_date                Yes date
--
--
-- Post Success:
--
--   The latest end date of a future assignment change is returned if one is
--   found. The process will return null if no future changes exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_max_asg_fut_change_end_dt
  (p_assignment_id  in     number
  ,p_effective_date in     date
  ) return date is
  --
  -- Declare cursors and local variables
  --
  l_max_asg_end_date  per_assignments_f.effective_end_date%TYPE;
  l_proc              varchar2(72)
                        := g_package || 'get_max_asg_fut_change_end_dt';
  --
  cursor csr_get_max_asg_end_date is
  select max(asg.effective_end_date)
  from   per_assignments_f asg
  where  asg.assignment_id        = p_assignment_id
  and    asg.effective_start_date > p_effective_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- This function returns the maximum effective end date of any changes to
  -- the specified assignment which start after the specified effective date.
  -- If no future changes are found, then a NULL is returned.
  --
  open  csr_get_max_asg_end_date;
  fetch csr_get_max_asg_end_date
   into l_max_asg_end_date;
  close csr_get_max_asg_end_date;
  --
  hr_utility.set_location(l_proc, 10);
  --
  return l_max_asg_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
end get_max_asg_fut_change_end_dt;
--
-- ----------------------------------------------------------------------------
-- |------------------------< actual_term_cwk_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_term_cwk_asg
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  --
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_correction                 boolean;
  l_datetrack_mode             varchar2(30);
  l_entries_changed            varchar2(1);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_asg_end_date           per_assignments_f.effective_end_date%TYPE;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  l_pay_proposal_warning       boolean := FALSE; -- Bug 3202260
  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_payroll_id_updated         boolean;
  l_update                     boolean;
  l_update_change_insert       boolean;
  l_update_override            boolean;
  l_future_records_flag        boolean;
  l_cor_validation_start_date  date;
  l_cor_validation_end_date    date;
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_esd_not_required           date;
  l_eed_not_required           date;
  l_proc                       varchar2(72) :=
                                       g_package || 'actual_term_cwk_asg';
  --
  cursor csr_get_legislation_code is
  select bus.legislation_code
  from   per_business_groups bus
  where  bus.business_group_id = l_business_group_id;
  --
  cursor csr_asg_values (l_effective_date date) is
  select asg.object_version_number
       , asg.effective_start_date
       , asg.effective_end_date
    from per_assignments_f asg
   where asg.assignment_id      = p_assignment_id
     and l_effective_date between asg.effective_start_date
                              and asg.effective_end_date;
  --
  cursor csr_get_future_asg (l_effective_date date) is
  select asg.object_version_number
       , asg.effective_start_date
       , asg.effective_end_date
    from per_assignments_f asg
   where asg.assignment_id = p_assignment_id
     and asg.effective_start_date >= l_effective_date;
  --
  cursor csr_lock_alu is
  select null
  from   pay_assignment_link_usages_f alu
  where  alu.assignment_id = p_assignment_id
  for    update nowait;

  --  Fix for bug 5841180 starts here
/*  cursor csr_lock_ele is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_eev is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  for    update nowait; */
  --


  cursor csr_lock_ele(p_effective_date date) is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  and    p_effective_date between effective_start_date and effective_end_date
  for    update nowait;

  cursor csr_lock_eev(p_effective_date date) is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  and    p_effective_date between ele.effective_start_date and ele.effective_end_date
  for    update nowait;

  -- Fix for bug 5841180 ends here

  cursor csr_lock_pyp is
  select null
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_asa is
  select asa.assignment_action_id
  from   pay_assignment_actions asa
  where  asa.assignment_id = p_assignment_id
  for    update nowait;
  --
  -- Start of fix 3202260
  cursor csr_pay_proposal is
  select pyp.pay_proposal_id, pyp.object_version_number
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  and    pyp.change_date > p_actual_termination_date
  order  by pyp.change_date desc;

  --
  cursor csr_proposal_comp(l_proposal_id number) is
  select ppc.component_id, ppc.object_version_number
  from   per_pay_proposal_components ppc
  where  ppc.pay_proposal_id = l_proposal_id;
  -- End of 3202260
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Process Logic
  --
  -- Determine the datetrack mode to use for the assignment table handler
  -- update call.
  --
  per_asg_shd.find_dt_upd_modes
    (p_effective_date       => p_actual_termination_date + 1
    ,p_base_key_value       => p_assignment_id
    ,p_correction           => l_correction
    ,p_update               => l_update
    ,p_update_override      => l_update_override
    ,p_update_change_insert => l_update_change_insert
    );
  hr_utility.set_location(l_proc, 10);
  --
  if l_update_change_insert then
    --
    -- This is the case where there is a future dated assignment and
    -- we need to insert a record betwen ATD+1 and that future change
    -- with a TERM status. We need 'CORRECTION' of future records to
    -- have the right status.
    --
    l_datetrack_mode             := 'UPDATE_CHANGE_INSERT';
    l_asg_future_changes_warning := TRUE;
    l_object_version_number      := p_object_version_number;
    l_future_records_flag        := TRUE;
    hr_utility.set_location(l_proc, 20);
  elsif l_update then
    --
    l_datetrack_mode        := 'UPDATE';
    l_object_version_number := p_object_version_number;
    hr_utility.set_location(l_proc, 30);
    --
  elsif l_correction then
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- We have the OVN for the assignment record which starts on ATD+1
    -- so lock this one for termination.
    --
    l_object_version_number := p_object_version_number;
    --
    -- Lock the current row as of ATD+1, using correction mode.
    -- This validates the object version number passed in and obtains the
    -- validation_start_date and validation_end_date.
    --
    per_asg_shd.lck
      (p_effective_date        => p_actual_termination_date + 1
      ,p_datetrack_mode        => 'CORRECTION'
      ,p_assignment_id         => p_assignment_id
      ,p_object_version_number => l_object_version_number
      ,p_validation_start_date => l_cor_validation_start_date
      ,p_validation_end_date   => l_cor_validation_end_date
      );
    hr_utility.set_location(l_proc, 50);
    --
    -- Find out if there changes after, the day
    -- after the actual termination date
    --
    l_max_asg_end_date := get_max_asg_fut_change_end_dt
      (p_assignment_id  => p_assignment_id
      ,p_effective_date => p_actual_termination_date + 1
      );
    hr_utility.set_location(l_proc, 70);
    --
    if l_max_asg_end_date is not null then
      --
      l_future_records_flag := TRUE;
      hr_utility.set_location(l_proc, 80);
    end if;
    --
    hr_utility.set_location(l_proc, 110);
    --
    l_datetrack_mode             := 'CORRECTION';
    l_asg_future_changes_warning := TRUE;
    -- For correction the object_version_number has already been derived.
    hr_utility.set_location(l_proc, 120);
  else
    --
    -- No other datetrack modes are valid, and so should not occur.
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','130');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 140);
  --
  -- Update employee assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
--    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_comment_id                   => l_comment_id
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_actual_termination_date + 1
    ,p_datetrack_mode               => l_datetrack_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  hr_utility.set_location(l_proc, 150);
  --
  -- If there are future dated records then we need to process these and set the
  -- right assignment status.
  --
  if l_future_records_flag then
    --
    -- We have future dated assignment records so set them to a
    -- TERM_CWK_ASG status.
    --
    for c_asg_rec in csr_get_future_asg(p_actual_termination_date+2)
    loop
      per_asg_upd.upd
        (p_assignment_id                => p_assignment_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_business_group_id            => l_business_group_id
       -- ,p_assignment_status_type_id    => p_assignment_status_type_id /*Commented for 4377925*/
        ,p_comment_id                   => l_comment_id
        ,p_payroll_id_updated           => l_payroll_id_updated
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_no_managers_warning          => l_no_managers_warning
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_validation_start_date        => l_validation_start_date
        ,p_validation_end_date          => l_validation_end_date
        ,p_object_version_number        => c_asg_rec.object_version_number
        ,p_effective_date               => c_asg_rec.effective_start_date
        ,p_datetrack_mode               => 'CORRECTION'
        ,p_validate                     => FALSE
        ,p_hourly_salaried_warning      => l_hourly_salaried_warning
        );
    end loop;
  end if;
  --
  -- Lock the appropriate child rows for this assignment.
  --
  open  csr_lock_alu; -- Locking ladder processing order 1110
  close csr_lock_alu;
  hr_utility.set_location(l_proc, 160);
  --
  open csr_lock_asa;  -- Locking ladder processing order 1190
  close csr_lock_asa;
  hr_utility.set_location(l_proc,170);
  --

  -- fix for bug 5841180 starts here

 /*    open  csr_lock_ele; -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 180);
  --
  open  csr_lock_eev; -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 190); */
  --

  open  csr_lock_ele(p_actual_termination_date); -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 180);
  --
  open  csr_lock_eev(p_actual_termination_date); -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 190);
  --

  -- fix for bug 5841180 ends here

  open  csr_lock_pyp; -- Locking ladder processing order 1630
  close csr_lock_pyp;
  hr_utility.set_location(l_proc, 200);
  --
  -- Process any element entries and assignment_link_usages for this
  -- assignment.
  -- N.B. The procedure hrempter.terminate_entries_and_alus was procduced for
  --      the Forms Application to perform this task, so it will be used here
  --      as well. (We require the legislation code.)
  --
  open  csr_get_legislation_code;
  fetch csr_get_legislation_code into l_legislation_code;
  if csr_get_legislation_code%NOTFOUND then
    close csr_get_legislation_code;
    -- This should never happen
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','210');
    hr_utility.raise_error;
  end if;
  close csr_get_legislation_code;
  hr_utility.set_location(l_proc, 220);
  --
  -- VT 10/07/96 bug #306710 added parameter in a call list
  hrempter.terminate_entries_and_alus
    (p_assignment_id      => p_assignment_id
    ,p_actual_term_date   => p_actual_termination_date
    ,p_last_standard_date => p_last_standard_process_date
    ,p_final_process_date => null
    ,p_legislation_code   => l_legislation_code
    ,p_entries_changed_warning => l_entries_changed_warning
    );
  --
  hr_utility.set_location(l_proc, 230);
  --
  -- Delete any pay proposals for this assignment that occur after the
  -- actual termination date.
  --
  -- After the delete from per_pay_proposals a warning out parameter is set.
  --
  -- Start of fix 3202260
  for rec_pay_prop in csr_pay_proposal loop
      --
      hr_utility.set_location(l_proc, 231);
      --
       for rec_prop_comp in csr_proposal_comp(rec_pay_prop.pay_proposal_id) loop
      -- Calling the per_pay_proposal_components row handler to delete the
      -- proposal components
         --
         hr_utility.set_location(l_proc, 232);
         --
         per_ppc_del.del(p_component_id          => rec_prop_comp.component_id,
                         p_object_version_number => rec_prop_comp.object_version_number,
                         p_validation_strength   => 'WEAK');
         --
         hr_utility.set_location(l_proc, 233);
         --
      end loop;
      --
      -- Now deleting the salary proposal
      --
      hr_utility.set_location(l_proc, 234);
      --
      delete
      from   per_pay_proposals pyp
      where  pyp.pay_proposal_id = rec_pay_prop.pay_proposal_id;
      --
      -- Setting the Warning Out variable
      if sql%notfound then
         l_pay_proposal_warning := FALSE;
      else
         l_pay_proposal_warning := TRUE;
      end if;
      --
      --
      hr_utility.set_location(l_proc, 235);
      --
  end loop;
  -- End of fix 3202260
  --
  hr_utility.set_location(l_proc, 240);
  --
  if l_datetrack_mode = 'CORRECTION' then
    --
    -- Leave p_object_version_number set to its existing value, as it will
    -- not have changed.
    -- Set effective date parameters to the validation start and date values
    -- which were returned when the assignment row was locked.
    --
    p_effective_start_date := l_cor_validation_start_date;
    p_effective_end_date   := l_cor_validation_end_date;
    hr_utility.set_location(l_proc, 250);
  else
    hr_utility.set_location(l_proc, 260);
    --
    -- When a different DateTrack mode is used, need to select the current
    -- object version number and effective dates. This is because the row
    -- as of the actual termination date will have been modified.
    --
    open csr_asg_values (p_actual_termination_date);
    fetch csr_asg_values into p_object_version_number
                            , p_effective_start_date
                            , p_effective_end_date;
    if csr_asg_values%notfound then
      close csr_asg_values;
      -- This should never happen.
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','270');
      hr_utility.raise_error;
    end if;
    close csr_asg_values;
    hr_utility.set_location(l_proc, 280);
  end if;
  --
  -- Set other output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_pay_proposal_warning       := l_pay_proposal_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 300);
end actual_term_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< final_process_cwk_asg >--------------------------|
-- ----------------------------------------------------------------------------
--

procedure final_process_cwk_asg
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_actual_termination_date      in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning boolean := FALSE;
  --
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_asg_end_date           per_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72) :=
                                      g_package || 'final_process_cwk_asg';
  l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
  l_status                     varchar2(2);
  --
  --
  cursor csr_get_busgrp_legislation is
   select pbg.business_group_id, pbg.legislation_code
      from per_business_groups_perf  pbg
      where  pbg.business_group_id =  (select distinct asg.business_group_id  from
                                     per_assignments_f    asg
                                    where asg.assignment_id  = p_assignment_id);

  --
  --
  cursor csr_lock_csa is
  select null
  from   pay_cost_allocations_f csa
  where  csa.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_alu is
  select null
  from   pay_assignment_link_usages_f alu
  where  alu.assignment_id = p_assignment_id
  for    update nowait;

  -- fix fr bug 5841180 starts here
  /* cursor csr_lock_ele is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_eev is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  for    update nowait; */

  cursor csr_lock_ele(p_effective_date date) is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  and    p_effective_date between effective_start_date and effective_end_date
  for    update nowait;

  cursor csr_lock_eev(p_effective_date date) is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  and    p_effective_date between ele.effective_start_date and ele.effective_end_date
  for    update nowait;

  -- fix for bug 5841180 ends here

  cursor csr_lock_spp is
  select null
  from   per_spinal_point_placements_f spp
  where  spp.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_ppm is
  select null
  from   pay_personal_payment_methods_f ppm
  where  ppm.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_asa is
  select asa.assignment_action_id
  from   pay_assignment_actions asa
  where  asa.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_sas is
  select null
  from   per_secondary_ass_statuses sas
  where  sas.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_pyp is
  select null
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  for    update nowait;
  --
  -- Start of fix for Bug 2796523
  cursor csr_zap_ppm is
  select personal_payment_method_id,object_version_number,effective_start_date
  from   pay_personal_payment_methods_f
  where  assignment_id        = p_assignment_id
  and    effective_start_date > p_final_process_date;
  -- End of fix for Bug 2796523
 --
  cursor csr_dt_del_ppm is
  select personal_payment_method_id,object_version_number
  from   pay_personal_payment_methods_f
  where  assignment_id        = p_assignment_id
  and    p_final_process_date   between effective_start_date
                                and     effective_end_date;
  --
  cursor csr_lock_abv is
  select assignment_budget_value_id
  from   per_assignment_budget_values_f
  where  assignment_id        = p_assignment_id
  and    p_final_process_date   between effective_start_date
                               and     effective_end_date;
  --
  cursor csr_lock_asg_rates is
  select pgr.grade_or_spinal_point_id
  from   pay_grade_rules_f pgr
  where  pgr.grade_or_spinal_point_id = p_assignment_id
  and    rate_type = 'A'
  and    p_final_process_Date between pgr.effective_start_date
                                  and pgr.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  -- None.
  --
  -- Process Logic
  --
  -- Determine asg future changes warning.
  -- Made changes according to first_api_issues.txt

 If p_final_process_date = p_actual_termination_date then
  --
  l_max_asg_end_date := get_max_asg_fut_change_end_dt
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => p_actual_termination_date + 1
    );
  --
 else
  l_max_asg_end_date := get_max_asg_fut_change_end_dt
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => p_final_process_date
    );
 End if;
 hr_utility.set_location(l_proc, 10);
  --
  if l_max_asg_end_date is not null then
    --
    l_asg_future_changes_warning := TRUE;
    hr_utility.set_location(l_proc, 20);
    --
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Lock the appropriate child rows for this assignment.
  --
  open  csr_lock_csa; -- Locking ladder processing order 970
  close csr_lock_csa;
  hr_utility.set_location(l_proc, 40);
  --
  open  csr_lock_alu; -- Locking ladder processing order 1110
  close csr_lock_alu;
  hr_utility.set_location(l_proc, 50);
  --
  open csr_lock_asa;  -- Locking ladder processing order 1190
  close csr_lock_asa;
  hr_utility.set_location(l_proc,55);
  --
  -- fix for bug 5841180 starts here
 /* open  csr_lock_ele; -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 60);
  --
  open  csr_lock_eev; -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 70);*/

  open  csr_lock_ele(p_final_process_date); -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 60);
  --
  open  csr_lock_eev(p_final_process_date); -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 70);

  -- fix for bug 5841180 ends here
  --

  open  csr_lock_spp; -- Locking ladder processing order 1470
  close csr_lock_spp;
  hr_utility.set_location(l_proc, 80);
  --
  open  csr_lock_ppm; -- Locking ladder processing order 1490
  close csr_lock_ppm;
  hr_utility.set_location(l_proc, 90);
  --
  --
  open  csr_lock_abv; -- Locking ladder processing order 1550
  close csr_lock_abv;
  hr_utility.set_location(l_proc, 115);

  --
  open  csr_lock_sas; -- Locking ladder processing order 1590
  close csr_lock_sas;
  hr_utility.set_location(l_proc, 120);
  --
  open  csr_lock_pyp; -- Locking ladder processing order 1630
  close csr_lock_pyp;
  --
  hr_utility.set_location(l_proc, 130);
  --
  open csr_lock_asg_rates;
  close csr_lock_asg_rates;
  --
  hr_utility.set_location(l_proc,135);
  --
  -- For the following tables, date effectively delete any rows which exist as
  -- of the final process date, and ZAP any rows which start after the final
  -- process date:
  --
  --   per_secondary_ass_statuses (not datetracked)
  --   pay_cost_allocations_f
  --   per_spinal_point_placements_f
  --   pay_personal_payment_methods_f
  --   per_assignment_budget_values_f
  --
  update per_secondary_ass_statuses sas
  set    sas.end_date      = p_final_process_date
  where  sas.assignment_id = p_assignment_id
  and    sas.end_date      IS NULL;
  --
  hr_utility.set_location(l_proc, 140);
  --
 delete per_secondary_ass_statuses sas
  where  sas.assignment_id = p_assignment_id
  and    sas.start_date    > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 150);
  --
  hr_utility.set_location(l_proc, 170);
  --
  update pay_cost_allocations_f pca
  set    pca.effective_end_date = p_final_process_date
  where  pca.assignment_id      = p_assignment_id
  and    p_final_process_date   between  pca.effective_start_date
                                and      pca.effective_end_date;
  --
  hr_utility.set_location(l_proc, 180);
  --
  delete pay_cost_allocations_f pca
  where  pca.assignment_id        = p_assignment_id
  and    pca.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 190);
  --
  update per_spinal_point_placements_f  spp
  set    spp.effective_end_date = p_final_process_date
  where  spp.assignment_id      = p_assignment_id
  and    p_final_process_date   between  spp.effective_start_date
                                and      spp.effective_end_date;
  --
  hr_utility.set_location(l_proc, 200);
  --
  delete per_spinal_point_placements_f  spp
  where  spp.assignment_id        = p_assignment_id
  and    spp.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 210);

  --
  -- SASmith date track of abv. 16-APR-1998

  update per_assignment_budget_values_f  abv
  set    abv.effective_end_date = p_final_process_date
  where  abv.assignment_id      = p_assignment_id
  and    p_final_process_date   between  abv.effective_start_date
                                and      abv.effective_end_date;
  --
  hr_utility.set_location(l_proc, 212);
  --
  delete per_assignment_budget_values_f  abv
  where  abv.assignment_id        = p_assignment_id
  and    abv.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 214);
  --
  update pay_grade_rules_f pgr
  set    pgr.effective_end_date = p_final_process_date
  where  pgr.grade_or_spinal_point_id = p_assignment_id
  and    pgr.rate_type                = 'A'
  and    p_final_process_date between pgr.effective_start_date
                                  and pgr.effective_end_date;
  --
  hr_utility.set_location(l_proc,220);
  --
  delete pay_grade_rules_f pgr
  where  grade_or_spinal_point_Id = p_assignment_id
  and    pgr.rate_type = 'A'
  and    pgr.effective_start_Date > p_final_process_date;
  --
  hr_utility.set_location(l_proc,225);
  --
  -- Process any element entries and assignment_link_usages for this
  -- assignment.
  -- N.B. The procedure hrempter.terminate_entries_and_alus was procduced for
  --      the Forms Application to perform this task, so it will be used here
  --      as well. (We require the legislation code.)
  --

  open csr_get_busgrp_legislation;
  fetch csr_get_busgrp_legislation
   into l_business_group_id, l_legislation_code;
  --
  --
  if csr_get_busgrp_legislation%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 230);
    --
    close csr_get_busgrp_legislation;
    --
    -- This should never happen!
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_busgrp_legislation;
  --
  hr_utility.set_location(l_proc, 240);
  hr_utility.set_location('assignment_id : '||to_char(p_assignment_id),99);
  hr_utility.set_location('effective date : '||to_char(p_final_process_date,
							     'DD-MON-yyyy'),99);
  --
  -- VT 10/07/96 bug #306710 added parameter in a call list
  hrempter.terminate_entries_and_alus
    (p_assignment_id      => p_assignment_id
    ,p_actual_term_date   => null
    ,p_last_standard_date => null
    ,p_final_process_date => p_final_process_date
    ,p_legislation_code   => l_legislation_code
    ,p_entries_changed_warning => l_entries_changed_warning
    );
  --
  --
  hr_utility.set_location(l_proc, 250);
  --

--  Call the row handler to date effectively delete the rows
  --
  for rec in csr_dt_del_ppm loop

    pay_ppm_del.del
    ( p_personal_payment_method_id => rec.personal_payment_method_id
     ,p_effective_start_date       => l_effective_start_date
     ,p_effective_end_date         => l_effective_end_date
     ,p_object_version_number      => rec.object_version_number
     ,p_effective_date             => p_final_process_date
     ,p_datetrack_mode             => 'DELETE');

  end loop;
  --
  hr_utility.set_location(l_proc, 255);

  --  Call the row handler to zap rows

  for rec in csr_zap_ppm loop

    pay_ppm_del.del
    ( p_personal_payment_method_id => rec.personal_payment_method_id
     ,p_effective_start_date       => l_effective_start_date
     ,p_effective_end_date         => l_effective_end_date
     ,p_object_version_number      => rec.object_version_number
     ,p_effective_date             => rec.effective_start_date -- Bug 2796523
     ,p_datetrack_mode             => 'ZAP');

  end loop;

  -- Date effectively delete the assignment.
  --
  hr_utility.set_location('assignment_id : '||to_char(p_assignment_id),99);
  hr_utility.set_location('effective date : '||to_char(p_final_process_date,
						       'DD-MON-yyyy'),99);
  per_asg_del.del
    (p_assignment_id                 => p_assignment_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => l_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_final_process_date
    ,p_validation_start_date         => l_validation_start_date
    ,p_validation_end_date           => l_validation_end_date
    ,p_datetrack_mode                => 'DELETE'
    ,p_org_now_no_manager_warning    => l_org_now_no_manager_warning
    );
  --
  --
  hr_utility.set_location(l_proc, 260);
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 400);
end final_process_cwk_asg;
--
-- 115.66 (START)
--
-- ----------------------------------------------------------------------------
-- |------------------< actual_term_emp_asg_sup (overloaded) >----------------|
-- ----------------------------------------------------------------------------
--
procedure actual_term_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ) is
--
l_alu_change_warning VARCHAR2(1) := 'N';
--
begin
  actual_term_emp_asg_sup
    (p_assignment_id              => p_assignment_id
    ,p_object_version_number      => p_object_version_number
    ,p_actual_termination_date    => p_actual_termination_date
    ,p_last_standard_process_date => p_last_standard_process_date
    ,p_assignment_status_type_id  => p_assignment_status_type_id
    ,p_effective_start_date       => p_effective_start_date
    ,p_effective_end_date         => p_effective_end_date
    ,p_asg_future_changes_warning => p_asg_future_changes_warning
    ,p_entries_changed_warning    => p_entries_changed_warning
    ,p_pay_proposal_warning       => p_pay_proposal_warning
    ,p_alu_change_warning         => l_alu_change_warning
    );
end actual_term_emp_asg_sup;
--
-- 115.66 (END)
--
-- ----------------------------------------------------------------------------
-- |------------------------< actual_term_emp_asg_sup >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_term_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
--
-- 115.66 (START)
--
  ,p_alu_change_warning              out nocopy varchar2
--
-- 115.66 (END)
--
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
--
-- 115.66 (START)
--
  l_alu_change_warning         varchar2(1) := 'N';
--
-- 115.66 (END)
--
  --
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_correction                 boolean;
  l_datetrack_mode             varchar2(30);
  l_entries_changed            varchar2(1);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_asg_end_date           per_assignments_f.effective_end_date%TYPE;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  l_pay_proposal_warning       boolean := FALSE; -- Bug 3202260
  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_payroll_id_updated         boolean;
  l_update                     boolean;
  l_update_change_insert       boolean;
  l_update_override            boolean;
  l_future_records_flag        boolean;
  l_cor_validation_start_date  date;
  l_cor_validation_end_date    date;
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_esd_not_required           date;
  l_eed_not_required           date;
  l_proc                       varchar2(72) :=
                                       g_package || 'actual_term_emp_asg_sup';
  --
  cursor csr_get_legislation_code is
  select bus.legislation_code
  from   per_business_groups bus
  where  bus.business_group_id = l_business_group_id;
  --
  cursor csr_asg_values (l_effective_date date) is
  select asg.object_version_number
       , asg.effective_start_date
       , asg.effective_end_date
    from per_assignments_f asg
   where asg.assignment_id      = p_assignment_id
     and l_effective_date between asg.effective_start_date
                              and asg.effective_end_date;
  --
  cursor csr_get_future_asg (l_effective_date date) is
  select asg.object_version_number
       , asg.effective_start_date
       , asg.effective_end_date
    from per_assignments_f asg
   where asg.assignment_id = p_assignment_id
     and asg.effective_start_date >= l_effective_date;
  --
  cursor csr_lock_alu is
  select null
  from   pay_assignment_link_usages_f alu
  where  alu.assignment_id = p_assignment_id
  for    update nowait;

-- fix for bug 5841180 starts here
/*
  cursor csr_lock_ele is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_eev is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  for    update nowait;
  */

  cursor csr_lock_ele(p_effective_date date) is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  and    p_effective_date between effective_start_date and effective_end_date
  for    update nowait;

  cursor csr_lock_eev (p_effective_date date) is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  and    p_effective_date between ele.effective_start_date and ele.effective_end_date
  for    update nowait;

  -- fix for bug 5841180 ends here

  cursor csr_lock_asa is
  select asa.assignment_action_id
  from   pay_assignment_actions asa
  where  asa.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_pyp is
  select null
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  for    update nowait;
  --
  -- Start of fix 3202260
  cursor csr_pay_proposal is
  select pyp.pay_proposal_id, pyp.object_version_number, pyp.business_group_id
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  and    pyp.change_date > p_actual_termination_date
  order  by pyp.change_date desc;
  --Added business_group_id for bug 4689950
  --
  cursor csr_proposal_comp(l_proposal_id number) is
  select ppc.component_id, ppc.object_version_number
  from   per_pay_proposal_components ppc
  where  ppc.pay_proposal_id = l_proposal_id;
  -- End of 3202260

  --start of bug 5026287
/*commented the changes for  bug 5026287
  l_effective_end_date1          per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date1        per_assignments_f.effective_start_date%TYPE;
  l_object_version_number1       per_assignments_f.object_version_number%TYPE;*/
  --end of bug 5026287

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Process Logic
  --
  -- Determine the datetrack mode to use for the assignment table handler
  -- update call.
  --
  --start of bug 5026287

/* open csr_asg_values (p_actual_termination_date);
    fetch csr_asg_values into l_object_version_number1
                            , l_effective_start_date1
                            , l_effective_end_date1;
    if csr_asg_values%notfound then
      close csr_asg_values;
      -- This should never happen.
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','270');
      hr_utility.raise_error;
    end if;
    close csr_asg_values;*/
 /* commented the changes made by bug 5026287*/
/*if p_actual_termination_date = l_effective_start_date1 then

   per_asg_shd.find_dt_upd_modes
    (p_effective_date       => p_actual_termination_date
    ,p_base_key_value       => p_assignment_id
    ,p_correction           => l_correction
    ,p_update               => l_update
    ,p_update_override      => l_update_override
    ,p_update_change_insert => l_update_change_insert
    );
else
  per_asg_shd.find_dt_upd_modes
    (p_effective_date       => p_actual_termination_date + 1
    ,p_base_key_value       => p_assignment_id
    ,p_correction           => l_correction
    ,p_update               => l_update
    ,p_update_override      => l_update_override
    ,p_update_change_insert => l_update_change_insert
    );
end if;*/

  per_asg_shd.find_dt_upd_modes
    (p_effective_date       => p_actual_termination_date + 1
    ,p_base_key_value       => p_assignment_id
    ,p_correction           => l_correction
    ,p_update               => l_update
    ,p_update_override      => l_update_override
    ,p_update_change_insert => l_update_change_insert
    );
--end of bug 5026287


  hr_utility.set_location(l_proc, 10);
  --
  if l_update_change_insert then
    --
    -- This is the case where there is a future dated assignment and
    -- we need to insert a record betwen ATD+1 and that future change
    -- with a TERM status. We need 'CORRECTION' of future records to
    -- have the right status.
    --
    l_datetrack_mode             := 'UPDATE_CHANGE_INSERT';
    l_asg_future_changes_warning := TRUE;
    l_object_version_number      := p_object_version_number;
    l_future_records_flag        := TRUE;
    hr_utility.set_location(l_proc, 20);
  elsif l_update then
    --
    l_datetrack_mode        := 'UPDATE';
    l_object_version_number := p_object_version_number;
    hr_utility.set_location(l_proc, 30);
    --
  elsif l_correction then
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- We have the OVN for the assignment record which starts on ATD+1
    -- so lock this one for termination.
    --
    l_object_version_number := p_object_version_number;
    --
    -- Lock the current row as of ATD+1, using correction mode.
    -- This validates the object version number passed in and obtains the
    -- validation_start_date and validation_end_date.
    --
    per_asg_shd.lck
      (p_effective_date        => p_actual_termination_date + 1
      ,p_datetrack_mode        => 'CORRECTION'
      ,p_assignment_id         => p_assignment_id
      ,p_object_version_number => l_object_version_number
      ,p_validation_start_date => l_cor_validation_start_date
      ,p_validation_end_date   => l_cor_validation_end_date
      );
    hr_utility.set_location(l_proc, 50);
    --
    -- Find out if there changes after, the day
    -- after the actual termination date
    --
    l_max_asg_end_date := get_max_asg_fut_change_end_dt
      (p_assignment_id  => p_assignment_id
      ,p_effective_date => p_actual_termination_date + 1
      );
    hr_utility.set_location(l_proc, 70);
    --
    if l_max_asg_end_date is not null then
      --
      l_future_records_flag := TRUE;
      hr_utility.set_location(l_proc, 80);
    end if;
    --
    hr_utility.set_location(l_proc, 110);
    --
    l_datetrack_mode             := 'CORRECTION';
    l_asg_future_changes_warning := TRUE;
    -- For correction the object_version_number has already been derived.
    hr_utility.set_location(l_proc, 120);
  else
    --
    -- No other datetrack modes are valid, and so should not occur.
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','130');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 140);
  --
  -- Update employee assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_comment_id                   => l_comment_id
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_actual_termination_date + 1
    ,p_datetrack_mode               => l_datetrack_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  hr_utility.set_location(l_proc, 150);
  --
  -- If there are future dated records then we need to process these and set the
  -- right assignment status.
  --
  if l_future_records_flag then
    --
    -- We have future dated assignment records so set them to a TERM_ASSIGN
    -- status.
    --
    for c_asg_rec in csr_get_future_asg(p_actual_termination_date+2)
    loop
      per_asg_upd.upd
        (p_assignment_id                => p_assignment_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_business_group_id            => l_business_group_id
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_comment_id                   => l_comment_id
        ,p_payroll_id_updated           => l_payroll_id_updated
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_no_managers_warning          => l_no_managers_warning
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_validation_start_date        => l_validation_start_date
        ,p_validation_end_date          => l_validation_end_date
        ,p_object_version_number        => c_asg_rec.object_version_number
        ,p_effective_date               => c_asg_rec.effective_start_date
        ,p_datetrack_mode               => 'CORRECTION'
        ,p_validate                     => FALSE
        ,p_hourly_salaried_warning      => l_hourly_salaried_warning
        );
    end loop;
  end if;
  --
  -- Lock the appropriate child rows for this assignment.
  --
  open  csr_lock_alu; -- Locking ladder processing order 1110
  close csr_lock_alu;
  hr_utility.set_location(l_proc, 160);
  --
  open csr_lock_asa;  -- Locking ladder processing order 1190
  close csr_lock_asa;
  hr_utility.set_location(l_proc,170);
  --

  -- Fix for bug 5841180 starts here

 /* open  csr_lock_ele; -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 180);
  --
  open  csr_lock_eev; -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 190); */

  open  csr_lock_ele(p_actual_termination_date); -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 180);
  --
  open  csr_lock_eev(p_actual_termination_date); -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 190);

  -- Fix for bug 5841180 ends here

  open  csr_lock_pyp; -- Locking ladder processing order 1630
  close csr_lock_pyp;
  hr_utility.set_location(l_proc, 200);
  --
  -- Process any element entries and assignment_link_usages for this
  -- assignment.
  -- N.B. The procedure hrempter.terminate_entries_and_alus was procduced for
  --      the Forms Application to perform this task, so it will be used here
  --      as well. (We require the legislation code.)
  --
  open  csr_get_legislation_code;
  fetch csr_get_legislation_code into l_legislation_code;
  if csr_get_legislation_code%NOTFOUND then
    close csr_get_legislation_code;
    -- This should never happen
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','210');
    hr_utility.raise_error;
  end if;
  close csr_get_legislation_code;
  hr_utility.set_location(l_proc, 220);
  --
  -- VT 10/07/96 bug #306710 added parameter in a call list
  hrempter.terminate_entries_and_alus
    (p_assignment_id      => p_assignment_id
    ,p_actual_term_date   => p_actual_termination_date
    ,p_last_standard_date => p_last_standard_process_date
    ,p_final_process_date => null
    ,p_legislation_code   => l_legislation_code
    ,p_entries_changed_warning => l_entries_changed_warning
--
-- 115.66 (START)
--
    ,p_alu_change_warning => l_alu_change_warning
--
-- 115.66 (END)
--
    );
--
-- 115.66 (START)
--
    p_alu_change_warning := l_alu_change_warning;
--
-- 115.66 (END)
--
  --
  hr_utility.set_location(l_proc, 230);
  --
  -- Delete any pay proposals for this assignment that occur after the
  -- actual termination date.
  --
  -- After the delete from per_pay_proposals a warning out parameter is set.
  --
  -- Start of fix 3202260
  for rec_pay_prop in csr_pay_proposal loop
      --
      hr_utility.set_location(l_proc, 231);
      --
      for rec_prop_comp in csr_proposal_comp(rec_pay_prop.pay_proposal_id) loop
      -- Calling the per_pay_proposal_components row handler to delete the
      -- proposal components
         --
         hr_utility.set_location(l_proc, 232);
         --
         per_ppc_del.del(p_component_id          => rec_prop_comp.component_id,
                         p_object_version_number => rec_prop_comp.object_version_number,
                         p_validation_strength   => 'WEAK',
                         p_validate => true);
         --
         hr_utility.set_location(l_proc, 233);
         --
      end loop;
/*      --
      -- Now deleting the salary proposal
      --
      hr_utility.set_location(l_proc, 234);
      --
      delete
      from   per_pay_proposals pyp
      where  pyp.pay_proposal_id = rec_pay_prop.pay_proposal_id;
      --
      -- Setting the Warning Out variable
     if sql%notfound then
         l_pay_proposal_warning := FALSE;
      else
         l_pay_proposal_warning := TRUE;
      end if;
      --*/
      --Start of fix for bug 4689950
       hr_maintain_proposal_api.delete_salary_proposal(
               p_pay_proposal_id   => rec_pay_prop.pay_proposal_id,
		       p_business_group_id => rec_pay_prop.business_group_id,
               p_object_version_number => rec_pay_prop.object_version_number,
               p_validate     => NULL,
               p_salary_warning => l_pay_proposal_warning
               );
      l_pay_proposal_warning := TRUE;
      --End of fix for bug 4689950
      --
      hr_utility.set_location(l_proc, 235);
      --
  end loop;
  -- End of fix 3202260
  --
  hr_utility.set_location(l_proc, 240);
  --
  if l_datetrack_mode = 'CORRECTION' then
    --
    -- Leave p_object_version_number set to its existing value, as it will
    -- not have changed.
    -- Set effective date parameters to the validation start and date values
    -- which were returned when the assignment row was locked.
    --
    p_effective_start_date := l_cor_validation_start_date;
    p_effective_end_date   := l_cor_validation_end_date;
    hr_utility.set_location(l_proc, 250);
  else
    hr_utility.set_location(l_proc, 260);
    --
    -- When a different DateTrack mode is used, need to select the current
    -- object version number and effective dates. This is because the row
    -- as of the actual termination date will have been modified.
    --
    open csr_asg_values (p_actual_termination_date);
    fetch csr_asg_values into p_object_version_number
                            , p_effective_start_date
                            , p_effective_end_date;
    if csr_asg_values%notfound then
      close csr_asg_values;
      -- This should never happen.
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','270');
      hr_utility.raise_error;
    end if;
    close csr_asg_values;
    hr_utility.set_location(l_proc, 280);
  end if;
  --
  -- Set other output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_pay_proposal_warning       := l_pay_proposal_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 300);
end actual_term_emp_asg_sup;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_first_spp >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_first_spp
  (p_effective_date		in     date
  ,p_assignment_id		in     number
  ,p_validation_start_date	in     date
  ,p_validation_end_date	in     date
  ,p_future_spp_warning		   out nocopy boolean) is

  l_effective_end_date		date;
  l_effective_start_date	date;
  l_object_version_number	number;
  l_placement_id		number;
  l_update			number;
  l_future_spp_warning		boolean;
  l_datetrack_mode		varchar2(30);

  --
  -- Check to see if a grade step has been created for assignment
  --
  cursor csr_grade_step is
         select spp.placement_id
         from per_spinal_point_placements_f  spp
         where spp.assignment_id = p_assignment_id
         and p_validation_start_date between spp.effective_start_date
                                 and spp.effective_end_date;

begin

  --
  -- Check that there has been a grade step created for this assignment
  --
  open csr_grade_step;
  fetch csr_grade_step into l_update;
    if csr_grade_step%found then

   --
   -- Get the placement id and object version number for the assignment
   --
      select placement_id,object_version_number,effective_end_date
      into l_placement_id,l_object_version_number,l_effective_end_date
      from per_spinal_point_placements_f
      where assignment_id = p_assignment_id
      and p_validation_start_date between effective_start_date
                            and effective_end_date;

	   --
           -- Delete next change until the effective end date of the record
           -- that was just inserted matches the validation end date
           --
           loop

           l_datetrack_mode := 'DELETE_NEXT_CHANGE';

           hr_utility.set_location('l_effective_end_date :'||l_effective_end_date,25);

           if l_effective_end_date = p_validation_end_date then
           exit;
           end if;

           hr_sp_placement_api.delete_spp
           (p_effective_date        => p_validation_start_date
           ,p_datetrack_mode        => l_datetrack_mode
           ,p_placement_id          => l_placement_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);

           select effective_end_date
           into l_effective_end_date
           from per_spinal_point_placements_f
           where placement_id = l_placement_id
           and p_validation_start_date between effective_start_date
                           		   and effective_end_date;

           end loop;

   --
   -- Now that there is only one record for the period, use dml to remove the first record
   --
   delete from per_spinal_point_placements_f
   where assignment_id = p_assignment_id
   and placement_id = l_placement_id
   and effective_start_date = p_validation_start_date;

   l_future_spp_warning := TRUE;
   p_future_spp_warning := l_future_spp_warning;

  end if;

end delete_first_spp;

-- ----------------------------------------------------------------------------
-- |------------------------< create_default_emp_asg >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_default_emp_asg
  (p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_period_of_service_id         in     number
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_location_id            per_business_groups.location_id%TYPE;
  l_time_normal_finish     per_business_groups.default_end_time%TYPE;
  l_time_normal_start      per_business_groups.default_start_time%TYPE;
  l_normal_hours           number;
  l_frequency              per_business_groups.frequency%TYPE;
  l_legislation_code       per_business_groups.legislation_code%TYPE;
  l_effective_start_date   per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_assignments_f.effective_start_date%TYPE;
  l_assignment_number      per_assignments_f.assignment_number%TYPE;
  l_comment_id             per_assignments_f.comment_id%TYPE;
  l_other_manager_warning  boolean;
  l_proc                   varchar2(72):=g_package||'create_default_emp_asg';
  --
  cursor csr_get_default_details is
    select bus.location_id
         , bus.default_end_time
         , bus.default_start_time
         , fnd_number.canonical_to_number(bus.working_hours)
         , bus.frequency
         , bus.legislation_code
      from per_business_groups bus
     where bus.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_number := null;
  --
  -- Process Logic
  --
  -- Get default details.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'business_group_id',
     p_argument_value => p_business_group_id);
  --
  open  csr_get_default_details;
  fetch csr_get_default_details
   into l_location_id
      , l_time_normal_finish
      , l_time_normal_start
      , l_normal_hours
      , l_frequency
      , l_legislation_code;
  --
  if csr_get_default_details%NOTFOUND then
    --
    hr_utility.set_location(l_proc, 10);
    --
    close csr_get_default_details;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_get_default_details;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Create employee assignment.
  --
  hr_assignment_internal.create_emp_asg
    (p_effective_date               => p_effective_date
    ,p_legislation_code             => l_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_business_group_id
    ,p_primary_flag                 => 'Y'
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_location_id                  => l_location_id
    ,p_people_group_id              => null
    ,p_assignment_number            => l_assignment_number
    ,p_frequency                    => l_frequency
    ,p_normal_hours                 => l_normal_hours
    ,p_time_normal_finish           => l_time_normal_finish
    ,p_time_normal_start            => l_time_normal_start
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_validate_df_flex             => false
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set remaining output arguments
  --
  p_assignment_number := l_assignment_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end create_default_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_emp_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_primary_flag                 in     varchar2
  ,p_period_of_service_id         in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_id             per_assignments_f.assignment_id%TYPE;
  l_assignment_sequence       per_assignments_f.assignment_sequence%TYPE;
  l_assignment_status_type_id per_assignments_f.assignment_status_type_id%TYPE;
  l_entries_changed           varchar2(1);
  l_effective_start_date      per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date        per_assignments_f.effective_end_date%TYPE;
  l_proc                      varchar2(72) := g_package||'create_emp_asg';
  l_hourly_salaried_warning   boolean;
  l_object_version_number      per_assignments_f.object_version_number%TYPE;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_status_type_id := p_assignment_status_type_id;

  hr_assignment_internal.create_emp_asg
    (p_effective_date               => p_effective_date
    ,p_legislation_code             => p_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_organization_id
    ,p_primary_flag                 => p_primary_flag
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_comment_id                   => p_comment_id
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_validate_df_flex             => p_validate_df_flex        --Added to fix the bug 2354616
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );


  p_assignment_id                := l_assignment_id;
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
 p_object_version_number         := l_object_version_number ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end create_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_emp_asg >------ OVERLOADED----------|
-- ----------------------------------------------------------------------------
--
procedure create_emp_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_primary_flag                 in     varchar2
  ,p_period_of_service_id         in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_grade_ladder_pgm_id          in     number   default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_id             per_assignments_f.assignment_id%TYPE;
  l_assignment_sequence       per_assignments_f.assignment_sequence%TYPE;
  l_assignment_status_type_id per_assignments_f.assignment_status_type_id%TYPE;
  l_entries_changed           varchar2(1);
  l_effective_start_date      per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date        per_assignments_f.effective_end_date%TYPE;
  l_proc                      varchar2(72) := g_package||'create_emp_asg';
  l_labour_union_member_flag  per_assignments_f.labour_union_member_flag%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  --
   -- fix for bug 4550165 starts here.
  if p_legislation_code = 'DE' then
  l_labour_union_member_flag := null;
  else
  l_labour_union_member_flag := p_labour_union_member_flag;
  end if;
  -- fix for bug 4550165 ends here.

  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is null then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => p_business_group_id
    ,p_legislation_code          => p_legislation_code
    ,p_expected_system_status    => 'ACTIVE_ASSIGN'
    );
    --
  hr_utility.set_location(l_proc, 10);
  --
  -- Insert per_assignments_f row.
  --
  per_asg_ins.ins
    (p_assignment_id                => l_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => p_business_group_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_type              => 'E'
    ,p_primary_flag                 => p_primary_flag
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => p_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => l_labour_union_member_flag -- fix for bug 4550165.
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_validate                     => FALSE
    ,p_validate_df_flex             => p_validate_df_flex
    ,p_hourly_salaried_warning      => p_hourly_salaried_warning
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Create standard element entries for this assignment.
  --
  hrentmnt.maintain_entries_asg
    (p_assignment_id                => l_assignment_id
    ,p_old_payroll_id               => null
    ,p_new_payroll_id               => null
    ,p_business_group_id            => p_business_group_id
    ,p_operation                    => 'ASG_CRITERIA'
    ,p_actual_term_date             => null
    ,p_last_standard_date           => null
    ,p_final_process_date           => null
    ,p_dt_mode                      => 'INSERT'
    ,p_validation_start_date        => l_effective_start_date
    ,p_validation_end_date          => l_effective_end_date
    ,p_entries_changed              => l_entries_changed
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Create budget values for this assignment.
  -- 16-APR-1998 Change to include effective dates. SASmith
  --
  hr_assignment.load_budget_values
    (p_assignment_id                => l_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_userid                       => null
    ,p_login                        => null
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
  hr_assignment.load_assignment_allocation
    (p_assignment_id => l_assignment_id
    ,p_business_group_id => p_business_group_id
    ,p_effective_date =>l_effective_start_date
    ,p_position_id => p_position_id);
  --
  -- Set all output arguments
  --
  p_assignment_id                := l_assignment_id;
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end create_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< final_process_emp_asg_sup >----------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_emp_asg_sup
  (p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_actual_termination_date      in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
--
-- 115.66 (START)
--
  l_alu_change_warning         varchar2(1) := 'N';
--
-- 115.66 (END)
--
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning boolean := FALSE;
--surendra
--
  l_loc_change_tax_issues    boolean;
  l_delete_asg_budgets       boolean;
  l_element_salary_warning   boolean;
  l_element_entries_warning  boolean;
  l_spp_warning              boolean;
  l_cost_warning             boolean;
  l_life_events_exists       boolean;
  --
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_asg_end_date           per_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72) :=
                                      g_package || 'final_process_emp_asg_sup';
  l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
  l_status                     varchar2(2);
  --
  --
  cursor csr_get_busgrp_legislation is
  select pbg.business_group_id, pbg.legislation_code
      from per_business_groups_perf  pbg
      where  pbg.business_group_id =  (select distinct asg.business_group_id  from
                                     per_assignments_f    asg
                                    where asg.assignment_id  = p_assignment_id);
  --
  --
  cursor csr_lock_csa is
  select null
  from   pay_cost_allocations_f csa
  where  csa.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_alu is
  select null
  from   pay_assignment_link_usages_f alu
  where  alu.assignment_id = p_assignment_id
  for    update nowait;
  --
  -- Fix for bug 5841180 starts here
  /* cursor csr_lock_ele is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_eev is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  for    update nowait; */


  cursor csr_lock_ele(p_effective_date date) is
  select null
  from   pay_element_entries_f ele
  where  ele.assignment_id = p_assignment_id
  and    p_effective_date between effective_start_date and effective_end_date
  for    update nowait;

  cursor csr_lock_eev(p_effective_date date) is
  select eev.element_entry_id
  from   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  where  ele.assignment_id    = p_assignment_id
  and    eev.element_entry_id = ele.element_entry_id
  and    p_effective_date between ele.effective_start_date and ele.effective_end_date
  for    update nowait;

  -- Fix for bug 5841180 ends here
  --
  cursor csr_lock_spp is
  select null
  from   per_spinal_point_placements_f spp
  where  spp.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_ppm is
  select null
  from   pay_personal_payment_methods_f ppm
  where  ppm.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_sas is
  select null
  from   per_secondary_ass_statuses sas
  where  sas.assignment_id = p_assignment_id
  for    update nowait;
  --
  cursor csr_lock_pyp is
  select null
  from   per_pay_proposals pyp
  where  pyp.assignment_id = p_assignment_id
  for    update nowait;
  --
  -- Start of fix for Bug 2796523
  cursor csr_zap_ppm is
  select personal_payment_method_id,object_version_number,effective_start_date
  from   pay_personal_payment_methods_f
  where  assignment_id        = p_assignment_id
  and    effective_start_date > p_final_process_date;
  -- End of fix for Bug 2796523
 --
  cursor csr_dt_del_ppm is
  select personal_payment_method_id,object_version_number
  from   pay_personal_payment_methods_f
  where  assignment_id        = p_assignment_id
  and    p_final_process_date   between effective_start_date
                                and     effective_end_date;
  cursor csr_lock_asa is
  select asa.assignment_action_id
  from   pay_assignment_actions asa
  where  asa.assignment_id = p_assignment_id
  for    update nowait;
  --
  --
  cursor csr_lock_abv is
  select assignment_budget_value_id
  from   per_assignment_budget_values_f
  where  assignment_id        = p_assignment_id
  and    p_final_process_date   between effective_start_date
                               and     effective_end_date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  -- None.
  --
  -- Process Logic
  --
  -- Determine asg future changes warning.
  -- Made changes according to first_api_issues.txt

 If p_final_process_date = p_actual_termination_date then
  --
  l_max_asg_end_date := get_max_asg_fut_change_end_dt
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => p_actual_termination_date + 1
    );
  --
 else
  l_max_asg_end_date := get_max_asg_fut_change_end_dt
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => p_final_process_date
    );
 End if;
 hr_utility.set_location(l_proc, 10);
  --
  if l_max_asg_end_date is not null then
    --
    l_asg_future_changes_warning := TRUE;
    hr_utility.set_location(l_proc, 20);
    --
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Lock the appropriate child rows for this assignment.
  --
  open  csr_lock_csa; -- Locking ladder processing order 970
  close csr_lock_csa;
  hr_utility.set_location(l_proc, 40);
  --
  open  csr_lock_alu; -- Locking ladder processing order 1110
  close csr_lock_alu;
  hr_utility.set_location(l_proc, 50);
  --
  open csr_lock_asa;  -- Locking ladder processing order 1190
  close csr_lock_asa;
  hr_utility.set_location(l_proc,55);
  --
  -- Fix for bug 5841180 starts here
  /* open  csr_lock_ele; -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 60);
  --
  open  csr_lock_eev; -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 70); */

  open  csr_lock_ele(p_final_process_date); -- Locking ladder processing order 1440
  close csr_lock_ele;
  hr_utility.set_location(l_proc, 60);
  --
  open  csr_lock_eev(p_final_process_date); -- Locking ladder processing order 1450
  close csr_lock_eev;
  hr_utility.set_location(l_proc, 70);

    -- Fix for bug 5841180 ends here
  --
  open  csr_lock_spp; -- Locking ladder processing order 1470
  close csr_lock_spp;
  hr_utility.set_location(l_proc, 80);
  --
  open  csr_lock_ppm; -- Locking ladder processing order 1490
  close csr_lock_ppm;
  hr_utility.set_location(l_proc, 90);
  --
  open  csr_lock_abv; -- Locking ladder processing order 1550
  close csr_lock_abv;
  hr_utility.set_location(l_proc, 115);
  --
  open  csr_lock_sas; -- Locking ladder processing order 1590
  close csr_lock_sas;
  hr_utility.set_location(l_proc, 120);
  --
  open  csr_lock_pyp; -- Locking ladder processing order 1630
  close csr_lock_pyp;
  hr_utility.set_location(l_proc, 130);

  --
  -- For the following tables, date effectively delete any rows which exist as
  -- of the final process date, and ZAP any rows which start after the final
  -- process date:
  --
  --   per_secondary_ass_statuses (not datetracked)
  --   pay_cost_allocations_f
  --   per_spinal_point_placements_f
  --   pay_personal_payment_methods_f
  --   per_assignment_budget_values_f
  --
  update per_secondary_ass_statuses sas
  set    sas.end_date      = p_final_process_date
  where  sas.assignment_id = p_assignment_id
  and    sas.end_date      IS NULL;
  --
  hr_utility.set_location(l_proc, 140);
  --
 delete per_secondary_ass_statuses sas
  where  sas.assignment_id = p_assignment_id
  and    sas.start_date    > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 150);
  --
  hr_utility.set_location(l_proc, 170);
  --
  update pay_cost_allocations_f pca
  set    pca.effective_end_date = p_final_process_date
  where  pca.assignment_id      = p_assignment_id
  and    p_final_process_date   between  pca.effective_start_date
                                and      pca.effective_end_date;
  --
  hr_utility.set_location(l_proc, 180);
  --
  delete pay_cost_allocations_f pca
  where  pca.assignment_id        = p_assignment_id
  and    pca.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 190);
  --
  update per_spinal_point_placements_f  spp
  set    spp.effective_end_date = p_final_process_date
  where  spp.assignment_id      = p_assignment_id
  and    p_final_process_date   between  spp.effective_start_date
                                and      spp.effective_end_date;
  --
  hr_utility.set_location(l_proc, 200);
  --
  delete per_spinal_point_placements_f  spp
  where  spp.assignment_id        = p_assignment_id
  and    spp.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 210);

  --
  -- SASmith date track of abv. 16-APR-1998

  update per_assignment_budget_values_f  abv
  set    abv.effective_end_date = p_final_process_date
  where  abv.assignment_id      = p_assignment_id
  and    p_final_process_date   between  abv.effective_start_date
                                and      abv.effective_end_date;
  --
  hr_utility.set_location(l_proc, 212);
  --
  delete per_assignment_budget_values_f  abv
  where  abv.assignment_id        = p_assignment_id
  and    abv.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc, 214);


  --
  -- Process any element entries and assignment_link_usages for this
  -- assignment.
  -- N.B. The procedure hrempter.terminate_entries_and_alus was procduced for
  --      the Forms Application to perform this task, so it will be used here
  --      as well. (We require the legislation code.)
  --

  open csr_get_busgrp_legislation;
  fetch csr_get_busgrp_legislation
   into l_business_group_id, l_legislation_code;
  --
  --
  if csr_get_busgrp_legislation%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 230);
    --
    close csr_get_busgrp_legislation;
    --
    -- This should never happen!
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_busgrp_legislation;
  --
  hr_utility.set_location(l_proc, 240);
  hr_utility.set_location('assignment_id : '||to_char(p_assignment_id),99);
  hr_utility.set_location('effective date : '||to_char(p_final_process_date,
							     'DD-MON-yyyy'),99);
  --
  -- VT 10/07/96 bug #306710 added parameter in a call list
  hrempter.terminate_entries_and_alus
    (p_assignment_id      => p_assignment_id
    ,p_actual_term_date   => null
    ,p_last_standard_date => null
    ,p_final_process_date => p_final_process_date
    ,p_legislation_code   => l_legislation_code
    ,p_entries_changed_warning => l_entries_changed_warning
--
-- 115.66 (START)
--
    ,p_alu_change_warning => l_alu_change_warning
--
-- 115.66 (END)
--
    );
  --
  --
  hr_utility.set_location(l_proc, 250);
  --

--  Call the row handler to date effectively delete the rows
  --
  for rec in csr_dt_del_ppm loop

    pay_ppm_del.del
    ( p_personal_payment_method_id => rec.personal_payment_method_id
     ,p_effective_start_date       => l_effective_start_date
     ,p_effective_end_date         => l_effective_end_date
     ,p_object_version_number      => rec.object_version_number
     ,p_effective_date             => p_final_process_date
     ,p_datetrack_mode             => 'DELETE');

  end loop;
  --
  hr_utility.set_location(l_proc, 255);

  --  Call the row handler to zap rows

  for rec in csr_zap_ppm loop

    pay_ppm_del.del
    ( p_personal_payment_method_id => rec.personal_payment_method_id
     ,p_effective_start_date       => l_effective_start_date
     ,p_effective_end_date         => l_effective_end_date
     ,p_object_version_number      => rec.object_version_number
     ,p_effective_date             => rec.effective_start_date -- Bug #2796523
     ,p_datetrack_mode             => 'ZAP');

  end loop;

  -- Date effectively delete the assignment.
  --
  hr_utility.set_location('assignment_id : '||to_char(p_assignment_id),99);
  hr_utility.set_location('effective date : '||to_char(p_final_process_date,
						       'DD-MON-yyyy'),99);
  --
  per_asg_del.del
    (p_assignment_id                 => p_assignment_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => l_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_final_process_date
    ,p_validation_start_date         => l_validation_start_date
    ,p_validation_end_date           => l_validation_end_date
    ,p_datetrack_mode                => 'DELETE'
    ,p_org_now_no_manager_warning    => l_org_now_no_manager_warning
    );
  --
  --
  hr_utility.set_location(l_proc, 260);
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end final_process_emp_asg_sup;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< SPP_ZAP >--------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE spp_zap
  (p_assignment_id         IN     per_assignments_f.assignment_id%TYPE) IS
  --
  -- Declare Local Variables
  --
  l_proc                 VARCHAR2(72) := g_package||'spp_zap';
  l_previous_id          per_spinal_point_placements_f.placement_id%TYPE;
  l_effective_start_date DATE;
  l_effective_end_date   DATE;
  --
  CURSOR csr_spp_records IS
    SELECT spp.placement_id,
           spp.object_version_number,
           spp.effective_start_date
    FROM   per_spinal_point_placements_f  spp
    WHERE  spp.assignment_id =  p_assignment_id
    ORDER BY placement_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  l_previous_id := -1;
  --
  FOR c_spp_record IN csr_spp_records LOOP
    --
    hr_utility.set_location(l_proc||'/'||c_spp_record.placement_id,20);
    hr_utility.set_location(l_proc||'/'||c_spp_record.object_version_number,21);
    hr_utility.set_location(l_proc||'/'||c_spp_record.effective_start_date,22);
    --
    IF l_previous_id <> c_spp_record.placement_id THEN
      --
      hr_utility.set_location(l_proc,30);
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date		       => c_spp_record.effective_start_date
        ,p_datetrack_mode	       	=> hr_api.g_zap
        ,p_placement_id		         => c_spp_record.placement_id
        ,p_object_version_number  => c_spp_record.object_version_number
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
      --
      l_previous_id := c_spp_record.placement_id;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
END spp_zap;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< SPP_UPDATE_CHANGE_INSERT >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE spp_update_change_insert
  (p_assignment_id         IN     per_assignments_f.assignment_id%TYPE
  ,p_placement_id          IN     per_spinal_point_placements_f.placement_id%TYPE
  ,p_validation_start_date IN     DATE
  ,p_validation_end_date   IN     DATE
  ,p_spp_eff_start_date    IN     DATE
  ,p_datetrack_mode        IN OUT NOCOPY VARCHAR2
  ,p_object_version_number IN OUT NOCOPY NUMBER) IS
  --
  -- Declare Local Variables
  --
  l_proc                  VARCHAR2(72) := g_package||'spp_update_change_insert';
  l_effective_start_date  DATE;
  l_effective_end_date    DATE;
  l_datetrack_mode        VARCHAR2(30);
  l_object_version_number per_spinal_point_placements_f.object_version_number%TYPE;
  l_dummy_id              per_spinal_point_placements_f.placement_id%TYPE;
  --
  -- Checks to see if future rows exist
  --
  CURSOR csr_future_records IS
  	 SELECT spp.placement_id
	   FROM   per_spinal_point_placements_f spp
	   WHERE  spp.assignment_id = p_assignment_id
	   AND    spp.effective_start_date > p_validation_start_date;
  --
  --
  -- Cursor used to retrieve all SPP records for an
  -- grade when performing an update_change_insert.
  --
  CURSOR csr_update_change_insert_rows IS
    SELECT spp.placement_id,
           spp.object_version_number,
           spp.effective_start_date
    FROM   per_spinal_point_placements_f spp
    WHERE  effective_start_date BETWEEN p_spp_eff_start_date
                                    AND p_validation_end_date
    AND    effective_end_date < p_validation_end_date
    AND    assignment_id = p_assignment_id
    ORDER BY effective_start_date DESC;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  l_datetrack_mode        := p_datetrack_mode;
  l_object_version_number := p_object_version_number;
  --
  -- Check for future dated SPP records.
  --
  OPEN  csr_future_records;
  FETCH csr_future_records INTO l_dummy_id;
  --
  IF csr_future_records%FOUND THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    -- Loop through all SPP records that are linked to the
    -- assignment between the assignment record start and end
    -- date and perform a DELETE_NEXT_CHANGE on these records.
    --
    -- Update Change Insert
    --      Gr3
    --       |
    --       |
    --         Gr1            Gr2           Gr3
    --ASG |-------------|-------------|------------>
    --       1    2    3       4             8
    --SPP |----|-----|--|-------------|------------>
    --
    -- BECOMES
    --
    --     Gr1   Gr3          Gr2           Gr3
    --ASG |--|----------|-------------|------------>
    --     1       8           4             8
    --SPP |--|----------|-------------|------------>
    --
    -- The FOR LOOP below will perform a DELETE_NEXT_CHANGE
    -- on SPP records 2 then 1, so that SPP 1 record will match
    -- the assignment start and end dates. An
    -- UPDATE_CHANGE_INSERT will then be performed on SPP 1
    -- record to insert SPP 8. THis update will be done in the
    -- maintain_spp_asg procedure.
    --
    FOR c1_rec IN csr_update_change_insert_rows LOOP
      --
      hr_utility.set_location(l_proc||'/'||c1_rec.object_version_number,30);
      hr_utility.set_location(l_proc||'/'||c1_rec.effective_start_date,31);
      --
      l_object_version_number := c1_rec.object_version_number;
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date		       => c1_rec.effective_start_date
        ,p_datetrack_mode	       	=> hr_api.g_delete_next_change
        ,p_placement_id		         => p_placement_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
      --
    END LOOP;
    --
    -- Check if the step placement record starts on the same day
    -- as the updated assignment record. If it does then change
    -- the date track mode to Correction.
    --
    IF p_spp_eff_start_date = p_validation_start_date THEN
      --
      hr_utility.set_location(l_proc,40);
      --
      l_datetrack_mode := 'CORRECTION';
      --
    ELSE
      --
      hr_utility.set_location(l_proc,50);
      --
      l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
      --
    END IF;
  --
  -- If no future records have been found then
  -- set the datetrack mode
  --
  ELSE
    --
    hr_utility.set_location(l_proc,60);
    --
    -- Check if the step placement record starts on the same
    -- day as the updated assignment record. If it does then change
    -- the date track mode to Correction.
    --
    IF p_spp_eff_start_date = p_validation_start_date THEN
      --
      hr_utility.set_location(l_proc,70);
      --
      l_datetrack_mode := 'CORRECTION';
      --
    ELSE
      --
      hr_utility.set_location(l_proc,80);
      --
      l_datetrack_mode := 'UPDATE';
      --
    END IF;
    --
    CLOSE csr_future_records;
    --
  END IF; -- csr_future_records%found
  --
  -- Set Out parameters
  --
  p_object_version_number := l_object_version_number;
  p_datetrack_mode        := l_datetrack_mode;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
END spp_update_change_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHECK_VALID_PLACEMENT >------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_valid_placement_id
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id           in  per_spinal_point_placements_f.placement_id%Type
   ,p_validation_start_date  in  date) is
   --
   -- Local variables
   l_exist                   varchar2(1);
   --
   l_proc                    varchar(72) := g_package||'chk_valid_placement_id';
   -- Fetch future SPP Records(other placement id)
   cursor csr_invalid_placement_id is
          select 'Y'
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.effective_start_date > p_validation_start_date
          and    spp.placement_id <> p_placement_id;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- If there are future SPP records that have
   -- a different placement id then raise an error
   open csr_invalid_placement_id;
   fetch csr_invalid_placement_id into l_exist;
   if csr_invalid_placement_id%found then
      --
      close csr_invalid_placement_id;
      --
      hr_utility.set_message(800, 'HR_289827_SPP_FUTURE_SPP_REC');
      hr_utility.raise_error;
      --
   else
      --
      close csr_invalid_placement_id;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< CLEANUP_SPP >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure cleanup_spp
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode         in  varchar2
   ,p_validation_start_date  in  date
   ,p_del_end_future_spp     in  out nocopy boolean) is
   --
   -- Local variables
   l_old_grade_id            per_grade_spines_f.grade_id%Type;
   --
   l_proc                    varchar(72) := g_package||'cleanup_spp';
   -- Cursor to retrive the assignment records
   cursor csr_asg_details is
          select paa.effective_start_date,
                 paa.effective_end_date,
                 paa.grade_id
          from   per_all_assignments_f paa
          where  paa.assignment_id = p_assignment_id
          and    paa.effective_end_date >= p_validation_start_date - 1
          order  by paa.effective_start_date;
   -- Cursor to retrive the spp records for the assignment record for with
   -- there is no Grade attached (if any)
   cursor csr_asg_spp(l_asg_eff_start_date date, l_asg_eff_end_date date) is
          select spp.placement_id,
                 spp.object_version_number,
                 spp.effective_start_date,
                 spp.effective_end_date
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.effective_start_date >= l_asg_eff_start_date
          and    spp.effective_end_date <= l_asg_eff_end_date;
   -- Cursor to retrive the SPP records without a valid Grade
   cursor csr_spp_placement(l_asg_eff_start_date date, l_asg_eff_end_date date) is
          select pgs.grade_id,
                 spp.placement_id,
                 spp.effective_start_date,
                 spp.effective_end_date
          from   per_grade_spines_f pgs,
                 per_spinal_point_steps_f sps,
                 per_spinal_point_placements_f spp
          where  sps.grade_spine_id = pgs.grade_spine_id
          and    spp.step_id = sps.step_id
          and    pgs.parent_spine_id = spp.parent_spine_id
          and    spp.assignment_id = p_assignment_id
          and    spp.effective_start_date >= l_asg_eff_start_date
          and    spp.effective_end_date <= l_asg_eff_end_date;
   -- Cursor to get the future SPP records, with effective_start_date >
   -- validation_start_date and effective_end_date is > validation_end_date
   cursor csr_asg_spp_error(l_asg_eff_start_date date, l_asg_eff_end_date date) is
          select pgs.grade_id
          from   per_grade_spines_f pgs,
                 per_spinal_point_steps_f sps,
                 per_spinal_point_placements_f spp
          where  sps.grade_spine_id = pgs.grade_spine_id
          and    spp.step_id = sps.step_id
          and    pgs.parent_spine_id = spp.parent_spine_id
          and    spp.assignment_id = p_assignment_id
          and    spp.effective_start_date between l_asg_eff_start_date
          and    l_asg_eff_end_date
          and    spp.effective_end_date > l_asg_eff_end_date;
   -- Cursor to check any SPP record is existing from the validation start date
   -- If any such SPP record is existing, then we need to delete that records
   cursor csr_spp_records is
          select spp.placement_id,
                 spp.effective_start_date,
                 spp.effective_end_date
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.effective_start_date >= p_validation_start_date;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- All Non valid future SPP records needs to be deleted(if any)
   for csr_asg_rec in csr_asg_details loop
      -- If Grade Id is already set to Null then we should delete the corresponding
      -- Grade Step records.
      if csr_asg_rec.grade_id is null then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 20);
         end if;
         -- Needs to be deleted all non valid SPP records
         for asg_spp_rec in csr_asg_spp(csr_asg_rec.effective_start_date,
                                        csr_asg_rec.effective_end_date) loop
            -- There are some SPP records existing for this assignment without a Grade.
            delete from  per_spinal_point_placements_f spp
                   where spp.placement_id = asg_spp_rec.placement_id
                   and   spp.effective_start_date = asg_spp_rec.effective_start_date
                   and   spp.effective_end_date = asg_spp_rec.effective_end_date;
            --
            if g_debug then
               hr_utility.set_location(l_proc, 30);
            end if;
            -- Setting the warning parameter
            p_del_end_future_spp := true;
            --
         end loop;
         -- Grade is attached, but a placement is existing for an invalid Grade
         -- during this assignment period, then that SPP record needs to be deleted.
      else
         for rec_spp_placement in csr_spp_placement(csr_asg_rec.effective_start_date,
                                                    csr_asg_rec.effective_end_date) loop
            -- Placement is with an invalid Grade, whcih needs to be deleted
            if g_debug then
               hr_utility.set_location(l_proc||' Placement Grade Id '||rec_spp_placement.grade_id , 40);
               hr_utility.set_location(l_proc||' Asg Grade Id '||csr_asg_rec.grade_id , 50);
            end if;
            if rec_spp_placement.grade_id <> csr_asg_rec.grade_id then
               --
               delete from  per_spinal_point_placements_f spp
                      where spp.placement_id = rec_spp_placement.placement_id
                      and   spp.effective_start_date = rec_spp_placement.effective_start_date
                      and   spp.effective_end_date = rec_spp_placement.effective_end_date;
               --
               if g_debug then
                  hr_utility.set_location(l_proc, 60);
               end if;
               -- Setting the warning parameter
               p_del_end_future_spp := true;
               --
            end if;
            --
         end loop;
         --
      end if;
      -- We need to verify that, any SPP record is existing during the assignment
      -- record period, and effective_start_date of that SPP record is after the
      -- validation_start_date and effective_end_date is greater than the
      -- validation_end_date, such cases we cannot perform delete next change,
      -- should display an error message and user needs to delete that SPP record
      -- through Placement form, if he wants to proceed.
      if p_datetrack_mode = hr_api.g_delete_next_change then
         --
         open csr_asg_spp_error(csr_asg_rec.effective_start_date,
                                csr_asg_rec.effective_end_date);
         fetch csr_asg_spp_error into l_old_grade_id;
         if csr_asg_spp_error%found and
            nvl(l_old_grade_id, hr_api.g_number) <>
            nvl(csr_asg_rec.grade_id, hr_api.g_number) then
            --
            close csr_asg_spp_error;
            --
            hr_utility.set_message(800, 'HR_289771_SPP_MIN_START_DATE');
            hr_utility.raise_error;
            --
         else
           --
           close csr_asg_spp_error;
           --
         end if;
         --
      end if;
      --
   end loop;
   if p_datetrack_mode in (hr_api.g_correction,
                           hr_api.g_update_change_insert) then
      --
      for spp_rec in csr_spp_records loop
         --
         delete from  per_spinal_point_placements_f spp
                where spp.placement_id = spp_rec.placement_id
                and   spp.effective_start_date = spp_rec.effective_start_date
                and   spp.effective_end_date = spp_rec.effective_end_date;
         if g_debug then
            hr_utility.set_location(l_proc, 70);
         end if;
         -- Setting the warning parameter
         p_del_end_future_spp := true;
         --
      end loop;
      --
   end if;
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end cleanup_spp;
--
-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_NEXT_CHANGE_SPP >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_next_change_spp
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id           in  per_spinal_point_placements_f.placement_id%Type
   ,p_grade_id               in  per_grade_spines_f.grade_id%Type
   ,p_datetrack_mode         in  varchar2
   ,p_validation_start_date  in  date
   ,p_validation_end_date    in  date
   ,p_del_end_future_spp     out nocopy boolean) is
   --
   -- Declare Local Variables
   l_placement_id number;
   l_datetrack_mode         varchar2(30);
   l_exists                  varchar2(1);
   l_effective_start_date    date;
   l_effective_end_date      date;
   l_del_end_future_spp      boolean := false;
   l_object_version_number   per_spinal_point_placements_f.object_version_number%Type;
   l_grade_id                per_spinal_point_placements_f.placement_id%Type;
   --
   l_proc                    varchar(72) := g_package||'delete_next_change_spp';
   -- Cursor used to retrieve all SPP records for a Grade.
   cursor csr_update_change_rows is
          select spp.placement_id,
                 spp.effective_start_date,
                 spp.effective_end_date,
                 spp.object_version_number
          from   per_spinal_point_placements_f spp
          where  spp.effective_end_date between p_validation_start_date - 1
          and    p_validation_end_date
          and    spp.effective_end_date < p_validation_end_date
          and    spp.assignment_id = p_assignment_id
          order  by spp.effective_start_date desc;
   -- Cursor to get the Grade of future SPP
   cursor csr_spp_grade is
          select pgs.grade_id
          from   per_grade_spines_f pgs,
                 per_spinal_point_steps_f sps,
                 per_spinal_point_placements_f spp
          where  sps.grade_spine_id = pgs.grade_spine_id
          and    spp.step_id = sps.step_id
          and    pgs.parent_spine_id = spp.parent_spine_id
          and    spp.assignment_id = p_assignment_id
          and    spp.effective_start_date between p_validation_start_date
                 and p_validation_end_date;
   --
   -- check if any spp is continues at the Validation End Date.
   --
   cursor csr_ved_continues_spp IS
   select spp.placement_id,spp.effective_start_date
         ,spp.effective_end_date, spp.object_version_number
   from   per_spinal_point_placements_f spp
   where  spp.assignment_id = p_assignment_id
   and    spp.effective_start_date < p_validation_end_date
   and    spp.effective_end_date > p_validation_end_date;
   --
   -- Check for future spp dt records.
   --
   cursor csr_future_spp_exists(p_date date,p_placement_id number) IS
   select 'Y'
   from   per_spinal_point_placements_f
   where  placement_id = p_placement_id
   and    effective_start_date > p_date;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- Needs to perform the delete next change operation only, if there is
   -- Grade change after the assignment level DNC. (Not null to a new not null)
   open csr_spp_grade;
   fetch csr_spp_grade into l_grade_id;
   close csr_spp_grade;
   --
   if p_grade_id <> l_grade_id then
      -- If there are future date SPP records that have
      -- a different placement id then raise an error
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      -- At validation end date check for continues placement record.
      -- If found, just break it.
      --
      hr_utility.set_location(l_proc, 30);
      open csr_ved_continues_spp;
      fetch csr_ved_continues_spp into
           l_placement_id,l_effective_start_date
          ,l_effective_end_date,l_object_version_number;
      if csr_ved_continues_spp%found then
        --
        --
        l_datetrack_mode := hr_api.g_update;
        --
        open csr_future_spp_exists(p_validation_end_date,l_placement_id);
        fetch csr_future_spp_exists into l_exists;
        if csr_future_spp_exists%found then
          --
          l_datetrack_mode := hr_api.g_update_change_insert;
          --
        end if;
        --
        close csr_future_spp_exists;
        --
        -- continues placement record found on validation end date.
        -- Therefore simply break it on validation end date.
        --
        hr_utility.set_location('ved spp found', 40);
        hr_utility.set_location('dt mode :'||l_datetrack_mode, 40);
        hr_sp_placement_api.update_spp(
          p_effective_date        => p_validation_end_date+1
         ,p_datetrack_mode        => l_datetrack_mode
         ,p_placement_id          => l_placement_id
         ,p_object_version_number => l_object_version_number
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date);
        --
      end if;
      close csr_ved_continues_spp;
      --
      chk_valid_placement_id(p_assignment_id         => p_assignment_id
                            ,p_placement_id          => p_placement_id
                            ,p_validation_start_date => p_validation_start_date);
      --
      for csr_rec in csr_update_change_rows loop
         --
         if g_debug then
            hr_utility.set_location(l_proc||'/'||csr_rec.object_version_number, 30);
            hr_utility.set_location(l_proc||'/'||csr_rec.effective_start_date, 40);
            hr_utility.set_location(l_proc||'/'||csr_rec.effective_end_date, 50);
            hr_utility.set_location(l_proc||'/'||csr_rec.placement_id, 60);
         end if;
         --
         if p_validation_end_date > csr_rec.effective_end_date and
            csr_rec.effective_end_date <> hr_api.g_eot then
            --
            l_object_version_number := csr_rec.object_version_number;
            hr_sp_placement_api.delete_spp(
                        p_effective_date        => csr_rec.effective_start_date
                       ,p_datetrack_mode        => hr_api.g_delete_next_change
                       ,p_placement_id          => csr_rec.placement_id
                       ,p_object_version_number => l_object_version_number
                       ,p_effective_start_date  => l_effective_start_date
                       ,p_effective_end_date    => l_effective_end_date);
            --
            l_del_end_future_spp := true;
            --
            if g_debug then
               hr_utility.set_location(l_proc, 70);
            end if;
            --
         end if;
         --
      end loop;
      --
   end if;
   -- Cleanup of all invalid steps(if any)
   cleanup_spp(p_assignment_id         => p_assignment_id
              ,p_datetrack_mode        => p_datetrack_mode
              ,p_validation_start_date => p_validation_start_date
              ,p_del_end_future_spp    => l_del_end_future_spp);
   -- Setting the out parameter
   p_del_end_future_spp := l_del_end_future_spp;
   --
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end delete_next_change_spp;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< FUTURE_CHANGE_SPP >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure future_change_spp
   (p_assignment_id         in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id          in  per_spinal_point_placements_f.placement_id%Type
   ,p_datetrack_mode        in  varchar2
   ,p_validation_start_date in  date
   ,p_del_end_future_spp    out nocopy boolean) is
   --
   -- Local variables
   l_spp_eff_start_date     date;
   l_spp_eff_end_date       date;
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_del_end_future_spp     boolean := false;
   l_placement_id           per_spinal_point_placements_f.placement_id%Type;
   l_object_version_number  per_spinal_point_placements_f.object_version_number%Type;
   --
   l_proc                   varchar2(72) := g_package||'future_change_spp';
   -- As the validation start and end dates are for the asg row being
   -- deleted, then we need to get the SPP record that belongs to the
   -- previous date tracked row.
   cursor csr_spp_details is
          select spp.placement_id,
                 spp.object_version_number,
                 spp.effective_start_date,
                 spp.effective_end_date
          from   per_spinal_point_placements_f  spp
          where  spp.assignment_id =  p_assignment_id
          and    spp.effective_start_date < p_validation_start_date
          order  by effective_start_date desc;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- Check for the uniqueness of Step placement id
   chk_valid_placement_id(p_assignment_id         => p_assignment_id
                         ,p_placement_id          => p_placement_id
                         ,p_validation_start_date => p_validation_start_date);
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   -- Check that there has been a grade step created for this assignment
   open  csr_spp_details;
   fetch csr_spp_details into l_placement_id
                             ,l_object_version_number
                             ,l_spp_eff_start_date
                             ,l_spp_eff_end_date;
   -- If the are SPP records for the assignment then
   -- perform a DT FUTURE_CHANGE on the current spp_row.
   -- We can perform a FUTURE_CHANGE operation on SPP records only if,
   -- a) Current effective records effective_end_date is NOT EOT and
   -- b) p_validation_end_date is NOT less than or equal to current
   --    effective_end_date of SPP record.
   if csr_spp_details%found  and
      l_spp_eff_end_date <> hr_api.g_eot then
      --
      hr_sp_placement_api.delete_spp(
                     p_effective_date         => l_spp_eff_start_date
                    ,p_datetrack_mode         => p_datetrack_mode
                    ,p_placement_id           => l_placement_id
                    ,p_object_version_number  => l_object_version_number
                    ,p_effective_start_date   => l_effective_start_date
                    ,p_effective_end_date     => l_effective_end_date);
      --
      l_del_end_future_spp := true;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
   end if;
   --
   close csr_spp_details;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 40);
   end if;
   -- Cleanup of all invalid steps(if any)
      cleanup_spp(p_assignment_id         => p_assignment_id
                 ,p_datetrack_mode        => p_datetrack_mode
                 ,p_validation_start_date => p_validation_start_date
                 ,p_del_end_future_spp    => l_del_end_future_spp);
   -- Setting the out parameter
   p_del_end_future_spp := l_del_end_future_spp;
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end future_change_spp;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_OVERRIDE_SPP >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_override_spp
   (p_assignment_id         in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id          in  per_spinal_point_placements_f.placement_id%Type
   ,p_datetrack_mode        in  varchar2
   ,p_validation_start_date in  date
   ,p_validation_end_date   in  date
   ,p_spp_eff_start_date    in  date
   ,p_grade_id              in  number
   ,p_step_id               in  number
   ,p_object_version_number in  number
   ,p_current_spp_exist     in  boolean
   ,p_pay_scale_defined     in  boolean
   ,p_del_end_future_spp    out nocopy boolean) is
   --
   -- declare local variables
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_max_eff_end_date       date;
   l_grade_id               number;
   l_datetrack_mode         varchar2(30);
   l_del_end_future_spp     boolean := false;
   l_dummy_id               per_spinal_point_placements_f.placement_id%Type;
   l_previous_ovn           per_spinal_point_placements_f.object_version_number%Type;
   l_object_version_number  per_spinal_point_placements_f.object_version_number%Type
                            := p_object_version_number;
   --
   l_proc                   varchar2(72) := g_package||'update_override_spp';
   -- Assignment record is already updated with UPDATE_OVERRIDE DT Mode
   -- We need to get the previous assignment record to check whether any
   -- Grade changes is happend in this DT UPDATE_OVERRIDE
   cursor csr_asg_details is
          select paa.grade_id
          from   per_all_assignments_f paa
          where  paa.assignment_id = p_assignment_id
          and    p_validation_start_date - 1 between paa.effective_start_date
          and    paa.effective_end_date
          order  by paa.effective_start_date;
  -- Checks to see if any future Grade Step rows exist for the given assignment
  cursor csr_future_records is
         select spp.placement_id
         from   per_spinal_point_placements_f spp
         where  spp.assignment_id = p_assignment_id
         and    spp.effective_start_date > p_validation_start_date;
  -- Cursor to retrive the past SPP record to perform
  -- DELETE_NEXT_CHANGE
  cursor csr_past_spp_details(l_placement_id in number) is
         select spp.object_version_number,
                spp.effective_start_date,
                spp.effective_end_date
         from   per_spinal_point_placements_f spp
         where  spp.placement_id = l_placement_id
         and    p_validation_start_date - 1 between spp.effective_start_date
         and    spp.effective_end_date;
  -- Cursor to see if any past Grade Step rows exist for thie given assignment.
  cursor csr_past_spp_records(l_placement_id in number) is
         select spp.object_version_number
         from   per_spinal_point_placements_f spp
         where  spp.placement_id = l_placement_id
         and    spp.effective_start_date < p_validation_start_date
         order  by effective_start_date desc;
  -- Cursor used to retrieve all SPP records for a Grade
  cursor csr_update_change_rows is
         select spp.object_version_number,
                spp.effective_start_date
         from   per_spinal_point_placements_f spp
         where  spp.effective_start_date between p_spp_eff_start_date
         and    p_validation_end_date
         and    spp.effective_end_date < p_validation_end_date
         and    spp.assignment_id = p_assignment_id
         order  by spp.effective_start_date desc;
  --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- Assignment record is having some SPP records for this DT period
   if p_current_spp_exist then
      -- If the assignemnt record is having a Grade and that Grade has a Pay Scale
      -- already defined. Or no changes in Grade Information for the new
      -- datetracked assgt record
      -- If the Pay Scale is not defined for the new Grade or the user is setting the
      -- Grade to Null
      -- Check for the uniqueness of Step placement id
      chk_valid_placement_id(p_assignment_id         => p_assignment_id
                            ,p_placement_id          => p_placement_id
                            ,p_validation_start_date => p_validation_start_date);
      --
      if p_pay_scale_defined then
         --
         open csr_asg_details;
         fetch csr_asg_details into l_grade_id;
         --
         if csr_asg_details%found then
            --
            close csr_asg_details;
            -- Here both values must be not null (only that case will come
            -- to this IF condition)
            -- User is swapping the Grade with a New Grade
            if p_grade_id <> l_grade_id then
               --
               if g_debug then
                  hr_utility.set_location(l_proc, 20);
               end if;
               --
               open csr_future_records;
               fetch csr_future_records into l_dummy_id;
               if csr_future_records%found then
                  -- As future records are existing, we can perform an UPDATE_OVERRIDE
                  l_datetrack_mode := p_datetrack_mode;
                  --
                  if g_debug then
                     hr_utility.set_location(l_proc||' /l_datetrack_mode '||l_datetrack_mode, 30);
                     hr_utility.set_location(l_proc, 40);
                  end if;
                  --
               else
                  -- As there is no future records are existing.
                  -- We need to end date the current record and create a new DT record
                  -- with the new Grade
                  -- Performing a DT UPDATE
                  l_datetrack_mode := hr_api.g_update;
                  if g_debug then
                     hr_utility.set_location(l_proc||' /l_datetrack_mode '||l_datetrack_mode, 50);
                     hr_utility.set_location(l_proc, 60);
                  end if;
                 --
               end if;
               --
               close csr_future_records;
               --
               hr_sp_placement_api.update_spp(
                                 p_effective_date        => p_validation_start_date
                                ,p_datetrack_mode        => l_datetrack_mode
                                ,p_placement_id          => p_placement_id
                                ,p_object_version_number => l_object_version_number
                                ,p_step_id               => p_step_id
                                ,p_auto_increment_flag   => 'N'
                                ,p_reason                => ''
                                ,p_increment_number      => NULL
                                ,p_effective_start_date  => l_effective_start_date
                                ,p_effective_end_date    => l_effective_end_date);
               -- Setting the warning parameter
               l_del_end_future_spp := true;
               --
               if g_debug then
                  hr_utility.set_location(l_proc, 70);
               end if;
               -- No change in Grade
            else
               -- Needs to check if any future records are existing for the SPP records
               -- If there is no future records, then we cannot perfom an UPDATE_OVERRIDE
               -- as there is no future records to be overridden
               --
               open csr_future_records;
               fetch csr_future_records into l_dummy_id;
               if csr_future_records%found then
                  -- Since future records are existing then perfom an UPDATE_OVERRIDE
                  if g_debug then
                     hr_utility.set_location(l_proc||' /p_datetrack_mode '||p_datetrack_mode, 80);
                  end if;
                  -- As future records existing for the current SPP. And if the SPP
                  -- effective start date and validation start date are same, then we
                  -- cannot perform a DT UPDATE_OVERRIDE.
                  if p_validation_start_date = p_spp_eff_start_date then
                     --
                     for csr_rec in csr_update_change_rows loop
                        --
                        if g_debug then
                           hr_utility.set_location(l_proc||'/'||csr_rec.object_version_number, 90);
                           hr_utility.set_location(l_proc||'/'||csr_rec.effective_start_date, 100);
                        end if;
                        l_object_version_number := csr_rec.object_version_number;
                        hr_sp_placement_api.delete_spp(
                              p_effective_date        => csr_rec.effective_start_date
                             ,p_datetrack_mode        => hr_api.g_delete_next_change
                             ,p_placement_id          => p_placement_id
                             ,p_object_version_number => l_object_version_number
                             ,p_effective_start_date  => l_effective_start_date
                             ,p_effective_end_date    => l_effective_end_date);
                        -- Setting the warning parameter
                        l_del_end_future_spp := true;
                        --
                        if g_debug then
                           hr_utility.set_location(l_proc, 110);
                        end if;
                        --
                     end loop;
                     --
                  else
                     -- Normal case, performing UPDATE_OVERRIDE
                     hr_sp_placement_api.update_spp(
                                 p_effective_date        => p_validation_start_date
                                ,p_datetrack_mode        => p_datetrack_mode
                                ,p_placement_id          => p_placement_id
                                ,p_object_version_number => l_object_version_number
                                ,p_step_id               => p_step_id
                                ,p_auto_increment_flag   => 'N'
                                ,p_reason                => ''
                                ,p_increment_number      => NULL
                                ,p_effective_start_date  => l_effective_start_date
                                ,p_effective_end_date    => l_effective_end_date);
                     -- Setting the warning parameter
                     l_del_end_future_spp := true;
                     --
                     if g_debug then
                        hr_utility.set_location(l_proc, 120);
                     end if;
                     -- We need to do extra process if the DT Mode is UPDATE_OVERRIDE
                     -- Update SPP API will end date the current record with
                     -- p_validation_start_date - 1 and insert a new record. Then the same
                     -- placement will be repeating twice with a different datetrack period
                     -- We need to combine these records.
                     for rec_past_spp in csr_past_spp_details(l_placement_id => p_placement_id) loop
                        --
                        if rec_past_spp.effective_end_date <> hr_api.g_eot then
                           l_object_version_number := rec_past_spp.object_version_number;
                           hr_sp_placement_api.delete_spp(
                                 p_effective_date        => p_validation_start_date - 1
                                ,p_datetrack_mode        => hr_api.g_delete_next_change
                                ,p_placement_id          => p_placement_id
                                ,p_object_version_number => l_object_version_number
                                ,p_effective_start_date  => l_effective_start_date
                                ,p_effective_end_date    => l_effective_end_date);
                           if g_debug then
                              hr_utility.set_location(l_proc, 130);
                           end if;
                           --
                        end if;
                        --
                     end loop;
                     --
                  end if;
                  --
               end if;
               --
               close csr_future_records;
               --
            end if; -- End of Grade change check
            --
         end if; -- End of assignment details found
         --
         if csr_asg_details%isopen then close csr_asg_details; end if;
         --
      else
         --
         open  csr_past_spp_records(l_placement_id => p_placement_id);
         fetch csr_past_spp_records into l_previous_ovn;
         if csr_past_spp_records%found then
            --
            if g_debug then
               hr_utility.set_location(l_proc, 140);
               hr_utility.set_location(l_proc||' ovn  ='||l_previous_ovn, 150);
            end if;
            hr_sp_placement_api.delete_spp(
                        p_effective_date        => p_validation_start_date - 1
                       ,p_datetrack_mode        => hr_api.g_delete
                       ,p_placement_id          => p_placement_id
                       ,p_object_version_number => l_previous_ovn
                       ,p_effective_start_date  => l_effective_start_date
                       ,p_effective_end_date    => l_effective_end_date);
            -- Setting the warning parameter
            l_del_end_future_spp := true;
            if g_debug then
               hr_utility.set_location(l_proc, 160);
            end if;
            --
         end if;
         --
         close csr_past_spp_records;
         --
      end if; -- End of Pay Scale defined check
      --
   end if; -- End of current SPP exists
   --
   -- Cleanup of all invalid steps(if any)
   cleanup_spp(p_assignment_id         => p_assignment_id
              ,p_datetrack_mode        => p_datetrack_mode
              ,p_validation_start_date => p_validation_start_date
              ,p_del_end_future_spp    => l_del_end_future_spp);
   -- Setting the out parameter
   p_del_end_future_spp := l_del_end_future_spp;
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 999);
   end if;
   --
end update_override_spp;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CLOSE_SPP_RECORDS >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure close_spp_records
   (p_assignment_id          in  per_all_assignments_f.assignment_id%Type
   ,p_placement_id           in  per_spinal_point_placements_f.placement_id%Type
   ,p_datetrack_mode         in  varchar2
   ,p_validation_start_date  in  date
   ,p_object_version_number  in  number
   ,p_current_spp_exist      in  boolean
   ,p_del_end_future_spp     out nocopy boolean) is
   --
   -- Declare Local Variables
   l_effective_start_date    date;
   l_effective_end_date      date;
   l_del_end_future_spp      boolean := false;
   l_dummy_id                per_spinal_point_placements_f.placement_id%Type;
   l_object_version_number   per_spinal_point_placements_f.object_version_number%Type
                             := p_object_version_number;
   --
   l_proc                    varchar(72) := g_package||'close_spp_records';
   -- Checks to see if future rows exist for the Placement_id.
   cursor csr_spp_future_records is
          select spp.placement_id
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.placement_id = p_placement_id
          and    spp.effective_start_date > p_validation_start_date;
   -- Cursor to see if any past Grade Step rows exist for thie given assignment.
   cursor csr_past_spp_records is
          select spp.object_version_number
          from   per_spinal_point_placements_f spp
          where  spp.placement_id = p_placement_id
          and    spp.effective_start_date < p_validation_start_date
          order  by effective_start_date desc;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   -- Assignment record is having some SPP records for this DT period
   if p_current_spp_exist then
      -- Check for the uniqueness of Step placement id
      chk_valid_placement_id(p_assignment_id         => p_assignment_id
                            ,p_placement_id          => p_placement_id
                            ,p_validation_start_date => p_validation_start_date);
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      -- Check for future records SPP records if any for the same placement id
      open csr_spp_future_records;
      fetch csr_spp_future_records into l_dummy_id;
      if csr_spp_future_records%found then
         if g_debug then
            hr_utility.set_location(l_proc, 30);
         end if;
         -- If the future SPP changes are existing after the validation_start_date
         -- then we need to delete all future changes
         hr_sp_placement_api.delete_spp(
               p_effective_date        => p_validation_start_date
              ,p_datetrack_mode        => hr_api.g_future_change
              ,p_placement_id          => p_placement_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_start_date  => l_effective_start_date
              ,p_effective_end_date    => l_effective_end_date);
         -- Setting the warning parameter
         l_del_end_future_spp := true;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
      end if;
      --
      close csr_spp_future_records;
      -- End dating the existing Grade step placement
      open  csr_past_spp_records;
      fetch csr_past_spp_records into l_object_version_number;
      if csr_past_spp_records%found then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 50);
            hr_utility.set_location(l_proc||' ovn  ='||l_object_version_number, 60);
         end if;
         --
         hr_sp_placement_api.delete_spp(
               p_effective_date        => p_validation_start_date - 1
              ,p_datetrack_mode        => hr_api.g_delete
              ,p_placement_id          => p_placement_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_start_date  => l_effective_start_date
              ,p_effective_end_date    => l_effective_end_date);
         -- Setting the warning parameter
         l_del_end_future_spp := true;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 70);
         end if;
         --
      end if;
      --
   end if;
   -- Cleanup of all invalid steps(if any)
   cleanup_spp(p_assignment_id         => p_assignment_id
              ,p_datetrack_mode        => p_datetrack_mode
              ,p_validation_start_date => p_validation_start_date
              ,p_del_end_future_spp    => l_del_end_future_spp);
   -- Setting the out parameter
   p_del_end_future_spp := l_del_end_future_spp;
   --
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end close_spp_records;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CORRECTION_SPP >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure correction_spp(
                     p_assignment_id  number
                    ,p_placement_id number
                    ,p_grade_id number
                    ,p_min_step_id  number
                    ,p_validation_start_date date
                    ,p_validation_end_date    date
                    ,p_del_end_future_spp in out nocopy  boolean  ) IS
   --
   -- Local variables
   --
   l_placement_id number;
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_effective_date         date;
   l_datetrack_mode         varchar2(30);
   l_del_end_future_spp     boolean := false;
   l_object_version_number  per_spinal_point_placements_f.object_version_number%Type;
   l_vsd_continues_spp_exists boolean :=false;
   l_ved_continues_spp_exists boolean :=false;
   l_min_step_id number;
   l_exists varchar2(1);
   --
   l_proc                   varchar2(72) := g_package||'correction_spp';
   --
   -- check if any spp is continues at the Validation Start Date.
   --
   cursor csr_vsd_continues_spp IS
   select spp.placement_id,spp.effective_start_date
         ,spp.effective_end_date, spp.object_version_number
   from   per_spinal_point_placements_f spp
   where  spp.assignment_id = p_assignment_id
   and    spp.effective_start_date < p_validation_start_date
  -- and    spp.effective_end_date > p_validation_start_date;
   and    spp.effective_end_date >= p_validation_start_date;-- fix for the bug5203227
   --
   -- check if any spp is continues at the Validation End Date.
   --
   cursor csr_ved_continues_spp IS
   select spp.placement_id,spp.effective_start_date
         ,spp.effective_end_date, spp.object_version_number
   from   per_spinal_point_placements_f spp
   where  spp.assignment_id = p_assignment_id
   and    spp.effective_start_date < p_validation_end_date
   and    spp.effective_end_date > p_validation_end_date;
   --
   -- select the placement records in the validation period.
   --
   cursor csr_spps_in_validation_period IS
   select spp.placement_id,spp.effective_start_date
         ,spp.effective_end_date, spp.object_version_number
   from   per_spinal_point_placements_f spp
   where  spp.assignment_id = p_assignment_id
   and    spp.effective_start_date between p_validation_start_date and p_validation_end_date
   order by effective_end_date;
   --
   cursor csr_next_spp(p_date date) IS
   select placement_id, effective_start_date,
                        effective_end_date, object_version_number
   from   per_spinal_point_placements_f
   where  placement_id = p_placement_id
  -- and    effective_start_date >= p_date;--fix for bug 5067855 .
   and    effective_start_date = p_date; -- fix for the bug 5306697 .
   --
   -- Check for future spp dt records.
   --
   cursor csr_future_spp_exists(p_date date) IS
   select 'Y'
   from   per_spinal_point_placements_f
   where  placement_id = p_placement_id
   and    effective_start_date > p_date;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering : '||l_proc, 10);
   end if;
   --
   l_min_step_id := p_min_step_id;
   --
   open csr_ved_continues_spp;
   fetch csr_ved_continues_spp into
       l_placement_id,l_effective_start_date
      ,l_effective_end_date,l_object_version_number;
   if csr_ved_continues_spp%found then
     --
     --
     l_datetrack_mode := hr_api.g_update;
     --
     open csr_future_spp_exists(p_validation_end_date);
     fetch csr_future_spp_exists into l_exists;
     if csr_future_spp_exists%found then
       --
       l_datetrack_mode := hr_api.g_update_change_insert;
       --
     end if;
     --
     close csr_future_spp_exists;

     -- continues placement record found on validation end date.
     -- Therefore simply break it on validation end date.
     --
     hr_utility.set_location('ved spp found', 20);
     hr_utility.set_location('dt mode :'||l_datetrack_mode, 20);
     --
     l_del_end_future_spp := TRUE;
     --
     hr_sp_placement_api.update_spp(
            p_effective_date        => p_validation_end_date+1
           ,p_datetrack_mode        => l_datetrack_mode
           ,p_placement_id          => l_placement_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);
     --
   end if;
   close csr_ved_continues_spp;
   --
   open csr_vsd_continues_spp;
   fetch csr_vsd_continues_spp into
       l_placement_id,l_effective_start_date
      ,l_effective_end_date,l_object_version_number;
   if csr_vsd_continues_spp%found then
     --
     --
     l_datetrack_mode := hr_api.g_update;
     --
     open csr_future_spp_exists(p_validation_start_date);
     fetch csr_future_spp_exists into l_exists;
     if csr_future_spp_exists%found then
       --
       l_datetrack_mode := hr_api.g_update_change_insert;
       --
     end if;
     --
     close csr_future_spp_exists;
     --
     -- continues placement record found on validation start date.
     -- Therefore simply break it on validation start date.
     --
     hr_utility.set_location('vsd spp found', 20);
     hr_utility.set_location('dt mode :'||l_datetrack_mode, 20);
     --
     l_del_end_future_spp := TRUE;
     --
     hr_sp_placement_api.update_spp(
            p_effective_date        => p_validation_start_date
           ,p_datetrack_mode        => l_datetrack_mode
           ,p_placement_id          => l_placement_id
           ,p_step_id               => l_min_step_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);
     --
   end if;
   close csr_vsd_continues_spp;
   --
   -- Check for the uniqueness of Step placement id
   --
   chk_valid_placement_id(p_assignment_id         => p_assignment_id
                         ,p_placement_id          => p_placement_id
                         ,p_validation_start_date => p_validation_start_date);
   --
   hr_utility.set_location(l_proc,30);
   -- Now starting from the first spp record in the validation period, perform
   -- DELETE-NEXT-CHANGE to make all the spp records in the validation
   -- period as a single record.
   --
   -- Get the first record details in the validation period.
   --
   hr_utility.set_location('l_effective_start_date'||l_effective_start_date,399);
   --
  --fix for bug 5067855 starts here.

   open csr_next_spp(p_validation_start_date);

   LOOP
   fetch csr_next_spp into l_placement_id, l_effective_start_date,
                           l_effective_end_date, l_object_version_number;

       hr_utility.set_location(l_proc,40);
       hr_utility.set_location('l_object_version_number'||l_object_version_number,199);
       hr_utility.set_location('l_effective_start_date'||l_effective_start_date,199);
       hr_utility.set_location('l_effective_end_date'||l_effective_end_date,199);

     if (l_effective_end_date >= p_validation_end_date or csr_next_spp%notfound ) then
       --
          hr_utility.set_location(l_proc,50);
	  close csr_next_spp;
       exit;
       --
     end if;

     --fix for bug 5067855 ends here.
     --
     -- For further safety, perform the DNC only when the spp eed is
     -- less than the validation end date.
     --
        hr_utility.set_location(l_proc,60);
     if l_effective_end_date < p_validation_end_date then
       --
       -- ADD check to see if the SPP is not end dated in
       -- between the validation dates. DNC which will open up the end dated SPP.
       --
       hr_utility.set_location('performing delete_spp',70);
       hr_utility.set_location('l_effective_start_date'||l_effective_start_date,399);
       --
       l_effective_date := l_effective_start_date;
       hr_sp_placement_api.delete_spp(
            p_effective_date        => l_effective_date
           ,p_datetrack_mode        => hr_api.g_delete_next_change
           ,p_placement_id          => l_placement_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);
       --
       l_del_end_future_spp := TRUE;
       --
       hr_utility.set_location('l_object_version_number'||l_object_version_number,299);
       hr_utility.set_location('l_effective_start_date'||l_effective_start_date,299);
       hr_utility.set_location('l_effective_end_date'||l_effective_end_date,299);
       --
     end if;
     --
        hr_utility.set_location(l_proc,90);
   END LOOP;
   --
   -- Now, update the spp in the validation period in CORRECTION mode.
   --
   -- fix for the bug 5160851
   -- added the following if condition.
   if (l_placement_id is not null ) then
      hr_sp_placement_api.update_spp(
            p_effective_date        => p_validation_start_date
           ,p_datetrack_mode        => hr_api.g_correction
           ,p_placement_id          => l_placement_id
           ,p_step_id               => l_min_step_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);
   --
   end if;
   p_del_end_future_spp := l_del_end_future_spp;
   --
   if g_debug then
      hr_utility.set_location('Leaving  : '||l_proc, 99);
   end if;
   --
end correction_spp;
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_FUTURE_SPP_RECORDS >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_future_spp_records
  (p_assignment_id         IN per_all_assignments_f.assignment_id%TYPE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_placement_id          IN per_spinal_point_placements_f.placement_id%TYPE
  ,p_object_version_number IN per_spinal_point_placements_f.object_version_number%TYPE
  ,p_effective_date        IN DATE) IS
  --
  -- Declare Local Variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_future_spp_records';
  l_effective_date        DATE;
  l_effective_start_date  DATE;
  l_effective_end_date    DATE;
  l_previous_end_date     DATE;
  l_previous_id           per_spinal_point_placements_f.placement_id%TYPE;
  l_previous_ovn          per_spinal_point_placements_f.object_version_number%TYPE;
  l_object_version_number per_spinal_point_placements_f.object_version_number%TYPE;
  l_placement_id          per_spinal_point_placements_f.placement_id%TYPE;
  --
  -- Fetch future SPP_Records
  --
  CURSOR csr_future_spp_records IS
  SELECT spp.placement_id,
         spp.object_version_number,
         spp.effective_start_date
  FROM   per_spinal_point_placements_f spp
  WHERE  spp.assignment_id = p_assignment_id
  AND    spp.effective_start_date > p_effective_date
  AND    spp.placement_id <> p_placement_id
  ORDER BY placement_id;
  --
  -- Cursor to see if past rows exist.
  --
  CURSOR csr_past_spp_records IS
  	 SELECT spp.placement_id
	   FROM   per_spinal_point_placements_f spp
	   WHERE  spp.placement_id = p_placement_id
	   AND    spp.effective_start_date < p_effective_date;
  --
  CURSOR csr_previous_spp_record IS
    SELECT spp.object_version_number,
           spp.effective_end_date
      FROM per_spinal_point_placements_f spp
     WHERE spp.placement_id = p_placement_id
       AND spp.effective_start_date < p_effective_date
     ORDER BY spp.effective_end_date desc;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc, 10);
  --
  IF p_datetrack_mode = hr_api.g_correction THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check for previous SPP records
    --
    OPEN csr_past_spp_records;
    FETCH csr_past_spp_records INTO l_placement_id;
    --
    -- If there are no previous SPP records
    -- then ZAP the SPP record.
    --
    IF csr_past_spp_records%NOTFOUND THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      l_object_version_number := p_object_version_number;
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date		       => p_effective_date
        ,p_datetrack_mode	       	=> hr_api.g_zap
        ,p_placement_id		         => p_placement_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
    --
    -- If there are previous SPP records
    -- then perform a DT Delete.
    --
    ELSE
      --
      hr_utility.set_location(l_proc, 40);
      --
      l_object_version_number := p_object_version_number;
      --
      OPEN csr_previous_spp_record;
      FETCH csr_previous_spp_record INTO l_previous_ovn,
                                         l_previous_end_date;
      --
      hr_utility.set_location(l_proc||l_previous_ovn||'/'||l_previous_end_date, 50);
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date		       => l_previous_end_date
        ,p_datetrack_mode	       	=> hr_api.g_delete
        ,p_placement_id		         => p_placement_id
        ,p_object_version_number  => l_previous_ovn
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
      --
    END IF;
  --
  -- If datetrack mode is not CORRECTION then
  --
  ELSE
    --
    hr_utility.set_location(l_proc, 50);
    --
    l_object_version_number := p_object_version_number;
    --
    hr_sp_placement_api.delete_spp
        (p_effective_date		       => p_effective_date -1
        ,p_datetrack_mode	       	=> hr_api.g_delete
        ,p_placement_id		         => p_placement_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 60);
  --
  l_previous_id := -1;
  --
  -- Delete all future SPP records that have
  -- a different placement_id do the SPP record delete above
  --
  FOR c_future_spp IN csr_future_spp_records LOOP
    --
    hr_utility.set_location(l_proc||'/ pl_id = '||c_future_spp.placement_id, 70);
    hr_utility.set_location(l_proc||'/ ovn   = '||c_future_spp.object_version_number, 71);
    --
    -- If the record retrieved has a different placement id
    -- then perform a ZAP on this record. If the ID is the same
    -- as the previous id then do nothing as this record has already
    -- been deleted.
    --
    IF l_previous_id <> c_future_spp.placement_id THEN
      --
      hr_utility.set_location(l_proc, 80);
      --
      l_previous_id           := c_future_spp.placement_id;
      l_object_version_number := c_future_spp.object_version_number;
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date		       => c_future_spp.effective_start_date
        ,p_datetrack_mode	       	=> hr_api.g_zap
        ,p_placement_id		         => c_future_spp.placement_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_start_date	  => l_effective_start_date
        ,p_effective_end_date	    => l_effective_end_date);
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END delete_future_spp_records;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< MAINTAIN_SPP_ASG >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure maintain_spp_asg
   (p_assignment_id         in     number
   ,p_datetrack_mode        in     varchar2
   ,p_validation_start_date in     date
   ,p_validation_end_date   in     date
   ,p_grade_id              in     number
   ,p_spp_delete_warning    out    nocopy boolean) is
   --
   -- Declare local variables
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_spp_eff_start_date     date;
   l_spp_eff_end_date       date;
   l_min_spp_date           date;
   l_proc                   varchar2(72) := g_package||'maintain_spp_asg';
   l_datetrack_mode         varchar2(30);
   l_current_spp_exist      boolean := false;
   l_future_spp_exist       boolean := false;
   l_pay_scale_defined      boolean := false;
   l_placement_id           per_spinal_point_placements_f.placement_id%Type;
   l_object_version_number  per_spinal_point_placements_f.object_version_number%Type;
   l_min_step_id            per_spinal_point_steps_f.step_id%Type;
   l_grade_spine_id         per_grade_spines_f.grade_spine_id%Type;
   l_dummy_id               per_spinal_point_placements_f.placement_id%Type;
   -- This warning variable will be used, whenever system internaly delete's
   -- any future dated SPP records or End Date an SPP record whcih is having
   -- effective_end_date greater than the validation end date. This warning
   -- will be set depends on the DT Mode and the SPP records.
   l_del_end_future_spp     boolean := false;
   -- Cursor to lock all the current assignment's SPPs. Also this cursor will
   -- ensure that any SPP record is available for the current assignment.
   -- We need this check for ZAP mode, all other DT modes we need a date
   -- effective check and this will be done by cursor csr_spp_details.
   cursor csr_lock_spp_rows is
          select spp.placement_id
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          for    update nowait;
   -- Checks to see if any future Grade Step rows exist for the given assignment
   cursor csr_future_records is
          select spp.placement_id
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.effective_start_date > p_validation_start_date;
   -- Checks to see if future rows exist for the Placement_id.
   cursor csr_spp_future_records(p_placement_id number)  is
          select spp.placement_id
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id
          and    spp.placement_id = p_placement_id
          and    spp.effective_start_date > p_validation_start_date;
   -- Cursor to retrive the current Grade Step placement details
   cursor csr_spp_details is
          select spp.placement_id,
                 spp.object_version_number,
                 spp.effective_start_date,
                 spp.effective_end_date
          from   per_spinal_point_placements_f  spp
          where  spp.assignment_id = p_assignment_id
          and    p_validation_start_date between spp.effective_start_date
          and    spp.effective_end_date;
   -- Cursor to retrieve the first step (Minimum Grade Step) on the pay scale
   -- for the new grade
   cursor csr_new_grade_scale is
          select sps.step_id
          from   per_grade_spines_f pgs,
                 per_spinal_point_steps_f sps
          where  sps.grade_spine_id = pgs.grade_spine_id
          and    p_validation_start_date between sps.effective_start_date
          and    sps.effective_end_date
          and    pgs.grade_id = p_grade_id
          and    p_validation_start_date between pgs.effective_start_date
          and    pgs.effective_end_date
          and    sps.sequence in (
          select min(sps2.sequence)
          from   per_spinal_point_steps_f sps2
          where  sps2.grade_spine_id = pgs.grade_spine_id
          and    p_validation_start_date between sps2.effective_start_date
          and    sps2.effective_end_date);
   -- Cursor to check if the new Grade has been linked to a Pay Scale at any time
   cursor csr_grade_pay_scale_defined is
          select grade_spine_id
          from   per_grade_spines_f pgs
          where  grade_id = p_grade_id;
   -- Cursor to get the minimum effective_start_date of the SPP records
   cursor csr_min_spp_date is
          select min(spp.effective_start_date)
          from   per_spinal_point_placements_f spp
          where  spp.assignment_id = p_assignment_id;
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   -- Validation in addition to Table Handlers
   -- Check that all mandatory arguments are not null.
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'assignment_id',
      p_argument_value => p_assignment_id);
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'datetrack_mode',
      p_argument_value => p_datetrack_mode);
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'validation_start_date',
      p_argument_value => p_validation_start_date);
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'validation_end_date',
      p_argument_value => p_validation_end_date);
   -- Process Logic
   if g_debug then
      hr_utility.set_location(l_proc||' p_assignment_id = '||p_assignment_id, 15);
      hr_utility.set_location(l_proc||' p_datetrack_mode = '||p_datetrack_mode, 16);
      hr_utility.set_location(l_proc||' p_val_st_date = '||p_validation_start_date, 17);
      hr_utility.set_location(l_proc||' p_val_end_date = '||p_validation_end_date, 18);
   end if;
   -- Setting this variable as TRUE, because when we call SPP rhi, the validation proc
   -- per_spp_bus.chk_future_asg_changes should not be executed
   g_called_from_spp_asg := true;
   -- Obtaining Lock on datetracked instance of any SPPs associated with this
   -- assignment.
   open  csr_lock_spp_rows;
   fetch csr_lock_spp_rows into l_dummy_id;
   -- Ensuring that atleast one SPP record is available to maintain
   if csr_lock_spp_rows%found then
      --
      close csr_lock_spp_rows;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      -- DT mode ZAP needs to processed seperately. Date effective SPP records
      -- check may not be valid for all the case.
      -- If the datetrack mode is ZAP,(This DT mode is allowed only for
      -- secondary assignment) then removing all the SPP records pertaining
      -- to this assignment from the database.
      if p_datetrack_mode = hr_api.g_zap then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 30);
            hr_utility.set_location(l_proc||' DT Mode = '||p_datetrack_mode, 31);
         end if;
         --
         spp_zap (p_assignment_id => p_assignment_id);
         -- All other DT mode, Date effective check that there has been a grade step
         -- created for this assignment, Needs to maintain SPP records only if there
         -- is Grade Step for this assignment.
      else
         --
         open  csr_spp_details;
         fetch csr_spp_details into l_placement_id ,l_object_version_number
                                   ,l_spp_eff_start_date ,l_spp_eff_end_date;
         if csr_spp_details%found then
            --
            l_current_spp_exist := true;
            --
            if g_debug then
               hr_utility.set_location(l_proc||' Current SPP record exist', 32);
            end if;
            -- If there is NO current SPP records exists, then we need to
            -- check for future SPP records
         else
            --
            open csr_future_records;
            fetch csr_future_records into l_dummy_id;
            if csr_future_records%found then
               --
               l_future_spp_exist := true;
               --
               if g_debug then
                  hr_utility.set_location(l_proc||' Future SPP record exist', 33);
               end if;
              --
            end if;
            --
         end if;
         --
         if csr_future_records%isopen then close csr_future_records; end if;
         if csr_spp_details%isopen then close csr_spp_details; end if;
         -- Grade Step exists for current or future assignment then, maintain the
         -- spinal point information.
         if l_current_spp_exist or l_future_spp_exist then
            -- Checking the datetarck mode selected by the user, and performing
            -- the process accordingly
            if p_datetrack_mode = hr_api.g_delete_next_change then
               --
               delete_next_change_spp(
                      p_assignment_id         => p_assignment_id
                     ,p_placement_id          => l_placement_id
                     ,p_grade_id              => p_grade_id
                     ,p_datetrack_mode        => p_datetrack_mode
                     ,p_validation_start_date => p_validation_start_date
                     ,p_validation_end_date   => p_validation_end_date
                     ,p_del_end_future_spp    => l_del_end_future_spp);
               if g_debug then
                  hr_utility.set_location(l_proc, 60);
               end if;
               --
            elsif p_datetrack_mode = hr_api.g_future_change then
               --
               future_change_spp(
                      p_assignment_id         => p_assignment_id
                     ,p_placement_id          => l_placement_id
                     ,p_datetrack_mode        => p_datetrack_mode
                     ,p_validation_start_date => p_validation_start_date
                     ,p_del_end_future_spp    => l_del_end_future_spp);
               if g_debug then
                  hr_utility.set_location(l_proc, 80);
               end if;
               -- Needs to perform DT modes like CORRECTION, UPDATE, UPDATE_CHANGE_INSERT,
               -- UPDATE_OVERRIDE, DELETE only if there is an SPP record exist for current DT
            else
              -- If a valid new grade is passed.
              If p_grade_id is not null then
               -- Check if the new Grade has a Pay Scale defined for it

               open csr_grade_pay_scale_defined;
               fetch csr_grade_pay_scale_defined into l_grade_spine_id;
               if csr_grade_pay_scale_defined%found then
                  --
                  l_pay_scale_defined := true;
                  if g_debug then
                     hr_utility.set_location(l_proc, 100);
                  end if;
                  open csr_new_grade_scale;
                  fetch csr_new_grade_scale into l_min_step_id;
                  -- If no steps exists on the effective date then raise an error
                  if csr_new_grade_scale%notfound then
                     --
                     close csr_new_grade_scale;
                     --
                     hr_utility.set_message(800, 'HR_289829_NO_SPP_REC_FOR_EDATE');
                     hr_utility.raise_error;
                     --
                  end if;
                  --
                  close csr_new_grade_scale;
                  --
                  if g_debug then
                     hr_utility.set_location(l_proc||'/l_min_step_id = '||l_min_step_id, 250);
                  end if;
                  --
                /* else
                   --
                     hr_utility.set_message(800, 'HR_289829_NO_SPP_REC_FOR_EDATE');
                     hr_utility.raise_error;  */   /* commented for bug 6346478*/

                     --
               end if;
               --
               close csr_grade_pay_scale_defined;
               --
               End if;
               --
               if p_datetrack_mode = hr_api.g_update_override then
                  --
                  update_override_spp(
                      p_assignment_id         => p_assignment_id
                     ,p_placement_id          => l_placement_id
                     ,p_datetrack_mode        => p_datetrack_mode
                     ,p_validation_start_date => p_validation_start_date
                     ,p_validation_end_date   => p_validation_end_date
                     ,p_spp_eff_start_date    => l_spp_eff_start_date
                     ,p_grade_id              => p_grade_id
                     ,p_step_id               => l_min_step_id
                     ,p_object_version_number => l_object_version_number
                     ,p_current_spp_exist     => l_current_spp_exist
                     ,p_pay_scale_defined     => l_pay_scale_defined
                     ,p_del_end_future_spp    => l_del_end_future_spp);
                  --
               elsif p_datetrack_mode in (hr_api.g_correction,
                                          hr_api.g_update_change_insert) then
                  --
                  If p_grade_id is not null then
                     --
                     correction_spp(
                     p_assignment_id          => p_assignment_id
                    ,p_placement_id           => l_placement_id
                    ,p_grade_id               => p_grade_id
                    ,p_min_step_id            => l_min_step_id
                    ,p_validation_start_date  => p_validation_start_date
                    ,p_validation_end_date    => p_validation_end_date
                    ,p_del_end_future_spp     => l_del_end_future_spp);
                    --
                  Else
                    --
                    -- Inform user there are steps that they will have to delete before correcting.
                    --
                    hr_utility.set_message(800, 'HR_50426_REM_STEP_BEF_REM_GRD');
                    hr_utility.raise_error;
                  End if;
                  --
               elsif p_datetrack_mode = hr_api.g_update then
                  -- Check for future records SPP records if any for the same
                  -- placement id
                  open csr_spp_future_records(l_placement_id);
                  fetch csr_spp_future_records into l_dummy_id;
                  --
                  if csr_spp_future_records%found then
                     -- If the Step placement record starts on the same day
                     -- as the updated assignment record then change the
                     -- date track mode to CORRECTION
                     if l_spp_eff_start_date = p_validation_start_date then
                        -- If the future SPP changes are existing and the
                        -- validation_start_date is same as current SPP
                        -- effective_start_date, then we need to delete
                        -- all future changes
                        hr_sp_placement_api.delete_spp(
                           p_effective_date        => p_validation_start_date
                          ,p_datetrack_mode        => hr_api.g_future_change
                          ,p_placement_id          => l_placement_id
                          ,p_object_version_number => l_object_version_number
                          ,p_effective_start_date  => l_effective_start_date
                          ,p_effective_end_date    => l_effective_end_date);
                        -- Setting the warning parameter
                        l_del_end_future_spp := true;
                        --
                        if g_debug then
                           hr_utility.set_location(l_proc, 275);
                        end if;
                        l_datetrack_mode := hr_api.g_correction;
                        --
                     else
                        --
                        l_datetrack_mode := hr_api.g_update_override;
                        --
                     end if;
                     -- There are no future SPP records existing
                  else
                     -- If the step placement record starts on the same day
                     -- as the updated assignment record then change the
                     -- date track mode to CORRECTION
                     if l_spp_eff_start_date = p_validation_start_date then
                        --
                        if g_debug then
                           hr_utility.set_location(l_proc, 300);
                        end if;
                        l_datetrack_mode := hr_api.g_correction;
                        --
                     else
                        --
                        if g_debug then
                           hr_utility.set_location(l_proc, 310);
                        end if;
                        l_datetrack_mode := hr_api.g_update;
                        --
                     end if;
                     --
                  end if;
                  --
                  close csr_spp_future_records;
                  --
                  if g_debug then
                     hr_utility.set_location(l_proc||' DT Mode = '||l_datetrack_mode, 320);
                  end if;
                  --
               elsif p_datetrack_mode = hr_api.g_delete then
                  --
                  l_datetrack_mode := hr_api.g_delete;
                  --
               end if;
               --
               if p_datetrack_mode in (hr_api.g_update, hr_api.g_delete) then
                  -- Check that the effective date of the process is not less than the min
                  -- effective start date for the spp record for the assignment
                  -- If it is then the process will not be able to update the current step
                  -- as there is none so raise an error
                  open csr_min_spp_date;
                  fetch csr_min_spp_date into l_min_spp_date;
                  if l_min_spp_date > p_validation_start_date then
                     --
                     hr_utility.set_message(800, 'HR_289771_SPP_MIN_START_DATE');
                     hr_utility.raise_error;
                     --
                  end if;
                  --
                  close csr_min_spp_date;
                  --
                  -- We need to end date the existing (current) grade step information if,
                  -- 1) NO pay scale defined for the new grade (update mode)
                  -- 2) Updating the assignment grade information with a Null Grade.
                  -- 3) Hiring an applicant whose applicant assignment is not having
                  --    a grade attached and updating the primary assignment. As a result
                  --    primary assignment will get end dated and the new primary assignment
                  --    (created from applicant assignment) will not be having a grade.
                  --    In such case the previous grade step placement should get end dated.
                  if not l_pay_scale_defined and p_datetrack_mode = hr_api.g_update then
                     --
                     close_spp_records(
                                p_assignment_id         => p_assignment_id
                               ,p_placement_id          => l_placement_id
                               ,p_datetrack_mode        => p_datetrack_mode
                               ,p_validation_start_date => p_validation_start_date
                               ,p_object_version_number => l_object_version_number
                               ,p_current_spp_exist     => l_current_spp_exist
                               ,p_del_end_future_spp    => l_del_end_future_spp);
                     --
                  else
                     --
                     hr_sp_placement_api.update_spp(
                                p_effective_date        => p_validation_start_date
                               ,p_datetrack_mode        => l_datetrack_mode
                               ,p_placement_id          => l_placement_id
                               ,p_object_version_number => l_object_version_number
                               ,p_step_id               => l_min_step_id
                               ,p_auto_increment_flag   => 'N'
                               ,p_reason                => ''
                               ,p_increment_number      => NULL
                               ,p_effective_start_date  => l_effective_start_date
                               ,p_effective_end_date    => l_effective_end_date);
                     --
                  end if;
                  --
               end if;
               --
            end if; -- End of Second inner DT Mode check
            --
         end if; -- End of Current or future SPP exist check
         --
      end if; -- End of First DT Mode check
      --
   end if; -- End of Lock
   --
   if csr_lock_spp_rows%isopen then close csr_lock_spp_rows; end if;
   -- Setting the out warning parameter(if any)
   p_spp_delete_warning := l_del_end_future_spp;
   -- Resetting this variable back as this will be used through SPP rhi's.
   -- The value should be FALSE, when maintain_app_asg is called through SPP rhi's.
   g_called_from_spp_asg := false;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 999);
   end if;
   --
exception
   --
   when others then
      --
      l_del_end_future_spp := false;
      -- Resetting this variable back as this will be used through SPP rhi's.
      -- The value should be FALSE, when maintain_app_asg is called through SPP rhi's.
      g_called_from_spp_asg := false;
      --
      raise;
      --
   --
end maintain_spp_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_cwk_asg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_status_type_cwk_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
 --
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_type            per_assignments_f.assignment_type%TYPE;
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_payroll_id_updated         boolean;
  l_org_now_no_manager_warning boolean;
  l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72):=
                                        g_package||'update_status_type_cwk_asg';
  --
  cursor csr_get_asg_dets is
    select asg.assignment_type
         , asg.business_group_id
         , bus.legislation_code
     from  per_assignments_f   asg
         , per_business_groups_perf bus
    where  asg.assignment_id     = p_assignment_id
    and    p_effective_date      between asg.effective_start_date
                                 and     asg.effective_end_date
    and    bus.business_group_id+0 = asg.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  l_object_version_number     := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  if  p_expected_system_status <> 'ACTIVE_CWK'
  and p_expected_system_status <> 'SUSP_CWK_ASG'
  then
    --
    hr_utility.set_location(l_proc, 10);
    --
    hr_utility.set_message(800, 'HR_289693_ASG_INV_EXP_STATUS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Get assignment details.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  open  csr_get_asg_dets;
  fetch csr_get_asg_dets
   into l_assignment_type
      , l_business_group_id
      , l_legislation_code;
  --
  if csr_get_asg_dets%NOTFOUND then
    --
    hr_utility.set_location(l_proc, 40);
    --
    close csr_get_asg_dets;
    hr_utility.set_message(801, 'HR_52360_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_asg_dets;
  --
  hr_utility.set_location(l_proc, 50);
  --
  if l_assignment_type <> 'C' then
    --
    -- Assignment is not an employee assignment.
    --
    hr_utility.set_location(l_proc, 60);
    --
    hr_utility.set_message(800, 'HR_289616_ASG_NOT_CWK');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is g_number then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => p_expected_system_status
    );
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Update employee assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Set all output arguments
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
end update_status_type_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_emp_asg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_status_type_emp_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
 --
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_type            per_assignments_f.assignment_type%TYPE;
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_payroll_id_updated         boolean;
  l_org_now_no_manager_warning boolean;
  l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72):=
                                        g_package||'update_status_type_emp_asg';
  --
  cursor csr_get_asg_dets is
    select asg.assignment_type
         , asg.business_group_id
         , bus.legislation_code
     from  per_assignments_f   asg
         , per_business_groups_perf bus
    where  asg.assignment_id     = p_assignment_id
    and    p_effective_date      between asg.effective_start_date
                                 and     asg.effective_end_date
    and    bus.business_group_id+0 = asg.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  l_object_version_number     := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  if  p_expected_system_status <> 'ACTIVE_ASSIGN'
  and p_expected_system_status <> 'SUSP_ASSIGN'
  then
    --
    hr_utility.set_location(l_proc, 10);
    --
    hr_utility.set_message(801, 'HR_7947_ASG_INV_EXP_STATUS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Get assignment details.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  open  csr_get_asg_dets;
  fetch csr_get_asg_dets
   into l_assignment_type
      , l_business_group_id
      , l_legislation_code;
  --
  if csr_get_asg_dets%NOTFOUND then
    --
    hr_utility.set_location(l_proc, 40);
    --
    close csr_get_asg_dets;
    hr_utility.set_message(801, 'HR_52360_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_asg_dets;
  --
  hr_utility.set_location(l_proc, 50);
  --
  if l_assignment_type <> 'E' then
    --
    -- Assignment is not an employee assignment.
    --
    hr_utility.set_location(l_proc, 60);
    --
    hr_utility.set_message(801, 'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is g_number then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => p_expected_system_status
    );
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Update employee assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Set all output arguments
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
end update_status_type_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_apl_asg
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_person_referred_by_id        in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number   default null
  ,p_source_organization_id       in     number   default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_vacancy_id                   in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_application_id               in     number
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
  ,p_cagr_grade_def_id            in     number   default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_posting_content_id           in     number   default null
  ,p_applicant_rank               in     number   default null
  ,p_grade_ladder_pgm_id          in     number   default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_object_version_number           out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_status_id      number;
  l_asg_status_ovn            number;
  l_assignment_id             per_assignments_f.assignment_id%TYPE;
  l_assignment_sequence       per_assignments_f.assignment_sequence%TYPE;
  l_object_version_number     per_assignments_f.object_version_number%TYPE;
  l_assignment_status_type_id per_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_number         per_assignments_f.assignment_number%TYPE;
  l_effective_start_date      per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date        per_assignments_f.effective_end_date%TYPE;
  l_comment_id                per_assignments_f.comment_id%TYPE;
  l_other_manager_warning     boolean;
  l_hourly_salaried_warning   boolean;
  l_proc                      varchar2(72) := g_package||'create_apl_asg';
  l_labour_union_member_flag  per_assignments_f.labour_union_member_flag%TYPE;
begin
  --
  hr_utility.set_location(l_proc, 10);
       -- fix for bug 4550165 starts here.
  if p_legislation_code = 'DE' then
  l_labour_union_member_flag := null;
  else
  l_labour_union_member_flag := p_labour_union_member_flag;
  end if;
  -- fix for bug 4550165 ends here.
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process logic
  -- Start of 3554801
  if p_application_id is not null then
     --
     per_app_asg_pkg.check_apl_end_date(p_application_id => p_application_id);
     --
  end if;
  -- End of 3554801
  -- If p_assignment_status_type_id is null, derive default status for
  -- person's business group.
  --
  if p_assignment_status_type_id is null then
    per_people3_pkg.get_default_person_type
      (p_required_type     => 'ACTIVE_APL'
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_person_type       => l_assignment_status_type_id
      );
  else
    l_assignment_status_type_id := p_assignment_status_type_id;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_assignment_number := null;
  --
  -- Insert per_assignments_f row.
  --
  per_asg_ins.ins
    (p_assignment_id                => l_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => p_business_group_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_person_id                    => p_person_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_assignment_type              => 'A'
    ,p_primary_flag                 => 'N'
    ,p_application_id               => p_application_id
    ,p_assignment_number            => l_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => l_labour_union_member_flag -- fix for bug 4550165
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_posting_content_id           => p_posting_content_id
    ,p_applicant_rank               => p_applicant_rank
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_validate                     => FALSE
    ,p_validate_df_flex             => p_validate_df_flex
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --

  IRC_ASG_STATUS_API.create_irc_asg_status
         (p_assignment_id               => l_assignment_id
         , p_assignment_status_type_id  => l_assignment_status_type_id
         , p_status_change_date         => p_effective_date
	 , p_status_change_reason       => p_change_reason
         , p_assignment_status_id       => l_assignment_status_id
         , p_object_version_number      => l_asg_status_ovn);


  hr_utility.set_location(l_proc, 30);
  --
  -- Create assignment budget values.
  --Change 16-APR-1998 Include effective dates. SASmith
  --
  hr_assignment.load_budget_values
    (p_assignment_id                => l_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_userid                       => null
    ,p_login                        => null
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check if a letter request is necessary for the assignment.
  --
  per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => p_business_group_id
    ,p_per_system_status            => null
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => l_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_validation_start_date        => l_effective_start_date
    ,p_vacancy_id		    => p_vacancy_id
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  --  Set OUT parameters
  --
  p_assignment_id	   := l_assignment_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_assignment_sequence    := l_assignment_sequence;
  p_comment_id             := l_comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
--
end create_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_cwk_asg >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_default_cwk_asg
  (p_effective_date                 in   date
  ,p_person_id                      in   number
  ,p_business_group_id              in   number
  ,p_placement_date_start           in   date
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_location_id            per_business_groups.location_id%TYPE;
  l_time_normal_finish     per_business_groups.default_end_time%TYPE;
  l_time_normal_start      per_business_groups.default_start_time%TYPE;
  l_normal_hours           number;
  l_frequency              per_business_groups.frequency%TYPE;
  l_legislation_code       per_business_groups.legislation_code%TYPE;
  l_effective_start_date   per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_assignments_f.effective_start_date%TYPE;
  l_assignment_number      per_assignments_f.assignment_number%TYPE;
  l_comment_id             per_assignments_f.comment_id%TYPE;
  l_other_manager_warning  boolean;
  l_proc                   varchar2(72):=g_package||'create_default_cwk_asg';
  --
  cursor csr_get_default_details is
    select bus.location_id
         , bus.default_end_time
         , bus.default_start_time
         , fnd_number.canonical_to_number(bus.working_hours)
         , bus.frequency
         , bus.legislation_code
      from per_business_groups bus
     where bus.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_number := null;
  --
  -- Process Logic
  --
  -- Get default details.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'business_group_id',
     p_argument_value => p_business_group_id);
  --
  open  csr_get_default_details;
  fetch csr_get_default_details
   into l_location_id
      , l_time_normal_finish
      , l_time_normal_start
      , l_normal_hours
      , l_frequency
      , l_legislation_code;
  --
  if csr_get_default_details%NOTFOUND then
    --
    hr_utility.set_location(l_proc, 10);
    --
    close csr_get_default_details;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
	--
  end if;
  --
  close csr_get_default_details;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Create the contingent worker assignment.
  --
  hr_assignment_internal.create_cwk_asg
    (p_effective_date               => p_effective_date
    ,p_legislation_code             => l_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_business_group_id
    ,p_primary_flag                 => 'Y'
    ,p_placement_date_start         => p_placement_date_start
    ,p_location_id                  => l_location_id
    ,p_people_group_id              => null
    ,p_assignment_number            => l_assignment_number
    ,p_frequency                    => l_frequency
    ,p_normal_hours                 => l_normal_hours
    ,p_time_normal_finish           => l_time_normal_finish
    ,p_time_normal_start            => l_time_normal_start
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_validate_df_flex             => false
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set remaining output arguments
  --
  p_assignment_number := l_assignment_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end create_default_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_cwk_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwk_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_person_id                    in     number
  ,p_placement_date_start         in     date
  ,p_organization_id              in     number
  ,p_primary_flag                 in     varchar2
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_category          in     varchar2 default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_establishment_id             in     number   default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_job_id                       in     number   default null
  ,p_labor_union_member_flag      in     varchar2 default null
  ,p_location_id                  in     number   default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_position_id                  in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_project_title                in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_supervisor_id                in     number   default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_vendor_assignment_number     in     varchar2 default null
  ,p_vendor_employee_number       in     varchar2 default null
  ,p_vendor_id                    in     number   default null
  ,p_vendor_site_id               in     number   default null
  ,p_po_header_id                 in     number   default null
  ,p_po_line_id                   in     number   default null
  ,p_projected_assignment_end     in     date     default null
  ,p_people_group_id              in     number   default null
  ,p_soft_coding_keyflex_id       in     number   default null
  ,p_ass_attribute_category       in   varchar2 default null
  ,p_ass_attribute1               in   varchar2 default null
  ,p_ass_attribute2               in   varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_validate_df_flex             in     boolean  default true
  ,p_supervisor_assignment_id     in     number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_id             per_assignments_f.assignment_id%TYPE;
  l_assignment_sequence       per_assignments_f.assignment_sequence%TYPE;
  l_assignment_status_type_id per_assignments_f.assignment_status_type_id%TYPE;
  l_effective_start_date      per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date        per_assignments_f.effective_end_date%TYPE;
  l_hourly_salaried_warning   boolean;
  l_proc                      varchar2(72) := g_package||'create_cwk_asg';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is null then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => p_business_group_id
    ,p_legislation_code          => p_legislation_code
    ,p_expected_system_status    => 'ACTIVE_CWK'
    );
    --
  hr_utility.set_location(l_proc, 10);
  --
  -- Insert per_assignments_f row.
  --
  per_asg_ins.ins
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_placement_date_start         => p_placement_date_start
    ,p_organization_id              => p_organization_id
    ,p_primary_flag                 => p_primary_flag
    ,p_assignment_number            => p_assignment_number
    ,p_assignment_category          => p_assignment_category
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_assignment_type              => 'C'
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_establishment_id             => p_establishment_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_job_id                       => p_job_id
    ,p_labour_union_member_flag     => p_labor_union_member_flag
    ,p_location_id                  => p_location_id
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_position_id                  => p_position_id
    -- Bug 3545065, Grade should not be maintained for CWK asg
    -- ,p_grade_id                     => p_grade_id
    ,p_project_title                => p_project_title
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_supervisor_id                => p_supervisor_id
    ,p_time_normal_start            => p_time_normal_start
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_title                        => p_title
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_id                    => p_vendor_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => p_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_people_group_id              => p_people_group_id
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_validate_df_flex             => p_validate_df_flex
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_comment_id                   => p_comment_id
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set all output arguments
  --
  p_assignment_id                := l_assignment_id;
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end create_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_apl_asg >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_default_apl_asg
  (p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_application_id               in     number
  ,p_vacancy_id                   in     number
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_assignment_sequence             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_location_id            per_business_groups.location_id%TYPE;
--  Bug 4325900
  l_vac_location_id        per_all_vacancies.location_id%TYPE;
-- Bug 4520212
  l_org_id   per_all_vacancies.business_group_id%TYPE := p_business_group_id;
  l_vac_org_id    per_all_vacancies.business_group_id%TYPE ;
  l_vac_pgp_id        per_all_vacancies.people_group_id%TYPE ;
  l_vac_rec_id        per_all_vacancies.recruiter_id%TYPE ;
  l_vac_job_id        per_all_vacancies.job_id%TYPE ;
  l_vac_position_id        per_all_vacancies.position_id%TYPE ;
  l_vac_grade_id        per_all_vacancies.grade_id%TYPE ;

  l_time_normal_finish     per_business_groups.default_end_time%TYPE;
  l_time_normal_start      per_business_groups.default_start_time%TYPE;
  l_normal_hours           number;
  l_frequency              per_business_groups.frequency%TYPE;
  l_legislation_code       per_business_groups.legislation_code%TYPE;
  l_effective_start_date   per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_assignments_f.effective_end_date%TYPE;
  l_comment_id             per_assignments_f.comment_id%TYPE;
  l_proc                   varchar2(72):=g_package||'create_default_apl_asg';
  --
  cursor csr_get_default_details is
    select bus.location_id
         , bus.default_start_time
         , bus.default_end_time
         , fnd_number.canonical_to_number(bus.working_hours)
         , bus.frequency
         , bus.legislation_code
      from per_business_groups bus
     where bus.business_group_id = p_business_group_id;
  --
--  Bug 4325900 Starts
  cursor csr_get_vac_loc is
    select   location_id,people_group_id,recruiter_id,job_id,position_id,grade_id,organization_id
    from     PER_ALL_VACANCIES
    where    vacancy_id = p_vacancy_id
    and      p_effective_date between  date_from
             and nvl(date_to, hr_api.g_eot);
--  Bug 4325900 Ends
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Process Logic
  --
  -- Get default details.
  --
  open  csr_get_default_details;
  fetch csr_get_default_details
   into l_location_id
      , l_time_normal_start
      , l_time_normal_finish
      , l_normal_hours
      , l_frequency
      , l_legislation_code;
  if csr_get_default_details%NOTFOUND then
    --
    close csr_get_default_details;
    --
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_get_default_details;
  --
  hr_utility.set_location(l_proc, 20);
--  Bug 4325900 Starts
--  Desc: Check to see if the vacancy is null or not. If vacancy
--        is not null then get the default location of the vacancy
--        to pass the the assignment rowhandler.
  if p_vacancy_id is not null then
     open csr_get_vac_loc;
     fetch csr_get_vac_loc into l_vac_location_id
                                ,l_vac_pgp_id
				,l_vac_rec_id
				,l_vac_job_id
				,l_vac_position_id
				,l_vac_grade_id
				,l_vac_org_id;
     close csr_get_vac_loc;
     if l_vac_location_id is not null then
        l_location_id := l_vac_location_id;
     end if;
     if l_vac_org_id is not null then
        l_org_id := l_vac_org_id;
     end if;
  end if;
--  Bug 4325900 Ends
  --
  -- Create applicant assignment.
  --
  hr_assignment_internal.create_apl_asg
    (p_effective_date               => p_effective_date
    ,p_legislation_code             => l_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => l_org_id
    ,p_application_id               => p_application_id
    ,p_location_id                  => l_location_id
--    ,p_people_group_id              => null
    ,p_frequency                    => l_frequency
    ,p_manager_flag                 => 'N'
    ,p_normal_hours                 => l_normal_hours
    ,p_time_normal_finish           => l_time_normal_finish
    ,p_time_normal_start            => l_time_normal_start
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_validate_df_flex             => false
    ,p_vacancy_id                   => p_vacancy_id
    ,p_recruiter_id                 => l_vac_rec_id
    ,p_job_id                       => l_vac_job_id
    ,p_position_id                  => l_vac_position_id
    ,p_grade_id                     => l_vac_grade_id
    ,p_people_group_id              => l_vac_pgp_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end create_default_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_status_type_apl_asg >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_status_type_apl_asg
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_expected_system_status       in     varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
Cursor csr_vacancy_id is
Select vacancy_id
From per_all_assignments_f
Where assignment_id = p_assignment_id
And p_effective_date between effective_start_date and effective_end_date;

  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_status_id       number;
  L_ASG_STATUS_OVN             number;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_type            per_assignments_f.assignment_type%TYPE;
  l_person_id                  per_assignments_f.person_id%TYPE;
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_payroll_id_updated         boolean;
  l_org_now_no_manager_warning boolean;
  l_hourly_salaried_warning    boolean;
  l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72):=
                                        g_package||'update_status_type_apl_asg';
  l_vacancy_id 			number;
  --
  cursor csr_get_asg_dets is
    select asg.assignment_type
         , asg.person_id
         , asg.business_group_id
         , bus.legislation_code
    from  per_assignments_f   asg
         , per_business_groups_perf bus
    where  asg.assignment_id     = p_assignment_id
    and    p_effective_date      between asg.effective_start_date
                                 and     asg.effective_end_date
    and    bus.business_group_id+0 = asg.business_group_id;
  --
  cursor csr_get_asg_status_type is
    select ast.per_system_status
    from per_assignment_status_types ast
    where ast.assignment_status_type_id = p_assignment_status_type_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Validation in addition to Table Handlers
  --
  if  p_expected_system_status <> 'ACTIVE_APL'
  and p_expected_system_status <> 'OFFER'
  and p_expected_system_status <> 'ACCEPTED'
  and p_expected_system_status <> 'INTERVIEW1'
  and p_expected_system_status <> 'INTERVIEW2'
  then
    --
    hr_utility.set_message(801, 'HR_51232_ASG_INV_AASG_AST');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Get assignment details.
  --
  open  csr_get_asg_dets;
  fetch csr_get_asg_dets
   into l_assignment_type
      , l_person_id
      , l_business_group_id
      , l_legislation_code;
  --
  if csr_get_asg_dets%NOTFOUND then
    --
    close csr_get_asg_dets;
    hr_utility.set_message(801, 'HR_52360_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_asg_dets;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if l_assignment_type <> 'A' then
    --
    -- Assignment is not an applicant assignment.
    --
    hr_utility.set_message(801, 'HR_51036_ASG_ASG_NOT_APL');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is hr_api.g_number then derive it's default
  -- value, otherwise validate it.
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => p_expected_system_status
    );
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update applicant assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_comment_id                   => l_comment_id
    ,p_change_reason		    => p_change_reason
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  --
  hr_utility.set_location(l_proc, 45);
  --
  IRC_ASG_STATUS_API.dt_update_irc_asg_status
         (p_assignment_id               => p_assignment_id
         , p_datetrack_mode             => 'INSERT'
         , p_assignment_status_type_id  => l_assignment_status_type_id
         , p_status_change_reason       => p_change_reason
         , p_status_change_date         => p_effective_date
         , p_assignment_status_id       => l_assignment_status_id
         , p_object_version_number      => l_asg_status_ovn);

  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Remove out-of-date letter request lines
  --
  per_app_asg_pkg.cleanup_letters
    (p_assignment_id => p_assignment_id);
  --
  -- Check if a letter request is necessary for the assignment.
  --
open csr_vacancy_id;
fetch csr_vacancy_id into l_vacancy_id;
if csr_vacancy_id%NOTFOUND then null;
end if;
close csr_vacancy_id;

  per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => l_business_group_id
    ,p_per_system_status            => null
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_person_id                    => l_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_validation_start_date        => l_validation_start_date
    ,p_vacancy_id 		    => l_vacancy_id
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set out arguments
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end update_status_type_apl_asg;
--surendra
--
-- ----------------------------------------------------------------------------
-- |----------------------< irc_delete_assgt_checks >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure irc_delete_assgt_checks
   (p_assignment_id         in per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode        in varchar2
   ,p_validation_start_date in date )
  is
   --
   cursor irc_asgt_statuses is
     SELECT ASSIGNMENT_STATUS_ID,OBJECT_VERSION_NUMBER
       FROM IRC_ASSIGNMENT_STATUSES
         WHERE ASSIGNMENT_ID = p_assignment_id
           AND TRUNC(STATUS_CHANGE_DATE)=  p_validation_start_date;
   --
/*   cursor irc_offers is
     SELECT 'Y'
       FROM IRC_OFFERS
         WHERE ASSIGNMENT_ID  = p_assignment_id; */
   --
   temp             varchar2(10);
   l_asgt_status_id number;
   l_ovn            number;
   l_proc           varchar2(72) := g_package||'irc_delete_assgt_checks';
   --
begin
   --
   if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
/*   if per_asg_shd.g_old_rec.assignment_type = 'O' then
      if g_debug then
         hr_utility.set_location('Assignment of type O is found', 20);
      end if;
      --
      fnd_message.set_name('PER', 'ERROR_TO_BE_REPLACED_BY_IRC_1');
      fnd_message.raise_error;
   end if;
   --
   if ((p_datetrack_mode = 'ZAP') and ( per_asg_shd.g_old_rec.assignment_type = 'A')) then
       open irc_offers;
       fetch irc_offers into temp;
       close irc_offers;
       --
      if (temp = 'Y') then
          --
          if g_debug then
              hr_utility.set_location('IRC Offers available for this assignment', 30);
          end if;
          --
         fnd_message.set_name('PER', 'ERROR_TO_BE_REPLACED_BY_IRC_2');
         fnd_message.raise_error;
      end if;
      --
   end if;
   --  */
   open irc_asgt_statuses;
   LOOP
      fetch irc_asgt_statuses into l_asgt_status_id,l_ovn;
      EXIT WHEN irc_asgt_statuses%NOTFOUND;
      irc_ias_del.del( p_assignment_status_id    =>  l_asgt_status_id,
                       p_object_version_number   =>  l_ovn);
   END LOOP;
   close irc_asgt_statuses;
   --
   if g_debug then
   hr_utility.set_location('Leaving:'|| l_proc, 40);
   end if;
   --
end;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< ben_delete_assgt_checks >--------------------------|
-- ----------------------------------------------------------------------------
procedure ben_delete_assgt_checks
   (p_assignment_id         in  per_all_assignments_f.assignment_id%Type
   ,p_datetrack_mode        in  varchar2
   ,p_life_events_exists    out NOCOPY boolean)
  is
  --
   cursor ben_le_checks is
     SELECT 'Y'
        FROM BEN_PER_IN_LER
	  WHERE ASSIGNMENT_ID = p_assignment_id
	    AND PER_IN_LER_STAT_CD = 'STRTD';
   --
   temp varchar2(10);
   l_proc   varchar2(72) := g_package||'ben_delete_assgt_checks';
begin
   --
   if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if (p_datetrack_mode = 'ZAP') then
      open ben_le_checks;
      fetch ben_le_checks into temp;
      close ben_le_checks;
      --
      if (temp = 'Y') then
          --
          if g_debug then
             hr_utility.set_location('BEN Life Events available for this assignment', 20);
          end if;
          p_life_events_exists := true;
	  --
      end if;
   --
   end if;
   if g_debug then
   hr_utility.set_location('Leaving:'|| l_proc, 30);
   end if;
   --
end;
--
--surendra
--
procedure pre_delete
    (p_rec                         in  per_asg_shd.g_rec_type,
     p_effective_date              in  date,
     p_datetrack_mode              in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date         in  date,
     p_org_now_no_manager_warning  out nocopy boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     ---
     p_new_prim_ass_id             OUT nocopy number,
     p_prim_change_flag            OUT nocopy varchar2,
     p_new_end_date                OUT nocopy date,
     p_new_primary_flag            OUT nocopy varchar2,
     p_s_pay_id                    OUT nocopy number,
     p_cancel_atd                  OUT nocopy date,
     p_cancel_lspd                 OUT nocopy date,
     p_reterm_atd                  OUT nocopy date,
     p_reterm_lspd                 OUT nocopy date,
     ---
     p_appl_asg_new_end_date       OUT nocopy date
     )
 is
     l_sys_status_type  varchar2(100);
     l_ceil_seq         number;
     l_new_end_date	date;
     l_prim_change_flag	varchar2(1);
     l_new_prim_flag	varchar2(1);
     l_re_entry_point	number;
     l_returned_warning	varchar2(80);
     l_prim_date_from	date;
     l_new_prim_ass_id	number;
     l_cancel_atd	date;
     l_cancel_lspd	date;
     l_reterm_atd	date;
     l_reterm_lspd	date;
     l_rowid            varchar2(100);
     --
     l_s_pos_id           number;
     l_s_ass_num          varchar2(30);
     l_s_org_id           number;
     l_s_pg_id            number;
     l_s_job_id           number;
     l_s_grd_id           number;
     l_s_pay_id           number;
     l_s_def_code_comb_id number;
     l_s_soft_code_kf_id  number;
     l_s_per_sys_st       varchar2(300);
     l_s_ass_st_type_id   number;
     l_s_prim_flag        varchar2(10);
     l_s_sp_ceil_step_id  number;
     l_s_pay_bas          varchar2(300);
     l_pay_basis_id       number;   -- Added for Bug 4764140
     --
     l_warning_text       varchar2(240);
     l_loc_code           varchar2(100);
	l_legislation_code   per_business_groups.legislation_code%TYPE; --added for bug 6917728
     --
     cursor csr_ass_sys_type is
       select per_system_status
          from per_assignment_status_types
	    where assignment_status_type_id = per_asg_shd.g_old_rec.assignment_status_type_id;
     --
     cursor csr_ass_step_sequence is
       select sequence
         from per_spinal_point_steps_f
           where step_id = per_asg_shd.g_old_rec.special_ceiling_step_id
             and p_effective_date between effective_start_date and effective_end_date;
     --
     cursor csr_ass_row_id is
       select rowid from per_all_assignments_f
         where assignment_id = p_rec.assignment_id
	   and p_effective_date between effective_start_date and effective_end_date;
     --
     cursor csr_ass_loc_code is
        select location_code
	  from hr_locations
	    where location_id = per_asg_shd.g_old_rec.location_id;
     --
	--start changes for bug 6917728
     cursor csr_get_legislation_code is
        select bus.legislation_code
         from   per_business_groups bus
          where  bus.business_group_id = per_asg_shd.g_old_rec.business_group_id;
	--start changes for bug 6917728

     l_proc   varchar2(72) := g_package||'pre_delete';
     --
begin
     --
     if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
     end if;
     --
     open csr_ass_sys_type;
     fetch csr_ass_sys_type into l_sys_status_type;
     close csr_ass_sys_type;
     --
     open csr_ass_step_sequence;
     fetch csr_ass_step_sequence into l_ceil_seq;
     close csr_ass_step_sequence;
     --
     open csr_ass_row_id;
     fetch csr_ass_row_id into l_rowid;
     close csr_ass_row_id;
     --
     open csr_ass_loc_code;
     fetch csr_ass_loc_code into l_loc_code;
     close csr_ass_loc_code;
     --
	--
	--start changes for bug 6917728
     open  csr_get_legislation_code;
     fetch csr_get_legislation_code into l_legislation_code;
     if csr_get_legislation_code%NOTFOUND then
       close csr_get_legislation_code;
       -- This should never happen
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE', l_proc);
       hr_utility.set_message_token('STEP','210');
       hr_utility.raise_error;
     end if;
	close csr_get_legislation_code;
	--end changes for bug 6917728
	--
     --	 IRC Checks.
     --
     irc_delete_assgt_checks
                (p_assignment_id         =>  p_rec.assignment_id
                ,p_datetrack_mode        =>  p_datetrack_mode
                ,p_validation_start_date =>  p_validation_start_date );
     --
     -- BEN Checks.
     --
     ben_delete_assgt_checks
                (p_assignment_id         =>  p_rec.assignment_id
                ,p_datetrack_mode        =>  p_datetrack_mode
                ,p_life_events_exists    =>  p_life_events_exists );
     --
     if per_asg_shd.g_old_rec.assignment_type = 'A' then
        ---
        if g_debug then
           hr_utility.set_location('Applicant type Assignment', 20);
        end if;
        --
        per_app_asg_pkg.pre_delete_validation (
	                                  p_business_group_id     => per_asg_shd.g_old_rec.business_group_id,
				          p_assignment_id         => p_rec.assignment_id,
				          p_application_id        => per_asg_shd.g_old_rec.application_id,
				          p_person_id             => per_asg_shd.g_old_rec.person_id,
				          p_session_date          => p_effective_date, --:ctl_globals.session_date,
				          p_validation_start_date => p_validation_start_date,
				          p_validation_end_date   => p_validation_end_date,
				          p_delete_mode		  => p_datetrack_mode,
					  p_new_end_date	  => p_appl_asg_new_end_date);     -- :assgt.c_new_end_date ) ;
	---
     elsif ((per_asg_shd.g_old_rec.assignment_type = 'E') OR (per_asg_shd.g_old_rec.assignment_type = 'C')) then
	---
        if g_debug then
           hr_utility.set_location('EMP/CWK type Assignment', 30);
        end if;
        --
	l_re_entry_point        := 999;
	l_returned_warning	:= null;
	--
	-- Note l_re_entry_point is EITHER
	--	the re-entry point for the update_and_delete_bundle S-S proc
	--	called by the pre_delete S-S proc.
	-- OR
	--	the re-entry point after the check_future_primary warning in
	--	the pre_delete S-S proc.
	--
	-- l_prim_change_flag	:= p_prim_change_flag;
	-- l_new_prim_flag	:= p_new_prim_flag;
	-- l_prim_date_from	:= p_prim_date_from;
	--
	while l_re_entry_point <> 0 loop
                if g_debug then
                   hr_utility.set_location('l_re_entry_point :'||l_re_entry_point, 40);
                end if;
                --
		per_assignments_f2_pkg.pre_delete(
			p_datetrack_mode,				-- p_del_mode,
			p_validation_start_date,			-- p_val_st_date,
			per_asg_shd.g_old_rec.effective_start_date,     -- p_eff_st_date,
			per_asg_shd.g_old_rec.effective_end_date,       -- p_eff_end_date,
			per_asg_shd.g_old_rec.period_of_service_id,     -- p_pd_os_id,
			l_sys_status_type,				-- p_per_sys_st,
			p_rec.assignment_id,				-- p_ass_id,
			p_effective_date,				-- p_sess_date,
			p_new_end_date,					-- need this in post_delete()
			p_validation_end_date,				-- p_val_end_date,
			per_asg_shd.g_old_rec.payroll_id,               -- p_pay_id,
			per_asg_shd.g_old_rec.grade_id,                 -- p_grd_id,
			per_asg_shd.g_old_rec.special_ceiling_step_id,  -- p_sp_ceil_st_id,
			l_ceil_seq,					-- p_ceil_seq,
			per_asg_shd.g_old_rec.person_id,                -- p_per_id,
			per_asg_shd.g_old_rec.primary_flag,             -- p_prim_flag,
			p_prim_change_flag,             -- need this in post_delete()
			p_new_primary_flag,             -- need this in post_delete()
			l_re_entry_point,               -- no change
			l_returned_warning,             -- no change
			p_cancel_atd,                   -- need this in post_delete()
			p_cancel_lspd,                  -- need this in post_delete()
			p_reterm_atd,                   -- need this in post_delete()
			p_reterm_lspd,                  -- need this in post_delete()
			l_prim_date_from,               -- no change
			p_new_prim_ass_id,              -- need this in post_delete()
			l_rowid,                        -- p_row_id,
			l_s_pos_id,                     -- modified from p_
			l_s_ass_num,                    -- modified from p_
			l_s_org_id,                     -- modified from p_
			l_s_pg_id,                      -- modified from p_
			l_s_job_id,                     -- modified from p_
			l_s_grd_id,                     -- modified from p_
			p_s_pay_id,                     -- need this in post_delete()
			l_s_def_code_comb_id,           -- modified from p_
			l_s_soft_code_kf_id,            -- modified from p_
			l_s_per_sys_st,                 -- modified from p_
			l_s_ass_st_type_id,             -- modified from p_
			l_s_prim_flag,                  -- modified from p_
			l_s_sp_ceil_step_id,            -- modified from p_
			l_s_pay_bas,                    -- modified from p_
                        l_pay_basis_id                  -- Added for Bug 4764140
			 );
                --
		if l_returned_warning is not null then
			if l_returned_warning = 'SHOW_LOV' then
				--
				-- Warning was returned to show candidate primary
				-- assignment LOV and get user to select a new primary
				-- assignment. It is not possible from API, so raise
				-- an application error.
				--
                                fnd_message.set_name('PER', 'HR_449745_DEL_PRIM_ASG');
                                fnd_message.raise_error;
		                --
			elsif l_returned_warning = 'HR_ASS_TERM_COBRA_EXISTS' then
			        p_cobra_coverage_elements := true;
			elsif l_returned_warning = 'HR_ASS_TERM_COBRA_EXISTS' then
                                p_assgt_term_elements  := true;
			end if;
		end if;
		--
	end loop;
        --
	-- It calls a procedure to check whether in next records location is
	-- different from the location that is present in the form. If location
	-- is different in any of the future records the user will not be allowed
	-- to delete the record. and he will get an warning This is done as an
	-- impact of date tracking of W4 screen
	--
        if g_debug then
           hr_utility.set_location('Before check_payroll_run checks', 50);
        end if;

	   --if condition added for bug 6917728
	   -- extra check in if condition added for bug 8353075
	   IF l_legislation_code = 'US'
	   and not (hr_utility.chk_product_install ( 'GHR','US') ) then
		l_warning_text := pay_us_emp_dt_tax_val.check_payroll_run(
					  p_rec.assignment_id,                         -- p_ass_id ,
					  l_loc_code,                                  -- p_loc_code,
					  per_asg_shd.g_old_rec.location_id,           -- p_loc_id ,
					  p_effective_date,                            -- p_sess_date ,
					  per_asg_shd.g_old_rec.effective_start_date,  -- p_eff_st_date,
							    per_asg_shd.g_old_rec.effective_end_date,    -- p_eff_end_date,
					  p_datetrack_mode                             -- l_del_mode
					   );
		--
		if  l_warning_text is not null then
			   p_loc_change_tax_issues := true;
		   else p_loc_change_tax_issues := false;
		end if;
	   END if;
        --
	-- Now S-S checks.
	--
	-- l_new_end_date := p_new_end_date;
	--
        if g_debug then
           hr_utility.set_location('Before key_delrec ', 60);
        end if;
	--
	per_assignments_f2_pkg.key_delrec(
		p_datetrack_mode,                               -- l_del_mode,
		p_validation_start_date,                        -- p_val_st_date,
		per_asg_shd.g_old_rec.effective_start_date,     -- p_eff_st_date,
                per_asg_shd.g_old_rec.effective_end_date,       -- p_eff_end_date,
		per_asg_shd.g_old_rec.period_of_service_id,     -- p_pd_os_id,
		l_sys_status_type,                              -- p_per_sys_st,
		p_rec.assignment_id,                            -- p_ass_id ,
		per_asg_shd.g_old_rec.grade_id,                 -- p_grd_id,
		per_asg_shd.g_old_rec.special_ceiling_step_id,  -- p_sp_ceil_st_id,
		l_ceil_seq,                                     -- p_ceil_seq,
                per_asg_shd.g_old_rec.person_id,                -- p_per_id,
		p_effective_date,                               -- p_sess_date ,
		l_new_end_date,                                 -- no change
		p_validation_end_date,                          -- p_val_end_date,
		per_asg_shd.g_old_rec.payroll_id,               -- p_pay_id,
                l_pay_basis_id                                  -- added for bug 4764140
		);
	--
	-- CHECK_TERM_BY_POS changes (called in per_assignments_f2_pkg.key_delrec)
	--
	declare
	  l_rec2	per_asg_shd.g_rec_type;
	begin
	--
	l_rec2.assignment_id := p_rec.assignment_id;                -- p_ass_id;
	l_rec2.position_id   := per_asg_shd.g_old_rec.position_id;  -- name_in('ASSGT.POSITION_ID');
	--
        if g_debug then
           hr_utility.set_location('Before per_pqh_shr.per_asg_bus call ', 70);
        end if;
	per_pqh_shr.per_asg_bus(
		 p_event		 => 'DELETE_VALIDATE'
		,p_rec 			 => l_rec2
		,p_effective_date	 => p_effective_date        -- p_sess_date ,
		,p_validation_start_date => p_validation_start_date -- l_validation_start_date
		,p_validation_end_date   => p_validation_end_date   -- l_validation_end_date
		,p_datetrack_mode	 => p_datetrack_mode        -- l_del_mode
		);
	--
	end;
	--
        -- p_new_prim_ass_id 	:= l_new_prim_ass_id;
        -- p_prim_change_flag	:= l_prim_change_flag;
        --
   end if; -- End of EMP/CWK type Assignment validation checks.
   --
   if g_debug then
      hr_utility.set_location('Leaving :'||l_proc, 80);
   end if;
   --
end;  -- End of pre-delete checks
--
--
--surendra
--
procedure post_delete
    (p_rec                         in  per_asg_shd.g_rec_type,
     p_effective_date              in  date,
     p_datetrack_mode              in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date         in  date,
     p_org_now_no_manager_warning  out nocopy boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     ---
     p_new_prim_ass_id             IN number,
     p_prim_change_flag            IN varchar2,
     p_new_end_date                IN date,
     p_new_primary_flag            IN varchar2,
     p_s_pay_id                    IN number,
     p_cancel_atd                  IN date,
     p_cancel_lspd                 IN date,
     p_reterm_atd                  IN date,
     p_reterm_lspd                 IN date,
     ---
     p_appl_asg_new_end_date       IN date)
  is
    --
    l_sys_status_type       varchar2(100);
    l_warning		    varchar2(80);
    l_future_spp_warning    boolean;
    l_cost_warning          boolean;
    l_prim_change_flag      varchar2(10);
    l_new_prim_ass_id       number;
    --
    l_appl_cost_warning     boolean;
    --
    cursor csr_ass_sys_type is
       select per_system_status
          from per_assignment_status_types
	    where assignment_status_type_id = p_rec.assignment_status_type_id;
    --
    l_proc   varchar2(72) := g_package||'post_delete';
    --
begin
     --
     if g_debug then
        hr_utility.set_location('Entering :'||l_proc, 10);
     end if;
     --
     open csr_ass_sys_type;
     fetch csr_ass_sys_type into l_sys_status_type;
     close csr_ass_sys_type;
     --
     l_new_prim_ass_id 	:= p_new_prim_ass_id;
     l_prim_change_flag	:= p_prim_change_flag;
     --
     if per_asg_shd.g_old_rec.assignment_type = 'A' then
       ---
       if g_debug then
          hr_utility.set_location('Applicant type Assignment', 20);
       end if;
       --
       if ( p_datetrack_mode in ('FUTURE_CHANGE','DELETE_NEXT_CHANGE' ) ) then
	  if ( p_appl_asg_new_end_date is null ) then
	     if ( p_validation_end_date = hr_api.g_eot ) then
		 hr_assignment.tidy_up_ref_int ( p_rec.assignment_id,                      -- p_assignment_id,
						 'FUTURE',
						 p_validation_end_date,                    -- p_validation_end_date,
						 per_asg_shd.g_old_rec.effective_end_date, -- p_effective_end_date,
						 null,
						 null ,
						 l_appl_cost_warning) ;	                   -- used to catch the cost warning
						                                           -- but as Apl asg's can't have costing
											   -- records no need to return to caller.
             end if;
          else   hr_assignment.tidy_up_ref_int ( p_rec.assignment_id,                      -- p_assignment_id,
                                                 'FUTURE',
                                                 p_validation_end_date,                    -- p_new_end_date,
                                                 per_asg_shd.g_old_rec.effective_end_date, -- p_effective_end_date,
                                                 null,
                                                 null,
                                                 l_appl_cost_warning ) ;
          end if;
          --
	  if ( p_appl_asg_new_end_date is not null ) then
               --   set_end_date (  p_new_end_date  , p_assignment_id ) ;  -- copied this logic from per_app_asg_pkg
	       --   Sets an end date on rows which are deleted with delete mode FUTURE_CHANGES or NEXT_CHANGE
               --
               if g_debug then
                  hr_utility.set_location('Before updating assignment end date', 30);
               end if;
               --
               update	per_assignments_f a
               set	a.effective_end_date	= p_appl_asg_new_end_date
               where	a.assignment_id		= p_rec.assignment_id                      -- p_assignment_id
               and	a.effective_end_date	= (
                        select	max(a2.effective_end_date)
                        from	per_assignments_f a2
                        where	a2.assignment_id = a.assignment_id);
          end if;
	  --
          per_app_asg_pkg.cleanup_letters ( p_rec.assignment_id);                          -- p_assignment_id );
          --
       end if;	-- end of code for 'FUTURE_CHANGE','DELETE_NEXT_CHANGE' modes.
       --
       if ( p_datetrack_mode = 'ZAP' ) then
           per_app_asg_pkg.post_delete ( p_assignment_id         => p_rec.assignment_id,      -- :ASSGT.ASSIGNMENT_ID,
					 p_validation_start_date => p_validation_start_date); -- :ASSGT.VALIDATION_START_DATE ) ;
       end if; -- end of code for 'ZAP' mode.
	---
     elsif ((per_asg_shd.g_old_rec.assignment_type = 'E') OR (per_asg_shd.g_old_rec.assignment_type = 'C')) then
	---
        if g_debug then
           hr_utility.set_location('EMP/CWK type assignment checks ', 40);
        end if;
        --
	per_assignments_f1_pkg.post_delete(
		p_rec.assignment_id,                        -- p_ass_id,
		per_asg_shd.g_old_rec.grade_id,             -- p_grd_id,
		p_effective_date,                           -- p_sess_date,
		p_new_end_date,                             -- from pre_del()
		p_validation_end_date,                      -- p_val_end_date,
		per_asg_shd.g_old_rec.effective_end_date,   -- p_eff_end_date,
		p_datetrack_mode,                           -- p_del_mode,
		p_validation_start_date,                    -- p_val_st_date,
		p_new_primary_flag,                         -- from pre_del()
		hr_api.g_eot,                               -- p_eot,
		per_asg_shd.g_old_rec.period_of_service_id, -- p_pd_os_id,
		l_new_prim_ass_id,                          -- l_new_prim_ass_id,
		l_prim_change_flag,                         -- l_prim_change_flag,
		l_sys_status_type,                          -- p_per_sys_st,
		per_asg_shd.g_old_rec.business_group_id,    -- p_bg_id,
		p_s_pay_id,                                 -- p_old_pay_id,
		per_asg_shd.g_old_rec.payroll_id,           -- p_new_pay_id,
		p_cancel_atd,                               -- from pre_del()
		p_cancel_lspd,                              -- from pre_del()
		p_reterm_atd,                               -- from pre_del()
		p_reterm_lspd,                              -- from pre_del()
		l_warning,
		l_future_spp_warning,
		l_cost_warning);
	--
        If l_warning = 'HR_7016_ASS_ENTRIES_CHANGED' then
             p_element_salary_warning := true;
        else p_element_salary_warning := false;
	end if;
        --
        If l_warning = 'HR_7442_ASS_SAL_ENT_CHANGED' then
             p_element_entries_warning := true;
        else p_element_entries_warning := false;
	end if;
        --
        p_spp_warning  := l_future_spp_warning;
        p_cost_warning := l_cost_warning;
       --
     end if; -- End of EMP/CWK type Assignment validation checks.
     ---
     if g_debug then
        hr_utility.set_location('Leaving :'||l_proc, 50);
     end if;
     --
end;
--3
end hr_assignment_internal;

/
