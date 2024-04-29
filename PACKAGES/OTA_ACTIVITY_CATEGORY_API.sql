--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_CATEGORY_API" AUTHID CURRENT_USER as
/* $Header: otaciapi.pkh 120.1 2005/10/02 02:07:13 aroussel $ */
/*#
 * This package contains the Course Category API.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Course Category
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_act_cat_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a course-to-category association.
 *
 * This business process allows the user to create a course-to-category
 * association identified by a course identifier (p_activity_version_id ) and
 * category identifier (p_category_usage_id)
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Course and the Category for which this association is being created must
 * be defined
 *
 * <p><b>Post Success</b><br>
 * An association between the course and category is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a member record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_activity_category Obsoleted.
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created course category inclusion. If p_validate is
 * true, then the value will be null.
 * @param p_aci_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_aci_information1 Descriptive flexfield segment.
 * @param p_aci_information2 Descriptive flexfield segment.
 * @param p_aci_information3 Descriptive flexfield segment.
 * @param p_aci_information4 Descriptive flexfield segment.
 * @param p_aci_information5 Descriptive flexfield segment.
 * @param p_aci_information6 Descriptive flexfield segment.
 * @param p_aci_information7 Descriptive flexfield segment.
 * @param p_aci_information8 Descriptive flexfield segment.
 * @param p_aci_information9 Descriptive flexfield segment.
 * @param p_aci_information10 Descriptive flexfield segment.
 * @param p_aci_information11 Descriptive flexfield segment.
 * @param p_aci_information12 Descriptive flexfield segment.
 * @param p_aci_information13 Descriptive flexfield segment.
 * @param p_aci_information14 Descriptive flexfield segment.
 * @param p_aci_information15 Descriptive flexfield segment.
 * @param p_aci_information16 Descriptive flexfield segment.
 * @param p_aci_information17 Descriptive flexfield segment.
 * @param p_aci_information18 Descriptive flexfield segment.
 * @param p_aci_information19 Descriptive flexfield segment.
 * @param p_aci_information20 Descriptive flexfield segment.
 * @param p_start_date_active Start Date
 * @param p_end_date_active End Date
 * @param p_primary_flag Primary Indicator. Can be only 'Y' or 'N'
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @rep:displayname Create Course Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_CATALOG_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_act_cat_inclusion
  (p_validate                      in     boolean  default false,
  p_effective_date                in     date,
  p_activity_version_id          in  number,
  p_activity_category            in  varchar2,
  p_comments                     in  varchar2  default null,
  p_object_version_number        out nocopy number,
  p_aci_information_category     in  varchar2  default null,
  p_aci_information1             in  varchar2  default null,
  p_aci_information2             in  varchar2  default null,
  p_aci_information3             in  varchar2  default null,
  p_aci_information4             in  varchar2  default null,
  p_aci_information5             in  varchar2  default null,
  p_aci_information6             in  varchar2  default null,
  p_aci_information7             in  varchar2  default null,
  p_aci_information8             in  varchar2  default null,
  p_aci_information9             in  varchar2  default null,
  p_aci_information10            in  varchar2  default null,
  p_aci_information11            in  varchar2  default null,
  p_aci_information12            in  varchar2  default null,
  p_aci_information13            in  varchar2  default null,
  p_aci_information14            in  varchar2  default null,
  p_aci_information15            in  varchar2  default null,
  p_aci_information16            in  varchar2  default null,
  p_aci_information17            in  varchar2  default null,
  p_aci_information18            in  varchar2  default null,
  p_aci_information19            in  varchar2  default null,
  p_aci_information20            in  varchar2  default null,
  p_start_date_active            in  date      default null,
  p_end_date_active              in  date      default null,
  p_primary_flag                 in  varchar2  default 'N',
  p_category_usage_id            in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_act_cat_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a course-to-category association.
 *
 * This business process allows the user to update a course-to-category
 * association identified by a course identifier (p_activity_version_id ) and
 * category identifier (p_category_usage_id).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The course and the category for which this association is being created must
 * be defined.
 *
 * <p><b>Post Success</b><br>
 * The Course Category Association is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The Course Category Association is not updated. An error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_activity_category Obsoleted.
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_object_version_number Passes in the current version number of the
 * Course category inclusion to be updated. When the API completes, if
 * p_validate is false, the number is set to the new version number of the
 * updated Course category inclusion. If p_validate is true, the number is set
 * to the default value (null)
 * @param p_aci_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_aci_information1 Descriptive flexfield segment.
 * @param p_aci_information2 Descriptive flexfield segment.
 * @param p_aci_information3 Descriptive flexfield segment.
 * @param p_aci_information4 Descriptive flexfield segment.
 * @param p_aci_information5 Descriptive flexfield segment.
 * @param p_aci_information6 Descriptive flexfield segment.
 * @param p_aci_information7 Descriptive flexfield segment.
 * @param p_aci_information8 Descriptive flexfield segment.
 * @param p_aci_information9 Descriptive flexfield segment.
 * @param p_aci_information10 Descriptive flexfield segment.
 * @param p_aci_information11 Descriptive flexfield segment.
 * @param p_aci_information12 Descriptive flexfield segment.
 * @param p_aci_information13 Descriptive flexfield segment.
 * @param p_aci_information14 Descriptive flexfield segment.
 * @param p_aci_information15 Descriptive flexfield segment.
 * @param p_aci_information16 Descriptive flexfield segment.
 * @param p_aci_information17 Descriptive flexfield segment.
 * @param p_aci_information18 Descriptive flexfield segment.
 * @param p_aci_information19 Descriptive flexfield segment.
 * @param p_aci_information20 Descriptive flexfield segment.
 * @param p_start_date_active Start Date
 * @param p_end_date_active End Date
 * @param p_primary_flag Primary Indicator. Can be only 'Y' or 'N'
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @rep:displayname Update Course Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_CATALOG_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_act_cat_inclusion
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_activity_version_id          in number
  ,p_activity_category            in varchar2
  ,p_comments                     in varchar2     default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_aci_information_category     in varchar2     default hr_api.g_varchar2
  ,p_aci_information1             in varchar2     default hr_api.g_varchar2
  ,p_aci_information2             in varchar2     default hr_api.g_varchar2
  ,p_aci_information3             in varchar2     default hr_api.g_varchar2
  ,p_aci_information4             in varchar2     default hr_api.g_varchar2
  ,p_aci_information5             in varchar2     default hr_api.g_varchar2
  ,p_aci_information6             in varchar2     default hr_api.g_varchar2
  ,p_aci_information7             in varchar2     default hr_api.g_varchar2
  ,p_aci_information8             in varchar2     default hr_api.g_varchar2
  ,p_aci_information9             in varchar2     default hr_api.g_varchar2
  ,p_aci_information10            in varchar2     default hr_api.g_varchar2
  ,p_aci_information11            in varchar2     default hr_api.g_varchar2
  ,p_aci_information12            in varchar2     default hr_api.g_varchar2
  ,p_aci_information13            in varchar2     default hr_api.g_varchar2
  ,p_aci_information14            in varchar2     default hr_api.g_varchar2
  ,p_aci_information15            in varchar2     default hr_api.g_varchar2
  ,p_aci_information16            in varchar2     default hr_api.g_varchar2
  ,p_aci_information17            in varchar2     default hr_api.g_varchar2
  ,p_aci_information18            in varchar2     default hr_api.g_varchar2
  ,p_aci_information19            in varchar2     default hr_api.g_varchar2
  ,p_aci_information20            in varchar2     default hr_api.g_varchar2
  ,p_start_date_active            in date         default hr_api.g_date
  ,p_end_date_active              in date         default hr_api.g_date
  ,p_primary_flag                 in varchar2     default hr_api.g_varchar2
  ,p_category_usage_id            in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_act_cat_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a course-to-category association.
 *
 * This business process allows the user to delete a course-to-category
 * association identified by a course identifier (p_activity_version_id ) and
 * category identifier (p_category_usage_id).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The inclusion as well as the course and category must exist
 *
 * <p><b>Post Success</b><br>
 * The course category inclusion is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the course category association record and raises an
 * error.
 * @param p_activity_version_id {@rep:casecolumn
 * OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID}
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @param p_object_version_number Passes in the current version number of the
 * course-to-category inclusion to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Course Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_CATALOG_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_act_cat_inclusion
  ( p_activity_version_id                in number,
  p_category_usage_id                   in varchar2,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  );
end ota_activity_category_api;

 

/
