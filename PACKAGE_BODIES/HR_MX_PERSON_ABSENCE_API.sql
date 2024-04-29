--------------------------------------------------------
--  DDL for Package Body HR_MX_PERSON_ABSENCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_PERSON_ABSENCE_API" AS
/* $Header: hrmxwrpa.pkb 120.0 2005/05/31 01:32:16 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : HR_MX_PERSON_ABSENCE_API

    Description : This is Mexican wrapper package for hr_person_absence_api.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    29-JUN-2004 sdahiya    115.0            Created.
    09-JUL-2004 sdahiya    115.1            Added business group check in
                                            update_mx_person_absence.
  *****************************************************************************/

    g_proc_name varchar2 (50);
/*******************************************************************************
    Name    : create_mx_person_absence
    Purpose : This procedure acts as wrapper for hr_person_absence_api.create_person_absence.
*******************************************************************************/

PROCEDURE CREATE_MX_PERSON_ABSENCE
    (p_validate                      in     boolean  default false
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
    ,p_period_of_incapacity_id       in     number   default null
    ,p_ssp1_issued                   in     varchar2 default 'N'
    ,p_maternity_id                  in     number   default null
    ,p_sickness_start_date           in     date     default null
    ,p_sickness_end_date             in     date     default null
    ,p_pregnancy_related_illness     in     varchar2 default 'N'
    ,p_reason_for_notification_dela  in     varchar2 default null
    ,p_accept_late_notification_fla  in     varchar2 default 'N'
    ,p_linked_absence_id             in     number   default null
    ,p_batch_id                      in     number   default null
    ,p_create_element_entry          in     boolean  default true
    ,p_type_of_disability            in     varchar2 default null
    ,p_disability_id                 in     varchar2 default null
    ,p_absence_attendance_id         out nocopy    number
    ,p_object_version_number         out nocopy    number
    ,p_occurrence                    out nocopy    number
    ,p_dur_dys_less_warning          out nocopy    boolean
    ,p_dur_hrs_less_warning          out nocopy    boolean
    ,p_exceeds_pto_entit_warning     out nocopy    boolean
    ,p_exceeds_run_total_warning     out nocopy    boolean
    ,p_abs_overlap_warning           out nocopy    boolean
    ,p_abs_day_after_warning         out nocopy    boolean
    ,p_dur_overwritten_warning       out nocopy    boolean
    ) AS

    l_proc_name varchar2(100);

BEGIN
    l_proc_name := g_proc_name||'CREATE_MX_PERSON_ABSENCE';
    hr_utility.trace('Entering '||l_proc_name);
    --
    hr_mx_utility.check_bus_grp (p_business_group_id, 'MX');
    --
    fnd_profile.put('PER_PERSON_ID',p_person_id);
    hr_person_absence_api.create_person_absence
        (p_validate                      => p_validate
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
        ,p_batch_id                      => p_batch_id
        ,p_create_element_entry          => p_create_element_entry
        ,p_abs_information_category      => 'MX'
        ,p_abs_information1              => p_type_of_disability
        ,p_abs_information2              => p_disability_id
        ,p_absence_attendance_id         => p_absence_attendance_id
        ,p_object_version_number         => p_object_version_number
        ,p_occurrence                    => p_occurrence
        ,p_dur_dys_less_warning          => p_dur_dys_less_warning
        ,p_dur_hrs_less_warning          => p_dur_hrs_less_warning
        ,p_exceeds_pto_entit_warning     => p_exceeds_pto_entit_warning
        ,p_exceeds_run_total_warning     => p_exceeds_run_total_warning
        ,p_abs_overlap_warning           => p_abs_overlap_warning
        ,p_abs_day_after_warning         => p_abs_day_after_warning
        ,p_dur_overwritten_warning       => p_dur_overwritten_warning
        );

    hr_utility.trace('Leaving '||l_proc_name);
END CREATE_MX_PERSON_ABSENCE;


/*******************************************************************************
    Name    : update_mx_person_absence
    Purpose : This procedure acts as wrapper for hr_person_absence_api.update_person_absence.
*******************************************************************************/

PROCEDURE UPDATE_MX_PERSON_ABSENCE
    (p_validate                      in     boolean  default false
    ,p_effective_date                in     date
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
    ,p_batch_id                      in     number   default hr_api.g_number
    ,p_type_of_disability            in     varchar2 default hr_api.g_varchar2
    ,p_disability_id                 in     varchar2 default hr_api.g_varchar2
    ,p_object_version_number         in out nocopy number
    ,p_dur_dys_less_warning          out nocopy    boolean
    ,p_dur_hrs_less_warning          out nocopy    boolean
    ,p_exceeds_pto_entit_warning     out nocopy    boolean
    ,p_exceeds_run_total_warning     out nocopy    boolean
    ,p_abs_overlap_warning           out nocopy    boolean
    ,p_abs_day_after_warning         out nocopy    boolean
    ,p_dur_overwritten_warning       out nocopy    boolean
    ,p_del_element_entry_warning     out nocopy    boolean
    ) AS

    CURSOR get_person_id IS
        SELECT person_id
          FROM per_absence_attendances_v
         WHERE absence_attendance_id = p_absence_attendance_id;

    l_proc_name varchar2(100);
    l_person_id per_absence_attendances_v.person_id%type;

BEGIN
    l_proc_name := g_proc_name||'UPDATE_MX_PERSON_ABSENCE';
    hr_utility.trace('Entering '||l_proc_name);

    OPEN get_person_id;
        FETCH get_person_id INTO l_person_id;
    CLOSE get_person_id;

    fnd_profile.put('PER_PERSON_ID',l_person_id);

    hr_mx_utility.check_bus_grp(hr_mx_utility.get_bg_from_person(l_person_id),'MX');

    hr_person_absence_api.update_person_absence
        (p_validate                      => p_validate
        ,p_effective_date                => p_effective_date
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
        ,p_batch_id                      => p_batch_id
        ,p_abs_information_category      => 'MX'
        ,p_abs_information1              => p_type_of_disability
        ,p_abs_information2              => p_disability_id
        ,p_object_version_number         => p_object_version_number
        ,p_dur_dys_less_warning          => p_dur_dys_less_warning
        ,p_dur_hrs_less_warning          => p_dur_hrs_less_warning
        ,p_exceeds_pto_entit_warning     => p_exceeds_pto_entit_warning
        ,p_exceeds_run_total_warning     => p_exceeds_run_total_warning
        ,p_abs_overlap_warning           => p_abs_overlap_warning
        ,p_abs_day_after_warning         => p_abs_day_after_warning
        ,p_dur_overwritten_warning       => p_dur_overwritten_warning
        ,p_del_element_entry_warning     => p_del_element_entry_warning);

    hr_utility.trace('Leaving '||l_proc_name);
END UPDATE_MX_PERSON_ABSENCE;
BEGIN
    g_proc_name := 'HR_MX_PERSON_ABSENCE_API.';
END HR_MX_PERSON_ABSENCE_API;

/
