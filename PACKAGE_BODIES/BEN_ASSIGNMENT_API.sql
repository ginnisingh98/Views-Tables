--------------------------------------------------------
--  DDL for Package Body BEN_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASSIGNMENT_API" as
/* $Header: beasgapi.pkb 120.1.12010000.5 2008/12/29 07:46:10 pvelvano ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_assignment_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check__benasg_allow >----------------------------|
-- ----------------------------------------------------------------------------
--
function check__benasg_allow
   (p_business_group_id in  number )
    return  boolean is

 l_allow   boolean := false  ;


 cursor ben_assign_ok is
 select substr(hoi.ORG_INFORMATION3,1)
 from  hr_organization_information hoi
 where hoi.org_information_context = 'Benefits Defaults'
 and   hoi.organization_id         = p_business_group_id;

 l_status   varchar2(1);

begin
  open ben_assign_ok;
  fetch ben_assign_ok into l_status;
  if ben_assign_ok%FOUND and l_status = 'Y'
  then
    l_allow :=true;
  end if;
  close ben_assign_ok;
  return l_allow ;
end check__benasg_allow ;

-- ----------------------------------------------------------------------------
-- |----------------------------< create_ben_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ben_asg
  (p_validate                     in     boolean  default false
  ,p_event_mode                   in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
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
  ,p_age                          in     number   default null
  ,p_adjusted_service_date        in     date     default null
  ,p_original_hire_date           in     date     default null
  ,p_salary                       in     varchar2 default null
  ,p_original_person_type         in     varchar2 default null
  ,p_original_person_type_id     in     varchar2 default null  -- Added parameter for Bug:7562768
  ,p_termination_date             in     date     default null
  ,p_termination_reason           in     varchar2 default null
  ,p_leave_of_absence_date        in     date     default null
  ,p_absence_type                 in     varchar2 default null
  ,p_absence_reason               in     varchar2 default null
  ,p_date_of_hire                 in     date     default null
  --
  ,p_called_from                  in     varchar2 default null
  --
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_extra_info_id        out nocopy number
  ,p_aei_object_version_number       out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'create_ben_asg';
  --
  l_effective_date            date;
  l_date_probation_end        date;
  l_assignment_number         per_all_assignments_f.assignment_number%TYPE;
  l_business_group_id         number;
  l_legislation_code          per_business_groups.legislation_code%TYPE;
  l_assignment_id             number;
  l_object_version_number     number;
  l_age                       varchar2(100);
  l_adj_serv_date             varchar2(100);
  l_orig_hire_date            varchar2(100);
  l_aei_payroll_changed       varchar2(100);
  l_salary                    varchar2(100);
  l_date_of_hire              varchar2(100);
  l_date_dummy1               date;
  l_date_dummy2               date;
  l_number_dummy1             number;
  l_number_dummy2             number;
  l_default_code_comb_id      number;
  l_location_id               number;
  l_supervisor_id             number;
  l_assignment_status_type_id number;
  l_boolean_dummy1            boolean;
  l_boolean_dummy2            boolean;
  l_aei_id                    number;
  l_aei_ovn                   number;
  l_pay_period_type           varchar2(100);
  l_default_payroll           boolean;
  l_mthpayroll_id             number := null;
  l_origpayroll_id            number;
  l_asg_esd                   date;
  l_asg_eed                   date;
  l_v2exists                  varchar2(1);
  l_dummy                     varchar2(1);
  --
  cursor csr_get_derived_details
    (c_person_id in     number
    ,c_eff_date  in     date
    )
  is
    select per.business_group_id
      from per_all_people_f    per
     where per.person_id         = c_person_id
     and   c_eff_date      between per.effective_start_date
                                 and     per.effective_end_date;
  --
  cursor csr_getactempasg
    (c_person_id in     number
    ,c_eff_date   in     date
    )
  is
    select null
      from per_all_assignments_f asg,
           per_assignment_status_types ast
     where asg.person_id    = c_person_id
     and   asg.assignment_type <> 'C'
     and   asg.assignment_status_type_id = ast.assignment_status_type_id
     and   c_eff_date      between asg.effective_start_date
                                 and asg.effective_end_date
     and   ast.PER_SYSTEM_STATUS = 'ACTIVE_ASSIGN'
     and   asg.primary_flag = 'Y';
  --
  cursor c_getpaydtinsdets
    (c_payroll_id in     number
    ,c_eff_date   in     date
    )
  Is
    select  pay.period_type
    from    pay_all_payrolls_f pay
    where   pay.payroll_id = c_payroll_id
    and     c_eff_date
      between pay.effective_start_date and pay.effective_end_date;
  --
  cursor c_getdefmthpaydets
    (c_bgp_id   in     number
    )
  Is
    select  to_number(ori.ORG_INFORMATION2)
    from    hr_organization_information ori
    where   ori.organization_id = c_bgp_id
    and     ori.ORG_INFORMATION_CONTEXT = 'Benefits Defaults';
  --
  -- Begin of bug 1919015
  --
  cursor c_default_code_comb_id is
    select null
    from   gl_code_combinations
    where  code_combination_id = l_default_code_comb_id
    and    enabled_flag = 'Y'
    and    l_effective_date
           between nvl(start_date_active,l_effective_date)
           and     nvl(end_date_active,l_effective_date);
  --
  -- End of bug 1919015
  --
  --
  -- Begin of bug 1925131
  --
  cursor c_location is
    select null
    from   hr_locations_all
    where  location_id = l_location_id
    and    l_effective_date <= nvl(inactive_date,l_effective_date);
  --
  cursor c_supervisor is
    select null
    from   per_all_people_f
    where  person_id = l_supervisor_id
    and    current_employee_flag = 'Y'
    and    l_effective_date
           between  effective_start_date
           and      effective_end_date;
  --
  cursor c_assignment_status_type_id is
    select null
    from   per_assignment_status_types
    where  assignment_status_type_id = p_assignment_status_type_id
    and    active_flag = 'Y';

 /* Bug 7597322: Added cursor to get the person_type_id on benefits assignment creation date*/
 cursor c_ptyp_id is
    select ptu.person_type_id from per_person_type_usages_f ptu,per_person_types ppt where
    ptu.person_id=p_person_id
    and ppt.person_type_id=ptu.person_type_id
    and ppt.system_person_type='EMP'
    and l_effective_date between ptu.effective_start_date and ptu.effective_end_date;

 l_org_ptyp_id number;
 /* End 7597322*/


  --
  -- End of bug 1925131
  --
  l_entries_changed varchar2(200) := null;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  -- Truncate the parameter p_effective_date and p_date_probation_end
  -- into local variables
  --
  l_effective_date := trunc(p_effective_date);
  l_date_probation_end := trunc(p_date_probation_end);
  --
  savepoint create_ben_asg;
  --
  begin
    null;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_EMP_ASG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_secondary_emp_asg
    --
  end;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Get person details.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );
  --
  -- Record the value of in out parameters
  --
  open  csr_get_derived_details
    (c_person_id => p_person_id
    ,c_eff_date  => l_effective_date
    );
  fetch csr_get_derived_details into l_business_group_id;
  --
  if csr_get_derived_details%NOTFOUND then
    --
    close csr_get_derived_details;
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
    --
  end if;
  close csr_get_derived_details;
  --- check for whther the Business group allows
  --- creation of benefits assignments
  ---
  if  not check__benasg_allow(l_business_group_id) then
      hr_utility.set_location('Leaving:'|| l_proc, 999);
      return ;
  end if ;
  hr_utility.set_location(l_proc, 20);

  --
  --  Remove this edit as it is not relevant for reduction of hours.
  --
  --  Check if an existing employee assignment with a status of
  --  'ACTIVE_ASSIGN' exists
  --
  /* if not p_event_mode then
    --
    -- Get existing 'ACTIVE_ASSIGN' employee assignments for the person
    --
    open csr_getactempasg
      (c_person_id => p_person_id
      ,c_eff_date  => l_effective_date
      );
    fetch csr_getactempasg into l_v2exists;
    if csr_getactempasg%FOUND then
      close csr_getactempasg;
      --
      --  A benefit assignment cannot be created for a person with an
      --  active employee assignment
      --
      hr_utility.set_message(805,'BEN_92114_ACTEMPASGEXISTS');
      hr_utility.raise_error;
      --
    end if;
    close csr_getactempasg;
    hr_utility.set_location(l_proc, 25);
    --
  end if; */
  --
  -- Default the payroll from the business group
  --
  hr_utility.set_location(l_proc, 35);
  --
  --   Get the default payroll
  --
  open c_getdefmthpaydets
    (c_bgp_id => l_business_group_id
    );
  --
  fetch c_getdefmthpaydets into l_mthpayroll_id;
  if hr_api.return_legislation_code(l_business_group_id) in ('US','CA') and
     (c_getdefmthpaydets%notfound or l_mthpayroll_id is null) then --Bug 1539414
    close c_getdefmthpaydets;
    --
    hr_utility.set_message(805,'BEN_92109_NODEFPAYEXISTS');
    hr_utility.raise_error;
    --
  end if;
  close c_getdefmthpaydets;

  hr_utility.set_location(l_proc, 45);
  hr_utility.set_location('p_payroll_id: '||p_payroll_id||' '||l_proc, 45);
  hr_utility.set_location('l_mthpayroll_id: '||l_mthpayroll_id||' '||l_proc, 45);
  --
  -- Check if existing payroll is set
  --
  if p_payroll_id is not null then
    if p_payroll_id <> l_mthpayroll_id then
    --
    l_aei_payroll_changed := 'Y';
    l_origpayroll_id  := p_payroll_id;
    --
    else
    l_aei_payroll_changed := 'N';
    l_origpayroll_id  := p_payroll_id;
    --
    end if;

  else
    --
    -- Do not set payroll changed flag when payroll was null
    --
    l_aei_payroll_changed := 'N';
    l_origpayroll_id  := null;
    --
  end if;
  --
  -- Begin of bug 1919015
  --
  l_default_code_comb_id := p_default_code_comb_id;
  --
  open c_default_code_comb_id;
    --
    fetch c_default_code_comb_id into l_dummy;
    --
    if c_default_code_comb_id%notfound then
      --
      l_default_code_comb_id := null;
      --
    end if;
    --
  close c_default_code_comb_id;
  --
  -- End of bug 1919015
  --
  --
  -- Begin of bug 1925131
  --
  l_location_id := p_location_id;
  --
  open c_location;
    --
    fetch c_location into l_dummy;
    --
    if c_location%notfound then
      --
      l_location_id := null;
      --
    end if;
    --
  close c_location;
  --
  l_supervisor_id := p_supervisor_id;
  --
  open c_supervisor;
    --
    fetch c_supervisor into l_dummy;
    --
    if c_supervisor%notfound then
      --
      l_supervisor_id := null;
      --
    end if;
    --
  close c_supervisor;
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  --
  open c_assignment_status_type_id;
    --
    fetch c_assignment_status_type_id into l_dummy;
    --
    if c_assignment_status_type_id%notfound then
      --
      -- Use an assignment status type that can't be disabled.
      -- In other words take the default active assignment status.
      --
      select assignment_status_type_id
      into   l_assignment_status_type_id
      from   per_assignment_status_types
      where  per_system_status = 'ACTIVE_ASSIGN'
      and    default_flag = 'Y'
      and    business_group_id is null;
      --
    end if;
    --
  close c_assignment_status_type_id;
  --
  -- End of bug 1925131
  --
  --
  -- Create the benefits assignment
  --
  l_assignment_number         := null;
  --
  hr_utility.set_location(l_proc, 40);

  --
  -- Call per_asg_ins.ins when p_called_from = 'FORM', (called from BENEBNAS.pld)
  -- to create benefits assignment with HR api validations.
  --
  -- Call ben_asg_ins.ins when p_called_from is NULL, to create benefits assignment
  -- without HR api validations
  --

  if p_called_from = 'FORM' then
    per_asg_ins.ins
      (p_business_group_id            => l_business_group_id
      ,p_effective_date               => p_effective_date
      ,p_assignment_status_type_id    => l_assignment_status_type_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_period_of_service_id         => null
      ,p_assignment_type              => 'B'
      ,p_primary_flag                 => 'Y'
      ,p_assignment_number            => l_assignment_number
      --
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_payroll_id                   => nvl(p_payroll_id, l_mthpayroll_id)
      ,p_location_id                  => l_location_id
      ,p_supervisor_id                => l_supervisor_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_people_group_id              => p_people_group_id
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_change_reason                => p_change_reason
      ,p_date_probation_end           => p_date_probation_end
      ,p_default_code_comb_id         => l_default_code_comb_id
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
      ,p_title                        => p_title
      ,p_validate                     => FALSE
      --
      ,p_assignment_id                => l_assignment_id
      ,p_effective_start_date         => l_asg_esd
      ,p_effective_end_date           => l_asg_eed
      ,p_assignment_sequence          => l_number_dummy1
      ,p_comment_id                   => l_number_dummy2
      ,p_other_manager_warning        => l_boolean_dummy1
      ,p_object_version_number        => l_object_version_number
      ,p_hourly_salaried_warning      => l_boolean_dummy2
      );
  else
    ben_asg_ins.ins
      (p_business_group_id            => l_business_group_id
      ,p_effective_date               => p_effective_date
      ,p_assignment_status_type_id    => l_assignment_status_type_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_period_of_service_id         => null
      ,p_assignment_type              => 'B'
      ,p_primary_flag                 => 'Y'
      ,p_assignment_number            => l_assignment_number
      --
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_payroll_id                   => l_mthpayroll_id
      ,p_location_id                  => p_location_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_people_group_id              => p_people_group_id
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_change_reason                => p_change_reason
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
      ,p_title                        => p_title
      ,p_validate                     => FALSE
      --
      ,p_assignment_id                => l_assignment_id
      ,p_effective_start_date         => l_asg_esd
      ,p_effective_end_date           => l_asg_eed
      ,p_assignment_sequence          => l_number_dummy1
      ,p_comment_id                   => l_number_dummy2
      ,p_other_manager_warning        => l_boolean_dummy1
      ,p_object_version_number        => l_object_version_number
      ,p_hourly_salaried_warning      => l_boolean_dummy2
      );
  end if;
  hr_utility.set_location(l_proc, 50);
  --
  -- Bug 5355232
  --
  hr_utility.set_location('ACE : Before : hrentmnt.adjust_entries_asg_criteria', 9999);
  --
  begin
    --
      hrentmnt.maintain_entries_asg
      (
        p_assignment_id                 => l_assignment_id,
        p_old_payroll_id                => null,
        p_new_payroll_id                => l_mthpayroll_id,
        p_business_group_id             => l_business_group_id,
        p_operation                     => 'ASG_CRITERIA',
        p_actual_term_date              => null,
        p_last_standard_date            => null,
        p_final_process_date            => null,
        p_dt_mode                       => 'INSERT',
        p_validation_start_date         => l_asg_esd,
        p_validation_end_date           => l_asg_eed,
        p_entries_changed               => l_entries_changed,
        p_old_hire_date                 => null,
        p_old_people_group_id           => null,
        p_new_people_group_id           => p_people_group_id
      );
    --
  exception
    --
    when others then
    --
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 1, 50), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 51, 100), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 101, 150), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 151, 200), 9999);
    --
    raise;
    --
  end;
  --
  hr_utility.set_location('ACE : After : hrentmnt.adjust_entries_asg_criteria', 9999);
  --
  --
  -- Bug 5355232
  --
  --
  -- Create the assignment extra info for the assignment
  --
   hr_utility.set_location('p_called_from '||p_called_from, 9999);

  /* Added for Bug 7597322 */
  if(p_called_from is null ) then
   open c_ptyp_id;
   fetch c_ptyp_id into l_org_ptyp_id;
   close c_ptyp_id;
   hr_utility.set_location('l_org_ptyp_id '||l_org_ptyp_id, 9999);
  end if;
   /* Ended for Bug 7597322 */

  hr_assignment_extra_info_api.create_assignment_extra_info
    (p_assignment_id            => l_assignment_id
    ,p_information_type         => 'BEN_DERIVED'
    --
    ,p_aei_information_category => 'BEN_DERIVED'
    ,p_aei_information1         => p_age
    ,p_aei_information2         => fnd_date.date_to_canonical(p_adjusted_service_date)
    ,p_aei_information3         => fnd_date.date_to_canonical(p_original_hire_date)
    ,p_aei_information4         => l_aei_payroll_changed
    ,p_aei_information5         => l_origpayroll_id
    ,p_aei_information6         => p_salary
    ,p_aei_information7         => p_original_person_type
    ,p_aei_information8         => fnd_date.date_to_canonical(p_termination_date)
    ,p_aei_information9         => p_termination_reason
    ,p_aei_information10        => fnd_date.date_to_canonical(p_leave_of_absence_date)
    ,p_aei_information11        => p_absence_type
    ,p_aei_information12        => p_absence_reason
    ,p_aei_information13        => fnd_date.date_to_canonical(p_date_of_hire)
    ,p_aei_information14        => nvl(p_original_person_type_id,l_org_ptyp_id)  -- Bug:7562768, store the person_type_id in addition to system_person_type
    --
    ,p_assignment_extra_info_id => l_aei_id
    ,p_object_version_number    => l_aei_ovn
    );
  hr_utility.set_location(l_proc, 60);
  begin
    null;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_EMP_ASG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_secondary_emp_asg
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_assignment_id             := l_assignment_id;
  p_object_version_number     := l_object_version_number;
  p_effective_start_date      := l_asg_esd;
  p_effective_end_date        := l_asg_eed;
  p_assignment_extra_info_id  := l_aei_id;
  p_aei_object_version_number := l_aei_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ben_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_id             := null;
    p_object_version_number     := null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    p_assignment_extra_info_id  := null;
    p_aei_object_version_number := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_ben_asg;
    raise;
    --
end create_ben_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ben_asg >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ben_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  --
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_people_group_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
  --
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_age                          in     number   default hr_api.g_number
  ,p_adjusted_service_date        in     date     default hr_api.g_date
  ,p_original_hire_date           in     date     default hr_api.g_date
  ,p_salary                       in     varchar2 default hr_api.g_varchar2
  ,p_original_person_type         in     varchar2 default hr_api.g_varchar2
  ,p_original_person_type_id     in     varchar2 default hr_api.g_varchar2 -- Added parameter for Bug:7562768
  ,p_termination_date             in     date     default hr_api.g_date
  ,p_termination_reason           in     varchar2 default hr_api.g_varchar2
  ,p_leave_of_absence_date        in     date     default hr_api.g_date
  ,p_absence_type                 in     varchar2 default hr_api.g_varchar2
  ,p_absence_reason               in     varchar2 default hr_api.g_varchar2
  ,p_date_of_hire                 in     date     default hr_api.g_date
  --
  ,p_called_from                  in     varchar2 default hr_api.g_varchar2
  --
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'update_ben_asg';
  -- Out variables
  --
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_no_managers_warning    boolean;
  l_other_manager_warning  boolean;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  --
  -- Internal working variables
  --
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_business_group_id          per_business_groups.business_group_id%TYPE;
  l_person_id                  number;
  l_assignment_extra_info_id   number;
  l_assignment_extra_info_ovn  number;
  l_payroll_id_updated         boolean;
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
  l_org_now_no_manager_warning boolean;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_entries_changed            varchar2(100);
  l_age                        number;
  l_adj_serv_date              date;
  l_orig_hire_date             date;
  l_payroll_changed            varchar2(100);
  l_orig_payroll_id            varchar2(100);
  l_salary                     varchar2(100);
  l_date_of_hire               date;
  l_payroll_id                 number;
  l_aei_origpayroll_id         number;
  l_char_age                   varchar2(100);
  l_char_adjusted_service_date varchar2(100);
  l_char_original_hire_date    varchar2(100);
  l_char_termination_date      varchar2(100);
  l_char_leave_of_absence_date varchar2(100);
  l_char_date_of_hire          varchar2(100);
  l_boolean_dummy2             boolean;
  --
  cursor csr_get_asg_dets
    (c_assignment_id in     number
    ,c_eff_date      in     date
    )
  is
    select asg.assignment_type
         , asg.business_group_id
         , asg.soft_coding_keyflex_id
         , asg.payroll_id
      from per_all_assignments_f asg
     where asg.assignment_id   = c_assignment_id
       and asg.assignment_type = 'B'
       and c_eff_date  between asg.effective_start_date
                             and     asg.effective_end_date;
  --
  cursor csr_get_aei_dets
    (c_assignment_id in     number
    )
  is
    select aei.assignment_extra_info_id
         , aei.object_version_number
         , aei.aei_information5
      from per_assignment_extra_info aei
     where aei.assignment_id = c_assignment_id
       and aei.aei_information_category = 'BEN_DERIVED';
  --

    cursor c_getdefmthpaydets
    (c_bgp_id   in     number
    )
    Is
    select  to_number(ori.ORG_INFORMATION2)
    from    hr_organization_information ori
    where   ori.organization_id = c_bgp_id
    and     ori.ORG_INFORMATION_CONTEXT = 'Benefits Defaults';
    l_mthpayroll_id             number := null;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('OVN:'||p_object_version_number||' '||l_proc, 10);
  --
  -- Truncate date and date_probation_end values, effectively removing time element.
  --
  l_effective_date     := trunc(p_effective_date);
  l_date_probation_end := trunc(p_date_probation_end);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint.
  --
  savepoint update_ben_asg;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment type.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => l_effective_date);
  hr_utility.set_location('ASG ID: '||p_assignment_id||' '||l_proc, 25);
  hr_utility.set_location('ESD: '||l_effective_date||' '||l_proc, 25);
  --
  -- Get assignment details
  --
  open csr_get_asg_dets
    (c_assignment_id => p_assignment_id
    ,c_eff_date      => l_effective_date
    );
  fetch csr_get_asg_dets
  into l_assignment_type,
       l_business_group_id,
       l_soft_coding_keyflex_id,
       l_payroll_id;
  --
  if csr_get_asg_dets%NOTFOUND then
    close csr_get_asg_dets;
      --
      -- Temporary - BEN_????_BENASGNOTEXISTS
      --
      --   - The benefit assignment cannot be modified because it does not exist
      --
      hr_utility.set_message(805,'BEN_????_BENASGNOTEXISTS ');
      hr_utility.raise_error;
      --
  end if;
  close csr_get_asg_dets;
  hr_utility.set_location(l_proc, 20);
  --- check for whether the Business group allows
  --- creation of benefits assignments
  ---
  if  not check__benasg_allow(l_business_group_id) then
      hr_utility.set_location('Leaving:'|| l_proc, 999);
      return ;
  end if ;

  --
  -- Get assignment details
  --
  open csr_get_aei_dets
    (c_assignment_id => p_assignment_id
    );
  fetch csr_get_aei_dets into l_assignment_extra_info_id,
                              l_assignment_extra_info_ovn,
                              l_aei_origpayroll_id;
  --
  close csr_get_aei_dets;
  hr_utility.set_location(l_proc, 30);
  --
  -- Check for a assignment type of B
  --
  if l_assignment_type <> 'B'
  then
    --
    -- Temporary - BEN_????_NOTBENASG
    --
    --   - The assignment being modified should be a benefits assignment.
    --
    hr_utility.set_message(805,'BEN_????_NOTBENASG');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Update assignment.
  --

  --
  -- Call per_asg_upd.upd when p_called_from = 'FORM', (called from BENEBNAS.pld)
  -- to update benefits assignment with HR api validations.
  --
  -- Call ben_asg_upd.upd when p_called_from is NULL, to update benefits assignment
  -- without HR api validations
  --

  if p_called_from = 'FORM' then
    per_asg_upd.upd
      (p_assignment_id                => p_assignment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_business_group_id            => l_business_group_id
      --
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => p_organization_id
      ,p_people_group_id              => p_people_group_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_employment_category          => p_employment_category
      --
      ,p_supervisor_id                => p_supervisor_id
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_assignment_number            => hr_api.g_varchar2
      ,p_change_reason                => p_change_reason
      ,p_comment_id                   => l_comment_id
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
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
      ,p_title                        => p_title
      --
      ,p_payroll_id_updated           => l_payroll_id_updated
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_validation_start_date        => l_validation_start_date
      ,p_validation_end_date          => l_validation_end_date
      ,p_object_version_number        => l_object_version_number
      ,p_effective_date               => l_effective_date
      ,p_datetrack_mode               => p_datetrack_update_mode
      ,p_validate                     => FALSE
      ,p_hourly_salaried_warning      => l_boolean_dummy2
      );
   else

      l_orig_payroll_id := hr_api.g_varchar2;
      l_payroll_changed := hr_api.g_varchar2;

      --- Defaulrt  Payroll id  passed only for
      --- Backend process, if Ben_Assg form modifield
      ----  the payroll passed as it is
      open c_getdefmthpaydets
         (c_bgp_id => l_business_group_id
         );
      --
      fetch c_getdefmthpaydets into l_mthpayroll_id;
      if hr_api.return_legislation_code(l_business_group_id) in ('US','CA') and
         (c_getdefmthpaydets%notfound or l_mthpayroll_id is null) then -- Bug 1539414
        close c_getdefmthpaydets;
        --
        hr_utility.set_message(805,'BEN_92109_NODEFPAYEXISTS');
        hr_utility.raise_error;
        --
      end if;
      close c_getdefmthpaydets;
      hr_utility.set_location(l_proc, 45);
      hr_utility.set_location('p_payroll_id: '||p_payroll_id||' '||l_proc, 45);
      hr_utility.set_location('l_mthpayroll_id: '||l_mthpayroll_id||' '||l_proc, 45);
      --
      -- Check if existing payroll is set
      if p_payroll_id is not null then
         if p_payroll_id <> l_mthpayroll_id then
         --
            l_orig_payroll_id  := p_payroll_id;
            --
            l_payroll_changed := 'Y';

         else
            l_orig_payroll_id  := p_payroll_id;
             --
         end if;

     end if;


     ben_asg_upd.upd
      (p_assignment_id                => p_assignment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_business_group_id            => l_business_group_id
      --
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_payroll_id                   => nvl(l_mthpayroll_id,p_payroll_id)
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => p_organization_id
      ,p_people_group_id              => p_people_group_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_employment_category          => p_employment_category
      --
      ,p_supervisor_id                => p_supervisor_id
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_assignment_number            => hr_api.g_varchar2
      ,p_change_reason                => p_change_reason
      ,p_comment_id                   => l_comment_id
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
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
      ,p_title                        => p_title
      --
      ,p_payroll_id_updated           => l_payroll_id_updated
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_validation_start_date        => l_validation_start_date
      ,p_validation_end_date          => l_validation_end_date
      ,p_object_version_number        => l_object_version_number
      ,p_effective_date               => l_effective_date
      ,p_datetrack_mode               => p_datetrack_update_mode
      ,p_validate                     => FALSE
      ,p_hourly_salaried_warning      => l_boolean_dummy2
      );
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Bug 5355232
  --
  hr_utility.set_location('ACE : Before : hrentmnt.adjust_entries_asg_criteria', 9999);
  --
  begin
    --
      hrentmnt.maintain_entries_asg
      (
        p_assignment_id                 => p_assignment_id,
        p_old_payroll_id                => null,
        p_new_payroll_id                => nvl(l_mthpayroll_id, p_payroll_id),
        p_business_group_id             => l_business_group_id,
        p_operation                     => 'ASG_CRITERIA',
        p_actual_term_date              => null,
        p_last_standard_date            => null,
        p_final_process_date            => null,
        p_dt_mode                       => p_datetrack_update_mode,
        p_validation_start_date         => l_validation_start_date,
        p_validation_end_date           => l_validation_end_date,
        p_entries_changed               => l_entries_changed,
        p_old_hire_date                 => null,
        p_old_people_group_id           => null,
        p_new_people_group_id           => p_people_group_id
      );
    --
  exception
    --
    when others then
    --
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 1, 50), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 51, 100), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 101, 150), 9999);
    hr_utility.set_location('EXC : ' || substr(SQLERRM, 151, 200), 9999);
    --
    raise;
    --
  end;
  --
  hr_utility.set_location('ACE : After : hrentmnt.adjust_entries_asg_criteria', 9999);
  --
  --
  -- Bug 5355232
  --
  --
  -- Check if the payroll has changed
  --
 /*
  if l_payroll_id_updated
  then
    --
    hr_utility.set_location(l_proc, 50);
    hr_utility.set_location('ORIG PAY ID: '||l_orig_payroll_id||' '||l_proc, 50);
    --
    -- Check if the original payroll is already set
    --
    if l_aei_origpayroll_id is null then
      --
      l_orig_payroll_id := l_payroll_id;
      l_payroll_changed := 'Y';
      --
    else
      --
      l_orig_payroll_id := hr_api.g_varchar2;
      l_payroll_changed := hr_api.g_varchar2;
      --
    end if;
    --
  else
    --
    hr_utility.set_location(l_proc, 60);
    --
    -- Unchanged
    --
    l_orig_payroll_id := hr_api.g_varchar2;
    l_payroll_changed := hr_api.g_varchar2;
    --
  end if;
  */
  --
  -- Refresh the AEI details
  --
  --   Check for forms mode
  --
  -- Bug 1904347 : eventhough update_ben_asg defaults p_age to number and
  -- p_adjusted_service_date, p_original_hire_date, p_termination_date
  -- p_leave_of_absence_date are defaulted to dates, when they are defaulted
  -- they have to go as hr_api.g_varchar2.
  --
  hr_utility.set_location('ORIG PAY ID: '||l_orig_payroll_id||' '||l_proc, 50);
  if p_age = hr_api.g_number then
     --
     l_char_age := hr_api.g_varchar2;
     --
  else
     --
     l_char_age := to_char(p_age);
     --
  end if;
  --
  if p_adjusted_service_date = hr_api.g_date then
     --
     l_char_adjusted_service_date := hr_api.g_varchar2;
     --
  else
     --
     l_char_adjusted_service_date := fnd_date.date_to_canonical(p_adjusted_service_date);
     --
  end if;
  --
  if p_original_hire_date = hr_api.g_date then
     --
     l_char_original_hire_date := hr_api.g_varchar2;
     --
  else
     --
     l_char_original_hire_date := fnd_date.date_to_canonical(p_original_hire_date);
     --
  end if;
  --
  if p_termination_date = hr_api.g_date then
     --
     l_char_termination_date := hr_api.g_varchar2;
     --
  else
     --
     l_char_termination_date := fnd_date.date_to_canonical(p_termination_date);
     --
  end if;
  --
  if p_leave_of_absence_date = hr_api.g_date then
     --
     l_char_leave_of_absence_date := hr_api.g_varchar2;
     --
  else
     --
     l_char_leave_of_absence_date := fnd_date.date_to_canonical(p_leave_of_absence_date);
     --
  end if;
  --
  if p_date_of_hire = hr_api.g_date then
     --
     l_char_date_of_hire := hr_api.g_varchar2;
     --
  else
     --
     l_char_date_of_hire := fnd_date.date_to_canonical(p_date_of_hire);
     --
  end if;
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
    (p_assignment_extra_info_id => l_assignment_extra_info_id
    ,p_object_version_number    => l_assignment_extra_info_ovn
    ,p_aei_information_category => 'BEN_DERIVED'
    ,p_aei_information1         => l_char_age -- p_age
    ,p_aei_information2         => l_char_adjusted_service_date -- fnd_date.date_to_canonical(p_adjusted_service_date)
    ,p_aei_information3         => l_char_original_hire_date -- fnd_date.date_to_canonical(p_original_hire_date)
    ,p_aei_information4         => l_payroll_changed
    ,p_aei_information5         => l_orig_payroll_id
    ,p_aei_information6         => p_salary
    ,p_aei_information7         => p_original_person_type
    ,p_aei_information8         => l_char_termination_date -- fnd_date.date_to_canonical(p_termination_date)
    ,p_aei_information9         => p_termination_reason
    ,p_aei_information10        => l_char_leave_of_absence_date -- fnd_date.date_to_canonical(p_leave_of_absence_date)
    ,p_aei_information11        => p_absence_type
    ,p_aei_information12        => p_absence_reason
    ,p_aei_information13        => l_char_date_of_hire -- fnd_date.date_to_canonical(p_date_of_hire)
    ,p_aei_information14        => p_original_person_type_id -- Bug:7562768, store the person_type_id in addition to system_person_type
    );
  hr_utility.set_location(l_proc, 70);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ben_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_ben_asg;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ben_asg;
--
procedure delete_ben_asg
  (p_validate              in     boolean  default false
  ,p_datetrack_mode        in     varchar2
  ,p_assignment_id         in     number
  ,p_object_version_number in out nocopy number
  ,p_effective_date        in     date
  ---
  ,p_effective_start_date     out nocopy date
  ,p_effective_end_date       out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ben_asg';
  --
  cursor c_getbenasgptudets
    (c_assignment_id in     number
    ,c_eff_date      in     date
    )
  Is
    select  ptu.person_type_usage_id,
            ptu.object_version_number
    from    per_all_assignments_f asg,
            per_person_type_usages_f ptu,
            per_person_types pet
    where   ptu.person_id = asg.person_id
    and     asg.assignment_type <> 'C'
    and     ptu.person_type_id = pet.person_type_id
    and     c_eff_date
      between ptu.effective_start_date and ptu.effective_end_date
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date
    and     asg.assignment_id = c_assignment_id
    and     pet.SYSTEM_PERSON_TYPE
                      in('SRVNG_SPS'
                        ,'FRMR_SPS'
                        ,'SRVNG_FMLY_MMBR'
                        ,'FRMR_FMLY_MMBR'
                        );
  --
  cursor c_getbenasgpendets
    (c_assignment_id in     number
    ,c_eff_date      in     date
    )
  Is
    select  pen.PRTT_ENRT_RSLT_ID,
            pen.object_version_number
    from    BEN_PRTT_ENRT_RSLT_F pen
    where   c_eff_date
      between pen.effective_start_date and pen.effective_end_date
    and     pen.assignment_id = c_assignment_id;
  --
  l_business_group_id     number;
  l_dummy_id              number;
  l_dummy_warning         boolean;
  l_dummy_date1           date;
  l_dummy_date2           date;
  --
  l_object_version_number number;
  --
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  l_aei_id                number;
  l_aei_ovn               number;
  --
  l_ovn                   number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  begin
  select asg.business_group_id
  into   l_business_group_id
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    asg.assignment_type <> 'C'
  and    p_effective_date between asg.effective_start_date
         and asg.effective_end_date;
  exception
     when no_data_found then
          fnd_message.set_name('BEN','BEN_92409_ASG_NOT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.raise_error;
  end;
  --- check for whether the Business group allows
  --- creation of benefits assignments
  ---
 /*
 --  This  restrict to delete  the asg which is created
 --  whne the prfile allows to create the asg
  if  not check__benasg_allow(l_business_group_id) then
      hr_utility.set_location('Leaving:'|| l_proc, 999);
      return ;
  end if ;
 */
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ben_asg;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check the datetrack mode
  --
  if p_datetrack_mode = hr_api.g_zap then
    --
    -- Remove related information
    --
    -- - Remove all benefits assignment related PTUs
    --   for the person of the benefits assignment
    --
    delete from per_person_type_usages_f ptu
    where ptu.person_id in
        (select asg.person_id
         from   per_all_assignments_f asg
         where  asg.assignment_id = p_assignment_id
             )
    and   ptu.person_type_id in
        (select pet.person_type_id
         from   per_person_types pet
         where  pet.SYSTEM_PERSON_TYPE
                      in('SRVNG_SPS'
                        ,'FRMR_SPS'
                        ,'SRVNG_FMLY_MMBR'
                        ,'FRMR_FMLY_MMBR'
                        )
             );
    --
    -- Remove in-direct references
    --
    -- - Remove children before parents
    --
    -- - per_events
    --   - per_bookings
    --
    delete  from per_bookings chd
    where   chd.event_id in
    (select par.event_id
     from   per_events par
     where  par.assignment_id = p_assignment_id
        );
    --
    delete from per_events par
    where par.assignment_id = p_assignment_id;
    --
    -- - per_pay_proposals
    --   - per_pay_proposal_components
    --
    delete  from per_pay_proposal_components chd
    where   chd.pay_proposal_id in
    (select par.pay_proposal_id
     from   per_pay_proposals par
     where  par.assignment_id = p_assignment_id
        );
    --
    delete from per_pay_proposals par
    where par.assignment_id = p_assignment_id;
    --
    -- - pay_element_entries_f
    --   - pay_element_entry_values_f
    --
    delete  from pay_element_entry_values_f chd
    where chd.ELEMENT_ENTRY_ID in
    (select par.ELEMENT_ENTRY_ID
     from   pay_element_entries_f par
     where  par.assignment_id = p_assignment_id
        );
    --
    delete from pay_element_entries_f par
    where par.assignment_id = p_assignment_id;
    --
    -- Remove direct references
    --
    delete from ben_le_clsn_n_rstr
    where assignment_id = p_assignment_id;
    --
    delete from ben_prtt_enrt_rslt_f
    where assignment_id = p_assignment_id;
    --
    delete from per_assignment_budget_values_f
    where assignment_id = p_assignment_id;
    --
    delete from per_assignment_extra_info
    where assignment_id = p_assignment_id;
    --
    delete from per_assign_proposal_answers
    where assignment_id = p_assignment_id;
    --
    delete from per_letter_request_lines
    where assignment_id = p_assignment_id;
    --
    delete from per_mm_assignments
    where assignment_id = p_assignment_id;
    --
    delete from per_quickpaint_result_text
    where assignment_id = p_assignment_id;
    --
    delete from per_secondary_ass_statuses
    where assignment_id = p_assignment_id;
    --
    delete from per_spinal_point_placements_f
    where assignment_id = p_assignment_id;
    --
    delete from hr_assignment_set_amendments
    where assignment_id = p_assignment_id;
    --
    delete from pay_cost_allocations_f
    where assignment_id = p_assignment_id;
    --
    delete from pay_personal_payment_methods_f
    where assignment_id = p_assignment_id;
    --
    delete from pay_assignment_latest_balances
    where assignment_id = p_assignment_id;
    --
    delete from pay_assignment_link_usages_f
    where assignment_id = p_assignment_id;
    --
  elsif p_datetrack_mode = hr_api.g_delete then
    --
    -- End date related information
    --
    -- - PTUs
    --
    for dets in c_getbenasgptudets
      (c_assignment_id => p_assignment_id
      ,c_eff_date      => p_effective_date
      )
    loop
      --
      l_ovn := dets.object_version_number;
      --
      hr_per_type_usage_internal.delete_person_type_usage
        (p_person_type_usage_id  => dets.person_type_usage_id
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => 'DELETE'
        ,p_object_version_number => l_ovn
        --
        ,p_effective_start_date  => l_dummy_date1
        ,p_effective_end_date    => l_dummy_date2
        );
      --
    end loop;
    --
    -- - PENs
    --
    for dets in c_getbenasgpendets
      (c_assignment_id => p_assignment_id
      ,c_eff_date      => p_effective_date
      )
    loop
      --
      l_ovn := dets.object_version_number;
      --
      ben_PRTT_ENRT_RESULT_api.update_PRTT_ENRT_RESULT
        (p_prtt_enrt_rslt_id     => dets.prtt_enrt_rslt_id
        ,p_object_version_number => l_ovn
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => 'DELETE'
        --
        ,p_effective_start_date  => l_dummy_date1
        ,p_effective_end_date    => l_dummy_date2
        );
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  per_asg_del.del
    (p_assignment_id              => p_assignment_id
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_effective_date             => p_effective_date
    --
    ,p_object_version_number      => l_object_version_number
    --
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_business_group_id          => l_dummy_id
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_org_now_no_manager_warning => l_dummy_warning
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set OUT parameters
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ben_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ben_asg;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_ben_asg;
--
end ben_assignment_api;

/
