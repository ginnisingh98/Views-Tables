--------------------------------------------------------
--  DDL for Package PER_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVENTS_API" AUTHID CURRENT_USER as
/* $Header: peevtapi.pkh 120.1 2005/10/02 02:17:00 aroussel $ */
/*#
 * This package contains HR Event APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_event >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a standard or interview event.
 *
 * Use this API to create a standard event, or schedule an employee review or
 * applicant interview. The type of event created depends on the parameters you
 * specify. Note: You can schedule employees, applicants and contingent workers
 * for standard events.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for which the event will be created within must already
 * exist. When booking an employee review, applicant interview, or performance
 * review, the person's assignment must already exist. At least one of the
 * following event lookup types must have been defined: EMP_EVENT_TYPE,
 * APL_EVENT_TYPE, EMP_INTERVIEW_TYPE, APL_INTERVIEW_TYPE.
 *
 * <p><b>Post Success</b><br>
 * The event will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The event will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_start Start date of the event.
 * @param p_type The type of event. Valid values are defined by the lookup
 * types 'EMP_EVENT_TYPE' (for employee or contingent worker standard events),
 * 'APL_EVENT_TYPE' (for applicant standard events), 'EMP_INTERVIEW_TYPE' (for
 * employee review events), and 'APL_INTERVIEW_TYPE' (for applicant interview
 * events).
 * @param p_business_group_id Uniquely identifies the business group under
 * which the event will be created.
 * @param p_location_id Uniquely identifies the location of the event.
 * @param p_internal_contact_person_id Uniquely identifies the person who is
 * the internal contact for this event.
 * @param p_organization_run_by_id Uniquely identifies the organization running
 * the event.
 * @param p_assignment_id For interview events, this uniquely identifies the
 * assignment related to the interview or review.
 * @param p_contact_telephone_number Contact number for the event.
 * @param p_date_end End date of the event.
 * @param p_emp_or_apl Defines whether the event is an employee and contingent
 * worker event, or an applicant event. Valid values are defined by the
 * 'EMP_APL' lookup type.
 * @param p_event_or_interview Defines whether the event is a standard event or
 * an interview event. Valid values are defined by the 'EVENT_INTERVIEW' lookup
 * type.
 * @param p_external_contact External contact for the event.
 * @param p_time_end End time of the event.
 * @param p_time_start Start time of the event.
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
 * @param p_party_id Party to whom the event applies.
 * @param p_event_id If p_validate is false, then this uniquely identifies the
 * event. If p_validate is true, then this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event record. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Event
 * @rep:category BUSINESS_ENTITY HR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_event

(p_validate                         in     BOOLEAN   default FALSE
,p_date_start                       in     DATE
,p_type                             in     VARCHAR2
,p_business_group_id                in     NUMBER    default NULL -- HR/TCA merge
,p_location_id                      in     NUMBER    default NULL
,p_internal_contact_person_id       in     NUMBER    default NULL
,p_organization_run_by_id           in     NUMBER    default NULL
,p_assignment_id                    in     NUMBER    default NULL
,p_contact_telephone_number         in     VARCHAR2  default NULL
,p_date_end                         in     DATE      default NULL
,p_emp_or_apl                       in     VARCHAR2  default NULL
,p_event_or_interview               in     VARCHAR2  default NULL
,p_external_contact                 in     VARCHAR2  default NULL
,p_time_end                         in     VARCHAR2  default NULL
,p_time_start                       in     VARCHAR2  default NULL
,p_attribute_category               in     VARCHAR2  default NULL
,p_attribute1                       in     VARCHAR2  default NULL
,p_attribute2                       in     VARCHAR2  default NULL
,p_attribute3                       in     VARCHAR2  default NULL
,p_attribute4                       in     VARCHAR2  default NULL
,p_attribute5                       in     VARCHAR2  default NULL
,p_attribute6                       in     VARCHAR2  default NULL
,p_attribute7                       in     VARCHAR2  default NULL
,p_attribute8                       in     VARCHAR2  default NULL
,p_attribute9                       in     VARCHAR2  default NULL
,p_attribute10                      in     VARCHAR2  default NULL
,p_attribute11                      in     VARCHAR2  default NULL
,p_attribute12                      in     VARCHAR2  default NULL
,p_attribute13                      in     VARCHAR2  default NULL
,p_attribute14                      in     VARCHAR2  default NULL
,p_attribute15                      in     VARCHAR2  default NULL
,p_attribute16                      in     VARCHAR2  default NULL
,p_attribute17                      in     VARCHAR2  default NULL
,p_attribute18                      in     VARCHAR2  default NULL
,p_attribute19                      in     VARCHAR2  default NULL
,p_attribute20                      in     VARCHAR2  default NULL
,p_party_id                         in     NUMBER    default NULL -- HR/TCA merge
,p_event_id                         out nocopy    NUMBER
,p_object_version_number            out nocopy    NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_event >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a standard or interview event.
 *
 * Use this API to update a standard event, employee review, or applicant
 * interview.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The event must have already been created.
 *
 * <p><b>Post Success</b><br>
 * The event will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The event will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_id Uniquely identifies the location of the event.
 * @param p_business_group_id Uniquely identifies the business group that the
 * event belongs to.
 * @param p_internal_contact_person_id Uniquely identifies the person who is
 * the internal contact for this event.
 * @param p_organization_run_by_id Uniquely identifies the organization running
 * the event.
 * @param p_assignment_id For interview events, this uniquely identifies the
 * assignment related to the interview or review.
 * @param p_contact_telephone_number Contact number for the event.
 * @param p_date_end End date of the event.
 * @param p_emp_or_apl Defines whether the event is an employee and contingent
 * worker event, or an applicant event. Valid values are defined by the
 * 'EMP_APL' lookup type.
 * @param p_event_or_interview Defines whether the event is a standard event or
 * an interview event. Valid values are defined by the 'EVENT_INTERVIEW' lookup
 * type.
 * @param p_external_contact External contact for the event.
 * @param p_time_end End time of the event.
 * @param p_time_start Start time of the event.
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
 * @param p_date_start Start date of the event.
 * @param p_type The type of event. Valid values are defined by the lookup
 * types 'EMP_EVENT_TYPE' (for employee or contingent worker standard events),
 * 'APL_EVENT_TYPE' (for applicant standard events), 'EMP_INTERVIEW_TYPE' (for
 * employee review events), and 'APL_INTERVIEW_TYPE' (for applicant interview
 * events).
 * @param p_party_id Party to whom the event applies.
 * @param p_event_id Uniquely identifies the event that will be updated.
 * @param p_object_version_number Pass in the current version number of the
 * Event to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated Event. If p_validate is true
 * will be set to the same value which was passed in.
 * @rep:displayname Update Event
 * @rep:category BUSINESS_ENTITY HR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_event
(p_validate                         in     BOOLEAN      default FALSE
,p_location_id                      in     NUMBER       default hr_api.g_number
,p_business_group_id                in     NUMBER       default hr_api.g_number
,p_internal_contact_person_id       in     NUMBER       default hr_api.g_number
,p_organization_run_by_id           in     NUMBER       default hr_api.g_number
,p_assignment_id                    in     NUMBER       default hr_api.g_number
,p_contact_telephone_number         in     VARCHAR2     default hr_api.g_varchar2
,p_date_end                         in     DATE         default hr_api.g_date
,p_emp_or_apl                       in     VARCHAR2     default hr_api.g_varchar2
,p_event_or_interview               in     VARCHAR2     default hr_api.g_varchar2
,p_external_contact                 in     VARCHAR2     default hr_api.g_varchar2
,p_time_end                         in     VARCHAR2     default hr_api.g_varchar2
,p_time_start                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute_category               in     VARCHAR2     default hr_api.g_varchar2
,p_attribute1                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute2                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute3                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute4                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute5                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute6                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute7                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute8                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute9                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute10                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute11                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute12                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute13                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute14                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute15                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute16                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute17                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute18                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute19                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute20                      in     VARCHAR2     default hr_api.g_varchar2
,p_date_start                       in     DATE         default hr_api.g_date
,p_type                             in     VARCHAR2     default hr_api.g_varchar2
,p_party_id                         in     NUMBER       default hr_api.g_number
,p_event_id                         in out nocopy NUMBER
,p_object_version_number            in out nocopy NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_event >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a standard or interview event.
 *
 * Use this API to delete a standard event, employee review, or applicant
 * interview.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The event must have already been created.
 *
 * <p><b>Post Success</b><br>
 * The event will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The event will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_id Uniquely identifies the event that will be deleted.
 * @param p_object_version_number Current version number of the Event to be
 * deleted.
 * @rep:displayname Delete Event
 * @rep:category BUSINESS_ENTITY HR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_event
  (p_validate                in   boolean  default false
  ,p_event_id                in   number
  ,p_object_version_number   in   number
  );

end per_events_api;

 

/
