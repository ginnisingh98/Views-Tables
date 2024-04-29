--------------------------------------------------------
--  DDL for Package Body PAY_PL_SII_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_SII_API" as
/* $Header: pypsdapi.pkb 120.1 2005/12/08 05:09:19 ssekhar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_pl_sii_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2
  ,p_per_or_asg_id                 in     number
  ,p_business_group_id             in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_old_age_cont_end_reason       in     varchar2  default null
  ,p_pension_cont_end_reason       in     varchar2  default null
  ,p_sickness_cont_end_reason      in     varchar2  default null
  ,p_work_injury_cont_end_reason   in     varchar2  default null
  ,p_labor_fund_cont_end_reason    in     varchar2  default null
  ,p_health_cont_end_reason        in     varchar2  default null
  ,p_unemployment_cont_end_reason  in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  )
   is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'create_pl_sii_details';
  l_program_id             number;
  l_program_login_id       number;
  l_program_application_id number;
  l_request_id             number;
  l_sii_details_id         number;
  l_object_version_number  number;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_reset_date             date;

 l_old_age_contribution      pay_pl_sii_details_f.old_age_contribution%type;
 l_pension_contribution      pay_pl_sii_details_f.pension_contribution%type;
 l_sickness_contribution     pay_pl_sii_details_f.sickness_contribution%type;
 l_work_injury_contribution  pay_pl_sii_details_f.work_injury_contribution%type;
 l_labor_contribution        pay_pl_sii_details_f.labor_contribution%type;
 l_health_contribution       pay_pl_sii_details_f.health_contribution%type;
 l_unemployment_contribution pay_pl_sii_details_f.unemployment_contribution%type;

 l_emp                       per_person_types.system_person_type%TYPE;
 l_emp_apl                   per_person_types.system_person_type%TYPE;
 l_active_assign             per_assignment_status_types.per_system_status%TYPE;
 l_susp_assign               per_assignment_status_types.per_system_status%TYPE;

 cursor csr_per_date is
   select min(papf.effective_start_date)
     from per_all_people_f  papf,
     per_person_types ppt
    where papf.person_type_id = ppt.person_type_id
	and system_person_type in (l_emp,l_emp_apl)
        and papf.person_id          =  p_per_or_asg_id
        and papf.business_group_id  =  p_business_group_id;

 cursor csr_asg_date is
   select min(effective_start_date)
	from per_all_assignments_f paaf,
		 hr_soft_coding_keyflex scl,
		 per_assignment_status_types past
	where paaf.ASSIGNMENT_STATUS_TYPE_ID = past.ASSIGNMENT_STATUS_TYPE_ID
	and paaf.SOFT_CODING_KEYFLEX_ID = scl.SOFT_CODING_KEYFLEX_ID
	and scl.segment3 = p_contract_category
	and paaf.assignment_id = p_per_or_asg_id
	and paaf.business_group_id = p_business_group_id
	and past.per_system_status in (l_active_assign,l_susp_assign);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  l_emp           := 'EMP';
  l_emp_apl       := 'EMP_APL';
  l_active_assign := 'ACTIVE_ASSIGN';
  l_susp_assign   := 'SUSP_ASSIGN';

  -- Issue a savepoint
  --
  savepoint create_pl_sii_details;
  --

  -- Reset the effective_start_date to the Effective Start date of Assignment/Person depending on
  -- whether the Contract Category is 'CIVIL' or 'NORMAL'

     if p_contract_category in ('CIVIL','LUMP','F_LUMP') then
        open csr_asg_date;
          fetch csr_asg_date into l_reset_date;
        close csr_asg_date;
     elsif p_contract_category = 'NORMAL' then
        open csr_per_date;
          fetch csr_per_date into l_reset_date;
        close csr_per_date;
     end if;

     if p_effective_date > l_reset_date then
        l_effective_date := trunc(l_reset_date);
        p_effective_date_warning := TRUE;
     else
        l_effective_date := trunc(p_effective_date);
        p_effective_date_warning := FALSE;
     end if;


 -- Validation prior to deriving the Contribution values
 -- Here we validate the 'Employee Social Security Information' prior to deriving
 -- the null Contribution values

     pay_psd_bus.chk_emp_social_security_info(p_sii_details_id => l_sii_details_id
       									 ,p_effective_date => l_effective_date
                                             ,p_emp_social_security_info =>  p_emp_social_security_info
                                             ,p_object_version_number     => l_object_version_number);


  -- Since the 'Employee Social Security Info' has been validated, we derive the various Contribution values

 l_old_age_contribution      := p_old_age_contribution;
 l_pension_contribution      := p_pension_contribution;
 l_sickness_contribution     := p_sickness_contribution;
 l_work_injury_contribution  := p_work_injury_contribution;
 l_labor_contribution        := p_labor_contribution;
 l_health_contribution       := p_health_contribution;
 l_unemployment_contribution := p_unemployment_contribution;


    pay_psd_bus.get_contribution_values(p_effective_date => l_effective_date
                                       ,p_emp_social_security_info  => p_emp_social_security_info
                                       ,p_old_age_contribution      => l_old_age_contribution
                                       ,p_pension_contribution      => l_pension_contribution
				               ,p_sickness_contribution     => l_sickness_contribution
                                       ,p_work_injury_contribution  => l_work_injury_contribution
                                       ,p_labor_contribution        => l_labor_contribution
                                       ,p_health_contribution       => l_health_contribution
                                       ,p_unemployment_contribution => l_unemployment_contribution);

  --
  -- Call Before Process User Hook
  --
  begin
    PAY_PL_SII_BK1.create_pl_sii_details_b
      (p_effective_date                => l_effective_date
      ,p_contract_category             => p_contract_category
      ,p_business_group_id             => p_business_group_id
      ,p_per_or_asg_id                 => p_per_or_asg_id
      ,p_emp_social_security_info      => p_emp_social_security_info
      ,p_old_age_contribution          => l_old_age_contribution
      ,p_pension_contribution          => l_pension_contribution
      ,p_sickness_contribution         => l_sickness_contribution
      ,p_work_injury_contribution      => l_work_injury_contribution
      ,p_labor_contribution            => l_labor_contribution
      ,p_health_contribution           => l_health_contribution
      ,p_unemployment_contribution     => l_unemployment_contribution
      ,p_old_age_cont_end_reason       => p_old_age_cont_end_reason
      ,p_pension_cont_end_reason       => p_pension_cont_end_reason
      ,p_sickness_cont_end_reason      => p_sickness_cont_end_reason
      ,p_work_injury_cont_end_reason   => p_work_injury_cont_end_reason
      ,p_labor_fund_cont_end_reason    => p_health_cont_end_reason
      ,p_health_cont_end_reason        => p_health_cont_end_reason
      ,p_unemployment_cont_end_reason  => p_unemployment_cont_end_reason
      ,p_effective_date_warning        => p_effective_date_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pl_sii_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
   --
  -- Process Logic
  --
   pay_psd_ins.ins
      (p_effective_date               => l_effective_date
      ,p_per_or_asg_id                => p_per_or_asg_id
      ,p_business_group_id            => p_business_group_id
      ,p_contract_category            => p_contract_category
      ,p_emp_social_security_info     => p_emp_social_security_info
      ,p_old_age_contribution         => l_old_age_contribution
      ,p_pension_contribution         => l_pension_contribution
      ,p_sickness_contribution        => l_sickness_contribution
      ,p_work_injury_contribution     => l_work_injury_contribution
      ,p_labor_contribution           => l_labor_contribution
      ,p_health_contribution          => l_health_contribution
      ,p_unemployment_contribution    => l_unemployment_contribution
      ,p_old_age_cont_end_reason      => p_old_age_cont_end_reason
      ,p_pension_cont_end_reason      => p_pension_cont_end_reason
      ,p_sickness_cont_end_reason     => p_sickness_cont_end_reason
      ,p_work_injury_cont_end_reason  => p_work_injury_cont_end_reason
      ,p_labor_fund_cont_end_reason   => p_labor_fund_cont_end_reason
      ,p_health_cont_end_reason       => p_health_cont_end_reason
      ,p_unemployment_cont_end_reason => p_health_cont_end_reason
      ,p_program_id                   => l_program_id
      ,p_program_login_id             => l_program_login_id
      ,p_program_application_id       => l_program_application_id
      ,p_request_id                   => l_request_id
      ,p_sii_details_id               => l_sii_details_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date);



  --
  -- Call After Process User Hook
  --
  begin
    pay_pl_sii_bk1.create_pl_sii_details_a
      (p_effective_date               => l_effective_date
      ,p_per_or_asg_id                => p_per_or_asg_id
      ,p_business_group_id            => p_business_group_id
      ,p_contract_category            => p_contract_category
      ,p_emp_social_security_info     => p_emp_social_security_info
      ,p_old_age_contribution         => l_old_age_contribution
      ,p_pension_contribution         => l_pension_contribution
      ,p_sickness_contribution        => l_sickness_contribution
      ,p_work_injury_contribution     => l_work_injury_contribution
      ,p_labor_contribution           => l_labor_contribution
      ,p_health_contribution          => l_health_contribution
      ,p_unemployment_contribution    => l_unemployment_contribution
      ,p_old_age_cont_end_reason      => p_old_age_cont_end_reason
      ,p_pension_cont_end_reason      => p_pension_cont_end_reason
      ,p_sickness_cont_end_reason     => p_sickness_cont_end_reason
      ,p_work_injury_cont_end_reason  => p_work_injury_cont_end_reason
      ,p_labor_fund_cont_end_reason   => p_labor_fund_cont_end_reason
      ,p_health_cont_end_reason       => p_health_cont_end_reason
      ,p_unemployment_cont_end_reason => p_health_cont_end_reason
      ,p_sii_details_id               => l_sii_details_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_effective_date_warning        => p_effective_date_warning);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pl_sii_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
    p_sii_details_id        := l_sii_details_id;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_pl_sii_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_sii_details_id         := NULL;
    p_object_version_number  := NULL;
    p_effective_start_date   := NULL;
    p_effective_end_date     := NULL;
    p_effective_date_warning := NULL;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_pl_sii_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_sii_details_id         := NULL;
    p_object_version_number  := NULL;
    p_effective_start_date   := NULL;
    p_effective_end_date     := NULL;
    p_effective_date_warning := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_pl_sii_details;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_civil_sii_details >----------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_civil_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_contract_category pay_pl_sii_details_f.contract_category%TYPE;

 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_sii_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_civil_sii_details';
 l_reset_date             date;

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.person_id         = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_effective_date    := trunc(p_effective_date);
 l_contract_category := 'CIVIL';

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375857_PL_INVALID_ASG');
    hr_utility.set_message_token('ENTITY',hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT'));
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_psd_bus.chk_per_asg_id(p_effective_date => l_effective_date
                             ,p_per_or_asg_id  => p_assignment_id
                             ,p_contract_category => l_contract_category
                             ,p_business_group_id => l_business_group_id
                             ,p_object_version_number => l_object_version_number);

 -- Calling the Create SII API

  pay_pl_sii_api.create_pl_sii_details
     (p_validate                      => p_validate
     ,p_effective_date                => l_effective_date
     ,p_contract_category             => l_contract_category
     ,p_per_or_asg_id                 => p_assignment_id
     ,p_business_group_id             => l_business_group_id
     ,p_emp_social_security_info      => p_emp_social_security_info
     ,p_old_age_contribution          => p_old_age_contribution
     ,p_pension_contribution          => p_pension_contribution
     ,p_sickness_contribution         => p_sickness_contribution
     ,p_work_injury_contribution      => p_work_injury_contribution
     ,p_labor_contribution            => p_labor_contribution
     ,p_health_contribution           => p_health_contribution
     ,p_unemployment_contribution     => p_unemployment_contribution
     ,p_sii_details_id                => l_sii_details_id
     ,p_object_version_number         => l_object_version_number
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_effective_date_warning        => p_effective_date_warning
     );

end create_pl_civil_sii_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_lump_sii_details >----------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_lump_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_contract_category pay_pl_sii_details_f.contract_category%TYPE;

 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_sii_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_lump_sii_details';
 l_reset_date             date;

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.person_id         = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_effective_date    := trunc(p_effective_date);
 l_contract_category := 'LUMP';

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375857_PL_INVALID_ASG');
    hr_utility.set_message_token('ENTITY',hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT'));
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_psd_bus.chk_per_asg_id(p_effective_date => l_effective_date
                             ,p_per_or_asg_id  => p_assignment_id
                             ,p_contract_category => l_contract_category
                             ,p_business_group_id => l_business_group_id
                             ,p_object_version_number => l_object_version_number);

 -- Calling the Create SII API

  pay_pl_sii_api.create_pl_sii_details
     (p_validate                      => p_validate
     ,p_effective_date                => l_effective_date
     ,p_contract_category             => l_contract_category
     ,p_per_or_asg_id                 => p_assignment_id
     ,p_business_group_id             => l_business_group_id
     ,p_emp_social_security_info      => p_emp_social_security_info
     ,p_old_age_contribution          => p_old_age_contribution
     ,p_pension_contribution          => p_pension_contribution
     ,p_sickness_contribution         => p_sickness_contribution
     ,p_work_injury_contribution      => p_work_injury_contribution
     ,p_labor_contribution            => p_labor_contribution
     ,p_health_contribution           => p_health_contribution
     ,p_unemployment_contribution     => p_unemployment_contribution
     ,p_sii_details_id                => l_sii_details_id
     ,p_object_version_number         => l_object_version_number
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_effective_date_warning        => p_effective_date_warning
     );

end create_pl_lump_sii_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_f_lump_sii_details >---------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_f_lump_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_contract_category pay_pl_sii_details_f.contract_category%TYPE;

 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_sii_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_f_lump_sii_details';
 l_reset_date             date;

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.person_id         = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_effective_date    := trunc(p_effective_date);
 l_contract_category := 'F_LUMP';

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375857_PL_INVALID_ASG');
    hr_utility.set_message_token('ENTITY',hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT'));
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_psd_bus.chk_per_asg_id(p_effective_date => l_effective_date
                             ,p_per_or_asg_id  => p_assignment_id
                             ,p_contract_category => l_contract_category
                             ,p_business_group_id => l_business_group_id
                             ,p_object_version_number => l_object_version_number);

 -- Calling the Create SII API

  pay_pl_sii_api.create_pl_sii_details
     (p_validate                      => p_validate
     ,p_effective_date                => l_effective_date
     ,p_contract_category             => l_contract_category
     ,p_per_or_asg_id                 => p_assignment_id
     ,p_business_group_id             => l_business_group_id
     ,p_emp_social_security_info      => p_emp_social_security_info
     ,p_old_age_contribution          => p_old_age_contribution
     ,p_pension_contribution          => p_pension_contribution
     ,p_sickness_contribution         => p_sickness_contribution
     ,p_work_injury_contribution      => p_work_injury_contribution
     ,p_labor_contribution            => p_labor_contribution
     ,p_health_contribution           => p_health_contribution
     ,p_unemployment_contribution     => p_unemployment_contribution
     ,p_sii_details_id                => l_sii_details_id
     ,p_object_version_number         => l_object_version_number
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_effective_date_warning        => p_effective_date_warning
     );

end create_pl_f_lump_sii_details;
--

-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_normal_sii_details >---------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_normal_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;

 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_sii_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_civil_sii_details';
 l_contract_category pay_pl_sii_details_f.contract_category%TYPE;

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_people_f papf
         , per_business_groups_perf bus
     where papf.person_id        = p_person_id
     and   l_effective_date      between papf.effective_start_date
                                 and     papf.effective_end_date
     and   bus.business_group_id = papf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_effective_date    := trunc(p_effective_date);
 l_contract_category := 'NORMAL';

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375857_PL_INVALID_ASG');
    hr_utility.set_message_token('ENTITY',hr_general.decode_lookup('PL_FORM_LABELS','PERSON'));
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Person's start date,
 -- we first validate the person id before deriving the effective_start_date.

   pay_psd_bus.chk_per_asg_id(p_effective_date => l_effective_date
                             ,p_per_or_asg_id  => p_person_id
                             ,p_contract_category => l_contract_category
                             ,p_business_group_id => l_business_group_id
                             ,p_object_version_number => l_object_version_number);

 -- Calling the Create SII API

  pay_pl_sii_api.create_pl_sii_details
     (p_validate                      => p_validate
     ,p_effective_date                => l_effective_date
     ,p_contract_category             => l_contract_category
     ,p_per_or_asg_id                 => p_person_id
     ,p_business_group_id             => l_business_group_id
     ,p_emp_social_security_info      => p_emp_social_security_info
     ,p_old_age_contribution          => p_old_age_contribution
     ,p_pension_contribution          => p_pension_contribution
     ,p_sickness_contribution         => p_sickness_contribution
     ,p_work_injury_contribution      => p_work_injury_contribution
     ,p_labor_contribution            => p_labor_contribution
     ,p_health_contribution           => p_health_contribution
     ,p_unemployment_contribution     => p_unemployment_contribution
     ,p_sii_details_id                => l_sii_details_id
     ,p_object_version_number         => l_object_version_number
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_effective_date_warning        => p_effective_date_warning);

end create_pl_normal_sii_details;



--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_sii_details_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_emp_social_security_info      in     varchar2 default hr_api.g_varchar2
  ,p_old_age_contribution          in     varchar2 default hr_api.g_varchar2
  ,p_pension_contribution          in     varchar2 default hr_api.g_varchar2
  ,p_sickness_contribution         in     varchar2 default hr_api.g_varchar2
  ,p_work_injury_contribution      in     varchar2 default hr_api.g_varchar2
  ,p_labor_contribution            in     varchar2 default hr_api.g_varchar2
  ,p_health_contribution           in     varchar2 default hr_api.g_varchar2
  ,p_unemployment_contribution     in     varchar2 default hr_api.g_varchar2
  ,p_old_age_cont_end_reason       in     varchar2 default hr_api.g_varchar2
  ,p_pension_cont_end_reason       in     varchar2 default hr_api.g_varchar2
  ,p_sickness_cont_end_reason      in     varchar2 default hr_api.g_varchar2
  ,p_work_injury_cont_end_reason   in     varchar2 default hr_api.g_varchar2
  ,p_labor_fund_cont_end_reason    in     varchar2 default hr_api.g_varchar2
  ,p_health_cont_end_reason        in     varchar2 default hr_api.g_varchar2
  ,p_unemployment_cont_end_reason  in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  )
   is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'update_pl_sii_details';
  l_program_id             number;
  l_program_login_id       number;
  l_program_application_id number;
  l_request_id             number;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_object_version_number  number;
  l_in_out_parameter1      number;
  l_norm_term              pay_pl_sii_details_f.contract_category%TYPE;
  l_norm_active            pay_pl_sii_details_f.contract_category%TYPE;
  l_exists                 pay_pl_sii_details_f.per_or_asg_id%TYPE;

  l_assg_type1             per_assignment_status_types.per_system_status%TYPE;
  l_assg_type2             per_assignment_status_types.per_system_status%TYPE;
  l_flag                   varchar2(1);

 cursor csr_term_catg(p_contract_catg char) is
    select per_or_asg_id from pay_pl_sii_details_f
     where sii_details_id  = p_sii_details_id and
           p_effective_date between effective_start_date and effective_end_date and
           contract_category = p_contract_catg;

 cursor csr_contract_type is
   select soft1.segment4 contract_type1, soft2.segment4 contract_type2
     from hr_soft_coding_keyflex soft1,
          per_all_assignments_f paf1,
          per_all_people_f pap,
          per_assignment_status_types pst,
          hr_soft_coding_keyflex soft2,
          per_all_assignments_f paf2
    where pap.person_id = (select per_or_asg_id from pay_pl_sii_details_f
                           where sii_details_id = p_sii_details_id and
                           p_effective_date between effective_start_date
                                                  and effective_end_date)
      and pap.person_id = paf1.person_id
      and p_effective_date between pap.effective_start_date and pap.effective_end_date
      and p_effective_date between paf1.effective_start_date and paf1.effective_end_date
      and paf1.soft_coding_keyflex_id = soft1.soft_coding_keyflex_id
      and soft1.segment3 = l_norm_active
      and paf1.assignment_status_type_id = pst.assignment_status_type_id
      and pst.per_system_status in (l_assg_type1,l_assg_type2)
      and pap.person_id = paf2.person_id
      and (p_effective_date-1) between paf2.effective_start_date and paf2.effective_end_date
      and  paf2.soft_coding_keyflex_id = soft2.soft_coding_keyflex_id
      and soft2.segment3 = l_norm_active
      and paf2.assignment_status_type_id = pst.assignment_status_type_id
  -- This join ensures that the Contract types are for the same assignment
      and paf2.assignment_id = paf1.assignment_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_norm_term   := 'TERM_NORMAL';
  l_norm_active := 'NORMAL';
  l_assg_type1  := 'ACTIVE_ASSIGN';
  l_assg_type2  := 'SUSP_ASSIGN';
  l_flag        := 'Y';
  --
  -- Issue a savepoint
  --
  savepoint update_pl_sii_details;
  --
 -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter1 := p_object_version_number;
 --
 --
   l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  open csr_term_catg(l_norm_term);
    fetch csr_term_catg into l_exists;
      if csr_term_catg%FOUND and p_datetrack_update_mode <> 'CORRECTION' then
        -- Raise an error message as the record can only be Corrected for a Normal Terminated
        -- Assignment
           hr_utility.set_message(801,'PAY_375859_INVALID_TERM_MODE');
           hr_utility.raise_error;
      end if;
  close csr_term_catg;

  open csr_term_catg(l_norm_active);
    fetch csr_term_catg into l_exists;
      if csr_term_catg%FOUND and p_datetrack_update_mode <> 'CORRECTION' then
        --
          close csr_term_catg;
--  If the Normal Active Record is not being Corrected, then we need to check if on the date
--  the record is being changed, we need to ensure that the Contract type for the corresponding
--  assignment has changed
      FOR r_contract_type in csr_contract_type
        LOOP
             if r_contract_type.contract_type1 <> r_contract_type.contract_type2 then
                l_flag := 'N';
                exit;
             end if;
        END LOOP;

      if l_flag = 'Y' then
 -- If this flag is Yes then an UPDATE is being done on a date when the Contract type has not
 -- changed. So we raise an error message
        hr_utility.set_message(801,'PAY_375860_INVALID_NORMAL_MODE');
        hr_utility.raise_error;
      end if;

 end if;

  --
  -- Call Before Process User Hook
  --
  begin
    PAY_PL_SII_BK2.update_pl_sii_details_b
      (p_effective_date                => p_effective_date
      ,p_sii_details_id                => p_sii_details_id
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_emp_social_security_info      => p_emp_social_security_info
      ,p_old_age_contribution          => p_old_age_contribution
      ,p_pension_contribution          => p_pension_contribution
      ,p_sickness_contribution         => p_sickness_contribution
      ,p_work_injury_contribution      => p_work_injury_contribution
      ,p_labor_contribution            => p_labor_contribution
      ,p_health_contribution           => p_health_contribution
      ,p_unemployment_contribution     => p_unemployment_contribution
      ,p_old_age_cont_end_reason       => p_old_age_cont_end_reason
      ,p_pension_cont_end_reason       => p_pension_cont_end_reason
      ,p_sickness_cont_end_reason      => p_sickness_cont_end_reason
      ,p_work_injury_cont_end_reason   => p_work_injury_cont_end_reason
      ,p_labor_fund_cont_end_reason    => p_labor_fund_cont_end_reason
      ,p_health_cont_end_reason        => p_health_cont_end_reason
      ,p_unemployment_cont_end_reason  => p_unemployment_cont_end_reason
      ,p_object_version_number         => l_object_version_number
       );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pl_sii_details'
        ,p_hook_type   => 'BP'
        );
  end;

   --
  -- Process Logic
  --

   pay_psd_upd.upd
       (p_effective_date               => p_effective_date
       ,p_datetrack_mode               => p_datetrack_update_mode
       ,p_sii_details_id               => p_sii_details_id
       ,p_object_version_number        => l_object_version_number
       ,p_emp_social_security_info     => p_emp_social_security_info
       ,p_old_age_contribution         => p_old_age_contribution
       ,p_pension_contribution         => p_pension_contribution
       ,p_sickness_contribution        => p_sickness_contribution
       ,p_work_injury_contribution     => p_work_injury_contribution
       ,p_labor_contribution           => p_labor_contribution
       ,p_health_contribution          => p_health_contribution
       ,p_unemployment_contribution    => p_unemployment_contribution
       ,p_old_age_cont_end_reason      => p_old_age_cont_end_reason
       ,p_pension_cont_end_reason      => p_pension_cont_end_reason
       ,p_sickness_cont_end_reason     => p_sickness_cont_end_reason
       ,p_work_injury_cont_end_reason  => p_work_injury_cont_end_reason
       ,p_labor_fund_cont_end_reason   => p_labor_fund_cont_end_reason
       ,p_health_cont_end_reason       => p_health_cont_end_reason
       ,p_unemployment_cont_end_reason => p_unemployment_cont_end_reason
       ,p_program_id                   => l_program_id
       ,p_program_login_id             => l_program_login_id
       ,p_program_application_id       => l_program_application_id
       ,p_request_id                   => l_request_id
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
  --
  -- Call After Process User Hook
  --
  begin
     pay_pl_sii_bk2.update_pl_sii_details_a
       (p_effective_date                => p_effective_date
       ,p_sii_details_id                => p_sii_details_id
       ,p_datetrack_update_mode         => p_datetrack_update_mode
       ,p_emp_social_security_info      => p_emp_social_security_info
       ,p_old_age_contribution          => p_old_age_contribution
       ,p_pension_contribution          => p_pension_contribution
       ,p_sickness_contribution         => p_sickness_contribution
       ,p_work_injury_contribution      => p_work_injury_contribution
       ,p_labor_contribution            => p_labor_contribution
       ,p_health_contribution           => p_health_contribution
       ,p_unemployment_contribution     => p_unemployment_contribution
       ,p_old_age_cont_end_reason       => p_old_age_cont_end_reason
       ,p_pension_cont_end_reason       => p_pension_cont_end_reason
       ,p_sickness_cont_end_reason      => p_sickness_cont_end_reason
       ,p_work_injury_cont_end_reason   => p_work_injury_cont_end_reason
       ,p_labor_fund_cont_end_reason    => p_labor_fund_cont_end_reason
       ,p_health_cont_end_reason        => p_health_cont_end_reason
       ,p_unemployment_cont_end_reason  => p_unemployment_cont_end_reason
       ,p_object_version_number         => l_object_version_number
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date
       );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pl_sii_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_pl_sii_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_pl_sii_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pl_sii_details;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_sii_details_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  )
   is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'delete_pl_sii_details';
  l_program_id             number;
  l_program_login_id       number;
  l_program_application_id number;
  l_request_id             number;
  l_sii_details_id         number;
  l_object_version_number  number;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_in_out_parameter1      number;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pl_sii_details;
  --
  -- Remember IN OUT parameter IN values
  --
  l_in_out_parameter1 := p_object_version_number;
 --
 --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --

  begin
    PAY_PL_SII_BK3.delete_pl_sii_details_b
      (p_effective_date          => p_effective_date
      ,p_sii_details_id          => p_sii_details_id
      ,p_datetrack_delete_mode   => p_datetrack_delete_mode
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pl_sii_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
   --
  -- Process Logic
  --

  pay_psd_del.del
     (p_effective_date         => p_effective_date
     ,p_datetrack_mode         => p_datetrack_delete_mode
     ,p_sii_details_id         => p_sii_details_id
     ,p_object_version_number  => l_object_version_number
     ,p_effective_start_date   => l_effective_start_date
     ,p_effective_end_date     => l_effective_end_date
     );
--


  --
  -- Call After Process User Hook
  --
  begin

   pay_pl_sii_bk3.delete_pl_sii_details_a
     (p_effective_date        => p_effective_date
     ,p_sii_details_id        => p_sii_details_id
     ,p_datetrack_delete_mode => p_datetrack_delete_mode
     ,p_object_version_number => l_object_version_number
     ,p_effective_start_date  => l_effective_start_date
     ,p_effective_end_date    => l_effective_end_date
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pl_sii_details'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_pl_sii_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to pay_pl_sii_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_pl_sii_details;
--
end pay_pl_sii_api;

/
