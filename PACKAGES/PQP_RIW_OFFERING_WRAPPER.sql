--------------------------------------------------------
--  DDL for Package PQP_RIW_OFFERING_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RIW_OFFERING_WRAPPER" AUTHID CURRENT_USER As
/* $Header: pqpriwofwr.pkh 120.0.12010000.3 2008/12/04 10:55:15 psengupt noship $ */

-- =============================================================================
-- InsUpd_Offering: This procedure is called by the web-adi spreadsheet
-- to create  an Offering in Oracle Learning Management from data
-- entered in the spreadsheet.
-- =============================================================================
PROCEDURE InsUpd_Offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_activity_version_id          in     number    default null
  ,p_end_date                     in     date      default null
  ,p_owner_id                     in     number    default null
  ,p_delivery_mode_id             in     number    default null
  ,p_language_id                  in     number    default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_learning_object_id           in     number    default null
  ,p_player_toolbar_flag          in     varchar2  default null
  ,p_player_exit_flag		  in     varchar2  default null
  ,p_player_next_flag		  in     varchar2  default null
  ,p_player_previous_flag	  in     varchar2  default null
  ,p_player_outline_flag	  in	 varchar2  default null
  ,p_player_new_window_flag       in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_price               in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_offering_id                  in     number    default null
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                   in     varchar2  default null
  ,p_vendor_id                     in     number  default null
  ,p_description                  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  );

end pqp_riw_offering_wrapper;



/
