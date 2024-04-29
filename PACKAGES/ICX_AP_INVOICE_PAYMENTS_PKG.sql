--------------------------------------------------------
--  DDL for Package ICX_AP_INVOICE_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_AP_INVOICE_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXAPPAS.pls 115.2 2001/06/22 22:51:17 pkm ship   $ */

    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER,
                              l_payment_num IN NUMBER) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(get_paid_by_list, WNDS);
END ICX_AP_INVOICE_PAYMENTS_PKG;

 

/
