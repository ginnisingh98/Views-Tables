--------------------------------------------------------
--  DDL for Package WSH_SHIPPING_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPPING_CONSTRAINTS_PKG" AUTHID CURRENT_USER as
/* $Header: WSHCSCPS.pls 120.0 2005/05/26 18:09:14 appldev noship $ */

TYPE ChangedAttributeRecType IS RECORD
		(original_source_line_id			NUMBER  ,
		source_header_id				NUMBER  ,
		source_line_id					NUMBER  ,
          hold_code						VARCHAR2(1)  ,
		sold_to_org_id					NUMBER  ,
		sold_to_contact_id				NUMBER  ,
          item_type_code					VARCHAR2(30)  ,
		ship_from_org_id				NUMBER  ,
		ship_to_org_id					NUMBER  ,
		ship_to_contact_id				NUMBER  ,
		deliver_to_org_id				NUMBER  ,
		deliver_to_contact_id			NUMBER  ,
		intmed_ship_to_org_id			NUMBER  ,
		intmed_ship_to_contact_id		NUMBER  ,
		ship_tolerance_above			NUMBER  ,
		ship_tolerance_below			NUMBER  ,
		ordered_quantity				NUMBER  ,
		order_quantity_uom				VARCHAR2(3)  ,
		subinventory					VARCHAR2(10)  ,
		revision						VARCHAR2(3)  ,
-- HW OPMCONV - Expand length of lot_number to 80
		lot_number					VARCHAR2(80)  ,
		customer_requested_lot_flag		VARCHAR2(1)  ,
		serial_number					VARCHAR2(30)  ,
		locator_id					NUMBER  ,
		date_requested					DATE ,
		date_scheduled					DATE ,
		master_container_item_id			NUMBER  ,
		detail_container_item_id			NUMBER  ,
		shipping_method_code			VARCHAR2(30)  ,
		carrier_id					NUMBER  ,
		freight_terms_code				VARCHAR2(30)  ,
		freight_carrier_code			VARCHAR2(30)  ,
		shipment_priority_code			VARCHAR2(30)  ,
		fob_code						VARCHAR2(30)  ,
		dep_plan_required_flag			VARCHAR2(1)  ,
		customer_prod_seq				VARCHAR2(50)  ,
		customer_dock_code				VARCHAR2(50)  ,
		cust_model_serial_number			VARCHAR2(50)  ,
		customer_job					VARCHAR2(50)  ,
		customer_production_line			VARCHAR2(50)  ,
		gross_weight					NUMBER  ,
		net_weight					NUMBER  ,
		weight_uom_code				VARCHAR2(3)  ,
		volume						NUMBER  ,
		volume_uom_code				VARCHAR2(3)  ,
		top_model_line_id				NUMBER  ,
		ship_set_id					NUMBER  ,
		ato_line_id					NUMBER  ,
	     arrival_set_id					NUMBER  ,
		ship_model_complete_flag			VARCHAR2(1)  ,
	     cust_po_number					VARCHAR2(50)  ,
		released_status				VARCHAR2(1)  ,
		action_flag					VARCHAR2(1)  ,
		shipped_flag            VARCHAR2(1)  ,
		packing_instructions			VARCHAR2(2000)  ,
		shipping_instructions			VARCHAR2(2000)  ,
		delivery_detail_id				NUMBER  ,
 -- hverddin 26-jun-2000 start of OPM changes
-- HW OPMCONV - No need for sublot_number
--        sublot_number                      VARCHAR2(32)  ,
          ordered_quantity2                  NUMBER  ,
          ordered_quantity_uom2              VARCHAR2(3)  ,
-- HW OPMCONV - Increage size of grade
          preferred_grade                    VARCHAR2(150)  ,
          lot_id                             NUMBER   ,
	  currency_code                      VARCHAR2(15)  ,
-- hverddin 26-jun-2000 end of OPM changes
          cycle_count_quantity               NUMBER    ,    -- added for Backordering
          cycle_count_quantity2              NUMBER    ,
	  transfer_lpn_id                    NUMBER    ,    -- added for cross-docking
		inspection_flag                    VARCHAR2(1)  ,   -- added for Contracts
		shipped_quantity                 NUMBER  ,
		shipped_quantity2                NUMBER  ,
	tracking_number               VARCHAR2(30)  ,
                customer_item_id                NUMBER         ,
-- modified per bug 1535895 - added code to handle the flexfields.
		attribute_category		VARCHAR2(150)  ,
		attribute1			VARCHAR2(150)  ,
		attribute2			VARCHAR2(150)  ,
		attribute3			VARCHAR2(150)  ,
		attribute4			VARCHAR2(150)  ,
		attribute5			VARCHAR2(150)  ,
		attribute6			VARCHAR2(150)  ,
		attribute7			VARCHAR2(150)  ,
		attribute8			VARCHAR2(150)  ,
		attribute9			VARCHAR2(150)  ,
		attribute10			VARCHAR2(150)  ,
		attribute11			VARCHAR2(150)  ,
		attribute12			VARCHAR2(150)  ,
		attribute13			VARCHAR2(150)  ,
		attribute14			VARCHAR2(150)  ,
		attribute15			VARCHAR2(150)  ,
		pickable_flag            VARCHAR2(1)  ,
		original_subinventory    VARCHAR2(10) ,
                line_number 		 VARCHAR2(150) , -- Bug 1610845
		picked_quantity		NUMBER ,	 -- overpicking bug 1848530
		picked_quantity2	NUMBER ,	 -- overpicking bug 1848530
		pending_quantity	NUMBER ,	 -- overpicking bug 1848530
		pending_quantity2	NUMBER , 	 -- overpicking bug 1848530
		trans_id                 NUMBER -- NC OPM changes BUG #1636578

);

TYPE ChangedAttributeTabType IS TABLE OF ChangedAttributeRecType
        INDEX BY BINARY_INTEGER;


PROCEDURE check_shipping_constraints
	(
	p_source_code            IN     VARCHAR2,
	p_changed_attributes      IN     ChangedAttributeRecType,
	x_return_status            OUT NOCOPY     VARCHAR2,
	x_action_allowed       OUT NOCOPY  VARCHAR2,
	x_action_message       OUT NOCOPY  VARCHAR2,
	x_ord_qty_allowed	       OUT NOCOPY  NUMBER,
	p_log_level              IN     NUMBER DEFAULT 0
	);

END  WSH_SHIPPING_CONSTRAINTS_PKG;

 

/
