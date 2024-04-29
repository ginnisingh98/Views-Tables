--------------------------------------------------------
--  DDL for Package PQH_CORPS_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pqceiapi.pkh 120.1 2005/10/02 02:26:26 aroussel $ */
/*#
 * This package contains APIs to validate, create, update and delete corps
 * extra information records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname CORPS Extra Information for France
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_corps_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the inputs and creates a new corps extra information
 * record.
 *
 * Validates the information entered for each of the seeded information types,
 * also checks for uniqueness of data within an information type for a corps.
 * The record is created in PQH_CORPS_EXTRA_INFO table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Corps must exist as of the effective date.
 *
 * <p><b>Post Success</b><br>
 * A new corps extra information record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A corps extra information record is not created in the database and an error
 * is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_corps_extra_info_id The process returns the unique corps extra
 * information identifier generated for each new record as a primary key
 * @param p_corps_definition_id Corps definition identifier for the extra
 * information. It is primary key of PQH_CORPS_DEFINITIONS
 * @param p_information_type Identifies the type of information being provided.
 * Valid values are DOCUMENT, EXAM, FILERE, ORGANIZATION and TRAINING.
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
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created corps extra information. If p_validate is
 * true, it returns null
 * @rep:displayname Create CORPS Extra Information
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_corps_extra_info
(
  p_validate                      in     boolean   default false
  ,p_effective_date               in     date
  ,p_corps_extra_info_id          out nocopy    number
  ,p_corps_definition_id          in     number
  ,p_information_type             in    varchar2
  ,p_information1                 in    varchar2   default null
  ,p_information2                 in    varchar2   default null
  ,p_information3                 in    varchar2   default null
  ,p_information4                 in    varchar2   default null
  ,p_information5                 in    varchar2   default null
  ,p_information6                 in    varchar2   default null
  ,p_information7                 in    varchar2   default null
  ,p_information8                 in    varchar2   default null
  ,p_information9                 in    varchar2   default null
  ,p_information10                in    varchar2   default null
  ,p_information11                in    varchar2   default null
  ,p_information12                in    varchar2   default null
  ,p_information13                in    varchar2   default null
  ,p_information14                in    varchar2   default null
  ,p_information15                in    varchar2   default null
  ,p_information16                in    varchar2   default null
  ,p_information17                in    varchar2   default null
  ,p_information18                in    varchar2   default null
  ,p_information19                in    varchar2   default null
  ,p_information20                in    varchar2   default null
  ,p_information21                in    varchar2   default null
  ,p_information22                in    varchar2   default null
  ,p_information23                in    varchar2   default null
  ,p_information24                in    varchar2   default null
  ,p_information25                in    varchar2   default null
  ,p_information26                in    varchar2   default null
  ,p_information27                in    varchar2   default null
  ,p_information28                in    varchar2   default null
  ,p_information29                in    varchar2   default null
  ,p_information30                in    varchar2   default null
  ,p_information_category         in    varchar2   default null
  ,p_attribute1                   in    varchar2   default null
  ,p_attribute2                   in    varchar2   default null
  ,p_attribute3                   in    varchar2   default null
  ,p_attribute4                   in    varchar2   default null
  ,p_attribute5                   in    varchar2   default null
  ,p_attribute6                   in    varchar2   default null
  ,p_attribute7                   in    varchar2   default null
  ,p_attribute8                   in    varchar2   default null
  ,p_attribute9                   in    varchar2   default null
  ,p_attribute10                  in    varchar2   default null
  ,p_attribute11                  in    varchar2   default null
  ,p_attribute12                  in    varchar2   default null
  ,p_attribute13                  in    varchar2   default null
  ,p_attribute14                  in    varchar2   default null
  ,p_attribute15                  in    varchar2   default null
  ,p_attribute16                  in    varchar2   default null
  ,p_attribute17                  in    varchar2   default null
  ,p_attribute18                  in    varchar2   default null
  ,p_attribute19                  in    varchar2   default null
  ,p_attribute20                  in    varchar2   default null
  ,p_attribute21                  in    varchar2   default null
  ,p_attribute22                  in    varchar2   default null
  ,p_attribute23                  in    varchar2   default null
  ,p_attribute24                  in    varchar2   default null
  ,p_attribute25                  in    varchar2   default null
  ,p_attribute26                  in    varchar2   default null
  ,p_attribute27                  in    varchar2   default null
  ,p_attribute28                  in    varchar2   default null
  ,p_attribute29                  in    varchar2   default null
  ,p_attribute30                  in    varchar2   default null
  ,p_attribute_category           in    varchar2   default null
  ,p_object_version_number        out nocopy   number
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_corps_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing corps extra information
 * record is changed and updates the record in the database.
 *
 * Validates the information entered for each of the seeded information types,
 * also checks for uniqueness of data within an information type for a corps.
 * The record is created in PQH_CORPS_EXTRA_INFO table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This corps extra information record must exist with the specified object
 * version number.
 *
 * <p><b>Post Success</b><br>
 * The existing corps extra information record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing corps extra information record is not changed in the database
 * and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_corps_extra_info_id Unique corps extra information identifier
 * generated for each new record as a primary key
 * @param p_corps_definition_id Corps definition identifier for the extra
 * information being provided. It is primary key of PQH_CORPS_DEFINITIONS
 * @param p_information_type Identifies the type of information being provided.
 * Valid values are DOCUMENT, EXAM, FILERE, ORGANIZATION and TRAINING.
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
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_object_version_number Passes the current version number of the
 * corps extra information to be updated. When the API completes if p_validate
 * is false, the process returns the new version number of the updated corps
 * extra information If p_validate is true, it returns the same value which was
 * passed in
 * @rep:displayname Update CORPS Extra Information
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_corps_extra_info
  (
  p_validate                      in    boolean    default false
  ,p_effective_date               in    date
  ,p_corps_extra_info_id          in    number
  ,p_corps_definition_id          in    number     default hr_api.g_number
  ,p_information_type             in    varchar2   default hr_api.g_varchar2
  ,p_information1                 in    varchar2   default hr_api.g_varchar2
  ,p_information2                 in    varchar2   default hr_api.g_varchar2
  ,p_information3                 in    varchar2   default hr_api.g_varchar2
  ,p_information4                 in    varchar2   default hr_api.g_varchar2
  ,p_information5                 in    varchar2   default hr_api.g_varchar2
  ,p_information6                 in    varchar2   default hr_api.g_varchar2
  ,p_information7                 in    varchar2   default hr_api.g_varchar2
  ,p_information8                 in    varchar2   default hr_api.g_varchar2
  ,p_information9                 in    varchar2   default hr_api.g_varchar2
  ,p_information10                in    varchar2   default hr_api.g_varchar2
  ,p_information11                in    varchar2   default hr_api.g_varchar2
  ,p_information12                in    varchar2   default hr_api.g_varchar2
  ,p_information13                in    varchar2   default hr_api.g_varchar2
  ,p_information14                in    varchar2   default hr_api.g_varchar2
  ,p_information15                in    varchar2   default hr_api.g_varchar2
  ,p_information16                in    varchar2   default hr_api.g_varchar2
  ,p_information17                in    varchar2   default hr_api.g_varchar2
  ,p_information18                in    varchar2   default hr_api.g_varchar2
  ,p_information19                in    varchar2   default hr_api.g_varchar2
  ,p_information20                in    varchar2   default hr_api.g_varchar2
  ,p_information21                in    varchar2   default hr_api.g_varchar2
  ,p_information22                in    varchar2   default hr_api.g_varchar2
  ,p_information23                in    varchar2   default hr_api.g_varchar2
  ,p_information24                in    varchar2   default hr_api.g_varchar2
  ,p_information25                in    varchar2   default hr_api.g_varchar2
  ,p_information26                in    varchar2   default hr_api.g_varchar2
  ,p_information27                in    varchar2   default hr_api.g_varchar2
  ,p_information28                in    varchar2   default hr_api.g_varchar2
  ,p_information29                in    varchar2   default hr_api.g_varchar2
  ,p_information30                in    varchar2   default hr_api.g_varchar2
  ,p_information_category         in    varchar2   default hr_api.g_varchar2
  ,p_attribute1                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute2                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute3                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute4                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute5                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute6                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute7                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute8                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute9                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute10                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute11                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute12                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute13                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute14                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute15                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute16                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute17                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute18                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute19                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute20                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute21                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute22                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute23                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute24                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute25                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute26                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute27                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute28                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute29                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute30                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute_category           in    varchar2   default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_corps_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes corps extra information records from the database.
 *
 * The record is deleted from PQH_CORPS_EXTRA_INFO table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This corps extra information must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The corps extra information record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The corps extra information record is not deleted from the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_corps_extra_info_id Corps definition identifier for the extra
 * information being provided. It is the primary key of PQH_CORPS_DEFINITIONS
 * table.
 * @param p_object_version_number Current version number of the corps extra
 * information record to be deleted
 * @rep:displayname Delete CORPS Extra Information
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_corps_extra_info
  (
  p_validate                        in boolean        default false
  ,p_corps_extra_info_id            in  number
  ,p_object_version_number          in number
  );
--
end pqh_corps_extra_info_api;

 

/
