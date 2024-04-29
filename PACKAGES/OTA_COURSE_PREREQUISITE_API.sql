--------------------------------------------------------
--  DDL for Package OTA_COURSE_PREREQUISITE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COURSE_PREREQUISITE_API" AUTHID CURRENT_USER as
/* $Header: otcprapi.pkh 120.1 2006/07/12 10:59:32 niarora noship $ */
/*#
 * This package contains course prerequisite APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Course Prerequisite
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_course_prerequisite >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API identifies the prerequisite course for another course.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Course and prerequisite course records must exist.
 *
 * <p><b>Post Success</b><br>
 * Course prerequisite is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a course prerequisite record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_activity_version_id The Course for which prerequisite course needs to be added.
 * @param p_prerequisite_course_id Prerequisite course that needs to be added.
 * @param p_business_group_id The business group owning the course record.
 * @param p_prerequisite_type Prerequisite type of the Prerequisite Course.
 * Valid values are defined by 'OTA_CATALOG_PREREQUISITE_TYPE'  lookup type.
 * @param p_enforcement_mode Enforcement Mode for the Prerequisite Course.
 * Valid values are defined by 'OTA_CATALOG_PREREQ_ENF_MODE'  lookup type.
 * @param p_object_version_number If p_validate is false, then set to the version number
 * of the created prerequisite course. If p_validate is true, then the value will be null.
 * @rep:displayname Create Course Prerequisite
 * @rep:category BUSINESS_ENTITY OTA_COURSE_PREREQUISITE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_course_prerequisite
  (p_validate                       in  boolean  default false
  ,p_effective_date                 in     date
  ,p_activity_version_id            in number
  ,p_prerequisite_course_id         in number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_course_prerequisite >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the course prerequisite for another course.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The prerequisite record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The course prerequisite is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the course prerequisite record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_activity_version_id The Course for which the course prerequisite needs to be updated.
 * @param p_prerequisite_course_id Courrse prerequisite that needs to be updated.
 * @param p_business_group_id The business group owning the course record.
 * @param p_prerequisite_type Prerequisite type of the Prerequisite Course.
 * Valid values are defined by 'OTA_CATALOG_PREREQUISITE_TYPE'  lookup type.
 * @param p_enforcement_mode Enforcement Mode for the Prerequisite Course.
 * Valid values are defined by 'OTA_CATALOG_PREREQ_ENF_MODE'  lookup type.
 * @param p_object_version_number Pass in the current version number of the prerequisite course
 * to be updated. When the API completes if p_validate is false, will be set to the new
 * version number of the updated prerequisite course. If p_validate is true will be set
 * to the same value which was passed in.
 * @rep:displayname Update Course Prerequisite
 * @rep:category BUSINESS_ENTITY OTA_COURSE_PREREQUISITE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_course_prerequisite
  (p_validate                       in  boolean  default false
  ,p_effective_date                 in     date
  ,p_activity_version_id            in number
  ,p_prerequisite_course_id         in number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_course_prerequisite >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the course prerequisite for another course.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The prerequisite course record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The course prerequisite is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the course prerequisite record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_activity_version_id The Course for which the course prerequisite needs to be deleted.
 * @param p_prerequisite_course_id Course prerequisite to be deleted.
 * @param p_object_version_number Current version number of the course prerequisite to be deleted.
 * @rep:displayname Delete Course Prerequisite
 * @rep:category BUSINESS_ENTITY OTA_COURSE_PREREQUISITE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_course_prerequisite
  (p_validate                           in boolean default false
  ,p_activity_version_id                in number
  ,p_prerequisite_course_id             in number
  ,p_object_version_number              in number
  );
end ota_course_prerequisite_api;

 

/
