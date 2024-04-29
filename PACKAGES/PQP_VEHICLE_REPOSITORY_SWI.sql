--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_REPOSITORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_REPOSITORY_SWI" AUTHID CURRENT_USER As
/* $Header: pqvreswi.pkh 120.0 2005/05/29 02:18:56 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_vehicle_repository_api.create_vehicle
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_vehicle
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_registration_number          in     varchar2  default null
  ,p_vehicle_type                 in     varchar2
  ,p_vehicle_id_number            in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_make                         in     varchar2
  ,p_engine_capacity_in_cc        in     number    default null
  ,p_fuel_type                    in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_vehicle_status               in     varchar2  default 'A'
  ,p_vehicle_inactivity_reason    in     varchar2  default null
  ,p_model                        in     varchar2
  ,p_initial_registration         in     date      default null
  ,p_last_registration_renew_date in     date      default null
  ,p_list_price                   in     number    default null
  ,p_accessory_value_at_startdate in     number    default null
  ,p_accessory_value_added_later  in     number    default null
  ,p_market_value_classic_car     in     number    default null
  ,p_fiscal_ratings               in     number    default null
  ,p_fiscal_ratings_uom           in     varchar2  default null
  ,p_vehicle_provider             in     varchar2  default null
  ,p_vehicle_ownership            in     varchar2  default null
  ,p_shared_vehicle               in     varchar2  default null
  ,p_asset_number                 in     varchar2  default null
  ,p_lease_contract_number        in     varchar2  default null
  ,p_lease_contract_expiry_date   in     date      default null
  ,p_taxation_method              in     varchar2  default null
  ,p_fleet_info                   in     varchar2  default null
  ,p_fleet_transfer_date          in     date      default null
  ,p_color                        in     varchar2  default null
  ,p_seating_capacity             in     number    default null
  ,p_weight                       in     number    default null
  ,p_weight_uom                   in     varchar2  default null
  ,p_model_year                   in     number    default null
  ,p_insurance_number             in     varchar2  default null
  ,p_insurance_expiry_date        in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_vre_attribute_category       in     varchar2  default null
  ,p_vre_attribute1               in     varchar2  default null
  ,p_vre_attribute2               in     varchar2  default null
  ,p_vre_attribute3               in     varchar2  default null
  ,p_vre_attribute4               in     varchar2  default null
  ,p_vre_attribute5               in     varchar2  default null
  ,p_vre_attribute6               in     varchar2  default null
  ,p_vre_attribute7               in     varchar2  default null
  ,p_vre_attribute8               in     varchar2  default null
  ,p_vre_attribute9               in     varchar2  default null
  ,p_vre_attribute10              in     varchar2  default null
  ,p_vre_attribute11              in     varchar2  default null
  ,p_vre_attribute12              in     varchar2  default null
  ,p_vre_attribute13              in     varchar2  default null
  ,p_vre_attribute14              in     varchar2  default null
  ,p_vre_attribute15              in     varchar2  default null
  ,p_vre_attribute16              in     varchar2  default null
  ,p_vre_attribute17              in     varchar2  default null
  ,p_vre_attribute18              in     varchar2  default null
  ,p_vre_attribute19              in     varchar2  default null
  ,p_vre_attribute20              in     varchar2  default null
  ,p_vre_information_category     in     varchar2  default null
  ,p_vre_information1             in     varchar2  default null
  ,p_vre_information2             in     varchar2  default null
  ,p_vre_information3             in     varchar2  default null
  ,p_vre_information4             in     varchar2  default null
  ,p_vre_information5             in     varchar2  default null
  ,p_vre_information6             in     varchar2  default null
  ,p_vre_information7             in     varchar2  default null
  ,p_vre_information8             in     varchar2  default null
  ,p_vre_information9             in     varchar2  default null
  ,p_vre_information10            in     varchar2  default null
  ,p_vre_information11            in     varchar2  default null
  ,p_vre_information12            in     varchar2  default null
  ,p_vre_information13            in     varchar2  default null
  ,p_vre_information14            in     varchar2  default null
  ,p_vre_information15            in     varchar2  default null
  ,p_vre_information16            in     varchar2  default null
  ,p_vre_information17            in     varchar2  default null
  ,p_vre_information18            in     varchar2  default null
  ,p_vre_information19            in     varchar2  default null
  ,p_vre_information20            in     varchar2  default null
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_vehicle_repository_api.delete_vehicle
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_vehicle
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_vehicle_repository_api.update_vehicle
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_vehicle
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out nocopy number
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
  ,p_asset_number                 in     varchar2  default hr_api.g_number
  ,p_lease_contract_number        in     varchar2  default hr_api.g_number
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
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
end pqp_vehicle_repository_swi;

 

/
