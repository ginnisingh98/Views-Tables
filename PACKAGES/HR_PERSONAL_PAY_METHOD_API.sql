--------------------------------------------------------
--  DDL for Package HR_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER as
/* $Header: pyppmapi.pkh 120.4.12010000.4 2009/07/24 09:45:52 pgongada ship $ */
/*#
 * This package contains Personal Payment Method APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Payment Method
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_personal_pay_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a personal payment method for an employee assignment.
 *
 * This API calls the generic create_personal_pay_method API with the
 * parameters set for a personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An Organization and a valid employee assignment must exists for the person.
 * Also a contact relationship, for third-party payments, between the payee and
 * the owner of the personal payment method must exist.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method will be successfully inserted into the database.
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
 * @param p_run_type_id Identifies the run type for which the personal payment
 * method is being created.
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
 * @param p_territory_code Country or territory identifier. Used in the
 * validation of bank account information.
 * @param p_segment1 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment2 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment3 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment4 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment5 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment6 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment7 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment8 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment9 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment10 If p_validate is false, then set to the effective end
 * date for the created personal payment method. If p_validate is true, then
 * set to null.
 * @param p_segment11 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment12 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment13 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment14 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment15 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment16 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment17 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment18 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment19 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment20 If p_validate is false, then set to the effective end
 * date for the created personal payment method. If p_validate is true, then
 * set to null.
 * @param p_segment21 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment22 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment23 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment24 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment25 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment26 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment27 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment28 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment29 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment30 If p_validate is false, then set to the effective end
 * date for the created personal payment method. If p_validate is true, then
 * set to null.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Create Personal Payment Method
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number   default null
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
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
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
/** sbilling **/
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_ppm_information_category      in     varchar2 default null  --Bug 6439573
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_gb_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a specific personal payment method for an employee
 * assignment in Great Britain.
 *
 * This API calls the generic create_personal_pay_method API with the
 * parameters set for a Great Britain specific personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_personal_pay_method.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for Great Britain will be successfully
 * inserted into the database.
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
 * @param p_run_type_id Identifies the run type for which the personal payment
 * method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_sort_code Bank sort code.
 * @param p_bank_name Bank name.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch.
 * @param p_bank_branch_location Bank branch location.
 * @param p_bldg_society_account_number Building society account number.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Create Personal Payment Method for United Kingdom
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_gb_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number   default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_sort_code                     in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_bank_branch_location          in     varchar2 default null
  ,p_bldg_society_account_number   in     varchar2 default null
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
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ,p_segment9                      in     varchar2 default null -- Bug 7185344
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
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
  ,p_segment30                     in     varchar2 default null -- Bug 7185344
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_us_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a specific personal payment method for an employee
 * assignment in United States of America.
 *
 * This API calls the generic create_personal_pay_method API with the
 * parameters set for a USA specific personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_personal_pay_method.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for USA will be successfully inserted
 * into the database.
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
 * @param p_run_type_id Identifies the run type for which the personal payment
 * method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_transit_code Bank transit code.
 * @param p_bank_name Bank name.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_prenote_date Date on which a prenote for this account was sent.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Create Personal Payment Method for United States
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_us_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_transit_code                  in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
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
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_prenote_date                  in     date     default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ca_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a specific personal payment method for an employee
 * assignment in Canada.
 *
 * This API calls the generic create_personal_pay_method API with the
 * parameters set for a Canada specific personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_personal_pay_method.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for Canada will be successfully
 * inserted into the database.
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
 * @param p_run_type_id Identifies the run type for which the personal payment
 * method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_transit_code Bank transit code.
 * @param p_bank_name Bank name.
 * @param p_bank_number Bank number.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Create Personal Payment Method for Canada
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_transit_code                  in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_bank_number                   in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
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
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_personal_pay_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a personal payment method.
 *
 * This API updates record for the given p_personal_payment_method_id and
 * p_object_version_number at the specified p_effective_date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method specified by the parameters
 * p_personal_payment_method_id and p_object_version_number must exist as of
 * p_effective_date.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method will be successfully updated in the database.
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
 * @param p_territory_code Country or territory identifier. Used in the
 * validation of bank account information.
 * @param p_segment1 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment2 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment3 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment4 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment5 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment6 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment7 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment8 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment9 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment10 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment11 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment12 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment13 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment14 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment15 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment16 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment17 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment18 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment19 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment20 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment21 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment22 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment23 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment24 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment25 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment26 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment27 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment28 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment29 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_segment30 External accounts key flexfield segment for specifying
 * bank account information.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Update Personal Payment Method
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_personal_pay_method
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
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
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
/** sbilling **/
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2  --Bug 6439573
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_gb_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a specific personal payment method for an employee
 * assignment in Great Britain.
 *
 * This API calls the generic update_personal_pay_method API with the
 * parameters set as appropriate for a Great Britain specific personal payment
 * method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method specified by the parameters
 * p_personal_payment_method_id and p_object_version_number must exist as of
 * p_effective_date.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for Great Britain has been successfully
 * updated.
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
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_sort_code Bank sort code.
 * @param p_bank_name Bank name.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch.
 * @param p_bank_branch_location Bank branch location.
 * @param p_bldg_society_account_number Building society account number.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Update Personal Payment Method for United Kingdom
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_gb_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_sort_code                     in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch_location          in     varchar2 default hr_api.g_varchar2
  ,p_bldg_society_account_number   in     varchar2 default hr_api.g_varchar2
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
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_segment9                      in     varchar2 default null -- Bug 7185344
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
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
  ,p_segment30                     in     varchar2 default null -- Bug 7185344
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_us_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a specific personal payment method for an employee
 * assignment in USA.
 *
 * This API calls the generic update_personal_pay_method API with the
 * parameters set for a USA specific personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method specified by the parameters
 * p_personal_payment_method_id and p_object_version_number must exist as of
 * p_effective_date.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for USA has been successfully updated.
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
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_transit_code Bank sort code.
 * @param p_bank_name Bank name.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch. number.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_prenote_date Date on which a prenote for this account was sent.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Update Personal Payment Method for United States
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_us_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_transit_code                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
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
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_prenote_date                  in     date     default hr_api.g_date
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_ca_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a specific personal payment method for an employee
 * assignment in Canada .
 *
 * This API calls the generic update_personal_pay_method API with the
 * parameters set for a Canada specific personal payment method.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method specified by the parameters
 * p_personal_payment_method_id and p_object_version_number must exist as of
 * p_effective_date.
 *
 * <p><b>Post Success</b><br>
 * The specific personal payment method for Canada will be successfully updated
 * into the database.
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
 * @param p_account_name Bank account name.
 * @param p_account_number Bank account number.
 * @param p_transit_code Bank transit code.
 * @param p_bank_number Bank number.
 * @param p_bank_name Bank name.
 * @param p_account_type Account type.
 * @param p_bank_branch Bank branch. number.
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
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
 * @param p_territory_code Territory code for syncronizing bank details.
 * @param p_ppm_information_category Identifies the context of the Further
 * Personal Payment Method Info DFF.
 * @param p_ppm_information1 Identifies the Further Personal Payment Method
 * Info DFF's segment1.
 * @param p_ppm_information2 Identifies the Further Personal Payment Method
 * Info DFF's segment2.
 * @param p_ppm_information3 Identifies the Further Personal Payment Method
 * Info DFF's segment3
 * @param p_ppm_information4 Identifies the Further Personal Payment Method
 * Info DFF's segment4
 * @param p_ppm_information5 Identifies the Further Personal Payment Method
 * Info DFF's segment5
 * @param p_ppm_information6 Identifies the Further Personal Payment Method
 * Info DFF's segment6
 * @param p_ppm_information7 Identifies the Further Personal Payment Method
 * Info DFF's segment7
 * @param p_ppm_information8 Identifies the Further Personal Payment Method
 * Info DFF's segment8
 * @param p_ppm_information9 Identifies the Further Personal Payment Method
 * Info DFF's segment9
 * @param p_ppm_information10 Identifies the Further Personal Payment Method
 * Info DFF's segment10
 * @param p_ppm_information11 Identifies the Further Personal Payment Method
 * Info DFF's segment11
 * @param p_ppm_information12 Identifies the Further Personal Payment Method
 * Info DFF's segment12
 * @param p_ppm_information13 Identifies the Further Personal Payment Method
 * Info DFF's segment13
 * @param p_ppm_information14 Identifies the Further Personal Payment Method
 * Info DFF's segment14
 * @param p_ppm_information15 Identifies the Further Personal Payment Method
 * Info DFF's segment15
 * @param p_ppm_information16 Identifies the Further Personal Payment Method
 * Info DFF's segment16
 * @param p_ppm_information17 Identifies the Further Personal Payment Method
 * Info DFF's segment17
 * @param p_ppm_information18 Identifies the Further Personal Payment Method
 * Info DFF's segment18
 * @param p_ppm_information19 Identifies the Further Personal Payment Method
 * Info DFF's segment19
 * @param p_ppm_information20 Identifies the Further Personal Payment Method
 * Info DFF's segment20
 * @param p_ppm_information21 Identifies the Further Personal Payment Method
 * Info DFF's segment21
 * @param p_ppm_information22 Identifies the Further Personal Payment Method
 * Info DFF's segment22
 * @param p_ppm_information23 Identifies the Further Personal Payment Method
 * Info DFF's segment23
 * @param p_ppm_information24 Identifies the Further Personal Payment Method
 * Info DFF's segment24
 * @param p_ppm_information25 Identifies the Further Personal Payment Method
 * Info DFF's segment25
 * @param p_ppm_information26 Identifies the Further Personal Payment Method
 * Info DFF's segment26
 * @param p_ppm_information27 Identifies the Further Personal Payment Method
 * Info DFF's segment27
 * @param p_ppm_information28 Identifies the Further Personal Payment Method
 * Info DFF's segment28
 * @param p_ppm_information29 Identifies the Further Personal Payment Method
 * Info DFF's segment29
 * @param p_ppm_information30 Identifies the Further Personal Payment Method
 * Info DFF's segment30
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
 * @rep:displayname Update Personal Payment Method for Canada
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_transit_code                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_number                   in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
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
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
   /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_personal_pay_method >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the personal payment method record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method specified by the parameters
 * p_personal_payment_method_id and p_object_version_number must exist as of
 * p_effective_date.
 *
 * <p><b>Post Success</b><br>
 * Personal Payment will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the personal payment method and raises an error.
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
 * @param p_personal_payment_method_id Identifies the personal payment method
 * being deleted.
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be deleted. When the API completes if p_validate
 * is false, will be set to the new version number of the deleted personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted personal payment method row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created personal payment method. If p_validate is
 * true, then set to null.
 * @rep:displayname Delete Personal Payment Method
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--
end hr_personal_pay_method_api;

/
