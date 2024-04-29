--------------------------------------------------------
--  DDL for Package PAY_ORG_PAYMENT_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAYMENT_METHOD_API" AUTHID CURRENT_USER as
/* $Header: pyopmapi.pkh 120.5 2005/10/24 00:35:01 adkumar noship $ */
/*#
 * This package contains Organization Payment Method APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Payment Method
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_org_payment_method >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts an Organization Payment Method record.
 *
 * In addition to creating the organization payment method it also creates or
 * maintains the bank details in Cash Management.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Payment type must be available. If not third party payment then a default
 * defined balance must exists for the business group or else for the
 * legislation or else for the global. Cash Analysis can be only performed if
 * products CE and PAY are installed. If a GL sets of book is selected then
 * Asset Key flexfield structure must be defined.
 *
 * <p><b>Post Success</b><br>
 * The organization payment method will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the org payment method then it raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ORG_PAYMENT_METHODS_F.BUSINESS_GROUP_ID}
 * @param p_org_payment_method_name Name of the payment method. [Translated
 * Value].
 * @param p_payment_type_id {@rep:casecolumn
 * PAY_ORG_PAYMENT_METHODS_F.PAYMENT_TYPE_ID}
 * @param p_currency_code {@rep:casecolumn
 * PAY_ORG_PAYMENT_METHODS_F.CURRENCY_CODE}
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
 * @param p_pmeth_information1 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information2 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information3 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information4 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information5 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information6 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information7 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information8 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information9 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information10 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information11 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information12 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information13 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information14 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information15 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information16 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information17 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information18 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information19 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information20 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_comments Organization payment method comment text.
 * @param p_segment1 Key flexfield segment containing External Account Info.
 * @param p_segment2 Key flexfield segment containing External Account Info.
 * @param p_segment3 Key flexfield segment containing External Account Info.
 * @param p_segment4 Key flexfield segment containing External Account Info.
 * @param p_segment5 Key flexfield segment containing External Account Info.
 * @param p_segment6 Key flexfield segment containing External Account Info.
 * @param p_segment7 Key flexfield segment containing External Account Info.
 * @param p_segment8 Key flexfield segment containing External Account Info.
 * @param p_segment9 Key flexfield segment containing External Account Info.
 * @param p_segment10 Key flexfield segment containing External Account Info.
 * @param p_segment11 Key flexfield segment containing External Account Info.
 * @param p_segment12 Key flexfield segment containing External Account Info.
 * @param p_segment13 Key flexfield segment containing External Account Info.
 * @param p_segment14 Key flexfield segment containing External Account Info.
 * @param p_segment15 Key flexfield segment containing External Account Info.
 * @param p_segment16 Key flexfield segment containing External Account Info.
 * @param p_segment17 Key flexfield segment containing External Account Info.
 * @param p_segment18 Key flexfield segment containing External Account Info.
 * @param p_segment19 Key flexfield segment containing External Account Info.
 * @param p_segment20 Key flexfield segment containing External Account Info.
 * @param p_segment21 Key flexfield segment containing External Account Info.
 * @param p_segment22 Key flexfield segment containing External Account Info.
 * @param p_segment23 Key flexfield segment containing External Account Info.
 * @param p_segment24 Key flexfield segment containing External Account Info.
 * @param p_segment25 Key flexfield segment containing External Account Info.
 * @param p_segment26 Key flexfield segment containing External Account Info.
 * @param p_segment27 Key flexfield segment containing External Account Info.
 * @param p_segment28 Key flexfield segment containing External Account Info.
 * @param p_segment29 Key flexfield segment containing External Account Info.
 * @param p_segment30 Key flexfield segment containing External Account Info.
 * @param p_concat_segments Key flexfield concatenated segment containing
 * External Account Info.
 * @param p_gl_segment1 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment2 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment3 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment4 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment5 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment6 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment7 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment8 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment9 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment10 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment11 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment12 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment13 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment14 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment15 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment16 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment17 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment18 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment19 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment20 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment21 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment22 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment23 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment24 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment25 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment26 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment27 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment28 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment29 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment30 Key flexfield segment containing GL Asset Info.
 * @param p_gl_concat_segments Key flexfield concatenated segment containing GL
 * Asset Info.
 * @param p_gl_ctrl_segment1 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment2 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment3 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment4 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment5 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment6 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment7 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment8 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment9 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment10 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment11 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment12 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment13 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment14 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment15 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment16 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment17 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment18 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment19 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment20 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment21 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment22 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment23 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment24 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment25 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment26 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment27 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment28 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment29 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment30 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_concat_segments Key flexfield concatenated segment
 * containing GL Control Account Info.
 * @param p_gl_ccrl_segment1 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment2 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment3 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment4 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment5 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment6 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment7 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment8 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment9 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment10 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment11 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment12 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment13 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment14 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment15 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment16 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment17 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment18 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment19 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment20 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment21 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment22 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment23 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment24 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment25 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment26 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment27 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment28 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment29 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment30 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_concat_segments Key flexfield concatenated segment
 * containing GL Cash Clearing Account Info.
 * @param p_gl_err_segment1 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment2 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment3 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment4 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment5 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment6 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment7 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment8 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment9 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment10 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment11 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment12 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment13 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment14 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment15 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment16 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment17 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment18 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment19 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment20 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment21 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment22 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment23 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment24 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment25 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment26 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment27 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment28 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment29 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment30 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_concat_segments Key flexfield concatenated segment
 * containing GL Error Account Info.
 * @param p_sets_of_book_id Foreign Key to GL Sets of Books
 * @param p_third_party_payment Third Party Flag (Y/N). YES_NO lookup type of
 * HR_LOOKUPS Default 'N'.
 * @param p_transfer_to_gl_flag Transfer to GL flag.
 * @param p_cost_payment Allow Cosing of payment.
 * @param p_cost_cleared_payment Allow Costing of cleared payment.
 * @param p_cost_cleared_void_payment Allow Costing of cleared void payment.
 * @param p_exclude_manual_payment Exclude manual payment from Cositng.
 * @param p_default_gl_account Default the GL account for the given bank account.
 * @param p_bank_account_id Identifier for the payroll external account.
 * @param p_org_payment_method_id If p_validate is false, this uniquely
 * identifies the Organization Payment Method created. If p_validate is set to
 * true, this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created organization payment method.
 * If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created organization payment method. If
 * p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created organization payment method. If p_validate is
 * true, then the value will be null.
 * @param p_asset_code_combination_id If p_validate is false, this uniquely
 * identifies the Asset Code Combination created. If p_validate is set to true,
 * this parameter will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created organization payment
 * method comment record. If p_validate is true or no comment text was
 * provided, then will be null.
 * @param p_external_account_id If p_validate is false, this uniquely
 * identifies the External Account created. If p_validate is set to true, this
 * parameter will be null.
 * @rep:displayname Create Organization Payment Method
 * @rep:category BUSINESS_ENTITY PAY_ORG_PAYMENT_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_org_payment_method
  (P_VALIDATE                      in     boolean  default false
  ,P_EFFECTIVE_DATE                in     date
  ,P_LANGUAGE_CODE                 in     varchar2 default hr_api.userenv_lang
  ,P_BUSINESS_GROUP_ID             in     number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2
  ,P_PAYMENT_TYPE_ID               in     number
  ,P_CURRENCY_CODE                 in     varchar2 default null
  ,P_ATTRIBUTE_CATEGORY            in     varchar2 default null
  ,P_ATTRIBUTE1                    in     varchar2 default null
  ,P_ATTRIBUTE2                    in     varchar2 default null
  ,P_ATTRIBUTE3                    in     varchar2 default null
  ,P_ATTRIBUTE4                    in     varchar2 default null
  ,P_ATTRIBUTE5                    in     varchar2 default null
  ,P_ATTRIBUTE6                    in     varchar2 default null
  ,P_ATTRIBUTE7                    in     varchar2 default null
  ,P_ATTRIBUTE8                    in     varchar2 default null
  ,P_ATTRIBUTE9                    in     varchar2 default null
  ,P_ATTRIBUTE10                   in     varchar2 default null
  ,P_ATTRIBUTE11                   in     varchar2 default null
  ,P_ATTRIBUTE12                   in     varchar2 default null
  ,P_ATTRIBUTE13                   in     varchar2 default null
  ,P_ATTRIBUTE14                   in     varchar2 default null
  ,P_ATTRIBUTE15                   in     varchar2 default null
  ,P_ATTRIBUTE16                   in     varchar2 default null
  ,P_ATTRIBUTE17                   in     varchar2 default null
  ,P_ATTRIBUTE18                   in     varchar2 default null
  ,P_ATTRIBUTE19                   in     varchar2 default null
  ,P_ATTRIBUTE20                   in     varchar2 default null
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2 default null
  ,P_PMETH_INFORMATION1            in     varchar2 default null
  ,P_PMETH_INFORMATION2            in     varchar2 default null
  ,P_PMETH_INFORMATION3            in     varchar2 default null
  ,P_PMETH_INFORMATION4            in     varchar2 default null
  ,P_PMETH_INFORMATION5            in     varchar2 default null
  ,P_PMETH_INFORMATION6            in     varchar2 default null
  ,P_PMETH_INFORMATION7            in     varchar2 default null
  ,P_PMETH_INFORMATION8            in     varchar2 default null
  ,P_PMETH_INFORMATION9            in     varchar2 default null
  ,P_PMETH_INFORMATION10           in     varchar2 default null
  ,P_PMETH_INFORMATION11           in     varchar2 default null
  ,P_PMETH_INFORMATION12           in     varchar2 default null
  ,P_PMETH_INFORMATION13           in     varchar2 default null
  ,P_PMETH_INFORMATION14           in     varchar2 default null
  ,P_PMETH_INFORMATION15           in     varchar2 default null
  ,P_PMETH_INFORMATION16           in     varchar2 default null
  ,P_PMETH_INFORMATION17           in     varchar2 default null
  ,P_PMETH_INFORMATION18           in     varchar2 default null
  ,P_PMETH_INFORMATION19           in     varchar2 default null
  ,P_PMETH_INFORMATION20           in     varchar2 default null
  ,P_COMMENTS                      in     varchar2 default null
  ,P_SEGMENT1                      in     varchar2 default null
  ,P_SEGMENT2                      in     varchar2 default null
  ,P_SEGMENT3                      in     varchar2 default null
  ,P_SEGMENT4                      in     varchar2 default null
  ,P_SEGMENT5                      in     varchar2 default null
  ,P_SEGMENT6                      in     varchar2 default null
  ,P_SEGMENT7                      in     varchar2 default null
  ,P_SEGMENT8                      in     varchar2 default null
  ,P_SEGMENT9                      in     varchar2 default null
  ,P_SEGMENT10                     in     varchar2 default null
  ,P_SEGMENT11                     in     varchar2 default null
  ,P_SEGMENT12                     in     varchar2 default null
  ,P_SEGMENT13                     in     varchar2 default null
  ,P_SEGMENT14                     in     varchar2 default null
  ,P_SEGMENT15                     in     varchar2 default null
  ,P_SEGMENT16                     in     varchar2 default null
  ,P_SEGMENT17                     in     varchar2 default null
  ,P_SEGMENT18                     in     varchar2 default null
  ,P_SEGMENT19                     in     varchar2 default null
  ,P_SEGMENT20                     in     varchar2 default null
  ,P_SEGMENT21                     in     varchar2 default null
  ,P_SEGMENT22                     in     varchar2 default null
  ,P_SEGMENT23                     in     varchar2 default null
  ,P_SEGMENT24                     in     varchar2 default null
  ,P_SEGMENT25                     in     varchar2 default null
  ,P_SEGMENT26                     in     varchar2 default null
  ,P_SEGMENT27                     in     varchar2 default null
  ,P_SEGMENT28                     in     varchar2 default null
  ,P_SEGMENT29                     in     varchar2 default null
  ,P_SEGMENT30                     in     varchar2 default null
  ,P_CONCAT_SEGMENTS               in     varchar2 default null
  ,P_GL_SEGMENT1                   in     varchar2 default null
  ,P_GL_SEGMENT2                   in     varchar2 default null
  ,P_GL_SEGMENT3                   in     varchar2 default null
  ,P_GL_SEGMENT4                   in     varchar2 default null
  ,P_GL_SEGMENT5                   in     varchar2 default null
  ,P_GL_SEGMENT6                   in     varchar2 default null
  ,P_GL_SEGMENT7                   in     varchar2 default null
  ,P_GL_SEGMENT8                   in     varchar2 default null
  ,P_GL_SEGMENT9                   in     varchar2 default null
  ,P_GL_SEGMENT10                  in     varchar2 default null
  ,P_GL_SEGMENT11                  in     varchar2 default null
  ,P_GL_SEGMENT12                  in     varchar2 default null
  ,P_GL_SEGMENT13                  in     varchar2 default null
  ,P_GL_SEGMENT14                  in     varchar2 default null
  ,P_GL_SEGMENT15                  in     varchar2 default null
  ,P_GL_SEGMENT16                  in     varchar2 default null
  ,P_GL_SEGMENT17                  in     varchar2 default null
  ,P_GL_SEGMENT18                  in     varchar2 default null
  ,P_GL_SEGMENT19                  in     varchar2 default null
  ,P_GL_SEGMENT20                  in     varchar2 default null
  ,P_GL_SEGMENT21                  in     varchar2 default null
  ,P_GL_SEGMENT22                  in     varchar2 default null
  ,P_GL_SEGMENT23                  in     varchar2 default null
  ,P_GL_SEGMENT24                  in     varchar2 default null
  ,P_GL_SEGMENT25                  in     varchar2 default null
  ,P_GL_SEGMENT26                  in     varchar2 default null
  ,P_GL_SEGMENT27                  in     varchar2 default null
  ,P_GL_SEGMENT28                  in     varchar2 default null
  ,P_GL_SEGMENT29                  in     varchar2 default null
  ,P_GL_SEGMENT30                  in     varchar2 default null
  ,P_GL_CONCAT_SEGMENTS            in     varchar2 default null
  ,P_GL_CTRL_SEGMENT1              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT2              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT3              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT4              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT5              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT6              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT7              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT8              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT9              in     varchar2 default null
  ,P_GL_CTRL_SEGMENT10             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT11             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT12             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT13             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT14             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT15             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT16             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT17             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT18             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT19             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT20             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT21             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT22             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT23             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT24             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT25             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT26             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT27             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT28             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT29             in     varchar2 default null
  ,P_GL_CTRL_SEGMENT30             in     varchar2 default null
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2 default null
  ,P_GL_CCRL_SEGMENT1              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT2              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT3              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT4              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT5              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT6              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT7              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT8              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT9              in     varchar2 default null
  ,P_GL_CCRL_SEGMENT10             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT11             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT12             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT13             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT14             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT15             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT16             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT17             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT18             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT19             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT20             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT21             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT22             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT23             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT24             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT25             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT26             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT27             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT28             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT29             in     varchar2 default null
  ,P_GL_CCRL_SEGMENT30             in     varchar2 default null
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2 default null
  ,P_GL_ERR_SEGMENT1               in     varchar2 default null
  ,P_GL_ERR_SEGMENT2               in     varchar2 default null
  ,P_GL_ERR_SEGMENT3               in     varchar2 default null
  ,P_GL_ERR_SEGMENT4               in     varchar2 default null
  ,P_GL_ERR_SEGMENT5               in     varchar2 default null
  ,P_GL_ERR_SEGMENT6               in     varchar2 default null
  ,P_GL_ERR_SEGMENT7               in     varchar2 default null
  ,P_GL_ERR_SEGMENT8               in     varchar2 default null
  ,P_GL_ERR_SEGMENT9               in     varchar2 default null
  ,P_GL_ERR_SEGMENT10              in     varchar2 default null
  ,P_GL_ERR_SEGMENT11              in     varchar2 default null
  ,P_GL_ERR_SEGMENT12              in     varchar2 default null
  ,P_GL_ERR_SEGMENT13              in     varchar2 default null
  ,P_GL_ERR_SEGMENT14              in     varchar2 default null
  ,P_GL_ERR_SEGMENT15              in     varchar2 default null
  ,P_GL_ERR_SEGMENT16              in     varchar2 default null
  ,P_GL_ERR_SEGMENT17              in     varchar2 default null
  ,P_GL_ERR_SEGMENT18              in     varchar2 default null
  ,P_GL_ERR_SEGMENT19              in     varchar2 default null
  ,P_GL_ERR_SEGMENT20              in     varchar2 default null
  ,P_GL_ERR_SEGMENT21              in     varchar2 default null
  ,P_GL_ERR_SEGMENT22              in     varchar2 default null
  ,P_GL_ERR_SEGMENT23              in     varchar2 default null
  ,P_GL_ERR_SEGMENT24              in     varchar2 default null
  ,P_GL_ERR_SEGMENT25              in     varchar2 default null
  ,P_GL_ERR_SEGMENT26              in     varchar2 default null
  ,P_GL_ERR_SEGMENT27              in     varchar2 default null
  ,P_GL_ERR_SEGMENT28              in     varchar2 default null
  ,P_GL_ERR_SEGMENT29              in     varchar2 default null
  ,P_GL_ERR_SEGMENT30              in     varchar2 default null
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2 default null
  ,P_SETS_OF_BOOK_ID               in     number   default null
  ,P_THIRD_PARTY_PAYMENT           in     varchar2 default 'N'
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2 default null
  ,P_COST_PAYMENT                  in     varchar2 default null
  ,P_COST_CLEARED_PAYMENT          in     varchar2 default null
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2 default null
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2 default null
  ,P_DEFAULT_GL_ACCOUNT		   in     varchar2 default 'Y'
  ,P_BANK_ACCOUNT_ID               in     number default null
  ,P_ORG_PAYMENT_METHOD_ID            out nocopy number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  ,P_OBJECT_VERSION_NUMBER            out nocopy number
  ,P_ASSET_CODE_COMBINATION_ID        out nocopy number
  ,P_COMMENT_ID                       out nocopy number
  ,P_EXTERNAL_ACCOUNT_ID              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_org_payment_method >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization payment method record.
 *
 * In addition to updating the organization payment method it also maintain the
 * bank details in Cash Management.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Payment type must be available. If not third party payment then a default
 * defined balance must exists for the business group or else for the
 * legislation or else for the global. Cash Analysis can be only performed if
 * products CE and PAY are installed. If a GL sets of book is selected then
 * Asset Key flexfield structure must be defined.
 *
 * <p><b>Post Success</b><br>
 * The organization payment method will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the org payment method then it raises an error.
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
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_org_payment_method_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the org
 * payment method to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated org payment method. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_org_payment_method_name Name of the payment method. [Translated
 * Value].
 * @param p_currency_code {@rep:casecolumn
 * PAY_ORG_PAYMENT_METHODS_F.CURRENCY_CODE}
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
 * @param p_pmeth_information1 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information2 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information3 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information4 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information5 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information6 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information7 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information8 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information9 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information10 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information11 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information12 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information13 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information14 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information15 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information16 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information17 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information18 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information19 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_pmeth_information20 Developer Descriptive flexfield segment
 * containing Cash Analysis Info.
 * @param p_comments Organization payment method comment text.
 * @param p_segment1 Key flexfield segment containing External Account Info.
 * @param p_segment2 Key flexfield segment containing External Account Info.
 * @param p_segment3 Key flexfield segment containing External Account Info.
 * @param p_segment4 Key flexfield segment containing External Account Info.
 * @param p_segment5 Key flexfield segment containing External Account Info.
 * @param p_segment6 Key flexfield segment containing External Account Info.
 * @param p_segment7 Key flexfield segment containing External Account Info.
 * @param p_segment8 Key flexfield segment containing External Account Info.
 * @param p_segment9 Key flexfield segment containing External Account Info.
 * @param p_segment10 Key flexfield segment containing External Account Info.
 * @param p_segment11 Key flexfield segment containing External Account Info.
 * @param p_segment12 Key flexfield segment containing External Account Info.
 * @param p_segment13 Key flexfield segment containing External Account Info.
 * @param p_segment14 Key flexfield segment containing External Account Info.
 * @param p_segment15 Key flexfield segment containing External Account Info.
 * @param p_segment16 Key flexfield segment containing External Account Info.
 * @param p_segment17 Key flexfield segment containing External Account Info.
 * @param p_segment18 Key flexfield segment containing External Account Info.
 * @param p_segment19 Key flexfield segment containing External Account Info.
 * @param p_segment20 Key flexfield segment containing External Account Info.
 * @param p_segment21 Key flexfield segment containing External Account Info.
 * @param p_segment22 Key flexfield segment containing External Account Info.
 * @param p_segment23 Key flexfield segment containing External Account Info.
 * @param p_segment24 Key flexfield segment containing External Account Info.
 * @param p_segment25 Key flexfield segment containing External Account Info.
 * @param p_segment26 Key flexfield segment containing External Account Info.
 * @param p_segment27 Key flexfield segment containing External Account Info.
 * @param p_segment28 Key flexfield segment containing External Account Info.
 * @param p_segment29 Key flexfield segment containing External Account Info.
 * @param p_segment30 Key flexfield segment containing External Account Info.
 * @param p_concat_segments Key flexfield concatenated segment containing
 * External Account Info.
 * @param p_gl_segment1 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment2 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment3 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment4 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment5 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment6 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment7 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment8 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment9 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment10 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment11 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment12 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment13 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment14 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment15 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment16 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment17 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment18 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment19 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment20 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment21 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment22 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment23 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment24 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment25 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment26 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment27 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment28 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment29 Key flexfield segment containing GL Asset Info.
 * @param p_gl_segment30 Key flexfield segment containing GL Asset Info.
 * @param p_gl_concat_segments Key flexfield concatenated segment containing GL
 * Asset Info.
 * @param p_gl_ctrl_segment1 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment2 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment3 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment4 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment5 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment6 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment7 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment8 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment9 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment10 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment11 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment12 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment13 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment14 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment15 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment16 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment17 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment18 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment19 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment20 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment21 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment22 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment23 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment24 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment25 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment26 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment27 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment28 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment29 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_segment30 Key flexfield segment containing GL Control
 * Account Info.
 * @param p_gl_ctrl_concat_segments Key flexfield concatenated segment
 * containing GL Control Account Info.
 * @param p_gl_ccrl_segment1 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment2 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment3 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment4 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment5 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment6 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment7 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment8 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment9 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment10 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment11 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment12 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment13 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment14 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment15 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment16 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment17 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment18 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment19 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment20 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment21 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment22 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment23 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment24 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment25 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment26 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment27 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment28 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment29 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_segment30 Key flexfield segment containing GL Cash Clearing
 * Account Info.
 * @param p_gl_ccrl_concat_segments Key flexfield concatenated segment
 * containing GL Cash Clearing Account Info.
 * @param p_gl_err_segment1 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment2 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment3 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment4 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment5 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment6 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment7 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment8 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment9 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment10 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment11 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment12 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment13 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment14 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment15 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment16 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment17 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment18 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment19 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment20 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment21 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment22 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment23 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment24 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment25 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment26 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment27 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment28 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment29 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_segment30 Key flexfield segment containing GL Error
 * Account Info.
 * @param p_gl_err_concat_segments Key flexfield concatenated segment
 * containing GL Error Account Info.
 * @param p_sets_of_book_id Foreign Key to GL Sets of Books
 * @param p_transfer_to_gl_flag Transfer to GL flag.
 * @param p_cost_payment Allow Cosing of payment.
 * @param p_cost_cleared_payment Allow Costing of cleared payment.
 * @param p_cost_cleared_void_payment Allow Costing of cleared void payment.
 * @param p_exclude_manual_payment Exclude manual payment from Cositng.
 * @param p_default_gl_account Default the GL account for the given bank account.
 * @param p_bank_account_id Identifier for the payroll external account.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated organization payment method row which
 * now exists as of the effective date. If p_validate is true, then set to
 * null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated organization payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_asset_code_combination_id If p_validate is false, this uniquely
 * identifies the Asset Code Combination created. If p_validate is set to true,
 * this parameter will be null.
 * @param p_comment_id If p_validate is false, this uniquely identifies the
 * Comment updated. If p_validate is set to true, this parameter will be null.
 * @param p_external_account_id If p_validate is false, this uniquely
 * identifies the External Account updated. If p_validate is set to true, this
 * parameter will be null.
 * @rep:displayname Update Organization Payment Method
 * @rep:category BUSINESS_ENTITY PAY_ORG_PAYMENT_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_org_payment_method
  (P_VALIDATE                      in     boolean  default false
  ,P_EFFECTIVE_DATE                in     date
  ,P_DATETRACK_UPDATE_MODE         in     varchar2
  ,P_LANGUAGE_CODE                 in     varchar2 default hr_api.userenv_lang
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_OBJECT_VERSION_NUMBER         in out nocopy number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2 default hr_api.g_varchar2
  ,P_CURRENCY_CODE                 in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE_CATEGORY            in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE1                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE2                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE3                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE4                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE5                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE6                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE7                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE8                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE9                    in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE10                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE11                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE12                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE13                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE14                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE15                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE16                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE17                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE18                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE19                   in     varchar2 default hr_api.g_varchar2
  ,P_ATTRIBUTE20                   in     varchar2 default hr_api.g_varchar2
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION1            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION2            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION3            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION4            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION5            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION6            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION7            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION8            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION9            in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION10           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION11           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION12           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION13           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION14           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION15           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION16           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION17           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION18           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION19           in     varchar2 default hr_api.g_varchar2
  ,P_PMETH_INFORMATION20           in     varchar2 default hr_api.g_varchar2
  ,P_COMMENTS                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT1                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT2                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT3                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT4                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT5                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT6                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT7                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT8                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT9                      in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT10                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT11                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT12                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT13                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT14                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT15                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT16                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT17                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT18                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT19                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT20                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT21                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT22                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT23                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT24                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT25                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT26                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT27                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT28                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT29                     in     varchar2 default hr_api.g_varchar2
  ,P_SEGMENT30                     in     varchar2 default hr_api.g_varchar2
  ,P_CONCAT_SEGMENTS               in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT1                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT2                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT3                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT4                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT5                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT6                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT7                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT8                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT9                   in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT10                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT11                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT12                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT13                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT14                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT15                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT16                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT17                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT18                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT19                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT20                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT21                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT22                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT23                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT24                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT25                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT26                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT27                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT28                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT29                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_SEGMENT30                  in     varchar2 default hr_api.g_varchar2
  ,P_GL_CONCAT_SEGMENTS            in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT1              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT2              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT3              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT4              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT5              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT6              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT7              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT8              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT9              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT10             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT11             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT12             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT13             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT14             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT15             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT16             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT17             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT18             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT19             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT20             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT21             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT22             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT23             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT24             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT25             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT26             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT27             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT28             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT29             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_SEGMENT30             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT1              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT2              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT3              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT4              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT5              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT6              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT7              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT8              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT9              in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT10             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT11             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT12             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT13             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT14             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT15             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT16             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT17             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT18             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT19             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT20             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT21             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT22             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT23             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT24             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT25             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT26             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT27             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT28             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT29             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_SEGMENT30             in     varchar2 default hr_api.g_varchar2
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT1               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT2               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT3               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT4               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT5               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT6               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT7               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT8               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT9               in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT10              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT11              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT12              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT13              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT14              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT15              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT16              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT17              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT18              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT19              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT20              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT21              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT22              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT23              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT24              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT25              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT26              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT27              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT28              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT29              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_SEGMENT30              in     varchar2 default hr_api.g_varchar2
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2 default hr_api.g_varchar2
  ,P_SETS_OF_BOOK_ID               in     number   default hr_api.g_number
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2 default hr_api.g_varchar2
  ,P_COST_PAYMENT                  in     varchar2 default hr_api.g_varchar2
  ,P_COST_CLEARED_PAYMENT          in     varchar2 default hr_api.g_varchar2
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2 default hr_api.g_varchar2
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2 default hr_api.g_varchar2
  ,P_DEFAULT_GL_ACCOUNT		   in     varchar2 default 'Y'
  ,P_BANK_ACCOUNT_ID               in     number   default hr_api.g_number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  ,P_ASSET_CODE_COMBINATION_ID        out nocopy number
  ,P_COMMENT_ID                       out nocopy number
  ,P_EXTERNAL_ACCOUNT_ID              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_org_payment_method >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an organization payment method record.
 *
 * This only deletes if this payment method has not been referenced form other
 * records.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization payment method to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * The organization payment method will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Organization Payment Method then it raises an
 * error.
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
 * @param p_org_payment_method_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * organization payment method to be deleted. When the API completes if
 * p_validate is false, will be set to the new version number of the deleted
 * organization payment method. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted organization payment method row which
 * now exists as of the effective date. If p_validate is true or all row
 * instances have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted organization payment method row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @rep:displayname Delete Organization Payment Method
 * @rep:category BUSINESS_ENTITY PAY_ORG_PAYMENT_METHOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_org_payment_method
  (P_VALIDATE                      in     boolean  default false
  ,P_EFFECTIVE_DATE                in     date
  ,P_DATETRACK_DELETE_MODE         in     varchar2
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_OBJECT_VERSION_NUMBER         in out nocopy number
  ,P_EFFECTIVE_START_DATE             out nocopy date
  ,P_EFFECTIVE_END_DATE               out nocopy date
  );
--
--
--
end PAY_ORG_PAYMENT_METHOD_API;

 

/
