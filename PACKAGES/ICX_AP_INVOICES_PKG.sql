--------------------------------------------------------
--  DDL for Package ICX_AP_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_AP_INVOICES_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXAPINS.pls 115.0 99/08/09 17:21:52 porting ship $ */

    FUNCTION get_po_number_list(l_invoice_id IN NUMBER) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(get_po_number_list, WNDS, WNPS, RNPS);

    FUNCTION get_amount_withheld(l_invoice_id IN NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(get_amount_withheld, WNDS, WNPS, RNPS);
END ICX_AP_INVOICES_PKG;

 

/
