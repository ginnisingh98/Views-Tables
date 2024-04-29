--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV9" AUTHID CURRENT_USER AS
/* $Header: POXPOS9S.pls 115.3 2003/12/16 01:37:24 sbull ship $*/

  PROCEDURE test_get_shipment_num
		      (X_po_release_id IN     NUMBER,
		       X_po_line_id    IN     NUMBER);
  PROCEDURE test_get_planned_ship_info (X_source_shipment_id IN NUMBER,
                                        X_set_of_books_id    IN NUMBER);
  PROCEDURE test_get_sched_released_qty
		      (X_source_id            IN     NUMBER,
		       X_entity_level         IN     VARCHAR2,
		       X_shipment_type        IN     VARCHAR2);
  PROCEDURE test_get_number_shipments
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2);
   PROCEDURE test_val_release_shipments(X_po_line_id       IN NUMBER,
				        X_shipment_type IN VARCHAR2);
  PROCEDURE test_get_line_location_id
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2);
  PROCEDURE test_get_shipment_status
                      (X_po_line_id IN NUMBER,
		       X_shipment_type IN VARCHAR2);
  PROCEDURE test_val_ship_qty
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2,
		       X_line_quantity        IN     NUMBER);
  PROCEDURE test_val_ship_price
		      (X_po_line_id           IN NUMBER,
		       X_shipment_type     IN VARCHAR2,
		       X_unit_price           IN NUMBER);
  PROCEDURE test_val_approval_status(
                       X_shipment_id             IN NUMBER,
		       X_shipment_type           IN VARCHAR2,
		       X_quantity                IN NUMBER,
		       X_ship_to_location_id     IN NUMBER,
		       X_promised_date           IN DATE,
		       X_need_by_date            IN DATE,
		       X_shipment_num            IN NUMBER,
		       X_last_accept_date        IN DATE,
		       X_taxable_flag            IN VARCHAR2,
		       X_ship_to_organization_id IN NUMBER,
		       X_price_discount          IN NUMBER,
		       X_price_override          IN NUMBER,
		       X_tax_code_id		 IN NUMBER);
  PROCEDURE test_source_line_server_cover
			(X_entity_level 		IN VARCHAR2,
			 X_po_line_id 			IN NUMBER,
			 X_line_location_id		IN NUMBER,
			 X_shipment_type		IN VARCHAR2,
			 X_quantity_ordered		IN NUMBER,
                         X_line_type_id                 IN NUMBER,
                         X_item_id                      IN NUMBER,
                         X_inventory_org_id             IN NUMBER);

  PROCEDURE test_val_start_dates
		(X_start_date		IN	DATE,
		 X_po_header_id		IN	NUMBER);

  PROCEDURE test_val_end_dates
		(X_end_date		IN	DATE,
		 X_po_header_id		IN	NUMBER);

END PO_SHIPMENTS_SV9;

 

/
