--------------------------------------------------------
--  DDL for Package PQH_SITUATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SITUATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqlosapi.pkh 120.1 2005/10/02 02:26:58 aroussel $ */
/*#
 * This package contains APIs to validate, create, update and delete seniority
 * situations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Situation for France
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_situation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the inputs and creates a new seniority situation.
 *
 * Seniority situation defines the seniority entitlements for a selected
 * section of employees. Based on the entitlements defined as seniority
 * situations for a type of length of service, the effective length of service
 * is computed.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * It can be created only for an existing business group on the effective date.
 *
 * <p><b>Post Success</b><br>
 * A situation is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A situation is not created in the database and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_situation Situation corresponding to situation type. If the
 * situation type is ABSENCE, then valid values are in 'ABSENCE_CATEGORY'
 * lookup type. If the situation is ASSIGNMENT, then valid values are in
 * 'PER_ASS_SYS_STATUS'. If the situation is MILITARY, then valid values are in
 * legislation specific lookup types like FR_MILITARY_SERVICE_STATUS. If the
 * situation is EMPLOYMENT, then valid values are in 'PREV_EMP_TYPE' lookup
 * type
 * @param p_effective_start_date Effective start date of the situation
 * @param p_business_group_id It is the business group identifier for which
 * this Situation is being created. It is a mandatory parameter
 * @param p_situation_type It is the type of the situation. Valid values are
 * identified by lookup type 'FR_PQH_SITUATION_TYPE'.
 * @param p_length_of_service Identifies the type of seniority for which the
 * situation is applicable. Valid values are identified by lookup type
 * 'FR_PQH_LENGTH_OF_SERVICE_TYPE'
 * @param p_effective_end_date Effective end date of the situation. It is
 * generally set to null
 * @param p_employee_type Agent type for which the situation is applicable.
 * Valid values are identified by lookup type 'FR_PQH_EMP_TYPE'.
 * @param p_entitlement_flag Flag which decides the entitlement for the
 * situation
 * @param p_worktime_proportional Indicates whether the entitlement is
 * proportional to work time or not. Value can be not null only if
 * entitlement_flag is set to Y.
 * @param p_entitlement_value The entitlement value. Value can be not null only
 * if entitlement_flag is set to Y.
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
 * @param p_situation_id The process returns the unique situation identifier
 * generated for the new record as primary key
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created situation. If p_validate is true, it
 * returns null.
 * @rep:displayname Create Situation
 * @rep:category BUSINESS_ENTITY PQH_EMEA_SENIORITY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_situation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_situation                      in     varchar2
  ,p_effective_start_date           in     date
  ,p_business_group_id              in     number
  ,p_situation_type                 in     varchar2
  ,p_length_of_service              in     varchar2
  ,p_effective_end_date             in     date     default null
  ,p_employee_type                  in     varchar2 default null
  ,p_entitlement_flag               in     varchar2 default null
  ,p_worktime_proportional          in     varchar2 default null
  ,p_entitlement_value              in     number   default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_situation_id                   out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_situation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the changes made to the existing seniority situation and
 * updates it in the database.
 *
 * It validates the combination of situation, situation type, length of service
 * and employee type for uniqueness. The record is updated in PQH_SITUATIONS
 * table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Record should exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The existing situation record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing situation is not changed in the database and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_situation_id Unique situation identifier generated for the new
 * record as primary key
 * @param p_object_version_number Passes the current version number of the
 * seniority situation to be updated. When the API completes if p_validate is
 * false, the process returns the new version number of the updated seniority
 * situation. If p_validate, it returns the same value which was passed in.
 * @param p_situation Situation corresponding to situation type. If the
 * situation type is ABSENCE, then valid values are in 'ABSENCE_CATEGORY'
 * lookup type. If the situation is ASSIGNMENT, then valid values are in
 * 'PER_ASS_SYS_STATUS'. If the situation is MILITARY, then valid values are in
 * legislation specific lookup types like FR_MILITARY_SERVICE_STATUS. If the
 * situation is EMPLOYMENT, then valid values are in 'PREV_EMP_TYPE' lookup
 * type
 * @param p_effective_start_date Effective start date of the situation
 * @param p_business_group_id Business group identifier for which this
 * situation is being created. It is a mandatory parameter
 * @param p_situation_type It is the type of the Situation. Valid values are
 * identified by lookup type 'FR_PQH_SITUATION_TYPE'.
 * @param p_length_of_service Identifies the type of seniority for which the
 * situation is applicable. Valid values are identified by lookup type
 * 'FR_PQH_LENGTH_OF_SERVICE_TYPE'
 * @param p_effective_end_date Effective end date of the situation. It is
 * generally set to null
 * @param p_employee_type Agent type for which the situation is applicable.
 * Valid values are identified by lookup type 'FR_PQH_EMP_TYPE'.
 * @param p_entitlement_flag Flag which decides the entitlement for the
 * situation
 * @param p_worktime_proportional Indicates whether the entitlement is
 * proportional to work time or not. Value can be not null only if
 * entitlement_flag is set to Y.
 * @param p_entitlement_value The entitlement value. Value can be not null only
 * if entitlement_flag is set to Y.
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
 * @rep:displayname Update Situation
 * @rep:category BUSINESS_ENTITY PQH_EMEA_SENIORITY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_situation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_situation_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_situation                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_length_of_service            in     varchar2  default hr_api.g_varchar2
  ,p_effective_end_date           in     date      default hr_api.g_date
  ,p_employee_type                in     varchar2  default hr_api.g_varchar2
  ,p_entitlement_flag             in     varchar2  default hr_api.g_varchar2
  ,p_worktime_proportional        in     varchar2  default hr_api.g_varchar2
  ,p_entitlement_value            in     number    default hr_api.g_number
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_situation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a seniority situation record from the database.
 *
 * The record is deleted from PQH_SITUATIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This record should exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The seniority situation record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The seniority situation record is not deleted from the database and an error
 * is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_situation_id Unique situation identifier generated for the new
 * record as primary key
 * @param p_object_version_number Current version number of the situation to be
 * deleted
 * @rep:displayname Delete Situation
 * @rep:category BUSINESS_ENTITY PQH_EMEA_SENIORITY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_situation
  (p_validate                      in     boolean  default false
  ,p_situation_id                  in     number
  ,p_object_version_number         in     number
  );

--
end pqh_situations_api;

 

/
