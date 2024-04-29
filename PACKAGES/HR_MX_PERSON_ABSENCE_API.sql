--------------------------------------------------------
--  DDL for Package HR_MX_PERSON_ABSENCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_PERSON_ABSENCE_API" AUTHID CURRENT_USER AS
/* $Header: hrmxwrpa.pkh 120.1 2005/10/02 02:36:36 aroussel $ */
/*#
 * This package contains Person Absence APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person Absence for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_mx_person_absence >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API records the details of an absence for a person in Mexico.
 *
 * Use this API to record dates and times a person in Mexico was, or will be,
 * absent. You can also record the type of absence, projected and actual dates
 * and times, the person who authorized the absence, and the person who
 * replaces the absent person. This API also creates an element entry when you
 * enter the actual absence details and associate the absence type with an
 * element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom an absence is being recorded must already exist within
 * the business group. At least one absence type must have been set up.
 *
 * <p><b>Post Success</b><br>
 * The absence record for the person will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The absence record will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the absence
 * attendance record.
 * @param p_business_group_id The business group under which you record the
 * absence. This is usually the same business group that the person belongs to.
 * @param p_absence_attendance_type_id Uniquely identifies the type of absence.
 * @param p_abs_attendance_reason_id Uniquely identifies the reason for this
 * absence.
 * @param p_comments Absence Attendance comment text.
 * @param p_date_notification The date when the organization was first notified
 * about the absence.
 * @param p_date_projected_start The projected start date of the absence.
 * @param p_time_projected_start The projected start time of the absence. This
 * can only be set when the absence type is associated with an hours-based
 * absence element, or when the absence type has no associated element.
 * @param p_date_projected_end The projected end date of the absence.
 * @param p_time_projected_end The projected end time of the absence. This can
 * only be set when the absence type is associated with an hours-based absence
 * element, or when the absence type has no associated element.
 * @param p_date_start The actual start date of absence.
 * @param p_time_start The actual start time of the absence. This can only be
 * set when the absence type is associated with an hours-based absence element,
 * or when the absence type has no associated element.
 * @param p_date_end The actual end date of absence.
 * @param p_time_end The actual end time of the absence. This can only be set
 * when the absence type is associated with an hours-based absence element, or
 * when the absence type has no associated element.
 * @param p_absence_days The duration of the absence in days. This can only be
 * set when the absence type is associated with an hours-based absence element,
 * or when the absence type has no associated element.
 * @param p_absence_hours The duration of the absence in hours. This can only
 * be set when the absence type is associated with an hours-based absence
 * element, or when the absence type has no associated element.
 * @param p_authorising_person_id Uniquely identifies the person who authorized
 * this absence.
 * @param p_replacement_person_id Uniquely identifies the person who replaces
 * the absent person.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_period_of_incapacity_id Uniquely identifies the period of
 * incapacity.
 * @param p_ssp1_issued Set this to 'Y' if an SSP1 has been issued, otherwise
 * set this to 'N'.
 * @param p_maternity_id Uniquely identifies the maternity record, which is
 * required when the absence is for SMP, SAP or SPP.
 * @param p_sickness_start_date The date the sickness started.
 * @param p_sickness_end_date The date the sickness ended.
 * @param p_pregnancy_related_illness Set this to 'Y' if the illness is related
 * to maternity leave, otherwise set this to 'N'.
 * @param p_reason_for_notification_dela The reason for late notification,
 * defined as free-format text.
 * @param p_accept_late_notification_fla Set this to 'Y' if late notification
 * was accepted, otherwise set this to 'N'.
 * @param p_linked_absence_id Uniquely identifies the absence record that is
 * the first absence in the PIW.
 * @param p_batch_id Uniquely identifies the Batch Element Entry (BEE) run that
 * automatically created this absence record. This is used to roll back BEE
 * runs, and is for Oracle internal use only.
 * @param p_create_element_entry When set to True (the default), the absence
 * element is created automatically. When set to False, the absence element is
 * not created. This is for Oracle internal use only.
 * @param p_type_of_disability Identifies the type of disability related to
 * this absence.
 * @param p_disability_id Uniquely identifies the disability record of the type
 * specified under p_type_of_disability.
 * @param p_absence_attendance_id If p_validate is false, then this uniquely
 * identifies the absence record created. If p_validate is true, then this is
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created absence record. If p_validate is true, then
 * the value will be null.
 * @param p_occurrence A numerical sequence that denotes the number of absences
 * this person has taken for this type of absence.
 * @param p_dur_dys_less_warning If set to true, this serves as a warning that
 * the specified absence duration in days is less than what the system has
 * calculated. The application uses the BG_ABSENCE_DURATION Fast Formula for
 * this calculation if it exists.
 * @param p_dur_hrs_less_warning If set to true, this serves as a warning that
 * the specified absence duration in hours is less than what the system has
 * calculated. The application uses the BG_ABSENCE_DURATION Fast Formula for
 * this calculation if it exists.
 * @param p_exceeds_pto_entit_warning If set to true, this serves as a warning
 * that the net entitlement of at least one of this person's accrual plans will
 * be below zero when you apply this absence.
 * @param p_exceeds_run_total_warning If set to true, this serves as a warning
 * that the absence's type is using a decreasing balance and that the running
 * total will be below zero when you apply this absence.
 * @param p_abs_overlap_warning If set to true, this serves as a warning that
 * this absence overlaps an existing absence for this person.
 * @param p_abs_day_after_warning If set to true, this serves as a warning that
 * this absence starts the day after an existing sickness absence. A sickness
 * absence in this case is one that has an absence category starting with 'S'.
 * @param p_dur_overwritten_warning If set to true, this serves as a warning
 * that the HR: Absence Duration Auto Overwrite profile option is set to 'Yes'
 * and that the the system-calculated duration has automatically overwritten
 * the absence duration.
 * @rep:displayname Create Person Absence for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
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
    ,p_dur_overwritten_warning       out nocopy    boolean);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_mx_person_absence >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of an absence for a person in Mexico.
 *
 * Use this API to update projected and actual dates and times a person in
 * Mexico is absent, the person who authorized the absence, and the person who
 * replaces the absent person. The API also updates the absence element entry
 * when you change the actual absence details and the absence type is
 * associated with an element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence record being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The absence record for the person will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The absence record will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_absence_attendance_id Uniquely identifies the absence record that
 * is being updated.
 * @param p_abs_attendance_reason_id Uniquely identifies the reason for this
 * absence.
 * @param p_comments Absence Attendance comment text.
 * @param p_date_notification The date when the organization was first notified
 * about the absence.
 * @param p_date_projected_start The projected start date of the absence.
 * @param p_time_projected_start The projected start time of the absence. This
 * can only be set when the absence type is associated with an hours-based
 * absence element, or when the absence type has no associated element.
 * @param p_date_projected_end The projected end date of the absence.
 * @param p_time_projected_end The projected end time of the absence. This can
 * only be set when the absence type is associated with an hours-based absence
 * element, or when the absence type has no associated element.
 * @param p_date_start The actual start date of absence.
 * @param p_time_start The actual start time of the absence. This can only be
 * set when the absence type is associated with an hours-based absence element,
 * or when the absence type has no associated element.
 * @param p_date_end The actual end date of absence.
 * @param p_time_end The actual end time of the absence. This can only be set
 * when the absence type is associated with an hours-based absence element, or
 * when the absence type has no associated element.
 * @param p_absence_days The duration of the absence in days. This can only be
 * set when the absence type is associated with an hours-based absence element,
 * or when the absence type has no associated element.
 * @param p_absence_hours The duration of the absence in hours. This can only
 * be set when the absence type is associated with an hours-based absence
 * element, or when the absence type has no associated element.
 * @param p_authorising_person_id Uniquely identifies the person who authorized
 * this absence.
 * @param p_replacement_person_id Uniquely identifies the person who replaces
 * the absent person.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_period_of_incapacity_id Uniquely identifies the period of
 * incapacity.
 * @param p_ssp1_issued Set this to 'Y' if an SSP1 has been issued, otherwise
 * set this to 'N'.
 * @param p_maternity_id Uniquely identifies the maternity record, which is
 * required when the absence is for SMP, SAP or SPP.
 * @param p_sickness_start_date The date the sickness started.
 * @param p_sickness_end_date The date the sickness ended.
 * @param p_pregnancy_related_illness Set this to 'Y' if the illness is related
 * to maternity leave, otherwise set this to 'N'.
 * @param p_reason_for_notification_dela The reason for late notification,
 * defined as free-format text.
 * @param p_accept_late_notification_fla Set this to 'Y' if late notification
 * was accepted, otherwise set this to 'N'.
 * @param p_linked_absence_id Uniquely identifies the absence record that is
 * the first absence in the PIW.
 * @param p_batch_id Uniquely identifies the Batch Element Entry (BEE) run that
 * automatically created this absence record. This is used to roll back BEE
 * runs, and is for Oracle internal use only.
 * @param p_type_of_disability Identifies the type of disability related to
 * this absence.
 * @param p_disability_id Uniquely identifies the disability record of the type
 * specified under p_type_of_disability.
 * @param p_object_version_number Pass in the current version number of the
 * Absence to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated Absence. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_dur_dys_less_warning If set to true, this serves as a warning that
 * the specified absence duration in days is less than what the system has
 * calculated. The application uses the BG_ABSENCE_DURATION Fast Formula for
 * this calculation if it exists.
 * @param p_dur_hrs_less_warning If set to true, this serves as a warning that
 * the specified absence duration in hours is less than what the system has
 * calculated. The application uses the BG_ABSENCE_DURATION Fast Formula for
 * this calculation if it exists.
 * @param p_exceeds_pto_entit_warning If set to true, this serves as a warning
 * that the net entitlement of at least one of this person's accrual plans will
 * be below zero when you apply this absence.
 * @param p_exceeds_run_total_warning If set to true, this serves as a warning
 * that the absence's type is using a decreasing balance and that the running
 * total will be below zero when you apply this absence.
 * @param p_abs_overlap_warning If set to true, this serves as a warning that
 * this absence overlaps an existing absence for this person.
 * @param p_abs_day_after_warning If set to true, this serves as a warning that
 * this absence starts the day after an existing sickness absence. A sickness
 * absence in this case is one that has an absence category starting with 'S'.
 * @param p_dur_overwritten_warning If set to true, this serves as a warning
 * that the HR: Absence Duration Auto Overwrite profile option is set to 'Yes'
 * and that the the system-calculated duration has automatically overwritten
 * the absence duration.
 * @param p_del_element_entry_warning If set to true, this serves as a warning
 * that the associated absence element entry will be deleted.
 * @rep:displayname Update Person Absence for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
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
    ,p_del_element_entry_warning     out nocopy    boolean);

END HR_MX_PERSON_ABSENCE_API;

 

/
