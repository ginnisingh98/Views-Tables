--------------------------------------------------------
--  DDL for Package AP_INVOICE_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICE_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apiinpas.pls 120.2 2004/10/28 00:06:01 pjena noship $ */

    FUNCTION get_paid_by(l_invoice_id IN NUMBER,
			 l_payment_num IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER,
			      l_payment_num IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_paid_date(l_invoice_id IN NUMBER,
			   l_payment_num IN NUMBER) RETURN DATE;
    FUNCTION get_payment_id(l_invoice_id IN NUMBER,
			    l_payment_num IN NUMBER) RETURN NUMBER;
    FUNCTION get_payment_type(l_invoice_id IN NUMBER,
			      l_payment_num IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_max_gl_date(l_check_id IN NUMBER) RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(get_paid_by_list, WNDS);
    PRAGMA RESTRICT_REFERENCES(get_paid_date, WNDS);
    PRAGMA RESTRICT_REFERENCES(get_payment_id, WNDS);
    PRAGMA RESTRICT_REFERENCES(get_payment_type, WNDS);
    PRAGMA RESTRICT_REFERENCES(get_max_gl_date, WNDS, WNPS, RNPS);

END AP_INVOICE_PAYMENTS_PKG;

 

/
