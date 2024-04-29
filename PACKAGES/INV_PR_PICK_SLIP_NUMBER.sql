--------------------------------------------------------
--  DDL for Package INV_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PR_PICK_SLIP_NUMBER" AUTHID CURRENT_USER AS
  /* $Header: INVPRPNS.pls 120.2 2005/10/10 07:30:39 methomas noship $ */

  --
  -- Package
  --        INV_PR_PICK_SLIP_NUMBER
  --
  -- Purpose
  --   This package does the following:
  --   - Initialize variables to be used in determining the how to group pick slips.
  --   - Get pick slip number
  --

  -- Used only by Shipping related GET_PICK_SLIP_NUMBER
/* FP-J PAR Replenishment Count:
      Introduced four new columns dest_subinventory, dest_locator_id, project_id,
      task_id to the RECORD TYPE. */
  TYPE keyrectyp IS RECORD
  ( grouping_rule_id              NUMBER
  , header_id                     NUMBER
  , customer_id                   NUMBER
  , ship_method_code              VARCHAR2(30)
  , ship_to_loc_id                NUMBER
  , shipment_priority             VARCHAR2(30)
  , subinventory                  VARCHAR2(10)
  , dest_subinventory             VARCHAR2(10)
  , dest_locator_id               NUMBER
  , project_id                    NUMBER
  , task_id                       NUMBER
  , trip_stop_id                  NUMBER
  , delivery_id                   NUMBER
  , inventory_item_id             NUMBER
  , locator_id                    NUMBER
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  , lot_number                    VARCHAR2(80)
  , revision                      VARCHAR2(3)
  , organization_id               NUMBER
  , pick_slip_number              NUMBER
  , counter                       NUMBER);

  TYPE keytabtyp IS TABLE OF keyrectyp
    INDEX BY BINARY_INTEGER;

  g_pskey_table         keytabtyp;
  g_order_pick_method   VARCHAR2(1) := '1';
  g_zone_pick_method    VARCHAR2(1) := '2';
  g_cluster_pick_method VARCHAR2(1) := '3';
  g_bulk_pick_method    VARCHAR2(1) := '4';

  --
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER (Used by Shipping)
  --
  -- Purpose
  --   Returns Pick Slip Number and whether a Pick Slip should be printed. This
  --   overloaded procedure is used by Shipping.
  --
  -- Input Parameters
  --   p_ps_mode               => Pick Slip Print Mode: I = Immediate, E = Deferred
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_header_id             => Order Header ID
  --   p_customer_id           => Customer ID
  --   p_ship_method_code      => Ship Method
  --   p_ship_to_loc_id        => Ship to Location
  --   p_shipment_priority     => Shipment Priority
  --   p_subinventory          => SubInventory
  --   p_trip_stop_id          => Trip Stop
  --   p_delivery_id           => Delivery
  --   p_inventory_item_id     => Inventory Item ID
  --   p_locator_id            => Locator ID
  --   p_lot_number            => Lot Number
  --   p_revision              => Revision
/* FP-J PAR Replenishment Count:
      Introduced four new DEFAULT NULL inputs dest_subinventory, dest_locator_id,
      project_id, task_id to the signature of the procedure. */
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id
  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_ready_to_print        => FND_API.G_TRUE or FND_API.G_FALSE
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message
  --
  PROCEDURE get_pick_slip_number
  ( p_ps_mode               IN     VARCHAR2
  , p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_header_id             IN     NUMBER
  , p_customer_id           IN     NUMBER
  , p_ship_method_code      IN     VARCHAR2
  , p_ship_to_loc_id        IN     NUMBER
  , p_shipment_priority     IN     VARCHAR2
  , p_subinventory          IN     VARCHAR2
  , p_trip_stop_id          IN     NUMBER
  , p_delivery_id           IN     NUMBER
  , p_inventory_item_id     IN     NUMBER DEFAULT NULL
  , p_locator_id            IN     NUMBER DEFAULT NULL
  , p_lot_number            IN     VARCHAR2 DEFAULT NULL
  , p_revision              IN     VARCHAR2 DEFAULT NULL
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_ready_to_print        OUT    NOCOPY VARCHAR2
  , x_call_mode             OUT    NOCOPY VARCHAR2
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
  , p_dest_subinventory     IN     VARCHAR2 DEFAULT NULL
  , p_dest_locator_id       IN     NUMBER DEFAULT NULL
  , p_project_id            IN     NUMBER DEFAULT NULL
  , p_task_id               IN     NUMBER DEFAULT NULL
);

  --
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER (Used by Component Picking (WIP))
  --
  -- Purpose
  --   Returns Pick Slip Number. This overloaded procedure is used for WIP.
  --
  -- Input Parameters
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_wip_entity_id         => WIP Entity ID
  --   p_rep_schedule_id       => Repetitive Schedule ID
  --   p_operation_seq_num     => Operation Sequence Number
  --   p_dept_id               => Department ID
  --   p_push_or_pull          => Push or Pull
  --   p_supply_subinventory   => Supply SubInventory
  --   p_supply_locator_id     => Supply Locator ID
  --   p_project_id            => Project ID
  --   p_task_id               => Task ID
  --   p_src_subinventory      => Source SubInventory
  --   p_src_locator_id        => Source Locator ID
  --   p_inventory_item_id     => Inventory Item ID
  --   p_revision              => Revision
  --   p_lot_number            => Lot Number
  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message
  --
  PROCEDURE get_pick_slip_number
  ( p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_wip_entity_id         IN     NUMBER
  , p_rep_schedule_id       IN     NUMBER DEFAULT NULL
  , p_operation_seq_num     IN     NUMBER
  , p_dept_id               IN     NUMBER
  , p_push_or_pull          IN     VARCHAR2
  , p_supply_subinventory   IN     VARCHAR2 DEFAULT NULL
  , p_supply_locator_id     IN     NUMBER DEFAULT NULL
  , p_project_id            IN     NUMBER DEFAULT NULL
  , p_task_id               IN     NUMBER DEFAULT NULL
  , p_src_subinventory      IN     VARCHAR2
  , p_src_locator_id        IN     NUMBER DEFAULT NULL
  , p_inventory_item_id     IN     NUMBER
  , p_revision              IN     VARCHAR2 DEFAULT NULL
  , p_lot_number            IN     VARCHAR2 DEFAULT NULL
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
  );

  --
  -- Name
  --   PROCEDURE PRINT_PICK_SLIP (Used by Component Picking (WIP))
  --
  -- Purpose
  --   Submits the Concurrent Request to print the Move Order Pick Slip Report.
  --
  -- Input Parameters
  --   p_organization_id       => Organization ID
  --   p_mo_request_number     => Move Order Request Number
  --
  -- Output Parameters
  --   x_request_id            => Concurrent Request ID
  --   x_return_status         => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_msg_data              => Error Messages
  --   x_msg_count             => Error Messages Count
  FUNCTION print_pick_slip
  ( x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , p_organization_id       NUMBER
  , p_mo_request_number     NUMBER
  , p_plan_tasks            BOOLEAN
  )
  RETURN NUMBER;

  --
  -- Name
  --   PROCEDURE DELETE_WIP_PS_TBL
  --
  -- Purpose
  --   Deletes the global PL/SQL table used to store pick slip numbers
  --   This is called at the end of component pick release
  --
  -- Input Parameters
  --   None
  --
  -- Output Parameters
  --   None
  PROCEDURE delete_wip_ps_tbl;

  --
  -- Name
  --   PROCEDURE GET_PICK_SLIP_NUMBER_PARALLEL
  --
  -- Purpose
  --   Returns Pick Slip Number and whether a Pick Slip should be printed. This
  --   procedure used by Shipping in pick-release parallel mode
  --     WSH_PICK_LIST.G_PICK_REL_PARALLEL = TRUE.
  --
  -- Input Parameters
  --   p_ps_mode               => Pick Slip Print Mode: I = Immediate, E = Deferred
  --   p_pick_grouping_rule_id => Pick Grouping Rule ID
  --   p_org_id                => Organization ID
  --   p_header_id             => Order Header ID
  --   p_customer_id           => Customer ID
  --   p_ship_method_code      => Ship Method
  --   p_ship_to_loc_id        => Ship to Location
  --   p_shipment_priority     => Shipment Priority
  --   p_subinventory          => SubInventory
  --   p_trip_stop_id          => Trip Stop
  --   p_delivery_id           => Delivery
  --   p_inventory_item_id     => Inventory Item ID
  --   p_locator_id            => Locator ID
  --   p_lot_number            => Lot Number
  --   p_revision              => Revision
  --   p_dest_subinventory     => Destination Subinventory
  --   p_dest_locator_id       => Destination Locator Id
  --   p_project_id            => Project Id
  --   p_task_id               => Task Id
  --
  -- Output Parameters
  --   x_pick_slip_number      => Pick Slip Number
  --   x_ready_to_print        => FND_API.G_TRUE or FND_API.G_FALSE
  --   x_api_status            => FND_API.G_RET_STS_SUCESSS or
  --                              FND_API.G_RET_STS_ERROR
  --   x_error_message         => Error message
  --

  PROCEDURE GET_PICK_SLIP_NUMBER_PARALLEL
  ( p_ps_mode               IN     VARCHAR2
  , p_pick_grouping_rule_id IN     NUMBER
  , p_org_id                IN     NUMBER
  , p_header_id             IN     NUMBER
  , p_customer_id           IN     NUMBER
  , p_ship_method_code      IN     VARCHAR2
  , p_ship_to_loc_id        IN     NUMBER
  , p_shipment_priority     IN     VARCHAR2
  , p_subinventory          IN     VARCHAR2
  , p_trip_stop_id          IN     NUMBER
  , p_delivery_id           IN     NUMBER
  , p_inventory_item_id     IN     NUMBER DEFAULT NULL
  , p_locator_id            IN     NUMBER DEFAULT NULL
  , p_lot_number            IN     VARCHAR2 DEFAULT NULL
  , p_revision              IN     VARCHAR2 DEFAULT NULL
  , x_pick_slip_number      OUT    NOCOPY NUMBER
  , x_ready_to_print        OUT    NOCOPY VARCHAR2
  , x_call_mode             OUT    NOCOPY VARCHAR2
  , x_api_status            OUT    NOCOPY VARCHAR2
  , x_error_message         OUT    NOCOPY VARCHAR2
  , p_dest_subinventory     IN     VARCHAR2
  , p_dest_locator_id       IN     NUMBER
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  );


END inv_pr_pick_slip_number;

 

/
