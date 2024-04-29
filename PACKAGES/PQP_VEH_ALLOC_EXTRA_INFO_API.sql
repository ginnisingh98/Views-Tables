--------------------------------------------------------
--  DDL for Package PQP_VEH_ALLOC_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEH_ALLOC_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pqvaiapi.pkh 120.0.12010000.3 2008/08/08 07:18:36 ubhat ship $ */
/*#
 * This package contains vehicle allocation extra information APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Vehicle Allocation Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_veh_alloc_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates vehicle allocation extra information for an allocation.
 *
 * Using this insert API you can create any additional information regarding
 * the vehicle allocation.The extra information types are either delivered by
 * the localization teams or created by the customers.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle allocation should be present before creating a vehicle allocation
 * extra information.
 *
 * <p><b>Post Success</b><br>
 * The vehicle allocation extra information record will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle allocation extra information record will not be created and an
 * error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vehicle_allocation_id The vehicle allocation id for which this
 * extra information is created. Its a foreign key to PQP_VEHICLE_ALLOCATION_F.
 * @param p_information_type Foreign key to PQP_VEH_ALLOC_INFO_TYPES to
 * identify the type of information.
 * @param p_vaei_attribute_category Descriptive flexfield column.
 * @param p_vaei_attribute1 Descriptive flexfield column.
 * @param p_vaei_attribute2 Descriptive flexfield column.
 * @param p_vaei_attribute3 Descriptive flexfield column.
 * @param p_vaei_attribute4 Descriptive flexfield column.
 * @param p_vaei_attribute5 Descriptive flexfield column.
 * @param p_vaei_attribute6 Descriptive flexfield column.
 * @param p_vaei_attribute7 Descriptive flexfield column.
 * @param p_vaei_attribute8 Descriptive flexfield column.
 * @param p_vaei_attribute9 Descriptive flexfield column.
 * @param p_vaei_attribute10 Descriptive flexfield column.
 * @param p_vaei_attribute11 Descriptive flexfield column.
 * @param p_vaei_attribute12 Descriptive flexfield column.
 * @param p_vaei_attribute13 Descriptive flexfield column.
 * @param p_vaei_attribute14 Descriptive flexfield column.
 * @param p_vaei_attribute15 Descriptive flexfield column.
 * @param p_vaei_attribute16 Descriptive flexfield column.
 * @param p_vaei_attribute17 Descriptive flexfield column.
 * @param p_vaei_attribute18 Descriptive flexfield column.
 * @param p_vaei_attribute19 Descriptive flexfield column.
 * @param p_vaei_attribute20 Descriptive flexfield column.
 * @param p_vaei_information_category Developer descriptive flexfield column.
 * @param p_vaei_information1 Developer descriptive flexfield column.
 * @param p_vaei_information2 Developer descriptive flexfield column.
 * @param p_vaei_information3 Developer descriptive flexfield column.
 * @param p_vaei_information4 Developer descriptive flexfield column.
 * @param p_vaei_information5 Developer descriptive flexfield column.
 * @param p_vaei_information6 Developer descriptive flexfield column.
 * @param p_vaei_information7 Developer descriptive flexfield column.
 * @param p_vaei_information8 Developer descriptive flexfield column.
 * @param p_vaei_information9 Developer descriptive flexfield column.
 * @param p_vaei_information10 Developer descriptive flexfield column.
 * @param p_vaei_information11 Developer descriptive flexfield column.
 * @param p_vaei_information12 Developer descriptive flexfield column.
 * @param p_vaei_information13 Developer descriptive flexfield column.
 * @param p_vaei_information14 Developer descriptive flexfield column.
 * @param p_vaei_information15 Developer descriptive flexfield column.
 * @param p_vaei_information16 Developer descriptive flexfield column.
 * @param p_vaei_information17 Developer descriptive flexfield column.
 * @param p_vaei_information18 Developer descriptive flexfield column.
 * @param p_vaei_information19 Developer descriptive flexfield column.
 * @param p_vaei_information20 Developer descriptive flexfield column.
 * @param p_vaei_information21 Developer descriptive flexfield column.
 * @param p_vaei_information22 Developer descriptive flexfield column.
 * @param p_vaei_information23 Developer descriptive flexfield column.
 * @param p_vaei_information24 Developer descriptive flexfield column.
 * @param p_vaei_information25 Developer descriptive flexfield column.
 * @param p_vaei_information26 Developer descriptive flexfield column.
 * @param p_vaei_information27 Developer descriptive flexfield column.
 * @param p_vaei_information28 Developer descriptive flexfield column.
 * @param p_vaei_information29 Developer descriptive flexfield column.
 * @param p_vaei_information30 Developer descriptive flexfield column.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_veh_alloc_extra_info_id The primary key generated by the API for
 * this record. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created vehicle allocation extra information. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Vehicle Allocation Extra Information
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_veh_alloc_extra_info
  (p_validate                      in     boolean  default false
  ,p_vehicle_allocation_id          in     number
  ,p_information_type               in     varchar2
  ,p_vaei_attribute_category        in     varchar2 default null
  ,p_vaei_attribute1                in     varchar2 default null
  ,p_vaei_attribute2                in     varchar2 default null
  ,p_vaei_attribute3                in     varchar2 default null
  ,p_vaei_attribute4                in     varchar2 default null
  ,p_vaei_attribute5                in     varchar2 default null
  ,p_vaei_attribute6                in     varchar2 default null
  ,p_vaei_attribute7                in     varchar2 default null
  ,p_vaei_attribute8                in     varchar2 default null
  ,p_vaei_attribute9                in     varchar2 default null
  ,p_vaei_attribute10               in     varchar2 default null
  ,p_vaei_attribute11               in     varchar2 default null
  ,p_vaei_attribute12               in     varchar2 default null
  ,p_vaei_attribute13               in     varchar2 default null
  ,p_vaei_attribute14               in     varchar2 default null
  ,p_vaei_attribute15               in     varchar2 default null
  ,p_vaei_attribute16               in     varchar2 default null
  ,p_vaei_attribute17               in     varchar2 default null
  ,p_vaei_attribute18               in     varchar2 default null
  ,p_vaei_attribute19               in     varchar2 default null
  ,p_vaei_attribute20               in     varchar2 default null
  ,p_vaei_information_category      in     varchar2 default null
  ,p_vaei_information1              in     varchar2 default null
  ,p_vaei_information2              in     varchar2 default null
  ,p_vaei_information3              in     varchar2 default null
  ,p_vaei_information4              in     varchar2 default null
  ,p_vaei_information5              in     varchar2 default null
  ,p_vaei_information6              in     varchar2 default null
  ,p_vaei_information7              in     varchar2 default null
  ,p_vaei_information8              in     varchar2 default null
  ,p_vaei_information9              in     varchar2 default null
  ,p_vaei_information10             in     varchar2 default null
  ,p_vaei_information11             in     varchar2 default null
  ,p_vaei_information12             in     varchar2 default null
  ,p_vaei_information13             in     varchar2 default null
  ,p_vaei_information14             in     varchar2 default null
  ,p_vaei_information15             in     varchar2 default null
  ,p_vaei_information16             in     varchar2 default null
  ,p_vaei_information17             in     varchar2 default null
  ,p_vaei_information18             in     varchar2 default null
  ,p_vaei_information19             in     varchar2 default null
  ,p_vaei_information20             in     varchar2 default null
  ,p_vaei_information21             in     varchar2 default null
  ,p_vaei_information22             in     varchar2 default null
  ,p_vaei_information23             in     varchar2 default null
  ,p_vaei_information24             in     varchar2 default null
  ,p_vaei_information25             in     varchar2 default null
  ,p_vaei_information26             in     varchar2 default null
  ,p_vaei_information27             in     varchar2 default null
  ,p_vaei_information28             in     varchar2 default null
  ,p_vaei_information29             in     varchar2 default null
  ,p_vaei_information30             in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_veh_alloc_extra_info_id        out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_veh_alloc_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates vehicle allocation extra information.
 *
 * This is used to update a row for the additional information about vehicle
 * allocation for an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle Allocation should be present before updating a vehicle allocation
 * extra information.
 *
 * <p><b>Post Success</b><br>
 * The Vehicle Allocation Extra Information record will be successfully updated
 * into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Vehicle Allocation Extra Information record will not be updated and an
 * error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_veh_alloc_extra_info_id System generated primary key column using
 * the sequence PQP_VEH_ALLOC_EXTRA_INFO_S.
 * @param p_object_version_number Pass in the current version number of the
 * vehicle allocation extra information to be updated. When the API completes
 * if p_validate is false, will be set to the new version number of the updated
 * vehicle allocation extra information. If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_vehicle_allocation_id The vehicle allocation id for which this
 * extra information is created. Its a foreign key to PQP_VEHICLE_ALLOCATION_F.
 * @param p_information_type Foreign key to PQP_VEH_ALLOC_INFO_TYPES to
 * identify the type of information.
 * @param p_vaei_attribute_category Descriptive flexfield column.
 * @param p_vaei_attribute1 Descriptive flexfield column.
 * @param p_vaei_attribute2 Descriptive flexfield column.
 * @param p_vaei_attribute3 Descriptive flexfield column.
 * @param p_vaei_attribute4 Descriptive flexfield column.
 * @param p_vaei_attribute5 Descriptive flexfield column.
 * @param p_vaei_attribute6 Descriptive flexfield column.
 * @param p_vaei_attribute7 Descriptive flexfield column.
 * @param p_vaei_attribute8 Descriptive flexfield column.
 * @param p_vaei_attribute9 Descriptive flexfield column.
 * @param p_vaei_attribute10 Descriptive flexfield column.
 * @param p_vaei_attribute11 Descriptive flexfield column.
 * @param p_vaei_attribute12 Descriptive flexfield column.
 * @param p_vaei_attribute13 Descriptive flexfield column.
 * @param p_vaei_attribute14 Descriptive flexfield column.
 * @param p_vaei_attribute15 Descriptive flexfield column.
 * @param p_vaei_attribute16 Descriptive flexfield column.
 * @param p_vaei_attribute17 Descriptive flexfield column.
 * @param p_vaei_attribute18 Descriptive flexfield column.
 * @param p_vaei_attribute19 Descriptive flexfield column.
 * @param p_vaei_attribute20 Descriptive flexfield column.
 * @param p_vaei_information_category Developer descriptive flexfield column.
 * @param p_vaei_information1 Developer descriptive flexfield column.
 * @param p_vaei_information2 Developer descriptive flexfield column.
 * @param p_vaei_information3 Developer descriptive flexfield column.
 * @param p_vaei_information4 Developer descriptive flexfield column.
 * @param p_vaei_information5 Developer descriptive flexfield column.
 * @param p_vaei_information6 Developer descriptive flexfield column.
 * @param p_vaei_information7 Developer descriptive flexfield column.
 * @param p_vaei_information8 Developer descriptive flexfield column.
 * @param p_vaei_information9 Developer descriptive flexfield column.
 * @param p_vaei_information10 Developer descriptive flexfield column.
 * @param p_vaei_information11 Developer descriptive flexfield column.
 * @param p_vaei_information12 Developer descriptive flexfield column.
 * @param p_vaei_information13 Developer descriptive flexfield column.
 * @param p_vaei_information14 Developer descriptive flexfield column.
 * @param p_vaei_information15 Developer descriptive flexfield column.
 * @param p_vaei_information16 Developer descriptive flexfield column.
 * @param p_vaei_information17 Developer descriptive flexfield column.
 * @param p_vaei_information18 Developer descriptive flexfield column.
 * @param p_vaei_information19 Developer descriptive flexfield column.
 * @param p_vaei_information20 Developer descriptive flexfield column.
 * @param p_vaei_information21 Developer descriptive flexfield column.
 * @param p_vaei_information22 Developer descriptive flexfield column.
 * @param p_vaei_information23 Developer descriptive flexfield column.
 * @param p_vaei_information24 Developer descriptive flexfield column.
 * @param p_vaei_information25 Developer descriptive flexfield column.
 * @param p_vaei_information26 Developer descriptive flexfield column.
 * @param p_vaei_information27 Developer descriptive flexfield column.
 * @param p_vaei_information28 Developer descriptive flexfield column.
 * @param p_vaei_information29 Developer descriptive flexfield column.
 * @param p_vaei_information30 Developer descriptive flexfield column.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @rep:displayname Update Vehicle Allocation Extra Information
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure update_veh_alloc_extra_info
 (p_validate                      in     boolean  default false
  ,p_veh_alloc_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_allocation_id        in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information1            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information2            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information3            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information4            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information5            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information6            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information7            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information8            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information9            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information10           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information11           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information12           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information13           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information14           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information15           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information16           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information17           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information18           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information19           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information20           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information21           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information22           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information23           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information24           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information25           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information26           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information27           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information28           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information29           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information30           in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date

  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_veh_alloc_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the vehicle allocation extra information row for an
 * allocation.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *
 * <p><b>Post Success</b><br>
 * The Vehicle Allocation Extra Information record will be successfully deleted
 * from the database.
 *
 * <p><b>Post Failure</b><br>
 * The Vehicle Allocation Extra Information record will not be deleted and an
 * error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_veh_alloc_extra_info_id System generated primary key column using
 * the sequence PQP_VEH_ALLOC_EXTRA_INFO_S.
 * @param p_object_version_number Current version number of the vehicle
 * allocation extra information to be deleted.
 * @rep:displayname Delete Vehicle Allocation Extra Information.
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure delete_veh_alloc_extra_info
  ( p_validate                       in     boolean  default false
   ,p_veh_alloc_extra_info_id        in     number
  ,p_object_version_number           in     number
  );
end PQP_VEH_ALLOC_EXTRA_INFO_API;

/
