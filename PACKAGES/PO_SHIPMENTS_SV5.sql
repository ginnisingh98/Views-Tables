--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV5" AUTHID CURRENT_USER AS
/* $Header: POXPOS5S.pls 115.3 2003/12/16 01:59:40 sbull ship $*/





   PROCEDURE val_source_line_num
   			(X_entity_level 		IN VARCHAR2,
			 X_po_line_id 			IN NUMBER,
			 X_line_location_id		IN NUMBER,
			 X_shipment_type		IN VARCHAR2,
			 X_item_id			IN NUMBER,
			 X_inventory_organization_id	IN NUMBER,
                         X_line_type_id	                IN NUMBER,
			 X_quantity_ordered		IN OUT NOCOPY NUMBER,
			 X_line_type			IN OUT NOCOPY VARCHAR2,
                         X_outside_operation_flag	IN OUT NOCOPY VARCHAR2,
			 X_receiving_flag		IN OUT NOCOPY VARCHAR2,
                         X_planned_item_flag            IN OUT NOCOPY VARCHAR2,
                         X_outside_op_uom_type          IN OUT NOCOPY VARCHAR2,
                         X_invoice_close_tolerance      IN OUT NOCOPY NUMBER,
                         X_receive_close_tolerance      IN OUT NOCOPY NUMBER,
                         X_receipt_required_flag        IN OUT NOCOPY VARCHAR2,
                         X_stock_enabled_flag           IN OUT NOCOPY VARCHAR2,
                         X_total_line_quantity          IN OUT NOCOPY NUMBER );


   PROCEDURE val_source_ship_num
   		      (X_entity_level            IN     VARCHAR2,
                       X_set_of_books_id         IN     NUMBER,
		       X_line_id                 IN     NUMBER,
		       X_line_location_id        IN     NUMBER,
		       X_shipment_type           IN     VARCHAR2,
		       X_quantity_ordered        IN     NUMBER,
		       X_source_shipment_id      IN     NUMBER,
                       X_ship_to_location_code   IN OUT NOCOPY VARCHAR2,
		       X_ship_to_location_id     IN OUT NOCOPY NUMBER,
		       X_ship_to_org_code        IN OUT NOCOPY VARCHAR2,
		       X_ship_to_organization_id IN OUT NOCOPY NUMBER,
		       X_quantity                IN OUT NOCOPY NUMBER,
		       X_price_override		 IN OUT NOCOPY NUMBER,
		       X_promised_date	         IN OUT NOCOPY DATE,
		       X_need_by_date            IN OUT NOCOPY DATE,
		       X_taxable_flag 		 IN OUT NOCOPY VARCHAR2,
		       X_tax_name                IN OUT NOCOPY VARCHAR2,
                       X_enforce_ship_to_location   IN OUT NOCOPY VARCHAR2,
                       X_allow_substitute_receipts  IN OUT NOCOPY VARCHAR2,
                       X_receiving_routing_id       IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_tolerance          IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_exception_code     IN OUT NOCOPY VARCHAR2  ,
                       X_days_early_receipt_allowed IN OUT NOCOPY NUMBER ,
                       X_last_accept_date        IN OUT NOCOPY DATE,
		       X_days_late_receipt_allowed  IN OUT NOCOPY NUMBER  ,
                       X_receipt_days_exception_code IN OUT NOCOPY VARCHAR2  ,
                       X_invoice_close_tolerance IN OUT NOCOPY NUMBER,
		       X_receive_close_tolerance IN OUT NOCOPY NUMBER,
		       X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
		       X_receipt_required_flag   IN OUT NOCOPY VARCHAR2,
		       X_inspection_required_flag IN OUT NOCOPY VARCHAR2,
		       X_val_sched_released_qty  IN OUT NOCOPY VARCHAR2);


END PO_SHIPMENTS_SV5;

 

/
