--------------------------------------------------------
--  DDL for Package QPR_DEAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DEAL_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRPDPRS.pls 120.11 2008/06/19 11:05:35 vinnaray ship $ */
/* Public Procedures */
   TYPE num_type IS TABLE OF Number;

--g_origin number;

TYPE TERM_DATA_REC is record
(
  TERM_TYPE	varchar2(30),
  DIM_CODE	varchar2(30),
  LEVEL_CODE	varchar2(30)
);

type TERM_SETUP_TBL_TYPE is table of TERM_DATA_REC;


type PN_AW_DATA_REC is record
(
  PN_LINE_ID		number,
  CUSTOMER_SK		varchar2(240),
  PRODUCT_DIM_SK	varchar2(240),
  PR_SEGMENT_SK         varchar2(240),
  DEAL_CREATION_DATE    date,
  DEAL_CURRENCY		varchar2(240),
  PAYMENT_TERM_CODE	varchar2(240),
  SHIP_METHOD_CODE	varchar2(240),
  REBATE_CODE		varchar2(240),
  GROSS_REVENUE		number,
  PAYMENT_TERM_OAD_VAL	number,
  SHIP_METHOD_OAD_VAL	number,
  REBATE_OAD_VAL	number,
	GET_COST_FLAG varchar2(1),
	UNIT_COST	number
);

type PN_AW_TBL_TYPE is table of PN_AW_DATA_REC ;

procedure debug_ext_log(text in varchar2, source_id in number);

procedure get_line_aw_details(
			errbuf out nocopy varchar2,
			retcode out nocopy varchar2,
			p_price_plan_id IN NUMBER,
                        p_instance_id in number,
		p_t_line_det IN OUT nocopy QPR_DEAL_PVT.PN_AW_TBL_TYPE);

function assign_aw(errbuf out nocopy varchar2,
                   retcode out nocopy varchar2,
                   p_instance_id in number,
                   p_inventory_item_id in number,
                   p_org_id in number,
                   p_sales_rep_id in number,
                   p_customer_id in number,
                   p_geography_id in number,
                   p_sales_channel_code in varchar2,
                   p_pr_segment_id in number,
                   p_aw_name out nocopy varchar2) return number;

function get_volume_band(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_inventory_item_id number,
			 p_ordered_qty number,
			 p_transf_group_id number) return varchar2;

function get_number(p_char varchar2) return number;

procedure handle_request_event(p_quote_origin in number,
			p_quote_header_id in number,
			p_request_header_id number,
			p_response_header_id number,
			p_instance_id number default null,
			callback_status varchar2,
			return_status out nocopy varchar2,
                        p_err_msg out nocopy varchar2);

procedure cancel_pn_request(p_quote_origin in number,
			    p_quote_header_id in number,
			    p_instance_id in number,
			    return_status out nocopy varchar2);

procedure update_request(p_request_header_id number,
			status varchar2);

function get_redirect_function(
			p_quote_origin in number,
			p_quote_header_id in number,
			p_instance_id in number,
			skip_search in boolean default true) return varchar2;

function user_allowed( p_response_hdr_id in number,
			p_fnd_user in varchar2) return varchar2;
function actions_enable( p_response_hdr_id in number) return varchar2;

function has_active_requests(p_quote_origin number, p_quote_header_id number,
			p_instance_id in number)
return boolean;

function has_saved_requests(p_quote_origin number, p_quote_header_id number,
			p_instance_id in number)
return boolean;

END QPR_DEAL_PVT ;

/
