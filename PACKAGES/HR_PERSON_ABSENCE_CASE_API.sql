--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_CASE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_CASE_API" AUTHID CURRENT_USER as
/* $Header: peabcapi.pkh 120.3.12010000.2 2008/08/06 08:52:15 ubhat ship $ */
/*#
 * This package contains API procedures to maintain Employee Absence Cases.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Absence Cases
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_absence_case >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Absence Case for an Employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person selected must be an Employee in the system.
 *
 * <p><b>Post Success</b><br>
 * An Absence Case is created for the selected Employee.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person record to which Absence Case is
 * created.
 * @param p_name Absence Case Name.
 * @param p_business_group_id The business group associated with this person.
 * @param p_incident_id Identifies the Work incident that is attached to the Absence Case.
 * @param p_absence_category Identifies the Absence Category.
 * @param p_ac_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_ac_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_ac_information1 Developer Descriptive flexfield segment.
 * @param p_ac_information2 Developer Descriptive flexfield segment.
 * @param p_ac_information3 Developer Descriptive flexfield segment.
 * @param p_ac_information4 Developer Descriptive flexfield segment.
 * @param p_ac_information5 Developer Descriptive flexfield segment.
 * @param p_ac_information6 Developer Descriptive flexfield segment.
 * @param p_ac_information7 Developer Descriptive flexfield segment.
 * @param p_ac_information8 Developer Descriptive flexfield segment.
 * @param p_ac_information9 Developer Descriptive flexfield segment.
 * @param p_ac_information10 Developer Descriptive flexfield segment.
 * @param p_ac_information11 Developer Descriptive flexfield segment.
 * @param p_ac_information12 Developer Descriptive flexfield segment.
 * @param p_ac_information13 Developer Descriptive flexfield segment.
 * @param p_ac_information14 Developer Descriptive flexfield segment.
 * @param p_ac_information15 Developer Descriptive flexfield segment.
 * @param p_ac_information16 Developer Descriptive flexfield segment.
 * @param p_ac_information17 Developer Descriptive flexfield segment.
 * @param p_ac_information18 Developer Descriptive flexfield segment.
 * @param p_ac_information19 Developer Descriptive flexfield segment.
 * @param p_ac_information20 Developer Descriptive flexfield segment.
 * @param p_ac_information21 Developer Descriptive flexfield segment.
 * @param p_ac_information22 Developer Descriptive flexfield segment.
 * @param p_ac_information23 Developer Descriptive flexfield segment.
 * @param p_ac_information24 Developer Descriptive flexfield segment.
 * @param p_ac_information25 Developer Descriptive flexfield segment.
 * @param p_ac_information26 Developer Descriptive flexfield segment.
 * @param p_ac_information27 Developer Descriptive flexfield segment.
 * @param p_ac_information28 Developer Descriptive flexfield segment.
 * @param p_ac_information29 Developer Descriptive flexfield segment.
 * @param p_ac_information30 Developer Descriptive flexfield segment.
 * @param p_comments Comment Text.
 * @param p_absence_case_id If p_validate is false, then this uniquely
 * identifies the absence case record created. If p_validate is true, then
 * this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created absence record. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Person Absence Case
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_absence_case
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number
  ,p_incident_id                   in     number   default null
  ,p_absence_category              in     varchar2 default null
  ,p_ac_attribute_category         in     varchar2 default null
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ac_information_category       in     varchar2 default null
  ,p_ac_information1               in     varchar2 default null
  ,p_ac_information2               in     varchar2 default null
  ,p_ac_information3               in     varchar2 default null
  ,p_ac_information4               in     varchar2 default null
  ,p_ac_information5               in     varchar2 default null
  ,p_ac_information6               in     varchar2 default null
  ,p_ac_information7               in     varchar2 default null
  ,p_ac_information8               in     varchar2 default null
  ,p_ac_information9               in     varchar2 default null
  ,p_ac_information10              in     varchar2 default null
  ,p_ac_information11              in     varchar2 default null
  ,p_ac_information12              in     varchar2 default null
  ,p_ac_information13              in     varchar2 default null
  ,p_ac_information14              in     varchar2 default null
  ,p_ac_information15              in     varchar2 default null
  ,p_ac_information16              in     varchar2 default null
  ,p_ac_information17              in     varchar2 default null
  ,p_ac_information18              in     varchar2 default null
  ,p_ac_information19              in     varchar2 default null
  ,p_ac_information20              in     varchar2 default null
  ,p_ac_information21              in     varchar2 default null
  ,p_ac_information22              in     varchar2 default null
  ,p_ac_information23              in     varchar2 default null
  ,p_ac_information24              in     varchar2 default null
  ,p_ac_information25              in     varchar2 default null
  ,p_ac_information26              in     varchar2 default null
  ,p_ac_information27              in     varchar2 default null
  ,p_ac_information28              in     varchar2 default null
  ,p_ac_information29              in     varchar2 default null
  ,p_ac_information30              in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_absence_case_id               out    nocopy    number
  ,p_object_version_number         out    nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_absence_case >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the absence case as identified by the in
 * parameter p_absence_case_id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence case as identified by the in parameter p_absence_case_id
 * and the in out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * Absence Case details are updated.
 *
 * <p><b>Post Failure</b><br>
 * The absence case record will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_case_id This uniquely identifies the absence case record
 * being updated.
 * @param p_name Absence Case Name.
 * @param p_incident_id Identifies the Work incident that is attached to the
 * Absence Case.
 * @param p_absence_category Identifies the Absence Category.
 * @param p_ac_attribute_category This context value determines which flexfield
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_ac_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_ac_information1 Developer Descriptive flexfield segment.
 * @param p_ac_information2 Developer Descriptive flexfield segment.
 * @param p_ac_information3 Developer Descriptive flexfield segment.
 * @param p_ac_information4 Developer Descriptive flexfield segment.
 * @param p_ac_information5 Developer Descriptive flexfield segment.
 * @param p_ac_information6 Developer Descriptive flexfield segment.
 * @param p_ac_information7 Developer Descriptive flexfield segment.
 * @param p_ac_information8 Developer Descriptive flexfield segment.
 * @param p_ac_information9 Developer Descriptive flexfield segment.
 * @param p_ac_information10 Developer Descriptive flexfield segment.
 * @param p_ac_information11 Developer Descriptive flexfield segment.
 * @param p_ac_information12 Developer Descriptive flexfield segment.
 * @param p_ac_information13 Developer Descriptive flexfield segment.
 * @param p_ac_information14 Developer Descriptive flexfield segment.
 * @param p_ac_information15 Developer Descriptive flexfield segment.
 * @param p_ac_information16 Developer Descriptive flexfield segment.
 * @param p_ac_information17 Developer Descriptive flexfield segment.
 * @param p_ac_information18 Developer Descriptive flexfield segment.
 * @param p_ac_information19 Developer Descriptive flexfield segment.
 * @param p_ac_information20 Developer Descriptive flexfield segment.
 * @param p_ac_information21 Developer Descriptive flexfield segment.
 * @param p_ac_information22 Developer Descriptive flexfield segment.
 * @param p_ac_information23 Developer Descriptive flexfield segment.
 * @param p_ac_information24 Developer Descriptive flexfield segment.
 * @param p_ac_information25 Developer Descriptive flexfield segment.
 * @param p_ac_information26 Developer Descriptive flexfield segment.
 * @param p_ac_information27 Developer Descriptive flexfield segment.
 * @param p_ac_information28 Developer Descriptive flexfield segment.
 * @param p_ac_information29 Developer Descriptive flexfield segment.
 * @param p_ac_information30 Developer Descriptive flexfield segment.
 * @param p_comments Comment Text.
 * @param p_object_version_number Pass in the current version number of the
 * Absence Case to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Absence. If p_validate
 * is true will be set to the same value which was passed in.
 * @rep:displayname Update Person Absence Case
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_absence_case
  (p_validate                      in     boolean  default false
  ,p_absence_case_id               in     number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_incident_id                   in     number   default hr_api.g_number
  ,p_absence_category              in     varchar2 default null
  ,p_ac_attribute_category         in     varchar2 default hr_api.g_varchar2
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_ac_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_ac_information1               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information2               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information3               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information4               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information5               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information6               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information7               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information8               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information9               in     varchar2 default hr_api.g_varchar2
  ,p_ac_information10              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information11              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information12              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information13              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information14              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information15              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information16              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information17              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information18              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information19              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information20              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information21              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information22              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information23              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information24              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information25              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information26              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information27              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information28              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information29              in     varchar2 default hr_api.g_varchar2
  ,p_ac_information30              in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_absence_case >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Deletes an absence case for the specified person, and delinks the
 * associated Absences from the case if any exists.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence case being Deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The absence case for the person will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The absence case will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_case_id This uniquely identifies the absence case record
 * being deleted.
 * @param p_object_version_number Current version number of the Absence to be
 * deleted.
 * @rep:displayname Delete Person Absence Case
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_absence_case
  (p_validate                      in     boolean  default false
  ,p_absence_case_id         in     number
  ,p_object_version_number         in     number
  );

end hr_person_absence_case_api;

/
