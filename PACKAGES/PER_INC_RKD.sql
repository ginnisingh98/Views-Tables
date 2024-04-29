--------------------------------------------------------
--  DDL for Package PER_INC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_INC_RKD" AUTHID CURRENT_USER as
/* $Header: peincrhi.pkh 120.0 2005/05/31 10:08:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_incident_id                  in number
  ,p_person_id_o                  in number
  ,p_incident_reference_o         in varchar2
  ,p_incident_type_o              in varchar2
  ,p_incident_date_o              in date
  ,p_incident_time_o              in varchar2
  ,p_org_notified_date_o          in date
  ,p_assignment_id_o              in number
  ,p_location_o                   in varchar2
  ,p_at_work_flag_o               in varchar2
  ,p_report_date_o                in date
  ,p_report_time_o                in varchar2
  ,p_report_method_o              in varchar2
  ,p_person_reported_by_o         in number
  ,p_person_reported_to_o         in varchar2
  ,p_witness_details_o            in varchar2
  ,p_description_o                in varchar2
  ,p_injury_type_o                in varchar2
  ,p_disease_type_o               in varchar2
  ,p_hazard_type_o                in varchar2
  ,p_body_part_o                  in varchar2
  ,p_treatment_received_flag_o    in varchar2
  ,p_hospital_details_o           in varchar2
    ,p_emergency_code_o                 in     varchar2
    ,p_hospitalized_flag_o              in     varchar2
    ,p_hospital_address_o               in     varchar2
    ,p_activity_at_time_of_work_o       in     varchar2
    ,p_objects_involved_o               in     varchar2
    ,p_privacy_issue_o                  in     varchar2
    ,p_work_start_time_o                in     varchar2
    ,p_date_of_death_o                  in     date
    ,p_report_completed_by_o            in     varchar2
    ,p_reporting_person_title_o         in     varchar2
    ,p_reporting_person_phone_o         in     varchar2
    ,p_days_restricted_work_o           in     number
    ,p_days_away_from_work_o            in     number
  ,p_doctor_name_o                in varchar2
  ,p_compensation_date_o          in date
  ,p_compensation_currency_o      in varchar2
  ,p_compensation_amount_o        in number
  ,p_remedial_hs_action_o         in varchar2
  ,p_notified_hsrep_id_o          in number
  ,p_notified_hsrep_date_o        in date
  ,p_notified_rep_id_o            in number
  ,p_notified_rep_date_o          in date
  ,p_notified_rep_org_id_o        in number
  ,p_related_incident_id_o        in number
  ,p_over_time_flag_o             in varchar2
  ,p_absence_exists_flag_o        in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_inc_information_category_o   in varchar2
  ,p_inc_information1_o           in varchar2
  ,p_inc_information2_o           in varchar2
  ,p_inc_information3_o           in varchar2
  ,p_inc_information4_o           in varchar2
  ,p_inc_information5_o           in varchar2
  ,p_inc_information6_o           in varchar2
  ,p_inc_information7_o           in varchar2
  ,p_inc_information8_o           in varchar2
  ,p_inc_information9_o           in varchar2
  ,p_inc_information10_o          in varchar2
  ,p_inc_information11_o          in varchar2
  ,p_inc_information12_o          in varchar2
  ,p_inc_information13_o          in varchar2
  ,p_inc_information14_o          in varchar2
  ,p_inc_information15_o          in varchar2
  ,p_inc_information16_o          in varchar2
  ,p_inc_information17_o          in varchar2
  ,p_inc_information18_o          in varchar2
  ,p_inc_information19_o          in varchar2
  ,p_inc_information20_o          in varchar2
  ,p_inc_information21_o          in varchar2
  ,p_inc_information22_o          in varchar2
  ,p_inc_information23_o          in varchar2
  ,p_inc_information24_o          in varchar2
  ,p_inc_information25_o          in varchar2
  ,p_inc_information26_o          in varchar2
  ,p_inc_information27_o          in varchar2
  ,p_inc_information28_o          in varchar2
  ,p_inc_information29_o          in varchar2
  ,p_inc_information30_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_inc_rkd;

 

/
