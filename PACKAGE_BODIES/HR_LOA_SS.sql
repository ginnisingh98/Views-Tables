--------------------------------------------------------
--  DDL for Package Body HR_LOA_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOA_SS" 
/* $Header: hrloawrs.pkb 120.7.12010000.8 2009/12/22 11:02:14 pthoonig ship $*/
AS
g_package      constant varchar2(75):='HR_LOA_SS.';
g_data_error            exception;
g_date_format  constant varchar2(10):='RRRR-MM-DD';
g_confirm      constant varchar2(9):='CONFIRMED';
g_planned      constant varchar2(7):='PLANNED';
g_usr_date_fmt       varchar2(20) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
g_usr_day_time_fmt  varchar(40) := g_usr_date_fmt|| ' HH24:MI:SS';

--2793140 change starts
--cursor to fetch the absence row from per_absence_attendances
CURSOR gc_get_absence_row (p_absence_attendance_id in number) IS
SELECT     paa.absence_attendance_type_id
          ,paa.business_group_id
          ,paa.person_id
          ,paa.abs_attendance_reason_id
          ,paa.authorising_person_id
          ,paa.replacement_person_id
          ,paa.absence_days
          ,paa.absence_hours
          ,paa.date_projected_start
          ,paa.time_projected_start
          ,paa.date_projected_end
          ,paa.time_projected_end
          ,paa.date_start
          ,paa.time_start
          ,paa.date_end
          ,paa.time_end
          ,paa.comments
          ,paa.absence_attendance_id
          ,paa.object_version_number
          ,paa.date_notification
          ,paa.attribute_category
          ,paa.attribute1
	  ,paa.attribute2
	  ,paa.attribute3
	  ,paa.attribute4
	  ,paa.attribute5
	 ,paa.attribute6
	 ,paa.attribute7
	 ,paa.attribute8
	 ,paa.attribute9
	 ,paa.attribute10
	 ,paa.attribute11
	 ,paa.attribute12
	 ,paa.attribute13
	 ,paa.attribute14
	 ,paa.attribute15
	 ,paa.attribute16
	 ,paa.attribute17
	 ,paa.attribute18
	 ,paa.attribute19
	 ,paa.attribute20
	 ,paa.abs_information_category
	 ,paa.abs_information1
	 ,paa.abs_information2
	 ,paa.abs_information3
	 ,paa.abs_information4
	 ,paa.abs_information5
	 ,paa.abs_information6
	 ,paa.abs_information7
	 ,paa.abs_information8
	 ,paa.abs_information9
	 ,paa.abs_information10
	 ,paa.abs_information11
	 ,paa.abs_information12
	 ,paa.abs_information13
	 ,paa.abs_information14
	 ,paa.abs_information15
	 ,paa.abs_information16
	 ,paa.abs_information17
	 ,paa.abs_information18
	 ,paa.abs_information19
	 ,paa.abs_information20
	 ,paa.abs_information21
	 ,paa.abs_information22
	 ,paa.abs_information23
	 ,paa.abs_information24
	 ,paa.abs_information25
	 ,paa.abs_information26
	 ,paa.abs_information27
	 ,paa.abs_information28
	 ,paa.abs_information29
	 ,paa.abs_information30
FROM per_absence_attendances paa
WHERE   paa.absence_attendance_id = p_absence_attendance_id;

--2793140 change ends
  /*
  ||===========================================================================
  || PROCEDURE: create_person_absence
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_absence_api.create_person_absence()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE create_person_absence
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     date     default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
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
  ,p_period_of_incapacity_id       in     number   default null
  ,p_ssp1_issued                   in     varchar2 default 'N'
  ,p_maternity_id                  in     number   default null
  ,p_sickness_start_date           in     date     default null
  ,p_sickness_end_date             in     date     default null
  ,p_pregnancy_related_illness     in     varchar2 default 'N'
  ,p_reason_for_notification_dela  in     varchar2 default null
  ,p_accept_late_notification_fla  in     varchar2 default 'N'
  ,p_linked_absence_id             in     number   default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  )
  IS

    l_proc                       varchar2(72) := g_package||'create_person_absence';
    lb_abs_day_after_warning     BOOLEAN;
    lb_abs_overlap_warning       BOOLEAN;
    lb_dur_dys_less_warning      BOOLEAN;
    lb_dur_hrs_less_warning      BOOLEAN;
    lb_exceeds_pto_entit_warning BOOLEAN;
    lb_exceeds_run_total_warning BOOLEAN;
    lb_dur_overwritten_warning   BOOLEAN;


  BEGIN
  --
  --
  --
    hr_utility.set_location(' Entering:' || l_proc,5);

    -- Call the actual API.
    hr_person_absence_api.create_person_absence
      (p_validate                      => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
      ,p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => p_absence_days
      ,p_absence_hours                 => p_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
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
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_abs_information_category            => p_abs_information_category
      ,p_abs_information1                    => p_abs_information1
      ,p_abs_information2                    => p_abs_information2
      ,p_abs_information3                    => p_abs_information3
      ,p_abs_information4                    => p_abs_information4
      ,p_abs_information5                    => p_abs_information5
      ,p_abs_information6                    => p_abs_information6
      ,p_abs_information7                    => p_abs_information7
      ,p_abs_information8                    => p_abs_information8
      ,p_abs_information9                    => p_abs_information9
      ,p_abs_information10                   => p_abs_information10
      ,p_abs_information11                   => p_abs_information11
      ,p_abs_information12                   => p_abs_information12
      ,p_abs_information13                   => p_abs_information13
      ,p_abs_information14                   => p_abs_information14
      ,p_abs_information15                   => p_abs_information15
      ,p_abs_information16                   => p_abs_information16
      ,p_abs_information17                   => p_abs_information17
      ,p_abs_information18                   => p_abs_information18
      ,p_abs_information19                   => p_abs_information19
      ,p_abs_information20                   => p_abs_information20
      ,p_abs_information21                   => p_abs_information21
      ,p_abs_information22                   => p_abs_information22
      ,p_abs_information23                   => p_abs_information23
      ,p_abs_information24                   => p_abs_information24
      ,p_abs_information25                   => p_abs_information25
      ,p_abs_information26                   => p_abs_information26
      ,p_abs_information27                   => p_abs_information27
      ,p_abs_information28                   => p_abs_information28
      ,p_abs_information29                   => p_abs_information29
      ,p_abs_information30                   => p_abs_information30
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_occurrence                    => p_occurrence
      ,p_dur_dys_less_warning          => lb_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => lb_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => lb_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => lb_exceeds_run_total_warning
      ,p_abs_overlap_warning           => lb_abs_overlap_warning
      ,p_abs_day_after_warning         => lb_abs_day_after_warning
      ,p_dur_overwritten_warning       => lb_dur_overwritten_warning
    );
    hr_utility.set_location( l_proc,10);

      p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
      p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
      p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
      p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
      p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
      p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
      p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

 hr_utility.set_location(' Leaving:' || l_proc,15);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in HR_LOA_SS.create_person_absence: ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,555);

      RAISE;  -- Raise error here relevant to the new tech stack.

  END create_person_absence;

  --2793140 change starts
  /*
  ||===========================================================================
  || PROCEDURE: is_rec_changed
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will check if the user has changed the data or not
  ||
  || Access Status:
  ||     Private.
  ||
  ||===========================================================================
  */

  FUNCTION  is_rec_changed
    (p_effective_date                in     date   default hr_api.g_date
  ,p_absence_attendance_id         in     number   default hr_api.g_number
  ,p_abs_attendance_reason_id      in     number   default hr_api.g_number
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_date_notification             in     date     default hr_api.g_date
  ,p_date_projected_start          in     date     default hr_api.g_date
  ,p_time_projected_start          in     varchar2 default hr_api.g_varchar2
  ,p_date_projected_end            in     date     default hr_api.g_date
  ,p_time_projected_end            in     varchar2 default hr_api.g_varchar2
  ,p_date_start                    in     date     default hr_api.g_date
  ,p_time_start                    in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_time_end                      in     varchar2 default hr_api.g_varchar2
  ,p_absence_days                  in     number   default hr_api.g_number
  ,p_absence_hours                 in     number   default hr_api.g_number
  ,p_authorising_person_id         in     number   default hr_api.g_number
  ,p_replacement_person_id         in     number   default hr_api.g_number
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
  ,p_absiod_of_incapacity_id       in     number   default hr_api.g_number
  ,p_ssp1_issued                   in     varchar2 default hr_api.g_varchar2
  ,p_maternity_id                  in     number   default hr_api.g_number
  ,p_sickness_start_date           in     date     default hr_api.g_date
  ,p_sickness_end_date             in     date     default hr_api.g_date
  ,p_pregnancy_related_illness     in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_notification_dela  in     varchar2 default hr_api.g_varchar2
  ,p_accept_late_notification_fla  in     varchar2 default hr_api.g_varchar2
  ,p_linked_absence_id             in     number   default hr_api.g_number
  ,p_batch_id                      in     number   default hr_api.g_number
  ,p_abs_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_abs_information1              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information2              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information3              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information4              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information5              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information6              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information7              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information8              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information9              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information10             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information11             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information12             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information13             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information14             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information15             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information16             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information17             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information18             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information19             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information20             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information21             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information22             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information23             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information24             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information25             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information26             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information27             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information28             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information29             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information30             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in     number   default hr_api.g_number
   )
   return boolean
   IS

  l_proc varchar2(200) := g_package || 'is_rec_changed';
  l_rec_changed                    boolean default false;
  l_cur_absence_row                gc_get_absence_row%rowtype;
  custom_exc exception;
--
BEGIN

  hr_utility.set_location(' Entering:' || l_proc,5);

  OPEN gc_get_absence_row (p_absence_attendance_id => p_absence_attendance_id);

  FETCH gc_get_absence_row into l_cur_absence_row;
  IF gc_get_absence_row%NOTFOUND
  THEN
     hr_utility.set_location(l_proc,10);
     CLOSE gc_get_absence_row;
     raise g_data_error;
  ELSE
     hr_utility.set_location(l_proc,15);
     CLOSE gc_get_absence_row;
  END IF;
--
------------------------------------------------------------------------------
-- NOTE: We need to use nvl(xxx attribute name, hr_api.g_xxxx) because the
--       parameter coming in can be null.  If we do not use nvl, then it will
--       never be equal to the database null value if the parameter value is
--       also null.
------------------------------------------------------------------------------
  IF p_date_projected_start <> hr_api.g_date OR p_date_projected_start IS NULL
  THEN
     hr_utility.set_location(l_proc,20);
     IF nvl(p_date_projected_start, hr_api.g_date) <>
        nvl(l_cur_absence_row.date_projected_start, hr_api.g_date)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,25);
        return TRUE;
     END IF;
  END IF;
--
  IF p_date_projected_end <> hr_api.g_date OR p_date_projected_end IS NULL
    THEN
     IF nvl(p_date_projected_end, hr_api.g_date) <>
        nvl(l_cur_absence_row.date_projected_end, hr_api.g_date)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,30);
        return TRUE;
     END IF;
  END IF;
--
  IF p_time_projected_start <> hr_api.g_varchar2 OR p_time_projected_start IS NULL
  THEN
     IF nvl(p_time_projected_start, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.time_projected_start, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,35);
	return TRUE;
     END IF;
  END IF;
--
  IF p_time_projected_end <> hr_api.g_varchar2 OR p_time_projected_end IS NULL
  THEN
     IF nvl(p_time_projected_end, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.time_projected_end, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,40);
	return TRUE;
     END IF;
  END IF;
--
  IF p_date_start <> hr_api.g_date OR p_date_start IS NULL
  THEN
     IF nvl(p_date_start, hr_api.g_date) <>
        nvl(l_cur_absence_row.date_start, hr_api.g_date)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,45);
	return TRUE;
     END IF;
  END IF;
--
  IF p_date_end <> hr_api.g_date OR p_date_end IS NULL
    THEN
     IF nvl(p_date_end, hr_api.g_date) <>
        nvl(l_cur_absence_row.date_end, hr_api.g_date)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,50);
	return TRUE;
     END IF;
  END IF;
--
  IF p_time_start <> hr_api.g_varchar2 OR p_time_start IS NULL
  THEN
     IF nvl(p_time_start, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.time_start, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,55);
	return TRUE;
     END IF;
  END IF;
--
  IF p_time_end <> hr_api.g_varchar2 OR p_time_end IS NULL
  THEN
     IF nvl(p_time_end, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.time_end, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,60);
	return TRUE;
     END IF;
  END IF;
--
  IF p_absence_days <> hr_api.g_number OR p_absence_days IS NULL
  THEN
     IF nvl(p_absence_days, hr_api.g_number) <>
        nvl(l_cur_absence_row.absence_days, hr_api.g_number)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,65);
	return TRUE;
     END IF;
  END IF;
--
  IF p_absence_hours <> hr_api.g_number OR p_absence_hours IS NULL
  THEN
     IF nvl(p_absence_hours, hr_api.g_number) <>
        nvl(l_cur_absence_row.absence_hours, hr_api.g_number)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,70);
	return TRUE;
     END IF;
  END IF;
--
  IF p_replacement_person_id <> hr_api.g_number OR p_replacement_person_id IS NULL
  THEN
     IF nvl(p_replacement_person_id, hr_api.g_number) <>
        nvl(l_cur_absence_row.replacement_person_id, hr_api.g_number)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,70);
	return TRUE;
     END IF;
  END IF;
--
  IF p_comments <> hr_api.g_varchar2 OR p_comments IS NULL
  THEN
     IF nvl(p_comments, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.comments, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,75);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute_category <> hr_api.g_varchar2 OR p_attribute_category IS NULL
  THEN
     IF nvl(p_attribute_category, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute_category, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,80);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute1 <> hr_api.g_varchar2 OR p_attribute1 IS NULL
  THEN
     IF nvl(p_attribute1, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute1, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,85);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute2 <> hr_api.g_varchar2 OR p_attribute2 IS NULL
  THEN
     IF nvl(p_attribute2, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute2, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,90);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute3 <> hr_api.g_varchar2 OR p_attribute3 IS NULL
  THEN
     IF nvl(p_attribute3, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute3, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,95);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute4 <> hr_api.g_varchar2 OR p_attribute4 IS NULL
  THEN
     IF nvl(p_attribute4, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute4, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,100);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute5 <> hr_api.g_varchar2 OR p_attribute5 IS NULL
  THEN
     IF nvl(p_attribute5, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute5, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,105);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute6 <> hr_api.g_varchar2 OR p_attribute6 IS NULL
  THEN
     IF nvl(p_attribute6, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute6, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,110);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute7 <> hr_api.g_varchar2 OR p_attribute7 IS NULL
  THEN
     IF nvl(p_attribute7, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute7, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,115);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute8 <> hr_api.g_varchar2 OR p_attribute8 IS NULL
  THEN
     IF nvl(p_attribute8, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute8, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,120);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute9 <> hr_api.g_varchar2 OR p_attribute9 IS NULL
  THEN
     IF nvl(p_attribute9, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute9, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,125);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute10 <> hr_api.g_varchar2 OR p_attribute10 IS NULL
  THEN
     IF nvl(p_attribute10, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute10, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,130);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute11 <> hr_api.g_varchar2 OR p_attribute11 IS NULL
  THEN
     IF nvl(p_attribute11, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute11, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,135);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute12 <> hr_api.g_varchar2 OR p_attribute12 IS NULL
  THEN
     IF nvl(p_attribute12, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute12, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,140);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute13 <> hr_api.g_varchar2 OR p_attribute13 IS NULL
  THEN
     IF nvl(p_attribute13, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute13, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,145);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute14 <> hr_api.g_varchar2 OR p_attribute14 IS NULL
  THEN
     IF nvl(p_attribute14, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute14, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,150);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute15 <> hr_api.g_varchar2 OR p_attribute15 IS NULL
  THEN
     IF nvl(p_attribute15, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute15, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,155);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute16 <> hr_api.g_varchar2 OR p_attribute16 IS NULL
  THEN
     IF nvl(p_attribute16, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute16, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,160);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute17 <> hr_api.g_varchar2 OR p_attribute17 IS NULL
  THEN
     IF nvl(p_attribute17, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute17, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,165);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute18 <> hr_api.g_varchar2 OR p_attribute18 IS NULL
  THEN
     IF nvl(p_attribute18, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute18, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,170);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute19 <> hr_api.g_varchar2 OR p_attribute19 IS NULL
  THEN
     IF nvl(p_attribute19, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute19, hr_api.g_varchar2)
     THEN
        hr_utility.set_location(' Leaving:' || l_proc,175);
	return TRUE;
     END IF;
  END IF;
--
  IF p_attribute20 <> hr_api.g_varchar2 OR p_attribute20 IS NULL
  THEN
     IF nvl(p_attribute20, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.attribute20, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,180);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information_category <> hr_api.g_varchar2 OR p_abs_information_category IS NULL
  THEN
     IF nvl(p_abs_information_category, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information_category, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,185);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information1 <> hr_api.g_varchar2 OR p_abs_information1 IS NULL
  THEN
     IF nvl(p_abs_information1, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information1, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,190);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information2 <> hr_api.g_varchar2 OR p_abs_information2 IS NULL
  THEN
     IF nvl(p_abs_information2, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information2, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,195);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information3 <> hr_api.g_varchar2 OR p_abs_information3 IS NULL
  THEN
     IF nvl(p_abs_information3, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information3, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,200);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information4 <> hr_api.g_varchar2 OR p_abs_information4 IS NULL
  THEN
     IF nvl(p_abs_information4, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information4, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,205);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information5 <> hr_api.g_varchar2 OR p_abs_information5 IS NULL
  THEN
     IF nvl(p_abs_information5, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information5, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,210);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information6 <> hr_api.g_varchar2 OR p_abs_information6 IS NULL
  THEN
     IF nvl(p_abs_information6, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information6, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,215);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information7 <> hr_api.g_varchar2 OR p_abs_information7 IS NULL
  THEN
     IF nvl(p_abs_information7, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information7, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,220);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information8 <> hr_api.g_varchar2 OR p_abs_information8 IS NULL
  THEN
     IF nvl(p_abs_information8, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information8, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,225);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information9 <> hr_api.g_varchar2 OR p_abs_information9 IS NULL
  THEN
     IF nvl(p_abs_information9, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information9, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,230);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information10 <> hr_api.g_varchar2 OR p_abs_information10 IS NULL
  THEN
     IF nvl(p_abs_information10, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information10, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,235);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information11 <> hr_api.g_varchar2 OR p_abs_information11 IS NULL
  THEN
     IF nvl(p_abs_information11, hr_api.g_varchar2) <>
     nvl(l_cur_absence_row.abs_information11, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,240);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information12 <> hr_api.g_varchar2 OR p_abs_information12 IS NULL
  THEN
     IF nvl(p_abs_information12, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information12, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,245);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information13 <> hr_api.g_varchar2 OR p_abs_information13 IS NULL
  THEN
     IF nvl(p_abs_information13, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information13, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,250);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information14 <> hr_api.g_varchar2 OR p_abs_information14 IS NULL
  THEN
     IF nvl(p_abs_information14, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information14, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,255);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information15 <> hr_api.g_varchar2 OR p_abs_information15 IS NULL
  THEN
     IF nvl(p_abs_information15, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information15, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,260);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information16 <> hr_api.g_varchar2 OR p_abs_information16 IS NULL
  THEN
     IF nvl(p_abs_information16, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information16, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,265);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information17 <> hr_api.g_varchar2 OR p_abs_information17 IS NULL
  THEN
     IF nvl(p_abs_information17, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information17, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,270);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information18 <> hr_api.g_varchar2 OR p_abs_information18 IS NULL
  THEN
     IF nvl(p_abs_information18, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information18, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,275);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information19 <> hr_api.g_varchar2 OR p_abs_information19 IS NULL
  THEN
     IF nvl(p_abs_information19, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information19, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,280);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information20 <> hr_api.g_varchar2 OR p_abs_information20 IS NULL
  THEN
     IF nvl(p_abs_information20, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information20, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,285);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information21 <> hr_api.g_varchar2 OR p_abs_information21 IS NULL
  THEN
     IF nvl(p_abs_information21, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information21, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,290);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information22 <> hr_api.g_varchar2 OR p_abs_information22 IS NULL
  THEN
     IF nvl(p_abs_information22, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information22, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,295);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information23 <> hr_api.g_varchar2 OR p_abs_information23 IS NULL
  THEN
     IF nvl(p_abs_information23, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information23, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,300);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information24 <> hr_api.g_varchar2 OR p_abs_information24 IS NULL
  THEN
     IF nvl(p_abs_information24, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information24, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,305);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information25 <> hr_api.g_varchar2 OR p_abs_information25 IS NULL
  THEN
     IF nvl(p_abs_information25, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information25, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,310);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information26 <> hr_api.g_varchar2 OR p_abs_information26 IS NULL
  THEN
     IF nvl(p_abs_information26, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information26, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,315);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information27 <> hr_api.g_varchar2 OR p_abs_information27 IS NULL
  THEN
     IF nvl(p_abs_information27, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information27, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,320);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information28 <> hr_api.g_varchar2 OR p_abs_information28 IS NULL
  THEN
     IF nvl(p_abs_information28, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information28, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,325);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information29 <> hr_api.g_varchar2 OR p_abs_information29 IS NULL
  THEN
     IF nvl(p_abs_information29, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information29, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,330);
	return TRUE;
     END IF;
  END IF;
--
  IF p_abs_information30 <> hr_api.g_varchar2 OR p_abs_information30 IS NULL
  THEN
     IF nvl(p_abs_information30, hr_api.g_varchar2) <>
        nvl(l_cur_absence_row.abs_information30, hr_api.g_varchar2)
     THEN
     hr_utility.set_location(' Leaving:' || l_proc,335);
	return TRUE;
     END IF;
  END IF;
--
hr_utility.set_location(' Leaving:' || l_proc,340);
  RETURN FALSE;


EXCEPTION
  When g_data_error THEN
  hr_utility.set_location(' Leaving:' || l_proc,555);
       raise;

  When others THEN
  hr_utility.set_location(' Leaving:' || l_proc,560);
       raise;

END is_rec_changed;

  --2793140 change ends

  /*
  ||===========================================================================
  || PROCEDURE: update_person_absence
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_absence_api.update_person_absence()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

 PROCEDURE update_person_absence
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_absence_attendance_id         in     number
  ,p_abs_attendance_reason_id      in     number   default hr_api.g_number
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_date_notification             in     date     default hr_api.g_date
  ,p_date_projected_start          in     date     default hr_api.g_date
  ,p_time_projected_start          in     varchar2 default hr_api.g_varchar2
  ,p_date_projected_end            in     date     default hr_api.g_date
  ,p_time_projected_end            in     varchar2 default hr_api.g_varchar2
  ,p_date_start                    in     date     default hr_api.g_date
  ,p_time_start                    in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_time_end                      in     varchar2 default hr_api.g_varchar2
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default hr_api.g_number
  ,p_replacement_person_id         in     number   default hr_api.g_number
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
  ,p_period_of_incapacity_id       in     number   default hr_api.g_number
  ,p_ssp1_issued                   in     varchar2 default hr_api.g_varchar2
  ,p_maternity_id                  in     number   default hr_api.g_number
  ,p_sickness_start_date           in     date     default hr_api.g_date
  ,p_sickness_end_date             in     date     default hr_api.g_date
  ,p_pregnancy_related_illness     in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_notification_dela  in     varchar2 default hr_api.g_varchar2
  ,p_accept_late_notification_fla  in     varchar2 default hr_api.g_varchar2
  ,p_linked_absence_id             in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_del_element_entry_warning     out nocopy    number
  )
  IS

    l_proc                       varchar2(72) := g_package||'update_person_absence';
    lb_abs_day_after_warning     BOOLEAN;
    lb_abs_overlap_warning       BOOLEAN;
    lb_dur_dys_less_warning      BOOLEAN;
    lb_dur_hrs_less_warning      BOOLEAN;
    lb_exceeds_pto_entit_warning BOOLEAN;
    lb_exceeds_run_total_warning BOOLEAN;
    lb_dur_overwritten_warning   BOOLEAN;
    lb_del_element_entry_warning BOOLEAN;

  BEGIN
    hr_utility.set_location(' Entering:' || l_proc,5);


    -- Call the actual API.
    hr_person_absence_api.update_person_absence
      (p_validate                      => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
      ,p_effective_date                => p_effective_date
--      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => p_absence_days
      ,p_absence_hours                 => p_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
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
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_object_version_number         => p_object_version_number
      ,p_abs_information_category            => p_abs_information_category
      ,p_abs_information1                    => p_abs_information1
      ,p_abs_information2                    => p_abs_information2
      ,p_abs_information3                    => p_abs_information3
      ,p_abs_information4                    => p_abs_information4
      ,p_abs_information5                    => p_abs_information5
      ,p_abs_information6                    => p_abs_information6
      ,p_abs_information7                    => p_abs_information7
      ,p_abs_information8                    => p_abs_information8
      ,p_abs_information9                    => p_abs_information9
      ,p_abs_information10                   => p_abs_information10
      ,p_abs_information11                   => p_abs_information11
      ,p_abs_information12                   => p_abs_information12
      ,p_abs_information13                   => p_abs_information13
      ,p_abs_information14                   => p_abs_information14
      ,p_abs_information15                   => p_abs_information15
      ,p_abs_information16                   => p_abs_information16
      ,p_abs_information17                   => p_abs_information17
      ,p_abs_information18                   => p_abs_information18
      ,p_abs_information19                   => p_abs_information19
      ,p_abs_information20                   => p_abs_information20
      ,p_abs_information21                   => p_abs_information21
      ,p_abs_information22                   => p_abs_information22
      ,p_abs_information23                   => p_abs_information23
      ,p_abs_information24                   => p_abs_information24
      ,p_abs_information25                   => p_abs_information25
      ,p_abs_information26                   => p_abs_information26
      ,p_abs_information27                   => p_abs_information27
      ,p_abs_information28                   => p_abs_information28
      ,p_abs_information29                   => p_abs_information29
      ,p_abs_information30                   => p_abs_information30
      ,p_dur_dys_less_warning          => lb_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => lb_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => lb_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => lb_exceeds_run_total_warning
      ,p_abs_overlap_warning           => lb_abs_overlap_warning
      ,p_abs_day_after_warning         => lb_abs_day_after_warning
      ,p_dur_overwritten_warning       => lb_dur_overwritten_warning
      ,p_del_element_entry_warning     => lb_del_element_entry_warning
    );

      p_abs_day_after_warning :=  hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning );
      p_abs_overlap_warning :=  hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
      p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
      p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
      p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
      p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
      p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);
      p_del_element_entry_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_del_element_entry_warning);

hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in HR_LOA_SS.update_person_absence: ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,555);

      RAISE;  -- Raise error here relevant to the new tech stack.

  END update_person_absence;

/*
  ||===========================================================================
  || PROCEDURE: create_transactrion
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the following API
  ||                hr_transaction_ss
  ||                hr_transaction_api
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE  create_transaction(
     p_item_type           IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key  	   IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id    	   IN NUMBER ,
     p_activity_name       IN VARCHAR2,
     p_transaction_id      IN OUT NOCOPY NUMBER ,
     p_transaction_step_id IN OUT NOCOPY NUMBER,
     p_login_person_id     IN NUMBER,
     p_review_proc_call    IN VARCHAR2) IS

  l_proc                 varchar2(72) := g_package||'create_transaction';
  ln_transaction_id      NUMBER ;
  ln_transaction_step_id NUMBER ;
  lv_result  VARCHAR2(100) ;
  ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
  lv_activity_name        wf_item_activity_statuses_v.activity_name%TYPE;
  ln_trans_step_rows      number  default 0;
  ltt_trans_step_ids      hr_util_web.g_varchar2_tab_type;
  ln_ovn                  hr_api_transaction_steps.object_version_number%TYPE;
  lv_creator_person_id    per_all_people_f.person_id%TYPE;


  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);

    hr_util_misc_web.validate_session(p_person_id => lv_creator_person_id);


    ---------------------------------------------------------------------
    -- Check if there is already a transaction for this process?
    ---------------------------------------------------------------------
    ln_transaction_id := hr_transaction_ss.get_transaction_id
      (p_Item_Type => p_item_type
      ,p_Item_Key => p_item_key);


    IF ln_transaction_id IS NULL
    THEN
      hr_utility.set_location(l_proc,10);


      -------------------------------------------------------------------
      -- Create a new transaction
      -------------------------------------------------------------------
      hr_transaction_ss.start_transaction
      (itemtype => p_item_type
       ,itemkey => p_item_key
       ,actid => p_act_id
       ,funmode => 'RUN'
       ,p_login_person_id=>p_login_person_id
       ,result => lv_result);


       ln_transaction_id := hr_transaction_ss.get_transaction_id
                              (p_item_type => p_item_type
                               ,p_item_key => p_item_key);


    END IF;     -- now we have a valid txn id , let's find out txn steps

    hr_utility.set_location(l_proc,15);
    ---------------------------------------------------------------------
    -- There is already a transaction for this process.
    -- Retieve the transaction step for this current
    -- activity. We will update this transaction step with
    -- the new information.
    ---------------------------------------------------------------------

    hr_transaction_api.get_transaction_step_info
        (p_Item_Type     => p_item_type
        ,p_Item_Key      => p_item_key
        ,p_activity_id   => to_number(p_act_id)
        ,p_transaction_step_id => ltt_trans_step_ids
        ,p_object_version_number => ltt_trans_obj_vers_num
        ,p_rows                  => ln_trans_step_rows);


    IF ln_trans_step_rows < 1 THEN
      hr_utility.set_location(l_proc,20);

       ---------------------------------------------------------------------
       --There is no transaction step for this transaction.
       --Create a step within this new transaction
       ---------------------------------------------------------------------

       hr_transaction_api.create_transaction_step(
           p_validate => false
  	   ,p_creator_person_id => p_login_person_id
	   ,p_transaction_id => ln_transaction_id
	   ,p_api_name => 'HR_LOA_SS.PROCESS_API'
	   ,p_Item_Type => p_item_type
	   ,p_Item_Key => p_item_key
	   ,p_activity_id => p_act_id
	   ,p_transaction_step_id => ln_transaction_step_id
           ,p_object_version_number =>ln_ovn ) ;

    ELSE
        hr_utility.set_location(l_proc,25);
         ---------------------------------------------------------------------
	 --There are transaction steps for this transaction.
         --Get the Transaction Step ID for this activity.
         ---------------------------------------------------------------------
         ln_transaction_step_id :=
         hr_transaction_ss.get_activity_trans_step_id(
           p_activity_name => 'HR_CREATE_ABSENCE' ,
	   p_trans_step_id_tbl => ltt_trans_step_ids);

    END IF;

    hr_utility.set_location(l_proc,30);
 -- write  activity name  to txn table
 -- review page requires the following information
    hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>ln_transaction_step_id,
          p_person_id => lv_creator_person_id ,
          p_name => 'p_activity_name' ,
          p_value => p_activity_name ) ;

    hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>ln_transaction_step_id,
          p_person_id => lv_creator_person_id ,
          p_name => 'P_REVIEW_PROC_CALL' ,
          p_value => p_review_proc_call ) ;

    hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>ln_transaction_step_id,
          p_person_id => lv_creator_person_id ,
          p_name => 'P_REVIEW_ACTID' ,
          p_value => p_act_id ) ;

    p_transaction_id := ln_transaction_id ;
    p_transaction_step_id := ln_transaction_step_id ;


     hr_utility.set_location(' Leaving:' || l_proc,35);

  EXCEPTION
   WHEN OTHERS THEN
     hr_utility.trace(' Exception in HR_LOA_SS.create_transaction:' || SQLERRM );
     hr_utility.set_location(' Leaving:' || l_proc,555);

     raise ;
  END create_transaction ;

/*
  ||===========================================================================
  || PROCEDURE: write_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will write transaction data into transaction table
  ||                hr_api_transaction_vlues
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE write_transaction (
  p_transaction_step_id  in NUMBER
  ,p_validate           in NUMBER default 0
  ,p_effective_date     in Date
  ,p_person_id          in NUMBER default NULL
  ,p_business_group_id  in NUMBER default NULL
  ,p_absence_attendance_type_id    in NUMBER default NULL
  ,p_abs_attendance_reason_id      in NUMBER default NULL
  ,p_comments           in long
  ,p_date_notification  in Date
  ,p_projected_start_date in Date
  ,p_projected_start_time in varchar2
  ,p_projected_end_date  in Date
  ,p_projected_end_time in varchar2
  ,p_start_date         in Date
  ,p_start_time         in VARCHAR2
  ,p_end_date           in Date
  ,p_end_time           in VARCHAR2
  ,p_days               in VARCHAR2
  ,p_hours              in VARCHAR2
  ,p_authorising_id     in NUMBER default NULL
  ,p_replacement_id     in NUMBER default NULL
  ,p_attribute_category in varchar2 default null
  ,p_attribute1         in varchar2 default null
  ,p_attribute2         in varchar2 default null
  ,p_attribute3         in varchar2 default null
  ,p_attribute4         in varchar2 default null
  ,p_attribute5         in varchar2 default null
  ,p_attribute6         in varchar2 default null
  ,p_attribute7         in varchar2 default null
  ,p_attribute8         in varchar2 default null
  ,p_attribute9         in varchar2 default null
  ,p_attribute10        in varchar2 default null
  ,p_attribute11        in varchar2 default null
  ,p_attribute12        in varchar2 default null
  ,p_attribute13        in varchar2 default null
  ,p_attribute14        in varchar2 default null
  ,p_attribute15        in varchar2 default null
  ,p_attribute16        in varchar2 default null
  ,p_attribute17        in varchar2 default null
  ,p_attribute18        in varchar2 default null
  ,p_attribute19        in varchar2 default null
  ,p_attribute20        in varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null

) IS

  l_proc                 varchar2(72) := g_package||'write_transaction';
  lv_creator_person_id per_all_people_f.person_id%TYPE;

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);

    hr_util_misc_web.validate_session(p_person_id => lv_creator_person_id);


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_validate' ,
        p_value =>p_validate ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_effective_date' ,
        p_value =>p_effective_date ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_person_id' ,
        p_value =>p_person_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_business_group_id' ,
        p_value =>p_business_group_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_absence_attendance_type_id' ,
        p_value =>p_absence_attendance_type_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_attendance_reason_id' ,
        p_value =>p_abs_attendance_reason_id ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_comments' ,
        p_value =>p_comments ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_id ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_date_projected_start' ,
        p_value =>p_projected_start_date) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_time_projected_start' ,
        p_value =>p_projected_start_time ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_date_projected_end' ,
        p_value =>p_projected_end_date) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_time_projected_end' ,
        p_value =>p_projected_end_time ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_id ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_date_start' ,
        p_value =>p_start_date) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_time_start' ,
        p_value =>p_start_time ) ;


      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_date_end' ,
        p_value =>p_end_date) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_time_end' ,
        p_value =>p_end_time ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_absence_days' ,
        p_value =>p_days ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_absence_hours' ,
        p_value =>p_hours ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_date_notification' ,
        p_value =>p_date_notification ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_authorising_person_id' ,
        p_value =>p_authorising_id ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute_category' ,
        p_value =>p_attribute_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute1' ,
        p_value =>p_attribute1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute2' ,
        p_value =>p_attribute2 ) ;


     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute3' ,
        p_value =>p_attribute3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute4' ,
        p_value =>p_attribute4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute5' ,
        p_value =>p_attribute5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute6' ,
        p_value =>p_attribute6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute7' ,
        p_value =>p_attribute7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute8' ,
        p_value =>p_attribute8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute9' ,
        p_value =>p_attribute9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute10' ,
        p_value =>p_attribute10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute11' ,
        p_value =>p_attribute11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute12' ,
        p_value =>p_attribute12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute13' ,
        p_value =>p_attribute13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute14' ,
        p_value =>p_attribute14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute15' ,
        p_value =>p_attribute15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute16' ,
        p_value =>p_attribute16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute17' ,
        p_value =>p_attribute17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute18' ,
        p_value =>p_attribute18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute19' ,
        p_value =>p_attribute19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_attribute20' ,
        p_value =>p_attribute20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information_category' ,
        p_value =>p_abs_information_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information1' ,
        p_value =>p_abs_information1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information2' ,
        p_value =>p_abs_information2 ) ;


     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information3' ,
        p_value =>p_abs_information3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information4' ,
        p_value =>p_abs_information4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information5' ,
        p_value =>p_abs_information5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information6' ,
        p_value =>p_abs_information6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information7' ,
        p_value =>p_abs_information7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information8' ,
        p_value =>p_abs_information8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information9' ,
        p_value =>p_abs_information9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information10' ,
        p_value =>p_abs_information10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information11' ,
        p_value =>p_abs_information11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information12' ,
        p_value =>p_abs_information12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information13' ,
        p_value =>p_abs_information13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information14' ,
        p_value =>p_abs_information14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information15' ,
        p_value =>p_abs_information15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information16' ,
        p_value =>p_abs_information16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information17' ,
        p_value =>p_abs_information17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information18' ,
        p_value =>p_abs_information18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information19' ,
        p_value =>p_abs_information19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information20' ,
        p_value =>p_abs_information20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information21' ,
        p_value =>p_abs_information21 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information22' ,
        p_value =>p_abs_information22 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information23' ,
        p_value =>p_abs_information23 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information24' ,
        p_value =>p_abs_information24 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information25' ,
        p_value =>p_abs_information25 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information26' ,
        p_value =>p_abs_information26 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information27' ,
        p_value =>p_abs_information27 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information28' ,
        p_value =>p_abs_information28 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information29' ,
        p_value =>p_abs_information29 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_abs_information30' ,
        p_value =>p_abs_information30 ) ;

hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
   hr_utility.trace(' HR_LOA_SS.write_transaction:' || SQLERRM );
   hr_utility.set_location(' Leaving:' || l_proc,555);

    raise ;

  END write_transaction ;

/*
  ||===========================================================================
  || PROCEDURE: get_absence_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Reads Absence Transaction from transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction id keys
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Reads from transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
  procedure get_absence_transaction
  (p_transaction_step_id   		IN VARCHAR2,
   p_effective_date        	 OUT NOCOPY VARCHAR2,
   p_person_id             	 OUT NOCOPY VARCHAR2,
   p_absence_attendance_type_id	 OUT NOCOPY VARCHAR2,
   p_abs_attendance_reason_id  	 OUT NOCOPY VARCHAR2,
   p_comments              	 OUT NOCOPY VARCHAR2,
   p_date_notification    	        OUT NOCOPY VARCHAR2,
   p_authorising_id       	        OUT NOCOPY VARCHAR2,
   p_replacement_id        	 OUT NOCOPY VARCHAR2,
   p_projected_start_date  	 OUT NOCOPY VARCHAR2,
   p_projected_start_time  	 OUT NOCOPY VARCHAR2,
   p_projected_end_date  	        OUT NOCOPY VARCHAR2,
   p_projected_end_time    	 OUT NOCOPY VARCHAR2,
   p_start_date           	        OUT NOCOPY VARCHAR2,
   p_start_time           	        OUT NOCOPY VARCHAR2,
   p_end_date                           OUT NOCOPY VARCHAR2,
   p_end_time              	 OUT NOCOPY VARCHAR2,
   p_days          		        OUT NOCOPY VARCHAR2,
   p_hours                 	 OUT NOCOPY VARCHAR2,
   p_start_ampm        		        OUT NOCOPY VARCHAR2,
   p_end_ampm           	        OUT NOCOPY VARCHAR2,
   p_attribute_category 	        OUT NOCOPY VARCHAR2,
   p_attribute1            	 OUT NOCOPY VARCHAR2,
   p_attribute2 		        OUT NOCOPY VARCHAR2,
   p_attribute3      		        OUT NOCOPY VARCHAR2,
   p_attribute4   		        OUT NOCOPY VARCHAR2,
   p_attribute5     		        OUT NOCOPY VARCHAR2,
   p_attribute6 		        OUT NOCOPY VARCHAR2,
   p_attribute7    		        OUT NOCOPY VARCHAR2,
   p_attribute8		                OUT NOCOPY VARCHAR2,
   p_attribute9		                OUT NOCOPY VARCHAR2,
   p_attribute10		        OUT NOCOPY VARCHAR2,
   p_attribute11     		        OUT NOCOPY VARCHAR2,
   p_attribute12     		        OUT NOCOPY VARCHAR2,
   p_attribute13     		        OUT NOCOPY VARCHAR2,
   p_attribute14    		        OUT NOCOPY VARCHAR2,
   p_attribute15     		        OUT NOCOPY VARCHAR2,
   p_attribute16     		        OUT NOCOPY VARCHAR2,
   p_attribute17      		        OUT NOCOPY VARCHAR2,
   p_attribute18     		        OUT NOCOPY VARCHAR2,
   p_attribute19      		        OUT NOCOPY VARCHAR2,
   p_attribute20     		        OUT NOCOPY VARCHAR2,
   p_absence_attendance_id	 OUT NOCOPY VARCHAR2,
   p_review_actid      		        OUT NOCOPY VARCHAR2,
   p_review_proc_call     	        OUT NOCOPY VARCHAR2,
   p_abs_information_category           OUT NOCOPY VARCHAR2,
   p_abs_information1                   OUT NOCOPY VARCHAR2,
   p_abs_information2                   OUT NOCOPY VARCHAR2,
   p_abs_information3                   OUT NOCOPY VARCHAR2,
   p_abs_information4                   OUT NOCOPY VARCHAR2,
   p_abs_information5                   OUT NOCOPY VARCHAR2,
   p_abs_information6                   OUT NOCOPY VARCHAR2,
   p_abs_information7                   OUT NOCOPY VARCHAR2,
   p_abs_information8                   OUT NOCOPY VARCHAR2,
   p_abs_information9                   OUT NOCOPY VARCHAR2,
   p_abs_information10                  OUT NOCOPY VARCHAR2,
   p_abs_information11                  OUT NOCOPY VARCHAR2,
   p_abs_information12                  OUT NOCOPY VARCHAR2,
   p_abs_information13                  OUT NOCOPY VARCHAR2,
   p_abs_information14                  OUT NOCOPY VARCHAR2,
   p_abs_information15                  OUT NOCOPY VARCHAR2,
   p_abs_information16                  OUT NOCOPY VARCHAR2,
   p_abs_information17                  OUT NOCOPY VARCHAR2,
   p_abs_information18                  OUT NOCOPY VARCHAR2,
   p_abs_information19                  OUT NOCOPY VARCHAR2,
   p_abs_information20                  OUT NOCOPY VARCHAR2,
   p_abs_information21                  OUT NOCOPY VARCHAR2,
   p_abs_information22                  OUT NOCOPY VARCHAR2,
   p_abs_information23                  OUT NOCOPY VARCHAR2,
   p_abs_information24                  OUT NOCOPY VARCHAR2,
   p_abs_information25                  OUT NOCOPY VARCHAR2,
   p_abs_information26                  OUT NOCOPY VARCHAR2,
   p_abs_information27                  OUT NOCOPY VARCHAR2,
   p_abs_information28                  OUT NOCOPY VARCHAR2,
   p_abs_information29                  OUT NOCOPY VARCHAR2,
   p_abs_information30                  OUT NOCOPY VARCHAR2,
   p_leave_status                       OUT NOCOPY VARCHAR2,
   p_save_mode                          OUT NOCOPY VARCHAR2,
   p_activity_name                      OUT NOCOPY VARCHAR2,
   p_business_group_id                  OUT NOCOPY VARCHAR2,
   p_object_version_number    		OUT NOCOPY VARCHAR2  --2793220
 ) IS

  --
  l_proc              varchar2(72) := g_package||'get_absence_transaction';
  --

BEGIN
  --
    hr_utility.set_location(' Entering:' || l_proc,5);

    p_effective_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_effective_date')
      ,g_date_format);
  --
    p_person_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_person_id');
  --
    p_absence_attendance_type_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_absence_attendance_type_id');
  --
    p_abs_attendance_reason_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_abs_attendance_reason_id');
  --
    p_comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_comments');
  --
    p_date_notification:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_notification')
      ,g_date_format);
  --
    p_authorising_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_authorising_person_id');
  --
    p_replacement_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_replacement_person_id');
  --
    p_projected_start_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_start')
      ,g_date_format);
  --
    p_projected_start_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_start');
  --
    p_projected_end_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_end')
      ,g_date_format);
  --
    p_projected_end_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_end');
  --
    p_start_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_start')
      ,g_date_format);
  --
    p_start_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_start');
  --
    p_end_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_end')
      ,g_date_format);
  --
    p_end_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_end');
  --
    p_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_start_ampm:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_start_ampm');
  --
    p_end_ampm:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_end_ampm');
  --
    p_attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_attribute1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --
    p_attribute2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_attribute3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_attribute4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_attribute5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_attribute6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_attribute7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_attribute8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_attribute9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_attribute10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_attribute11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_attribute12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_attribute13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_attribute14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_attribute15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_attribute16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_attribute17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_attribute18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_attribute19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_attribute20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_absence_attendance_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_attendance_id');
  --
    p_review_proc_call:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_proc_call');
  --
    p_review_actid:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_actid');

  --
    p_abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_abs_information1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --
    p_abs_information2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_abs_information3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_abs_information4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_abs_information5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_abs_information6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_abs_information7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_abs_information8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_abs_information9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_abs_information10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_abs_information11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_abs_information12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_abs_information13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_abs_information14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_abs_information15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_abs_information16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_abs_information17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_abs_information18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_abs_information19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_abs_information20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_abs_information21:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_abs_information22:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_abs_information23:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_abs_information24:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_abs_information25:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_abs_information26:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_abs_information27:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');
  --
    p_abs_information28:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_abs_information29:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_abs_information30:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --
    p_leave_status:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_leave_status');
  --
    p_save_mode:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_save_mode');
  --
    p_activity_name:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_activity_name');
  --
    p_business_group_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_business_group_id');
  --
    --2793220 changes start
    p_object_version_number :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_object_version_number');
    --2793220 changes end

    hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' Exception in get_absence_transaction ' || SQLERRM );
  hr_utility.set_location(' Leaving:' || l_proc,555);

    RAISE;  -- Raise error here relevant to the new tech stack.
END get_absence_transaction;

 /*
 ||===========================================================================
 || PROCEDURE: get_return_transaction
 ||---------------------------------------------------------------------------
 ||
 || Description:
 ||     This procedure will retrieve confirm return information from
 ||     trensaction table
 ||
 || Access Status:
 ||     Public.
 ||
 ||===========================================================================
 */
 procedure get_return_transaction
  (p_transaction_step_id   IN  VARCHAR2
  ,p_effective_date        OUT NOCOPY VARCHAR2
  ,p_start_date            OUT NOCOPY VARCHAR2
  ,p_start_time            OUT NOCOPY VARCHAR2
  ,p_end_date              OUT NOCOPY VARCHAR2
  ,p_end_time              OUT NOCOPY VARCHAR2
  ,p_days                  OUT NOCOPY VARCHAR2
  ,p_hours                 OUT NOCOPY VARCHAR2
  ,p_review_actid          OUT NOCOPY VARCHAR2
  ,p_review_proc_call      OUT NOCOPY VARCHAR2
  ,p_attribute_category                 OUT NOCOPY VARCHAR2
  ,p_attribute1                         OUT NOCOPY VARCHAR2
  ,p_attribute2                         OUT NOCOPY VARCHAR2
  ,p_attribute3                         OUT NOCOPY VARCHAR2
  ,p_attribute4                         OUT NOCOPY VARCHAR2
  ,p_attribute5                         OUT NOCOPY VARCHAR2
  ,p_attribute6                         OUT NOCOPY VARCHAR2
  ,p_attribute7                         OUT NOCOPY VARCHAR2
  ,p_attribute8                         OUT NOCOPY VARCHAR2
  ,p_attribute9                         OUT NOCOPY VARCHAR2
  ,p_attribute10                        OUT NOCOPY VARCHAR2
  ,p_attribute11                        OUT NOCOPY VARCHAR2
  ,p_attribute12                        OUT NOCOPY VARCHAR2
  ,p_attribute13                        OUT NOCOPY VARCHAR2
  ,p_attribute14                        OUT NOCOPY VARCHAR2
  ,p_attribute15                        OUT NOCOPY VARCHAR2
  ,p_attribute16                        OUT NOCOPY VARCHAR2
  ,p_attribute17                        OUT NOCOPY VARCHAR2
  ,p_attribute18                        OUT NOCOPY VARCHAR2
  ,p_attribute19                        OUT NOCOPY VARCHAR2
  ,p_attribute20                        OUT NOCOPY VARCHAR2
  ,p_abs_information_category           OUT NOCOPY VARCHAR2
  ,p_abs_information1                   OUT NOCOPY VARCHAR2
  ,p_abs_information2                   OUT NOCOPY VARCHAR2
  ,p_abs_information3                   OUT NOCOPY VARCHAR2
  ,p_abs_information4                   OUT NOCOPY VARCHAR2
  ,p_abs_information5                   OUT NOCOPY VARCHAR2
  ,p_abs_information6                   OUT NOCOPY VARCHAR2
  ,p_abs_information7                   OUT NOCOPY VARCHAR2
  ,p_abs_information8                   OUT NOCOPY VARCHAR2
  ,p_abs_information9                   OUT NOCOPY VARCHAR2
  ,p_abs_information10                  OUT NOCOPY VARCHAR2
  ,p_abs_information11                  OUT NOCOPY VARCHAR2
  ,p_abs_information12                  OUT NOCOPY VARCHAR2
  ,p_abs_information13                  OUT NOCOPY VARCHAR2
  ,p_abs_information14                  OUT NOCOPY VARCHAR2
  ,p_abs_information15                  OUT NOCOPY VARCHAR2
  ,p_abs_information16                  OUT NOCOPY VARCHAR2
  ,p_abs_information17                  OUT NOCOPY VARCHAR2
  ,p_abs_information18                  OUT NOCOPY VARCHAR2
  ,p_abs_information19                  OUT NOCOPY VARCHAR2
  ,p_abs_information20                  OUT NOCOPY VARCHAR2
  ,p_abs_information21                  OUT NOCOPY VARCHAR2
  ,p_abs_information22                  OUT NOCOPY VARCHAR2
  ,p_abs_information23                  OUT NOCOPY VARCHAR2
  ,p_abs_information24                  OUT NOCOPY VARCHAR2
  ,p_abs_information25                  OUT NOCOPY VARCHAR2
  ,p_abs_information26                  OUT NOCOPY VARCHAR2
  ,p_abs_information27                  OUT NOCOPY VARCHAR2
  ,p_abs_information28                  OUT NOCOPY VARCHAR2
  ,p_abs_information29                  OUT NOCOPY VARCHAR2
  ,p_abs_information30                  OUT NOCOPY VARCHAR2
 ) IS

  --
  l_proc              varchar2(72) := g_package||'get_return_transaction';
  --
  --

 BEGIN
  --
   hr_utility.set_location(' Entering:' || l_proc,5);

    p_effective_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_effective_date')
      ,g_date_format);
  --
    p_start_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_start')
      ,g_date_format);
  --
    p_start_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_start');
  --
    p_end_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_end')
      ,g_date_format);
  --
    p_end_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_end');
  --
    p_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_review_proc_call:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_proc_call');
  --
    p_review_actid:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_actid');

  --
    p_attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_attribute1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --
    p_attribute2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_attribute3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_attribute4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_attribute5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_attribute6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_attribute7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_attribute8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_attribute9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_attribute10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_attribute11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_attribute12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_attribute13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_attribute14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_attribute15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_attribute16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_attribute17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_attribute18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_attribute19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_attribute20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_abs_information1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --
    p_abs_information2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_abs_information3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_abs_information4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_abs_information5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_abs_information6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_abs_information7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_abs_information8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_abs_information9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_abs_information10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_abs_information11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_abs_information12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_abs_information13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_abs_information14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_abs_information15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_abs_information16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_abs_information17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_abs_information18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_abs_information19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_abs_information20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_abs_information21:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_abs_information22:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_abs_information23:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_abs_information24:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_abs_information25:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_abs_information26:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_abs_information27:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');
  --
    p_abs_information28:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_abs_information29:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_abs_information30:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --

hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' Exception in get_return_transaction :' || SQLERRM );
  hr_utility.set_location(' Leaving:' || l_proc,555);

    RAISE;  -- Raise error here relevant to the new tech stack.
END get_return_transaction;

 /*
 ||===========================================================================
 || PROCEDURE: get_update_transaction
 ||---------------------------------------------------------------------------
 ||
 || Description:
 ||     This procedure will retrieve confirm return information from
 ||     trensaction table
 ||
 || Access Status:
 ||     Public.
 ||
 ||===========================================================================
 */
 procedure get_update_transaction
  (p_transaction_step_id   IN  VARCHAR2
  ,p_effective_date        OUT NOCOPY VARCHAR2
  ,p_projected_start_date  OUT NOCOPY VARCHAR2
  ,p_projected_start_time  OUT NOCOPY VARCHAR2
  ,p_projected_end_date    OUT NOCOPY VARCHAR2
  ,p_projected_end_time    OUT NOCOPY VARCHAR2
  ,p_days                  OUT NOCOPY VARCHAR2
  ,p_hours                 OUT NOCOPY VARCHAR2
  ,p_review_actid          OUT NOCOPY VARCHAR2
  ,p_review_proc_call      OUT NOCOPY VARCHAR2
  ,p_attribute_category                 OUT NOCOPY VARCHAR2
  ,p_attribute1                         OUT NOCOPY VARCHAR2
  ,p_attribute2                         OUT NOCOPY VARCHAR2
  ,p_attribute3                         OUT NOCOPY VARCHAR2
  ,p_attribute4                         OUT NOCOPY VARCHAR2
  ,p_attribute5                         OUT NOCOPY VARCHAR2
  ,p_attribute6                         OUT NOCOPY VARCHAR2
  ,p_attribute7                         OUT NOCOPY VARCHAR2
  ,p_attribute8                         OUT NOCOPY VARCHAR2
  ,p_attribute9                         OUT NOCOPY VARCHAR2
  ,p_attribute10                        OUT NOCOPY VARCHAR2
  ,p_attribute11                        OUT NOCOPY VARCHAR2
  ,p_attribute12                        OUT NOCOPY VARCHAR2
  ,p_attribute13                        OUT NOCOPY VARCHAR2
  ,p_attribute14                        OUT NOCOPY VARCHAR2
  ,p_attribute15                        OUT NOCOPY VARCHAR2
  ,p_attribute16                        OUT NOCOPY VARCHAR2
  ,p_attribute17                        OUT NOCOPY VARCHAR2
  ,p_attribute18                        OUT NOCOPY VARCHAR2
  ,p_attribute19                        OUT NOCOPY VARCHAR2
  ,p_attribute20                        OUT NOCOPY VARCHAR2
  ,p_abs_information_category           OUT NOCOPY VARCHAR2
  ,p_abs_information1                   OUT NOCOPY VARCHAR2
  ,p_abs_information2                   OUT NOCOPY VARCHAR2
  ,p_abs_information3                   OUT NOCOPY VARCHAR2
  ,p_abs_information4                   OUT NOCOPY VARCHAR2
  ,p_abs_information5                   OUT NOCOPY VARCHAR2
  ,p_abs_information6                   OUT NOCOPY VARCHAR2
  ,p_abs_information7                   OUT NOCOPY VARCHAR2
  ,p_abs_information8                   OUT NOCOPY VARCHAR2
  ,p_abs_information9                   OUT NOCOPY VARCHAR2
  ,p_abs_information10                  OUT NOCOPY VARCHAR2
  ,p_abs_information11                  OUT NOCOPY VARCHAR2
  ,p_abs_information12                  OUT NOCOPY VARCHAR2
  ,p_abs_information13                  OUT NOCOPY VARCHAR2
  ,p_abs_information14                  OUT NOCOPY VARCHAR2
  ,p_abs_information15                  OUT NOCOPY VARCHAR2
  ,p_abs_information16                  OUT NOCOPY VARCHAR2
  ,p_abs_information17                  OUT NOCOPY VARCHAR2
  ,p_abs_information18                  OUT NOCOPY VARCHAR2
  ,p_abs_information19                  OUT NOCOPY VARCHAR2
  ,p_abs_information20                  OUT NOCOPY VARCHAR2
  ,p_abs_information21                  OUT NOCOPY VARCHAR2
  ,p_abs_information22                  OUT NOCOPY VARCHAR2
  ,p_abs_information23                  OUT NOCOPY VARCHAR2
  ,p_abs_information24                  OUT NOCOPY VARCHAR2
  ,p_abs_information25                  OUT NOCOPY VARCHAR2
  ,p_abs_information26                  OUT NOCOPY VARCHAR2
  ,p_abs_information27                  OUT NOCOPY VARCHAR2
  ,p_abs_information28                  OUT NOCOPY VARCHAR2
  ,p_abs_information29                  OUT NOCOPY VARCHAR2
  ,p_abs_information30                  OUT NOCOPY VARCHAR2
  ,p_comments                           OUT NOCOPY VARCHAR2
) IS

  --
  l_proc              varchar2(72) := g_package||'get_update_transaction';
  --
  --

 BEGIN
  --
    hr_utility.set_location(' Entering:' || l_proc,5);

    p_effective_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_effective_date')
      ,g_date_format);
  --
    p_projected_start_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_start')
      ,g_date_format);
  --
    p_projected_start_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_start');
  --
    p_projected_end_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_end')
      ,g_date_format);
  --
    p_projected_end_time:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_end');
  --
    p_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_review_proc_call:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_proc_call');
  --
    p_review_actid:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_review_actid');
  --
    p_attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_attribute1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --
    p_attribute2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_attribute3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_attribute4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_attribute5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_attribute6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_attribute7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_attribute8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_attribute9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_attribute10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_attribute11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_attribute12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_attribute13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_attribute14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_attribute15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_attribute16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_attribute17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_attribute18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_attribute19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_attribute20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_abs_information1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --
    p_abs_information2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_abs_information3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_abs_information4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_abs_information5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_abs_information6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_abs_information7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_abs_information8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_abs_information9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_abs_information10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_abs_information11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_abs_information12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_abs_information13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_abs_information14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_abs_information15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_abs_information16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_abs_information17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_abs_information18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_abs_information19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_abs_information20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_abs_information21:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_abs_information22:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_abs_information23:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_abs_information24:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_abs_information25:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_abs_information26:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_abs_information27:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');
  --
    p_abs_information28:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_abs_information29:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_abs_information30:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --
    p_comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_comments');
  --

hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace(' HR_LOA_SS.get_update_transaction ' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,555);

    RAISE;  -- Raise error here relevant to the new tech stack.
END get_update_transaction;
  /*
  ||===========================================================================
  || PROCEDURE: validate_api
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure validate_api(
   p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     date     default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
--  ,p_authorising_person_id         in     number   default null
--  ,p_replacement_person_id         in     number   default null
  ,p_authorising_person_id         in     varchar2 default null
 ,p_replacement_person_id         in     varchar2 default null
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
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ) IS

   l_proc               varchar2(72) := g_package||'validate_api';
   l_validate           boolean;
   l_authorising_person_id          number;
   l_replacement_person_id          number;
   lb_abs_day_after_warning     BOOLEAN;
   lb_abs_overlap_warning       BOOLEAN;
   lb_dur_dys_less_warning      BOOLEAN;
   lb_dur_hrs_less_warning      BOOLEAN;
   lb_exceeds_pto_entit_warning BOOLEAN;
   lb_exceeds_run_total_warning BOOLEAN;
   lb_dur_overwritten_warning   BOOLEAN;


BEGIN
--
--
--
    hr_utility.set_location(' Entering:' || l_proc,5);

    l_validate := TRUE;
    l_authorising_person_id  := to_number(p_authorising_person_id);
    l_replacement_person_id  := to_number(p_replacement_person_id);
    hr_person_absence_api.create_person_absence(
       p_validate                      => l_validate
      ,p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => p_absence_days
      ,p_absence_hours                 => p_absence_hours
      ,p_authorising_person_id         => l_authorising_person_id
      ,p_replacement_person_id         => l_replacement_person_id
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
      ,p_period_of_incapacity_id       => null
      ,p_ssp1_issued                   => 'N'
      ,p_maternity_id                  => null
      ,p_sickness_start_date           => null
      ,p_sickness_end_date             => null
      ,p_pregnancy_related_illness     => 'N'
      ,p_reason_for_notification_dela  => null
      ,p_accept_late_notification_fla  => 'N'
      ,p_linked_absence_id             => null
      ,p_abs_information_category            => p_abs_information_category
      ,p_abs_information1                    => p_abs_information1
      ,p_abs_information2                    => p_abs_information2
      ,p_abs_information3                    => p_abs_information3
      ,p_abs_information4                    => p_abs_information4
      ,p_abs_information5                    => p_abs_information5
      ,p_abs_information6                    => p_abs_information6
      ,p_abs_information7                    => p_abs_information7
      ,p_abs_information8                    => p_abs_information8
      ,p_abs_information9                    => p_abs_information9
      ,p_abs_information10                   => p_abs_information10
      ,p_abs_information11                   => p_abs_information11
      ,p_abs_information12                   => p_abs_information12
      ,p_abs_information13                   => p_abs_information13
      ,p_abs_information14                   => p_abs_information14
      ,p_abs_information15                   => p_abs_information15
      ,p_abs_information16                   => p_abs_information16
      ,p_abs_information17                   => p_abs_information17
      ,p_abs_information18                   => p_abs_information18
      ,p_abs_information19                   => p_abs_information19
      ,p_abs_information20                   => p_abs_information20
      ,p_abs_information21                   => p_abs_information21
      ,p_abs_information22                   => p_abs_information22
      ,p_abs_information23                   => p_abs_information23
      ,p_abs_information24                   => p_abs_information24
      ,p_abs_information25                   => p_abs_information25
      ,p_abs_information26                   => p_abs_information26
      ,p_abs_information27                   => p_abs_information27
      ,p_abs_information28                   => p_abs_information28
      ,p_abs_information29                   => p_abs_information29
      ,p_abs_information30                   => p_abs_information30
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_occurrence                    => p_occurrence
      ,p_dur_dys_less_warning          => lb_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => lb_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => lb_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => lb_exceeds_run_total_warning
      ,p_abs_overlap_warning           => lb_abs_overlap_warning
      ,p_abs_day_after_warning         => lb_abs_day_after_warning
      ,p_dur_overwritten_warning       => lb_dur_overwritten_warning
     );

     p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
     p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
     p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
     p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
     p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
     p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
     p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

hr_utility.set_location(' Leaving:' || l_proc,10);

    EXCEPTION
    WHEN g_data_error THEN
      hr_utility.trace('Exception in g_data_error in  HR_LOA_SS..validate_api ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,555);

      raise;

    WHEN OTHERS THEN
      hr_utility.trace('When others exception in  HR_LOA_SS..validate_api ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,560);
      raise ;

  END validate_api;

  /*
  ||===========================================================================
  || PROCEDURE: process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_save(
   p_item_type                     in     WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key  	                   in     WF_ITEMS.ITEM_KEY%TYPE
  ,p_act_id    	                   in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date default null
  ,p_date_projected_start          in     date default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
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
  ,p_start_ampm                    in     varchar2 default null
  ,p_end_ampm                      in     varchar2 default null
  ,p_save_mode                     in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_return_on_warning             in     varchar2 default null --2713296
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_transaction_step_id           out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) IS

   l_proc                     varchar2(72) := g_package||'process_save';
   l_creator_person_id        per_all_people_f.person_id%TYPE;
   l_validate                 boolean;
   l_transaction_id	      number;
   l_absence_days             number;
   l_absence_hours            number;
   l_transaction_step_id      number;
   l_abs_attendance_reason_id number;
   l_login_person_id 	      number;
   l_authorising_person_id    number;
   l_replacement_person_id    number;
   lb_abs_day_after_warning    BOOLEAN;
   lb_abs_overlap_warning      BOOLEAN;
   lb_dur_dys_less_warning      BOOLEAN;
   lb_dur_hrs_less_warning      BOOLEAN;
   lb_exceeds_pto_entit_warning BOOLEAN;
   lb_exceeds_run_total_warning BOOLEAN;
   lb_dur_overwritten_warning   BOOLEAN;

   --2966372 changes start
   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := null;
   l_sickness_end_date date := null;
   --2966372 changes end


BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 --  Call API with validate mode
 --

    l_validate := TRUE;
    l_authorising_person_id  := to_number(p_authorising_person_id);
    l_replacement_person_id  := to_number(p_replacement_person_id);

    if p_abs_attendance_reason_id = -1 then
      l_abs_attendance_reason_id := null;
    else
      l_abs_attendance_reason_id := p_abs_attendance_reason_id;
    end if;
    if p_absence_days = -1 then
      l_absence_days := null;
  --    p_absence_days := null; -- #2491612
    else
      l_absence_days := p_absence_days;
    end if;
    if p_absence_hours = -1 then
      l_absence_hours := null;
   --   p_absence_hours := null;
    else
      l_absence_hours := p_absence_hours;
    end if;

    --2966372 changes start
    l_populate_sickness_dates := is_gb_leg_and_category_s(p_absence_attendance_type_id , p_business_group_id);

    IF l_populate_sickness_dates THEN
       l_sickness_start_date := p_date_start;
       l_sickness_end_date := p_date_end;
    END IF;
    --2966372 changes end

    --
    -- Support Save For Later
    --
    if p_save_mode <> 'SaveForLater' then

      hr_utility.set_location(l_proc, 20);

      hr_person_absence_api.create_person_absence(
       p_validate                      => l_validate
      ,p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => l_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => l_authorising_person_id
      ,p_replacement_person_id         => l_replacement_person_id
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
      ,p_period_of_incapacity_id       => null
      ,p_ssp1_issued                   => 'N'
      ,p_maternity_id                  => null
      ,p_sickness_start_date           => l_sickness_start_date --2966372
      ,p_sickness_end_date             => l_sickness_end_date --2966372
      ,p_pregnancy_related_illness     => 'N'
      ,p_reason_for_notification_dela  => null
      ,p_accept_late_notification_fla  => 'N'
      ,p_linked_absence_id             => null
      ,p_abs_information_category            => p_abs_information_category
      ,p_abs_information1                    => p_abs_information1
      ,p_abs_information2                    => p_abs_information2
      ,p_abs_information3                    => p_abs_information3
      ,p_abs_information4                    => p_abs_information4
      ,p_abs_information5                    => p_abs_information5
      ,p_abs_information6                    => p_abs_information6
      ,p_abs_information7                    => p_abs_information7
      ,p_abs_information8                    => p_abs_information8
      ,p_abs_information9                    => p_abs_information9
      ,p_abs_information10                   => p_abs_information10
      ,p_abs_information11                   => p_abs_information11
      ,p_abs_information12                   => p_abs_information12
      ,p_abs_information13                   => p_abs_information13
      ,p_abs_information14                   => p_abs_information14
      ,p_abs_information15                   => p_abs_information15
      ,p_abs_information16                   => p_abs_information16
      ,p_abs_information17                   => p_abs_information17
      ,p_abs_information18                   => p_abs_information18
      ,p_abs_information19                   => p_abs_information19
      ,p_abs_information20                   => p_abs_information20
      ,p_abs_information21                   => p_abs_information21
      ,p_abs_information22                   => p_abs_information22
      ,p_abs_information23                   => p_abs_information23
      ,p_abs_information24                   => p_abs_information24
      ,p_abs_information25                   => p_abs_information25
      ,p_abs_information26                   => p_abs_information26
      ,p_abs_information27                   => p_abs_information27
      ,p_abs_information28                   => p_abs_information28
      ,p_abs_information29                   => p_abs_information29
      ,p_abs_information30                   => p_abs_information30
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_occurrence                    => p_occurrence
      ,p_dur_dys_less_warning          => lb_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => lb_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => lb_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => lb_exceeds_run_total_warning
      ,p_abs_overlap_warning           => lb_abs_overlap_warning
      ,p_abs_day_after_warning         => lb_abs_day_after_warning
      ,p_dur_overwritten_warning       => lb_dur_overwritten_warning
   );

   p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
   p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
   p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
   p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
   p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
   p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
   p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

   -- 2713296 changes start
   if (lb_abs_day_after_warning OR
       lb_abs_overlap_warning   OR
       lb_exceeds_pto_entit_warning OR   --2848345
       lb_dur_dys_less_warning  OR       --2765646
       lb_dur_hrs_less_warning  OR       --2765646
       lb_exceeds_run_total_warning) AND --2797220
       p_return_on_warning = 'true' then
     hr_utility.set_location(l_proc, 40);
     return;
   else -- BUG 2415512
      lb_abs_overlap_warning := chk_overlap(p_person_id,p_business_group_id,p_date_start,p_date_end,p_time_start,p_time_end);

      if lb_abs_overlap_warning AND p_return_on_warning = 'true' then
        hr_utility.set_location(l_proc, 50);
        p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
        return;
      end if;
   end if;
   -- 2713296 changes ends
   end if; -- Support Save For Later

   hr_utility.set_location(l_proc, 60);
 --
 --  Create transaction
 --
    create_transaction(
      p_item_type           => p_item_type
     ,p_item_key            => p_item_key
     ,p_act_id              => p_act_id
     ,p_activity_name       => p_review_proc_call
     ,p_transaction_id      => l_transaction_id
     ,p_transaction_step_id => l_transaction_step_id
     ,p_login_person_id     => p_login_person_id
     ,p_review_proc_call    => p_review_proc_call
    );

    p_transaction_step_id := l_transaction_step_id;

    p_absence_days := l_absence_days;
    p_absence_hours := l_absence_hours;

 --
 -- Write Transaction
 --

    l_validate := FALSE;
--    hr_util_misc_web.validate_session(p_person_id => l_creator_person_id);
    l_creator_person_id := p_login_person_id;


      hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_validate' ,
        p_value =>l_validate ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_effective_date' ,
        p_value =>p_effective_date ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_person_id' ,
        p_value =>p_person_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_business_group_id' ,
        p_value =>p_business_group_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_attendance_type_id' ,
        p_value =>p_absence_attendance_type_id ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_attendance_reason_id' ,
        p_value =>l_abs_attendance_reason_id ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_comments' ,
        p_value =>p_comments ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_authorising_person_id' ,
        p_value =>p_authorising_person_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_person_id ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_projected_start' ,
        p_value =>p_date_projected_start) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_projected_start' ,
        p_value =>p_time_projected_start ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_projected_end' ,
        p_value =>p_date_projected_end) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_projected_end' ,
        p_value =>p_time_projected_end ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_start' ,
        p_value =>p_date_start) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_start' ,
        p_value =>p_time_start ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_end' ,
        p_value =>p_date_end) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_end' ,
        p_value =>p_time_end ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_days' ,
        p_value =>p_absence_days ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_hours' ,
        p_value =>p_absence_hours ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_notification' ,
        p_value =>p_date_notification ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute_category' ,
        p_value =>p_attribute_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute1' ,
        p_value =>p_attribute1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute2' ,
        p_value =>p_attribute2 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute3' ,
        p_value =>p_attribute3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute4' ,
        p_value =>p_attribute4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute5' ,
        p_value =>p_attribute5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute6' ,
        p_value =>p_attribute6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute7' ,
        p_value =>p_attribute7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute8' ,
        p_value =>p_attribute8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute9' ,
        p_value =>p_attribute9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute10' ,
        p_value =>p_attribute10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute11' ,
        p_value =>p_attribute11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute12' ,
        p_value =>p_attribute12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute13' ,
        p_value =>p_attribute13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute14' ,
        p_value =>p_attribute14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute15' ,
        p_value =>p_attribute15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute16' ,
        p_value =>p_attribute16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute17' ,
        p_value =>p_attribute17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute18' ,
        p_value =>p_attribute18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute19' ,
        p_value =>p_attribute19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute20' ,
        p_value =>p_attribute20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information_category' ,
        p_value =>p_abs_information_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information1' ,
        p_value =>p_abs_information1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information2' ,
        p_value =>p_abs_information2 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information3' ,
        p_value =>p_abs_information3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information4' ,
        p_value =>p_abs_information4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information5' ,
        p_value =>p_abs_information5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information6' ,
        p_value =>p_abs_information6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information7' ,
        p_value =>p_abs_information7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information8' ,
        p_value =>p_abs_information8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information9' ,
        p_value =>p_abs_information9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information10' ,
        p_value =>p_abs_information10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information11' ,
        p_value =>p_abs_information11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information12' ,
        p_value =>p_abs_information12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information13' ,
        p_value =>p_abs_information13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information14' ,
        p_value =>p_abs_information14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information15' ,
        p_value =>p_abs_information15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information16' ,
        p_value =>p_abs_information16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information17' ,
        p_value =>p_abs_information17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information18' ,
        p_value =>p_abs_information18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information19' ,
        p_value =>p_abs_information19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information20' ,
        p_value =>p_abs_information20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information21' ,
        p_value =>p_abs_information21 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information22' ,
        p_value =>p_abs_information22 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information23' ,
        p_value =>p_abs_information23 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information24' ,
        p_value =>p_abs_information24 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information25' ,
        p_value =>p_abs_information25 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information26' ,
        p_value =>p_abs_information26 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information27' ,
        p_value =>p_abs_information27 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information28' ,
        p_value =>p_abs_information28 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information29' ,
        p_value =>p_abs_information29 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information30' ,
        p_value =>p_abs_information30 ) ;

  --
     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_leave_status' ,
        p_value =>p_leave_status ) ;

  --
  -- Save For Later
  --
     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_start_ampm' ,
        p_value =>p_start_ampm ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_end_ampm' ,
        p_value =>p_end_ampm ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_save_mode' ,
        p_value =>p_save_mode ) ;
 --
 --
 --
 hr_utility.set_location('Leaving..:' || l_proc, 70);
    EXCEPTION
      WHEN hr_utility.hr_error then
         hr_message.provide_error;
         p_page_error := hr_message.last_message_app;
         p_page_error_msg := hr_message.get_message_text;
         p_page_error_num := hr_message.last_message_number;
	 hr_utility.set_location('Leaving..:' || l_proc, 555);
      WHEN OTHERS THEN
      hr_utility.trace('Exception  HR_LOA_SS..process_save:: ' || SQLERRM );
      hr_utility.set_location('Leaving..:' || l_proc, 560);
        raise ;

  END process_save;

    --2966372 changes start
  /*
   ||===========================================================================
   || FUNCTION: is_gb_leg_and_category_s
   ||---------------------------------------------------------------------------
   ||
   || Description:
   ||     This function will return true if the absence category is 'Sickness'
   ||     and the legislation is 'GB' , else will return false.
   ||
   || Access Status:
   ||     Public.
   ||
   ||===========================================================================
   */

  function is_gb_leg_and_category_s(p_absence_attendance_type_id IN NUMBER ,
				    p_business_group_id IN NUMBER)
  return boolean is

   l_proc varchar2(200) := g_package || 'is_gb_leg_and_category_s';

   populate_sickness_dates boolean := false;
   l_absence_category per_absence_attendance_types.absence_category%type ;
   l_legislation_code varchar2(150);

   cursor get_category_code (p_absence_attendance_type_id number) is
   select absence_category
   from per_absence_attendance_types
   where absence_attendance_type_id = p_absence_attendance_type_id;

  begin
    hr_utility.set_location(' Entering:' || l_proc,5);

    open get_category_code(p_absence_attendance_type_id);
    fetch get_category_code into l_absence_category ;
    close get_category_code ;

    IF l_absence_category = 'S' THEN
       l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
       IF l_legislation_code = 'GB' THEN
          hr_utility.set_location(l_proc,10);

    	  populate_sickness_dates := true;
       END IF;
    END IF;
    hr_utility.set_location(' Leaving:' || l_proc,15);

    return populate_sickness_dates;
  END is_gb_leg_and_category_s ;
    --2966372 changes end


--kcks

procedure process_update_save(
   p_item_type                     in     WF_ITEMS.ITEM_TYPE%TYPE
  ,p_item_key  	                   in     WF_ITEMS.ITEM_KEY%TYPE
  ,p_act_id    	                   in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_date_notification             in     date
  ,p_absence_attendance_id         in     per_absence_attendances.absence_attendance_id%type
  ,p_object_version_number         in out nocopy number
  ,p_date_start			   in     date     default null
  ,p_time_start     	           in     varchar2 default null
  ,p_date_end			   in     date     default null
  ,p_time_end     	           in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_replacement_person_id         in     number   default null
  ,p_update_return                 in     varchar2
  ,p_save_mode                     in     varchar2
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
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_person_id                     in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_date_projected_start	   in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end		   in     date     default null
  ,p_time_projected_end	           in     varchar2 default null
  ,p_return_on_warning             in     varchar2 default null  --2713296
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_transaction_step_id           out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) IS

   l_proc              varchar2(72)  :=  g_package||'process_update_save';
   l_creator_person_id      per_all_people_f.person_id%TYPE;
   l_absence_rec            per_absence_attendances%rowtype;
   l_validate               boolean ;
   l_transaction_id	    number;
   l_transaction_step_id    number;
   l_login_person_id 	    number;
   l_object_version_number  number;
   lb_abs_day_after_warning BOOLEAN;
   lb_abs_overlap_warning   BOOLEAN;
   lb_dur_dys_less_warning      BOOLEAN;
   lb_dur_hrs_less_warning      BOOLEAN;
   lb_exceeds_pto_entit_warning BOOLEAN;
   lb_exceeds_run_total_warning BOOLEAN;
   lb_dur_overwritten_warning   BOOLEAN;
   lb_del_element_entry_warning BOOLEAN;
   l_absence_days           number;
   l_absence_day_hours      number;
   l_absence_hours          number;
   l_business_group_id      number;

   --2966372 changes start
   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := null;
   l_sickness_end_date date := null;
   --2966372 changes end

   l_leave_data_changed boolean := false ; --2793140

   cursor csr_abs_attendances is
   select *
     from per_absence_attendances paa
     where paa.absence_attendance_id = p_absence_attendance_id ;

BEGIN
 --
 --
 --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   open csr_abs_attendances;
   fetch csr_abs_attendances into l_absence_rec;
   if  csr_abs_attendances%notfound then
     close csr_abs_attendances;
     hr_utility.set_location('api error exists', 10);
     raise g_data_error;
   end if;


    if p_absence_days = -1 then
      l_absence_days := null;
    else
      l_absence_days := p_absence_days;
    end if;
    if p_absence_hours = -1 then
      l_absence_hours := null;
    else
      l_absence_hours := p_absence_hours;
    end if;

    --2793140 changes start
    l_leave_data_changed := is_rec_changed
                   (p_effective_date                => p_effective_date
    ,p_absence_attendance_id           => p_absence_attendance_id
    ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
    ,p_comments                      => p_comments
    ,p_date_notification             => p_date_notification
    ,p_date_projected_start          => p_date_projected_start
    ,p_time_projected_start          => p_time_projected_start
    ,p_date_projected_end            => p_date_projected_end
    ,p_time_projected_end            => p_time_projected_end
    ,p_date_start                    => p_date_start
    ,p_time_start                    => p_time_start
    ,p_date_end                      => p_date_end
    ,p_time_end                      => p_time_end
    ,p_absence_days                  => l_absence_days
    ,p_absence_hours                 => l_absence_hours
    ,p_replacement_person_id         => p_replacement_person_id
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
    ,p_abs_information_category      => p_abs_information_category
    ,p_abs_information1              => p_abs_information1
    ,p_abs_information2              => p_abs_information2
    ,p_abs_information3              => p_abs_information3
    ,p_abs_information4              => p_abs_information4
    ,p_abs_information5              => p_abs_information5
    ,p_abs_information6              => p_abs_information6
    ,p_abs_information7              => p_abs_information7
    ,p_abs_information8              => p_abs_information8
    ,p_abs_information9              => p_abs_information9
    ,p_abs_information10             => p_abs_information10
    ,p_abs_information11             => p_abs_information11
    ,p_abs_information12             => p_abs_information12
    ,p_abs_information13             => p_abs_information13
    ,p_abs_information14             => p_abs_information14
    ,p_abs_information15             => p_abs_information15
    ,p_abs_information16             => p_abs_information16
    ,p_abs_information17             => p_abs_information17
    ,p_abs_information18             => p_abs_information18
    ,p_abs_information19             => p_abs_information19
    ,p_abs_information20             => p_abs_information20
    ,p_abs_information21             => p_abs_information21
    ,p_abs_information22             => p_abs_information22
    ,p_abs_information23             => p_abs_information23
    ,p_abs_information24             => p_abs_information24
    ,p_abs_information25             => p_abs_information25
    ,p_abs_information26             => p_abs_information26
    ,p_abs_information27             => p_abs_information27
    ,p_abs_information28             => p_abs_information28
    ,p_abs_information29             => p_abs_information29
    ,p_abs_information30             => p_abs_information30
    ,p_object_version_number         => p_object_version_number
    );

    if l_leave_data_changed = false then
      hr_utility.set_location(l_proc||' no data changed:returning', 15);
      return;
    end if;

    --2793140 changes end

    l_object_version_number := p_object_version_number; -- WWBUG 2411426
    hr_utility.trace(l_proc || ':p_object_version_number =>'|| to_char(l_object_version_number));

    --2966372 changes start
    l_populate_sickness_dates := is_gb_leg_and_category_s(p_absence_attendance_type_id
					, l_absence_rec.business_group_id);

    IF l_populate_sickness_dates THEN
       l_sickness_start_date := p_date_start;
       l_sickness_end_date := p_date_end;
    END IF;
    --2966372 changes end

 --
 --  Call API with validate mode
 --

    if p_save_mode <> 'SaveForLater' then
      hr_utility.set_location(l_proc, 20);

      l_validate := TRUE;

      if p_leave_status = g_confirm then

      hr_utility.set_location(l_proc, 30);

      hr_person_absence_api.update_person_absence(
       p_validate                   => l_validate
        ,p_effective_date             => p_effective_date
--        ,p_business_group_id          => l_absence_rec.business_group_id
        ,p_absence_attendance_id      => p_absence_attendance_id
        ,p_date_notification          => p_date_notification
        ,p_date_start                 => p_date_start
        ,p_time_start                 => p_time_start
        ,p_date_end                   => p_date_end
        ,p_time_end                   => p_time_end
        ,p_absence_days               => l_absence_days
        ,p_absence_hours              => l_absence_hours
        ,p_replacement_person_id      => p_replacement_person_id
        ,p_object_version_number      => l_object_version_number
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
        ,p_abs_information_category            => p_abs_information_category
        ,p_abs_information1                    => p_abs_information1
        ,p_abs_information2                    => p_abs_information2
        ,p_abs_information3                    => p_abs_information3
        ,p_abs_information4                    => p_abs_information4
        ,p_abs_information5                    => p_abs_information5
        ,p_abs_information6                    => p_abs_information6
        ,p_abs_information7                    => p_abs_information7
        ,p_abs_information8                    => p_abs_information8
        ,p_abs_information9                    => p_abs_information9
        ,p_abs_information10                   => p_abs_information10
        ,p_abs_information11                   => p_abs_information11
        ,p_abs_information12                   => p_abs_information12
        ,p_abs_information13                   => p_abs_information13
        ,p_abs_information14                   => p_abs_information14
        ,p_abs_information15                   => p_abs_information15
        ,p_abs_information16                   => p_abs_information16
        ,p_abs_information17                   => p_abs_information17
        ,p_abs_information18                   => p_abs_information18
        ,p_abs_information19                   => p_abs_information19
        ,p_abs_information20                   => p_abs_information20
        ,p_abs_information21                   => p_abs_information21
        ,p_abs_information22                   => p_abs_information22
        ,p_abs_information23                   => p_abs_information23
        ,p_abs_information24                   => p_abs_information24
        ,p_abs_information25                   => p_abs_information25
        ,p_abs_information26                   => p_abs_information26
        ,p_abs_information27                   => p_abs_information27
        ,p_abs_information28                   => p_abs_information28
        ,p_abs_information29                   => p_abs_information29
        ,p_abs_information30                   => p_abs_information30
	    ,p_sickness_start_date        => l_sickness_start_date --2966372
        ,p_sickness_end_date          => l_sickness_end_date --2966372
        ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
        ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
        ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
        ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
        ,p_abs_overlap_warning        => lb_abs_overlap_warning
        ,p_abs_day_after_warning      => lb_abs_day_after_warning
        ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
        ,p_del_element_entry_warning  => lb_del_element_entry_warning
      );
    else
-- Update absence
      hr_utility.set_location(l_proc, 40);

      hr_person_absence_api.update_person_absence(
        p_validate                   => l_validate
       ,p_effective_date             => p_effective_date
--       ,p_business_group_id          => l_absence_rec.business_group_id
       ,p_absence_attendance_id      => p_absence_attendance_id
       ,p_date_notification          => p_date_notification
       ,p_date_projected_start       => p_date_projected_start   --WWBUG 2413294
       ,p_time_projected_start       => p_time_projected_start   --WWBUG 2413294
       ,p_date_projected_end         => p_date_projected_end     --WWBUG 2413294
       ,p_time_projected_end         => p_time_projected_end     --WWBUG 2413294
       ,p_date_start                 => null
       ,p_time_start                 => null
       ,p_date_end                   => null
       ,p_time_end                   => null
       ,p_absence_days               => l_absence_days
       ,p_absence_hours              => l_absence_hours
       ,p_replacement_person_id      => p_replacement_person_id
       ,p_object_version_number      => l_object_version_number
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
       ,p_abs_information_category            => p_abs_information_category
       ,p_abs_information1                    => p_abs_information1
       ,p_abs_information2                    => p_abs_information2
       ,p_abs_information3                    => p_abs_information3
       ,p_abs_information4                    => p_abs_information4
       ,p_abs_information5                    => p_abs_information5
       ,p_abs_information6                    => p_abs_information6
       ,p_abs_information7                    => p_abs_information7
       ,p_abs_information8                    => p_abs_information8
       ,p_abs_information9                    => p_abs_information9
       ,p_abs_information10                   => p_abs_information10
       ,p_abs_information11                   => p_abs_information11
       ,p_abs_information12                   => p_abs_information12
       ,p_abs_information13                   => p_abs_information13
       ,p_abs_information14                   => p_abs_information14
       ,p_abs_information15                   => p_abs_information15
       ,p_abs_information16                   => p_abs_information16
       ,p_abs_information17                   => p_abs_information17
       ,p_abs_information18                   => p_abs_information18
       ,p_abs_information19                   => p_abs_information19
       ,p_abs_information20                   => p_abs_information20
       ,p_abs_information21                   => p_abs_information21
       ,p_abs_information22                   => p_abs_information22
       ,p_abs_information23                   => p_abs_information23
       ,p_abs_information24                   => p_abs_information24
       ,p_abs_information25                   => p_abs_information25
       ,p_abs_information26                   => p_abs_information26
       ,p_abs_information27                   => p_abs_information27
       ,p_abs_information28                   => p_abs_information28
       ,p_abs_information29                   => p_abs_information29
       ,p_abs_information30                   => p_abs_information30
       ,p_sickness_start_date        => l_sickness_start_date --2966372
       ,p_sickness_end_date          => l_sickness_end_date --2966372
       ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
       ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
       ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
       ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
       ,p_abs_overlap_warning        => lb_abs_overlap_warning
       ,p_abs_day_after_warning      => lb_abs_day_after_warning
       ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
       ,p_del_element_entry_warning     => lb_del_element_entry_warning
     );
   end if;

   p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
   p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);

--   When validate mode is 'TRUE', API always returns null for p_object_version_number
--   p_object_version_number := l_object_version_number; -- WWBUG 2411426

   hr_utility.trace(l_proc || ':p_object_version_number =>'|| to_char(l_object_version_number));

   p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
   p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
   p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
   p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
   p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

   --2713296 change starts
   if (lb_abs_day_after_warning OR
       lb_abs_overlap_warning   OR
       lb_exceeds_pto_entit_warning OR   --2848345
       lb_dur_dys_less_warning  OR       --2765646
       lb_dur_hrs_less_warning  OR       --2765646
       lb_exceeds_run_total_warning) AND --2797220
       p_return_on_warning = 'true' then
     hr_utility.set_location(l_proc, 50);
     return;
   else -- BUG 2415512
      lb_abs_overlap_warning := chk_overlap(p_person_id,l_absence_rec.business_group_id,p_date_start,p_date_end,p_time_start,p_time_end);


      if lb_abs_overlap_warning AND p_return_on_warning = 'true' then
        hr_utility.set_location(l_proc, 55);
        p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
       return;
      end if;
    --2713296 change ends
   end if;
   hr_utility.set_location(l_proc, 60);

   end if; -- Support of Save Of Later

 --
 --  Create transaction
 --
    create_transaction(
      p_item_type           => p_item_type
     ,p_item_key            => p_item_key
     ,p_act_id              => p_act_id
     ,p_activity_name       => p_update_return
     ,p_transaction_id      => l_transaction_id
     ,p_transaction_step_id => l_transaction_step_id
     ,p_login_person_id     => p_login_person_id
     ,p_review_proc_call    => p_review_proc_call
    );

    p_transaction_step_id := l_transaction_step_id;
    hr_utility.set_location(l_proc, 70);
    hr_utility.trace(l_proc || ':transaction_step_id =>'|| to_char(l_transaction_step_id));

 --
 -- Write Transaction
 --

   l_creator_person_id := p_login_person_id;

   l_validate := FALSE;

   hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_validate' ,
        p_value =>l_validate ) ;

   hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_effective_date' ,
        p_value =>p_effective_date ) ;

   hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_notification' ,
        p_value =>p_date_notification) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_business_group_id' ,
        p_value =>l_absence_rec.business_group_id ) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_object_version_number' ,
        p_value => p_object_version_number ) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_attendance_id' ,
        p_value =>p_absence_attendance_id ) ;

   --if p_leave_status = g_confirm then
     hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_start' ,
          p_value =>p_date_start) ;

    hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_start' ,
          p_value =>p_time_start ) ;

    hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_end' ,
          p_value =>p_date_end) ;

    hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_end' ,
          p_value =>p_time_end ) ;

  --end if;

  hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_projected_start' ,
          p_value =>p_date_projected_start) ;

  hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_projected_start' ,
          p_value =>p_time_projected_start ) ;

  hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_projected_end' ,
          p_value =>p_date_projected_end) ;

  hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_projected_end' ,
          p_value =>p_time_projected_end ) ;



  hr_utility.set_location(l_proc, 90);

  hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_days' ,
        p_value =>l_absence_days ) ;

  hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_hours' ,
        p_value =>l_absence_hours ) ;

    hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_person_id ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute_category' ,
        p_value =>p_attribute_category ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute1' ,
        p_value =>p_attribute1 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute2' ,
        p_value =>p_attribute2 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute3' ,
        p_value =>p_attribute3 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute4' ,
        p_value =>p_attribute4 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute5' ,
        p_value =>p_attribute5 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute6' ,
        p_value =>p_attribute6 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute7' ,
        p_value =>p_attribute7 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute8' ,
        p_value =>p_attribute8 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute9' ,
        p_value =>p_attribute9 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute10' ,
        p_value =>p_attribute10 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute11' ,
        p_value =>p_attribute11 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute12' ,
        p_value =>p_attribute12 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute13' ,
        p_value =>p_attribute13 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute14' ,
        p_value =>p_attribute14 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute15' ,
        p_value =>p_attribute15 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute16' ,
        p_value =>p_attribute16 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute17' ,
        p_value =>p_attribute17 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute18' ,
        p_value =>p_attribute18 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute19' ,
        p_value =>p_attribute19 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute20' ,
        p_value =>p_attribute20 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information_category' ,
        p_value =>p_abs_information_category ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information1' ,
        p_value =>p_abs_information1 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information2' ,
        p_value =>p_abs_information2 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information3' ,
        p_value =>p_abs_information3 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information4' ,
        p_value =>p_abs_information4 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information5' ,
        p_value =>p_abs_information5 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information6' ,
        p_value =>p_abs_information6 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information7' ,
        p_value =>p_abs_information7 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information8' ,
        p_value =>p_abs_information8 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information9' ,
        p_value =>p_abs_information9 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information10' ,
        p_value =>p_abs_information10 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information11' ,
        p_value =>p_abs_information11 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information12' ,
        p_value =>p_abs_information12 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information13' ,
        p_value =>p_abs_information13 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information14' ,
        p_value =>p_abs_information14 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information15' ,
        p_value =>p_abs_information15 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information16' ,
        p_value =>p_abs_information16 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information17' ,
        p_value =>p_abs_information17 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information18' ,
        p_value =>p_abs_information18 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information19' ,
        p_value =>p_abs_information19 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information20' ,
        p_value =>p_abs_information20 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information21' ,
        p_value =>p_abs_information21 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information22' ,
        p_value =>p_abs_information22 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information23' ,
        p_value =>p_abs_information23 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information24' ,
        p_value =>p_abs_information24 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information25' ,
        p_value =>p_abs_information25 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information26' ,
        p_value =>p_abs_information26 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information27' ,
        p_value =>p_abs_information27 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information28' ,
        p_value =>p_abs_information28 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information29' ,
        p_value =>p_abs_information29 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information30' ,
        p_value =>p_abs_information30 ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_leave_status' ,
        p_value =>p_leave_status ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_comments' ,
        p_value =>p_comments ) ;

  hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_save_mode' ,
        p_value =>p_save_mode ) ;

  hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_person_id' ,
        p_value =>p_person_id ) ;

  hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_attendance_type_id' ,
        p_value =>p_absence_attendance_type_id ) ;

  hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_attendance_reason_id' ,
        p_value =>p_abs_attendance_reason_id ) ;


  close csr_abs_attendances;

  hr_utility.set_location(l_proc, 100);

  p_absence_days := l_absence_days;
  p_absence_hours := l_absence_hours;
 --
 --
 -- hr_utility.set_location(' Leaving:' || l_proc,105);

    EXCEPTION
    WHEN hr_utility.hr_error then
         hr_message.provide_error;
         p_page_error := hr_message.last_message_app;
         p_page_error_msg := hr_message.get_message_text;
         p_page_error_num := hr_message.last_message_number;
	 hr_utility.set_location(' Leaving:' || l_proc,555);

    WHEN g_data_error THEN
    hr_utility.trace( 'g_data_error in .process_update_save: ' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,560);

      raise ;
    WHEN OTHERS THEN
      close csr_abs_attendances;
      hr_utility.trace( 'when others in .process_update_save: ' || SQLERRM );
      hr_utility.set_location(' Leaving:' || l_proc,565);

      raise ;

  END process_update_save;

 /*
  ||===========================================================================
  || PROCEDURE: process_update_txn_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||     when updating transaction table for update absence
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
   procedure process_update_txn_save(
   p_transaction_step_id           in     number
  ,p_login_person_id               in     number
  ,p_effective_date                in     date
  --2713296 changes start
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_id         in     per_absence_attendances.absence_attendance_id%type
  ,p_object_version_number         in     number
  ,p_save_mode                     in     varchar2 default null
  --2713296 changes end
  ,p_absence_attendance_type_id    in     number   --2966372
  ,p_date_notification             in     date
  ,p_date_start			   in     date     default null
  ,p_time_start     	           in     varchar2 default null
  ,p_date_end			   in     date     default null
  ,p_time_end     	           in     varchar2 default null
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
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_replacement_person_id         in     number   default null
  ,p_date_projected_start	   in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end	           in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  --2713296 changes start
  ,p_return_on_warning             in      varchar2 default null
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  --2713296 changes end
  ) IS

   l_proc                   varchar2(72) := g_package||'process_updae_txn_save';
   l_creator_person_id      per_all_people_f.person_id%TYPE;
   l_absence_rec            per_absence_attendances%rowtype;
   l_absence_days           per_absence_attendances.absence_days%TYPE;
   l_absence_hours          per_absence_attendances.absence_hours%TYPE;
   l_validate               boolean ;
   l_transaction_id	    number;
   l_transaction_step_id    number;
   l_login_person_id 	    number;

   --2713296 changes start
   l_object_version_number    number;
   l_authorising_person_id    number;
   l_replacement_person_id    number;
   lb_abs_day_after_warning    BOOLEAN;
   lb_abs_overlap_warning      BOOLEAN;
   lb_dur_dys_less_warning      BOOLEAN;
   lb_dur_hrs_less_warning      BOOLEAN;
   lb_exceeds_pto_entit_warning BOOLEAN;
   lb_exceeds_run_total_warning BOOLEAN;
   lb_dur_overwritten_warning   BOOLEAN;
   lb_del_element_entry_warning BOOLEAN;

   --2966372 changes start
   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := null;
   l_sickness_end_date date := null;
   --2966372 changes end

   -- Do not consider current transaction records while checking for overlap
   -- Absence timings are to be considered for checking overlap.

   l_exists            varchar2(1) ;

          CURSOR c_abs_overlap(p_person_id          IN NUMBER
                                 ,p_business_group_id IN NUMBER
                                 ,p_date_start         IN DATE
                                 ,p_date_end           IN DATE
                                 ,p_transaction_step_id IN varchar2
                                 ,p_time_start          IN VARCHAR2
                                 ,p_time_end            IN VARCHAR2
             ) IS

       SELECT null
           FROM  hr_api_transaction_values tv
                ,hr_api_transaction_steps  ts
                ,hr_api_transaction_values tv1
                ,hr_api_transaction_values tv2
                ,hr_api_transaction_values tv3
                ,hr_api_transaction_values tv4
                ,hr_api_transaction_values tv5
                ,hr_api_transaction_values tv6
                ,hr_api_transactions hat -- Fix 3191531
           WHERE
                ts.api_name = 'HR_LOA_SS.PROCESS_API'
            and ts.UPDATE_PERSON_ID = p_person_id
            and p_date_start IS NOT NULL
            and p_date_end IS NOT NULL
            and ts.transaction_step_id = tv.transaction_step_id
            and tv.name = 'P_PERSON_ID'
            and tv.number_value = p_person_id
            and ts.transaction_step_id = tv1.transaction_step_id
            and tv1.name = 'P_BUSINESS_GROUP_ID'
            and tv1.number_value = p_business_group_id
            and ts.transaction_step_id = tv2.transaction_step_id
            and ts.transaction_id=hat.transaction_id
            and hat.status  in ('Y','C') -- Fix 3191531 and 3205669
            and ts.transaction_step_id = tv3.transaction_step_id
            and tv3.name = 'P_DATE_START'
            and ts.transaction_step_id = tv4.transaction_step_id
            and tv4.name = 'P_DATE_END'
            and ts.transaction_step_id = tv5.transaction_step_id
            and ts.transaction_step_id = tv6.transaction_step_id
            and tv5.name = 'P_TIME_START'
            and tv5.name = 'P_TIME_END'
            and tv3.date_value is NOT NULL
            and tv4.date_value is NOT NULL
and (
	                  (
	                 to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt)  ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                  BETWEEN to_date (to_char(p_date_start, g_usr_date_fmt)||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
	                  AND to_date(to_char(p_date_end, g_usr_date_fmt) || ' '|| nvl(p_time_end,'00:00') , g_usr_day_time_fmt)
	                   )
	                  or
	                  (
	                  to_date (to_char(p_date_start, g_usr_date_fmt) ||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
	                   BETWEEN
	                   to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                  AND
	                  to_date( to_char(nvl(tv4.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv6.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                   )

          )
       and ts.transaction_step_id <>p_transaction_step_id ;

   --2713296 changes end




BEGIN

 --
 -- Update Transaction Table
 --
   hr_utility.set_location(' Entering:' || l_proc,5);

   l_creator_person_id := p_login_person_id;
   l_transaction_step_id := p_transaction_step_id;

   --2713296 changes start
   l_object_version_number := p_object_version_number;
   l_validate := TRUE;
   --2713296 changes end

   if p_absence_days = -1 then
      l_absence_days := null;
   else
      l_absence_days := p_absence_days;
   end if;
   if p_absence_hours = -1 then
      l_absence_hours := null;
   else
      l_absence_hours := p_absence_hours;
   end if;

   --2966372 changes start
   l_populate_sickness_dates := is_gb_leg_and_category_s(p_absence_attendance_type_id , p_business_group_id);

   IF l_populate_sickness_dates THEN
      l_sickness_start_date := p_date_start;
      l_sickness_end_date := p_date_end;
   END IF;
   --2966372 changes end

   --2713296 changes start
   --
   -- Support Save For Later
   --
   -- p_absence_attendance_id and p_object_version_number will be 0
   -- when transaction corresponds to Return for correction.
  if p_save_mode <> 'SaveForLater'
     and p_absence_attendance_id <> 0 --2824349
  then

   hr_utility.set_location(l_proc, 20);
   hr_person_absence_api.update_person_absence(
          p_validate                   => l_validate
           ,p_effective_date             => p_effective_date
   --        ,p_business_group_id          => l_absence_rec.business_group_id
           ,p_absence_attendance_id      => p_absence_attendance_id
           ,p_date_notification          => p_date_notification
           ,p_date_start                 => p_date_start
           ,p_time_start                 => p_time_start
           ,p_date_end                   => p_date_end
           ,p_time_end                   => p_time_end
           ,p_absence_days               => l_absence_days
           ,p_absence_hours              => l_absence_hours
           ,p_replacement_person_id      => p_replacement_person_id
           ,p_object_version_number      => l_object_version_number
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
           ,p_abs_information_category            => p_abs_information_category
           ,p_abs_information1                    => p_abs_information1
           ,p_abs_information2                    => p_abs_information2
           ,p_abs_information3                    => p_abs_information3
           ,p_abs_information4                    => p_abs_information4
           ,p_abs_information5                    => p_abs_information5
           ,p_abs_information6                    => p_abs_information6
           ,p_abs_information7                    => p_abs_information7
           ,p_abs_information8                    => p_abs_information8
           ,p_abs_information9                    => p_abs_information9
           ,p_abs_information10                   => p_abs_information10
           ,p_abs_information11                   => p_abs_information11
           ,p_abs_information12                   => p_abs_information12
           ,p_abs_information13                   => p_abs_information13
           ,p_abs_information14                   => p_abs_information14
           ,p_abs_information15                   => p_abs_information15
           ,p_abs_information16                   => p_abs_information16
           ,p_abs_information17                   => p_abs_information17
           ,p_abs_information18                   => p_abs_information18
           ,p_abs_information19                   => p_abs_information19
           ,p_abs_information20                   => p_abs_information20
           ,p_abs_information21                   => p_abs_information21
           ,p_abs_information22                   => p_abs_information22
           ,p_abs_information23                   => p_abs_information23
           ,p_abs_information24                   => p_abs_information24
           ,p_abs_information25                   => p_abs_information25
           ,p_abs_information26                   => p_abs_information26
           ,p_abs_information27                   => p_abs_information27
           ,p_abs_information28                   => p_abs_information28
           ,p_abs_information29                   => p_abs_information29
           ,p_abs_information30                   => p_abs_information30
           ,p_sickness_start_date        => l_sickness_start_date --2966372
           ,p_sickness_end_date          => l_sickness_end_date --2966372
           ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
           ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
           ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
           ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
           ,p_abs_overlap_warning        => lb_abs_overlap_warning
           ,p_abs_day_after_warning      => lb_abs_day_after_warning
           ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
           ,p_del_element_entry_warning  => lb_del_element_entry_warning
      );

   p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
   p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
   p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
   p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
   p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
   p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
   p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

   if (lb_abs_day_after_warning OR
       lb_abs_overlap_warning   OR
       lb_exceeds_pto_entit_warning OR   --2848345
       lb_dur_dys_less_warning  OR       --2765646
       lb_dur_hrs_less_warning  OR       --2765646
       lb_exceeds_run_total_warning) AND --2797220
       p_return_on_warning = 'true' then  --2713296
     hr_utility.set_location(l_proc, 30);
     return;
   else
   -- Replaced call to chk_overlap function because we should check for overlapping
   -- in all but current transaction step id records of hr_api_transaction_values.

   -- Need to check for null otherwise, we may get invalid month error
     IF p_date_start IS NOT NULL AND p_date_end IS NOT NULL AND
       p_time_start IS NOT NULL and p_time_end IS NOT NULL AND p_transaction_step_id IS NOT NULL
     THEN

       open  c_abs_overlap(p_person_id,p_business_group_id,p_date_start,p_date_end,p_transaction_step_id,p_time_start,p_time_end);

       fetch c_abs_overlap into l_exists;

       if c_abs_overlap%found then

         lb_abs_overlap_warning := TRUE;
       else
         lb_abs_overlap_warning := FALSE;
       end if;

     END IF;     --Dates Not Null

     if lb_abs_overlap_warning and p_return_on_warning = 'true' then  --2713296
        hr_utility.set_location(l_proc, 40);
        p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
        return;
     end if;

   end if;	--WARNING CHECK

  end if; -- Support Save For Later

  --2713296 changes end

  --
  -- Update Transaction
  --


   hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_effective_date' ,
        p_value =>p_effective_date ) ;

   hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_notification' ,
        p_value =>p_date_notification) ;

   hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_start' ,
          p_value =>p_date_start) ;

   hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_start' ,
          p_value =>p_time_start ) ;

   hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_end' ,
          p_value =>p_date_end) ;

   hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_end' ,
          p_value =>p_time_end ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute_category' ,
        p_value =>p_attribute_category ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute1' ,
        p_value =>p_attribute1 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute2' ,
        p_value =>p_attribute2 ) ;


   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute3' ,
        p_value =>p_attribute3 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute4' ,
        p_value =>p_attribute4 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute5' ,
        p_value =>p_attribute5 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute6' ,
        p_value =>p_attribute6 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute7' ,
        p_value =>p_attribute7 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute8' ,
        p_value =>p_attribute8 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute9' ,
        p_value =>p_attribute9 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute10' ,
        p_value =>p_attribute10 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute11' ,
        p_value =>p_attribute11 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute12' ,
        p_value =>p_attribute12 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute13' ,
        p_value =>p_attribute13 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute14' ,
        p_value =>p_attribute14 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute15' ,
        p_value =>p_attribute15 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute16' ,
        p_value =>p_attribute16 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute17' ,
        p_value =>p_attribute17 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute18' ,
        p_value =>p_attribute18 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute19' ,
        p_value =>p_attribute19 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute20' ,
        p_value =>p_attribute20 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information_category' ,
        p_value =>p_abs_information_category ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information1' ,
        p_value =>p_abs_information1 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information2' ,
        p_value =>p_abs_information2 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information3' ,
        p_value =>p_abs_information3 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information4' ,
        p_value =>p_abs_information4 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information5' ,
        p_value =>p_abs_information5 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information6' ,
        p_value =>p_abs_information6 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information7' ,
        p_value =>p_abs_information7 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information8' ,
        p_value =>p_abs_information8 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information9' ,
        p_value =>p_abs_information9 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information10' ,
        p_value =>p_abs_information10 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information11' ,
        p_value =>p_abs_information11 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information12' ,
        p_value =>p_abs_information12 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information13' ,
        p_value =>p_abs_information13 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information14' ,
        p_value =>p_abs_information14 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information15' ,
        p_value =>p_abs_information15 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information16' ,
        p_value =>p_abs_information16 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information17' ,
        p_value =>p_abs_information17 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information18' ,
        p_value =>p_abs_information18 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information19' ,
        p_value =>p_abs_information19 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information20' ,
        p_value =>p_abs_information20 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information21' ,
        p_value =>p_abs_information21 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information22' ,
        p_value =>p_abs_information22 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information23' ,
        p_value =>p_abs_information23 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information24' ,
        p_value =>p_abs_information24 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information25' ,
        p_value =>p_abs_information25 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information26' ,
        p_value =>p_abs_information26 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information27' ,
        p_value =>p_abs_information27 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information28' ,
        p_value =>p_abs_information28 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information29' ,
        p_value =>p_abs_information29 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information30' ,
        p_value =>p_abs_information30 ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_leave_status' ,
        p_value =>p_leave_status ) ;

   hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_comments' ,
        p_value =>p_comments ) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_days' ,
        p_value =>l_absence_days ) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_hours' ,
        p_value =>l_absence_hours ) ;

   hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_person_id ) ;

   hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_projected_start' ,
          p_value =>p_date_projected_start) ;

   hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_projected_start' ,
          p_value =>p_time_projected_start ) ;

   hr_transaction_api.set_date_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_date_projected_end' ,
          p_value =>p_date_projected_end) ;

   hr_transaction_api.set_varchar2_value (
          p_transaction_step_id =>l_transaction_step_id,
          p_person_id => l_creator_person_id ,
          p_name => 'p_time_projected_end' ,
          p_value =>p_time_projected_end ) ;

 --
 --
 hr_utility.set_location(' Leaving:' || l_proc,45);

 --
    EXCEPTION

    --4064949
    WHEN hr_utility.hr_error then
         hr_message.provide_error;
         p_page_error := hr_message.last_message_app;
         p_page_error_msg := hr_message.get_message_text;
         p_page_error_num := hr_message.last_message_number;
         hr_utility.set_location(' Leaving:' || l_proc,500);

    WHEN g_data_error THEN
    hr_utility.trace('g_data_error exception in .process_update_txn_save: ' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,555);

      raise ;
    WHEN OTHERS THEN
    hr_utility.trace(' when others exception in .process_update_txn_save: ' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,560);

      raise ;

  END process_update_txn_save;



--kcke

/*
  ||===========================================================================
  || PROCEDURE: process_txn_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call actual API with validate mode
  ||     if there are no error, save date into transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure process_txn_save(
   p_transaction_step_id           in     NUMBER
  ,p_login_person_id               in     number
  ,p_review_proc_call              in     varchar2
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date default null
  ,p_date_projected_start          in     date default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
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
  ,p_start_ampm                    in     varchar2 default null
  ,p_end_ampm                      in     varchar2 default null
  ,p_save_mode                     in     varchar2 default null
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_leave_status                  in     varchar2 default null
  ,p_return_on_warning             in     varchar2 default null  --2713296
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    number
  ,p_dur_hrs_less_warning          out nocopy    number
  ,p_exceeds_pto_entit_warning     out nocopy    number
  ,p_exceeds_run_total_warning     out nocopy    number
  ,p_abs_overlap_warning           out nocopy    number
  ,p_abs_day_after_warning         out nocopy    number
  ,p_dur_overwritten_warning       out nocopy    number
  ,p_page_error                    out nocopy    varchar2
  ,p_page_error_msg                out nocopy    varchar2
  ,p_page_error_num                out nocopy    varchar2
  ) IS

   l_proc                     varchar2(72) := g_package||'process_txn_save';
   l_creator_person_id        per_all_people_f.person_id%TYPE;
   l_validate                 boolean;
   l_transaction_id	      number;
   l_absence_days             number;
   l_absence_hours            number;
   l_transaction_step_id      number;
   l_abs_attendance_reason_id number;
   l_login_person_id 	      number;
   l_authorising_person_id    number;
   l_replacement_person_id    number;
   lb_abs_day_after_warning    BOOLEAN;
   lb_abs_overlap_warning      BOOLEAN;
   lb_dur_dys_less_warning      BOOLEAN;
   lb_dur_hrs_less_warning      BOOLEAN;
   lb_exceeds_pto_entit_warning BOOLEAN;
   lb_exceeds_run_total_warning BOOLEAN;
   lb_dur_overwritten_warning   BOOLEAN;

   --2966372 changes start
   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := null;
   l_sickness_end_date date := null;
   --2966372 changes end

  -- Fix 2666959 Start
  -- Do not consider current transaction records while checking for overlap
  --

  -- Fix 2706099
  -- Absence timings are to be considered for checking overlap.
  --

   l_exists            varchar2(1) ;

      CURSOR c_abs_overlap(p_person_id          IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_date_start         IN DATE
                             ,p_date_end           IN DATE
                             ,p_transaction_step_id IN varchar2
                             ,p_time_start          IN VARCHAR2
                             ,p_time_end            IN VARCHAR2
         ) IS

 SELECT null
        FROM  hr_api_transaction_values tv
             ,hr_api_transaction_steps  ts
             ,hr_api_transaction_values tv1
             ,hr_api_transaction_values tv2
             ,hr_api_transaction_values tv3
             ,hr_api_transaction_values tv4
             ,hr_api_transaction_values tv5
             ,hr_api_transaction_values tv6
             ,hr_api_transactions hat -- Fix 3191531

        WHERE
             ts.api_name = 'HR_LOA_SS.PROCESS_API'
         and ts.UPDATE_PERSON_ID = p_person_id
         and p_date_start IS NOT NULL
         and p_date_end IS NOT NULL
         and ts.transaction_step_id = tv.transaction_step_id
         and tv.name = 'P_PERSON_ID'
         and tv.number_value = p_person_id
         and ts.transaction_step_id = tv1.transaction_step_id
         and tv1.name = 'P_BUSINESS_GROUP_ID'
         and tv1.number_value = p_business_group_id
         and ts.transaction_step_id = tv2.transaction_step_id
         and ts.transaction_id=hat.transaction_id
         and hat.status  in ('Y','C') -- Fix 3191531 and 3205669
         and ts.transaction_step_id = tv3.transaction_step_id
         and tv3.name = 'P_DATE_START'
         and ts.transaction_step_id = tv4.transaction_step_id
         and tv4.name = 'P_DATE_END'
         and ts.transaction_step_id = tv5.transaction_step_id
         and ts.transaction_step_id = tv6.transaction_step_id
         and tv5.name = 'P_TIME_START'
         and tv5.name = 'P_TIME_END'
         and tv3.date_value is NOT NULL
         and tv4.date_value is NOT NULL
 and (
 	                  (
 	                 to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt)  ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
 	                  BETWEEN to_date (to_char(p_date_start, g_usr_date_fmt)||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
 	                  AND to_date(to_char(p_date_end, g_usr_date_fmt) || ' '|| nvl(p_time_end,'00:00') , g_usr_day_time_fmt)
 	                   )
 	                  or
 	                  (
 	                  to_date (to_char(p_date_start, g_usr_date_fmt) ||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
 	                   BETWEEN
 	                   to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
 	                  AND
 	                  to_date( to_char(nvl(tv4.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv6.varchar2_value,'00:00'),g_usr_day_time_fmt)
 	                   )

           )
       and ts.transaction_step_id <>p_transaction_step_id ;
    -- Fix 2666959 End
    -- For checking dates in transaction tables, we should convert dates into user's date and time format.

BEGIN
    hr_utility.set_location('Entering..:' || l_proc, 10);
 --
 --  Call API with validate mode
 --

    l_transaction_step_id := p_transaction_step_id;

    l_validate := TRUE;
    l_authorising_person_id  := to_number(p_authorising_person_id);
    l_replacement_person_id  := to_number(p_replacement_person_id);

    if p_abs_attendance_reason_id = -1 then
      l_abs_attendance_reason_id := null;
    else
      l_abs_attendance_reason_id := p_abs_attendance_reason_id;
    end if;
    if p_absence_days = -1 then
      l_absence_days := null;
    else
      l_absence_days := p_absence_days;
    end if;
    if p_absence_hours = -1 then
      l_absence_hours := null;
    else
      l_absence_hours := p_absence_hours;
    end if;

    --2966372 changes start
    l_populate_sickness_dates := is_gb_leg_and_category_s(p_absence_attendance_type_id , p_business_group_id);

    IF l_populate_sickness_dates THEN
       l_sickness_start_date := p_date_start;
       l_sickness_end_date := p_date_end;
    END IF;
    --2966372 changes end

    --
    -- Support Save For Later
    --
    if p_save_mode <> 'SaveForLater' then

    hr_utility.set_location(l_proc, 20);
    hr_person_absence_api.create_person_absence(
       p_validate                      => l_validate
      ,p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => l_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => l_authorising_person_id
      ,p_replacement_person_id         => l_replacement_person_id
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
      ,p_period_of_incapacity_id       => null
      ,p_ssp1_issued                   => 'N'
      ,p_maternity_id                  => null
      ,p_sickness_start_date           => l_sickness_start_date --2966372
      ,p_sickness_end_date             => l_sickness_end_date --2966372
      ,p_pregnancy_related_illness     => 'N'
      ,p_reason_for_notification_dela  => null
      ,p_accept_late_notification_fla  => 'N'
      ,p_linked_absence_id             => null
      ,p_abs_information_category            => p_abs_information_category
      ,p_abs_information1                    => p_abs_information1
      ,p_abs_information2                    => p_abs_information2
      ,p_abs_information3                    => p_abs_information3
      ,p_abs_information4                    => p_abs_information4
      ,p_abs_information5                    => p_abs_information5
      ,p_abs_information6                    => p_abs_information6
      ,p_abs_information7                    => p_abs_information7
      ,p_abs_information8                    => p_abs_information8
      ,p_abs_information9                    => p_abs_information9
      ,p_abs_information10                   => p_abs_information10
      ,p_abs_information11                   => p_abs_information11
      ,p_abs_information12                   => p_abs_information12
      ,p_abs_information13                   => p_abs_information13
      ,p_abs_information14                   => p_abs_information14
      ,p_abs_information15                   => p_abs_information15
      ,p_abs_information16                   => p_abs_information16
      ,p_abs_information17                   => p_abs_information17
      ,p_abs_information18                   => p_abs_information18
      ,p_abs_information19                   => p_abs_information19
      ,p_abs_information20                   => p_abs_information20
      ,p_abs_information21                   => p_abs_information21
      ,p_abs_information22                   => p_abs_information22
      ,p_abs_information23                   => p_abs_information23
      ,p_abs_information24                   => p_abs_information24
      ,p_abs_information25                   => p_abs_information25
      ,p_abs_information26                   => p_abs_information26
      ,p_abs_information27                   => p_abs_information27
      ,p_abs_information28                   => p_abs_information28
      ,p_abs_information29                   => p_abs_information29
      ,p_abs_information30                   => p_abs_information30
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_occurrence                    => p_occurrence
      ,p_dur_dys_less_warning          => lb_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => lb_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => lb_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => lb_exceeds_run_total_warning
      ,p_abs_overlap_warning           => lb_abs_overlap_warning
      ,p_abs_day_after_warning         => lb_abs_day_after_warning
      ,p_dur_overwritten_warning       => lb_dur_overwritten_warning
   );


   p_abs_day_after_warning := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_day_after_warning);
   p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
   p_dur_dys_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_dys_less_warning);
   p_dur_hrs_less_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_hrs_less_warning);
   p_exceeds_pto_entit_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_pto_entit_warning);
   p_exceeds_run_total_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_exceeds_run_total_warning);
   p_dur_overwritten_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_dur_overwritten_warning);

   if (lb_abs_day_after_warning OR
       lb_abs_overlap_warning   OR
       lb_exceeds_pto_entit_warning OR   --2848345
       lb_dur_dys_less_warning  OR       --2765646
       lb_dur_hrs_less_warning  OR       --2765646
       lb_exceeds_run_total_warning) AND --2797220
       p_return_on_warning = 'true' then  --2713296
     hr_utility.set_location(l_proc, 30);
     return;
   else -- BUG 2415512


   -- Fix 2666959 Start
   -- Replaced call to chk_overlap function because we should check for overlapping
   -- in all but current transaction step id records of hr_api_transaction_values.

   -- Need to check for null otherwise, we may get invalid month error
     IF p_date_start IS NOT NULL AND p_date_end IS NOT NULL AND
       p_time_start IS NOT NULL and p_time_end IS NOT NULL AND p_transaction_step_id IS NOT NULL
     THEN

   open  c_abs_overlap(p_person_id,p_business_group_id,p_date_start,p_date_end,p_transaction_step_id,p_time_start,p_time_end);

     fetch c_abs_overlap into l_exists;

     if c_abs_overlap%found then

       lb_abs_overlap_warning := TRUE;
     else
       lb_abs_overlap_warning := FALSE;
     end if;
  END IF;
   -- Fix 2666959 End

   if lb_abs_overlap_warning and p_return_on_warning = 'true' then  --2713296
        hr_utility.set_location(l_proc, 40);
        p_abs_overlap_warning  := hr_java_conv_util_ss.get_number(p_boolean => lb_abs_overlap_warning);
        return;
      end if;
   end if;
   end if; -- Support Save For Later

    hr_utility.set_location(l_proc, 50);

    p_absence_days := l_absence_days;
    p_absence_hours := l_absence_hours;
 --
 -- Update Transaction
 --

    l_validate := FALSE;
--    hr_util_misc_web.validate_session(p_person_id => l_creator_person_id);
    l_creator_person_id := p_login_person_id;


      hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_validate' ,
        p_value =>l_validate ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_effective_date' ,
        p_value =>p_effective_date ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_person_id' ,
        p_value =>p_person_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_business_group_id' ,
        p_value =>p_business_group_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_attendance_type_id' ,
        p_value =>p_absence_attendance_type_id ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_attendance_reason_id' ,
        p_value =>l_abs_attendance_reason_id ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_comments' ,
        p_value =>p_comments ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_authorising_person_id' ,
        p_value =>p_authorising_person_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_replacement_person_id' ,
        p_value =>p_replacement_person_id ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_projected_start' ,
        p_value =>p_date_projected_start) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_projected_start' ,
        p_value =>p_time_projected_start ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_projected_end' ,
        p_value =>p_date_projected_end) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_projected_end' ,
        p_value =>p_time_projected_end ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_start' ,
        p_value =>p_date_start) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_start' ,
        p_value =>p_time_start ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_end' ,
        p_value =>p_date_end) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_time_end' ,
        p_value =>p_time_end ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_days' ,
        p_value =>p_absence_days ) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_absence_hours' ,
        p_value =>p_absence_hours ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_date_notification' ,
        p_value =>p_date_notification ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute_category' ,
        p_value =>p_attribute_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute1' ,
        p_value =>p_attribute1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute2' ,
        p_value =>p_attribute2 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute3' ,
        p_value =>p_attribute3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute4' ,
        p_value =>p_attribute4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute5' ,
        p_value =>p_attribute5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute6' ,
        p_value =>p_attribute6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute7' ,
        p_value =>p_attribute7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute8' ,
        p_value =>p_attribute8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute9' ,
        p_value =>p_attribute9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute10' ,
        p_value =>p_attribute10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute11' ,
        p_value =>p_attribute11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute12' ,
        p_value =>p_attribute12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute13' ,
        p_value =>p_attribute13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute14' ,
        p_value =>p_attribute14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute15' ,
        p_value =>p_attribute15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute16' ,
        p_value =>p_attribute16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute17' ,
        p_value =>p_attribute17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute18' ,
        p_value =>p_attribute18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute19' ,
        p_value =>p_attribute19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_attribute20' ,
        p_value =>p_attribute20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information_category' ,
        p_value =>p_abs_information_category ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information1' ,
        p_value =>p_abs_information1 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information2' ,
        p_value =>p_abs_information2 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information3' ,
        p_value =>p_abs_information3 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information4' ,
        p_value =>p_abs_information4 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information5' ,
        p_value =>p_abs_information5 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information6' ,
        p_value =>p_abs_information6 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information7' ,
        p_value =>p_abs_information7 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information8' ,
        p_value =>p_abs_information8 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information9' ,
        p_value =>p_abs_information9 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information10' ,
        p_value =>p_abs_information10 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information11' ,
        p_value =>p_abs_information11 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information12' ,
        p_value =>p_abs_information12 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information13' ,
        p_value =>p_abs_information13 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information14' ,
        p_value =>p_abs_information14 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information15' ,
        p_value =>p_abs_information15 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information16' ,
        p_value =>p_abs_information16 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information17' ,
        p_value =>p_abs_information17 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information18' ,
        p_value =>p_abs_information18 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information19' ,
        p_value =>p_abs_information19 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information20' ,
        p_value =>p_abs_information20 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information21' ,
        p_value =>p_abs_information21 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information22' ,
        p_value =>p_abs_information22 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information23' ,
        p_value =>p_abs_information23 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information24' ,
        p_value =>p_abs_information24 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information25' ,
        p_value =>p_abs_information25 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information26' ,
        p_value =>p_abs_information26 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information27' ,
        p_value =>p_abs_information27 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information28' ,
        p_value =>p_abs_information28 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information29' ,
        p_value =>p_abs_information29 ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_abs_information30' ,
        p_value =>p_abs_information30 ) ;

  --
     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_leave_status' ,
        p_value =>p_leave_status ) ;

  --
  -- Save For Later
  --
     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_start_ampm' ,
        p_value =>p_start_ampm ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_end_ampm' ,
        p_value =>p_end_ampm ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>l_transaction_step_id,
        p_person_id => l_creator_person_id ,
        p_name => 'p_save_mode' ,
        p_value =>p_save_mode ) ;
 --
 --
 -- hr_utility.set_location('Leaving..:' || l_proc, 50);
    EXCEPTION
      WHEN hr_utility.hr_error then
         hr_message.provide_error;
         p_page_error := hr_message.last_message_app;
         p_page_error_msg := hr_message.get_message_text;
         p_page_error_num := hr_message.last_message_number;
	 hr_utility.set_location('Leaving..:' || l_proc, 555);
      WHEN OTHERS THEN
      hr_utility.trace( ' HR_LOA_SS.process_save ' || SQLERRM );
      hr_utility.set_location('Leaving..:' || l_proc, 560);
         raise ;


  END process_txn_save;

  /*
  ||===========================================================================
  || PROCEDURE: process_api
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API from transaction table
  ||                hr_person_absence_api.update_person_absence()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure process_api
  (p_validate                 in     boolean default false
  ,p_transaction_step_id      in     number
  ,p_effective_date           in     varchar2 default null
  ) is

   l_proc                         varchar2(72) := g_package||'process_api';
   l_validate                     boolean;
   l_effective_date	          date;
   l_absence_rec	          per_absence_attendances%rowtype;
   l_activity_name	          varchar2(30);
   l_leave_status	          varchar2(30);
   l_business_group_id            number;
   l_absence_attendance_id        number;
   l_object_version_number        number;
   l_occurrence                   number;
   lb_abs_day_after_warning       boolean;
   lb_abs_overlap_warning         boolean;
   lb_dur_dys_less_warning        BOOLEAN;
   lb_dur_hrs_less_warning        BOOLEAN;
   lb_exceeds_pto_entit_warning   BOOLEAN;
   lb_exceeds_run_total_warning   BOOLEAN;
   lb_dur_overwritten_warning     BOOLEAN;
   lb_del_element_entry_warning BOOLEAN;
   l_period_of_incapacity_id      number;
   l_ssp1_issued                  varchar2(30);
   l_maternity_id                 number;
   l_sickness_start_date          date := null; --2966372
   l_sickness_end_date            date := null; --2966372
   l_pregnancy_related_illness    varchar2(30);
   l_reason_for_notification_dela varchar2(2000);
   l_accept_late_notification_fla varchar2(30);
   l_absence_days                 number;
   l_absence_hours                number;
   l_populate_sickness_dates      boolean := false; --2966372

BEGIN

  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    if (p_effective_date is not null) then
      l_effective_date:= to_date(p_effective_date,g_date_format);
    else
      l_effective_date:= to_date(
        hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => p_transaction_step_id),g_date_format);
    end if;

--    l_effective_date :=
--      hr_transaction_api.get_date_value
--      (p_transaction_step_id => p_transaction_step_id
--      ,p_name                => 'p_effective_date');

  --
    l_activity_name:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_activity_name');

    l_leave_status:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_leave_status');


    --
    -- Issue the savepoint.
    --
    savepoint loa_process_api;

    if l_activity_name = 'HrLoa' OR l_activity_name = 'HrLoaComp' then
      hr_utility.set_location(l_proc, 20);

      get_abs_from_tt
        (p_transaction_step_id => p_transaction_step_id
        ,p_absence_rec         => l_absence_rec);

      l_absence_days := l_absence_rec.absence_days ;
      l_absence_hours := l_absence_rec.absence_hours ;

      --2966372 changes start
      l_populate_sickness_dates := is_gb_leg_and_category_s(l_absence_rec.absence_attendance_type_id
						, l_absence_rec.business_group_id);

      IF l_populate_sickness_dates THEN
         l_sickness_start_date := l_absence_rec.date_start;
         l_sickness_end_date := l_absence_rec.date_end;
      END IF;
      --2966372 changes end

      hr_person_absence_api.create_person_absence(
        p_validate                   => l_validate
       ,p_effective_date             => l_effective_date
       ,p_person_id                  => l_absence_rec.person_id
       ,p_business_group_id          => l_absence_rec.business_group_id
       ,p_absence_attendance_type_id => l_absence_rec.absence_attendance_type_id
       ,p_abs_attendance_reason_id   => l_absence_rec.abs_attendance_reason_id
       ,p_comments                   => l_absence_rec.comments
       ,p_date_notification          => l_absence_rec.date_notification
       ,p_date_projected_start       => l_absence_rec.date_projected_start
       ,p_time_projected_start       => l_absence_rec.time_projected_start
       ,p_date_projected_end         => l_absence_rec.date_projected_end
       ,p_time_projected_end         => l_absence_rec.time_projected_end
       ,p_date_start                 => l_absence_rec.date_start
       ,p_time_start                 => l_absence_rec.time_start
       ,p_date_end                   => l_absence_rec.date_end
       ,p_time_end                   => l_absence_rec.time_end
       ,p_absence_days               => l_absence_rec.absence_days
       ,p_absence_hours              => l_absence_rec.absence_hours
       ,p_authorising_person_id      => l_absence_rec.authorising_person_id
       ,p_replacement_person_id      => l_absence_rec.replacement_person_id
       ,p_attribute_category         => l_absence_rec.attribute_category
       ,p_attribute1                 => l_absence_rec.attribute1
       ,p_attribute2                 => l_absence_rec.attribute2
       ,p_attribute3                 => l_absence_rec.attribute3
       ,p_attribute4                 => l_absence_rec.attribute4
       ,p_attribute5                 => l_absence_rec.attribute5
       ,p_attribute6                 => l_absence_rec.attribute6
       ,p_attribute7                 => l_absence_rec.attribute7
       ,p_attribute8                 => l_absence_rec.attribute8
       ,p_attribute9                 => l_absence_rec.attribute9
       ,p_attribute10                => l_absence_rec.attribute10
       ,p_attribute11                => l_absence_rec.attribute11
       ,p_attribute12                => l_absence_rec.attribute12
       ,p_attribute13                => l_absence_rec.attribute13
       ,p_attribute14                => l_absence_rec.attribute14
       ,p_attribute15                => l_absence_rec.attribute15
       ,p_attribute16                => l_absence_rec.attribute16
       ,p_attribute17                => l_absence_rec.attribute17
       ,p_attribute18                => l_absence_rec.attribute18
       ,p_attribute19                => l_absence_rec.attribute19
       ,p_attribute20                => l_absence_rec.attribute20
       ,p_period_of_incapacity_id    => null
       ,p_ssp1_issued                => 'N'
       ,p_maternity_id               => null
       ,p_sickness_start_date        => l_sickness_start_date --2966372
       ,p_sickness_end_date          => l_sickness_end_date --2966372
       ,p_pregnancy_related_illness     => 'N'
       ,p_reason_for_notification_dela  => null
       ,p_accept_late_notification_fla  => 'N'
       ,p_linked_absence_id             => null
       ,p_abs_information_category         => l_absence_rec.abs_information_category
       ,p_abs_information1                 => l_absence_rec.abs_information1
       ,p_abs_information2                 => l_absence_rec.abs_information2
       ,p_abs_information3                 => l_absence_rec.abs_information3
       ,p_abs_information4                 => l_absence_rec.abs_information4
       ,p_abs_information5                 => l_absence_rec.abs_information5
       ,p_abs_information6                 => l_absence_rec.abs_information6
       ,p_abs_information7                 => l_absence_rec.abs_information7
       ,p_abs_information8                 => l_absence_rec.abs_information8
       ,p_abs_information9                 => l_absence_rec.abs_information9
       ,p_abs_information10                => l_absence_rec.abs_information10
       ,p_abs_information11                => l_absence_rec.abs_information11
       ,p_abs_information12                => l_absence_rec.abs_information12
       ,p_abs_information13                => l_absence_rec.abs_information13
       ,p_abs_information14                => l_absence_rec.abs_information14
       ,p_abs_information15                => l_absence_rec.abs_information15
       ,p_abs_information16                => l_absence_rec.abs_information16
       ,p_abs_information17                => l_absence_rec.abs_information17
       ,p_abs_information18                => l_absence_rec.abs_information18
       ,p_abs_information19                => l_absence_rec.abs_information19
       ,p_abs_information20                => l_absence_rec.abs_information20
       ,p_abs_information21                => l_absence_rec.abs_information21
       ,p_abs_information22                => l_absence_rec.abs_information22
       ,p_abs_information23                => l_absence_rec.abs_information23
       ,p_abs_information24                => l_absence_rec.abs_information24
       ,p_abs_information25                => l_absence_rec.abs_information25
       ,p_abs_information26                => l_absence_rec.abs_information26
       ,p_abs_information27                => l_absence_rec.abs_information27
       ,p_abs_information28                => l_absence_rec.abs_information28
       ,p_abs_information29                => l_absence_rec.abs_information29
       ,p_abs_information30                => l_absence_rec.abs_information30
       ,p_absence_attendance_id      => l_absence_attendance_id
       ,p_object_version_number      => l_object_version_number
       ,p_occurrence                 => l_occurrence
       ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
       ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
       ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
       ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
       ,p_abs_overlap_warning        => lb_abs_overlap_warning
       ,p_abs_day_after_warning      => lb_abs_day_after_warning
       ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
     );

    elsif l_activity_name = 'HrLoaReturn' OR l_leave_status = g_confirm then
      hr_utility.set_location(l_proc, 30);

      get_rtn_from_tt
        (p_transaction_step_id => p_transaction_step_id
        ,p_absence_rec         => l_absence_rec);

      --3400323 changes start
      l_populate_sickness_dates := is_gb_leg_and_category_s(l_absence_rec.absence_attendance_type_id
						, l_absence_rec.business_group_id);

      IF l_populate_sickness_dates THEN
         l_sickness_start_date := l_absence_rec.date_start;
         l_sickness_end_date := l_absence_rec.date_end;
      END IF;
      --3400323 changes end

      l_absence_days := l_absence_rec.absence_days ;
      l_absence_hours := l_absence_rec.absence_hours ;
      l_object_version_number := l_absence_rec.object_version_number;

      hr_person_absence_api.update_person_absence(
        p_validate                   => l_validate
       ,p_effective_date             => l_effective_date
       ,p_date_notification          => l_effective_date
--       ,p_business_group_id          => l_absence_rec.business_group_id
       ,p_absence_attendance_id      => l_absence_rec.absence_attendance_id
       ,p_date_start                 => l_absence_rec.date_start
       ,p_time_start                 => l_absence_rec.time_start
       ,p_date_end                   => l_absence_rec.date_end
       ,p_time_end                   => l_absence_rec.time_end
       ,p_replacement_person_id      => l_absence_rec.replacement_person_id
       ,p_comments                   => l_absence_rec.comments
       ,p_absence_days               => l_absence_rec.absence_days
       ,p_absence_hours              => l_absence_rec.absence_hours
       ,p_attribute_category         => l_absence_rec.attribute_category
       ,p_attribute1                 => l_absence_rec.attribute1
       ,p_attribute2                 => l_absence_rec.attribute2
       ,p_attribute3                 => l_absence_rec.attribute3
       ,p_attribute4                 => l_absence_rec.attribute4
       ,p_attribute5                 => l_absence_rec.attribute5
       ,p_attribute6                 => l_absence_rec.attribute6
       ,p_attribute7                 => l_absence_rec.attribute7
       ,p_attribute8                 => l_absence_rec.attribute8
       ,p_attribute9                 => l_absence_rec.attribute9
       ,p_attribute10                => l_absence_rec.attribute10
       ,p_attribute11                => l_absence_rec.attribute11
       ,p_attribute12                => l_absence_rec.attribute12
       ,p_attribute13                => l_absence_rec.attribute13
       ,p_attribute14                => l_absence_rec.attribute14
       ,p_attribute15                => l_absence_rec.attribute15
       ,p_attribute16                => l_absence_rec.attribute16
       ,p_attribute17                => l_absence_rec.attribute17
       ,p_attribute18                => l_absence_rec.attribute18
       ,p_attribute19                => l_absence_rec.attribute19
       ,p_attribute20                => l_absence_rec.attribute20
       ,p_sickness_start_date        => l_sickness_start_date --3400323
       ,p_sickness_end_date          => l_sickness_end_date --3400323
       ,p_abs_information_category         => l_absence_rec.abs_information_category
       ,p_abs_information1                 => l_absence_rec.abs_information1
       ,p_abs_information2                 => l_absence_rec.abs_information2
       ,p_abs_information3                 => l_absence_rec.abs_information3
       ,p_abs_information4                 => l_absence_rec.abs_information4
       ,p_abs_information5                 => l_absence_rec.abs_information5
       ,p_abs_information6                 => l_absence_rec.abs_information6
       ,p_abs_information7                 => l_absence_rec.abs_information7
       ,p_abs_information8                 => l_absence_rec.abs_information8
       ,p_abs_information9                 => l_absence_rec.abs_information9
       ,p_abs_information10                => l_absence_rec.abs_information10
       ,p_abs_information11                => l_absence_rec.abs_information11
       ,p_abs_information12                => l_absence_rec.abs_information12
       ,p_abs_information13                => l_absence_rec.abs_information13
       ,p_abs_information14                => l_absence_rec.abs_information14
       ,p_abs_information15                => l_absence_rec.abs_information15
       ,p_abs_information16                => l_absence_rec.abs_information16
       ,p_abs_information17                => l_absence_rec.abs_information17
       ,p_abs_information18                => l_absence_rec.abs_information18
       ,p_abs_information19                => l_absence_rec.abs_information19
       ,p_abs_information20                => l_absence_rec.abs_information20
       ,p_abs_information21                => l_absence_rec.abs_information21
       ,p_abs_information22                => l_absence_rec.abs_information22
       ,p_abs_information23                => l_absence_rec.abs_information23
       ,p_abs_information24                => l_absence_rec.abs_information24
       ,p_abs_information25                => l_absence_rec.abs_information25
       ,p_abs_information26                => l_absence_rec.abs_information26
       ,p_abs_information27                => l_absence_rec.abs_information27
       ,p_abs_information28                => l_absence_rec.abs_information28
       ,p_abs_information29                => l_absence_rec.abs_information29
       ,p_abs_information30                => l_absence_rec.abs_information30
       ,p_object_version_number      => l_object_version_number
       ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
       ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
       ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
       ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
       ,p_abs_overlap_warning        => lb_abs_overlap_warning
       ,p_abs_day_after_warning      => lb_abs_day_after_warning
       ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
       ,p_del_element_entry_warning  => lb_del_element_entry_warning
      );

    elsif l_activity_name = 'HrLoaUpdate' then
      hr_utility.set_location(l_proc, 40);

      get_upd_from_tt
        (p_transaction_step_id => p_transaction_step_id
        ,p_absence_rec         => l_absence_rec);

      l_absence_days := l_absence_rec.absence_days ;
      l_absence_hours := l_absence_rec.absence_hours ;
      l_object_version_number := l_absence_rec.object_version_number;

      --2966372 changes start
      l_populate_sickness_dates := is_gb_leg_and_category_s(l_absence_rec.absence_attendance_type_id
                                                , l_absence_rec.business_group_id);

      IF l_populate_sickness_dates THEN
         l_sickness_start_date := l_absence_rec.date_start;
         l_sickness_end_date := l_absence_rec.date_end;
      END IF;
      --2966372 changes end

      hr_person_absence_api.update_person_absence(
        p_validate                   => l_validate
       ,p_effective_date             => l_effective_date
       ,p_date_notification          => l_effective_date
--       ,p_business_group_id          => l_absence_rec.business_group_id
       ,p_absence_attendance_id      => l_absence_rec.absence_attendance_id
       ,p_date_projected_start       => l_absence_rec.date_projected_start
       ,p_time_projected_start       => l_absence_rec.time_projected_start
       ,p_date_projected_end         => l_absence_rec.date_projected_end
       ,p_time_projected_end         => l_absence_rec.time_projected_end
       ,p_date_start                 => null
       ,p_time_start                 => null
       ,p_date_end                   => null
       ,p_time_end                   => null
       ,p_absence_days               => l_absence_rec.absence_days
       ,p_absence_hours              => l_absence_rec.absence_hours
       ,p_replacement_person_id      => l_absence_rec.replacement_person_id
       ,p_attribute_category         => l_absence_rec.attribute_category
       ,p_attribute1                 => l_absence_rec.attribute1
       ,p_attribute2                 => l_absence_rec.attribute2
       ,p_attribute3                 => l_absence_rec.attribute3
       ,p_attribute4                 => l_absence_rec.attribute4
       ,p_attribute5                 => l_absence_rec.attribute5
       ,p_attribute6                 => l_absence_rec.attribute6
       ,p_attribute7                 => l_absence_rec.attribute7
       ,p_attribute8                 => l_absence_rec.attribute8
       ,p_attribute9                 => l_absence_rec.attribute9
       ,p_attribute10                => l_absence_rec.attribute10
       ,p_attribute11                => l_absence_rec.attribute11
       ,p_attribute12                => l_absence_rec.attribute12
       ,p_attribute13                => l_absence_rec.attribute13
       ,p_attribute14                => l_absence_rec.attribute14
       ,p_attribute15                => l_absence_rec.attribute15
       ,p_attribute16                => l_absence_rec.attribute16
       ,p_attribute17                => l_absence_rec.attribute17
       ,p_attribute18                => l_absence_rec.attribute18
       ,p_attribute19                => l_absence_rec.attribute19
       ,p_attribute20                => l_absence_rec.attribute20
       ,p_period_of_incapacity_id    => null
       ,p_ssp1_issued                => 'N'
       ,p_maternity_id               => null
       ,p_sickness_start_date        => l_sickness_start_date --2966372
       ,p_sickness_end_date          => l_sickness_end_date --2966372
       ,p_pregnancy_related_illness     => 'N'
       ,p_reason_for_notification_dela  => null
       ,p_accept_late_notification_fla  => 'N'
       ,p_linked_absence_id             => null
       ,p_abs_information_category         => l_absence_rec.abs_information_category
       ,p_abs_information1                 => l_absence_rec.abs_information1
       ,p_abs_information2                 => l_absence_rec.abs_information2
       ,p_abs_information3                 => l_absence_rec.abs_information3
       ,p_abs_information4                 => l_absence_rec.abs_information4
       ,p_abs_information5                 => l_absence_rec.abs_information5
       ,p_abs_information6                 => l_absence_rec.abs_information6
       ,p_abs_information7                 => l_absence_rec.abs_information7
       ,p_abs_information8                 => l_absence_rec.abs_information8
       ,p_abs_information9                 => l_absence_rec.abs_information9
       ,p_abs_information10                => l_absence_rec.abs_information10
       ,p_abs_information11                => l_absence_rec.abs_information11
       ,p_abs_information12                => l_absence_rec.abs_information12
       ,p_abs_information13                => l_absence_rec.abs_information13
       ,p_abs_information14                => l_absence_rec.abs_information14
       ,p_abs_information15                => l_absence_rec.abs_information15
       ,p_abs_information16                => l_absence_rec.abs_information16
       ,p_abs_information17                => l_absence_rec.abs_information17
       ,p_abs_information18                => l_absence_rec.abs_information18
       ,p_abs_information19                => l_absence_rec.abs_information19
       ,p_abs_information20                => l_absence_rec.abs_information20
       ,p_abs_information21                => l_absence_rec.abs_information21
       ,p_abs_information22                => l_absence_rec.abs_information22
       ,p_abs_information23                => l_absence_rec.abs_information23
       ,p_abs_information24                => l_absence_rec.abs_information24
       ,p_abs_information25                => l_absence_rec.abs_information25
       ,p_abs_information26                => l_absence_rec.abs_information26
       ,p_abs_information27                => l_absence_rec.abs_information27
       ,p_abs_information28                => l_absence_rec.abs_information28
       ,p_abs_information29                => l_absence_rec.abs_information29
       ,p_abs_information30                => l_absence_rec.abs_information30
       ,p_comments                   => l_absence_rec.comments --3232911
       ,p_object_version_number      => l_object_version_number
       ,p_dur_dys_less_warning       => lb_dur_dys_less_warning
       ,p_dur_hrs_less_warning       => lb_dur_hrs_less_warning
       ,p_exceeds_pto_entit_warning  => lb_exceeds_pto_entit_warning
       ,p_exceeds_run_total_warning  => lb_exceeds_run_total_warning
       ,p_abs_overlap_warning        => lb_abs_overlap_warning
       ,p_abs_day_after_warning      => lb_abs_day_after_warning
       ,p_dur_overwritten_warning    => lb_dur_overwritten_warning
       ,p_del_element_entry_warning     => lb_del_element_entry_warning
      );

  end if;
  -- Fix 2706099
  -- No error should be displayed for such warnings


  -- 2713296
  --if lb_abs_overlap_warning = true then
      --rollback to loa_process_api;
      --hr_utility.set_message(800, 'HR_LOA_ABSENCE_OVERLAP');
      --hr_utility.raise_error;
  --end if;
  -- 2713296

   hr_utility.set_location(' Leaving:' || l_proc,45);


  EXCEPTION
  WHEN OTHERS THEN
    rollback to loa_process_api;
    hr_utility.trace('Exception in .process_api:' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,555);

    raise ;
  end process_api;

  /*
  ||===========================================================================
  || PROCEDURE: get_abs_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will retrieve data from hr_api_transaction_values
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_abs_from_tt(
   p_transaction_step_id in  number
  ,p_absence_rec         out nocopy per_absence_attendances%rowtype
  ) is

  l_proc                 varchar2(72) := g_package||'get_abs_from_tt';
  --
  begin

  --hr_utility.set_location(' Entering:' || l_proc,5);

    p_absence_rec.business_group_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_business_group_id');
  --
    p_absence_rec.person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_person_id');
  --
    p_absence_rec.absence_attendance_type_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_absence_attendance_type_id');
  --
    p_absence_rec.abs_attendance_reason_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_abs_attendance_reason_id');
  --
    p_absence_rec.comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_comments');
  --
    p_absence_rec.date_notification:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_notification');
  --
    p_absence_rec.authorising_person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_authorising_person_id');
  --
    p_absence_rec.replacement_person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_replacement_person_id');
  --
    p_absence_rec.date_projected_start:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_start');
  --
    p_absence_rec.time_projected_start:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_start');
  --
    p_absence_rec.date_projected_end:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_end');
  --
    p_absence_rec.time_projected_end:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_end');
  --
    p_absence_rec.date_start:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_start');
  --
    p_absence_rec.time_start:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_start');
  --
    p_absence_rec.date_end:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_end');
  --
    p_absence_rec.time_end:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_end');
  --
    p_absence_rec.absence_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_absence_rec.absence_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_absence_rec.attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_absence_rec.attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --

    p_absence_rec.attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_absence_rec.attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_absence_rec.attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_absence_rec.attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_absence_rec.attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_absence_rec.attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_absence_rec.attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_absence_rec.attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_absence_rec.attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_absence_rec.attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_absence_rec.attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_absence_rec.attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_absence_rec.attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_absence_rec.attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_absence_rec.attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_absence_rec.attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_absence_rec.attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_absence_rec.attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_absence_rec.attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_absence_rec.abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_absence_rec.abs_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --

    p_absence_rec.abs_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_absence_rec.abs_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_absence_rec.abs_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_absence_rec.abs_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_absence_rec.abs_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_absence_rec.abs_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_absence_rec.abs_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_absence_rec.abs_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_absence_rec.abs_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_absence_rec.abs_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_absence_rec.abs_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_absence_rec.abs_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_absence_rec.abs_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_absence_rec.abs_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_absence_rec.abs_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_absence_rec.abs_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_absence_rec.abs_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_absence_rec.abs_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_absence_rec.abs_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_absence_rec.abs_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_absence_rec.abs_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_absence_rec.abs_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_absence_rec.abs_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_absence_rec.abs_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_absence_rec.abs_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_absence_rec.abs_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');

  --
    p_absence_rec.abs_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_absence_rec.abs_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_absence_rec.abs_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);


  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace ( 'Exception in .get_abs_from_tt: ' || SQLERRM );
  hr_utility.set_location(' Leaving:' || l_proc,15);

    raise ;
 end get_abs_from_tt;

  /*
  ||===========================================================================
  || PROCEDURE: get_rtn_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will retrieve data from hr_api_transaction_values
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_rtn_from_tt(
   p_transaction_step_id in  number
  ,p_absence_rec         out nocopy per_absence_attendances%rowtype
  ) is

  --
  l_proc                 varchar2(72) := g_package||'get_rtn_from_tt';
  --
  begin

  --
  hr_utility.set_location(' Entering:' || l_proc,5);

    p_absence_rec.person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_person_id');
  --
    p_absence_rec.absence_attendance_type_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_absence_attendance_type_id');
  --
    p_absence_rec.absence_attendance_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_attendance_id');
  --
    p_absence_rec.business_group_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_business_group_id');
  --
    p_absence_rec.object_version_number:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_object_version_number');
  --
    p_absence_rec.date_notification:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_notification');
  --
    p_absence_rec.date_start:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_start');
  --
    p_absence_rec.time_start:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_start');
  --
    p_absence_rec.date_end:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_end');
  --
    p_absence_rec.time_end:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_end');
  --
    p_absence_rec.absence_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_absence_rec.absence_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_absence_rec.replacement_person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_replacement_person_id');

  --
    p_absence_rec.comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_comments');

  --
    p_absence_rec.attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_absence_rec.attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --

    p_absence_rec.attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_absence_rec.attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_absence_rec.attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_absence_rec.attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_absence_rec.attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_absence_rec.attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_absence_rec.attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_absence_rec.attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_absence_rec.attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_absence_rec.attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_absence_rec.attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_absence_rec.attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_absence_rec.attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_absence_rec.attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_absence_rec.attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_absence_rec.attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_absence_rec.attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_absence_rec.attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_absence_rec.attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_absence_rec.abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_absence_rec.abs_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --

    p_absence_rec.abs_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_absence_rec.abs_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_absence_rec.abs_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_absence_rec.abs_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_absence_rec.abs_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_absence_rec.abs_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_absence_rec.abs_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_absence_rec.abs_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_absence_rec.abs_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_absence_rec.abs_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_absence_rec.abs_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_absence_rec.abs_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_absence_rec.abs_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_absence_rec.abs_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_absence_rec.abs_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_absence_rec.abs_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_absence_rec.abs_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_absence_rec.abs_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_absence_rec.abs_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_absence_rec.abs_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_absence_rec.abs_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_absence_rec.abs_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_absence_rec.abs_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_absence_rec.abs_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_absence_rec.abs_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_absence_rec.abs_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');

  --
    p_absence_rec.abs_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_absence_rec.abs_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_absence_rec.abs_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' get_rtn_from_tt: ' || SQLERRM );
  hr_utility.set_location(' Leaving:' || l_proc,555);

    raise ;
 end get_rtn_from_tt;

  /*
  ||===========================================================================
  || PROCEDURE: get_upd_from_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will retrieve data from hr_api_transaction_values
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure get_upd_from_tt(
   p_transaction_step_id in  number
  ,p_absence_rec         out nocopy per_absence_attendances%rowtype
  ) is

  --
  l_proc                 varchar2(72) := g_package||'get_upd_from_tt';
  --
  begin

hr_utility.set_location(' Entering:' || l_proc,5);

  --
    p_absence_rec.absence_attendance_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_attendance_id');
  --
    p_absence_rec.business_group_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_business_group_id');
  --
    p_absence_rec.object_version_number:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_object_version_number');
  --
    p_absence_rec.date_notification:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_notification');
  --
    p_absence_rec.date_projected_start:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_start');
  --
    p_absence_rec.time_projected_start:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_start');
  --
    p_absence_rec.date_projected_end:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_projected_end');
  --
    p_absence_rec.time_projected_end:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_projected_end');
  --
-- Fix 3400323 Start
  --
    p_absence_rec.date_start:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_start');
  --
    p_absence_rec.time_start:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_start');
  --
    p_absence_rec.date_end:=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_date_end');
  --
    p_absence_rec.time_end:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_time_end');
--
-- Fix 3400323 End
    p_absence_rec.absence_days:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_days');
  --
    p_absence_rec.absence_hours:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_absence_hours');
  --
    p_absence_rec.replacement_person_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'p_replacement_person_id');

  --
    p_absence_rec.comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_comments');

  --
    p_absence_rec.attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute_category');
  --
    p_absence_rec.attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute1');
  --

    p_absence_rec.attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute2');
  --
    p_absence_rec.attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute3');
  --
    p_absence_rec.attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute4');
  --
    p_absence_rec.attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute5');
  --
    p_absence_rec.attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute6');
  --
    p_absence_rec.attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute7');
  --
    p_absence_rec.attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute8');
  --
    p_absence_rec.attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute9');
  --
    p_absence_rec.attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute10');
  --
    p_absence_rec.attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute11');
  --
    p_absence_rec.attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute12');
  --
    p_absence_rec.attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute13');
  --
    p_absence_rec.attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute14');
  --
    p_absence_rec.attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute15');
  --
    p_absence_rec.attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute16');
  --
    p_absence_rec.attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute17');
  --
    p_absence_rec.attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute18');
  --
    p_absence_rec.attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute19');
  --
    p_absence_rec.attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_attribute20');
  --
    p_absence_rec.abs_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information_category');
  --
    p_absence_rec.abs_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information1');
  --

    p_absence_rec.abs_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information2');
  --
    p_absence_rec.abs_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information3');
  --
    p_absence_rec.abs_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information4');
  --
    p_absence_rec.abs_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information5');
  --
    p_absence_rec.abs_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information6');
  --
    p_absence_rec.abs_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information7');
  --
    p_absence_rec.abs_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information8');
  --
    p_absence_rec.abs_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information9');
  --
    p_absence_rec.abs_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information10');
  --
    p_absence_rec.abs_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information11');
  --
    p_absence_rec.abs_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information12');
  --
    p_absence_rec.abs_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information13');
  --
    p_absence_rec.abs_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information14');
  --
    p_absence_rec.abs_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information15');
  --
    p_absence_rec.abs_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information16');
  --
    p_absence_rec.abs_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information17');
  --
    p_absence_rec.abs_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information18');
  --
    p_absence_rec.abs_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information19');
  --
    p_absence_rec.abs_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information20');
  --
    p_absence_rec.abs_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information21');
  --
    p_absence_rec.abs_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information22');
  --
    p_absence_rec.abs_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information23');
  --
    p_absence_rec.abs_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information24');
  --
    p_absence_rec.abs_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information25');
  --
    p_absence_rec.abs_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information26');
  --
    p_absence_rec.abs_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information27');

  --
    p_absence_rec.abs_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information28');
  --
    p_absence_rec.abs_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information29');
  --
    p_absence_rec.abs_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'p_abs_information30');
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' .get_upd_from_tt: ' || SQLERRM );
  hr_utility.set_location(' Leaving:' || l_proc,555);

    raise ;
 end get_upd_from_tt;

--
--  +-------------------------------------------------------------------------+
--  |-----------------<      good_time_format       >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Tests CHAR values for valid time.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_time VARCHAR2
--
--  Out Arguments:
--    BOOLEAN
--
--  Post Success:
--    Returns TRUE or FALSE depending on valid time or not.
--
--  Post Failure:
--    Returns FALSE for invalid time.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN IS
--
BEGIN
  --
  IF p_time IS NOT NULL THEN
    --
    IF NOT (SUBSTR(p_time,1,2) BETWEEN '00' AND '23' AND
            SUBSTR(p_time,4,2) BETWEEN '00' AND '59' AND
            SUBSTR(p_time,3,1) = ':' AND
            LENGTH(p_time) = 5) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    --
  ELSE
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    RETURN FALSE;
  --
END good_time_format;
--
--  +-------------------------------------------------------------------------+
--  |-----------------<     calc_sch_based_dur      >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Calculate the absence duration in hours/days based on the work schedule.
--  This is a copy of the procedure PER_ABS_BUS.calc_sch_based_dur.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_days_or_hours VARCHAR2
--    p_date_start    DATE
--    p_date_end      DATE
--    p_time_start    VARCHAR2
--    p_time_end      VARCHAR2
--    p_assignment_id NUMBER
--
--  Out Arguments:
--    p_duration NUMBER
--
--  Post Success:
--    Value returned for absence duration.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE calc_sch_based_dur ( p_days_or_hours IN VARCHAR2,
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_assignment_id IN NUMBER,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) IS
  --
  l_idx             NUMBER;
  l_ref_date        DATE;
  l_first_band      BOOLEAN;
  l_day_start_time  VARCHAR2(5);
  l_day_end_time    VARCHAR2(5);
  l_start_time      VARCHAR2(5);
  l_end_time        VARCHAR2(5);
  --
  l_start_date      DATE;
  l_end_date        DATE;
  l_schedule        cac_avlblty_time_varray;
  l_schedule_source VARCHAR2(10);
  l_return_status   VARCHAR2(1);
  l_return_message  VARCHAR2(2000);
  --
  l_time_start      VARCHAR2(5);
  l_time_end        VARCHAR2(5);
  --
  e_bad_time_format EXCEPTION;
  --
BEGIN
  hr_utility.set_location('Entering '||g_package||'.calc_sch_based_dur',10);
  p_duration := 0;
  l_time_start := p_time_start;
  l_time_end := p_time_end;
  --
  IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    IF NOT good_time_format(l_time_start) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  -- fix for the bug 8668042
   IF l_time_end IS NULL THEN

   IF p_days_or_hours = 'D' THEN
      l_time_end := '00:00';
   ELSE
      l_time_end := '23:59';
   END IF;

  ELSE
    IF NOT good_time_format(l_time_end) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  --fix for the bug 8668042

  l_start_date := TO_DATE(TO_CHAR(p_date_start,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
  l_end_date := TO_DATE(TO_CHAR(p_date_end,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
  IF p_days_or_hours = 'D' THEN
    l_end_date := l_end_date + 1;
  END IF;
  --
  -- Fetch the work schedule
  --
  hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => p_assignment_id
  , p_period_start_date    => l_start_date
  , p_period_end_date      => l_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
  --
  IF l_return_status = '0' THEN
    --
    -- Calculate duration
    --
    l_idx := l_schedule.first;
    --
    IF p_days_or_hours = 'D' THEN
      --
      l_first_band := TRUE;
      l_ref_date := NULL;
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_first_band THEN
              l_first_band := FALSE;
              l_ref_date := TRUNC(l_schedule(l_idx).START_DATE_TIME);
              IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
              ELSE
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              END IF;
            ELSE -- not first time
              IF TRUNC(l_schedule(l_idx).START_DATE_TIME) = l_ref_date THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              ELSE
                l_ref_date := TRUNC(l_schedule(l_idx).END_DATE_TIME);
                IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
                ELSE
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      --
    ELSE -- p_days_or_hours is 'H'
      --
      l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_schedule(l_idx).END_DATE_TIME < l_schedule(l_idx).START_DATE_TIME THEN
              -- Skip this invalid slot which ends before it starts
              NULL;
            ELSE
              IF TRUNC(l_schedule(l_idx).END_DATE_TIME) > TRUNC(l_schedule(l_idx).START_DATE_TIME) THEN
                -- Start and End on different days
                --
                -- Get first day hours
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_day_end_time,1,2)*60 + SUBSTR(l_day_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get last day hours
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_day_start_time,1,2)*60 + SUBSTR(l_day_start_time,4,2)) + 1)/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get between full day hours
                SELECT p_duration + ((TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) - 1) * 24)
                INTO p_duration
                FROM DUAL;
              ELSE
                -- Start and End on same day
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      p_duration := ROUND(p_duration,2);
      --
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
  --
END calc_sch_based_dur;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration  (OLD)>--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure calculate_absence_duration
 (
--p_absence_attendance_id      in  number
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
-- ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy number
 ,p_min_max_failure  	       out nocopy varchar2
 ,p_warning_or_error           out nocopy varchar2
 ,p_page_error_msg         out nocopy varchar2 --2695922
)
  is

  l_proc                 varchar2(72) := g_package||
                                        'calculate_absence_duration';
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_assignment_id        number;
  l_hours_or_days        varchar2(1);
  l_element_type_id      number;
  l_legislation_code     varchar2(150);
  l_formula_id           number;
  l_inputs               ff_exec.inputs_t;
  l_outputs              ff_exec.outputs_t;
  l_user_message         varchar2(1) := 'N';
  l_invalid_message      fnd_new_messages.message_text%TYPE;
  l_custom_exception     exception;  --2695922
  wrong_parameters       exception;
  l_normal_time_start    varchar2(5);
  l_normal_time_end      varchar2(5);
  l_normal_day_minutes   number;
  l_first_day_minutes    number;
  l_last_day_minutes     number;
  l_same_day_minutes     number;
  l_absence_days         number;
  l_absence_hours        number;
  l_use_formula          number;
  l_max_value            varchar2(60);
  l_min_value            varchar2(60);
  l_min_max_failure  	 varchar2(1) := null;  -- S:Success F:failure
  l_warning_or_error     varchar2(1) := null;
  l_screen_format        varchar2(100);
  l_element_link_id      number;
  l_input_value_id       number;

  --
  -- Bug 4534572 START
  --
  l_sch_based_dur        VARCHAR2(1);
  l_sch_based_dur_found  BOOLEAN;
  l_absence_duration     NUMBER;
  --
  -- Bug 4534572 END
  --

  cursor c_get_absence_info is
  select abt.hours_or_days
        ,piv.element_type_id
        ,piv.input_value_id
        ,piv.max_value        		-- WWBUG #2602856
        ,piv.min_value        		-- WWBUG #2602856
        ,pet.element_link_id        	-- WWBUG #2602856
  from   per_absence_attendance_types abt
        ,pay_input_values_f piv
        ,pay_element_links_f pet
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.input_value_id = piv.input_value_id(+)
  and    piv.element_type_id = pet.element_type_id(+)
  -- bug 5295672
  and p_effective_date between piv.effective_start_date
                               and piv.effective_end_date
       and  p_effective_date between pet.effective_start_date
                               and pet.effective_end_date;
-- bug 5295672
  cursor c_get_normal_hours (p_assignment_id in number) is
  select nvl(nvl(asg.time_normal_start, pbg.default_start_time), '00:00'),
         nvl(nvl(asg.time_normal_finish, pbg.default_end_time), '23:59')
  FROM   per_all_assignments_f asg,
         per_business_groups pbg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = pbg.business_group_id
  AND    p_effective_date between asg.effective_start_date
                          and     asg.effective_end_date;

--
begin

 hr_utility.set_location('Entering:'|| l_proc, 10);

 HR_LOA_SS.calculate_absence_duration
  (p_absence_attendance_type_id    => p_absence_attendance_type_id
  ,p_business_group_id             => p_business_group_id
  ,p_effective_date                => p_effective_date
  ,p_person_id                     => p_person_id
  ,p_date_start                    => p_date_start
  ,p_date_end                      => p_date_end
  ,p_time_start                    => p_time_start
  ,p_time_end                      => p_time_end
  ,p_abs_information_category      => NULL
  ,p_abs_information1             => NULL
  ,p_abs_information2             => NULL
  ,p_abs_information3             => NULL
  ,p_abs_information4             => NULL
  ,p_abs_information5             => NULL
  ,p_abs_information6             => NULL
  ,p_absence_days                  => p_absence_days
  ,p_absence_hours                 => p_absence_hours
  ,p_use_formula                   => p_use_formula
  ,p_min_max_failure               => p_min_max_failure
  ,p_warning_or_error              => p_warning_or_error
  ,p_page_error_msg                => p_page_error_msg
  );
  /*
  p_absence_days      :=	l_absence_days  ;
  p_absence_hours     :=	l_absence_hours  ;
  p_use_formula       :=	l_use_formula  ;
  p_min_max_failure   :=	l_min_max_failure ;
  p_warning_or_error  :=	l_warning_or_error ;
  p_page_error_msg    :=	l_invalid_message ;
  */

   hr_utility.set_location('Leaving:'|| l_proc, 20);

EXCEPTION
--2695922
   WHEN l_custom_exception THEN
hr_utility.set_location(' Leaving:'|| l_proc, 555);
    p_page_error_msg := l_invalid_message;
--2695922
   WHEN wrong_parameters then
    --
    -- The inputs / outputs of the Fast Formula are incorrect
    -- so raise an error.
    --
   hr_utility.set_location(' Leaving:'|| l_proc, 560);

    hr_utility.set_message(800,'HR_34964_BAD_FF_DEFINITION');
    hr_utility.raise_error;

   --3001784
   WHEN others THEN
   hr_utility.set_location(' Leaving:'|| l_proc, 565);
     p_page_error_msg := hr_utility.get_message;
   --3001784

end calculate_absence_duration;

--  New calculate_absence_duration with additional parameters
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--    p_abs_information_category
--    p_abs_information1
--    p_abs_information2
--    p_abs_information3
--    p_abs_information4
--    p_abs_information5
--    p_abs_information6
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure calculate_absence_duration
 (
--p_absence_attendance_id      in  number
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
-- ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_abs_information_category   in varchar2
 ,p_abs_information1          in varchar2
 ,p_abs_information2          in varchar2
 ,p_abs_information3          in varchar2
 ,p_abs_information4          in varchar2
 ,p_abs_information5          in varchar2
 ,p_abs_information6          in varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy number
 ,p_min_max_failure  	       out nocopy varchar2
 ,p_warning_or_error           out nocopy varchar2
 ,p_page_error_msg         out nocopy varchar2 --2695922
)
  is

  l_proc                 varchar2(72) := g_package||
                                        'calculate_absence_duration';
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_assignment_id        number;
  l_hours_or_days        varchar2(1);
  l_element_type_id      number;
  l_legislation_code     varchar2(150);
  l_formula_id           number;
  l_inputs               ff_exec.inputs_t;
  l_outputs              ff_exec.outputs_t;
  l_user_message         varchar2(1) := 'N';
  l_invalid_message      fnd_new_messages.message_text%TYPE;
  l_custom_exception     exception;  --2695922
  wrong_parameters       exception;
  l_normal_time_start    varchar2(5);
  l_normal_time_end      varchar2(5);
  l_normal_day_minutes   number;
  l_first_day_minutes    number;
  l_last_day_minutes     number;
  l_same_day_minutes     number;
  l_absence_days         number;
  l_absence_hours        number;
  l_use_formula          boolean;
  l_max_value            varchar2(60);
  l_min_value            varchar2(60);
  l_min_max_failure  	 varchar2(1) := null;  -- S:Success F:failure
  l_warning_or_error     varchar2(1) := null;
  l_screen_format        varchar2(100);
  l_element_link_id      number;
  l_input_value_id       number;

  --
  -- Bug 4534572 START
  --
  l_sch_based_dur        VARCHAR2(1);
  l_sch_based_dur_found  BOOLEAN;
  l_absence_duration     NUMBER;
  --
  -- Bug 4534572 END
  --

  cursor c_get_absence_info is
  select abt.hours_or_days
        ,piv.element_type_id
        ,piv.input_value_id
        ,piv.max_value        		-- WWBUG #2602856
        ,piv.min_value        		-- WWBUG #2602856
        ,pet.element_link_id        	-- WWBUG #2602856
  from   per_absence_attendance_types abt
        ,pay_input_values_f piv
        ,pay_element_links_f pet
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.input_value_id = piv.input_value_id(+)
  and    piv.element_type_id = pet.element_type_id(+)
  -- bug 5295672
  and p_effective_date between piv.effective_start_date
                               and piv.effective_end_date
       and  p_effective_date between pet.effective_start_date
                               and pet.effective_end_date;
-- bug 5295672
  cursor c_get_normal_hours (p_assignment_id in number) is
  select nvl(nvl(asg.time_normal_start, pbg.default_start_time), '00:00'),
         nvl(nvl(asg.time_normal_finish, pbg.default_end_time), '23:59')
  FROM   per_all_assignments_f asg,
         per_business_groups pbg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = pbg.business_group_id
  AND    p_effective_date between asg.effective_start_date
                          and     asg.effective_end_date;

--
begin

 hr_utility.set_location('Entering:'|| l_proc, 10);

/*
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
 = nvl(p_date_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_start, hr_api.g_varchar2)
    = nvl(p_time_start, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.time_end, hr_api.g_varchar2)
    = nvl(p_time_end, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.absence_days, hr_api.g_number)
    = nvl(p_absence_days, hr_api.g_number)
  and nvl(per_abs_shd.g_old_rec.absence_hours, hr_api.g_number)
    = nvl(p_absence_hours, hr_api.g_number)) then
     return;
  end if;

*/

  per_abs_bus.chk_time_format (p_time => p_time_start);
  per_abs_bus.chk_time_format (p_time => p_time_end);

  hr_utility.set_location(l_proc, 15);

  --
  -- See if a Fast Formula exists. Here the Fast Formula names
  -- are hard-coded. Fast Formulas with these exact names can
  -- be defined at one of three levels to default the absence
  -- duration:
  --
  --  1. Business group (customer-definable)
  --  2. Legislation (Oracle internal legislation-specific)
  --  3. Core (Oracle internal core product)
  --

  --
  -- Get the varous additional values that are required for use later.
  --

  l_assignment_id := hr_person_absence_api.get_primary_assignment
      (p_person_id         => p_person_id
      ,p_effective_date    => p_effective_date);

  l_legislation_code := hr_api.return_legislation_code
      (p_business_group_id => p_business_group_id);

  open  c_get_absence_info;
  fetch c_get_absence_info into l_hours_or_days,
                                l_element_type_id,
                                l_input_value_id,
                                l_max_value,
                                l_min_value,
                                l_element_link_id;
  close c_get_absence_info;

  --
  -- Bug 4534572 START
  --
  l_sch_based_dur := NVL(FND_PROFILE.Value('HR_SCH_BASED_ABS_CALC'),'N');
  l_sch_based_dur_found := FALSE;
  --
  IF l_sch_based_dur = 'Y' THEN
    --
    hr_utility.set_location(l_proc, 16);
    p_use_formula := hr_java_conv_util_ss.get_number(p_boolean => TRUE);
    --
    calc_sch_based_dur (p_days_or_hours => l_hours_or_days,
                        p_date_start    => p_date_start,
                        p_date_end      => p_date_end,
                        p_time_start    => p_time_start,
                        p_time_end      => p_time_end,
                        p_assignment_id => l_assignment_id,
                        p_duration      => l_absence_duration
                       );
    --
    IF l_absence_duration IS NOT NULL THEN
      --
      l_sch_based_dur_found := TRUE;
      --
      IF l_hours_or_days = 'H' THEN
        hr_utility.set_location(l_proc, 17);
        p_absence_hours := l_absence_duration;
      ELSIF l_hours_or_days = 'D' THEN
        hr_utility.set_location(l_proc, 18);
        p_absence_days := l_absence_duration;
      ELSE
        hr_utility.set_location(l_proc, 19);
        l_sch_based_dur_found := FALSE;
      END IF;
      --
    END IF;
    --
  END IF; -- sch_based_dur is 'Y'
  --
  IF l_sch_based_dur <> 'Y' OR (l_sch_based_dur = 'Y' AND NOT l_sch_based_dur_found) THEN
  --
  -- Bug 4534572 END
  --

  hr_utility.set_location(l_proc, 20);

  begin
    --
    -- Look for a customer-defined formula
    --
    select ff.formula_id
    into   l_formula_id
    from   ff_formulas_f ff
    where  ff.formula_name = 'BG_ABSENCE_DURATION'
    and    ff.business_group_id = p_business_group_id
    and    p_effective_date between ff.effective_start_date and
                                    ff.effective_end_date;
  exception

    when no_data_found then
      --
      -- There is no customer defined formula so look for
      -- a legislative formula.
      --
      begin

        hr_utility.set_location(l_proc, 25);

        select ff.formula_id
        into   l_formula_id
        from   ff_formulas_f ff
        where  ff.formula_name = 'LEGISLATION_ABSENCE_DURATION'
        and    ff.legislation_code = l_legislation_code
        and    ff.business_group_id is null
        and    p_effective_date between ff.effective_start_date and
                                        ff.effective_end_date;

      exception

        when no_data_found then
          --
--
          -- If none of the two above then select the core formula
          --
          begin

            hr_utility.set_location(l_proc, 30);

            select ff.formula_id
            into   l_formula_id
            from   ff_formulas_f ff
            where  ff.formula_name = 'CORE_ABSENCE_DURATION'
            and    ff.legislation_code is null
            and    ff.business_group_id is null
            and    p_effective_date between ff.effective_start_date and
                                            ff.effective_end_date;

          exception

            when no_data_found then
              --
              -- No formula is found. We capture the error and do nothing.
              --
              null;

          end;
      end;
  end;

  hr_utility.set_location(l_proc, 35);

  if l_formula_id is not null then
    --
    -- An absence duration Fast Formula should be used so the
    -- formula is called. First, the formula is initialised.
    --
    l_use_formula := TRUE;

    hr_utility.set_location(l_proc, 40);

    --
    -- Initalise the formula.
    --
    ff_exec.init_formula
      (p_formula_id     => l_formula_id
      ,p_effective_date => p_effective_date
      ,p_inputs         => l_inputs
      ,p_outputs        => l_outputs);

    hr_utility.set_location(l_proc, 45);

    --
    -- Assign the inputs.
    --
    for i_input in l_inputs.first..l_inputs.last
    loop

      if l_inputs(i_input).name    = 'DAYS_OR_HOURS' then
         l_inputs(i_input).value  := l_hours_or_days;
      elsif l_inputs(i_input).name = 'DATE_START' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical(p_date_start);
      elsif l_inputs(i_input).name = 'DATE_END' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical(p_date_end);
      elsif l_inputs(i_input).name = 'TIME_START' then
         l_inputs(i_input).value  := p_time_start;
      elsif l_inputs(i_input).name = 'TIME_END' then
         l_inputs(i_input).value  := p_time_end;
      elsif l_inputs(i_input).name = 'DATE_EARNED' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical
                                     (p_effective_date);
      elsif l_inputs(i_input).name = 'BUSINESS_GROUP_ID' then
         l_inputs(i_input).value  := p_business_group_id;
      elsif l_inputs(i_input).name = 'LEGISLATION_CODE' then
         l_inputs(i_input).value  := l_legislation_code;
      elsif l_inputs(i_input).name = 'ASSIGNMENT_ID' then
         l_inputs(i_input).value  := l_assignment_id;
      elsif l_inputs(i_input).name = 'ELEMENT_TYPE_ID' then
         l_inputs(i_input).value  := l_element_type_id;
      elsif l_inputs(i_input).name = 'ABSENCE_ATTENDANCE_TYPE_ID' then
         l_inputs(i_input).value  := p_absence_attendance_type_id;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION_CATEGORY' then
         l_inputs(i_input).value  := p_ABS_INFORMATION_CATEGORY;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION1' then
         l_inputs(i_input).value  := p_ABS_INFORMATION1;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION2' then
         l_inputs(i_input).value  := p_ABS_INFORMATION2;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION3' then
         l_inputs(i_input).value  := p_ABS_INFORMATION3;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION4' then
         l_inputs(i_input).value  := p_ABS_INFORMATION4;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION5' then
         l_inputs(i_input).value  := p_ABS_INFORMATION5;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION6' then
         l_inputs(i_input).value  := p_ABS_INFORMATION6;
      else
         raise wrong_parameters;
      end if;

    end loop;

    hr_utility.set_location(l_proc, 50);

    --
    -- Run the formula.
    --
    ff_exec.run_formula(l_inputs, l_outputs);

    hr_utility.set_location(l_proc, 55);

    --
    -- Assign the outputs.
    --
    for i_output in l_outputs.first..l_outputs.last
    loop

      if l_outputs(i_output).name = 'DURATION' then

        if l_outputs(i_output).value = 'FAILED' then
          l_user_message := 'Y';
        else
          --
          -- The absence hours / days out parameter is set. If no UOM
          -- is set but the start or end time have been entered, the output
          -- is returned in hours.
          --
          if l_hours_or_days = 'H'
          or (p_time_start is not null and p_time_end is not null) then
            p_absence_hours := round(to_number(l_outputs(i_output).value),2);
            l_screen_format := to_char(p_absence_hours); -- WWBUG #2602856
          else
            p_absence_days := round(to_number(l_outputs(i_output).value),2);
            l_screen_format := to_char(p_absence_days); -- WWBUG #2602856
          end if;
        end if;
     elsif l_outputs(i_output).name = 'INVALID_MSG' then

       --    Here we do not plan to use p_invalid_message as error
       --    messages during this formula will be raised during the
       --    API.

           l_invalid_message := l_outputs(i_output).value;

        null;
      else
        raise wrong_parameters;
      end if;

    end loop;

    hr_utility.set_location(l_proc, 60);
    hr_utility.trace('l_user_message: '||l_user_message);
    hr_utility.trace('l_invalid_message: '||l_invalid_message);

    --
    -- If the Fast Formula raises a user-defined error message,
    -- raise the error back to the user. Here the message is
    -- truncated to 30 characters because that is the limit
    -- in the calling program.
    --

    if l_user_message = 'Y' then
      raise l_custom_exception; --2695922
      --hr_utility.set_message(800, substr(l_invalid_message, 1, 30));
      --hr_utility.raise_error;
    end if;

  else
    --
    -- No formula could be located so we calculate based on the
    -- standard hours of the assignment or business group.
    --
    l_use_formula := FALSE;

    hr_utility.set_location(l_proc, 65);

    --
    -- Get the default start and end times. First check the assignment, then
    -- the business group. If neither of these, assume 24 hours a day.
    --
    open  c_get_normal_hours (l_assignment_id);
    fetch c_get_normal_hours into l_normal_time_start,
                                  l_normal_time_end;
    close c_get_normal_hours;

    hr_utility.set_location(l_proc, 70);

    --
    -- Calculate the number of minutes in each day.
    --
    -- 3191259 changes start
    l_normal_day_minutes := per_abs_bus.convert_to_minutes(l_normal_time_start,
                                            l_normal_time_end);
    l_first_day_minutes := per_abs_bus.convert_to_minutes(nvl(p_time_start,
                                               l_normal_time_start),
                                               l_normal_time_end);
    l_last_day_minutes := per_abs_bus.convert_to_minutes(l_normal_time_start,
                                             nvl(p_time_end,
                                              l_normal_time_end));

    if l_first_day_minutes <= 0 OR l_first_day_minutes > l_normal_day_minutes
       OR l_last_day_minutes <= 0 OR l_last_day_minutes > l_normal_day_minutes  THEN
       --
       -- The leave timings are out off the standard timings.
       -- So use 24 hours rule to calculate the first day and last day minutes.
       --
       hr_utility.set_location(l_proc, 72);
       l_first_day_minutes := per_abs_bus.convert_to_minutes(nvl(p_time_start,
                                                 l_normal_time_start),
                                                '24:00');
       l_last_day_minutes := per_abs_bus.convert_to_minutes('00:00', nvl(p_time_end,
                                              l_normal_time_end));
    end if;

    -- 3191259 changes end

    --3323744 change starts
    l_same_day_minutes := per_abs_bus.convert_to_minutes(nvl(p_time_start,
                                              l_normal_time_start),
                                          nvl(p_time_end,
                                              l_normal_time_end));
    --3323744 change ends

    --2943479 changes start
    if l_normal_time_end = '23:59'
    then
       l_normal_day_minutes := l_normal_day_minutes +1;
       l_first_day_minutes := l_first_day_minutes +1;
       --3075512 changes start
       if (p_time_end is null or p_time_end = '') then
         l_last_day_minutes := l_last_day_minutes +1;
         l_same_day_minutes := l_same_day_minutes +1;
       end if;
       --3075512 changes end
    end if;
    --2943479 changes end

    hr_utility.trace('Normal Day Minutes: ' || to_char(l_normal_day_minutes));
    hr_utility.trace('First Day Minutes: ' || to_char(l_first_day_minutes));
    hr_utility.trace('Last Day Minutes: ' || to_char(l_last_day_minutes));
    hr_utility.trace('Same Day Minutes: ' || to_char(l_same_day_minutes));

    hr_utility.set_location(l_proc, 75);

    --
    -- Calculate the absence days.
    --
    l_absence_days := (p_date_end - p_date_start) + 1;

    hr_utility.trace('Absence Days: ' || to_char(l_absence_days));

    --
    -- Calculate the absence hours.
    --
    if l_absence_days = 1 then
      --
      -- The absence starts and ends on the same day.
      --
      l_absence_hours := l_same_day_minutes / 60;

    elsif l_absence_days = 2 then
      --
      -- The absence ends the day after another.
      --
      l_absence_hours := (l_first_day_minutes + l_last_day_minutes) / 60;

    else
      --
      -- The absence is n number of days.
      --
      l_absence_hours := (l_first_day_minutes + l_last_day_minutes +
                          ((l_absence_days - 2) * l_normal_day_minutes)) / 60;

    end if;

    hr_utility.set_location(l_proc, 80);

    --
    -- Check that the absence hours are not less than zero. This could
    -- happen if the entered start time is after the normal start time or
    -- the entered end time is after the normal end time.
    --
    If l_absence_hours < 0 then
      l_absence_hours := 0;
    end if;

    --
    -- Set the absence days and hours out parameters.
    --
    if l_hours_or_days = 'H' then
      p_absence_hours := round(l_absence_hours,2);
      l_screen_format := to_char(p_absence_hours); -- WWBUG #2602856

    elsif l_hours_or_days = 'D' then
      p_absence_days := round(l_absence_days,2);
      l_screen_format := to_char(p_absence_days); -- WWBUG #2602856

    else
      p_absence_hours := round(l_absence_hours,2);
      p_absence_days := round(l_absence_days,2);

    end if;

  end if;

  hr_utility.set_location(l_proc, 90);
  --
  -- Check min/max value in input_value for element.(WWBUG #2602856)
  --
  hr_utility.trace('l_element_link_id is '|| l_element_link_id);
  hr_utility.trace('l_input_value_id is  '|| l_input_value_id);
  hr_utility.trace('p_effective_date is  '|| p_effective_date);
  hr_utility.trace('l_screen_format is   '|| l_screen_format);

  if l_element_link_id is not null and l_input_value_id is not null then

    hr_entry.check_format
       (l_element_link_id,
        l_input_value_id,
        p_effective_date,
        l_screen_format,
        l_screen_format,
        'Y',
        l_min_max_failure,
        l_warning_or_error,
        l_min_value,
        l_max_value);

  hr_utility.trace('l_min_max_failure is  '|| l_min_max_failure);
  hr_utility.trace('l_warning_or_error is '|| l_warning_or_error);
  hr_utility.trace('l_min_value is        '|| l_min_value);
  hr_utility.trace('l_max_value is        '|| l_max_value);

  else --3403256 changes start
    -- set absence_hrs to null if absence is not linked with an
    -- element and time values are not entered by user
    if l_element_link_id is null  and
    (p_time_start is null or p_time_start = '') and
    (p_time_end is null or p_time_end = '')
    then
       p_absence_hours := null;
    end if; --3403256 changes end

  end if;
  p_min_max_failure := l_min_max_failure;
  p_warning_or_error := l_warning_or_error;

  hr_utility.set_location(l_proc, 100);
/*
  if l_min_max_failure = 'F' and l_warning_or_error = 'E' then
       hr_utility.set_message(800, 'PER_6303_INPUT_VALUE_OUT_RANGE');
       hr_utility.raise_error;
     end if;
     --
     -- if the warning_or_error flag has been set to 'Error' then only Warn
     -- but let the processing continue
     --
      if l_min_max_failure = 'F' and l_warning_or_error = 'W' then
        hr_utility.set_message(800, 'PER_6303_INPUT_VALUE_OUT_RANGE');
        hr_utility.set_warning;
      end if;

*/
  p_use_formula := hr_java_conv_util_ss.get_number(p_boolean => l_use_formula);

  --
  -- Bug 4534572 START
  --
  END IF; -- Schedule based calculation not used
  --
  -- Bug 4534572 END
  --

  hr_utility.set_location(' Leaving:'|| l_proc, 110);

EXCEPTION
--2695922
   WHEN l_custom_exception THEN
hr_utility.set_location(' Leaving:'|| l_proc, 555);
    p_page_error_msg := l_invalid_message;
--2695922
   WHEN wrong_parameters then
    --
    -- The inputs / outputs of the Fast Formula are incorrect
    -- so raise an error.
    --
   hr_utility.set_location(' Leaving:'|| l_proc, 560);

    hr_utility.set_message(800,'HR_34964_BAD_FF_DEFINITION');
    hr_utility.raise_error;

   --3001784
   WHEN others THEN
   hr_utility.set_location(' Leaving:'|| l_proc, 565);
     p_page_error_msg := hr_utility.get_message;
   --3001784

end calculate_absence_duration;

  /*
  ||===========================================================================
  || PROCEDURE: delete_absenc
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will delete absence record from
  ||     per_absence_attendances
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  procedure delete_absence(
   p_absence_attendance_id         IN NUMBER
   ,p_page_error_msg         OUT NOCOPY VARCHAR2 --2782075
  ) is

  l_proc              varchar2(30)  :=  g_package||'delete_absence';
  l_ovn               number;
  --
  cursor csr_get_ovn_abs_attendances is
       select object_version_number
         from per_absence_attendances paa
         where paa.absence_attendance_id = p_absence_attendance_id ;
  --
  BEGIN

  hr_utility.set_location(' Entering:' || l_proc,5);


  open csr_get_ovn_abs_attendances;
  fetch csr_get_ovn_abs_attendances into l_ovn;
  if  csr_get_ovn_abs_attendances%notfound then
  hr_utility.set_location(l_proc,10);

     close csr_get_ovn_abs_attendances;
     hr_utility.set_location('api error exists', 10);
     raise g_data_error;
  end if;


 -- Call the actual API.
        hr_person_absence_api.delete_person_absence
        (
            p_absence_attendance_id         => p_absence_attendance_id
           ,p_object_version_number         => l_ovn
        );

	hr_utility.set_location(' Leaving:' || l_proc,15);

  --

  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('When others exception in  .delete_absence: ' || SQLERRM );
    --2782075 changes start
    --Don't raise the error. just fetch the msg text and return
    p_page_error_msg := fnd_message.get;
    --2782075 changes start

 end delete_absence;

  /*
  ||===========================================================================
  || FUNCTION: chk_overlap
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will check overlap absence in transaction table
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  function chk_overlap(
    p_person_id          IN NUMBER
   ,p_business_group_id  IN NUMBER
   ,p_date_start         IN DATE
   ,p_date_end           IN DATE
   ,p_time_start         IN VARCHAR2
   ,p_time_end           IN VARCHAR2
  ) return boolean
  IS
  --
  --
  l_proc              varchar2(30)  :=  g_package||'chk_overlap';
  l_exists            varchar2(1) ;
  l_abs_overlap_warning boolean;
  --
  --

  -- Fix 2706099
   CURSOR c_abs_overlap(p_person_id          IN NUMBER
                       ,p_business_grroup_id IN NUMBER
                       ,p_date_start         IN DATE
                       ,p_date_end           IN DATE
                       ,p_time_start         IN VARCHAR2
                       ,p_time_end           IN VARCHAR2
   ) IS

 SELECT null
    FROM  hr_api_transaction_values tv
         ,hr_api_transaction_steps  ts
         ,hr_api_transaction_values tv1
         ,hr_api_transaction_values tv2
         ,hr_api_transaction_values tv3
         ,hr_api_transaction_values tv4
         ,hr_api_transaction_values tv5
         ,hr_api_transaction_values tv6
         ,hr_api_transactions hat -- Fix 3191531
    WHERE
         ts.api_name = 'HR_LOA_SS.PROCESS_API'
     and ts.UPDATE_PERSON_ID = p_person_id
     and p_date_start IS NOT NULL
     and p_date_end IS NOT NULL
     and ts.transaction_step_id = tv.transaction_step_id
     and tv.name = 'P_PERSON_ID'
     and tv.number_value = p_person_id
     and ts.transaction_step_id = tv1.transaction_step_id
     and tv1.name = 'P_BUSINESS_GROUP_ID'
     and tv1.number_value = p_business_group_id
     and ts.transaction_step_id = tv2.transaction_step_id
     and ts.transaction_id=hat.transaction_id
     and hat.status  in ('Y','C') -- Fix 3191531
     and ts.transaction_step_id = tv3.transaction_step_id
     and tv3.name = 'P_DATE_START'
     and ts.transaction_step_id = tv4.transaction_step_id
     and tv4.name = 'P_DATE_END'
     and ts.transaction_step_id = tv5.transaction_step_id
     and ts.transaction_step_id = tv6.transaction_step_id
     and tv5.name = 'P_TIME_START'
     and tv6.name = 'P_TIME_END'
     and tv3.date_value is NOT NULL
     and tv4.date_value is NOT NULL
          and (
	                  (
	                 to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt)  ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                  BETWEEN to_date (to_char(p_date_start, g_usr_date_fmt)||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
	                  AND to_date(to_char(p_date_end, g_usr_date_fmt) || ' '|| nvl(p_time_end,'00:00') , g_usr_day_time_fmt)
	                   )
	                  or
	                  (
	                  to_date (to_char(p_date_start, g_usr_date_fmt) ||' ' || nvl(p_time_start,'00:00'),g_usr_day_time_fmt)
	                   BETWEEN
	                   to_date( to_char(nvl(tv3.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv5.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                  AND
	                  to_date( to_char(nvl(tv4.date_value,hr_api.g_eot), g_usr_date_fmt) ||' ' || nvl(tv6.varchar2_value,'00:00'),g_usr_day_time_fmt)
	                   )

          );
--
     --  TRANS_SUBMIT status
     --  'Y' - Submit for Approval
     --  'S' - Save For Laer
     --  'C' - Returned for Correction
     --  'W' - Initial Save For Later - Inadvertent Save
     --

 BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --       check if this absence overlaps another absence for the same person.
  --

  -- Fix 2706099
  -- Absence timings are to be considered for checking overlap.
  --

  open  c_abs_overlap(p_person_id,p_business_group_id,p_date_start,p_date_end,p_time_start,p_time_end);
  fetch c_abs_overlap into l_exists;

  if c_abs_overlap%found then
    hr_utility.set_location(l_proc, 10);
    --
    -- Set the warning message
    --
    l_abs_overlap_warning := TRUE;
    --
  else
    hr_utility.set_location(l_proc, 20);
    l_abs_overlap_warning := FALSE;

  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 30);
  return l_abs_overlap_warning;

  --
  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' .chk_overlap: ' || SQLERRM );
  hr_utility.set_location('Leaving:'|| l_proc, 555);
    raise ;
 end chk_overlap;

END HR_LOA_SS;

/
