--------------------------------------------------------
--  DDL for Package Body PER_DK_WORK_INCIDENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DK_WORK_INCIDENT_API" as
/* $Header: peincdki.pkb 120.0 2005/05/31 10:05:55 appldev noship $ */

-- Package Variables
--
g_package  varchar2(33) := 'per_dk_work_incident_api.';
--
-- ----------------------------------------------------------------------
-- |----------------------< create_dk_work_incident >--------------------|
-- ----------------------------------------------------------------------
--
procedure create_dk_work_incident
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_incident_reference            in     varchar2
  ,p_incident_type                 in     varchar2
  ,p_at_work_flag                  in     varchar2
  ,p_incident_date                 in     date
  ,p_incident_time                 in     varchar2 default null
  ,p_org_notified_date             in     date     default null
  ,p_assignment_id                 in     number   default null
  ,p_location                      in     varchar2 default null
  ,p_report_date                   in     date     default null
  ,p_report_time                   in     varchar2 default null
  ,p_report_method                 in     varchar2 default null
  ,p_person_reported_by            in     number   default null
  ,p_person_reported_to            in     varchar2 default null
  ,p_witness_details               in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_injury_type                   in     varchar2 default null
  ,p_disease_type                  in     varchar2 default null
  ,p_hazard_type                   in     varchar2 default null
  ,p_body_part                     in     varchar2 default null
  ,p_treatment_received_flag       in     varchar2 default null
  ,p_hospital_details              in     varchar2 default null
  ,p_emergency_code                in     varchar2 default null
  ,p_hospitalized_flag             in     varchar2 default null
  ,p_hospital_address              in     varchar2 default null
  ,p_activity_at_time_of_work      in     varchar2 default null
  ,p_objects_involved              in     varchar2 default null
  ,p_privacy_issue                 in     varchar2 default null
  ,p_work_start_time               in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_report_completed_by           in     varchar2 default null
  ,p_reporting_person_title        in     varchar2 default null
  ,p_reporting_person_phone        in     varchar2 default null
  ,p_days_restricted_work          in     number   default null
  ,p_days_away_from_work           in     number   default null
  ,p_doctor_name                   in     varchar2 default null
  ,p_compensation_date             in     date     default null
  ,p_compensation_currency         in     varchar2 default null
  ,p_compensation_amount           in     number   default null
  ,p_remedial_hs_action            in     varchar2 default null
  ,p_notified_hsrep_id             in     number   default null
  ,p_notified_hsrep_date           in     date     default null
  ,p_notified_rep_id               in     number   default null
  ,p_notified_rep_date             in     date     default null
  ,p_notified_rep_org_id           in     number   default null
  ,p_related_incident_id           in     number   default null
  ,p_over_time_flag                in     varchar2 default null
  ,p_absence_exists_flag           in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_company_activity	           in     varchar2 default null
  ,p_married_to_employer           in     varchar2 default null
  ,p_relative_to_employer          in     varchar2 default null
  ,p_notified_by_subcontractor     in     varchar2 default null
  ,p_accident_location	           in     varchar2 default null
  ,p_activity_at_accident_time     in     varchar2 default null
  ,p_wearing_glasses_at_acc_time   in     varchar2 default null
  ,p_reason_for_wearing_glasses    in     varchar2 default null
  ,p_glasses_location_at_acc_time  in     varchar2 default null
  ,p_cause_of_damage_to_glasses    in     varchar2 default null
  ,p_type_of_damage_to_glasses     in     varchar2 default null
  ,p_glasses_purchase_date         in     varchar2 default null
  ,p_glasses_purchase_price        in     number   default null
  ,p_optician_name                 in     varchar2 default null
  ,p_incident_id                   out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc              varchar2(72) := g_package||'create_dk_work_incident';
  l_legislation_code  varchar2(2);
  --
  cursor csr_get_business_group_id is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id = p_person_id
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = l_business_group_id;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_dk_work_incident;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  open  csr_get_business_group_id;
  fetch csr_get_business_group_id
  into l_business_group_id;
  --
  if csr_get_business_group_id%NOTFOUND then
    close csr_get_business_group_id;
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group is 'DK'.
  --
  if l_legislation_code <> 'DK' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','DK');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the Work Incident business process
  --
    per_work_incident_api.create_work_incident
      (p_validate                       => p_validate
       ,p_effective_date                => p_effective_date
       ,p_person_id                     => p_person_id
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => p_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => p_org_notified_date
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
       ,p_emergency_code                => p_emergency_code
       ,p_hospitalized_flag             => p_hospitalized_flag
       ,p_hospital_address              => p_hospital_address
       ,p_activity_at_time_of_work      => p_activity_at_time_of_work
       ,p_objects_involved              => p_objects_involved
       ,p_privacy_issue                 => p_privacy_issue
       ,p_work_start_time               => p_work_start_time
       ,p_date_of_death                 => p_date_of_death
       ,p_report_completed_by           => p_report_completed_by
       ,p_reporting_person_title        => p_reporting_person_title
       ,p_reporting_person_phone        => p_reporting_person_phone
       ,p_days_restricted_work          => p_days_restricted_work
       ,p_days_away_from_work           => p_days_away_from_work
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
       ,p_inc_information_category      => 'DK'
       ,p_inc_information1           	=> p_company_activity
       ,p_inc_information2           	=> p_married_to_employer
       ,p_inc_information3          	=> p_relative_to_employer
       ,p_inc_information4          	=> p_notified_by_subcontractor
       ,p_inc_information5           	=> p_accident_location
       ,p_inc_information6           	=> p_activity_at_accident_time
       ,p_inc_information7           	=> p_wearing_glasses_at_acc_time
       ,p_inc_information8           	=> p_reason_for_wearing_glasses
       ,p_inc_information9          	=> p_glasses_location_at_acc_time
       ,p_inc_information10         	=> p_cause_of_damage_to_glasses
       ,p_inc_information11         	=> p_type_of_damage_to_glasses
       ,p_inc_information12         	=> p_glasses_purchase_date
       ,p_inc_information13         	=> p_glasses_purchase_price
       ,p_inc_information14         	=> p_optician_name
       ,p_incident_id                   => p_incident_id
       ,p_object_version_number 	=> p_object_version_number
      );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_dk_work_incident;
--
-- ----------------------------------------------------------------------
-- |--------------------< update_dk_work_incident >---------------------|
-- ----------------------------------------------------------------------
--
procedure update_dk_work_incident
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_incident_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_incident_reference            in     varchar2 default hr_api.g_varchar2
  ,p_incident_type                 in     varchar2 default hr_api.g_varchar2
  ,p_at_work_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_incident_date                 in     date     default hr_api.g_date
  ,p_incident_time                 in     varchar2 default hr_api.g_varchar2
  ,p_org_notified_date             in     date     default hr_api.g_date
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_report_date                   in     date     default hr_api.g_date
  ,p_report_time                   in     varchar2 default hr_api.g_varchar2
  ,p_report_method                 in     varchar2 default hr_api.g_varchar2
  ,p_person_reported_by            in     number   default hr_api.g_number
  ,p_person_reported_to            in     varchar2 default hr_api.g_varchar2
  ,p_witness_details               in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_injury_type                   in     varchar2 default hr_api.g_varchar2
  ,p_disease_type                  in     varchar2 default hr_api.g_varchar2
  ,p_hazard_type                   in     varchar2 default hr_api.g_varchar2
  ,p_body_part                     in     varchar2 default hr_api.g_varchar2
  ,p_treatment_received_flag       in     varchar2 default hr_api.g_varchar2
  ,p_hospital_details              in     varchar2 default hr_api.g_varchar2
  ,p_emergency_code                in     varchar2 default hr_api.g_varchar2
  ,p_hospitalized_flag             in     varchar2 default hr_api.g_varchar2
  ,p_hospital_address              in     varchar2 default hr_api.g_varchar2
  ,p_activity_at_time_of_work      in     varchar2 default hr_api.g_varchar2
  ,p_objects_involved              in     varchar2 default hr_api.g_varchar2
  ,p_privacy_issue                 in     varchar2 default hr_api.g_varchar2
  ,p_work_start_time               in     varchar2 default hr_api.g_varchar2
  ,p_date_of_death                 in     date     default hr_api.g_date
  ,p_report_completed_by           in     varchar2 default hr_api.g_varchar2
  ,p_reporting_person_title        in     varchar2 default hr_api.g_varchar2
  ,p_reporting_person_phone        in     varchar2 default hr_api.g_varchar2
  ,p_days_restricted_work          in     number   default hr_api.g_number
  ,p_days_away_from_work           in     number   default hr_api.g_number
  ,p_doctor_name                   in     varchar2 default hr_api.g_varchar2
  ,p_compensation_date             in     date     default hr_api.g_date
  ,p_compensation_currency         in     varchar2 default hr_api.g_varchar2
  ,p_compensation_amount           in     number   default hr_api.g_number
  ,p_remedial_hs_action            in     varchar2 default hr_api.g_varchar2
  ,p_notified_hsrep_id             in     number   default hr_api.g_number
  ,p_notified_hsrep_date           in     date     default hr_api.g_date
  ,p_notified_rep_id               in     number   default hr_api.g_number
  ,p_notified_rep_date             in     date     default hr_api.g_date
  ,p_notified_rep_org_id           in     number   default hr_api.g_number
  ,p_related_incident_id           in     number   default hr_api.g_number
  ,p_over_time_flag                in     varchar2 default hr_api.g_varchar2
  ,p_absence_exists_flag           in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_company_activity	           in     varchar2 default hr_api.g_varchar2
  ,p_married_to_employer           in     varchar2 default hr_api.g_varchar2
  ,p_relative_to_employer          in     varchar2 default hr_api.g_varchar2
  ,p_notified_by_subcontractor     in     varchar2 default hr_api.g_varchar2
  ,p_accident_location	           in     varchar2 default hr_api.g_varchar2
  ,p_activity_at_accident_time     in     varchar2 default hr_api.g_varchar2
  ,p_wearing_glasses_at_acc_time   in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_wearing_glasses    in     varchar2 default hr_api.g_varchar2
  ,p_glasses_location_at_acc_time  in     varchar2 default hr_api.g_varchar2
  ,p_cause_of_damage_to_glasses    in     varchar2 default hr_api.g_varchar2
  ,p_type_of_damage_to_glasses     in     varchar2 default hr_api.g_varchar2
  ,p_glasses_purchase_date         in     varchar2 default hr_api.g_varchar2
  ,p_glasses_purchase_price        in     number   default hr_api.g_number
  ,p_optician_name                 in     varchar2 default hr_api.g_varchar2

  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id    per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'update_dk_work_incident';
  l_legislation_code     varchar2(2);
  --
  cursor csr_get_business_group_id is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id = (select person_id
                          from    per_work_incidents
                          where   incident_id = p_incident_id)
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = l_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_dk_work_incident;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  open  csr_get_business_group_id;
  fetch csr_get_business_group_id
  into l_business_group_id;
  --
  if csr_get_business_group_id%NOTFOUND then
    close csr_get_business_group_id;
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group is 'DK'.
  --
  if l_legislation_code  <>  'DK' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','DK');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
    per_work_incident_api.update_work_incident
      (p_validate                       => p_validate
       ,p_effective_date                => p_effective_date
       ,p_incident_id                   => p_incident_id
       ,p_object_version_number         => p_object_version_number
       ,p_incident_reference            => p_incident_reference
       ,p_incident_type                 => p_incident_type
       ,p_at_work_flag                  => p_at_work_flag
       ,p_incident_date                 => p_incident_date
       ,p_incident_time                 => p_incident_time
       ,p_org_notified_date             => p_org_notified_date
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
       ,p_emergency_code                => p_emergency_code
       ,p_hospitalized_flag             => p_hospitalized_flag
       ,p_hospital_address              => p_hospital_address
       ,p_activity_at_time_of_work      => p_activity_at_time_of_work
       ,p_objects_involved              => p_objects_involved
       ,p_privacy_issue                 => p_privacy_issue
       ,p_work_start_time               => p_work_start_time
       ,p_date_of_death                 => p_date_of_death
       ,p_report_completed_by           => p_report_completed_by
       ,p_reporting_person_title        => p_reporting_person_title
       ,p_reporting_person_phone        => p_reporting_person_phone
       ,p_days_restricted_work          => p_days_restricted_work
       ,p_days_away_from_work           => p_days_away_from_work
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
       ,p_inc_information_category  	=> 'DK'
       ,p_inc_information1           	=> p_company_activity
       ,p_inc_information2           	=> p_married_to_employer
       ,p_inc_information3           	=> p_relative_to_employer
       ,p_inc_information4           	=> p_notified_by_subcontractor
       ,p_inc_information5           	=> p_accident_location
       ,p_inc_information6           	=> p_activity_at_accident_time
       ,p_inc_information7          	=> p_wearing_glasses_at_acc_time
       ,p_inc_information8           	=> p_reason_for_wearing_glasses
       ,p_inc_information9           	=> p_glasses_location_at_acc_time
       ,p_inc_information10         	=> p_cause_of_damage_to_glasses
       ,p_inc_information11         	=> p_type_of_damage_to_glasses
       ,p_inc_information12         	=> p_glasses_purchase_date
       ,p_inc_information13         	=> p_glasses_purchase_price
       ,p_inc_information14         	=> p_optician_name
      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end update_dk_work_incident;
--
end per_dk_work_incident_api;

/
