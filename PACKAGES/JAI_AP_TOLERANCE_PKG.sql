--------------------------------------------------------
--  DDL for Package JAI_AP_TOLERANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TOLERANCE_PKG" 
/* $Header: jai_ap_tolerance.pls 120.1.12010000.3 2008/09/23 16:58:29 lgopalsa ship $ */
AUTHID CURRENT_USER AS

PROCEDURE inv_holds_check
       ( p_invoice_id            in NUMBER,
         p_org_id                in NUMBER,
         p_set_of_books_id       in NUMBER,
         p_invoice_amount        in NUMBER,
         p_invoice_currency_code in  varchar2,
         p_return_code           out nocopy varchar2,
         p_return_message        out nocopy varchar2);


END jai_ap_tolerance_pkg;

/
