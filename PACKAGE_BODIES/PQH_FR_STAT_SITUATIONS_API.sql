--------------------------------------------------------
--  DDL for Package Body PQH_FR_STAT_SITUATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_STAT_SITUATIONS_API" as
/* $Header: pqstsapi.pkb 120.0 2005/05/29 02:43:03 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_fr_stat_situations_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_STATUTORY_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_statutory_situation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date     default sysdate
  ,p_business_group_id              in     number
  ,p_situation_name                 in     varchar2
  ,p_type_of_ps                     in     varchar2
  ,p_situation_type                 in     varchar2
  ,p_sub_type                       in     varchar2 default null
  ,p_source                         in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_reason                         in     varchar2 default null
  ,p_is_default                     in     varchar2 default null
  ,p_date_from                      in     date     default null
  ,p_date_to                        in     date     default null
  ,p_request_type                   in     varchar2 default null
  ,p_employee_agreement_needed      in     varchar2 default null
  ,p_manager_agreement_needed       in     varchar2 default null
  ,p_print_arrette                  in     varchar2 default null
  ,p_reserve_position               in     varchar2 default null
  ,p_allow_progressions             in     varchar2 default null
  ,p_extend_probation_period        in     varchar2 default null
  ,p_remuneration_paid              in     varchar2 default null
  ,p_pay_share                      in     number   default null
  ,p_pay_periods                    in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_first_period_max_duration      in     number   default null
  ,p_min_duration_per_request       in     number   default null
  ,p_max_duration_per_request       in     number   default null
  ,p_max_duration_whole_career      in     number   default null
  ,p_renewable_allowed              in     varchar2 default null
  ,p_max_no_of_renewals             in     number   default null
  ,p_max_duration_per_renewal       in     number   default null
  ,p_max_tot_continuous_duration    in     number   default null
  ,p_remunerate_assign_status_id    in     number   default null
  ,p_statutory_situation_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_statutory_situation';
  l_object_version_number number(9);
  l_statutory_situation_id pqh_fr_stat_situations.statutory_situation_id%type;

begin

  g_debug := hr_utility.debug_enabled;

 if g_debug then
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 End if;

  --
  -- Issue a savepoint
  --
  savepoint create_statutory_situation;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_situations_bk1.create_statutory_situation_b
      (  p_effective_date               =>  l_effective_date
        ,p_business_group_id            =>  p_business_group_id
        ,p_situation_name               =>  p_situation_name
        ,p_type_of_ps                   =>  p_type_of_ps
        ,p_situation_type               =>   p_situation_type
        ,p_sub_type                     =>   p_sub_type
        ,p_source                       =>   p_source
        ,p_location                     =>   p_location
        ,p_reason                       =>   p_reason
        ,p_is_default                   =>   p_is_default
        ,p_date_from                    =>   p_date_from
        ,p_date_to                      =>   p_date_to
        ,p_request_type                 =>   p_request_type
        ,p_employee_agreement_needed    =>   p_employee_agreement_needed
        ,p_manager_agreement_needed     =>   p_manager_agreement_needed
        ,p_print_arrette                =>   p_print_arrette
        ,p_reserve_position             =>   p_reserve_position
        ,p_allow_progressions           =>   p_allow_progressions
        ,p_extend_probation_period      =>   p_extend_probation_period
        ,p_remuneration_paid            =>   p_remuneration_paid
        ,p_pay_share                    =>   p_pay_share
        ,p_pay_periods                  =>   p_pay_periods
        ,p_frequency                    =>   p_frequency
        ,p_first_period_max_duration    =>   p_first_period_max_duration
        ,p_min_duration_per_request     =>   p_min_duration_per_request
        ,p_max_duration_per_request     =>   p_max_duration_per_request
        ,p_max_duration_whole_career    =>   p_max_duration_whole_career
        ,p_renewable_allowed            =>   p_renewable_allowed
        ,p_max_no_of_renewals           =>   p_max_no_of_renewals
        ,p_max_duration_per_renewal     =>   p_max_duration_per_renewal
        ,p_max_tot_continuous_duration  =>   p_max_tot_continuous_duration
        ,p_remunerate_assign_status_id  =>   p_remunerate_assign_status_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STATUTORY_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
          pqh_sts_ins.ins
          		(p_effective_date            =>    p_effective_date
          		,p_business_group_id         =>    p_business_group_id
          		,p_situation_name            =>    p_situation_name
          		,p_type_of_ps                =>    p_type_of_ps
          		,p_situation_type            =>    p_situation_type
          		,p_sub_type                  =>    p_sub_type
          		,p_source                    =>    p_source
          		,p_location                  =>    p_location
          		,p_reason                    =>    p_reason
          		,p_is_default                =>    p_is_default
          		,p_date_from                 =>    p_date_from
          		,p_date_to                   =>    p_date_to
          		,p_request_type              =>    p_request_type
          		,p_employee_agreement_needed =>    p_employee_agreement_needed
          		,p_manager_agreement_needed  =>    p_manager_agreement_needed
          		,p_print_arrette             =>    p_print_arrette
          		,p_reserve_position          =>    p_reserve_position
          		,p_allow_progressions        =>    p_allow_progressions
          		,p_extend_probation_period   =>    p_extend_probation_period
          		,p_remuneration_paid         =>    p_remuneration_paid
          		,p_pay_share                 =>    p_pay_share
          		,p_pay_periods               =>    p_pay_periods
          		,p_frequency                 =>    p_frequency
          		,p_first_period_max_duration =>    p_first_period_max_duration
          		,p_min_duration_per_request  =>    p_min_duration_per_request
          		,p_max_duration_per_request  =>    p_max_duration_per_request
          		,p_max_duration_whole_career   =>  p_max_duration_whole_career
          		,p_renewable_allowed           =>  p_renewable_allowed
          		,p_max_no_of_renewals          =>  p_max_no_of_renewals
          		,p_max_duration_per_renewal    =>  p_max_duration_per_renewal
          		,p_max_tot_continuous_duration =>  p_max_tot_continuous_duration
          		,p_statutory_situation_id      =>  l_statutory_situation_id
          		,p_object_version_number       =>  l_object_version_number
                  ,p_remunerate_assign_status_id =>  p_remunerate_assign_status_id
          		);



  --
  -- Call After Process User Hook
  --
  begin
    pqh_fr_stat_situations_bk1.create_statutory_situation_a
       ( p_effective_date               =>   l_effective_date
        ,p_business_group_id            =>   p_business_group_id
        ,p_situation_name               =>   p_situation_name
        ,p_type_of_ps                   =>   p_type_of_ps
        ,p_situation_type               =>   p_situation_type
        ,p_sub_type                     =>   p_sub_type
        ,p_source                       =>   p_source
        ,p_location                     =>   p_location
        ,p_reason                       =>   p_reason
  	  ,p_is_default                   =>   p_is_default
        ,p_date_from                    =>   p_date_from
        ,p_date_to                      =>   p_date_to
        ,p_request_type                 =>   p_request_type
        ,p_employee_agreement_needed    =>   p_employee_agreement_needed
        ,p_manager_agreement_needed     =>   p_manager_agreement_needed
        ,p_print_arrette                =>   p_print_arrette
        ,p_reserve_position             =>   p_reserve_position
	  ,p_allow_progressions           =>   p_allow_progressions
        ,p_extend_probation_period      =>   p_extend_probation_period
        ,p_remuneration_paid            =>   p_remuneration_paid
        ,p_pay_share                    =>   p_pay_share
        ,p_pay_periods                  =>   p_pay_periods
        ,p_frequency                    =>   p_frequency
        ,p_first_period_max_duration    =>   p_first_period_max_duration
        ,p_min_duration_per_request     =>   p_min_duration_per_request
        ,p_max_duration_per_request     =>   p_max_duration_per_request
        ,p_max_duration_whole_career    =>   p_max_duration_whole_career
        ,p_renewable_allowed            =>   p_renewable_allowed
        ,p_max_no_of_renewals           =>   p_max_no_of_renewals
        ,p_max_duration_per_renewal     =>   p_max_duration_per_renewal
        ,p_max_tot_continuous_duration  =>   p_max_tot_continuous_duration
        ,p_statutory_situation_id       =>   l_statutory_situation_id
        ,p_object_version_number        =>  l_object_version_number
        ,p_remunerate_assign_status_id  =>   p_remunerate_assign_status_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STATUTORY_SITUATION'
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
  p_statutory_situation_id := l_statutory_situation_id;
  p_object_version_number  := l_object_version_number;
    --
 if g_debug then
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 --
 End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_statutory_situation_id := null;
  p_object_version_number  := null;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_statutory_situation_id := null;
  p_object_version_number  := null;

    raise;

end CREATE_STATUTORY_SITUATION;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_STATUTORY_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_statutory_situation
  ( p_validate                     in     boolean   default false
   ,p_effective_date               in     date      default sysdate
   ,p_statutory_situation_id       in     number
   ,p_object_version_number        in out nocopy number
   ,p_business_group_id            in     number    default hr_api.g_number
   ,p_situation_name               in     varchar2  default hr_api.g_varchar2
   ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
   ,p_situation_type               in     varchar2  default hr_api.g_varchar2
   ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
   ,p_source                       in     varchar2  default hr_api.g_varchar2
   ,p_location                     in     varchar2  default hr_api.g_varchar2
   ,p_reason                       in     varchar2  default hr_api.g_varchar2
   ,p_is_default                   in     varchar2  default hr_api.g_varchar2
   ,p_date_from                    in     date      default hr_api.g_date
   ,p_date_to                      in     date      default hr_api.g_date
   ,p_request_type                 in     varchar2  default hr_api.g_varchar2
   ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
   ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
   ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
   ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
   ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
   ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
   ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
   ,p_pay_share                    in     number    default hr_api.g_number
   ,p_pay_periods                  in     number    default hr_api.g_number
   ,p_frequency                    in     varchar2  default hr_api.g_varchar2
   ,p_first_period_max_duration    in     number    default hr_api.g_number
   ,p_min_duration_per_request     in     number    default hr_api.g_number
   ,p_max_duration_per_request     in     number    default hr_api.g_number
   ,p_max_duration_whole_career    in     number    default hr_api.g_number
   ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
   ,p_max_no_of_renewals           in     number    default hr_api.g_number
   ,p_max_duration_per_renewal     in     number    default hr_api.g_number
   ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
   ,p_remunerate_assign_status_id  in     number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_statutory_situation';
  l_object_version_number number(9);
  l_in_out_ovn 		number(9);
  l_statutory_situation_id pqh_fr_stat_situations.statutory_situation_id%type;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;
  --
  -- Issue a savepoint
  --
  savepoint update_statutory_situation;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_object_version_number := p_object_version_number;


  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_situations_bk2.update_statutory_situation_b
      (  p_effective_date               =>   l_effective_date
        ,p_business_group_id            =>   p_business_group_id
        ,p_situation_name               =>   p_situation_name
        ,p_type_of_ps                   =>   p_type_of_ps
        ,p_situation_type               =>   p_situation_type
        ,p_sub_type                     =>   p_sub_type
        ,p_source                       =>   p_source
        ,p_location                     =>   p_location
        ,p_reason                       =>   p_reason
        ,p_is_default                   =>   p_is_default
        ,p_date_from                    =>   p_date_from
        ,p_date_to                      =>   p_date_to
        ,p_request_type                 =>   p_request_type
        ,p_employee_agreement_needed    =>   p_employee_agreement_needed
        ,p_manager_agreement_needed     =>   p_manager_agreement_needed
        ,p_print_arrette                =>   p_print_arrette
        ,p_reserve_position             =>   p_reserve_position
        ,p_allow_progressions           =>   p_allow_progressions
        ,p_extend_probation_period      =>   p_extend_probation_period
        ,p_remuneration_paid            =>   p_remuneration_paid
        ,p_pay_share                    =>   p_pay_share
        ,p_pay_periods                  =>   p_pay_periods
        ,p_frequency                    =>   p_frequency
        ,p_first_period_max_duration    =>   p_first_period_max_duration
        ,p_min_duration_per_request     =>   p_min_duration_per_request
        ,p_max_duration_per_request     =>   p_max_duration_per_request
        ,p_max_duration_whole_career    =>   p_max_duration_whole_career
        ,p_renewable_allowed            =>   p_renewable_allowed
        ,p_max_no_of_renewals           =>   p_max_no_of_renewals
        ,p_max_duration_per_renewal     =>   p_max_duration_per_renewal
        ,p_max_tot_continuous_duration  =>   p_max_tot_continuous_duration
        ,p_statutory_situation_id       =>   p_statutory_situation_id
        ,p_object_version_number        =>   l_object_version_number
        ,p_remunerate_assign_status_id  =>   p_remunerate_assign_status_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STATUTORY_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	   pqh_sts_upd.upd
	   (
	     p_effective_date               =>       l_effective_date
	    ,p_statutory_situation_id      	=>	   p_statutory_situation_id
	    ,p_object_version_number       	=>	   l_object_version_number
	    ,p_business_group_id           	=>	   p_business_group_id
	    ,p_situation_name              	=>	   p_situation_name
	    ,p_type_of_ps                  	=>	   p_type_of_ps
	    ,p_situation_type              	=>	   p_situation_type
	    ,p_sub_type                    	=>	   p_sub_type
	    ,p_source                      	=>	   p_source
	    ,p_location                    	=>	   p_location
	    ,p_reason                      	=>	   p_reason
          ,p_is_default                   =>       p_is_default
	    ,p_date_from                   	=>	   p_date_from
	    ,p_date_to                     	=>	   p_date_to
	    ,p_request_type                	=>	   p_request_type
	    ,p_employee_agreement_needed   	=>	   p_employee_agreement_needed
	    ,p_manager_agreement_needed    	=>	   p_manager_agreement_needed
	    ,p_print_arrette               	=>	   p_print_arrette
	    ,p_reserve_position            	=>	   p_reserve_position
	    ,p_allow_progressions           =>       p_allow_progressions
          ,p_extend_probation_period      =>       p_extend_probation_period
	    ,p_remuneration_paid           	=>	   p_remuneration_paid
	    ,p_pay_share                   	=>	   p_pay_share
	    ,p_pay_periods                 	=>	   p_pay_periods
	    ,p_frequency                   	=>	   p_frequency
	    ,p_first_period_max_duration   	=>	   p_first_period_max_duration
	    ,p_min_duration_per_request    	=>	   p_min_duration_per_request
	    ,p_max_duration_per_request    	=>	   p_max_duration_per_request
	    ,p_max_duration_whole_career   	=>	   p_max_duration_whole_career
	    ,p_renewable_allowed           	=>	   p_renewable_allowed
	    ,p_max_no_of_renewals          	=>	   p_max_no_of_renewals
	    ,p_max_duration_per_renewal    	=>	   p_max_duration_per_renewal
	    ,p_max_tot_continuous_duration 	=>	   p_max_tot_continuous_duration
          ,p_remunerate_assign_status_id  =>       p_remunerate_assign_status_id
	    );



  --
  -- Call After Process User Hook
  --
  begin
    pqh_fr_stat_situations_bk2.update_statutory_situation_a
       ( p_effective_date               =>   l_effective_date
        ,p_business_group_id            =>   p_business_group_id
        ,p_situation_name               =>   p_situation_name
        ,p_type_of_ps                   =>   p_type_of_ps
        ,p_situation_type               =>   p_situation_type
        ,p_sub_type                     =>   p_sub_type
        ,p_source                       =>   p_source
        ,p_location                     =>   p_location
        ,p_reason                       =>   p_reason
        ,p_is_default                   =>   p_is_default
        ,p_date_from                    =>   p_date_from
        ,p_date_to                      =>   p_date_to
        ,p_request_type                 =>   p_request_type
        ,p_employee_agreement_needed    =>   p_employee_agreement_needed
        ,p_manager_agreement_needed     =>   p_manager_agreement_needed
        ,p_print_arrette                =>   p_print_arrette
        ,p_reserve_position             =>   p_reserve_position
        ,p_allow_progressions           =>   p_allow_progressions
        ,p_extend_probation_period      =>   p_extend_probation_period
        ,p_remuneration_paid            =>   p_remuneration_paid
        ,p_pay_share                    =>   p_pay_share
        ,p_pay_periods                  =>   p_pay_periods
        ,p_frequency                    =>   p_frequency
        ,p_first_period_max_duration    =>   p_first_period_max_duration
        ,p_min_duration_per_request     =>   p_min_duration_per_request
        ,p_max_duration_per_request     =>   p_max_duration_per_request
        ,p_max_duration_whole_career    =>   p_max_duration_whole_career
        ,p_renewable_allowed            =>   p_renewable_allowed
        ,p_max_no_of_renewals           =>   p_max_no_of_renewals
        ,p_max_duration_per_renewal     =>   p_max_duration_per_renewal
        ,p_max_tot_continuous_duration  =>   p_max_tot_continuous_duration
        ,p_statutory_situation_id       =>   p_statutory_situation_id
        ,p_object_version_number        =>   l_object_version_number
        ,p_remunerate_assign_status_id  =>   p_remunerate_assign_status_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STATUTORY_SITUATION'
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
  p_object_version_number  := l_object_version_number;
    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   p_object_version_number  := l_object_version_number;

   if g_debug then
   --
   hr_utility.set_location(' Leaving:'||l_proc, 80);
   --
   End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
     p_object_version_number  := l_object_version_number;

    raise;

end UPDATE_STATUTORY_SITUATION;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_STATUTORY_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_statutory_situation
    (p_validate                      in     boolean  default false
    ,p_statutory_situation_id               in     number
    ,p_object_version_number                in     number
    ) is

  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_statutory_situation';
  l_object_version_number number(9);
  l_statutory_situation_id pqh_fr_stat_situations.statutory_situation_id%type;

  --
  Cursor Csr_Any_Civil_Servant_On_Sit IS
  Select null
  From pqh_fr_emp_stat_situations
  Where statutory_situation_id = p_statutory_situation_id;
  --
  l_temp varchar2(1);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint delete_statutory_situation;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

    l_object_version_number := p_object_version_number;

    -- Adding Validation
       Open Csr_Any_Civil_Servant_On_Sit;
         Fetch Csr_Any_Civil_Servant_On_Sit into l_temp;
       If Csr_Any_Civil_Servant_On_Sit%FOUND Then
       --
          fnd_message.set_name('PQH','PQH_FR_CIVIL_SERVANT_ONSIT');
           hr_multi_message.add();
       --
       End If;
  --
  -- Truncate the time portion from all IN date parameters
  --
 -- l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_situations_bk3.delete_statutory_situation_b
      (  p_statutory_situation_id       =>   p_statutory_situation_id
	,p_object_version_number	=>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STATUTORY_SITUATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	   pqh_sts_del.del
	   (
	     p_statutory_situation_id      	=>	   p_statutory_situation_id
	    ,p_object_version_number       	=>	   l_object_version_number
	   );



  --
  -- Call After Process User Hook
  --
  begin
      pqh_fr_stat_situations_bk3.delete_statutory_situation_a
         (
         p_statutory_situation_id       =>   p_statutory_situation_id
   	,p_object_version_number	=>   l_object_version_number
         );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STATUTORY_SITUATION'
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
  -- p_object_version_number  := l_object_version_number;
    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  if g_debug then
  --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_STATUTORY_SITUATION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    raise;

end DELETE_STATUTORY_SITUATION;
--

end PQH_FR_STAT_SITUATIONS_API;

/
