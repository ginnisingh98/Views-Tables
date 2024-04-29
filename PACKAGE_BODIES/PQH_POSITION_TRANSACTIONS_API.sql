--------------------------------------------------------
--  DDL for Package Body PQH_POSITION_TRANSACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_POSITION_TRANSACTIONS_API" as
/* $Header: pqptxapi.pkb 115.12 2002/12/06 18:07:14 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_position_transactions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_position_transaction >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position_transaction
  (p_validate                       in  boolean   default false
  ,p_position_transaction_id        out nocopy number
  ,p_action_date                    in  date      default null
  ,p_position_id                    in  number    default null
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id                  in  number    default null
  ,p_job_id                         in  number    default null
  ,p_location_id                    in  number    default null
  ,p_organization_id                in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_definition_id         in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id          in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_country1                       in  varchar2  default null
  ,p_country2                       in  varchar2  default null
  ,p_country3                       in  varchar2  default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_date_effective                 in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_fte_capacity                   in  varchar2  default null
  ,p_location1                      in  varchar2  default null
  ,p_location2                      in  varchar2  default null
  ,p_location3                      in  varchar2  default null
  ,p_max_persons                    in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_other_requirements             in  varchar2  default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_passport_required              in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default null
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_relocate_domestically          in  varchar2  default null
  ,p_relocate_internationally       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_service_minimum                in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_transaction_status             in  varchar2  default null
  ,p_travel_required                in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_any_country               in  varchar2  default null
  ,p_work_any_location              in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_schedule                  in  varchar2  default null
  ,p_work_duration                  in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  ,p_wf_transaction_category_id     in  number    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_position_transaction_id pqh_position_transactions.position_transaction_id%TYPE;
  l_proc varchar2(72) := g_package||'create_position_transaction';
  l_object_version_number pqh_position_transactions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_position_transaction;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_position_transaction
    --
    pqh_position_transactions_bk1.create_position_transaction_b
      (
       p_action_date                    =>  p_action_date
      ,p_position_id                    =>  p_position_id
      ,p_availability_status_id         =>  p_availability_status_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id                  =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  p_position_definition_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id          =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_country1                       =>  p_country1
      ,p_country2                       =>  p_country2
      ,p_country3                       =>  p_country3
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_date_effective                 =>  p_date_effective
      ,p_date_end                       =>  p_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_fte_capacity                   =>  p_fte_capacity
      ,p_location1                      =>  p_location1
      ,p_location2                      =>  p_location2
      ,p_location3                      =>  p_location3
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_other_requirements             =>  p_other_requirements
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_passport_required              =>  p_passport_required
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_relocate_domestically          =>  p_relocate_domestically
      ,p_relocate_internationally       =>  p_relocate_internationally
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_service_minimum                =>  p_service_minimum
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_transaction_status             =>  p_transaction_status
      ,p_travel_required                =>  p_travel_required
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_any_country               =>  p_work_any_country
      ,p_work_any_location              =>  p_work_any_location
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_schedule                  =>  p_work_schedule
      ,p_work_duration                  =>  p_work_duration
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_pay_basis_id                   => p_pay_basis_id
      ,p_supervisor_id                  => p_supervisor_id
      ,p_wf_transaction_category_id     => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POSITION_TRANSACTION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_position_transaction
    --
  end;
  --
  pqh_ptx_ins.ins
    (
     p_position_transaction_id       => l_position_transaction_id
    ,p_action_date                   => p_action_date
    ,p_position_id                   => p_position_id
    ,p_availability_status_id        => p_availability_status_id
    ,p_business_group_id             => p_business_group_id
    ,p_entry_step_id                 => p_entry_step_id
    ,p_entry_grade_rule_id                 => p_entry_grade_rule_id
    ,p_job_id                        => p_job_id
    ,p_location_id                   => p_location_id
    ,p_organization_id               => p_organization_id
    ,p_pay_freq_payroll_id           => p_pay_freq_payroll_id
    ,p_position_definition_id        => p_position_definition_id
    ,p_prior_position_id             => p_prior_position_id
    ,p_relief_position_id            => p_relief_position_id
    ,p_entry_grade_id         => p_entry_grade_id
    ,p_successor_position_id         => p_successor_position_id
    ,p_supervisor_position_id        => p_supervisor_position_id
    ,p_amendment_date                => p_amendment_date
    ,p_amendment_recommendation      => p_amendment_recommendation
    ,p_amendment_ref_number          => p_amendment_ref_number
    ,p_avail_status_prop_end_date    => p_avail_status_prop_end_date
    ,p_bargaining_unit_cd            => p_bargaining_unit_cd
    ,p_comments                      => p_comments
    ,p_country1                      => p_country1
    ,p_country2                      => p_country2
    ,p_country3                      => p_country3
    ,p_current_job_prop_end_date     => p_current_job_prop_end_date
    ,p_current_org_prop_end_date     => p_current_org_prop_end_date
    ,p_date_effective                => p_date_effective
    ,p_date_end                      => p_date_end
    ,p_earliest_hire_date            => p_earliest_hire_date
    ,p_fill_by_date                  => p_fill_by_date
    ,p_frequency                     => p_frequency
    ,p_fte                           => p_fte
    ,p_fte_capacity                  => p_fte_capacity
    ,p_location1                     => p_location1
    ,p_location2                     => p_location2
    ,p_location3                     => p_location3
    ,p_max_persons                   => p_max_persons
    ,p_name                          => p_name
    ,p_other_requirements            => p_other_requirements
    ,p_overlap_period                => p_overlap_period
    ,p_overlap_unit_cd               => p_overlap_unit_cd
    ,p_passport_required             => p_passport_required
    ,p_pay_term_end_day_cd           => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd         => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag      => p_permanent_temporary_flag
    ,p_permit_recruitment_flag       => p_permit_recruitment_flag
    ,p_position_type                 => p_position_type
    ,p_posting_description           => p_posting_description
    ,p_probation_period              => p_probation_period
    ,p_probation_period_unit_cd      => p_probation_period_unit_cd
    ,p_relocate_domestically         => p_relocate_domestically
    ,p_relocate_internationally      => p_relocate_internationally
    ,p_replacement_required_flag     => p_replacement_required_flag
    ,p_review_flag                   => p_review_flag
    ,p_seasonal_flag                 => p_seasonal_flag
    ,p_security_requirements         => p_security_requirements
    ,p_service_minimum               => p_service_minimum
    ,p_term_start_day_cd             => p_term_start_day_cd
    ,p_term_start_month_cd           => p_term_start_month_cd
    ,p_time_normal_finish            => p_time_normal_finish
    ,p_time_normal_start             => p_time_normal_start
    ,p_transaction_status            => p_transaction_status
    ,p_travel_required               => p_travel_required
    ,p_working_hours                 => p_working_hours
    ,p_works_council_approval_flag   => p_works_council_approval_flag
    ,p_work_any_country              => p_work_any_country
    ,p_work_any_location             => p_work_any_location
    ,p_work_period_type_cd           => p_work_period_type_cd
    ,p_work_schedule                 => p_work_schedule
    ,p_work_duration                 => p_work_duration
    ,p_work_term_end_day_cd          => p_work_term_end_day_cd
    ,p_work_term_end_month_cd        => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff       => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff      => p_proposed_date_for_layoff
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_attribute_category            => p_attribute_category
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_pay_basis_id                   => p_pay_basis_id
    ,p_supervisor_id                  => p_supervisor_id
    ,p_wf_transaction_category_id     => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_position_transaction
    --
    pqh_position_transactions_bk1.create_position_transaction_a
      (
       p_position_transaction_id        =>  l_position_transaction_id
      ,p_action_date                    =>  p_action_date
      ,p_position_id                    =>  p_position_id
      ,p_availability_status_id         =>  p_availability_status_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id                  =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  p_position_definition_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id          =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_country1                       =>  p_country1
      ,p_country2                       =>  p_country2
      ,p_country3                       =>  p_country3
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_date_effective                 =>  p_date_effective
      ,p_date_end                       =>  p_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_fte_capacity                   =>  p_fte_capacity
      ,p_location1                      =>  p_location1
      ,p_location2                      =>  p_location2
      ,p_location3                      =>  p_location3
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_other_requirements             =>  p_other_requirements
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_passport_required              =>  p_passport_required
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_relocate_domestically          =>  p_relocate_domestically
      ,p_relocate_internationally       =>  p_relocate_internationally
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_service_minimum                =>  p_service_minimum
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_transaction_status             =>  p_transaction_status
      ,p_travel_required                =>  p_travel_required
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_any_country               =>  p_work_any_country
      ,p_work_any_location              =>  p_work_any_location
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_schedule                  =>  p_work_schedule
      ,p_work_duration                  =>  p_work_duration
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_pay_basis_id                   => p_pay_basis_id
      ,p_supervisor_id                  => p_supervisor_id
      ,p_wf_transaction_category_id     => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POSITION_TRANSACTION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_position_transaction
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_position_transaction_id := l_position_transaction_id;
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
    ROLLBACK TO create_position_transaction;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_position_transaction_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_position_transaction_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_position_transaction;
    raise;
    --
end create_position_transaction;
-- ----------------------------------------------------------------------------
-- |------------------------< update_position_transaction >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_transaction
  (p_validate                       in  boolean   default false
  ,p_position_transaction_id        in  number
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_availability_status_id         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_entry_step_id                  in  number    default hr_api.g_number
  ,p_entry_grade_rule_id                  in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_location_id                    in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_pay_freq_payroll_id            in  number    default hr_api.g_number
  ,p_position_definition_id         in  number    default hr_api.g_number
  ,p_prior_position_id              in  number    default hr_api.g_number
  ,p_relief_position_id             in  number    default hr_api.g_number
  ,p_entry_grade_id          in  number    default hr_api.g_number
  ,p_successor_position_id          in  number    default hr_api.g_number
  ,p_supervisor_position_id         in  number    default hr_api.g_number
  ,p_amendment_date                 in  date      default hr_api.g_date
  ,p_amendment_recommendation       in  varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number           in  varchar2  default hr_api.g_varchar2
  ,p_avail_status_prop_end_date     in  date      default hr_api.g_date
  ,p_bargaining_unit_cd             in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  long      default null
  ,p_country1                       in  varchar2  default hr_api.g_varchar2
  ,p_country2                       in  varchar2  default hr_api.g_varchar2
  ,p_country3                       in  varchar2  default hr_api.g_varchar2
  ,p_current_job_prop_end_date      in  date      default hr_api.g_date
  ,p_current_org_prop_end_date      in  date      default hr_api.g_date
  ,p_date_effective                 in  date      default hr_api.g_date
  ,p_date_end                       in  date      default hr_api.g_date
  ,p_earliest_hire_date             in  date      default hr_api.g_date
  ,p_fill_by_date                   in  date      default hr_api.g_date
  ,p_frequency                      in  varchar2  default hr_api.g_varchar2
  ,p_fte                            in  number    default hr_api.g_number
  ,p_fte_capacity                   in  varchar2  default hr_api.g_varchar2
  ,p_location1                      in  varchar2  default hr_api.g_varchar2
  ,p_location2                      in  varchar2  default hr_api.g_varchar2
  ,p_location3                      in  varchar2  default hr_api.g_varchar2
  ,p_max_persons                    in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_other_requirements             in  varchar2  default hr_api.g_varchar2
  ,p_overlap_period                 in  number    default hr_api.g_number
  ,p_overlap_unit_cd                in  varchar2  default hr_api.g_varchar2
  ,p_passport_required              in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd            in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd          in  varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag       in  varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag        in  varchar2  default hr_api.g_varchar2
  ,p_position_type                  in  varchar2  default hr_api.g_varchar2
  ,p_posting_description            in  varchar2  default hr_api.g_varchar2
  ,p_probation_period               in  number    default hr_api.g_number
  ,p_probation_period_unit_cd       in  varchar2  default hr_api.g_varchar2
  ,p_relocate_domestically          in  varchar2  default hr_api.g_varchar2
  ,p_relocate_internationally       in  varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag      in  varchar2  default hr_api.g_varchar2
  ,p_review_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_security_requirements          in  varchar2  default hr_api.g_varchar2
  ,p_service_minimum                in  varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd              in  varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd            in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish             in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_start              in  varchar2  default hr_api.g_varchar2
  ,p_transaction_status             in  varchar2  default hr_api.g_varchar2
  ,p_travel_required                in  varchar2  default hr_api.g_varchar2
  ,p_working_hours                  in  number    default hr_api.g_number
  ,p_works_council_approval_flag    in  varchar2  default hr_api.g_varchar2
  ,p_work_any_country               in  varchar2  default hr_api.g_varchar2
  ,p_work_any_location              in  varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_work_schedule                  in  varchar2  default hr_api.g_varchar2
  ,p_work_duration                  in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd           in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd         in  varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff        in  number    default hr_api.g_number
  ,p_proposed_date_for_layoff       in  date      default hr_api.g_date
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_pay_basis_id                   in  number    default hr_api.g_number
  ,p_supervisor_id                  in  number    default hr_api.g_number
  ,p_wf_transaction_category_id     in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_position_transaction';
  l_object_version_number pqh_position_transactions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_position_transaction;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_position_transaction
    --
    pqh_position_transactions_bk2.update_position_transaction_b
      (
       p_position_transaction_id        =>  p_position_transaction_id
      ,p_action_date                    =>  p_action_date
      ,p_position_id                    =>  p_position_id
      ,p_availability_status_id         =>  p_availability_status_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id                  =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  p_position_definition_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id          =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_country1                       =>  p_country1
      ,p_country2                       =>  p_country2
      ,p_country3                       =>  p_country3
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_date_effective                 =>  p_date_effective
      ,p_date_end                       =>  p_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_fte_capacity                   =>  p_fte_capacity
      ,p_location1                      =>  p_location1
      ,p_location2                      =>  p_location2
      ,p_location3                      =>  p_location3
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_other_requirements             =>  p_other_requirements
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_passport_required              =>  p_passport_required
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_relocate_domestically          =>  p_relocate_domestically
      ,p_relocate_internationally       =>  p_relocate_internationally
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_service_minimum                =>  p_service_minimum
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_transaction_status             =>  p_transaction_status
      ,p_travel_required                =>  p_travel_required
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_any_country               =>  p_work_any_country
      ,p_work_any_location              =>  p_work_any_location
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_schedule                  =>  p_work_schedule
      ,p_work_duration                  =>  p_work_duration
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
    ,p_pay_basis_id                   => p_pay_basis_id
    ,p_supervisor_id                  => p_supervisor_id
    ,p_wf_transaction_category_id     => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSITION_TRANSACTION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_position_transaction
    --
  end;
  --
  pqh_ptx_upd.upd
    (
     p_position_transaction_id       => p_position_transaction_id
    ,p_action_date                   => p_action_date
    ,p_position_id                   => p_position_id
    ,p_availability_status_id        => p_availability_status_id
    ,p_business_group_id             => p_business_group_id
    ,p_entry_step_id                 => p_entry_step_id
    ,p_entry_grade_rule_id                 => p_entry_grade_rule_id
    ,p_job_id                        => p_job_id
    ,p_location_id                   => p_location_id
    ,p_organization_id               => p_organization_id
    ,p_pay_freq_payroll_id           => p_pay_freq_payroll_id
    ,p_position_definition_id        => p_position_definition_id
    ,p_prior_position_id             => p_prior_position_id
    ,p_relief_position_id            => p_relief_position_id
    ,p_entry_grade_id         => p_entry_grade_id
    ,p_successor_position_id         => p_successor_position_id
    ,p_supervisor_position_id        => p_supervisor_position_id
    ,p_amendment_date                => p_amendment_date
    ,p_amendment_recommendation      => p_amendment_recommendation
    ,p_amendment_ref_number          => p_amendment_ref_number
    ,p_avail_status_prop_end_date    => p_avail_status_prop_end_date
    ,p_bargaining_unit_cd            => p_bargaining_unit_cd
    ,p_comments                      => p_comments
    ,p_country1                      => p_country1
    ,p_country2                      => p_country2
    ,p_country3                      => p_country3
    ,p_current_job_prop_end_date     => p_current_job_prop_end_date
    ,p_current_org_prop_end_date     => p_current_org_prop_end_date
    ,p_date_effective                => p_date_effective
    ,p_date_end                      => p_date_end
    ,p_earliest_hire_date            => p_earliest_hire_date
    ,p_fill_by_date                  => p_fill_by_date
    ,p_frequency                     => p_frequency
    ,p_fte                           => p_fte
    ,p_fte_capacity                  => p_fte_capacity
    ,p_location1                     => p_location1
    ,p_location2                     => p_location2
    ,p_location3                     => p_location3
    ,p_max_persons                   => p_max_persons
    ,p_name                          => p_name
    ,p_other_requirements            => p_other_requirements
    ,p_overlap_period                => p_overlap_period
    ,p_overlap_unit_cd               => p_overlap_unit_cd
    ,p_passport_required             => p_passport_required
    ,p_pay_term_end_day_cd           => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd         => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag      => p_permanent_temporary_flag
    ,p_permit_recruitment_flag       => p_permit_recruitment_flag
    ,p_position_type                 => p_position_type
    ,p_posting_description           => p_posting_description
    ,p_probation_period              => p_probation_period
    ,p_probation_period_unit_cd      => p_probation_period_unit_cd
    ,p_relocate_domestically         => p_relocate_domestically
    ,p_relocate_internationally      => p_relocate_internationally
    ,p_replacement_required_flag     => p_replacement_required_flag
    ,p_review_flag                   => p_review_flag
    ,p_seasonal_flag                 => p_seasonal_flag
    ,p_security_requirements         => p_security_requirements
    ,p_service_minimum               => p_service_minimum
    ,p_term_start_day_cd             => p_term_start_day_cd
    ,p_term_start_month_cd           => p_term_start_month_cd
    ,p_time_normal_finish            => p_time_normal_finish
    ,p_time_normal_start             => p_time_normal_start
    ,p_transaction_status            => p_transaction_status
    ,p_travel_required               => p_travel_required
    ,p_working_hours                 => p_working_hours
    ,p_works_council_approval_flag   => p_works_council_approval_flag
    ,p_work_any_country              => p_work_any_country
    ,p_work_any_location             => p_work_any_location
    ,p_work_period_type_cd           => p_work_period_type_cd
    ,p_work_schedule                 => p_work_schedule
    ,p_work_duration                 => p_work_duration
    ,p_work_term_end_day_cd          => p_work_term_end_day_cd
    ,p_work_term_end_month_cd        => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff       => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff      => p_proposed_date_for_layoff
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_attribute_category            => p_attribute_category
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_pay_basis_id                  => p_pay_basis_id
    ,p_supervisor_id                 => p_supervisor_id
    ,p_wf_transaction_category_id    => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_position_transaction
    --
    pqh_position_transactions_bk2.update_position_transaction_a
      (
       p_position_transaction_id        =>  p_position_transaction_id
      ,p_action_date                    =>  p_action_date
      ,p_position_id                    =>  p_position_id
      ,p_availability_status_id         =>  p_availability_status_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id            =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  p_position_definition_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id                 =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_country1                       =>  p_country1
      ,p_country2                       =>  p_country2
      ,p_country3                       =>  p_country3
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_date_effective                 =>  p_date_effective
      ,p_date_end                       =>  p_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_fte_capacity                   =>  p_fte_capacity
      ,p_location1                      =>  p_location1
      ,p_location2                      =>  p_location2
      ,p_location3                      =>  p_location3
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_other_requirements             =>  p_other_requirements
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_passport_required              =>  p_passport_required
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_relocate_domestically          =>  p_relocate_domestically
      ,p_relocate_internationally       =>  p_relocate_internationally
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_service_minimum                =>  p_service_minimum
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_transaction_status             =>  p_transaction_status
      ,p_travel_required                =>  p_travel_required
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_any_country               =>  p_work_any_country
      ,p_work_any_location              =>  p_work_any_location
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_schedule                  =>  p_work_schedule
      ,p_work_duration                  =>  p_work_duration
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_pay_basis_id                  => p_pay_basis_id
      ,p_supervisor_id                 => p_supervisor_id
      ,p_wf_transaction_category_id    => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSITION_TRANSACTION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_position_transaction
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
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
    ROLLBACK TO update_position_transaction;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_position_transaction;
    raise;
    --
end update_position_transaction;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_position_transaction >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_transaction
  (p_validate                       in  boolean  default false
  ,p_position_transaction_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_position_transaction';
  l_object_version_number pqh_position_transactions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_position_transaction;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_position_transaction
    --
    pqh_position_transactions_bk3.delete_position_transaction_b
      (
       p_position_transaction_id        =>  p_position_transaction_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSITION_TRANSACTION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_position_transaction
    --
  end;
  --
  pqh_ptx_del.del
    (
     p_position_transaction_id       => p_position_transaction_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_position_transaction
    --
    pqh_position_transactions_bk3.delete_position_transaction_a
      (
       p_position_transaction_id        =>  p_position_transaction_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSITION_TRANSACTION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_position_transaction
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
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
    ROLLBACK TO delete_position_transaction;
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
    ROLLBACK TO delete_position_transaction;
    raise;
    --
end delete_position_transaction;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_position_transaction_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqh_ptx_shd.lck
    (
      p_position_transaction_id                 => p_position_transaction_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_position_transactions_api;

/
