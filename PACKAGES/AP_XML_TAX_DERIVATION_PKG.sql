--------------------------------------------------------
--  DDL for Package AP_XML_TAX_DERIVATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_XML_TAX_DERIVATION_PKG" AUTHID CURRENT_USER as
/* $Header: aptxders.pls 120.2 2004/10/29 19:06:25 pjena noship $ */

PROCEDURE correct_tax(p_invoice_id in NUMBER, p_vendor_id in NUMBER);

END AP_XML_TAX_DERIVATION_PKG;

 

/
