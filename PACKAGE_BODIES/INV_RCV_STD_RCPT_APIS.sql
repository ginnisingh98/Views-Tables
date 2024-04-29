--------------------------------------------------------
--  DDL for Package Body INV_RCV_STD_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_STD_RCPT_APIS" AS
  /* $Header: INVSTDRB.pls 120.24.12010000.27 2011/05/11 23:19:29 sfulzele ship $*/

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_STD_RCPT_APIS';

  --g_rcpt_lot_qty_rec_tb rcpt_lot_qty_rec_tb_tp;
  --g_prev_lot_number VARCHAR2(30) := NULL;

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER DEFAULT 4) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(
            p_err_msg => p_err_msg
          , p_module => 'INV_RCV_STD_RCPT_APIS'
          , p_level => p_level);
    END IF;
  --   dbms_output.put_line(p_err_msg);
  END print_debug;

  PROCEDURE get_project_task(
    p_po_line_location_id  IN             NUMBER
  , p_oe_order_line_id     IN             NUMBER
  , x_project_id           OUT NOCOPY     NUMBER
  , x_task_id              OUT NOCOPY     NUMBER
  ) IS
    l_project_id NUMBER := '';
    l_task_id    NUMBER := '';
    l_debug      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('get_project_task: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF p_po_line_location_id IS NOT NULL THEN
       --BUG 3444210: Modify the query below for performance reason
       SELECT
   pod.project_id project_id
   ,NVL(pod.task_id, '') task_id
   INTO l_project_id
           , l_task_id
   FROM po_distributions_all pod
   WHERE pod.line_location_id = p_po_line_location_id
   AND ROWNUM = 1
   AND pod.project_id IS NOT NULL
   ORDER BY nvl(pod.task_id,-1) DESC;
    ELSIF p_oe_order_line_id IS NOT NULL THEN
      SELECT project_id
           , task_id
        INTO l_project_id
           , l_task_id
        FROM oe_order_lines_all
       WHERE line_id = p_oe_order_line_id;
    END IF;

    x_project_id := l_project_id;
    x_task_id := l_task_id;

    IF (l_debug = 1) THEN
      print_debug('project_id:' || x_project_id, 4);
      print_debug('task_id:' || x_task_id, 4);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_project_id := '';
      x_task_id := '';
  END get_project_task;

  FUNCTION insert_txn_interface(
    p_rcv_transaction_rec  IN OUT NOCOPY  rcv_transaction_rec_tp
  , p_rcv_rcpt_rec         IN OUT NOCOPY  rcv_enter_receipts_rec_tp
  , p_group_id             IN             NUMBER
  , p_transaction_type     IN             VARCHAR2
  , p_organization_id      IN             NUMBER
  , p_location_id          IN             NUMBER
  , p_source_type          IN             VARCHAR2
  , p_qa_routing_id        IN             NUMBER DEFAULT -1
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_express_transaction  IN             VARCHAR2 DEFAULT NULL

  )
    RETURN NUMBER IS
    l_rcv_transaction_rec        rcv_transaction_rec_tp; -- rcv_transaction block
    l_rti_rowid                  VARCHAR2(40);
    l_interface_transaction_id   NUMBER;
    l_sysdate                    DATE           := SYSDATE;
    l_txn_date                   DATE           := Sysdate;
    l_auto_transact_code         VARCHAR2(30);
    l_shipment_line_id           NUMBER;
    l_primary_uom                VARCHAR2(25);
    l_source_type_code           VARCHAR2(30);
    l_vendor_id                  NUMBER;
    l_vendor_site_id             NUMBER;
    l_from_org_id                NUMBER;
    l_to_org_id                  NUMBER;
    l_source_doc_code            VARCHAR2(30);
    l_po_header_id               NUMBER;
    l_po_release_id              NUMBER;
    l_po_line_id                 NUMBER;
    l_po_line_location_id        NUMBER;
    l_po_distribution_id         NUMBER;
    l_req_line_id                NUMBER;
    l_sub_unordered_code         VARCHAR2(30);
    l_deliver_to_person_id       NUMBER;
    l_location_id                NUMBER;
    l_deliver_to_location_id     NUMBER;
    l_subinventory               VARCHAR2(10);
    l_locator_id                 NUMBER;
    l_wip_entity_id              NUMBER;
    l_wip_line_id                NUMBER;
    l_department_code            VARCHAR2(30);
    l_wip_rep_sched_id           NUMBER;
    l_wip_oper_seq_num           NUMBER;
    l_wip_res_seq_num            NUMBER;
    l_bom_resource_id            NUMBER;
    l_oe_order_header_id         NUMBER;
    l_oe_order_line_id           NUMBER;
    l_customer_item_num          NUMBER;
    l_customer_id                NUMBER;
    l_customer_site_id           NUMBER;
    l_rate                       NUMBER;
    l_shipment_header_id         NUMBER;
    --variables for defaulting rcv_transaction non-db items

    x_available_qty              NUMBER;
    x_ordered_qty                NUMBER;
    x_primary_qty                NUMBER;
    x_tolerable_qty              NUMBER;
    x_uom                        VARCHAR2(25);
    x_primary_uom                VARCHAR2(25);
    x_valid_ship_to_location     BOOLEAN;
    x_num_of_distributions       NUMBER;
    x_po_distribution_id         NUMBER;
    x_destination_type_code      VARCHAR2(30);
    x_destination_type_dsp       VARCHAR2(80);
    x_deliver_to_location_id     NUMBER;
    x_deliver_to_location        VARCHAR2(80);
    x_deliver_to_person_id       NUMBER;
    x_deliver_to_person          VARCHAR2(240);
    x_deliver_to_sub             VARCHAR2(10);
    x_deliver_to_locator_id      NUMBER;
    x_wip_entity_id              NUMBER;
    x_wip_repetitive_schedule_id NUMBER;
    x_wip_line_id                NUMBER;
    x_wip_operation_seq_num      NUMBER;
    x_wip_resource_seq_num       NUMBER;
    x_bom_resource_id            NUMBER;
    x_to_organization_id         NUMBER;
    x_job                        VARCHAR2(80);
    x_line_num                   VARCHAR2(10);
    x_sequence                   NUMBER;
    x_department                 VARCHAR2(40);
    x_enforce_ship_to_loc        VARCHAR2(30);
    x_allow_substitutes          VARCHAR2(3);
    x_routing_id                 NUMBER;
    x_qty_rcv_tolerance          NUMBER;
    x_qty_rcv_exception          VARCHAR2(30);
    x_days_early_receipt         NUMBER;
    x_days_late_receipt          NUMBER;
    x_rcv_days_exception         VARCHAR2(30);
    x_item_revision              VARCHAR2(3);
    x_locator_control            NUMBER;
    x_inv_destinations           BOOLEAN;
    x_rate                       NUMBER;
    x_rate_date                  DATE;
    x_project_id                 NUMBER;
    x_task_id                    NUMBER;
    x_req_line_id                NUMBER;
    x_pos                        NUMBER;
    x_oe_order_line_id           NUMBER;
    x_item_id                    NUMBER;
    x_org_id                     NUMBER;
    x_category_id                NUMBER;
    x_category_set_id            NUMBER;
    x_routing_name               VARCHAR2(240);
    l_project_id                 NUMBER := p_project_id;
    l_task_id                    NUMBER := p_task_id;
    l_validation_flag            VARCHAR2(1);
    l_lpn_group_id               NUMBER;
    l_header_interface_id        NUMBER;
    l_debug                      NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --OPM Convergence
    l_secondary_unit_of_measure              VARCHAR2(25);
    l_secondary_uom_code         VARCHAR2(3);
    l_secondary_quantity         NUMBER;
    l_express_transaction        VARCHAR2(1) := NVL(p_express_transaction, 'N');

    t_sec_uom_code VARCHAR2(3);
     t_sec_uom VARCHAR2(25); t_sec_qty NUMBER;

     l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;   --<R12 MOAC>

     l_po_item_id MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE; --bug 4697949
     l_substitute_item_id MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE; --bug 4697949

-- For Bug 7440217
     v_lcm_enabled_org  varchar2(1) := 'N';
     v_pre_receive      varchar2(1) := 'N';
     v_lcm_flag         varchar2(1) := 'N';
     v_lcm_ship_line_id NUMBER;
     v_unit_landed_cost NUMBER;
-- End for Bug 7440217
     l_client_code VARCHAR2(40);  /* Bug 9158529: LSP Changes */

  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter insert_txn_interface: 1   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('insert_txn_interface: p_express_transaction ' || p_express_transaction, 1);
      print_debug('insert_txn_interface: l_express_transaction ' || l_express_transaction, 1);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface 2 value of coutry of origin is ' || p_rcv_rcpt_rec.country_of_origin_code, 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface: revision1  - ' || p_rcv_transaction_rec.item_revision, 4); -- revision needs to be taken care of by matching
    END IF;

    print_debug('Rcpt source code ' || p_rcv_rcpt_rec.receipt_source_code);
  --  print_debug('Rcv Sub ' || p_rcv_transaction_rec.destination_subinventory);
  --  print_debug('Rcv Loc ' || p_rcv_transaction_rec.locator_id);
    l_rcv_transaction_rec := p_rcv_transaction_rec;
    -- populate DB items in rcv_transaction block
    l_rcv_transaction_rec.line_chkbox := p_rcv_rcpt_rec.line_chkbox;
    l_rcv_transaction_rec.source_type_code := p_rcv_rcpt_rec.source_type_code;
    l_rcv_transaction_rec.receipt_source_code := p_rcv_rcpt_rec.receipt_source_code;
    l_rcv_transaction_rec.order_type_code := p_rcv_rcpt_rec.order_type_code;
    l_rcv_transaction_rec.order_type := p_rcv_rcpt_rec.order_type;
    l_rcv_transaction_rec.po_header_id := p_rcv_rcpt_rec.po_header_id;
    l_rcv_transaction_rec.po_number := p_rcv_rcpt_rec.po_number;
    l_rcv_transaction_rec.po_line_id := p_rcv_rcpt_rec.po_line_id;
    l_rcv_transaction_rec.po_line_location_id := p_rcv_rcpt_rec.po_line_location_id;
    l_rcv_transaction_rec.po_line_number := p_rcv_rcpt_rec.po_line_number;
    l_rcv_transaction_rec.po_shipment_number := p_rcv_rcpt_rec.po_shipment_number;
    l_rcv_transaction_rec.po_release_id := p_rcv_rcpt_rec.po_release_id;
    l_rcv_transaction_rec.po_release_number := p_rcv_rcpt_rec.po_release_number;
    l_rcv_transaction_rec.req_header_id := p_rcv_rcpt_rec.req_header_id;
    l_rcv_transaction_rec.req_number := p_rcv_rcpt_rec.req_number;
    l_rcv_transaction_rec.req_line_id := p_rcv_rcpt_rec.req_line_id;
    l_rcv_transaction_rec.req_line := p_rcv_rcpt_rec.req_line;
    l_rcv_transaction_rec.req_distribution_id := p_rcv_rcpt_rec.req_distribution_id;
    l_rcv_transaction_rec.rcv_shipment_header_id := p_rcv_rcpt_rec.rcv_shipment_header_id;
    l_rcv_transaction_rec.rcv_shipment_number := p_rcv_rcpt_rec.rcv_shipment_number;
    l_rcv_transaction_rec.rcv_shipment_line_id := p_rcv_rcpt_rec.rcv_shipment_line_id;
    l_rcv_transaction_rec.rcv_line_number := p_rcv_rcpt_rec.rcv_line_number;
    l_rcv_transaction_rec.from_organization_id := p_rcv_rcpt_rec.from_organization_id;
    l_rcv_transaction_rec.to_organization_id := p_rcv_rcpt_rec.to_organization_id;
    l_rcv_transaction_rec.vendor_id := p_rcv_rcpt_rec.vendor_id;
    --    l_rcv_transaction_rec.source := p_rcv_rcpt_rec.source;
    l_rcv_transaction_rec.vendor_site_id := p_rcv_rcpt_rec.vendor_site_id;
    --    l_rcv_transaction_rec.outside_operation_flag := p_rcv_rcpt_rec.outside_operation_flag;
    l_rcv_transaction_rec.item_id := p_rcv_rcpt_rec.item_id;
    --OPM Convergence
   /* l_rcv_transaction_rec.secondary_uom  := p_rcv_rcpt_rec.secondary_uom;
    l_rcv_transaction_rec.secondary_uom_code  := p_rcv_rcpt_rec.secondary_uom_code;
    l_rcv_transaction_rec .secondary_quantity := p_rcv_rcpt_rec.secondary_quantity; */
    -- end of changes for OPM Convergence changes


    IF (l_debug = 1) THEN
      print_debug('l_rcv_transaction_rec.item_id - ' || l_rcv_transaction_rec.item_id, 4);
      print_debug('l_rcv_transaction_rec.secondary_uom - ' || l_rcv_transaction_rec.secondary_uom, 4);
      print_debug('l_rcv_transaction_rec .secondary_quantity - ' || l_rcv_transaction_rec .secondary_quantity, 4);
    END IF;

    -- Bug 2073164
    l_rcv_transaction_rec.uom_code := p_rcv_rcpt_rec.uom_code;
    l_rcv_transaction_rec.primary_uom_class := p_rcv_rcpt_rec.primary_uom_class;
    l_rcv_transaction_rec.serial_number_control_code := p_rcv_rcpt_rec.serial_number_control_code;
    l_rcv_transaction_rec.lot_control_code := p_rcv_rcpt_rec.lot_control_code;
    l_rcv_transaction_rec.item_rev_control_flag_to := p_rcv_rcpt_rec.item_rev_control_flag_to;
    l_rcv_transaction_rec.item_rev_control_flag_from := p_rcv_rcpt_rec.item_rev_control_flag_from;
    l_rcv_transaction_rec.item_number := p_rcv_rcpt_rec.item_number;
    l_rcv_transaction_rec.item_description := p_rcv_rcpt_rec.item_description;
    l_rcv_transaction_rec.item_category_id := p_rcv_rcpt_rec.item_category_id;
    l_rcv_transaction_rec.vendor_item_number := p_rcv_rcpt_rec.vendor_item_number;
    l_rcv_transaction_rec.ship_to_location_id := p_rcv_rcpt_rec.ship_to_location_id;
    l_rcv_transaction_rec.packing_slip := p_rcv_rcpt_rec.packing_slip;
    l_rcv_transaction_rec.routing_id := p_rcv_rcpt_rec.routing_id;
    l_rcv_transaction_rec.need_by_date := p_rcv_rcpt_rec.need_by_date;
    l_rcv_transaction_rec.expected_receipt_date := p_rcv_rcpt_rec.expected_receipt_date;
    l_rcv_transaction_rec.ordered_uom := p_rcv_rcpt_rec.ordered_uom;
    l_rcv_transaction_rec.ussgl_transaction_code := p_rcv_rcpt_rec.ussgl_transaction_code;
    l_rcv_transaction_rec.government_context := p_rcv_rcpt_rec.government_context;
    l_rcv_transaction_rec.inspection_required_flag := p_rcv_rcpt_rec.inspection_required_flag;
    l_rcv_transaction_rec.receipt_required_flag := p_rcv_rcpt_rec.receipt_required_flag;
    l_rcv_transaction_rec.enforce_ship_to_location_code := p_rcv_rcpt_rec.enforce_ship_to_location_code;
    l_rcv_transaction_rec.unit_price := p_rcv_rcpt_rec.unit_price;
    l_rcv_transaction_rec.currency_code := p_rcv_rcpt_rec.currency_code;
    l_rcv_transaction_rec.currency_conversion_type := p_rcv_rcpt_rec.currency_conversion_type;
    l_rcv_transaction_rec.note_to_receiver := p_rcv_rcpt_rec.note_to_receiver;
    l_rcv_transaction_rec.destination_type_code := p_rcv_rcpt_rec.destination_type_code;
    l_rcv_transaction_rec.deliver_to_location_id := p_rcv_rcpt_rec.deliver_to_location_id;
    l_rcv_transaction_rec.attribute_category := p_rcv_rcpt_rec.attribute_category;
    l_rcv_transaction_rec.attribute1 := p_rcv_rcpt_rec.attribute1;
    l_rcv_transaction_rec.attribute2 := p_rcv_rcpt_rec.attribute2;
    l_rcv_transaction_rec.attribute3 := p_rcv_rcpt_rec.attribute3;
    l_rcv_transaction_rec.attribute4 := p_rcv_rcpt_rec.attribute4;
    l_rcv_transaction_rec.attribute5 := p_rcv_rcpt_rec.attribute5;
    l_rcv_transaction_rec.attribute6 := p_rcv_rcpt_rec.attribute6;
    l_rcv_transaction_rec.attribute7 := p_rcv_rcpt_rec.attribute7;
    l_rcv_transaction_rec.attribute8 := p_rcv_rcpt_rec.attribute8;
    l_rcv_transaction_rec.attribute9 := p_rcv_rcpt_rec.attribute9;
    l_rcv_transaction_rec.attribute10 := p_rcv_rcpt_rec.attribute10;
    l_rcv_transaction_rec.attribute11 := p_rcv_rcpt_rec.attribute11;
    l_rcv_transaction_rec.attribute12 := p_rcv_rcpt_rec.attribute12;
    l_rcv_transaction_rec.attribute13 := p_rcv_rcpt_rec.attribute13;
    l_rcv_transaction_rec.attribute14 := p_rcv_rcpt_rec.attribute14;
    l_rcv_transaction_rec.attribute15 := p_rcv_rcpt_rec.attribute15;
    l_rcv_transaction_rec.closed_code := p_rcv_rcpt_rec.closed_code;
    l_rcv_transaction_rec.asn_type := p_rcv_rcpt_rec.asn_type;
    l_rcv_transaction_rec.bill_of_lading := p_rcv_rcpt_rec.bill_of_lading;
    l_rcv_transaction_rec.shipped_date := p_rcv_rcpt_rec.shipped_date;
    l_rcv_transaction_rec.freight_carrier_code := p_rcv_rcpt_rec.freight_carrier_code;
    l_rcv_transaction_rec.waybill_airbill_num := p_rcv_rcpt_rec.waybill_airbill_num;
    l_rcv_transaction_rec.freight_bill_num := p_rcv_rcpt_rec.freight_bill_num;
    l_rcv_transaction_rec.vendor_lot_num := p_rcv_rcpt_rec.vendor_lot_num;
    l_rcv_transaction_rec.container_num := p_rcv_rcpt_rec.container_num;
    l_rcv_transaction_rec.truck_num := p_rcv_rcpt_rec.truck_num;
    l_rcv_transaction_rec.bar_code_label := p_rcv_rcpt_rec.bar_code_label;
    l_rcv_transaction_rec.match_option := p_rcv_rcpt_rec.match_option;
    l_rcv_transaction_rec.country_of_origin_code := p_rcv_rcpt_rec.country_of_origin_code;
    l_rcv_transaction_rec.oe_order_header_id := p_rcv_rcpt_rec.oe_order_header_id;
    l_rcv_transaction_rec.oe_order_num := p_rcv_rcpt_rec.oe_order_num;
    l_rcv_transaction_rec.oe_order_line_id := p_rcv_rcpt_rec.oe_order_line_id;
    l_rcv_transaction_rec.oe_order_line_num := p_rcv_rcpt_rec.oe_order_line_num;
    l_rcv_transaction_rec.customer_id := p_rcv_rcpt_rec.customer_id;
    l_rcv_transaction_rec.customer_site_id := p_rcv_rcpt_rec.customer_site_id;

    --    l_rcv_transaction_rec.customer_item_num := p_rcv_rcpt_rec.customer_item_num;
    -- defaulting other non-db items
    -- generate l_interface_transaction_id
    -- QA Skip lot change
    -- interface txn id is generated in create_po at times as we need to
    -- pass that to quality. So using that if it is generated.
    IF l_rcv_transaction_rec.interface_transaction_id IS NOT NULL THEN
      l_interface_transaction_id := l_rcv_transaction_rec.interface_transaction_id;
    ELSE
      SELECT rcv_transactions_interface_s.NEXTVAL
        INTO l_interface_transaction_id
        FROM DUAL;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('RTI interface id:' || l_interface_transaction_id, 4);
      print_debug('insert_txn_interface: 2  before RCV_RECEIPTS_QUERY_SV.POST_QUERY ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4);
    END IF;

    -- call defaulting api
    rcv_receipts_query_sv.post_query(
      l_rcv_transaction_rec.po_line_location_id
    , l_rcv_transaction_rec.rcv_shipment_line_id
    , l_rcv_transaction_rec.receipt_source_code
    , l_rcv_transaction_rec.to_organization_id
    , l_rcv_transaction_rec.item_id
    , l_rcv_transaction_rec.primary_uom_class
    , l_rcv_transaction_rec.ship_to_location_id
    , l_rcv_transaction_rec.vendor_id
    , l_rcv_transaction_rec.customer_id
    , l_rcv_transaction_rec.item_rev_control_flag_to
    , x_available_qty
    , x_primary_qty
    , x_tolerable_qty
    , x_uom
    , x_primary_uom
    , x_valid_ship_to_location
    , x_num_of_distributions
    , x_po_distribution_id
    , x_destination_type_code
    , x_destination_type_dsp
    , x_deliver_to_location_id
    , x_deliver_to_location
    , x_deliver_to_person_id
    , x_deliver_to_person
    , x_deliver_to_sub
    , x_deliver_to_locator_id
    , x_wip_entity_id
    , x_wip_repetitive_schedule_id
    , x_wip_line_id
    , x_wip_operation_seq_num
    , x_wip_resource_seq_num
    , x_bom_resource_id
    , x_to_organization_id
    , x_job
    , x_line_num
    , x_sequence
    , x_department
    , x_enforce_ship_to_loc
    , x_allow_substitutes
    , x_routing_id
    , x_qty_rcv_tolerance
    , x_qty_rcv_exception
    , x_days_early_receipt
    , x_days_late_receipt
    , x_rcv_days_exception
    , x_item_revision
    , x_locator_control
    , x_inv_destinations
    , x_rate
    , x_rate_date
    , l_rcv_transaction_rec.asn_type
    , l_rcv_transaction_rec.oe_order_header_id
    , l_rcv_transaction_rec.oe_order_line_id
    , l_rcv_transaction_rec.from_organization_id
    );

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface: 3  after RCV_RECEIPTS_QUERY_SV.POST_QUERY ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_rcv_transaction_rec.destination_type_code_hold := x_destination_type_code;

    IF l_rcv_transaction_rec.source_type_code = 'CUSTOMER' THEN
      -- get the item category based on item_id, category_set_id and org_id

      IF l_rcv_transaction_rec.item_category_id IS NULL THEN
        BEGIN
          SELECT MAX(category_id)
            INTO l_rcv_transaction_rec.item_category_id
            FROM mtl_item_categories
           WHERE inventory_item_id = l_rcv_transaction_rec.item_id
             AND organization_id = p_organization_id
             AND category_set_id = inv_rcv_common_apis.g_po_startup_value.category_set_id;
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              print_debug('insert_txn_interface: Exception in getting the item categories', 4);
            END IF;
        END;
      END IF;

      IF NVL(l_rcv_transaction_rec.inspection_required_flag, 'N') = 'Y' THEN
        x_routing_id := 2;
      -- Bug 3124881 Get the default routing parameter from rcv_parameters
      ELSIF ( l_rcv_transaction_rec.receipt_source_code = 'CUSTOMER' ) then
          Begin

            /* Bug 9158529: LSP Changes */

            IF (NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'), 1) = 3) THEN

            l_client_code := wms_deploy.get_client_code(l_rcv_transaction_rec.item_id);


            If (l_client_code IS NOT NULL) THEN

              select RMA_RECEIPT_ROUTING_ID
  	          into   x_routing_id
  	          from mtl_client_parameters
              WHERE client_code = l_client_code;


            ELSE

             select rma_receipt_routing_id
             into x_routing_id
             from rcv_parameters
             where organization_id = p_organization_id;


            End If;

            Else

             select rma_receipt_routing_id
             into x_routing_id
             from rcv_parameters
             where organization_id = p_organization_id;

           END IF;

	   /* End Bug 9158529 */

            IF (l_debug = 1) THEN
              print_debug('insert_txn_interface: from rcv parameters: x_routing_id = '|| x_routing_id, 4);
            END IF;

          Exception
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                print_debug('insert_txn_interface: Exception in getting the routing id from rcv parameters', 4);
                print_debug('insert_txn_interface: routing id is set to what fetched from post_query : x_routing_id ='|| x_routing_id, 4);
              END IF;
          End;
      END IF;

      /*
             select routing_name
          into l_rcv_transaction_rec.routing_name
          from rcv_routing_headers
         where routing_header_id = x_routing_id;
      */
      x_available_qty := l_rcv_transaction_rec.ordered_qty;
    --       x_uom := l_rcv_transaction_rec.ordered_uom;

    END IF;

    -- using a nvl around p_qa_routing_id as calling apis pass null sometimes

    IF (Nvl(p_qa_routing_id,-1) = -1) THEN
       --BUG 3346758: For Int Ship, if the intrasit shipment is set
       --created with a routing id, then the user go and change it in the
       --shipping network form.  Post_query above would return a different
       --id then the one passed in UI.  So, the check below is used to
       --bypass this scenario.
       IF (l_rcv_transaction_rec.routing_id IS NULL) THEN
    l_rcv_transaction_rec.routing_id := x_routing_id;
       END IF;
    ELSE
      l_rcv_transaction_rec.routing_id := p_qa_routing_id;
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.blind_receiving_flag = 'Y' THEN
      x_available_qty := 0;
      l_rcv_transaction_rec.ordered_qty := 0;
    END IF;

    IF (NOT x_valid_ship_to_location) THEN
      l_rcv_transaction_rec.ship_to_location_id := '';
    --       l_rcv_transaction_rec.ship_to_location := '';
    END IF;

    IF (NVL(l_rcv_transaction_rec.receipt_source_code, 'VENDOR') = 'CUSTOMER') THEN
      -- Final destination for an RMA receiving trx. is always inventory.
      SELECT displayed_field
           , lookup_code
        INTO x_destination_type_dsp
           , x_destination_type_code
        FROM po_lookup_codes
       WHERE lookup_code = 'INVENTORY'
         AND lookup_type = 'RCV DESTINATION TYPE';
    END IF;

    l_rcv_transaction_rec.destination_type_code_hold := x_destination_type_code;

   --Bug #3792668
   --Checking the conversion rate has been defined for a currency
   --which is other than functional one for the transaction date.
   --Taken out this portion of code from the check --> IF l_rcv_transaction_rec.routing_id IN('1', '2') THEN
   --Changes Start

   IF l_rcv_transaction_rec.routing_id IN('1', '2') THEN
     IF x_num_of_distributions <= 1 THEN
        l_rcv_transaction_rec.currency_conversion_rate := x_rate;
        l_rcv_transaction_rec.currency_conversion_date := x_rate_date;
     END IF;
   END IF;

     -- currency coversion info post query
     -- copied from rcv_currency_c1.PostQuery (RCVRCCUR.pld)

     IF l_rcv_transaction_rec.match_option <> 'P' THEN
       l_rcv_transaction_rec.currency_conversion_date := l_sysdate;

       IF (l_rcv_transaction_rec.currency_code <> inv_rcv_common_apis.g_po_startup_value.currency_code) THEN
         l_rate := l_rcv_transaction_rec.currency_conversion_rate;

         IF (l_rcv_transaction_rec.currency_conversion_type <> 'User') THEN
           BEGIN
             l_rate :=
               gl_currency_api.get_rate(
                 inv_rcv_common_apis.g_po_startup_value.sob_id
               , l_rcv_transaction_rec.currency_code
               , l_rcv_transaction_rec.currency_conversion_date
               , l_rcv_transaction_rec.currency_conversion_type
               );

           EXCEPTION
             WHEN gl_currency_api.no_rate THEN
               l_rate := NULL;
             WHEN gl_currency_api.invalid_currency THEN
               l_rate := NULL;
             WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                  print_debug('insert_txn_interface: ERROR in getting the Conversion Rate' , 4);
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
           END;

           IF (l_debug = 1) THEN
             print_debug('insert_txn_interface : l_rate :  ' || l_rate, 4);
           END IF;

           -- Give error message to user that no rate has been found
           IF l_rate IS NULL THEN
             fnd_message.set_name('PO', 'PO_CPO_NO_RATE_FOR_DATE');
             fnd_msg_pub.add;
             IF (l_debug = 1) THEN
                print_debug('insert_txn_interface: No Conversion rate has been defined for the currency : ' || l_rcv_transaction_rec.currency_code || ' for the txn date :  ' || l_rcv_transaction_rec.currency_conversion_date , 4);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

         END IF;

         l_rcv_transaction_rec.currency_conversion_rate := l_rate;
       END IF;
     END IF;
     --End of fix for the Bug #3792668


    IF l_rcv_transaction_rec.routing_id IN('1', '2') THEN
      l_rcv_transaction_rec.destination_type_code := 'RECEIVING';
      -- following fields will be set at po_distribution level if
      -- it has a direct routing
      l_rcv_transaction_rec.po_distribution_id := x_po_distribution_id;
      l_rcv_transaction_rec.deliver_to_location_id := x_deliver_to_location_id;
 --     l_rcv_transaction_rec.locator_id := x_deliver_to_locator_id;
      l_rcv_transaction_rec.deliver_to_person_id := x_deliver_to_person_id;
  --  l_rcv_transaction_rec.locator_id := x_deliver_to_locator_id; --RCVCLOCSSUPPORT

  --    IF x_deliver_to_sub IS NOT NULL THEN
 --       l_rcv_transaction_rec.destination_subinventory := x_deliver_to_sub;
 --     END IF; RCVLOCSSUPPORT --RCVLOCSSUPPORT

      IF (x_wip_entity_id > 0) THEN
        l_rcv_transaction_rec.wip_entity_id := x_wip_entity_id;
        l_rcv_transaction_rec.wip_line_id := x_wip_line_id;
        l_rcv_transaction_rec.wip_repetitive_schedule_id := x_wip_repetitive_schedule_id;
        l_rcv_transaction_rec.wip_operation_seq_num := x_wip_operation_seq_num;
        l_rcv_transaction_rec.wip_resource_seq_num := x_wip_resource_seq_num;
        l_rcv_transaction_rec.bom_resource_id := x_bom_resource_id;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('insert_txn_interface: revision2  - ' || x_item_revision, 4);
      END IF;

      -- revision needs to be taken care of by matching

      IF x_item_revision IS NOT NULL THEN
        l_rcv_transaction_rec.item_revision := x_item_revision;
      END IF;

      IF (
          x_req_line_id IS NOT NULL
          AND x_deliver_to_locator_id IS NOT NULL
          AND NVL(l_rcv_transaction_rec.receipt_source_code, 'VENDOR') <> 'VENDOR'
         ) THEN
        SELECT project_id
             , task_id
          INTO x_project_id
             , x_task_id
          FROM po_req_distributions
         WHERE requisition_line_id = x_req_line_id;
      END IF;

      IF (
          l_rcv_transaction_rec.receipt_source_code = 'CUSTOMER'
          AND x_oe_order_line_id IS NOT NULL
          AND x_deliver_to_locator_id IS NOT NULL
         ) THEN
        SELECT project_id
             , task_id
          INTO x_project_id
             , x_task_id
          FROM oe_order_lines_all
         WHERE line_id = x_oe_order_line_id;
      END IF;

      IF x_project_id IS NOT NULL THEN
        pjm_project_locator.get_defaultprojectlocator(
              p_organization_id
            , x_deliver_to_locator_id
            , x_project_id
            , x_task_id
            , x_deliver_to_locator_id);
      END IF;

    --  l_rcv_transaction_rec.locator_id := x_deliver_to_locator_id;
    ELSE
      IF (NVL(l_rcv_transaction_rec.receipt_source_code, 'VENDOR') = 'CUSTOMER') THEN
        SELECT lookup_code
          INTO l_rcv_transaction_rec.destination_type_code
          FROM po_lookup_codes
         WHERE lookup_code = 'INVENTORY'
           AND lookup_type = 'RCV DESTINATION TYPE';
      END IF;
    END IF;

    IF l_rcv_transaction_rec.destination_type_code = 'RECEIVING'
       AND p_location_id IS NOT NULL THEN
      l_rcv_transaction_rec.ship_to_location_id := p_location_id;
    ELSE
      l_rcv_transaction_rec.deliver_to_location_id := p_location_id;
    END IF;
    -- end defaulting

    -- prepare other values before inserting into RTI
    -- this part of code is replicating RCV_RECEIPTS_TH.insert_transaction (RCVRCERL.pld)
    l_primary_uom := l_rcv_transaction_rec.primary_uom;
    l_source_type_code := l_rcv_transaction_rec.receipt_source_code;
    l_source_doc_code := l_rcv_transaction_rec.order_type_code;
    l_to_org_id := l_rcv_transaction_rec.to_organization_id;
    l_sub_unordered_code := l_rcv_transaction_rec.substitute_receipt;
    --OPM Convergence
    l_secondary_unit_of_measure := l_rcv_transaction_rec.secondary_uom;
    l_secondary_uom_code := l_rcv_transaction_rec.secondary_uom_code;
    l_secondary_quantity := l_rcv_transaction_rec .secondary_quantity;
    --end of changes for OPM Convergence

    print_debug('l_secondary_quantity ' || l_secondary_quantity,4);
    print_debug('l_secondary_uom_code ' || l_secondary_uom_code,4);
    print_debug('l_secondary_unit_of_measure ' || l_secondary_unit_of_measure,4);


-- For Bug 7440217 added LCM Doc type along with ASN
    IF l_rcv_transaction_rec.source_type_code IN('VENDOR', 'ASN', 'LCM') THEN
-- End for Bug 7440217
      l_vendor_id := l_rcv_transaction_rec.vendor_id;
      l_vendor_site_id := l_rcv_transaction_rec.vendor_site_id;
      l_po_header_id := l_rcv_transaction_rec.po_header_id;
      l_po_release_id := l_rcv_transaction_rec.po_release_id;
      l_po_line_id := l_rcv_transaction_rec.po_line_id;
      l_po_line_location_id := l_rcv_transaction_rec.po_line_location_id;
    ELSIF l_rcv_transaction_rec.source_type_code = 'CUSTOMER' THEN
      l_customer_id := l_rcv_transaction_rec.customer_id;
      l_customer_site_id := l_rcv_transaction_rec.customer_site_id;
      l_oe_order_header_id := l_rcv_transaction_rec.oe_order_header_id;
      l_oe_order_line_id := l_rcv_transaction_rec.oe_order_line_id;
    ELSIF l_rcv_transaction_rec.source_type_code = 'INTERNAL' THEN
      l_req_line_id := l_rcv_transaction_rec.req_line_id;
      l_from_org_id := l_rcv_transaction_rec.from_organization_id;
      l_shipment_line_id := l_rcv_transaction_rec.rcv_shipment_line_id;
    END IF;

-- For Bug 7440217 added LCM Doc type along with ASN
    IF l_rcv_transaction_rec.source_type_code IN ('ASN', 'LCM') THEN
-- End for Bug 7440217
      l_shipment_line_id := l_rcv_transaction_rec.rcv_shipment_line_id;
    END IF;

    IF l_rcv_transaction_rec.destination_type_code = 'RECEIVING' THEN
      l_auto_transact_code := 'RECEIVE';
      l_location_id  := l_rcv_transaction_rec.ship_to_location_id;
      l_subinventory := l_rcv_transaction_rec.destination_subinventory; --RCVLOCSSUPPORT
      l_locator_id   := l_rcv_transaction_rec.locator_id;
    ELSE
      l_auto_transact_code := 'DELIVER';
      l_po_distribution_id := l_rcv_transaction_rec.po_distribution_id;
      l_deliver_to_person_id := l_rcv_transaction_rec.deliver_to_person_id;
      l_deliver_to_location_id := l_rcv_transaction_rec.deliver_to_location_id;
      l_subinventory := l_rcv_transaction_rec.destination_subinventory;
      l_locator_id := l_rcv_transaction_rec.locator_id;
      l_location_id := l_rcv_transaction_rec.deliver_to_location_id;

-- For Bug 7440217 added LCM Doc type along with ASN
      IF l_rcv_transaction_rec.source_type_code IN('VENDOR', 'ASN', 'LCM') THEN
-- End for Bug 7440217
        l_wip_entity_id := l_rcv_transaction_rec.wip_entity_id;
        l_wip_line_id := l_rcv_transaction_rec.wip_line_id;
        l_department_code := l_rcv_transaction_rec.department_code;
        l_wip_rep_sched_id := l_rcv_transaction_rec.wip_repetitive_schedule_id;
        l_wip_oper_seq_num := l_rcv_transaction_rec.wip_operation_seq_num;
        l_wip_res_seq_num := l_rcv_transaction_rec.wip_resource_seq_num;
        l_bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
      END IF;
    END IF;

    l_sub_unordered_code := l_rcv_transaction_rec.substitute_receipt;

    IF l_rcv_transaction_rec.receipt_source_code = 'CUSTOMER' THEN
      l_source_doc_code := 'RMA';
    END IF;

    -- insert this record into RTI
    -- Insert the row into the interface table using
    -- the table handler call for the
    -- rcv_transactions_interface table

    -- For inter-org shipment and ASN receipt, shipment header id is set already
    -- For Normal PO, we generate a shipment header id at this point,
    -- then use the same when actually inserting record into RSH.
    -- If it is to receive a PO that belongs to an ASN,
    -- we need to create a new shipment header for it

    -- If patchset J since the g_shipment_header_id is cleared from
    -- rcv_clear_global in INVRCVCB.pls and not g_header_intf_id
    -- we look at g_shipment_header_id to figure out if we need
    -- to generate a new value for header_intf_id to insert in RTI.
    IF g_shipment_header_id IS NULL THEN
      SELECT rcv_headers_interface_s.NEXTVAL
      INTO g_header_intf_id
      FROM dual;
    END IF;

    IF l_rcv_transaction_rec.source_type_code = 'INTERNAL'
-- For Bug 7440217
       OR(l_rcv_transaction_rec.source_type_code IN ('ASN', 'LCM')
-- End for Bug 7440217
          AND p_source_type <> 'VENDOR') THEN
      g_shipment_header_id := l_rcv_transaction_rec.rcv_shipment_header_id;
    END IF;

    IF g_shipment_header_id IS NULL THEN
      SELECT rcv_shipment_headers_s.NEXTVAL
        INTO g_shipment_header_id
        FROM DUAL;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface: 4  before rcv_trx_interface_insert_pkg.insert_row '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface: revision3 - ' || l_rcv_transaction_rec.item_revision, 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface: rcv sub loc - ' || l_subinventory ||' , '|| l_locator_id, 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('insert_txn_interface before insert row  value of coutry of origin is '
        || l_rcv_transaction_rec.country_of_origin_code
      , 4);
    END IF;

    /* If INV and PO J are installed, :
     *    -> shipment_header_id should be inserted as null but header_interface_id
     *       should be inserted. Header_interface_id will be non null only if INV
     *       and  PO J are installed (or higher).
     *    -> Populate values for three new columns lpn_group_id, validation_flag
     *       and header_interface_id_id
     *    -> Populate project_id and task_id in RTI from inputs
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF ((l_rcv_transaction_rec.source_type_code = 'INTERNAL') OR
-- For Bug 7440217
         (l_rcv_transaction_rec.source_type_code IN ('ASN', 'LCM') AND p_source_type <> 'VENDOR')) THEN
-- End for Bug 7440217
        IF (l_debug = 1) THEN
          print_debug('Setting the shipment_header_id as this may be a INTSHIP/ASN Receive TXN', 4);
        END IF;
        l_shipment_header_id := g_shipment_header_id;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('Nulling the shipment_header_id to insert for J code', 4);
        END IF;
        l_shipment_header_id := NULL;
      END IF;

      --Set the values of the new columns to be populated in RTI
      l_lpn_group_id := p_group_id;
      l_validation_flag := 'Y';
      l_header_interface_id := g_header_intf_id;

      IF p_project_id = -9999 THEN
        l_project_id := NULL;
      END IF;

      IF p_task_id = -9999 THEN
        l_task_id := NULL;
      END IF;

    --If INV or PO patch levels are lower than J
    ELSE
      l_shipment_header_id := g_shipment_header_id;
      l_header_interface_id := NULL;
      l_lpn_group_id := NULL;
      l_validation_flag := NULL;
      l_project_id := NULL;
      l_task_id := NULL;
    END IF;

    -- bug 3452845
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
       l_txn_date := Sysdate;
     ELSE
       l_txn_date := Trunc(Sysdate);
    END IF;

    --BUG 4730474: populate the document number column when receiving
    --against INTSHP/INTREQ so that the receiving preprocessor can
    --match to the right line
    IF (p_rcv_rcpt_rec.receipt_source_code = 'INVENTORY') then --bug 5483231
       l_rcv_transaction_rec.rcv_line_number := p_rcv_rcpt_rec.rcv_line_number;
     ELSE
       l_rcv_transaction_rec.rcv_line_number := NULL;
    END IF;

 print_debug('b4 inserting l_secondary_quantity ' || l_secondary_quantity,4);
    print_debug('b4 insertingl_secondary_uom_code ' || l_secondary_uom_code,4);
    print_debug('b4 insertingl_secondary_unit_of_measure ' || l_secondary_unit_of_measure,4);

    --<R12 MOAC>
    l_operating_unit_id := inv_rcv_common_apis.get_operating_unit_id(
                                     l_rcv_transaction_rec.receipt_source_code,
                                     l_rcv_transaction_rec.po_header_id,
                                     l_rcv_transaction_rec.req_line_id,
                                     l_rcv_transaction_rec.oe_order_header_id );

    --Using the direct insert statement here rather than table handler

    /*bug 4697949.Populating the rti.item with item_id from po_line
      and populating substitute_item_id with item_id so that the transaction
      passes the validation.also nulling out description so that it can bedefaulted
      correctly later on*/

    /** Bug: 5598511
      * Added the following conditions rcv_shipment_header_id not null and
      * item_id not null.
      */
    IF     l_po_line_id IS NOT null
       and l_rcv_transaction_rec.rcv_shipment_header_id IS NULL
       and l_rcv_transaction_rec.item_id IS NOT NULL  THEN
      SELECT item_id
      INTO   l_po_item_id
      FROM   po_lines_all pol
      WHERE  pol.po_line_id = l_po_line_id;

      IF (l_po_item_id <> l_rcv_transaction_rec.item_id) THEN
        l_substitute_item_id := l_rcv_transaction_rec.item_id;
        l_rcv_transaction_rec.item_id := l_po_item_id;
	l_rcv_transaction_rec.item_description := null;
      END IF;
    END IF;
    print_debug('l_express_transaction: ' || l_express_transaction,4);
    -- bug 4697949 end
    INSERT INTO rcv_transactions_interface
              (
               interface_transaction_id
             , GROUP_ID
             , last_update_date
             , last_updated_by
             , creation_date
             , created_by
             , last_update_login
             , transaction_type
             , transaction_date
             , processing_status_code
             , processing_mode_code
             , processing_request_id
             , transaction_status_code
             , category_id
             , quantity
             , unit_of_measure
             , interface_source_code
             , interface_source_line_id
             , inv_transaction_id
             , item_id
             , item_description
             , item_revision
             , uom_code
             , employee_id
             , auto_transact_code
             , shipment_header_id
             , shipment_line_id
             , ship_to_location_id
             , primary_quantity
             , primary_unit_of_measure
             , receipt_source_code
             , vendor_id
             , vendor_site_id
             , from_organization_id
             , to_organization_id
             , routing_header_id
             , routing_step_id
             , source_document_code
             , parent_transaction_id
             , po_header_id
             , po_revision_num
             , po_release_id
             , po_line_id
             , po_line_location_id
             , po_unit_price
             , currency_code
             , currency_conversion_type
             , currency_conversion_rate
             , currency_conversion_date
             , po_distribution_id
             , requisition_line_id
             , req_distribution_id
             , charge_account_id
             , substitute_unordered_code
             , receipt_exception_flag
             , accrual_status_code
             , inspection_status_code
             , inspection_quality_code
             , destination_type_code
             , deliver_to_person_id
             , location_id
             , deliver_to_location_id
             , subinventory
             , locator_id
             , wip_entity_id
             , wip_line_id
             , department_code
             , wip_repetitive_schedule_id
             , wip_operation_seq_num
             , wip_resource_seq_num
             , bom_resource_id
             , shipment_num
             , freight_carrier_code
             , bill_of_lading
             , packing_slip
             , shipped_date
             , expected_receipt_date
             , actual_cost
             , transfer_cost
             , transportation_cost
             , transportation_account_id
             , num_of_containers
             , waybill_airbill_num
             , vendor_item_num
             , vendor_lot_num
             , rma_reference
             , comments
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
             , ship_head_attribute_category
             , ship_head_attribute1
             , ship_head_attribute2
             , ship_head_attribute3
             , ship_head_attribute4
             , ship_head_attribute5
             , ship_head_attribute6
             , ship_head_attribute7
             , ship_head_attribute8
             , ship_head_attribute9
             , ship_head_attribute10
             , ship_head_attribute11
             , ship_head_attribute12
             , ship_head_attribute13
             , ship_head_attribute14
             , ship_head_attribute15
             , ship_line_attribute_category
             , ship_line_attribute1
             , ship_line_attribute2
             , ship_line_attribute3
             , ship_line_attribute4
             , ship_line_attribute5
             , ship_line_attribute6
             , ship_line_attribute7
             , ship_line_attribute8
             , ship_line_attribute9
             , ship_line_attribute10
             , ship_line_attribute11
             , ship_line_attribute12
             , ship_line_attribute13
             , ship_line_attribute14
             , ship_line_attribute15
             , ussgl_transaction_code
             , government_context
             , reason_id
             , destination_context
             , source_doc_quantity
             , source_doc_unit_of_measure
             , use_mtl_lot
             , use_mtl_serial
             , qa_collection_id
             , country_of_origin_code
             , oe_order_header_id
             , oe_order_line_id
             , customer_item_num
             , customer_id
             , customer_site_id
             , put_away_rule_id
             , put_away_strategy_id
             , lpn_id
             , transfer_lpn_id
             , cost_group_id
             , mmtt_temp_id
             , mobile_txn
             , transfer_cost_group_id
             , lpn_group_id
             , validation_flag
             , header_interface_id
             , project_id
             , task_id
             , secondary_unit_of_measure --OPM Convergence
             , secondary_quantity --OPM Convergence
             , secondary_uom_code --OPM Convergence
	     , org_id              --<R12 MOAC>
             , document_line_num  --BUG 4730474
	     , substitute_item_id --bug 4697949
	     , express_transaction --bug 5550783
              )
       VALUES (
               l_interface_transaction_id
             , p_group_id
             , l_sysdate
             , inv_rcv_common_apis.g_po_startup_value.user_id  /* Last Updated By */
             , l_sysdate  /* Created Date */
             , inv_rcv_common_apis.g_po_startup_value.user_id  /* Created By */
             , inv_rcv_common_apis.g_po_startup_value.user_id  /* last Update Login */
             , p_transaction_type  /* transaction type */
             , l_txn_date  /* transaction date */
             , 'PENDING'  /* Processing status code */
             , inv_rcv_common_apis.g_po_startup_value.transaction_mode
             , NULL
             , 'PENDING'  /* Transaction status code */
             , l_rcv_transaction_rec.item_category_id
             , l_rcv_transaction_rec.transaction_qty
             , l_rcv_transaction_rec.transaction_uom
             , 'RCV'  /* interface source code */
             , NULL  /* interface source line id */
             , NULL  /* inv_transaction id */
             , l_rcv_transaction_rec.item_id
             , l_rcv_transaction_rec.item_description
             , l_rcv_transaction_rec.item_revision
             , l_rcv_transaction_rec.uom_code
             , inv_rcv_common_apis.g_po_startup_value.employee_id -- Fix for bug 2073164
             , l_auto_transact_code  /* Auto transact code */
             , l_shipment_header_id  /* shipment header id */
             , l_shipment_line_id  /* shipment line id */
             , l_rcv_transaction_rec.ship_to_location_id
             , l_rcv_transaction_rec.primary_quantity  /* primary quantity */
             , l_primary_uom  /* primary uom */
             , l_source_type_code  /* receipt source code */
             , l_vendor_id
             , l_vendor_site_id
             , l_from_org_id  /* from org id */
             , l_to_org_id  /* to org id */
             , l_rcv_transaction_rec.routing_id
             , 1  /* routing step id */
             , l_source_doc_code  /* source document code */
             , NULL  /* Parent trx id */
             , l_po_header_id
             , NULL  /* PO Revision number */
             , l_po_release_id
             , l_po_line_id
             , l_po_line_location_id
             , l_rcv_transaction_rec.unit_price
             , l_rcv_transaction_rec.currency_code  /* Currency_Code */
             , l_rcv_transaction_rec.currency_conversion_type
             , l_rcv_transaction_rec.currency_conversion_rate
             , TRUNC(l_rcv_transaction_rec.currency_conversion_date)
             , l_po_distribution_id
             , l_req_line_id
             , l_rcv_transaction_rec.req_distribution_id
             , NULL  /* Charge_Account_Id */
             , l_sub_unordered_code  /* Substitute_Unordered_Code */
             , l_rcv_transaction_rec.receipt_exception  /* Receipt_Exception_Flag  forms check box?*/
             , NULL  /* Accrual_Status_Code */
             , 'NOT INSPECTED'  /* Inspection_Status_Code */
             , NULL  /* Inspection_Quality_Code */
             , l_rcv_transaction_rec.destination_type_code  /* Destination_Type_Code */
             , l_deliver_to_person_id  /* Deliver_To_Person_Id */
             , l_location_id  /* Location_Id */
             , l_deliver_to_location_id  /* Deliver_To_Location_Id */
             , l_subinventory  /* Subinventory */
             , l_locator_id  /* Locator_Id */
             , l_wip_entity_id  /* Wip_Entity_Id */
             , l_wip_line_id  /* Wip_Line_Id */
             , l_department_code  /* Department_Code */
             , l_wip_rep_sched_id  /* Wip_Repetitive_Schedule_Id */
             , l_wip_oper_seq_num  /* Wip_Operation_Seq_Num */
             , l_wip_res_seq_num  /* Wip_Resource_Seq_Num */
             , l_bom_resource_id  /* Bom_Resource_Id */
             , l_rcv_transaction_rec.rcv_shipment_number
             , NULL
             , NULL  /* Bill_Of_Lading */
             , NULL  /* Packing_Slip */
             , TRUNC(l_rcv_transaction_rec.shipped_date)
             , TRUNC(l_rcv_transaction_rec.expected_receipt_date)  /* Expected_Receipt_Date */
             , NULL  /* Actual_Cost */
             , NULL  /* Transfer_Cost */
             , NULL  /* Transportation_Cost */
             , NULL  /* Transportation_Account_Id */
             , NULL  /* Num_Of_Containers */
             , NULL  /* Waybill_Airbill_Num */
             , l_rcv_transaction_rec.vendor_item_number  /* Vendor_Item_Num */
             , l_rcv_transaction_rec.vendor_lot_num  /* Vendor_Lot_Num */
             , NULL  /* Rma_Reference */
             , l_rcv_transaction_rec.comments  /* Comments  ? from form*/
             , l_rcv_transaction_rec.attribute_category  /* Attribute_Category */
             , l_rcv_transaction_rec.attribute1  /* Attribute1 */
             , l_rcv_transaction_rec.attribute2  /* Attribute2 */
             , l_rcv_transaction_rec.attribute3  /* Attribute3 */
             , l_rcv_transaction_rec.attribute4  /* Attribute4 */
             , l_rcv_transaction_rec.attribute5  /* Attribute5 */
             , l_rcv_transaction_rec.attribute6  /* Attribute6 */
             , l_rcv_transaction_rec.attribute7  /* Attribute7 */
             , l_rcv_transaction_rec.attribute8  /* Attribute8 */
             , l_rcv_transaction_rec.attribute9  /* Attribute9 */
             , l_rcv_transaction_rec.attribute10  /* Attribute10 */
             , l_rcv_transaction_rec.attribute11  /* Attribute11 */
             , l_rcv_transaction_rec.attribute12  /* Attribute12 */
             , l_rcv_transaction_rec.attribute13  /* Attribute13 */
             , l_rcv_transaction_rec.attribute14  /* Attribute14 */
             , l_rcv_transaction_rec.attribute15  /* Attribute15 */
             , NULL  /* Ship_Head_Attribute_Category */
             , NULL  /* Ship_Head_Attribute1 */
             , NULL  /* Ship_Head_Attribute2 */
             , NULL  /* Ship_Head_Attribute3 */
             , NULL  /* Ship_Head_Attribute4 */
             , NULL  /* Ship_Head_Attribute5 */
             , NULL  /* Ship_Head_Attribute6 */
             , NULL  /* Ship_Head_Attribute7 */
             , NULL  /* Ship_Head_Attribute8 */
             , NULL  /* Ship_Head_Attribute9 */
             , NULL  /* Ship_Head_Attribute10 */
             , NULL  /* Ship_Head_Attribute11 */
             , NULL  /* Ship_Head_Attribute12 */
             , NULL  /* Ship_Head_Attribute13 */
             , NULL  /* Ship_Head_Attribute14 */
             , NULL  /* Ship_Head_Attribute15 */
             , NULL  /* Ship_Line_Attribute_Category */
             , NULL  /* Ship_Line_Attribute1 */
             , NULL  /* Ship_Line_Attribute2 */
             , NULL  /* Ship_Line_Attribute3 */
             , NULL  /* Ship_Line_Attribute4 */
             , NULL  /* Ship_Line_Attribute5 */
             , NULL  /* Ship_Line_Attribute6 */
             , NULL  /* Ship_Line_Attribute7 */
             , NULL  /* Ship_Line_Attribute8 */
             , NULL  /* Ship_Line_Attribute9 */
             , NULL  /* Ship_Line_Attribute10 */
             , NULL  /* Ship_Line_Attribute11 */
             , NULL  /* Ship_Line_Attribute12 */
             , NULL  /* Ship_Line_Attribute13 */
             , NULL  /* Ship_Line_Attribute14 */
             , NULL  /* Ship_Line_Attribute15 */
             , l_rcv_transaction_rec.ussgl_transaction_code  /* Ussgl_Transaction_Code */
             , l_rcv_transaction_rec.government_context  /* Government_Context */
             , l_rcv_transaction_rec.reason_id  /* ? */
             , l_rcv_transaction_rec.destination_type_code  /* Destination_Context */
             , l_rcv_transaction_rec.transaction_qty
             , l_rcv_transaction_rec.transaction_uom
             , l_rcv_transaction_rec.lot_control_code
             , l_rcv_transaction_rec.serial_number_control_code
             , NULL
             , l_rcv_transaction_rec.country_of_origin_code
             , l_oe_order_header_id
             , l_oe_order_line_id
             , l_customer_item_num
             , l_customer_id
             , l_customer_site_id
             , NULL  /* PUT_AWAY_RULE_ID */
             , NULL  /* PUT_AWAY_STRATEGY_ID */
             , l_rcv_transaction_rec.lpn_id  /* LPN_ID */
             , l_rcv_transaction_rec.transfer_lpn_id  /* Transfer LPN ID */
             , l_rcv_transaction_rec.cost_group_id  /* cost_group_id */
             , NULL  /* mmtt_temp_id */
             , 'Y'  /* mobile_txn */
             , l_rcv_transaction_rec.transfer_cost_group_id  /* xfer_cost_group_id*/
             , l_lpn_group_id
             , l_validation_flag
             , l_header_interface_id
             , l_project_id
             , l_task_id
             , l_secondary_unit_of_measure
             , l_secondary_quantity
             , l_secondary_uom_code
	     , l_operating_unit_id  --<R12 MOAC>
             , l_rcv_transaction_rec.rcv_line_number--BUG 4730474
	     , l_substitute_item_id --bug 4697949
	     , l_express_transaction --bug 5550783
              );

-- For Bug 7440217 added the following code to update RTI with the status as PENDING so that it gets picked up for processing

IF l_po_line_location_id IS NOT NULL THEN
  SELECT  LCM_FLAG
  INTO    v_lcm_flag
  FROM    PO_LINE_LOCATIONS_ALL
  WHERE   LINE_LOCATION_ID = l_po_line_location_id;
END IF;

IF nvl(v_lcm_flag, 'N') = 'Y' THEN
  SELECT  mp.lcm_enabled_flag
  INTO    v_lcm_enabled_org
  FROM    mtl_parameters mp
  WHERE	  mp.organization_id = l_to_org_id;

  SELECT  rp.pre_receive
  INTO    v_pre_receive
  FROM    rcv_parameters rp
  WHERE	  rp.organization_id = l_to_org_id;

/*  SELECT  LCM_FLAG
  INTO    v_lcm_flag
  FROM    PO_LINE_LOCATIONS_ALL
  WHERE   LINE_LOCATION_ID = l_po_line_location_id;
*/

  IF	nvl(v_lcm_enabled_org, 'N') = 'Y' THEN
	IF	nvl(v_pre_receive, 'N') = 'Y'   THEN

		  SELECT	LCM_SHIPMENT_LINE_ID, UNIT_LANDED_COST
		  INTO		v_lcm_ship_line_id, v_unit_landed_cost
		  FROM		rcv_shipment_lines
		  WHERE		shipment_line_id = l_shipment_line_id;

		  UPDATE	rcv_transactions_interface
		  SET		lcm_shipment_line_id = v_lcm_ship_line_id,
				    unit_landed_cost = v_unit_landed_cost
		  WHERE		interface_transaction_id = l_interface_transaction_id
		  AND		to_organization_id = l_to_org_id;

	ELSE
		  UPDATE	rcv_transactions_interface
		  SET		processing_status_code = 'LC_PENDING',
                    PROCESSING_MODE_CODE = 'BATCH'
		  WHERE		interface_transaction_id = l_interface_transaction_id
		  AND		to_organization_id = l_to_org_id;

	END IF;
 END IF;
END IF;
-- End for Bug 7440217

BEGIN
    SELECT secondary_uom_code, secondary_unit_of_measure,
       secondary_quantity
       INTO t_sec_uom_code, t_sec_uom, t_sec_qty
       FROM rcv_transactions_interface
       WHERE interface_transaction_id = l_interface_transaction_id;
    print_debug('t_sec_uom_code ' || t_sec_uom_code, 1);
    print_debug('t_sec_uom ' || t_sec_uom, 1);
    print_debug('t_sec_qty ' || t_sec_qty, 1);
EXCEPTION
   WHEN OTHERS THEN
print_debug('other error ' || SQLERRM,1);
END;
    IF (l_debug = 1) THEN
      print_debug('About exit insert_txn_interface: 5  after rcv_trx_interface_insert_pkg.insert_row '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    RETURN l_interface_transaction_id;
  END insert_txn_interface;

  /****************************************************
  *  This procedure populates the data structure that
  *  stores received lot quantity.
  *  It retrieves this info  from wms_LPN_contents table
  ****************************************************/
  PROCEDURE populate_lot_rec(
    p_lot_number    IN  VARCHAR2
  , p_primary_qty   IN  NUMBER
  , p_txn_uom_code  IN  VARCHAR2
  , p_org_id            NUMBER
  , p_item_id       IN  NUMBER
  , p_secondary_quantity  IN NUMBER
  ) IS
    l_primary_uom VARCHAR2(3);
    l_txn_qty     NUMBER;
    l_counter     NUMBER;
    l_create_new  NUMBER      := 1;
    l_debug       NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --OPM Convergence
    l_sec_txn_qty NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter populate_lot_rec: 1  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SELECT primary_uom_code
      INTO l_primary_uom
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_org_id;

    IF (l_debug = 1) THEN
      print_debug('populate_lot_rec: 2  p_primary_qty = ' || p_primary_qty || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('p_item_id = ' || p_item_id || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('l_primary_uom = ' || l_primary_uom || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('p_txn_uom_code = ' || p_txn_uom_code || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    -- it is txn qty in primary uom passed from PackUnpack
       -- need to convert it to txn uom qty here
    IF (l_primary_uom <> p_txn_uom_code) THEN
       l_txn_qty := inv_rcv_cache.convert_qty
	             (p_inventory_item_id    => p_item_id
		      ,p_from_qty            => p_primary_qty
		      ,p_from_uom_code       => l_primary_uom
		      ,p_to_uom_code         => p_txn_uom_code);
     ELSE
       l_txn_qty := p_primary_qty;
    END IF;

    --OPM Convergence
    l_sec_txn_qty := p_secondary_quantity;

    FOR i IN 1 .. g_rcpt_lot_qty_rec_tb.COUNT LOOP
      IF g_rcpt_lot_qty_rec_tb(i).lot_number = p_lot_number THEN
        g_rcpt_lot_qty_rec_tb(i).txn_quantity := g_rcpt_lot_qty_rec_tb(i).txn_quantity + l_txn_qty;
        --OPM Convergence
        g_rcpt_lot_qty_rec_tb(i).sec_txn_quantity := g_rcpt_lot_qty_rec_tb(i).sec_txn_quantity + l_sec_txn_qty;
        l_create_new := 0;
        EXIT;
      END IF;
    END LOOP;

    IF l_create_new = 1 THEN
      l_counter := g_rcpt_lot_qty_rec_tb.COUNT + 1;
      g_rcpt_lot_qty_rec_tb(l_counter).txn_quantity := l_txn_qty;
      --OPM Convergence
      g_rcpt_lot_qty_rec_tb(l_counter).sec_txn_quantity := l_sec_txn_qty;
      g_rcpt_lot_qty_rec_tb(l_counter).lot_number := p_lot_number;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_lot_rec: 3  l_txn_qty = ' || l_txn_qty || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_lot_number = ' || p_lot_number || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;
  END populate_lot_rec;

  /****************************************************
  *  This procedure splits the input transaction qty
  *  based on received lot qty
  *  It retrieves this info  from global variable g_rcpt_lot_qty_rec_tb
  ****************************************************/
  PROCEDURE split_qty_for_lot(p_txn_qty IN NUMBER, p_splitted_qty_rec_tb OUT NOCOPY rcpt_lot_qty_rec_tb_tp) IS
    l_new_txn_quantity NUMBER; -- the quanity user wants to split
    l_new_counter      NUMBER := 0;
    l_debug            NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter split_qty_for_lot: 1  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_new_txn_quantity := p_txn_qty;

    IF (l_debug = 1) THEN
      print_debug('split_qty_for_lot: 1.1 txn qty :' || l_new_txn_quantity, 4);
    END IF;

    FOR i IN 1 .. g_rcpt_lot_qty_rec_tb.COUNT LOOP -- Loop through all the transaction lines need to be splitted
      IF (l_debug = 1) THEN
        print_debug('split_qty_for_lot: 1.2 lot_number - ' || g_rcpt_lot_qty_rec_tb(i).lot_number, 4);
        print_debug('split_qty_for_lot: 1.3 lot_txn_qty - ' || g_rcpt_lot_qty_rec_tb(i).txn_quantity, 4);
      END IF;

      IF l_new_txn_quantity > g_rcpt_lot_qty_rec_tb(i).txn_quantity
         AND g_rcpt_lot_qty_rec_tb(i).txn_quantity > 0 THEN
        -- reduce input qty
        l_new_txn_quantity := l_new_txn_quantity - g_rcpt_lot_qty_rec_tb(i).txn_quantity;
        -- create a record in output table
        l_new_counter := l_new_counter + 1;
        p_splitted_qty_rec_tb(l_new_counter).txn_quantity := g_rcpt_lot_qty_rec_tb(i).txn_quantity;
        p_splitted_qty_rec_tb(l_new_counter).lot_number := g_rcpt_lot_qty_rec_tb(i).lot_number;
        -- set lot record table quantity
        g_rcpt_lot_qty_rec_tb(i).txn_quantity := 0;
      ELSIF l_new_txn_quantity < g_rcpt_lot_qty_rec_tb(i).txn_quantity THEN
        -- create a record in output table
        l_new_counter := l_new_counter + 1;
        p_splitted_qty_rec_tb(l_new_counter).txn_quantity := l_new_txn_quantity;
        p_splitted_qty_rec_tb(l_new_counter).lot_number := g_rcpt_lot_qty_rec_tb(i).lot_number;
        -- set lot record table quantity
        g_rcpt_lot_qty_rec_tb(i).txn_quantity := g_rcpt_lot_qty_rec_tb(i).txn_quantity - l_new_txn_quantity;
        -- exit loop
        EXIT;
      ELSIF l_new_txn_quantity = g_rcpt_lot_qty_rec_tb(i).txn_quantity THEN
        -- create a record in output table
        l_new_counter := l_new_counter + 1;
        p_splitted_qty_rec_tb(l_new_counter).txn_quantity := l_new_txn_quantity;
        p_splitted_qty_rec_tb(l_new_counter).lot_number := g_rcpt_lot_qty_rec_tb(i).lot_number;
        -- set lot record table quantity
        g_rcpt_lot_qty_rec_tb(i).txn_quantity := g_rcpt_lot_qty_rec_tb(i).txn_quantity - l_new_txn_quantity;
      END IF;
    END LOOP;

    IF (l_debug = 1) THEN
      print_debug('About Exit split_qty_for_lot: 2  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  END split_qty_for_lot;

  /** Bug #4147209 -
    * New procedure added to populate the attribute_category
    * and attributes 1-15 columns of the enter receipts record type
    * with the values passed from the Mobile Receipt UI
    */
  PROCEDURE set_attribute_vals (
      p_rcv_rcpt_rec         IN OUT NOCOPY  rcv_enter_receipts_rec_tp
    , p_attribute_category   IN             VARCHAR2  DEFAULT NULL
    , p_attribute1           IN             VARCHAR2  DEFAULT NULL
    , p_attribute2           IN             VARCHAR2  DEFAULT NULL
    , p_attribute3           IN             VARCHAR2  DEFAULT NULL
    , p_attribute4           IN             VARCHAR2  DEFAULT NULL
    , p_attribute5           IN             VARCHAR2  DEFAULT NULL
    , p_attribute6           IN             VARCHAR2  DEFAULT NULL
    , p_attribute7           IN             VARCHAR2  DEFAULT NULL
    , p_attribute8           IN             VARCHAR2  DEFAULT NULL
    , p_attribute9           IN             VARCHAR2  DEFAULT NULL
    , p_attribute10          IN             VARCHAR2  DEFAULT NULL
    , p_attribute11          IN             VARCHAR2  DEFAULT NULL
    , p_attribute12          IN             VARCHAR2  DEFAULT NULL
    , p_attribute13          IN             VARCHAR2  DEFAULT NULL
    , p_attribute14          IN             VARCHAR2  DEFAULT NULL
    , p_attribute15          IN             VARCHAR2  DEFAULT NULL) IS
  BEGIN
    p_rcv_rcpt_rec.attribute_category := p_attribute_category;
    p_rcv_rcpt_rec.attribute1         := p_attribute1;
    p_rcv_rcpt_rec.attribute2         := p_attribute2;
    p_rcv_rcpt_rec.attribute3         := p_attribute3;
    p_rcv_rcpt_rec.attribute4         := p_attribute4;
    p_rcv_rcpt_rec.attribute5         := p_attribute5;
    p_rcv_rcpt_rec.attribute6         := p_attribute6;
    p_rcv_rcpt_rec.attribute7         := p_attribute7;
    p_rcv_rcpt_rec.attribute8         := p_attribute8;
    p_rcv_rcpt_rec.attribute9         := p_attribute9;
    p_rcv_rcpt_rec.attribute10        := p_attribute10;
    p_rcv_rcpt_rec.attribute11        := p_attribute11;
    p_rcv_rcpt_rec.attribute12        := p_attribute12;
    p_rcv_rcpt_rec.attribute13        := p_attribute13;
    p_rcv_rcpt_rec.attribute14        := p_attribute14;
    p_rcv_rcpt_rec.attribute15        := p_attribute15;
  END set_attribute_vals;


  PROCEDURE create_po_rcpt_intf_rec(
    p_move_order_header_id   IN OUT NOCOPY  NUMBER
  , p_organization_id        IN             NUMBER
  , p_po_header_id           IN             NUMBER
  , p_po_release_number_id   IN             NUMBER
  , p_po_line_id             IN             NUMBER
  , p_item_id                IN             NUMBER
  , p_location_id            IN             NUMBER
  , p_rcv_qty                IN             NUMBER
  , p_rcv_uom                IN             VARCHAR2
  , p_rcv_uom_code           IN             VARCHAR2
  , p_source_type            IN             VARCHAR2
  , p_lpn_id                 IN             NUMBER
  , p_lot_control_code       IN             NUMBER
  , p_revision               IN             VARCHAR2
  , p_inspect                IN             NUMBER
  , x_status                 OUT NOCOPY     VARCHAR2
  , x_message                OUT NOCOPY     VARCHAR2
  , p_inv_item_id            IN             NUMBER    DEFAULT NULL
  , p_item_desc              IN             VARCHAR2  DEFAULT NULL
  , p_project_id             IN             NUMBER    DEFAULT NULL
  , p_task_id                IN             NUMBER    DEFAULT NULL
  , p_country_code           IN             VARCHAR2  DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2  DEFAULT NULL -- RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER    DEFAULT NULL
  , p_original_rti_id        IN             NUMBER    DEFAULT NULL  --Lot/Serial Support
  --OPM convergence
  , p_secondary_uom          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_uom_code     IN             VARCHAR2 DEFAULT NULL
  , p_secondary_quantity          IN             NUMBER   DEFAULT NULL
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF columns
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
  ) IS
    l_rcpt_match_table_detail  inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec      rcv_transaction_rec_tp; -- rcv_transaction block
    l_interface_transaction_id NUMBER                                      := NULL;
    -- this is used to keep track of the id used to insert the row in rti

    l_transaction_type         VARCHAR2(20) := 'RECEIVE';
    l_total_primary_qty        NUMBER       := 0;
    l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_progress                 VARCHAR2(10);
    l_err_message              VARCHAR2(100);
    l_temp_message             VARCHAR2(100);
    l_msg_prod                 VARCHAR2(5);
    l_group_id                 NUMBER;
    l_inspect                  NUMBER;
    l_qa_availability          VARCHAR2(30) := fnd_api.g_false;
    l_qa_routing_id            NUMBER       := -1;
    l_evaluation_result        VARCHAR2(20);
    -- bug 2797704
    -- changed the defaulting from null to the passed values
    l_project_id               NUMBER       := p_project_id;
    l_task_id                  NUMBER       := p_task_id;
    --Bug 4699085
    l_item_revision						 VARCHAR2(10);

    CURSOR l_curs_rcpt_detail(v_po_line_location_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'VENDOR' source_type_code
           , 'VENDOR' receipt_source_code
           , 'PO' order_type_code
           , '' order_type
           , poll.po_header_id po_header_id
           , poh.segment1 po_number
           , poll.po_line_id po_line_id
           , pol.line_num po_line_number
           , poll.line_location_id po_line_location_id
           , poll.shipment_num po_shipment_number
           , poll.po_release_id po_release_id
           , por.release_num po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           --Passing the values as NULL   --Bug #3878174
           , TO_NUMBER(NULL) rcv_shipment_header_id
           , NULL rcv_shipment_number
           , TO_NUMBER(NULL) rcv_shipment_line_id
           , TO_NUMBER(NULL) rcv_line_number
           , TO_NUMBER(NULL) from_organization_id
/*
           , poh.po_header_id rcv_shipment_header_id
           , poh.segment1 rcv_shipment_number
           , pol.po_line_id rcv_shipment_line_id
           , pol.line_num rcv_line_number
           , poh.po_header_id from_organization_id
*/
           , poll.ship_to_organization_id to_organization_id
           , poh.vendor_id vendor_id
           , '' SOURCE
           , poh.vendor_site_id vendor_site_id
           , '' outside_operation_flag
           , pol.item_id item_id
           , -- Bug 2073164
             NULL uom_code
--         , pol.unit_meas_lookup_code primary_uom
	   , msi.primary_unit_of_measure primary_uom /* Bug 5665041:Primary UOM should be taken from MSI*/
           , mum.uom_class primary_uom_class
           , NULL item_allowed_units_lookup_code
           , NULL item_locator_control
           , '' restrict_locators_code
           , '' restrict_subinventories_code
           , NULL shelf_life_code
           , NULL shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , NULL item_number
           , pol.item_revision item_revision
           , pol.item_description item_description
           , pol.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , pol.vendor_product_num vendor_item_number
           , poll.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , NULL packing_slip
           , poll.receiving_routing_id routing_id
           , '' routing_name
           , poll.need_by_date need_by_date
           , NVL(poll.promised_date, poll.need_by_date) expected_receipt_date
           , poll.quantity ordered_qty
           , pol.unit_meas_lookup_code ordered_uom
           , NULL ussgl_transaction_code
           , poll.government_context government_context
           , poll.inspection_required_flag inspection_required_flag
           , poll.receipt_required_flag receipt_required_flag
           , poll.enforce_ship_to_location_code enforce_ship_to_location_code
           , NVL(poll.price_override, pol.unit_price) unit_price
           , poh.currency_code currency_code
           , poh.rate_type currency_conversion_type
           , poh.rate_date currency_conversion_date
           , poh.rate currency_conversion_rate
           , poh.note_to_receiver note_to_receiver
           , NULL destination_type_code
           , TO_NUMBER(NULL) deliver_to_person_id
           , TO_NUMBER(NULL) deliver_to_location_id
           , NULL destination_subinventory
           , poll.attribute_category attribute_category
           , poll.attribute1 attribute1
           , poll.attribute2 attribute2
           , poll.attribute3 attribute3
           , poll.attribute4 attribute4
           , poll.attribute5 attribute5
           , poll.attribute6 attribute6
           , poll.attribute7 attribute7
           , poll.attribute8 attribute8
           , poll.attribute9 attribute9
           , poll.attribute10 attribute10
           , poll.attribute11 attribute11
           , poll.attribute12 attribute12
           , poll.attribute13 attribute13
           , poll.attribute14 attribute14
           , poll.attribute15 attribute15
           , poll.closed_code closed_code
           , NULL asn_type
           , NULL bill_of_lading
           , TO_DATE(NULL) shipped_date
           , NULL freight_carrier_code
           , NULL waybill_airbill_num
           , NULL freight_bill_num
           , NULL vendor_lot_num
           , NULL container_num
           , NULL truck_num
           , NULL bar_code_label
           , '' rate_type_display
           , poll.match_option match_option
           , poll.country_of_origin_code country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --POLL.NOTE_TO_RECEIVER PLL_NOTE_TO_RECEIVER,
             NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
           , pol.secondary_uom secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , pol.secondary_qty secondary_quantity --OPM Convergence* commented out temp
        FROM po_headers poh
            , po_line_locations poll
            , po_lines pol
            , po_releases por
            , mtl_system_items msi
            , mtl_units_of_measure mum
       WHERE poll.line_location_id = v_po_line_location_id
         AND poh.po_header_id = poll.po_header_id
         AND pol.po_line_id = poll.po_line_id
         AND poll.po_release_id = por.po_release_id(+)
         AND mum.unit_of_measure(+) = pol.unit_meas_lookup_code
         AND NVL(msi.organization_id, poll.ship_to_organization_id) = poll.ship_to_organization_id
         AND msi.inventory_item_id(+) = pol.item_id
         AND poll.line_location_id IN(
              SELECT pod.line_location_id
                FROM po_distributions_all pod
               WHERE (
                      p_project_id IS NULL
                      OR(p_project_id = -9999
                         AND pod.project_id IS NULL) --bug#2669021
                      OR pod.project_id = p_project_id
                     )
                 AND(p_task_id IS NULL
                     OR pod.task_id = p_task_id)
                 AND pod.po_header_id = poll.po_header_id
                 AND pod.po_line_id = poll.po_line_id
                 AND pod.line_location_id = poll.line_location_id);

    l_rcv_rcpt_rec             rcv_enter_receipts_rec_tp;
    l_debug                    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count              NUMBER := 0;
    l_line_id NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter create_po_rcpt_intf_rec: 10   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug(p_secondary_uom,1);
print_debug(p_secondary_uom_code,1);
print_debug(p_secondary_quantity,1);
    END IF;

    l_progress := '10';
    SAVEPOINT crt_po_rti_sp;
    x_status := fnd_api.g_ret_sts_success;
    l_split_lot_serial_ok := TRUE;

    -- query po_startup_value
    l_progress := '20';

    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    l_progress := '30';

    -- default header level non-DB items in rcv_transaction block
    -- and default other values need to be insert into RTI
    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      l_progress := '40';

      SELECT rcv_interface_groups_s.NEXTVAL
        INTO l_group_id
        FROM DUAL;

      l_progress := '50';

      IF (l_debug = 1) THEN
        print_debug(
             'Enter create_po_rcpt_intf_rec: 20 -  Create l_group_id - l_group_id = '
          || l_group_id
          || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      IF (l_debug = 1) THEN
        print_debug(
             'Enter create_po_rcpt_intf_rec: 30 -  l_group_id exists - l_group_id = '
          || l_group_id
          || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;
    END IF;

    -- initialize input record for matching algorithm
    g_rcpt_match_table_gross(g_receipt_detail_index).GROUP_ID := l_group_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).transaction_type := 'RECEIVE';
    g_rcpt_match_table_gross(g_receipt_detail_index).quantity := p_rcv_qty;
    g_rcpt_match_table_gross(g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    --OPM Convergence
   /* g_rcpt_match_table_gross(g_receipt_detail_index).secondary_quantity := p_secondary_quantity;
    g_rcpt_match_table_gross(g_receipt_detail_index).secondary_uom := p_secondary_uom;*/

    IF (l_debug = 1) THEN
      print_debug(
        'create_po_rcpt_intf_rec: 40-S - p_inv_item_id' || TO_CHAR(p_inv_item_id) || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    IF p_inv_item_id IS NOT NULL THEN -- p_item_id has substitute item id
      g_rcpt_match_table_gross(g_receipt_detail_index).item_id := p_inv_item_id;
    ELSE
      IF p_item_id IS NOT NULL THEN
        g_rcpt_match_table_gross(g_receipt_detail_index).item_id := p_item_id;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('create_po_rcpt_intf_rec: Item id is null - One time item', 4);
        END IF;

        g_rcpt_match_table_gross(g_receipt_detail_index).item_id := NULL;
        g_rcpt_match_table_gross(g_receipt_detail_index).item_desc := p_item_desc;
      END IF;
    END IF;

    g_rcpt_match_table_gross(g_receipt_detail_index).revision := p_revision;
    g_rcpt_match_table_gross(g_receipt_detail_index).po_header_id := p_po_header_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).po_release_id := p_po_release_number_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).po_line_id := p_po_line_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcpt_match_table_gross(g_receipt_detail_index).ship_to_location_id := p_location_id; -- for tolerance checks in matching.
    g_rcpt_match_table_gross(g_receipt_detail_index).tax_amount := 0; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).error_status := 'S'; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).to_organization_id := p_organization_id;
    -- bug 2797704
    g_rcpt_match_table_gross(g_receipt_detail_index).project_id := p_project_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).task_id := p_task_id;
    l_progress := '60';

    IF p_item_id IS NOT NULL THEN
      BEGIN
        SELECT primary_unit_of_measure
          INTO g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure
          FROM mtl_system_items
         WHERE mtl_system_items.inventory_item_id = p_item_id
           AND mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('Primary_uom is null should not be null', 4);
          END IF;

          l_progress := '65';
          RAISE fnd_api.g_exc_error;
      END;
    ELSE
      g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure := NULL;
      --OPM Convergence..should this be unit_of_measure????
     -- g_rcpt_match_table_gross(g_receipt_detail_index).secondary_uom := NULL;
    END IF;

    l_progress := '70';

    IF (l_debug = 1) THEN
      print_debug('create_po_rcpt_intf_rec: 35 - p_inspect = '||p_inspect, 4);
    END IF;

    -- BUG 3325627: Pass inspection status to matching logic
    IF p_inspect IS NOT NULL AND p_inspect = 1 THEN
       g_rcpt_match_table_gross(g_receipt_detail_index).inspection_status_code := 'Y';
     ELSE
       g_rcpt_match_table_gross(g_receipt_detail_index).inspection_status_code := 'N';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('create_po_rcpt_intf_rec: 40 - before matching  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    inv_rcv_txn_interface.matching_logic(
      x_return_status          => l_return_status
    , --?
      x_msg_count              => l_msg_count
    , x_msg_data               => l_msg_data
    , x_cascaded_table         => g_rcpt_match_table_gross
    , n                        => g_receipt_detail_index
    , temp_cascaded_table      => l_rcpt_match_table_detail
    , p_receipt_num            => NULL
    , p_shipment_header_id     => NULL
    , p_lpn_id                 => NULL
    );

    IF (l_debug = 1) THEN
      print_debug('create_po_rcpt_intf_rec: 50 - after matching  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('create_po_rcpt_intf_rec: 50.1 - after matching  l_return_status = ' || l_return_status, 4);
      print_debug('create_po_rcpt_intf_rec: 50.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_po_rcpt_intf_rec: 50.3 - after matching  l_msg_data = ' || l_msg_data, 4);
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_po_rcpt_intf_rec 60.2: Unexpect error calling matching'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF g_rcpt_match_table_gross(g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := g_rcpt_match_table_gross(g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_receipt_detail_index ..(g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'create_po_rcpt_intf_rec 80: adding tolerance message - l_msg_prod = '
          || l_msg_prod
          || ' l_err_message = '
          || l_err_message
          || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1
        );
      END IF;
    END IF;

    -- load the matching algorithm result into input data structure

    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI


    IF (l_debug = 1) THEN
      print_debug('create_po_rcpt_intf_rec: 90 - before macthing result loop  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := 72;

      IF (l_debug = 1) THEN
        print_debug(
             'create_po_rcpt_intf_rec: 90.1 - after matching  po_line_location_id = '
          || l_rcpt_match_table_detail(match_result_count).po_line_location_id
        , 4
        );
        print_debug(
          'create_po_rcpt_intf_rec: 90.2 - after matching  txn_quantity = '
          || l_rcpt_match_table_detail(match_result_count).quantity
        , 4
        );

      END IF;

      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).po_line_location_id);
      l_progress := 74;
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      -- Earlier item_id was filled with PO Line Item ID if the parameter p_inv_item_id
      -- is not null, so that matching logic finds shipments. Now, in order to actually
      -- insert RTI, replace item_id with a new value which is nothing but the substitute
      -- item.
      l_rcv_rcpt_rec.item_id := p_item_id;
      l_progress := 76;
      CLOSE l_curs_rcpt_detail;
      l_progress := 78;
      --Bug 6978466 Substitute Value should be there when we are doing substitute receipts through mobile.
      IF p_inv_item_id IS NOT NULL THEN
         l_rcv_transaction_rec.substitute_receipt:='SUBSTITUTE';
      END IF;
      --End of 6978466

      l_rcv_transaction_rec.po_line_location_id := l_rcpt_match_table_detail(match_result_count).po_line_location_id;
      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      --OPM Convergence
      --l_rcv_transaction_rec.secondary_quantity := l_rcpt_match_table_detail(match_result_count).secondary_quantity;
       l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) * p_secondary_quantity;
       l_rcv_transaction_rec.secondary_uom := p_secondary_uom; --OPM Convergence
       l_rcv_transaction_rec.secondary_uom_code := p_secondary_uom_code; --OPM Convergence
    print_debug(l_rcv_transaction_rec.secondary_quantity,1);
    print_debug( l_rcv_transaction_rec.secondary_uom,1);
    print_debug(l_rcv_transaction_rec.secondary_uom_code,1);

    l_rcv_transaction_rec.destination_subinventory := p_rcv_subinventory_code;
    l_rcv_transaction_rec.locator_id := p_rcv_locator_id;


    l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      l_rcv_transaction_rec.item_revision := p_revision;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.ordered_qty;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_rcpt_rec.secondary_uom_code := p_secondary_uom_code;--OPM Convergence
      print_debug('l_rcv_rcpt_rec.secondary_uom_code ' || l_rcv_rcpt_rec.secondary_uom_code,4);
      print_debug('l_rcv_rcpt_rec.secondary_uom ' || l_rcv_rcpt_rec.secondary_uom,4);

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec: 100 - within cursor loop - before insert RTI  '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      --Begin bug 4699085
      --If the item is not revision controlled ie l_rcv_rcpt_rec.item_rev_control_flag_to = 'N'
      --and l_rcv_transaction_rec.item_revision is null, ie p_revision is passed NULL to this
      --API, then check if there is a item revision stamped on the po lines table and use that
      --revision to pass to QA skip lot API and to the interface record created in RTI to
      --process the PO receipt.
      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec: 100.1 l_rcv_rcpt_rec.item_rev_control_flag_to='||l_rcv_rcpt_rec.item_rev_control_flag_to, 4);
        print_debug('create_po_rcpt_intf_rec: 100.2 l_rcv_transaction_rec.item_revision='||l_rcv_transaction_rec.item_revision, 4);
      END IF;

      IF ((l_rcv_rcpt_rec.item_rev_control_flag_to = 'N') AND
          (l_rcv_transaction_rec.item_revision IS NULL)) THEN

        BEGIN
          SELECT nvl(item_revision, '@@@@')
          INTO l_item_revision
          FROM po_lines_all
          WHERE po_line_id = l_rcv_rcpt_rec.po_line_id;

          IF (l_debug = 1) THEN
                  print_debug('create_po_rcpt_intf_rec: 100.5 l_item_revision='||l_item_revision, 4);
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_item_revision := '@@@@';
          WHEN OTHERS THEN
            l_item_revision := '@@@@';
        END;

        IF (l_debug = 1) THEN
          print_debug('create_po_rcpt_intf_rec: 100.6 l_item_revision='||l_item_revision, 4);
        END IF;

        IF (l_item_revision <> '@@@@') THEN
          l_rcv_transaction_rec.item_revision := l_item_revision;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_po_rcpt_intf_rec: 100.7 l_rcv_transaction_rec.item_revision='||l_rcv_transaction_rec.item_revision, 4);
        END IF;
      END IF;
      --End bug 4699085

      l_progress := '80';

      -- check if the routing_id = 2 (Inspection required) then call
      -- QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY
      -- to check if Quaility Skip Lot function is available for current org.
      -- returns fnd_api.g_true/false
      IF l_rcv_rcpt_rec.routing_id = 2 THEN
        BEGIN
          l_progress := '81';
          qa_skiplot_rcv_grp.check_availability(
            p_api_version          => 1.0
          , p_init_msg_list        => fnd_api.g_false
          , p_commit               => fnd_api.g_false
          , p_validation_level     => fnd_api.g_valid_level_full
          , p_organization_id      => p_organization_id
          , x_qa_availability      => l_qa_availability
          , x_return_status        => l_return_status
          , x_msg_count            => l_msg_count
          , x_msg_data             => l_msg_data
          );
          l_progress := '82';
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              print_debug(
                   'create_po_rcpt_intf_rec: 102 - Exception in calling QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4
              );
            END IF;

            RAISE fnd_api.g_exc_error;
        END;

        IF NVL(l_return_status, fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_success THEN
          -- If the Quaility Skip Lot function is available, then gets the interface transaction id and
          -- calls QA_SKIPLOT_RCV_GRP.EVALUATE_LOT
          -- returns 'Standard' or 'Inspect' to x_evaluation_result.
          IF NVL(l_qa_availability, fnd_api.g_false) = fnd_api.g_true THEN
            l_qa_routing_id := 2;

            BEGIN
              SELECT rcv_transactions_interface_s.NEXTVAL
                INTO l_rcv_transaction_rec.interface_transaction_id
                FROM DUAL;

              l_progress := '83';
              /*
                 We get the project /task from create_std..rec itself and it in turns
                 gets it from java code (rcptflistener)
                      get_project_task(p_po_line_location_id   =>  l_rcv_transaction_rec.po_line_location_id,
                             p_oe_order_line_id      =>  NULL,
                             x_project_id            =>  l_project_id,
                             x_task_id               =>  l_task_id);
              */
              l_project_id := p_project_id;
              l_task_id := p_task_id;

              IF l_project_id = '' THEN
                l_project_id := NULL;
              END IF;

              IF l_task_id = '' THEN
                l_task_id := NULL;
              END IF;

              --Begin bug 4699085
              --Added following debug messages
              IF (l_debug = 1) THEN
              	print_debug('create_po_rcpt_intf_rec 84 calling qa_skiplot_rcv_grp.evaluate_lot', 4);
              	print_debug('create_po_rcpt_intf_rec 84 with l_rcv_rcpt_rec.item_revision='||l_rcv_rcpt_rec.item_revision, 4);
              END IF;
              --End bug 4699085

              l_progress := '84';
              qa_skiplot_rcv_grp.evaluate_lot(
                p_api_version             => 1.0
              , p_init_msg_list           => fnd_api.g_false
              , p_commit                  => fnd_api.g_false
              , p_validation_level        => fnd_api.g_valid_level_full
              , p_interface_txn_id        => l_rcv_transaction_rec.interface_transaction_id
              , p_organization_id         => p_organization_id
              , p_vendor_id               => l_rcv_rcpt_rec.vendor_id
              , p_vendor_site_id          => l_rcv_rcpt_rec.vendor_site_id
              , p_item_id                 => l_rcv_rcpt_rec.item_id
              , p_item_revision           => l_rcv_rcpt_rec.item_revision
              , p_item_category_id        => l_rcv_rcpt_rec.item_category_id
              , p_project_id              => l_project_id
              , p_task_id                 => l_task_id
              , p_manufacturer_id         => NULL
              , p_source_inspected        => NULL
              , p_receipt_qty             => l_rcv_transaction_rec.transaction_qty
              , p_receipt_date            => SYSDATE
              , p_primary_uom             => l_rcv_transaction_rec.primary_uom
              , p_transaction_uom         => l_rcv_transaction_rec.transaction_uom
              , p_po_header_id            => l_rcv_rcpt_rec.po_header_id
              , p_po_line_id              => l_rcv_rcpt_rec.po_line_id
              , p_po_line_location_id     => l_rcv_transaction_rec.po_line_location_id
              , p_po_distribution_id      => l_rcv_rcpt_rec.po_distribution_id
              , p_lpn_id                  => p_lpn_id
              , p_wms_flag                => 'Y'
              , x_evaluation_result       => l_evaluation_result
              , x_return_status           => l_return_status
              , x_msg_count               => l_msg_count
              , x_msg_data                => l_msg_data
              );

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                  print_debug('create_po_rcpt_intf_rec 84.1: QA CALL RAISE  FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                END IF;

                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  print_debug('create_po_rcpt_intf_rec 135.2: QA CALL RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              -- If QA_SKIPLOT_RCV_GRP returns 'Standard', sets the routing id to 1.
              -- If QA_SKIPLOT_RCV_GRP returns 'Inspect', leaves the routing id as 2.
              IF l_evaluation_result = 'STANDARD' THEN
                l_rcv_rcpt_rec.routing_id := 1;
                l_qa_routing_id := 1;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  print_debug('create_po_rcpt_intf_rec: 104 - Exception in calling QA_SKIPLOT_RCV_GRP.EVALUATE_LOT'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                END IF;
                RAISE fnd_api.g_exc_error;
            END;
          END IF;
        END IF;
      END IF;

      l_return_status := fnd_api.g_ret_sts_success;
      l_progress := '85';

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      l_interface_transaction_id :=
        insert_txn_interface(
          l_rcv_transaction_rec
        , l_rcv_rcpt_rec
        , l_group_id
        , l_transaction_type
        , p_organization_id
        , p_location_id
        , p_source_type
        , l_qa_routing_id
        , p_project_id
        , p_task_id
        );
      l_progress := '90';

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec: 110 - within cursor loop - after insert RTI '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('create_po_rcpt_intf_rec 130.5: INV J and PO J are installed. No Move Order creation from UI', 4);
      END IF;
      /* Populate the table to store the information of the RTIs created*/
      l_new_rti_info(match_result_count).orig_interface_trx_id := p_original_rti_id;
      l_new_rti_info(match_result_count).new_interface_trx_id := l_interface_transaction_id;
      l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
    END LOOP;   -- loop through results returned by matching algorithm

    --BUG 3326408,3346758,3405320
    --If there are any serials confirmed from the UI for an item that is
    --lot controlled and serial control dynamic at SO issue,
    --do not NULL out serial_transaction_temp_id. In other cases,
    --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
    IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
	l_rcv_rcpt_rec.serial_number_control_code IN (1,6)) THEN
       IF (l_debug = 1) THEN
          print_debug('create_po_rcpt_intf_rec 130.6: serial_control_code IS 6, need TO NULL OUT mtli', 4);
       END IF;
       BEGIN
          UPDATE mtl_transaction_lots_interface
	    SET  serial_transaction_temp_id = NULL
	    WHERE product_transaction_id = p_original_rti_id
	    AND   product_code = 'RCV';
       EXCEPTION
          WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('create_po_rcpt_intf_rec 130.7: Error nulling serial temp id OF MTLI', 4);
	     END IF;
       END ;
    END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

    l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
    IF ( NOT l_split_lot_serial_ok) THEN
	 IF (l_debug = 1) THEN
	    print_debug('create_po_rcpt_intf_rec 132: Failure in split_lot_serial', 4);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('create_po_rcpt_intf_rec 133: Call split_lot_serial is OK', 4);
    END IF;

    IF l_curs_rcpt_detail%ISOPEN THEN
      CLOSE l_curs_rcpt_detail;
    END IF;

    -- append index in input table where the line to be detailed needs to be inserted
    --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

    -- clear the lot/qty data structure
    g_rcpt_lot_qty_rec_tb.DELETE;
    l_progress := '90';

    IF p_item_id IS NOT NULL THEN
      inv_rcv_common_apis.do_check(
        p_organization_id         => p_organization_id
      , p_inventory_item_id       => p_item_id
      , p_transaction_type_id     => 18
      , p_primary_quantity        => l_total_primary_qty
      , x_return_status           => l_return_status
      , x_msg_count               => l_msg_count
      , x_msg_data                => x_message
      );
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';

    IF (l_debug = 1) THEN
      print_debug('About exiting create_po_rcpt_intf_rec: 140 - after cursor loop  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_po_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_rcpt_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_po_rcpt_intf_rec;

  -- Added one more parameter p_from_lpn_id
  PROCEDURE create_intship_rcpt_intf_rec(
    p_move_order_header_id   IN OUT NOCOPY  NUMBER
  , p_organization_id        IN             NUMBER
  , p_shipment_header_id     IN             NUMBER
  , p_req_header_id          IN             NUMBER
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
  , p_project_id             IN             NUMBER    DEFAULT NULL
  , p_task_id                IN             NUMBER    DEFAULT NULL
  , p_country_code           IN             VARCHAR2  DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2  DEFAULT NULL -- RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER    DEFAULT NULL
  , p_original_rti_id        IN             NUMBER    DEFAULT NULL  --Lot/Serial Support
   , p_secondary_uom          IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_uom_code     IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_quantity          IN             NUMBER    DEFAULT NULL --OPM Convergence
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  ) IS
    l_rcpt_match_table_detail  inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec      rcv_transaction_rec_tp; -- rcv_transaction block
    l_interface_transaction_id NUMBER       := NULL;
    -- this is used to keep track of the id used to insert the row in rti

    l_transaction_type         VARCHAR2(20) := 'RECEIVE';
    l_total_primary_qty        NUMBER       := 0;
    l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_progress                 VARCHAR2(10);
    l_err_message              VARCHAR2(100);
    l_temp_message             VARCHAR2(100);
    l_msg_prod                 VARCHAR2(5);
    l_group_id                 NUMBER;
    l_rcv_rcpt_rec             rcv_enter_receipts_rec_tp;
    l_inspect                  NUMBER;
    l_receipt_num              VARCHAR2(30);
    l_serial_number            VARCHAR2(80); --9651496,9764650
	l_lot_number               VARCHAR2(80) ; --9229228

    CURSOR l_curs_rcpt_detail(v_shipment_line_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'INTERNAL' source_type_code
           , DECODE(rsl.source_document_code, 'INVENTORY', 'INVENTORY', 'REQ', 'INTERNAL ORDER') receipt_source_code
           , rsl.source_document_code order_type_code
           , '' order_type
           --Passing as NULL for the columns for which value is not known.  --Bug #3878174
           , TO_NUMBER(NULL) po_header_id
           , NULL po_number
           , TO_NUMBER(NULL) po_line_id
           , TO_NUMBER(NULL) po_line_number
           , TO_NUMBER(NULL) po_line_location_id
           , NULL po_shipment_number
           , TO_NUMBER(NULL) po_release_id
           , TO_NUMBER(NULL) po_release_number
/*
           , rsh.shipment_header_id po_header_id
           , rsh.shipment_num po_number
           , rsl.shipment_line_id po_line_id
           , rsl.line_num po_line_number
           , rsl.shipment_line_id po_line_location_id
           , rsl.line_num po_shipment_number
           , rsh.shipment_header_id po_release_id
           , rsh.shipment_header_id po_release_number
*/
           , porh.requisition_header_id req_header_id
           , porh.segment1 req_number
           , porl.requisition_line_id req_line_id
           , porl.line_num req_line
           , rsl.req_distribution_id req_distribution_id
           , rsl.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id
           , rsl.to_organization_id to_organization_id
           , rsl.shipment_line_id vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , 'N' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , DECODE(msi1.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsh.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsh.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , porl.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , rsl.quantity_shipped ordered_qty
           , rsl.primary_unit_of_measure ordered_uom
           , rsh.ussgl_transaction_code ussgl_transaction_code
           , rsh.government_context government_context
           , NULL inspection_required_flag
           , NULL receipt_required_flag
           , NULL enforce_ship_to_location_code
           , TO_NUMBER(NULL) unit_price
           , NULL currency_code
           , NULL currency_conversion_type
           , TO_DATE(NULL) currency_conversion_date
           , TO_NUMBER(NULL) currency_conversion_rate
           , NULL note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
             rsl.destination_type_code destination_type_code
           , rsl.deliver_to_person_id deliver_to_person_id
           , rsl.deliver_to_location_id deliver_to_location_id
           , rsl.to_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , 'OPEN' closed_code
           , NULL asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , NULL rate_type_display
           , 'P' match_option
           , NULL country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence temp
        FROM rcv_shipment_headers rsh
           , rcv_shipment_lines rsl
           , po_requisition_headers porh
           , po_requisition_lines porl
           , mtl_system_items msi
           , mtl_system_items msi1
           , mtl_units_of_measure mum
       WHERE rsh.receipt_source_code <> 'VENDOR'
         AND rsl.requisition_line_id = porl.requisition_line_id(+)
         AND porl.requisition_header_id = porh.requisition_header_id(+)
         AND rsh.shipment_header_id = rsl.shipment_header_id
         AND mum.unit_of_measure(+) = rsl.unit_of_measure
         AND msi.organization_id(+) = rsl.to_organization_id
         AND msi.inventory_item_id(+) = rsl.item_id
         AND msi1.organization_id(+) = rsl.from_organization_id
         AND msi1.inventory_item_id(+) = rsl.item_id
         AND rsl.shipment_line_id = v_shipment_line_id
         AND(
             (
              rsl.source_document_code = 'REQ'
              AND EXISTS(
                   SELECT '1'
                     FROM po_req_distributions_all prd
                    WHERE prd.requisition_line_id = rsl.requisition_line_id
                      AND Nvl(rsl.req_distribution_id,Nvl(prd.distribution_id,-999)) = Nvl(prd.distribution_id,-999)--BUG 4946182
                      AND(
                          p_project_id IS NULL
                          OR(p_project_id = -9999
                             AND prd.project_id IS NULL) --bug#2669021
                          OR NVL(prd.project_id, -99) = p_project_id
                         ))
             )
             OR rsl.source_document_code <> 'REQ'
            );

    l_debug                    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok      BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count               NUMBER := 0;
    l_line_id                  NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_intship_rcpt_intf_rec: 10   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SAVEPOINT crt_intship_rti_sp;
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      /* Bug #2516729
       * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
       * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
       * in order that a new receipt # is not created everytime and the existing receipt # is used
       */
      BEGIN
        SELECT receipt_num
          INTO l_receipt_num
          FROM rcv_shipment_headers
         WHERE shipment_header_id = p_shipment_header_id
           AND ship_to_org_id = p_organization_id;

	--Bug 4252372
  	--We should set inv_rcv_common_apis.g_rcv_global_var.receipt_num to
	--l_receipt_num only if l_receipt_num is not null. It it is null and
	--we set the value then we will end up generating extra receipt numbers.
	IF (l_receipt_num IS NOT NULL) THEN
	   inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
	END IF;

        IF (l_debug = 1) THEN
          print_debug('create_intship_rcpt_intf_rec: 10.1 ' || inv_rcv_common_apis.g_rcv_global_var.receipt_num, 1);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_receipt_num := NULL;
      END;

      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    -- default header level non-DB items in rcv_transaction block
    -- and default other values need to be insert into RTI

    IF (l_debug = 1) THEN
      print_debug('create_intship_rcpt_intf_rec: 20   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
        INTO l_group_id
        FROM DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    /* We'll get shipment_header_id for req at front end
       IF p_shipment_header_id IS NULL THEN
          SELECT DISTINCT rsl.shipment_header_id
       INTO l_shipment_header_id
       FROM rcv_shipment_lines rsl,
       po_requisition_lines prl
       WHERE
       prl.requisition_header_id = p_req_header_id
       AND prl.requisition_line_id = rsl.requisition_line_id;
        ELSE
          l_shipment_header_id := p_shipment_header_id;
       END IF;

      */
       --9651496,9764650-starts
     BEGIN
        SELECT  fm_serial_number INTO l_serial_number
        FROM mtl_serial_numbers_interface
        WHERE  product_transaction_id = p_original_rti_id ;
     EXCEPTION
     WHEN No_Data_Found THEN
         IF (l_debug = 1) THEN
            print_debug('create_intship_rcpt_intf_rec: No Serial records in MSNI for id :'||p_original_rti_id,4);
         END IF;
         l_serial_number :=NULL;
     WHEN too_many_rows THEN
          IF (l_debug = 1) THEN
            print_debug('create_intship_rcpt_intf_rec: More than one records in MSNI for id :'||p_original_rti_id,4);
         END IF;
         l_serial_number :=NULL; --For multiple lots dont input to matching logic
    END;
    IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec: 30.2 serial_number: ' || l_serial_number, 4);
    END IF;
    --9651496,9764650-ends


		  --9229228-starts
 	      BEGIN
 	         SELECT  lot_number INTO l_lot_number
 	         FROM mtl_transaction_lots_interface
 	         WHERE  product_transaction_id = p_original_rti_id ;
 	      EXCEPTION
 	      WHEN No_Data_Found THEN
 	          IF (l_debug = 1) THEN
 	             print_debug('create_intship_rcpt_intf_rec: No Lot records in MTLI for id :'||p_original_rti_id,4);
 	          END IF;
 	          l_lot_number :=NULL;
 	      WHEN too_many_rows THEN
 	           IF (l_debug = 1) THEN
 	             print_debug('create_intship_rcpt_intf_rec: More than one records in MTLI for id :'||p_original_rti_id,4);
 	          END IF;
 	          l_lot_number :=NULL; --For multiple lots dont input to matching logic
 	     END;
 	     IF (l_debug = 1) THEN
 	         print_debug('create_intship_rcpt_intf_rec: 30.2 lot_number: ' || l_lot_number, 4);
 	     END IF;
 	     --9229228-ends

    l_progress := '40';
    -- call matching algorithm   ?

    -- initialize input record for matching algorithm
    g_rcpt_match_table_gross(g_receipt_detail_index).GROUP_ID := l_group_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).transaction_type := 'RECEIVE';
    g_rcpt_match_table_gross(g_receipt_detail_index).quantity := p_rcv_qty;
    g_rcpt_match_table_gross(g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    g_rcpt_match_table_gross(g_receipt_detail_index).item_id := p_item_id;
    --Need to use revision also in matching if entered by user.bug 3368197
    g_rcpt_match_table_gross(g_receipt_detail_index).revision := p_revision;
    g_rcpt_match_table_gross(g_receipt_detail_index).shipment_header_id := p_shipment_header_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcpt_match_table_gross(g_receipt_detail_index).ship_to_location_id := p_location_id; -- for tolerance checks in matching.
    g_rcpt_match_table_gross(g_receipt_detail_index).tax_amount := 0; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).error_status := 'S'; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).to_organization_id := p_organization_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).project_id := p_project_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).task_id := p_task_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).lot_number := l_lot_number;
    g_rcpt_match_table_gross(g_receipt_detail_index).serial_number := l_serial_number; --9651496,9764650
    l_progress := '60';

    SELECT primary_unit_of_measure
      INTO g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure
      FROM mtl_system_items
     WHERE mtl_system_items.inventory_item_id = p_item_id
       AND mtl_system_items.organization_id = p_organization_id;

    l_progress := '70';

    IF (l_debug = 1) THEN
      print_debug('create_intship_rcpt_intf_rec: 30 before matching   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => l_return_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , x_cascaded_table        => g_rcpt_match_table_gross
    , n                       => g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => 'INTRANSIT SHIPMENT'
    , p_lpn_id                => p_from_lpn_id
    );

    IF (l_debug = 1) THEN
      print_debug('create_intship_rcpt_intf_rec: 40 after matching   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('create_intship_rcpt_intf_rec: 40.1 - after matching  l_return_status = ' || l_return_status, 4);
      print_debug('create_intship_rcpt_intf_rec: 40.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_intship_rcpt_intf_rec: 40.3 - after matching  l_msg_data = ' || l_msg_data, 4);
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF g_rcpt_match_table_gross(g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := g_rcpt_match_table_gross(g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_receipt_detail_index ..(g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- load the matching algorithm result into input data structure



    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI



    --loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '72';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).shipment_line_id);
      l_progress := '74';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '76';
      CLOSE l_curs_rcpt_detail;
      l_progress := '78';
      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;
      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

      l_rcv_transaction_rec.destination_subinventory := p_rcv_subinventory_code;
      l_rcv_transaction_rec.locator_id := p_rcv_locator_id;

      l_rcv_transaction_rec.lpn_id := p_from_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;


      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.ordered_qty;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;

      --bug 3368197. Need to pass revision to insert_txn_interface
      l_rcv_transaction_rec.item_revision := p_revision;

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec: 90 before insert_txn_interface ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '80';

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      l_interface_transaction_id := insert_txn_interface(
            l_rcv_transaction_rec
          , l_rcv_rcpt_rec
          , l_group_id
          , l_transaction_type
          , p_organization_id
          , p_location_id
          , p_source_type
          , NULL  --p_qa_routing_id
          , p_project_id
          , p_task_id);
      l_progress := '90';

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec: 100 after insert_txn_interface ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('create_intship_rcpt_intf_rec 135.5: INV J and PO J are installed. No Move Order creation from UI', 4);
      END IF;
      /* Populate the table to store the information of the RTIs created*/
      l_new_rti_info(match_result_count).orig_interface_trx_id := p_original_rti_id;
      l_new_rti_info(match_result_count).new_interface_trx_id := l_interface_transaction_id;
      l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
    END LOOP;  --END LOOP through results returned by matching algorithm

    l_progress := '100';

    --BUG 3326408,3346758,3405320
    --If there are any serials confirmed from the UI for an item that is
    --lot controlled and serial control dynamic at SO issue,
    --do not NULL out serial_transaction_temp_id. In other cases,
    --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
    l_msni_count := 0;
    IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
	l_rcv_rcpt_rec.serial_number_control_code IN (1,6)) THEN
       IF (l_debug = 1) THEN
          print_debug('create_intship_rcpt_intf_rec 135.6: serial_control_code IS 6, need TO NULL OUT mtli', 4);
       END IF;

       BEGIN
	  IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN
	     SELECT count(1)
	       INTO   l_msni_count
	       FROM   mtl_serial_numbers_interface
	       WHERE  product_transaction_id = p_original_rti_id
	       AND    product_code = 'RCV';
          END IF;

          IF l_msni_count = 0 THEN
	     UPDATE mtl_transaction_lots_interface
	       SET  serial_transaction_temp_id = NULL
	       WHERE product_transaction_id = p_original_rti_id
	       AND   product_code = 'RCV';
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('create_intship_rcpt_intf_rec 135.7: Error nulling serial temp id OF MTLI', 4);
	     END IF;
       END ;
    END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

    l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
    IF ( NOT l_split_lot_serial_ok) THEN
       IF (l_debug = 1) THEN
          print_debug('create_intship_rcpt_intf_rec 100.1: Failure in split_lot_serial', 4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('create_intship_rcpt_intf_rec 100.2: Call split_lot_serial is OK', 4);
    END IF;

    l_progress := '110';

    IF l_curs_rcpt_detail%ISOPEN THEN
      CLOSE l_curs_rcpt_detail;
    END IF;

    -- append index in input table where the line to be detailed needs to be inserted
    --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

    -- clear the lot/qty data structure
    g_rcpt_lot_qty_rec_tb.DELETE;
    l_progress := '120';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 61
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '130';

    IF (l_debug = 1) THEN
      print_debug('About exiting create_intship_rcpt_intf_rec: 140 - after cursor loop  '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_intship_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_intship_rcpt_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_intship_rcpt_intf_rec;

  PROCEDURE create_rma_rcpt_intf_rec(
    p_move_order_header_id   IN OUT NOCOPY  NUMBER
  , p_organization_id        IN             NUMBER
  , p_oe_order_header_id     IN             NUMBER
  , p_item_id                IN             NUMBER
  , p_location_id            IN             NUMBER
  , p_rcv_qty                IN             NUMBER
  , p_rcv_uom                IN             VARCHAR2
  , p_rcv_uom_code           IN             VARCHAR2
  , p_source_type            IN             VARCHAR2
  , p_lpn_id                 IN             NUMBER
  , p_lot_control_code       IN             NUMBER
  , p_revision               IN             VARCHAR2
  , p_inspect                IN             NUMBER
  , x_status                 OUT NOCOPY     VARCHAR2
  , x_message                OUT NOCOPY     VARCHAR2
  , p_project_id             IN             NUMBER    DEFAULT NULL
  , p_task_id                IN             NUMBER    DEFAULT NULL
  , p_country_code           IN             VARCHAR2  DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2  DEFAULT NULL -- RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER    DEFAULT NULL
  , p_original_rti_id        IN             NUMBER    DEFAULT NULL  --Lot/Serial Support
  , p_secondary_uom          IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_uom_code     IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_quantity          IN             NUMBER    DEFAULT NULL --OPM Convergence
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  ) IS
    l_rcpt_match_table_detail  inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec      rcv_transaction_rec_tp; -- rcv_transaction block
    l_interface_transaction_id NUMBER       := NULL;
    -- this is used to keep track of the id used to insert the row in rti

    l_transaction_type         VARCHAR2(20) := 'RECEIVE';
    l_total_primary_qty        NUMBER       := 0;
    l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_progress                 VARCHAR2(10);
    l_err_message              VARCHAR2(100);
    l_temp_message             VARCHAR2(100);
    l_msg_prod                 VARCHAR2(5);
    l_group_id                 NUMBER;
    l_rcv_rcpt_rec             rcv_enter_receipts_rec_tp;
    l_inspect                  NUMBER;
    l_default_routing_id       NUMBER;

    CURSOR l_curs_rcpt_detail(v_oe_order_line_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'CUSTOMER' source_type_code
           , 'CUSTOMER' receipt_source_code
           , '' order_type_code
           , '' order_type
           , TO_NUMBER(NULL) po_header_id
           , NULL po_number
           , TO_NUMBER(NULL) po_line_id
           , TO_NUMBER(NULL) po_line_number
           , TO_NUMBER(NULL) po_line_location_id
           , TO_NUMBER(NULL) po_shipment_number
           , TO_NUMBER(NULL) po_release_id
           , TO_NUMBER(NULL) po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           , TO_NUMBER(NULL) rcv_shipment_header_id
           , NULL rcv_shipment_number
           , TO_NUMBER(NULL) rcv_shipment_line_id
           , TO_NUMBER(NULL) rcv_line_number
           , NVL(oel.ship_to_org_id, oeh.ship_to_org_id) from_organization_id
           , NVL(oel.ship_from_org_id, oeh.ship_from_org_id) to_organization_id
           , TO_NUMBER(NULL) vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , NULL outside_operation_flag
           , oel.inventory_item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , mum.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , msi.segment1 item_number
           , oel.item_revision item_revision
           , msi.description item_description
           , TO_NUMBER(NULL) item_category_id
           , NULL hazard_class
           , NULL un_number
           , NULL vendor_item_number
           , oel.ship_from_org_id ship_to_location_id
           , '' ship_to_location
           , NULL packing_slip
           , TO_NUMBER(NULL) routing_id
           , NULL routing_name
           , oel.request_date need_by_date
           , NVL(oel.promise_date, oel.request_date) expected_receipt_date
           , oel.ordered_quantity ordered_qty
           , '' ordered_uom
           , NULL ussgl_transaction_code
           , NULL government_context
           , DECODE(msi.return_inspection_requirement, 1, 'Y', 'N') inspection_required_flag
           , 'Y' receipt_required_flag
           , 'N' enforce_ship_to_location_code
           , oel.unit_selling_price unit_price
           , oeh.transactional_curr_code currency_code
           , oeh.conversion_type_code currency_conversion_type
           , oeh.conversion_rate_date currency_conversion_date
           , oeh.conversion_rate currency_conversion_rate
           , NULL note_to_receiver
           , NULL destination_type_code
           , oel.deliver_to_contact_id deliver_to_person_id
           , oel.deliver_to_org_id deliver_to_location_id
           , NULL destination_subinventory
           , oel.CONTEXT attribute_category
           , oel.attribute1 attribute1
           , oel.attribute2 attribute2
           , oel.attribute3 attribute3
           , oel.attribute4 attribute4
           , oel.attribute5 attribute5
           , oel.attribute6 attribute6
           , oel.attribute7 attribute7
           , oel.attribute8 attribute8
           , oel.attribute9 attribute9
           , oel.attribute10 attribute10
           , oel.attribute11 attribute11
           , oel.attribute12 attribute12
           , oel.attribute13 attribute13
           , oel.attribute14 attribute14
           , oel.attribute15 attribute15
           , NULL closed_code
           , NULL asn_type
           , NULL bill_of_lading
           , TO_DATE(NULL) shipped_date
           , NULL freight_carrier_code
           , NULL waybill_airbill_num
           , NULL freight_bill_num
           , NULL vendor_lot_num
           , NULL container_num
           , NULL truck_num
           , NULL bar_code_label
           , NULL rate_type_display
           , NULL match_option
           , NULL country_of_origin_code
           , oel.header_id oe_order_header_id
           , oeh.order_number oe_order_num
           , oel.line_id oe_order_line_id
           , oel.line_number oe_order_line_num
           , oel.sold_to_org_id customer_id
           , NVL(oel.ship_to_org_id, oeh.ship_to_org_id) customer_site_id
           , '' customer_item_num
           , '' pll_note_to_receiver
           , NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , project_id project_id
           , task_id task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
        FROM  oe_order_lines_all oel
            , oe_order_headers_all oeh
            , mtl_system_items msi
            , mtl_units_of_measure mum
       WHERE oel.line_category_code = 'RETURN'
         AND oel.header_id = oeh.header_id
         AND oel.inventory_item_id = msi.inventory_item_id
         AND oel.ship_from_org_id = msi.organization_id
         AND msi.primary_uom_code = mum.uom_code
         AND oel.booked_flag = 'Y'
         AND oel.ordered_quantity > NVL(oel.shipped_quantity, 0)
         AND msi.mtl_transactions_enabled_flag = 'Y'
         AND oel.line_id = v_oe_order_line_id
         AND(
             (p_project_id IS NULL
              OR(p_project_id = -9999
                 AND oel.project_id IS NULL) --bug#2669021
              OR oel.project_id = p_project_id)
             AND(p_task_id IS NULL
                 OR oel.task_id = p_task_id)
            );
    -- don't need from and to org for the query since both have 1-to-1 relationship to shipment header

    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok      BOOLEAN;   --Return status of lot_serial_split API
    l_line_id NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_rma_rcpt_intf_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    --   print_debug('project id ' || p_project_id);
    --   print_debug('task_id ' || p_task_id);
    SAVEPOINT crt_rma_rti_sp;
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      print_debug('create_rma_rcpt_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    -- default header level non-DB items in rcv_transaction block
    -- and default other values need to be insert into RTI

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
        INTO l_group_id
        FROM DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm   ?

    -- initialize input record for matching algorithm
    g_rcpt_match_table_gross(g_receipt_detail_index).GROUP_ID := l_group_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).transaction_type := 'RECEIVE';
    g_rcpt_match_table_gross(g_receipt_detail_index).quantity := p_rcv_qty;
    g_rcpt_match_table_gross(g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    g_rcpt_match_table_gross(g_receipt_detail_index).item_id := p_item_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).oe_order_header_id := p_oe_order_header_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcpt_match_table_gross(g_receipt_detail_index).ship_to_location_id := p_location_id; -- for tolerance checks in matching.
    g_rcpt_match_table_gross(g_receipt_detail_index).tax_amount := 0; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).error_status := 'S'; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).to_organization_id := p_organization_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).project_id := p_project_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).task_id := p_task_id;
    l_progress := '60';

    SELECT primary_unit_of_measure
      INTO g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure
      FROM mtl_system_items
     WHERE mtl_system_items.inventory_item_id = p_item_id
       AND mtl_system_items.organization_id = p_organization_id;

    l_progress := '70';

    IF (l_debug = 1) THEN
      print_debug('create_rma_rcpt_intf_rec: 30 before matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => l_return_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , x_cascaded_table        => g_rcpt_match_table_gross
    , n                       => g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => 'RMA'
    , p_lpn_id                => NULL
    );

    IF (l_debug = 1) THEN
      print_debug('create_rma_rcpt_intf_rec: 40 after matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('create_rma_rcpt_intf_rec: 40.1 - after matching  l_return_status = ' || l_return_status, 4);
      print_debug('create_rma_rcpt_intf_rec: 40.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_rma_rcpt_intf_rec: 40.3 - after matching  l_msg_data = ' || l_msg_data, 4);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF g_rcpt_match_table_gross(g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := g_rcpt_match_table_gross(g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_receipt_detail_index ..(g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- load the matching algorithm result into input data structure
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI
    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '72';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).oe_order_line_id);
      l_progress := '74';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '76';
      --     print_debug('receipt source code before passing ' || l_rcv_rcpt_rec.source_type_code,4);
      --     print_debug('OE project id = ' || l_rcv_rcpt_rec.project_id,4);
      --     print_debug('OE task id = ' || l_rcv_rcpt_rec.task_id,4);
      CLOSE l_curs_rcpt_detail;
      l_progress := '78';
      l_rcv_transaction_rec.oe_order_line_id := l_rcpt_match_table_detail(match_result_count).oe_order_line_id;
      -- update following fields from matching algorithm return value

      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      --BUG 3308727 issue 129
      l_rcv_transaction_rec.item_revision := p_revision;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

      l_rcv_transaction_rec.destination_subinventory := p_rcv_subinventory_code;
      l_rcv_transaction_rec.locator_id := p_rcv_locator_id;

      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.ordered_qty;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
       /* Bug 8270256: Assign secondary quantity and uoms */
 	       IF p_secondary_quantity IS NOT NULL THEN

                       IF (l_debug = 1) THEN
 	                   print_debug('In create_rma_std_dlvr_rti_rec 7.1: p_rcv_qty'|| p_rcv_qty, 1);
 	                   print_debug('In create_rma_std_dlvr_rti_rec 7.2: l_rcpt_match_table_detail(match_result_count).quantity'|| l_rcpt_match_table_detail(match_result_count).quantity, 1);
 	                   print_debug('In create_rma_std_dlvr_rti_rec 7.3: p_secondary_quantity'|| p_secondary_quantity, 1);
 	                   print_debug('In create_rma_std_dlvr_rti_rec 7.4: p_secondary_uom'|| p_secondary_uom, 1);
 	                   print_debug('In create_rma_std_dlvr_rti_rec 7.5: p_secondary_uom_code'|| p_secondary_uom_code, 1);
 	                END IF;


 	                l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) *  p_secondary_quantity;
 	                l_rcv_transaction_rec.secondary_uom := p_secondary_uom;
 	                l_rcv_transaction_rec.secondary_uom_code := p_secondary_uom_code;
 	       END IF;
	 /* End of bug 8270256 changes */

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec: 90 before insert_txn_interface' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '80';

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

l_interface_transaction_id := insert_txn_interface(
            l_rcv_transaction_rec
          , l_rcv_rcpt_rec
          , l_group_id
          , l_transaction_type
          , p_organization_id
          , p_location_id
          , p_source_type
                , NULL -- p_qa_routing_id
                , p_project_id
                , p_task_id);
      l_progress := '90';

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec: 100 after insert_txn_interface' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('create_rma_rcpt_intf_rec 135.5: INV J and PO J are installed. No Move Order creation from UI', 4);
      END IF;
      /* Populate the table to store the information of the RTIs created*/
      l_new_rti_info(match_result_count).orig_interface_trx_id := p_original_rti_id;
      l_new_rti_info(match_result_count).new_interface_trx_id := l_interface_transaction_id;
      l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
    END LOOP; --END LOOP through results returned by matching algorithm

    --Call the split_lot API to split the lots and serials inserted from the UI
    --based on the quantity of each RTI record
    l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
    IF ( NOT l_split_lot_serial_ok) THEN
       IF (l_debug = 1) THEN
          print_debug('create_rama_rcpt_intf_rec 110.1: Failure in split_lot_serial', 4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('create_rma_rcpt_intf_rec 110.2: Call split_lot_serial is OK', 4);
    END IF;

    IF l_curs_rcpt_detail%ISOPEN THEN
      CLOSE l_curs_rcpt_detail;
    END IF;

    -- append index in input table where the line to be detailed needs to be inserted
    --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

    -- clear the lot/qty data structure
    g_rcpt_lot_qty_rec_tb.DELETE;
    l_progress := '120';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 15
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '130';

    IF (l_debug = 1) THEN
      print_debug('About exit create_rma_rcpt_intf_rec: 140 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_rma_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_rma_rcpt_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_rma_rcpt_intf_rec;

  PROCEDURE create_asn_con_rcpt_intf_rec(
    p_move_order_header_id   IN OUT NOCOPY  NUMBER
  , p_organization_id        IN             NUMBER
  , p_shipment_header_id     IN             NUMBER
  , p_po_header_id           IN             NUMBER
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
  , p_item_desc              IN             VARCHAR2  DEFAULT NULL
  , p_project_id             IN             NUMBER    DEFAULT NULL
  , p_task_id                IN             NUMBER    DEFAULT NULL
  , p_country_code           IN             VARCHAR2  DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2  DEFAULT NULL -- RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER    DEFAULT NULL
  , p_original_rti_id        IN             NUMBER    DEFAULT NULL  --Lot/Serial Support
  , p_secondary_uom          IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_uom_code     IN             VARCHAR2  DEFAULT NULL-- OPM Convergence
  , p_secondary_quantity          IN             NUMBER    DEFAULT NULL --OPM Convergence
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  , p_express_transaction    IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_rcpt_match_table_detail  inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec      rcv_transaction_rec_tp; -- rcv_transaction block
    l_interface_transaction_id NUMBER       := NULL;
    -- this is used to keep track of the id used to insert the row in rti

    l_transaction_type         VARCHAR2(20) := 'RECEIVE';
    l_total_primary_qty        NUMBER       := 0;
    l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_progress                 VARCHAR2(10);
    l_err_message              VARCHAR2(100);
    l_temp_message             VARCHAR2(100);
    l_msg_prod                 VARCHAR2(5);
    l_group_id                 NUMBER;
    l_rcv_rcpt_rec             rcv_enter_receipts_rec_tp;
    l_inspect                  NUMBER;
    l_match_type               VARCHAR2(30);
    l_receipt_num              VARCHAR2(30);
    -- Added for bug# 6967549
    l_qa_availability          VARCHAR2(30) := fnd_api.g_false;
    l_evaluation_result        VARCHAR2(20);
    l_project_id               NUMBER       := p_project_id;
    l_task_id                  NUMBER       := p_task_id;
    l_lot_number               VARCHAR2(80) ; --12339922

    CURSOR l_curs_rcpt_detail(v_shipment_line_id NUMBER) IS
      SELECT 'N' line_chkbox
-- For Bug 7440217
           , p_source_type source_type_code
-- End for Bug 7440217
           , 'VENDOR' receipt_source_code
           , 'PO' order_type_code
           , '' order_type
           , poll.po_header_id po_header_id
           , poh.segment1 po_number
           , poll.po_line_id po_line_id
           , pol.line_num po_line_number
           , poll.line_location_id po_line_location_id
           , poll.shipment_num po_shipment_number
           , poll.po_release_id po_release_id
           , por.release_num po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           , rsh.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id  --Bug #3878174
/*
           , NVL(rsl.from_organization_id, poh.po_header_id) from_organization_id
*/
           , rsl.to_organization_id to_organization_id
           , rsh.vendor_id vendor_id
           , '' SOURCE
           , poh.vendor_site_id vendor_site_id -- Bug 6403165
           , '' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsl.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsl.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , poll.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , poll.quantity ordered_qty
           , pol.unit_meas_lookup_code ordered_uom
           , rsl.ussgl_transaction_code ussgl_transaction_code
           , rsl.government_context government_context
           , poll.inspection_required_flag inspection_required_flag
           , poll.receipt_required_flag receipt_required_flag
           , poll.enforce_ship_to_location_code enforce_ship_to_location_code
           , NVL(poll.price_override, pol.unit_price) unit_price
           , poh.currency_code currency_code
           , poh.rate_type currency_conversion_type
           , poh.rate_date currency_conversion_date
           , poh.rate currency_conversion_rate
           , poh.note_to_receiver note_to_receiver
           , rsl.destination_type_code destination_type_code
           , rsl.deliver_to_person_id deliver_to_person_id
           , rsl.deliver_to_location_id deliver_to_location_id
           , rsl.to_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , poll.closed_code closed_code
           , rsh.asn_type asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , '' rate_type_display
           , poll.match_option match_option
           , rsl.country_of_origin_code country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --POLL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
        FROM rcv_shipment_lines rsl
           , rcv_shipment_headers rsh
           , po_headers poh
           , po_line_locations poll
           , po_lines pol
           , po_releases por
           , mtl_system_items msi
           , mtl_units_of_measure mum
       WHERE NVL(poll.approved_flag, 'N') = 'Y'
         AND NVL(poll.cancel_flag, 'N') = 'N'
         AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
         AND poll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
         AND poh.po_header_id = poll.po_header_id
         AND pol.po_line_id = poll.po_line_id
         AND poll.po_release_id = por.po_release_id(+)
         AND mum.unit_of_measure(+) = rsl.unit_of_measure
         AND NVL(msi.organization_id, rsl.to_organization_id) = rsl.to_organization_id
         AND msi.inventory_item_id(+) = rsl.item_id
         AND poll.line_location_id = rsl.po_line_location_id
         AND rsl.shipment_header_id = rsh.shipment_header_id
-- For Bug 7440217  Added type LCM also
         AND rsh.asn_type IN('ASN', 'ASBN', 'LCM')
-- End for Bug 7440217
         AND rsl.shipment_line_status_code <> 'CANCELLED'
         AND rsl.shipment_line_id = v_shipment_line_id
         AND poll.line_location_id IN(
              SELECT pod.line_location_id
                FROM po_distributions_all pod
               WHERE (
                      p_project_id IS NULL
                      OR(p_project_id = -9999
                         AND pod.project_id IS NULL)
                      OR --bug#2669021
                         NVL(pod.project_id, -9999) = p_project_id
                     )
                 AND(p_task_id IS NULL
                     OR NVL(pod.task_id, -9999) = p_task_id)
                 AND pod.po_header_id = poll.po_header_id
                 AND pod.po_line_id = poll.po_line_id
                 AND pod.line_location_id = poll.line_location_id)
      UNION
      SELECT 'N' line_chkbox
           , 'INTERNAL' source_type_code
           , DECODE(rsl.source_document_code, 'INVENTORY', 'INVENTORY', 'REQ', 'INTERNAL ORDER') receipt_source_code
           , rsl.source_document_code order_type_code
           , '' order_type
           , rsh.shipment_header_id po_header_id
           , rsh.shipment_num po_number
           , rsl.shipment_line_id po_line_id
           , rsl.line_num po_line_number
           , rsl.shipment_line_id po_line_location_id
           , rsl.line_num po_shipment_number
           , rsh.shipment_header_id po_release_id
           , rsh.shipment_header_id po_release_number
           , porh.requisition_header_id req_header_id
           , porh.segment1 req_number
           , porl.requisition_line_id req_line_id
           , porl.line_num req_line
           , rsl.req_distribution_id req_distribution_id
           , rsl.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id
           , rsl.to_organization_id to_organization_id
           , rsl.shipment_line_id vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , 'N' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , DECODE(msi1.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsh.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsh.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , porl.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , rsl.quantity_shipped ordered_qty
           , rsl.primary_unit_of_measure ordered_uom
           , rsh.ussgl_transaction_code ussgl_transaction_code
           , rsh.government_context government_context
           , NULL inspection_required_flag
           , NULL receipt_required_flag
           , NULL enforce_ship_to_location_code
           , TO_NUMBER(NULL) unit_price
           , NULL currency_code
           , NULL currency_conversion_type
           , TO_DATE(NULL) currency_conversion_date
           , TO_NUMBER(NULL) currency_conversion_rate
           , NULL note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
             rsl.destination_type_code destination_type_code
           , rsl.deliver_to_person_id deliver_to_person_id
           , rsl.deliver_to_location_id deliver_to_location_id
           , rsl.to_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , 'OPEN' closed_code
           , NULL asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , NULL rate_type_display
           , 'P' match_option
           , NULL country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence temp
        FROM rcv_shipment_headers rsh
           , rcv_shipment_lines rsl
           , po_requisition_headers porh
           , po_requisition_lines porl
           , mtl_system_items msi
           , mtl_system_items msi1
           , mtl_units_of_measure mum
       WHERE rsh.receipt_source_code <> 'VENDOR'
         AND rsl.requisition_line_id = porl.requisition_line_id(+)
         AND porl.requisition_header_id = porh.requisition_header_id(+)
         AND rsh.shipment_header_id = rsl.shipment_header_id
         AND mum.unit_of_measure(+) = rsl.unit_of_measure
         AND msi.organization_id(+) = rsl.to_organization_id
         AND msi.inventory_item_id(+) = rsl.item_id
         AND msi1.organization_id(+) = rsl.from_organization_id
         AND msi1.inventory_item_id(+) = rsl.item_id
         AND rsh.asn_type IS NULL
         AND rsl.shipment_line_id = v_shipment_line_id;
    -- dont need from and to org for the query since both have 1-to-1 relationship to shipment header

    l_debug                    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok      BOOLEAN;   --Return status of lot_serial_split API
    l_lpn_id                   NUMBER       := p_lpn_id;
    l_msni_count               NUMBER := 0;
    l_line_id                  NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_asn_con_rcpt_intf_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_move_order_header_id = ' || p_move_order_header_id, 4);
      print_debug('p_organization_id = ' || p_organization_id, 4);
      print_debug('p_shipment_header_id = ' || p_shipment_header_id, 4);
      print_debug('p_po_header_id = ' || p_po_header_id, 4);
      print_debug('p_item_id = ' || p_item_id, 4);
      print_debug('p_location_id = ' || p_location_id, 4);
      print_debug('p_rcv_qty = ' || p_rcv_qty, 4);
      print_debug('p_rcv_uom = ' || p_rcv_uom, 4);
      print_debug('p_rcv_uom_code = ' || p_rcv_uom_code, 4);
      print_debug('p_source_type = ' || p_source_type, 4);
      print_debug('p_from_lpn_id = ' || p_from_lpn_id, 4);
      print_debug('p_lpn_id = ' || p_lpn_id, 4);
      print_debug('p_lot_control_code = ' || p_lot_control_code, 4);
      print_debug('p_revision = ' || p_revision, 4);
      print_debug('p_inspect = ' || p_inspect, 4);
      print_debug('p_item_desc = ' || p_item_desc, 4);
      print_debug('p_project_id = ' || p_project_id, 4);
      print_debug('p_task_id = ' || p_task_id, 4);
    END IF;

    SAVEPOINT crt_asn_con_rti_sp;
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      /* Bug #2516729
       * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
       * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
       * in order that a new receipt # is not created everytime and the existing receipt # is used
       */
      BEGIN
        SELECT receipt_num
          INTO l_receipt_num
          FROM rcv_shipment_headers
         WHERE shipment_header_id = p_shipment_header_id
           AND ship_to_org_id = p_organization_id;

	/* Bug# 6339752 the global variable inv_rcv_common_apis.g_rcv_global_var.receipt_num is to be set only if
         * there is non-null value from RSH.
	 */

	IF (l_receipt_num IS NOT NULL) THEN
	  inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
	END IF;

	 IF (l_debug = 1) THEN
          print_debug('create_asn_con_rcpt_intf_rec: 10.1 ' || inv_rcv_common_apis.g_rcv_global_var.receipt_num, 1);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_receipt_num := NULL;
      END;

      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    -- default header level non-DB items in rcv_transaction block
    -- and default other values need to be insert into RTI

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_rcpt_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
        INTO l_group_id
        FROM DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm   ?

	--12339922-starts
 	BEGIN
 	  SELECT  lot_number INTO l_lot_number
 	  FROM mtl_transaction_lots_interface
 	  WHERE  product_transaction_id = p_original_rti_id ;
 	EXCEPTION
 	  WHEN No_Data_Found THEN
 	    IF (l_debug = 1) THEN
 	    print_debug('The value of create_intship_rcpt_intf_rec: No Lot records in MTLI for id :'||p_original_rti_id,4);
 	    END IF;
 	    l_lot_number :=NULL;
 	  WHEN too_many_rows THEN
 	    IF (l_debug = 1) THEN
 	     print_debug('The value of create_intship_rcpt_intf_rec: More than one records in MTLI for id :'||p_original_rti_id,4);
 	    END IF;
 	    l_lot_number :=NULL; --For multiple lots dont input to matching logic
    END;
 	    IF (l_debug = 1) THEN
 	     print_debug('The value of create_intship_rcpt_intf_rec: 30.2 lot_number: ' || l_lot_number, 4);
 	    END IF;
    --12339922-ends

    -- initialize input record for matching algorithm
    g_rcpt_match_table_gross(g_receipt_detail_index).GROUP_ID := l_group_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).transaction_type := 'RECEIVE';
    g_rcpt_match_table_gross(g_receipt_detail_index).quantity := p_rcv_qty;
    g_rcpt_match_table_gross(g_receipt_detail_index).unit_of_measure := p_rcv_uom;

    IF p_item_id IS NOT NULL THEN
      g_rcpt_match_table_gross(g_receipt_detail_index).item_id := p_item_id;
    ELSE
      g_rcpt_match_table_gross(g_receipt_detail_index).item_id := NULL;
      g_rcpt_match_table_gross(g_receipt_detail_index).item_desc := p_item_desc;
    END IF;

    g_rcpt_match_table_gross(g_receipt_detail_index).to_organization_id := p_organization_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).shipment_header_id := p_shipment_header_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).po_header_id := p_po_header_id;
    g_rcpt_match_table_gross(g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcpt_match_table_gross(g_receipt_detail_index).ship_to_location_id := p_location_id; -- for tolerance checks in matching.
    g_rcpt_match_table_gross(g_receipt_detail_index).tax_amount := 0; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).error_status := 'S'; -- ?
    g_rcpt_match_table_gross(g_receipt_detail_index).project_id := p_project_id; --BUG# 2794612
    g_rcpt_match_table_gross(g_receipt_detail_index).task_id := p_task_id; --BUG# 2794612
    g_rcpt_match_table_gross(g_receipt_detail_index).lot_number := l_lot_number; --Bug 12339922
    l_progress := '60';

    IF p_item_id IS NOT NULL THEN
      BEGIN
        SELECT primary_unit_of_measure
          INTO g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure
          FROM mtl_system_items
         WHERE mtl_system_items.inventory_item_id = p_item_id
           AND mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('Primary_uom is null should not be null', 4);
          END IF;

          l_progress := '65';
          RAISE fnd_api.g_exc_error;
      END;
    ELSE
      g_rcpt_match_table_gross(g_receipt_detail_index).primary_unit_of_measure := NULL;
    END IF;

    l_progress := '70';

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_rcpt_intf_rec: 30 before matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

-- For Bug 7440217 Added LCM Type also
    IF p_source_type IN ('ASN', 'LCM') THEN
      l_match_type := p_source_type;
-- End for Bug 7440217

      ELSE
      l_match_type := 'INTRANSIT SHIPMENT';

      BEGIN
        SELECT cost_group_id
          INTO l_rcv_transaction_rec.cost_group_id
          FROM wms_lpn_contents wlpnc
         WHERE organization_id = p_organization_id
           AND parent_lpn_id = p_lpn_id
           AND wlpnc.inventory_item_id = p_item_id
           AND EXISTS(SELECT 1
                        FROM cst_cost_group_accounts
                       WHERE organization_id = p_organization_id
                         AND cost_group_id = wlpnc.cost_group_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_rcv_transaction_rec.cost_group_id := NULL;
      END;

      IF l_rcv_transaction_rec.cost_group_id IS NULL THEN
        UPDATE wms_lpn_contents wlpnc
           SET cost_group_id = NULL
         WHERE organization_id = p_organization_id
           AND parent_lpn_id = p_from_lpn_id
           AND wlpnc.inventory_item_id = p_item_id
           AND NOT EXISTS(SELECT 1
                            FROM cst_cost_group_accounts
                           WHERE organization_id = p_organization_id
                             AND cost_group_id = wlpnc.cost_group_id);
      END IF;
    END IF;

    l_lpn_id := p_from_lpn_id;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => l_return_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , x_cascaded_table        => g_rcpt_match_table_gross
    , n                       => g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => l_match_type
    , p_lpn_id                => l_lpn_id
    );

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_rcpt_intf_rec: 40 after matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('create_asn_con_rcpt_intf_rec: 40.1 - after matching  l_return_status = ' || l_return_status, 4);
      print_debug('create_asn_con_rcpt_intf_rec: 40.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_asn_con_rcpt_intf_rec: 40.3 - after matching  l_msg_data = ' || l_msg_data, 4);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF g_rcpt_match_table_gross(g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := g_rcpt_match_table_gross(g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_receipt_detail_index ..(g_receipt_detail_index + l_rcpt_match_table_detail.COUNT - 1) LOOP
      IF l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- load the matching algorithm result into input data structure
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '72';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).shipment_line_id);
      l_progress := '74';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '76';
      CLOSE l_curs_rcpt_detail;
      l_progress := '78';
      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;

      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_con_rcpt_intf_rec: 90.1 - the '
          || match_result_count
          || 'th record of matching results - rcv_shipment_line_id = '
          || l_rcpt_match_table_detail(match_result_count).shipment_line_id
        , 4
        );
      END IF;

      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;

      -- Nested LPN changes pass p_from_lpn_id
      -- are at J then pass From_lpn_id as lpn_id otherwise use old code.
      -- IF p_from_lpn_id IS NOT NULL
      l_rcv_transaction_rec.lpn_id := p_from_lpn_id;
      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.ordered_qty;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec: 100 before insert_txn_interface' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '80';

      l_rcv_transaction_rec.destination_subinventory := p_rcv_subinventory_code;
      l_rcv_transaction_rec.locator_id := p_rcv_locator_id;
      -- Bug 3211452
      -- Putting the Revision also
      l_rcv_transaction_rec.item_revision := p_revision;

      IF p_country_code IS NOT NULL THEN
        l_rcv_transaction_rec.country_of_origin_code := p_country_code;
      END IF;

      IF (p_inspect IS NOT NULL AND p_inspect = 1) THEN

        -- Bug# 6967549, Check to see if Skip Lot functionality is enabled for the
        -- current org or not and activate the same only for ASN receipts.
        IF p_source_type = 'ASN' THEN

          -- Calling function QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY to check if Skip/Lot
          -- is enabled for the given org or not.
          -- returns fnd_api.g_true/false
          BEGIN
            l_progress := '81';
            qa_skiplot_rcv_grp.check_availability(
              p_api_version            => 1.0
              , p_init_msg_list        => fnd_api.g_false
              , p_commit               => fnd_api.g_false
              , p_validation_level     => fnd_api.g_valid_level_full
              , p_organization_id      => p_organization_id
              , x_qa_availability      => l_qa_availability
              , x_return_status        => l_return_status
              , x_msg_count            => l_msg_count
              , x_msg_data             => l_msg_data
            );
            l_progress := '82';
          EXCEPTION
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                print_debug( 'create_asn_con_rcpt_intf_rec: 101 - Exception in calling QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY'
                  || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
              END IF;
              RAISE fnd_api.g_exc_error;
          END;

          IF NVL(l_return_status, fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_success THEN

            -- If the Quaility Skip Lot function is available, then gets the interface transaction id and
            -- call QA_SKIPLOT_RCV_GRP.EVALUATE_LOT
            -- returns 'Standard' or 'Inspect' to x_evaluation_result.
            IF NVL(l_qa_availability, fnd_api.g_false) = fnd_api.g_true THEN
              l_rcv_rcpt_rec.inspection_required_flag := 'Y';
              l_rcv_rcpt_rec.routing_id := 2;

              BEGIN
                SELECT rcv_transactions_interface_s.NEXTVAL
                INTO l_rcv_transaction_rec.interface_transaction_id
                FROM DUAL;

                l_progress := '83';
                l_project_id := p_project_id;
                l_task_id := p_task_id;

                IF l_project_id = '' THEN
                  l_project_id := NULL;
                END IF;

                IF l_task_id = '' THEN
                  l_task_id := NULL;
                END IF;

                IF (l_debug = 1) THEN
                  print_debug('create_asn_con_rcpt_intf_rec 101 calling qa_skiplot_rcv_grp.evaluate_lot', 4);
                  print_debug('create_asn_con_rcpt_intf_rec 101 with l_rcv_rcpt_rec.item_revision = '|| l_rcv_rcpt_rec.item_revision, 4);
                END IF;

                -- Bug# 6967549, Same as previous version except now passing p_lpn_id directly
                -- to the p_lpn_id parameter in the qa_skiplot_rcv_grp.evaluate_lot() API call.

                l_progress := '84';
                qa_skiplot_rcv_grp.evaluate_lot(
                  p_api_version               => 1.0
                  , p_init_msg_list           => fnd_api.g_false
                  , p_commit                  => fnd_api.g_false
                  , p_validation_level        => fnd_api.g_valid_level_full
                  , p_interface_txn_id        => l_rcv_transaction_rec.interface_transaction_id
                  , p_organization_id         => p_organization_id
                  , p_vendor_id               => l_rcv_rcpt_rec.vendor_id
                  , p_vendor_site_id          => l_rcv_rcpt_rec.vendor_site_id
                  , p_item_id                 => l_rcv_rcpt_rec.item_id
                  , p_item_revision           => l_rcv_rcpt_rec.item_revision
                  , p_item_category_id        => l_rcv_rcpt_rec.item_category_id
                  , p_project_id              => l_project_id
                  , p_task_id                 => l_task_id
                  , p_manufacturer_id         => NULL
                  , p_source_inspected        => NULL
                  , p_receipt_qty             => l_rcv_transaction_rec.transaction_qty
                  , p_receipt_date            => SYSDATE
                  , p_primary_uom             => l_rcv_transaction_rec.primary_uom
                  , p_transaction_uom         => l_rcv_transaction_rec.transaction_uom
                  , p_po_header_id            => l_rcv_rcpt_rec.po_header_id
                  , p_po_line_id              => l_rcv_rcpt_rec.po_line_id
                  , p_po_line_location_id     => l_rcv_rcpt_rec.po_line_location_id
                  , p_po_distribution_id      => l_rcv_rcpt_rec.po_distribution_id
                  , p_lpn_id                  => p_lpn_id
                  , p_wms_flag                => 'Y'
                  , x_evaluation_result       => l_evaluation_result
                  , x_return_status           => l_return_status
                  , x_msg_count               => l_msg_count
                  , x_msg_data                => l_msg_data
                );

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                  IF (l_debug = 1) THEN
                    print_debug('create_asn_con_rcpt_intf_rec 84.1: QA CALL RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                  END IF;
                  RAISE fnd_api.g_exc_error;
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF (l_debug = 1) THEN
                    print_debug('create_asn_con_rcpt_intf_rec 135.2: QA CALL RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                -- If QA_SKIPLOT_RCV_GRP returns 'Standard', sets the routing id to 1.
                -- If QA_SKIPLOT_RCV_GRP returns 'Inspect', leaves the routing id as 2.
                IF l_evaluation_result = 'STANDARD' THEN
                  l_rcv_rcpt_rec.inspection_required_flag := 'N';
                  l_rcv_rcpt_rec.routing_id := 1;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  IF (l_debug = 1) THEN
                    print_debug('create_asn_con_rcpt_intf_rec: 135.3 - Exception in calling QA_SKIPLOT_RCV_GRP.EVALUATE_LOT'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                  END IF;
                  RAISE fnd_api.g_exc_error;
              END;

            END IF;
          END IF;

        ELSE -- p_source_type is <> ASN
          l_rcv_rcpt_rec.inspection_required_flag := 'Y';
          l_rcv_rcpt_rec.routing_id := 2;
        END IF;

      ELSE
        l_rcv_rcpt_rec.routing_id := 1;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      l_interface_transaction_id := insert_txn_interface(
          l_rcv_transaction_rec
        , l_rcv_rcpt_rec
        , l_group_id
        , l_transaction_type
        , p_organization_id
        , p_location_id
        , p_source_type
        , l_rcv_rcpt_rec.routing_id
        , p_project_id
        , p_task_id
        , p_express_transaction
        );
      l_progress := '90';

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec: 110 after insert_txn_interface' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('create_asn_con_rcpt_intf_rec 135.5: INV J and PO J are installed. No Move Order creation from UI', 4);
      END IF;
      /* Populate the table to store the information of the RTIs created*/
      l_new_rti_info(match_result_count).orig_interface_trx_id := p_original_rti_id;
      l_new_rti_info(match_result_count).new_interface_trx_id := l_interface_transaction_id;
      l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
    END LOOP; --END LOOP through results returned by matching algorithm

    --Call the split_lot API to split the lots and serials inserted from the UI
    --based on the quantity of each RTI record

    --BUG 3326408,3346758,3405320
    --If there are any serials confirmed from the UI for an item that is
    --lot controlled and serial control dynamic at SO issue,
    --do not NULL out serial_transaction_temp_id. In other cases,
    --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
    l_msni_count := 0;
    IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
	l_rcv_rcpt_rec.serial_number_control_code IN (1,6)) THEN
       IF (l_debug = 1) THEN
          print_debug('create_asn_con_rcpt_intf_rec 135.6: serial_control_code IS 6, need TO NULL OUT mtli', 4);
       END IF;

       BEGIN
          IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN
            SELECT count(1)
            INTO   l_msni_count
            FROM   mtl_serial_numbers_interface
            WHERE  product_transaction_id = p_original_rti_id
            AND    product_code = 'RCV';
          END IF;

          IF l_msni_count = 0 THEN
            UPDATE mtl_transaction_lots_interface
            SET  serial_transaction_temp_id = NULL
            WHERE product_transaction_id = p_original_rti_id
            AND   product_code = 'RCV';
          END IF;
       EXCEPTION
          WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('create_asn_con_rcpt_intf_rec 135.7: Error nulling serial temp id OF MTLI', 4);
	     END IF;
       END ;
    END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

    l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
    IF ( NOT l_split_lot_serial_ok) THEN
       IF (l_debug = 1) THEN
          print_debug('create_asn_con_rcpt_intf_rec 95.1: Failure in split_lot_serial', 4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('create_asn_con_rcpt_intf_rec 05.2: Call split_lot_serial is OK', 4);
    END IF;

    IF l_curs_rcpt_detail%ISOPEN THEN
      CLOSE l_curs_rcpt_detail;
    END IF;

    -- append index in input table where the line to be detailed needs to be inserted
    --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

    l_progress := '110';
    -- clear the lot/qty data structure
    -- Called after Calling the INV_CR_ASN_DETAILS
    -- g_rcpt_lot_qty_rec_tb.DELETE;

    l_progress := '120';

    IF p_item_id IS NOT NULL THEN
      inv_rcv_common_apis.do_check(
        p_organization_id         => p_organization_id
      , p_inventory_item_id       => p_item_id
      , p_transaction_type_id     => 18
      , p_primary_quantity        => l_total_primary_qty
      , x_return_status           => l_return_status
      , x_msg_count               => l_msg_count
      , x_msg_data                => x_message
      );
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '130';

    -- Calling The ASN Discrepnacy  Details
    IF (l_debug = 1) THEN
      print_debug('Before Calling ASN Ddetails ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    inv_cr_asn_details.create_asn_details(
      p_organization_id
    , l_group_id
    , l_rcv_rcpt_rec
    , l_rcv_transaction_rec
    , g_rcpt_lot_qty_rec_tb
    , l_interface_transaction_id
    , l_return_status
    , l_msg_data
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('About exit create_asn_con_rcpt_intf_rec: 140' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_rcpt_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_asn_con_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_con_rcpt_intf_rec: Other exception - l_progress = '
          || l_progress
          || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1
        );
      END IF;
  END create_asn_con_rcpt_intf_rec;

  PROCEDURE create_asn_exp_rcpt_intf_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_shipment_header_id    IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_location_id           IN             NUMBER
  , p_source_type           IN             VARCHAR2
  , p_lpn_id                IN             NUMBER
  , p_inspect               IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_project_id            IN             NUMBER DEFAULT NULL
  , p_task_id               IN             NUMBER DEFAULT NULL
  , p_rcv_subinventory_code IN             VARCHAR2 DEFAULT NULL
  , p_rcv_locator_id        IN             NUMBER DEFAULT NULL
  , p_original_rti_id       IN             NUMBER DEFAULT NULL
  , p_secondary_quantity          IN             NUMBER    DEFAULT NULL --OPM Convergence
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  ) IS
    -- get unit_of_measure in a later query because of some
    -- SQL problem, ???

    /* FP-J Lot/Serial Support Enhancement
     * Fetch the item's serial control code and item's primary uom code
     */
    CURSOR l_curs_asn_lpn_content IS
      SELECT lpn.lpn_id
           , lpnc.inventory_item_id
           , lpnc.revision
           , lpnc.quantity
           , lpnc.uom_code
           , msi.lot_control_code
           , ''
           , --uom.unit_of_measure,
             p_po_header_id
           , lpnc.lot_number
           , lpn.organization_id
           , msi.serial_number_control_code
           , msi.primary_uom_code
           , lpnc.secondary_quantity   -- Bug 7708998
        FROM wms_lpn_contents lpnc, wms_license_plate_numbers lpn, mtl_system_items_b msi, rcv_shipment_headers rsh
       WHERE rsh.shipment_header_id = p_shipment_header_id
         AND(lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
         AND lpn.lpn_context IN(6, 7) -- only those pre-ASN receiving ones
                                      -- Nested LPN changes to explode the LPN
                                      -- AND wlpnc.parent_lpn_id = Nvl(p_lpn_id, wlpn.lpn_id)
                                      -- In case user tries to to ASN reciept by giving only PO Number
                                      -- LPN id will be NULL, In this case we should not expand the LPN
                                      -- in which case start with lpn_id = p_lpn_id will fail.
         AND(lpn.lpn_id = NVL(p_lpn_id, lpn.lpn_id)
             OR lpn.lpn_id IN(SELECT     lpn_id
                                    FROM wms_license_plate_numbers
                              START WITH lpn_id = p_lpn_id
                              CONNECT BY parent_lpn_id = PRIOR lpn_id))
         --AND    lpn.lpn_id = nvl(p_lpn_id, lpn.lpn_id)
         AND lpn.lpn_id = lpnc.parent_lpn_id
         AND lpnc.inventory_item_id = msi.inventory_item_id
         AND msi.organization_id = p_organization_id
         AND(
             lpnc.source_line_id IN(SELECT pola.po_line_id
                                      FROM po_lines_all pola
                                     WHERE pola.po_header_id = NVL(p_po_header_id, pola.po_header_id))
             OR lpnc.source_line_id IS NULL
            );

    /* FP-J Lot/Serial Support Enhancement
     * Cursor to create MSNI records for serials in the LPN
     */
    CURSOR l_curs_serial_number(v_inventory_item_id NUMBER, v_revision VARCHAR2
                , v_lot_number VARCHAR2, v_lpn_id NUMBER) IS
       SELECT serial_number,
              status_id
        FROM mtl_serial_numbers
       WHERE inventory_item_id = v_inventory_item_id
         AND(revision = v_revision
             OR(revision IS NULL
                AND v_revision IS NULL))
         AND(lot_number = v_lot_number
             OR(lot_number IS NULL
                AND v_lot_number IS NULL))
         AND lpn_id = v_lpn_id;

    l_lpn_id            NUMBER;
    l_inventory_item_id   NUMBER;
    l_revision            VARCHAR2(30);
    l_quantity            NUMBER;
    l_uom_code            VARCHAR2(3);
    l_lot_control_code    NUMBER;
    l_unit_of_measure     VARCHAR2(25);
    l_po_header_id        NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number          VARCHAR2(80);
    l_lpn_org             NUMBER;
    l_expiration_date     DATE;
    l_object_id           NUMBER;
    l_return_status       VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(4000);
    l_progress            VARCHAR2(10);
    l_label_status        VARCHAR2(500);
    l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_serial_control_code         NUMBER;
    l_transaction_interface_id    NUMBER;
    l_product_transaction_id      NUMBER;
    l_serial_transaction_temp_id  NUMBER;
    l_serial_number              mtl_serial_numbers.serial_number%type;
    l_primary_uom_code            mtl_system_items.primary_uom_code%TYPE;
    l_lot_prm_quantity            NUMBER; --lot quantity in primary uom
    l_lot_status_id               NUMBER;
    l_serial_status_id            NUMBER;
    l_from_org_id                 NUMBER;

    l_secondary_quantity          NUMBER;  --Bug 7708998
    l_msni_count                  NUMBER;  --Bug 10288330

  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_asn_exp_rcpt_intf_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_move_order_header_id = ' || p_move_order_header_id, 4);
      print_debug('p_organization_id = ' || p_organization_id, 4);
      print_debug('p_shipment_header_id = ' || p_shipment_header_id, 4);
      print_debug('p_po_header_id = ' || p_po_header_id, 4);
      print_debug('p_location_id = ' || p_location_id, 4);
      print_debug('p_source_type = ' || p_source_type, 4);
      print_debug('p_lpn_id = ' || p_lpn_id, 4);
      print_debug('p_inspect = ' || p_inspect, 4);
    END IF;

    --bug 10288330
    SAVEPOINT create_asn_exp_rcpt_intf_rec;

    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';
    OPEN l_curs_asn_lpn_content;
    l_progress := '20';

    LOOP
      FETCH l_curs_asn_lpn_content INTO
       l_lpn_id
     , l_inventory_item_id
     , l_revision
     , l_quantity
     , l_uom_code
     , l_lot_control_code
     , l_unit_of_measure
     , l_po_header_id
     , l_lot_number
     , l_lpn_org
     , l_serial_control_code
     , l_primary_uom_code
     , l_secondary_quantity;   --Bug 7708998
      EXIT WHEN l_curs_asn_lpn_content%NOTFOUND;
      l_progress := '30';

      --Reset the variables that store interface Ids
      l_transaction_interface_id    := NULL;
      l_serial_transaction_temp_id  := NULL;
      l_product_transaction_id      := NULL;

      IF (p_source_type = 'INTERNAL'
          AND l_lot_control_code = 2) THEN
        BEGIN
          SELECT expiration_date
            INTO l_expiration_date
            FROM mtl_lot_numbers
           WHERE inventory_item_id = l_inventory_item_id
             AND organization_id = l_lpn_org
             AND lot_number = l_lot_number;
        EXCEPTION
          WHEN OTHERS THEN
            l_expiration_date := NULL;
        END;

        inv_rcv_common_apis.insert_dynamic_lot(
          p_api_version           => 1.0
        , --p_init_msg_list            => p_init_msg_list,
          --p_commit                   => p_commit,
          --p_validation_level         => p_validation_level,
          p_inventory_item_id     => l_inventory_item_id
        , p_organization_id       => p_organization_id
        , p_lot_number            => l_lot_number
        , p_expiration_date       => l_expiration_date
        , --p_transaction_temp_id      => p_transaction_temp_id,
          --p_transaction_action_id    => p_transaction_action_id,
          p_transfer_organization_id => l_lpn_org,  --uncommenting and setting the transfer_org_id to l_lpn_org_id to
                                                    --populate lot attributes bug3368089
          p_status_id             => ''
        , p_update_status         => 'FALSE'
        , x_object_id             => l_object_id
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_asn_exp_rcpt_intf_rec 30.1:create_asn_con_rcpt_intf_rec  RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_asn_exp_rcpt_intf_rec 30.2: create_asn_con_rcpt_intf_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      l_progress := '33';

      -- should we be updating the org for the lpn here instead of in the lpnexit??????
      l_progress := '35';

      SELECT unit_of_measure
        INTO l_unit_of_measure
        FROM mtl_item_uoms_view
       WHERE uom_code = l_uom_code
         AND organization_id = p_organization_id
         AND inventory_item_id = l_inventory_item_id;

      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: 20.1 before populate_lot_rec : ', 4);
        print_debug('l_lot_number => ' || l_lot_number, 4);
        print_debug('l_quantity => ' || l_quantity, 4);
        print_debug('l_uom_code => ' || l_uom_code, 4);
        print_debug('p_organization_id => ' || p_organization_id, 4);
        print_debug('l_inventory_item_id => ' || l_inventory_item_id, 4);
      END IF;

      populate_lot_rec(
        p_lot_number       => l_lot_number
      , p_primary_qty      => l_quantity
      , p_txn_uom_code     => l_uom_code
      , p_org_id           => p_organization_id
      , p_item_id          => l_inventory_item_id
      );
      l_progress := '50';

      --Create the MTLI and MSNI records for the lots and serials in the LPN
        IF l_lot_control_code > 1 THEN
          IF l_lot_number IS NOT NULL THEN
            --Convert the lot quantity into Item's Primary UOM code
            IF l_uom_code <> l_primary_uom_code THEN
	       l_lot_prm_quantity := inv_rcv_cache.convert_qty
		                        (p_inventory_item_id  => l_inventory_item_id
					 ,p_from_qty          => l_quantity
					 ,p_from_uom_code     => l_uom_code
					 ,p_to_uom_code       => l_primary_uom_code);

	      --Check for failure
              IF l_lot_prm_quantity = -99999 THEN
                fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                  print_debug('create_asn_exp_rcpt_intf_rec: 20.2 - txn/primary uom conversion failed', 4);
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;   --END IF check for failure

            ELSE
              l_lot_prm_quantity := l_quantity;
            END IF;

            --Get the lot expiration date
            SELECT  expiration_date
                   , status_id
            INTO     l_expiration_date
                   , l_lot_status_id
            FROM mtl_lot_numbers
            WHERE inventory_item_id = l_inventory_item_id
            AND organization_id = l_lpn_org
            AND lot_number = l_lot_number;

            IF ((p_source_type = 'INTERNAL') AND (l_lpn_org <> p_organization_id)) THEN
              l_from_org_id := l_lpn_org;
            ELSE
              l_from_org_id := p_organization_id;
            END IF;

            --Create MTLI record for the lot and the lot quantity for this content
            --Set the flag for the API to populate the lot attributes
            inv_rcv_integration_apis.insert_mtli(
                p_api_version                 =>  1.0
              , p_init_msg_lst                =>  FND_API.G_FALSE
              , x_return_status               =>  l_return_status
              , x_msg_count                   =>  l_msg_count
              , x_msg_data                    =>  l_msg_data
              , p_transaction_interface_id    =>  l_transaction_interface_id
              , p_lot_number                  =>  l_lot_number
              , p_transaction_quantity        =>  l_quantity
              , p_primary_quantity            =>  l_lot_prm_quantity
              , p_secondary_quantity          =>  l_secondary_quantity   --Bug 7708998
              , p_organization_id             =>  l_from_org_id
              , p_inventory_item_id           =>  l_inventory_item_id
              , p_expiration_date             =>  l_expiration_date
              , p_status_id                   =>  l_lot_status_id
              , x_serial_transaction_temp_id  =>  l_serial_transaction_temp_id
              , p_product_transaction_id      =>  l_product_transaction_id
              , p_product_code                =>  'RCV'
              , p_att_exist                   =>  'Y'
              , p_update_mln                  =>  'N'
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (l_debug = 1) THEN
                print_debug('create_asn_exp_rcpt_intf_rec 20.3: Error in MTLI creation', 4);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (l_debug = 1) THEN
              print_debug('create_asn_exp_rcpt_intf_rec 20.4 : txn i/f id: ' || l_transaction_interface_id
                            || ' serial temp : ' || l_serial_transaction_temp_id || ' prod txn id: ' || l_product_transaction_id, 4);
            END IF;
          END IF;   --END IF l_lot_number IS NOT NULL

          --Create MSNI records for the serials within lots
          --Bug #3405320
          --Create MSNI records even if serial control code is dynamic at SO Issue in
          --receiving org if there are serials shipped
          IF ((l_serial_control_code IN (2, 5)) OR
              (l_serial_control_code = 6 AND p_source_type = 'INTERNAL')) THEN
            -- bug 3196554
            OPEN l_curs_serial_number(l_inventory_item_id, l_revision, l_lot_number, l_lpn_id);
            --Loop through the serials in the lot
            LOOP
              FETCH l_curs_serial_number INTO l_serial_number, l_serial_status_id;
              EXIT WHEN l_curs_serial_number%NOTFOUND;
              --For each serial number in the lot create one MSNI record. The
              --serial attributes would be populated by the API
              IF (l_debug = 1) THEN
                print_debug('create_asn_exp_rcpt_intf_rec 20.4.1: Before MSNI creation', 4);
              END IF;
              inv_rcv_integration_apis.insert_msni(
                  p_api_version                 =>  1.0
                , p_init_msg_lst                =>  FND_API.G_FALSE
                , x_return_status               =>  l_return_status
                , x_msg_count                   =>  l_msg_count
                , x_msg_data                    =>  l_msg_data
                , p_transaction_interface_id    =>  l_serial_transaction_temp_id
                , p_fm_serial_number            =>  l_serial_number
                , p_to_serial_number            =>  l_serial_number
                , p_organization_id             =>  p_organization_id
                , p_inventory_item_id           =>  l_inventory_item_id
                , p_status_id                   =>  l_serial_status_id
                , p_product_transaction_id      =>  l_product_transaction_id
                , p_product_code                =>  'RCV'
                , p_att_exist                   =>  'Y'
                , p_update_msn                  =>  'N'
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF (l_debug = 1) THEN
                  print_debug('create_asn_exp_rcpt_intf_rec 20.5: Error in MSNI creation', 4);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;   --END LOOP through serials for the lot

            --Close the serial cursor
            IF l_curs_serial_number%ISOPEN THEN
              CLOSE l_curs_serial_number;
            END IF;
          END IF;   --END IF item is lot and serial controlled

        --If the item is serial controlled, loop through the serials within
        --the LPN and create one MSNI record for each serial number
        --The attributes for each serial number would be fetched by the API
        ELSIF (l_serial_control_code IN (2, 5) OR
               (l_serial_control_code = 6 AND p_source_type = 'INTERNAL')) THEN
          -- bug 3196554
          OPEN l_curs_serial_number(l_inventory_item_id, l_revision, l_lot_number, l_lpn_id);
          --Loop through the serials in the lot
          LOOP
            FETCH l_curs_serial_number INTO l_serial_number, l_serial_status_id;
            EXIT WHEN l_curs_serial_number%NOTFOUND;
            --For each serial number in the lot create one MSNI record. The
            --serial attributes would be populated by the API
            IF (l_debug = 1) THEN
              print_debug('create_asn_exp_rcpt_intf_rec 20.5.1: Before MSNI creation', 4);
            END IF;
            inv_rcv_integration_apis.insert_msni(
                p_api_version                 =>  1.0
              , p_init_msg_lst                =>  FND_API.G_FALSE
              , x_return_status               =>  l_return_status
              , x_msg_count                   =>  l_msg_count
              , x_msg_data                    =>  l_msg_data
              , p_transaction_interface_id    =>  l_transaction_interface_id
              , p_fm_serial_number            =>  l_serial_number
              , p_to_serial_number            =>  l_serial_number
              , p_organization_id             =>  p_organization_id
              , p_inventory_item_id           =>  l_inventory_item_id
              , p_status_id                   =>  l_serial_status_id
              , p_product_transaction_id      =>  l_product_transaction_id
              , p_product_code                =>  'RCV'
              , p_att_exist                   =>  'Y'
              , p_update_msn                  =>  'N'
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (l_debug = 1) THEN
                print_debug('create_asn_exp_rcpt_intf_rec 20.6: Error in MSNI creation', 4);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_debug = 1) THEN
              print_debug('create_asn_exp_rcpt_intf_rec 20.7 : txn i/f id: ' || l_transaction_interface_id || ' prod txn id: ' || l_product_transaction_id, 4);
            END IF;
          END LOOP;   --END LOOP through serials for the lot

          --Close the serial cursor
          IF l_curs_serial_number%ISOPEN THEN
            CLOSE l_curs_serial_number;
          END IF;
        END IF;    --END IF check lot and serial control codes

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: 30 before create_asn_con_rcpt_intf_rec'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('before create_asn_con_rcpt_intf_rec: l_product_transaction_id: ' || l_product_transaction_id, 4);
      END IF;

      create_asn_con_rcpt_intf_rec(
        p_move_order_header_id     => p_move_order_header_id
      , p_organization_id          => p_organization_id
      , p_shipment_header_id       => p_shipment_header_id
      , p_po_header_id             => l_po_header_id
      , p_item_id                  => l_inventory_item_id
      , p_location_id              => p_location_id
      , p_rcv_qty                  => l_quantity
      , p_rcv_uom                  => l_unit_of_measure
      , p_rcv_uom_code             => l_uom_code
      , p_source_type              => p_source_type
      , p_from_lpn_id              => l_lpn_id
      , p_lpn_id                   => l_lpn_id
      , p_lot_control_code         => l_lot_control_code
      , p_revision                 => l_revision
      , p_inspect                  => p_inspect
      , x_status                   => l_return_status
      , x_message                  => l_msg_data
      , p_item_desc                => NULL
      , p_project_id               => p_project_id
      , p_task_id                  => p_task_id
      , p_rcv_subinventory_code    => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
      , p_rcv_locator_id           => p_rcv_locator_id
      , p_original_rti_id          => l_product_transaction_id
      , p_attribute_category        => p_attribute_category  --Bug #4147209
      , p_attribute1                => p_attribute1
      , p_attribute2                => p_attribute2
      , p_attribute3                => p_attribute3
      , p_attribute4                => p_attribute4
      , p_attribute5                => p_attribute5
      , p_attribute6                => p_attribute6
      , p_attribute7                => p_attribute7
      , p_attribute8                => p_attribute8
      , p_attribute9                => p_attribute9
      , p_attribute10               => p_attribute10
      , p_attribute11               => p_attribute11
      , p_attribute12               => p_attribute12
      , p_attribute13               => p_attribute13
      , p_attribute14               => p_attribute14
      , p_attribute15               => p_attribute15
      , p_express_transaction       => 'Y'
      );

      IF (l_debug = 1) THEN
        print_debug('after create_asn_con_rcpt_intf_rec: l_product_transaction_id: ' || l_product_transaction_id, 4);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_asn_exp_rcpt_intf_rec 40.1:create_asn_con_rcpt_intf_rec  RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_asn_exp_rcpt_intf_rec 40.2: create_asn_con_rcpt_intf_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: 50 after create_asn_con_rcpt_intf_rec'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      /*bug 10288330 start*/
      /* For ASN express receipt, if there is a mismatch between MSNI and RTI in terms of serial number quantity, error out.
         Keeping the validation inside the LPN loop, so that it can be done per LPN basis; that way we can also handle the scenario
         where multiple LPNs exists in an ASN and not all LPNs are problematic.
         Moreover, the call insert_msni (see above) inserts 1 record per serial number. This will be the underlying assumption of
         following validation.
      */
      l_msni_count := 0;
      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: 60 Validate RTI-MSNI mismatch for serial numbers', 4);
      END IF;
      IF ((l_serial_control_code IN (2, 5)) AND p_source_type = 'ASN') THEN
        IF (l_debug = 1) THEN
          print_debug('create_asn_exp_rcpt_intf_rec: 61 Item is serial controlled', 4);
        END IF;

        select count(1) into
        l_msni_count
        from mtl_serial_numbers_interface msni, rcv_transactions_interface rti,
	wms_license_plate_numbers lpn, rcv_shipment_headers rsh
        where rti.interface_transaction_id = msni.product_transaction_id
        and rsh.shipment_header_id = p_shipment_header_id
        and (lpn.source_header_id = rsh.shipment_header_id
             or lpn.source_name = rsh.shipment_num)
        and lpn.lpn_id = l_lpn_id
        and rti.lpn_id = l_lpn_id
        and rti.item_id = l_inventory_item_id
        and nvl (rti.item_revision,'@@@') = nvl (l_revision,'@@@')
        and msni.product_code = 'RCV'
        and rti.processing_status_code <> 'ERROR'
        and rti.transaction_status_code <> 'ERROR';

        IF (l_debug = 1) THEN
          print_debug('create_asn_exp_rcpt_intf_rec: No of MSNIs found: ' || l_msni_count, 4);
        END IF;

        IF l_msni_count <> l_quantity THEN
          IF (l_debug = 1) THEN
            print_debug('create_asn_exp_rcpt_intf_rec: 62 quantity mismatch for serial numbers between RTI and MSNI', 4);
          END IF;
          --fnd_message.clear;
          --fnd_message.retrieve(l_fnd_msg_out);
          fnd_message.set_name('WMS', 'WMS_MISSING_SERIALS_EXP_RCPT');
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_asn_exp_rcpt_intf_rec: 63 : RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          ROLLBACK to create_asn_exp_rcpt_intf_rec;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
      /*bug 10288330  end*/

    END LOOP;   --END LOOP fetch LPN contents

    -- insert WLPNI for FromLPN with parent as NULL.
      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_exp_dd_intf_rec: 50.1 - Before inserting into wlpni for p_lpn_id with parent NULL '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      IF ((p_source_type = 'INTERNAL') AND (l_lpn_org <> p_organization_id)) THEN
        l_from_org_id := l_lpn_org;
      ELSE
        l_from_org_id := p_organization_id;
      END IF;

      -- Nested LPN changes. Insert WLPNI
      inv_rcv_integration_apis.insert_wlpni(
          p_api_version           => 1.0
         ,x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data
         ,p_organization_id       => l_from_org_id --BUG 4096028: Should use from org_id
         ,p_lpn_id                => p_lpn_id
         ,p_license_plate_number  => NULL
         ,p_lpn_group_id          => inv_rcv_common_apis.g_rcv_global_var.interface_group_id
         ,p_parent_lpn_id         => NULL
         );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_asn_exp_dd_intf_rec 50.2:create_asn_con_dd_intf_rec -  RAISE FND_API.G_EXC_ERROR after insert_wlpni;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_exp_dd_intf_rec: 50.3 - After inserting into wlpni for p_lpn_id with parent NULL '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

    l_progress := '60';

    IF l_curs_asn_lpn_content%ISOPEN THEN
      CLOSE l_curs_asn_lpn_content;
    END IF;

    l_progress := '70';

    IF (l_debug = 1) THEN
      print_debug('Exit create_asn_exp_rcpt_intf_rec: 70 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      IF l_curs_serial_number%ISOPEN THEN
        CLOSE l_curs_serial_number;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      IF l_curs_serial_number%ISOPEN THEN
        CLOSE l_curs_serial_number;
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      IF l_curs_serial_number%ISOPEN THEN
        CLOSE l_curs_serial_number;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_asn_exp_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_rcpt_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_asn_exp_rcpt_intf_rec;

  /* FP-J Lot/Serial Support
   * Added a new parameter p_original_rti_id to store the product_transaction_id
   * passed from the UI to split the lots and serials based on RTI quantity
   */
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
  , p_inv_item_id            IN             NUMBER    DEFAULT NULL
  , p_item_desc              IN             VARCHAR2  DEFAULT NULL
  , p_project_id             IN             NUMBER    DEFAULT NULL
  , p_task_id                IN             NUMBER    DEFAULT NULL
  , p_country_code           IN             VARCHAR2  DEFAULT NULL
  , p_rcv_subinventory_code  IN             VARCHAR2  DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_rcv_locator_id         IN             NUMBER    DEFAULT NULL
  , p_original_rti_id        IN             NUMBER    DEFAULT NULL
  --OPM convergence
  , p_secondary_uom          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_uom_code     IN             VARCHAR2 DEFAULT NULL
  , p_secondary_quantity          IN             NUMBER   DEFAULT NULL
 , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  ) IS
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_label_status  VARCHAR2(500);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER                            := 0;

-- For LCM
    l_tx_type       VARCHAR2(40);
-- END FOR LCM

    /* Bug 2200851 */
    /* Changed min to max */
    /* Group BY LPN_ID is changed for Express Receipts */
    /* Also  duplicate print of LPN labels is avoided */
    CURSOR c_rti_txn_id IS
      SELECT   MAX(rti.interface_transaction_id)
          FROM rcv_transactions_interface rti
         WHERE rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      GROUP BY DECODE(p_source_type,
                          'ASNEXP', rti.interface_transaction_id
                        , 'SHIPMENTEXP', rti.interface_transaction_id, NULL);

    -- GROUP BY rti.lpn_id;
    l_debug         NUMBER   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_std_rcpt_intf_rec: 1' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('original_rti_id: ' || p_original_rti_id, 4);
print_debug(p_secondary_uom,1);
print_debug(p_secondary_uom_code,1);
print_debug(p_secondary_quantity,1);
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444210: For performance reason, use the follow query
       --instead of gl_sets_of_books
       SELECT TO_NUMBER(hoi.org_information1)
   INTO inv_rcv_common_apis.g_po_startup_value.sob_id
   FROM hr_organization_information hoi
   WHERE hoi.organization_id = p_organization_id
   AND (hoi.org_information_context || '') = 'Accounting Information';
    END IF;

    l_progress := '15';
    -- first check if the transaction date satisfies the validation.
    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_status
    , x_error_code          => x_message
    );

    IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    x_status := fnd_api.g_ret_sts_success;
    IF p_source_type = 'VENDOR' THEN
      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 2 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      l_progress := '20';
      create_po_rcpt_intf_rec(
        p_move_order_header_id      => p_move_order_header_id
      , p_organization_id           => p_organization_id
      , p_po_header_id              => p_po_header_id
      , p_po_release_number_id      => p_po_release_number_id
      , p_po_line_id                => p_po_line_id
      , p_item_id                   => p_item_id
      , p_location_id               => p_location_id
      , p_rcv_qty                   => p_rcv_qty
      , p_rcv_uom                   => p_rcv_uom
      , p_rcv_uom_code              => p_rcv_uom_code
      , p_source_type               => p_source_type
      , p_lpn_id                    => p_lpn_id
      , p_lot_control_code          => p_lot_control_code
      , p_revision                  => p_revision
      , p_inspect                   => p_inspect
      , x_status                    => l_return_status
      , x_message                   => l_msg_data
      , p_inv_item_id               => p_inv_item_id
      , p_item_desc                 => p_item_desc
      , p_project_id                => p_project_id
      , p_task_id                   => p_task_id
      , p_country_code              => p_country_code
      , p_rcv_subinventory_code     => p_rcv_subinventory_code --RCVLOCATORSSUPPORT
      , p_rcv_locator_id            => p_rcv_locator_id
      , p_original_rti_id           => p_original_rti_id  --Lot/Serial Support
      --OPM convergence
      , p_secondary_uom             => p_secondary_uom
      , p_secondary_uom_code        => p_secondary_uom_code
      , p_secondary_quantity             => p_secondary_quantity
      , p_attribute_category        => p_attribute_category  --Bug #4147209
      , p_attribute1                => p_attribute1
      , p_attribute2                => p_attribute2
      , p_attribute3                => p_attribute3
      , p_attribute4                => p_attribute4
      , p_attribute5                => p_attribute5
      , p_attribute6                => p_attribute6
      , p_attribute7                => p_attribute7
      , p_attribute8                => p_attribute8
      , p_attribute9                => p_attribute9
      , p_attribute10               => p_attribute10
      , p_attribute11               => p_attribute11
      , p_attribute12               => p_attribute12
      , p_attribute13               => p_attribute13
      , p_attribute14               => p_attribute14
      , p_attribute15               => p_attribute15
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 2.1:  create_po_rcpt_intf_rec RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 2.2: create_po_rcpt_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_source_type = 'INTERNAL' THEN
      l_progress := '30';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 3 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_intship_rcpt_intf_rec(
        p_move_order_header_id      => p_move_order_header_id
      , p_organization_id           => p_organization_id
      , p_shipment_header_id        => p_shipment_header_id
      , p_req_header_id             => p_req_header_id
      , p_item_id                   => p_item_id
      , p_location_id               => p_location_id
      , p_rcv_qty                   => p_rcv_qty
      , p_rcv_uom                   => p_rcv_uom
      , p_rcv_uom_code              => p_rcv_uom_code
      , p_source_type               => p_source_type
      , p_from_lpn_id               => p_from_lpn_id
      , p_lpn_id                    => p_lpn_id
      , p_lot_control_code          => p_lot_control_code
      , p_revision                  => p_revision
      , p_inspect                   => p_inspect
      , x_status                    => l_return_status
      , x_message                   => l_msg_data
      , p_project_id                => p_project_id
      , p_task_id                   => p_task_id
      , p_country_code              => p_country_code
      , p_rcv_subinventory_code     => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
      , p_rcv_locator_id            => p_rcv_locator_id
      , p_original_rti_id           => p_original_rti_id  --Lot/Serial Support
      --OPM convergence
      , p_secondary_uom             => p_secondary_uom
      , p_secondary_uom_code        => p_secondary_uom_code
      , p_secondary_quantity             => p_secondary_quantity
      , p_attribute_category        => p_attribute_category  --Bug #4147209
      , p_attribute1                => p_attribute1
      , p_attribute2                => p_attribute2
      , p_attribute3                => p_attribute3
      , p_attribute4                => p_attribute4
      , p_attribute5                => p_attribute5
      , p_attribute6                => p_attribute6
      , p_attribute7                => p_attribute7
      , p_attribute8                => p_attribute8
      , p_attribute9                => p_attribute9
      , p_attribute10               => p_attribute10
      , p_attribute11               => p_attribute11
      , p_attribute12               => p_attribute12
      , p_attribute13               => p_attribute13
      , p_attribute14               => p_attribute14
      , p_attribute15               => p_attribute15
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 3.1:  create_intship_rcpt_intf_rec RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 3.2: create_intship_rcpt_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_source_type = 'CUSTOMER' THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 4 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_rma_rcpt_intf_rec(
        p_move_order_header_id      => p_move_order_header_id
      , p_organization_id           => p_organization_id
      , p_oe_order_header_id        => p_oe_order_header_id
      , p_item_id                   => p_item_id
      , p_location_id               => p_location_id
      , p_rcv_qty                   => p_rcv_qty
      , p_rcv_uom                   => p_rcv_uom
      , p_rcv_uom_code              => p_rcv_uom_code
      , p_source_type               => p_source_type
      , p_lpn_id                    => p_lpn_id
      , p_lot_control_code          => p_lot_control_code
      , p_revision                  => p_revision
      , p_inspect                   => p_inspect
      , x_status                    => l_return_status
      , x_message                   => l_msg_data
      , p_project_id                => p_project_id
      , p_task_id                   => p_task_id
      , p_country_code              => p_country_code
      , p_rcv_subinventory_code     => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
      , p_rcv_locator_id            => p_rcv_locator_id
      , p_original_rti_id           => p_original_rti_id  --Lot/Serial Support
      --OPM convergence
      , p_secondary_uom             => p_secondary_uom
      , p_secondary_uom_code        => p_secondary_uom_code
      , p_secondary_quantity             => p_secondary_quantity
      , p_attribute_category        => p_attribute_category  --Bug #4147209
      , p_attribute1                => p_attribute1
      , p_attribute2                => p_attribute2
      , p_attribute3                => p_attribute3
      , p_attribute4                => p_attribute4
      , p_attribute5                => p_attribute5
      , p_attribute6                => p_attribute6
      , p_attribute7                => p_attribute7
      , p_attribute8                => p_attribute8
      , p_attribute9                => p_attribute9
      , p_attribute10               => p_attribute10
      , p_attribute11               => p_attribute11
      , p_attribute12               => p_attribute12
      , p_attribute13               => p_attribute13
      , p_attribute14               => p_attribute14
      , p_attribute15               => p_attribute15
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 4.1: create_rma_rcpt_intf_rec  RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 4.2: create_rma_rcpt_intf_rec  FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_source_type = 'ASNEXP'
          OR p_source_type = 'SHIPMENTEXP'
          OR p_source_type = 'SHIPMENT'
          OR p_source_type = 'REQEXP' THEN
      IF p_source_type = 'ASNEXP' THEN
        l_progress := '50';

        IF (l_debug = 1) THEN
          print_debug(
            'create_std_rcpt_intf_rec: 5 - calling  create_asn_exp_rcpt_intf_rec for ASN' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 1
          );
        END IF;

        create_asn_exp_rcpt_intf_rec(
          p_move_order_header_id     => p_move_order_header_id
        , p_organization_id          => p_organization_id
        , p_shipment_header_id       => p_shipment_header_id
        , p_po_header_id             => p_po_header_id
        , p_location_id              => p_location_id
        , p_source_type              => 'ASN'
        , p_lpn_id                   => p_from_lpn_id
        , p_inspect                  => p_inspect
        , x_status                   => l_return_status
        , x_message                  => l_msg_data
        , p_project_id               => p_project_id
        , p_task_id                  => p_task_id
        , p_rcv_subinventory_code    => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
        , p_rcv_locator_id           => p_rcv_locator_id
        , p_attribute_category        => p_attribute_category  --Bug #4147209
        , p_attribute1                => p_attribute1
        , p_attribute2                => p_attribute2
        , p_attribute3                => p_attribute3
        , p_attribute4                => p_attribute4
        , p_attribute5                => p_attribute5
        , p_attribute6                => p_attribute6
        , p_attribute7                => p_attribute7
        , p_attribute8                => p_attribute8
        , p_attribute9                => p_attribute9
        , p_attribute10               => p_attribute10
        , p_attribute11               => p_attribute11
        , p_attribute12               => p_attribute12
        , p_attribute13               => p_attribute13
        , p_attribute14               => p_attribute14
        , p_attribute15               => p_attribute15
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_std_rcpt_intf_rec 5.1: create_asn_exp_rcpt_intf_rec  RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_std_rcpt_intf_rec 5.2: create_asn_exp_rcpt_intf_rec  FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_progress := '50';

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec: 6 - calling  create_asn_exp_rcpt_intf_rec for intransit shipment'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 1
          );
        END IF;

        create_asn_exp_rcpt_intf_rec(
          p_move_order_header_id     => p_move_order_header_id
        , p_organization_id          => p_organization_id
        , p_shipment_header_id       => p_shipment_header_id
        , p_po_header_id             => p_po_header_id
        , p_location_id              => p_location_id
        , p_source_type              => 'INTERNAL'
        , p_lpn_id                   => p_from_lpn_id
        , p_inspect                  => p_inspect
        , x_status                   => l_return_status
        , x_message                  => l_msg_data
        , p_project_id               => p_project_id
        , p_task_id                  => p_task_id
        , p_rcv_subinventory_code    => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
        , p_rcv_locator_id           => p_rcv_locator_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_std_rcpt_intf_rec 6.1: create_asn_exp_rcpt_intf_rec for IntShip RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_std_rcpt_intf_rec 6.2: create_asn_exp_rcpt_intf_rec for IntShip RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

-- For Bug 7440217 added LCMCONFM also
    ELSIF p_source_type IN ('ASNCONFM', 'LCMCONFM') THEN
-- End for Bug 7440217

      l_progress := '60';

-- For Bug 7440217 added code to handle LCM Doc also
      IF p_source_type = 'ASNCONFM' THEN
           l_tx_type := 'ASN';
      ELSIF p_source_type = 'LCMCONFM' THEN
           l_tx_type := 'LCM';
      END IF;
-- End for Bug 7440217

      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 7  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_asn_con_rcpt_intf_rec(
        p_move_order_header_id      => p_move_order_header_id
      , p_organization_id           => p_organization_id
      , p_shipment_header_id        => p_shipment_header_id
      , p_po_header_id              => p_po_header_id
      , p_item_id                   => p_item_id
      , p_location_id               => p_location_id
      , p_rcv_qty                   => p_rcv_qty
      , p_rcv_uom                   => p_rcv_uom
      , p_rcv_uom_code              => p_rcv_uom_code
-- For Bug 7440217 Modified code to handle LCM Doc also
      , p_source_type               => l_tx_type
-- End for Bug 7440217
      , p_from_lpn_id               => p_from_lpn_id
      , p_lpn_id                    => p_lpn_id
      , p_lot_control_code          => p_lot_control_code
      , p_revision                  => p_revision
      , p_inspect                   => p_inspect
      , x_status                    => l_return_status
      , x_message                   => l_msg_data
      , p_item_desc                 => p_item_desc
      , p_project_id                => p_project_id
      , p_task_id                   => p_task_id
      , p_country_code              => p_country_code
      , p_rcv_subinventory_code     => p_rcv_subinventory_code -- RCVLOCATORSSUPPORT
      , p_rcv_locator_id            => p_rcv_locator_id
      , p_original_rti_id           => p_original_rti_id  --Lot/Serial Support
   /*   --OPM convergence
      , p_secondary_uom             => p_secondary_uom
      , p_secondary_uom_code        => p_secondary_uom_code
      , p_secondary_quantity             => p_secondary_quantity */
      , p_attribute_category        => p_attribute_category  --Bug #4147209
      , p_attribute1                => p_attribute1
      , p_attribute2                => p_attribute2
      , p_attribute3                => p_attribute3
      , p_attribute4                => p_attribute4
      , p_attribute5                => p_attribute5
      , p_attribute6                => p_attribute6
      , p_attribute7                => p_attribute7
      , p_attribute8                => p_attribute8
      , p_attribute9                => p_attribute9
      , p_attribute10               => p_attribute10
      , p_attribute11               => p_attribute11
      , p_attribute12               => p_attribute12
      , p_attribute13               => p_attribute13
      , p_attribute14               => p_attribute14
      , p_attribute15               => p_attribute15
      , p_express_transaction       => NULL--Bug 5550783
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_ASNCON_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 7.1: create_asn_con_rcpt_intf_rec RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_std_rcpt_intf_rec 7.2: create_asn_con_rcpt_intf_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('create_std_rcpt_intf_rec: 8 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '70';
    x_status := l_return_status; -- l_return_status can be 'W', we want to carry that over

                                 -- calling label printing API

    IF l_return_status <> fnd_api.g_ret_sts_error THEN
      l_progress := '80';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 8.1 before  inv_label.print_label ', 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po) OR
          (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j))  THEN
        IF (p_source_type <> 'VENDOR') THEN    --bug 3630412 for normal PO receipt moved the code to rcv_insert_update_header
        l_counter := 1;
        OPEN c_rti_txn_id;

        LOOP
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;

          IF (l_debug = 1) THEN
            print_debug('create_std_rcpt_intf_rec calling printing for:' || l_txn_id_tbl(l_counter)||'p_source_type'||p_source_type, 4);
          END IF;

          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;

        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 1
        , p_transaction_id         => l_txn_id_tbl
        );

        IF (l_debug = 1) THEN
          print_debug('create_std_rcpt_intf_rec: 8.15 after inv_label.print_label ', 4);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_status := 'W';

          IF (l_debug = 1) THEN
            print_debug('create_std_rcpt_intf_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
         END IF;
  END IF; --bug3630412
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF check INV J and PO J installed
    END IF;

    l_progress := '90';

    IF (l_debug = 1) THEN
      print_debug('create_std_rcpt_intf_rec exitting: 9' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      IF c_rti_txn_id%ISOPEN THEN
        CLOSE c_rti_txn_id;
      END IF;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      IF c_rti_txn_id%ISOPEN THEN
        CLOSE c_rti_txn_id;
      END IF;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      IF c_rti_txn_id%ISOPEN THEN
        CLOSE c_rti_txn_id;
      END IF;
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_std_rcpt_intf_rec', l_progress, SQLCODE);
      END IF;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);
  END create_std_rcpt_intf_rec;

  PROCEDURE create_mo_for_correction(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_po_line_location_id   IN             NUMBER   DEFAULT NULL
  , p_po_distribution_id    IN             NUMBER   DEFAULT NULL
  , p_shipment_line_id      IN             NUMBER   DEFAULT NULL
  , p_oe_order_line_id      IN             NUMBER   DEFAULT NULL
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
  , p_transfer_org_id       IN             NUMBER   DEFAULT NULL
  , p_wms_process_flag      IN             NUMBER   DEFAULT NULL
  , p_secondary_qty         IN             NUMBER  DEFAULT NULL --OPM Convergence
  , p_secondary_uom         IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  ) IS
    l_dummy     VARCHAR2(5);
    l_object_id NUMBER;
    l_msg_count NUMBER;

    CURSOR c_mlt IS
      SELECT lot_number
           , transaction_quantity
           , primary_quantity   -- 3648908
           , lot_expiration_date
           , transaction_temp_id
           , secondary_quantity --OPM Convergence
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_txn_source_id
      UNION ALL
      SELECT mtln.lot_number
           , mtln.transaction_quantity
           , mtln.primary_quantity
           , TO_DATE(NULL)
           , TO_NUMBER(NULL)
           , mtln.secondary_transaction_quantity --OPM Convergence
        FROM mtl_material_transactions mmt
           , mtl_transaction_lot_numbers mtln
           , rcv_transactions rt
           , rcv_shipment_lines rsl
           , mtl_system_items msi
       WHERE rt.interface_transaction_id = p_txn_source_id
         AND mmt.rcv_transaction_id = rt.transaction_id
         AND mmt.transaction_id = mtln.transaction_id
         AND(rt.transaction_type = 'RETURN TO RECEIVING'
             OR(rt.transaction_type = 'CORRECT'
                AND rt.quantity < 0))
         AND msi.lot_control_code = 2
         AND EXISTS(SELECT 1
                      FROM rcv_transactions rt1
                     WHERE rt1.transaction_id = rt.parent_transaction_id
                       AND rt1.transaction_type = 'DELIVER')
         AND rt.user_entered_flag = 'Y'
         AND rsl.shipment_line_id = rt.shipment_line_id
         AND msi.inventory_item_id = rsl.item_id
         AND msi.organization_id = rt.organization_id;

    /*******************************************************************************
     * Bug # : 1922526
     * Description:
     * Cursor c_mlt in procedure
     * create_mo_for_correction is modified
     * so that it selects the lot and qty
     * from mtln instead of mtlt, if the txn
     * is post-inv txn processing, because
     * mtlt records will not exist post-inv
     * txn processing.
     ******************************************************************************/
    l_debug     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_line_id NUMBER;
  BEGIN
    IF p_lot_control_code = 2 THEN
      g_rcpt_lot_qty_rec_tb.DELETE;

      IF (l_debug = 1) THEN
        print_debug('Opening Lots loop ', 1);
      END IF;

      FOR i IN c_mlt LOOP
        IF (l_debug = 1) THEN
          print_debug('Checking if ' || i.lot_number || ' exists', 1);
        END IF;

        /* Before creating move orders, lot numbers should exist in
        ** mtl_lot_numbers. So, insert the lot number from
        ** mtl_transactions_lot_temp into mtl_lot_numbers
        ** by calling API INV_LOT_API_PUB.insertLot.
        ** This API takes care of populating attributes also.
        */
        BEGIN
          SELECT '1'
            INTO l_dummy
            FROM mtl_lot_numbers
           WHERE lot_number = i.lot_number
             AND inventory_item_id = p_item_id
       AND organization_id   = p_org_id;  --Added bug3466942

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
              print_debug('Lot insertion ' || i.lot_number, 1);
            END IF;

            inv_lot_api_pub.insertlot(
              p_api_version                  => 1.0
            , p_init_msg_list                => fnd_api.g_false
            , p_commit                       => fnd_api.g_false
            , p_validation_level             => fnd_api.g_valid_level_full
            , p_inventory_item_id            => p_item_id
            , p_organization_id              => p_org_id
            , p_lot_number                   => i.lot_number
            , p_expiration_date              => i.lot_expiration_date
            , p_transaction_temp_id          => i.transaction_temp_id
            , p_transaction_action_id        => NULL
            , p_transfer_organization_id     => NULL
            , x_object_id                    => l_object_id
            , x_return_status                => x_status
            , x_msg_count                    => l_msg_count
            , x_msg_data                     => x_message
            );

            IF x_status <> fnd_api.g_ret_sts_success THEN
              IF (l_debug = 1) THEN
                print_debug('maintain move order - unable to insert lot ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
              END IF;

              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              print_debug('Lot inserted ', 1);
            END IF;
        END;

         IF (l_debug = 1) THEN
            print_debug('p_primary_qty : '|| i.primary_quantity || ' txn_uom : '|| p_uom_code, 1);
         END IF;

        populate_lot_rec(
          p_lot_number       => i.lot_number
        , p_primary_qty      => ABS(i.primary_quantity)
        , p_txn_uom_code     => p_uom_code
        , p_org_id           => p_org_id
        , p_item_id          => p_item_id
        , p_secondary_quantity => i.secondary_quantity --OPM Convergence
        );
      END LOOP;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Calling create_move_order ', 1);
    END IF;

    create_move_order(
      p_move_order_header_id     => p_move_order_header_id
    , p_po_line_location_id      => p_po_line_location_id
    , p_po_distribution_id       => p_po_distribution_id
    , p_shipment_line_id         => p_shipment_line_id
    , p_oe_order_line_id         => p_oe_order_line_id
    , p_routing                  => p_routing
    , p_lot_control_code         => p_lot_control_code
    , p_org_id                   => p_org_id
    , p_item_id                  => p_item_id
    , p_qty                      => p_qty
    , p_uom_code                 => p_uom_code
    , p_lpn                      => p_lpn
    , p_project_id               => NULL
    , p_task_id                  => NULL
    , p_revision                 => p_revision
    , p_inspect                  => p_inspect
    , p_txn_source_id            => p_txn_source_id
    , x_status                   => x_status
    , x_message                  => x_message
    , p_transfer_org_id          => p_transfer_org_id
    , p_wms_process_flag         => p_wms_process_flag
    , p_secondary_quantity       => p_secondary_qty --OPM Convergence
    , p_secondary_uom            => p_secondary_uom --OPM Convergence
    , x_line_id                  => l_line_id
    );
    g_rcpt_lot_qty_rec_tb.DELETE;
  END create_mo_for_correction;


-- For LCM Project  BUG 7702666
PROCEDURE lcm_call_rcv_rtp(
    p_lcmOrgID                IN             NUMBER
  , p_lcmReceiptNum           IN             VARCHAR2
  , x_lcmvalid_status         OUT NOCOPY     VARCHAR2
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  ) IS

   v_processing_status_code  varchar2(10);

  BEGIN

  SELECT  PROCESSING_STATUS_CODE
  INTO    v_processing_status_code
  FROM    RCV_TRANSACTIONS_INTERFACE
  WHERE   HEADER_INTERFACE_ID in
      (SELECT HEADER_INTERFACE_ID
       FROM   RCV_HEADERS_INTERFACE
       WHERE  receipt_num = p_lcmReceiptNum
       AND   SHIP_TO_ORGANIZATION_ID = p_lcmOrgID)
  AND     ROWNUM < 2;

   IF nvl(v_processing_status_code, '@@@') = 'LC_PENDING' THEN
         x_lcmvalid_status := 'true';
         x_return_status := '';
         x_msg_data := '';
   ELSE
         x_lcmvalid_status := 'false';
         x_return_status := '';
         x_msg_data := '';
   END IF;
END lcm_call_rcv_rtp;
-- For LCM Project  BUG 7702666


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
  , p_project_id            IN             NUMBER   DEFAULT NULL
  , p_task_id               IN             NUMBER   DEFAULT NULL
  , p_revision              IN             VARCHAR2 DEFAULT NULL
  , p_inspect               IN             NUMBER
  , p_txn_source_id         IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_transfer_org_id       IN             NUMBER   DEFAULT NULL
  , p_wms_process_flag      IN             NUMBER   DEFAULT NULL
  , p_lot_number            IN             VARCHAR2     DEFAULT NULL
  , p_secondary_quantity    IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom         IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  , x_line_id               OUT NOCOPY     NUMBER
    ) IS
    l_project_id          NUMBER     := '';
    l_task_id             NUMBER     := '';
    l_lot_qty_rec_tb      rcpt_lot_qty_rec_tb_tp;
    l_line_id             NUMBER;
    l_reference           VARCHAR2(2000);
    l_reference_type_code NUMBER;
    l_reference_id        NUMBER;
    l_count               NUMBER;
    l_from_cost_group_id  NUMBER;
    l_return_status       VARCHAR2(1):= fnd_api.g_ret_sts_success;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(4000);
    l_progress            VARCHAR2(10);
    l_wms_process_flag    NUMBER     := 2;
    l_debug               NUMBER     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --Added for bug #3989521
    l_po_line_location_id NUMBER := NULL;
    l_po_distribution_id  NUMBER := NULL;
    l_is_asn              VARCHAR2(1);
    l_is_req              VARCHAR2(1) := 'N'; -- Bug 5460505
    l_source_document_code  rcv_shipment_lines.source_document_code%TYPE;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_move_order: 1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF p_project_id <> -9999 THEN
      l_project_id := p_project_id;
      l_task_id := p_task_id;
    END IF;

    SAVEPOINT rcv_crt_mo_sp;

    IF p_wms_process_flag IS NOT NULL THEN
      l_wms_process_flag := p_wms_process_flag;
    END IF;

    --R12: If Shipment_line_id is passed, first checked if it is an ASN
    --If it is ASN, then REFERENCE should be SHIPMENT_LINE_ID.  If not,
    --Reference should be PO_LINE_LOCATION_ID
    IF (p_shipment_line_id IS NOT NULL) THEN
       BEGIN
	  SELECT rsl.po_line_location_id,rsl.po_distribution_id,
	    decode(rsh.asn_type,'ASN','Y','N'),Decode(rsh.receipt_source_code,'INTERNAL ORDER','Y','N')
          INTO l_po_line_location_id,l_po_distribution_id,l_is_asn,l_is_req
          FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh
	  WHERE rsl.shipment_line_id = p_shipment_line_id
	  AND   rsl.shipment_header_id = rsh.shipment_header_id;
       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug( 'create_move_order 4.1: RAISE FND_API.G_EXC_ERROR - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS') , 4 );
	     END IF;
	     RAISE fnd_api.g_exc_error;
       END;

       print_debug( 'create_move_order 4.2 : PLL ID : '||l_po_line_location_id ||
		    '  POD ID : ' || l_po_distribution_id ||
		    '  IS ASN?: ' || l_is_asn,4);

    END IF;

    IF (p_po_line_location_id IS NOT NULL AND l_is_asn = 'N') THEN
      IF (l_debug = 1) THEN
        print_debug('create_move_order: 2 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF p_project_id IS NULL THEN
        get_project_task(
          p_po_line_location_id     => p_po_line_location_id
        , p_oe_order_line_id        => NULL
        , x_project_id              => l_project_id
        , x_task_id                 => l_task_id
        );
      END IF;

      l_reference_id := p_po_line_location_id;
      l_reference := 'PO_LINE_LOCATION_ID';
      l_reference_type_code := 4; -- for purchase orders

      IF (l_debug = 1) THEN
        print_debug('create_move_order: 3 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;
    ELSIF p_po_distribution_id IS NOT NULL THEN
      --    l_project_id := p_project_id;
      --    l_task_id := p_task_id;
      l_reference_id := p_po_distribution_id;
      l_reference := 'PO_DISTRIBUTION_ID';
      l_reference_type_code := 4; -- for purchase orders
    ELSIF p_oe_order_line_id IS NOT NULL AND l_is_req = 'N' THEN
      IF (l_debug = 1) THEN
        print_debug('create_move_order: 5 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_reference_id := p_oe_order_line_id;
      l_reference_type_code := 7; -- for RMA
      get_project_task(
        p_po_line_location_id     => NULL
      , p_oe_order_line_id        => p_oe_order_line_id
      , x_project_id              => l_project_id
      , x_task_id                 => l_task_id
      );

      IF p_routing = 'DIRECT' THEN
        l_reference := 'DIRECT ORDER_LINE_ID';
      ELSE
        l_reference := 'ORDER_LINE_ID';
      END IF;
    ELSIF p_shipment_line_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
        print_debug('create_move_order: 4 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_reference_id := p_shipment_line_id;

    BEGIN
	  SELECT po_line_location_id, po_distribution_id, source_document_code
          INTO l_po_line_location_id, l_po_distribution_id, l_source_document_code
          FROM rcv_shipment_lines
          WHERE shipment_line_id = p_shipment_line_id;
    EXCEPTION
       WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug( 'create_move_order 4.1: RAISE FND_API.G_EXC_ERROR - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS') , 4 );
         END IF;

    END;
    print_debug( 'create_move_order 4.2 : PLL ID : ' || l_po_line_location_id || '  POD ID : ' || l_po_distribution_id || '  p_shipment_line_id ' || p_shipment_line_id || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS') , 4 );

     IF l_po_line_location_id IS NOT NULL OR l_po_distribution_id IS NOT NULL THEN
        l_reference_type_code := 4; --Considering the ASN

     ELSIF l_source_document_code = 'INVENTORY' THEN
        l_reference_type_code := 6;
     ELSE
        l_reference_type_code := 8;
     END IF;
      --End of fix for Bug #3989521

      -- for internal reqs
      --???????????????????????????????? Ans:
      -- how to populate the project and task ids

      IF p_routing = 'DIRECT' THEN
        l_reference := 'DIRECT SHIPMENT_LINE_ID';
      ELSE
        l_reference := 'SHIPMENT_LINE_ID';
      END IF;
    END IF;

    l_progress := '20';

    IF p_lot_control_code = 2 THEN
      IF (l_debug = 1) THEN
        print_debug('create_move_order: 6 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '30';
      --If INV and PO J are installed,
      -- execute the old split logic else just update the local table
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
    (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
   IF (l_debug = 1) THEN
      print_debug('Calling to insert RHI for J code', 4);
   END IF;
   l_lot_qty_rec_tb(1).lot_number := p_lot_number;
   l_lot_qty_rec_tb(1).txn_quantity := p_qty;
       ELSE
   split_qty_for_lot(p_qty, l_lot_qty_rec_tb);
      END IF;
      l_progress := '40';

      FOR i IN 1 .. l_lot_qty_rec_tb.COUNT LOOP
        IF (l_debug = 1) THEN
          print_debug(
            'create_move_order 7: before calling wms_task_dispatch_put_away.create_mo ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        IF p_shipment_line_id IS NOT NULL THEN
     IF p_lpn IS NOT NULL THEN
        BEGIN
     SELECT cost_group_id
       INTO   l_from_cost_group_id
       FROM   wms_lpn_contents wlpnc
       WHERE  organization_id = p_org_id
       AND    parent_lpn_id = p_lpn
       AND    wlpnc.inventory_item_id = p_item_id
       AND    Nvl(wlpnc.lot_number,'@@@') = Nvl(l_lot_qty_rec_tb(i).lot_number,Nvl(wlpnc.lot_number,'@@@'))
       AND    EXISTS(
         SELECT 1
         FROM   cst_cost_group_accounts
         WHERE  organization_id = p_org_id
         AND    cost_group_id = wlpnc.cost_group_id);
        EXCEPTION
     WHEN OTHERS THEN
        l_from_cost_group_id                      := NULL;
        END;
      ELSE
      BEGIN
         SELECT cost_group_id
           INTO l_from_cost_group_id
           FROM rcv_shipment_lines rsl
           WHERE shipment_line_id = p_shipment_line_id
           AND exists (
           SELECT 1
           FROM   cst_cost_group_accounts
           WHERE  organization_id = p_org_id
           AND    cost_group_id = rsl.cost_group_id)
           AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
      l_from_cost_group_id := NULL;
      END;
     END IF;
        END IF;

        IF p_project_id = -9999 THEN
          l_project_id := NULL;
          l_task_id := NULL;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_move_order 7.1 parameters organization -' || p_org_id, 4);
          print_debug('create_move_order 7.1 parameters p_item_id -' || p_item_id, 4);
          print_debug('create_move_order 7.1 parameters txn_quantity -' || l_lot_qty_rec_tb(i).txn_quantity, 4);
          print_debug('create_move_order 7.1 parameters p_uom_code -' || p_uom_code, 4);
          print_debug('create_move_order 7.1 parameters p_lpn -' || p_lpn, 4);
          print_debug('create_move_order 7.1 parameters l_project_id -' || l_project_id, 4);
          print_debug('create_move_order 7.1 parameters l_task_id -' || l_task_id, 4);
          print_debug('create_move_order 7.1 parameters l_reference -' || l_reference, 4);
          print_debug('create_move_order 7.1 parameters l_reference_type_code -' || l_reference_type_code, 4);
          print_debug('create_move_order 7.1 parameters l_reference_id -' || l_reference_id, 4);
          print_debug('create_move_order 7.1 parameters lot_number -' || l_lot_qty_rec_tb(i).lot_number, 4);
          print_debug('create_move_order 7.1 parameters p_revision -' || p_revision, 4);
          print_debug('create_move_order 7.1 parameters p_move_order_header_id -' || p_move_order_header_id, 4);
          print_debug('create_move_order 7.1 parameters p_inspect -' || p_inspect, 4);
          print_debug('create_move_order 7.1 parameters p_txn_source_id -' || p_txn_source_id, 4);
          print_debug('create_move_order 7.1 parameters l_from_cost_group_id -' || l_from_cost_group_id, 4);
          print_debug('create_move_order 7.1 parameters p_transfer_org_id -' || p_transfer_org_id, 4);
        END IF;

        wms_task_dispatch_put_away.create_mo(
          p_org_id                  => p_org_id
        , p_inventory_item_id       => p_item_id
        , p_qty                     => l_lot_qty_rec_tb(i).txn_quantity
        , p_uom                     => p_uom_code
        , p_lpn                     => p_lpn
        , p_project_id              => l_project_id
        , p_task_id                 => l_task_id
        , p_reference               => l_reference
        , p_reference_type_code     => l_reference_type_code
        , p_reference_id            => l_reference_id
        , p_lot_number              => l_lot_qty_rec_tb(i).lot_number
        , p_revision                => p_revision
        , p_header_id               => p_move_order_header_id
        , x_line_id                 => l_line_id
        , x_return_status           => l_return_status
        , x_msg_count               => l_count
        , x_msg_data                => l_msg_data
        , p_inspection_status       => p_inspect
        , p_txn_source_id           => p_txn_source_id
        , p_wms_process_flag        => l_wms_process_flag
        , p_from_cost_group_id      => l_from_cost_group_id
        , p_transfer_org_id         => p_transfer_org_id
        , p_sec_qty                 => p_secondary_quantity --OPM Convergence
        , p_sec_uom                 => p_secondary_uom --OPM Convergence
        );

        IF (l_debug = 1) THEN
          print_debug(
            'create_move_order 7: after calling wms_task_dispatch_put_away.create_mo ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            print_debug(
                 'create_move_order 7.1: wms_task_dispatch_put_away.create_mo RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            print_debug(
                 'create_move_order 7.2: wms_task_dispatch_put_away.create_mo RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      -- Should set wms_process_flag to 2 (do not allocate), then
      -- rcvtp will call rcv_txn_clean_up to update this flag to 1,
      -- if receipt transaction goes through successfully.
      -- We set this flag to 1 right now for testing purpose since
      -- rcvtp is not calling our code yet.
      END LOOP;
    ELSE
      IF (l_debug = 1) THEN
        print_debug('create_move_order 8: before calling wms_task_dispatch_put_away.create_mo '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      IF p_shipment_line_id IS NOT NULL THEN
   IF p_lpn IS NOT NULL THEN
        BEGIN
     SELECT cost_group_id
       INTO   l_from_cost_group_id
       FROM   wms_lpn_contents wlpnc
       WHERE  organization_id = p_org_id
       AND    parent_lpn_id = p_lpn
       AND    wlpnc.inventory_item_id = p_item_id
       AND    EXISTS(
         SELECT 1
         FROM   cst_cost_group_accounts
         WHERE  organization_id = p_org_id
         AND    cost_group_id = wlpnc.cost_group_id);
        EXCEPTION
     WHEN OTHERS THEN
        l_from_cost_group_id                      := NULL;
        END;
    ELSE
      BEGIN
         SELECT cost_group_id
           INTO l_from_cost_group_id
           FROM rcv_shipment_lines rsl
           WHERE shipment_line_id = p_shipment_line_id
           AND exists (
           SELECT 1
           FROM   cst_cost_group_accounts
           WHERE  organization_id = p_org_id
           AND    cost_group_id = rsl.cost_group_id)
           AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
      l_from_cost_group_id := NULL;
      END;
   END IF;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_move_order 8.1 parameters organization -' || p_org_id, 4);
        print_debug('create_move_order 8.1 parameters p_item_id -' || p_item_id, 4);
        print_debug('create_move_order 8.1 parameters p_uom_code -' || p_uom_code, 4);
        print_debug('create_move_order 8.1 parameters p_lpn -' || p_lpn, 4);
        print_debug('create_move_order 8.1 parameters l_project_id -' || l_project_id, 4);
        print_debug('create_move_order 8.1 parameters l_task_id -' || l_task_id, 4);
        print_debug('create_move_order 8.1 parameters l_reference -' || l_reference, 4);
        print_debug('create_move_order 8.1 parameters l_reference_type_code -' || l_reference_type_code, 4);
        print_debug('create_move_order 8.1 parameters l_reference_id -' || l_reference_id, 4);
        print_debug('create_move_order 8.1 parameters p_revision -' || p_revision, 4);
        print_debug('create_move_order 8.1 parameters p_move_order_header_id -' || p_move_order_header_id, 4);
        print_debug('create_move_order 8.1 parameters p_inspect -' || p_inspect, 4);
        print_debug('create_move_order 8.1 parameters p_txn_source_id -' || p_txn_source_id, 4);
        print_debug('create_move_order 8.1 parameters l_from_cost_group_id -' || l_from_cost_group_id, 4);
        print_debug('create_move_order 8.1 parameters p_transfer_org_id -' || p_transfer_org_id, 4);
      END IF;

      wms_task_dispatch_put_away.create_mo(
        p_org_id                  => p_org_id
      , p_inventory_item_id       => p_item_id
      , p_qty                     => p_qty
      , p_uom                     => p_uom_code
      , p_lpn                     => p_lpn
      , p_project_id              => l_project_id
      , p_task_id                 => l_task_id
      , p_reference               => l_reference
      , p_reference_type_code     => l_reference_type_code
      , p_reference_id            => l_reference_id
      , p_lot_number              => NULL
      , p_revision                => p_revision
      , p_header_id               => p_move_order_header_id
      , x_line_id                 => l_line_id
      , x_return_status           => l_return_status
      , x_msg_count               => l_count
      , x_msg_data                => l_msg_data
      , p_inspection_status       => p_inspect
      , p_txn_source_id           => p_txn_source_id
      , p_wms_process_flag        => l_wms_process_flag
      , p_from_cost_group_id      => l_from_cost_group_id
      , p_transfer_org_id         => p_transfer_org_id
      -- Bug #8212440
      , p_sec_qty                 => p_secondary_quantity --OPM Convergence
      , p_sec_uom                 => p_secondary_uom --OPM Convergence
      );

      IF (l_debug = 1) THEN
        print_debug('create_move_order 8: after calling wms_task_dispatch_put_away.create_mo '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug(
               'create_move_order 8.1: wms_task_dispatch_put_away.create_mo RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug(
               'create_move_order 8.2: wms_task_dispatch_put_away.create_mo RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    x_line_id := l_line_id;

    IF (l_debug = 1) THEN
          print_debug(
               'create_move_order returns with success'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_crt_mo_sp;
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_move_order:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_crt_mo_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_move_order: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO rcv_crt_mo_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_move_order', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false
        , p_count => l_msg_count
        , p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_move_order: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_move_order;

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
  ) IS
    l_return_status  VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
    l_progress       VARCHAR2(10);
    l_process_status VARCHAR2(10);
    l_debug          NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('rcv_update_rti_from_header 5:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    BEGIN
      --If INV and PO J are installed,
      -- then query using the group_id as RTI is not stamped with shipment_header_id
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
    (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
   IF (l_debug = 1) THEN
      print_debug('Calling to insert RHI for J code', 4);
   END IF;

   SELECT transaction_status_code
     INTO l_process_status
     FROM rcv_transactions_interface
    WHERE group_id = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      AND ROWNUM = 1;
       ELSE
   SELECT transaction_status_code
     INTO l_process_status
     FROM rcv_transactions_interface
     WHERE shipment_header_id = g_shipment_header_id
     AND ROWNUM < 2;
      END IF;

      IF (l_process_status = 'ERROR') THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name('INV', 'INV_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name('INV', 'INV_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      print_debug('rcv_update_rti_from_header 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    --If INV and PO J are installed,
    -- then query using the group_id as RTI is not stamped with shipment_header_id
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
  (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
       IF (l_debug = 1) THEN
    print_debug('Calling to insert RHI for J code', 4);
       END IF;
       UPDATE rcv_transactions_interface
    SET shipment_num = p_shipment_num
            , freight_carrier_code = p_freight_carrier_code
            , bill_of_lading = p_bill_of_lading
            , packing_slip = p_packing_slip
            , num_of_containers = p_num_of_containers
            , waybill_airbill_num = p_waybill_airbill_num
  WHERE group_id = inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
     ELSE
       UPDATE rcv_transactions_interface
    SET shipment_num = p_shipment_num
            , freight_carrier_code = p_freight_carrier_code
            , bill_of_lading = p_bill_of_lading
            , packing_slip = p_packing_slip
            , num_of_containers = p_num_of_containers
            , waybill_airbill_num = p_waybill_airbill_num
  WHERE shipment_header_id = g_shipment_header_id;
    END IF;
    l_progress := '20';

    IF (l_debug = 1) THEN
      print_debug('rcv_update_rti_from_header 20:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.rcv_update_rti_from_header', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END rcv_update_rti_from_header;

  -- Only called if patchset J or higher from rcv_insert_update_header
  -- This is called instead of rcv_insert_header
  PROCEDURE rcv_insert_header_interface(
    p_organization_id                     NUMBER
  , p_source_type                         VARCHAR2
  , p_receipt_num             OUT NOCOPY  VARCHAR2
  , p_vendor_id                           NUMBER
  , p_vendor_site_id                      NUMBER
  , p_shipment_num                        VARCHAR2
  , p_ship_to_location_id                 NUMBER
  , p_bill_of_lading                      VARCHAR2
  , p_packing_slip                        VARCHAR2
  , p_shipped_date                        DATE
  , p_freight_carrier_code                VARCHAR2
  , p_expected_receipt_date               DATE
  , p_num_of_containers                   NUMBER
  , p_waybill_airbill_num                 VARCHAR2
  , p_comments                            VARCHAR2
  , p_ussgl_transaction_code              VARCHAR2
  , p_government_context                  VARCHAR2
  , p_request_id                          NUMBER
  , p_program_application_id              NUMBER
  , p_program_id                          NUMBER
  , p_program_update_date                 DATE
  , p_customer_id                         NUMBER
  , p_customer_site_id                    NUMBER
  , x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count               OUT NOCOPY  NUMBER
  , x_msg_data                OUT NOCOPY  VARCHAR2
  , p_attribute_category      IN          VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
  , p_attribute1              IN          VARCHAR2  DEFAULT NULL
  , p_attribute2              IN          VARCHAR2  DEFAULT NULL
  , p_attribute3              IN          VARCHAR2  DEFAULT NULL
  , p_attribute4              IN          VARCHAR2  DEFAULT NULL
  , p_attribute5              IN          VARCHAR2  DEFAULT NULL
  , p_attribute6              IN          VARCHAR2  DEFAULT NULL
  , p_attribute7              IN          VARCHAR2  DEFAULT NULL
  , p_attribute8              IN          VARCHAR2  DEFAULT NULL
  , p_attribute9              IN          VARCHAR2  DEFAULT NULL
  , p_attribute10             IN          VARCHAR2  DEFAULT NULL
  , p_attribute11             IN          VARCHAR2  DEFAULT NULL
  , p_attribute12             IN          VARCHAR2  DEFAULT NULL
  , p_attribute13             IN          VARCHAR2  DEFAULT NULL
  , p_attribute14             IN          VARCHAR2  DEFAULT NULL
  , p_attribute15             IN          VARCHAR2  DEFAULT NULL
  ) IS
    l_header        rcv_headers_interface%ROWTYPE;
    l_rowid         VARCHAR2(40);
    l_sysdate       DATE                           := SYSDATE;
    l_return_status VARCHAR2(1)                    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER                         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('rcv_insert_header_interface 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_insert_ship_header_sp;
    l_header.last_update_date := l_sysdate;
    l_header.creation_date := l_sysdate;
    l_header.last_update_login := inv_rcv_common_apis.g_po_startup_value.user_id;
    l_header.created_by := inv_rcv_common_apis.g_po_startup_value.user_id;
    l_header.last_updated_by := inv_rcv_common_apis.g_po_startup_value.user_id;
    -- Bug 3443989 for Internal Requition we have to enter receipt_source_code as INTERNAL ORDER
    -- According to PO

    IF p_source_type = 'CUSTOMER' THEN
      l_header.receipt_source_code := 'CUSTOMER';
    elsif p_source_type = 'INVENTORY' THEN
      l_header.receipt_source_code := 'INVENTORY';
    elsif p_source_type = 'INTERNAL ORDER' THEN
      l_header.receipt_source_code := 'INTERNAL ORDER';
    END IF;

    l_progress := '13';
    l_header.receipt_num := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
    IF l_header.receipt_num IS NULL THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := '15';
    l_header.vendor_id := p_vendor_id;
    l_header.vendor_site_id := p_vendor_site_id;
    l_header.ship_to_organization_id := p_organization_id;
    l_header.shipment_num := p_shipment_num;
    l_header.bill_of_lading := p_bill_of_lading;
    l_header.packing_slip := p_packing_slip;
    l_header.shipped_date := p_shipped_date;
    l_header.freight_carrier_code := p_freight_carrier_code;
    l_header.expected_receipt_date := Nvl(p_expected_receipt_date,l_sysdate);
    l_header.employee_id := inv_rcv_common_apis.g_po_startup_value.employee_id;
    l_header.num_of_containers := p_num_of_containers;
    l_header.waybill_airbill_num := p_waybill_airbill_num;
    l_header.comments := p_comments;
    l_header.usggl_transaction_code := p_ussgl_transaction_code;
    l_header.processing_request_id := p_request_id;
    l_header.customer_id := p_customer_id;
    l_header.customer_site_id := p_customer_site_id;

    --Bug #4147209 - Populate the header record with the DFF attribute category
    --and segment values passed from the mobile UI
    l_header.attribute_category := p_attribute_category;
    l_header.attribute1         := p_attribute1;
    l_header.attribute2         := p_attribute2;
    l_header.attribute3         := p_attribute3;
    l_header.attribute4         := p_attribute4;
    l_header.attribute5         := p_attribute5;
    l_header.attribute6         := p_attribute6;
    l_header.attribute7         := p_attribute7;
    l_header.attribute8         := p_attribute8;
    l_header.attribute9         := p_attribute9;
    l_header.attribute10        := p_attribute10;
    l_header.attribute10        := p_attribute10;
    l_header.attribute11        := p_attribute11;
    l_header.attribute12        := p_attribute12;
    l_header.attribute13        := p_attribute13;
    l_header.attribute14        := p_attribute14;
    l_header.attribute15        := p_attribute15;

    IF (l_debug = 1) THEN
      print_debug('rcv_insert_header_interface 20: before rcv_shipment_headers_pkg.insert_row ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 1);
    END IF;

    l_progress := '20';

    IF g_header_intf_id IS NULL THEN
      SELECT rcv_headers_interface_s.NEXTVAL
        INTO g_header_intf_id
        FROM SYS.DUAL;
    END IF;

    l_progress := '25';

    INSERT INTO rcv_headers_interface
                (
                 header_interface_id
               , group_id
               , processing_status_code
               , transaction_type
               , validation_flag
               , auto_transact_code
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , receipt_source_code
               , vendor_id
               , vendor_site_id
               , ship_to_organization_id
               , shipment_num
               , receipt_num
               , bill_of_lading
               , packing_slip
               , shipped_date
               , freight_carrier_code
               , expected_receipt_date
               , employee_id
               , num_of_containers
               , waybill_airbill_num
               , comments
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , usggl_transaction_code
               , processing_request_id
               , customer_id
               , customer_site_id
                )
         VALUES (
                 g_header_intf_id
               , inv_rcv_common_apis.g_rcv_global_var.interface_group_id
               , 'PENDING' -- processing_status_code
               , 'NEW' -- transaction_type
               , 'Y' -- validation_flag
               , 'RECEIVE' -- auto_transact_code
               , l_header.last_update_date
               , l_header.last_updated_by
               , l_header.creation_date
               , l_header.created_by
               , l_header.last_update_login
               , NVL(l_header.receipt_source_code, 'VENDOR')
               , l_header.vendor_id
               , l_header.vendor_site_id
               , l_header.ship_to_organization_id
               , l_header.shipment_num
               , l_header.receipt_num
               , l_header.bill_of_lading
               , l_header.packing_slip
               , l_header.shipped_date
               , l_header.freight_carrier_code
               , l_header.expected_receipt_date
               , l_header.employee_id
               , l_header.num_of_containers
               , l_header.waybill_airbill_num
               , l_header.comments
               , l_header.attribute_category
               , l_header.attribute1
               , l_header.attribute2
               , l_header.attribute3
               , l_header.attribute4
               , l_header.attribute5
               , l_header.attribute6
               , l_header.attribute7
               , l_header.attribute8
               , l_header.attribute9
               , l_header.attribute10
               , l_header.attribute11
               , l_header.attribute12
               , l_header.attribute13
               , l_header.attribute14
               , l_header.attribute15
               , l_header.usggl_transaction_code
               , l_header.processing_request_id
               , l_header.customer_id
               , l_header.customer_site_id
                );

    l_progress := '30';

    IF (l_debug = 1) THEN
      print_debug('rcv_insert_header_interface 30: after insert_row ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    p_receipt_num := l_header.receipt_num;

    IF (l_debug = 1) THEN
      print_debug('rcv_insert_header_interface 40: before rcv_update_rti_from_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_insert_ship_header_sp;
      x_return_status := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('INV_RCV_STD_RCPT_APIS.rcv_insert_header_interface 50.1:  RAISE FND_API.G_EXC_ERROR;' || l_progress, 4);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_insert_ship_header_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('INV_RCV_STD_RCPT_APIS.rcv_insert_header_interface 50.2:  RAISE FND_API.G_EXC_ERROR;' || l_progress, 4);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_insert_ship_header_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.rcv_insert_header_interface', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END rcv_insert_header_interface;

  PROCEDURE rcv_update_header_interface(
    p_organization_id                     NUMBER
  , p_header_intf_id                      NUMBER
  , p_source_type                         VARCHAR2
  , p_receipt_num                         VARCHAR2
  , p_vendor_id                           NUMBER
  , p_vendor_site_id                      NUMBER
  , p_shipment_num                        VARCHAR2
  , p_ship_to_location_id                 NUMBER
  , p_bill_of_lading                      VARCHAR2
  , p_packing_slip                        VARCHAR2
  , p_shipped_date                        DATE
  , p_freight_carrier_code                VARCHAR2
  , p_expected_receipt_date               DATE
  , p_num_of_containers                   NUMBER
  , p_waybill_airbill_num                 VARCHAR2
  , p_comments                            VARCHAR2
  , p_ussgl_transaction_code              VARCHAR2
  , p_program_request_id                  NUMBER
  , p_customer_id                         NUMBER
  , p_customer_site_id                    NUMBER
  , x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count               OUT NOCOPY  NUMBER
  , x_msg_data                OUT NOCOPY  VARCHAR2
  , p_attribute_category      IN          VARCHAR2  DEFAULT NULL  --Bug #4147209
  , p_attribute1              IN          VARCHAR2  DEFAULT NULL
  , p_attribute2              IN          VARCHAR2  DEFAULT NULL
  , p_attribute3              IN          VARCHAR2  DEFAULT NULL
  , p_attribute4              IN          VARCHAR2  DEFAULT NULL
  , p_attribute5              IN          VARCHAR2  DEFAULT NULL
  , p_attribute6              IN          VARCHAR2  DEFAULT NULL
  , p_attribute7              IN          VARCHAR2  DEFAULT NULL
  , p_attribute8              IN          VARCHAR2  DEFAULT NULL
  , p_attribute9              IN          VARCHAR2  DEFAULT NULL
  , p_attribute10             IN          VARCHAR2  DEFAULT NULL
  , p_attribute11             IN          VARCHAR2  DEFAULT NULL
  , p_attribute12             IN          VARCHAR2  DEFAULT NULL
  , p_attribute13             IN          VARCHAR2  DEFAULT NULL
  , p_attribute14             IN          VARCHAR2  DEFAULT NULL
  , p_attribute15             IN          VARCHAR2  DEFAULT NULL
  ) IS

    l_sysdate       DATE                           := SYSDATE;
    l_return_status VARCHAR2(1)                    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_check_asn     VARCHAR2(25);--Bug 4551595
    l_vendor_site_id NUMBER; --bug9409867

    l_debug         NUMBER                         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- receving api is using row_id in where clause
    -- so query row_id based on shipment_header_id
    IF (l_debug = 1) THEN
      print_debug('rcv_update_header_interface 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_update_ship_header_sp;
    l_progress := '20';

    IF (l_debug = 1) THEN
      print_debug('rcv_update_header_interface 20: before update_row ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4);
    END IF;
    --bug9409867,if vendor_site_id not passed from caller,then we should fetch vendor_site_id from rsh.
    l_vendor_site_id := p_vendor_site_id;
    --bug9588190,for bug9409867 fix,it is only for ASN receipt,it should be owned by source type='VENDOR' .
    if(nvl(l_vendor_site_id,-1)=-1 and p_source_type='VENDOR') then
      SELECT vendor_site_id
      INTO l_vendor_site_id
      FROM rcv_shipment_headers
      WHERE shipment_header_id = g_shipment_header_id;
    end if;
    --bug9409867 end
    l_progress := '40';
    UPDATE rcv_headers_interface
       SET customer_id = Nvl(p_customer_id, customer_id)
         , last_update_date = l_sysdate
         , last_update_login = NVL(inv_rcv_common_apis.g_po_startup_value.user_id, last_update_login)
         , last_updated_by = NVL(inv_rcv_common_apis.g_po_startup_value.user_id, last_updated_by)
         , vendor_id = NVL(p_vendor_id, vendor_id)
         , vendor_site_id = NVL(l_vendor_site_id, vendor_site_id)--bug9409867
         , ship_to_organization_id = NVL(p_organization_id, ship_to_organization_id)
         , receipt_num = NVL(p_receipt_num, receipt_num)
         , bill_of_lading = p_bill_of_lading
         , waybill_airbill_num = Nvl(p_waybill_airbill_num,waybill_airbill_num)--BUG 5111375 (FP of BUG 4500055)
         , packing_slip = p_packing_slip
         , shipped_date = NVL(p_shipped_date, shipped_date)
         , freight_carrier_code = p_freight_carrier_code
         , expected_receipt_date = NVL(p_expected_receipt_date, expected_receipt_date)
         , employee_id = NVL(inv_rcv_common_apis.g_po_startup_value.employee_id, employee_id)
         , num_of_containers = NVL(p_num_of_containers, num_of_containers)
         , comments = p_comments
         , attribute_category = p_attribute_category
         , attribute1 = p_attribute1
         , attribute2 = p_attribute2
         , attribute3 = p_attribute3
         , attribute4 = p_attribute4
         , attribute5 = p_attribute5
         , attribute6 = p_attribute6
         , attribute7 = p_attribute7
         , attribute8 = p_attribute8
         , attribute9 = p_attribute9
         , attribute10 = p_attribute10
         , attribute11 = p_attribute11
         , attribute12 = p_attribute12
         , attribute13 = p_attribute13
         , attribute14 = p_attribute14
         , attribute15 = p_attribute15
     WHERE header_interface_id = p_header_intf_id;

    l_progress := '50';

    IF (l_debug = 1) THEN
      print_debug(
           'rcv_update_header_interface 30: after update_row  before rcv_update_rti_from_header '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    rcv_update_rti_from_header(
      p_shipment_num             => p_shipment_num
    , p_freight_carrier_code     => p_freight_carrier_code
    , p_bill_of_lading           => p_bill_of_lading
    , p_packing_slip             => p_packing_slip
    , p_num_of_containers        => p_num_of_containers
    , p_waybill_airbill_num      => p_waybill_airbill_num
    , x_return_status            => l_return_status
    , x_msg_count                => l_msg_count
    , x_msg_data                 => l_msg_data
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_UPDATE_RTI_FAIL');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
          'rcv_update_header_interface 30.1: rcv_update_rti_from_header RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_UPDATE_RTI_FAIL');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'rcv_update_header_interface 30.2: rcv_update_rti_from_header RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('rcv_update_header_interface 40: after rcv_update_rti_from_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    --BUG 4563411:Added the call to the new procedure to update
    --wms_asn_Details for the item
    BEGIN
       SELECT NVL(ASN_TYPE,'@@@')
	 INTO l_check_asn
	 FROM rcv_shipment_headers
	 WHERE shipment_header_id = g_shipment_header_id;
    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('No RSH found. SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,4);
	  END IF;
	  l_check_asn := '@@@';
    END;

    IF l_check_asn ='ASN' THEN

       IF (l_debug = 1) THEN
	  print_debug('In type ASN before call to new procedure', 4);
	  print_debug('group_id:'||inv_rcv_common_apis.g_rcv_global_var.interface_group_id,4);
       END IF;

       --Calling the procedure
       INV_CR_ASN_DETAILS.update_asn_item_details
	 (p_group_id=>inv_rcv_common_apis.g_rcv_global_var.interface_group_id);

       IF (l_debug = 1) THEN
	  print_debug('In type ASN after call to new procedure.', 4);
	  print_debug('# of WAD updated:'||SQL%rowcount,4);
       END IF;
   END IF;
   --End of fix for Bug 4563411

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_update_ship_header_sp;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_update_ship_header_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_update_ship_header_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.rcv_update_header_interface', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END rcv_update_header_interface;

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
  , p_attribute_category     IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - Added DFF cols
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
  ) IS
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    -- Changes for BUG 3630412
      l_label_status VARCHAR2(500);
      l_txn_id_tbl inv_label.transaction_id_rec_type;
      l_counter NUMBER := 0;
      l_receipt_number VARCHAR2(30);
         CURSOR c_rti_txn_id(p_shipment_header_id NUMBER) IS
         SELECT rti.interface_transaction_id
           FROM rcv_transactions_interface rti
          WHERE rti.shipment_header_id = p_shipment_header_id;
  BEGIN
    l_progress := '10';
    l_receipt_number := p_receipt_num; --bug 3630412
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_shipment_header_id IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('rcv_insert_update_header 10: before calling rcv_insert_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      -- insert RHI else insert RSH
   IF (l_debug = 1) THEN
      print_debug('Calling to insert RHI for J code', 4);
   END IF;
        rcv_insert_header_interface(
            p_organization_id            => p_organization_id
      , p_source_type                => p_source_type
      , p_receipt_num                => p_receipt_num
      , p_vendor_id                  => p_vendor_id
      , p_vendor_site_id             => p_vendor_site_id
      , p_shipment_num               => p_shipment_num
      , p_ship_to_location_id        => p_ship_to_location_id
      , p_bill_of_lading             => p_bill_of_lading
      , p_packing_slip               => p_packing_slip
      , p_shipped_date               => p_shipped_date
      , p_freight_carrier_code       => p_freight_carrier_code
      , p_expected_receipt_date      => p_expected_receipt_date
      , p_num_of_containers          => p_num_of_containers
      , p_waybill_airbill_num        => p_waybill_airbill_num
      , p_comments                   => p_comments
      , p_ussgl_transaction_code     => p_ussgl_transaction_code
      , p_government_context         => p_government_context
      , p_request_id                 => p_request_id
     , p_program_application_id     => p_program_application_id
     , p_program_id                 => p_program_id
     , p_program_update_date        => p_program_update_date
     , p_customer_id                => p_customer_id
     , p_customer_site_id           => p_customer_site_id
     , x_return_status              => l_return_status
     , x_msg_count                  => l_msg_count
     , x_msg_data                   => l_msg_data
          , p_attribute_category         => p_attribute_category  --Bug #4147209
          , p_attribute1                 => p_attribute1
          , p_attribute2                 => p_attribute2
          , p_attribute3                 => p_attribute3
          , p_attribute4                 => p_attribute4
          , p_attribute5                 => p_attribute5
          , p_attribute6                 => p_attribute6
          , p_attribute7                 => p_attribute7
          , p_attribute8                 => p_attribute8
          , p_attribute9                 => p_attribute9
          , p_attribute10                => p_attribute10
          , p_attribute11                => p_attribute11
          , p_attribute12                => p_attribute12
          , p_attribute13                => p_attribute13
          , p_attribute14                => p_attribute14
          , p_attribute15                => p_attribute15
     );

      IF (l_debug = 1) THEN
        print_debug('rcv_insert_update_header 20: after calling rcv_insert_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_INS_SHIP_HDR_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
            'rcv_insert_update_header 20.1: rcv_insert_header RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_INS_SHIP_HDR_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'rcv_insert_update_header 20.2: rcv_insert_header RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- to pass back the shipment header id that was created.

      --The header_interface_id should be passed back to the UI as
      --the ui will always INSERT a rhi ON pageentered which should be always
      --updated ON processtxn FROM rcptInfoPage
   IF (l_debug = 1) THEN
      print_debug('Setting the lpn_group_id and validation_flag for J code', 4);
   END IF;
   p_shipment_header_id := g_header_intf_id;

      l_progress := '20';
    ELSE
      IF (l_debug = 1) THEN
        print_debug('rcv_insert_update_header 30: before calling rcv_update_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      --If INV and PO J are installed,
      -- then update RHI else update RSH
   IF (l_debug = 1) THEN
      print_debug('Calling to insert RHI for J code', 4);
   END IF;
   rcv_update_header_interface
     (
        p_organization_id            => p_organization_id
      , p_header_intf_id             => p_shipment_header_id
      , p_source_type                => p_source_type
      , p_receipt_num                => p_receipt_num
      , p_vendor_id                  => p_vendor_id
      , p_vendor_site_id             => p_vendor_site_id
      , p_shipment_num               => p_shipment_num
      , p_ship_to_location_id        => p_ship_to_location_id
      , p_bill_of_lading             => p_bill_of_lading
      , p_packing_slip               => p_packing_slip
      , p_shipped_date               => p_shipped_date
      , p_freight_carrier_code       => p_freight_carrier_code
      , p_expected_receipt_date      => p_expected_receipt_date
      , p_num_of_containers          => p_num_of_containers
      , p_waybill_airbill_num        => p_waybill_airbill_num
      , p_comments                   => p_comments
      , p_ussgl_transaction_code     => p_ussgl_transaction_code
      , p_program_request_id         => p_request_id
     , p_customer_id                => p_customer_id
     , p_customer_site_id           => p_customer_site_id
     , x_return_status              => l_return_status
     , x_msg_count                  => l_msg_count
     , x_msg_data                   => l_msg_data
          , p_attribute_category         => p_attribute_category  --Bug #4147209
          , p_attribute1                 => p_attribute1
          , p_attribute2                 => p_attribute2
          , p_attribute3                 => p_attribute3
          , p_attribute4                 => p_attribute4
          , p_attribute5                 => p_attribute5
          , p_attribute6                 => p_attribute6
          , p_attribute7                 => p_attribute7
          , p_attribute8                 => p_attribute8
          , p_attribute9                 => p_attribute9
          , p_attribute10                => p_attribute10
          , p_attribute11                => p_attribute11
          , p_attribute12                => p_attribute12
          , p_attribute13                => p_attribute13
          , p_attribute14                => p_attribute14
          , p_attribute15                => p_attribute15
     );

      IF (l_debug = 1) THEN
        print_debug('rcv_insert_update_header 40: after calling rcv_update_header ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_UPD_SHIP_HDR_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
            'rcv_insert_update_header 40.1: rcv_update_header RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_UPD_SHIP_HDR_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'rcv_insert_update_header 40.2: rcv_update_header RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_progress := '30';
    END IF;
    IF (l_debug = 1) THEN
      print_debug('Exit rcv_insert_update_header 50: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.rcv_update_insert_header', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END rcv_insert_update_header;

  PROCEDURE packunpack_container(
    p_api_version             IN             NUMBER
  , p_init_msg_list           IN             VARCHAR2 := fnd_api.g_false
  , p_commit                  IN             VARCHAR2 := fnd_api.g_false
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     NUMBER
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_from_lpn_id             IN             NUMBER   := NULL
  , p_lpn_id                  IN             NUMBER
  , p_content_lpn_id          IN             NUMBER   := NULL
  , p_content_item_id         IN             NUMBER   := NULL
  , p_content_item_desc       IN             VARCHAR2 := NULL
  , p_revision                IN             VARCHAR2 := NULL
  , p_lot_number              IN             VARCHAR2 := NULL
  , p_from_serial_number      IN             VARCHAR2 := NULL
  , p_to_serial_number        IN             VARCHAR2 := NULL
  , p_quantity                IN             NUMBER   := NULL
  , p_uom                     IN             VARCHAR2 := NULL
  , p_organization_id         IN             NUMBER
  , p_subinventory            IN             VARCHAR2 := NULL
  , p_locator_id              IN             NUMBER   := NULL
  , p_enforce_wv_constraints  IN             NUMBER   := 2
  , p_operation               IN             NUMBER
  , p_cost_group_id           IN             NUMBER   := NULL
  , p_source_type_id          IN             NUMBER   := NULL
  , p_source_header_id        IN             NUMBER   := NULL
  , p_source_name             IN             VARCHAR2 := NULL
  , p_source_line_id          IN             NUMBER   := NULL
  , p_source_line_detail_id   IN             NUMBER   := NULL
  , p_homogeneous_container   IN             NUMBER   := 2
  , p_match_locations         IN             NUMBER   := 2
  , p_match_lpn_context       IN             NUMBER   := 2
  , p_match_lot               IN             NUMBER   := 2
  , p_match_cost_groups       IN             NUMBER   := 2
  , p_match_mtl_status        IN             NUMBER   := 2
  ) IS
    l_to_lpn_id     NUMBER;
    l_to_lpn        VARCHAR2(30);
    l_process_id    NUMBER;
    l_lpn_rec       wms_container_pub.lpn;
    l_quantity      NUMBER;
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('PackUnpack_Container 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Parameters passed : 10.1: p_from_lpn_id - ' || p_from_lpn_id, 4);
      print_debug('Parameters passed : 10.2: p_lpn_id - ' || p_lpn_id, 4);
      print_debug('Parameters passed : 10.3: p_content_item_id - ' || p_content_item_id, 4);
      print_debug('Parameters passed : 10.4: p_revision - ' || p_revision, 4);
      print_debug('Parameters passed : 10.5: p_lot_number - ' || p_lot_number, 4);
      print_debug('Parameters passed : 10.6: p_from_serial_number - ' || p_from_serial_number, 4);
      print_debug('Parameters passed : 10.7: p_to_serial_number - ' || p_to_serial_number, 4);
      print_debug('Parameters passed : 10.8: p_organization_id - ' || p_organization_id, 4);
      print_debug('Parameters passed : 10.9: p_quantity - ' || p_quantity, 4);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_pack_unpack_sp;
    /* comment out unpack from LPN and generate dummy LPN code,
    since we are not doing discrepancy check at realy time any more. */

    /*   IF p_from_lpn_id = p_lpn_id
         AND g_dummy_lpn_id IS NULL THEN
          IF (l_debug = 1) THEN
             print_debug('PackUnpack_Container 2: generate dummy LPN '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
          -- generate a dummy lpn
          wms_container_pub.generate_lpn
       (p_api_version  => 1.0,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_organization_id => p_organization_id,
        p_lpn_out => l_to_lpn,
        p_lpn_id_out => l_to_lpn_id,
        p_process_id => l_process_id,
             p_validation_level => FND_API.G_VALID_LEVEL_NONE
            );

          l_progress := '20';

          g_dummy_lpn_id := l_to_lpn_id;

          IF l_return_status = FND_API.g_ret_sts_error THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_GENERATION_FAIL');
        FND_MSG_PUB.ADD;
        IF (l_debug = 1) THEN
           print_debug('PackUnpack_Container 2.1: generate dummy LPN RAISE FND_API.G_EXC_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_GENERATION_FAIL');
        FND_MSG_PUB.ADD;
        IF (l_debug = 1) THEN
           print_debug('PackUnpack_Container 2.2: generate dummy LPN RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
          END IF;



        ELSIF g_dummy_lpn_id IS NOT NULL THEN
          IF (l_debug = 1) THEN
             print_debug('PackUnpack_Container 3: g_dummy_lpn_id = '|| g_dummy_lpn_id || ' ' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
          l_to_lpn_id := g_dummy_lpn_id;
        ELSE
          IF (l_debug = 1) THEN
             print_debug('PackUnpack_Container 4: l_to_lpn_id = '|| l_to_lpn_id || ' ' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
          l_to_lpn_id := p_lpn_id;
       END IF;

    */
    l_to_lpn_id := p_lpn_id;
    l_progress := '30';

    IF (l_debug = 1) THEN
      print_debug(
        'PackUnpack_Container 5: before calling WMS_Container_PUB.PackUnpack_Container ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    IF p_from_serial_number IS NULL THEN
      l_quantity := p_quantity;
    ELSE
      l_quantity := NULL;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('PackUnpack_Container 5.1: qty - ' || l_quantity, 4);
    END IF;

    wms_container_pub.packunpack_container(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_lpn_id                     => l_to_lpn_id
    , p_content_lpn_id             => p_content_lpn_id
    , p_content_item_id            => p_content_item_id
    , p_content_item_desc          => p_content_item_desc
    , p_revision                   => p_revision
    , p_lot_number                 => p_lot_number
    , p_from_serial_number         => p_from_serial_number
    , p_to_serial_number           => p_to_serial_number
    , p_quantity                   => l_quantity
    , p_uom                        => p_uom
    , p_organization_id            => p_organization_id
    , p_subinventory               => p_subinventory
    , p_locator_id                 => p_locator_id
    , p_enforce_wv_constraints     => p_enforce_wv_constraints
    , p_operation                  => p_operation
    , p_cost_group_id              => p_cost_group_id
    , p_source_type_id             => p_source_type_id
    , p_source_header_id           => inv_rcv_common_apis.g_rcv_global_var.interface_group_id
    , p_source_name                => p_source_name
    , p_source_line_id             => p_source_line_id
    , p_source_line_detail_id      => p_source_line_detail_id
    , p_homogeneous_container      => p_homogeneous_container
    , p_match_locations            => p_match_locations
    , p_match_lpn_context          => p_match_lpn_context
    , p_match_lot                  => p_match_lot
    , p_match_cost_groups          => p_match_cost_groups
    , p_match_mtl_status           => p_match_mtl_status
    , p_validation_level           => fnd_api.g_valid_level_none
    , p_concurrent_pack            => 1
/* uncomment after changes to WMSCONTB.pls are complete
    , p_secondary_qty              => p_secondary_qty --OPM Convergence
    , p_secondary_uom              => p_secondary_uom --OPM Convergence */
    );
    l_progress := '40';

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL'); -- cannot pack LPN MSGTBD
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'PackUnpack_Container 5.1: WMS_Container_PUB.PackUnpack_Container RAISE FND_API.G_EXC_ERROR;'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'PackUnpack_Container 5.2: WMS_Container_PUB.PackUnpack_Container FND_API.G_EXC_UNEXPECTED_ERROR;'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
      print_debug(
        'PackUnpack_Container 6: after calling WMS_Container_PUB.PackUnpack_Container ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    /*
    IF l_return_status = fnd_api.g_ret_sts_success
      AND p_from_lpn_id IS NOT NULL
        AND p_from_lpn_id <> 0 THEN
       -- unpack the from lpn

       IF (l_debug = 1) THEN
          print_debug('PackUnpack_Container 7: before calling WMS_Container_PUB.PackUnpack_Container for unpack - lpn_id = ' || p_from_lpn_id ||'  '  || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
       END IF;


       WMS_Container_PUB.PackUnpack_Container
       (p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_commit => p_commit,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_lpn_id => p_from_lpn_id,
        p_content_lpn_id => p_content_lpn_id,
        p_content_item_id => p_content_item_id,
        p_content_item_desc => p_content_item_desc,
        p_revision => p_revision,
        p_lot_number => p_lot_number,
        p_from_serial_number => p_from_serial_number,
        p_to_serial_number => p_to_serial_number,
        p_quantity => l_quantity,
        p_uom => p_uom,
        p_organization_id => p_organization_id,
        p_subinventory => p_subinventory,
        p_locator_id => p_locator_id,
        p_enforce_wv_constraints => p_enforce_wv_constraints,
        p_operation => 2,   -- unpack flag
        p_cost_group_id => p_cost_group_id,
        p_source_type_id => p_source_type_id,
        p_source_header_id => p_source_header_id,
        p_source_name => p_source_name,
        p_source_line_id => p_source_line_id,
        p_source_line_detail_id => p_source_line_detail_id,
        p_homogeneous_container => p_homogeneous_container,
        p_match_locations => p_match_locations,
        p_match_lpn_context => p_match_lpn_context,
        p_match_lot => p_match_lot,
        p_match_cost_groups => p_match_cost_groups,
        p_match_mtl_status => p_match_mtl_status,
             p_validation_level => FND_API.G_VALID_LEVEL_NONE
       );

     l_progress := '50';

     IF (l_debug = 1) THEN
        print_debug('PackUnpack_Container 8: after calling WMS_Container_PUB.PackUnpack_Container x_msg_data = '|| x_msg_data || ' ' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
     END IF;

     IF l_return_status = FND_API.g_ret_sts_error THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_PACK_CONTAINER_FAIL');  -- cannot pack LPN MSGTBD
        FND_MSG_PUB.ADD;
        IF (l_debug = 1) THEN
           print_debug('PackUnpack_Container 8.1: - Unpack - WMS_Container_PUB.PackUnpack_Container RAISE FND_API.G_EXC_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_PACK_CONTAINER_FAIL');
        FND_MSG_PUB.ADD;
        IF (l_debug = 1) THEN
           print_debug('PackUnpack_Container 8.2: - Unpack - WMS_Container_PUB.PackUnpack_Container FND_API.G_EXC_UNEXPECTED_ERROR;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

       END IF;
      */


    /*   move populating global record to process_lot
         -- populate the lot/qty data structure for lot split
         IF (p_lot_number IS NOT NULL AND Nvl(g_prev_lot_number,'@@@') <> p_lot_number) THEN
       IF (l_debug = 1) THEN
          print_debug('PackUnpack_Container 9: before calling populate_lot_rec '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
       END IF;
       g_prev_lot_number := p_lot_number;

       l_progress := '60';

       populate_lot_rec(p_lot_number => p_lot_number,
              p_primary_qty => p_quantity,
              p_txn_uom_code => p_uom,
              p_org_id => p_organization_id,
              p_item_id => p_content_item_id);

       l_progress := '70';


       IF (l_debug = 1) THEN
          print_debug('PackUnpack_Container 10: after calling populate_lot_rec '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
       END IF;
         END IF;

     */
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO rcv_pack_unpack_sp;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_pack_unpack_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_pack_unpack_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_pack_unpack_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.packunpack_container', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END packunpack_container;

  PROCEDURE detect_asn_discrepancy(
    p_shipment_header_id              NUMBER
  , p_lpn_id                          NUMBER
  , p_po_header_id                    NUMBER
  , x_discrepancy_flag    OUT NOCOPY  NUMBER
  , x_return_status       OUT NOCOPY  VARCHAR2
  , x_msg_count           OUT NOCOPY  NUMBER
  , x_msg_data            OUT NOCOPY  VARCHAR2
  ) IS
    CURSOR l_curs_remaining_asn IS --modified for bug 4951745
      SELECT 1
        FROM wms_lpn_contents_v lpnc, wms_license_plate_numbers lpn, rcv_shipment_headers rsh
       WHERE (lpn.source_header_id = rsh.shipment_header_id
              OR lpn.source_name = rsh.shipment_num)
         AND rsh.shipment_header_id = p_shipment_header_id
         AND (p_lpn_id IS NULL OR lpn.lpn_id=p_lpn_id)
         AND lpn.lpn_id = lpnc.parent_lpn_id
         AND(
             lpnc.source_line_id IN(SELECT pola.po_line_id
                                      FROM po_lines_all pola
                                     WHERE (p_po_header_id IS NULL  OR  pola.po_header_id=p_po_header_id)
                                    )
             OR lpnc.source_line_id IS NULL
            );

     --Added for Bug 4951745
     CURSOR l_curs_remaining_asn_has_lpn IS
      SELECT 1
        FROM wms_lpn_contents_v lpnc, wms_license_plate_numbers lpn, rcv_shipment_headers rsh
       WHERE (lpn.source_header_id = rsh.shipment_header_id
              OR lpn.source_name = rsh.shipment_num)
         AND rsh.shipment_header_id = p_shipment_header_id
         AND lpn.lpn_id = p_lpn_id
         AND lpn.lpn_id = lpnc.parent_lpn_id
         AND(
             lpnc.source_line_id IN(SELECT pola.po_line_id
                                      FROM po_lines_all pola
                                     WHERE (p_po_header_id IS NULL  OR  pola.po_header_id=p_po_header_id)
                                    )
             OR lpnc.source_line_id IS NULL
            );

    l_remaining_asn_line NUMBER;
    l_return_status      VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_progress           VARCHAR2(10);
    l_debug              NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter detect_ASN_discrepancy 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_lpn_id ' || p_lpn_id , 1);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_discrepancy_flag := 0;
    l_progress := '10';

    IF p_lpn_id IS NULL THEN
        OPEN l_curs_remaining_asn;
        FETCH l_curs_remaining_asn INTO l_remaining_asn_line;
        l_progress := '20';
       CLOSE l_curs_remaining_asn;
    ELSE
        OPEN  l_curs_remaining_asn_has_lpn;
        FETCH l_curs_remaining_asn_has_lpn INTO l_remaining_asn_line;
        l_progress := '30';
        CLOSE l_curs_remaining_asn_has_lpn;
    END IF;


    IF nvl(l_remaining_asn_line,0) > 0 THEN
      x_discrepancy_flag := 1;
    END IF;


    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug(
           'About exit detect_ASN_discrepancy 20 - x_discrepancy_flag = '
        || x_discrepancy_flag
        || ' '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 1
      );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_curs_remaining_asn%ISOPEN THEN
        CLOSE l_curs_remaining_asn;
      END IF;
      IF l_curs_remaining_asn_has_lpn%ISOPEN THEN
        CLOSE l_curs_remaining_asn_has_lpn;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_insert_ship_header_sp;

      IF l_curs_remaining_asn%ISOPEN THEN
        CLOSE l_curs_remaining_asn;
      END IF;
      IF l_curs_remaining_asn_has_lpn%ISOPEN THEN
        CLOSE l_curs_remaining_asn_has_lpn;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_insert_ship_header_sp;

      IF l_curs_remaining_asn%ISOPEN THEN
        CLOSE l_curs_remaining_asn;
      END IF;
      IF l_curs_remaining_asn_has_lpn%ISOPEN THEN
        CLOSE l_curs_remaining_asn_has_lpn;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.detect_ASN_discrepancy', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END detect_asn_discrepancy;

  PROCEDURE remove_lpn_contents(
    p_lpn_id         IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  , p_routing_id     IN             NUMBER DEFAULT NULL
  ) IS
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('remove_lpn_contents 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_remove_lpn_cont_sp;

    -- delete the contents of the putaway LPN
    DELETE      wms_lpn_contents
          WHERE parent_lpn_id = p_lpn_id;

    -- clear serial numbers table
    UPDATE mtl_serial_numbers
       SET lpn_id = NULL
     WHERE lpn_id = p_lpn_id;

    l_progress := '20';

    -- update LPN context to receiving
    UPDATE wms_license_plate_numbers
       SET lpn_context = 5
     WHERE lpn_id = p_lpn_id;

    l_progress := '30';

    IF (l_debug = 1) THEN
      print_debug('remove_lpn_contents 20:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO rcv_remove_lpn_cont_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.remove_lpn_contents', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END remove_lpn_contents;

  PROCEDURE clear_lpn_for_ship(
    p_organization_id     IN             NUMBER
  , p_shipment_header_id  IN             NUMBER
  , x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  , p_routing_id          IN             NUMBER DEFAULT NULL
  ) IS
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_asn_type      VARCHAR2(10);
    l_lpn_id        NUMBER;
    l_wms_enabled   VARCHAR2(1);

    CURSOR l_curs_lpn_for_ship IS
      SELECT lpn_id
        FROM wms_license_plate_numbers
       WHERE source_name = (SELECT shipment_num
                              FROM rcv_shipment_headers
                             WHERE shipment_header_id = p_shipment_header_id);

    CURSOR l_curs_lpn_for_asn IS
      SELECT lpn_id
        FROM wms_license_plate_numbers
       WHERE source_header_id = p_shipment_header_id;

    l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('clear_LPN_for_ship 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_clear_lpn_cont_sp;

    IF (l_debug = 1) THEN
      print_debug('clear_LPN_for_ship 10.1:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SELECT SUBSTR(asn_type, 1, 3)
      INTO l_asn_type
      FROM rcv_shipment_headers
     WHERE shipment_header_id = p_shipment_header_id;

    IF (l_debug = 1) THEN
      print_debug('clear_LPN_for_ship 10.2 ASN_TYPE =:  ' || l_asn_type, 1);
    END IF;

    SELECT wms_enabled_flag
      INTO l_wms_enabled
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

    IF (l_debug = 1) THEN
      print_debug('clear_LPN_for_ship 10.3 WMS_ENABLED_FLAG : ' || l_wms_enabled, 1);
    END IF;

    IF UPPER(l_asn_type) = 'ASN' THEN
      OPEN l_curs_lpn_for_asn;

      LOOP
        FETCH l_curs_lpn_for_asn INTO l_lpn_id;
        EXIT WHEN l_curs_lpn_for_asn%NOTFOUND;

        IF (l_debug = 1) THEN
          print_debug('clear_LPN_for_ASN 20:  - calling update_lpn_org for:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          print_debug('lpn_id => ' || l_lpn_id, 4);
          print_debug('org_id => ' || p_organization_id, 4);
        END IF;

        l_progress := '20';

        IF (l_wms_enabled = 'Y') THEN --Update lpn org only if the current org is wms enabled
          update_lpn_org(
            p_organization_id     => p_organization_id
          , p_lpn_id              => l_lpn_id
          , x_return_status       => l_return_status
          , x_msg_count           => l_msg_count
          , x_msg_data            => l_msg_data
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              print_debug('clear_LPN_for_ASN 20.1 : update_lpn_org RAISE FND_API.G_EXC_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              print_debug(
                   'clear_LPN_for_ASN 20.2: update_lpn_org RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4
              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('clear_LPN_for_ASN 30:  - calling remove_lpn_contents' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        l_progress := '30';
        remove_lpn_contents(
          p_lpn_id            => l_lpn_id
        , x_return_status     => l_return_status
        , x_msg_count         => l_msg_count
        , x_msg_data          => l_msg_data
        , p_routing_id        => p_routing_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            print_debug(
              'clear_LPN_for_ASN 30.1 : remove_lpn_contents RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            print_debug(
                 'clear_LPN_for_ASN 30.2: remove_lpn_contents RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      CLOSE l_curs_lpn_for_asn;
    ELSE
      OPEN l_curs_lpn_for_ship;

      LOOP
        FETCH l_curs_lpn_for_ship INTO l_lpn_id;
        EXIT WHEN l_curs_lpn_for_ship%NOTFOUND;

        IF (l_debug = 1) THEN
          print_debug('clear_LPN_for_ship 20:  - calling update_lpn_org for:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          print_debug('lpn_id => ' || l_lpn_id, 4);
          print_debug('org_id => ' || p_organization_id, 4);
        END IF;

        l_progress := '20';

        IF (l_wms_enabled = 'Y') THEN --Update lpn org only if the current org is wms enabled
          update_lpn_org(
            p_organization_id     => p_organization_id
          , p_lpn_id              => l_lpn_id
          , x_return_status       => l_return_status
          , x_msg_count           => l_msg_count
          , x_msg_data            => l_msg_data
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              print_debug('clear_LPN_for_ship 20.1 : update_lpn_org RAISE FND_API.G_EXC_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              print_debug(
                   'clear_LPN_for_ship 20.2: update_lpn_org RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4
              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('clear_LPN_for_ship 30:  - calling remove_lpn_contents' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        l_progress := '30';
        remove_lpn_contents(
          p_lpn_id            => l_lpn_id
        , x_return_status     => l_return_status
        , x_msg_count         => l_msg_count
        , x_msg_data          => l_msg_data
        , p_routing_id        => p_routing_id
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            print_debug(
              'clear_LPN_for_ship 30.1 : remove_lpn_contents RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            print_debug(
                 'clear_LPN_for_ship 30.2: remove_lpn_contents RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      CLOSE l_curs_lpn_for_ship;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('clear_LPN_for_ship 20:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO rcv_clear_lpn_cont_sp;

      IF l_curs_lpn_for_ship%ISOPEN THEN
        CLOSE l_curs_lpn_for_ship;
      END IF;

      IF l_curs_lpn_for_asn%ISOPEN THEN
        CLOSE l_curs_lpn_for_asn;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.clear_LPN_for_ship', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END clear_lpn_for_ship;

  -- Check if there are LPNs on this shipment
  -- If theres LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

  PROCEDURE check_lpn_on_shipment(
    p_shipment_number       IN             VARCHAR2
  , p_from_organization_id  IN             NUMBER
  , p_to_organization_id    IN             NUMBER
  , x_lpn_flag              OUT NOCOPY     NUMBER
  , x_return_status         OUT NOCOPY     VARCHAR2
  , x_msg_count             OUT NOCOPY     NUMBER
  , x_msg_data              OUT NOCOPY     VARCHAR2
  ) IS
    l_lpn_count       NUMBER         := 0;
    l_lot_serial_flag NUMBER         := 1;
    l_return_status   VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_progress        VARCHAR2(10);
    l_debug           NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('check_lpn_on_shipment 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_return_status := fnd_api.g_ret_sts_success;
    x_lpn_flag := 0;

      SELECT COUNT(*)
        INTO l_lpn_count
        FROM wms_license_plate_numbers
       WHERE organization_id = p_from_organization_id
         AND lpn_context = 6
         AND source_name = p_shipment_number;

    l_progress := '20';

    /* bug# 2783559
          We dont need to check for incompatible serial/lot/revision codes here,
          but in individual lpns
       IF l_lpn_count > 0 THEN
          -- fix for bug 2403033
          BEGIN
        SELECT 1
          INTO l_lot_serial_flag
          FROM rcv_shipment_lines rsl
             , rcv_shipment_headers rsh
             , mtl_system_items msi1
             , mtl_system_items msi2
         WHERE rsh.shipment_num = p_shipment_number
          AND rsl.shipment_header_id = rsh.shipment_header_id
          AND rsl.item_id = msi1.inventory_item_id
          AND msi1.organization_id = p_from_organization_id
          AND (Nvl(msi1.lot_control_code,1) <> Nvl(msi2.lot_control_code,1)
          OR (Nvl(msi1.serial_number_control_code,1) in (1,6)
              AND Nvl(msi2.serial_number_control_code,1) IN (2,5))
          OR (Nvl(msi1.serial_number_control_code,1) in (2,5)
              AND Nvl(msi2.serial_number_control_code,1) IN (1,6)))
          AND rsl.item_id = msi2.inventory_item_id
          AND msi2.organization_id = rsl.to_organization_id
          AND ROWNUM = 1;
        l_lot_serial_flag := 2;
          EXCEPTION
        WHEN no_data_found THEN
           l_lot_serial_flag := 0;
        WHEN OTHERS THEN
           l_lot_serial_flag := 1;
          END;
          IF l_lot_serial_flag = 0 THEN
        x_lpn_flag := 1;
           ELSIF l_lot_serial_flag = 2 THEN
        x_lpn_flag := 2;
           ELSE
        x_lpn_flag := 0;
          END IF;
       END IF;
    */
    IF l_lpn_count > 0 THEN
      x_lpn_flag := 1;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exit check_lpn_on_shipment 20: l_lpn_count =  ' || l_lpn_count || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 1);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_lpn_flag := 0;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.check_lpn_on_shipment', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END check_lpn_on_shipment;

  PROCEDURE check_lpn_on_asn(
    p_shipment_header_id  IN             VARCHAR2
  , x_lpn_flag            OUT NOCOPY     NUMBER
  , x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  ) IS
    l_lpn_count       NUMBER         := 0;
    l_lot_serial_flag NUMBER         := 1;
    l_return_status   VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_progress        VARCHAR2(10);
    l_debug           NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('check_lpn_on_ASN 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    x_lpn_flag := 0;
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT COUNT(*)
      INTO l_lpn_count
      FROM wms_license_plate_numbers
     WHERE lpn_context = 7
       AND source_header_id = p_shipment_header_id;

    l_progress := '20';

    /* bug# 2783559
       We dont need to check for incompatible serial/lot/revision codes here,
       but in individual lpns

    IF l_lpn_count > 0 THEN
       -- fix for bug 2403033
       BEGIN
     SELECT 1
       INTO l_lot_serial_flag
       FROM rcv_shipment_lines rsl
          , rcv_shipment_headers rsh
          , mtl_system_items msi1
          , mtl_system_items msi2
      WHERE rsh.shipment_header_id = p_shipment_header_id
       AND rsl.shipment_header_id = rsh.shipment_header_id
       AND rsl.item_id = msi1.inventory_item_id
       AND msi1.organization_id = rsl.from_organization_id
       AND (Nvl(msi1.lot_control_code,1) <> Nvl(msi2.lot_control_code,1)
       OR (Nvl(msi1.serial_number_control_code,1) in (1,6)
           AND Nvl(msi2.serial_number_control_code,1) IN (2,5))
       OR (Nvl(msi1.serial_number_control_code,1) in (2,5)
           AND Nvl(msi2.serial_number_control_code,1) IN (1,6)))
       AND rsl.item_id = msi2.inventory_item_id
       AND msi2.organization_id = rsl.to_organization_id
       AND ROWNUM = 1;
     l_lot_serial_flag := 1;
       EXCEPTION
     WHEN no_data_found THEN
        l_lot_serial_flag := 0;
     WHEN OTHERS THEN
        l_lot_serial_flag := 1;
       END;
       IF l_lot_serial_flag = 0 THEN
     x_lpn_flag := 1;
        ELSE
     x_lpn_flag := 0;
       END IF;
    END IF;
    */
    IF l_lpn_count > 0 THEN
      x_lpn_flag := 1;
    ELSE
      x_lpn_flag := 0;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exit check_lpn_on_ASN 20: l_lpn_count =  ' || l_lpn_count || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_lpn_flag := 0;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.check_lpn_on_ASN', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END check_lpn_on_asn;

  -- Express Int Req Receiving
  PROCEDURE check_lpn_on_req(
    p_req_num        IN             VARCHAR2
  , x_lpn_flag       OUT NOCOPY     NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  ) IS
    l_lpn_flag        NUMBER      := 0;
    l_lpn_id          NUMBER      := NULL;
    l_order_header_id NUMBER;
    l_order_line_id   NUMBER;
    l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_progress        VARCHAR2(10);
    l_shipping_org    NUMBER;
    l_lpn_org         NUMBER;
    l_lpn_context     NUMBER;
    l_exit_outer      BOOLEAN     := FALSE;
    CURSOR c_order_lines IS
      SELECT line_id
        FROM oe_order_lines_all
       WHERE header_id = l_order_header_id;

    l_debug           NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- bug 3209246
    CURSOR c_delivery_details(v_order_header_id NUMBER, v_order_line_id NUMBER) IS
      SELECT wdd1.lpn_id
           , wdd1.organization_id
        FROM wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda
     , wsh_delivery_details_ob_grp_v wdd1
       WHERE wdd.source_header_id = v_order_header_id
         AND wdd.source_line_id = v_order_line_id
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wdd1.delivery_detail_id = wda.parent_delivery_detail_id;
  BEGIN
    l_progress := '10';
    SELECT header_id
      INTO l_order_header_id
      FROM oe_order_headers_all
     WHERE orig_sys_document_ref = p_req_num
       AND order_source_id = 10;
    --and    order_type_id    = 1023;

    IF (l_debug = 1) THEN
      print_debug('header_id: ' || TO_CHAR(l_order_header_id), 1);
    END IF;

    OPEN c_order_lines;
    l_progress := '20';

    LOOP
      FETCH c_order_lines INTO l_order_line_id;
      EXIT WHEN c_order_lines%NOTFOUND;
      l_progress := '30';

      /* Exp Int Req */
      IF (l_debug = 1) THEN
        print_debug('line_id: ' || TO_CHAR(l_order_line_id), 1);
      END IF;

      /* Bug #2778747
       * To check if the requisition contains a valid LPN, check for:
       * -> Get the lpn_id and org_id FROM wsh_delivery_details
       * -> If there is an LPN which belongs to the shipping org and the LPN context
       *    is "Resides in Intransit", then set the lpn_flag to 1 to indicate that the
       *    req contains a valid LPN that can be received and break out of the loop
       * -> If the LPN org is different from the shipping org, set the lpn_flag to 0
       *    and check for the next wsh_delivery_detail record.
       * -> If the LPN context is not "Resides in Intransit", i.e., the LPN was not
       *    shipped, set the lpn_flag to 0 and check for the next wsh_delivery_detail record
       */
      BEGIN
        l_exit_outer := FALSE;
        OPEN c_delivery_details(l_order_header_id, l_order_line_id);

        LOOP
          FETCH c_delivery_details INTO l_lpn_id, l_shipping_org;
          EXIT WHEN c_delivery_details%NOTFOUND;
          l_progress := 35;
          IF l_lpn_id IS NOT NULL THEN
            -- Nested LPN changes. Check whether the given LPN has content.
            IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
               OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
               OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
              SELECT organization_id
                   , lpn_context
                INTO l_lpn_org
                   , l_lpn_context
                FROM wms_license_plate_numbers
               WHERE lpn_id = l_lpn_id;
            ELSE
              SELECT organization_id
                   , lpn_context
                INTO l_lpn_org
                   , l_lpn_context
                FROM wms_license_plate_numbers
               WHERE lpn_id = l_lpn_id
                 AND lpn_id IN(SELECT parent_lpn_id
                                 FROM wms_lpn_contents
                                WHERE parent_lpn_id = l_lpn_id);
            END IF;
            IF (l_debug = 1) THEN
              print_debug('lpn_id: ' || TO_CHAR(l_lpn_id), 1);
              print_debug('lpn_org: ' || TO_CHAR(l_lpn_org), 1);
              print_debug('lpn_context: ' || TO_CHAR(l_lpn_context), 1);
            END IF;

            IF l_lpn_org <> l_shipping_org THEN
              l_lpn_flag := 0;

              IF (l_debug = 1) THEN
                print_debug('lpn org and shipping org do not match', 1);
              END IF;
            ELSIF l_lpn_org = l_shipping_org
                  AND l_lpn_context <> 6 THEN
              l_lpn_flag := 0;

              IF (l_debug = 1) THEN
                print_debug('lpn context is not resides in intransit', 1);
              END IF;
            ELSE
              l_lpn_flag := 1;
              l_exit_outer := TRUE;

              IF (l_debug = 1) THEN
                print_debug('Found a valid LPN. Should come out of the loop', 1);
              END IF;

              EXIT;
            END IF;
          END IF;
        END LOOP;

        CLOSE c_delivery_details;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_lpn_flag := 0;

          IF c_delivery_details%ISOPEN THEN
            CLOSE c_delivery_details;
          END IF;
      END;

      IF (l_debug = 1) THEN
        print_debug('lpn_id: ' || TO_CHAR(l_lpn_id), 1);
      END IF;

      IF l_lpn_flag = 1 THEN
        EXIT;
      END IF;

      /* Exp Int Req */
      l_progress := '40';
    END LOOP;

    CLOSE c_order_lines;
    l_progress := '50';
    /* bug 2783559 Dont need to check it here but, in individual lpn
       FOR ASN,Int Req and Int Shipment

    IF l_lpn_flag = 1 THEN

       BEGIN
     SELECT 2
       INTO l_lpn_flag
       FROM po_requisition_headers prh
       , po_requisition_lines prl
       , rcv_shipment_lines rsl
       , mtl_system_items msi1
       , mtl_system_items msi2
       WHERE prh.segment1 = p_req_num
       AND prl.requisition_header_id = prh.requisition_header_id
       AND rsl.requisition_line_id = prl.requisition_line_id
       AND rsl.item_id = msi1.inventory_item_id
       AND msi1.organization_id = rsl.from_organization_id
       AND (Nvl(msi1.lot_control_code,1) <> Nvl(msi2.lot_control_code,1)
       OR (Nvl(msi1.serial_number_control_code,1) in (1,6)
           AND Nvl(msi2.serial_number_control_code,1) IN (2,5))
       OR (Nvl(msi1.serial_number_control_code,1) in (2,5)
           AND Nvl(msi2.serial_number_control_code,1) IN (1,6)))
       AND rsl.item_id = msi2.inventory_item_id
       AND msi2.organization_id = rsl.to_organization_id
       AND ROWNUM = 1;
     l_lpn_flag := 2;
       EXCEPTION
     WHEN no_data_found THEN
        NULL;
       END;
   END IF;
   */
    x_lpn_flag := l_lpn_flag;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_lpn_flag := 0;
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- Nested LPN changes
      -- Close delivery detials cusror if it is open
      IF c_delivery_details%ISOPEN THEN
        CLOSE c_delivery_details;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.check_lpn_on_REQ', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Express Int Req Receiving

  PROCEDURE update_lpn_org(
    p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  , x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  ) IS
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --variables below are added for bug# 2814405
    l_serial_code   NUMBER;
    l_lot_code      NUMBER;
    l_item_id       NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number    VARCHAR2(80);

    CURSOR lpn_lot_items IS
      SELECT distinct inventory_item_id
        FROM wms_lpn_contents
       WHERE lot_number IS NOT NULL
         AND parent_lpn_id = p_lpn_id;

    CURSOR lpn_serial_items IS
      SELECT DISTINCT inventory_item_id
      FROM mtl_serial_numbers
      WHERE lpn_id = p_lpn_id;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter update_LPN_Org 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_update_lpn_org_sp;
    l_progress := '10';

    UPDATE wms_license_plate_numbers
       SET organization_id = p_organization_id
         , subinventory_code = ''
         , locator_id = NULL
     WHERE lpn_id = p_lpn_id;

    l_progress := '20';
    --bug# 2814405 start
    OPEN lpn_lot_items;

    LOOP
      FETCH lpn_lot_items INTO l_item_id;
      EXIT WHEN lpn_lot_items%NOTFOUND;

      BEGIN
        SELECT lot_control_code
          INTO l_lot_code
          FROM mtl_system_items
         WHERE inventory_item_id = l_item_id
           AND organization_id = p_organization_id;

        print_debug('item id ' || l_item_id || ' lot code ' || l_lot_code );

        IF (l_lot_code = 1) THEN
           UPDATE wms_lpn_contents
           SET lot_number = NULL   /* 3835398 */
           WHERE parent_lpn_id = p_lpn_id
     AND   inventory_item_id = l_item_id;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
          print_debug('Failed to get lot control codes ' || l_progress);
      END;
    END LOOP;

    OPEN lpn_serial_items;

    LOOP
      FETCH lpn_serial_items INTO l_item_id;
      EXIT WHEN lpn_serial_items%NOTFOUND;

      BEGIN
        l_progress := '25';

        SELECT serial_number_control_code
          INTO l_serial_code
          FROM mtl_system_items
         WHERE organization_id = p_organization_id
           AND inventory_item_id = l_item_id;

        IF l_serial_code IN(2, 5) THEN
          -- bug 2167174
          UPDATE mtl_serial_numbers
          SET    current_organization_id = p_organization_id
          WHERE  lpn_id = p_lpn_id
    AND    inventory_item_id = l_item_id; /* 3835398 */

  ELSIF (l_serial_code = 1 ) THEN
    UPDATE wms_lpn_contents
    SET    serial_summary_entry = 2
          WHERE  parent_lpn_id = p_lpn_id
    AND    inventory_item_id = l_item_id; /* 3835398 */

        END IF;

        l_progress := '30';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
          print_debug('Failed to get serial control codes ' || l_progress);
      END;
    END LOOP;

    -- bug# 2814405 end;

    UPDATE wms_lpn_contents
       SET organization_id = p_organization_id
     WHERE parent_lpn_id = p_lpn_id;

    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug('Exit update_LPN_Org 10:  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO rcv_update_lpn_org_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.update_LPN_Org', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END update_lpn_org;

--Start of fix for the Bug #4037082
--This procedure will validate the entered lot quantity
--against the shipped lot quantity
PROCEDURE validate_lot_qty(
                             p_lot_number         IN  VARCHAR2
                           , p_inventory_item_id  IN  NUMBER
                           , p_lot_txn_qty        IN  NUMBER
                           , p_lot_primary_qty    IN  NUMBER
                           , p_shipment_header_id IN  NUMBER
                           , p_rcv_org_id         IN  NUMBER
                           , x_return_status      OUT NOCOPY  VARCHAR2
                           )
IS
l_rlsu_quantity            RCV_LOTS_SUPPLY.QUANTITY%TYPE := 0;
l_rlsu_primary_quantity    RCV_LOTS_SUPPLY.PRIMARY_QUANTITY%TYPE := 0;
l_index                    NUMBER := 0;
l_diff_txn_qty             NUMBER := 0;
l_partial_rcpt             NUMBER := 0;
l_rec_count                NUMBER := 0;
l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN

  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty: 10 Entering into Lot Qty Validation Procedure' , 4);
     print_debug('validate_lot_qty: 20 Validating for lot: ' || p_lot_number || ' Item: ' || p_inventory_item_id || ' shipment_hdr_id: '|| p_shipment_header_id  , 4);
     print_debug('validate_lot_qty: 30 txn_qty :' || p_lot_txn_qty || ' p_lot_primary_qty: ' || p_lot_primary_qty || ' p_rcv_org_id: ' || p_rcv_org_id , 4);
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
    SELECT count(1)
      INTO l_partial_rcpt
      FROM dual
     WHERE EXISTS ( SELECT 1
                      FROM rcv_transactions
                     WHERE shipment_header_id = p_shipment_header_id
                       AND organization_id    = p_rcv_org_id
                  );
  EXCEPTION
    WHEN OTHERS THEN
      l_partial_rcpt := 0;
  END;

  IF l_partial_rcpt = 0 THEN
     BEGIN
       SELECT count(1)
       INTO l_partial_rcpt
       FROM dual
      WHERE EXISTS ( SELECT 1
                      FROM rcv_transactions_interface
                     WHERE shipment_header_id  = p_shipment_header_id
                       AND to_organization_id  = p_rcv_org_id
                  );
    EXCEPTION
     WHEN OTHERS THEN
       l_partial_rcpt := 0;
    END;
  END IF;

  IF l_partial_rcpt = 1 THEN
    print_debug('validate_lot_qty: 30.1 Not doing Qty Validation for Partial Receipts..Hence Returning..' , 4);
    RETURN;
  END IF;

  BEGIN

    SELECT NVL(SUM(rlsu.quantity),0) ,
           NVL(SUM(rlsu.primary_quantity),0)
     INTO  l_rlsu_quantity,
           l_rlsu_primary_quantity
     FROM  rcv_lots_supply rlsu,
           rcv_shipment_lines rsl
    WHERE  rlsu.shipment_line_id = rsl.shipment_line_id
      AND  rsl.item_id  = p_inventory_item_id
      AND  rsl.to_organization_id = p_rcv_org_id
      AND  rsl.shipment_header_id = p_shipment_header_id
      AND  rlsu.lot_num = p_lot_number
      AND  rlsu.supply_type_code = 'SHIPMENT' ;
  EXCEPTION
     WHEN OTHERS THEN
       IF (l_debug = 1) THEN
         print_debug('validate_lot_qty: 40  When Others Exception' , 4);
       END IF;
       l_rlsu_quantity := 0 ;
       l_rlsu_primary_quantity := 0 ;
  END;

  IF NVL(p_lot_primary_qty,0) <> 0 AND l_rlsu_primary_quantity <> 0 THEN
    IF p_lot_primary_qty > l_rlsu_primary_quantity THEN
      fnd_message.set_name('INV', 'INV_MAX_QTY');
      fnd_message.set_token('TOKEN', l_rlsu_primary_quantity);
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('validate_lot_qty: 50 Receiving Lot Qty : ' || p_lot_primary_qty || ' cannot be more than Shipped Qty : ' || l_rlsu_primary_quantity , 4);
      END IF;

      --Removing the errored Lot from g_rcpt_lot_qty_rec_tb table
      l_rec_count := g_rcpt_lot_qty_rec_tb.COUNT;

       FOR i IN 1 .. l_rec_count  LOOP
         IF g_rcpt_lot_qty_rec_tb(i).lot_number = p_lot_number THEN
           l_diff_txn_qty := g_rcpt_lot_qty_rec_tb(i).txn_quantity - p_lot_txn_qty ;
           l_index := i;
           EXIT;
         END IF;
       END LOOP;

       IF l_diff_txn_qty = 0 THEN
          IF l_rec_count = 1 THEN
            g_rcpt_lot_qty_rec_tb.DELETE;
          ELSE
            g_rcpt_lot_qty_rec_tb.DELETE(l_index);
          END IF;
       ELSE
         g_rcpt_lot_qty_rec_tb(l_index).txn_quantity := l_diff_txn_qty ;
       END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty: 60  Exitting from Lot Qty Validation Procedure' , 4);
  END IF;

END validate_lot_qty;
--End of fix for the Bug #4037082

 --Added to fix the Bug #4086191
 --overload the procedure created above
 --with one more parameter, p_product_transaction_id
 PROCEDURE validate_lot_qty(
     p_lot_number         IN  VARCHAR2
  ,  p_inventory_item_id  IN  NUMBER
  ,  p_lot_txn_qty        IN  NUMBER
  ,  p_lot_primary_qty    IN  NUMBER
  ,  p_shipment_header_id IN  NUMBER
  ,  p_rcv_org_id         IN  NUMBER
  ,  p_product_txn_id     IN  NUMBER
  ,  x_return_status      OUT NOCOPY  VARCHAR2
  ) IS
     l_rlsu_primary_quantity    RCV_LOTS_SUPPLY.PRIMARY_QUANTITY%TYPE := 0;
     l_mtli_primary_quantity    NUMBER := 0;
     l_current_grp_prim_qty     NUMBER := 0;
     l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

 BEGIN
  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty J: 10 Entering into Lot Qty Validation Procedure' , 4);
     print_debug('validate_lot_qty J: 20 Validating for lot: ' || p_lot_number || ' Item: ' || p_inventory_item_id || ' shipment_hdr_id: '|| p_shipment_header_id  , 4);
     print_debug('validate_lot_qty J: 30 txn_qty :' || p_lot_txn_qty || ' p_lot_primary_qty: ' || p_lot_primary_qty || ' p_rcv_org_id: ' || p_rcv_org_id , 4);
     print_debug('validate_lot_qty J: 31 p_shipment_header_id:' || p_shipment_header_id);
     print_debug('validate_lot_qty J: 31 p_prod_txn_id:' || p_product_txn_id);
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
     SELECT  NVL(SUM(rlsu.primary_quantity),0)
       INTO  l_rlsu_primary_quantity
       FROM  rcv_lots_supply rlsu,
             rcv_shipment_lines rsl
       WHERE rlsu.shipment_line_id = rsl.shipment_line_id
       AND   rsl.item_id  = p_inventory_item_id
       AND   rsl.to_organization_id = p_rcv_org_id
       AND   rsl.shipment_header_id = p_shipment_header_id
       AND   rlsu.lot_num = p_lot_number
       AND   rlsu.supply_type_code = 'SHIPMENT' ;
  EXCEPTION
     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('validate_lot_qty: 31  When Others Exception' , 4);
	END IF;
	l_rlsu_primary_quantity := 0 ;
  END;

  BEGIN
     SELECT   NVL(SUM(mtli.primary_quantity),0)
       INTO   l_mtli_primary_quantity
       FROM   mtl_transaction_lots_interface mtli,
              rcv_transactions_interface rti
       WHERE  rti.processing_status_code <> 'ERROR'
       AND    rti.transaction_status_code <> 'ERROR'
       AND    rti.to_organization_id = p_rcv_org_id
       AND    rti.item_id = p_inventory_item_id
       AND    rti.shipment_header_id = p_shipment_header_id
       AND    rti.interface_transaction_id = mtli.product_transaction_id
       AND    mtli.lot_number = p_lot_number
       AND    mtli.product_code = 'RCV';
  EXCEPTION
     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('validate_lot_qty: 32  When Others Exception' , 4);
	END IF;
	l_mtli_primary_quantity := 0;
  END;

  IF (p_product_txn_id IS NOT NULL) THEN
     BEGIN
	SELECT Nvl(SUM(primary_quantity),0)
	  INTO l_current_grp_prim_qty
	  FROM mtl_transaction_lots_interface
	  WHERE product_transaction_id = p_product_txn_id
	  AND   lot_number = p_lot_number
	  AND   product_code = 'RCV';
     EXCEPTION
	WHEN OTHERS THEN
	   IF (l_debug = 1) THEN
	      print_debug('validate_lot_qty: 32  When Others Exception' , 4);
	   END IF;
	   l_current_grp_prim_qty := 0;
     END;
   ELSE
	   l_current_grp_prim_qty := 0;
  END IF;

  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty: 33 RLS Qty : ' || l_rlsu_primary_quantity,4);
     print_debug('validate_lot_qty: 34 MTLI QTY : ' || l_mtli_primary_quantity,4);
     print_debug('validate_lot_qty: 34 l_current_grp_prim_qty : ' || l_current_grp_prim_qty,4);
  END IF;

  IF  (p_lot_primary_qty > (l_rlsu_primary_quantity - (l_mtli_primary_quantity + l_current_grp_prim_qty) )) THEN
     fnd_message.set_name('INV', 'INV_MAX_QTY');
     fnd_message.set_token('TOKEN', l_rlsu_primary_quantity - (l_mtli_primary_quantity + l_current_grp_prim_qty));
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_error;
     IF (l_debug = 1) THEN
	print_debug('validate_lot_qty: 33 Receiving Lot Qty : ' || p_lot_primary_qty || ' cannot be more than Shipped Qty : ' || l_rlsu_primary_quantity , 4);
     END IF;
   ELSE
     RETURN;
  END IF;

 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_error;
       IF (l_debug = 1) THEN
	  print_debug('validate_lot_qty: Exception occured!  Exiting...', 4);
      END IF;
 END validate_lot_qty;

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
  ) IS
     l_rlsu_primary_quantity    RCV_LOTS_SUPPLY.PRIMARY_QUANTITY%TYPE := 0;
     l_mtli_primary_quantity    NUMBER := 0;
     l_current_grp_prim_qty     NUMBER := 0;
     l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

 BEGIN
  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty J: 10 Entering into Lot Qty Validation Procedure' , 4);
     print_debug('validate_lot_qty J: 20 Validating for lot: ' || p_lot_number || ' Item: ' || p_inventory_item_id || ' shipment_hdr_id: '|| p_shipment_header_id  , 4);
     print_debug('validate_lot_qty J: 30 txn_qty :' || p_lot_txn_qty || ' p_lot_primary_qty: ' || p_lot_primary_qty || ' p_rcv_org_id: ' || p_rcv_org_id , 4);
     print_debug('validate_lot_qty J: 31 p_shipment_header_id:' || p_shipment_header_id);
     print_debug('validate_lot_qty J: 32 p_prod_txn_id:' || p_product_txn_id);
     print_debug('validate_lot_qty J: 33 p_from_lpn_id:' || p_from_lpn_id);
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
     SELECT  NVL(SUM(rlsu.primary_quantity),0)
       INTO  l_rlsu_primary_quantity
       FROM  rcv_lots_supply rlsu,
             rcv_shipment_lines rsl
       WHERE rlsu.shipment_line_id = rsl.shipment_line_id
       AND   rsl.item_id  = p_inventory_item_id
       AND   rsl.to_organization_id = p_rcv_org_id
       AND   rsl.shipment_header_id = p_shipment_header_id
       AND   rlsu.lot_num = p_lot_number
       AND   rlsu.supply_type_code = 'SHIPMENT'
       AND   Nvl(rsl.asn_lpn_id,-1)  = Nvl(decode(p_from_lpn_id,0,NULL,p_from_lpn_id),Nvl(rsl.asn_lpn_id,-1));

     print_debug('validate_lot_qty: 31 l_rlsu_primary_quantity' || l_rlsu_primary_quantity , 4);
  EXCEPTION
     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('validate_lot_qty: 31  When Others Exception' , 4);
	END IF;
	l_rlsu_primary_quantity := 0 ;
  END;

  BEGIN
     SELECT   NVL(SUM(mtli.primary_quantity),0)
       INTO   l_mtli_primary_quantity
       FROM   mtl_transaction_lots_interface mtli,
              rcv_transactions_interface rti
       WHERE  rti.processing_status_code <> 'ERROR'
       AND    rti.transaction_status_code <> 'ERROR'
       AND    rti.to_organization_id = p_rcv_org_id
       AND    rti.item_id = p_inventory_item_id
       AND    rti.shipment_header_id = p_shipment_header_id
       AND    rti.interface_transaction_id = mtli.product_transaction_id
       AND    mtli.lot_number = p_lot_number
       AND    mtli.product_code = 'RCV'
       AND    Nvl(rti.lpn_id,-1)  = Nvl(decode(p_from_lpn_id,0,NULL,p_from_lpn_id),Nvl(rti.lpn_id,-1));
  EXCEPTION
     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('validate_lot_qty: 32  When Others Exception' , 4);
	END IF;
	l_mtli_primary_quantity := 0;
  END;

  IF (p_product_txn_id IS NOT NULL) THEN
     BEGIN
	SELECT Nvl(SUM(primary_quantity),0)
	  INTO l_current_grp_prim_qty
	  FROM mtl_transaction_lots_interface
	  WHERE product_transaction_id = p_product_txn_id
	  AND   lot_number = p_lot_number
	  AND   product_code = 'RCV';
     EXCEPTION
	WHEN OTHERS THEN
	   IF (l_debug = 1) THEN
	      print_debug('validate_lot_qty: 32  When Others Exception' , 4);
	   END IF;
	   l_current_grp_prim_qty := 0;
     END;
   ELSE
	   l_current_grp_prim_qty := 0;
  END IF;

  IF (l_debug = 1) THEN
     print_debug('validate_lot_qty: 33 RLS Qty : ' || l_rlsu_primary_quantity,4);
     print_debug('validate_lot_qty: 34 MTLI QTY : ' || l_mtli_primary_quantity,4);
     print_debug('validate_lot_qty: 34 l_current_grp_prim_qty : ' || l_current_grp_prim_qty,4);
  END IF;

  IF  (p_lot_primary_qty > (l_rlsu_primary_quantity - (l_mtli_primary_quantity + l_current_grp_prim_qty) )) THEN
     fnd_message.set_name('INV', 'INV_MAX_QTY');
     fnd_message.set_token('TOKEN', l_rlsu_primary_quantity - (l_mtli_primary_quantity + l_current_grp_prim_qty));
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_error;
     IF (l_debug = 1) THEN
	print_debug('validate_lot_qty: 33 Receiving Lot Qty : ' || p_lot_primary_qty || ' cannot be more than Shipped Qty : ' || l_rlsu_primary_quantity , 4);
     END IF;
   ELSE
     RETURN;
  END IF;

 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_error;
       IF (l_debug = 1) THEN
	  print_debug('validate_lot_qty: Exception occured!  Exiting...', 4);
      END IF;
 END validate_lot_qty;

END inv_rcv_std_rcpt_apis;

/
