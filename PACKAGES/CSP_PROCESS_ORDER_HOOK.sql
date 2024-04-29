--------------------------------------------------------
--  DDL for Package CSP_PROCESS_ORDER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PROCESS_ORDER_HOOK" AUTHID CURRENT_USER as
/* $Header: cspiohooks.pls 120.0.12010000.2 2012/01/31 16:13:13 vmandava noship $ */

PROCEDURE update_oe_dff_info(px_req_header_rec IN OUT NOCOPY csp_parts_requirement.header_rec_type
                        ,px_req_line_table IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
			,px_oe_header_rec IN OUT NOCOPY  oe_order_pub.header_rec_type
			,px_oe_line_table   IN OUT NOCOPY  oe_order_pub.line_tbl_type);


END CSP_PROCESS_ORDER_HOOK;

/
