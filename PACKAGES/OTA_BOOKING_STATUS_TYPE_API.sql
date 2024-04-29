--------------------------------------------------------
--  DDL for Package OTA_BOOKING_STATUS_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BOOKING_STATUS_TYPE_API" AUTHID CURRENT_USER as
/* $Header: otbstapi.pkh 120.2 2006/08/30 06:58:23 niarora noship $ */
/*#
 * This package contains Enrollment status APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Enrollment Status
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_booking_status_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Enrollment status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Business Group record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Enrollment status section was created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API did not create an Enrollment status record and raised an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start-to-end active date range. This date does
 * not determine when the changes take effect.
 * @param p_business_group_id The business group owning the Enrollment status.
 * @param p_active_flag The flag indicating whether the booking status type
 * is active or not; permissible values Y and N.
 * @param p_default_flag The default flag for the Enrollment status.
 * Permissible values Y and N.
 * @param p_name The name of the Enrollment status.
 * @param p_type Enrollment type. Valid values are defined by the
 * 'DELEGATE_BOOKING_STATUS' lookup type.
 * @param p_place_used_flag An indication of whether the status implies that
 * a place on an event has been allocated.
 * @param p_comments Comment text.
 * @param p_description The description of the Enrollment status.
 * @param p_bst_information_category This context value determines which flexfield structure to
 * use with the descriptive flexfield segments.
 * @param p_bst_information1 Descriptive flexfield segment.
 * @param p_bst_information2 Descriptive flexfield segment.
 * @param p_bst_information3 Descriptive flexfield segment.
 * @param p_bst_information4 Descriptive flexfield segment.
 * @param p_bst_information5 Descriptive flexfield segment.
 * @param p_bst_information6 Descriptive flexfield segment.
 * @param p_bst_information7 Descriptive flexfield segment.
 * @param p_bst_information8 Descriptive flexfield segment.
 * @param p_bst_information9 Descriptive flexfield segment.
 * @param p_bst_information10 Descriptive flexfield segment.
 * @param p_bst_information11 Descriptive flexfield segment.
 * @param p_bst_information12 Descriptive flexfield segment.
 * @param p_bst_information13 Descriptive flexfield segment.
 * @param p_bst_information14 Descriptive flexfield segment.
 * @param p_bst_information15 Descriptive flexfield segment.
 * @param p_bst_information16 Descriptive flexfield segment.
 * @param p_bst_information17 Descriptive flexfield segment.
 * @param p_bst_information18 Descriptive flexfield segment.
 * @param p_bst_information19 Descriptive flexfield segment.
 * @param p_bst_information20 Descriptive flexfield segment.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Enrollment status. If p_validate is true,
 * then the value will be null.
 * @param p_booking_status_type_id The unique identifier for this Enrollment status.
 * @rep:displayname Create Enrollment Status
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_STATUS_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_BOOKING_STATUS_TYPE
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2 default null
  ,p_default_flag                   in     varchar2 default null
  ,p_name                           in     varchar2 default null
  ,p_type                           in     varchar2 default null
  ,p_place_used_flag                in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_bst_information_category       in     varchar2 default null
  ,p_bst_information1               in     varchar2 default null
  ,p_bst_information2               in     varchar2 default null
  ,p_bst_information3               in     varchar2 default null
  ,p_bst_information4               in     varchar2 default null
  ,p_bst_information5               in     varchar2 default null
  ,p_bst_information6               in     varchar2 default null
  ,p_bst_information7               in     varchar2 default null
  ,p_bst_information8               in     varchar2 default null
  ,p_bst_information9               in     varchar2 default null
  ,p_bst_information10              in     varchar2 default null
  ,p_bst_information11              in     varchar2 default null
  ,p_bst_information12              in     varchar2 default null
  ,p_bst_information13              in     varchar2 default null
  ,p_bst_information14              in     varchar2 default null
  ,p_bst_information15              in     varchar2 default null
  ,p_bst_information16              in     varchar2 default null
  ,p_bst_information17              in     varchar2 default null
  ,p_bst_information18              in     varchar2 default null
  ,p_bst_information19              in     varchar2 default null
  ,p_bst_information20              in     varchar2 default null
  ,p_object_version_number          out    nocopy number
  ,p_booking_status_type_id         out nocopy	   number
--  ,p_data_source                    in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_booking_status_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Enrollment status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Enrollment status record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Enrollment status section was updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API did not update the Enrollment status record and raised an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are applicable
 * during the start-to-end active date range. This date does not determine when
 * the changes take effect.
 * @param p_business_group_id The business group owning the Enrollment status.
 * @param p_active_flag The flag indicating whether the booking status type is active or not.
 * Permissible values Y and N.
 * @param p_default_flag The default flag for the Enrollment status. Permissible values Y and N.
 * @param p_name The name of the Enrollment status.
 * @param p_type Enrollment type. Valid values are defined by the 'DELEGATE_BOOKING_STATUS' lookup type.
 * @param p_place_used_flag Indicates whether the status implies that a place on an event has been allocated.
 * @param p_comments Comment text.
 * @param p_description The description of the Enrollment status.
 * @param p_bst_information_category This context value determines which flexfield structure
 * to use with the descriptive flexfield segments.
 * @param p_bst_information1 Descriptive flexfield segment.
 * @param p_bst_information2 Descriptive flexfield segment.
 * @param p_bst_information3 Descriptive flexfield segment.
 * @param p_bst_information4 Descriptive flexfield segment.
 * @param p_bst_information5 Descriptive flexfield segment.
 * @param p_bst_information6 Descriptive flexfield segment.
 * @param p_bst_information7 Descriptive flexfield segment.
 * @param p_bst_information8 Descriptive flexfield segment.
 * @param p_bst_information9 Descriptive flexfield segment.
 * @param p_bst_information10 Descriptive flexfield segment.
 * @param p_bst_information11 Descriptive flexfield segment.
 * @param p_bst_information12 Descriptive flexfield segment.
 * @param p_bst_information13 Descriptive flexfield segment.
 * @param p_bst_information14 Descriptive flexfield segment.
 * @param p_bst_information15 Descriptive flexfield segment.
 * @param p_bst_information16 Descriptive flexfield segment.
 * @param p_bst_information17 Descriptive flexfield segment.
 * @param p_bst_information18 Descriptive flexfield segment.
 * @param p_bst_information19 Descriptive flexfield segment.
 * @param p_bst_information20 Descriptive flexfield segment.
 * @param p_booking_status_type_id The unique identifier for this Enrollment status.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created
 * Enrollment status. If p_validate is true, then the value will be null.
 * @rep:displayname Update Enrollment Status
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_STATUS_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_BOOKING_STATUS_TYPE
  (p_validate                     in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_default_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_name                           in     varchar2 default hr_api.g_varchar2
  ,p_type                           in     varchar2 default hr_api.g_varchar2
  ,p_place_used_flag                in     varchar2 default hr_api.g_varchar2
  ,p_comments                       in     varchar2 default hr_api.g_varchar2
  ,p_description                    in     varchar2 default hr_api.g_varchar2
  ,p_bst_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_bst_information1               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information2               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information3               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information4               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information5               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information6               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information7               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information8               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information9               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information10              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information11              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information12              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information13              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information14              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information15              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information16              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information17              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information18              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information19              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information20              in     varchar2 default hr_api.g_varchar2
  ,p_booking_status_type_id         in	   number default hr_api.g_number
  ,p_object_version_number          in out    nocopy number
--  ,p_data_source                    in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_booking_status_type >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Enrollment status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Enrollment status record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Enrollment status section is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete a Enrollment status record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_booking_status_type_id The unique identifier for this Enrollment status.
 * @param p_object_version_number If p_validate is false, then set to the version
 * number of the created Enrollment status. If p_validate is true, then the value will be null.
 * @rep:displayname Delete Enrollment Status
 * @rep:category BUSINESS_ENTITY OTA_ENROLLMENT_STATUS_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure DELETE_BOOKING_STATUS_TYPE
  (p_validate                      in     boolean  default false
  ,p_booking_status_type_id        in     number
  ,p_object_version_number         in     number
  );

end ota_BOOKING_STATUS_TYPE_api;

 

/
