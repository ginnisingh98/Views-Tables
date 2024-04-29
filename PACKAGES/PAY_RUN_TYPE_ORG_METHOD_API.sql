--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_ORG_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_ORG_METHOD_API" AUTHID CURRENT_USER as
/* $Header: pyromapi.pkh 120.1 2005/10/02 02:34:08 aroussel $ */
/*#
 * This package contains the Run Type Organization Method API.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Run Type Organization Method
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_run_type_org_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a Run Type Organization Method record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type and the organization payment method should exist for the same
 * business group as this record.
 *
 * <p><b>Post Success</b><br>
 * The run type organization payment method will be successfully inserted into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the run type organization payment method and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_run_type_id The identifier of the run type using the payment
 * method.
 * @param p_org_payment_method_id The identifier of the payment method
 * referenced by the run type.
 * @param p_priority Must be between 1 and 99
 * @param p_percentage Must be between 1 and 100 in decimal format to 2.d.p
 * Cannot be null if amount is null and must be null if amount is not null.
 * @param p_amount Must be &gt;= 0. Must be of correct money format for payment
 * method. Cannot be null if percentage is null and must be null if percentage
 * is not null.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.LEGISLATION_CODE}
 * @param p_run_type_org_method_id If p_validate is false, this uniquely
 * identifies the run type organization payment method created. If p_validate
 * is set to true, this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created run type organization payment. If p_validate
 * is true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created run type organization payment.
 * If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created run type organization payment. If
 * p_validate is true, then set to null.
 * @rep:displayname Create Run Type Organization Method
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_org_payment_method_id         in     number
  ,p_priority                      in     number
  ,p_percentage                    in     number   default null
  ,p_amount                        in     number   default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_run_type_org_method_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_run_type_org_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the run type organization payment method record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type organization method to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * The run type organization payment method will be successfully updated in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the run type organization payment method and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_run_type_org_method_id Unique Identifier of the run type
 * organization payment method being updated.
 * @param p_object_version_number Pass in the current version number of the run
 * type organization payment method to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * run type organization payment method. If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_priority Must be between 1 and 99
 * @param p_percentage Must be between 1 and 100 in decimal format to 2.d.p
 * Cannot be null if amount is null and must be null if amount is not null.
 * @param p_amount Must be &gt;= 0. Must be of correct money format for payment
 * method. Cannot be null if percentage is null and must be null if percentage
 * is not null.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.LEGISLATION_CODE}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated run type org row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated run type org row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Run Type Organization Method
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_run_type_org_method_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_run_type_org_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a run type organization payment method record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type organization method to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * The run type organization payment method will be successfully deleted from
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the run type organization payment method and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_run_type_org_method_id Unique Identifier of the run type
 * organization payment method being deleted.
 * @param p_object_version_number Pass in the current version number of the run
 * type org to be deleted. When the API completes if p_validate is false, will
 * be set to the new version number of the deleted run type org. If p_validate
 * is true will be set to the same value which was passed in.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_RUN_TYPE_ORG_METHODS_F.LEGISLATION_CODE}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted run type org row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted run type org row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Run Type Organization Method
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_org_method_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
end PAY_RUN_TYPE_ORG_METHOD_API
;

 

/
