--------------------------------------------------------
--  DDL for Package Body ICX_SR_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_SR_CUSTOM_PVT" AS
/* $Header: ICXVSRB.pls 115.0 99/07/17 03:30:31 porting ship $ */

g_pkg_name	constant varchar2(30) := 'ICX_SR_CUSTOM_PVT';


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
		p_incident_comment	out varchar2) is

  l_api_name		constant varchar2(30) := 'SR_DEFAULT';
  l_api_version		constant number := 1.0;

begin

  -- Standard start of API savepoint
  SAVEPOINT SR_DEFAULT_PVT;

  -- Standard call to check for call compatibility
  if not fnd_api.Compatible_API_Call(l_api_version,
					p_api_version,
					l_api_name,
					g_pkg_name) then

	raise fnd_api.g_exc_unexpected_error;
  end if;


  -- Initialize message list if p_init_msg_list is TRUE
  if fnd_api.to_boolean(p_init_msg_list) then
	fnd_msg_pub.initialize;
  end if;

  -- Initialize API return status to success
  p_return_status := fnd_api.g_ret_sts_success;

  -- *******************************************************************
  -- API body
  -- Put custom code here
  -- *******************************************************************


  -- *******************************************************************
  -- end API body
  -- *******************************************************************


  -- Standard check of p_simulate and p_commit parameters
  if fnd_api.to_boolean(p_simulate) then
	ROLLBACK to SR_DEFAULT_PVT;

  elsif fnd_api.to_boolean(p_commit) then
	COMMIT WORK;

  end if;

  -- Standard call to get message count and if count=1, get message info
  fnd_msg_pub.count_and_get(p_count => p_msg_count,
			p_data => p_msg_data);

exception
  when fnd_api.g_exc_error then
	ROLLBACK to SR_DEFAULT_PVT;
	p_return_status := fnd_api.g_ret_sts_error;

	fnd_msg_pub.count_and_get(p_count => p_msg_count,
				p_data => p_msg_data);


  when fnd_api.g_exc_unexpected_error then
	ROLLBACK to SR_DEFAULT_PVT;
	p_return_status := fnd_api.g_ret_sts_unexp_error;

	fnd_msg_pub.count_and_get(p_count => p_msg_count,
				p_data => p_msg_data);

  when others then
	ROLLBACK to SR_DEFAULT_PVT;
	p_return_status := fnd_api.g_ret_sts_unexp_error;

	if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	  fnd_msg_pub.Add_Exc_Msg(g_pkg_name,
				l_api_name);
	end if;

	fnd_msg_pub.count_and_get(p_count => p_msg_count,
				p_data => p_msg_data);


end sr_default;




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
		p_cust_contact_area_code in varchar2	default null,
		p_cust_contact_phone	in varchar2 	default null,
		p_cust_contact_extension in varchar2	default null,
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
		p_msg_data		out varchar2) is

  l_api_name		constant varchar2(30) := 'SR_VALIDATE';
  l_api_version 	constant number := 1.0;

begin



  -- Standard start of API savepoint
  SAVEPOINT SR_VALIDATE_PVT;

  -- Standard call to check for call compatibility
  if not fnd_api.Compatible_API_Call(l_api_version,
					p_api_version,
					l_api_name,
					g_pkg_name) then

	raise fnd_api.g_exc_unexpected_error;
  end if;


  -- Initialize message list if p_init_msg_list is TRUE
  if fnd_api.to_boolean(p_init_msg_list) then
	fnd_msg_pub.initialize;
  end if;

  -- Initialize API return status to success
  p_return_status := fnd_api.g_ret_sts_success;

  -- *******************************************************************
  -- API body
  -- Put custom code here
  -- *******************************************************************


  -- *******************************************************************
  -- end API body
  -- *******************************************************************


  -- Standard check of p_simulate and p_commit parameters
  if fnd_api.to_boolean(p_simulate) then
	ROLLBACK to SR_VALIDATE_PVT;

  elsif fnd_api.to_boolean(p_commit) then
	COMMIT WORK;

  end if;

  -- Standard call to get message count and if count=1, get message info
  fnd_msg_pub.count_and_get(p_count => p_msg_count,
			p_data => p_msg_data);

exception
  when fnd_api.g_exc_error then
	ROLLBACK to SR_VALIDATE_PVT;
	p_return_status := fnd_api.g_ret_sts_error;

	fnd_msg_pub.count_and_get(p_count => p_msg_count,
				p_data => p_msg_data);


  when fnd_api.g_exc_unexpected_error then
	ROLLBACK to SR_VALIDATE_PVT;
	p_return_status := fnd_api.g_ret_sts_unexp_error;

	fnd_msg_pub.count_and_get(p_count => p_msg_count,
				p_data => p_msg_data);

  when others then
	ROLLBACK to SR_VALIDATE_PVT;
	p_return_status := fnd_api.g_ret_sts_unexp_error;

	if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	  fnd_msg_pub.Add_Exc_Msg(g_pkg_name,
				l_api_name);
	end if;

	fnd_msg_pub.Count_And_Get(p_count => p_msg_count,
				p_data => p_msg_data);


end sr_validate;





END ICX_SR_CUSTOM_PVT;

/
