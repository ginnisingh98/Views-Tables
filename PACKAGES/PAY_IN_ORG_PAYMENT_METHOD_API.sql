--------------------------------------------------------
--  DDL for Package PAY_IN_ORG_PAYMENT_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_ORG_PAYMENT_METHOD_API" AUTHID CURRENT_USER AS
/* $Header: pyopmini.pkh 120.1 2005/10/02 02:46 aroussel $ */
/*#
 * This package contains organization payment method APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Organization Payment Method for India
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_org_payment_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an organization payment method.
 *
 * This API is to create an organization payment method (OPM). Also create or
 * maintain pay external accounts, ap bank accounts all, and ap bank branches.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * 1. A Payment type must be available. &lt;BR&gt;2. If not third party payment
 * then a default defined balance must exist for the business group or else for
 * the legislation or else for the global. &lt;BR&gt;3. Currency code should
 * exist within fnd_currency_vl &lt;BR&gt;4. Cash Analysis can only be
 * performed if products CE and PAY are installed. &lt;BR&gt;5. A Bank Keyflex
 * structure should be defined within the PAY_LEGISLATION_RULES for the payment
 * type's territory code or else for the business group's legislation code.
 * &lt;BR&gt;6. If a GL sets of book is selected then Asset Keyflex structure
 * must be - defined.
 *
 * <p><b>Post Success</b><br>
 * Creates a new organization payment method.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization payment method and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Business Group of the record
 * @param p_org_payment_method_name Name of the organization payment method.
 * [Translated Value]
 * @param p_payment_type_id Foreign key to Pay_payment_types.
 * @param p_currency_code If Payment Type's Currency_Code is NULL then this is
 * a mandatory parameter.
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
 * @param p_payable_at Company Id.
 * @param p_comments Comment text.
 * @param p_account_number Account Number
 * @param p_account_type Bank Account Type. Valid values are defined by
 * 'IN_ACCOUNT_TYPE' lookup type.
 * @param p_bank_code Bank Code. Valid values are defined by 'IN_BANK' lookup
 * type.
 * @param p_branch_code Bank Branch Code. Valid values are defined by
 * 'IN_BANK_BRANCH' lookup type.
 * @param p_concat_segments External Account Info (Default null).
 * @param p_gl_segment1 GL Asset information (Default Null).
 * @param p_gl_segment2 GL Asset information (Default Null).
 * @param p_gl_segment3 GL Asset information (Default Null).
 * @param p_gl_segment4 GL Asset information (Default Null).
 * @param p_gl_segment5 GL Asset information (Default Null).
 * @param p_gl_segment6 GL Asset information (Default Null).
 * @param p_gl_segment7 GL Asset information (Default Null).
 * @param p_gl_segment8 GL Asset information (Default Null).
 * @param p_gl_segment9 GL Asset information (Default Null).
 * @param p_gl_segment10 GL Asset information (Default Null).
 * @param p_gl_segment11 GL Asset information (Default Null).
 * @param p_gl_segment12 GL Asset information (Default Null).
 * @param p_gl_segment13 GL Asset information (Default Null).
 * @param p_gl_segment14 GL Asset information (Default Null).
 * @param p_gl_segment15 GL Asset information (Default Null).
 * @param p_gl_segment16 GL Asset information (Default Null).
 * @param p_gl_segment17 GL Asset information (Default Null).
 * @param p_gl_segment18 GL Asset information (Default Null).
 * @param p_gl_segment19 GL Asset information (Default Null).
 * @param p_gl_segment20 GL Asset information (Default Null).
 * @param p_gl_segment21 GL Asset information (Default Null).
 * @param p_gl_segment22 GL Asset information (Default Null).
 * @param p_gl_segment23 GL Asset information (Default Null).
 * @param p_gl_segment24 GL Asset information (Default Null).
 * @param p_gl_segment25 GL Asset information (Default Null).
 * @param p_gl_segment26 GL Asset information (Default Null).
 * @param p_gl_segment27 GL Asset information (Default Null).
 * @param p_gl_segment28 GL Asset information (Default Null).
 * @param p_gl_segment29 GL Asset information (Default Null).
 * @param p_gl_segment30 GL Asset information (Default Null).
 * @param p_gl_concat_segments GL Asset information (Default Null).
 * @param p_sets_of_book_id Foreign Key to GL Sets of Books.
 * @param p_third_party_payment Third Party Flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_org_payment_method_id Primary Key of the record. If p_validate is
 * false, this uniquely identifies the organization payment method created. If
 * p_validate is set to true, this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created organization payment method.
 * If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created organization payment method. If
 * p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created organization payment method. If p_validate is
 * true, then the value will be null.
 * @param p_asset_code_combination_id Keyflex id for the Asset Code
 * Combination.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created organization method
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_external_account_id Keyflex id for the External Account.
 * @rep:displayname Create Organization Payment Method for India
 * @rep:category BUSINESS_ENTITY PAY_ORG_PAYMENT_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_org_payment_method
  (P_VALIDATE                      IN     BOOLEAN  DEFAULT false
  ,P_EFFECTIVE_DATE                IN     DATE
  ,P_LANGUAGE_CODE                 IN     VARCHAR2 DEFAULT hr_api.userenv_lang
  ,P_BUSINESS_GROUP_ID             IN     NUMBER
  ,P_ORG_PAYMENT_METHOD_NAME       IN     VARCHAR2
  ,P_PAYMENT_TYPE_ID               IN     NUMBER
  ,P_CURRENCY_CODE                 IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE1                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE2                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE3                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE4                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE5                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE6                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE7                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE8                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE9                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE10                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE11                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE12                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE13                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE14                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE15                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE16                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE17                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE18                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE19                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE20                   IN     VARCHAR2 DEFAULT null
  ,p_payable_at                     IN    VARCHAR2 DEFAULT null -- Bugfix 3762728
  ,P_COMMENTS                      IN     VARCHAR2 DEFAULT null
  ,p_account_number               IN      VARCHAR2 DEFAULT null -- Bugfix 3762728
  ,p_account_type                  IN     VARCHAR2 DEFAULT null
  ,p_bank_code                     IN     VARCHAR2 DEFAULT null
  ,p_branch_code                   IN     VARCHAR2 DEFAULT null
  ,P_CONCAT_SEGMENTS               IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT1                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT2                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT3                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT4                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT5                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT6                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT7                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT8                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT9                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT10                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT11                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT12                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT13                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT14                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT15                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT16                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT17                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT18                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT19                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT20                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT21                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT22                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT23                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT24                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT25                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT26                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT27                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT28                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT29                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT30                  IN     VARCHAR2 DEFAULT null
  ,P_GL_CONCAT_SEGMENTS            IN     VARCHAR2 DEFAULT null
  ,P_SETS_OF_BOOK_ID               IN     NUMBER   DEFAULT null
  ,P_THIRD_PARTY_PAYMENT           IN     VARCHAR2 DEFAULT 'N'
  ,P_ORG_PAYMENT_METHOD_ID            OUT NOCOPY NUMBER
  ,P_EFFECTIVE_START_DATE             OUT NOCOPY DATE
  ,P_EFFECTIVE_END_DATE               OUT NOCOPY DATE
  ,P_OBJECT_VERSION_NUMBER            OUT NOCOPY NUMBER
  ,P_ASSET_CODE_COMBINATION_ID        OUT NOCOPY NUMBER
  ,P_COMMENT_ID                       OUT NOCOPY NUMBER
  ,P_EXTERNAL_ACCOUNT_ID              OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_org_payment_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization payment method.
 *
 * This API is to update an organization payment method (OPM). Also create or
 * maintain pay external accounts, ap bank accounts all, and ap bank branches.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * 0. An Org Payment Method must exist. &lt;BR&gt;1. A Payment type must be
 * available. &lt;BR&gt;2. If not third party payment then a default defined
 * balance must exist for the business group or else for the legislation or
 * else for the global. &lt;BR&gt;3. Currency code should exist within
 * fnd_currency_vl &lt;BR&gt;4. Cash Analysis can only be performed if products
 * CE and PAY are installed. &lt;BR&gt;5. A Bank Keyflex structure should be
 * defined within the PAY_LEGISLATION_RULES for the payment type's territory
 * code or else for the business group's legislation code. &lt;BR&gt;6. If a GL
 * sets of book is selected then Asset Keyflex structure must be - defined.
 *
 * <p><b>Post Success</b><br>
 * Updates the organization payment method.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the organization payment method and raises an error.
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
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_org_payment_method_id Id of the organization payment method to be
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * organization payment method to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * organization payment method. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_org_payment_method_name Name of the organization paymeny method.
 * [Translated Value]
 * @param p_currency_code If Payment Type's Currency_Code is NULL then this is
 * a mandatory parameter.
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
 * @param p_payable_at Company Id.
 * @param p_comments Comment text.
 * @param p_account_number Account Number.
 * @param p_account_type Bank Account Type. Valid values are defined by
 * 'IN_ACCOUNT_TYPE' lookup type.
 * @param p_bank_code Bank Code. Valid values are defined by 'IN_BANK' lookup
 * type.
 * @param p_branch_code Bank Branch Code. Valid values are defined by
 * 'IN_BANK_BRANCH' lookup type.
 * @param p_concat_segments External Account Information.
 * @param p_gl_segment1 GL Asset Information.
 * @param p_gl_segment2 GL Asset Information.
 * @param p_gl_segment3 GL Asset Information.
 * @param p_gl_segment4 GL Asset Information.
 * @param p_gl_segment5 GL Asset Information.
 * @param p_gl_segment6 GL Asset Information.
 * @param p_gl_segment7 GL Asset Information.
 * @param p_gl_segment8 GL Asset Information.
 * @param p_gl_segment9 GL Asset Information.
 * @param p_gl_segment10 GL Asset Information.
 * @param p_gl_segment11 GL Asset Information.
 * @param p_gl_segment12 GL Asset Information.
 * @param p_gl_segment13 GL Asset Information.
 * @param p_gl_segment14 GL Asset Information.
 * @param p_gl_segment15 GL Asset Information.
 * @param p_gl_segment16 GL Asset Information.
 * @param p_gl_segment17 GL Asset Information.
 * @param p_gl_segment18 GL Asset Information.
 * @param p_gl_segment19 GL Asset Information.
 * @param p_gl_segment20 GL Asset Information.
 * @param p_gl_segment21 GL Asset Information.
 * @param p_gl_segment22 GL Asset Information.
 * @param p_gl_segment23 GL Asset Information.
 * @param p_gl_segment24 GL Asset Information.
 * @param p_gl_segment25 GL Asset Information.
 * @param p_gl_segment26 GL Asset Information.
 * @param p_gl_segment27 GL Asset Information.
 * @param p_gl_segment28 GL Asset Information.
 * @param p_gl_segment29 GL Asset Information.
 * @param p_gl_segment30 GL Asset Information.
 * @param p_gl_concat_segments GL Asset Information.
 * @param p_sets_of_book_id Foreign Key to GL Sets of Books
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated organization payment method row which
 * now exists as of the effective date. If p_validate is true, then set to
 * null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated organization payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_asset_code_combination_id Keyflex id for the Asset Code
 * Combination.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the organization payment
 * method comment record. If p_validate is true or no comment text exists, then
 * will be null.
 * @param p_external_account_id Keyflex id for the External Account.
 * @rep:displayname Update Organization Payment Method for India
 * @rep:category BUSINESS_ENTITY PAY_ORG_PAYMENT_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_org_payment_method
  (P_VALIDATE                      IN     BOOLEAN  DEFAULT false
  ,P_EFFECTIVE_DATE                IN     DATE
  ,P_DATETRACK_UPDATE_MODE         IN     VARCHAR2
  ,P_LANGUAGE_CODE                 IN     VARCHAR2 DEFAULT hr_api.userenv_lang
  ,P_ORG_PAYMENT_METHOD_ID         IN     NUMBER
  ,P_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
  ,P_ORG_PAYMENT_METHOD_NAME       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_CURRENCY_CODE                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payable_at                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2 -- Bugfix 3762728
  ,P_COMMENTS                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_number                IN     VARCHAR2 DEFAULT hr_api.g_varchar2 -- Bugfix 3762728
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_CONCAT_SEGMENTS               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT1                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT2                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT3                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT4                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT5                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT6                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT7                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT8                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT9                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT10                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT11                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT12                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT13                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT14                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT15                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT16                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT17                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT18                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT19                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT20                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT21                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT22                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT23                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT24                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT25                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT26                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT27                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT28                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT29                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT30                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_CONCAT_SEGMENTS            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_SETS_OF_BOOK_ID               IN     NUMBER   DEFAULT hr_api.g_number
  ,P_EFFECTIVE_START_DATE             OUT NOCOPY DATE
  ,P_EFFECTIVE_END_DATE               OUT NOCOPY DATE
  ,P_ASSET_CODE_COMBINATION_ID        OUT NOCOPY NUMBER
  ,P_COMMENT_ID                       OUT NOCOPY NUMBER
  ,P_EXTERNAL_ACCOUNT_ID              OUT NOCOPY NUMBER
  );

END pay_in_org_payment_method_api;


 

/
