--------------------------------------------------------
--  DDL for Package Body AP_PO_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PO_UTILITIES_PKG" AS
/* $Header: appoutlb.pls 120.0 2006/05/06 01:44:19 mswamina noship $ */

  -- This procedure will return maximum invoice date based on the
  -- line location information passed to us. Depending on the type
  -- of the shipment this procedure will include/exclude prepayments.
  -- refer to bug 4549985 for details.

  PROCEDURE Get_Invoice_Close_Date
                (P_Line_Location_ID          IN         NUMBER,
                 P_Shipment_Type             IN         VARCHAR2,
                 P_Invoice_Date              OUT NOCOPY DATE) IS

  BEGIN

    IF P_Shipment_Type = 'PREPAYMENT' THEN

       SELECT MAX(AI.invoice_date)
       INTO   P_Invoice_Date
       FROM   AP_Invoices_All AI,
              AP_Invoice_Lines_All AIL
       WHERE  AI.invoice_id = AIL.invoice_id
         AND  AIL.po_line_location_id = P_Line_Location_ID
         AND  NVL(AIL.discarded_flag,'N') <> 'N'
         AND  AI.invoice_type_lookup_code = 'PREPAYMENT';

       RETURN;

    END IF;

    IF P_Shipment_Type = 'STANDARD' THEN

       SELECT MAX(AI.invoice_date)
       INTO   P_Invoice_Date
       FROM   AP_Invoices_All AI,
              AP_Invoice_Lines_All AIL
       WHERE  AI.invoice_id = AIL.invoice_id
         AND  AIL.po_line_location_id = P_Line_Location_ID
         AND  NVL(AIL.discarded_flag,'N') <> 'N'
         AND  AI.invoice_type_lookup_code = 'STANDARD';

       RETURN;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      P_Invoice_Date := NULL;
  END Get_Invoice_Close_Date;


END AP_PO_UTILITIES_PKG;

/
