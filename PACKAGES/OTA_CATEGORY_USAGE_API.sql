--------------------------------------------------------
--  DDL for Package OTA_CATEGORY_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CATEGORY_USAGE_API" AUTHID CURRENT_USER as
/* $Header: otctuapi.pkh 120.1.12010000.2 2009/07/24 10:51:35 shwnayak ship $ */
/*#
 * This package contains the category usage APIs that create or update a
 * Category or Delivery Mode.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Category Usage
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_category >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The business group that owns this category should exist.
 *
 * <p><b>Post Success</b><br>
 * Record for category created
 *
 * <p><b>Post Failure</b><br>
 * Record for category is not created and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.BUSINESS_GROUP_ID}
 * @param p_category {@rep:casecolumn OTA_CATEGORY_USAGES_TL.CATEGORY}
 * @param p_type The category's type. Valid values are defined in the
 * 'CATEGORY_TYPE' lookup type.
 * @param p_description {@rep:casecolumn OTA_CATEGORY_USAGES_TL.DESCRIPTION}
 * @param p_parent_cat_usage_id Since a category can be created within a
 * category, this value determines the category_usage_id of the parent
 * category. It should be a valid category_usage_id within the same business
 * group.
 * @param p_synchronous_flag This flag is used only for categories of type 'DM'
 * (Delivery Modes). Valid values are defined in the 'YES_NO' lookup type.
 * @param p_online_flag This flag is used only for category of type 'DM'
 * (Delivery Modes). Valid values are defined in the 'YES_NO' lookup type.
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
 * @param p_data_source {@rep:casecolumn OTA_CATEGORY_USAGES.DATA_SOURCE}
 * @param p_start_date_active {@rep:casecolumn
 * OTA_CATEGORY_USAGES.START_DATE_ACTIVE}
 * @param p_end_date_active {@rep:casecolumn
 * OTA_CATEGORY_USAGES.END_DATE_ACTIVE}
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @param p_object_version_number If p_validate is false, then it is set to the
 * version number of the created external learning. If p_validate is true, then
 * the value is null.
 * @param p_comments If profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @rep:displayname Create Category
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CATALOG_CAT_USE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_category                      in     varchar2
  ,p_type                          in	  varchar2
  ,p_description                   in     varchar2
  ,p_parent_cat_usage_id           in	  number
  ,p_synchronous_flag              in	  varchar2
  ,p_online_flag                   in	  varchar2 default null
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
  ,p_data_source                   in     varchar2 default null
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date default null
  ,p_category_usage_id             out nocopy number
  ,p_object_version_number         out nocopy number
  ,p_comments                      in     varchar2 default null
  ,p_user_group_id                 in     number default null

  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_category >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Category record must exist for the user.
 *
 * <p><b>Post Success</b><br>
 * Record for category is updated
 *
 * <p><b>Post Failure</b><br>
 * Record for category is not update and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * category to be updated. When the API completes, if p_validate is false, the
 * number is set to the new version number of the updated category. If
 * p_validate is true the number remains unchanged.
 * @param p_category {@rep:casecolumn OTA_CATEGORY_USAGES_TL.CATEGORY}
 * @param p_type The category's type. Valid values are defined in the
 * 'CATEGORY_TYPE' lookup type.
 * @param p_description {@rep:casecolumn OTA_CATEGORY_USAGES_TL.DESCRIPTION}
 * @param p_parent_cat_usage_id Since a category can be created within a
 * category, this value determines the category_usage_id of the parent
 * category. It should be a valid category_usage_id within the same business
 * group.
 * @param p_synchronous_flag This flag is used only for categories of type 'DM'
 * (Delivery Mode). Valid values are defined in the 'YES_NO' lookup type.
 * @param p_online_flag This flag is used only for categories of type 'DM'
 * (Delivery Mode). Valid values are defined in the 'YES_NO' lookup type.
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
 * @param p_data_source {@rep:casecolumn OTA_CATEGORY_USAGES.DATA_SOURCE}
 * @param p_start_date_active {@rep:casecolumn
 * OTA_CATEGORY_USAGES.START_DATE_ACTIVE}
 * @param p_end_date_active {@rep:casecolumn
 * OTA_CATEGORY_USAGES.END_DATE_ACTIVE}
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @rep:displayname Update Category
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CATALOG_CAT_USE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_category_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_category                      in     varchar2
  ,p_type                          in	  varchar2
  ,p_description                   in     varchar2
  ,p_parent_cat_usage_id           in	  number
  ,p_synchronous_flag              in	  varchar2
  ,p_online_flag                   in	  varchar2 default null
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
  ,p_data_source                   in     varchar2 default null
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date default null
  ,p_comments                      in     varchar2 default null

  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_category >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Category record must exist for the user.
 *
 * <p><b>Post Success</b><br>
 * Record for category is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Record for category is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_category_usage_id {@rep:casecolumn
 * OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * category to be deleted.
 * @rep:displayname Delete Category
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CATALOG_CAT_USE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_category
  (p_validate                      in     boolean  default false
  ,p_category_usage_id             in     number
  ,p_object_version_number         in     number
  );

end ota_category_usage_api;

/
