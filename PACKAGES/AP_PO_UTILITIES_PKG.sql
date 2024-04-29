--------------------------------------------------------
--  DDL for Package AP_PO_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PO_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: appoutls.pls 120.0 2006/05/06 01:44:06 mswamina noship $ */

  -- This procedure will return maximum invoice date based on the
  -- line location information passed to us. Depending on the type
  -- of the shipment this procedure will include/exclude prepayments.
  -- refer to bug 4549985 for details.

  PROCEDURE Get_Invoice_Close_Date
                (P_Line_Location_ID          IN         NUMBER,
                 P_Shipment_Type             IN         VARCHAR2,
                 P_Invoice_Date              OUT NOCOPY DATE);


END AP_PO_UTILITIES_PKG;

 

/
