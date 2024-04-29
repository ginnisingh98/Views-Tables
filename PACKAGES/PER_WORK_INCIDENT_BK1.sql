--------------------------------------------------------
--  DDL for Package PER_WORK_INCIDENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WORK_INCIDENT_BK1" AUTHID CURRENT_USER as
/* $Header: peincapi.pkh 120.1 2005/10/02 02:17:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_work_incident_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_work_incident_b
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_incident_reference            in     varchar2
  ,p_incident_type                 in     varchar2
  ,p_incident_date                 in     date
  ,p_incident_time                 in     varchar2
  ,p_org_notified_date             in     date
  ,p_assignment_id                 in     number
  ,p_location                      in     varchar2
  ,p_at_work_flag                  in     varchar2
  ,p_report_date                   in     date
  ,p_report_time                   in     varchar2
  ,p_report_method                 in     varchar2
  ,p_person_reported_by            in     number
  ,p_person_reported_to            in     varchar2
  ,p_witness_details               in     varchar2
  ,p_description                   in     varchar2
  ,p_injury_type                   in     varchar2
  ,p_disease_type                  in     varchar2
  ,p_hazard_type                   in     varchar2
  ,p_body_part                     in     varchar2
  ,p_treatment_received_flag       in     varchar2
  ,p_hospital_details              in     varchar2
    ,p_emergency_code                 in     varchar2
    ,p_hospitalized_flag              in     varchar2
    ,p_hospital_address               in     varchar2
    ,p_activity_at_time_of_work       in     varchar2
    ,p_objects_involved               in     varchar2
    ,p_privacy_issue                  in     varchar2
    ,p_work_start_time                in     varchar2
    ,p_date_of_death                  in     date
    ,p_report_completed_by            in     varchar2
    ,p_reporting_person_title         in     varchar2
    ,p_reporting_person_phone         in     varchar2
    ,p_days_restricted_work           in     number
    ,p_days_away_from_work            in     number
  ,p_doctor_name                   in     varchar2
  ,p_compensation_date             in     date
  ,p_compensation_currency         in     varchar2
  ,p_compensation_amount           in     number
  ,p_remedial_hs_action            in     varchar2
  ,p_notified_hsrep_id             in     number
  ,p_notified_hsrep_date           in     date
  ,p_notified_rep_id               in     number
  ,p_notified_rep_date             in     date
  ,p_notified_rep_org_id           in     number
  ,p_related_incident_id           in     number
  ,p_over_time_flag                in     varchar2
  ,p_absence_exists_flag           in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_inc_information_category      in     varchar2
  ,p_inc_information1              in     varchar2
  ,p_inc_information2              in     varchar2
  ,p_inc_information3              in     varchar2
  ,p_inc_information4              in     varchar2
  ,p_inc_information5              in     varchar2
  ,p_inc_information6              in     varchar2
  ,p_inc_information7              in     varchar2
  ,p_inc_information8              in     varchar2
  ,p_inc_information9              in     varchar2
  ,p_inc_information10             in     varchar2
  ,p_inc_information11             in     varchar2
  ,p_inc_information12             in     varchar2
  ,p_inc_information13             in     varchar2
  ,p_inc_information14             in     varchar2
  ,p_inc_information15             in     varchar2
  ,p_inc_information16             in     varchar2
  ,p_inc_information17             in     varchar2
  ,p_inc_information18             in     varchar2
  ,p_inc_information19             in     varchar2
  ,p_inc_information20             in     varchar2
  ,p_inc_information21             in     varchar2
  ,p_inc_information22             in     varchar2
  ,p_inc_information23             in     varchar2
  ,p_inc_information24             in     varchar2
  ,p_inc_information25             in     varchar2
  ,p_inc_information26             in     varchar2
  ,p_inc_information27             in     varchar2
  ,p_inc_information28             in     varchar2
  ,p_inc_information29             in     varchar2
  ,p_inc_information30             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_work_incident_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_work_incident_a
  (p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_incident_reference            in     varchar2
  ,p_incident_type                 in     varchar2
  ,p_incident_date                 in     date
  ,p_incident_time                 in     varchar2
  ,p_org_notified_date             in     date
  ,p_assignment_id                 in     number
  ,p_location                      in     varchar2
  ,p_at_work_flag                  in     varchar2
  ,p_report_date                   in     date
  ,p_report_time                   in     varchar2
  ,p_report_method                 in     varchar2
  ,p_person_reported_by            in     number
  ,p_person_reported_to            in     varchar2
  ,p_witness_details               in     varchar2
  ,p_description                   in     varchar2
  ,p_injury_type                   in     varchar2
  ,p_disease_type                  in     varchar2
  ,p_hazard_type                   in     varchar2
  ,p_body_part                     in     varchar2
  ,p_treatment_received_flag       in     varchar2
  ,p_hospital_details              in     varchar2
    ,p_emergency_code                 in     varchar2
    ,p_hospitalized_flag              in     varchar2
    ,p_hospital_address               in     varchar2
    ,p_activity_at_time_of_work       in     varchar2
    ,p_objects_involved               in     varchar2
    ,p_privacy_issue                  in     varchar2
    ,p_work_start_time                in     varchar2
    ,p_date_of_death                  in     date
    ,p_report_completed_by            in     varchar2
    ,p_reporting_person_title         in     varchar2
    ,p_reporting_person_phone         in     varchar2
    ,p_days_restricted_work           in     number
    ,p_days_away_from_work            in     number
  ,p_doctor_name                   in     varchar2
  ,p_compensation_date             in     date
  ,p_compensation_currency         in     varchar2
  ,p_compensation_amount           in     number
  ,p_remedial_hs_action            in     varchar2
  ,p_notified_hsrep_id             in     number
  ,p_notified_hsrep_date           in     date
  ,p_notified_rep_id               in     number
  ,p_notified_rep_date             in     date
  ,p_notified_rep_org_id           in     number
  ,p_related_incident_id           in     number
  ,p_over_time_flag                in     varchar2
  ,p_absence_exists_flag           in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_inc_information_category      in     varchar2
  ,p_inc_information1              in     varchar2
  ,p_inc_information2              in     varchar2
  ,p_inc_information3              in     varchar2
  ,p_inc_information4              in     varchar2
  ,p_inc_information5              in     varchar2
  ,p_inc_information6              in     varchar2
  ,p_inc_information7              in     varchar2
  ,p_inc_information8              in     varchar2
  ,p_inc_information9              in     varchar2
  ,p_inc_information10             in     varchar2
  ,p_inc_information11             in     varchar2
  ,p_inc_information12             in     varchar2
  ,p_inc_information13             in     varchar2
  ,p_inc_information14             in     varchar2
  ,p_inc_information15             in     varchar2
  ,p_inc_information16             in     varchar2
  ,p_inc_information17             in     varchar2
  ,p_inc_information18             in     varchar2
  ,p_inc_information19             in     varchar2
  ,p_inc_information20             in     varchar2
  ,p_inc_information21             in     varchar2
  ,p_inc_information22             in     varchar2
  ,p_inc_information23             in     varchar2
  ,p_inc_information24             in     varchar2
  ,p_inc_information25             in     varchar2
  ,p_inc_information26             in     varchar2
  ,p_inc_information27             in     varchar2
  ,p_inc_information28             in     varchar2
  ,p_inc_information29             in     varchar2
  ,p_inc_information30             in     varchar2
  ,p_incident_id                   in     number
  ,p_object_version_number         in     number
  );
--
end per_work_incident_bk1;

 

/
