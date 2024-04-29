--------------------------------------------------------
--  DDL for Package AP_RETAINAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RETAINAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: apcwrtns.pls 120.0 2005/06/25 00:41:28 schitlap noship $ */

PROCEDURE Create_Retainage_Distributions(x_invoice_id          IN ap_invoices.invoice_id%type,
                                         x_invoice_line_number IN ap_invoice_lines.line_number%type);


END AP_RETAINAGE_PKG;

 

/
