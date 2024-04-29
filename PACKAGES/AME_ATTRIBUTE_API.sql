--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_API" AUTHID CURRENT_USER as
/* $Header: amatrapi.pkh 120.3.12010000.2 2019/09/12 12:02:21 jaakhtar ship $ */
/*#
 * This package contains AME Attribute APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_attribute >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a new attribute and creates an attribute usage
 * for a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 *  Application Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * The attribute and the usage is created.
 *
 * <p><b>Post Failure</b><br>
 * The attribute is not created and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_LANGUAGE_CODE Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param P_NAME This is the unique attribute name given to an attribute
 * while creating it.
 * @param P_DESCRIPTION This parameter contains the description for the
 * attribute.
 * @param P_ATTRIBUTE_TYPE This parameter contains the type of the attribute.
 * Valid values of attribute type are defined in AME_ATTRIBUTE_DATA_TYPE
 * lookup type.
 * @param P_ITEM_CLASS_ID This uniquely identifies the item class to which
 * the attribute belongs.
 * @param P_APPROVER_TYPE_ID This uniquely identifies the approver type
 * associated with the attribute.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which attribute usage is to be created.
 * @param P_IS_STATIC This parameter tells whether the attribute usage is
 * static or dynamic.
 * @param P_QUERY_STRING This parameter is the query string for the attribute
 * usage and should not be null when P_IS_STATIC is false.
 * @param P_USER_EDITABLE This parameter tells whether the attribute is user
 * editable or not.
 * @param p_VALUE_SET_ID This uniquely identifies the value set associated
 * with the attribute usage.
 * @param P_ATTRIBUTE_ID If p_validate is false, then this uniquely
 * identifies the attribute created. If p_validate is true, then set to null.
 * @param P_ATR_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * version number of the created attribute. If p_validate is true,
 * then set to null.
 * @param P_ATR_START_DATE If p_validate is false, then set to the start date
 * for the created attribute. If p_validate is true, then set to null.
 * @param P_ATR_END_DATE It is the date up to, which the attribute is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @param P_ATU_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * version number of the created attribute usage. If p_validate is true,
 * then set to null.
 * @param P_ATU_START_DATE If p_validate is false, then set to the effective
 * start date for the created attribute usage. If p_validate is true,
 * then set to null.
 * @param P_ATU_END_DATE It is the date up to, which the attribute usage is
 * effective. If p_validate is false, then it is set to 31-Dec-4712. If
 * p_validate is true, then it is set to null.
 * @rep:displayname Create Ame Attribute
 * @rep:category BUSINESS_ENTITY AME_ATTRIBUTE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_attribute
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_type                in     varchar2
  ,p_item_class_id                 in     number
  ,p_approver_type_id              in     number   default null
  ,p_application_id                in     number   default null
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_user_editable                 in     varchar2 default ame_util.booleanTrue
  ,p_value_set_id                  in     number   default null
  ,p_attribute_id                     out nocopy   number
  ,p_atr_object_version_number        out nocopy   number
  ,p_atr_start_date                   out nocopy   date
  ,p_atr_end_date                     out nocopy   date
  ,p_atu_object_version_number        out nocopy   number
  ,p_atu_start_date                   out nocopy   date
  ,p_atu_end_date                     out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_attribute_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates an attribute usage for a given transaction type for an
 * existing attribute.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Application Id and attribute Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Attribute usage is created.
 *
 * <p><b>Post Failure</b><br>
 * Attribute Usage is not created and error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_ATTRIBUTE_ID If p_validate is false, then this uniquely identifies
 * the attribute for which a usage has to be created. If p_validate is true,
 * then it is set to null.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which attribute usage is to be created.
 * @param P_IS_STATIC This parameter tells whether the attribute is static or
 * dynamic.
 * @param P_QUERY_STRING This parameter is the query string for the attribute
 * and should not be null when P_IS_STATIC is false.
 * @param P_USER_EDITABLE This parameter tells whether the attribute is user
 * editable or not.
 * @param p_VALUE_SET_ID This uniquely identifies the value set associated
 * with the attribute.
 * @param P_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * version number of the created item class usage. If p_validate is true,
 * then set to null.
 * @param P_START_DATE If p_validate is false, then set to the start date
 * for the created attribute usage. If p_validate is true, then set to null.
 * @param P_END_DATE It is the date up to, which the attribute usage is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Create Ame Attribute Usage
 * @rep:category BUSINESS_ENTITY AME_ATTRIBUTE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_user_editable                 in     varchar2 default ame_util.booleanTrue
  ,p_value_set_id                  in     number   default null
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ame_attribute >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API Updates the attribute definition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Attribute Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Updates the attribute Successfully.
 *
 * <p><b>Post Failure</b><br>
 * The attribute is not updated and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_LANGUAGE_CODE Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param P_ATTRIBUTE_ID This uniquely identifies the attribute to be updated.
 * @param P_DESCRIPTION This is the description of the attribute.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * attribute to be updated. When the API completes, if p_validate is
 * false, it will be set to the new version number of the updated
 * attribute. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, then set to the start date
 * for the updated attribute. If p_validate is true, then set to null.
 * @param P_END_DATE It is the date up to, which the attribute is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Update Ame Attribute
 * @rep:category BUSINESS_ENTITY AME_ATTRIBUTE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_attribute
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_attribute_id                  in     number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ame_attribute_usage >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates the attribute usage definition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Application Id and attribute Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Attribute usage is updated successfully for the entered transaction type.
 *
 * <p><b>Post Failure</b><br>
 * The attribute usage is not updated and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_ATTRIBUTE_ID This uniquely identifies the attribute for the
 * application id.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which attribute usage is to be updated.
 * @param P_IS_STATIC This parameter tells whether the attribute usage is
 * static or dynamic.
 * @param P_QUERY_STRING This parameter is the query string for the attribute
 * usage and should not be null when P_IS_STATIC is false.
 * @param p_VALUE_SET_ID This uniquely identifies the value set associated
 * with the attribute usage.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * attribute usage to be updated. When the API completes, if p_validate is
 * false, it will be set to the new version number of the updated
 * attribute usage. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, then set to the start date
 * for the updated attribute usage. If p_validate is true, then set to null.
 * @param P_END_DATE It is the date up to, which the attribute usage is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Update Ame Attribute Usage
 * @rep:category BUSINESS_ENTITY AME_ATTRIBUTE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_value_set_id                  in     number   default null
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ame_attribute_usage >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes the attribute usage from the given transaction type.
 *
 * This API delete the attribute usage from the transaction type and if this
 * usage is the last usage for the attribute and no other transaction type is
 * using this attribute then the attribute is also deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Application Id and attribute Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Deletes the attribute usage successfully.
 *
 * <p><b>Post Failure</b><br>
 * The attribute usage is not deleted and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_ATTRIBUTE_ID This uniquely identifies the attribute.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which attribute usage is to be deleted.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * attribute usage to be deleted. When the API completes, if p_validate
 * is false, it will be set to the new version number of the deleted
 * attribute usage. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, then set to the start date
 * for the deleted attribute usage. If p_validate is true, then set to null.
 * @param P_END_DATE f p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Delete Ame Attribute Usage
 * @rep:category BUSINESS_ENTITY AME_ATTRIBUTE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
-- -----------------------------------------------------------------------
-- |---------------------------< updateUseCount >------------------------|
-- -----------------------------------------------------------------------
  procedure updateUseCount(p_attribute_id              in integer
                          ,p_application_id            in integer
                          ,p_atu_object_version_number in integer);
--
--
end ame_attribute_api;

/
