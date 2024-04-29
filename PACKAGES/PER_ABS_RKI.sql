--------------------------------------------------------
--  DDL for Package PER_ABS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_RKI" AUTHID CURRENT_USER as
/* $Header: peabsrhi.pkh 120.3.12010000.3 2009/12/22 10:04:55 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_absence_attendance_id        in number
  ,p_business_group_id            in number
  ,p_absence_attendance_type_id   in number
  ,p_abs_attendance_reason_id     in number
  ,p_person_id                    in number
  ,p_authorising_person_id        in number
  ,p_replacement_person_id        in number
  ,p_period_of_incapacity_id      in number
  ,p_absence_days                 in number
  ,p_absence_hours                in number
  ,p_comments                     in varchar2
  ,p_date_end                     in date
  ,p_date_notification            in date
  ,p_date_projected_end           in date
  ,p_date_projected_start         in date
  ,p_date_start                   in date
  ,p_occurrence                   in number
  ,p_ssp1_issued                  in varchar2
  ,p_time_end                     in varchar2
  ,p_time_projected_end           in varchar2
  ,p_time_projected_start         in varchar2
  ,p_time_start                   in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_maternity_id                 in number
  ,p_sickness_start_date          in date
  ,p_sickness_end_date            in date
  ,p_pregnancy_related_illness    in varchar2
  ,p_reason_for_notification_dela in varchar2
  ,p_accept_late_notification_fla in varchar2
  ,p_linked_absence_id            in number
  ,p_abs_information_category     in varchar2
  ,p_abs_information1             in varchar2
  ,p_abs_information2             in varchar2
  ,p_abs_information3             in varchar2
  ,p_abs_information4             in varchar2
  ,p_abs_information5             in varchar2
  ,p_abs_information6             in varchar2
  ,p_abs_information7             in varchar2
  ,p_abs_information8             in varchar2
  ,p_abs_information9             in varchar2
  ,p_abs_information10            in varchar2
  ,p_abs_information11            in varchar2
  ,p_abs_information12            in varchar2
  ,p_abs_information13            in varchar2
  ,p_abs_information14            in varchar2
  ,p_abs_information15            in varchar2
  ,p_abs_information16            in varchar2
  ,p_abs_information17            in varchar2
  ,p_abs_information18            in varchar2
  ,p_abs_information19            in varchar2
  ,p_abs_information20            in varchar2
  ,p_abs_information21            in varchar2
  ,p_abs_information22            in varchar2
  ,p_abs_information23            in varchar2
  ,p_abs_information24            in varchar2
  ,p_abs_information25            in varchar2
  ,p_abs_information26            in varchar2
  ,p_abs_information27            in varchar2
  ,p_abs_information28            in varchar2
  ,p_abs_information29            in varchar2
  ,p_abs_information30            in varchar2
  ,p_absence_case_id              in number
  ,p_batch_id                     in number
  ,p_object_version_number        in number
  );
end per_abs_rki;

/