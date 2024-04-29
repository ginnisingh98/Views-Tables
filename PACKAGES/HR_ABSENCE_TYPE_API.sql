--------------------------------------------------------
--  DDL for Package HR_ABSENCE_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ABSENCE_TYPE_API" AUTHID CURRENT_USER as
/* $Header: peabbapi.pkh 120.4.12010000.1 2008/07/28 03:59:56 appldev ship $ */
/*#
 * This package contains Absence Attendance Type APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Absence Attendance Type
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_absence_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Absence Attendance Type record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group must exist within which to create the absence type.
 *
 * <p><b>Post Success</b><br>
 * The API creates an absence attendance type in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an absence attendance type and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Identifies the business group in which the
 * absence attendance type is to be created.
 * @param p_input_value_id Identifies the input value of an element entry to
 * associate with the absence attendance type.
 * @param p_date_effective The start date for this absence attendance type.
 * @param p_date_end If p_validate is false, and a value not passed, will be
 * set to end date of input value if less than end of time. If p_validate is
 * true, set to the value passed in.
 * @param p_name The unique name for the absence attendance type.
 * @param p_absence_category The category for the absence attendance type.
 * Valid values are defined by the 'ABSENCE_CATEGORY' lookup type.
 * @param p_comments Absence Attendance Type comment text.
 * @param p_hours_or_days Specifies the unit of measure associated with this
 * absence attendance type, valid values are 'H' for hours and 'D' for days.
 * The value must correspond with the unit of measure of the input value if
 * set. If p_input_value_id is not set, p_hours_or_days must be null.
 * @param p_inc_or_dec_flag Specifies whether this absence attendance type
 * should have an increasing or decreasing total. Valid values are 'I' for
 * increasing, and 'D' for decreasing. Must be null if p_input_value is not
 * set.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_user_role Identifes the User Role of the Absence Type.
 * @param p_assignment_status_type_id Identifies the Assignment Status
 * related to the Absence Type.
 * @param p_advance_pay Identifies whether Advance Pay is associated
 * to the Absence Type or not.
 * @param p_absence_overlap_flag Identifies whether overlap of absence
 * is permitted to the Absence Type or not.
 * @param p_absence_attendance_type_id If p_validate is false, uniquely
 * identifies the absence attendance type created. If p_validate is true, set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created absence attendance type. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Absence Attendance Type
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_absence_type
  (p_validate                      in  boolean     default false
  ,p_language_code                 in  varchar2    default hr_api.userenv_lang
  ,p_business_group_id             in  number      default null
  ,p_input_value_id                in  number      default null
  ,p_date_effective                in  date
  ,p_date_end                      in out nocopy date
  ,p_name                          in  varchar2
  ,p_absence_category              in  varchar2    default null
  ,p_comments                      in  varchar2    default null
  ,p_hours_or_days                 in  varchar2    default null
  ,p_inc_or_dec_flag               in  varchar2    default null
  ,p_attribute_category            in  varchar2    default null
  ,p_attribute1                    in  varchar2    default null
  ,p_attribute2                    in  varchar2    default null
  ,p_attribute3                    in  varchar2    default null
  ,p_attribute4                    in  varchar2    default null
  ,p_attribute5                    in  varchar2    default null
  ,p_attribute6                    in  varchar2    default null
  ,p_attribute7                    in  varchar2    default null
  ,p_attribute8                    in  varchar2    default null
  ,p_attribute9                    in  varchar2    default null
  ,p_attribute10                   in  varchar2    default null
  ,p_attribute11                   in  varchar2    default null
  ,p_attribute12                   in  varchar2    default null
  ,p_attribute13                   in  varchar2    default null
  ,p_attribute14                   in  varchar2    default null
  ,p_attribute15                   in  varchar2    default null
  ,p_attribute16                   in  varchar2    default null
  ,p_attribute17                   in  varchar2    default null
  ,p_attribute18                   in  varchar2    default null
  ,p_attribute19                   in  varchar2    default null
  ,p_attribute20                   in  varchar2    default null
  ,p_information_category          in  varchar2    default null
  ,p_information1                  in  varchar2    default null
  ,p_information2                  in  varchar2    default null
  ,p_information3                  in  varchar2    default null
  ,p_information4                  in  varchar2    default null
  ,p_information5                  in  varchar2    default null
  ,p_information6                  in  varchar2    default null
  ,p_information7                  in  varchar2    default null
  ,p_information8                  in  varchar2    default null
  ,p_information9                  in  varchar2    default null
  ,p_information10                 in  varchar2    default null
  ,p_information11                 in  varchar2    default null
  ,p_information12                 in  varchar2    default null
  ,p_information13                 in  varchar2    default null
  ,p_information14                 in  varchar2    default null
  ,p_information15                 in  varchar2    default null
  ,p_information16                 in  varchar2    default null
  ,p_information17                 in  varchar2    default null
  ,p_information18                 in  varchar2    default null
  ,p_information19                 in  varchar2    default null
  ,p_information20                 in  varchar2    default null
  ,p_user_role                     in  varchar2    default null
  ,p_assignment_status_type_id     in  number      default null
  ,p_advance_pay                   in  varchar2    default null
  ,p_absence_overlap_flag          in  varchar2    default null
  ,p_absence_attendance_type_id       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_absence_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Absence Attendance Type record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates an absence attendance type.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the absence attendance type and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_attendance_type_id Unique identifier of the absence
 * attendance type to update.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_input_value_id Identifies the input value of an element entry to
 * associate with the absence attendance type. If a value has already been set
 * in the database, then it cannot be changed.
 * @param p_date_effective The start date for this absence attendance type.
 * @param p_date_end If p_validate is false, and a value not passed, will be
 * set to end date of input value if less than end of time. If p_validate is
 * true, set to the value passed in automatically if input_value has end date
 * @param p_name The unique name for the absence attendance type.
 * @param p_absence_category The category for the absence attendance type.
 * Valid values are defined by the 'ABSENCE_CATEGORY' lookup type.
 * @param p_comments Absence Attendance type comment text.
 * @param p_hours_or_days Specifies the unit of measure associated with this
 * absence attendance type, valid values are 'H' for hours and 'D' for days.
 * The value must correspond with the unit of measure of the input value if
 * set. If p_input_value_id is not set, p_hours_or_days must be null. If a
 * value has already been set on the database record, then it cannot be
 * changed.
 * @param p_inc_or_dec_flag Specifies whether this absence attendance type
 * should have an increasing or decreasing total. Valid values are 'I' for
 * increasing, and 'D' for decreasing. Must be null if p_input_value is not
 * set. If a value has already been set on the database record, then it cannot
 * be changed
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_user_role Identifes the User Role of the Absence Type.
 * @param p_assignment_status_type_id Identifies the Assignment Status
 * related to the Absence Type.
 * @param p_advance_pay Identifies whether Advance Pay is associated
 * to the Absence Type or not.
 * @param p_absence_overlap_flag Identifies whether overlap of absence
 * is permitted to the Absence Type or not.
 * @param p_object_version_number Pass in the current version number of the
 * Absence Attendance Type to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Absence
 * Attendance Type. If p_validate is true will be set to the same value which
 * was passed in.
 * @rep:displayname Update Absence Attendance Type
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_absence_type
  (p_validate                      in  boolean     default false
  ,p_absence_attendance_type_id    in  number
  ,p_language_code                 in  varchar2    default hr_api.userenv_lang
  ,p_input_value_id                in  number      default hr_api.g_number
  ,p_date_effective                in  date        default hr_api.g_date
  ,p_date_end                      in out nocopy date
  ,p_name                          in  varchar2    default hr_api.g_varchar2
  ,p_absence_category              in  varchar2    default hr_api.g_varchar2
  ,p_comments                      in  varchar2    default hr_api.g_varchar2
  ,p_hours_or_days                 in  varchar2    default hr_api.g_varchar2
  ,p_inc_or_dec_flag               in  varchar2    default hr_api.g_varchar2
  ,p_attribute_category            in  varchar2    default hr_api.g_varchar2
  ,p_attribute1                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute2                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute3                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute4                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute5                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute6                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute7                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute8                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute9                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute10                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute11                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute12                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute13                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute14                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute15                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute16                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute17                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute18                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute19                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute20                   in  varchar2    default hr_api.g_varchar2
  ,p_information_category          in  varchar2    default hr_api.g_varchar2
  ,p_information1                  in  varchar2    default hr_api.g_varchar2
  ,p_information2                  in  varchar2    default hr_api.g_varchar2
  ,p_information3                  in  varchar2    default hr_api.g_varchar2
  ,p_information4                  in  varchar2    default hr_api.g_varchar2
  ,p_information5                  in  varchar2    default hr_api.g_varchar2
  ,p_information6                  in  varchar2    default hr_api.g_varchar2
  ,p_information7                  in  varchar2    default hr_api.g_varchar2
  ,p_information8                  in  varchar2    default hr_api.g_varchar2
  ,p_information9                  in  varchar2    default hr_api.g_varchar2
  ,p_information10                 in  varchar2    default hr_api.g_varchar2
  ,p_information11                 in  varchar2    default hr_api.g_varchar2
  ,p_information12                 in  varchar2    default hr_api.g_varchar2
  ,p_information13                 in  varchar2    default hr_api.g_varchar2
  ,p_information14                 in  varchar2    default hr_api.g_varchar2
  ,p_information15                 in  varchar2    default hr_api.g_varchar2
  ,p_information16                 in  varchar2    default hr_api.g_varchar2
  ,p_information17                 in  varchar2    default hr_api.g_varchar2
  ,p_information18                 in  varchar2    default hr_api.g_varchar2
  ,p_information19                 in  varchar2    default hr_api.g_varchar2
  ,p_information20                 in  varchar2    default hr_api.g_varchar2
  ,p_user_role                     in  varchar2    default hr_api.g_varchar2
  ,p_assignment_status_type_id     in  number      default hr_api.g_number
  ,p_advance_pay                   in  varchar2    default hr_api.g_varchar2
  ,p_absence_overlap_flag          in  varchar2    default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_absence_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Absence Attendance Type record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes an absence attendance type.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the absence attendance type and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_attendance_type_id Unique identifier of the absence
 * attendance type to delete.
 * @param p_object_version_number Current version number of the Absence
 * Attendance Type to be deleted.
 * @rep:displayname Delete Absence Attendance Type
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_absence_type
  (p_validate                      in  boolean     default false
  ,p_absence_attendance_type_id    in  number
  ,p_object_version_number         in  number
  );
--
end hr_absence_type_api;

/
