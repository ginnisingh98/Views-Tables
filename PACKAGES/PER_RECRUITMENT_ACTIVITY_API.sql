--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITY_API" AUTHID CURRENT_USER as
/* $Header: peraaapi.pkh 120.1 2005/10/02 02:23:28 aroussel $ */
/*#
 * This package contains HR Recruitment Activity APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Recruitment Activity
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_recruitment_activity >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a recruitment activity.
 *
 * Use this API to record the details of a recruitment activity, including the
 * dates, costs, and people authorizing and organizing the event. Use the
 * Create Recruitment Activity For API to associate a particular recruitment
 * activity with a list of vacancies you define.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for which the recruitment activity is created must
 * already exist.
 *
 * <p><b>Post Success</b><br>
 * The recruitment activity will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The recruitment activity will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Uniquely identifies the business group under
 * which the Recruitment Activity is created.
 * @param p_date_start Start date of the activity.
 * @param p_name Name of the recruitment activity.
 * @param p_authorising_person_id Uniquely identifies the person that
 * authorized the activity.
 * @param p_run_by_organization_id Uniquely identifies the organization running
 * the activity.
 * @param p_internal_contact_person_id Uniquely identifies the person who is
 * the internal contact for the activity.
 * @param p_parent_recruitment_activity Uniquely identifies this recruitment
 * activity's parent activity.
 * @param p_currency_code Currency the application uses to costs the activity.
 * @param p_actual_cost Cost of the activity.
 * @param p_comments Comment text.
 * @param p_contact_telephone_number Telephone number of the contact for this
 * activity.
 * @param p_date_closing Date the activity closes.
 * @param p_date_end Date the activity ends.
 * @param p_external_contact Name of the external contact for the activity.
 * @param p_planned_cost Planned cost of the activity.
 * @param p_recruiting_site_id Uniquely identifies the recruiting site.
 * @param p_recruiting_site_response The response from the recruiting site,
 * indicating if the post succeeds.
 * @param p_last_posted_date Date on which the posting was last sent.
 * @param p_type Type of recruitment activity. Valid values are defined by the
 * 'REC_TYPE' lookup type.
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
 * @param p_posting_content_id Uniquely identifies the posting content.
 * @param p_status The status of the recruitment activity. Valid values are
 * defined by the 'REC_STATUS' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created recruitment activity. If p_validate is true,
 * then the value will be null.
 * @param p_recruitment_activity_id If p_validate is false, then this uniquely
 * identifies the recruitment activity created. If p_validate is true, then
 * this is set to null.
 * @rep:displayname Create Recruitment Activity
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean   default false
  ,p_business_group_id             in   number
  ,p_date_start                    in   date
  ,p_name                          in   varchar2
  ,p_authorising_person_id         in   number     default null
  ,p_run_by_organization_id        in   number     default null
  ,p_internal_contact_person_id    in   number     default null
  ,p_parent_recruitment_activity   in   number     default null
  ,p_currency_code                 in   varchar2   default null
  ,p_actual_cost                   in   varchar2   default null
  ,p_comments                      in   long       default null
  ,p_contact_telephone_number      in   varchar2   default null
  ,p_date_closing                  in   date       default null
  ,p_date_end                      in   date       default null
  ,p_external_contact              in   varchar2   default null
  ,p_planned_cost                  in   varchar2   default null
  ,p_recruiting_site_id            in   number     default null
  ,p_recruiting_site_response      in   varchar2   default null
  ,p_last_posted_date              in   date       default null
  ,p_type                          in   varchar2   default null
  ,p_attribute_category            in   varchar2   default null
  ,p_attribute1                    in   varchar2   default null
  ,p_attribute2                    in   varchar2   default null
  ,p_attribute3                    in   varchar2   default null
  ,p_attribute4                    in   varchar2   default null
  ,p_attribute5                    in   varchar2   default null
  ,p_attribute6                    in   varchar2   default null
  ,p_attribute7                    in   varchar2   default null
  ,p_attribute8                    in   varchar2   default null
  ,p_attribute9                    in   varchar2   default null
  ,p_attribute10                   in   varchar2   default null
  ,p_attribute11                   in   varchar2   default null
  ,p_attribute12                   in   varchar2   default null
  ,p_attribute13                   in   varchar2   default null
  ,p_attribute14                   in   varchar2   default null
  ,p_attribute15                   in   varchar2   default null
  ,p_attribute16                   in   varchar2   default null
  ,p_attribute17                   in   varchar2   default null
  ,p_attribute18                   in   varchar2   default null
  ,p_attribute19                   in   varchar2   default null
  ,p_attribute20                   in   varchar2   default null
  ,p_posting_content_id            in   number     default null
  ,p_status                        in   varchar2   default null
  ,p_object_version_number           out nocopy  number
  ,p_recruitment_activity_id         out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_recruitment_activity >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a recruitment activity.
 *
 * Use this API to update the details of a recruitment activity, including the
 * dates, costs, and people authorizing and organizing the event.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruitment activity must already exist.
 *
 * <p><b>Post Success</b><br>
 * The recruitment activity will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The recruitment activity will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_recruitment_activity_id Uniquely identifies the recruitment
 * activity that is being updated.
 * @param p_authorising_person_id Uniquely identifies the person that
 * authorized the activity.
 * @param p_run_by_organization_id Uniquely identifies the organization running
 * the activity.
 * @param p_internal_contact_person_id Uniquely identifies the person who is
 * the internal contact for this activity.
 * @param p_parent_recruitment_activity Uniquely identifies this recruitment
 * activity's parent activity.
 * @param p_currency_code Currency the application uses to costs the activity.
 * @param p_date_start Start date of the activity.
 * @param p_name Name of the recruitment activity.
 * @param p_actual_cost Cost of the activity.
 * @param p_comments Comment text.
 * @param p_contact_telephone_number Telephone Number of the contact for this
 * activity.
 * @param p_date_closing Date the activity closes.
 * @param p_date_end Date the activity ends.
 * @param p_external_contact Name of the external contact for this activity.
 * @param p_planned_cost Planned cost of the activity.
 * @param p_recruiting_site_id Uniquely identifies the recruiting site.
 * @param p_recruiting_site_response The response from the recruiting site,
 * indicating if the post succeeds.
 * @param p_last_posted_date Date on which the posting was last sent.
 * @param p_type Type of recruitment activity. Valid values are defined by the
 * 'REC_TYPE' lookup type.
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
 * @param p_posting_content_id Uniquely identifies the posting content.
 * @param p_status The status of the recruitment activity. Valid values are
 * defined by the 'REC_STATUS' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * recruitment activity to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated recruitment
 * activity. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Recruitment Activity
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure UPDATE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean    default false
  ,p_recruitment_activity_id       in   number
  ,p_authorising_person_id         in   number     default hr_api.g_number
  ,p_run_by_organization_id        in   number     default hr_api.g_number
  ,p_internal_contact_person_id    in   number     default hr_api.g_number
  ,p_parent_recruitment_activity   in   number     default hr_api.g_number
  ,p_currency_code                 in   varchar2   default hr_api.g_varchar2
  ,p_date_start                    in   date       default hr_api.g_date
  ,p_name                          in   varchar2   default hr_api.g_varchar2
  ,p_actual_cost                   in   varchar2   default hr_api.g_varchar2
  ,p_comments                      in   long       default hr_api.g_varchar2
  ,p_contact_telephone_number      in   varchar2   default hr_api.g_varchar2
  ,p_date_closing                  in   date       default hr_api.g_date
  ,p_date_end                      in   date       default hr_api.g_date
  ,p_external_contact              in   varchar2   default hr_api.g_varchar2
  ,p_planned_cost                  in   varchar2   default hr_api.g_varchar2
  ,p_recruiting_site_id            in   number     default hr_api.g_number
  ,p_recruiting_site_response      in   varchar2   default hr_api.g_varchar2
  ,p_last_posted_date              in   date       default hr_api.g_date
  ,p_type                          in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_posting_content_id            in   number     default hr_api.g_number
  ,p_status                        in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number      in out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_recruitment_activity >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a recruitment activity.
 *
 * Use the Delete Recruitment Activity For API to remove an association between
 * a particular recruitment activity and a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruitment activity must already exist.
 *
 * <p><b>Post Success</b><br>
 * The recruitment activity will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The recruitment activity will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the Recruitment
 * Activity to be deleted.
 * @param p_recruitment_activity_id Uniquely identifies the Recruitment
 * Activity that is being deleted.
 * @rep:displayname Delete Recruitment Activity
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean    default false
  ,p_object_version_number         in   number
  ,p_recruitment_activity_id       in   number
  );
--
end PER_RECRUITMENT_ACTIVITY_API;

 

/
