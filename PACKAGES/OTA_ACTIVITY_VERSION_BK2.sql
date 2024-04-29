--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_VERSION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_VERSION_BK2" AUTHID CURRENT_USER as
/* $Header: ottavapi.pkh 120.4.12010000.2 2009/08/11 13:01:11 smahanka ship $ */
-- ----------------------------------------------------------------------------
-- |----------------< update_activity_version_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_activity_version_b
  (p_effective_date               in date,
  p_activity_id                  in number,
  p_superseded_by_act_version_id in number,
  p_developer_organization_id    in number,
  p_object_version_number         in     number,
  p_controlling_person_id        in number,
  p_version_name                 in varchar2,
  p_comments                     in varchar2,
  p_description                  in varchar2,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_end_date                     in date    ,
  p_intended_audience            in varchar2,
  p_language_id                  in number  ,
  p_maximum_attendees            in number  ,
  p_minimum_attendees            in number  ,
  p_objectives                   in varchar2,
  p_start_date                   in date    ,
  p_success_criteria             in varchar2,
  p_user_status                  in varchar2,
  p_vendor_id                    in number  ,
  p_actual_cost                  in number  ,
  p_budget_cost                  in number  ,
  p_budget_currency_code         in varchar2,
  p_expenses_allowed             in varchar2,
  p_professional_credit_type     in varchar2,
  p_professional_credits         in number  ,
  p_maximum_internal_attendees   in number  ,
  p_tav_information_category     in varchar2,
  p_tav_information1             in varchar2,
  p_tav_information2             in varchar2,
  p_tav_information3             in varchar2,
  p_tav_information4             in varchar2,
  p_tav_information5             in varchar2,
  p_tav_information6             in varchar2,
  p_tav_information7             in varchar2,
  p_tav_information8             in varchar2,
  p_tav_information9             in varchar2,
  p_tav_information10            in varchar2,
  p_tav_information11            in varchar2,
  p_tav_information12            in varchar2,
  p_tav_information13            in varchar2,
  p_tav_information14            in varchar2,
  p_tav_information15            in varchar2,
  p_tav_information16            in varchar2,
  p_tav_information17            in varchar2,
  p_tav_information18            in varchar2,
  p_tav_information19            in varchar2,
  p_tav_information20            in varchar2,
  p_inventory_item_id 		 in number,
  p_organization_id		 in number,
  p_rco_id		         in number,
  p_version_code                 in varchar2,
  p_business_group_id            in number,
  p_data_source                  in varchar2,
  p_activity_version_id          in number
  ,p_competency_update_level        in     varchar2

  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_activity_version_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_activity_version_a
  (p_effective_date               in date,
  p_activity_id                  in number,
  p_object_version_number         in     number,
  p_superseded_by_act_version_id in number,
  p_developer_organization_id    in number,
  p_controlling_person_id        in number,
  p_version_name                 in varchar2,
  p_comments                     in varchar2,
  p_description                  in varchar2,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_end_date                     in date    ,
  p_intended_audience            in varchar2,
  p_language_id                  in number  ,
  p_maximum_attendees            in number  ,
  p_minimum_attendees            in number  ,
  p_objectives                   in varchar2,
  p_start_date                   in date    ,
  p_success_criteria             in varchar2,
  p_user_status                  in varchar2,
  p_vendor_id                    in number  ,
  p_actual_cost                  in number  ,
  p_budget_cost                  in number  ,
  p_budget_currency_code         in varchar2,
  p_expenses_allowed             in varchar2,
  p_professional_credit_type     in varchar2,
  p_professional_credits         in number  ,
  p_maximum_internal_attendees   in number  ,
  p_tav_information_category     in varchar2,
  p_tav_information1             in varchar2,
  p_tav_information2             in varchar2,
  p_tav_information3             in varchar2,
  p_tav_information4             in varchar2,
  p_tav_information5             in varchar2,
  p_tav_information6             in varchar2,
  p_tav_information7             in varchar2,
  p_tav_information8             in varchar2,
  p_tav_information9             in varchar2,
  p_tav_information10            in varchar2,
  p_tav_information11            in varchar2,
  p_tav_information12            in varchar2,
  p_tav_information13            in varchar2,
  p_tav_information14            in varchar2,
  p_tav_information15            in varchar2,
  p_tav_information16            in varchar2,
  p_tav_information17            in varchar2,
  p_tav_information18            in varchar2,
  p_tav_information19            in varchar2,
  p_tav_information20            in varchar2,
  p_inventory_item_id 		 in number,
  p_organization_id		 in number,
  p_rco_id		         in number,
  p_version_code                 in varchar2,
  p_business_group_id            in number,
  p_data_source                  in varchar2,
  p_activity_version_id          in number
  ,p_competency_update_level        in     varchar2

  );

end ota_activity_version_bk2 ;

/
