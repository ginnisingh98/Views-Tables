--------------------------------------------------------
--  DDL for Package GME_RESERVE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESERVE_CONC" AUTHID CURRENT_USER as
/* $Header: GMECRSVS.pls 120.0 2007/12/24 19:42:22 srpuri noship $ */

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


Procedure Make_to_Order
(ERRBUF                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 RETCODE                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 /* Moac */
 p_org_id                       IN NUMBER,
 p_use_reservation_time_fence   IN CHAR,
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
 p_line_id                      IN NUMBER    DEFAULT NULL
);

Procedure Reserve_Eligible
 ( p_line_rec      		IN OE_ORDER_PUB.line_rec_type,
   p_use_reservation_time_fence	IN VARCHAR2,
   x_return_status 		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

PROCEDURE set_parameter_for_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );

END GME_RESERVE_CONC;

/
