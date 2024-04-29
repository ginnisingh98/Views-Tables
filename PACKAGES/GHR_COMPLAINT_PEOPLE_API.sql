--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_PEOPLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_PEOPLE_API" AUTHID CURRENT_USER as
/* $Header: ghcplapi.pkh 120.1 2005/10/02 01:57:40 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * GHR Complaint Tracking Complaint People records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint People
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_compl_person >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Complaint People record.
 *
 * This API creates a child Complaint Person record in table ghr_compl_people
 * for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2 and the person must
 * exist in per_all_people_f.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Complaint Person record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Complaint Person record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the Complaint
 * Person record.
 * @param p_complaint_id Unique key of the Parent Complaint record.
 * @param p_role_code Complaint Person Role Code. Valid values are defined by
 * 'GHR_US_PERSON_ROLES' lookup type.
 * @param p_start_date {@rep:casecolumn GHR_COMPL_PEOPLE.START_DATE}
 * @param p_end_date {@rep:casecolumn GHR_COMPL_PEOPLE.END_DATE}
 * @param p_compl_person_id If p_validate is false, then this uniquely
 * identifies the Complaint Person created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Complaint Person. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Complaint Person
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_compl_person
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_complaint_id                   in     number
  ,p_role_code                      in     varchar2 default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_compl_person_id                   out nocopy number
  ,p_object_version_number             out nocopy number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_compl_person >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaints Tracking Complaint People record.
 *
 * This API updates a child Complaint Person record in table ghr_compl_people
 * for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2 and the person must
 * exist in per_all_people_f.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Complaint Person record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Complaint Person record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_person_id Uniquely identifies the Person for whom you are
 * updating the Complaint Person record.
 * @param p_object_version_number Pass in the current version number of the
 * Complaint Person to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Complaint
 * Person. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_person_id Identifies the person for whom you are updating the
 * Complaint Person record.
 * @param p_complaint_id Unique key of the Parent Complaint record.
 * @param p_role_code Complaint Person Role Code. Valid values are defined by
 * 'GHR_US_PERSON_ROLES' lookup type.
 * @param p_start_date {@rep:casecolumn GHR_COMPL_PEOPLE.START_DATE}
 * @param p_end_date {@rep:casecolumn GHR_COMPL_PEOPLE.END_DATE}
 * @rep:displayname Update Complaint Person
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_compl_person
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_person_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_role_code                    in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_compl_person >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Complaints Tracking Complaint People record.
 *
 * This API deletes a child Complaint Person record in table ghr_compl_people
 * for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Complaint Person record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Complaint Person record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Complaint Person record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_person_id Uniquely identifies the Complaint Person record to
 * be deleted.
 * @param p_object_version_number Current version number of the Complaint
 * Person to be deleted.
 * @rep:displayname Delete Complaint Person
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_compl_person
  (p_validate                      in     boolean  default false
  ,p_compl_person_id               in     number
  ,p_object_version_number         in     number
  );

end ghr_complaint_people_api;

 

/
