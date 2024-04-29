--------------------------------------------------------
--  DDL for Package OTA_TRB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRB_RKD" AUTHID CURRENT_USER as
/* $Header: ottrbrhi.pkh 120.3.12000000.1 2007/01/18 05:24:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_resource_booking_id          in number
  ,p_supplied_resource_id_o       in number
  ,p_event_id_o                   in number
  ,p_date_booking_placed_o        in date
  ,p_object_version_number_o      in number
  ,p_status_o                     in varchar2
  ,p_absolute_price_o             in number
  ,p_booking_person_id_o          in number
  ,p_comments_o                   in varchar2
  ,p_contact_name_o               in varchar2
  ,p_contact_phone_number_o       in varchar2
  ,p_delegates_per_unit_o         in number
  ,p_quantity_o                   in number
  ,p_required_date_from_o         in date
  ,p_required_date_to_o           in date
  ,p_required_end_time_o          in varchar2
  ,p_required_start_time_o        in varchar2
  ,p_deliver_to_o                 in varchar2
  ,p_primary_venue_flag_o         in varchar2
  ,p_role_to_play_o               in varchar2
  ,p_trb_information_category_o   in varchar2
  ,p_trb_information1_o           in varchar2
  ,p_trb_information2_o           in varchar2
  ,p_trb_information3_o           in varchar2
  ,p_trb_information4_o           in varchar2
  ,p_trb_information5_o           in varchar2
  ,p_trb_information6_o           in varchar2
  ,p_trb_information7_o           in varchar2
  ,p_trb_information8_o           in varchar2
  ,p_trb_information9_o           in varchar2
  ,p_trb_information10_o          in varchar2
  ,p_trb_information11_o          in varchar2
  ,p_trb_information12_o          in varchar2
  ,p_trb_information13_o          in varchar2
  ,p_trb_information14_o          in varchar2
  ,p_trb_information15_o          in varchar2
  ,p_trb_information16_o          in varchar2
  ,p_trb_information17_o          in varchar2
  ,p_trb_information18_o          in varchar2
  ,p_trb_information19_o          in varchar2
  ,p_trb_information20_o          in varchar2
  ,p_display_to_learner_flag_o      in     varchar2
  ,p_book_entire_period_flag_o    in     varchar2
--  ,p_unbook_request_flag_o    in     varchar2
  ,p_chat_id_o                    in number
  ,p_forum_id_o                   in number
  ,p_timezone_code_o              IN VARCHAR2
  );
--
end ota_trb_rkd;

 

/
