--------------------------------------------------------
--  DDL for Package PER_REC_ACTIVITY_FOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REC_ACTIVITY_FOR_API" AUTHID CURRENT_USER as
/* $Header: percfapi.pkh 120.1 2005/10/02 02:23:35 aroussel $ */
/*#
 * This package contains APIs to create and maintain Association between a
 * Recruitment activity and a Vacancy.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Recruitment Activity For
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_rec_activity_for >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an association between a recruitment activity and a
 * vacancy.
 *
 * You can specify multiple vacancies for each recruitment activity by calling
 * this API multiple times.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruitment activity and vacancy must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Recruitment Activity For association will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The Recruitment Activity For association will not be created and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rec_activity_for_id If p_validate is false, then this uniquely
 * identifies the Recruitment Activity For association. If p_validate is true,
 * then this is set to null.
 * @param p_business_group_id Uniquely identifies the business group under
 * which the Recruitment Activity For association is created.
 * @param p_vacancy_id Uniquely identifies the vacancy you are linking to the
 * recruitment activity.
 * @param p_rec_activity_id Uniquely identifies the recruitment activity you
 * are linking to the vacancy.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Recruitment Activity For record. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Recruitment Activity For
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rec_activity_for
  (
   p_validate                        in     boolean  default false
  ,p_rec_activity_for_id             out nocopy    number
  ,p_business_group_id               in     number
  ,p_vacancy_id                      in     number
  ,p_rec_activity_id                 in     number
  ,p_object_version_number           out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rec_activity_for >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an association between a recruitment activity and a
 * vacancy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruitment activity for the vacancy must have already been created.
 *
 * <p><b>Post Success</b><br>
 * The Recruitment Activity For association will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The Recruitment Activity For association will not be updated and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rec_activity_for_id Uniquely identifies the Recruitment Activity
 * For record that is being updated.
 * @param p_vacancy_id Uniquely identifies the vacancy that you are linking to
 * the recruitment activity.
 * @param p_rec_activity_id Uniquely identifies the recruitment activity that
 * you are linking to the vacancy.
 * @param p_object_version_number Pass in the current version number of the
 * Recruitment Activity For to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Recruitment
 * Activity For. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Recruitment Activity For
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rec_activity_for
  (p_validate                        in     boolean  default false
  ,p_rec_activity_for_id             in     number
  ,p_vacancy_id                      in     number   default hr_api.g_number
  ,p_rec_activity_id                 in     number   default hr_api.g_number
  ,p_object_version_number           in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rec_activity_for >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an association between a recruitment activity and a
 * vacancy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruitment activity for the vacancy must have already been created.
 *
 * <p><b>Post Success</b><br>
 * The Recruitment Activity For association will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Recruitment Activity For association will not be deleted and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rec_activity_for_id Uniquely identifies the Recruitment Activity
 * For record that is being deleted.
 * @param p_object_version_number Current version number of the Recruitment
 * Activity For to be deleted.
 * @rep:displayname Delete Recruitment Activity For
 * @rep:category BUSINESS_ENTITY PER_RECRUITMENT_ACTIVITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rec_activity_for
  (p_validate                      in     boolean  default false
  ,p_rec_activity_for_id           in     number
  ,p_object_version_number         in     number
  );
--
end PER_REC_ACTIVITY_FOR_API;

 

/
