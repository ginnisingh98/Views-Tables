--------------------------------------------------------
--  DDL for Package WMS_PICKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PICKING_PKG" AUTHID CURRENT_USER AS
  /* $Header: WMSPLPDS.pls 120.7.12010000.4 2009/07/30 14:38:41 pbonthu ship $ */


  g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_PICKING_PKG';

  TYPE task_status_table_type IS TABLE OF NUMBER INDEX BY LONG;   --For bug 8552027
  g_previous_task_status task_status_table_type;

  TYPE task_start_over_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_start_over_tempid task_start_over_table_type;

  TYPE t_genref IS REF CURSOR;

  PROCEDURE change_task_to_active(p_transaction_temp_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

  --
  -- Name
  --   PROCEDURE GET_NEXT_TASK_INFO
  --
  -- Purpose
  --   Gets the task information.
  --
  -- Input Parameters
  --   p_sign_on_emp_id       => Employee ID
  --   p_sign_on_org_id       => Organization ID
  --   p_transaction_temp_id  => Transaction Temp ID (For Manual Pick)
  --   p_cartonization_id     => Cartonization ID (For Label Picking)
  --   p_device_id            => Device ID
  --   p_is_cluster_pick      => Cluster Pick or not
  --   p_cartons_list         => Carton Grouping ID List (For Cluster Picking)
  --
  -- Output Parameters
  --   x_task_info            => Ref Cursor containing the Task Information
  --   x_return_status        => FND_API.G_RET_STS_SUCESSS or
  --                             FND_API.G_RET_STS_ERROR
  --   x_error_code           => Code indicating the error message.
  --   x_error_mesg           => Error Messages
  --   x_mesg_count           => Error Messages Count

  PROCEDURE get_next_task_info(
    p_sign_on_emp_id      IN            NUMBER
  , p_sign_on_org_id      IN            NUMBER
  , p_transaction_temp_id IN            NUMBER := NULL
  , p_cartonization_id    IN            NUMBER := NULL
  , p_device_id           IN            NUMBER := NULL
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_error_code          OUT NOCOPY    NUMBER
  , x_mesg_count          OUT NOCOPY    NUMBER
  , x_error_mesg          OUT NOCOPY    VARCHAR2
  , x_task_info           OUT NOCOPY    t_genref
  , p_is_cluster_pick     IN            VARCHAR2 := 'N'
  , p_cartons_list        IN            VARCHAR2 := ' (-999) '
   , p_is_manifest_pick     IN           VARCHAR2 := 'N'  --Added for Case Picking Project
  );


  --
  -- Name
  --   PROCEDURE GET_TASKS
  --
  -- Purpose
  --   Gets a list of Tasks given the LPN and Organization.
  --   Changed as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_organization_id   => Organization ID
  --   p_transfer_lpn_id   => LPN ID
  --
  -- Output Parameters
  --   x_tasks             => Ref Cursor containing the Tasks
  --   x_drop_type         => Either MFG or OTHERS depending on whether LPN has Mfg Picks or not
  --   x_multiple_drops    => Number of drop locations for Mfg Picks
  --   x_drop_lpn_option   => Drop LPN Option
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR

  PROCEDURE get_tasks(
    x_tasks           OUT NOCOPY    t_genref
  , x_drop_type       OUT NOCOPY    VARCHAR2
  , x_multiple_drops  OUT NOCOPY    VARCHAR2
  , x_drop_lpn_option OUT NOCOPY    NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , p_organization_id IN            NUMBER
  , p_transfer_lpn_id IN            NUMBER
  );


  --
  -- Name
  --   PROCEDURE GET_LOT_NUMBER_INFO
  --
  -- Purpose
  --   Gets the list of all Lots and its Quantity for the passed in list of Transaction Temp IDs.
  --   Added as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_txn_temp_id_list  => Comma delimited Transaction Temp ID List
  --
  -- Output Parameters
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR
  --   x_lot_num_list      => Comma delimited Lot Number List
  --   x_lot_qty_list      => Comma delimited Lot Qty List
  --   x_display_serials   => Whether Serials are associated with the Txn Temp ID list.

  PROCEDURE get_lot_number_info(
    x_return_status    OUT NOCOPY    VARCHAR2
  , x_lot_num_list     OUT NOCOPY    VARCHAR2
  , x_lot_qty_list     OUT NOCOPY    VARCHAR2
  , x_display_serials  OUT NOCOPY    VARCHAR2
  , p_txn_temp_id_list IN            VARCHAR2
  );

  --
  -- Name
  --   PROCEDURE GET_SERIAL_NUMBERS
  --
  -- Purpose
  --   Gets the list of all Serials for the passed in list of Transaction Temp IDs. If Lot is given
  --   the list contains Serials belonging to that Lot alone.
  --   Added as part of Bug#2666620. Refer it for any information.
  --
  -- Input Parameters
  --   p_txn_temp_id_list  => Comma delimited Transaction Temp ID List
  --   p_lot_number        => Lot Number
  --
  -- Output Parameters
  --   x_return_status     => FND_API.G_RET_STS_SUCESSS or
  --                          FND_API.G_RET_STS_ERROR
  --   x_serial_list       => Comma Delimited Serial List
  PROCEDURE get_serial_numbers(
    x_return_status    OUT NOCOPY    VARCHAR2
  , x_serial_list      OUT NOCOPY    VARCHAR2
  , p_txn_temp_id_list IN            VARCHAR2
  , p_lot_number       IN            VARCHAR2
  );

  PROCEDURE next_task
    (p_employee_id              IN NUMBER,
     p_effective_start_date     IN DATE,
     p_effective_end_date       IN DATE,
     p_organization_id          IN NUMBER,
     p_subinventory_code        IN VARCHAR2,
     p_equipment_id             IN NUMBER,
     p_equipment_serial         IN VARCHAR2,
     p_number_of_devices        IN NUMBER,
     p_device_id                IN NUMBER,
     p_task_filter              IN VARCHAR2,
     p_task_method              IN VARCHAR2,
     p_prioritize_dispatched_tasks IN VARCHAR2 := 'N',	-- BugFix 4560814
     p_retain_dispatch_task	IN VARCHAR2 := 'N', -- BugFix 4560814
     p_allow_unreleased_task    IN VARCHAR2     :='Y', -- for manual picking only bug 4718145
     p_max_clusters             IN NUMBER := null, -- added for cluster picking
     p_dispatch_needed          IN VARCHAR2 := 'Y', -- added for cluster picking
     x_grouping_document_type   IN OUT nocopy VARCHAR2,
     x_grouping_document_number IN OUT nocopy NUMBER,
     x_grouping_source_type_id  IN OUT nocopy NUMBER,
     x_is_changed_group         IN OUT nocopy VARCHAR2,
     x_task_info                OUT nocopy t_genref,
     x_task_number              OUT nocopy NUMBER,
     x_num_of_tasks             OUT nocopy NUMBER,
     x_task_type_id             OUT nocopy NUMBER,
     x_avail_device_id          OUT nocopy NUMBER,
     x_device_request_id        OUT nocopy NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

  TYPE task_cursor_type IS REF CURSOR;


  TYPE task_record_type IS RECORD
    (transaction_temp_id   NUMBER,
     subinventory_code     VARCHAR2(10),
     locator_id            NUMBER,
     revision              VARCHAR2(3),
     transaction_uom       VARCHAR2(10),
     transaction_quantity  NUMBER,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     lot_number            VARCHAR2(80),
     task_type             NUMBER,
     priority              NUMBER,
     operation_plan_id     NUMBER,
     standard_operation_id NUMBER,
     effective_start_date  DATE,
     effective_end_date    DATE,
     person_resource_id    NUMBER,
     machine_resource_id   NUMBER,
     move_order_line_id    NUMBER);


    --Start Additions for Bug 6682436

    new_task_table wms_Task_mgmt_pub.new_task_tbl;

    PROCEDURE split_mmtt_lpn(
    p_transaction_temp_id   IN        NUMBER
  , p_line_quantity         IN        NUMBER
  , p_transaction_UOM       IN        VARCHAR2
  , p_lpn_id		    IN	      NUMBER
  , l_transaction_temp_id   OUT	NOCOPY      NUMBER
   ,x_return_status         OUT       NOCOPY VARCHAR2
   ,x_msg_count             OUT       NOCOPY NUMBER
   ,x_msg_data              OUT       NOCOPY VARCHAR2
  );

 PROCEDURE split_task( p_source_transaction_number IN NUMBER DEFAULT NULL,
		      p_split_quantities IN wms_Task_mgmt_pub.TASK_QTY_TBL_TYPE ,
		      p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		      x_resultant_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
		      x_resultant_task_details OUT NOCOPY wms_Task_mgmt_pub.TASK_DETAIL_TBL_TYPE ,
		      x_return_status OUT NOCOPY VARCHAR2 ,
		      x_msg_count OUT NOCOPY NUMBER ,
		      x_msg_data OUT NOCOPY VARCHAR2 );

PROCEDURE validate_quantities( p_transaction_temp_id IN NUMBER ,
        p_split_quantities   IN wms_Task_mgmt_pub.task_qty_tbl_type ,
        x_lot_control_code OUT   NOCOPY  NUMBER ,
        x_serial_control_code OUT NOCOPY NUMBER ,
        x_split_uom_quantities OUT NOCOPY wms_Task_mgmt_pub.qty_changed_tbl_type ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT NOCOPY     VARCHAR2 ,
        x_msg_count OUT NOCOPY    VARCHAR2 );

PROCEDURE split_mmtt( p_orig_transaction_temp_id IN NUMBER ,
        p_new_transaction_temp_id                IN NUMBER ,
        p_new_transaction_header_id              IN NUMBER ,
        p_new_mol_id                             IN NUMBER ,
        p_transaction_qty_to_split               IN NUMBER ,
        p_primary_qty_to_split                   IN NUMBER ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT NOCOPY     VARCHAR2 ,
        x_msg_count OUT NOCOPY    VARCHAR2 );

PROCEDURE split_wdt( p_new_task_id IN NUMBER ,
        p_new_transaction_temp_id  IN NUMBER ,
        p_new_mol_id               IN NUMBER ,
        p_orig_transaction_temp_id IN NUMBER ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT NOCOPY     VARCHAR2 ,
        x_msg_count OUT  NOCOPY   VARCHAR2 );

PROCEDURE split_lot_serial( p_orig_transaction_temp_id IN NUMBER ,
        p_new_transaction_temp_id                      IN NUMBER ,
        p_transaction_qty_to_split                     IN NUMBER ,
        p_primary_qty_to_split                         IN NUMBER ,
        p_inventory_item_id                            IN NUMBER ,
        p_organization_id                              IN NUMBER ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT  NOCOPY    VARCHAR2 ,
        x_msg_count OUT NOCOPY    VARCHAR2 );

PROCEDURE split_serial( p_orig_transaction_temp_id IN NUMBER ,
        p_new_transaction_temp_id                  IN NUMBER ,
        p_transaction_qty_to_split                 IN NUMBER ,
        p_primary_qty_to_split                     IN NUMBER ,
        p_inventory_item_id                        IN NUMBER ,
        p_organization_id                          IN NUMBER ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT   NOCOPY   VARCHAR2 ,
        x_msg_count OUT  NOCOPY   VARCHAR2 );

PROCEDURE split_mtlt ( p_new_transaction_temp_id IN NUMBER ,
        p_transaction_qty_to_split               IN NUMBER ,
        p_primary_qty_to_split                   IN NUMBER ,
        p_row_id                                 IN ROWID ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_data OUT   NOCOPY   VARCHAR2 ,
        x_msg_count OUT  NOCOPY   VARCHAR2 );
--End Additions for Bug 6682436
--Begin of Bug: 7254397
TYPE numset_t IS TABLE OF NUMBER;
TYPE numset_tabType IS TABLE OF NUMBER
                INDEX BY BINARY_INTEGER;
PROCEDURE insert_cartonization_id (
     p_lpn_id                   IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

FUNCTION list_cartonization_id RETURN numset_t PIPELINED;

PROCEDURE clear_cartonization_id(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);
--End of Bug: 7254397
FUNCTION get_total_lpns RETURN NUMBER;



--Added for Case Picking Project start

FUNCTION list_order_numbers RETURN numset_t PIPELINED;
FUNCTION list_pick_slip_numbers RETURN numset_t PIPELINED;

PROCEDURE insert_order_numbers (
     p_order_number             IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

PROCEDURE insert_pick_slip_number (
     p_pick_slip_number         IN NUMBER,
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

PROCEDURE clear_order_numbers(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

PROCEDURE clear_pick_slip_number(
     x_return_status            OUT nocopy VARCHAR2,
     x_msg_count                OUT nocopy NUMBER,
     x_msg_data                 OUT nocopy VARCHAR2);

--Added for Case Picking Project end


END wms_picking_pkg;

/
