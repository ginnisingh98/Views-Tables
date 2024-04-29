--------------------------------------------------------
--  DDL for Package PER_BF_PAYMENT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYMENT_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: pebpdapi.pkh 120.1 2005/10/02 02:12:21 aroussel $ */
/*#
 * This package contains APIs that maintain backfeed payment details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Backfeed Payment Detail
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_payment_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates backfeed payment details for a processed assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The personal payment method has to exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payment detail will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payment detail will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group of the payment details.
 * @param p_personal_payment_method_id Personal payment method of the payment
 * details.
 * @param p_payroll_run_id Payroll run id of the payment.
 * @param p_assignment_id Assignment id of the payment detail.
 * @param p_check_number Number of the check.
 * @param p_payment_date Date of the payment.
 * @param p_amount Amount on the payment.
 * @param p_check_type Type of check.
 * @param p_currency_code The currency code of the amount. Required if the
 * amount is not null or 0.
 * @param p_bpd_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpd_attribute1 Descriptive flexfield segment.
 * @param p_bpd_attribute2 Descriptive flexfield segment.
 * @param p_bpd_attribute3 Descriptive flexfield segment.
 * @param p_bpd_attribute4 Descriptive flexfield segment.
 * @param p_bpd_attribute5 Descriptive flexfield segment.
 * @param p_bpd_attribute6 Descriptive flexfield segment.
 * @param p_bpd_attribute7 Descriptive flexfield segment.
 * @param p_bpd_attribute8 Descriptive flexfield segment.
 * @param p_bpd_attribute9 Descriptive flexfield segment.
 * @param p_bpd_attribute10 Descriptive flexfield segment.
 * @param p_bpd_attribute11 Descriptive flexfield segment.
 * @param p_bpd_attribute12 Descriptive flexfield segment.
 * @param p_bpd_attribute13 Descriptive flexfield segment.
 * @param p_bpd_attribute14 Descriptive flexfield segment.
 * @param p_bpd_attribute15 Descriptive flexfield segment.
 * @param p_bpd_attribute16 Descriptive flexfield segment.
 * @param p_bpd_attribute17 Descriptive flexfield segment.
 * @param p_bpd_attribute18 Descriptive flexfield segment.
 * @param p_bpd_attribute19 Descriptive flexfield segment.
 * @param p_bpd_attribute20 Descriptive flexfield segment.
 * @param p_bpd_attribute21 Descriptive flexfield segment.
 * @param p_bpd_attribute22 Descriptive flexfield segment.
 * @param p_bpd_attribute23 Descriptive flexfield segment.
 * @param p_bpd_attribute24 Descriptive flexfield segment.
 * @param p_bpd_attribute25 Descriptive flexfield segment.
 * @param p_bpd_attribute26 Descriptive flexfield segment.
 * @param p_bpd_attribute27 Descriptive flexfield segment.
 * @param p_bpd_attribute28 Descriptive flexfield segment.
 * @param p_bpd_attribute29 Descriptive flexfield segment.
 * @param p_bpd_attribute30 Descriptive flexfield segment.
 * @param p_payment_detail_id If p_validate is false, then this uniquely
 * identifies the backfeed payment detail created. If p_validate is true, then
 * set to null.
 * @param p_payment_detail_ovn If p_validate is false, then set to the version
 * number of the created backfeed payment detail. If p_validate is true, then
 * the value will be null.
 * @param p_processed_assignment_id The processed assignment for this backfeed
 * payment detail.
 * @param p_processed_assignment_ovn Version number of the processed assignment
 * @rep:displayname Create Backfeed Payment Detail
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_payment_detail
  (p_validate                     in      boolean  default false
  ,p_effective_date               in      date
  ,p_business_group_id            in      number
  ,p_personal_payment_method_id   in      number
  ,p_payroll_run_id               in      number
  ,p_assignment_id                in      number
  ,p_check_number                 in      number   default null
  ,p_payment_date                 in      date     default null
  ,p_amount                       in      number   default null
  ,p_check_type                   in      varchar2 default null
  ,p_currency_code                in      varchar2 default null
  ,p_bpd_attribute_category        in     varchar2 default null
  ,p_bpd_attribute1                in     varchar2 default null
  ,p_bpd_attribute2                in     varchar2 default null
  ,p_bpd_attribute3                in     varchar2 default null
  ,p_bpd_attribute4                in     varchar2 default null
  ,p_bpd_attribute5                in     varchar2 default null
  ,p_bpd_attribute6                in     varchar2 default null
  ,p_bpd_attribute7                in     varchar2 default null
  ,p_bpd_attribute8                in     varchar2 default null
  ,p_bpd_attribute9                in     varchar2 default null
  ,p_bpd_attribute10               in     varchar2 default null
  ,p_bpd_attribute11               in     varchar2 default null
  ,p_bpd_attribute12               in     varchar2 default null
  ,p_bpd_attribute13               in     varchar2 default null
  ,p_bpd_attribute14               in     varchar2 default null
  ,p_bpd_attribute15               in     varchar2 default null
  ,p_bpd_attribute16               in     varchar2 default null
  ,p_bpd_attribute17               in     varchar2 default null
  ,p_bpd_attribute18               in     varchar2 default null
  ,p_bpd_attribute19               in     varchar2 default null
  ,p_bpd_attribute20               in     varchar2 default null
  ,p_bpd_attribute21               in     varchar2 default null
  ,p_bpd_attribute22               in     varchar2 default null
  ,p_bpd_attribute23               in     varchar2 default null
  ,p_bpd_attribute24               in     varchar2 default null
  ,p_bpd_attribute25               in     varchar2 default null
  ,p_bpd_attribute26               in     varchar2 default null
  ,p_bpd_attribute27               in     varchar2 default null
  ,p_bpd_attribute28               in     varchar2 default null
  ,p_bpd_attribute29               in     varchar2 default null
  ,p_bpd_attribute30               in     varchar2 default null
  ,p_payment_detail_id               out nocopy    number
  ,p_payment_detail_ovn              out nocopy    number
  ,p_processed_assignment_id         out nocopy    number
  ,p_processed_assignment_ovn        out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_payment_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates backfeed payment details for a processed assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The backfeed payment detail should exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payment detail will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payment detail will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_check_number Number of the check.
 * @param p_payment_date Date of the payment.
 * @param p_amount Amount on the payment.
 * @param p_check_type Type of check.
 * @param p_payment_detail_id Uniquely identifies the payment detail.
 * @param p_currency_code The currency code of the amount. Required if the
 * amount is not null or 0.
 * @param p_bpd_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpd_attribute1 Descriptive flexfield segment.
 * @param p_bpd_attribute2 Descriptive flexfield segment.
 * @param p_bpd_attribute3 Descriptive flexfield segment.
 * @param p_bpd_attribute4 Descriptive flexfield segment.
 * @param p_bpd_attribute5 Descriptive flexfield segment.
 * @param p_bpd_attribute6 Descriptive flexfield segment.
 * @param p_bpd_attribute7 Descriptive flexfield segment.
 * @param p_bpd_attribute8 Descriptive flexfield segment.
 * @param p_bpd_attribute9 Descriptive flexfield segment.
 * @param p_bpd_attribute10 Descriptive flexfield segment.
 * @param p_bpd_attribute11 Descriptive flexfield segment.
 * @param p_bpd_attribute12 Descriptive flexfield segment.
 * @param p_bpd_attribute13 Descriptive flexfield segment.
 * @param p_bpd_attribute14 Descriptive flexfield segment.
 * @param p_bpd_attribute15 Descriptive flexfield segment.
 * @param p_bpd_attribute16 Descriptive flexfield segment.
 * @param p_bpd_attribute17 Descriptive flexfield segment.
 * @param p_bpd_attribute18 Descriptive flexfield segment.
 * @param p_bpd_attribute19 Descriptive flexfield segment.
 * @param p_bpd_attribute20 Descriptive flexfield segment.
 * @param p_bpd_attribute21 Descriptive flexfield segment.
 * @param p_bpd_attribute22 Descriptive flexfield segment.
 * @param p_bpd_attribute23 Descriptive flexfield segment.
 * @param p_bpd_attribute24 Descriptive flexfield segment.
 * @param p_bpd_attribute25 Descriptive flexfield segment.
 * @param p_bpd_attribute26 Descriptive flexfield segment.
 * @param p_bpd_attribute27 Descriptive flexfield segment.
 * @param p_bpd_attribute28 Descriptive flexfield segment.
 * @param p_bpd_attribute29 Descriptive flexfield segment.
 * @param p_bpd_attribute30 Descriptive flexfield segment.
 * @param p_payment_detail_ovn Pass in the current version number of the
 * backfeed payment detail to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated backfeed
 * payment detail. If p_validate is true will be set to the same value which
 * was passed in.
 * @rep:displayname Update Backfeed Payment Detail
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_payment_detail
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_check_number                  in     number   default hr_api.g_number
  ,p_payment_date                  in     date     default hr_api.g_date
  ,p_amount                        in     number   default hr_api.g_number
  ,p_check_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payment_detail_id             in     number
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_payment_detail_ovn            in     out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_payment_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes backfeed payment details for a processed assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The backfeed payment detail must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payment detail amount will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payment detail amount will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_payment_detail_id Uniquely identifies the payment detail.
 * @param p_payment_detail_ovn Current version number of the backfeed payment
 * detail to be deleted.
 * @rep:displayname Delete Backfeed Payment Detail
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_payment_detail
  (p_validate                     in      boolean  default false
  ,p_payment_detail_id            in      number
  ,p_payment_detail_ovn           in      number
  );
--
end PER_BF_PAYMENT_DETAILS_API ;

 

/
