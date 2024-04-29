--------------------------------------------------------
--  DDL for Package HR_PL_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER as
/* $Header: pyppmpli.pkh 120.3.12010000.4 2009/12/18 12:07:55 bkeshary ship $ */
/*#
 * This package contains personal payment method APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Personal Payment Method for Poland
*/
g_package  varchar2(33);
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a personal payment method for an assignment.
 *
 * This API is an alternative to the API create_personal_pay_method. If
 * p_validate is set to false, a personal payment method is created for the
 * assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid employee assignment must be set up for a person, and must exist at
 * the effective start date of the personal payment method. Where the personal
 * payment method represents a payment to an organization, then this
 * organization must exist at the effective start date of the personal payment
 * method and be in the same business group as the person's assignment. Where
 * the personal payment method represents a payment to an individual, then this
 * person must exist at the effective start date of the personal payment method
 * and there must exist a contact relationship, for third- party payments,
 * between the payee and the owner of the personal payment method.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the personal payment method and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment for which you create the
 * personal payment method record.
 * @param p_run_type_id Identifies the run_type_id for which the personal
 * payment method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_percentage Percentage to be allocated if there is more than one
 * payment method.
 * @param p_priority Priority order for different payment methods for an
 * employee.
 * @param p_comments Comment text.
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
 * @param p_territory_code Country or territory identifier.
 * @param p_account_check_digit Check Digit of the account number.
 * @param p_bank_id Identification of the Bank.
 * @param p_account_number Account Number.
 * @param p_account_name Name of the account.
 * @param p_bank_name Name of the Bank. Valid values are defined by
 * 'PL_BANK_NAME' lookup type.
 * @param p_bank_branch Name of the bank branch. Valid values are defined by
 * 'PL_BANK_BRANCH_NAME' lookup type.
 * @param p_address Address of the bank.
 * @param p_additional_information Additional Information.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_bic_code BIC Code.
 * @param p_iban_number IBAN Number.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30.
 * @param p_payee_type The type of payee (for a third party payment).
 * @param p_payee_id The payee for a third party payment. This can be a person
 * or an organization.
 * @param p_personal_payment_method_id If p_validate is false, this uniquely
 * identifies the personal payment method created. If p_validate is set to
 * true, this parameter will be null.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is false. If p_validate is set to true,
 * this parameter will be null.
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
 * then will be set to the identifier of the created payment method comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @rep:displayname Create Personal Payment Method for Poland
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
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
  ,p_territory_code                in     varchar2 default null
  ,p_account_check_digit           in     varchar2
  ,p_bank_id                       in     varchar2
  ,p_account_number                in     varchar2 default null /* modfified */
  ,p_account_name                  in     varchar2 default null
  ,p_bank_name                     in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_address                       in     varchar2 default null
  ,p_additional_information        in     varchar2 default null
  ,p_segment9		          	   in     varchar2 default '*'
  ,p_segment10		               in     varchar2 default '1'
  ,p_bic_code                      in     varchar2 default null /* added 9226630  */
  ,p_iban_number                   in     varchar2 default null /* added 9226630  */
  /*,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null */
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number);
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pl_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a personal payment method for an assignment.
 *
 * This API is an alternative to the API update_personal_pay_method. If
 * p_validate is set to false, the personal payment method is updated for the
 * assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method as identified by the in parameters
 * p_personal_payment_method_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method record will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the personal payment method and raises an error.
 *
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
 * @param p_personal_payment_method_id Identification of personal payment
 * method being updated.
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_comments Comment text.
 * @param p_percentage Percentage to be allocated if there is more than one
 * payment method.
 * @param p_priority Priority order for different payment methods for an
 * employee.
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
 * @param p_territory_code Country or territory identifier.
 * @param p_account_check_digit Check Digit of the account number.
 * @param p_bank_id Identification of the Bank.
 * @param p_account_number Account Number.
 * @param p_account_name Name of the account.
 * @param p_bank_name Name of the Bank. Valid values are defined by
 * 'PL_BANK_NAME' lookup type.
 * @param p_bank_branch Name of the bank branch. Valid values are defined by
 * 'PL_BANK_BRANCH_NAME' lookup type.
 * @param p_address Address of the bank.
 * @param p_additional_information Additional Information.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_bic_code BIC Code.
 * @param p_iban_number IBAN Number.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30.
 * @param p_payee_type The type of payee (for a third party payment).
 * @param p_payee_id The payee for a third party payment. This can be a person
 * or an organization.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the personal payment method
 * comment record. If p_validate is true or no comment text exists, then will
 * be null.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is false. If p_validate is set to true,
 * this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated personal payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated personal payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Personal Payment Method for Poland
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pl_personal_pay_method
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
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  ,p_account_check_digit           in     varchar2 default hr_api.g_varchar2
  ,p_bank_id                       in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_address                       in     varchar2 default hr_api.g_varchar2
  ,p_additional_information        in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default '*'
  ,p_segment10                     in     varchar2 default '1'
  ,p_bic_code                      in     varchar2 default hr_api.g_varchar2 /* added bkeshary */
  ,p_iban_number                   in     varchar2 default hr_api.g_varchar2/* added bkeshary */
 /* ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2 */
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_comment_id                    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  );

End hr_pl_personal_pay_method_api;

/
