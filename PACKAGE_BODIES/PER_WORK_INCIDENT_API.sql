--------------------------------------------------------
--  DDL for Package Body PER_WORK_INCIDENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WORK_INCIDENT_API" as
/* $Header: peincapi.pkb 115.16 2002/12/11 11:15:34 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'per_work_incident_api';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_work_incident >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_work_incident
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
    ,p_emergency_code                 in     varchar2 default null
    ,p_hospitalized_flag              in     varchar2 default null
    ,p_hospital_address               in     varchar2 default null
    ,p_activity_at_time_of_work       in     varchar2 default null
    ,p_objects_involved               in     varchar2 default null
    ,p_privacy_issue                  in     varchar2 default null
    ,p_work_start_time                in     varchar2 default null
    ,p_date_of_death                  in     date     default null
    ,p_report_completed_by            in     varchar2 default null
    ,p_reporting_person_title         in     varchar2 default null
    ,p_reporting_person_phone         in     varchar2 default null
    ,p_days_restricted_work           in     number   default null
    ,p_days_away_from_work            in     number   default null
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
  ,p_inc_information_category      in     varchar2 default null
  ,p_inc_information1              in     varchar2 default null
  ,p_inc_information2              in     varchar2 default null
  ,p_inc_information3              in     varchar2 default null
  ,p_inc_information4              in     varchar2 default null
  ,p_inc_information5              in     varchar2 default null
  ,p_inc_information6              in     varchar2 default null
  ,p_inc_information7              in     varchar2 default null
  ,p_inc_information8              in     varchar2 default null
  ,p_inc_information9              in     varchar2 default null
  ,p_inc_information10             in     varchar2 default null
  ,p_inc_information11             in     varchar2 default null
  ,p_inc_information12             in     varchar2 default null
  ,p_inc_information13             in     varchar2 default null
  ,p_inc_information14             in     varchar2 default null
  ,p_inc_information15             in     varchar2 default null
  ,p_inc_information16             in     varchar2 default null
  ,p_inc_information17             in     varchar2 default null
  ,p_inc_information18             in     varchar2 default null
  ,p_inc_information19             in     varchar2 default null
  ,p_inc_information20             in     varchar2 default null
  ,p_inc_information21             in     varchar2 default null
  ,p_inc_information22             in     varchar2 default null
  ,p_inc_information23             in     varchar2 default null
  ,p_inc_information24             in     varchar2 default null
  ,p_inc_information25             in     varchar2 default null
  ,p_inc_information26             in     varchar2 default null
  ,p_inc_information27             in     varchar2 default null
  ,p_inc_information28             in     varchar2 default null
  ,p_inc_information29             in     varchar2 default null
  ,p_inc_information30             in     varchar2 default null
  ,p_incident_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_work_incident';
  l_incident_id            per_work_incidents.incident_id%TYPE;
  l_object_version_number  per_work_incidents.object_version_number%TYPE;
  l_effective_date         date;
  l_incident_date          per_work_incidents.incident_date%TYPE;
  l_org_notified_date      per_work_incidents.org_notified_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_work_incident;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_incident_date := trunc(p_incident_date);
  l_org_notified_date := trunc(p_org_notified_date);
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
  ,p_emergency_code                 => p_emergency_code
  ,p_hospitalized_flag              => p_hospitalized_flag
  ,p_hospital_address               => p_hospital_address
  ,p_activity_at_time_of_work       => p_activity_at_time_of_work
  ,p_objects_involved               => p_objects_involved
  ,p_privacy_issue                  => p_privacy_issue
  ,p_work_start_time                => p_work_start_time
  ,p_date_of_death                  => p_date_of_death
  ,p_report_completed_by            => p_report_completed_by
  ,p_reporting_person_title         => p_reporting_person_title
  ,p_reporting_person_phone         => p_reporting_person_phone
  ,p_days_restricted_work           => p_days_restricted_work
  ,p_days_away_from_work            => p_days_away_from_work
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
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_inc_ins.ins
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
     ,p_emergency_code                 => p_emergency_code
     ,p_hospitalized_flag              => p_hospitalized_flag
     ,p_hospital_address               => p_hospital_address
     ,p_activity_at_time_of_work       => p_activity_at_time_of_work
     ,p_objects_involved               => p_objects_involved
     ,p_privacy_issue                  => p_privacy_issue
     ,p_work_start_time                => p_work_start_time
     ,p_date_of_death                  => p_date_of_death
     ,p_report_completed_by            => p_report_completed_by
     ,p_reporting_person_title         => p_reporting_person_title
     ,p_reporting_person_phone         => p_reporting_person_phone
     ,p_days_restricted_work           => p_days_restricted_work
     ,p_days_away_from_work            => p_days_away_from_work
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
       ,p_object_version_number         => l_object_version_number);
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
    ,p_emergency_code                 => p_emergency_code
    ,p_hospitalized_flag              => p_hospitalized_flag
    ,p_hospital_address               => p_hospital_address
    ,p_activity_at_time_of_work       => p_activity_at_time_of_work
    ,p_objects_involved               => p_objects_involved
    ,p_privacy_issue                  => p_privacy_issue
    ,p_work_start_time                => p_work_start_time
    ,p_date_of_death                  => p_date_of_death
    ,p_report_completed_by            => p_report_completed_by
    ,p_reporting_person_title         => p_reporting_person_title
    ,p_reporting_person_phone         => p_reporting_person_phone
    ,p_days_restricted_work           => p_days_restricted_work
    ,p_days_away_from_work            => p_days_away_from_work
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
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_incident_id            := l_incident_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_work_incident;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_incident_id            := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_work_incident;
    --
    -- set in out parameters and set out parameters
    --
    p_incident_id            := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_work_incident;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_work_incident >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_work_incident
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
    ,p_emergency_code                 in     varchar2 default hr_api.g_varchar2
    ,p_hospitalized_flag              in     varchar2 default hr_api.g_varchar2
    ,p_hospital_address               in     varchar2 default hr_api.g_varchar2
    ,p_activity_at_time_of_work       in     varchar2 default hr_api.g_varchar2
    ,p_objects_involved               in     varchar2 default hr_api.g_varchar2
    ,p_privacy_issue                  in     varchar2 default hr_api.g_varchar2
    ,p_work_start_time                in     varchar2 default hr_api.g_varchar2
    ,p_date_of_death                  in     date     default hr_api.g_date
    ,p_report_completed_by            in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_title         in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_phone         in     varchar2 default hr_api.g_varchar2
    ,p_days_restricted_work           in     number   default hr_api.g_number
    ,p_days_away_from_work            in     number   default hr_api.g_number
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
  ,p_inc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_inc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_inc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_inc_information30             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_work_incident';
  l_incident_id            per_work_incidents.incident_id%TYPE;
  l_object_version_number  per_work_incidents.object_version_number%TYPE;
  l_ovn per_work_incidents.object_version_number%TYPE := p_object_version_number;
  l_effective_date         date;
  l_incident_date          per_work_incidents.incident_date%TYPE;
  l_org_notified_date      per_work_incidents.org_notified_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_work_incident;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_incident_date := trunc(p_incident_date);
  l_org_notified_date := trunc(p_org_notified_date);
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
    ,p_emergency_code                 => p_emergency_code
    ,p_hospitalized_flag              => p_hospitalized_flag
    ,p_hospital_address               => p_hospital_address
    ,p_activity_at_time_of_work       => p_activity_at_time_of_work
    ,p_objects_involved               => p_objects_involved
    ,p_privacy_issue                  => p_privacy_issue
    ,p_work_start_time                => p_work_start_time
    ,p_date_of_death                  => p_date_of_death
    ,p_report_completed_by            => p_report_completed_by
    ,p_reporting_person_title         => p_reporting_person_title
    ,p_reporting_person_phone         => p_reporting_person_phone
    ,p_days_restricted_work           => p_days_restricted_work
    ,p_days_away_from_work            => p_days_away_from_work
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
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_inc_upd.upd
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
    ,p_emergency_code                 => p_emergency_code
    ,p_hospitalized_flag              => p_hospitalized_flag
    ,p_hospital_address               => p_hospital_address
    ,p_activity_at_time_of_work       => p_activity_at_time_of_work
    ,p_objects_involved               => p_objects_involved
    ,p_privacy_issue                  => p_privacy_issue
    ,p_work_start_time                => p_work_start_time
    ,p_date_of_death                  => p_date_of_death
    ,p_report_completed_by            => p_report_completed_by
    ,p_reporting_person_title         => p_reporting_person_title
    ,p_reporting_person_phone         => p_reporting_person_phone
    ,p_days_restricted_work           => p_days_restricted_work
    ,p_days_away_from_work            => p_days_away_from_work
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
       ,p_inc_information30             => p_inc_information30);
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
    ,p_emergency_code                 => p_emergency_code
    ,p_hospitalized_flag              => p_hospitalized_flag
    ,p_hospital_address               => p_hospital_address
    ,p_activity_at_time_of_work       => p_activity_at_time_of_work
    ,p_objects_involved               => p_objects_involved
    ,p_privacy_issue                  => p_privacy_issue
    ,p_work_start_time                => p_work_start_time
    ,p_date_of_death                  => p_date_of_death
    ,p_report_completed_by            => p_report_completed_by
    ,p_reporting_person_title         => p_reporting_person_title
    ,p_reporting_person_phone         => p_reporting_person_phone
    ,p_days_restricted_work           => p_days_restricted_work
    ,p_days_away_from_work            => p_days_away_from_work
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
    rollback to update_work_incident;
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
    rollback to update_work_incident;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_work_incident;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_work_incident >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_work_incident
  (p_validate                      in     boolean  default false
  ,p_incident_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_work_incident';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_work_incident;
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
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_inc_del.del
  (p_incident_id                   => p_incident_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
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
  end;
  --
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
    ROLLBACK TO delete_work_incident;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_work_incident;
  --
  raise;
  --
end delete_work_incident;
--
end per_work_incident_api;

/
