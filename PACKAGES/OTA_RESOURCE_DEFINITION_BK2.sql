--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_DEFINITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_DEFINITION_BK2" AUTHID CURRENT_USER as
/* $Header: ottsrapi.pkh 120.3 2006/08/04 10:43:59 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_RESOURCE_DEFINITION_BK2.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_RESOURCE_DEFINITION_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Update_RESOURCE_DEFINITION_b
  ( p_supplied_resource_id          in number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2
  ,p_object_version_number        in  number
  ,p_resource_type                in varchar2
  ,p_start_date                   in date
  ,p_comments                     in varchar2
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2
  ,p_currency_code                in varchar2
  ,p_end_date                     in date
  ,p_internal_address_line        in varchar2
  ,p_lead_time                    in number
  ,p_name                         in varchar2
  ,p_supplier_reference           in varchar2
  ,p_tsr_information_category     in varchar2
  ,p_tsr_information1             in varchar2
  ,p_tsr_information2             in varchar2
  ,p_tsr_information3             in varchar2
  ,p_tsr_information4             in varchar2
  ,p_tsr_information5             in varchar2
  ,p_tsr_information6             in varchar2
  ,p_tsr_information7             in varchar2
  ,p_tsr_information8             in varchar2
  ,p_tsr_information9             in varchar2
  ,p_tsr_information10            in varchar2
  ,p_tsr_information11            in varchar2
  ,p_tsr_information12            in varchar2
  ,p_tsr_information13            in varchar2
  ,p_tsr_information14            in varchar2
  ,p_tsr_information15            in varchar2
  ,p_tsr_information16            in varchar2
  ,p_tsr_information17            in varchar2
  ,p_tsr_information18            in varchar2
  ,p_tsr_information19            in varchar2
  ,p_tsr_information20            in varchar2
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2
  ,p_effective_date               in date
  ,p_data_source                  in varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_RESOURCE_DEFINITION_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure UPDATE_RESOURCE_DEFINITION_A
  ( p_supplied_resource_id          in number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2
  ,p_object_version_number        in  number
  ,p_resource_type                in varchar2
  ,p_start_date                   in date
  ,p_comments                     in varchar2
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2
  ,p_currency_code                in varchar2
  ,p_end_date                     in date
  ,p_internal_address_line        in varchar2
  ,p_lead_time                    in number
  ,p_name                         in varchar2
  ,p_supplier_reference           in varchar2
  ,p_tsr_information_category     in varchar2
  ,p_tsr_information1             in varchar2
  ,p_tsr_information2             in varchar2
  ,p_tsr_information3             in varchar2
  ,p_tsr_information4             in varchar2
  ,p_tsr_information5             in varchar2
  ,p_tsr_information6             in varchar2
  ,p_tsr_information7             in varchar2
  ,p_tsr_information8             in varchar2
  ,p_tsr_information9             in varchar2
  ,p_tsr_information10            in varchar2
  ,p_tsr_information11            in varchar2
  ,p_tsr_information12            in varchar2
  ,p_tsr_information13            in varchar2
  ,p_tsr_information14            in varchar2
  ,p_tsr_information15            in varchar2
  ,p_tsr_information16            in varchar2
  ,p_tsr_information17            in varchar2
  ,p_tsr_information18            in varchar2
  ,p_tsr_information19            in varchar2
  ,p_tsr_information20            in varchar2
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2
  ,p_effective_date               in date
  ,p_data_source                  in varchar2
  );

end OTA_RESOURCE_DEFINITION_BK2;

 

/
