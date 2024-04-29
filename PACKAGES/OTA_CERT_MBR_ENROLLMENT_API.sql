--------------------------------------------------------
--  DDL for Package OTA_CERT_MBR_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MBR_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otcmeapi.pkh 120.4 2006/07/13 11:44:44 niarora noship $ */
/*#
 * This package contains Certification Member Enrollment APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Certification Member Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cert_mbr_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Certification Member Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * This Certification and certification components should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Member Enrollment is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Certification Member Enrollment record and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cert_prd_enrollment_id The unique identifier for the parent certification
 * period enrollment record.
 * @param p_cert_member_id The unique identifier for the certification member record.
 * @param p_member_status_code Status for the Certification Member Enrollment.
 * Valid values are defined by 'OTA_CERT_MBR_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_business_group_id The business group owning the Certification Member
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
 * @param p_cert_mbr_enrollment_id The unique identifier for the Certification Member Enrollment record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created
 * Certification Member Enrollment. If p_validate is true, then the value will be null.
 * @rep:displayname Create Certification Member Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cert_mbr_enrollment
  (
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_cert_prd_enrollment_id       in number,
  p_cert_member_id               in number,
  p_member_status_code           in varchar2,
  p_completion_date              in date             default null,
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
  p_cert_mbr_enrollment_id       out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_cert_mbr_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Certification Member Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Member Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Member Enrollment is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Certification Member Enrollment record, and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cert_mbr_enrollment_id The unique identifier for the Certification Member Enrollment record.
 * @param p_object_version_number Pass in the current version number of the Certification
 * Member Enrollment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Certification Member Enrollment.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_cert_prd_enrollment_id The unique identifier for the parent certification period enrollment record.
 * @param p_cert_member_id The unique identifier for the certification member record.
 * @param p_member_status_code Status for the Certification Member Enrollment.
 * Valid values are defined by 'OTA_CERT_PRD_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_business_group_id The business group owning the Certification Member
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Certification Member Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cert_mbr_enrollment
  (
  p_effective_date               in date,
  p_cert_mbr_enrollment_id       in number,
  p_object_version_number        in out nocopy number,
  p_cert_prd_enrollment_id       in number,
  p_cert_member_id               in number,
  p_member_status_code           in varchar2,
  p_completion_date              in date             default hr_api.g_date,
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
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cert_mbr_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Certification Member Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Member Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Member Enrollment is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Certification Member Enrollment record, and raises an error.
 *
 * @param p_cert_mbr_enrollment_id The unique identifier for the Certification Member
 * Enrollment record.
 * @param p_object_version_number Current version number of the Certification Member
 * Enrollment to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Certification Member Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_cert_mbr_enrollment
  (p_cert_mbr_enrollment_id        in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_cert_mbr_enrollment_api;

 

/
