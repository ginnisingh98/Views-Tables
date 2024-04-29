--------------------------------------------------------
--  DDL for Package JAI_CMN_RCV_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RCV_MATCHING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rcv_mach.pls 120.2 2008/02/13 13:24:04 rallamse ship $ */

/*
Commented during removal of sql literals
PROCEDURE opm_default_taxes( p_subinventory IN VARCHAR2,
                                                  p_customer_id IN NUMBER,
                                                  p_ref_line_id IN NUMBER,
                                                  p_receipt_id IN NUMBER,
                                                  p_line_id NUMBER,  -- For OE it is Line ID, for AR it is Link to cust trx line id
                                                  p_line_quantity IN NUMBER,
                                                  p_curr_conv_factor IN NUMBER,
                                                  p_order_invoice IN VARCHAR2 ,
                                  p_line_no Number ) ;
*/

PROCEDURE automatic_match_process(
		errbuf OUT NOCOPY VARCHAR2,
		p_created_by IN NUMBER,
		p_last_update_login IN NUMBER,
		p_organization_id IN NUMBER,
		p_customer_id IN NUMBER,
		p_order_type_id IN NUMBER,
		p_delivery_id IN NUMBER DEFAULT null,
		p_delivery_detail_id IN NUMBER DEFAULT null,
		p_order_header_id IN NUMBER DEFAULT null,
		p_line_id IN NUMBER DEFAULT null
	);

PROCEDURE ar_default_taxes( p_ref_line_id IN NUMBER,
                                             p_customer_id IN NUMBER,
                                             p_link_to_cust_trx_line_id NUMBER,
                                             p_curr_conv_factor IN NUMBER,
                                             p_receipt_id  IN NUMBER,
                                             p_qty IN NUMBER );


PROCEDURE om_default_taxes(
    p_subinventory IN VARCHAR2,
    p_customer_id IN NUMBER,
    p_ref_line_id IN NUMBER,
    p_receipt_id IN NUMBER,
    p_line_id NUMBER,  -- For OE it is Line ID, for AR it is Link to cust trx line id
    p_line_quantity IN NUMBER,
    p_curr_conv_factor IN NUMBER,
    p_order_invoice IN VARCHAR2
) ;

END  jai_cmn_rcv_matching_pkg ;

/
