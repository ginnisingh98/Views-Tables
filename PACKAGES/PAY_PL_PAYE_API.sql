--------------------------------------------------------
--  DDL for Package PAY_PL_PAYE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_PAYE_API" AUTHID CURRENT_USER as
/* $Header: pyppdapi.pkh 120.4 2006/04/24 23:22:43 nprasath noship $ */
/*#
 * This package contains Tax APIs for Poland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Tax for Poland
*/

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_paye_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a PAYE record for a Polish employee.

-- Prerequisites:
--  The Assignment/Person (p_per_or_asg_id) record must exist as of the effective
--  date (p_effective_date)
--
-- In Parameters:
--   Name                         Reqd Type   Description
--   p_validate                   boolean     If true, the database remains
--                                            unchanged. If false a valid
--                                            PAYE record is create in
--                                            the database.
--   p_effective_date             Yes  date   The effective start date of the
--                                            PAYE
--   p_contract_category          Yes varchar2 Contract Category for whom the
--                                             PAYE record applies
--   p_per_or_asg_id              Yes  number  The Person/Assignment to whom
--                                             the PAYE record applies. If the
--                                             Contract Category is "CIVIL" then
--                                             this refers to the Person id. If
--                                             the Contract Category is "NORMAL"
--                                             then this refers to the Assignment
--                                                Id.
--   p_business_group_id          Yes  number  The Employee's Business group
--   p_tax_reduction     		       Yes varchar2 Employee Tax Reduction
--                                             Information.This field should be null
--					       for Contract Category 'CIVIL'.
--   p_tax_calc_with_spouse_child  Yes  varchar2 Tax Calculation with Spouse or Child
--                                               Information.This field should be null
--						 for Contract Category 'CIVIL'.
--   p_income_reduction		   Yes  varchar2 Income Reduction Information
--						 This field is for Normal Contract only.
--   p_income_reduction_amount      No   Number  Income reduction amount
--                                               Information.This field should be null
--						 for Contract Category 'NORMAL'.
--   p_rate_of_tax				 Yes  varchar2 Rate of Tax
--                                               Information
--
-- Post Success:
--   The API sets the following out parameters
--
--   Name                           Type     Description
--   p_paye_details_id              number   Unique ID for the PAYE record created by
--                                           the API
--   p_object_version_number        number   Version number of the new PAYE record
--   p_effective_start_date         date     The effective start date for this
--                                           change
--   p_effective_end_date           date     The effective start date for this
--                                           change
--   p_effective_date_warning       boolean  Set to TRUE if the effective date has
--                                           has been reset to the Employee's/
--                                           Assignment's start date

-- Post Failure:
--  The API will not create the PAYE record and raises an error.
--
-- Access Status:
--   For Internal Development use only.
--
-- {End Of Comments}
--
procedure create_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2
  ,p_per_or_asg_id                 in     number
  ,p_business_group_id             in     number
  ,p_tax_reduction				   in     varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2
  ,p_income_reduction	           in     varchar2
  ,p_income_reduction_amount       in     number	default null
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_paye_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
*  This API updates the tax record of a Polish employee.
*
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The tax record (p_paye_details_id) must
* exist as of the effective date of the update (p_effective_date).
*
* <p><b> Post Success</b><br>
* The API updates the tax record.
*
* <p><b> Post Failure</b><br>
*   The API does not update the tax record and raises an error.
*
* @param p_validate If true, the database remains unchanged. If false,
* tax record is updated in the database.
* @param p_effective_date Determines when the datetrack operation comes into
* force
* @param p_datetrack_update_mode Indicates which datetrack mode to use when
* updating the record. You must set to either UPDATE, CORRECTION,
* UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
* particular record depend on the dates of previous record changes and the
* effective date of this change.
* @param p_paye_details_id  Identifies the tax record to be updated
* @param p_object_version_number Pass in the version number of the tax record
* to be updated. When the API completes, if p_validate is false, will be set
* to the new version number of the updated tax record. If p_validate is true
* will be set to the same value which was passed in.
* @param p_tax_reduction Employee tax reduction information.
* This field should be null for contract category civil,
* lump sum and foreign lump sum .Valid values are defined
* by 'PL_TAX_REDUCTION' lookup type
* @param p_tax_calc_with_spouse_child Tax calculation with spouse or child,
* this field should be null for contract category civil,
* lump sum and foreign lump sum.Valid values are defined by 'YES_NO'
* lookup type.
* @param p_income_reduction Income reduction information. This field is for
* normal contract only.Valid values are defined by 'PL_INCOME_REDUCTION'
* lookup type.
* @param p_income_reduction_amount Income reduction amount information.This
* field should be null for normal contracts.
* @param p_rate_of_tax Rate of tax information .Valid values are defined
* by 'PL_NORMAL_RATE_OF_TAX' lookup type for normal contract ,
* by 'PL_NORMAL_RATE_OF_TAX' for civil contracts, by globals or
* values 0 to 100 for lump sum and foreign lump sum contracts.
* @param p_effective_start_date If p_validate is false, then set to the start
* date for this updated tax record which exists as of the effective date.If
* p_validate is true, then set to null
* @param p_effective_end_date If p_validate is false, then set to the end date
* for this updated tax record which exists as of the effective date.
* @rep:displayname Update Tax record of Polish employee.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_tax_reduction	           in     varchar2 default hr_api.g_varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2 default hr_api.g_varchar2
  ,p_income_reduction              in     varchar2 default hr_api.g_varchar2
  ,p_income_reduction_amount       in     number   default hr_api.g_number
  ,p_rate_of_tax		   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
--

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_paye_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
* This API deletes the tax record of a Polish Employee.
*
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The tax record (p_paye_details_id) must
* exist as of the effective date of the delete (p_effective_date).
*
* <p><b> Post Success</b><br>
* The API deletes tax record.
*
* <p><b> Post Failure</b><br>
*  The API does not delete the tax record and raises an error.
*
* @param p_validate If true, the database remains unchanged. If false,
* tax record is updated in the database.
* @param p_effective_date Determines when the datetrack operation comes into
* force
* @param p_datetrack_delete_mode Indicates which datetrack mode to use when
* deleting the record.You must set to either ZAP, DELETE, FUTURE_CHANGE
* or DELETE_NEXT_CHANGE. Modes available for use with a particular record
* depend on the dates of previous record changes and the effective date of
* this change.
* @param p_paye_details_id  ID of the tax record
* @param p_object_version_number Pass in the version number of the tax record
* to be deleted. When the API completes, if p_validate is false, will be set
* to the new version number of the deleted tax record. If p_validate is true
* will be set to the same value which was passed in.
* @param p_effective_start_date If p_validate is false, then set to the start
* date for this deleted tax record which exists as of the effective date.If
* p_validate is true, then set to null
* @param p_effective_end_date If p_validate is false, then set to the end date
* for this deleted tax record which exists as of the effective date.
* @rep:displayname Delete Tax record of Polish employee.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pl_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_civil_paye_details >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

/*#
* This API creates tax record for a Polish employee with civil contract.
* User hook for this module should be placed against create_pl_paye_details
* module
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The Assignment(p_assignment_id) record must exist
* as of the effective date (p_effective_date)
*
* <p><b> Post Success</b><br>
* The API creates a tax record.
*
* <p><b> Post Failure</b><br>
*  The API does not create tax record and raises an error.
*
* @param p_validate If true, then validation alone will be performed and the
* database will remain unchanged. If false and all validation checks pass,
* then the database will be modified.
* @param p_effective_date Determines when the DateTrack operation comes into
* force.
* @param p_contract_category Contract category for whom the tax record
* applies. Valid values are defined by 'PL_CONTRACT_CATEGORY' lookup type.
* @param p_assignment_id  The assignment to whom the tax record applies.
* @param p_income_reduction_amount  Income reduction amount information
* @param p_rate_of_tax Rate of tax information . Valid values are defined
* by 'PL_CIVIL_RATE_OF_TAX' lookup type
* @param p_paye_details_id Unique id for the tax record created by the API
* @param p_object_version_number If p_validate is false, then set to the
* version number of the created assignment. If p_validate is true, then the
* value will be null.
* @param p_effective_start_date If p_validate is false, then set to the
* earliest effective start date for the created tax record. If p_validate is
* true, then set to null.
* @param p_effective_end_date If p_validate is false, then set to the
* effective end date for the created tax record. If p_validate is true, then
* set to null.
* @param p_effective_date_warning Set to TRUE if the effective date
* has has been reset to the date when assignment became a civil contract
* @rep:displayname Create Tax record for civil contract.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
procedure create_pl_civil_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'CIVIL'
  ,p_assignment_id                 in     number
  ,p_income_reduction_amount       in     number	default null
  ,p_rate_of_tax			       in     varchar2  default 'C01'
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_Normal_paye_details >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
* This API creates a tax record for a Polish employee with normal
* contract category.
*
* User hook for this module should be placed against create_pl_paye_details module.
*
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The Person (p_person_id) record must exist as of the effective
* date (p_effective_date)
*
* <p><b>Post Success</b><br>
* A new tax record is created for the employee.
*
* <p><b>Post Failure</b><br>
* The API does not create tax record and raises an error.
*
* @param p_validate If true, then validation alone will be performed and the
* database will remain unchanged. If false and all validation checks pass,
* then the database will be modified.
* @param p_effective_date Determines when the datetrack operation comes into
* force.
* @param p_contract_category contract category for whom the tax record applies.
* Valid values are defined by 'PL_CONTRACT_CATEGORY' lookup type.
* @param p_person_id The Person to whom the tax record applies.
* @param p_tax_reduction Employee tax reduction information.
* Valid values are defined by 'PL_TAX_REDUCTION' lookup type.
* @param p_tax_calc_with_spouse_child Tax calculation with spouse or child
* Valid values are defined by 'YES_NO' lookup type.
* @param p_income_reduction Income reduction information
* @param p_rate_of_tax Rate of tax information .Valid values are defined
* by 'PL_NORMAL_RATE_OF_TAX' lookup type
* @param p_paye_details_id Unique id for the tax record created by the API
* @param p_object_version_number If p_validate is false, then set to the
* version number of the created tax record. If p_validate is true, then the
* value will be null.
* @param p_effective_start_date If p_validate is false, then set to the
* earliest effective start date for the created tax record. If p_validate is
* true, then set to null.
* @param p_effective_end_date If p_validate is false, then set to the
* effective end date for the created tax record. If p_validate is true, then
* set to null.
* @param p_effective_date_warning Set to TRUE if the effective date
* has has been reset to the Employee's start date
* @rep:displayname Create Tax record for normal contract.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_normal_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'NORMAL'
  ,p_person_id		           in     number
  ,p_tax_reduction	           in     varchar2 default 'NOTAX'
  ,p_tax_calc_with_spouse_child    in     varchar2 default 'N'
  ,p_income_reduction	           in     varchar2 default 'N01'
  ,p_rate_of_tax	           in     varchar2 default 'N01'
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_lump_paye_details >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
* This API creates a tax record for a polish employee with
* lump sum cntract category.
* User hook for this module should be placed
* against create_pl_paye_details module.
*
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The Assignment (p_assignment_id) record must exist as of the effective
* date (p_effective_date)
*
* <p><b>Post Success</b><br>
* A new tax record is created for the employee.
*
* <p><b>Post Failure</b><br>
* The API does not create tax record and raises an error.
*
* @param p_validate If true, then validation alone will be performed and the
* database will remain unchanged. If false and all validation checks pass,
* then the database will be modified.
* @param p_effective_date Determines when the datetrack operation comes into
* force.
* @param p_contract_category contract category for whom the tax record applies.
* Valid values are defined by the 'PL_CONTRACT_CATEGORY' lookup type.
* @param p_assignment_id The assignment to whom the record applies
* @param p_rate_of_tax Rate of tax information.Valid values are defined
* by globals 'PL_TAX_LUMP_FIRST' ,'PL_TAX_LUMP_SECOND','PL_TAX_LUMP_THIRD' or
* values between 0 and 100.
* @param p_paye_details_id Unique id for the tax record created by the API
* @param p_object_version_number If p_validate is false, then set to the
* version number of the created tax record. If p_validate is true, then the
* value will be null.
* @param p_effective_start_date If p_validate is false, then set to the
* earliest effective start date for the created tax record. If p_validate is
* true, then set to null.
* @param p_effective_end_date If p_validate is false, then set to the
* effective end date for the created tax record. If p_validate is true, then
* set to null.
* @param p_effective_date_warning Set to true if the effective date has
* has been reset to the date when the assignment first became lump sum contract
* @rep:displayname Create Tax record for lump sum contract.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
procedure create_pl_lump_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'LUMP'
  ,p_assignment_id                 in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_f_lump_paye_details >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
* This API creates a tax record for a Polish employee with
* foreign lump sum contract category.
* User hook for this module should be placed
* against create_pl_paye_details module.
*
* <p><b>Licensing</b><br>
* This API is licensed for use with Human Resources.
*
* <p><b>Prerequisites</b><br>
* The Assignment (p_assignment_id) record must exist as of the effective
*  date (p_effective_date)
*
* <p><b>Post Success</b><br>
* A new tax record is created for the employee.
*
* <p><b>Post Failure</b><br>
* The API does not create tax record and raises an error.
*
* @param p_validate If true, then validation alone will be performed and the
* database will remain unchanged. If false and all validation checks pass,
* then the database will be modified.
* @param p_effective_date Determines when the datetrack operation comes into
* force.
* @param p_contract_category contract category for whom the tax record applies .
* Valid values are defined by the 'PL_CONTRACT_CATEGORY' lookup type.
* @param p_assignment_id The assignment to whom the tax record applies
* @param p_rate_of_tax Rate of tax information.Valid values are defined
* by globals 'PL_TAX_LUMP_FIRST' ,'PL_TAX_LUMP_SECOND','PL_TAX_LUMP_THIRD' or
* values between 0 to 100.
* @param p_paye_details_id Unique id for the tax record created by the API
* @param p_object_version_number If p_validate is false, then set to the
* version number of the created tax record. If p_validate is true, then the
* value will be null.
* @param p_effective_start_date If p_validate is false, then set to the
* earliest effective start date for the created tax record. If p_validate is
* true, then set to null.
* @param p_effective_end_date If p_validate is false, then set to the
* effective end date for the created tax record. If p_validate is true, then
* set to null.
* @param p_effective_date_warning Set to true if the effective date has
* has been reset to the date when the assignment first became a foreign
* lumpsum contract
* @rep:displayname Create Tax record for foreign lump sum contract.
* @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
* @rep:category MISC_EXTENSIONS HR_USER_HOOKS
* @rep:lifecycle active
* @rep:scope public
* @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
procedure create_pl_f_lump_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_contract_category             in     varchar2 default 'F_LUMP'
  ,p_assignment_id                 in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_paye_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  ,p_effective_date_warning		   out nocopy boolean);
end PAY_PL_PAYE_API;

 

/
