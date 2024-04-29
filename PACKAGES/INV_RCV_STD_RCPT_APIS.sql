--------------------------------------------------------
--  DDL for Package INV_RCV_STD_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_STD_RCPT_APIS" AUTHID CURRENT_USER AS
  /* $Header: INVSTDRS.pls 120.1.12010000.7 2010/12/10 09:14:49 srsomasu ship $*/
  TYPE rcv_enter_receipts_rec_tp IS RECORD(
    line_chkbox                    CHAR(1)
  , source_type_code               VARCHAR2(30)
  , receipt_source_code            VARCHAR2(30)
  , order_type_code                VARCHAR2(30)
  , order_type                     VARCHAR2(80)
  , po_header_id                   NUMBER
  , po_number                      VARCHAR2(30)
  , po_line_id                     NUMBER
  , po_line_number                 NUMBER
  , po_line_location_id            NUMBER
  , po_shipment_number             NUMBER
  , po_release_id                  NUMBER
  , po_release_number              NUMBER
  , req_header_id                  NUMBER
  , req_number                     VARCHAR2(80)
  , req_line_id                    NUMBER
  , req_line                       NUMBER
  , req_distribution_id            NUMBER
  , rcv_shipment_header_id         NUMBER
  , rcv_shipment_number            VARCHAR2(30)
  , rcv_shipment_line_id           NUMBER
  , rcv_line_number                NUMBER
  , from_organization_id           NUMBER
  , to_organization_id             NUMBER
  , vendor_id                      NUMBER
  , SOURCE                         VARCHAR2(255)
  , vendor_site_id                 NUMBER
  , outside_operation_flag         VARCHAR2(1)
  , item_id                        NUMBER
  , -- bug 2073164
    -- Added extra column in the rec structure
    uom_code                       VARCHAR2(3)
  , primary_uom                    VARCHAR2(25)
  , primary_uom_class              VARCHAR2(10)
  , item_allowed_units_lookup_code NUMBER
  , item_locator_control           NUMBER
  , restrict_locators_code         VARCHAR2(1)
  , restrict_subinventories_code   VARCHAR2(1)
  , shelf_life_code                NUMBER
  , shelf_life_days                NUMBER
  , serial_number_control_code     NUMBER
  , lot_control_code               NUMBER
  , item_rev_control_flag_to       VARCHAR2(1)
  , item_rev_control_flag_from     VARCHAR2(1)
  , item_number                    VARCHAR2(40)
  , item_revision                  VARCHAR2(3)
  , item_description               VARCHAR2(240)
  , item_category_id               NUMBER
  , hazard_class                   VARCHAR2(40)
  , un_number                      VARCHAR2(30)
  , vendor_item_number             VARCHAR2(30)
  , ship_to_location_id            NUMBER
  , ship_to_location               VARCHAR2(60)
  , packing_slip                   VARCHAR2(80)
  , routing_id                     NUMBER
  , routing_name                   VARCHAR2(30)
  , need_by_date                   DATE
  , expected_receipt_date          DATE
  , ordered_qty                    NUMBER
  , ordered_uom                    VARCHAR2(25)
  , ussgl_transaction_code         VARCHAR2(30)
  , government_context             VARCHAR2(30)
  , inspection_required_flag       VARCHAR2(1)
  , receipt_required_flag          VARCHAR2(1)
  , enforce_ship_to_location_code  VARCHAR2(30)
  , unit_price                     NUMBER
  , currency_code                  VARCHAR2(30)
  , currency_conversion_type       VARCHAR2(30)
  , currency_conversion_date       DATE
  , currency_conversion_rate       NUMBER
  , note_to_receiver               VARCHAR2(480) --Changed the length from 240 to 480 for Bug 10333116
  , destination_type_code          VARCHAR2(30)
  , deliver_to_person_id           NUMBER
  , deliver_to_location_id         NUMBER
  , destination_subinventory       VARCHAR2(10)
  , attribute_category             VARCHAR2(30)
  , attribute1                     VARCHAR2(150)
  , attribute2                     VARCHAR2(150)
  , attribute3                     VARCHAR2(150)
  , attribute4                     VARCHAR2(150)
  , attribute5                     VARCHAR2(150)
  , attribute6                     VARCHAR2(150)
  , attribute7                     VARCHAR2(150)
  , attribute8                     VARCHAR2(150)
  , attribute9                     VARCHAR2(150)
  , attribute10                    VARCHAR2(150)
  , attribute11                    VARCHAR2(150)
  , attribute12                    VARCHAR2(150)
  , attribute13                    VARCHAR2(150)
  , attribute14                    VARCHAR2(150)
  , attribute15                    VARCHAR2(150)
  , closed_code                    VARCHAR2(30)
  , asn_type                       VARCHAR2(30)
  , bill_of_lading                 VARCHAR2(30)
  , shipped_date                   DATE
  , freight_carrier_code           VARCHAR2(30)
  , waybill_airbill_num            VARCHAR2(80)
  , freight_bill_num               VARCHAR2(35)
  , vendor_lot_num                 VARCHAR2(80)
  , container_num                  VARCHAR2(35)
  , truck_num                      VARCHAR2(35)
  , bar_code_label                 VARCHAR2(35)
  , rate_type_display              VARCHAR2(30)
  , match_option                   VARCHAR2(25)
  , country_of_origin_code         VARCHAR2(2)
  , oe_order_header_id             NUMBER
  , oe_order_num                   NUMBER
  , oe_order_line_id               NUMBER
  , oe_order_line_num              NUMBER
  , customer_id                    NUMBER
  , customer_site_id               NUMBER
  , customer_item_num              VARCHAR2(50)
  , pll_note_to_receiver           VARCHAR2(240)
  , -- ABOVE FIELDS ARE FROM RCV_ENTER_RECEIPTS_V
    -- BELOW ARE MAINLY FROM PO_DISTRIBUTIONS
    po_distribution_id             NUMBER
  , qty_ordered                    NUMBER
  , wip_entity_id                  NUMBER
  , wip_operation_seq_num          NUMBER
  , wip_resource_seq_num           NUMBER
  , wip_repetitive_schedule_id     NUMBER
  , wip_line_id                    NUMBER
  , bom_resource_id                NUMBER
  , destination_type               VARCHAR2(80)
  , LOCATION                       VARCHAR2(60)
  , currency_conversion_rate_pod   NUMBER
  , currency_conversion_date_pod   DATE
  , project_id                     NUMBER
  , task_id                        NUMBER
 -- OPM Convergence ..commented out temporarily
  , secondary_uom      VARCHAR2(25) DEFAULT NULL
  , secondary_uom_code                  VARCHAR2(3) DEFAULT NULL
  , secondary_quantity             NUMBER DEFAULT NULL
  );

  -- this is the record type for RCV_TRANSACTION Block
  -- which includes DB items from RCV_ENTER_RECEIPTS_V
  -- and NON-DB items
  TYPE rcv_transaction_rec_tp IS RECORD(
    line_chkbox                    CHAR(1)
  , source_type_code               VARCHAR2(30)
  , receipt_source_code            VARCHAR2(30)
  , order_type_code                VARCHAR2(30)
  , order_type                     VARCHAR2(80)
  , po_header_id                   NUMBER
  , po_number                      VARCHAR2(30)
  , po_line_id                     NUMBER
  , po_line_number                 NUMBER
  , po_line_location_id            NUMBER
  , po_shipment_number             NUMBER
  , po_release_id                  NUMBER
  , po_release_number              NUMBER
  , req_header_id                  NUMBER
  , req_number                     VARCHAR2(80)
  , req_line_id                    NUMBER
  , req_line                       NUMBER
  , req_distribution_id            NUMBER
  , rcv_shipment_header_id         NUMBER
  , rcv_shipment_number            VARCHAR2(30)
  , rcv_shipment_line_id           NUMBER
  , rcv_line_number                NUMBER
  , from_organization_id           NUMBER
  , to_organization_id             NUMBER
  , vendor_id                      NUMBER
  , SOURCE                         VARCHAR2(255)
  , vendor_site_id                 NUMBER
  , outside_operation_flag         VARCHAR2(1)
  , item_id                        NUMBER
  -- bug 2073164
  -- Added extra column in the rec structure
    ,uom_code                      VARCHAR2(3)
  , primary_uom                    VARCHAR2(25)
  , primary_uom_class              VARCHAR2(10)
  , item_allowed_units_lookup_code NUMBER
  , item_locator_control           NUMBER
  , restrict_locators_code         VARCHAR2(1)
  , restrict_subinventories_code   VARCHAR2(1)
  , shelf_life_code                NUMBER
  , shelf_life_days                NUMBER
  , serial_number_control_code     NUMBER
  , lot_control_code               NUMBER
  , item_rev_control_flag_to       VARCHAR2(1)
  , item_rev_control_flag_from     VARCHAR2(1)
  , item_number                    VARCHAR2(40)
  , item_revision                  VARCHAR2(3)
  , item_description               VARCHAR2(240)
  , item_category_id               NUMBER
  , hazard_class                   VARCHAR2(40)
  , un_number                      VARCHAR2(30)
  , vendor_item_number             VARCHAR2(30)
  , ship_to_location_id            NUMBER
  , ship_to_location               VARCHAR2(60)
  , packing_slip                   VARCHAR2(30)
  , routing_id                     NUMBER
  , routing_name                   VARCHAR2(30)
  , need_by_date                   DATE
  , expected_receipt_date          DATE
  , ordered_qty                    NUMBER
  , ordered_uom                    VARCHAR2(25)
  , ussgl_transaction_code         VARCHAR2(30)
  , government_context             VARCHAR2(30)
  , inspection_required_flag       VARCHAR2(1)
  , receipt_required_flag          VARCHAR2(1)
  , enforce_ship_to_location_code  VARCHAR2(30)
  , unit_price                     NUMBER
  , currency_code                  VARCHAR2(15)
  , currency_conversion_type       VARCHAR2(30)
  , currency_conversion_date       DATE
  , currency_conversion_rate       NUMBER
  , note_to_receiver               VARCHAR2(480) --Changed the length from 240 to 480 for Bug 10333116
  , destination_type_code          VARCHAR2(30)
  , deliver_to_person_id           NUMBER
  , deliver_to_location_id         NUMBER
  , destination_subinventory       VARCHAR2(10)
  , attribute_category             VARCHAR2(30)
  , attribute1                     VARCHAR2(150)
  , attribute2                     VARCHAR2(150)
  , attribute3                     VARCHAR2(150)
  , attribute4                     VARCHAR2(150)
  , attribute5                     VARCHAR2(150)
  , attribute6                     VARCHAR2(150)
  , attribute7                     VARCHAR2(150)
  , attribute8                     VARCHAR2(150)
  , attribute9                     VARCHAR2(150)
  , attribute10                    VARCHAR2(150)
  , attribute11                    VARCHAR2(150)
  , attribute12                    VARCHAR2(150)
  , attribute13                    VARCHAR2(150)
  , attribute14                    VARCHAR2(150)
  , attribute15                    VARCHAR2(150)
  , closed_code                    VARCHAR2(30)
  , asn_type                       VARCHAR2(30)
  , bill_of_lading                 VARCHAR2(30)
  , shipped_date                   DATE
  , freight_carrier_code           VARCHAR2(30)
  , waybill_airbill_num            VARCHAR2(80)
  , freight_bill_num               VARCHAR2(35)
  -- vendor_lot_num is defined as a non-db item in form
  -- however seems it is queried from db only and never changed thereafter ?
    ,vendor_lot_num                VARCHAR2(80)
  , container_num                  VARCHAR2(35)
  , truck_num                      VARCHAR2(35)
  , bar_code_label                 VARCHAR2(35)
  , rate_type_display              VARCHAR2(30)
  , match_option                   VARCHAR2(25)
  , country_of_origin_code         VARCHAR2(2)
  , oe_order_header_id             NUMBER
  , oe_order_num                   NUMBER
  , oe_order_line_id               NUMBER
  , oe_order_line_num              NUMBER
  , customer_id                    NUMBER
  , customer_site_id               NUMBER
  , customer_item_num              VARCHAR2(50)
  -- below are NON-DB Items
    ,interface_transaction_id      NUMBER
  , primary_quantity               NUMBER
  , transaction_qty                NUMBER
  , transaction_uom                VARCHAR2(25)
  , receipt_exception              NUMBER
  , comments                       VARCHAR2(240)
  -- this field is set in receiving form ?
    ,reason_id                     NUMBER
  , substitute_receipt             VARCHAR2(30)
  , original_item_id               NUMBER
  , locator_id                     NUMBER
  , subinventory_dsp               VARCHAR2(10)
  , wip_entity_id                  NUMBER
  , wip_line_id                    NUMBER
  , department_code                NUMBER
  , wip_repetitive_schedule_id     NUMBER
  , wip_operation_seq_num          NUMBER
  , wip_resource_seq_num           NUMBER
  , bom_resource_id                NUMBER
  , destination_type_code_hold     VARCHAR2(30)
  , po_distribution_id             NUMBER
  , lpn_id                         NUMBER
  , transfer_lpn_id                NUMBER
  , cost_group_id                  NUMBER
  , transfer_cost_group_id         NUMBER
 -- OPM Convergence
  , secondary_uom                  VARCHAR2(25)
  , secondary_uom_code             VARCHAR2(3)
  , secondary_quantity             NUMBER
  );

  TYPE rcpt_lot_qty_rec IS RECORD(
    lot_number   VARCHAR2(80)
  , txn_quantity NUMBER
  , sec_txn_quantity NUMBER --OPM Convergence
  );

  TYPE rcpt_lot_qty_rec_tb_tp IS TABLE OF rcpt_lot_qty_rec
    INDEX BY BINARY_INTEGER;

  g_rcpt_lot_qty_rec_tb    rcpt_lot_qty_rec_tb_tp;
  g_shipment_header_id     NUMBER := NULL;
  g_header_intf_id         NUMBER := NULL;
  g_rcpt_match_table_gross inv_rcv_common_apis.cascaded_trans_tab_type; -- input for matching algorithm
  g_receipt_detail_index   NUMBER := 1; -- index for the row needs to be detailed for matching
  g_dummy_lpn_id           NUMBER := NULL; -- dummy lpn_id for normal ASN receipt with the same from and to lpn
  g_po_line_location_id    NUMBER := 0; -- global variable for testing only ?
  g_po_distribution_id     NUMBER := 0;

  /*******************************************************
 *  Name: create_std_rcpt_intf_rec
 *
 *  Description:
 *
 *  This API is a wrapper to create record in RCV_TRANSACTIONS_INTERFACE for
 *  different receipt transactions.
 *
 *  This API takes PO_header_id or Shipment_header_id, item_id, received_qty,
 *  received_UOM, received_location as input. It calls the corresponding API
 *  for different txns (PO, Intransit, RMA, ASN, Int-req).
 *
 *  The underlying APIs will call the matching algorithm API
 *  to detail the receipt to PO_line_locations.
 *  Then it calls insert API, insert_txn_interface, to inserts PO line
 *  location record into RCV_TRANSACTION_INTERFACE
 *
 *  Flow:
 *
 *  1. query po_startup_value and other initial values
 *  2. query RCV_ENTER_RECEIPTS_V to populate DB items in rcv_transaction block
 *     before calling matching algorithm
 *  3. call matching algorithm to detail the receipt
 *  4. call insert API
 *
 *  Parameters:
 *
 *  p_move_order_header_id
 *  p_organization_id
 *  p_shipment_header_id
 *  p_req_header_id
 *  p_po_header_id
 *  p_item_id
 *  p_location_id
 *  p_rcv_qty
 *  p_rcv_uom
 *  p_source_type
 *  p_from_lpn_id
 *  p_lpn_id
 *  p_lot_control_code
 *  p_revision
 *
 *******************************************************/
  /* FP-J Lot/Serial Support
   * Added a new parameter p_original_rti_id to store the product_transaction_id
   * passed from the UI to split the lots and serials based on RTI quantity
   */
  --Bug #4147209 - Added the DFF attribute category and the attributes
  --as input parameters
  PROCEDURE create_std_rcpt_intf_rec(
    p_move_order_header_id   IN OUT NOCOPY  NUMBER
  , p_organization_id        IN             NUMBER
  , p_po_header_id           IN             NUMBER
  , p_po_release_number_id   IN             NUMBER
  , p_po_line_id             IN             NUMBER
  , p_shipment_header_id     IN             NUMBER
  , p_req_header_id          IN             NUMBER
  , p_oe_order_header_id     IN             NUMBER
  , p_item_id                IN             NUMBER
  , p_location_id            IN             NUMBER
  , p_rcv_qty                IN             NUMBER
  , p_rcv_uom                IN             VARCHAR2
  , p_rcv_uom_code           IN             VARCHAR2
  , p_source_type            IN             VARCHAR2
  , p_from_lpn_id            IN             NUMBER
  , p_lpn_id                 IN             NUMBER
  , p_lot_control_code       IN             NUMBER
  , p_revision               IN             VARCHAR2
  , p_inspect                IN             NUMBER
  , x_status                 OUT NOCOPY     VARCHAR2
  , x_message                OUT NOCOPY     VARCHAR2
  , p_inv_item_id            IN             NUMBER		DEFAULT NULL
  , p_item_desc              IN             VARCHAR2 	DEFAULT NULL
  , p_project_id             IN             NUMBER 		DEFAULT NULL
  , p_task_id                IN             NUMBER 		DEFAULT NULL
  , p_country_code           IN             VARCHAR2 	DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2 	DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER 		DEFAULT NULL
  , p_original_rti_id        IN             NUMBER 		DEFAULT NULL
    --OPM convergence
      , p_secondary_uom          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_uom_code     IN             VARCHAR2 DEFAULT NULL
  , p_secondary_quantity          IN             NUMBER   DEFAULT NULL
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL
  , p_attribute1             IN             VARCHAR2  DEFAULT NULL
  , p_attribute2             IN             VARCHAR2  DEFAULT NULL
  , p_attribute3             IN             VARCHAR2  DEFAULT NULL
  , p_attribute4             IN             VARCHAR2  DEFAULT NULL
  , p_attribute5             IN             VARCHAR2  DEFAULT NULL
  , p_attribute6             IN             VARCHAR2  DEFAULT NULL
  , p_attribute7             IN             VARCHAR2  DEFAULT NULL
  , p_attribute8             IN             VARCHAR2  DEFAULT NULL
  , p_attribute9             IN             VARCHAR2  DEFAULT NULL
  , p_attribute10            IN             VARCHAR2  DEFAULT NULL
  , p_attribute11            IN             VARCHAR2  DEFAULT NULL
  , p_attribute12            IN             VARCHAR2  DEFAULT NULL
  , p_attribute13            IN             VARCHAR2  DEFAULT NULL
  , p_attribute14            IN             VARCHAR2  DEFAULT NULL
  , p_attribute15            IN             VARCHAR2  DEFAULT NULL
  );

  FUNCTION insert_txn_interface(
    p_rcv_transaction_rec  IN OUT NOCOPY  rcv_transaction_rec_tp
  , p_rcv_rcpt_rec         IN OUT NOCOPY  rcv_enter_receipts_rec_tp
  , p_group_id                            NUMBER
  , p_transaction_type                    VARCHAR2
  , p_organization_id                     NUMBER
  , p_location_id                         NUMBER
  , p_source_type                         VARCHAR2
  , p_qa_routing_id                       NUMBER DEFAULT -1
  , p_project_id                          NUMBER DEFAULT NULL
  , p_task_id                             NUMBER DEFAULT NULL
  , p_express_transaction                 VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

  /*
  --rcv_insert_update_header
  --========================
    --If passed shipment_header_id is null it calls rcv_insert_header
    --Else it calls rcv_update_header
    --
    --Called from:
    --RcptInfoPage.java
    -------------------
    --For a PO/RMA receipt calls this API to insert a default RSH row which will
    --generate the g_shipment_header_id if it is null and pass it back to the
    --UI. This is the only time a RSH row is inserted. Later in processTxn in
    --the RcptInfoPage.java this API is called again. For intransit receipts the
    --g_shipment_header_id gets defaulted to the shipment_header_id in
    --insert_txn_interface procedure else in this method we generate the
    --g_shipment_header_id to be used later to insert a corresponding RHI.
    --The java file passes null for shipment_header_id but stores the value
    --which is again passed later from the listener to update the RSH.
    --
    --RcptInfoFListener.java
    ------------------------
    --From this API the shipment_header_id should always get passed to this API
    --and so we should be just updating the RSH created in the pageEntered or
    --the existing RSH for the non PO/RMA transaction with the values entered on
    --the infoPage.
    --
    --
    --rcv_insert_header/rcv_insert_header_insterface
    --==============================================
    --Call rcv_insert_header_interface if patchset J is installed
    --rcv_insert_header
    --If g_shipment_header_id is null then it generates it
    --Inserts into RSH
    --Calls rcv_update_rti_from_header
    --If patchsetJ is installed,
    --if g_header_interface_id is null then generate it
    --Insert into RHI
    --Calls the rcv_update_rti_from_header
    --else do what it used to do before.
    --INVSTDRB.pls
    --------------
    --rcv_insert_update_header
    --
    --
    --rcv_update_header
    --=================
    --Selects the RSH row for the shipment_header_id passed
    --Updates the various columns passed in the cursor
    --calls rcv_shipment_headers_pkg.update_row to update the columns
    --If patchsetJ is installed
    --select the RHI row for the header_interface_id passed
    --updates the various columns in RHI.
    --else do what it used to do before.
    --INVSTDRB.pls
    --------------
    --rcv_insert_update_header
    --
    --
    --rcv_update_rti_from_header
    --==========================
    --Querry RTI to get transaction_status_code using g_shipment_header_id on RTI.
    --update following columns in RTI:
    --SET shipment_num = p_shipment_num
    --, freight_carrier_code = p_freight_carrier_code
    --, bill_of_lading = p_bill_of_lading
    --, packing_slip = p_packing_slip
    --, num_of_containers = p_num_of_containers
    --, waybill_airbill_num = p_waybill_airbill_num
    --using g_shipment_header_id on RTI
    --If patchset J is installed
    --query RTI to get the transaction_status_code using g_header_intf_id on RTI.
    --Update the above columns in RTI.
    --
    --INVSTDRB.pls
    --------------
    --rcv_insert_header
    --rcv_update_header
    */
  --Bug #4147209 - Added the DFF attribute category and the attributes
  --as input parameters
  PROCEDURE rcv_insert_update_header(
    p_organization_id         IN             NUMBER
  , p_shipment_header_id      IN OUT NOCOPY  NUMBER
  , p_source_type             IN             VARCHAR2
  , p_receipt_num             IN OUT NOCOPY  VARCHAR2
  , p_vendor_id               IN             NUMBER
  , p_vendor_site_id          IN             NUMBER
  , p_shipment_num            IN             VARCHAR2
  , p_ship_to_location_id     IN             NUMBER
  , p_bill_of_lading          IN             VARCHAR2
  , p_packing_slip            IN             VARCHAR2
  , p_shipped_date            IN             DATE
  , p_freight_carrier_code    IN             VARCHAR2
  , p_expected_receipt_date   IN             DATE
  , p_num_of_containers       IN             NUMBER
  , p_waybill_airbill_num     IN             VARCHAR2
  , p_comments                IN             VARCHAR2
  , p_ussgl_transaction_code  IN             VARCHAR2
  , p_government_context      IN             VARCHAR2
  , p_request_id              IN             NUMBER
  , p_program_application_id  IN             NUMBER
  , p_program_id              IN             NUMBER
  , p_program_update_date     IN             DATE
  , p_customer_id             IN             NUMBER
  , p_customer_site_id        IN             NUMBER
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     NUMBER
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL
  , p_attribute1             IN             VARCHAR2  DEFAULT NULL
  , p_attribute2             IN             VARCHAR2  DEFAULT NULL
  , p_attribute3             IN             VARCHAR2  DEFAULT NULL
  , p_attribute4             IN             VARCHAR2  DEFAULT NULL
  , p_attribute5             IN             VARCHAR2  DEFAULT NULL
  , p_attribute6             IN             VARCHAR2  DEFAULT NULL
  , p_attribute7             IN             VARCHAR2  DEFAULT NULL
  , p_attribute8             IN             VARCHAR2  DEFAULT NULL
  , p_attribute9             IN             VARCHAR2  DEFAULT NULL
  , p_attribute10            IN             VARCHAR2  DEFAULT NULL
  , p_attribute11            IN             VARCHAR2  DEFAULT NULL
  , p_attribute12            IN             VARCHAR2  DEFAULT NULL
  , p_attribute13            IN             VARCHAR2  DEFAULT NULL
  , p_attribute14            IN             VARCHAR2  DEFAULT NULL
  , p_attribute15            IN             VARCHAR2  DEFAULT NULL
  );

  -- This API was not called from anywhere outside so removing this from
  -- the spec. Please look at comments for rcv_insert_update_header


-- For LCM Project  BUG 7702666
PROCEDURE lcm_call_rcv_rtp(
    p_lcmOrgID                IN             NUMBER
  , p_lcmReceiptNum           IN             VARCHAR2
  , x_lcmvalid_status         OUT NOCOPY     VARCHAR2
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  );
-- For LCM Project  BUG 7702666

/*
  PROCEDURE rcv_update_rti_from_header(
    p_shipment_num                      VARCHAR
  , p_freight_carrier_code              VARCHAR2
  , p_bill_of_lading                    VARCHAR2
  , p_packing_slip                      VARCHAR2
  , p_num_of_containers                 NUMBER
  , p_waybill_airbill_num               VARCHAR2
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  );
    */

  PROCEDURE create_move_order(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_po_line_location_id   IN             NUMBER
  , p_po_distribution_id    IN             NUMBER
  , p_shipment_line_id      IN             NUMBER
  , p_oe_order_line_id      IN             NUMBER
  , p_routing               IN             VARCHAR2
  , p_lot_control_code      IN             NUMBER
  , p_org_id                IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_qty                   IN             NUMBER
  , p_uom_code              IN             VARCHAR2
  , p_lpn                   IN             NUMBER
  , p_project_id            IN             NUMBER		DEFAULT NULL
  , p_task_id               IN             NUMBER		DEFAULT NULL
  , p_revision              IN             VARCHAR2 DEFAULT NULL
  , p_inspect               IN             NUMBER
  , p_txn_source_id         IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_transfer_org_id       IN             NUMBER 	DEFAULT NULL
  , p_wms_process_flag      IN             NUMBER 	DEFAULT NULL
  , p_lot_number            IN             VARCHAR2     DEFAULT NULL
  , p_secondary_quantity    IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom         IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  , x_line_id               OUT NOCOPY     NUMBER
  );

  PROCEDURE create_mo_for_correction(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_po_line_location_id   IN             NUMBER 	DEFAULT NULL
  , p_po_distribution_id    IN             NUMBER 	DEFAULT NULL
  , p_shipment_line_id      IN             NUMBER 	DEFAULT NULL
  , p_oe_order_line_id      IN             NUMBER 	DEFAULT NULL
  , p_routing               IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_org_id                IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_qty                   IN             NUMBER
  , p_uom_code              IN             VARCHAR2
  , p_lpn                   IN             NUMBER
  , p_revision              IN             VARCHAR2 DEFAULT NULL
  , p_inspect               IN             NUMBER
  , p_txn_source_id         IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_transfer_org_id       IN             NUMBER 	DEFAULT NULL
  , p_wms_process_flag      IN             NUMBER 	DEFAULT NULL
  , p_secondary_qty         IN             NUMBER  DEFAULT NULL --OPM Convergence
  , p_secondary_uom         IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  );

  PROCEDURE packunpack_container(
    p_api_version             IN             NUMBER
  , p_init_msg_list           IN             VARCHAR2 := fnd_api.g_false
  , p_commit                  IN             VARCHAR2 := fnd_api.g_false
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     NUMBER
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_from_lpn_id             IN             NUMBER 	:= NULL
  , p_lpn_id                  IN             NUMBER
  , p_content_lpn_id          IN             NUMBER 	:= NULL
  , p_content_item_id         IN             NUMBER 	:= NULL
  , p_content_item_desc       IN             VARCHAR2 := NULL
  , p_revision                IN             VARCHAR2 := NULL
  , p_lot_number              IN             VARCHAR2 := NULL
  , p_from_serial_number      IN             VARCHAR2 := NULL
  , p_to_serial_number        IN             VARCHAR2 := NULL
  , p_quantity                IN             NUMBER 	:= NULL
  , p_uom                     IN             VARCHAR2 := NULL
  , p_organization_id         IN             NUMBER
  , p_subinventory            IN             VARCHAR2 := NULL
  , p_locator_id              IN             NUMBER 	:= NULL
  , p_enforce_wv_constraints  IN             NUMBER 	:= 2
  , p_operation               IN             NUMBER
  , p_cost_group_id           IN             NUMBER 	:= NULL
  , p_source_type_id          IN             NUMBER 	:= NULL
  , p_source_header_id        IN             NUMBER 	:= NULL
  , p_source_name             IN             VARCHAR2 := NULL
  , p_source_line_id          IN             NUMBER 	:= NULL
  , p_source_line_detail_id   IN             NUMBER 	:= NULL
  , p_homogeneous_container   IN             NUMBER 	:= 2
  , p_match_locations         IN             NUMBER 	:= 2
  , p_match_lpn_context       IN             NUMBER 	:= 2
  , p_match_lot               IN             NUMBER 	:= 2
  , p_match_cost_groups       IN             NUMBER 	:= 2
  , p_match_mtl_status        IN             NUMBER 	:= 2
  );

  PROCEDURE detect_asn_discrepancy(
    p_shipment_header_id              NUMBER
  , p_lpn_id                          NUMBER
  , p_po_header_id                    NUMBER
  , x_discrepancy_flag    OUT NOCOPY  NUMBER
  , x_return_status       OUT NOCOPY  VARCHAR2
  , x_msg_count           OUT NOCOPY  NUMBER
  , x_msg_data            OUT NOCOPY  VARCHAR2
  );


  -- Check if there are LPNs on this shipment
  -- If there's LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

  PROCEDURE check_lpn_on_shipment(
    p_shipment_number       IN             VARCHAR2
  , p_from_organization_id  IN             NUMBER
  , p_to_organization_id    IN             NUMBER
  , x_lpn_flag              OUT NOCOPY     NUMBER
  , x_return_status         OUT NOCOPY     VARCHAR2
  , x_msg_count             OUT NOCOPY     NUMBER
  , x_msg_data              OUT NOCOPY     VARCHAR2
  );

  -- Check if there are LPNs on this ASN
  -- If there's LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

  PROCEDURE check_lpn_on_asn(
    p_shipment_header_id  IN             VARCHAR2
  , x_lpn_flag            OUT NOCOPY     NUMBER
  , x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  );

  PROCEDURE check_lpn_on_req(
    p_req_num        IN             VARCHAR2
  , x_lpn_flag       OUT NOCOPY     NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  );

  PROCEDURE update_lpn_org(
    p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  , x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  );

  PROCEDURE remove_lpn_contents(
    p_lpn_id         IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  , p_routing_id     IN             NUMBER DEFAULT NULL
  );

  PROCEDURE clear_lpn_for_ship(
    p_organization_id     IN             NUMBER
  , p_shipment_header_id  IN             NUMBER
  , x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  , p_routing_id          IN             NUMBER DEFAULT NULL
  );

  PROCEDURE populate_lot_rec(
    p_lot_number    IN  VARCHAR2
  , p_primary_qty   IN  NUMBER
  , p_txn_uom_code  IN  VARCHAR2
  , p_org_id            NUMBER
  , p_item_id       IN  NUMBER
  , p_secondary_quantity  IN NUMBER DEFAULT NULL);
 --Added to fix the Bug #4037082
 --This procedure will validate the entered lot quantity
 --against the shipped lot quantity
 PROCEDURE validate_lot_qty(
     p_lot_number         IN  VARCHAR2
  ,  p_inventory_item_id  IN  NUMBER
  ,  p_lot_txn_qty        IN  NUMBER
  ,  p_lot_primary_qty    IN  NUMBER
  ,  p_shipment_header_id IN  NUMBER
  ,  p_rcv_org_id         IN  NUMBER
  ,  x_return_status      OUT NOCOPY  VARCHAR2
  );

 --Added to fix the Bug #4086191
 --overload the procedure created above
 --with one more parameter, p_product_txn_id
 PROCEDURE validate_lot_qty(
     p_lot_number         IN  VARCHAR2
  ,  p_inventory_item_id  IN  NUMBER
  ,  p_lot_txn_qty        IN  NUMBER
  ,  p_lot_primary_qty    IN  NUMBER
  ,  p_shipment_header_id IN  NUMBER
  ,  p_rcv_org_id         IN  NUMBER
  ,  p_product_txn_id     IN  NUMBER
  ,  x_return_status      OUT NOCOPY  VARCHAR2
  );

  /* Bug 6830559: Making the procedure public, as this is now called from
   * INVRCVVB.pls
   */
  PROCEDURE get_project_task(
    p_po_line_location_id  IN             NUMBER
  , p_oe_order_line_id     IN             NUMBER
  , x_project_id           OUT NOCOPY     NUMBER
  , x_task_id              OUT NOCOPY     NUMBER
  );

  --Added to fix the Bug #6908946
  --overload the procedure created above
  --with one more parameter, p_from_lpn_id
  PROCEDURE validate_lot_qty(
      p_lot_number         IN  VARCHAR2
   ,  p_inventory_item_id  IN  NUMBER
   ,  p_lot_txn_qty        IN  NUMBER
   ,  p_lot_primary_qty    IN  NUMBER
   ,  p_shipment_header_id IN  NUMBER
   ,  p_rcv_org_id         IN  NUMBER
   ,  p_product_txn_id     IN  NUMBER
   ,  p_from_lpn_id        IN  NUMBER
   ,  x_return_status      OUT NOCOPY  VARCHAR2
   );

END inv_rcv_std_rcpt_apis;

/
