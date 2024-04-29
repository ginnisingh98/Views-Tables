--------------------------------------------------------
--  DDL for Package PO_LINES_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV5" AUTHID CURRENT_USER as
/* $Header: POXPOL5S.pls 120.0.12000000.2 2007/10/05 23:21:53 jburugul ship $ */

/*===========================================================================
  PROCEDURE NAME:	po_lines_post_query()

  DESCRIPTION:		This procedure is a wrapper that does post_query
                        processing for rows in PO_LINES block.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	08/08/95     SIYER
===========================================================================*/
 procedure  po_lines_post_query ( X_po_Line_id IN number,
                                  X_from_header_id IN number,
                                  X_from_line_id IN number,
                                  X_line_type_id IN number,
                                  X_item_id IN number,
                                  X_inventory_org_id IN number,
                                  X_expense_accrual_code IN varchar2,
                                  X_po_header_id IN number,
                                  X_type_lookup_code IN varchar2,
                                  X_receipt_required_flag IN OUT NOCOPY varchar2,
                                  X_quantity_received IN OUT NOCOPY number,
                                  X_quantity_billed IN OUT NOCOPY number,
                                  X_encumbered_flag IN OUT NOCOPY varchar2,
                                  X_prevent_price_update_flag IN OUT NOCOPY varchar2,
                                  X_online_req_flag IN OUT NOCOPY varchar2,
                                  X_quantity_released IN OUT NOCOPY number,
                                  X_amount_released IN OUT NOCOPY number,
                                  X_quotation_number IN OUT NOCOPY varchar2,
                                  X_quotation_line IN OUT NOCOPY number,
                                  X_quotation_type IN OUT NOCOPY varchar2,
                                  X_vendor_quotation_number IN OUT NOCOPY varchar2,
                                  X_num_of_ship IN OUT NOCOPY number,
                                  --< NBD TZ/Timestamp FPJ Start >
                                  --X_promised_date IN OUT NOCOPY varchar2,
                                  --X_need_by IN OUT NOCOPY varchar2,
                                  X_promised_date IN OUT NOCOPY DATE,
                                  X_need_by IN OUT NOCOPY DATE,
                                  --< NBD TZ/Timestamp FPJ End >
                                  X_num_of_dist IN OUT NOCOPY number,
                                  X_code_combination_id IN OUT NOCOPY number,
                                  X_line_total IN OUT NOCOPY number,
                                  X_ship_total IN OUT NOCOPY number,
                                  X_ship_total_rtot_db IN OUT NOCOPY number,
				  --togeorge 10/03/2000
				  --added oke variables
				  X_oke_contract_header_id IN number,
				  X_oke_contract_num IN OUT NOCOPY varchar2
                                  ) ;

/*===========================================================================
 *   PROCEDURE NAME:       price_update_allowed
 *   DESCRIPTION:          This function checks whether price update
 *                         on a PO line is allowed or not and returns true
 *                         or false.
 * PARAMETERS:           p_po_line_id : line id of the PO LINE.
 *
 * DESIGN REFERENCES:
 * ALGORITHM:           1. get the total quantity_received, quantity_billed
 *                         for a particular po line.
 *
 *                      2. if the destination at distribution is Inventory
 *                      or Shopfloor and quantity_billed or
 *                      received is > 0 disallow price update,
 *                      3. else for expense destination if any shipment
 *                      has accrual option - at receipt, then
 *                      if quantity billed or received is > 0 disallow the
 *                      price update.
 *
 * NOTES:
 * OPEN ISSUES:
 * CLOSED ISSUES:
 * CHANGE HISTORY:       Created         22/02/05 Ambansal
 * ===========================================================================*/

FUNCTION price_update_allowed(p_po_line_id IN NUMBER) RETURN BOOLEAN;

END PO_LINES_SV5;

 

/
