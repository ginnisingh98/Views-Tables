--------------------------------------------------------
--  DDL for Package PAY_CNU_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_API" AUTHID CURRENT_USER as
/* $Header: pycnuapi.pkh 120.1 2005/10/02 02:29:59 aroussel $ */
/*#
 * This package contains Contribution Usage APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contribution Usage
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_contribution_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allows the user to create a contribution usage for a business group
 * for France.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group and associated lookups must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The contribution usage record is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a contribution usage, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating which lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_date_from Date from which the row applies
 * @param p_date_to Date after which the row no longer applies
 * @param p_group_code The group code for the contribution type. Valid values
 * exist in either the 'FR_ELEMENT_GROUP' lookup type, or the
 * 'FR_USER_ELEMENT_GROUP' lookup type.
 * @param p_process_type The process type for the contribution type.Valid
 * values exist in the 'FR_PROCESS_TYPE' lookup type.
 * @param p_element_name The element name used by this contribution type.
 * @param p_contribution_usage_type The contribution usage type for the
 * contribution type. Valid values exist in the 'FR_CONTRIBUTION_USAGE_TYPE'
 * lookup type.
 * @param p_rate_type The rate type for the contribution type. Valid values
 * exist in the 'FR_CONTRIBUTION_RATE_TYPE' lookup type.
 * @param p_rate_category The rate category.
 * @param p_contribution_code The contribution code.
 * @param p_contribution_type The type of contribution.
 * @param p_retro_contribution_code The retro contribution code for the
 * contribution type.
 * @param p_business_group_id The business group owning this contribution type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contribution usage. If p_validate is true,
 * then the value will be null.
 * @param p_contribution_usage_id If p_validate is false, then set to the
 * unique identifier of the contribution usage. If p_validate is true then the
 * value will be null.
 * @param p_code_rate_id The unique identifier of the rate type with
 * contribution code.
 * @rep:displayname Create Contribution Usage
 * @rep:category BUSINESS_ENTITY PAY_CONTRIBUTION_USAGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_contribution_usage(
   p_validate                     IN      boolean  default false
  ,p_effective_date               IN      date
  ,p_date_from                    IN      date
  ,p_date_to                      IN      date     default null
  ,p_group_code                   IN      varchar2
  ,p_process_type                 IN      varchar2
  ,p_element_name                 IN      varchar2
  ,p_contribution_usage_type      IN      varchar2
  ,p_rate_type                    IN      varchar2 default null
  ,p_rate_category                IN      varchar2
  ,p_contribution_code            IN      varchar2 default null
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code      IN      varchar2 default null
  ,p_business_group_id            IN      varchar2 default null
  ,p_object_version_number           OUT  nocopy number
  ,p_contribution_usage_id           OUT  nocopy number
  ,p_code_rate_id                 IN OUT  nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_contribution_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allows the user to update a contribution usage for a business group
 * for France.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contribution usage to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The contribution usage record is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contribution usage, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating which lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_contribution_usage_id The unique identifier for the contribution
 * usage.
 * @param p_date_to Date after which the row no longer applies
 * @param p_contribution_code The contribution code contribution type.
 * @param p_contribution_type The type of contribution.
 * @param p_retro_contribution_code The retro contribution code for the
 * contribution type.
 * @param p_object_version_number Pass in the current version number of the
 * contribution usage to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated contribution
 * usage. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_code_rate_id The unique identifier of the rate type with
 * contribution code.
 * @rep:displayname Update Contribution Usage
 * @rep:category BUSINESS_ENTITY PAY_CONTRIBUTION_USAGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_contribution_usage
  (p_validate                     IN      boolean  default false
  ,p_effective_date               IN      date
  ,p_contribution_usage_id        IN      number
  ,p_date_to                      IN      date     default hr_api.g_date
  ,p_contribution_code            IN      varchar2
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code      IN      varchar2 default hr_api.g_varchar2
  ,p_object_version_number        IN OUT  nocopy number
  ,p_code_rate_id                 IN      varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_contribution_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allows the user to delete a contribution usage for a business group
 * for France.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contribution usage to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The specified row is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the contribution usage, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contribution_usage_id The unique identifier for the contribution
 * usage.
 * @param p_object_version_number Current version number of the contribution
 * usage to be deleted.
 * @rep:displayname Delete Contribution Usage
 * @rep:category BUSINESS_ENTITY PAY_CONTRIBUTION_USAGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_contribution_usage
  (p_validate                      in     boolean  default false
  ,p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  );
end pay_cnu_api;

 

/
