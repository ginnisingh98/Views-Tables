--------------------------------------------------------
--  DDL for Package HR_MX_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_PERSONAL_PAY_METHOD_API" AUTHID CURRENT_USER AS
/* $Header: hrmxwrpm.pkh 120.1 2005/10/02 02:36:43 aroussel $ */
/*#
 * This package contains personal payment method APIs for Mexico
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Personal Payment Method for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_mx_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new personal payment method for a particular assignment
 * for Mexico.
 *
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
 * Personal payment method is successfully inserted.
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
 * @param p_run_type_id Identifies run type for which the personal payment
 * method is being created.
 * @param p_org_payment_method_id Identifies the organization payment method
 * used for the personal payment method.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_percentage The percentage of the assignment's pay to be paid by the
 * personal payment method (if applicable).
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
 * @param p_bank Bank code as defined by MX_BANK lookup.
 * @param p_branch Branch code.
 * @param p_account Account number.
 * @param p_account_type Account type as defined by MX_HR_BANK_ACCT_TYPE
 * lookup.
 * @param p_clabe CLABE number.
 * @param p_concat_segments External account combination string. Always takes
 * precedence over bank details specified above.
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
 * @rep:displayname Create Personal Payment Method for Mexico
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_mx_personal_pay_method
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
  ,p_bank                          in     varchar2
  ,p_branch                        in     varchar2
  ,p_account                       in     varchar2
  ,p_account_type                  in     varchar2
  ,p_clabe                         in     varchar2
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_mx_personal_pay_method >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 * This API updates an existing personal payment method for Mexico as
 * identified by the parameters p_personal_payment_method_id and
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
 * The personal payment method is successfully updated.
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
 * @param p_personal_payment_method_id Identifies the personal payment method
 * being updated.
 * @param p_object_version_number Pass in the current version number of the
 * personal payment method to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated personal
 * payment method. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_amount The fixed amount payable by the personal payment method (if
 * applicable).
 * @param p_comments Personal payment method comment text.
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
 * @param p_bank Bank code as defined by MX_BANK lookup.
 * @param p_branch Branch code.
 * @param p_account Account number.
 * @param p_account_type Account type as defined by MX_HR_BANK_ACCT_TYPE
 * lookup.
 * @param p_clabe CLABE number.
 * @param p_concat_segments External account combination string. Always takes
 * precedence over bank details specified above.
 * @param p_payee_type The payee type for a third party payment. A payee may be
 * a person (P) or a payee organization (O).
 * @param p_payee_id The payee for a third party payment. Refers to a person or
 * a payee organization depending on the value of p_payee_type.
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
 * @rep:displayname Update Personal Payment Method for Mexico
 * @rep:category BUSINESS_ENTITY PAY_PERSONAL_PAY_METHOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE update_mx_personal_pay_method
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
  ,p_bank                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_clabe                         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY   NUMBER
  ,p_external_account_id           OUT    NOCOPY   NUMBER
  ,p_effective_start_date          OUT    NOCOPY   DATE
  ,p_effective_end_date            OUT    NOCOPY   DATE
  ) ;

END hr_mx_personal_pay_method_api ;

 

/
