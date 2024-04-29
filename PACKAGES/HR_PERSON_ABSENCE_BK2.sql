--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_BK2" AUTHID CURRENT_USER as
/* $Header: peabsapi.pkh 120.4.12010000.13 2009/10/09 07:46:59 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_person_absence_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_absence_b
  (p_effective_date                in     date
  ,p_absence_attendance_id         in     number
  ,p_object_version_number         in     number
  ,p_abs_attendance_reason_id      in     number
  ,p_comments                      in     long
  ,p_date_notification             in     date
  ,p_date_projected_start          in     date
  ,p_time_projected_start          in     varchar2
  ,p_date_projected_end            in     date
  ,p_time_projected_end            in     varchar2
  ,p_date_start                    in     date
  ,p_time_start                    in     varchar2
  ,p_date_end                      in     date
  ,p_time_end                      in     varchar2
  ,p_absence_days                  in     number
  ,p_absence_hours                 in     number
  ,p_authorising_person_id         in     number
  ,p_replacement_person_id         in     number
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
  ,p_period_of_incapacity_id       in     number
  ,p_ssp1_issued                   in     varchar2
  ,p_maternity_id                  in     number
  ,p_sickness_start_date           in     date
  ,p_sickness_end_date             in     date
  ,p_pregnancy_related_illness     in     varchar2
  ,p_reason_for_notification_dela  in     varchar2
  ,p_accept_late_notification_fla  in     varchar2
  ,p_linked_absence_id             in     number
  ,p_batch_id                      in     number
  ,p_abs_information_category      in     varchar2
  ,p_abs_information1              in     varchar2
  ,p_abs_information2              in     varchar2
  ,p_abs_information3              in     varchar2
  ,p_abs_information4              in     varchar2
  ,p_abs_information5              in     varchar2
  ,p_abs_information6              in     varchar2
  ,p_abs_information7              in     varchar2
  ,p_abs_information8              in     varchar2
  ,p_abs_information9              in     varchar2
  ,p_abs_information10             in     varchar2
  ,p_abs_information11             in     varchar2
  ,p_abs_information12             in     varchar2
  ,p_abs_information13             in     varchar2
  ,p_abs_information14             in     varchar2
  ,p_abs_information15             in     varchar2
  ,p_abs_information16             in     varchar2
  ,p_abs_information17             in     varchar2
  ,p_abs_information18             in     varchar2
  ,p_abs_information19             in     varchar2
  ,p_abs_information20             in     varchar2
  ,p_abs_information21             in     varchar2
  ,p_abs_information22             in     varchar2
  ,p_abs_information23             in     varchar2
  ,p_abs_information24             in     varchar2
  ,p_abs_information25             in     varchar2
  ,p_abs_information26             in     varchar2
  ,p_abs_information27             in     varchar2
  ,p_abs_information28             in     varchar2
  ,p_abs_information29             in     varchar2
  ,p_abs_information30             in     varchar2
  ,p_absence_case_id               in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_absence_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_absence_a
  (p_effective_date                in     date
  ,p_absence_attendance_id         in     number
  ,p_object_version_number         in     number
  ,p_abs_attendance_reason_id      in     number
  ,p_comments                      in     long
  ,p_date_notification             in     date
  ,p_date_projected_start          in     date
  ,p_time_projected_start          in     varchar2
  ,p_date_projected_end            in     date
  ,p_time_projected_end            in     varchar2
  ,p_date_start                    in     date
  ,p_time_start                    in     varchar2
  ,p_date_end                      in     date
  ,p_time_end                      in     varchar2
  ,p_absence_days                  in     number
  ,p_absence_hours                 in     number
  ,p_authorising_person_id         in     number
  ,p_replacement_person_id         in     number
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
  ,p_period_of_incapacity_id       in     number
  ,p_ssp1_issued                   in     varchar2
  ,p_maternity_id                  in     number
  ,p_sickness_start_date           in     date
  ,p_sickness_end_date             in     date
  ,p_pregnancy_related_illness     in     varchar2
  ,p_reason_for_notification_dela  in     varchar2
  ,p_accept_late_notification_fla  in     varchar2
  ,p_linked_absence_id             in     number
  ,p_batch_id                      in     number
  ,p_abs_information_category      in     varchar2
  ,p_abs_information1              in     varchar2
  ,p_abs_information2              in     varchar2
  ,p_abs_information3              in     varchar2
  ,p_abs_information4              in     varchar2
  ,p_abs_information5              in     varchar2
  ,p_abs_information6              in     varchar2
  ,p_abs_information7              in     varchar2
  ,p_abs_information8              in     varchar2
  ,p_abs_information9              in     varchar2
  ,p_abs_information10             in     varchar2
  ,p_abs_information11             in     varchar2
  ,p_abs_information12             in     varchar2
  ,p_abs_information13             in     varchar2
  ,p_abs_information14             in     varchar2
  ,p_abs_information15             in     varchar2
  ,p_abs_information16             in     varchar2
  ,p_abs_information17             in     varchar2
  ,p_abs_information18             in     varchar2
  ,p_abs_information19             in     varchar2
  ,p_abs_information20             in     varchar2
  ,p_abs_information21             in     varchar2
  ,p_abs_information22             in     varchar2
  ,p_abs_information23             in     varchar2
  ,p_abs_information24             in     varchar2
  ,p_abs_information25             in     varchar2
  ,p_abs_information26             in     varchar2
  ,p_abs_information27             in     varchar2
  ,p_abs_information28             in     varchar2
  ,p_abs_information29             in     varchar2
  ,p_abs_information30             in     varchar2
  ,p_absence_case_id               in     number
  ,p_dur_dys_less_warning          in     boolean
  ,p_dur_hrs_less_warning          in     boolean
  ,p_exceeds_pto_entit_warning     in     boolean
  ,p_exceeds_run_total_warning     in     boolean
  ,p_abs_overlap_warning           in     boolean
  ,p_abs_day_after_warning         in     boolean
  ,p_dur_overwritten_warning       in     boolean
  ,p_del_element_entry_warning     in     boolean
  );
--
end hr_person_absence_bk2;

/
