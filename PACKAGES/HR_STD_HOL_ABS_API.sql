--------------------------------------------------------
--  DDL for Package HR_STD_HOL_ABS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_STD_HOL_ABS_API" AUTHID CURRENT_USER as
/* $Header: peshaapi.pkh 120.1 2005/10/02 02:24:12 aroussel $ */
/*#
 * This package contains Standard Holiday Absence APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Standard Holiday Absence
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_std_hol_abs >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a standard holiday absence for a person.
 *
 * Use this API to record the statutory holidays a person works, and if a
 * person elects to take another day off in lieu of this holiday.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for which the standard holiday absence will be created must exist
 * and be effective.
 *
 * <p><b>Post Success</b><br>
 * The standard holiday absence will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The standard holiday absence will not be created and an error will be
 * raised.
 * @param p_date_not_taken Date of the standard holiday when the person worked.
 * @param p_person_id Identifies the person for whom you create the Standard
 * Holiday Absence record.
 * @param p_standard_holiday_id Uniquely identifies the standard holiday when
 * the person worked.
 * @param p_actual_date_taken Date the person elected to take another day off
 * in lieu of a standard holiday.
 * @param p_reason The reason for the holiday absence.
 * @param p_expired Specifies if the standard holiday absence has expired.
 * Valid values are 'Y' (it has expired) or 'N' (it has not expired).
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Standard Holiday Absence. If p_validate is
 * true, then the value will be null.
 * @param p_std_holiday_absences_id If p_validate is false, then this uniquely
 * identifies the Standard Holiday Absence. If p_validate is true, then this is
 * set to null.
 * @rep:displayname Create Standard Holiday Absence
 * @rep:category BUSINESS_ENTITY HR_CALENDAR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_std_hol_abs
 (p_date_not_taken               in     date,
  p_person_id                    in     number,
  p_standard_holiday_id          in     number,
  p_actual_date_taken            in     date             default null,
  p_reason                       in     varchar2         default null,
  p_expired                      in     varchar2         default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_validate                     in     boolean          default false,
  p_effective_date               in     date,
  p_object_version_number           out nocopy number,
  p_std_holiday_absences_id         out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_std_hol_abs >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a standard holiday absence for a person.
 *
 * Use this API to update the statutory holidays a person works, and if a
 * person elects to take another day off in lieu of this holiday.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Standard Holiday Absence must already exist.
 *
 * <p><b>Post Success</b><br>
 * The standard holiday absence will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The standard holiday absence will not be updated and an error will be
 * raised.
 * @param p_std_holiday_absences_id Uniquely identifies the standard holiday
 * absence that is being updated.
 * @param p_date_not_taken Date of the standard holiday when the person worked.
 * @param p_standard_holiday_id Uniquely identifies the standard holiday when
 * the person worked.
 * @param p_actual_date_taken Date the person elected to take another day off
 * in lieu of a standard holiday.
 * @param p_reason The reason for the holiday absence.
 * @param p_expired Specifies if the standard holiday absence has expired.
 * Valid values are 'Y' (it has expired) or 'N' (it has not expired).
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
 * Standard Holiday Absence to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Standard
 * Holiday Absence. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Standard Holiday Absence
 * @rep:category BUSINESS_ENTITY HR_CALENDAR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_std_hol_abs
 (p_std_holiday_absences_id      in number,
  p_date_not_taken               in date             default hr_api.g_date,
  p_standard_holiday_id          in number           default hr_api.g_number,
  p_actual_date_taken            in date             default hr_api.g_date,
  p_reason                       in varchar2         default hr_api.g_varchar2,
  p_expired                      in varchar2         default hr_api.g_varchar2,
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
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false,
  p_effective_date               in date
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_std_hol_abs >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a standard holiday absence for a person.
 *
 * A standard holiday absence records the statutory holidays a person works and
 * if a person elects to take another day off in lieu of this holiday.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Standard Holiday Absence must already exist.
 *
 * <p><b>Post Success</b><br>
 * The standard holiday absence will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The standard holiday absence will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_std_holiday_absences_id Uniquely identifies the standard holiday
 * absence that is being deleted.
 * @param p_object_version_number Current version number of the Standard
 * Holiday Absence to be deleted.
 * @rep:displayname Delete Standard Holiday Absence
 * @rep:category BUSINESS_ENTITY HR_CALENDAR_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_std_hol_abs
  (p_validate                       in     boolean  default false
  ,p_std_holiday_absences_id        in     number
  ,p_object_version_number          in     number
  );
--
end hr_std_hol_abs_api;

 

/
