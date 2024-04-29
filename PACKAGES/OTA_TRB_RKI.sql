--------------------------------------------------------
--  DDL for Package OTA_TRB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRB_RKI" AUTHID CURRENT_USER as
/* $Header: ottrbrhi.pkh 120.3.12000000.1 2007/01/18 05:24:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_resource_booking_id          in number
  ,p_supplied_resource_id         in number
  ,p_event_id                     in number
  ,p_date_booking_placed          in date
  ,p_object_version_number        in number
  ,p_status                       in varchar2
  ,p_absolute_price               in number
  ,p_booking_person_id            in number
  ,p_comments                     in varchar2
  ,p_contact_name                 in varchar2
  ,p_contact_phone_number         in varchar2
  ,p_delegates_per_unit           in number
  ,p_quantity                     in number
  ,p_required_date_from           in date
  ,p_required_date_to             in date
  ,p_required_end_time            in varchar2
  ,p_required_start_time          in varchar2
  ,p_deliver_to                   in varchar2
  ,p_primary_venue_flag           in varchar2
  ,p_role_to_play                 in varchar2
  ,p_trb_information_category     in varchar2
  ,p_trb_information1             in varchar2
  ,p_trb_information2             in varchar2
  ,p_trb_information3             in varchar2
  ,p_trb_information4             in varchar2
  ,p_trb_information5             in varchar2
  ,p_trb_information6             in varchar2
  ,p_trb_information7             in varchar2
  ,p_trb_information8             in varchar2
  ,p_trb_information9             in varchar2
  ,p_trb_information10            in varchar2
  ,p_trb_information11            in varchar2
  ,p_trb_information12            in varchar2
  ,p_trb_information13            in varchar2
  ,p_trb_information14            in varchar2
  ,p_trb_information15            in varchar2
  ,p_trb_information16            in varchar2
  ,p_trb_information17            in varchar2
  ,p_trb_information18            in varchar2
  ,p_trb_information19            in varchar2
  ,p_trb_information20            in varchar2
  ,p_display_to_learner_flag      in     varchar2
  ,p_book_entire_period_flag    in     varchar2
--  ,p_unbook_request_flag    in     varchar2
  ,p_chat_id                      in number
  ,p_forum_id                     in number
  ,p_timezone_code                IN VARCHAR2
  );
end ota_trb_rki;

 

/
