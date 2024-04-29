--------------------------------------------------------
--  DDL for Package QPR_PRICE_NEGOTIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_PRICE_NEGOTIATION_PUB" AUTHID CURRENT_USER AS
/* $Header: QPRADEAPS.pls 120.11 2008/05/30 09:15:00 vinnaray ship $ */

G_PRODUCT_STATUS VARCHAR2(1);
G_ORIGIN number;
exe_severe_error exception;

FUNCTION Get_QPR_Status RETURN VARCHAR2;

/*---------------------------------------------------------------
| Usage:
|  errbuf - contains error message
|  retcode - returns 2 in case of error
|  p_quote_origin - takes origin application id
|  p_quote_number - Quote number
|  p_quote_version - Quote version
|  p_order_type_name - needed in case of 'OM', takes the order type name
|  p_quote_header_id - Quote header_id
|  p_instance_id - identification of transaction instance - default null
|  p_simulation - A flag ('Y'/'N') to indicate if the values are
|       simulated/actual so that the price request status is set appropriately
|  p_response_id - Price negotiation response id created
|  p_is_deal_compliant - flag ('Y'/'N') indicating if the quote price is
|                     compliant or not.
| p_rules_desc - lists the lines that are not compliant
|--------------------------------------------------------------*/

procedure create_pn_request(
                       errbuf out nocopy varchar2,
                       retcode out nocopy varchar2,
                       p_quote_origin in number,
                       p_quote_number in number,
                       p_quote_version in number,
                       p_order_type_name in varchar2,
                       p_quote_header_id in number,
		       p_instance_id in number default null,
                       p_simulation in varchar2 default 'Y',
                       p_response_id out nocopy number,
		       p_is_deal_compliant out nocopy varchar2,
		       p_rules_desc out nocopy varchar2);

procedure get_pn_approval_status(
                       errbuf out nocopy varchar2,
                       retcode out nocopy varchar2,
                       p_quote_origin in number,
                       p_quote_header_id in number,
		       o_deal_id out nocopy number,
                       o_status out nocopy varchar2);

procedure debug_log(text varchar2);

-- New Integration APIs.

function has_active_requests(
			p_quote_origin number,
			p_quote_header_id number,
			p_instance_id number) return varchar2;

function has_saved_requests(
			p_quote_origin number,
			p_quote_header_id number,
			p_instance_id number) return varchar2;

procedure cancel_active_requests(p_quote_origin in number,
                           p_quote_header_id in number,
			   instance_id number,
                           suppress_event in boolean default false,
                           x_return_status out nocopy varchar2,
                           x_mesg_data out nocopy varchar2);

procedure create_request(p_quote_origin in number,
                   	p_quote_header_id in number,
			p_instance_id number,
			suppress_event in boolean default false,
		        p_is_deal_compliant out nocopy varchar2,
		        p_rules_desc out nocopy varchar2,
			x_return_status out nocopy varchar2,
			x_mesg_data out nocopy varchar2);

function get_redirect_function(
			p_quote_origin in number,
			p_quote_header_id in number,
			instance_id number,
			skip_search in boolean default true) return varchar2;

procedure initiate_deal(source_id in number,
		source_ref_id in number,
		instance_id number,
		updatable varchar2,
		redirect_function out nocopy varchar2,
		p_is_deal_compliant out nocopy varchar2,
		p_rules_desc out nocopy varchar2,
		x_return_status out nocopy varchar2,
		x_mesg_data out nocopy varchar2);
END;



/
