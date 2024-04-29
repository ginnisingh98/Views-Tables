--------------------------------------------------------
--  DDL for Package POS_TOTALS_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_TOTALS_PO_SV" AUTHID CURRENT_USER as
/* $Header: POSPOTOS.pls 120.1.12010000.3 2009/12/29 20:52:34 ankohli ship $ */

  FUNCTION get_po_total(X_header_id NUMBER)
	   return number;
  --pragma restrict_references (get_po_total,WNDS,RNPS,WNPS);

  FUNCTION get_release_total(X_release_id NUMBER)
	   return number;
  --pragma restrict_references (get_release_total,WNDS,RNPS,WNPS);

  FUNCTION get_po_archive_total(X_header_id NUMBER,
				X_revision_num NUMBER,
				X_doc_type VARCHAR)
	   return number;
   --pragma restrict_references (get_po_archive_total,WNDS,RNPS,WNPS);

  FUNCTION get_amount_ordered(X_header_id NUMBER,
				X_revision_num NUMBER,
				X_doc_type VARCHAR)
	   return number;
  pragma restrict_references (get_amount_ordered,WNDS,RNPS,WNPS);

  FUNCTION get_release_archive_total(X_release_id NUMBER,
				X_revision_num NUMBER)
	   return number;

FUNCTION get_line_total
	(x_po_header_id in number,
	 x_po_release_id in number,
	 x_po_line_id   number,
	 X_revision_num number default NULL) return number;


FUNCTION get_shipment_total
	(x_po_line_location_id   number,
	 X_revision_num number) return number;


PROCEDURE get_shipment_amounts (
	p_po_line_location_id	IN  NUMBER,
	p_revision_num 		IN  NUMBER,
	p_amount_ordered	OUT NOCOPY NUMBER,
	p_amount_received	OUT NOCOPY NUMBER,
	p_amount_billed		OUT NOCOPY NUMBER);

FUNCTION get_po_total_received (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER;

--bug 9208080: adding new function to get total_quantity_received

FUNCTION get_po_total_quantity_received (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER;

FUNCTION get_po_total_invoiced (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER;

--bug 9208080: adding new function to get total_quantity_invoiced

FUNCTION get_po_total_quantity_invoiced (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER;

FUNCTION get_po_payment_status (p_po_header_id 	NUMBER,
				p_po_release_id	NUMBER )
RETURN VARCHAR2;


FUNCTION get_ship_payment_status (p_line_location_id 	NUMBER)
RETURN VARCHAR2;


END POS_TOTALS_PO_SV;

/
