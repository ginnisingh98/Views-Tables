--------------------------------------------------------
--  DDL for Package HR_IN_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER AS
/* $Header: peinwrpm.pkh 120.3 2005/11/04 05:37 jcolman noship $ */
/*#
 * The package contains personal payment method APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Personal Payment Method for India
*/
g_trace BOOLEAN DEFAULT false;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_in_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a personal payment method.
 *
 * This API is effectively an alternative to the API create_personal_pay_method
 * for India localization. Personal payment method is created for the employee
 * assignment identified by the parameter p_assignment_id. The API calls the
 * generic API create_personal_pay_method, with the parameters set as
 * appropriate for a 'IN' employee assignment.
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
 * and there must exist a contact relationship, for third-party payments,
 * between the payee and the owner of the personal payment method.
 *
 * <p><b>Post Success</b><br>
 * A personal payment method is created.
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
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_percentage The percentage of the assignment's pay to be paid by the
 * personal payment method (if applicable).
 * @param p_priority The priority of the personal payment method.
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
 * @param p_account_number Bank Account Number.
 * @param p_account_type Bank Account Type. Valid values are defined by
 * 'IN_ACCOUNT_TYPE' lookup type.
 * @param p_bank_code Bank Code. Valid values are defined by 'IN_BANK' lookup
 * type.
 * @param p_branch_code Bank Branch Code. Valid values are defined by
 * 'IN_BANK_BRANCH' lookup type.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30.
 * @param p_payee_type The type of payee (for a third party payment). Valid
 * values are 'Person', 'Organization', 'None'.
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
 * @rep:displayname Create Personal Payment Method for India
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT false
  ,p_effective_date                IN     DATE
  ,p_assignment_id                 IN     NUMBER
  ,p_org_payment_method_id         IN     NUMBER
  ,p_amount                        IN     NUMBER   DEFAULT null
  ,p_percentage                    IN     NUMBER   DEFAULT null
  ,p_priority                      IN     NUMBER   DEFAULT null
  ,p_comments                      IN     VARCHAR2 DEFAULT null
  ,p_attribute_category            IN     VARCHAR2 DEFAULT null
  ,p_attribute1                    IN     VARCHAR2 DEFAULT null
  ,p_attribute2                    IN     VARCHAR2 DEFAULT null
  ,p_attribute3                    IN     VARCHAR2 DEFAULT null
  ,p_attribute4                    IN     VARCHAR2 DEFAULT null
  ,p_attribute5                    IN     VARCHAR2 DEFAULT null
  ,p_attribute6                    IN     VARCHAR2 DEFAULT null
  ,p_attribute7                    IN     VARCHAR2 DEFAULT null
  ,p_attribute8                    IN     VARCHAR2 DEFAULT null
  ,p_attribute9                    IN     VARCHAR2 DEFAULT null
  ,p_attribute10                   IN     VARCHAR2 DEFAULT null
  ,p_attribute11                   IN     VARCHAR2 DEFAULT null
  ,p_attribute12                   IN     VARCHAR2 DEFAULT null
  ,p_attribute13                   IN     VARCHAR2 DEFAULT null
  ,p_attribute14                   IN     VARCHAR2 DEFAULT null
  ,p_attribute15                   IN     VARCHAR2 DEFAULT null
  ,p_attribute16                   IN     VARCHAR2 DEFAULT null
  ,p_attribute17                   IN     VARCHAR2 DEFAULT null
  ,p_attribute18                   IN     VARCHAR2 DEFAULT null
  ,p_attribute19                   IN     VARCHAR2 DEFAULT null
  ,p_attribute20                   IN     VARCHAR2 DEFAULT null
  ,p_account_number                IN     VARCHAR2 DEFAULT null
  ,p_account_type                  IN     VARCHAR2 DEFAULT null
  ,p_bank_code                     IN     VARCHAR2 DEFAULT null
  ,p_branch_code		   IN     VARCHAR2 DEFAULT null
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT null
  ,p_payee_id                      IN     NUMBER   DEFAULT null
  ,p_personal_payment_method_id    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT    NOCOPY NUMBER
  ,p_object_version_number         OUT    NOCOPY NUMBER
  ,p_effective_start_date          OUT    NOCOPY DATE
  ,p_effective_end_date            OUT    NOCOPY DATE
  ,p_comment_id                    out    NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_in_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a personal payment method.
 *
 * Personal payment method is updated for an employee assignment as identified
 * by the parameter p_personal_payment_method_id and p_object_version_number,
 * where the personal payment method is for a 'IN' assignment. The API calls
 * the generic API update_personal_pay_method, with the parameters set as
 * appropriate for a 'IN' employee assignment. This API is effectively an
 * alternative to the API create_personal_pay_method for India localization.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method as identified by the in parameters
 * p_personal_payment_method_id and p_object_version_number must already exist.
 * The personal payment method to be updated must be for a 'IN' assignment.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method is updated.
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
 * @param p_personal_payment_method_id Id of personal payment method being
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_comments Comment text.
 * @param p_percentage The percentage of the assignment's pay to be paid by the
 * personal payment method (if applicable).
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
 * @param p_account_number Bank Account Number.
 * @param p_account_type Bank Account Type. Valid values are defined by
 * 'IN_ACCOUNT_TYPE' lookup type.
 * @param p_bank_code Bank Code. Valid values are defined by 'IN_BANK' lookup
 * type.
 * @param p_branch_code Bank Branch Code. Valid values are defined by
 * 'IN_BANK_BRANCH' lookup type.
 * @param p_concat_segments External account combination string, if specified
 * takes precedence over segment1...30.
 * @param p_payee_type The type of payee (for a third party payment). Valid
 * values are 'Person', 'Organization', 'None'.
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
 * @rep:displayname Update Personal Payment Method for India
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT false
  ,p_effective_date                IN     DATE
  ,p_datetrack_update_mode         IN     VARCHAR2
  ,p_personal_payment_method_id    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY   NUMBER
  ,p_amount                        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comments                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_percentage                    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_priority                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_attribute_category            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_number                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code		   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY   NUMBER
  ,p_external_account_id           OUT    NOCOPY   NUMBER
  ,p_effective_start_date          OUT    NOCOPY   DATE
  ,p_effective_end_date            OUT    NOCOPY   DATE
  );

END hr_in_personal_pay_method_api;

 

/
