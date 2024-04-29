--------------------------------------------------------
--  DDL for Package POS_AP_INVOICE_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_AP_INVOICE_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: POSAPPAS.pls 115.1 2002/01/08 11:43:55 pkm ship   $ */

    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER,
                              l_payment_num IN NUMBER) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(get_paid_by_list, WNDS);
END POS_AP_INVOICE_PAYMENTS_PKG;

 

/
