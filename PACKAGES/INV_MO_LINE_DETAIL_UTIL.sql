--------------------------------------------------------
--  DDL for Package INV_MO_LINE_DETAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MO_LINE_DETAIL_UTIL" AUTHID CURRENT_USER AS
  /* $Header: INVUTLDS.pls 120.1 2005/10/02 14:15:04 dherring noship $ */
  --
  TYPE g_mmtt_rec IS RECORD(
    transaction_header_id          NUMBER
  , transaction_temp_id            NUMBER
  , source_code                    VARCHAR2(30)  := fnd_api.g_miss_char
  , source_line_id                 NUMBER
  , transaction_mode               NUMBER
  , lock_flag                      VARCHAR2(1)   := fnd_api.g_miss_char
  , last_update_date               DATE          := fnd_api.g_miss_date
  , last_updated_by                NUMBER
  , creation_date                  DATE          := fnd_api.g_miss_date
  , created_by                     NUMBER
  , last_update_login              NUMBER
  , request_id                     NUMBER
  , program_application_id         NUMBER
  , program_id                     NUMBER
  , program_update_date            DATE          := fnd_api.g_miss_date
  , inventory_item_id              NUMBER
  , revision                       VARCHAR2(3)   := fnd_api.g_miss_char
  , organization_id                NUMBER
  , subinventory_code              VARCHAR2(10)  := fnd_api.g_miss_char
  , locator_id                     NUMBER
  , transaction_quantity           NUMBER
  , primary_quantity               NUMBER
  , transaction_uom                VARCHAR2(3)   := fnd_api.g_miss_char
  , transaction_cost               NUMBER
  , transaction_type_id            NUMBER
  , transaction_action_id          NUMBER
  , transaction_source_type_id     NUMBER
  , transaction_source_id          NUMBER
  , transaction_source_name        VARCHAR2(80)  := fnd_api.g_miss_char
  -- updated size of varchar from 30 to 80 for bug 4614163
  , transaction_date               DATE          := fnd_api.g_miss_date
  , acct_period_id                 NUMBER
  , distribution_account_id        NUMBER
  , transaction_reference          VARCHAR2(240) := fnd_api.g_miss_char
  , requisition_line_id            NUMBER
  , requisition_distribution_id    NUMBER
  , reason_id                      NUMBER
  , lot_number                     VARCHAR2(80)  := fnd_api.g_miss_char
  , lot_expiration_date            DATE          := fnd_api.g_miss_date
  , serial_number                  VARCHAR2(30)  := fnd_api.g_miss_char
  , receiving_document             VARCHAR2(10)  := fnd_api.g_miss_char
  , demand_id                      NUMBER
  , rcv_transaction_id             NUMBER
  , move_transaction_id            NUMBER
  , completion_transaction_id      NUMBER
  , wip_entity_type                NUMBER
  , schedule_id                    NUMBER
  , repetitive_line_id             NUMBER
  , employee_code                  VARCHAR2(10)  := fnd_api.g_miss_char
  , primary_switch                 NUMBER
  , schedule_update_code           NUMBER
  , setup_teardown_code            NUMBER
  , item_ordering                  NUMBER
  , negative_req_flag              NUMBER
  , operation_seq_num              NUMBER
  , picking_line_id                NUMBER
  , trx_source_line_id             NUMBER
  , trx_source_delivery_id         NUMBER
  , physical_adjustment_id         NUMBER
  , cycle_count_id                 NUMBER
  , rma_line_id                    NUMBER
  , customer_ship_id               NUMBER
  , currency_code                  VARCHAR2(10)  := fnd_api.g_miss_char
  , currency_conversion_rate       NUMBER
  , currency_conversion_type       VARCHAR2(30)  := fnd_api.g_miss_char
  , currency_conversion_date       DATE          := fnd_api.g_miss_date
  , ussgl_transaction_code         VARCHAR2(30)  := fnd_api.g_miss_char
  , vendor_lot_number              VARCHAR2(80)  := fnd_api.g_miss_char
  , encumbrance_account            NUMBER
  , encumbrance_amount             NUMBER
  , ship_to_location               NUMBER
  , shipment_number                VARCHAR2(30)  := fnd_api.g_miss_char
  , transfer_cost                  NUMBER
  , transportation_cost            NUMBER
  , transportation_account         NUMBER
  , freight_code                   VARCHAR2(25)  := fnd_api.g_miss_char
  , containers                     NUMBER
  , waybill_airbill                VARCHAR2(20)  := fnd_api.g_miss_char
  , expected_arrival_date          DATE          := fnd_api.g_miss_date
  , transfer_subinventory          VARCHAR2(10)  := fnd_api.g_miss_char
  , transfer_organization          NUMBER
  , transfer_to_location           NUMBER
  , new_average_cost               NUMBER
  , value_change                   NUMBER
  , percentage_change              NUMBER
  , material_allocation_temp_id    NUMBER
  , demand_source_header_id        NUMBER
  , demand_source_line             VARCHAR2(30)  := fnd_api.g_miss_char
  , demand_source_delivery         VARCHAR2(30)  := fnd_api.g_miss_char
  , item_segments                  VARCHAR2(240) := fnd_api.g_miss_char
  , item_description               VARCHAR2(240) := fnd_api.g_miss_char
  , item_trx_enabled_flag          VARCHAR2(1)   := fnd_api.g_miss_char
  , item_location_control_code     NUMBER
  , item_restrict_subinv_code      NUMBER
  , item_restrict_locators_code    NUMBER
  , item_revision_qty_control_code NUMBER
  , item_primary_uom_code          VARCHAR2(3)   := fnd_api.g_miss_char
  , item_uom_class                 VARCHAR2(10)  := fnd_api.g_miss_char
  , item_shelf_life_code           NUMBER
  , item_shelf_life_days           NUMBER
  , item_lot_control_code          NUMBER
  , item_serial_control_code       NUMBER
  , item_inventory_asset_flag      VARCHAR2(1)   := fnd_api.g_miss_char
  , allowed_units_lookup_code      NUMBER
  , department_id                  NUMBER
  , department_code                VARCHAR2(10)  := fnd_api.g_miss_char
  , wip_supply_type                NUMBER
  , supply_subinventory            VARCHAR2(10)  := fnd_api.g_miss_char
  , supply_locator_id              NUMBER
  , valid_subinventory_flag        VARCHAR2(1)   := fnd_api.g_miss_char
  , valid_locator_flag             VARCHAR2(1)   := fnd_api.g_miss_char
  , locator_segments               VARCHAR2(240) := fnd_api.g_miss_char
  , current_locator_control_code   NUMBER
  , number_of_lots_entered         NUMBER
  , wip_commit_flag                VARCHAR2(1)   := fnd_api.g_miss_char
  , next_lot_number                VARCHAR2(80)  := fnd_api.g_miss_char
  , lot_alpha_prefix               VARCHAR2(30)  := fnd_api.g_miss_char
  , next_serial_number             VARCHAR2(30)  := fnd_api.g_miss_char
  , serial_alpha_prefix            VARCHAR2(30)  := fnd_api.g_miss_char
  , shippable_flag                 VARCHAR2(1)   := fnd_api.g_miss_char
  , posting_flag                   VARCHAR2(1)   := fnd_api.g_miss_char
  , required_flag                  VARCHAR2(1)   := fnd_api.g_miss_char
  , process_flag                   VARCHAR2(1)   := fnd_api.g_miss_char
  , ERROR_CODE                     VARCHAR2(240) := fnd_api.g_miss_char
  , error_explanation              VARCHAR2(240) := fnd_api.g_miss_char
  , attribute_category             VARCHAR2(30)  := fnd_api.g_miss_char
  , attribute1                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute2                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute3                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute4                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute5                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute6                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute7                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute8                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute9                     VARCHAR2(150) := fnd_api.g_miss_char
  , attribute10                    VARCHAR2(150) := fnd_api.g_miss_char
  , attribute11                    VARCHAR2(150) := fnd_api.g_miss_char
  , attribute12                    VARCHAR2(150) := fnd_api.g_miss_char
  , attribute13                    VARCHAR2(150) := fnd_api.g_miss_char
  , attribute14                    VARCHAR2(150) := fnd_api.g_miss_char
  , attribute15                    VARCHAR2(150) := fnd_api.g_miss_char
  , movement_id                    NUMBER
  , reservation_quantity           NUMBER
  , shipped_quantity               NUMBER
  , transaction_line_number        NUMBER
  , task_id                        NUMBER
  , to_task_id                     NUMBER
  , source_task_id                 NUMBER
  , project_id                     NUMBER
  , source_project_id              NUMBER
  , pa_expenditure_org_id          NUMBER
  , to_project_id                  NUMBER
  , expenditure_type               VARCHAR2(30)  := fnd_api.g_miss_char
  , final_completion_flag          VARCHAR2(1)   := fnd_api.g_miss_char
  , transfer_percentage            NUMBER
  , transaction_sequence_id        NUMBER
  , material_account               NUMBER
  , material_overhead_account      NUMBER
  , resource_account               NUMBER
  , outside_processing_account     NUMBER
  , overhead_account               NUMBER
  , flow_schedule                  VARCHAR2(1)   := fnd_api.g_miss_char
  , cost_group_id                  NUMBER        := fnd_api.g_miss_num
  , demand_class                   VARCHAR2(30)  := fnd_api.g_miss_char
  , qa_collection_id               NUMBER
  , kanban_card_id                 NUMBER
  , overcompletion_transaction_id  NUMBER
  , overcompletion_primary_qty     NUMBER
  , overcompletion_transaction_qty NUMBER
  , end_item_unit_number           VARCHAR2(60)  := fnd_api.g_miss_char
  , scheduled_payback_date         DATE          := fnd_api.g_miss_date
  , line_type_code                 NUMBER
  , parent_transaction_temp_id     NUMBER
  , put_away_strategy_id           NUMBER
  , put_away_rule_id               NUMBER
  , pick_strategy_id               NUMBER
  , pick_rule_id                   NUMBER
  , common_bom_seq_id              NUMBER
  , common_routing_seq_id          NUMBER
  , cost_type_id                   NUMBER
  , org_cost_group_id              NUMBER
  , move_order_line_id             NUMBER
  , task_group_id                  NUMBER
  , pick_slip_number               NUMBER
  , reservation_id                 NUMBER
  , transaction_status             NUMBER
  , transfer_cost_group_id         NUMBER        := fnd_api.g_miss_num
  , lpn_id                         NUMBER
  , transfer_lpn_id                NUMBER
  , pick_slip_date                 DATE
  , content_lpn_id                 NUMBER
  , secondary_transaction_quantity NUMBER      --INVCONV
  , secondary_uom_code             VARCHAR2(3) --INVCONV
  );

  --TYPE g_mmtt_rec IS mtl_material_transactions_temp%ROWTYPE;

  TYPE g_mmtt_tbl_type IS TABLE OF g_mmtt_rec
    INDEX BY BINARY_INTEGER;

  TYPE g_update_qty_rec IS RECORD(
    inventory_item_id              NUMBER       := fnd_api.g_miss_num
  , revision                       VARCHAR2(3)  := fnd_api.g_miss_char
  , organization_id                NUMBER       := fnd_api.g_miss_num
  , subinventory_code              VARCHAR2(10) := fnd_api.g_miss_char
  , locator_id                     NUMBER       := fnd_api.g_miss_num
  , transaction_quantity           NUMBER       := fnd_api.g_miss_num
  , transaction_uom                VARCHAR2(3)  := fnd_api.g_miss_char
  , secondary_transaction_quantity NUMBER       := fnd_api.g_miss_num  --INVCONV
  , secondary_uom_code             VARCHAR2(3)  := fnd_api.g_miss_char  --INVCONV
  , lot_number                     VARCHAR2(80) := fnd_api.g_miss_char
  , serial_number                  VARCHAR2(30) := fnd_api.g_miss_char
  );

  TYPE g_update_qty_tbl_type IS TABLE OF g_update_qty_rec
    INDEX BY BINARY_INTEGER;

  --  Procedure Update_Row
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_mo_line_detail_rec IN g_mmtt_rec);

  --  Procedure Insert_Row
  PROCEDURE insert_row(x_return_status OUT NOCOPY VARCHAR2, p_mo_line_detail_rec IN g_mmtt_rec);

  --  Procedure Delete_Row
  PROCEDURE delete_row(x_return_status OUT NOCOPY VARCHAR2, p_line_id IN NUMBER, p_line_detail_id IN NUMBER);

  --  Procedure       lock_Row
  PROCEDURE lock_row(
    x_return_status      OUT NOCOPY VARCHAR2
  , p_mo_line_detail_rec IN         g_mmtt_rec
  , x_mo_line_detail_rec OUT NOCOPY g_mmtt_rec
  );

  --  Function Query_Row
  FUNCTION query_row(p_line_detail_id IN NUMBER)
    RETURN g_mmtt_rec;

  --  Function Query_Rows
  FUNCTION query_rows(p_line_id IN NUMBER := fnd_api.g_miss_num, p_line_detail_id IN NUMBER := fnd_api.g_miss_num)
    RETURN g_mmtt_tbl_type;


  PROCEDURE update_quantity_allocations(
    p_move_order_line_id IN         NUMBER
  , p_mold_table         IN         inv_mo_line_detail_util.g_update_qty_tbl_type
  , x_mold_table         OUT NOCOPY inv_mo_line_detail_util.g_mmtt_tbl_type
  , x_return_status      OUT NOCOPY VARCHAR2
  , x_msg_count          OUT NOCOPY NUMBER
  , x_msg_data           OUT NOCOPY VARCHAR2
  );

  PROCEDURE reduce_allocation_quantity(
    x_return_status       OUT NOCOPY VARCHAR2
  , p_transaction_temp_id IN         NUMBER
  , p_quantity            IN         NUMBER
  , p_secondary_quantity  IN         NUMBER   --INVCONV
  );

  /**
    * Deletes the Allocations existing for a Move Order Line.
    * <p>
    * Deletes the Allocations existing for a Move Order Line. If Move Order Line ID
    * is passed, then all the allocations for that line are deleted. If Transaction
    * Temp ID is passed, then that allocation alone is deleted. <br>
    * Either Move Order Line ID or Transaction Temp ID has to be passed for the API
    * to proceed further.
    * <p>
    * @param x_return_status       Return Status
    * @param x_msg_count           Count of the Messages in the Message Stack
    * @param x_msg_data            Message if the Count is 1
    * @param p_mo_line_id          Move Order Line ID
    * @param p_transaction_temp_id Transaction Temp ID
    * <p>
    * @author  Venkatesh (venjayar)
    */
  PROCEDURE delete_allocations(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_mo_line_id          IN         NUMBER DEFAULT NULL
  , p_transaction_temp_id IN         NUMBER DEFAULT NULL
  );

  /**
    * Checks the correctness of the allocations for the Move Order Line.
    * <p>
    * Checks whether the Move Order Line is detailed and if detailed whether the
    * allocations are in proper shape. For a Lot Controlled Item, the sum of Lot Qty
    * allocated assigned to the allocation should match the Transaction Qty of the
    * allocation. Similarly for Serial Controlled and Lot and Serial Controlled Item.
    * <p>
    * @param x_return_status       Return Status
    * @param x_msg_count           Count of the Messages in the Message Stack
    * @param x_msg_data            Message if the Count is 1
    * @param p_move_order_line_id  Move Order Line ID to be checked
    * <p>
    * @author  Venkatesh (venjayar)
    */
  PROCEDURE is_line_detailed(
    x_return_status      OUT NOCOPY VARCHAR2
  , x_msg_count          OUT NOCOPY NUMBER
  , x_msg_data           OUT NOCOPY VARCHAR2
  , p_move_order_line_id IN         NUMBER
  );
END inv_mo_line_detail_util;

 

/
