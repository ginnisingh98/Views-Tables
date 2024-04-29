--------------------------------------------------------
--  DDL for Package PQH_BUDGET_VERSIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_VERSIONS_API" AUTHID CURRENT_USER as
/* $Header: pqbvrapi.pkh 120.1 2005/10/02 02:26:21 aroussel $ */
/*#
 * This package contains APIs to create, update or delete budget versions.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Version
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_budget_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the budget version.
 *
 * Budget for a date range is created. An existing budget is divided into
 * different versions. Each version has a date range. In order to successfully
 * run reports, create a budget version that is valid for the budget and is
 * within the budget end date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A budget should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget version will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget version will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_version_id If p_validate is false, then this uniquely
 * identifies the budget version record created. If p_validate is true, then
 * set to null.
 * @param p_budget_id Budget identifier.
 * @param p_version_number Budget version number.
 * @param p_date_from Budget start date.
 * @param p_date_to Budget end date.
 * @param p_transfered_to_gl_flag Indicates version transfer to GL allowed or
 * not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_gl_status GL posting status. Possible values are Post, Error or
 * Null.
 * @param p_xfer_to_other_apps_cd Indicates the transfer to other applications.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget version. If p_validate is true, then
 * the value will be null.
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT3_AVAILABLE}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Budget Version
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_version
(
   p_validate                       in boolean    default false
  ,p_budget_version_id              out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_version_number                 in  number    default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_transfered_to_gl_flag          in  varchar2  default null
  ,p_gl_status                      in  varchar2  default null
  ,p_xfer_to_other_apps_cd          in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_budget_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the budget version.
 *
 * Budget for a date range is updated. An existing budget is divided into
 * different versions. Each version has a date range. In order to successfully
 * run reports, update budget version in such a way that it is valid for the
 * budget and is within the budget end date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The budget version and the corresponding budget should be valid.
 *
 * <p><b>Post Success</b><br>
 * Budget version will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget version will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_version_id Identifies the budget version to be updated.
 * @param p_budget_id Budget identifier.
 * @param p_version_number Budget version number.
 * @param p_date_from Budget start date.
 * @param p_date_to Budget end date.
 * @param p_transfered_to_gl_flag Indicates version transfer to GL allowed or
 * not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_gl_status GL posting status. Possible values are Post, Error or
 * Null.
 * @param p_xfer_to_other_apps_cd Indicates the transfer to other applications.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * budget version to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated budget version. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_VERSIONS.BUDGET_UNIT3_AVAILABLE}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Budget Version
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_version
  (
   p_validate                       in boolean    default false
  ,p_budget_version_id              in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_version_number                 in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_transfered_to_gl_flag          in  varchar2  default hr_api.g_varchar2
  ,p_gl_status                      in  varchar2  default hr_api.g_varchar2
  ,p_xfer_to_other_apps_cd          in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_budget_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes budget details record.
 *
 * Budget for a date range is deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The budget version to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget version will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget version will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_version_id This uniquely identifies the budget version.
 * @param p_object_version_number Current version number of the budget version
 * to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Budget Version
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_version
  (
   p_validate                       in boolean        default false
  ,p_budget_version_id              in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
end pqh_budget_versions_api;

 

/
