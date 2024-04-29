--------------------------------------------------------
--  DDL for Package PQH_TEMPLATE_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATE_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqtatapi.pkh 120.1 2005/10/02 02:28:15 aroussel $ */
/*#
 * This package contains template attribute APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Template Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_template_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a template attribute.
 *
 * The template is associated with a transaction type. Only attributes attached
 * to the transaction type can be chosen as template attributes.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template for which the template attribute is created must already exist.
 * The template must not be frozen. Only the transaction category attributes
 * attached to the transaction type of the template, which are marked as
 * selected can be selected as template attributes.
 *
 * <p><b>Post Success</b><br>
 * The template attribute is created successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The template attribute is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_required_flag Indicates if the attribute is a required attribute
 * for which the user must provide a value in the transaction.
 * @param p_view_flag Indicates if the attribute value can be viewed in the
 * transaction.
 * @param p_edit_flag Indicates if the attribute value can be edited in the
 * transaction.
 * @param p_template_attribute_id If p_validate is false, then this uniquely
 * identifies the template attribute created. If p_validate is true, then set
 * to null.
 * @param p_attribute_id {@rep:casecolumn PQH_TEMPLATE_ATTRIBUTES.ATTRIBUTE_ID}
 * @param p_template_id {@rep:casecolumn PQH_TEMPLATE_ATTRIBUTES.TEMPLATE_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created template attribute. If p_validate is true,
 * then the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Template Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_TEMPLATE_ATTRIBUTE
(
   p_validate                       in boolean    default false
  ,p_required_flag                  in  varchar2  default null
  ,p_view_flag                      in  varchar2  default null
  ,p_edit_flag                      in  varchar2  default null
  ,p_template_attribute_id          out nocopy number
  ,p_attribute_id                   in  number    default null
  ,p_template_id                    in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_template_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates template attribute details.
 *
 * The attribute permissions, for example, whether the attribute is viewable or
 * editable or required can be updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template attribute which is to be updated must already exist. The
 * template to which the template attribute is attached must be in unfrozen
 * state.
 *
 * <p><b>Post Success</b><br>
 * The template attribute Is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The template attribute is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_required_flag Indicates if the attribute is a required attribute
 * for which the user must provide a value in the transaction.
 * @param p_view_flag Indicates if the attribute value can be viewed in the
 * transaction.
 * @param p_edit_flag Indicates if the attribute value can be edited in the
 * transaction.
 * @param p_template_attribute_id Identifies uniquely the template attribute
 * record to be modified.
 * @param p_attribute_id {@rep:casecolumn PQH_TEMPLATE_ATTRIBUTES.ATTRIBUTE_ID}
 * @param p_template_id {@rep:casecolumn PQH_TEMPLATE_ATTRIBUTES.TEMPLATE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * template attribute to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated template
 * attribute. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Template Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_TEMPLATE_ATTRIBUTE
  (
   p_validate                       in boolean    default false
  ,p_required_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_view_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_edit_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_template_attribute_id          in  number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_template_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the template attribute.
 *
 * The template attribute is deleted from pqh_template_attributes table. The
 * deleted attribute can be selected again and associated with the template and
 * the attribute permissions can be edited.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template attribute to be deleted must already exist. The template to
 * which the template attribute is attached must be in unfrozen state.
 *
 * <p><b>Post Success</b><br>
 * The template attribute is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The template attribute is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_attribute_id Identifies uniquely the template attribute
 * record to be deleted.
 * @param p_object_version_number Current version number of the template
 * attribute to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Template Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_TEMPLATE_ATTRIBUTE
  (
   p_validate                       in boolean        default false
  ,p_template_attribute_id          in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
--
procedure create_update_copied_attribute
  (
   p_copied_attributes      in     pqh_prvcalc.t_attid_priv,
   p_template_id            in     number
  );
--
--
--
end pqh_TEMPLATE_ATTRIBUTES_api;

 

/
