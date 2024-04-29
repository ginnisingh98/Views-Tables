--------------------------------------------------------
--  DDL for Package OTA_OFF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFF_RKU" AUTHID CURRENT_USER as
/* $Header: otoffrhi.pkh 120.1 2007/02/06 15:24:40 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_offering_id                  in number
  ,p_activity_version_id          in number
  ,p_business_group_id            in number
   ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_owner_id                     in number
  ,p_delivery_mode_id             in number
  ,p_language_id                  in number
  ,p_duration                     in number
  ,p_duration_units               in varchar2
  ,p_learning_object_id           in number
  ,p_player_toolbar_flag          in varchar2
  ,p_player_toolbar_bitset        in number
  ,p_player_new_window_flag       in varchar2
  ,p_maximum_attendees            in number
  ,p_maximum_internal_attendees   in number
  ,p_minimum_attendees            in number
  ,p_actual_cost                  in number
  ,p_budget_cost                  in number
  ,p_budget_currency_code         in varchar2
  ,p_price_basis                  in varchar2
  ,p_currency_code                in varchar2
  ,p_standard_price               in number
  ,p_object_version_number        in number
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_data_source                  in varchar2
  ,p_vendor_id                    in number
  ,p_competency_update_level      in     varchar2
  ,p_activity_version_id_o        in number
  ,p_business_group_id_o          in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_owner_id_o                   in number
  ,p_delivery_mode_id_o           in number
  ,p_language_id_o                in number
  ,p_duration_o                   in number
  ,p_duration_units_o             in varchar2
  ,p_learning_object_id_o         in number
  ,p_player_toolbar_flag_o        in varchar2
  ,p_player_toolbar_bitset_o      in number
  ,p_player_new_window_flag_o     in varchar2
  ,p_maximum_attendees_o          in number
  ,p_maximum_internal_attendees_o in number
  ,p_minimum_attendees_o          in number
  ,p_actual_cost_o                in number
  ,p_budget_cost_o                in number
  ,p_budget_currency_code_o       in varchar2
  ,p_price_basis_o                in varchar2
  ,p_currency_code_o              in varchar2
  ,p_standard_price_o             in number
  ,p_object_version_number_o      in number
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_data_source_o                in varchar2
  ,p_vendor_id_o                  in number
  ,p_competency_update_level_o      in     varchar2
  ,p_language_code                 in     varchar2  -- 2733966
  );
--
end ota_off_rku;

/
