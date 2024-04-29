--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_REPOSITORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_REPOSITORY_API" AUTHID CURRENT_USER as
/* $Header: pqvreapi.pkh 120.1 2005/10/02 02:28:58 aroussel $ */
/*#
 * This package contains vehicle repository APIs that can be used to create,
 * update or delete a vehicle in the repository.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Vehicle Repository
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a vehicle in the repository, for example, a company or a
 * private vehicle.
 *
 * This API creates a vehicle in the repository, for example, a company or a
 * private vehicle. The vehicle can be car, van or a motorcycle and all
 * attributes related to that vehicle can be stored.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Business group should be present before creating a vehicle repository.
 *
 * <p><b>Post Success</b><br>
 * The vehicle repository record will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle repository record will not be created and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_registration_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.REGISTRATION_NUMBER}
 * @param p_vehicle_type {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_TYPE}
 * @param p_vehicle_id_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_ID_NUMBER}
 * @param p_business_group_id {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.BUSINESS_GROUP_ID}
 * @param p_make {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.MAKE}
 * @param p_engine_capacity_in_cc {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ENGINE_CAPACITY_IN_CC}
 * @param p_fuel_type {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.FUEL_TYPE}
 * @param p_currency_code {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.CURRENCY_CODE}
 * @param p_vehicle_status {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_STATUS}
 * @param p_vehicle_inactivity_reason {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_INACTIVITY_REASON}
 * @param p_model {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.MODEL}
 * @param p_initial_registration {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.INITIAL_REGISTRATION}
 * @param p_last_registration_renew_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LAST_REGISTRATION_RENEW_DATE}
 * @param p_list_price {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.LIST_PRICE}
 * @param p_accessory_value_at_startdate {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ACCESSORY_VALUE_AT_STARTDATE}
 * @param p_accessory_value_added_later {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ACCESSORY_VALUE_ADDED_LATER}
 * @param p_market_value_classic_car {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.MARKET_VALUE_CLASSIC_CAR}
 * @param p_fiscal_ratings {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FISCAL_RATINGS}
 * @param p_fiscal_ratings_uom {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FISCAL_RATINGS_UOM}
 * @param p_vehicle_provider {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_PROVIDER}
 * @param p_vehicle_ownership {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_OWNERSHIP}
 * @param p_shared_vehicle {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.SHARED_VEHICLE}
 * @param p_asset_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ASSET_NUMBER}
 * @param p_lease_contract_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LEASE_CONTRACT_NUMBER}
 * @param p_lease_contract_expiry_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LEASE_CONTRACT_EXPIRY_DATE}
 * @param p_taxation_method {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.TAXATION_METHOD}
 * @param p_fleet_info {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.FLEET_INFO}
 * @param p_fleet_transfer_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FLEET_TRANSFER_DATE}
 * @param p_color The color of the vehicle. The value is from the lookkup
 * PQP_VEHICLE_COLOR.
 * @param p_seating_capacity The passenger seating capacity for the vehicle.
 * @param p_weight The weight of the vehicle, the unit of measure is stored in
 * weight_uom column.
 * @param p_weight_uom The unit of measure for the weight column. The value is
 * from the lookup PQP_WEIGHT_UOM.
 * @param p_model_year The model year for the vehicle.
 * @param p_insurance_number The insurance details for the vehicle.
 * @param p_insurance_expiry_date Insurance expiration date for the vehicle.
 * @param p_comments Free text to store any comments.
 * @param p_vre_attribute_category {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE_CATEGORY}
 * @param p_vre_attribute1 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE1}
 * @param p_vre_attribute2 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE2}
 * @param p_vre_attribute3 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE3}
 * @param p_vre_attribute4 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE4}
 * @param p_vre_attribute5 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE5}
 * @param p_vre_attribute6 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE6}
 * @param p_vre_attribute7 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE7}
 * @param p_vre_attribute8 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE8}
 * @param p_vre_attribute9 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE9}
 * @param p_vre_attribute10 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE10}
 * @param p_vre_attribute11 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE11}
 * @param p_vre_attribute12 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE12}
 * @param p_vre_attribute13 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE13}
 * @param p_vre_attribute14 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE14}
 * @param p_vre_attribute15 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE15}
 * @param p_vre_attribute16 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE16}
 * @param p_vre_attribute17 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE17}
 * @param p_vre_attribute18 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE18}
 * @param p_vre_attribute19 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE19}
 * @param p_vre_attribute20 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE20}
 * @param p_vre_information_category {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION_CATEGORY}
 * @param p_vre_information1 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION1}
 * @param p_vre_information2 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION2}
 * @param p_vre_information3 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION3}
 * @param p_vre_information4 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION4}
 * @param p_vre_information5 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION5}
 * @param p_vre_information6 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION6}
 * @param p_vre_information7 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION7}
 * @param p_vre_information8 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION8}
 * @param p_vre_information9 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION9}
 * @param p_vre_information10 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION10}
 * @param p_vre_information11 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION11}
 * @param p_vre_information12 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION12}
 * @param p_vre_information13 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION13}
 * @param p_vre_information14 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION14}
 * @param p_vre_information15 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION15}
 * @param p_vre_information16 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION16}
 * @param p_vre_information17 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION17}
 * @param p_vre_information18 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION18}
 * @param p_vre_information19 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION19}
 * @param p_vre_information20 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION20}
 * @param p_vehicle_repository_id {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_REPOSITORY_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Vehicle Repository. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Vehicle Repository. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the createdVehicle Repository. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Vehicle Repository
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_vehicle
  (p_validate                       in     boolean default false
  ,p_effective_date                 in     date
  ,p_registration_number            in     varchar2 default null
  ,p_vehicle_type                   in     varchar2
  ,p_vehicle_id_number              in     varchar2 default null
  ,p_business_group_id              in     number
  ,p_make                           in     varchar2
  ,p_engine_capacity_in_cc          in     number   default null
  ,p_fuel_type                      in     varchar2 default null
  ,p_currency_code                  in     varchar2 default null
  ,p_vehicle_status                 in     varchar2 default 'A'
  ,p_vehicle_inactivity_reason      in     varchar2 default null
  ,p_model                          in     varchar2
  ,p_initial_registration           in     date     default null
  ,p_last_registration_renew_date   in     date     default null
  ,p_list_price                     in     number   default null
  ,p_accessory_value_at_startdate   in     number   default null
  ,p_accessory_value_added_later    in     number   default null
  ,p_market_value_classic_car       in     number   default null
  ,p_fiscal_ratings                 in     number   default null
  ,p_fiscal_ratings_uom             in     varchar2 default null
  ,p_vehicle_provider               in     varchar2 default null
  ,p_vehicle_ownership              in     varchar2 default null
  ,p_shared_vehicle                 in     varchar2 default null
  ,p_asset_number                   in     varchar2 default null
  ,p_lease_contract_number          in     varchar2 default null
  ,p_lease_contract_expiry_date     in     date     default null
  ,p_taxation_method                in     varchar2 default null
  ,p_fleet_info                     in     varchar2 default null
  ,p_fleet_transfer_date            in     date     default null
  ,p_color                          in     varchar2 default null
  ,p_seating_capacity               in     number   default null
  ,p_weight                         in     number   default null
  ,p_weight_uom                     in     varchar2 default null
  ,p_model_year                     in     number   default null
  ,p_insurance_number               in     varchar2 default null
  ,p_insurance_expiry_date          in     date     default null
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
  ,p_vre_information1               in     varchar2 default null
  ,p_vre_information2               in     varchar2 default null
  ,p_vre_information3               in     varchar2 default null
  ,p_vre_information4               in     varchar2 default null
  ,p_vre_information5               in     varchar2 default null
  ,p_vre_information6               in     varchar2 default null
  ,p_vre_information7               in     varchar2 default null
  ,p_vre_information8               in     varchar2 default null
  ,p_vre_information9               in     varchar2 default null
  ,p_vre_information10              in     varchar2 default null
  ,p_vre_information11              in     varchar2 default null
  ,p_vre_information12              in     varchar2 default null
  ,p_vre_information13              in     varchar2 default null
  ,p_vre_information14              in     varchar2 default null
  ,p_vre_information15              in     varchar2 default null
  ,p_vre_information16              in     varchar2 default null
  ,p_vre_information17              in     varchar2 default null
  ,p_vre_information18              in     varchar2 default null
  ,p_vre_information19              in     varchar2 default null
  ,p_vre_information20              in     varchar2 default null
  ,p_vehicle_repository_id          out    NOCOPY number
  ,p_object_version_number          out    NOCOPY number
  ,p_effective_start_date           out    NOCOPY date
  ,p_effective_end_date             out    NOCOPY date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates vehicle repository records.
 *
 * This API updates a vehicle in the repository. All attributes may not be
 * changed if the vehicle is already allocated to an assignment.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_vehicle_repository_id {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_REPOSITORY_ID}
 * @param p_object_version_number Pass in the current version number of the
 * vehicle repository to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Vehicle
 * Repository. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_registration_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.REGISTRATION_NUMBER}
 * @param p_vehicle_type {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_TYPE}
 * @param p_vehicle_id_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_ID_NUMBER}
 * @param p_business_group_id {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.BUSINESS_GROUP_ID}
 * @param p_make {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.MAKE}
 * @param p_engine_capacity_in_cc {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ENGINE_CAPACITY_IN_CC}
 * @param p_fuel_type {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.FUEL_TYPE}
 * @param p_currency_code {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.CURRENCY_CODE}
 * @param p_vehicle_status {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_STATUS}
 * @param p_vehicle_inactivity_reason {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_INACTIVITY_REASON}
 * @param p_model {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.MODEL}
 * @param p_initial_registration {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.INITIAL_REGISTRATION}
 * @param p_last_registration_renew_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LAST_REGISTRATION_RENEW_DATE}
 * @param p_list_price {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.LIST_PRICE}
 * @param p_accessory_value_at_startdate {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ACCESSORY_VALUE_AT_STARTDATE}
 * @param p_accessory_value_added_later {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ACCESSORY_VALUE_ADDED_LATER}
 * @param p_market_value_classic_car {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.MARKET_VALUE_CLASSIC_CAR}
 * @param p_fiscal_ratings {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FISCAL_RATINGS}
 * @param p_fiscal_ratings_uom {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FISCAL_RATINGS_UOM}
 * @param p_vehicle_provider {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_PROVIDER}
 * @param p_vehicle_ownership {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_OWNERSHIP}
 * @param p_shared_vehicle {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.SHARED_VEHICLE}
 * @param p_asset_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.ASSET_NUMBER}
 * @param p_lease_contract_number {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LEASE_CONTRACT_NUMBER}
 * @param p_lease_contract_expiry_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.LEASE_CONTRACT_EXPIRY_DATE}
 * @param p_taxation_method {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.TAXATION_METHOD}
 * @param p_fleet_info {@rep:casecolumn PQP_VEHICLE_REPOSITORY_F.FLEET_INFO}
 * @param p_fleet_transfer_date {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.FLEET_TRANSFER_DATE}
 * @param p_color The color of the vehicle. The value is from the lookkup
 * PQP_VEHICLE_COLOR.
 * @param p_seating_capacity The passenger seating capacity for the vehicle.
 * @param p_weight The weight of the vehicle, the unit of measure is stored in
 * weight_uom column.
 * @param p_weight_uom The unit of measure for the weight column. The value is
 * from the lookup PQP_WEIGHT_UOM.
 * @param p_model_year The model year for the vehicle.
 * @param p_insurance_number The insurance details for the vehicle.
 * @param p_insurance_expiry_date Insurance expiration date for the vehicle.
 * @param p_comments Free text to store any comments.
 * @param p_vre_attribute_category {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE_CATEGORY}
 * @param p_vre_attribute1 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE1}
 * @param p_vre_attribute2 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE2}
 * @param p_vre_attribute3 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE3}
 * @param p_vre_attribute4 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE4}
 * @param p_vre_attribute5 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE5}
 * @param p_vre_attribute6 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE6}
 * @param p_vre_attribute7 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE7}
 * @param p_vre_attribute8 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE8}
 * @param p_vre_attribute9 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE9}
 * @param p_vre_attribute10 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE10}
 * @param p_vre_attribute11 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE11}
 * @param p_vre_attribute12 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE12}
 * @param p_vre_attribute13 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE13}
 * @param p_vre_attribute14 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE14}
 * @param p_vre_attribute15 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE15}
 * @param p_vre_attribute16 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE16}
 * @param p_vre_attribute17 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE17}
 * @param p_vre_attribute18 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE18}
 * @param p_vre_attribute19 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE19}
 * @param p_vre_attribute20 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_ATTRIBUTE20}
 * @param p_vre_information_category {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION_CATEGORY}
 * @param p_vre_information1 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION1}
 * @param p_vre_information2 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION2}
 * @param p_vre_information3 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION3}
 * @param p_vre_information4 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION4}
 * @param p_vre_information5 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION5}
 * @param p_vre_information6 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION6}
 * @param p_vre_information7 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION7}
 * @param p_vre_information8 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION8}
 * @param p_vre_information9 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION9}
 * @param p_vre_information10 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION10}
 * @param p_vre_information11 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION11}
 * @param p_vre_information12 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION12}
 * @param p_vre_information13 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION13}
 * @param p_vre_information14 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION14}
 * @param p_vre_information15 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION15}
 * @param p_vre_information16 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION16}
 * @param p_vre_information17 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION17}
 * @param p_vre_information18 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION18}
 * @param p_vre_information19 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION19}
 * @param p_vre_information20 {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VRE_INFORMATION20}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated vehicle repository row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated vehicle repository row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Vehicle Repository
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure update_vehicle
  (p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_registration_number          in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_type                 in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_id_number            in     varchar2  default hr_api.g_varchar2
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
  ,p_model_year                   in     number    default hr_api.g_number
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
  ,p_vre_information1             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information2             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information3             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information4             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information5             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information6             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information7             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information8             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information9             in     varchar2  default hr_api.g_varchar2
  ,p_vre_information10            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information11            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information12            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information13            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information14            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information15            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information16            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information17            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information18            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information19            in     varchar2  default hr_api.g_varchar2
  ,p_vre_information20            in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    NOCOPY date
  ,p_effective_end_date           out    NOCOPY date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a vehicle in the repository.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Vehicle repository record should be present before deleting a vehicle
 * repository and the vehicle should not be allocated for an assignment.
 *
 * <p><b>Post Success</b><br>
 * The vehicle repository record will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The vehicle repository record will not be deleted and an error will be
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
 * @param p_vehicle_repository_id {@rep:casecolumn
 * PQP_VEHICLE_REPOSITORY_F.VEHICLE_REPOSITORY_ID}
 * @param p_object_version_number Current version number of the vehicle
 * allocation to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted vehicle repository row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted vehicle repository. If p_validate is
 * true, then set to null.
 * @rep:displayname Delete Vehicle Repository
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_vehicle
  (p_validate                         in     boolean default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_vehicle_repository_id            in     number
  ,p_object_version_number            in out NOCOPY number
  ,p_effective_start_date             out    NOCOPY date
  ,p_effective_end_date               out    NOCOPY date
  );

end PQP_VEHICLE_REPOSITORY_API;

 

/
