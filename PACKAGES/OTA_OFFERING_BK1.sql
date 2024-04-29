--------------------------------------------------------
--  DDL for Package OTA_OFFERING_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFFERING_BK1" AUTHID CURRENT_USER as
/* $Header: otoffapi.pkh 120.4.12010000.2 2008/08/05 11:45:04 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_offering_bk1.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_OFFERING_B >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Create_offering_b
  (  p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_start_date                     in     date
  ,p_activity_version_id            in     number
  ,p_end_date                       in     date
  ,p_owner_id                       in     number
  ,p_delivery_mode_id               in     number
  ,p_language_id                    in     number
  ,p_duration                       in     number
  ,p_duration_units                 in     varchar2
  ,p_learning_object_id             in     number
  ,p_player_toolbar_flag            in     varchar2
  ,p_player_toolbar_bitset          in     number
  ,p_player_new_window_flag         in     varchar2
  ,p_maximum_attendees              in     number
  ,p_maximum_internal_attendees     in     number
  ,p_minimum_attendees              in     number
  ,p_actual_cost                    in     number
  ,p_budget_cost                    in     number
  ,p_budget_currency_code           in     varchar2
  ,p_price_basis                    in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_standard_price                 in     number
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_data_source                    in     varchar2
  ,p_vendor_id                      in     number
  ,p_description		  in     varchar2
  ,p_competency_update_level      in     varchar2
  ,p_language_code                in     varchar2   -- 2733966
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_OFFERING_A >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Create_Offering_a
  (  p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_start_date                     in     date
  ,p_activity_version_id            in     number
  ,p_end_date                       in     date
  ,p_owner_id                       in     number
  ,p_delivery_mode_id               in     number
  ,p_language_id                    in     number
  ,p_duration                       in     number
  ,p_duration_units                 in     varchar2
  ,p_learning_object_id             in     number
  ,p_player_toolbar_flag            in     varchar2
  ,p_player_toolbar_bitset          in     number
  ,p_player_new_window_flag         in     varchar2
  ,p_maximum_attendees              in     number
  ,p_maximum_internal_attendees     in     number
  ,p_minimum_attendees              in     number
  ,p_actual_cost                    in     number
  ,p_budget_cost                    in     number
  ,p_budget_currency_code           in     varchar2
  ,p_price_basis                    in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_standard_price                 in     number
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_offering_id                       in  number
  ,p_object_version_number             in   number
  ,p_data_source                    in     varchar2
  ,p_vendor_id                      in     number
  ,p_description		  in     varchar2
  ,p_competency_update_level      in     varchar2
  ,p_language_code                in     varchar2   -- 2733966
  );



end ota_offering_bk1;

/
