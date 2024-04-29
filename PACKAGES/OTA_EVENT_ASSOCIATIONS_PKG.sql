--------------------------------------------------------
--  DDL for Package OTA_EVENT_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVENT_ASSOCIATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: ottea02t.pkh 115.2 2002/11/29 10:05:52 arkashya ship $ */

procedure maintain_delegate_bookings
(
 p_validate			in boolean
,p_price_basis                  in varchar2
,p_business_group_id            in number
,p_event_id                     in number
,p_customer_id                  in number
,p_booking_id			in out nocopy number
,p_tdb_object_version_number 	in out nocopy number
,p_booking_status_type_id	in number
,p_date_status_changed          in date
,p_status_change_comments       in varchar2
,p_booking_contact_id		in number
,p_contact_address_id           in number
,p_delegate_contact_phone       in varchar2
,p_delegate_contact_fax         in varchar2
,p_internal_booking_flag	in varchar2
,p_source_of_booking		in varchar2
,p_number_of_places		in number
,p_date_booking_placed		in date
,p_update_finance_line          in varchar2
,p_tfl_object_version_number    in out nocopy number
,p_finance_header_id		in number
,p_currency_code                in varchar2
,p_standard_amount		in number
,p_unitary_amount		in number
,p_money_amount			in number
,p_booking_deal_id		in number
,p_booking_deal_type		in varchar2
,p_finance_line_id		in out nocopy number
,p_delegate_contact_email     in varchar2
);

end ota_event_associations_pkg;

 

/
