--------------------------------------------------------
--  DDL for Package OTA_CERT_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otcreapi.pkh 120.7.12010000.2 2009/03/12 12:17:48 psengupt ship $ */
/*#
 * This package contains Learning Certification Enrollment APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Certification Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cert_enrollment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Certification Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * This Certification and certification components should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Enrollment is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Certification Enrollment record and raises an error.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_certification_id The unique identifier for the certification record.
 * @param p_person_id The unique identifier for the person.
 * @param p_contact_id The unique identifier for the customer contact.
 * @param p_certification_status_code Status for the Certification Enrollment.
 * Valid values are defined by 'OTA_CERT_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_unenrollment_date The date the certification is unsubscribed.
 * @param p_expiration_date After this date the certification is expired.
 * @param p_earliest_enroll_date The date from which learner can renew the certification.
 * @param p_is_history_flag Flag to determine whether learner moved the certification to history.
 * @param p_business_group_id The business group owning the Certification
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
 * @param p_enrollment_date The date the learner subscribed to this certification.
 * @param p_cert_enrollment_id The unique identifier for the Certification Enrollment record.
 * @param p_object_version_number If p_validate is false, then set to the version number of
 * the created Certification Enrollment. If p_validate is true, then the value will be null.
 * @rep:displayname Create Certification Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cert_enrollment
  (
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_certification_id             in number,
  p_person_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_certification_status_code    in varchar2,
  p_completion_date              in date             default null,
  p_UNENROLLMENT_DATE            in date             default null,
  p_EXPIRATION_DATE              in date             default null,
  p_EARLIEST_ENROLL_DATE         in date             default null,
  p_IS_HISTORY_FLAG              in varchar2         default 'N',
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
  p_enrollment_date	         in date             default null,
  p_cert_enrollment_id           out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cert_enrollment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Certification Enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Certification Enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification Enrollment is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Certification Enrollment record, and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cert_enrollment_id The unique identifier for the Certification Enrollment record.
 * @param p_object_version_number Pass in the current version number of the Certification
 * Enrollment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Certification Enrollment.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_certification_id The unique identifier for the certification record.
 * @param p_person_id The unique identifier for the person.
 * @param p_contact_id The unique identifier for the customer contact.
 * @param p_certification_status_code Status for the Certification Enrollment.
 * Valid values are defined by 'OTA_CERT_ENROLL_STATUS'  lookup type.
 * @param p_completion_date The date the certification is completed.
 * @param p_unenrollment_date The date the certification is unsubscribed.
 * @param p_expiration_date After this date the certification is expired.
 * @param p_earliest_enroll_date The date from which learner can renew the certification.
 * @param p_is_history_flag Flag to determine whether learner moved the certification to history.
 * @param p_business_group_id The business group owning the Certification Enrollment record of the certification.
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
 * @param p_enrollment_date The date the learner subscribed to this certification.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Certification Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cert_enrollment
  (
  p_effective_date               in date,
  p_cert_enrollment_id           in number,
  p_object_version_number        in out nocopy number,
  p_certification_id             in number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_certification_status_code    in varchar2         default hr_api.g_varchar2,
  p_completion_date              in date             default hr_api.g_date,
  p_UNENROLLMENT_DATE            in date             default hr_api.g_date,
  p_EXPIRATION_DATE              in date             default hr_api.g_date,
  p_EARLIEST_ENROLL_DATE         in date             default hr_api.g_date,
  p_IS_HISTORY_FLAG              in varchar2         default hr_api.g_varchar2,
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
  p_enrollment_date	         in date             default hr_api.g_date,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cert_enrollment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the certification enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The certification enrollment is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the certification enrollment record, and raises an error.
 *
 * @param p_cert_enrollment_id The unique identifier for the certification enrollment record.
 * @param p_object_version_number Current version number of the certification enrollment to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete certification enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cert_enrollment
  (p_cert_enrollment_id            in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< subscribe_to_certification >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API subscribes learner to Certification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Certification subscription is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Certification subscription record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_certification_id The unique identifier for the certification record.
 * @param p_person_id The unique identifier for the person.
 * @param p_contact_id The unique identifier for the customer contact.
 * @param p_business_group_id The business group owning the Certification Enrollment
 * record of the certification.
 * @param p_approval_flag The approval flag containing values; 'N' = non-approval,
 * 'A' = requested approval, 'S' = approved.
 * @param p_completion_date The date the certification is completed.
 * @param p_unenrollment_date The date the certification is unsubscribed.
 * @param p_expiration_date After this date the certification is expired.
 * @param p_earliest_enroll_date The date from which learner can renew the certification.
 * @param p_is_history_flag Flag to determine whether learner moved the certification to history.
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
 * @param p_enrollment_date The date the learner subscribed to this certification.
 * @param p_cert_enrollment_id The unique identifier for the Certification Enrollment record.
 * @param p_certification_status_code Status for the Certification Enrollment.
 * Valid values are defined by 'OTA_CERT_ENROLL_STATUS'  lookup type.
 * @param p_enroll_from Flag to determine subscription outside the learner interface.
 * @rep:displayname Subscribe Certification Enrollment
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure subscribe_to_certification
  (p_validate in boolean default false
  ,p_certification_id IN NUMBER
  ,p_person_id IN NUMBER default null
  ,p_contact_id IN NUMBER default null
  ,p_business_group_id IN NUMBER
  ,p_approval_flag IN VARCHAR2
  ,p_completion_date              in     date      default null
  ,p_unenrollment_date            in     date      default null
  ,p_expiration_date              in     date      default null
  ,p_earliest_enroll_date         in     date      default null
  ,p_is_history_flag              in     varchar2
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_enrollment_date	          in     date      default null
  ,p_cert_enrollment_id OUT NOCOPY NUMBER
  ,p_certification_status_code OUT NOCOPY VARCHAR2
   ,p_enroll_from         in varchar2 default null
  );

end ota_cert_enrollment_api;

/
