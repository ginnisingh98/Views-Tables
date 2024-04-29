--------------------------------------------------------
--  DDL for Package PQP_PL_VEHICLE_ALLOCATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PL_VEHICLE_ALLOCATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqvalpli.pkh 120.3 2006/04/24 23:29:02 nprasath noship $ */
/*#
 * This package contains Vehicle Allocation APIs for Poland.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Vehicle allocation for Poland
*/---------------------------------------------------------------------------
-- |--------------------------< create_pl_vehicle_allocation>------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
/*#
 * This API creates vehicle allocation for polish person.
 * This is an alternative to generic CREATE_VEHICLE_ALLOCATION API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle should be present in the vehicle repository before allocating to an
 * assignment.
 *
 * <p><b> Post Success</b><br>
 * The vehicle allocation record will be successfully inserted into the
 * database.
 *
 * <p><b> Post Failure</b><br>
 * The vehicle allocation record will not be created and an error will be
 * raised.
 * @param p_validate If true, the database remains unchanged. If false,
 * vehicle allocation is created.
 * @param p_effective_date The start date of vehicle allocation record
 * @param p_assignment_id The assignment identifier having this vehicle
 * allocation.
 * @param p_business_group_id Business group identifier
 * @param p_vehicle_repository_id  The repository identifier of the
 * vehicle which is being allocated to this assignment.The id is from
 * PQP_VEHICLE_REPOSITORY_F table
 * @param p_across_assignments Identifies whether the vehicle allocation is
 *  across assignments,if there are multiple assignments for this employee.
 * @param p_usage_type The usage type for this allocation. This value depends
 * on the type of vehicle being allocated.Valid values are from
 * 'PQP_COMPANY_VEHICLE_USER' or 'PQP_PRIVATE_VEHICLE_USER' lookup type.
 * @param p_capital_contribution Capital contribution from the employee
 * towards this vehicle
 * @param p_private_contribution Private contribution from the employee
 * towards this vehicle.
 * @param p_default_vehicle Identifies whether this vehicle should be treated
 * as the default vehicle for mileage claims when more than one vehicle
 * is allocated.
 * @param p_fuel_card Identifies whether a fuel card has been given for this
 * allocation.
 * @param p_fuel_card_number Fuel card number if fuel card has been given
 * @param p_calculation_method Calculation method used for mileage
 * calculation.Valid values are defined by 'PQP_VEHICLE_CALC_METHOD'
 * lookup type
 * @param p_rates_table_id Rates table identifier if the mileage rates
 * should be based on a particular user defined table.
 * @param p_element_type_id The element type identifier if a particular
 * element should be used for mileage calculations.
 * @param p_private_use_flag Indicates whether the company vehicle user
 * can use this vehicle for private purposes.
 * @param p_insurance_number Insurance number for the vehicle.
 * @param p_insurance_expiry_date Insurance expiration date.
 * @param p_val_attribute_category Descriptive flexfield column
 * @param p_val_attribute1 Descriptive flexfield column
 * @param p_val_attribute2 Descriptive flexfield column
 * @param p_val_attribute3 Descriptive flexfield column
 * @param p_val_attribute4 Descriptive flexfield column
 * @param p_val_attribute5 Descriptive flexfield column
 * @param p_val_attribute6 Descriptive flexfield column
 * @param p_val_attribute7 Descriptive flexfield column
 * @param p_val_attribute8 Descriptive flexfield column
 * @param p_val_attribute9 Descriptive flexfield column
 * @param p_val_attribute10 Descriptive flexfield column
 * @param p_val_attribute11 Descriptive flexfield column
 * @param p_val_attribute12 Descriptive flexfield column
 * @param p_val_attribute13 Descriptive flexfield column
 * @param p_val_attribute14 Descriptive flexfield column
 * @param p_val_attribute15 Descriptive flexfield column
 * @param p_val_attribute16 Descriptive flexfield column
 * @param p_val_attribute17 Descriptive flexfield column
 * @param p_val_attribute18 Descriptive flexfield column
 * @param p_val_attribute19 Descriptive flexfield column
 * @param p_val_attribute20 Descriptive flexfield column
 * @param p_val_information_category Developer descriptive flexfield column
 * @param p_agreement_description Agreement description
 * @param p_month_mileage_limit_by_law Monthly mileage limit by law
 * @param p_month_mileage_limit_by_emp Monthly mileage limit by employee
 * @param p_other_conditions Other conditions
 * @param p_fuel_benefit Identifies whether there is any additional fuel
 * benefit for this allocation.
 * @param p_sliding_rates_info Sliding rates table information.Valid values
 * are defined by 'PQP_SLIDING_RATES' lookup type
 * @param p_vehicle_allocation_id System generated primary key column from the
 * sequence PQP_VEHICLE_ALLOCATIONS_F_S.If p_validate is false, uniquely
 * identifies the Vehicle Allocation created.If p_validate is true, set to null
 * @param p_object_version_number System generated version of row. Increments by
 * one with each update.If p_validate is false, set to the version number of
 * this vehicle allocation. If p_validate is true, set to null.If p_validate is
 * false, set to the version number of this vehicle allocation.
 * If p_validate is true,set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the allocated vehicle. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the allocated vehicle. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Vehicle Allocation for Poland
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--

procedure create_pl_vehicle_allocation
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
  ,p_private_use_flag		    	in     varchar2 default null
  ,p_insurance_number		    	in     varchar2 default null
  ,p_insurance_expiry_date	    	in     date	    default null
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
  ,p_agreement_description          in     varchar2 default null
  ,p_month_mileage_limit_by_law  	in     varchar2 default null
  ,p_month_mileage_limit_by_emp  	in     varchar2 default null
  ,p_other_conditions               in     varchar2 default null
  ,p_fuel_benefit                   in     varchar2 default null
  ,p_sliding_rates_info		    	in     varchar2 default null
  ,p_vehicle_allocation_id          out    nocopy number
  ,p_object_version_number          out    nocopy number
  ,p_effective_start_date           out    nocopy date
  ,p_effective_end_date             out    nocopy date
  );
--

-- --------------------------------------------------------------------------------------
-- |--------------------------< update_pl_vehicle_allocation >--------------------------|
-- --------------------------------------------------------------------------------------
--
-- {Start Of Comments}
--

/*#
 * This API updates the vehicle allocation for polish person.
 * This is an alternative to generic UPDATE_VEHICLE_ALLOCATION API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources
 *
 * <p><b>Prerequisites</b><br>
 *  The Vehicle allocation to be updated must exist for Polish Localization
 *
 * <p><b> Post Success</b><br>
 * The vehicle allocation record will be successfully updated into the
 * database
 *
 * <p><b> Post Failure</b><br>
 * The vehicle allocation record will not be updated and an error will be
 * raised
 * @param p_validate If true, the database remains unchanged. If false,
 * the vehicle allocation is created
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when
 * updating the record. This must be set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_vehicle_allocation_id Identifies the vehicle allocation to be
 * updated
 * @param p_object_version_number System generated version of row. Increments
 * by one with each update.If p_validate is false, set to the version number of
 * updated vehicle allocation. If p_validate is true, the object number version
 * is left unchanged
 * @param p_assignment_id Assignment identifier having this vehicle allocation
 * @param p_business_group_id Business Group Identifier
 * @param p_vehicle_repository_id Repository identifier of the vehicle which is
 * being allocated to this assignment.The id is from PQP_VEHICLE_REPOSITORY_F table
 * @param p_across_assignments Identifies whether the vehicle allocation is
 * across assignments if there are multiple assignments for this employee
 * @param p_usage_type The usage type for this allocation. This value depends
 * on the type of vehicle being allocated.Valid values are defiend by
 * 'PQP_COMPANY_VEHICLE_USER' or 'PQP_PRIVATE_VEHICLE_USER' lookup type
 * @param p_capital_contribution  Capital contribution from the employee
 * towards this vehicle
 * @param p_private_contribution Private contribution from the employee
 * towards this vehicle
 * @param p_default_vehicle Identifies whether this vehicle should be treated
 * as the default vehicle for mileage claims when more than one
 * vehicle is allocated
 * @param p_fuel_card Identifies whether a fuel card has been given for this
 * allocation
 * @param p_fuel_card_number Fuel card number if fuel card has been given
 * @param p_calculation_method Calculation method used for mileage
 * calculation.Valid values are defined by 'PQP_VEHICLE_CALC_METHOD'
 * lookup type
 * @param p_rates_table_id Rates table Identifier if the mileage rates
 * should be based on a particular user defined table
 * @param p_element_type_id Element type identifier if a particular
 * element should be used for mileage calculations
 * @param p_private_use_flag Indicates whether the company vehicle user can use
 * this vehicle for private purposes
 * @param p_insurance_number Insurance details for the vehicle
 * @param p_insurance_expiry_date Insurance expiration date
 * @param p_val_attribute_category Descriptive flexfield column
 * @param p_val_attribute1 Descriptive flexfield column
 * @param p_val_attribute2 Descriptive flexfield column
 * @param p_val_attribute3 Descriptive flexfield column
 * @param p_val_attribute4 Descriptive flexfield column
 * @param p_val_attribute5 Descriptive flexfield column
 * @param p_val_attribute6 Descriptive flexfield column
 * @param p_val_attribute7 Descriptive flexfield column
 * @param p_val_attribute8 Descriptive flexfield column
 * @param p_val_attribute9 Descriptive flexfield column
 * @param p_val_attribute10 Descriptive flexfield column
 * @param p_val_attribute11 Descriptive flexfield column
 * @param p_val_attribute12 Descriptive flexfield column
 * @param p_val_attribute13 Descriptive flexfield column
 * @param p_val_attribute14 Descriptive flexfield column
 * @param p_val_attribute15 Descriptive flexfield column
 * @param p_val_attribute16 Descriptive flexfield column
 * @param p_val_attribute17 Descriptive flexfield column
 * @param p_val_attribute18 Descriptive flexfield column
 * @param p_val_attribute19 Descriptive flexfield column
 * @param p_val_attribute20 Descriptive flexfield column
 * @param p_val_information_category Developer descriptive flexfield column
 * @param p_agreement_description Agreement description
 * @param p_month_mileage_limit_by_emp Monthly mileage limit by employee
 * @param p_month_mileage_limit_by_law Monthly milegae limit by law
 * @param p_other_conditions Other Conditions
 * @param p_fuel_benefit Identifies whether there is any additional fuel
 * benefit for this allocation
 * @param p_sliding_rates_info The Sliding rates table information.Valid values
 * are defined by 'PQP_SLIDING_RATES' lookup type
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated vehicle allocation row which now exists
 * as of the effective date. If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated vehicle allocation row which now exists
 * as of the effective date. If p_validate is true, then set to null
 * @rep:displayname Update Vehicle Allocation for Poland
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */

--
-- {End Of Comments}
Procedure update_pl_vehicle_allocation
 (p_validate                      in     boolean  default false
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
  ,p_private_use_flag		  	  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_number		  	  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_expiry_date		  in     date	   default hr_api.g_date
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
  ,p_agreement_description        in     varchar2  default hr_api.g_varchar2
  ,p_month_mileage_limit_by_law   in     varchar2  default hr_api.g_varchar2
  ,p_month_mileage_limit_by_emp	  in     varchar2  default hr_api.g_varchar2
  ,p_other_conditions             in     varchar2  default hr_api.g_varchar2
  ,p_fuel_benefit                 in     varchar2  default hr_api.g_varchar2
  ,p_sliding_rates_info		      in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    nocopy date
  ,p_effective_end_date           out    nocopy date
  );

END pqp_pl_vehicle_allocations_api;

 

/
