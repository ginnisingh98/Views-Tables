--------------------------------------------------------
--  DDL for Package AP_MATCH_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MATCH_UTILITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: aprmtuts.pls 120.0 2006/08/22 08:42:25 mswamina noship $ */

/*=============================================================================
 | PUBLIC FUNCTION Check_Unvalidated_Invoices
 |
 | DESCRIPTION
 |   The function will Return 'TRUE' if there are unvalidated payables
 |   documents matched to a Purchase Order based on the input parameters.
 |
 | USAGE
 |      p_invoice_type and p_po_header_id are required parameters.
 |      Call this function, when the user unreserves funds for the PO.
 |      Unreserve from PO Header, pass p_po_line_id, p_line_location_id, p_po_distribution_id AS NULL
 |      Unreserve from PO Line, pass p_line_location_id and p_po_distribution_id AS NULL
 |      Unreserve from PO Shipment, pass p_po_distribution_id AS NULL
 |      Unreserve from PO Distribution, pass all parameters.
 |
 |      This function can also be used to prevent 'Final Close' of a PO if there are unvalidated
 |      invoices matched to it.
 |
 |      Parameter p_invoice_id
 |      ----------------------
 |      A special case during matching, is when a user indicates that it is a 'Final Match'. During
 |      invoice validation, Payables invokes po_actions.close_po() to 'Final Close' the PO.
 |
 |      When po_actions.close_po() is invoked as a result of 'Final Match', pass p_invoice_id
 |      to skip the check for the invoice doing the final match. Otherwise, we will not be
 |      able to final match or close the PO.
 |
 | RETURNS
 |      TRUE if there are unvalidated invoices, credit or debit memos.
 |
 | PARAMETERS
 |   p_invoice_type	  IN  Required parameter. Values: 'INVOICE' or 'CREDIT'
 |   p_po_header_id	  IN  Required parameter. PO Header Identifier.
 |   p_po_line_id	  IN  PO Line Identifier
 |   p_line_location_id	  IN  PO Shipment Identifier
 |   p_po_distribution_id IN  PO Distribution Identifier
 |   p_invoice_id	  IN  Invoice Identifier
 |   p_calling_sequence   IN  Calling module (package_name.procedure or block_name.field_name)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 |
 *=============================================================================*/

 FUNCTION Check_Unvalidated_Invoices(p_invoice_type	  IN  VARCHAR2 DEFAULT 'BOTH',
				     p_po_header_id	  IN  NUMBER,
                                     p_po_release_id      IN  NUMBER DEFAULT NULL,
				     p_po_line_id	  IN  NUMBER DEFAULT NULL,
				     p_line_location_id	  IN  NUMBER DEFAULT NULL,
				     p_po_distribution_id IN  NUMBER DEFAULT NULL,
				     p_invoice_id	  IN  NUMBER DEFAULT NULL,
				     p_calling_sequence   IN  VARCHAR2) RETURN BOOLEAN;

END AP_MATCH_UTILITIES_PUB;


 

/
