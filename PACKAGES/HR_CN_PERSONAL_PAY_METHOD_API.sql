--------------------------------------------------------
--  DDL for Package HR_CN_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER AS
/* $Header: hrcnwrpm.pkh 120.3 2005/11/04 05:36:46 jcolman noship $ */
/*#
 * This package contains APIs for creation of personal payment methods for
 * China.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Payment Method for China
*/
  g_trace BOOLEAN DEFAULT false;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_cn_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the personal payment method for an employee in business
 * groups using the legislation for China.
 *
 * The API calls the generic create_personal_pay_method API. It maps certain
 * columns to user-friendly names appropriate for China so as to ensure easy
 * identification. As this API is an alternative API, see the generic
 * create_personal_pay_method API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom the payment method is to be created must exist at the
 * effective date. The business group of the person must belong to Chinese
 * legislation. See the corresponding generic API for further details.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method for the employee will be created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the personal payment method and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_assignment_id Identifies the assignment for which you create the
 * personal payment method record.
 * @param p_org_payment_method_id {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.ORG_PAYMENT_METHOD_ID}
 * @param p_amount {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.AMOUNT}
 * @param p_percentage {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.PERCENTAGE}
 * @param p_priority {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PRIORITY}
 * @param p_comments Comment Text
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
 * @param p_bank_name Bank Name. 30 Characters width
 * @param p_bank_branch Bank Branch. 30 Characters width
 * @param p_bank_account_number Account Number. 20 Characters width
 * @param p_concat_segments External account combination string. If specified,
 * this takes precedence over any bank details specified.
 * @param p_payee_type Indicates the payee type of the person. Valid values are
 * defined by the 'PAYEE_TYPE' lookup type.
 * @param p_payee_id {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PAYEE_ID}
 * @param p_personal_payment_method_id If p_validate is false, this uniquely
 * identifies the personal payment method created. If p_validate is set to
 * true, this parameter will be null.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is false. If p_validate is set to true,
 * this parameter will be null.
 * @param p_object_version_number If p_validate is false, then this is set to
 * the version number of the created Personal Payment Method. If p_validate is
 * true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then this is set to
 * the earliest effective start date for the created personal pay method. If
 * p_validate is true, then his is set to null.
 * @param p_effective_end_date If p_validate is false, then this is set to the
 * effective end date for the created personal payment method. If p_validate is
 * true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then this will be set to the identifier of the created personal payment
 * method comment record. If p_validate is true or no comment text was
 * provided, then will be null.
 * @rep:displayname Create Personal Payment Method for China
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cn_personal_pay_method
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
  ,p_bank_name                     IN     VARCHAR2
  ,p_bank_branch                   IN     VARCHAR2
  ,p_bank_account_number           IN     VARCHAR2
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
-- |----------------------< update_cn_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the personal payment method for an employee in business
 * groups using the legislation for China.
 *
 * The API calls the generic update_personal_pay_method API. It maps certain
 * columns to user-friendly names appropriate for China so as to ensure easy
 * identification.As this API is an alternative API, see the generic
 * update_personal_pay_method API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method should already exists. The business group of the
 * person must belong to Chinese legislation. See the corresponding generic API
 * for further details.
 *
 * <p><b>Post Success</b><br>
 * The personal payment method will be updated.
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
 * @param p_object_version_number Passes in the current version number of the
 * personal payment method to be updated. When the API completes, if p_validate
 * is false, this will be set to the new version number of the updated personal
 * payment method. If p_validate is true this will be set to the same value.
 * @param p_amount {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.AMOUNT}
 * @param p_comments Comment Text
 * @param p_percentage {@rep:casecolumn
 * PAY_PERSONAL_PAYMENT_METHODS_F.PERCENTAGE}
 * @param p_priority {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PRIORITY}
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
 * @param p_bank_name Bank Name. 30 Characters width
 * @param p_bank_branch Bank Branch. 30 Characters width
 * @param p_bank_account_number Account Number. 20 Characters width
 * @param p_concat_segments External account combination string. If specified,
 * this takes precedence over bank details specified.
 * @param p_payee_type Indicates the payee type of the person. Valid values are
 * defined by the 'PAYEE_TYPE' lookup type.
 * @param p_payee_id {@rep:casecolumn PAY_PERSONAL_PAYMENT_METHODS_F.PAYEE_ID}
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then this will be set to the identifier of the personal payment
 * method comment record. If p_validate is true or no comment text exists, then
 * thiswill be null.
 * @param p_external_account_id Identifies the external account combination, if
 * a combination exists and p_validate is false. If p_validate is set to true,
 * this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then this is set to
 * the effective start date on the updated personal payment method row which
 * now exists as of the effective date. If p_validate is true, then this is set
 * to null.
 * @param p_effective_end_date If p_validate is false, then this is set to the
 * effective end date on the updated personal payment method row which now
 * exists as of the effective date. If p_validate is true, then this is set to
 * null.
 * @rep:displayname Update Personal Payment Method for China
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_cn_personal_pay_method
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
  ,p_bank_name                     IN     VARCHAR2
  ,p_bank_branch                   IN     VARCHAR2
  ,p_bank_account_number           IN     VARCHAR2
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY   NUMBER
  ,p_external_account_id           OUT    NOCOPY   NUMBER
  ,p_effective_start_date          OUT    NOCOPY   DATE
  ,p_effective_end_date            OUT    NOCOPY   DATE
  );

END hr_cn_personal_pay_method_api;

/
