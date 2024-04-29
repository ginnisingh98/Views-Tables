--------------------------------------------------------
--  DDL for Package Body HR_RETAINED_RIGHTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RETAINED_RIGHTS_API" as
/* $Header: peretapi.pkb 115.1 2002/12/10 14:29:13 eumenyio noship $ */
--
-- Package Variables
--
g_package  varchar2(25) := 'hr_retained_rights_api';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_retained_right >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retained_right
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cagr_entitlement_result_id    in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_freeze_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_cagr_retained_right_id           out nocopy number
  ,p_object_version_number            out nocopy number) is
  --
  -- Declare cursors and local variables
  --

 -- check if result already has a retained right
CURSOR csr_ret_rights IS
 SELECT null
 FROM PER_CAGR_RETAINED_RIGHTS crr
 WHERE crr.cagr_entitlement_result_id = p_cagr_entitlement_result_id;

 -- fetch result data to create the retained right
CURSOR csr_results IS
 SELECT *
 FROM PER_CAGR_ENTITLEMENT_RESULTS er
 WHERE er.cagr_entitlement_result_id = p_cagr_entitlement_result_id;

  l_proc                   varchar2(72) := g_package||'create_retained_right';
  l_result                 csr_results%ROWTYPE;
  l_dummy                  varchar2(1);
  l_cagr_retained_right_id per_cagr_retained_rights.cagr_retained_right_id%TYPE;
  l_object_version_number  per_cagr_retained_rights.object_version_number%TYPE;
  l_effective_date         date;
  l_start_date             per_cagr_retained_rights.start_date%TYPE;
  l_end_date               per_cagr_retained_rights.end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_retained_right;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date := trunc(p_start_date);
  l_end_date := trunc(p_end_date);

  --
  -- First test if it is valid to create the rr for the result
  --
  open csr_ret_rights;
  fetch csr_ret_rights into l_dummy;
  if csr_ret_rights%found then
    close csr_ret_rights;
    fnd_message.set_name(800, 'PER_XXXXX_INV_CAGR_RES_EXISTS');
    fnd_message.set_token('CAGR_ENTITLEMENT_RESULT_ID', p_cagr_entitlement_result_id);
    fnd_message.raise_error;
  end if;
  close csr_ret_rights;

  -- Next get the result data as identified by cagr_entitlement_result_id
  -- param, so that the retained right record can be populated
  -- (We do this even if the the retained right is not frozen)
  --
  open csr_results;
  fetch csr_results into l_result;
  if csr_results%notfound then
    close csr_results;
    fnd_message.set_name(800, 'PER_XXXXX_INV_CAGR_RESULT_ID');
    fnd_message.set_token('CAGR_ENTITLEMENT_RESULT_ID', p_cagr_entitlement_result_id);
    fnd_message.raise_error;
  end if;
  close csr_results;


/* comment hooks for now
  --
  -- Call Before Process User Hook
  --
  begin
    per_work_incident_bk1.create_work_incident_b
      (p_effective_date                 => l_effective_date
       ,p_person_id                     => p_person_id
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => l_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => l_org_notified_date
       ,p_assignment_id                 => p_assignment_id
       ,p_location                      => p_location
       ,p_report_date                   => p_report_date
       ,p_report_time                   => p_report_time
       ,p_report_method                 => p_report_method
       ,p_person_reported_by            => p_person_reported_by
       ,p_person_reported_to            => p_person_reported_to
       ,p_witness_details               => p_witness_details
       ,p_description                   => p_description
       ,p_injury_type                   => p_injury_type
       ,p_disease_type                  => p_disease_type
       ,p_hazard_type                   => p_hazard_type
       ,p_body_part                     => p_body_part
       ,p_treatment_received_flag       => p_treatment_received_flag
       ,p_hospital_details              => p_hospital_details
       ,p_doctor_name                   => p_doctor_name
       ,p_compensation_date             => p_compensation_date
       ,p_compensation_currency         => p_compensation_currency
       ,p_compensation_amount           => p_compensation_amount
       ,p_remedial_hs_action            => p_remedial_hs_action
       ,p_notified_hsrep_id             => p_notified_hsrep_id
       ,p_notified_hsrep_date           => p_notified_hsrep_date
       ,p_notified_rep_id               => p_notified_rep_id
       ,p_notified_rep_date             => p_notified_rep_date
       ,p_notified_rep_org_id           => p_notified_rep_org_id
       ,p_related_incident_id           => p_related_incident_id
       ,p_over_time_flag                => p_over_time_flag
	  ,p_absence_exists_flag           => p_absence_exists_flag
       ,p_attribute_category            => p_attribute_category
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
       ,p_inc_information_category      => p_inc_information_category
       ,p_inc_information1              => p_inc_information1
       ,p_inc_information2              => p_inc_information2
       ,p_inc_information3              => p_inc_information3
       ,p_inc_information4              => p_inc_information4
       ,p_inc_information5              => p_inc_information5
       ,p_inc_information6              => p_inc_information6
       ,p_inc_information7              => p_inc_information7
       ,p_inc_information8              => p_inc_information8
       ,p_inc_information9              => p_inc_information9
       ,p_inc_information10             => p_inc_information10
       ,p_inc_information11             => p_inc_information11
       ,p_inc_information12             => p_inc_information12
       ,p_inc_information13             => p_inc_information13
       ,p_inc_information14             => p_inc_information14
       ,p_inc_information15             => p_inc_information15
       ,p_inc_information16             => p_inc_information16
       ,p_inc_information17             => p_inc_information17
       ,p_inc_information18             => p_inc_information18
       ,p_inc_information19             => p_inc_information19
       ,p_inc_information20             => p_inc_information20
       ,p_inc_information21             => p_inc_information21
       ,p_inc_information22             => p_inc_information22
       ,p_inc_information23             => p_inc_information23
       ,p_inc_information24             => p_inc_information24
       ,p_inc_information25             => p_inc_information25
       ,p_inc_information26             => p_inc_information26
       ,p_inc_information27             => p_inc_information27
       ,p_inc_information28             => p_inc_information28
       ,p_inc_information29             => p_inc_information29
       ,p_inc_information30             => p_inc_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_work_incident_b'
        ,p_hook_type   => 'BP'
        );
  end;

*/
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_ret_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_assignment_id                  => l_result.assignment_id
    ,p_cagr_entitlement_item_id       => l_result.cagr_entitlement_item_id
    ,p_collective_agreement_id        => l_result.collective_agreement_id
    ,p_cagr_entitlement_id            => l_result.cagr_entitlement_id
    ,p_category_name                  => l_result.category_name
    ,p_element_type_id                => l_result.element_type_id
    ,p_input_value_id                 => l_result.input_value_id
    ,p_cagr_api_id                    => l_result.cagr_api_id
    ,p_cagr_api_param_id              => l_result.cagr_api_param_id
    ,p_cagr_entitlement_line_id       => l_result.cagr_entitlement_line_id
    ,p_freeze_flag                    => p_freeze_flag
    ,p_value                          => l_result.value
    ,p_units_of_measure               => l_result.units_of_measure
    ,p_start_date                     => l_start_date
    ,p_end_date                       => l_end_date
    ,p_parent_spine_id                => l_result.parent_spine_id
    ,p_formula_id                     => l_result.formula_id
    ,p_oipl_id                        => l_result.oipl_id
    ,p_step_id                        => l_result.step_id
    ,p_grade_spine_id                 => l_result.grade_spine_id
    ,p_column_type                    => l_result.column_type
    ,p_column_size                    => l_result.column_size
    ,p_eligy_prfl_id                  => l_result.eligy_prfl_id
    ,p_cagr_entitlement_result_id     => l_result.cagr_entitlement_result_id
    ,p_business_group_id              => l_result.business_group_id
    ,p_flex_value_set_id              => l_result.flex_value_set_id
    ,p_cagr_retained_right_id         => l_cagr_retained_right_id
    ,p_object_version_number          => l_object_version_number);

/* comment hooks for now
  --
  -- Call After Process User Hook
  --
  begin
    per_work_incident_bk1.create_work_incident_a
       (p_effective_date                => l_effective_date
       ,p_person_id                     => p_person_id
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => l_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => l_org_notified_date
       ,p_assignment_id                 => p_assignment_id
       ,p_location                      => p_location
       ,p_report_date                   => p_report_date
       ,p_report_time                   => p_report_time
       ,p_report_method                 => p_report_method
       ,p_person_reported_by            => p_person_reported_by
       ,p_person_reported_to            => p_person_reported_to
       ,p_witness_details               => p_witness_details
       ,p_description                   => p_description
       ,p_injury_type                   => p_injury_type
       ,p_disease_type                  => p_disease_type
       ,p_hazard_type                   => p_hazard_type
       ,p_body_part                     => p_body_part
       ,p_treatment_received_flag       => p_treatment_received_flag
       ,p_hospital_details              => p_hospital_details
       ,p_doctor_name                   => p_doctor_name
       ,p_compensation_date             => p_compensation_date
       ,p_compensation_currency         => p_compensation_currency
       ,p_compensation_amount           => p_compensation_amount
       ,p_remedial_hs_action            => p_remedial_hs_action
       ,p_notified_hsrep_id             => p_notified_hsrep_id
       ,p_notified_hsrep_date           => p_notified_hsrep_date
       ,p_notified_rep_id               => p_notified_rep_id
       ,p_notified_rep_date             => p_notified_rep_date
       ,p_notified_rep_org_id           => p_notified_rep_org_id
       ,p_related_incident_id           => p_related_incident_id
       ,p_over_time_flag                => p_over_time_flag
	  ,p_absence_exists_flag           => p_absence_exists_flag
       ,p_attribute_category            => p_attribute_category
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
       ,p_inc_information_category      => p_inc_information_category
       ,p_inc_information1              => p_inc_information1
       ,p_inc_information2              => p_inc_information2
       ,p_inc_information3              => p_inc_information3
       ,p_inc_information4              => p_inc_information4
       ,p_inc_information5              => p_inc_information5
       ,p_inc_information6              => p_inc_information6
       ,p_inc_information7              => p_inc_information7
       ,p_inc_information8              => p_inc_information8
       ,p_inc_information9              => p_inc_information9
       ,p_inc_information10             => p_inc_information10
       ,p_inc_information11             => p_inc_information11
       ,p_inc_information12             => p_inc_information12
       ,p_inc_information13             => p_inc_information13
       ,p_inc_information14             => p_inc_information14
       ,p_inc_information15             => p_inc_information15
       ,p_inc_information16             => p_inc_information16
       ,p_inc_information17             => p_inc_information17
       ,p_inc_information18             => p_inc_information18
       ,p_inc_information19             => p_inc_information19
       ,p_inc_information20             => p_inc_information20
       ,p_inc_information21             => p_inc_information21
       ,p_inc_information22             => p_inc_information22
       ,p_inc_information23             => p_inc_information23
       ,p_inc_information24             => p_inc_information24
       ,p_inc_information25             => p_inc_information25
       ,p_inc_information26             => p_inc_information26
       ,p_inc_information27             => p_inc_information27
       ,p_inc_information28             => p_inc_information28
       ,p_inc_information29             => p_inc_information29
       ,p_inc_information30             => p_inc_information30
       ,p_incident_id                   => l_incident_id
       ,p_object_version_number         => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_work_incident_a'
        ,p_hook_type   => 'AP'
        );
  end;
*/
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_cagr_retained_right_id := l_cagr_retained_right_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_retained_right;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cagr_retained_right_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_retained_right;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_retained_right;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retained_right >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retained_right
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cagr_retained_right_id        in     number
  ,p_end_date                      in     date  default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_retained_right';
  l_cagr_retained_right_id per_cagr_retained_rights.cagr_retained_right_id%TYPE;
  l_object_version_number  per_cagr_retained_rights.object_version_number%TYPE;
  l_effective_date         date;
  l_end_date               per_cagr_retained_rights.end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_retained_right;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_end_date := trunc(p_end_date);
  /*
  --
  -- Call Before Process User Hook
  --
  begin
    per_work_incident_bk2.update_work_incident_b
      (p_effective_date                 => l_effective_date
       ,p_incident_id                   => p_incident_id
       ,p_object_version_number         => p_object_version_number
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => l_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => l_org_notified_date
       ,p_assignment_id                 => p_assignment_id
       ,p_location                      => p_location
       ,p_report_date                   => p_report_date
       ,p_report_time                   => p_report_time
       ,p_report_method                 => p_report_method
       ,p_person_reported_by            => p_person_reported_by
       ,p_person_reported_to            => p_person_reported_to
       ,p_witness_details               => p_witness_details
       ,p_description                   => p_description
       ,p_injury_type                   => p_injury_type
       ,p_disease_type                  => p_disease_type
       ,p_hazard_type                   => p_hazard_type
       ,p_body_part                     => p_body_part
       ,p_treatment_received_flag       => p_treatment_received_flag
       ,p_hospital_details              => p_hospital_details
       ,p_doctor_name                   => p_doctor_name
       ,p_compensation_date             => p_compensation_date
       ,p_compensation_currency         => p_compensation_currency
       ,p_compensation_amount           => p_compensation_amount
       ,p_remedial_hs_action            => p_remedial_hs_action
       ,p_notified_hsrep_id             => p_notified_hsrep_id
       ,p_notified_hsrep_date           => p_notified_hsrep_date
       ,p_notified_rep_id               => p_notified_rep_id
       ,p_notified_rep_date             => p_notified_rep_date
       ,p_notified_rep_org_id           => p_notified_rep_org_id
       ,p_related_incident_id           => p_related_incident_id
       ,p_over_time_flag                => p_over_time_flag
	  ,p_absence_exists_flag           => p_absence_exists_flag
       ,p_attribute_category            => p_attribute_category
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
       ,p_inc_information_category      => p_inc_information_category
       ,p_inc_information1              => p_inc_information1
       ,p_inc_information2              => p_inc_information2
       ,p_inc_information3              => p_inc_information3
       ,p_inc_information4              => p_inc_information4
       ,p_inc_information5              => p_inc_information5
       ,p_inc_information6              => p_inc_information6
       ,p_inc_information7              => p_inc_information7
       ,p_inc_information8              => p_inc_information8
       ,p_inc_information9              => p_inc_information9
       ,p_inc_information10             => p_inc_information10
       ,p_inc_information11             => p_inc_information11
       ,p_inc_information12             => p_inc_information12
       ,p_inc_information13             => p_inc_information13
       ,p_inc_information14             => p_inc_information14
       ,p_inc_information15             => p_inc_information15
       ,p_inc_information16             => p_inc_information16
       ,p_inc_information17             => p_inc_information17
       ,p_inc_information18             => p_inc_information18
       ,p_inc_information19             => p_inc_information19
       ,p_inc_information20             => p_inc_information20
       ,p_inc_information21             => p_inc_information21
       ,p_inc_information22             => p_inc_information22
       ,p_inc_information23             => p_inc_information23
       ,p_inc_information24             => p_inc_information24
       ,p_inc_information25             => p_inc_information25
       ,p_inc_information26             => p_inc_information26
       ,p_inc_information27             => p_inc_information27
       ,p_inc_information28             => p_inc_information28
       ,p_inc_information29             => p_inc_information29
       ,p_inc_information30             => p_inc_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_work_incident_b'
        ,p_hook_type   => 'BP'
        );
  end;
*/
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_ret_upd.upd
  (p_effective_date               => l_effective_date
  ,p_cagr_retained_right_id       => p_cagr_retained_right_id
  ,p_object_version_number        => l_object_version_number
  ,p_end_date                     => l_end_date
  );

/*
--
  -- Call After Process User Hook
  --
  begin
    per_work_incident_bk2.update_work_incident_a
       (p_effective_date                => l_effective_date
       ,p_incident_id                   => p_incident_id
       ,p_object_version_number         => l_object_version_number
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => l_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => l_org_notified_date
       ,p_assignment_id                 => p_assignment_id
       ,p_location                      => p_location
       ,p_report_date                   => p_report_date
       ,p_report_time                   => p_report_time
       ,p_report_method                 => p_report_method
       ,p_person_reported_by            => p_person_reported_by
       ,p_person_reported_to            => p_person_reported_to
       ,p_witness_details               => p_witness_details
       ,p_description                   => p_description
       ,p_injury_type                   => p_injury_type
       ,p_disease_type                  => p_disease_type
       ,p_hazard_type                   => p_hazard_type
       ,p_body_part                     => p_body_part
       ,p_treatment_received_flag       => p_treatment_received_flag
       ,p_hospital_details              => p_hospital_details
       ,p_doctor_name                   => p_doctor_name
       ,p_compensation_date             => p_compensation_date
       ,p_compensation_currency         => p_compensation_currency
       ,p_compensation_amount           => p_compensation_amount
       ,p_remedial_hs_action            => p_remedial_hs_action
       ,p_notified_hsrep_id             => p_notified_hsrep_id
       ,p_notified_hsrep_date           => p_notified_hsrep_date
       ,p_notified_rep_id               => p_notified_rep_id
       ,p_notified_rep_date             => p_notified_rep_date
       ,p_notified_rep_org_id           => p_notified_rep_org_id
       ,p_related_incident_id           => p_related_incident_id
       ,p_over_time_flag                => p_over_time_flag
	  ,p_absence_exists_flag           => p_absence_exists_flag
       ,p_attribute_category            => p_attribute_category
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
       ,p_inc_information_category      => p_inc_information_category
       ,p_inc_information1              => p_inc_information1
       ,p_inc_information2              => p_inc_information2
       ,p_inc_information3              => p_inc_information3
       ,p_inc_information4              => p_inc_information4
       ,p_inc_information5              => p_inc_information5
       ,p_inc_information6              => p_inc_information6
       ,p_inc_information7              => p_inc_information7
       ,p_inc_information8              => p_inc_information8
       ,p_inc_information9              => p_inc_information9
       ,p_inc_information10             => p_inc_information10
       ,p_inc_information11             => p_inc_information11
       ,p_inc_information12             => p_inc_information12
       ,p_inc_information13             => p_inc_information13
       ,p_inc_information14             => p_inc_information14
       ,p_inc_information15             => p_inc_information15
       ,p_inc_information16             => p_inc_information16
       ,p_inc_information17             => p_inc_information17
       ,p_inc_information18             => p_inc_information18
       ,p_inc_information19             => p_inc_information19
       ,p_inc_information20             => p_inc_information20
       ,p_inc_information21             => p_inc_information21
       ,p_inc_information22             => p_inc_information22
       ,p_inc_information23             => p_inc_information23
       ,p_inc_information24             => p_inc_information24
       ,p_inc_information25             => p_inc_information25
       ,p_inc_information26             => p_inc_information26
       ,p_inc_information27             => p_inc_information27
       ,p_inc_information28             => p_inc_information28
       ,p_inc_information29             => p_inc_information29
       ,p_inc_information30             => p_inc_information30
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_work_incident_a'
        ,p_hook_type   => 'AP'
        );
  end;
*/
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_retained_right;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_retained_right;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_retained_right;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retained_right >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retained_right
  (p_validate                      in     boolean  default false
  ,p_cagr_retained_right_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_retained_right';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_retained_right;

/*
  --
  -- Call Before Process User Hook
  --
  begin
    per_work_incident_bk3.delete_work_incident_b
     (p_incident_id             => p_incident_id,
      p_object_version_number   => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_work_incident_b',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
*/
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_ret_del.del
  (p_cagr_retained_right_id        => p_cagr_retained_right_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
/*
  --
  -- Call After Process User Hook
  begin
    per_work_incident_bk3.delete_work_incident_a
     (p_incident_id             => p_incident_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'delete_work_incident_a',
            p_hook_type   => 'AP'
           );

*/
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_retained_right;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_retained_right;
  --
  raise;
  --
end delete_retained_right;
--
end HR_RETAINED_RIGHTS_API;

/
