--------------------------------------------------------
--  DDL for Package PAY_PL_SII_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_SII_API" AUTHID CURRENT_USER as
/* $Header: pypsdapi.pkh 120.4 2006/04/24 23:37:08 nprasath noship $ */
/*#
 * This package contains SII APIs for Poland.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname SII details for Poland
*/
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
-- { Start Of Comments}
--
-- Description:
--   This API creates a SII record for a Polish employee.

-- Prerequisites:
--  The Assignment/Person (p_per_or_asg_id) record must exist as of the effective
--  date (p_effective_date)
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                SII record is create in
--                                                the database.
--   p_effective_date               Yes  date     The effective start date of the
--                                                SII
--   p_contract_category            Yes  varchar2 Contract Category for whom the
--                                                SII record applies
--   p_per_or_asg_id                Yes  number   The Person/Assignment to whom
--                                                the SII record applies. If the
--                                                Contract Category is "CIVIL" then
--                                                this refers to the Person id. If
--                                                the Contract Category is "NORMAL"
--                                                then this refers to the Assignment
--                                                Id.
--   p_business_group_id            Yes  number   The Employee's Business group
--   p_emp_social_security_info     Yes  varchar2 Employee Social Security
--                                                Information
--   p_old_age_contribution         No   varchar2 Old Age Contribution
--                                                Information
--   p_pension_contribution         No   varchar2 Pension Contribution
--                                                Information
--   p_sickness_contribution        No   varchar2 Sickness Contribution
--                                                Information
--   p_work_injury_contribution     No   varchar2 Work Injury Contribution
--                                                Information
--   p_labor_contribution           No   varchar2 Labor Contribution
--                                                Information
--   p_health_contribution          No   varchar2 Health Contribution
--                                                Information
--   p_unemployment_contribution    No   varchar2 Unemployment Contribution
--                                                Information
--   p_old_age_cont_end_reason      No   varchar2 Old Age Contribution End Reason
--   p_pension_cont_end_reason      No   varchar2 Pension Contribution End Reason
--   p_sickness_cont_end_reason     No   varchar2 Sickness Contribution End Reason
--   p_work_injury_cont_end_reason  No   varchar2 Work Injury Contribution End Reason
--   p_labor_fund_cont_end_reason   No   varchar2 Labor fund Contribution End Reason
--   p_health_cont_end_reason       No   varchar2 Health Contribution End Reason
--   p_unemployment_cont_end_reason No   varchar2 Unemployment Contribution End
--                                                Reason


--
-- Post Success:
--   The API sets the following out parameters
--
--   Name                           Type     Description
--   p_sii_details_id               number   Unique ID for the SII record created by
--                                           the API
--   p_object_version_number        number   Version number of the new SII record
--   p_effective_start_date         date     The effective start date for this
--                                           change
--   p_effective_end_date           date     The effective start date for this
--                                           change
--   p_effective_date_warning       boolean  Set to TRUE if the effective date has
--                                           has been reset to the Employee's/
--                                           Assignment's start date

-- Post Failure:
--  The API will not create the SII record and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2
  ,p_per_or_asg_id                 in     number
  ,p_business_group_id             in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_old_age_cont_end_reason       in     varchar2  default null
  ,p_pension_cont_end_reason       in     varchar2  default null
  ,p_sickness_cont_end_reason      in     varchar2  default null
  ,p_work_injury_cont_end_reason   in     varchar2  default null
  ,p_labor_fund_cont_end_reason    in     varchar2  default null
  ,p_health_cont_end_reason        in     varchar2  default null
  ,p_unemployment_cont_end_reason  in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_civil_sii_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a SII record for a Polish employee with a
 * civil contract category.
 * User hook for this module should be placed against
 * module name 'create_pl_sii_details'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The assignment(p_assignment_id) record must exist as of the effective
 *  date (p_effective_date).
 *
 * <p><b> Post Success</b><br>
 *  A new SII record is created.
 *
 * <p><b> Post Failure</b><br>
 *   The API will not create the SII record and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,a valid
 * SII record is created in the database.
 * @param p_effective_date The effective start date of the SII record.
 * @param p_assignment_id The assignment to whom the SII record applies.
 * @param p_emp_social_security_info Employee social security information
 * @param p_old_age_contribution Old age contribution information.Valid values
 * for all contributions are defined by 'PL_CONTRIBUTION_TYPE' lookup type
 * @param p_pension_contribution Pension contribution information
 * @param p_sickness_contribution Sickness contribution information
 * @param p_work_injury_contribution  Work injury contribution information
 * @param p_labor_contribution Labor contribution information
 * @param p_health_contribution Health contribution information
 * @param p_unemployment_contribution Unemployment contribution information
 * @param p_sii_details_id If p_validate is false, then this uniquely
 * identifies the created SII record. If p_validate is true, then set to null
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the new SII record.If p_validate is true, then set to null
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this record.If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this record.If p_validate is true, then set to null
 * @param p_effective_date_warning If p_validate is false,Set to TRUE if the
 * effective date has been reset to the date when the assignment first
 * became a civil contract.If p_validate is true,then set to null
 * @rep:displayname Create SII record for civil contract
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure create_pl_civil_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  );
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pl_normal_sii_details >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 *  This API creates a SII record for a Polish employee with a normal contract
 *  category.
 *  User hook for this module should be placed against
 *  module name 'create_pl_sii_details'
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The person(p_person_id) record must exist as of the effective
 *  date (p_effective_date).
 *
 * <p><b> Post Success</b><br>
 *  A new SII record is created.
 *
 * <p><b> Post Failure</b><br>
 *   The API will not create the SII record and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,a valid
 * SII record is created in the database.
 * @param p_effective_date The effective start date of the SII record.
 * @param p_person_id The person to whom the SII record applies.
 * @param p_emp_social_security_info Employee social security information
 * @param p_old_age_contribution Old age contribution information.Valid values
 * for all contributions are defined by 'PL_CONTRIBUTION_TYPE' lookup type
 * @param p_pension_contribution Pension contribution information
 * @param p_sickness_contribution Sickness contribution information
 * @param p_work_injury_contribution  Work injury contribution information
 * @param p_labor_contribution Labor contribution information
 * @param p_health_contribution Health Contribution Information
 * @param p_unemployment_contribution Unemployment contribution information
 * @param p_sii_details_id If p_validate is false, then this uniquely
 * identifies the created SII record created.If p_validate is true,
 * then set to null
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the new SII record.If p_validate is true, then set to null
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this record.If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this record.If p_validate is true, then set to null
 * @param p_effective_date_warning If p_validate is false,set to TRUE if the
 * effective date has been reset to the employee's start date.If p_validate
 * is true,then set to null
 * @rep:displayname Create SII record for normal contract
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--

procedure create_pl_normal_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  );

--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_lump_sii_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 *  This API creates a SII record for a Polish employee with a lump sum
 *  contract category.
 *  User hook for this module should be placed against
 *  module name 'create_pl_sii_details'
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The assignment(p_assignment_id) record must exist as of the effective
 *  date (p_effective_date).
 *
 * <p><b> Post Success</b><br>
 *  A new SII record is created.
 *
 * <p><b> Post Failure</b><br>
 *   The API will not create the SII record and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,a valid
 * SII record is created in the database.
 * @param p_effective_date The effective start date of the SII record.
 * @param p_assignment_id The Assignment to whom the SII record applies.
 * @param p_emp_social_security_info Employee social security information
 * @param p_old_age_contribution Old age contribution information.Valid values
 * for all contributions are defined by 'PL_CONTRIBUTION_TYPE' lookup type
 * @param p_pension_contribution Pension contribution information
 * @param p_sickness_contribution Sickness contribution information
 * @param p_work_injury_contribution  Work injury contribution information
 * @param p_labor_contribution Labor contribution information
 * @param p_health_contribution Health contribution information
 * @param p_unemployment_contribution Unemployment contribution information
 * @param p_sii_details_id If p_validate is false, then this uniquely
 * identifies the created SII record. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the new SII record.If p_validate is true, then set to null
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this record.If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this record.If p_validate is true, then set to null
 * @param p_effective_date_warning Set to TRUE if the effective date has been
 * reset to the date when the assignment first became a lump sum contract
 * @rep:displayname Create SII record for lump sum contract.
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
-- {End Of Comments}
--
procedure create_pl_lump_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_f_lump_sii_details >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 *  This API creates a SII record for a Polish employee with a foreign
 *  lump sum contract category.
 *  User hook for this module should be placed against
 *  module name 'create_pl_sii_details'
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The assignment(p_assignment_id) record must exist as of the effective
 *  date (p_effective_date).
 *
 * <p><b> Post Success</b><br>
 *  A new SII record is created.
 *
 * <p><b> Post Failure</b><br>
 *   The API will not create the SII record and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,a valid
 * SII record is created in the database.
 * @param p_effective_date The effective start date of the SII record.
 * @param p_assignment_id The Assignment to whom the SII record applies.
 * @param p_emp_social_security_info Employee social security information
 * @param p_old_age_contribution Old age contribution information.Valid values
 * for all contributions are defined by 'PL_CONTRIBUTION_TYPE' lookup type
 * @param p_pension_contribution Pension contribution information
 * @param p_sickness_contribution Sickness contribution information
 * @param p_work_injury_contribution  Work injury contribution information
 * @param p_labor_contribution Labor contribution information
 * @param p_health_contribution Health contribution information
 * @param p_unemployment_contribution Unemployment contribution information
 * @param p_sii_details_id If p_validate is false, then this uniquely
 * identifies the created SII record. If p_validate is true, then set to null
 * @param p_object_version_number If p_validate is false, then set to the
 * version of new SII record.If p_validate is true, then set to null
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this record.If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this record.If p_validate is true, then set to null
 * @param p_effective_date_warning Set to TRUE if the effective date has been
 * reset to the date when the assignment first became a foreign lump sum contract
 * @rep:displayname Create SII record for foreign lump sum contract.
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure create_pl_f_lump_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2  default null
  ,p_pension_contribution          in     varchar2  default null
  ,p_sickness_contribution         in     varchar2  default null
  ,p_work_injury_contribution      in     varchar2  default null
  ,p_labor_contribution            in     varchar2  default null
  ,p_health_contribution           in     varchar2  default null
  ,p_unemployment_contribution     in     varchar2  default null
  ,p_sii_details_id                out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning        out nocopy   boolean
  );
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates the SII record of a Polish employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The SII record (p_sii_details_id) must exist as of the effective date of the
 *  update (p_effective_date)
 *
 * <p><b> Post Success</b><br>
 *  The API updates the SII record
 *
 * <p><b> Post Failure</b><br>
 * The API does not update the SII record and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If false,
 * SII record is updated in the database.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_sii_details_id Identifies the SII record to be updated
 * @param p_emp_social_security_info Employee social security information
 * @param p_old_age_contribution Old age contribution information.Valid values
 * for all contributions are defined by 'PL_CONTRIBUTION_TYPE' lookup type
 * @param p_pension_contribution Pension contribution information
 * @param p_sickness_contribution Sickness contribution information
 * @param p_work_injury_contribution  Work injury contribution information
 * @param p_labor_contribution Labor contribution information
 * @param p_health_contribution Health contribution information
 * @param p_unemployment_contribution Unemployment contribution information
 * @param p_old_age_cont_end_reason Old age contribution end reason.Valid
 * values for all end reasons are defined by 'PL_CONTRIBUTION_END_REASON'
 * lookup type
 * @param p_pension_cont_end_reason Pension contribution end reason
 * @param p_sickness_cont_end_reason Sickness contribution end reason
 * @param p_work_injury_cont_end_reason Work injury contribution end reason
 * @param p_labor_fund_cont_end_reason Labor fund contribution end reason
 * @param p_health_cont_end_reason Health contribution end reason
 * @param p_unemployment_cont_end_reason Unemployment contribution end reason
 * @param p_object_version_number Pass in the version number of the SII record
 * to be updated. When the API completes, if p_validate is false, will be set
 * to the new version number of the updated SII record. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this updated SII record which exists as of the effective date.If
 * p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this updated SII record which exists as of the effective date.If
 * p_validate is true, then set to null
 * @rep:displayname Update SII record of Polish employee.
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure update_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_sii_details_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_emp_social_security_info      in     varchar2 default hr_api.g_varchar2
  ,p_old_age_contribution          in     varchar2 default hr_api.g_varchar2
  ,p_pension_contribution          in     varchar2 default hr_api.g_varchar2
  ,p_sickness_contribution         in     varchar2 default hr_api.g_varchar2
  ,p_work_injury_contribution      in     varchar2 default hr_api.g_varchar2
  ,p_labor_contribution            in     varchar2 default hr_api.g_varchar2
  ,p_health_contribution           in     varchar2 default hr_api.g_varchar2
  ,p_unemployment_contribution     in     varchar2 default hr_api.g_varchar2
  ,p_old_age_cont_end_reason       in     varchar2 default hr_api.g_varchar2
  ,p_pension_cont_end_reason       in     varchar2 default hr_api.g_varchar2
  ,p_sickness_cont_end_reason      in     varchar2 default hr_api.g_varchar2
  ,p_work_injury_cont_end_reason   in     varchar2 default hr_api.g_varchar2
  ,p_labor_fund_cont_end_reason    in     varchar2 default hr_api.g_varchar2
  ,p_health_cont_end_reason        in     varchar2 default hr_api.g_varchar2
  ,p_unemployment_cont_end_reason  in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
--

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_sii_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes the SII record of a Polish Employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  The SII record (p_sii_details_id) must exist as of the effective date of the
 *  delete (p_effective_date)
 *
 * <p><b> Post Success</b><br>
 *  The API deletes the SII record
 *
 * <p><b> Post Failure</b><br>
 *   The API does not delete the SII record and raises an error.
 * @param p_validate If true, the database remains unchanged. If false,
 * SII record is deleted in the database.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE_NEXT_CHANGE or
 * FUTURE_CHANGE. Modes available for use with a particular record depend on
 * the dates of previous record changes and the effective date of this change.
 * @param p_sii_details_id Identifies the SII record to be deleted
 * @param p_object_version_number Pass in the version number of the SII record
 * to be deleted. When the API completes, if p_validate is false, will be set
 * to the new version number of the deleted SII record. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the start
 * date for this updated SII record which exists as of the effective date.If
 * p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this updated SII record which exists as of the effective date.If
 * p_validate is true, then set to null
 * @rep:displayname Delete SII record of Polish employee.
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
-- {End Of Comments}
--
procedure delete_pl_sii_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_sii_details_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
--
end PAY_PL_SII_API;

 

/
