--------------------------------------------------------
--  DDL for Package OTA_LP_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_CATEGORY_API" AUTHID CURRENT_USER as
/* $Header: otlciapi.pkh 120.1 2005/10/02 02:07:34 aroussel $ */
/*#
 * This package contains Learning Path Category Inclusion APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Learning Path Category Inclusion
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_lp_cat_inclusion >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Learning Path Category Inclusion that associates a
 * learning path with a category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Learning Path and the Category must exist.
 *
 * <p><b>Post Success</b><br>
 * The Learning Path is associated to the given Category.
 *
 * <p><b>Post Failure</b><br>
 * The learning path category inclusion will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_learning_path_id The unique identifier of the learning path to
 * which the category is being attached.
 * @param p_category_usage_id The unique identifier of the category to which
 * the learning path is being attached.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created learning path category Inclusion
 * record. If p_validate is true, then the value is null.
 * @param p_start_date_active {@rep:casecolumn
 * OTA_LP_CAT_INCLUSIONS.START_DATE_ACTIVE}
 * @param p_end_date_active {@rep:casecolumn
 * OTA_LP_CAT_INCLUSIONS.END_DATE_ACTIVE}
 * @param p_primary_flag {@rep:casecolumn OTA_LP_CAT_INCLUSIONS.PRIMARY_FLAG}
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
 * @rep:displayname Create Learning Path Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_lp_cat_inclusion
  (p_validate               in  boolean  default false,
  p_effective_date          in  date,
  p_learning_path_id        in  number,
   p_category_usage_id      in  number ,
  p_object_version_number   out nocopy number,
  p_start_date_active      in  date      default null,
  p_end_date_active        in  date      default null,
  p_primary_flag           in  varchar2  default 'N',
  p_attribute_category     in  varchar2  default null,
  p_attribute1             in  varchar2  default null,
  p_attribute2             in  varchar2  default null,
  p_attribute3             in  varchar2  default null,
  p_attribute4             in  varchar2  default null,
  p_attribute5             in  varchar2  default null,
  p_attribute6             in  varchar2  default null,
  p_attribute7             in  varchar2  default null,
  p_attribute8             in  varchar2  default null,
  p_attribute9             in  varchar2  default null,
  p_attribute10            in  varchar2  default null,
  p_attribute11            in  varchar2  default null,
  p_attribute12            in  varchar2  default null,
  p_attribute13            in  varchar2  default null,
  p_attribute14            in  varchar2  default null,
  p_attribute15            in  varchar2  default null,
  p_attribute16            in  varchar2  default null,
  p_attribute17            in  varchar2  default null,
  p_attribute18            in  varchar2  default null,
  p_attribute19            in  varchar2  default null,
  p_attribute20            in  varchar2  default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lp_cat_inclusion >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Learning Path Category Inclusion.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path category inclusion should exist.
 *
 * <p><b>Post Success</b><br>
 * The Learning path category inclusion will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The learning path category inclusion will not be updated and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_learning_path_id The Identifier of a Learning Path that is to be
 * added to the plan.
 * @param p_object_version_number Pass in the current version number of the
 * learning path category Inclusion record to be updated. When the API
 * completes, if p_validate is false, the number is set to the new version
 * number of the updated learning path category Inclusion record. If p_validate
 * is true, the number remains unchanged.
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
 * @param p_start_date_active {@rep:casecolumn
 * OTA_LP_CAT_INCLUSIONS.START_DATE_ACTIVE}
 * @param p_end_date_active {@rep:casecolumn
 * OTA_LP_CAT_INCLUSIONS.END_DATE_ACTIVE}
 * @param p_primary_flag {@rep:casecolumn OTA_LP_CAT_INCLUSIONS.PRIMARY_FLAG}
 * @param p_category_usage_id The unique identifier of the category to which
 * the learning path is being attached.
 * @rep:displayname Update Learning Path Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_lp_cat_inclusion
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_id          in number
  ,p_object_version_number        in out nocopy number
  ,p_attribute_category     in varchar2     default hr_api.g_varchar2
  ,p_attribute1             in varchar2     default hr_api.g_varchar2
  ,p_attribute2             in varchar2     default hr_api.g_varchar2
  ,p_attribute3             in varchar2     default hr_api.g_varchar2
  ,p_attribute4             in varchar2     default hr_api.g_varchar2
  ,p_attribute5             in varchar2     default hr_api.g_varchar2
  ,p_attribute6             in varchar2     default hr_api.g_varchar2
  ,p_attribute7             in varchar2     default hr_api.g_varchar2
  ,p_attribute8             in varchar2     default hr_api.g_varchar2
  ,p_attribute9             in varchar2     default hr_api.g_varchar2
  ,p_attribute10            in varchar2     default hr_api.g_varchar2
  ,p_attribute11            in varchar2     default hr_api.g_varchar2
  ,p_attribute12            in varchar2     default hr_api.g_varchar2
  ,p_attribute13            in varchar2     default hr_api.g_varchar2
  ,p_attribute14            in varchar2     default hr_api.g_varchar2
  ,p_attribute15            in varchar2     default hr_api.g_varchar2
  ,p_attribute16            in varchar2     default hr_api.g_varchar2
  ,p_attribute17            in varchar2     default hr_api.g_varchar2
  ,p_attribute18            in varchar2     default hr_api.g_varchar2
  ,p_attribute19            in varchar2     default hr_api.g_varchar2
  ,p_attribute20            in varchar2     default hr_api.g_varchar2
  ,p_start_date_active            in date         default hr_api.g_date
  ,p_end_date_active              in date         default hr_api.g_date
  ,p_primary_flag                 in varchar2     default hr_api.g_varchar2
  ,p_category_usage_id            in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_cat_inclusion >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Inclusion of a Learning Path into a Category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path category inclusion should exist.
 *
 * <p><b>Post Success</b><br>
 * The inclusion of the learning path into the category is successfully
 * deleted.
 *
 * <p><b>Post Failure</b><br>
 * The learning path category inclusion is not deleted and an error is raised.
 * @param p_learning_path_id The unique identifier of the learning path to
 * which the category is being attached.
 * @param p_category_usage_id The unique identifier of the category to which
 * the learning path is being attached.
 * @param p_object_version_number The current version number of the learning
 * path category Inclusion record to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Learning Path Category Inclusion
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_CATEGORY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_lp_cat_inclusion
  ( p_learning_path_id                in number,
  p_category_usage_id                   in varchar2,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  );
end ota_lp_category_api;

 

/
