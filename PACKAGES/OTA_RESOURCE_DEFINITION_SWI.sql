--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_DEFINITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_DEFINITION_SWI" AUTHID CURRENT_USER As
/* $Header: ottsrswi.pkh 120.0 2005/05/29 07:56 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_definition_api.create_resource_definition
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
PROCEDURE create_resource_definition
  (p_supplied_resource_id         in     number
  ,p_vendor_id                    in     number
  ,p_business_group_id            in     number
  ,p_resource_definition_id       in     number
  ,p_consumable_flag              in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_resource_type                in     varchar2  default null
  ,p_start_date                   in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_cost                         in     number
  ,p_cost_unit                    in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_lead_time                    in     number
  ,p_name                         in     varchar2  default null
  ,p_supplier_reference           in     varchar2  default null
  ,p_tsr_information_category     in     varchar2  default null
  ,p_tsr_information1             in     varchar2  default null
  ,p_tsr_information2             in     varchar2  default null
  ,p_tsr_information3             in     varchar2  default null
  ,p_tsr_information4             in     varchar2  default null
  ,p_tsr_information5             in     varchar2  default null
  ,p_tsr_information6             in     varchar2  default null
  ,p_tsr_information7             in     varchar2  default null
  ,p_tsr_information8             in     varchar2  default null
  ,p_tsr_information9             in     varchar2  default null
  ,p_tsr_information10            in     varchar2  default null
  ,p_tsr_information11            in     varchar2  default null
  ,p_tsr_information12            in     varchar2  default null
  ,p_tsr_information13            in     varchar2  default null
  ,p_tsr_information14            in     varchar2  default null
  ,p_tsr_information15            in     varchar2  default null
  ,p_tsr_information16            in     varchar2  default null
  ,p_tsr_information17            in     varchar2  default null
  ,p_tsr_information18            in     varchar2  default null
  ,p_tsr_information19            in     varchar2  default null
  ,p_tsr_information20            in     varchar2  default null
  ,p_training_center_id           in     number
  ,p_location_id                  in     number
  ,p_trainer_id                   in     number
  ,p_special_instruction          in     varchar2  default null
  ,p_validate                     in     number
  ,p_effective_date               in     date
  ,p_data_source                  in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_definition_api.update_resource_definition
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
PROCEDURE update_resource_definition
  (p_supplied_resource_id         in     number
  ,p_vendor_id                    in     number
  ,p_business_group_id            in     number
  ,p_resource_definition_id       in     number
  ,p_consumable_flag              in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_resource_type                in     varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_comments                     in     varchar2
  ,p_cost                         in     number
  ,p_cost_unit                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_internal_address_line        in     varchar2
  ,p_lead_time                    in     number
  ,p_name                         in     varchar2
  ,p_supplier_reference           in     varchar2
  ,p_tsr_information_category     in     varchar2
  ,p_tsr_information1             in     varchar2
  ,p_tsr_information2             in     varchar2
  ,p_tsr_information3             in     varchar2
  ,p_tsr_information4             in     varchar2
  ,p_tsr_information5             in     varchar2
  ,p_tsr_information6             in     varchar2
  ,p_tsr_information7             in     varchar2
  ,p_tsr_information8             in     varchar2
  ,p_tsr_information9             in     varchar2
  ,p_tsr_information10            in     varchar2
  ,p_tsr_information11            in     varchar2
  ,p_tsr_information12            in     varchar2
  ,p_tsr_information13            in     varchar2
  ,p_tsr_information14            in     varchar2
  ,p_tsr_information15            in     varchar2
  ,p_tsr_information16            in     varchar2
  ,p_tsr_information17            in     varchar2
  ,p_tsr_information18            in     varchar2
  ,p_tsr_information19            in     varchar2
  ,p_tsr_information20            in     varchar2
  ,p_training_center_id           in     number
  ,p_location_id                  in     number
  ,p_trainer_id                   in     number
  ,p_special_instruction          in     varchar2
  ,p_validate                     in     number
  ,p_effective_date               in     date
  ,p_data_source                  in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_definition_api.delete_resource_definition
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
PROCEDURE delete_resource_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_supplied_resource_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_resource_definition_swi;

 

/
