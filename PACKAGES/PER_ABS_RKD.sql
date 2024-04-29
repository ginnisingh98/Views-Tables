--------------------------------------------------------
--  DDL for Package PER_ABS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_RKD" AUTHID CURRENT_USER as
/* $Header: peabsrhi.pkh 120.3.12010000.3 2009/12/22 10:04:55 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_absence_attendance_id        in number
  ,p_business_group_id_o          in number
  ,p_absence_attendance_type_id_o in number
  ,p_abs_attendance_reason_id_o   in number
  ,p_person_id_o                  in number
  ,p_authorising_person_id_o      in number
  ,p_replacement_person_id_o      in number
  ,p_period_of_incapacity_id_o    in number
  ,p_absence_days_o               in number
  ,p_absence_hours_o              in number
  ,p_comments_o                   in varchar2
  ,p_date_end_o                   in date
  ,p_date_notification_o          in date
  ,p_date_projected_end_o         in date
  ,p_date_projected_start_o       in date
  ,p_date_start_o                 in date
  ,p_occurrence_o                 in number
  ,p_ssp1_issued_o                in varchar2
  ,p_time_end_o                   in varchar2
  ,p_time_projected_end_o         in varchar2
  ,p_time_projected_start_o       in varchar2
  ,p_time_start_o                 in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
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
  ,p_maternity_id_o               in number
  ,p_sickness_start_date_o        in date
  ,p_sickness_end_date_o          in date
  ,p_pregnancy_related_illness_o  in varchar2
  ,p_reason_for_notification_de_o in varchar2
  ,p_accept_late_notification_f_o in varchar2
  ,p_linked_absence_id_o          in number
  ,p_abs_information_category_o   in varchar2
  ,p_abs_information1_o           in varchar2
  ,p_abs_information2_o           in varchar2
  ,p_abs_information3_o           in varchar2
  ,p_abs_information4_o           in varchar2
  ,p_abs_information5_o           in varchar2
  ,p_abs_information6_o           in varchar2
  ,p_abs_information7_o           in varchar2
  ,p_abs_information8_o           in varchar2
  ,p_abs_information9_o           in varchar2
  ,p_abs_information10_o          in varchar2
  ,p_abs_information11_o          in varchar2
  ,p_abs_information12_o          in varchar2
  ,p_abs_information13_o          in varchar2
  ,p_abs_information14_o          in varchar2
  ,p_abs_information15_o          in varchar2
  ,p_abs_information16_o          in varchar2
  ,p_abs_information17_o          in varchar2
  ,p_abs_information18_o          in varchar2
  ,p_abs_information19_o          in varchar2
  ,p_abs_information20_o          in varchar2
  ,p_abs_information21_o          in varchar2
  ,p_abs_information22_o          in varchar2
  ,p_abs_information23_o          in varchar2
  ,p_abs_information24_o          in varchar2
  ,p_abs_information25_o          in varchar2
  ,p_abs_information26_o          in varchar2
  ,p_abs_information27_o          in varchar2
  ,p_abs_information28_o          in varchar2
  ,p_abs_information29_o          in varchar2
  ,p_abs_information30_o          in varchar2
  ,p_absence_case_id_o            in number
  ,p_batch_id_o                   in number
  ,p_object_version_number_o      in number
  );
--
end per_abs_rkd;

/
