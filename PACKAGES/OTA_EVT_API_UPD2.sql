--------------------------------------------------------
--  DDL for Package OTA_EVT_API_UPD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVT_API_UPD2" AUTHID CURRENT_USER as
/* $Header: otevt02t.pkh 120.1 2007/11/21 13:42:02 shwnayak noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE EVENT >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Updates an Event.
--
-- Access Status:
--   Public.
--
procedure update_event
  (
  p_event			 in varchar2,
  p_event_id                     in number,
  p_object_version_number        in out nocopy number,
  p_event_status                 in out nocopy varchar2,
  p_validate                     in boolean default false,
  p_reset_max_attendees		 in boolean default false,
  p_update_finance_line		 in varchar2 default 'N',
  p_booking_status_type_id	 in number default null,
  p_date_status_changed 	 in date default null,
  p_maximum_attendees		 in number default null);
--
end ota_evt_api_upd2;

/
