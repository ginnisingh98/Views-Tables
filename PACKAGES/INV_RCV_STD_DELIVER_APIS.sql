--------------------------------------------------------
--  DDL for Package INV_RCV_STD_DELIVER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_STD_DELIVER_APIS" AUTHID CURRENT_USER AS
  /* $Header: INVSTDDS.pls 120.2 2006/03/07 14:02:39 gayu noship $*/

  /*******************************************************
  *  Name: create_mobile_rcvtxn_interface_rec
  *
  *  Description:
  *
  *
  *  Flow:
  *
  *
  *******************************************************/
  g_po_distribution_id       NUMBER  := 0; -- global variable for testing only
  g_rcvtxn_detail_index      NUMBER  := 1;
  -- global variable which stores the line in input table to detail in the matching algo

  -- input for matching algorithm
  g_rcvtxn_match_table_gross inv_rcv_common_apis.cascaded_trans_tab_type;

  -- this is the record type for RCV_TRANSACTION Block
  -- which includes DB items from RCV_TRANSACTIONS_V
  -- and NON-DB items as is in the form.
  TYPE rcvtxn_transaction_rec_tp IS RECORD(
    from_organization_id         NUMBER
  , to_organization_id           NUMBER
  , source_document_code         VARCHAR2(30)
  , receipt_source_code          VARCHAR2(30)
  , rcv_transaction_id           NUMBER
  , transaction_date             DATE
  , transaction_type             VARCHAR2(30)
  , primary_uom                  VARCHAR2(25)
  , primary_quantity             NUMBER
  , po_header_id                 NUMBER
  , po_revision_num              NUMBER
  , po_release_id                NUMBER
  , vendor_id                    NUMBER
  , vendor_site_id               NUMBER
  , po_line_id                   NUMBER
  , po_unit_price                NUMBER
  , category_id                  NUMBER
  , item_id                      NUMBER
  , serial_number_control_code   NUMBER
  , lot_control_code             NUMBER
  , item_revision                VARCHAR2(3)
  , po_line_location_id          NUMBER
  , po_distribution_id           NUMBER
  , employee_id                  NUMBER(9)
  , comments                     VARCHAR2(240)
  , req_header_id                NUMBER
  , req_line_id                  NUMBER
  , shipment_header_id           NUMBER
  , shipment_line_id             NUMBER
  , packing_slip                 VARCHAR2(80)
  , government_context           VARCHAR2(30)
  , ussgl_transaction_code       VARCHAR2(30)
  , inspection_status_code       VARCHAR2(30)
  , inspection_quality_code      VARCHAR2(30)
  , vendor_lot_num               VARCHAR2(30)
  , vendor_item_number           VARCHAR2(30)
  , substitute_unordered_code    VARCHAR2(30)
  , routing_id                   NUMBER
  , routing_step_id              NUMBER
  , reason_id                    NUMBER
  , currency_code                VARCHAR2(30)
  , currency_conversion_rate     NUMBER
  , currency_conversion_date     DATE
  , currency_conversion_type     VARCHAR2(30)
  , req_distribution_id          NUMBER
  , destination_type_code_hold   VARCHAR2(30)
  , location_id                  NUMBER
  , deliver_to_person_id         NUMBER
  , deliver_to_location_id       NUMBER
  , subinventory                 VARCHAR2(10)
  , un_number_id                 NUMBER
  , hazard_class_id              NUMBER
  , creation_date                DATE
  , attribute_category           VARCHAR2(30)
  , attribute1                   VARCHAR2(150)
  , attribute2                   VARCHAR2(150)
  , attribute3                   VARCHAR2(150)
  , attribute4                   VARCHAR2(150)
  , attribute5                   VARCHAR2(150)
  , attribute6                   VARCHAR2(150)
  , attribute7                   VARCHAR2(150)
  , attribute8                   VARCHAR2(150)
  , attribute9                   VARCHAR2(150)
  , attribute10                  VARCHAR2(150)
  , attribute11                  VARCHAR2(150)
  , attribute12                  VARCHAR2(150)
  , attribute13                  VARCHAR2(150)
  , attribute14                  VARCHAR2(150)
  , attribute15                  VARCHAR2(150)
  , qa_collection_id             NUMBER
  , oe_order_header_id           NUMBER
  , oe_order_line_id             NUMBER
  , customer_id                  NUMBER
  , customer_site_id             NUMBER
  -- These are now non database items
    ,destination_type_code_pqry  VARCHAR2(30)
  , destination_type_code        VARCHAR2(30)
  , subinventory_hold            VARCHAR2(30)
  , subinventory_dsp             VARCHAR2(30)
  , destination_context_nb       VARCHAR2(30)
  , wip_entity_id                NUMBER
  , wip_line_id                  NUMBER
  , wip_repetitive_schedule_id   NUMBER
  , wip_resource_seq_num         NUMBER
  , wip_operation_seq_num        NUMBER
  , bom_resource_id_nb           NUMBER
  , locator_id                   NUMBER
  , subinventory_locator_control NUMBER
  , transaction_quantity         NUMBER
  , transaction_uom              VARCHAR2(30)
  , transaction_date_nb          DATE
  , inspection_detail            VARCHAR2(1)
  , interface_transaction_id     NUMBER
  , put_away_rule_id             NUMBER
  , put_away_strategy_id         NUMBER
  , lpn_id                       NUMBER
  , transfer_lpn_id              NUMBER
  , cost_group_id                NUMBER
  , mmtt_temp_id                 NUMBER
  , transfer_cost_group_id       NUMBER
  , secondary_uom                VARCHAR2(25) --OPM Convergence
  , secondary_uom_code           VARCHAR2(3) --OPM Convergence
  , sec_transaction_quantity     NUMBER --OPM Convergence
  , from_subinventory_code       VARCHAR2(30)
  , from_locator_id              NUMBER
);

  TYPE rcvtxn_enter_rec_cursor_rec IS RECORD(
    from_organization_id         NUMBER
  , to_organization_id           NUMBER
  , source_document_code         VARCHAR2(30)
  , receipt_source_code          VARCHAR2(30)
  , rcv_transaction_id           NUMBER
  , transaction_date             DATE
  , transaction_type             VARCHAR2(30)
  , primary_uom                  VARCHAR2(25)
  , primary_quantity             NUMBER
  , po_header_id                 NUMBER
  , po_revision_num              NUMBER
  , po_release_id                NUMBER
  , vendor_id                    NUMBER
  , vendor_site_id               NUMBER
  , po_line_id                   NUMBER
  , po_unit_price                NUMBER
  , category_id                  NUMBER
  , item_id                      NUMBER
  , serial_number_control_code   NUMBER
  , lot_control_code             NUMBER
  , item_revision                VARCHAR2(3)
  , po_line_location_id          NUMBER
  , po_distribution_id           NUMBER
  , employee_id                  NUMBER(9)
  , comments                     VARCHAR2(240)
  , req_header_id                NUMBER
  , req_line_id                  NUMBER
  , shipment_header_id           NUMBER
  , shipment_line_id             NUMBER
  , packing_slip                 VARCHAR2(80)
  , government_context           VARCHAR2(30)
  , ussgl_transaction_code       VARCHAR2(30)
  , inspection_status_code       VARCHAR2(30)
  , inspection_quality_code      VARCHAR2(30)
  , vendor_lot_num               VARCHAR2(30)
  , vendor_item_number           VARCHAR2(30)
  , substitute_unordered_code    VARCHAR2(30)
  , routing_id                   NUMBER
  , routing_step_id              NUMBER
  , reason_id                    NUMBER
  , currency_code                VARCHAR2(30)
  , currency_conversion_rate     NUMBER
  , currency_conversion_date     DATE
  , currency_conversion_type     VARCHAR2(30)
  , req_distribution_id          NUMBER
  , destination_type_code_hold   VARCHAR2(30)
  , final_destination_type_code  VARCHAR2(30)
  , location_id                  NUMBER
  , final_deliver_to_person_id   NUMBER(9)
  , final_deliver_to_location_id NUMBER
  , subinventory                 VARCHAR2(10)
  , un_number_id                 NUMBER
  , hazard_class_id              NUMBER
  , creation_date                DATE
  , attribute_category           VARCHAR2(30)
  , attribute1                   VARCHAR2(150)
  , attribute2                   VARCHAR2(150)
  , attribute3                   VARCHAR2(150)
  , attribute4                   VARCHAR2(150)
  , attribute5                   VARCHAR2(150)
  , attribute6                   VARCHAR2(150)
  , attribute7                   VARCHAR2(150)
  , attribute8                   VARCHAR2(150)
  , attribute9                   VARCHAR2(150)
  , attribute10                  VARCHAR2(150)
  , attribute11                  VARCHAR2(150)
  , attribute12                  VARCHAR2(150)
  , attribute13                  VARCHAR2(150)
  , attribute14                  VARCHAR2(150)
  , attribute15                  VARCHAR2(150)
  , qa_collection_id             NUMBER
  , oe_order_header_id           NUMBER
  , oe_order_line_id             NUMBER
  , customer_id                  NUMBER
  , customer_site_id             NUMBER
  , wip_entity_id                NUMBER
  , po_operation_seq_num         NUMBER
  , po_resource_seq_num          NUMBER
  , wip_repetitive_schedule_id   NUMBER
  , wip_line_id                  NUMBER
  , bom_resource_id              NUMBER
  , final_subinventory           VARCHAR2(10)
  , secondary_quantity           NUMBER --OPM Convergence
  , secondary_uom                VARCHAR2(25) --OPM Convergence
  , from_subinventory_code       VARCHAR2(30)
  , from_locator_id              NUMBER
  );

  PROCEDURE insert_lot_serial(
    p_lot_serial_break_tbl      IN  inv_rcv_common_apis.trans_rec_tb_tp
  , p_transaction_temp_id       IN  NUMBER
  , p_lot_control_code          IN  NUMBER
  , p_serial_control_code       IN  NUMBER
  , p_interface_transaction_id  IN  NUMBER
  );

  -- MANEESH - BEGIN CHANGES - FOR OUTSIDE PROCESSING ITEM

  PROCEDURE create_osp_std_rcvtxn_intf_rec(
    p_organization_id      IN             NUMBER
  , p_po_header_id         IN             NUMBER
  , p_po_release_id        IN             NUMBER
  , p_po_line_id           IN             NUMBER
  , p_po_distribution_id   IN             NUMBER
  , p_item_id              IN             NUMBER
  , p_vendor_id            IN             NUMBER
  , p_revision             IN             VARCHAR2
  , p_rcvtxn_qty           IN             NUMBER
  , p_rcvtxn_uom           IN             VARCHAR2
  , p_transaction_temp_id  IN             NUMBER
  , x_status               OUT NOCOPY     VARCHAR2
  , x_message              OUT NOCOPY     VARCHAR2
  , p_secondary_qty        IN             NUMBER DEFAULT NULL --OPM Convergence
  );

  -- MANEESH - END CHANGES - FOR OUTSIDE PROCESSING ITEM

  PROCEDURE create_std_rcvtxn_intf_rec(
    p_organization_id      IN             NUMBER
  , p_po_header_id         IN             NUMBER
  , p_po_release_id        IN             NUMBER
  , p_po_line_id           IN             NUMBER
  , p_shipment_header_id   IN             NUMBER
  , p_oe_order_header_id   IN             NUMBER
  , p_receipt_num          IN             VARCHAR2
  , p_item_id              IN             NUMBER
  , p_vendor_id            IN             NUMBER
  , p_revision             IN             VARCHAR2
  , p_subinventory_code    IN             VARCHAR2
  , p_locator_id           IN             NUMBER
  , p_rcvtxn_qty           IN             NUMBER
  , p_rcvtxn_uom           IN             VARCHAR2
  , p_transaction_temp_id  IN             NUMBER
  , p_lot_control_code     IN             NUMBER
  , p_serial_control_code  IN             NUMBER
  , x_status               OUT NOCOPY     VARCHAR2
  , x_message              OUT NOCOPY     VARCHAR2
  , p_deliver_to_location_id IN           NUMBER   DEFAULT NULL
  , p_sec_rcvtxn_qty       IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom        IN             VARCHAR2 DEFAULT NULL --OPMConvergence
  , p_rcv_act_rjt_qty_type   IN           NUMBER   DEFAULT NULL --BUG 4309432
  );

  /* FP-J Lot/Serial Support Enhancement
   * Added two new parameters p_transfer_lpn_id and p_lot_number
   * with default NULL values
   */
  PROCEDURE create_putaway_rcvtxn_intf_rec(
    p_organization_id         IN             NUMBER
  , p_reference_id            IN             NUMBER
  , p_reference               IN             VARCHAR2
  , p_reference_type_code     IN             NUMBER
  , p_item_id                 IN             NUMBER
  , p_revision                IN             VARCHAR2
  , p_subinventory_code       IN             VARCHAR2
  , p_locator_id              IN             NUMBER
  , p_rcvtxn_qty              IN             NUMBER
  , p_rcvtxn_uom_code         IN             VARCHAR2
  , p_transaction_temp_id     IN             NUMBER
  , p_lot_control_code        IN             NUMBER
  , p_serial_control_code     IN             NUMBER
  , p_original_txn_temp_id    IN             NUMBER
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_inspection_status_code  IN             NUMBER
  , p_lpn_id                  IN             NUMBER
  , p_transfer_lpn_id         IN             NUMBER   DEFAULT NULL
  , p_lot_number              IN             VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN             NUMBER   DEFAULT NULL
  , p_secondary_quantity      IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom           IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  );

  PROCEDURE rcvtxn_clear_global;

  PROCEDURE update_rcv_serials_supply(
    x_return_status     OUT NOCOPY  VARCHAR2
  , x_msg_count         OUT NOCOPY  NUMBER
  , x_msg_data          OUT NOCOPY  VARCHAR2
  , p_shipment_line_id              NUMBER
				      );
  PROCEDURE Match_putaway_rcvtxn_intf_rec(
    p_organization_id         IN             NUMBER
  , p_reference_id            IN             NUMBER
  , p_reference               IN             VARCHAR2
  , p_reference_type_code     IN             NUMBER
  , p_item_id                 IN             NUMBER
  , p_revision                IN             VARCHAR2
  , p_subinventory_code       IN             VARCHAR2
  , p_locator_id              IN             NUMBER
  , p_rcvtxn_qty              IN             NUMBER
  , p_rcvtxn_uom_code         IN             VARCHAR2
  , p_transaction_temp_id     IN             NUMBER
  , p_lot_control_code        IN             NUMBER
  , p_serial_control_code     IN             NUMBER
  , p_original_txn_temp_id    IN             NUMBER
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_inspection_status_code  IN             NUMBER
  , p_lpn_id                  IN             NUMBER
  , p_transfer_lpn_id         IN             NUMBER   DEFAULT NULL
  , p_lot_number              IN             VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN             NUMBER   DEFAULT NULL
  , p_secondary_quantity      IN             NUMBER   DEFAULT NULL --OPM Convergence
  , p_secondary_uom           IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  , p_inspection_status       IN             NUMBER DEFAULT NULL
  , p_primary_uom_code        IN             VARCHAR2
  );

END inv_rcv_std_deliver_apis;

 

/
