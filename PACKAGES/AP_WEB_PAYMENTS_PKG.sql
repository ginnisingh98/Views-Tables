--------------------------------------------------------
--  DDL for Package AP_WEB_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxpays.pls 120.4 2006/09/22 12:49:26 nammishr noship $ */
    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER,
                              l_payment_num IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_total_payments_made(l_invoice_id IN NUMBER)
    						RETURN VARCHAR2;
    FUNCTION get_checkid(l_invoice_id IN NUMBER)
    						RETURN NUMBER;
    FUNCTION get_last_payment_date(l_invoice_id IN NUMBER)
    						RETURN DATE;
    PRAGMA RESTRICT_REFERENCES(get_paid_by_list, WNDS);
    FUNCTION get_prepay_amount_remaining(P_invoice_id IN number,
                                     p_Invoice_num IN VARCHAR2,
                                     p_employee_id IN NUMBER,
                                     p_currency IN VARCHAR2,
                                     P_header_id IN NUMBER DEFAULT NULL,
                                     p_resp_id IN NUMBER DEFAULT NULL,
                                     p_apps_id NUMBER DEFAULT NULL)
       				 RETURN NUMBER;

    FUNCTION get_prepay_balance(P_invoice_id IN number,
                                p_Invoice_num IN VARCHAR2,
                                p_employee_id IN NUMBER,
                                p_currency IN VARCHAR2)
			       RETURN number;

    FUNCTION get_line_prepay_balance(P_invoice_id IN number,
                                 line_id IN NUMBER)
		       RETURN number;

END AP_WEB_PAYMENTS_PKG;

 

/
