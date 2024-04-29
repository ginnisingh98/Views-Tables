--------------------------------------------------------
--  DDL for Package HR_DEPLOYMENT_FACTOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEPLOYMENT_FACTOR_API" AUTHID CURRENT_USER as
/* $Header: pedpfapi.pkh 120.1 2005/10/02 02:15:01 aroussel $ */
/*#
 * This package contains person deployment factor APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Deployment Factor
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_dpmt_factor >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create a deployment factor for a person.
 *
 * Use this API to record work choices and work preferences for a person. You
 * can record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom deployment factors are being created must already exist
 * within the business group.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the person will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Uniquely identifies the person for whom you create the
 * deployment factor record.
 * @param p_work_any_country Specifies if the person is available to work in
 * any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the person is available to work in
 * any location. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_domestically Specifies if the person is available to
 * relocate domestically. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the person is available to
 * relocate internationally. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_travel_required Specifies if the person is available to travel.
 * Valid values are defined by the YES_NO' lookup type.
 * @param p_country1 Country one where the person is available to work.
 * @param p_country2 Country two where the person is available to work.
 * @param p_country3 Country three where the person is available to work.
 * @param p_work_duration Preferred work duration. Valid values are defined by
 * the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule Preferred work schedule. Valid values are defined by
 * the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours Preferred work hours. Valid values are defined by the
 * 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_visit_internationally Specifies willingness to travel
 * internationally. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_only_current_location Specifies if only the current location is
 * acceptable. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_no_country1 Country one that is not acceptable.
 * @param p_no_country2 Country two that is not acceptable.
 * @param p_no_country3 Country three that is not acceptable.
 * @param p_comments Comment text.
 * @param p_earliest_available_date The earliest available date for transfer.
 * @param p_available_for_transfer Specifies if the person is available for
 * transfer. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocation_preference The person's relocation preference. Valid
 * values are defined by the 'PER_RELOCATION_PREFERENCES' lookup type.
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
 * @param p_deployment_factor_id If p_validate is false, then this uniquely
 * identifies the person deployment factor created. If p_validate is true, then
 * this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created deployment factor. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Person Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_visit_internationally        in     varchar2 default null
  ,p_only_current_location        in     varchar2 default null
  ,p_no_country1                  in     varchar2 default null
  ,p_no_country2                  in     varchar2 default null
  ,p_no_country3                  in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_earliest_available_date      in     date     default null
  ,p_available_for_transfer       in     varchar2 default null
  ,p_relocation_preference        in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_dpmt_factor >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update a deployment factor for a person.
 *
 * Use this API to update the work choices and work preferences for a person.
 * You can also record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment factor must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the person will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_deployment_factor_id Uniquely identifies the person deployment
 * factor the process updates.
 * @param p_object_version_number Pass in the current version number of the
 * deployment factor to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated deployment
 * factor. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_work_any_country Specifies if the person is available to work in
 * any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the person is available to work in
 * any location. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_domestically Specifies if the person is available to
 * relocate domestically. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the person is available to
 * relocate internationally. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_travel_required Specifies if the person is available to travel.
 * Valid values are defined by the YES_NO' lookup type.
 * @param p_country1 Country one where the person is available to work.
 * @param p_country2 Country two where the person is available to work.
 * @param p_country3 Country three where the person is available to work.
 * @param p_work_duration Preferred work duration. Valid values are defined by
 * the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule Preferred work schedule. Valid values are defined by
 * the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours Preferred work hours. Valid values are defined by the
 * 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_visit_internationally Yes/No field to describe willingness to
 * travel internationally. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_only_current_location Specifies if only the current location is
 * acceptable. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_no_country1 Country one that is not acceptable.
 * @param p_no_country2 Country two that is not acceptable.
 * @param p_no_country3 Country three that is not acceptable.
 * @param p_comments Comment text.
 * @param p_earliest_available_date The earliest available date for transfer.
 * @param p_available_for_transfer Specifies if the person is available for
 * transfer. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocation_preference The person's relocation preference. Valid
 * values are defined by the 'PER_RELOCATION_PREFERENCES' lookup type.
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
 * @rep:displayname Update Person Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_visit_internationally        in     varchar2 default hr_api.g_varchar2
  ,p_only_current_location        in     varchar2 default hr_api.g_varchar2
  ,p_no_country1                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country2                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country3                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_earliest_available_date      in     date     default hr_api.g_date
  ,p_available_for_transfer       in     varchar2 default hr_api.g_varchar2
  ,p_relocation_preference        in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_position_dpmt_factor >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create a deployment factor for a position.
 *
 * Use this API to record the work choices and work preferences for a position.
 * You can also record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The position for which deployment factors are being created must already
 * exist within the business group.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the position will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_position_id Identifies the position for which you create the
 * deployment factor record.
 * @param p_work_any_country Specifies if the position requires availability to
 * work in any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the position requires availability
 * to work in any location. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_relocate_domestically Specifies if the position requires
 * willingness to relocate domestically. Valid values are defined by the
 * 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the position requires
 * willingness to relocate internationally. Valid values are defined by the
 * 'YES_NO' lookup type.
 * @param p_travel_required Specifies if the position requires travel. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_country1 Country one where the position requires work.
 * @param p_country2 Country two where the position requires work.
 * @param p_country3 Country three where the position requires work.
 * @param p_work_duration The work duration the position requires. Valid values
 * are defined by the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule The work schedule the position requires. Valid values
 * are defined by the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours The work hours the position requires. Valid values are
 * defined by the 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_relocation_required Specifies if the position requires relocation.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_passport_required Specifies if the position requires a passport.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_location1 Location one where the position requires work.
 * @param p_location2 Location two where the position requires work.
 * @param p_location3 Location three where the position requires work.
 * @param p_other_requirements Other miscellaneous requirements.
 * @param p_service_minimum Minimum length of service. Valid values are defined
 * by the 'PER_LENGTHS_OF_SERVICE' lookup type.
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
 * @param p_deployment_factor_id If p_validate is false, then this uniquely
 * identifies the position deployment factor created. If p_validate is true,
 * then this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created deployment factor. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Position Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_position_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_position_id                  in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_relocation_required          in     varchar2 default null
  ,p_passport_required            in     varchar2 default null
  ,p_location1                    in     varchar2 default null
  ,p_location2                    in     varchar2 default null
  ,p_location3                    in     varchar2 default null
  ,p_other_requirements           in     varchar2 default null
  ,p_service_minimum              in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_position_dpmt_factor >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update a deployment factor for a position.
 *
 * Use this API to update the work choices and work preferences for a position.
 * You can also record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment factor must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the position will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_deployment_factor_id Uniquely identifies the position deployment
 * factor that will be updated.
 * @param p_object_version_number Pass in the current version number of the
 * deployment factor to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated deployment
 * factor. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_work_any_country Specifies if the position requires availability to
 * work in any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the position requires availability
 * to work in any location. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_relocate_domestically Specifies if the position requires
 * willingness to relocate domestically. Valid values are defined by the
 * 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the position requires
 * willingness to relocate internationally. Valid values are defined by the
 * 'YES_NO' lookup type.
 * @param p_travel_required Specifies if the position requires travel. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_country1 Country one where the position requires work.
 * @param p_country2 Country two where the position requires work.
 * @param p_country3 Country three where the position requires work.
 * @param p_work_duration The work duration the position requires. Valid values
 * are defined by the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule The work schedule the position requires. Valid values
 * are defined by the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours The work hours the position requires. Valid values are
 * defined by the 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_relocation_required Specifies if the position requires relocation.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_passport_required Specifies if the position requires a passport.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_location1 Location one where the position requires work.
 * @param p_location2 Location two where the position requires work.
 * @param p_location3 Location three where the position requires work.
 * @param p_other_requirements Other miscellaneous requirements.
 * @param p_service_minimum Minimum length of service. Valid values are defined
 * by the 'PER_LENGTHS_OF_SERVICE' lookup type.
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
 * @rep:displayname Update Position Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_position_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_relocation_required          in     varchar2 default hr_api.g_varchar2
  ,p_passport_required            in     varchar2 default hr_api.g_varchar2
  ,p_location1                    in     varchar2 default hr_api.g_varchar2
  ,p_location2                    in     varchar2 default hr_api.g_varchar2
  ,p_location3                    in     varchar2 default hr_api.g_varchar2
  ,p_other_requirements           in     varchar2 default hr_api.g_varchar2
  ,p_service_minimum              in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_job_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create a deployment factor for a job.
 *
 * Use this API to record the work choices and work preferences for a job. You
 * can also record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job for which deployment factors are being created must already exist
 * within the business group.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the job will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_job_id Uniquely identifies the job for which you create the
 * deployment factor record.
 * @param p_work_any_country Specifies if the job requires availability to work
 * in any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the job requires availability to
 * work in any location. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_domestically Specifies if the job requires willingness to
 * relocate domestically. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the job requires willingness
 * to relocate internationally. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_travel_required Specifies if the job requires travel. Valid values
 * are defined by the 'YES_NO' lookup type.
 * @param p_country1 Country one where the job requires work.
 * @param p_country2 Country two where the job requires work.
 * @param p_country3 Country three where the job requires work.
 * @param p_work_duration The work duration the job requires. Valid values are
 * defined by the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule The work schedule the job requires. Valid values are
 * defined by the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours The work hours the job requires. Valid values are
 * defined by the 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_relocation_required Specifies if the job requires relocation. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_passport_required Specifies if the job requires a passport. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_location1 Location one where the job requires work.
 * @param p_location2 Location two where the job requires work.
 * @param p_location3 Location three where the job requires work.
 * @param p_other_requirements Other miscellaneous requirements.
 * @param p_service_minimum Minimum length of service. Valid values are defined
 * by the 'PER_LENGTHS_OF_SERVICE' lookup type.
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
 * @param p_deployment_factor_id If p_validate is false, then this uniquely
 * identifies the job deployment factor created. If p_validate is true, then
 * this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created deployment factor. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Job Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_job_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_job_id                       in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_relocation_required          in     varchar2 default null
  ,p_passport_required            in     varchar2 default null
  ,p_location1                    in     varchar2 default null
  ,p_location2                    in     varchar2 default null
  ,p_location3                    in     varchar2 default null
  ,p_other_requirements           in     varchar2 default null
  ,p_service_minimum              in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_job_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update a deployment factor for a job.
 *
 * Use this API to update the work choices and work preferences for a job. You
 * can also record details such as relocation preferences and International
 * Deployment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment factor must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The deployment factor for the job will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The deployment factor will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_deployment_factor_id Uniquely identifies the job deployment factor
 * that will be updated.
 * @param p_object_version_number Pass in the current version number of the
 * deployment factor to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated deployment
 * factor. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_work_any_country Specifies if the job requires availability to work
 * in any country. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_work_any_location Specifies if the job requires availability to
 * work in any location. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_domestically Specifies if the job requires willingness to
 * relocate domestically. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_relocate_internationally Specifies if the job requires willingness
 * to relocate internationally. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_travel_required Specifies if the job requires travel. Valid values
 * are defined by the 'YES_NO' lookup type.
 * @param p_country1 Country one where the job requires work.
 * @param p_country2 Country two where the job requires work.
 * @param p_country3 Country three where the job requires work.
 * @param p_work_duration The work duration the job requires. Valid values are
 * defined by the 'PER_TIME_SCALES' lookup type.
 * @param p_work_schedule The work schedule the job requires. Valid values are
 * defined by the 'PER_WORK_SCHEDULE' lookup type.
 * @param p_work_hours The work hours the job requires. Valid values are
 * defined by the 'PER_WORK_HOURS' lookup type.
 * @param p_fte_capacity The Full Time Equivalent (FTE) capacity. Valid values
 * are defined by the 'PER_FTE_CAPACITY' lookup type.
 * @param p_relocation_required Specifies if the job requires relocation. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_passport_required Specifies if the job requires a passport. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_location1 Location one where the job requires work.
 * @param p_location2 Location two where the job requires work.
 * @param p_location3 Location three where the job requires work.
 * @param p_other_requirements Other miscellaneous requirements.
 * @param p_service_minimum Minimum length of service. Valid values are defined
 * by the 'PER_LENGTHS_OF_SERVICE' lookup type.
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
 * @rep:displayname Update Job Deployment Factor
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_job_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_relocation_required          in     varchar2 default hr_api.g_varchar2
  ,p_passport_required            in     varchar2 default hr_api.g_varchar2
  ,p_location1                    in     varchar2 default hr_api.g_varchar2
  ,p_location2                    in     varchar2 default hr_api.g_varchar2
  ,p_location3                    in     varchar2 default hr_api.g_varchar2
  ,p_other_requirements           in     varchar2 default hr_api.g_varchar2
  ,p_service_minimum              in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  );
--
end hr_deployment_factor_api;

 

/
