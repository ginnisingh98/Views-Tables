--------------------------------------------------------
--  DDL for Package PQH_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: pqtemapi.pkh 120.1 2005/10/02 02:28:32 aroussel $ */
/*#
 * This package contains transaction template APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Transaction Template
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_generic_template >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a transaction template.
 *
 * The transaction template affects which fields in a transaction workflow
 * recipients can view and edit appropriate to the task and their workflow
 * role.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction category must exist for which the transaction template is
 * defined.
 *
 * <p><b>Post Success</b><br>
 * The transaction template will be successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The transaction template will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_name {@rep:casecolumn PQH_TEMPLATES.TEMPLATE_NAME}
 * @param p_short_name {@rep:casecolumn PQH_TEMPLATES.SHORT_NAME}
 * @param p_template_id If p_validate is false, then this uniquely identifies
 * the template created. If p_validate is true, then set to null.
 * @param p_attribute_only_flag Identifies if the current template can
 * reference other templates. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_enable_flag Identifies if the templates is Enabled/Disabled. Valid
 * values are defined by 'YES_NO' lookup_type.
 * @param p_create_flag Identifies if the template is create or update task
 * template. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_transaction_category_id {@rep:casecolumn
 * PQH_TEMPLATES.TRANSACTION_CATEGORY_ID}
 * @param p_under_review_flag Indicates if a transaction is to be placed under
 * review after the template is applied to it. It is applicable for update task
 * templates only. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created template. If p_validate is true, then the
 * value will be null.
 * @param p_freeze_status_cd Identifies if the template setup is frozen or not.
 * Valid values are defined by 'PQH_TEMPLATE_FREEZE_STATUS' lookup_type.
 * @param p_template_type_cd Identifies if the template is a task or role
 * template. Valid values are defined by 'PQH_TEMPLATE_TYPE' lookup type.
 * @param p_legislation_code {@rep:casecolumn PQH_TEMPLATES.LEGISLATION_CODE}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @rep:displayname Create Transaction Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_GENERIC_TEMPLATE
(
   p_validate                       in boolean    default false
  ,p_template_name                  in  varchar2
  ,p_short_name                     in  varchar2
  ,p_template_id                    out nocopy number
  ,p_attribute_only_flag            in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_create_flag                    in  varchar2  default null
  ,p_transaction_category_id        in  number
  ,p_under_review_flag              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_freeze_status_cd               in  varchar2  default null
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_generic_template >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the transaction template that affects which fields workflow
 * recipients can view and edit appropriate to the task and their workflow
 * role.
 *
 * A transaction template can be updated only if the setup is not frozen.
 * Seeded task and role templates do not allow edit.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Transaction template must be unfrozen before it can be updated.
 *
 * <p><b>Post Success</b><br>
 * The transaction template details will be updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The transaction template will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_name {@rep:casecolumn PQH_TEMPLATES.TEMPLATE_NAME}
 * @param p_short_name {@rep:casecolumn PQH_TEMPLATES.SHORT_NAME}
 * @param p_template_id Identifies the template record to be modified.
 * @param p_attribute_only_flag Identifies if the current template can
 * reference other templates. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_enable_flag Identifies if the templates is Enabled/Disabled. Valid
 * values are defined by 'YES_NO' lookup_type.
 * @param p_create_flag Identifies if the template is create or update task
 * template. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_transaction_category_id {@rep:casecolumn
 * PQH_TEMPLATES.TRANSACTION_CATEGORY_ID}
 * @param p_under_review_flag Identifies if a transaction is to be placed under
 * review after the template is applied to it. It is applicable for update task
 * templates only. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_object_version_number Pass in the current version number of the
 * template to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated template. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_freeze_status_cd Indicates if the template setup is frozen or not.
 * Valid values are defined by 'PQH_TEMPLATE_FREEZE_STATUS' lookup_type.
 * @param p_template_type_cd Identifies if the template is a task or role
 * template. Valid values are defined by 'PQH_TEMPLATE_TYPE' lookup type.
 * @param p_legislation_code {@rep:casecolumn PQH_TEMPLATES.LEGISLATION_CODE}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @rep:displayname Update Transaction Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_GENERIC_TEMPLATE
  (
   p_validate                       in boolean    default false
  ,p_template_name                  in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_template_id                    in  number
  ,p_attribute_only_flag            in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_create_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_under_review_flag              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_freeze_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_generic_template >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the transaction template that affects which fields workflow
 * recipients can view and edit appropriate to the task and their workflow
 * role.
 *
 * Seeded task and role templates cannot be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The template can be deleted only if it has no template attributes. The
 * template must not be referenced by other templates nor should it reference
 * other templates. It must not be used to restrict the edit/view privilege of
 * fields in a transaction.
 *
 * <p><b>Post Success</b><br>
 * The template will be deleted from the database successfully.
 *
 * <p><b>Post Failure</b><br>
 * The template will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_id Identifies the template record to be deleted.
 * @param p_object_version_number Current version number of the template to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Transaction Template
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_TRANS_TEMPLATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_GENERIC_TEMPLATE
  (
   p_validate                       in boolean        default false
  ,p_template_id                    in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
end pqh_TEMPLATES_api;

 

/
