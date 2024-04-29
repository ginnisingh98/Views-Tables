--------------------------------------------------------
--  DDL for Package HR_FR_PERS_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_PERS_PAY_METHOD_API" AUTHID CURRENT_USER as
/* $Header: peppmfri.pkh 120.1 2005/10/02 02:22:05 aroussel $ */
/*#
 * This package contains personal payment method APIs for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Payment Method for France
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_fr_pers_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a personal payment method for a person in France.
 *
 * This API creates the French personal payment method as specified, for the
 * employee assignment identified by the parameter p_assignment_id. The API
 * calls the generic API create_personal_pay_method, with the parameters set as
 * appropriate for a French employee assignment. See create_personal_pay_method
 * API for further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id), and the organizational payment method
 * (p_org_payment_method_id) must exist.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the personal payment method in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the personal payment method and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment for which the personal
 * payment method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_amount The monetary amount payable by the personal payment method.
 * One and only one of p_amount or p_percentage must be given a value.
 * @param p_percentage The percentage of the assignment's pay to be paid by the
 * personal payment method. One and only one of p_amount or p_percentage must
 * be given a value.
 * @param p_priority The priority of the personal payment method.
 * @param p_comments Personal payment method comment text.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 External accounts key flexfield segment for specifying
 * bank account information.
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
 * @param p_bank_name Bank name. Valid values exist in the 'FR_BANK' lookup
 * type.
 * @param p_bank_code Bank code. Valid values exist in the lookup code of the
 * 'FR_BANK' lookup type.
 * @param p_branch_code Branch code
 * @param p_branch_name Branch name
 * @param p_account_number Account number
 * @param p_account_name Account name
 * @param p_3rd_party_payee 3rd party of payee
 * @param p_transmitter_code Transmitter code
 * @param p_deposit_type Deposit type
 * @param p_valid_bank_branch Valid bank and branch. '*' for valid bank and
 * Branch values.
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_personal_payment_method_id If p_validate is false, this uniquely
 * identifies the personal payment method created. If p_validate is set to
 * true, this parameter will be null.
 * @param p_external_account_id Identifies the external account combination for
 * the bank account information, if a combination exists and p_validate is
 * false. If p_validate is set to true, this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created personal payment method. If p_validate is
 * true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created personal payment method. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created personal payment method. If p_validate is
 * true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created personal payment method
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @rep:displayname Create Personal Payment Method for France
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_pers_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_org_payment_method_id         in     number
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
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
  ,p_bank_name                     in     varchar2 default null
  ,p_bank_code                     in     varchar2 default null
  ,p_branch_code                   in     varchar2 default null
  ,p_branch_name                   in     varchar2 default null
  ,p_account_number                in     varchar2 default null
  ,p_account_name                  in     varchar2 default null
  ,p_3rd_party_payee               in     varchar2 default null
  ,p_transmitter_code              in     varchar2 default null
  ,p_deposit_type                  in     varchar2 default null
  ,p_valid_bank_branch             in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_personal_payment_method_id    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ,p_comment_id                    out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_fr_pers_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the personal payment method for an assignment in France.
 *
 * As this API is effectively an alternative to the API
 * update_personal_pay_method, see update_personal_pay_method API for further
 * details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method to be updated must be for an assignment in
 * France. See API update_personal_pay_method for further details.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the personal payment method and raises an error.
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
 * @param p_personal_payment_method_id Identifies the personal payment method
 * being updated.
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_amount The monetary amount payable by the personal payment method.
 * One and only one of p_amount or p_percentage must be given a value.
 * @param p_comments Personal payment method comment text.
 * @param p_percentage The percentage of the assignment's pay to be paid by the
 * personal payment method. One and only one of p_amount or p_percentage must
 * be given a value.
 * @param p_priority The priority of the personal payment method.
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
 * @param p_bank_name Bank name. Valid values exist in the 'FR_BANK' lookup
 * type.
 * @param p_bank_code Bank code. Valid values exist in the lookup code of the
 * 'FR_BANK' lookup type.
 * @param p_branch_code Branch code
 * @param p_branch_name Branch name
 * @param p_account_number Account number
 * @param p_account_name Account name
 * @param p_3rd_party_payee 3rd party of payee
 * @param p_transmitter_code Transmitter code
 * @param p_deposit_type Deposit type
 * @param p_valid_bank_branch Valid bank and branch. '*' for valid bank and
 * Branch values.
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created personal payment method
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_external_account_id Identifies the external account combination for
 * the bank account information, if a combination exists and p_validate is
 * false. If p_validate is set to true, this parameter will be null.
 * @param p_effective_start_date If p_validate is true, then set to null.If
 * p_validate is false, then set to the effective start date on the updated
 * personal payment method row which now exists as of the effective date. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated personal payment method row which now
 * exists as of the effective date.
 * @rep:displayname Update Personal Payment Method for France
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fr_pers_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_bank_code                     in     varchar2 default hr_api.g_varchar2
  ,p_branch_code                   in     varchar2 default hr_api.g_varchar2
  ,p_branch_name                   in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_3rd_party_payee               in     varchar2 default hr_api.g_varchar2
  ,p_transmitter_code              in     varchar2 default hr_api.g_varchar2
  ,p_deposit_type                  in     varchar2 default hr_api.g_varchar2
  ,p_valid_bank_branch             in     varchar2 default hr_api.g_varchar2
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_comment_id                    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  );
--
end hr_fr_pers_pay_method_api;

 

/
