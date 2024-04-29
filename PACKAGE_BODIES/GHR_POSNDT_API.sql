--------------------------------------------------------
--  DDL for Package Body GHR_POSNDT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSNDT_API" as
/* $Header: ghposndt.pkb 120.2 2005/10/06 09:42:02 vravikan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_posndt_api.';
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_position >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_position
  (p_position_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         out nocopy number
  ,p_name                           out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
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
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72);
  l_position_id                    number;
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_position_definition_id         number;
  l_name                           varchar2(2000);
  l_object_version_number          number;


  --
begin
  l_proc := g_package||'create_position';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_position;
  --
  hr_utility.set_location(l_proc, 10);
  --

  -- Set Session Variable so that DB triggers populate hisotry
  -- correctly for the Federal product.

  ghr_Session.set_session_var_for_core
  (p_effective_date    =>  p_date_effective);
  --
 hr_position_api.create_position
  (
     p_position_id                    => l_position_id
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    ,p_position_definition_id         => l_position_definition_id
    ,p_name                           => l_name
    ,p_object_version_number          => l_object_version_number
    ,p_job_id                         => p_job_id
    ,p_organization_id                => p_organization_id
    ,p_effective_date                 => p_effective_date
    ,p_date_effective                 => p_date_effective
    ,p_validate                       => FALSE
    ,p_availability_status_id         => p_availability_status_id
    ,p_business_group_id              => p_business_group_id
    ,p_entry_step_id                  => p_entry_step_id
    ,p_entry_grade_rule_id            => p_entry_grade_rule_id
    ,p_location_id                    => p_location_id
    ,p_pay_freq_payroll_id            => p_pay_freq_payroll_id
    ,p_position_transaction_id        => p_position_transaction_id
    ,p_prior_position_id              => p_prior_position_id
    ,p_relief_position_id             => p_relief_position_id
    ,p_entry_grade_id                 => p_entry_grade_id
    ,p_successor_position_id          => p_successor_position_id
    ,p_supervisor_position_id         => p_supervisor_position_id
    ,p_amendment_date                 => p_amendment_date
    ,p_amendment_recommendation       => p_amendment_recommendation
    ,p_amendment_ref_number           => p_amendment_ref_number
    ,p_bargaining_unit_cd             => p_bargaining_unit_cd
    ,p_comments                       => p_comments
    ,p_current_job_prop_end_date      => p_current_job_prop_end_date
    ,p_current_org_prop_end_date      => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date     => p_avail_status_prop_end_date
    ,p_date_end                       => p_date_end
    ,p_earliest_hire_date             => p_earliest_hire_date
    ,p_fill_by_date                   => p_fill_by_date
    ,p_frequency                      => p_frequency
    ,p_fte                            => p_fte
    ,p_max_persons                    => p_max_persons
    ,p_overlap_period                 => p_overlap_period
    ,p_overlap_unit_cd                => p_overlap_unit_cd
    ,p_pay_term_end_day_cd            => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd          => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag       => p_permanent_temporary_flag
    ,p_permit_recruitment_flag        => p_permit_recruitment_flag
    ,p_position_type                  => p_position_type
    ,p_posting_description            => p_posting_description
    ,p_probation_period               => p_probation_period
    ,p_probation_period_unit_cd       => p_probation_period_unit_cd
    ,p_replacement_required_flag      => p_replacement_required_flag
    ,p_review_flag                    => p_review_flag
    ,p_seasonal_flag                  => p_seasonal_flag
    ,p_security_requirements          => p_security_requirements
    ,p_status                         => p_status
    ,p_term_start_day_cd              => p_term_start_day_cd
    ,p_term_start_month_cd            => p_term_start_month_cd
    ,p_time_normal_finish             => p_time_normal_finish
    ,p_time_normal_start              => p_time_normal_start
    ,p_update_source_cd               => p_update_source_cd
    ,p_working_hours                  => p_working_hours
    ,p_works_council_approval_flag    => p_works_council_approval_flag
    ,p_work_period_type_cd            => p_work_period_type_cd
    ,p_work_term_end_day_cd           => p_work_term_end_day_cd
    ,p_work_term_end_month_cd         => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff        => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff       => p_proposed_date_for_layoff
    ,p_pay_basis_id                   => p_pay_basis_id
    ,p_supervisor_id                  => p_supervisor_id
    ,p_information1                   => p_information1
    ,p_information2                   => p_information2
    ,p_information3                   => p_information3
    ,p_information4                   => p_information4
    ,p_information5                   => p_information5
    ,p_information6                   => p_information6
    ,p_information7                   => p_information7
    ,p_information8                   => p_information8
    ,p_information9                   => p_information9
    ,p_information10                  => p_information10
    ,p_information11                  => p_information11
    ,p_information12                  => p_information12
    ,p_information13                  => p_information13
    ,p_information14                  => p_information14
    ,p_information15                  => p_information15
    ,p_information16                  => p_information16
    ,p_information17                  => p_information17
    ,p_information18                  => p_information18
    ,p_information19                  => p_information19
    ,p_information20                  => p_information20
    ,p_information21                  => p_information21
    ,p_information22                  => p_information22
    ,p_information23                  => p_information23
    ,p_information24                  => p_information24
    ,p_information25                  => p_information25
    ,p_information26                  => p_information26
    ,p_information27                  => p_information27
    ,p_information28                  => p_information29
    ,p_information29                  => p_information29
    ,p_information30                  => p_information30
    ,p_information_category           => p_information_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_attribute21                    => p_attribute21
    ,p_attribute22                    => p_attribute22
    ,p_attribute23                    => p_attribute23
    ,p_attribute24                    => p_attribute24
    ,p_attribute25                    => p_attribute25
    ,p_attribute26                    => p_attribute26
    ,p_attribute27                    => p_attribute27
    ,p_attribute28                    => p_attribute28
    ,p_attribute29                    => p_attribute29
    ,p_attribute30                    => p_attribute30
    ,p_attribute_category             => p_attribute_category
    ,p_segment1                       => p_segment1
    ,p_segment2                       => p_segment2
    ,p_segment3                       => p_segment3
    ,p_segment4                       => p_segment4
    ,p_segment5                       => p_segment5
    ,p_segment6                       => p_segment6
    ,p_segment7                       => p_segment7
    ,p_segment8                       => p_segment8
    ,p_segment9                       => p_segment9
    ,p_segment10                      => p_segment10
    ,p_segment11                      => p_segment11
    ,p_segment12                      => p_segment12
    ,p_segment13                      => p_segment13
    ,p_segment14                      => p_segment14
    ,p_segment15                      => p_segment15
    ,p_segment16                      => p_segment16
    ,p_segment17                      => p_segment17
    ,p_segment18                      => p_segment18
    ,p_segment19                      => p_segment19
    ,p_segment20                      => p_segment20
    ,p_segment21                      => p_segment21
    ,p_segment22                      => p_segment22
    ,p_segment23                      => p_segment23
    ,p_segment24                      => p_segment24
    ,p_segment25                      => p_segment25
    ,p_segment26                      => p_segment26
    ,p_segment27                      => p_segment27
    ,p_segment28                      => p_segment28
    ,p_segment29                      => p_segment29
    ,p_segment30                      => p_segment30
    ,p_concat_segments                => p_concat_segments
    ,p_request_id                     => p_request_id
    ,p_program_application_id         => p_program_application_id
    ,p_program_id                     => p_program_id
    ,p_program_update_date            => p_program_update_date
);

  p_position_id := l_position_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_position_definition_id := l_position_definition_id;
  p_name := l_name;
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(l_proc, 20);
  --
    ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
   p_position_definition_id  :=  p_position_definition_id;
   p_name := p_name;
--
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_name			:= null;
    p_position_id               := null;
    p_position_definition_id    := null;
    p_object_version_number 	:= null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    --
   When others then
     ROLLBACK TO ghr_create_position;
     --
     -- Reset IN OUT parameters and set OUT parameters
     --
     p_name			:= null;
     p_position_id              := null;
     p_position_definition_id   := null;
     p_object_version_number 	:= null;
     p_effective_start_date     := null;
     p_effective_end_date       := null;
    --
     raise;
END create_position;
--

procedure update_position
  (p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_name                           in out nocopy varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
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
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_datetrack_mode                 in  varchar2
  ,p_valid_grades_changed_warning  out nocopy boolean
  ) IS

  l_proc VARCHAR2(200);
  l_effective_start_date           hr_all_positions_f.effective_start_date%type;
  l_effective_end_date             hr_all_positions_f.effective_end_date%type;
  l_position_definition_id         hr_all_positions_f.position_definition_id%type;
  l_name                           hr_positions_f.name%type;
  l_object_version_number          hr_all_positions_f.object_version_number%type;
  l_valid_grades_changed_warning   BOOLEAN;

  BEGIN
	l_proc := 'update_position';
	hr_utility.set_location('Entering:'|| l_proc, 5);

	l_position_definition_id := p_position_definition_id;
	l_name			 := p_name;
	l_object_version_number  := p_object_version_number;

  --
  -- Issue a savepoint if operating in validation only mode.
  --
	savepoint ghr_update_position;
  --
	hr_utility.set_location(l_proc, 10);
  --
  -- Set Session Variable so that DB triggers populate hisotry
  -- correctly for the Federal product.

	ghr_Session.set_session_var_for_core
	  (p_effective_date    =>  p_date_effective);

	-- Calling update position API
	hr_position_api.update_position
	  (p_validate                       => FALSE
	  ,p_position_id                    => p_position_id
	  ,p_effective_start_date           => l_effective_start_date
	  ,p_effective_end_date             => l_effective_end_date
	  ,p_position_definition_id         => p_position_definition_id
	  ,p_valid_grades_changed_warning   => l_valid_grades_changed_warning
	  ,p_name                           => p_name
	  ,p_availability_status_id         => p_availability_status_id
	  ,p_entry_step_id                  => p_entry_step_id
	  ,p_entry_grade_rule_id            => p_entry_grade_rule_id
	  ,p_location_id                    => p_location_id
	  ,p_pay_freq_payroll_id            => p_pay_freq_payroll_id
	  ,p_position_transaction_id        => p_position_transaction_id
	  ,p_prior_position_id              => p_prior_position_id
	  ,p_relief_position_id             => p_relief_position_id
	  ,p_entry_grade_id                 => p_entry_grade_id
	  ,p_successor_position_id          => p_successor_position_id
	  ,p_supervisor_position_id         => p_supervisor_position_id
	  ,p_amendment_date                 => p_amendment_date
	  ,p_amendment_recommendation       => p_amendment_recommendation
	  ,p_amendment_ref_number           => p_amendment_ref_number
	  ,p_bargaining_unit_cd             => p_bargaining_unit_cd
	  ,p_comments                       => p_comments
	  ,p_current_job_prop_end_date      => p_current_job_prop_end_date
	  ,p_current_org_prop_end_date      => p_current_org_prop_end_date
	  ,p_avail_status_prop_end_date     => p_avail_status_prop_end_date
	  ,p_date_effective                 => p_date_effective
	  ,p_date_end                       => p_date_end
	  ,p_earliest_hire_date             => p_earliest_hire_date
	  ,p_fill_by_date                   => p_fill_by_date
	  ,p_frequency                      => p_frequency
	  ,p_fte                            => p_fte
	  ,p_max_persons                    => p_max_persons
	  ,p_overlap_period                 => p_overlap_period
	  ,p_overlap_unit_cd                => p_overlap_unit_cd
	  ,p_pay_term_end_day_cd            => p_pay_term_end_day_cd
	  ,p_pay_term_end_month_cd          => p_pay_term_end_month_cd
	  ,p_permanent_temporary_flag       => p_permanent_temporary_flag
	  ,p_permit_recruitment_flag        => p_permit_recruitment_flag
	  ,p_position_type                  => p_position_type
	  ,p_posting_description            => p_posting_description
	  ,p_probation_period               => p_probation_period
	  ,p_probation_period_unit_cd       => p_probation_period_unit_cd
	  ,p_replacement_required_flag      => p_replacement_required_flag
	  ,p_review_flag                    => p_review_flag
	  ,p_seasonal_flag                  => p_seasonal_flag
	  ,p_security_requirements          => p_security_requirements
	  ,p_status                         => p_status
	  ,p_term_start_day_cd              => p_term_start_day_cd
	  ,p_term_start_month_cd            => p_term_start_month_cd
	  ,p_time_normal_finish             => p_time_normal_finish
	  ,p_time_normal_start              => p_time_normal_start
	  ,p_update_source_cd               => p_update_source_cd
	  ,p_working_hours                  => p_working_hours
	  ,p_works_council_approval_flag    => p_works_council_approval_flag
	  ,p_work_period_type_cd            => p_work_period_type_cd
	  ,p_work_term_end_day_cd           => p_work_term_end_day_cd
	  ,p_work_term_end_month_cd         => p_work_term_end_month_cd
	  ,p_proposed_fte_for_layoff        => p_proposed_fte_for_layoff
	  ,p_proposed_date_for_layoff       => p_proposed_date_for_layoff
	  ,p_pay_basis_id                   => p_pay_basis_id
	  ,p_supervisor_id                  => p_supervisor_id
	  ,p_information1                   => p_information1
	  ,p_information2                   => p_information2
	  ,p_information3                   => p_information3
	  ,p_information4                   => p_information4
	  ,p_information5                   => p_information5
	  ,p_information6                   => p_information6
	  ,p_information7                   => p_information7
	  ,p_information8                   => p_information8
	  ,p_information9                   => p_information9
	  ,p_information10                  => p_information10
	  ,p_information11                  => p_information11
	  ,p_information12                  => p_information12
	  ,p_information13                  => p_information13
	  ,p_information14                  => p_information14
	  ,p_information15                  => p_information15
	  ,p_information16                  => p_information16
	  ,p_information17                  => p_information17
	  ,p_information18                  => p_information18
	  ,p_information19                  => p_information19
	  ,p_information20                  => p_information20
	  ,p_information21                  => p_information21
	  ,p_information22                  => p_information22
	  ,p_information23                  => p_information23
	  ,p_information24                  => p_information24
	  ,p_information25                  => p_information25
	  ,p_information26                  => p_information26
	  ,p_information27                  => p_information27
	  ,p_information28                  => p_information28
	  ,p_information29                  => p_information29
	  ,p_information30                  => p_information30
	  ,p_information_category           => p_information_category
	  ,p_attribute1                     => p_attribute1
	  ,p_attribute2                     => p_attribute2
	  ,p_attribute3                     => p_attribute3
	  ,p_attribute4                     => p_attribute4
	  ,p_attribute5                     => p_attribute5
	  ,p_attribute6                     => p_attribute6
	  ,p_attribute7                     => p_attribute7
	  ,p_attribute8                     => p_attribute8
	  ,p_attribute9                     => p_attribute9
	  ,p_attribute10                    => p_attribute10
	  ,p_attribute11                    => p_attribute11
	  ,p_attribute12                    => p_attribute12
	  ,p_attribute13                    => p_attribute13
	  ,p_attribute14                    => p_attribute14
	  ,p_attribute15                    => p_attribute15
	  ,p_attribute16                    => p_attribute16
	  ,p_attribute17                    => p_attribute17
	  ,p_attribute18                    => p_attribute18
	  ,p_attribute19                    => p_attribute19
	  ,p_attribute20                    => p_attribute20
	  ,p_attribute21                    => p_attribute21
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
	  ,p_segment1                       =>  p_segment1
	  ,p_segment2                       =>  p_segment2
	  ,p_segment3                       =>  p_segment3
	  ,p_segment4                       =>  p_segment4
	  ,p_segment5                       =>  p_segment5
	  ,p_segment6                       =>  p_segment6
	  ,p_segment7                       =>  p_segment7
	  ,p_segment8                       =>  p_segment8
	  ,p_segment9                       =>  p_segment9
	  ,p_segment10                      =>  p_segment10
	  ,p_segment11                      =>  p_segment11
	  ,p_segment12                      =>  p_segment12
	  ,p_segment13                      =>  p_segment13
	  ,p_segment14                      =>  p_segment14
	  ,p_segment15                      =>  p_segment15
	  ,p_segment16                      =>  p_segment16
	  ,p_segment17                      =>  p_segment17
	  ,p_segment18                      =>  p_segment18
	  ,p_segment19                      =>  p_segment19
	  ,p_segment20                      =>  p_segment20
	  ,p_segment21                      =>  p_segment21
	  ,p_segment22                      =>  p_segment22
	  ,p_segment23                      =>  p_segment23
	  ,p_segment24                      =>  p_segment24
	  ,p_segment25                      =>  p_segment25
	  ,p_segment26                      =>  p_segment26
	  ,p_segment27                      =>  p_segment27
	  ,p_segment28                      =>  p_segment28
	  ,p_segment29                      =>  p_segment29
	  ,p_segment30                      =>  p_segment30
	  ,p_concat_segments                =>  p_concat_segments
	  ,p_request_id                     =>  p_request_id
	  ,p_program_application_id         =>  p_program_application_id
	  ,p_program_id                     =>  p_program_id
	  ,p_program_update_date            =>  p_program_update_date
	  ,p_object_version_number          =>  p_object_version_number
	  ,p_effective_date                 =>  p_effective_date
	  ,p_datetrack_mode                 =>  p_datetrack_mode
	  );

	  if p_validate then
	    raise hr_api.validate_enabled;
	  end if;
	  p_effective_start_date := l_effective_start_date;
	  p_effective_end_date := l_effective_end_date;
	  l_valid_grades_changed_warning := p_valid_grades_changed_warning;
--
  hr_utility.set_location(l_proc, 20);
  --
    ghr_history_api.post_update_process;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_update_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    p_position_definition_id    := l_position_definition_id;
    p_name			:= l_name;
    p_object_version_number     := l_object_version_number;
    p_valid_grades_changed_warning := NULL;

    --
   When others then
     ROLLBACK TO ghr_update_position;
     --
     -- Reset IN OUT parameters and set OUT parameters
     p_effective_start_date     := null;
     p_effective_end_date       := null;
     p_position_definition_id   := l_position_definition_id;
     p_name			:= l_name;
     p_object_version_number    := l_object_version_number;
     p_valid_grades_changed_warning := NULL;
    --
     RAISE;

  END update_position;


END ghr_posndt_api;

/
