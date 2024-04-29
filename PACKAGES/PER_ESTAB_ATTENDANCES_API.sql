--------------------------------------------------------
--  DDL for Package PER_ESTAB_ATTENDANCES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESTAB_ATTENDANCES_API" AUTHID CURRENT_USER as
/* $Header: peesaapi.pkh 120.1 2005/10/02 02:16:54 aroussel $ */
/*#
 * This package contains HR Establishment Attendance APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Establishment Attendance
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_attended_estab >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an establishment attendance record for a person.
 *
 * Use this API to record the details of a person's attendance at schools,
 * colleges and other establishments, including the attendance dates and if
 * they were full-time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person must already exist. The establishment they attended must have
 * already been created.
 *
 * <p><b>Post Success</b><br>
 * The establishment attendance will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The establishment attendance will not be created and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_fulltime Specifies if the person attended the establishment full
 * time. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_attended_start_date Date attendance started.
 * @param p_attended_end_date Date attendance ended.
 * @param p_establishment Name of the establishment. Specify a value when the
 * establishment does not already exist in the database. If the establishment
 * already exists, use p_establishment_id.
 * @param p_business_group_id The business group under which the establishment
 * attendance will be recorded. This is usually the same business group that
 * the person belongs to.
 * @param p_person_id Identifies the person for whom you create the
 * Establishment Attendance record.
 * @param p_party_id Party to whom the establishment attendance applies.
 * @param p_address The address of the establishment.
 * @param p_establishment_id Uniquely identifies an establishment that already
 * exists in the database. If an establishment does not already exist, you can
 * specify p_establishment (a free-format text field that is not validated).
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
 * @param p_attendance_id If p_validate is false, then this uniquely identifies
 * the establishment attendance. If p_validate is true, then this is set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created establishment attendance record. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Establishment Attendance
 * @rep:category BUSINESS_ENTITY PER_ESTAB_ATTENDANCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date     default null
  ,p_attended_end_date             in     date     default null
  ,p_establishment                 in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_person_id                     in     number   default null
  ,p_party_id                      in     number   default null
  ,p_address			   in     varchar2 default null
  ,p_establishment_id              in     number   default null
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
  ,p_attendance_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_attended_estab >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an establishment attendance record for a person.
 *
 * Use this API to update the details of a person's attendance at schools,
 * colleges and other establishments, including the attendance dates and if
 * they were full-time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The establishment attendance record for this person must have already been
 * created.
 *
 * <p><b>Post Success</b><br>
 * The establishment attendance will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The establishment attendance will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_attendance_id Uniquely identifies the establishment attendance that
 * is being updated.
 * @param p_fulltime Specifies if the person attended the establishment full
 * time. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_attended_start_date Date attendance started.
 * @param p_attended_end_date Date attendance ended.
 * @param p_establishment Name of the establishment. Specify a value when the
 * establishment does not already exist in the database. If the establishment
 * already exists, use p_establishment_id.
 * @param p_establishment_id Uniquely identifies an establishment that already
 * exists in the database. If an establishment does not already exist, you can
 * specify p_establishment (a free-format text field that is not validated).
 * @param p_address The address of the establishment.
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
 * @param p_object_version_number Pass in the current version number of the
 * Establishment Attendance to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Establishment
 * Attendance. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Establishment Attendance
 * @rep:category BUSINESS_ENTITY PER_ESTAB_ATTENDANCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_attendance_id                 in     number
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date     default hr_api.g_date
  ,p_attended_end_date             in     date     default hr_api.g_date
  ,p_establishment                 in     varchar2 default hr_api.g_varchar2
  ,p_establishment_id              in     number   default hr_api.g_number
  ,p_address			   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_attended_estab >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes one instance of a person's establishment attendance.
 *
 * Use this API to delete the record of a person's attendance at a particular
 * establishment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The establishment attendance record for this person must have already been
 * created.
 *
 * <p><b>Post Success</b><br>
 * The establishment attendance will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The establishment attendance will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attendance_id Uniquely identifies the establishment attendance to
 * be deleted.
 * @param p_object_version_number Current version number of the Establishment
 * Attendance to be deleted.
 * @rep:displayname Delete Establishment Attendance
 * @rep:category BUSINESS_ENTITY PER_ESTAB_ATTENDANCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_attendance_id                 in     number
  ,p_object_version_number         in     number
  );
--

end PER_ESTAB_ATTENDANCES_API;

 

/
