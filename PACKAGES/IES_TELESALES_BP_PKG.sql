--------------------------------------------------------
--  DDL for Package IES_TELESALES_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TELESALES_BP_PKG" AUTHID CURRENT_USER AS
/* $Header: iestsbps.pls 120.1 2005/06/16 11:16:43 appldev  $ */
procedure create_sales_lead(
 p_api_version number,
 p_user_name varchar2,
 p_customer_id number,
 p_contact_id number,
 p_project_name varchar2,
 p_channel_code varchar2,
 p_budget_amount number,
 p_budget_status_code varchar2,
 p_currency_code varchar2,
 p_decision_timeframe_code varchar2,
 p_description varchar2,
 p_source_promotion_id number,
 p_status_code varchar2,
 p_interest_type_id number,
 p_primary_interest_code_id number,
 p_secondary_interest_code_id number default FND_API.G_MISS_NUM,
 x_sales_lead_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2
);


PROCEDURE CREATE_INTEREST(
 p_api_version number,
 p_user_name varchar2,
 p_party_type varchar2,
 p_party_id number,
 p_party_site_id number,
 p_contact_id number,
 p_interest_type_id number,
 p_primary_interest_code_id number,
 p_secondary_interest_code_id number,
 x_interest_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2
);

procedure create_opp_for_lead(
 p_api_version number,
 p_user_name varchar2,
 p_sales_lead_id number,
 x_opp_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2);


procedure submit_collateral_to_fm(
p_api_version number,
p_deliverable_id number,
p_email	varchar2,
p_subject varchar2,
p_party_id number,
p_user_name varchar2,
p_user_note varchar2,
x_request_id OUT NOCOPY /* file.sql.39 change */ number,
x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2);


procedure register_for_event(p_api_version number,
p_source_code varchar2,
p_event_offer_id number,
p_registrant_party_id number,
p_registrant_contact_id number,
p_attendant_party_id number,
p_attendant_contact_id number,
p_user_name varchar2,
p_application_id number,
x_event_registration_id OUT NOCOPY /* file.sql.39 change */ number,
x_confirmation_code OUT NOCOPY /* file.sql.39 change */ varchar2,
x_system_status_code  OUT NOCOPY /* file.sql.39 change */ varchar2,
x_return_status  OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data  OUT NOCOPY /* file.sql.39 change */ varchar2);

END IES_TELESALES_BP_PKG;

 

/
