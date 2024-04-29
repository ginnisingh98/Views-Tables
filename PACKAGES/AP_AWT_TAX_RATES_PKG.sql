--------------------------------------------------------
--  DDL for Package AP_AWT_TAX_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AWT_TAX_RATES_PKG" AUTHID CURRENT_USER AS
/* $Header: aptaxcks.pls 120.3 2004/10/29 19:04:57 pjena noship $ */

    PROCEDURE CHECK_AMOUNT_OVERLAP(X_tax_name IN VARCHAR2,
                                   X_calling_sequence IN VARCHAR2);

    PROCEDURE CHECK_AMOUNT_GAPS(X_tax_name IN VARCHAR2,
                                X_calling_sequence IN VARCHAR2);

    PROCEDURE CHECK_LAST_AMOUNT(X_tax_name IN VARCHAR2,
                                X_calling_sequence IN VARCHAR2);

END AP_AWT_TAX_RATES_PKG;

 

/
