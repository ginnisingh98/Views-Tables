--------------------------------------------------------
--  DDL for Package ICX_SR_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_SR_CUSTOM_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVSRS.pls 115.1 99/07/17 03:30:34 porting ship $ */


----------------------------------------------------------------------------
--   API name:		sr_default
--   Type:		private
--   Function:		Provides a mechanism for the customer to provide
--			 their own defaults for a service request
--   Pre-reqs:		none
--   Parameters:
--    In:		p_api_version		in number	Required
--			p_init_msg_list		in  varchar2 	Optional
--					default fnd_api.g_false
--			p_simulate		in  varchar2 	Optional
--					default fnd_api.g_false
--			p_commit		in  varchar2 	Optional
--					default fnd_api.g_false
--			p_validation_level	in  number   	Optional
--					default fnd_api.g_valid_level_full
--
--    Out:		p_return_status		out varchar2(1)
--			p_msg_count		out number
--			p_msg_data		out varchar2(2000)
--			p_customer_id		out number
--			p_customer_name		out varchar2(50)
--			p_cust_contact_id	out number
--			p_cust_contact_name	out varchar2(95)
--			p_cust_contact_area_code out varchar2(10)
--			p_cust_contact_phone	out varchar2(35)
--			p_cust_contact_extension out varchar2(10)
--			p_cust_contact_fax_area_code out varchar2(10)
--			p_cust_contact_fax	out varchar2(35)
--			p_cust_contact_email	out varchar2(240)
--			p_install_addr1		out varchar2(240)
--			p_install_addr2		out varchar2(240)
--			p_install_addr3		out varchar2(240)
--			p_inventory_item_id	out number
--			p_inventory_item	out varchar2(2000)
--			p_serial_number		out varchar2(30)
--			p_order_number		out number
--			p_customer_product_id	out number
--			p_problem_desc		out varchar2(240)
--			p_summary		out varchar2(80)
--			p_urgency_id		out number
--			p_incident_comment	out varchar2(2000)
--
--   Version:		Initial version	1.0
--   Notes:
--
-----------------------------------------------------------------------------

PROCEDURE sr_default(p_api_version	in number,
		p_init_msg_list		in  varchar2 default fnd_api.g_false,
		p_simulate		in  varchar2 default fnd_api.g_false,
		p_commit		in  varchar2 default fnd_api.g_false,
		p_validation_level	in  number   default fnd_api.g_valid_level_full,
		p_return_status		out varchar2,
		p_msg_count		out number,
		p_msg_data		out varchar2,
		p_customer_id		out number,
		p_customer_name		out varchar2,
		p_cust_contact_id	out number,
		p_cust_contact_name	out varchar2,
		p_cust_contact_area_code out varchar2,
		p_cust_contact_phone	out varchar2,
		p_cust_contact_extension out varchar2,
		p_cust_contact_fax_area_code out varchar2,
		p_cust_contact_fax	out varchar2,
		p_cust_contact_email	out varchar2,
		p_install_addr1		out varchar2,
		p_install_addr2		out varchar2,
		p_install_addr3		out varchar2,
		p_inventory_item_id	out number,
		p_inventory_item	out varchar2,
		p_serial_number		out varchar2,
		p_order_number		out number,
		p_customer_product_id	out number,
		p_problem_desc		out varchar2,
		p_summary		out varchar2,
		p_urgency_id		out number,
		p_incident_comment	out varchar2);



----------------------------------------------------------------------------
--   API name:		sr_validate
--   Type:		private
--   Function:		Provides a mechanism for customers to put in their
--			 own validation for a service request
--   Pre-reqs:		none
--   Parameters:
--    In:	p_api_version		in number			Required
--		p_init_msg_list		in varchar2 		Optional
--			default fnd_api.g_false
--		p_simulate		in  varchar2 		Optional
--			default fnd_api.g_false
--		p_commit		in  varchar2 		Optional
--			default fnd_api.g_false
--		p_validation_level	in  number 		Optional
--			default fnd_api.g_valid_level_full
--		p_submit_type		in varchar2		Optional
--			default null
--		p_incident_id		in number 		Optional
--			default null
--		p_request_number	in varchar2 		Optional
--			default null
--		p_customer_id		in number 		Optional
--			default null
--		p_customer_name		in varchar2 		Optional
--			default null
--		p_cust_contact_id	in number 		Optional
--			default null
--		p_cust_contact_name	in varchar2 		Optional
--			default null
--		p_cust_contact_area_code in varchar2 		Optional
--			default null
--		p_cust_contact_phone	in varchar2 		Optional
--			default null
--		p_cust_contact_extension in varchar2 		Optional
--			default null
--		p_cust_contact_fax_area_code in varchar2 	Optional
--			default null
--		p_cust_contact_fax	in varchar2 		Optional
--			default null
--		p_cust_contact_email	in varchar2 		Optional
--			default null
--		p_install_addr1		in varchar2 		Optional
--			default null
--		p_install_addr2		in varchar2 		Optional
--			default null
--		p_install_addr3		in varchar2 		Optional
--			default null
--		p_inventory_item_id	in varchar2 		Optional
--			default null
--		p_inventory_item	in varchar2 		Optional
--			default null
--		p_serial_number		in varchar2 		Optional
--			default null
--		p_order_number		in varchar2 		Optional
--			default null
--		p_customer_product_id	in number		Optional
--			default null
--		p_problem_desc		in varchar2 		Optional
--			default null
--		p_summary		in varchar2 		Optional
--			default null
--		p_urgency_id		in number 		Optional
--			default null
--		p_incident_comment	in varchar2 		Optional
--			default null
--    Out:
--		p_return_status		out varchar2(1)
--		p_msg_count		out number
--		p_msg_data		out varchar2(2000)
--
--   Version:	Initial version 1.0
--   Notes:
----------------------------------------------------------------------------

PROCEDURE sr_validate(p_api_version	in number,
		p_init_msg_list		in varchar2 	default fnd_api.g_false,
		p_simulate		in  varchar2 	default fnd_api.g_false,
		p_commit		in  varchar2 	default fnd_api.g_false,
		p_validation_level	in  number 	default fnd_api.g_valid_level_full,
		p_submit_type		in varchar2	default null,
		p_incident_id		in number 	default null,
		p_request_number	in varchar2 	default null,
		p_customer_id		in number 	default null,
		p_customer_name		in varchar2 	default null,
		p_cust_contact_id	in number 	default null,
		p_cust_contact_name	in varchar2 	default null,
		p_cust_contact_area_code in varchar2 	default null,
		p_cust_contact_phone	in varchar2 	default null,
		p_cust_contact_extension in varchar2 	default null,
		p_cust_contact_fax_area_code in varchar2 default null,
		p_cust_contact_fax	in varchar2 	default null,
		p_cust_contact_email	in varchar2 	default null,
		p_install_addr1		in varchar2 	default null,
		p_install_addr2		in varchar2 	default null,
		p_install_addr3		in varchar2 	default null,
		p_inventory_item_id	in number 	default null,
		p_inventory_item	in varchar2 	default null,
		p_serial_number		in varchar2 	default null,
		p_order_number		in number 	default null,
		p_customer_product_id	in number	default null,
		p_problem_desc		in varchar2 	default null,
		p_summary		in varchar2 	default null,
		p_urgency_id		in number 	default null,
		p_incident_comment	in varchar2 	default null,
		p_return_status		out varchar2,
		p_msg_count		out number,
		p_msg_data		out varchar2);




END ICX_SR_CUSTOM_PVT;

 

/
