--------------------------------------------------------
--  DDL for Package OTA_SKILL_PROVISION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SKILL_PROVISION_API" AUTHID CURRENT_USER as
/* $Header: ottspapi.pkh 120.1 2005/10/02 02:08:49 aroussel $ */
/*#
 * This package contains the Course Other Information APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Course Other Information
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_skill_provision >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Course Other Information record.
 *
 * This business process creates Course Other Information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course for which the other information is being defined should exist,
 * and the course other information should be enabled for application, OTA.
 *
 * <p><b>Post Success</b><br>
 * The Course Other Information record is created.
 *
 * <p><b>Post Failure</b><br>
 * The API is unable to create Course Other Information, an error is thrown
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_skill_provision_id The Course Other Information number generation
 * method determines when the API derives and passes
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Course Other Information. If p_validate is
 * true, then the value will be null.
 * @param p_type {@rep:casecolumn OTA_SKILL_PROVISIONS.TYPE}
 * @param p_comments {@rep:casecolumn OTA_SKILL_PROVISIONS.COMMENTS}
 * @param p_tsp_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_tsp_information1 Descriptive Flexfield
 * @param p_tsp_information2 Descriptive Flexfield
 * @param p_tsp_information3 Descriptive Flexfield
 * @param p_tsp_information4 Descriptive Flexfield
 * @param p_tsp_information5 Descriptive Flexfield
 * @param p_tsp_information6 Descriptive Flexfield
 * @param p_tsp_information7 Descriptive Flexfield
 * @param p_tsp_information8 Descriptive Flexfield
 * @param p_tsp_information9 Descriptive Flexfield
 * @param p_tsp_information10 Descriptive Flexfield
 * @param p_tsp_information11 Descriptive Flexfield
 * @param p_tsp_information12 Descriptive Flexfield
 * @param p_tsp_information13 Descriptive Flexfield
 * @param p_tsp_information14 Descriptive Flexfield
 * @param p_tsp_information15 Descriptive Flexfield
 * @param p_tsp_information16 Descriptive Flexfield
 * @param p_tsp_information17 Descriptive Flexfield
 * @param p_tsp_information18 Descriptive Flexfield
 * @param p_tsp_information19 Descriptive Flexfield
 * @param p_tsp_information20 Descriptive Flexfield
 * @param p_analysis_criteria_id {@rep:casecolumn
 * PER_ANALYSIS_CRITERIA.ANALYSIS_CRITERIA_ID}
 * @rep:displayname Create Course Other Information
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure create_skill_provision
  (
  p_skill_provision_id           out nocopy number,
  p_activity_version_id          in number,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_comments                     in varchar2         default null,
  p_tsp_information_category     in varchar2         default null,
  p_tsp_information1             in varchar2         default null,
  p_tsp_information2             in varchar2         default null,
  p_tsp_information3             in varchar2         default null,
  p_tsp_information4             in varchar2         default null,
  p_tsp_information5             in varchar2         default null,
  p_tsp_information6             in varchar2         default null,
  p_tsp_information7             in varchar2         default null,
  p_tsp_information8             in varchar2         default null,
  p_tsp_information9             in varchar2         default null,
  p_tsp_information10            in varchar2         default null,
  p_tsp_information11            in varchar2         default null,
  p_tsp_information12            in varchar2         default null,
  p_tsp_information13            in varchar2         default null,
  p_tsp_information14            in varchar2         default null,
  p_tsp_information15            in varchar2         default null,
  p_tsp_information16            in varchar2         default null,
  p_tsp_information17            in varchar2         default null,
  p_tsp_information18            in varchar2         default null,
  p_tsp_information19            in varchar2         default null,
  p_tsp_information20            in varchar2         default null,
  p_analysis_criteria_id         in number,
  p_validate                     in boolean   default false
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_skill_provision >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Course Other Information record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course Other Information record must exist
 *
 * <p><b>Post Success</b><br>
 * The Course Other Information record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The Course Other Information record is not updated, and an error is thrown.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_skill_provision_id The unique identifier for the Course Other
 * Information record.
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_object_version_number Pass in the variable holding for the version
 * number of the Course Other Information record to be updated. When the API
 * completes if p_validate is false, will be set to the new version number of
 * the Course Other Information record. If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_type {@rep:casecolumn OTA_SKILL_PROVISIONS.TYPE}
 * @param p_comments {@rep:casecolumn OTA_SKILL_PROVISIONS.COMMENTS}
 * @param p_tsp_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_tsp_information1 Descriptive Flexfield
 * @param p_tsp_information2 Descriptive Flexfield
 * @param p_tsp_information3 Descriptive Flexfield
 * @param p_tsp_information4 Descriptive Flexfield
 * @param p_tsp_information5 Descriptive Flexfield
 * @param p_tsp_information6 Descriptive Flexfield
 * @param p_tsp_information7 Descriptive Flexfield
 * @param p_tsp_information8 Descriptive Flexfield
 * @param p_tsp_information9 Descriptive Flexfield
 * @param p_tsp_information10 Descriptive Flexfield
 * @param p_tsp_information11 Descriptive Flexfield
 * @param p_tsp_information12 Descriptive Flexfield
 * @param p_tsp_information13 Descriptive Flexfield
 * @param p_tsp_information14 Descriptive Flexfield
 * @param p_tsp_information15 Descriptive Flexfield
 * @param p_tsp_information16 Descriptive Flexfield
 * @param p_tsp_information17 Descriptive Flexfield
 * @param p_tsp_information18 Descriptive Flexfield
 * @param p_tsp_information19 Descriptive Flexfield
 * @param p_tsp_information20 Descriptive Flexfield
 * @param p_analysis_criteria_id {@rep:casecolumn
 * PER_ANALYSIS_CRITERIA.ANALYSIS_CRITERIA_ID}
 * @rep:displayname Update Course Other Information
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure update_skill_provision
  (
  p_skill_provision_id           in number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tsp_information_category     in varchar2         default hr_api.g_varchar2,
  p_tsp_information1             in varchar2         default hr_api.g_varchar2,
  p_tsp_information2             in varchar2         default hr_api.g_varchar2,
  p_tsp_information3             in varchar2         default hr_api.g_varchar2,
  p_tsp_information4             in varchar2         default hr_api.g_varchar2,
  p_tsp_information5             in varchar2         default hr_api.g_varchar2,
  p_tsp_information6             in varchar2         default hr_api.g_varchar2,
  p_tsp_information7             in varchar2         default hr_api.g_varchar2,
  p_tsp_information8             in varchar2         default hr_api.g_varchar2,
  p_tsp_information9             in varchar2         default hr_api.g_varchar2,
  p_tsp_information10            in varchar2         default hr_api.g_varchar2,
  p_tsp_information11            in varchar2         default hr_api.g_varchar2,
  p_tsp_information12            in varchar2         default hr_api.g_varchar2,
  p_tsp_information13            in varchar2         default hr_api.g_varchar2,
  p_tsp_information14            in varchar2         default hr_api.g_varchar2,
  p_tsp_information15            in varchar2         default hr_api.g_varchar2,
  p_tsp_information16            in varchar2         default hr_api.g_varchar2,
  p_tsp_information17            in varchar2         default hr_api.g_varchar2,
  p_tsp_information18            in varchar2         default hr_api.g_varchar2,
  p_tsp_information19            in varchar2         default hr_api.g_varchar2,
  p_tsp_information20            in varchar2         default hr_api.g_varchar2,
  p_analysis_criteria_id         in number           default hr_api.g_number,
  p_validate                     in boolean      default false
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_skill_provision >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Course Other Information record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course Other Information record must exist
 *
 * <p><b>Post Success</b><br>
 * The Course Other Information record is deleted from the underlying system
 *
 * <p><b>Post Failure</b><br>
 * The API is unable to delete the Course Other Information record, an error is
 * thrown
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_skill_provision_id The unique identifier for the Course Other
 * Information record.
 * @param p_object_version_number Current version number of the Course Other
 * Information to be deleted
 * @rep:displayname Delete Course Other Information
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_COURSE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_skill_provision
  (
  p_skill_provision_id                 in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  );
end ota_skill_provision_api;

 

/
