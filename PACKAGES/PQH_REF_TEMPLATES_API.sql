--------------------------------------------------------
--  DDL for Package PQH_REF_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REF_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: pqrftapi.pkh 120.1 2005/10/02 02:27:21 aroussel $ */
/*#
 * This package contains reference template APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Reference Templates
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ref_template >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a reference template.
 *
 * A reference template allows attributes and the attribute permissions of an
 * existing template to be either referenced or copied by another template.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template whose attributes are referenced or copied by the parent
 * template, must already exist.
 *
 * <p><b>Post Success</b><br>
 * The reference template will be successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The reference template will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_ref_template_id If p_validate is false, then this uniquely
 * identifies the reference template created. If p_validate is true, then set
 * to null.
 * @param p_base_template_id The template whose attributes are referenced or
 * copied by the parent template.
 * @param p_parent_template_id The referencing template.
 * @param p_reference_type_cd Indicates if the base template attributes should
 * be referenced or copied. Valid values are defined by 'PQH_REFERENCE_TYPE'
 * lookup_type
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created reference template. If p_validate is true,
 * then the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Reference Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_REF_TEMPLATE
(
   p_validate                       in boolean    default false
  ,p_ref_template_id                out nocopy number
  ,p_base_template_id               in  number
  ,p_parent_template_id             in  number
  ,p_reference_type_cd             in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ref_template >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a reference template record.
 *
 * The current template may either copy or reference attributes along with the
 * attribute permissions from the base template. If the attributes are copied,
 * then the attribute permissions can be edited for the current template.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template whose attributes are referenced or copied by the parent
 * template, must already exist.
 *
 * <p><b>Post Success</b><br>
 * The reference template will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The reference template will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_ref_template_id Identifies the reference template record to be
 * modified.
 * @param p_base_template_id The template whose attributes are referenced or
 * copied by the parent template.
 * @param p_parent_template_id The referencing template.
 * @param p_reference_type_cd Indicates if the base template attributes should
 * be referenced or copied. Valid values are defined by 'PQH_REFERENCE_TYPE'
 * lookup_type
 * @param p_object_version_number Pass in the current version number of the
 * reference template to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated reference
 * template. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Reference Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_REF_TEMPLATE
  (
   p_validate                       in boolean    default false
  ,p_ref_template_id                in  number
  ,p_base_template_id               in  number    default hr_api.g_number
  ,p_parent_template_id             in  number    default hr_api.g_number
  ,p_reference_type_cd              in varchar2   default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ref_template >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API deletes the reference template record.
 *
 * When the reference template is deleted, the attributes copied from the base
 * template will not be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The parent template must have an unfrozen status, before any templates it
 * refers can be deleted.
 *
 * <p><b>Post Success</b><br>
 * The reference template will be successfully deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The reference template will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_ref_template_id Identifies the reference template record to be
 * deleted.
 * @param p_object_version_number Current version number of the reference
 * template to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Reference Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_REF_TEMPLATE
  (
   p_validate                       in boolean        default false
  ,p_ref_template_id                in number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  );
--
--
end pqh_REF_TEMPLATES_api;

 

/
