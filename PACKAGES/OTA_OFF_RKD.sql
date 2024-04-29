--------------------------------------------------------
--  DDL for Package OTA_OFF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFF_RKD" AUTHID CURRENT_USER as
/* $Header: otoffrhi.pkh 120.1 2007/02/06 15:24:40 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_offering_id                  in number
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
  ,p_language_code                in varchar2
  );
--
end ota_off_rkd;

/
