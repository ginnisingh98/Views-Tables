--------------------------------------------------------
--  DDL for Package FV_CROSS_DOC_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CROSS_DOC_REF" AUTHID CURRENT_USER AS
/* $Header: FVDOCCRS.pls 120.2 2002/11/10 15:02:52 ksriniva ship $*/
 procedure main
	(
		p_vendor_id  IN po_vendors.vendor_id%TYPE ,
		p_vendor_site_id IN po_vendor_sites.vendor_site_id%TYPE ,
		p_po_header_id IN  po_headers.po_header_id%TYPE,
		p_po_date  IN po_headers.creation_date%TYPE,
		p_requisition_header_id  IN po_requisition_headers.requisition_header_id%TYPE,
		p_requisition_line_id     IN po_requisition_lines.requisition_line_id%TYPE,
		p_req_date  IN po_requisition_headers.creation_date%TYPE,
		p_shipment_header_id  IN rcv_shipment_headers.shipment_header_id%TYPE,
		p_receipt_date  IN rcv_shipment_headers.creation_date%TYPE,
		p_buyer  IN po_headers.agent_id%TYPE,
		p_invoice_id  IN ap_invoices.invoice_id%TYPE,
		p_invoice_date  IN ap_invoices.invoice_date%TYPE ,
		p_invoice_amount  IN ap_invoices.invoice_amount%TYPE ,
		p_invoice_type  IN ap_invoices.invoice_type_lookup_code%TYPE ,
		p_check_id  IN ap_checks.check_id%TYPE,
		p_check_date  IN ap_checks.creation_date%TYPE,
		p_amount  IN ap_checks.amount%TYPE,
		p_treasury_pay_number  IN ap_checks.treasury_pay_number%TYPE,
		p_treasury_pay_date  IN ap_checks.treasury_pay_date%TYPE,
		p_valid_req_supplier  IN  NUMBER,
		p_supplier_name IN po_vendors.vendor_name%TYPE,
		p_supplier_site IN po_vendor_sites.vendor_site_code%TYPE,
		p_result IN VARCHAR2,
		p_err_code    OUT NOCOPY NUMBER,
		p_session_id  IN NUMBER
	);

END fv_cross_doc_ref;

 

/
