--------------------------------------------------------
--  DDL for Package AP_CARD_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CARD_INVOICE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcints.pls 120.2 2005/07/29 21:00:55 hchacko noship $ */

PROCEDURE CREATE_INVOICE(
      P_CARD_PROGRAM_ID IN NUMBER,
      P_INVOICE_ID      IN OUT NOCOPY NUMBER,
      P_START_DATE      IN DATE DEFAULT NULL,
      P_END_DATE        IN DATE DEFAULT NULL,
      P_ROLLUP_FLAG     IN VARCHAR2 DEFAULT 'Y');

END AP_CARD_INVOICE_PKG;

 

/
