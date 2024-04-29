--------------------------------------------------------
--  DDL for Package OE_RESERVE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RESERVE_CONC" AUTHID CURRENT_USER as
/* $Header: OEXCRSVS.pls 120.3.12010000.2 2008/11/11 08:12:34 rmoharan ship $ */

OESCH_ACT_RESERVE            CONSTANT VARCHAR2(30) := 'RESERVE';

/* Valid Scheduling Status.  */

SCH_LEVEL_ONE       CONSTANT VARCHAR2(30) :=  'ONE';
SCH_LEVEL_TWO       CONSTANT VARCHAR2(30) :=  'TWO';
SCH_LEVEL_THREE     CONSTANT VARCHAR2(30) :=  'THREE';
SCH_LEVEL_FOUR     CONSTANT VARCHAR2(30)  :=  'FOUR';
SCH_LEVEL_FIVE     CONSTANT VARCHAR2(30)  :=  'FIVE';

/* API message record type */

TYPE Res_Rec_Type IS RECORD
(line_id                   NUMBER,      -- Internal Line id
 header_id                 NUMBER,      -- Internal Header Id
 inventory_item_id         NUMBER,      -- Item being processed
 ordered_qty               NUMBER,      -- Ordered Quantity on the line
 ordered_qty_UOM           VARCHAR2(3), -- Ordered qty Uom on the line
 derived_reserved_qty      NUMBER,      -- Derived reservation qty based on the logic
 ordered_qty2              NUMBER,      -- Ordered Quantity2 on the line -- INVCONV
 ordered_qty_UOM2          VARCHAR2(3), -- Ordered qty Uom2 on the line  -- INVCONV
 derived_reserved_qty2     NUMBER,      -- Derived reservation qty based on the logic -- INVCONV
 reserved_qty_UOM          VARCHAR2(3), -- Derived reservation qty2 UOM
 ship_from_org_id          NUMBER,      -- Warehouse on the line
 subinventory              VARCHAR2(10),-- Subinventory on the line
 schedule_ship_date        DATE,        -- Schedule ship date  on the line
 corrected_reserved_qty    NUMBER,      -- Customer can correct the derived qty
 corrected_reserved_qty2   NUMBER,      -- Customer can correct the derived qty2 -- INVCONV
 source_document_type_id   NUMBER,
 order_source_id           NUMBER,      -- For internal use only
 orig_sys_document_ref     VARCHAR2(50),-- For internal use only
 orig_sys_line_ref         VARCHAR2(50),-- For internal use only
 orig_sys_shipment_ref     VARCHAR2(50),-- For internal use only
 change_sequence           VARCHAR2(50),-- For internal use only
 source_document_id        NUMBER,      -- For internal use only
 source_document_line_id   NUMBER,      -- For internal use only
 shipped_quantity          NUMBER,      -- For internal use only
 shipped_quantity2         NUMBER,      -- For internal use only  -- INVCONV
 reservation_exists        VARCHAR2(1), -- For internal use only
 derived_reserved_qty_mir  NUMBER,       -- For internal use only
 derived_reserved_qty2_mir  NUMBER,      -- For internal use only  -- INVCONV
 org_id                    NUMBER        -- MOAC: 4759251
);

TYPE Rsv_Tbl_Type IS TABLE OF Res_Rec_Type
INDEX BY BINARY_INTEGER;


Procedure Reserve
(ERRBUF                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 RETCODE                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 /* Moac */
 p_org_id                       IN NUMBER,
 p_use_reservation_time_fence       IN CHAR,
 p_order_number_low             IN NUMBER,
 p_order_number_high            IN NUMBER,
 p_customer_id                  IN VARCHAR2,
 p_order_type                   IN VARCHAR2,
 p_line_type_id                 IN VARCHAR2,
 p_warehouse                    IN VARCHAR2,
 p_inventory_item_id            IN VARCHAR2,
 p_request_date_low             IN VARCHAR2,
 p_request_date_high            IN VARCHAR2,
 p_schedule_ship_date_low       IN VARCHAR2,
 p_schedule_ship_date_high      IN VARCHAR2,
 p_schedule_arrival_date_low    IN VARCHAR2,
 p_schedule_arrival_date_high   IN VARCHAR2,
 p_ordered_date_low             IN VARCHAR2,
 p_ordered_date_high            IN VARCHAR2,
 p_demand_class_code            IN VARCHAR2,
 p_planning_priority            IN NUMBER,
 p_booked                       IN VARCHAR2  DEFAULT NULL,
 p_reservation_mode             IN VARCHAR2  DEFAULT NULL,
 p_dummy1                       IN VARCHAR2  DEFAULT NULL,
 p_dummy2                       IN VARCHAR2  DEFAULT NULL,
 p_percent                      IN NUMBER    DEFAULT NULL,
 p_shipment_priority            IN VARCHAR2  DEFAULT NULL,
 p_reserve_run_type             IN VARCHAR2  DEFAULT NULL,
 p_reserve_set_name             IN VARCHAR2  DEFAULT NULL,
 p_override_set                 IN VARCHAR2  DEFAULT NULL,
 p_order_by                     IN VARCHAR2,
 p_selected_ids                 IN VARCHAR2  DEFAULT NULL,
 p_dummy3                       IN VARCHAR2  DEFAULT NULL,
 p_partial_preference           IN VARCHAR2  DEFAULT 'N'
);

Procedure Reserve_Eligible
 ( p_line_rec      		IN OE_ORDER_PUB.line_rec_type,
   p_use_reservation_time_fence	IN VARCHAR2,
   x_return_status 		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

Procedure Create_Reservation
(p_line_rec	 IN OE_ORDER_PUB.line_rec_type,
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


Procedure Calculate_Percentage
 ( p_inventory_item_id IN NUMBER,
   p_ship_from_org_id  IN NUMBER,
   p_subinventory      IN VARCHAR2,
   p_rsv_tbl           IN OE_RESERVE_CONC.rsv_tbl_type,
   x_percentage        OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_primary_uom       OUT NOCOPY VARCHAR2 -- 4695715
  );

Procedure Create_Reservation
(p_x_rsv_tbl      IN OUT NOCOPY OE_RESERVE_CONC.rsv_tbl_type,
 p_partial_reservation IN VARCHAR2 DEFAULT FND_API.G_TRUE,
 x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END OE_RESERVE_CONC;

/
