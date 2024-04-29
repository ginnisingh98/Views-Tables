--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_ALLOCATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_ALLOCATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqvalapi.pkh 120.1 2005/10/02 02:28:38 aroussel $ */
/*#
 * This package contains APIs to create, update or delete a Vehicle Allocation
 * to an employee assignment.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Vehicle Allocation
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_vehicle_allocation >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allocates a vehicle from the vehicle repository to an assignment.
 *
 * This API creates a vehicle allocation record for an assignment. The vehicle
 * should already exist in the Vehicle Repository. Some of the attributes
 * depends on whether it is a company or a private vehicle. Additional details
 * related to the mileage reimbursements can also be stored. If 'Y' is passed
 * to p_accross_assignments then the vehicle will be allocated to all
 * assignments for that employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle should be present in the vehicle repository before allocating to an
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The vehicle allocation record will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle allocation record will not be created and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment for which you create the
 * vehicle allocation record.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.BUSINESS_GROUP_ID}
 * @param p_vehicle_repository_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VEHICLE_REPOSITORY_ID}
 * @param p_across_assignments {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.ACROSS_ASSIGNMENTS}
 * @param p_usage_type {@rep:casecolumn PQP_VEHICLE_ALLOCATIONS_F.USAGE_TYPE}
 * @param p_capital_contribution {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.CAPITAL_CONTRIBUTION}
 * @param p_private_contribution {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.PRIVATE_CONTRIBUTION}
 * @param p_default_vehicle {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.DEFAULT_VEHICLE}
 * @param p_fuel_card {@rep:casecolumn PQP_VEHICLE_ALLOCATIONS_F.FUEL_CARD}
 * @param p_fuel_card_number {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.FUEL_CARD_NUMBER}
 * @param p_calculation_method {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.CALCULATION_METHOD}
 * @param p_rates_table_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.RATES_TABLE_ID}
 * @param p_element_type_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.ELEMENT_TYPE_ID}
 * @param p_private_use_flag Indicates whether the company vehicle user can use
 * this vehicle for private purposes.
 * @param p_insurance_number The insurance details for the vehicle.
 * @param p_insurance_expiry_date Insurance expiration date.
 * @param p_val_attribute_category {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE_CATEGORY}
 * @param p_val_attribute1 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE1}
 * @param p_val_attribute2 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE2}
 * @param p_val_attribute3 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE3}
 * @param p_val_attribute4 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE4}
 * @param p_val_attribute5 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE5}
 * @param p_val_attribute6 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE6}
 * @param p_val_attribute7 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE7}
 * @param p_val_attribute8 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE8}
 * @param p_val_attribute9 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE9}
 * @param p_val_attribute10 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE10}
 * @param p_val_attribute11 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE11}
 * @param p_val_attribute12 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE12}
 * @param p_val_attribute13 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE13}
 * @param p_val_attribute14 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE14}
 * @param p_val_attribute15 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE15}
 * @param p_val_attribute16 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE16}
 * @param p_val_attribute17 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE17}
 * @param p_val_attribute18 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE18}
 * @param p_val_attribute19 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE19}
 * @param p_val_attribute20 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE20}
 * @param p_val_information_category {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION_CATEGORY}
 * @param p_val_information1 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION1}
 * @param p_val_information2 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION2}
 * @param p_val_information3 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION3}
 * @param p_val_information4 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION4}
 * @param p_val_information5 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION5}
 * @param p_val_information6 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION6}
 * @param p_val_information7 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION7}
 * @param p_val_information8 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION8}
 * @param p_val_information9 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION9}
 * @param p_val_information10 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION10}
 * @param p_val_information11 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION11}
 * @param p_val_information12 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION12}
 * @param p_val_information13 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION13}
 * @param p_val_information14 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION14}
 * @param p_val_information15 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION15}
 * @param p_val_information16 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION16}
 * @param p_val_information17 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION17}
 * @param p_val_information18 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION18}
 * @param p_val_information19 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION19}
 * @param p_val_information20 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION20}
 * @param p_fuel_benefit {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.FUEL_BENEFIT}
 * @param p_sliding_rates_info The Sliding rates table information using the
 * lookup PQP_SLIDING_RATES.
 * @param p_vehicle_allocation_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VEHICLE_ALLOCATION_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the allocated vehicle. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the allocated vehicle. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the allocated vehicle. If p_validate is true, then
 * set to null.
 * @rep:displayname Create Vehicle Allocation
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_vehicle_allocation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_assignment_id                  in     number
  ,p_business_group_id              in     number
  ,p_vehicle_repository_id          in     number   default null
  ,p_across_assignments             in     varchar2 default null
  ,p_usage_type                     in     varchar2 default null
  ,p_capital_contribution           in     number   default null
  ,p_private_contribution           in     number   default null
  ,p_default_vehicle                in     varchar2 default null
  ,p_fuel_card                      in     varchar2 default null
  ,p_fuel_card_number               in     varchar2 default null
  ,p_calculation_method             in     varchar2 default null
  ,p_rates_table_id                 in     number   default null
  ,p_element_type_id                in     number   default null
  ,p_private_use_flag		    in     varchar2 default null
  ,p_insurance_number		    in     varchar2 default null
  ,p_insurance_expiry_date	    in     date	    default null
  ,p_val_attribute_category         in     varchar2 default null
  ,p_val_attribute1                 in     varchar2 default null
  ,p_val_attribute2                 in     varchar2 default null
  ,p_val_attribute3                 in     varchar2 default null
  ,p_val_attribute4                 in     varchar2 default null
  ,p_val_attribute5                 in     varchar2 default null
  ,p_val_attribute6                 in     varchar2 default null
  ,p_val_attribute7                 in     varchar2 default null
  ,p_val_attribute8                 in     varchar2 default null
  ,p_val_attribute9                 in     varchar2 default null
  ,p_val_attribute10                in     varchar2 default null
  ,p_val_attribute11                in     varchar2 default null
  ,p_val_attribute12                in     varchar2 default null
  ,p_val_attribute13                in     varchar2 default null
  ,p_val_attribute14                in     varchar2 default null
  ,p_val_attribute15                in     varchar2 default null
  ,p_val_attribute16                in     varchar2 default null
  ,p_val_attribute17                in     varchar2 default null
  ,p_val_attribute18                in     varchar2 default null
  ,p_val_attribute19                in     varchar2 default null
  ,p_val_attribute20                in     varchar2 default null
  ,p_val_information_category       in     varchar2 default null
  ,p_val_information1               in     varchar2 default null
  ,p_val_information2               in     varchar2 default null
  ,p_val_information3               in     varchar2 default null
  ,p_val_information4               in     varchar2 default null
  ,p_val_information5               in     varchar2 default null
  ,p_val_information6               in     varchar2 default null
  ,p_val_information7               in     varchar2 default null
  ,p_val_information8               in     varchar2 default null
  ,p_val_information9               in     varchar2 default null
  ,p_val_information10              in     varchar2 default null
  ,p_val_information11              in     varchar2 default null
  ,p_val_information12              in     varchar2 default null
  ,p_val_information13              in     varchar2 default null
  ,p_val_information14              in     varchar2 default null
  ,p_val_information15              in     varchar2 default null
  ,p_val_information16              in     varchar2 default null
  ,p_val_information17              in     varchar2 default null
  ,p_val_information18              in     varchar2 default null
  ,p_val_information19              in     varchar2 default null
  ,p_val_information20              in     varchar2 default null
  ,p_fuel_benefit                   in     varchar2 default null
  ,p_sliding_rates_info		    in     varchar2 default null
  ,p_vehicle_allocation_id          out    nocopy number
  ,p_object_version_number          out    nocopy number
  ,p_effective_start_date           out    nocopy date
  ,p_effective_end_date             out    nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_vehicle_allocation >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of the allocation of a vehicle.
 *
 * This API updates a vehicle allocation record for an assignment. The vehicle
 * should already exist in the Vehicle Repository. Some of the attributes
 * depends on whether it is a company or a private vehicle.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle repository and vehicle allocation should be present before updating
 * a vehicle.
 *
 * <p><b>Post Success</b><br>
 * The vehicle allocation record will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle allocation record will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_vehicle_allocation_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VEHICLE_ALLOCATION_ID}
 * @param p_object_version_number Pass in the current version number of the
 * vehicle allocation to be updated. When the API completes, if p_validate is
 * false, it will be set to the new version number of the updated vehicle
 * allocation. If p_validate is true, it will be set to the same value which
 * was passed in.
 * @param p_assignment_id Identifies the assignment for which you create the
 * vehicle allocation record.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.BUSINESS_GROUP_ID}
 * @param p_vehicle_repository_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VEHICLE_REPOSITORY_ID}
 * @param p_across_assignments {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.ACROSS_ASSIGNMENTS}
 * @param p_usage_type {@rep:casecolumn PQP_VEHICLE_ALLOCATIONS_F.USAGE_TYPE}
 * @param p_capital_contribution {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.CAPITAL_CONTRIBUTION}
 * @param p_private_contribution {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.PRIVATE_CONTRIBUTION}
 * @param p_default_vehicle {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.DEFAULT_VEHICLE}
 * @param p_fuel_card {@rep:casecolumn PQP_VEHICLE_ALLOCATIONS_F.FUEL_CARD}
 * @param p_fuel_card_number {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.FUEL_CARD_NUMBER}
 * @param p_calculation_method {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.CALCULATION_METHOD}
 * @param p_rates_table_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.RATES_TABLE_ID}
 * @param p_element_type_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.ELEMENT_TYPE_ID}
 * @param p_private_use_flag Indicates whether the company vehicle user can use
 * this vehicle for private purposes.
 * @param p_insurance_number The insurance details for the vehicle.
 * @param p_insurance_expiry_date Insurance expiration date.
 * @param p_val_attribute_category {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE_CATEGORY}
 * @param p_val_attribute1 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE1}
 * @param p_val_attribute2 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE2}
 * @param p_val_attribute3 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE3}
 * @param p_val_attribute4 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE4}
 * @param p_val_attribute5 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE5}
 * @param p_val_attribute6 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE6}
 * @param p_val_attribute7 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE7}
 * @param p_val_attribute8 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE8}
 * @param p_val_attribute9 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE9}
 * @param p_val_attribute10 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE10}
 * @param p_val_attribute11 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE11}
 * @param p_val_attribute12 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE12}
 * @param p_val_attribute13 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE13}
 * @param p_val_attribute14 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE14}
 * @param p_val_attribute15 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE15}
 * @param p_val_attribute16 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE16}
 * @param p_val_attribute17 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE17}
 * @param p_val_attribute18 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE18}
 * @param p_val_attribute19 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE19}
 * @param p_val_attribute20 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_ATTRIBUTE20}
 * @param p_val_information_category {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION_CATEGORY}
 * @param p_val_information1 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION1}
 * @param p_val_information2 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION2}
 * @param p_val_information3 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION3}
 * @param p_val_information4 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION4}
 * @param p_val_information5 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION5}
 * @param p_val_information6 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION6}
 * @param p_val_information7 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION7}
 * @param p_val_information8 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION8}
 * @param p_val_information9 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION9}
 * @param p_val_information10 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION10}
 * @param p_val_information11 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION11}
 * @param p_val_information12 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION12}
 * @param p_val_information13 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION13}
 * @param p_val_information14 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION14}
 * @param p_val_information15 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION15}
 * @param p_val_information16 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION16}
 * @param p_val_information17 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION17}
 * @param p_val_information18 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION18}
 * @param p_val_information19 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION19}
 * @param p_val_information20 {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VAL_INFORMATION20}
 * @param p_fuel_benefit {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.FUEL_BENEFIT}
 * @param p_sliding_rates_info The Sliding rates table information using the
 * lookup PQP_SLIDING_RATES.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated vehicle allocation row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Vehicle Allocation row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Vehicle Allocation
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_vehicle_allocation
  (p_validate                       in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_vehicle_repository_id        in     number    default hr_api.g_number
  ,p_across_assignments           in     varchar2  default hr_api.g_varchar2
  ,p_usage_type                   in     varchar2  default hr_api.g_varchar2
  ,p_capital_contribution         in     number    default hr_api.g_number
  ,p_private_contribution         in     number    default hr_api.g_number
  ,p_default_vehicle              in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card                    in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card_number             in     varchar2  default hr_api.g_varchar2
  ,p_calculation_method           in     varchar2  default hr_api.g_varchar2
  ,p_rates_table_id               in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_private_use_flag		  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_number		  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_expiry_date	  in     date	   default hr_api.g_date
  ,p_val_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_val_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_val_information1             in     varchar2  default hr_api.g_varchar2
  ,p_val_information2             in     varchar2  default hr_api.g_varchar2
  ,p_val_information3             in     varchar2  default hr_api.g_varchar2
  ,p_val_information4             in     varchar2  default hr_api.g_varchar2
  ,p_val_information5             in     varchar2  default hr_api.g_varchar2
  ,p_val_information6             in     varchar2  default hr_api.g_varchar2
  ,p_val_information7             in     varchar2  default hr_api.g_varchar2
  ,p_val_information8             in     varchar2  default hr_api.g_varchar2
  ,p_val_information9             in     varchar2  default hr_api.g_varchar2
  ,p_val_information10            in     varchar2  default hr_api.g_varchar2
  ,p_val_information11            in     varchar2  default hr_api.g_varchar2
  ,p_val_information12            in     varchar2  default hr_api.g_varchar2
  ,p_val_information13            in     varchar2  default hr_api.g_varchar2
  ,p_val_information14            in     varchar2  default hr_api.g_varchar2
  ,p_val_information15            in     varchar2  default hr_api.g_varchar2
  ,p_val_information16            in     varchar2  default hr_api.g_varchar2
  ,p_val_information17            in     varchar2  default hr_api.g_varchar2
  ,p_val_information18            in     varchar2  default hr_api.g_varchar2
  ,p_val_information19            in     varchar2  default hr_api.g_varchar2
  ,p_val_information20            in     varchar2  default hr_api.g_varchar2
  ,p_fuel_benefit                 in     varchar2  default hr_api.g_varchar2
  ,p_sliding_rates_info		  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    nocopy date
  ,p_effective_end_date           out    nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vehicle_allocation >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a vehicle allocation.
 *
 * This API deletes a vehicle allocation record for an assignment.If the
 * vehicle was allocated to other assignments for that person, then it needs to
 * be removed individually.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle allocation should be present before deleting a vehicle.
 *
 * <p><b>Post Success</b><br>
 * The vehicle allocation record will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle allocation record will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change
 * @param p_vehicle_allocation_id {@rep:casecolumn
 * PQP_VEHICLE_ALLOCATIONS_F.VEHICLE_ALLOCATION_ID}
 * @param p_object_version_number Current version number of the vehicle
 * allocation to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted vehicle allocation row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created vehicle allocation. If p_validate is
 * true, then set to null.
 * @rep:displayname Delete Vehicle Allocation
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_vehicle_allocation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_vehicle_allocation_id          in     number
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date           out    nocopy date
  ,p_effective_end_date             out    nocopy date
  );

end PQP_VEHICLE_ALLOCATIONS_API;

 

/
