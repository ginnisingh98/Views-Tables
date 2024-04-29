--------------------------------------------------------
--  DDL for Package POS_AP_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_AP_INVOICES_PKG" AUTHID CURRENT_USER AS
/* $Header: POSAPINS.pls 120.6.12010000.2 2013/10/16 09:47:08 ramkandu ship $ */

    FUNCTION get_po_number_list(l_invoice_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION get_packing_slip_list(l_invoice_id IN NUMBER,
			p_invoice_num IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION get_retainage_for_invoice(l_invoice_id IN NUMBER) RETURN NUMBER;

    FUNCTION get_prepay_for_invoice(l_invoice_id IN NUMBER) RETURN NUMBER;

    FUNCTION get_total_for_invoice(l_invoice_id IN NUMBER) RETURN NUMBER;

    FUNCTION get_tax_for_invoice(l_invoice_id IN NUMBER) RETURN NUMBER;

    FUNCTION get_packing_slip(l_invoice_id IN NUMBER,
    			p_invoice_num IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION get_payment_list(l_invoice_id IN NUMBER,
                              l_payment_num IN NUMBER) RETURN VARCHAR2;

    PROCEDURE get_on_hold_info(l_invoice_id IN NUMBER,
                                    p_hold_status OUT NOCOPY VARCHAR2,
                                    p_hold_reason OUT NOCOPY VARCHAR2);

    FUNCTION get_due_date(l_invoice_id IN NUMBER) RETURN VARCHAR2;

    PROCEDURE get_po_info(l_invoice_id IN NUMBER,
    				p_po_switch OUT NOCOPY VARCHAR2,
     				p_po_num OUT NOCOPY VARCHAR2,
     				p_header_id OUT NOCOPY VARCHAR2,
     				p_release_id OUT NOCOPY VARCHAR2);

    PROCEDURE get_receipt_info(l_invoice_id IN NUMBER,
    				p_receipt_switch OUT NOCOPY VARCHAR2,
    				p_receipt_num OUT NOCOPY VARCHAR2,
    				p_receipt_shipment_header_id OUT NOCOPY VARCHAR2);

    /*deprecated - should be replaced by method with same name and which passes p_payment_method also*/
    PROCEDURE get_payment_info(l_invoice_id IN NUMBER,
       				p_payment_switch OUT NOCOPY VARCHAR2,
    				p_payment_num OUT NOCOPY VARCHAR2,
    				p_payment_id OUT NOCOPY VARCHAR2,
 				p_payment_date OUT NOCOPY VARCHAR2
 				);

    PROCEDURE get_payment_info(l_invoice_id IN NUMBER,
     				p_payment_switch OUT NOCOPY VARCHAR2,
  				p_payment_num OUT NOCOPY VARCHAR2,
  				p_payment_id OUT NOCOPY VARCHAR2,
  				p_payment_date OUT NOCOPY VARCHAR2,
  				p_payment_method OUT NOCOPY VARCHAR2
  				);

    FUNCTION get_amount_withheld(l_invoice_id IN NUMBER) RETURN NUMBER;

    FUNCTION get_on_hold_status(l_invoice_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION get_validation_status(l_org_id IN NUMBER, l_invoice_id IN NUMBER) RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES(get_amount_withheld, WNDS, WNPS, RNPS);

END POS_AP_INVOICES_PKG;

/
