--------------------------------------------------------
--  DDL for Package PQP_PL_VEHICLE_REPOSITORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PL_VEHICLE_REPOSITORY_API" AUTHID CURRENT_USER as
/* $Header: pqvrepli.pkh 120.3 2006/04/24 23:32:27 nprasath noship $ */
/*#
 * This package contains vehicle repository APIs for Poland
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Vehicle Repository for Poland
 */

-- ----------------------------------------------------------------------------
-- |--------------------------< create_pl_vehicle >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
/*#
 * This API creates a vehicle in the repository for Polish legislation.
 * This is an alternative to generic CREATE_VEHICLE API.
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  Business group should be present before creating a vehicle repository
 *
 * <p><b> Post Success</b><br>
 * The vehicle repository record will be successfully inserted into the
 * database.
 *
 * <p><b> Post Failure</b><br>
 * The vehicle repository record will not be created and an error will be
 * raised.
 * @param p_validate	If true, the database remains unchanged. If false,the
 * vehicle repository record is created
 * @param p_effective_date  The effective start date of the vehicle repository
 * record
 * @param p_vehicle_registration_number  Registration Number for this vehicle
 * @param p_vehicle_type Identifies whether the vehicle is a car,
 * motorcycle etc.Valid values are defined by 'PQP_VEHICLE_TYPE' lookup type
 * @param p_vehicle_body_number The unique Vehicle identification number,
 * commonly referred to as VIN or Chassis number
 * @param p_business_group_id  The Business Group Identifier to which the
 * vehicle belongs to
 * @param p_make The Make (manufacturer) of the vehicle
 * @param p_engine_capacity_in_cc The Vehicle's engine size in cubic capacity
 * @param p_fuel_type The type of fuel used in the vehicle. Valid values are
 * defined by 'PQP_FUEL_TYPE' lookup type
 * @param p_currency_code The currency code for all the monetary columns used
 * in this record.The value should be the same as the Business groups currency
 * code and is from the table FND_CURRENCIES.
 * @param p_vehicle_status The status of the vehicle, whether it is active or
 * inactive.Valid values are defined by 'PQP_VEHICLE_STATUS' lookup type
 * @param p_vehicle_inactivity_reason The reason for vehicle inactivity.
 * Only used if the status is Inactive (I). Valid values are defined by
 * 'PQP_VEHICLE_INACTIVE_REASONS' lookup type
 * @param p_model  The model name of the Vehicle
 * @param p_initial_registration The date the vehicle was registered for the
 * first time.
 * @param p_last_registration_renew_date The most recent date on which the
 * vehicle registration was renewed.
 * @param p_list_price The basic list price of the Vehicle.
 * @param p_accessory_value_at_startdate The value of the accessories in the
 * vehicle at Start Date.
 * @param p_accessory_value_added_later The value of the accessories added
 * later to the vehicle.
 * @param p_market_value_classic_car The market value of the vehicle if it is
 * a Classic vehicle
 * @param p_fiscal_ratings The Fiscal Ratings of the vehicle.
 * @param p_fiscal_ratings_uom The Fiscal Ratings Unit of Measure for the
 * vehicle
 * @param p_vehicle_provider The name of the vehicle provider
 * @param p_vehicle_ownership Identifies whether it is a company or
 * private vehicle.
 * @param p_shared_vehicle Flag to indicate whether the vehicle can be
 * 'allocated to' or 'shared between' multiple employees
 * @param p_asset_number The asset number, if any for the vehicle
 * @param p_lease_contract_number  Lease contract number for the leased
 * company vehicle
 * @param p_lease_contract_expiry_date The date when the lease expires for
 * the company vehicle.
 * @param p_taxation_method Taxation Method used for this vehicle. Valid values
 * are defined by 'PQP_VEHICLE_TAXATION_METHOD' lookup type
 * @param p_fleet_info Additional information for fleet vehicles.
 * @param p_fleet_transfer_date The date the vehicle was transferred, for the
 * fleet vehicle
 * @param p_color The color of the vehicle.Valid values are defined by
 * 'PQP_VEHICLE_COLOR' lookup type
 * @param p_seating_capacity   The passenger seating capacity of the vehicle
 * @param p_weight The weight of the vehicle, the unit of measure is stored in
 * weight_uom column
 * @param p_weight_uom The unit of measure for the weight column
 * Valid values are defined by 'PQP_WEIGHT_UOM' lookup type
 * @param p_year_of_manufacture Year of manufacture of the vehicle
 * @param p_insurance_number The insurance details for the vehicle
 * @param p_insurance_expiry_date Insurance expiration date for the vehicle
 * @param p_comments Free text to store any comments
 * @param p_vre_attribute_category Descriptive flexfield column
 * @param p_vre_attribute1 Descriptive Flexfield Column
 * @param p_vre_attribute2 Descriptive flexfield column
 * @param p_vre_attribute3 Descriptive flexfield column
 * @param p_vre_attribute4 Descriptive flexfield column
 * @param p_vre_attribute5 Descriptive flexfield column
 * @param p_vre_attribute6 Descriptive flexfield column
 * @param p_vre_attribute7 Descriptive flexfield column
 * @param p_vre_attribute8 Descriptive flexfield column
 * @param p_vre_attribute9 Descriptive flexfield column
 * @param p_vre_attribute10 Descriptive flexfield column
 * @param p_vre_attribute11 Descriptive flexfield column
 * @param p_vre_attribute12 Descriptive flexfield column
 * @param p_vre_attribute13 Descriptive flexfield column
 * @param p_vre_attribute14 Descriptive flexfield column
 * @param p_vre_attribute15 Descriptive flexfield column
 * @param p_vre_attribute16 Descriptive flexfield column
 * @param p_vre_attribute17 Descriptive flexfield column
 * @param p_vre_attribute18 Descriptive flexfield column
 * @param p_vre_attribute19 Descriptive flexfield column
 * @param p_vre_attribute20 Descriptive flexfield column
 * @param p_vre_information_category Descriptive flexfield column
 * @param p_vehicle_card_id_number Vehicle Card Identification number
 * @param p_owner Owner
 * @param p_engine_number Engine number
 * @param p_date_of_first_inspection Date of first technical inspection
 * @param p_date_of_next_inspection  Date of next technical inspection
 * @param p_other_technical_information Other Technical information
 * @param p_vehicle_repository_id System generated primary key column
 * using the sequence PQP_VEHICLE_REPOSITORY_F_S.If p_validate is false,
 * then this uniquely identifies the vehicle repository record created.
 * If p_validate is true, then set to null
 * @param p_object_version_number  If p_validate is false, then set to the
 * version number of the new vehicle repository record.If p_validate is true,
 * then set to null
 * @param p_effective_start_date  If p_validate is false, then set to the start
 * date for this record.If p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the end date
 * for this record.If p_validate is true, then set to null
 * @rep:displayname Create Vehicle Repository for Poland
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
-- End of commnets
--
procedure create_pl_vehicle
  ( p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_vehicle_registration_number    in     varchar2
  ,p_vehicle_type                   in     varchar2
  ,p_vehicle_body_number            in     varchar2 default null
  ,p_business_group_id              in     number
  ,p_make                           in     varchar2
  ,p_engine_capacity_in_cc          in     number
  ,p_fuel_type                      in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_vehicle_status                 in     varchar2
  ,p_vehicle_inactivity_reason      in     varchar2
  ,p_model                          in     varchar2 default null
  ,p_initial_registration           in     date default null
  ,p_last_registration_renew_date   in     date default null
  ,p_list_price                     in     number default null
  ,p_accessory_value_at_startdate   in     number default null
  ,p_accessory_value_added_later    in     number default null
  ,p_market_value_classic_car       in     number default null
  ,p_fiscal_ratings                 in     number default null
  ,p_fiscal_ratings_uom             in     varchar2 default null
  ,p_vehicle_provider               in     varchar2 default null
  ,p_vehicle_ownership              in     varchar2 default null
  ,p_shared_vehicle                 in     varchar2 default null
  ,p_asset_number                   in     varchar2 default null
  ,p_lease_contract_number          in     varchar2 default null
  ,p_lease_contract_expiry_date     in     date default null
  ,p_taxation_method                in     varchar2 default null
  ,p_fleet_info                     in     varchar2 default null
  ,p_fleet_transfer_date            in     date     default null
  ,p_color                          in     varchar2 default null
  ,p_seating_capacity               in     number default null
  ,p_weight                         in     number default null
  ,p_weight_uom                     in     varchar2 default null
  ,p_year_of_manufacture            in     number default null
  ,p_insurance_number               in     varchar2 default null
  ,p_insurance_expiry_date          in     date default null
  ,p_comments                       in     varchar2 default null
  ,p_vre_attribute_category         in     varchar2 default null
  ,p_vre_attribute1                 in     varchar2 default null
  ,p_vre_attribute2                 in     varchar2 default null
  ,p_vre_attribute3                 in     varchar2 default null
  ,p_vre_attribute4                 in     varchar2 default null
  ,p_vre_attribute5                 in     varchar2 default null
  ,p_vre_attribute6                 in     varchar2 default null
  ,p_vre_attribute7                 in     varchar2 default null
  ,p_vre_attribute8                 in     varchar2 default null
  ,p_vre_attribute9                 in     varchar2 default null
  ,p_vre_attribute10                in     varchar2 default null
  ,p_vre_attribute11                in     varchar2 default null
  ,p_vre_attribute12                in     varchar2 default null
  ,p_vre_attribute13                in     varchar2 default null
  ,p_vre_attribute14                in     varchar2 default null
  ,p_vre_attribute15                in     varchar2 default null
  ,p_vre_attribute16                in     varchar2 default null
  ,p_vre_attribute17                in     varchar2 default null
  ,p_vre_attribute18                in     varchar2 default null
  ,p_vre_attribute19                in     varchar2 default null
  ,p_vre_attribute20                in     varchar2 default null
  ,p_vre_information_category       in     varchar2 default null
  ,p_vehicle_card_id_number         in     varchar2 default null
  ,p_owner                          in     varchar2 default null
  ,p_engine_number                  in     varchar2 default null
  ,p_date_of_first_inspection       in     varchar2 default null
  ,p_date_of_next_inspection        in     varchar2 default null
  ,p_other_technical_information    in     varchar2 default null
  ,p_vehicle_repository_id          out    NOCOPY number
  ,p_object_version_number          out    NOCOPY number
  ,p_effective_start_date           out    NOCOPY date
  ,p_effective_end_date             out    NOCOPY date
   );
--

-- ----------------------------------------------------------------------------
-- |--------------------------< update_pl_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
/*#
 * This API updates a vehicle in the repository for Polish legislation.
 * All attributes may not be changed if the vehicle is already
 * allocated to an assignment.
 *
 * This is an alternative to generic 'UPDATE_VEHICLE' API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle repository record should be present before updating a vehicle
 * repository.
 *
 * <p><b>Post Success</b><br>
 * The vehicle repository record will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle repository record will not be updated and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the vehicle repository record will be updated
 * @param p_effective_date  Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_vehicle_repository_id Identifier to the vehicle repository record
 * that needs to be updated
 * @param p_object_version_number Pass in the current version number of the
 * vehicle repository to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Vehicle
 * Repository. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_vehicle_registration_number  Registration Number for this vehicle
 * @param p_vehicle_type Identifies whether the vehicle is a car, motorcycle etc.
 * Valid values are defined by 'PQP_VEHICLE_TYPE' lookup type
 * @param p_vehicle_body_number The unique Vehicle identification number,
 * commonly referred
 * to as VIN or Chassis number.
 * @param p_business_group_id  The Business Group Identifier to which the
 * vehicle belongs to.
 * @param p_make The Make (manufacturer) of the vehicle.
 * @param p_engine_capacity_in_cc  	The Vehicle's engine size in cubic capacity
 * @param p_fuel_type  The type of fuel used in the vehicle. Valid values are
 * defined by 'PQP_FUEL_TYPE' lookup type
 * @param p_currency_code  The currency code for all the monetary columns used
 * in this record.
 * The value should be the same as the Business groups currency code and
 * is from the table FND_CURRENCIES.
 * @param p_vehicle_status The status of the vehicle, whether it is active or
 * inactive. Valid values are defined by 'PQP_VEHICLE_STATUS' lookup type
 * @param p_vehicle_inactivity_reason The reason for vehicle inactivity. Only
 * used if the status is Inactive (I). Valid values are defined by
 * 'PQP_VEHICLE_INACTIVE_REASONS.' lookup type
 * @param p_model  The model name of the Vehicle.
 * @param p_initial_registration The date the vehicle was registered for the
 * first time.
 * @param p_last_registration_renew_date The most recent date on which the
 * vehicle registration was renewed
 * @param p_list_price The basic list price of the Vehicle.
 * @param p_accessory_value_at_startdate The value of the accessories in the
 * vehicle at Start Date.
 * @param p_accessory_value_added_later The value of the accessories added
 * later to the vehicle.
 * @param p_market_value_classic_car The market value of the vehicle if it is a
 * classic vehicle.
 * @param p_fiscal_ratings The Fiscal ratings of the vehicle
 * @param p_fiscal_ratings_uom The Fiscal ratings unit of measure for the
 * vehicle
 * @param p_vehicle_provider  The name of the vehicle provider.
 * @param p_vehicle_ownership Identifies whether it is a company or private
 * vehicle.
 * @param p_shared_vehicle Flag to indicate whether the vehicle can be
 *'allocated to' or 'shared between' multiple employees
 * @param p_asset_number The asset number, if any for the vehicle.
 * @param p_lease_contract_number Lease contract number for the leased company
 * vehicle
 * @param p_lease_contract_expiry_date The date when the lease expires for the
 * company vehicle
 * @param p_taxation_method Taxation method used for this vehicle.
 * Valid values are defined by 'PQP_VEHICLE_TAXATION_METHOD' lookup type
 * @param p_fleet_info Additional information for fleet vehicles.
 * @param p_fleet_transfer_date The date the vehicle was transferred, for
 * the fleet vehicle.
 * @param p_color The color of the vehicle. Valid values are defined by
 * 'PQP_VEHICLE_COLOR' lookup type
 * @param p_seating_capacity The passenger seating capacity of the vehicle
 * @param p_weight The weight of the vehicle, the unit of measure is stored in
 * weight_uom column.
 * @param p_weight_uom The unit of measure for the weight column.
 * Valid values are defined by 'PQP_WEIGHT_UOM' lookup type
 * @param p_year_of_manufacture Year of manufacture of the vehicle
 * @param p_insurance_number The insurance details for the vehicle
 * @param p_insurance_expiry_date Insurance expiration date for the vehicle
 * @param p_comments Free text to store any comments.
 * @param p_vre_attribute_category Descriptive flexfield column
 * @param p_vre_attribute1 Descriptive flexfield column
 * @param p_vre_attribute2 Descriptive flexfield column
 * @param p_vre_attribute3 Descriptive flexfield column
 * @param p_vre_attribute4 Descriptive flexfield column
 * @param p_vre_attribute5 Descriptive flexfield column
 * @param p_vre_attribute6 Descriptive flexfield column
 * @param p_vre_attribute7 Descriptive flexfield column
 * @param p_vre_attribute8 Descriptive flexfield column
 * @param p_vre_attribute9 Descriptive flexfield column
 * @param p_vre_attribute10 Descriptive flexfield column
 * @param p_vre_attribute11 Descriptive flexfield column
 * @param p_vre_attribute12 Descriptive flexfield column
 * @param p_vre_attribute13 Descriptive flexfield column
 * @param p_vre_attribute14 Descriptive flexfield column
 * @param p_vre_attribute15 Descriptive flexfield column
 * @param p_vre_attribute16 Descriptive flexfield column
 * @param p_vre_attribute17 Descriptive flexfield column
 * @param p_vre_attribute18 Descriptive flexfield column
 * @param p_vre_attribute19 Descriptive flexfield column
 * @param p_vre_attribute20 Descriptive flexfield column
 * @param p_vre_information_category Descriptive flexfield column
 * @param p_vehicle_card_id_number Vehicle card identification number
 * @param p_owner   Owner
 * @param p_engine_number Engine number
 * @param p_date_of_first_inspection  Date of first technical inspection
 * @param p_date_of_next_inspection   Date of next technical inspection
 * @param p_other_technical_information  Other technical information
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated vehicle repository row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated vehicle repository row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Vehicle Repository for Poland
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:lifecycle  active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
Procedure update_pl_vehicle
  (p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_vehicle_registration_number  in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_type                 in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_body_number          in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_make                         in     varchar2  default hr_api.g_varchar2
  ,p_engine_capacity_in_cc        in     number    default hr_api.g_number
  ,p_fuel_type                    in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_status               in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_inactivity_reason    in     varchar2  default hr_api.g_varchar2
  ,p_model                        in     varchar2  default hr_api.g_varchar2
  ,p_initial_registration         in     date      default hr_api.g_date
  ,p_last_registration_renew_date in     date      default hr_api.g_date
  ,p_list_price                   in     number    default hr_api.g_number
  ,p_accessory_value_at_startdate in     number    default hr_api.g_number
  ,p_accessory_value_added_later  in     number    default hr_api.g_number
  ,p_market_value_classic_car     in     number    default hr_api.g_number
  ,p_fiscal_ratings               in     number    default hr_api.g_number
  ,p_fiscal_ratings_uom           in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_provider             in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_ownership            in     varchar2  default hr_api.g_varchar2
  ,p_shared_vehicle               in     varchar2  default hr_api.g_varchar2
  ,p_asset_number                 in     varchar2  default hr_api.g_varchar2
  ,p_lease_contract_number        in     varchar2  default hr_api.g_varchar2
  ,p_lease_contract_expiry_date   in     date      default hr_api.g_date
  ,p_taxation_method              in     varchar2  default hr_api.g_varchar2
  ,p_fleet_info                   in     varchar2  default hr_api.g_varchar2
  ,p_fleet_transfer_date          in     date      default hr_api.g_date
  ,p_color                        in     varchar2  default hr_api.g_varchar2
  ,p_seating_capacity             in     number    default hr_api.g_number
  ,p_weight                       in     number    default hr_api.g_number
  ,p_weight_uom                   in     varchar2  default hr_api.g_varchar2
  ,p_year_of_manufacture          in     number    default hr_api.g_number
  ,p_insurance_number             in     varchar2  default hr_api.g_varchar2
  ,p_insurance_expiry_date        in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_vre_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_card_id_number       in     varchar2  default hr_api.g_varchar2
  ,p_owner                        in     varchar2  default hr_api.g_varchar2
  ,p_engine_number                in     varchar2  default hr_api.g_varchar2
  ,p_date_of_first_inspection     in     varchar2  default hr_api.g_varchar2
  ,p_date_of_next_inspection      in     varchar2  default hr_api.g_varchar2
  ,p_other_technical_information  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    NOCOPY date
  ,p_effective_end_date           out    NOCOPY date
  );

END pqp_pl_vehicle_repository_api;

 

/
