--------------------------------------------------------
--  DDL for Package OTA_CERT_PRD_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_PRD_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otcpeapi.pkh 120.6.12010000.2 2008/09/22 11:03:17 pekasi ship $ */
/*#
 * This package contains Learning Certification Period Enrollment APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Certification Period Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cert_prd_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Certification Period Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Certification must exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Period Enrollment is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Certification Period Enrollment record and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cert_enrollment_id The unique identifier for the parent certification enrollment record.
 * @param p_period_status_code Status for the Certification Period Enrollment.
 * Valid values are defined by 'OTA_CERT_PRD_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_cert_period_start_date The date the certification period begins.
 * @param p_cert_period_end_date After this date the certification period ends.
 * @param p_business_group_id The business group owning the Certification Period
 * Enrollment record of the certification.
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
 * @param p_expiration_date After this date the certification is expired.
 * @param p_cert_prd_enrollment_id The unique identifier for the Certification Period Enrollment record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created
 * Certification Period Enrollment. If p_validate is true, then the value will be null.
 * @rep:displayname Create Certification Period Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cert_prd_enrollment
  (
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_cert_enrollment_id           in number,
  p_period_status_code           in varchar2,
  p_completion_date              in date             default null,
  p_cert_period_start_date       in date             default null,
  p_cert_period_end_date         in date             default null,
  p_business_group_id            in number,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_expiration_date              in date             default null,
  p_cert_prd_enrollment_id       out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_cert_prd_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Certification Period Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Period Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Period Enrollment is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Certification Period Enrollment record, and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are applicable during
 * the start to end active date range. This date does not determine when the changes take effect.
 * @param p_cert_prd_enrollment_id The unique identifier for the Certification Period Enrollment record.
 * @param p_object_version_number Pass in the current version number of the Certification Period
 * Enrollment to be updated. When the API completes if p_validate is false, will be set to the
 * new version number of the updated Certification Period Enrollment. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_cert_enrollment_id The unique identifier for the parent certification enrollment record.
 * @param p_period_status_code Status for the Certification Period Enrollment. Valid values are
 * defined by 'OTA_CERT_PRD_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_cert_period_start_date The date the certification period begin.
 * @param p_cert_period_end_date After this date the certification period end.
 * @param p_business_group_id The business group owning the Certification Period Enrollment record
 * of the certification.
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
 * @param p_expiration_date After this date the certification period is expired.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Certification Period Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cert_prd_enrollment
  (
  p_effective_date               in date,
  p_cert_prd_enrollment_id       in number,
  p_object_version_number        in out nocopy number,
  p_cert_enrollment_id           in number,
  p_period_status_code           in varchar2,
  p_completion_date              in date             default hr_api.g_date,
  p_cert_period_start_date       in date             default hr_api.g_date,
  p_cert_period_end_date         in date             default hr_api.g_date,
  p_business_group_id            in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_expiration_date              in date             default hr_api.g_date,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cert_prd_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Certification Period Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Period Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Period Enrollment is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Certification Period Enrollment record, and raises an error.
 *
 * @param p_cert_prd_enrollment_id The unique identifier for the Certification Period Enrollment record.
 * @param p_object_version_number Current version number of the Certification Period Enrollment to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Certification Period Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cert_prd_enrollment
  (p_cert_prd_enrollment_id        in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< renew_cert_prd_enrollment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API renews the Certification Period Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Period Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Period Enrollment is renewed successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not renew the Certification Period Enrollment record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cert_enrollment_id The unique identifier for the parent Certification Enrollment record.
 * @param p_cert_prd_enrollment_id The unique identifier for the Certification Period Enrollment record.
 * @param p_cert_period_start_date The period start date for the Certification Period Enrollment record.
 * @param p_certification_status_code Status for the Certification Enrollment. Valid values are defined
 * by 'OTA_CERT_ENROLL_STATUS'  lookup type.
 * @rep:displayname Renew Certification Period Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure renew_cert_prd_enrollment(p_validate in boolean default false
		       		    ,p_cert_enrollment_id in number
		       		    ,p_cert_period_start_date in date default sysdate
				    ,p_cert_prd_enrollment_id OUT NOCOPY number
				    ,p_certification_status_code OUT NOCOPY VARCHAR2);

end ota_cert_prd_enrollment_api;

/
