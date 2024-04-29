--------------------------------------------------------
--  DDL for Package QP_DEALS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEALS_UTIL" AUTHID CURRENT_USER as
/* $Header: QPXUDLSS.pls 120.0.12010000.2 2008/11/05 12:08:47 bhuchand ship $ */
PROCEDURE CALL_DEALS_API(
	    p_origin 	in NUMBER,
	    p_header_id 	in NUMBER,
	    p_updatable_flag 	IN varchar2,
	    x_redirect_function out nocopy varchar2,
	    x_is_deal_compliant out nocopy varchar2,
	    x_rules_desc 	out nocopy varchar2,
	    x_return_status 	out nocopy varchar2,
	    x_msg_data 		out nocopy varchar2,
            x_is_curr_inst_deal_inst out nocopy varchar2);

END QP_DEALS_UTIL;

/
