--------------------------------------------------------
--  DDL for Package Body PAY_PL_PAYE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_PAYE_API" as
/* $Header: pyppdapi.pkb 120.1 2005/12/08 19:08:54 ssekhar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PAY_PL_PAYE_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_pl_paye_details> >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2
  ,p_per_or_asg_id                 in     number
  ,p_business_group_id             in     number
  ,p_tax_reduction				   in     varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2
  ,p_income_reduction	           in     varchar2
  ,p_income_reduction_amount       in     number	default null
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor cur_prs is   select min(papf.effective_start_date)
     from per_all_people_f  papf,
     per_person_types ppt
    where papf.person_type_id = ppt.person_type_id
	and system_person_type in ('EMP','EMP_APL')
        and papf.person_id          =  p_per_or_asg_id
        and papf.business_group_id  =  p_business_group_id
	and p_contract_category = 'NORMAL';

  cursor cur_asg is select nvl(assignment_eff_start_date,term_eff_start_date) effective_start_date from
		(select min(paaf.effective_start_date) assignment_eff_start_date
                      	from per_all_assignments_f paaf,
                      	 hr_soft_coding_keyflex scl,
                      	 per_assignment_status_types past
                      where paaf.ASSIGNMENT_STATUS_TYPE_ID = past.ASSIGNMENT_STATUS_TYPE_ID
                      	and paaf.SOFT_CODING_KEYFLEX_ID = scl.SOFT_CODING_KEYFLEX_ID
                      and paaf.assignment_id = p_per_or_asg_id
                      and paaf.business_group_id = p_business_group_id
                      and past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN') and not exists ( select
                       paaf.effective_start_date from per_all_assignments_f paaf,
										  per_assignment_status_types past
                      where paaf.ASSIGNMENT_STATUS_TYPE_ID = past.ASSIGNMENT_STATUS_TYPE_ID
                      and past.per_system_status = 'TERM_ASSIGN'
                      and paaf.assignment_id = p_per_or_asg_id
                      and paaf.business_group_id = p_business_group_id
                      and p_effective_date between paaf.effective_start_date and paaf.effective_end_date)),
                      (select min(paaf.effective_start_date) term_eff_start_date  from per_all_assignments_f paaf,
										  per_assignment_status_types past
                      where paaf.ASSIGNMENT_STATUS_TYPE_ID = past.ASSIGNMENT_STATUS_TYPE_ID
                      and past.per_system_status = 'TERM_ASSIGN'
                      and paaf.assignment_id = p_per_or_asg_id
                      and paaf.business_group_id = p_business_group_id
                      and p_effective_date between paaf.effective_start_date and paaf.effective_end_date);


  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_pl_paye_details';
  l_program_id 				number;
  l_program_login_id  		number;
  l_program_application_id 	number;
  l_request_id          	number;
  l_paye_details_id     	number;
  l_object_version_number 	number;
  l_effective_start_date 	date;
  l_effective_end_date   	date;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pl_paye_details;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
     If p_contract_category = 'NORMAL' then
  	open cur_prs;
	fetch cur_prs into l_effective_date;
	close cur_prs;
     else
        open cur_asg;
	fetch cur_asg into l_effective_date;
  	close cur_asg;
     end if;

     if p_effective_date > l_effective_date then
         p_effective_date_warning := TRUE;
     else
	l_effective_date := trunc(p_effective_date);
         p_effective_date_warning := FALSE;
     end if;

 --  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PAY_PL_PAYE_BK1.create_pl_paye_details_b
				  (p_effective_date                =>     l_effective_date
				  ,p_contract_category             =>     p_contract_category
				  ,p_business_group_id             =>     p_business_group_id
				  ,p_per_or_asg_id                 =>     p_per_or_asg_id
				  ,p_tax_reduction				   =>     p_tax_reduction
				  ,p_tax_calc_with_spouse_child    =>     p_tax_calc_with_spouse_child
				  ,p_income_reduction	           =>     p_income_reduction
				  ,p_income_reduction_amount       =>     p_income_reduction_amount
				  ,p_rate_of_tax			       =>     p_rate_of_tax);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pl_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
 	pay_ppd_ins.ins(p_effective_date                 =>	 l_effective_date
	           	   ,p_per_or_asg_id                  =>  p_per_or_asg_id
			   ,p_business_group_id              =>  p_business_group_id
			   ,p_contract_category              =>  p_contract_category
			   ,p_tax_reduction                  =>  p_tax_reduction
			   ,p_tax_calc_with_spouse_child     =>  p_tax_calc_with_spouse_child
 			   ,p_income_reduction               =>  p_income_reduction
			   ,p_income_reduction_amount        =>  p_income_reduction_amount
			   ,p_rate_of_tax                    =>  p_rate_of_tax
			   ,p_program_id                     =>  l_program_id
			   ,p_program_login_id               =>  l_program_login_id
			   ,p_program_application_id         =>  l_program_application_id
			   ,p_request_id                     =>  l_request_id
			   ,p_paye_details_id                =>  l_paye_details_id
			   ,p_object_version_number          =>  l_object_version_number
			   ,p_effective_start_date           =>  l_effective_start_date
			   ,p_effective_end_date             =>  l_effective_end_date
			   );



  --
  -- Call After Process User Hook
  --
  begin

	pay_pl_paye_bk1.create_pl_paye_details_a
				  (p_effective_date                =>     l_effective_date
				  ,p_contract_category             =>     p_contract_category
				  ,p_per_or_asg_id                 =>     p_per_or_asg_id
				  ,p_business_group_id             =>     p_business_group_id
				  ,p_tax_reduction				   =>     p_tax_reduction
				  ,p_tax_calc_with_spouse_child    =>     p_tax_calc_with_spouse_child
				  ,p_income_reduction	           =>     p_income_reduction
				  ,p_income_reduction_amount       =>     p_income_reduction_amount
				  ,p_rate_of_tax			       =>     p_rate_of_tax
				  ,p_paye_details_id               =>     l_paye_details_id
				  ,p_object_version_number         =>     l_object_version_number
				  ,p_effective_start_date          =>     l_effective_start_date
				  ,p_effective_end_date            =>     l_effective_end_date
				  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pl_paye_api'
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
    p_paye_details_id       := l_paye_details_id;
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
    rollback to create_pl_paye_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_paye_details_id        := NULL;
    p_object_version_number := NULL;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_pl_paye_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_paye_details_id        := NULL;
    p_object_version_number := NULL;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PL_PAYE_DETAILS;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_paye_details >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_tax_reduction			       in     varchar2 default hr_api.g_varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2 default hr_api.g_varchar2
  ,p_income_reduction              in     varchar2 default hr_api.g_varchar2
  ,p_income_reduction_amount       in     number   default hr_api.g_number
  ,p_rate_of_tax			 	   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  )
   is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'update_pl_paye_details';
  l_program_id             number;
  l_program_login_id       number;
  l_program_application_id number;
  l_request_id             number;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_object_version_number  number;
  l_in_out_parameter1      number;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_pl_paye_details;
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

    PAY_PL_PAYE_BK2.update_pl_paye_details_b(p_effective_date                => l_effective_date
							  	    ,p_paye_details_id               => p_paye_details_id
		  						    ,p_datetrack_update_mode         => p_datetrack_update_mode
								    ,p_tax_reduction				 => p_tax_reduction
								    ,p_tax_calc_with_spouse_child    => p_tax_calc_with_spouse_child
								    ,p_income_reduction	             => p_income_reduction
								    ,p_income_reduction_amount       => p_income_reduction_amount
									,p_rate_of_tax			         => p_rate_of_tax
  									,p_object_version_number		 => l_object_version_number
									);
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pl_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;

   --
  -- Process Logic
  --
   pay_ppd_upd.upd
	  (p_effective_date               =>  l_effective_date
	  ,p_datetrack_mode        =>  p_datetrack_update_mode
	  ,p_paye_details_id              =>  p_paye_details_id
	  ,p_object_version_number        =>  l_object_version_number
	  ,p_tax_reduction                =>  p_tax_reduction
	  ,p_tax_calc_with_spouse_child   =>  p_tax_calc_with_spouse_child
	  ,p_income_reduction             =>  p_income_reduction
	  ,p_income_reduction_amount      =>  p_income_reduction_amount
	  ,p_rate_of_tax                  =>  p_rate_of_tax
	  ,p_program_id                   =>  l_program_id
	  ,p_program_login_id             =>  l_program_login_id
	  ,p_program_application_id       =>  l_program_application_id
	  ,p_request_id                   =>  l_request_id
	  ,p_effective_start_date         =>  l_effective_start_date
	  ,p_effective_end_date           =>  l_effective_end_date
	  );

  --
  -- Call After Process User Hook
  --
  begin

     pay_pl_paye_bk2.update_pl_paye_details_a
	  	(p_effective_date                =>     l_effective_date
		,p_paye_details_id               =>     p_paye_details_id
		,p_datetrack_update_mode         =>     p_datetrack_update_mode
		,p_tax_reduction				 =>     p_tax_reduction
		,p_tax_calc_with_spouse_child    =>     p_tax_calc_with_spouse_child
		,p_income_reduction	           	 =>     p_income_reduction
		,p_income_reduction_amount       =>     p_income_reduction_amount
		,p_rate_of_tax			         =>     p_rate_of_tax
		,p_object_version_number         =>     l_object_version_number
		,p_effective_start_date          =>    	l_effective_start_date
		,p_effective_end_date            =>     l_effective_end_date
		 );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pl_paye_details'
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
    rollback to update_pl_paye_details;
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
    rollback to update_pl_paye_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pl_paye_details;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_paye_details >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  )
   is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'delete_pl_paye_details';
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
  savepoint delete_pl_paye_details;
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
    PAY_PL_PAYE_BK3.delete_pl_paye_details_b
      (p_effective_date          => l_effective_date
      ,p_paye_details_id         => p_paye_details_id
      ,p_datetrack_delete_mode   => p_datetrack_delete_mode
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pl_paye_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
   --
  -- Process Logic
  --

  pay_ppd_del.del
     (p_effective_date         => l_effective_date
     ,p_datetrack_mode         => p_datetrack_delete_mode
     ,p_paye_details_id        => p_paye_details_id
     ,p_object_version_number  => l_object_version_number
     ,p_effective_start_date   => l_effective_start_date
     ,p_effective_end_date     => l_effective_end_date
     );
--


  --
  -- Call After Process User Hook
  --
  begin

   pay_pl_paye_bk3.delete_pl_paye_details_a
     (p_effective_date        => l_effective_date
     ,p_paye_details_id        => p_paye_details_id
     ,p_datetrack_delete_mode => p_datetrack_delete_mode
     ,p_object_version_number => l_object_version_number
     ,p_effective_start_date  => l_effective_start_date
     ,p_effective_end_date    => l_effective_end_date
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pl_paye_details'
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
    rollback to delete_pl_paye_details;
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
    rollback to pay_pl_paye_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_in_out_parameter1;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_pl_paye_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_civil_paye_details >---------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_civil_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'CIVIL'
  ,p_assignment_id                 in     number
  ,p_income_reduction_amount       in     number	default null
  ,p_rate_of_tax			       in     varchar2  default 'C01'
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_leg_code          pay_user_column_instances_f.legislation_code%TYPE;
 l_income_reduction      ff_globals_f.global_value%type;
 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_paye_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_civil_paye_details';

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.assignment_id   = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_leg_code        := 'PL';

 l_effective_date  := trunc(p_effective_date);

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375848_PL_INVALID_ASG');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_ppd_bus.chk_per_asg_id(p_effective_date        => l_effective_date
                             ,p_per_or_asg_id         => p_assignment_id
                             ,p_contract_category     => 'CIVIL'
                             ,p_business_group_id     => l_business_group_id
                             ,p_object_version_number => l_object_version_number);




 -- Calling the Create PAYE API

   pay_pl_paye_api.create_pl_paye_details
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_contract_category            => p_contract_category
    ,p_per_or_asg_id                => p_assignment_id
    ,p_business_group_id            => l_business_group_id
    ,p_tax_reduction                => null
    ,p_tax_calc_with_spouse_child   => null
    ,p_income_reduction             => null
    ,p_income_reduction_amount      => p_income_reduction_amount
    ,p_rate_of_tax                  => p_rate_of_tax
    ,p_paye_details_id              => l_paye_details_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_effective_date_warning		  => p_effective_date_warning
    );

end create_pl_civil_paye_details;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_lump_paye_details >---------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_lump_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'LUMP'
  ,p_assignment_id                 in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_leg_code          pay_user_column_instances_f.legislation_code%TYPE;
 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_paye_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_lump_paye_details';

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.assignment_id   = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

cursor csr_contract_type is
   select segment4
     from hr_soft_coding_keyflex soft, per_all_assignments_f paaf
    where soft.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
      and paaf.assignment_id = p_assignment_id
      and p_effective_date between paaf.effective_start_date and paaf.effective_end_date;

l_contract_type hr_soft_coding_keyflex.segment4%TYPE;
l_rate_of_tax pay_pl_paye_details_f.rate_of_tax%TYPE;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_leg_code        := 'PL';

 l_effective_date  := trunc(p_effective_date);

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375848_PL_INVALID_ASG');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_ppd_bus.chk_per_asg_id(p_effective_date        => l_effective_date
                             ,p_per_or_asg_id         => p_assignment_id
                             ,p_contract_category     => 'LUMP'
                             ,p_business_group_id     => l_business_group_id
                             ,p_object_version_number => l_object_version_number);

   open csr_contract_type;
    fetch csr_contract_type into l_contract_type;
   close csr_contract_type;

 -- For Contract types L01, L02, L03, L04, L09, L10, L11 we will not store the Rate of Tax
 -- in the table pay_pl_paye_details_f
     if l_contract_type in ('L01','L02','L03','L04','L09','L10','L11') then
        l_rate_of_tax := NULL;
     else
        l_rate_of_tax := p_rate_of_tax;
     end if;


 -- Calling the Create PAYE API

   pay_pl_paye_api.create_pl_paye_details
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_contract_category            => p_contract_category
    ,p_per_or_asg_id                => p_assignment_id
    ,p_business_group_id            => l_business_group_id
    ,p_tax_reduction                => null
    ,p_tax_calc_with_spouse_child   => null
    ,p_income_reduction             => null
    ,p_income_reduction_amount      => null
    ,p_rate_of_tax                  => l_rate_of_tax
    ,p_paye_details_id              => l_paye_details_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_effective_date_warning		  => p_effective_date_warning
    );

end create_pl_lump_paye_details;
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_f_lump_paye_details >---------------------|
-- ----------------------------------------------------------------------------
procedure create_pl_f_lump_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'F_LUMP'
  ,p_assignment_id                 in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean)
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_leg_code          pay_user_column_instances_f.legislation_code%TYPE;
 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_paye_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_f_lump_paye_details';

 cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f    paf
         , per_business_groups_perf bus
     where paf.assignment_id   = p_assignment_id
     and   l_effective_date      between paf.effective_start_date
                                 and     paf.effective_end_date
     and   bus.business_group_id = paf.business_group_id;

begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

 l_leg_code        := 'PL';

 l_effective_date  := trunc(p_effective_date);

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375848_PL_INVALID_ASG');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

 -- Since we will be re-setting the effective_start_date to the Assignment's start date,
 -- we first validate the assignment id before deriving the effective_start_date.

   pay_ppd_bus.chk_per_asg_id(p_effective_date        => l_effective_date
                             ,p_per_or_asg_id         => p_assignment_id
                             ,p_contract_category     => 'F_LUMP'
                             ,p_business_group_id     => l_business_group_id
                             ,p_object_version_number => l_object_version_number);




 -- Calling the Create PAYE API

   pay_pl_paye_api.create_pl_paye_details
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_contract_category            => p_contract_category
    ,p_per_or_asg_id                => p_assignment_id
    ,p_business_group_id            => l_business_group_id
    ,p_tax_reduction                => null
    ,p_tax_calc_with_spouse_child   => null
    ,p_income_reduction             => null
    ,p_income_reduction_amount      => null
    ,p_rate_of_tax                  => p_rate_of_tax
    ,p_paye_details_id              => l_paye_details_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_effective_date_warning		  => p_effective_date_warning
    );

end create_pl_f_lump_paye_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_normal_paye_details >---------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_normal_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'NORMAL'
  ,p_person_id		               in     number
  ,p_tax_reduction				   in     varchar2 default 'NOTAX'
  ,p_tax_calc_with_spouse_child    in     varchar2 default 'N'
  ,p_income_reduction	           in     varchar2 default 'N01'
  ,p_rate_of_tax			       in     varchar2 default 'N01'
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean
  )
 is
 --
 -- Declare cursors and local variables
 --

 l_business_group_id per_business_groups.business_group_id%TYPE;
 l_legislation_code  per_business_groups.legislation_code%TYPE;
 l_leg_code          pay_user_column_instances_f.legislation_code%TYPE;
 l_effective_date         date;
 l_effective_start_date   date;
 l_effective_end_date     date;
 l_object_version_number  number;
 l_paye_details_id         number;
 l_proc                   varchar2(72) := g_package||'create_pl_paye_sii_details';

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

 l_leg_code        := 'PL';
 l_effective_date  := trunc(p_effective_date);

  open csr_get_derived_details;
    fetch csr_get_derived_details into l_business_group_id,l_legislation_code;
 --
   if csr_get_derived_details%NOTFOUND then
    --
     close csr_get_derived_details;
    --
    hr_utility.set_message(801,'PAY_375848_PL_INVALID_ASG');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
-- Since we will be re-setting the effective_start_date to the Person's start date,
 -- we first validate the person id before deriving the effective_start_date.

  pay_ppd_bus.chk_per_asg_id(p_effective_date         => l_effective_date
                             ,p_per_or_asg_id         => p_person_id
                             ,p_contract_category     => 'NORMAL'
                             ,p_business_group_id     => l_business_group_id
                             ,p_object_version_number => l_object_version_number);


 -- Calling the Create PAYE API

  pay_pl_paye_api.create_pl_paye_details
     (p_validate                      => p_validate
     ,p_effective_date                => l_effective_date
     ,p_contract_category             => p_contract_category
     ,p_per_or_asg_id                 => p_person_id
     ,p_business_group_id             => l_business_group_id
     ,p_tax_reduction                 => p_tax_reduction
     ,p_tax_calc_with_spouse_child    => p_tax_calc_with_spouse_child
     ,p_income_reduction              => p_income_reduction
     ,p_income_reduction_amount       => null
     ,p_rate_of_tax                   => p_rate_of_tax
     ,p_paye_details_id               => l_paye_details_id
     ,p_object_version_number         => l_object_version_number
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_effective_date_warning		  => p_effective_date_warning
     );

end create_pl_normal_paye_details;
end PAY_PL_PAYE_API;

/
