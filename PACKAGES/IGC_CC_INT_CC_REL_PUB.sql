--------------------------------------------------------
--  DDL for Package IGC_CC_INT_CC_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_INT_CC_REL_PUB" AUTHID CURRENT_USER AS
/*$Header: IGCCICRS.pls 120.4.12010000.2 2008/08/04 14:51:07 sasukuma ship $*/


PROCEDURE create_releases
(
 p_api_version		IN       NUMBER,
 p_init_msg_list	IN       VARCHAR2 := FND_API.G_FALSE,
 p_commit       	IN       VARCHAR2 := FND_API.G_FALSE,
 p_validation_level	IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_org_id		IN       igc_cc_headers.org_id%TYPE,
 p_sob_id		IN       igc_cc_headers.set_of_books_id%TYPE,
 p_cover_cc_header_id 	IN	 igc_cc_headers.cc_header_id%TYPE,
 p_invoice_id		IN	 ap_invoices_all.invoice_id%TYPE,
 p_invoice_amount	IN 	 ap_invoices_all.invoice_amount%TYPE,
 p_vendor_id		IN 	 igc_cc_headers.vendor_id%TYPE,
 p_user_id		IN  	 igc_cc_headers.created_by%TYPE,
 p_login_id		IN	 igc_cc_headers.last_update_login%TYPE,
 x_return_status	OUT NOCOPY      VARCHAR2,
 x_msg_count		OUT NOCOPY      NUMBER,
 x_msg_data		OUT NOCOPY      VARCHAR2,
 x_release_num		OUT NOCOPY      igc_cc_headers.cc_num%TYPE
);

END IGC_CC_INT_CC_REL_PUB;

/
