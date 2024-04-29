--------------------------------------------------------
--  DDL for Package HR_SG_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER AS
/* $Header: hrsgwrpm.pkh 120.1 2005/10/02 02:06:28 aroussel $ */
/*#
 * This Package contains APIs for creation of personal payment methods for
 * Singapore.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Payment Method for Singapore
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_sg_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the personal payment method of an employee for Singapore.
 *
 * This API creates the sg personal payment method as specified, for the
 * employee assignment identified by the parameter p_assignment_id. The API
 * calls the generic API create_personal_pay_method, with the parameters set as
 * appropriate for a sg employee assignment. As this API is effectively an
 * alternative to the API create_personal_pay_method, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See the generic API create_personal_pay_method
 *
 * <p><b>Post Success</b><br>
 * Successfully creates the person, personal payment method.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the personal payment method and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_assignment_id Identifies the assignment for which you create the
 * Personal Payment Method record.
 * @param p_org_payment_method_id {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.ORG_PAYMENT_METHOD_ID}
 * @param p_bank_account_number 12 digit bank account number for Singapore
 * @param p_bank_account_name Bank acc name
 * @param p_bank_account_type Bank acc type
 * @param p_bank_code Bank code
 * @param p_bank_name Bank name
 * @param p_branch_code Branch Code
 * @param p_branch_name Branch Name - Default Null
 * @param p_amount {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.AMOUNT}
 * @param p_percentage {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.PERCENTAGE}
 * @param p_priority {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PRIORITY}
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
 * @param p_payee_type Payee Type. Valid values are defined by the 'PAYEE_TYPE'
 * lookup type.
 * @param p_payee_id {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PAYEE_ID}
 * @param p_personal_payment_method_id If p_validate is FALSE, this uniquely
 * identifies the personal payment method created. If p_validate is set to
 * true, this parameter will be NULL.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is FALSE. If p_validate is set to true,
 * this parameter will be NULL.
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
 * @rep:displayname Create Personal Payment Method for Singapore
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_sg_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_assignment_id                 IN     NUMBER
  ,p_org_payment_method_id         IN     NUMBER
  ,p_bank_account_number           IN     VARCHAR2
  ,p_bank_account_name             IN     VARCHAR2
  ,p_bank_account_type             IN     VARCHAR2
  ,p_bank_code                     IN     VARCHAR2
  ,p_bank_name                     IN     VARCHAR2
  ,p_branch_code                   IN     VARCHAR2
  ,p_branch_name                   IN     VARCHAR2 DEFAULT NULL
  ,p_amount                        IN     NUMBER   DEFAULT NULL
  ,p_percentage                    IN     NUMBER   DEFAULT NULL
  ,p_priority                      IN     NUMBER
  ,p_comments                      IN     VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
  ,p_payee_type                    IN     VARCHAR2 DEFAULT NULL
  ,p_payee_id                      IN     NUMBER   DEFAULT NULL
  ,p_personal_payment_method_id    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT   NOCOPY NUMBER
  ,p_object_version_number         OUT   NOCOPY NUMBER
  ,p_effective_start_date          OUT   NOCOPY DATE
  ,p_effective_end_date            OUT   NOCOPY DATE
  ,p_comment_id                    OUT   NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_sg_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the personal payment method for Singapore.
 *
 * The API calls the generic API update_personal_pay_method, with the
 * parameters set as appropriate for a Singapore employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method to be updated must be for a sg assignment. See
 * API update_personal_pay_method for further details.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the person, personal payment method.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the personal payment method and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_personal_payment_method_id {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.ORG_PAYMENT_METHOD_ID}
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_bank_account_number 12 digit Bank acc no. for Singapore
 * @param p_bank_account_name Bank account name
 * @param p_bank_account_type Bank account type
 * @param p_bank_code Bank code
 * @param p_bank_name Bank name
 * @param p_branch_code 3 digit Branch Code
 * @param p_branch_name Branch Name - Default Null
 * @param p_amount {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.AMOUNT}
 * @param p_comments Comment text.
 * @param p_percentage {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.PERCENTAGE}
 * @param p_priority Indicates the priority of the personal payment method.
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
 * @param p_payee_type Payee Type. Valid values are defined by the 'PAYEE_TYPE'
 * lookup type.
 * @param p_payee_id {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PAYEE_ID}
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the personal payment method
 * comment record. If p_validate is true or no comment text exists, then will
 * be null.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is FALSE. If p_validate is set to true,
 * this parameter will be NULL.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated personal payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated personal payment method row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Personal Payment Method for Singapore
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_sg_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_datetrack_update_mode         IN     VARCHAR2
  ,p_personal_payment_method_id    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_bank_account_number           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_account_name             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_account_type             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_name                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_name                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT    NOCOPY NUMBER
  ,p_effective_start_date          OUT    NOCOPY DATE
  ,p_effective_end_date            OUT    NOCOPY DATE
  );

END hr_sg_personal_pay_method_api;

 

/
