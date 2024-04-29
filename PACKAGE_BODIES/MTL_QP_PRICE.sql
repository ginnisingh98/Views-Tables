--------------------------------------------------------
--  DDL for Package Body MTL_QP_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_QP_PRICE" AS
  /* $Header: INVVICAB.pls 120.5.12010000.6 2009/11/05 12:55:03 adeshmuk ship $ */
  g_pkg_name            CONSTANT VARCHAR2(30)                 := 'MTL_QP_PRICE';

  TYPE pls_integer_type IS TABLE OF PLS_INTEGER
    INDEX BY BINARY_INTEGER;

  TYPE number_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE varchar_type IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;

  TYPE flag_type IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;

  TYPE date_type IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;

  g_line_index_tbl               qp_preq_grp.pls_integer_type;
  g_line_type_code_tbl           qp_preq_grp.varchar_type;
  g_pricing_effective_date_tbl   qp_preq_grp.date_type;
  g_active_date_first_tbl        qp_preq_grp.date_type;
  g_active_date_first_type_tbl   qp_preq_grp.varchar_type;
  g_active_date_second_tbl       qp_preq_grp.date_type;
  g_active_date_second_type_tbl  qp_preq_grp.varchar_type;
  g_line_quantity_tbl            qp_preq_grp.number_type;
  g_line_uom_code_tbl            qp_preq_grp.varchar_type;
  g_request_type_code_tbl        qp_preq_grp.varchar_type;
  g_priced_quantity_tbl          qp_preq_grp.number_type;
  g_uom_quantity_tbl             qp_preq_grp.number_type;
  g_priced_uom_code_tbl          qp_preq_grp.varchar_type;
  g_currency_code_tbl            qp_preq_grp.varchar_type;
  g_unit_price_tbl               qp_preq_grp.number_type;
  g_percent_price_tbl            qp_preq_grp.number_type;
  g_adjusted_unit_price_tbl      qp_preq_grp.number_type;
  g_upd_adjusted_unit_price_tbl  qp_preq_grp.number_type;
  g_processed_flag_tbl           qp_preq_grp.varchar_type;
  g_price_flag_tbl               qp_preq_grp.varchar_type;
  g_line_id_tbl                  qp_preq_grp.number_type;
  g_processing_order_tbl         qp_preq_grp.pls_integer_type;
  g_rounding_factor_tbl          qp_preq_grp.pls_integer_type;
  g_rounding_flag_tbl            qp_preq_grp.flag_type;
  g_qualifiers_exist_flag_tbl    qp_preq_grp.varchar_type;
  g_pricing_attrs_exist_flag_tbl qp_preq_grp.varchar_type;
  g_price_list_id_tbl            qp_preq_grp.number_type;
  g_pl_validated_flag_tbl        qp_preq_grp.varchar_type;
  g_price_request_code_tbl       qp_preq_grp.varchar_type;
  g_usage_pricing_type_tbl       qp_preq_grp.varchar_type;
  g_pricing_status_code_tbl      qp_preq_grp.varchar_type;
  g_pricing_status_text_tbl      qp_preq_grp.varchar_type;
  g_line_category_tbl            qp_preq_grp.varchar_type;
  g_unit_selling_price_tbl       qp_preq_grp.number_type;
  g_unit_list_price_tbl          qp_preq_grp.number_type;
  g_unit_sell_price_per_pqty_tbl qp_preq_grp.number_type;
  g_unit_list_price_per_pqty_tbl qp_preq_grp.number_type;
  g_pricing_quantity_tbl         qp_preq_grp.number_type;
  g_unit_list_percent_tbl        qp_preq_grp.number_type;
  g_unit_percent_base_price_tbl  qp_preq_grp.number_type;
  g_unit_selling_percent_tbl     qp_preq_grp.number_type;

  FUNCTION get_transfer_price(
    p_transaction_id    IN            NUMBER
  , p_sell_ou_id        IN            NUMBER
  , p_ship_ou_id        IN            NUMBER
  , p_order_line_id     IN            NUMBER DEFAULT NULL
  , p_inventory_item_id IN            NUMBER DEFAULT NULL
  , p_organization_id   IN            NUMBER DEFAULT NULL
  , p_uom_code          IN            VARCHAR2 DEFAULT NULL
  , p_cto_item_flag     IN            VARCHAR2 DEFAULT 'N'
  , p_incr_code         IN            NUMBER
  , p_incrcurrency      IN            VARCHAR2
  , p_request_type_code  IN  VARCHAR2 DEFAULT 'IC'   -- OPM INVCONV  umoogala
  , p_pricing_event  IN  VARCHAR2 DEFAULT 'ICBATCH'  -- OPM INVCONV  umoogala
  , x_currency_code     OUT NOCOPY    VARCHAR2
  , x_tfrpricecode      OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  )
    RETURN NUMBER IS
    l_header_id                  NUMBER;
    l_line_id                    NUMBER;
    l_inventory_item_id          NUMBER;
    l_organization_id            NUMBER;
    l_transaction_uom            VARCHAR2(3);
    l_primary_uom                VARCHAR2(3);
    l_control_rec                qp_preq_grp.control_record_type;
    l_pricing_event              VARCHAR2(30)                    DEFAULT 'ICBATCH';
    l_request_type_code          VARCHAR2(30)                    DEFAULT 'IC';
    l_line_index                 NUMBER                          := 0;
    l_return_status_text         VARCHAR2(2000);
    l_version                    VARCHAR2(240);
    l_dir                        VARCHAR2(2000);
    l_tfrprice                   NUMBER;
    l_uom_rate                   NUMBER;
    l_doc_type                   VARCHAR2(4);   /* OPM Bug 2865040 */
    l_debug                      NUMBER                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_order_line_id              NUMBER;
    l_base_item_id               NUMBER;
    l_transaction_source_type_id NUMBER;
    l_transaction_action_id      NUMBER;
  BEGIN
    IF fnd_profile.VALUE('INV_DEBUG_TRACE') = 1 THEN
      IF (l_debug = 1) THEN
        print_debug('Enabling QP debug option...');
      END IF;

      SELECT VALUE
        INTO l_dir
        FROM v$parameter
       WHERE NAME = 'utl_file_dir';

      IF (INSTR(l_dir, ',') > 0) THEN
        l_dir  := SUBSTR(l_dir, 1, INSTR(l_dir, ',') - 1);
      END IF;

      oe_debug_pub.g_dir  := l_dir;
      oe_debug_pub.initialize;
      oe_debug_pub.debug_on;
      oe_debug_pub.setdebuglevel(10);
      oe_debug_pub.ADD('Before Process_Order', 1);

      IF (l_debug = 1) THEN
        print_debug('QP trace file is ' || oe_debug_pub.set_debug_mode('FILE'));
      END IF;

      l_version           := qp_preq_grp.get_version;

      IF (l_debug = 1) THEN
        print_debug('QP Version : ' || l_version);
      END IF;
    ELSE
      oe_debug_pub.debug_off;
    END IF;

    x_return_status                       := fnd_api.g_ret_sts_success;
    x_currency_code                       := ' ';
    x_tfrpricecode                        := 1;
    x_msg_count                           := 0;
    x_msg_data                            := ' ';
    l_tfrprice                            := -1;

    --
    -- OPM INVCONV umoogala  Process-Discrete Transfers Enh.
    -- Will be reusing the code for Internal Orders between Process
    -- and Discrete Orgs.
    -- For these, Request Type Code = INTORG
    --            Pricing Event     = ICBATCH (might change)
    --
    -- We will not be loading IC Parameters for this Request Type Code
    --
    l_request_type_code := p_request_type_code;
    l_pricing_event     := p_pricing_event;


    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Selecting Line Identifier...');
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_transaction_id = ' || p_transaction_id);
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_order_line_id = ' || p_order_line_id);
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_inventory_item_id = ' || p_inventory_item_id);
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_uom_code = ' || p_uom_code);
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_cto_item_flag = ' || p_cto_item_flag);
      print_debug('MTL_QP_PRICE.get_Transfer_price: p_organization_id = ' || p_organization_id);
    END IF;

    --l_inventory_item_id := p_inventory_item_id;
    l_organization_id                     := p_organization_id;
    l_transaction_uom                     := p_uom_code;

      /* bug 8881690 */
    IF (l_transaction_uom IS NULL) THEN
    BEGIN
	select transaction_uom
	into l_transaction_uom
	from mtl_material_transactions
        where transaction_id = p_transaction_id;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.get_Transfer_price:..transaction_uom IS NULL');
          END IF;
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.get_Transfer_price:..transaction_uom IS NULL');
          END IF;
     END;
    END IF;
/* End of changes for bug 8881690  */

    /* OPM Bug 2865040 */
    -- OPM INVCONV  umoogala: Following code is not applicable for R12.
    --
    /*
    IF (gml_process_flags.process_orgn = 1
        AND gml_process_flags.opmitem_flag = 1) THEN
      l_inventory_item_id  := p_inventory_item_id;

      SELECT doc_type
        INTO l_doc_type
        FROM ic_tran_pnd
       WHERE trans_id = p_transaction_id;

      IF l_doc_type = 'OMSO' THEN
        SELECT pnd.line_id
          INTO l_line_id
          FROM ic_tran_pnd pnd, ic_whse_mst whs, oe_order_lines_all oel
         WHERE pnd.trans_id = p_transaction_id
           AND oel.line_id = pnd.line_id
           AND pnd.orgn_code = whs.orgn_code
           AND pnd.whse_code = whs.whse_code;
      ELSIF l_doc_type = 'PORC' THEN
        SELECT oel.line_id
          INTO l_line_id
          FROM ic_tran_pnd pnd, ic_whse_mst whs, oe_order_lines_all oel, rcv_transactions rct
         WHERE pnd.trans_id = p_transaction_id
           AND rct.transaction_id = pnd.line_id
           AND rct.oe_order_line_id = oel.line_id
           AND pnd.orgn_code = whs.orgn_code
           AND pnd.whse_code = whs.whse_code;
      END IF;
    ELSE
    -- End OPM INVCONV */
    /* OPM Bug 2865040 */
      IF (p_transaction_id IS NOT NULL
          AND p_order_line_id IS NULL) THEN
        SELECT trx_source_line_id
             , transaction_source_type_id
             , transaction_action_id
          INTO l_line_id
             , l_transaction_source_type_id
             , l_transaction_action_id
          FROM mtl_material_transactions
         WHERE transaction_id = p_transaction_id;

        l_inventory_item_id  := p_inventory_item_id;
      ELSIF(p_transaction_id IS NOT NULL
            AND p_order_line_id IS NOT NULL) THEN
        SELECT DECODE(p_cto_item_flag, 'Y', p_order_line_id, trx_source_line_id)
             , inventory_item_id
             , transaction_source_type_id
             , transaction_action_id
          INTO l_line_id
             , l_inventory_item_id
             , l_transaction_source_type_id
             , l_transaction_action_id
          FROM mtl_material_transactions
         WHERE transaction_id = p_transaction_id;
      ELSIF(p_transaction_id IS NULL
            AND p_order_line_id IS NOT NULL) THEN
        l_inventory_item_id           := p_inventory_item_id;
        l_line_id                     := p_order_line_id;
        --
        -- OPM INVCONV umoogala
        --
        IF l_request_type_code = 'INTORG'
        THEN
          l_transaction_source_type_id := 8;
          l_transaction_action_id := 21;
        ELSE
          l_transaction_source_type_id := 13;
          l_transaction_action_id := 0;
        END IF;
      END IF;
    -- END IF;   /* OPM Bug 2865040 */ -- OPM INVCONV umoogala

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Selecting Header Identifier...');
    END IF;

    SELECT header_id
      INTO l_header_id
      FROM oe_order_lines_all
     WHERE line_id = l_line_id;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Selecting Primary UOM...');
    END IF;

    SELECT primary_uom_code
         , NVL(base_item_id, 0)
      INTO l_primary_uom
         , l_base_item_id
      FROM mtl_system_items
     WHERE inventory_item_id = l_inventory_item_id
       AND organization_id = l_organization_id;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Building Global Structure...');
      print_debug('l_base_item_id is ' || l_base_item_id);
      print_debug('p_cto_item_flag is ' || p_cto_item_flag);
    END IF;

    g_hdr_initialize(l_header_id, p_incr_code, p_incrcurrency, x_return_status);

    --
    -- OPM INVCONV umoogala  Added l_request_type_code to calls to G_Line_Initialize.
    -- This flag will decide whether to load Inter-Company parameters or not.
    -- Default value is 'IC': will not skip loading of IC params
    -- value 'INTORG' will be set only for Internal Order between process-discrete orgs
    -- across OUs and with IC Invoicing disabled.
    --
    IF (l_transaction_source_type_id = 8
        AND l_transaction_action_id = 21)
    THEN
      -- here if base_item_id > 0 and p_cto_item_flag = 'Y' then use the item id in sales order
      -- otherwise use the base item id.

      IF (l_base_item_id > 0 AND p_cto_item_flag = 'Y')
      THEN
        g_line_initialize(
          l_line_id,
          p_sell_ou_id,
          p_ship_ou_id,
          l_primary_uom,
          l_inventory_item_id,
          p_cto_item_flag,
          0,
          l_request_type_code,  -- OPM INVCONV umoogala
          x_return_status
        );
      ELSE
        IF ((l_base_item_id > 0 AND p_cto_item_flag = 'N')
            OR l_base_item_id = 0)
        THEN
          g_line_initialize(
            l_line_id,
            p_sell_ou_id,
            p_ship_ou_id,
            l_primary_uom,
            l_inventory_item_id,
            p_cto_item_flag,
            l_base_item_id,
            l_request_type_code,   -- OPM INVCONV umoogala
            x_return_status
          );
        END IF;
      END IF;
    ELSE
      -- here if the p_cto_item_flag = 'Y' then use l_inventory_item_id
      -- otherwise use the inventory_item_id in the sales order

      g_line_initialize(
        l_line_id,
        p_sell_ou_id,
        p_ship_ou_id,
        l_primary_uom,
        l_inventory_item_id,
        p_cto_item_flag,
        0,
        l_request_type_code,   -- OPM INVCONV umoogala
        x_return_status
      );
    END IF;

    IF (p_inventory_item_id <> l_inventory_item_id) THEN
      inv_ic_order_pub.g_line.inventory_item_id  := p_inventory_item_id;
    END IF;

    qp_price_request_context.set_request_id;
    copy_header_to_request(p_header_rec => inv_ic_order_pub.g_hdr, p_request_type_code => l_request_type_code
    , px_line_index                => l_line_index);

    /*
    IF (l_debug = 1) THEN
       Print_debug('MTL_QP_PRICE.get_transfer_price: Build Context for header...');
    END IF;*/

    qp_attr_mapping_pub.build_contexts(p_request_type_code => l_request_type_code, p_pricing_type_code => 'H'
    , p_line_index                 => inv_ic_order_pub.g_hdr.header_id);
    copy_line_to_request(
      p_line_rec                   => inv_ic_order_pub.g_line
    , p_pricing_events             => l_pricing_event
    , p_request_type_code          => l_request_type_code
    , px_line_index                => l_line_index
    );

    IF (l_debug = 1) THEN
      print_debug('Ship From=' || TO_CHAR(inv_ic_order_pub.g_line.ship_from_org_id));
      print_debug('Ship To=' || TO_CHAR(inv_ic_order_pub.g_line.ship_to_org_id));
    END IF;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Build Context for line...');
    END IF;

    qp_attr_mapping_pub.build_contexts(
      p_request_type_code          => l_request_type_code
    , p_pricing_type_code          => 'L'
    , p_line_index                 => mod(inv_ic_order_pub.g_line.header_id + inv_ic_order_pub.g_line.line_id, 2147483648)
    );
    /* Added mod function for bug 8534865 */

    IF l_line_index > 0 THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Populating Lines temp table...');
      END IF;

      populate_temp_table(x_return_status);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Initializing control record...');
    END IF;

    l_control_rec.pricing_event           := l_pricing_event;
    l_control_rec.calculate_flag          := qp_preq_grp.g_search_n_calculate;
    l_control_rec.temp_table_insert_flag  := 'N';
    l_control_rec.request_type_code       := l_request_type_code;
    l_control_rec.rounding_flag           := 'Y';
    -- Bug 3070474 (porting from bug 3027452) : added the following statement
    l_control_rec.use_multi_currency      := 'Y';

    print_debug('MTL_QP_PRICE.get_transfer_price: Assigning value of org_id to l_control_rec...'||p_ship_ou_id);
    --MOAC Changes: Passing the Shipping Operating unit to QP API.
    l_control_rec.org_id      := p_ship_ou_id;
    print_debug('MTL_QP_PRICE.get_transfer_price: After assigning the value of org_id to l_control_rec...'||l_control_rec.org_id);

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Calling QP:Price Request routine ...');
    END IF;

    qp_preq_pub.price_request(p_control_rec => l_control_rec, x_return_status => x_return_status
    , x_return_status_text         => l_return_status_text);

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: QP_PREQ_PUB.PRICE_REQUEST error ');
        print_debug('MTL_QP_PRICE.get_transfer_price: x_return_status_text=' || l_return_status_text);
      END IF;

      fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
      fnd_message.set_token('ENTITY1', 'QP_PREQ_PUB.PRICE_REQUEST');
      fnd_message.set_token('ENTITY2', SUBSTR(l_return_status_text, 1, 150));
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.get_transfer_price: Populating QP results ...');
    END IF;

    populate_results(l_line_index, x_return_status);
    x_currency_code                       := g_currency_code_tbl(l_line_index);
    l_tfrprice                            := g_unit_selling_price_tbl(l_line_index);

    IF g_priced_uom_code_tbl(l_line_index) = l_transaction_uom THEN
      x_tfrpricecode  := 1;
    ELSIF g_priced_uom_code_tbl(l_line_index) = l_primary_uom THEN
      x_tfrpricecode  := 2;
    ELSE
      /*
              INV_CONVERT.INV_UM_CONVERSION ( From_Unit => G_PRICED_UOM_CODE_TBL(l_line_index)
                                              , To_Unit => l_transaction_uom
                                              , Item_ID => l_inventory_item_id
                                              , Uom_Rate => l_Uom_rate);
              l_tfrPrice := G_UNIT_SELLING_PRICE_TBL(l_line_index) / l_uom_rate;
      */
      /* Added for Bug 7340642 */
       inv_convert.inv_um_conversion ( from_unit => g_priced_uom_code_tbl(l_line_index)
                                      , to_unit => l_transaction_uom
                                      , item_id => l_inventory_item_id
                                      , uom_rate => l_uom_rate);

       IF (l_uom_rate <> 0) THEN
          l_tfrPrice := g_unit_selling_price_tbl(l_line_index) / l_uom_rate;
       END IF;
      /* End of changes for Bug 7340642 */

      x_tfrpricecode  := 1;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('New Price=' || TO_CHAR(l_tfrprice));
      print_debug('UOM=' || l_transaction_uom);
    END IF;

    RETURN(l_tfrprice);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP NO_DATA_FOUND ');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP G_EXC_ERROR ');
      END IF;

      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP G_EXC_UNEXPECTED_ERROR ');
      END IF;

      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RETURN(g_unit_selling_price_tbl(l_line_index));
  END get_transfer_price;

  PROCEDURE g_hdr_initialize(p_header_id IN NUMBER, p_incr_code IN NUMBER, p_incrcurrency IN VARCHAR2, x_return_status OUT NOCOPY VARCHAR2) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    --  Header population
    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Hdr_Initialize: Populating G_HDR...');
    END IF;

    SELECT accounting_rule_id
         , agreement_id
         , attribute1
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , booked_flag
         , booked_date
         , cancelled_flag
         , CONTEXT
         , conversion_rate
         , conversion_rate_date
         , conversion_type_code
         , customer_preference_set_code
         , created_by
         , creation_date
         , cust_po_number
         , deliver_to_contact_id
         , deliver_to_org_id
         , demand_class_code
         , first_ack_code
         , first_ack_date
         , expiration_date
         , earliest_schedule_limit
         , fob_point_code
         , freight_carrier_code
         , freight_terms_code
         , global_attribute1
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute2
         , global_attribute20
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute_category
         , header_id
         , invoice_to_contact_id
         , invoice_to_org_id
         , invoicing_rule_id
         , last_ack_code
         , last_ack_date
         , last_updated_by
         , last_update_date
         , last_update_login
         , latest_schedule_limit
         , open_flag
         , ordered_date
         , order_date_type_code
         , order_number
         , order_source_id
         , order_type_id
         , order_category_code
         , org_id
         , orig_sys_document_ref
         , partial_shipments_allowed
         , payment_term_id
         , price_list_id
         , pricing_date
         , program_application_id
         , program_id
         , program_update_date
         , request_date
         , request_id
         , return_reason_code
         , salesrep_id
         , sales_channel_code
         , shipment_priority_code
         , shipping_method_code
         , ship_from_org_id
         , ship_tolerance_above
         , ship_tolerance_below
         , ship_to_contact_id
         , ship_to_org_id
         , sold_from_org_id
         , sold_to_contact_id
         , sold_to_org_id
         , source_document_id
         , source_document_type_id
         , tax_exempt_flag
         , tax_exempt_number
         , tax_exempt_reason_code
         , tax_point_code
         , DECODE(NVL(p_incr_code, 1), 3, transactional_curr_code, p_incrcurrency)
         , version_number
         , payment_type_code
         , payment_amount
         , check_number
         , credit_card_code
         , credit_card_holder_name
         , credit_card_number
         , credit_card_expiration_date
         , credit_card_approval_date
         , credit_card_approval_code
         , shipping_instructions
         , packing_instructions
         , flow_status_code
         , marketing_source_code_id
         , tp_attribute1
         , tp_attribute10
         , tp_attribute11
         , tp_attribute12
         , tp_attribute13
         , tp_attribute14
         , tp_attribute15
         , tp_attribute2
         , tp_attribute3
         , tp_attribute4
         , tp_attribute5
         , tp_attribute6
         , tp_attribute7
         , tp_attribute8
         , tp_attribute9
         , tp_context
         , upgraded_flag
         , lock_control
      INTO inv_ic_order_pub.g_hdr.accounting_rule_id
         , inv_ic_order_pub.g_hdr.agreement_id
         , inv_ic_order_pub.g_hdr.attribute1
         , inv_ic_order_pub.g_hdr.attribute10
         , inv_ic_order_pub.g_hdr.attribute11
         , inv_ic_order_pub.g_hdr.attribute12
         , inv_ic_order_pub.g_hdr.attribute13
         , inv_ic_order_pub.g_hdr.attribute14
         , inv_ic_order_pub.g_hdr.attribute15
         , inv_ic_order_pub.g_hdr.attribute2
         , inv_ic_order_pub.g_hdr.attribute3
         , inv_ic_order_pub.g_hdr.attribute4
         , inv_ic_order_pub.g_hdr.attribute5
         , inv_ic_order_pub.g_hdr.attribute6
         , inv_ic_order_pub.g_hdr.attribute7
         , inv_ic_order_pub.g_hdr.attribute8
         , inv_ic_order_pub.g_hdr.attribute9
         , inv_ic_order_pub.g_hdr.booked_flag
         , inv_ic_order_pub.g_hdr.booked_date
         , inv_ic_order_pub.g_hdr.cancelled_flag
         , inv_ic_order_pub.g_hdr.CONTEXT
         , inv_ic_order_pub.g_hdr.conversion_rate
         , inv_ic_order_pub.g_hdr.conversion_rate_date
         , inv_ic_order_pub.g_hdr.conversion_type_code
         , inv_ic_order_pub.g_hdr.customer_preference_set_code
         , inv_ic_order_pub.g_hdr.created_by
         , inv_ic_order_pub.g_hdr.creation_date
         , inv_ic_order_pub.g_hdr.cust_po_number
         , inv_ic_order_pub.g_hdr.deliver_to_contact_id
         , inv_ic_order_pub.g_hdr.deliver_to_org_id
         , inv_ic_order_pub.g_hdr.demand_class_code
         , inv_ic_order_pub.g_hdr.first_ack_code
         , inv_ic_order_pub.g_hdr.first_ack_date
         , inv_ic_order_pub.g_hdr.expiration_date
         , inv_ic_order_pub.g_hdr.earliest_schedule_limit
         , inv_ic_order_pub.g_hdr.fob_point_code
         , inv_ic_order_pub.g_hdr.freight_carrier_code
         , inv_ic_order_pub.g_hdr.freight_terms_code
         , inv_ic_order_pub.g_hdr.global_attribute1
         , inv_ic_order_pub.g_hdr.global_attribute10
         , inv_ic_order_pub.g_hdr.global_attribute11
         , inv_ic_order_pub.g_hdr.global_attribute12
         , inv_ic_order_pub.g_hdr.global_attribute13
         , inv_ic_order_pub.g_hdr.global_attribute14
         , inv_ic_order_pub.g_hdr.global_attribute15
         , inv_ic_order_pub.g_hdr.global_attribute16
         , inv_ic_order_pub.g_hdr.global_attribute17
         , inv_ic_order_pub.g_hdr.global_attribute18
         , inv_ic_order_pub.g_hdr.global_attribute19
         , inv_ic_order_pub.g_hdr.global_attribute2
         , inv_ic_order_pub.g_hdr.global_attribute20
         , inv_ic_order_pub.g_hdr.global_attribute3
         , inv_ic_order_pub.g_hdr.global_attribute4
         , inv_ic_order_pub.g_hdr.global_attribute5
         , inv_ic_order_pub.g_hdr.global_attribute6
         , inv_ic_order_pub.g_hdr.global_attribute7
         , inv_ic_order_pub.g_hdr.global_attribute8
         , inv_ic_order_pub.g_hdr.global_attribute9
         , inv_ic_order_pub.g_hdr.global_attribute_category
         , inv_ic_order_pub.g_hdr.header_id
         , inv_ic_order_pub.g_hdr.invoice_to_contact_id
         , inv_ic_order_pub.g_hdr.invoice_to_org_id
         , inv_ic_order_pub.g_hdr.invoicing_rule_id
         , inv_ic_order_pub.g_hdr.last_ack_code
         , inv_ic_order_pub.g_hdr.last_ack_date
         , inv_ic_order_pub.g_hdr.last_updated_by
         , inv_ic_order_pub.g_hdr.last_update_date
         , inv_ic_order_pub.g_hdr.last_update_login
         , inv_ic_order_pub.g_hdr.latest_schedule_limit
         , inv_ic_order_pub.g_hdr.open_flag
         , inv_ic_order_pub.g_hdr.ordered_date
         , inv_ic_order_pub.g_hdr.order_date_type_code
         , inv_ic_order_pub.g_hdr.order_number
         , inv_ic_order_pub.g_hdr.order_source_id
         , inv_ic_order_pub.g_hdr.order_type_id
         , inv_ic_order_pub.g_hdr.order_category_code
         , inv_ic_order_pub.g_hdr.org_id
         , inv_ic_order_pub.g_hdr.orig_sys_document_ref
         , inv_ic_order_pub.g_hdr.partial_shipments_allowed
         , inv_ic_order_pub.g_hdr.payment_term_id
         , inv_ic_order_pub.g_hdr.price_list_id
         , inv_ic_order_pub.g_hdr.pricing_date
         , inv_ic_order_pub.g_hdr.program_application_id
         , inv_ic_order_pub.g_hdr.program_id
         , inv_ic_order_pub.g_hdr.program_update_date
         , inv_ic_order_pub.g_hdr.request_date
         , inv_ic_order_pub.g_hdr.request_id
         , inv_ic_order_pub.g_hdr.return_reason_code
         , inv_ic_order_pub.g_hdr.salesrep_id
         , inv_ic_order_pub.g_hdr.sales_channel_code
         , inv_ic_order_pub.g_hdr.shipment_priority_code
         , inv_ic_order_pub.g_hdr.shipping_method_code
         , inv_ic_order_pub.g_hdr.ship_from_org_id
         , inv_ic_order_pub.g_hdr.ship_tolerance_above
         , inv_ic_order_pub.g_hdr.ship_tolerance_below
         , inv_ic_order_pub.g_hdr.ship_to_contact_id
         , inv_ic_order_pub.g_hdr.ship_to_org_id
         , inv_ic_order_pub.g_hdr.sold_from_org_id
         , inv_ic_order_pub.g_hdr.sold_to_contact_id
         , inv_ic_order_pub.g_hdr.sold_to_org_id
         , inv_ic_order_pub.g_hdr.source_document_id
         , inv_ic_order_pub.g_hdr.source_document_type_id
         , inv_ic_order_pub.g_hdr.tax_exempt_flag
         , inv_ic_order_pub.g_hdr.tax_exempt_number
         , inv_ic_order_pub.g_hdr.tax_exempt_reason_code
         , inv_ic_order_pub.g_hdr.tax_point_code
         , inv_ic_order_pub.g_hdr.transactional_curr_code
         , inv_ic_order_pub.g_hdr.version_number
         , inv_ic_order_pub.g_hdr.payment_type_code
         , inv_ic_order_pub.g_hdr.payment_amount
         , inv_ic_order_pub.g_hdr.check_number
         , inv_ic_order_pub.g_hdr.credit_card_code
         , inv_ic_order_pub.g_hdr.credit_card_holder_name
         , inv_ic_order_pub.g_hdr.credit_card_number
         , inv_ic_order_pub.g_hdr.credit_card_expiration_date
         , inv_ic_order_pub.g_hdr.credit_card_approval_date
         , inv_ic_order_pub.g_hdr.credit_card_approval_code
         , inv_ic_order_pub.g_hdr.shipping_instructions
         , inv_ic_order_pub.g_hdr.packing_instructions
         , inv_ic_order_pub.g_hdr.flow_status_code
         , inv_ic_order_pub.g_hdr.marketing_source_code_id
         , inv_ic_order_pub.g_hdr.tp_attribute1
         , inv_ic_order_pub.g_hdr.tp_attribute10
         , inv_ic_order_pub.g_hdr.tp_attribute11
         , inv_ic_order_pub.g_hdr.tp_attribute12
         , inv_ic_order_pub.g_hdr.tp_attribute13
         , inv_ic_order_pub.g_hdr.tp_attribute14
         , inv_ic_order_pub.g_hdr.tp_attribute15
         , inv_ic_order_pub.g_hdr.tp_attribute2
         , inv_ic_order_pub.g_hdr.tp_attribute3
         , inv_ic_order_pub.g_hdr.tp_attribute4
         , inv_ic_order_pub.g_hdr.tp_attribute5
         , inv_ic_order_pub.g_hdr.tp_attribute6
         , inv_ic_order_pub.g_hdr.tp_attribute7
         , inv_ic_order_pub.g_hdr.tp_attribute8
         , inv_ic_order_pub.g_hdr.tp_attribute9
         , inv_ic_order_pub.g_hdr.tp_context
         , inv_ic_order_pub.g_hdr.upgraded_flag
         , inv_ic_order_pub.g_hdr.lock_control
      FROM oe_order_headers_all
     WHERE header_id = p_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Hdr_Initialize: EXCEP NO_DATA_FOUND ');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Hdr_Initialize: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END g_hdr_initialize;

  PROCEDURE g_line_initialize(
    p_line_id           IN            NUMBER
  , l_sell_org_id       IN            NUMBER
  , l_ship_org_id       IN            NUMBER
  , l_primary_uom       IN            VARCHAR2
  , p_inventory_item_id IN            NUMBER
  , p_cto_item_flag     IN            VARCHAR2
  , p_base_item_id      IN            NUMBER
  , p_request_type_code IN VARCHAR2 DEFAULT 'IC'
    -- OPM INVCONV umoogala Added above parameter
  , x_return_status     OUT NOCOPY    VARCHAR2
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status                                         := fnd_api.g_ret_sts_success;
    inv_ic_order_pub.g_line.accounting_rule_id              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.actual_arrival_date             := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.actual_shipment_date            := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.agreement_id                    := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.arrival_set_id                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ato_line_id                     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.attribute1                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute10                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute11                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute12                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute13                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute14                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute15                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute2                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute3                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute4                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute5                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute6                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute7                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute8                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.attribute9                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.authorized_to_ship_flag         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.auto_selected_quantity          := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.booked_flag                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.cancelled_flag                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.cancelled_quantity              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.cancelled_quantity2             := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.commitment_id                   := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.component_code                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.component_number                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.component_sequence_id           := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.config_header_id                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.config_rev_nbr                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.config_display_sequence         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.configuration_id                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.CONTEXT                         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.created_by                      := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.creation_date                   := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.credit_invoice_line_id          := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.customer_dock_code              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_job                    := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_production_line        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_trx_line_id            := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.cust_model_serial_number        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.cust_po_number                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.cust_production_seq_num         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.delivery_lead_time              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.deliver_to_contact_id           := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.deliver_to_org_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.demand_bucket_type_code         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.demand_class_code               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.dep_plan_required_flag          := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.earliest_acceptable_date        := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.end_item_unit_number            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.explosion_date                  := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.fob_point_code                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.freight_carrier_code            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.freight_terms_code              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.fulfilled_quantity              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.fulfilled_quantity2             := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.global_attribute1               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute10              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute11              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute12              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute13              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute14              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute15              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute16              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute17              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute18              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute19              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute2               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute20              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute3               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute4               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute5               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute6               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute7               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute8               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute9               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.global_attribute_category       := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.header_id                       := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.industry_attribute1             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute10            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute11            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute12            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute13            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute14            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute15            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute16            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute17            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute18            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute19            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute20            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute21            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute22            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute23            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute24            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute25            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute26            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute27            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute28            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute29            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute30            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute2             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute3             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute4             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute5             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute6             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute7             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute8             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_attribute9             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.industry_context                := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_context                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute1                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute2                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute3                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute4                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute5                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute6                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute7                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute8                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute9                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute10                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute11                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute12                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute13                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute14                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tp_attribute15                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.intermed_ship_to_org_id         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.intermed_ship_to_contact_id     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.inventory_item_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.invoice_interface_status_code   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.invoice_to_contact_id           := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.invoice_to_org_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.invoicing_rule_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ordered_item                    := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.item_revision                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.item_type_code                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.last_updated_by                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.last_update_date                := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.last_update_login               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.latest_acceptable_date          := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.line_category_code              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.line_id                         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.line_number                     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.line_type_id                    := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.link_to_line_ref                := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.link_to_line_id                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.link_to_line_index              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.model_group_number              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.mfg_component_sequence_id       := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.mfg_lead_time                   := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.open_flag                       := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.option_flag                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.option_number                   := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ordered_quantity                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ordered_quantity2               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.order_quantity_uom              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ordered_quantity_uom2           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.org_id                          := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.orig_sys_document_ref           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.orig_sys_line_ref               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.over_ship_reason_code           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.over_ship_resolved_flag         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.payment_term_id                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.planning_priority               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.preferred_grade                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.price_list_id                   := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.pricing_attribute1              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute10             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute2              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute3              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute4              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute5              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute6              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute7              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute8              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_attribute9              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_context                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.pricing_date                    := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.pricing_quantity                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.pricing_quantity_uom            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.program_application_id          := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.program_id                      := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.program_update_date             := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.project_id                      := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.promise_date                    := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.re_source_flag                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.reference_customer_trx_line_id  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.reference_header_id             := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.reference_line_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.reference_type                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.request_date                    := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.request_id                      := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.reserved_quantity               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.return_attribute1               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute10              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute11              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute12              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute13              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute14              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute15              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute2               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute3               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute4               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute5               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute6               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute7               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute8               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_attribute9               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_context                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_reason_code              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.rla_schedule_type_code          := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.salesrep_id                     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.schedule_arrival_date           := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.schedule_ship_date              := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.schedule_action_code            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.schedule_status_code            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipment_number                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.shipment_priority_code          := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipped_quantity                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.shipped_quantity2               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.shipping_interfaced_flag        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipping_method_code            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipping_quantity               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.shipping_quantity2              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.shipping_quantity_uom           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipping_quantity_uom2          := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ship_from_org_id                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ship_model_complete_flag        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ship_set_id                     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.fulfillment_set_id              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ship_tolerance_above            := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ship_tolerance_below            := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ship_to_contact_id              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ship_to_org_id                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.sold_to_org_id                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.sold_from_org_id                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.sort_order                      := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.source_document_id              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.source_document_line_id         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.source_document_type_id         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.source_type_code                := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.split_from_line_id              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.task_id                         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.tax_code                        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tax_date                        := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.tax_exempt_flag                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tax_exempt_number               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tax_exempt_reason_code          := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tax_point_code                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.tax_rate                        := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.tax_value                       := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.top_model_line_ref              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.top_model_line_id               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.top_model_line_index            := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_list_price                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_list_price_per_pqty        := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_selling_price              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_selling_price_per_pqty     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.veh_cus_item_cum_key_id         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.visible_demand_flag             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_status                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.db_flag                         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.operation                       := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.first_ack_code                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.first_ack_date                  := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.last_ack_code                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.last_ack_date                   := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.change_reason                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.change_comments                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.arrival_set                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ship_set                        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.fulfillment_set                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.order_source_id                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.orig_sys_shipment_ref           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.change_sequence                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.change_request_code             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.status_flag                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.drop_ship_flag                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_line_number            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_shipment_number        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.customer_item_net_price         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.customer_payment_term_id        := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.ordered_item_id                 := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.item_identifier_type            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shipping_instructions           := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.packing_instructions            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.calculate_price_flag            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.invoiced_quantity               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_txn_reason_code         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.service_txn_comments            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.service_duration                := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_period                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.service_start_date              := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.service_end_date                := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.service_coterminate_flag        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.unit_list_percent               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_selling_percent            := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.unit_percent_base_price         := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_number                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_reference_type_code     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.service_reference_line_id       := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_reference_system_id     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.service_ref_order_number        := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.service_ref_line_number         := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.service_reference_order         := fnd_api.g_miss_char;   --
    inv_ic_order_pub.g_line.service_reference_line          := fnd_api.g_miss_char;   --
    inv_ic_order_pub.g_line.service_reference_system        := fnd_api.g_miss_char;   --
    inv_ic_order_pub.g_line.service_ref_shipment_number     := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.service_ref_option_number       := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.service_line_index              := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.line_set_id                     := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.split_by                        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.split_action_code               := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.shippable_flag                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.model_remnant_flag              := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.flow_status_code                := 'ENTERED';
    inv_ic_order_pub.g_line.fulfilled_flag                  := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.fulfillment_method_code         := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.revenue_amount                  := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.marketing_source_code_id        := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.fulfillment_date                := fnd_api.g_miss_date;
    inv_ic_order_pub.g_line.semi_processed_flag             := FALSE;
    inv_ic_order_pub.g_line.upgraded_flag                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.lock_control                    := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.subinventory                    := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.split_from_line_ref             := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ship_to_edi_location_code       := fnd_api.g_miss_char;
    --  The followings are attributes related to the IC
    inv_ic_order_pub.g_line.ic_customer_id                  := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_address_id                   := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_customer_site_id             := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_cust_trx_type_id             := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_vendor_id                    := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_vendor_site_id               := fnd_api.g_miss_num;   --
    inv_ic_order_pub.g_line.ic_revalue_average_flag         := fnd_api.g_miss_char;   --
    inv_ic_order_pub.g_line.ic_freight_code_combination_id  := fnd_api.g_miss_num;   --
    -- set values for non-DB fields
    inv_ic_order_pub.g_line.db_flag                         := fnd_api.g_true;
    inv_ic_order_pub.g_line.operation                       := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.return_status                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.schedule_action_code            := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.reserved_quantity               := fnd_api.g_miss_num;
    inv_ic_order_pub.g_line.change_reason                   := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.change_comments                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.arrival_set                     := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.ship_set                        := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.fulfillment_set                 := fnd_api.g_miss_char;
    inv_ic_order_pub.g_line.split_action_code               := fnd_api.g_miss_char;

    --  Intercompany fields population
    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Line_Initialize: Populating IC fields...');
    END IF;

    --
    -- OPM INVCONV umoogala  Process Discrete Transfers Enh.
    -- For above transfers via internal order, we are trying to
    -- reuse this get_transfe_price routine. For these transfers
    -- intercompany parameters are NOT mandatory.
    -- But, Internal Orders with IC Invoicing will need these parameters.
    -- Calling program GMF_get_transfer_price_PUB will set the following
    -- parameter to INTORG, so that IC parameters are not loaded.
    --
    IF p_request_type_code = 'IC'
    THEN
      BEGIN
        SELECT customer_id
             , address_id
             , customer_site_id
             , cust_trx_type_id
             , vendor_id
             , vendor_site_id
             , revalue_average_flag
             , freight_code_combination_id
          INTO inv_ic_order_pub.g_line.ic_customer_id
             , inv_ic_order_pub.g_line.ic_address_id
             , inv_ic_order_pub.g_line.ic_customer_site_id
             , inv_ic_order_pub.g_line.ic_cust_trx_type_id
             , inv_ic_order_pub.g_line.ic_vendor_id
             , inv_ic_order_pub.g_line.ic_vendor_site_id
             , inv_ic_order_pub.g_line.ic_revalue_average_flag
             , inv_ic_order_pub.g_line.ic_freight_code_combination_id
          FROM mtl_intercompany_parameters
         WHERE sell_organization_id = l_sell_org_id
           AND ship_organization_id = NVL(l_ship_org_id, ship_organization_id)
           AND flow_type = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status  := fnd_api.g_ret_sts_error;

          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.G_Line_Initialize: IC fields NO_DATA_FOUND...');
          END IF;
        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.G_Line_Initialize: IC fields EXCEP UNEXP OTHERS - ' || SQLERRM);
          END IF;
      END;

      inv_ic_order_pub.g_line.ic_selling_org_id               := l_sell_org_id;
      inv_ic_order_pub.g_line.ic_shipping_org_id              := l_ship_org_id;
      inv_ic_order_pub.g_line.primary_uom                     := l_primary_uom;
    END IF; -- OPM INVCONV umoogala (if p_request_type_code = 'IC')

    --  Line population
    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Line_Initialize: Populating G_LINE...');
    END IF;

    SELECT accounting_rule_id
         , actual_arrival_date
         , actual_shipment_date
         , agreement_id
         , arrival_set_id
         , ato_line_id
         , attribute1
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , auto_selected_quantity
         , authorized_to_ship_flag
         , booked_flag
         , cancelled_flag
         , cancelled_quantity
         , component_code
         , component_number
         , component_sequence_id
         , config_header_id
         , config_rev_nbr
         , config_display_sequence
         , configuration_id
         , CONTEXT
         , created_by
         , creation_date
         , credit_invoice_line_id
         , customer_dock_code
         , customer_job
         , customer_production_line
         , cust_production_seq_num
         , customer_trx_line_id
         , cust_model_serial_number
         , cust_po_number
         , customer_line_number
         , delivery_lead_time
         , deliver_to_contact_id
         , deliver_to_org_id
         , demand_bucket_type_code
         , demand_class_code
         , dep_plan_required_flag
         , earliest_acceptable_date
         , end_item_unit_number
         , explosion_date
         , first_ack_code
         , first_ack_date
         , fob_point_code
         , freight_carrier_code
         , freight_terms_code
         , fulfilled_quantity
         , fulfilled_flag
         , fulfillment_method_code
         , fulfillment_date
         , global_attribute1
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute2
         , global_attribute20
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute_category
         , header_id
         , industry_attribute1
         , industry_attribute10
         , industry_attribute11
         , industry_attribute12
         , industry_attribute13
         , industry_attribute14
         , industry_attribute15
         , industry_attribute16
         , industry_attribute17
         , industry_attribute18
         , industry_attribute19
         , industry_attribute20
         , industry_attribute21
         , industry_attribute22
         , industry_attribute23
         , industry_attribute24
         , industry_attribute25
         , industry_attribute26
         , industry_attribute27
         , industry_attribute28
         , industry_attribute29
         , industry_attribute30
         , industry_attribute2
         , industry_attribute3
         , industry_attribute4
         , industry_attribute5
         , industry_attribute6
         , industry_attribute7
         , industry_attribute8
         , industry_attribute9
         , industry_context
         , intmed_ship_to_contact_id
         , intmed_ship_to_org_id
         , DECODE(
             NVL(p_cto_item_flag, 'N')
           , 'N', DECODE(p_base_item_id, 0, inventory_item_id, p_base_item_id)
           , DECODE(p_base_item_id, 0, p_inventory_item_id, inventory_item_id)
           )
         , invoice_interface_status_code
         , invoice_to_contact_id
         , invoice_to_org_id
         , invoiced_quantity
         , invoicing_rule_id
         , ordered_item_id
         , item_identifier_type
         , ordered_item
         , item_revision
         , item_type_code
         , last_ack_code
         , last_ack_date
         , last_updated_by
         , last_update_date
         , last_update_login
         , latest_acceptable_date
         , line_category_code
         , line_id
         , line_number
         , line_type_id
         , link_to_line_id
         , model_group_number
         --  ,       MFG_COMPONENT_SEQUENCE_ID
    ,      mfg_lead_time
         , open_flag
         , option_flag
         , option_number
         , ordered_quantity
         , ordered_quantity2   --OPM 02/JUN/00
         , order_quantity_uom
         , ordered_quantity_uom2   --OPM 02/JUN/00
         , org_id
         , orig_sys_document_ref
         , orig_sys_line_ref
         , over_ship_reason_code
         , over_ship_resolved_flag
         , payment_term_id
         , planning_priority
         , preferred_grade   --OPM 02/JUN/00
         , price_list_id
         , pricing_attribute1
         , pricing_attribute10
         , pricing_attribute2
         , pricing_attribute3
         , pricing_attribute4
         , pricing_attribute5
         , pricing_attribute6
         , pricing_attribute7
         , pricing_attribute8
         , pricing_attribute9
         , pricing_context
         , pricing_date
         , pricing_quantity
         , pricing_quantity_uom
         , program_application_id
         , program_id
         , program_update_date
         , project_id
         , promise_date
         , re_source_flag
         , reference_customer_trx_line_id
         , reference_header_id
         , reference_line_id
         , reference_type
         , request_date
         , request_id
         , return_attribute1
         , return_attribute10
         , return_attribute11
         , return_attribute12
         , return_attribute13
         , return_attribute14
         , return_attribute15
         , return_attribute2
         , return_attribute3
         , return_attribute4
         , return_attribute5
         , return_attribute6
         , return_attribute7
         , return_attribute8
         , return_attribute9
         , return_context
         , return_reason_code
         , rla_schedule_type_code
         , salesrep_id
         , schedule_arrival_date
         , schedule_ship_date
         , schedule_status_code
         , shipment_number
         , shipment_priority_code
         , shipped_quantity
         , shipped_quantity2   -- OPM B1661023 04/02/01
         , shipping_method_code
         , shipping_quantity
         , shipping_quantity2   -- OPM B1661023 04/02/01
         , shipping_quantity_uom
         , ship_from_org_id
         , subinventory
         , ship_set_id
         , ship_tolerance_above
         , ship_tolerance_below
         , shippable_flag
         , shipping_interfaced_flag
         , ship_to_contact_id
         , ship_to_org_id
         , ship_model_complete_flag
         , sold_to_org_id
         , sold_from_org_id
         , sort_order
         , source_document_id
         , source_document_line_id
         , source_document_type_id
         , source_type_code
         , split_from_line_id
         , line_set_id
         , split_by
         , model_remnant_flag
         , task_id
         , tax_code
         , tax_date
         , tax_exempt_flag
         , tax_exempt_number
         , tax_exempt_reason_code
         , tax_point_code
         , tax_rate
         , tax_value
         , top_model_line_id
         , unit_list_price
         , unit_list_price_per_pqty
         , unit_selling_price
         , unit_selling_price_per_pqty
         , visible_demand_flag
         , veh_cus_item_cum_key_id
         , shipping_instructions
         , packing_instructions
         , service_txn_reason_code
         , service_txn_comments
         , service_duration
         , service_period
         , service_start_date
         , service_end_date
         , service_coterminate_flag
         , unit_list_percent
         , unit_selling_percent
         , unit_percent_base_price
         , service_number
         , service_reference_type_code
         , service_reference_line_id
         , service_reference_system_id
         , tp_context
         , tp_attribute1
         , tp_attribute2
         , tp_attribute3
         , tp_attribute4
         , tp_attribute5
         , tp_attribute6
         , tp_attribute7
         , tp_attribute8
         , tp_attribute9
         , tp_attribute10
         , tp_attribute11
         , tp_attribute12
         , tp_attribute13
         , tp_attribute14
         , tp_attribute15
         , flow_status_code
         , marketing_source_code_id
         , calculate_price_flag
         , commitment_id
         , order_source_id   -- aksingh
         , upgraded_flag
         , lock_control
      INTO inv_ic_order_pub.g_line.accounting_rule_id
         , inv_ic_order_pub.g_line.actual_arrival_date
         , inv_ic_order_pub.g_line.actual_shipment_date
         , inv_ic_order_pub.g_line.agreement_id
         , inv_ic_order_pub.g_line.arrival_set_id
         , inv_ic_order_pub.g_line.ato_line_id
         , inv_ic_order_pub.g_line.attribute1
         , inv_ic_order_pub.g_line.attribute10
         , inv_ic_order_pub.g_line.attribute11
         , inv_ic_order_pub.g_line.attribute12
         , inv_ic_order_pub.g_line.attribute13
         , inv_ic_order_pub.g_line.attribute14
         , inv_ic_order_pub.g_line.attribute15
         , inv_ic_order_pub.g_line.attribute2
         , inv_ic_order_pub.g_line.attribute3
         , inv_ic_order_pub.g_line.attribute4
         , inv_ic_order_pub.g_line.attribute5
         , inv_ic_order_pub.g_line.attribute6
         , inv_ic_order_pub.g_line.attribute7
         , inv_ic_order_pub.g_line.attribute8
         , inv_ic_order_pub.g_line.attribute9
         , inv_ic_order_pub.g_line.auto_selected_quantity
         , inv_ic_order_pub.g_line.authorized_to_ship_flag
         , inv_ic_order_pub.g_line.booked_flag
         , inv_ic_order_pub.g_line.cancelled_flag
         , inv_ic_order_pub.g_line.cancelled_quantity
         , inv_ic_order_pub.g_line.component_code
         , inv_ic_order_pub.g_line.component_number
         , inv_ic_order_pub.g_line.component_sequence_id
         , inv_ic_order_pub.g_line.config_header_id
         , inv_ic_order_pub.g_line.config_rev_nbr
         , inv_ic_order_pub.g_line.config_display_sequence
         , inv_ic_order_pub.g_line.configuration_id
         , inv_ic_order_pub.g_line.CONTEXT
         , inv_ic_order_pub.g_line.created_by
         , inv_ic_order_pub.g_line.creation_date
         , inv_ic_order_pub.g_line.credit_invoice_line_id
         , inv_ic_order_pub.g_line.customer_dock_code
         , inv_ic_order_pub.g_line.customer_job
         , inv_ic_order_pub.g_line.customer_production_line
         , inv_ic_order_pub.g_line.cust_production_seq_num
         , inv_ic_order_pub.g_line.customer_trx_line_id
         , inv_ic_order_pub.g_line.cust_model_serial_number
         , inv_ic_order_pub.g_line.cust_po_number
         , inv_ic_order_pub.g_line.customer_line_number
         , inv_ic_order_pub.g_line.delivery_lead_time
         , inv_ic_order_pub.g_line.deliver_to_contact_id
         , inv_ic_order_pub.g_line.deliver_to_org_id
         , inv_ic_order_pub.g_line.demand_bucket_type_code
         , inv_ic_order_pub.g_line.demand_class_code
         , inv_ic_order_pub.g_line.dep_plan_required_flag
         , inv_ic_order_pub.g_line.earliest_acceptable_date
         , inv_ic_order_pub.g_line.end_item_unit_number
         , inv_ic_order_pub.g_line.explosion_date
         , inv_ic_order_pub.g_line.first_ack_code
         , inv_ic_order_pub.g_line.first_ack_date
         , inv_ic_order_pub.g_line.fob_point_code
         , inv_ic_order_pub.g_line.freight_carrier_code
         , inv_ic_order_pub.g_line.freight_terms_code
         , inv_ic_order_pub.g_line.fulfilled_quantity
         , inv_ic_order_pub.g_line.fulfilled_flag
         , inv_ic_order_pub.g_line.fulfillment_method_code
         , inv_ic_order_pub.g_line.fulfillment_date
         , inv_ic_order_pub.g_line.global_attribute1
         , inv_ic_order_pub.g_line.global_attribute10
         , inv_ic_order_pub.g_line.global_attribute11
         , inv_ic_order_pub.g_line.global_attribute12
         , inv_ic_order_pub.g_line.global_attribute13
         , inv_ic_order_pub.g_line.global_attribute14
         , inv_ic_order_pub.g_line.global_attribute15
         , inv_ic_order_pub.g_line.global_attribute16
         , inv_ic_order_pub.g_line.global_attribute17
         , inv_ic_order_pub.g_line.global_attribute18
         , inv_ic_order_pub.g_line.global_attribute19
         , inv_ic_order_pub.g_line.global_attribute2
         , inv_ic_order_pub.g_line.global_attribute20
         , inv_ic_order_pub.g_line.global_attribute3
         , inv_ic_order_pub.g_line.global_attribute4
         , inv_ic_order_pub.g_line.global_attribute5
         , inv_ic_order_pub.g_line.global_attribute6
         , inv_ic_order_pub.g_line.global_attribute7
         , inv_ic_order_pub.g_line.global_attribute8
         , inv_ic_order_pub.g_line.global_attribute9
         , inv_ic_order_pub.g_line.global_attribute_category
         , inv_ic_order_pub.g_line.header_id
         , inv_ic_order_pub.g_line.industry_attribute1
         , inv_ic_order_pub.g_line.industry_attribute10
         , inv_ic_order_pub.g_line.industry_attribute11
         , inv_ic_order_pub.g_line.industry_attribute12
         , inv_ic_order_pub.g_line.industry_attribute13
         , inv_ic_order_pub.g_line.industry_attribute14
         , inv_ic_order_pub.g_line.industry_attribute15
         , inv_ic_order_pub.g_line.industry_attribute16
         , inv_ic_order_pub.g_line.industry_attribute17
         , inv_ic_order_pub.g_line.industry_attribute18
         , inv_ic_order_pub.g_line.industry_attribute19
         , inv_ic_order_pub.g_line.industry_attribute20
         , inv_ic_order_pub.g_line.industry_attribute21
         , inv_ic_order_pub.g_line.industry_attribute22
         , inv_ic_order_pub.g_line.industry_attribute23
         , inv_ic_order_pub.g_line.industry_attribute24
         , inv_ic_order_pub.g_line.industry_attribute25
         , inv_ic_order_pub.g_line.industry_attribute26
         , inv_ic_order_pub.g_line.industry_attribute27
         , inv_ic_order_pub.g_line.industry_attribute28
         , inv_ic_order_pub.g_line.industry_attribute29
         , inv_ic_order_pub.g_line.industry_attribute30
         , inv_ic_order_pub.g_line.industry_attribute2
         , inv_ic_order_pub.g_line.industry_attribute3
         , inv_ic_order_pub.g_line.industry_attribute4
         , inv_ic_order_pub.g_line.industry_attribute5
         , inv_ic_order_pub.g_line.industry_attribute6
         , inv_ic_order_pub.g_line.industry_attribute7
         , inv_ic_order_pub.g_line.industry_attribute8
         , inv_ic_order_pub.g_line.industry_attribute9
         , inv_ic_order_pub.g_line.industry_context
         , inv_ic_order_pub.g_line.intermed_ship_to_contact_id
         , inv_ic_order_pub.g_line.intermed_ship_to_org_id
         , inv_ic_order_pub.g_line.inventory_item_id
         , inv_ic_order_pub.g_line.invoice_interface_status_code
         , inv_ic_order_pub.g_line.invoice_to_contact_id
         , inv_ic_order_pub.g_line.invoice_to_org_id
         , inv_ic_order_pub.g_line.invoiced_quantity
         , inv_ic_order_pub.g_line.invoicing_rule_id
         , inv_ic_order_pub.g_line.ordered_item_id
         , inv_ic_order_pub.g_line.item_identifier_type
         , inv_ic_order_pub.g_line.ordered_item
         , inv_ic_order_pub.g_line.item_revision
         , inv_ic_order_pub.g_line.item_type_code
         , inv_ic_order_pub.g_line.last_ack_code
         , inv_ic_order_pub.g_line.last_ack_date
         , inv_ic_order_pub.g_line.last_updated_by
         , inv_ic_order_pub.g_line.last_update_date
         , inv_ic_order_pub.g_line.last_update_login
         , inv_ic_order_pub.g_line.latest_acceptable_date
         , inv_ic_order_pub.g_line.line_category_code
         , inv_ic_order_pub.g_line.line_id
         , inv_ic_order_pub.g_line.line_number
         , inv_ic_order_pub.g_line.line_type_id
         , inv_ic_order_pub.g_line.link_to_line_id
         , inv_ic_order_pub.g_line.model_group_number
         --  ,       INV_IC_ORDER_PUB.G_LINE.MFG_COMPONENT_SEQUENCE_ID
    ,      inv_ic_order_pub.g_line.mfg_lead_time
         , inv_ic_order_pub.g_line.open_flag
         , inv_ic_order_pub.g_line.option_flag
         , inv_ic_order_pub.g_line.option_number
         , inv_ic_order_pub.g_line.ordered_quantity
         , inv_ic_order_pub.g_line.ordered_quantity2   --OPM 02/JUN/00
         , inv_ic_order_pub.g_line.order_quantity_uom
         , inv_ic_order_pub.g_line.ordered_quantity_uom2   --OPM 02/JUN/00
         , inv_ic_order_pub.g_line.org_id
         , inv_ic_order_pub.g_line.orig_sys_document_ref
         , inv_ic_order_pub.g_line.orig_sys_line_ref
         , inv_ic_order_pub.g_line.over_ship_reason_code
         , inv_ic_order_pub.g_line.over_ship_resolved_flag
         , inv_ic_order_pub.g_line.payment_term_id
         , inv_ic_order_pub.g_line.planning_priority
         , inv_ic_order_pub.g_line.preferred_grade   --OPM 02/JUN/00
         , inv_ic_order_pub.g_line.price_list_id
         , inv_ic_order_pub.g_line.pricing_attribute1
         , inv_ic_order_pub.g_line.pricing_attribute10
         , inv_ic_order_pub.g_line.pricing_attribute2
         , inv_ic_order_pub.g_line.pricing_attribute3
         , inv_ic_order_pub.g_line.pricing_attribute4
         , inv_ic_order_pub.g_line.pricing_attribute5
         , inv_ic_order_pub.g_line.pricing_attribute6
         , inv_ic_order_pub.g_line.pricing_attribute7
         , inv_ic_order_pub.g_line.pricing_attribute8
         , inv_ic_order_pub.g_line.pricing_attribute9
         , inv_ic_order_pub.g_line.pricing_context
         , inv_ic_order_pub.g_line.pricing_date
         , inv_ic_order_pub.g_line.pricing_quantity
         , inv_ic_order_pub.g_line.pricing_quantity_uom
         , inv_ic_order_pub.g_line.program_application_id
         , inv_ic_order_pub.g_line.program_id
         , inv_ic_order_pub.g_line.program_update_date
         , inv_ic_order_pub.g_line.project_id
         , inv_ic_order_pub.g_line.promise_date
         , inv_ic_order_pub.g_line.re_source_flag
         , inv_ic_order_pub.g_line.reference_customer_trx_line_id
         , inv_ic_order_pub.g_line.reference_header_id
         , inv_ic_order_pub.g_line.reference_line_id
         , inv_ic_order_pub.g_line.reference_type
         , inv_ic_order_pub.g_line.request_date
         , inv_ic_order_pub.g_line.request_id
         , inv_ic_order_pub.g_line.return_attribute1
         , inv_ic_order_pub.g_line.return_attribute10
         , inv_ic_order_pub.g_line.return_attribute11
         , inv_ic_order_pub.g_line.return_attribute12
         , inv_ic_order_pub.g_line.return_attribute13
         , inv_ic_order_pub.g_line.return_attribute14
         , inv_ic_order_pub.g_line.return_attribute15
         , inv_ic_order_pub.g_line.return_attribute2
         , inv_ic_order_pub.g_line.return_attribute3
         , inv_ic_order_pub.g_line.return_attribute4
         , inv_ic_order_pub.g_line.return_attribute5
         , inv_ic_order_pub.g_line.return_attribute6
         , inv_ic_order_pub.g_line.return_attribute7
         , inv_ic_order_pub.g_line.return_attribute8
         , inv_ic_order_pub.g_line.return_attribute9
         , inv_ic_order_pub.g_line.return_context
         , inv_ic_order_pub.g_line.return_reason_code
         , inv_ic_order_pub.g_line.rla_schedule_type_code
         , inv_ic_order_pub.g_line.salesrep_id
         , inv_ic_order_pub.g_line.schedule_arrival_date
         , inv_ic_order_pub.g_line.schedule_ship_date
         , inv_ic_order_pub.g_line.schedule_status_code
         , inv_ic_order_pub.g_line.shipment_number
         , inv_ic_order_pub.g_line.shipment_priority_code
         , inv_ic_order_pub.g_line.shipped_quantity
         , inv_ic_order_pub.g_line.shipped_quantity2   -- OPM B1661023 04/02/01
         , inv_ic_order_pub.g_line.shipping_method_code
         , inv_ic_order_pub.g_line.shipping_quantity
         , inv_ic_order_pub.g_line.shipping_quantity2   -- OPM B1661023 04/02/01
         , inv_ic_order_pub.g_line.shipping_quantity_uom
         , inv_ic_order_pub.g_line.ship_from_org_id
         , inv_ic_order_pub.g_line.subinventory
         , inv_ic_order_pub.g_line.ship_set_id
         , inv_ic_order_pub.g_line.ship_tolerance_above
         , inv_ic_order_pub.g_line.ship_tolerance_below
         , inv_ic_order_pub.g_line.shippable_flag
         , inv_ic_order_pub.g_line.shipping_interfaced_flag
         , inv_ic_order_pub.g_line.ship_to_contact_id
         , inv_ic_order_pub.g_line.ship_to_org_id
         , inv_ic_order_pub.g_line.ship_model_complete_flag
         , inv_ic_order_pub.g_line.sold_to_org_id
         , inv_ic_order_pub.g_line.sold_from_org_id
         , inv_ic_order_pub.g_line.sort_order
         , inv_ic_order_pub.g_line.source_document_id
         , inv_ic_order_pub.g_line.source_document_line_id
         , inv_ic_order_pub.g_line.source_document_type_id
         , inv_ic_order_pub.g_line.source_type_code
         , inv_ic_order_pub.g_line.split_from_line_id
         , inv_ic_order_pub.g_line.line_set_id
         , inv_ic_order_pub.g_line.split_by
         , inv_ic_order_pub.g_line.model_remnant_flag
         , inv_ic_order_pub.g_line.task_id
         , inv_ic_order_pub.g_line.tax_code
         , inv_ic_order_pub.g_line.tax_date
         , inv_ic_order_pub.g_line.tax_exempt_flag
         , inv_ic_order_pub.g_line.tax_exempt_number
         , inv_ic_order_pub.g_line.tax_exempt_reason_code
         , inv_ic_order_pub.g_line.tax_point_code
         , inv_ic_order_pub.g_line.tax_rate
         , inv_ic_order_pub.g_line.tax_value
         , inv_ic_order_pub.g_line.top_model_line_id
         , inv_ic_order_pub.g_line.unit_list_price
         , inv_ic_order_pub.g_line.unit_list_price_per_pqty
         , inv_ic_order_pub.g_line.unit_selling_price
         , inv_ic_order_pub.g_line.unit_selling_price_per_pqty
         , inv_ic_order_pub.g_line.visible_demand_flag
         , inv_ic_order_pub.g_line.veh_cus_item_cum_key_id
         , inv_ic_order_pub.g_line.shipping_instructions
         , inv_ic_order_pub.g_line.packing_instructions
         , inv_ic_order_pub.g_line.service_txn_reason_code
         , inv_ic_order_pub.g_line.service_txn_comments
         , inv_ic_order_pub.g_line.service_duration
         , inv_ic_order_pub.g_line.service_period
         , inv_ic_order_pub.g_line.service_start_date
         , inv_ic_order_pub.g_line.service_end_date
         , inv_ic_order_pub.g_line.service_coterminate_flag
         , inv_ic_order_pub.g_line.unit_list_percent
         , inv_ic_order_pub.g_line.unit_selling_percent
         , inv_ic_order_pub.g_line.unit_percent_base_price
         , inv_ic_order_pub.g_line.service_number
         , inv_ic_order_pub.g_line.service_reference_type_code
         , inv_ic_order_pub.g_line.service_reference_line_id
         , inv_ic_order_pub.g_line.service_reference_system_id
         , inv_ic_order_pub.g_line.tp_context
         , inv_ic_order_pub.g_line.tp_attribute1
         , inv_ic_order_pub.g_line.tp_attribute2
         , inv_ic_order_pub.g_line.tp_attribute3
         , inv_ic_order_pub.g_line.tp_attribute4
         , inv_ic_order_pub.g_line.tp_attribute5
         , inv_ic_order_pub.g_line.tp_attribute6
         , inv_ic_order_pub.g_line.tp_attribute7
         , inv_ic_order_pub.g_line.tp_attribute8
         , inv_ic_order_pub.g_line.tp_attribute9
         , inv_ic_order_pub.g_line.tp_attribute10
         , inv_ic_order_pub.g_line.tp_attribute11
         , inv_ic_order_pub.g_line.tp_attribute12
         , inv_ic_order_pub.g_line.tp_attribute13
         , inv_ic_order_pub.g_line.tp_attribute14
         , inv_ic_order_pub.g_line.tp_attribute15
         , inv_ic_order_pub.g_line.flow_status_code
         , inv_ic_order_pub.g_line.marketing_source_code_id
         , inv_ic_order_pub.g_line.calculate_price_flag
         , inv_ic_order_pub.g_line.commitment_id
         , inv_ic_order_pub.g_line.order_source_id   -- aksingh
         , inv_ic_order_pub.g_line.upgraded_flag
         , inv_ic_order_pub.g_line.lock_control
      FROM oe_order_lines_all
     WHERE line_id = p_line_id;

    inv_ic_order_pub.g_line.calculate_price_flag            := 'Y';

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Line_Initialize: InventoryItemId=' || TO_CHAR(inv_ic_order_pub.g_line.inventory_item_id));
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Line_Initialize: EXCEP NO_DATA_FOUND ');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Line_Initialize: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END g_line_initialize;

  PROCEDURE copy_header_to_request(
    p_header_rec                      inv_ic_order_pub.header_rec_type
  , p_request_type_code               VARCHAR2
  , px_line_index       IN OUT NOCOPY NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    px_line_index                                  := px_line_index + 1;
    g_request_type_code_tbl(px_line_index)         := p_request_type_code;
    g_price_request_code_tbl(px_line_index)        := p_request_type_code;
    g_line_index_tbl(px_line_index)                := p_header_rec.header_id;
    g_line_type_code_tbl(px_line_index)            := 'ORDER';
    --  Hold the header_id in line_id for 'HEADER' Records
    g_line_id_tbl(px_line_index)                   := p_header_rec.header_id;

    IF p_header_rec.pricing_date IS NULL
       OR p_header_rec.pricing_date = fnd_api.g_miss_date THEN
      g_pricing_effective_date_tbl(px_line_index)  := TRUNC(SYSDATE);
    ELSE
      /*Bug 5211087 - populating truncated value of pricing_date in pricing_effective_date */
      g_pricing_effective_date_tbl(px_line_index)  := TRUNC(p_header_rec.pricing_date);
    END IF;

    g_currency_code_tbl(px_line_index)             := p_header_rec.transactional_curr_code;
    g_price_flag_tbl(px_line_index)                := 'Y';
    g_active_date_first_type_tbl(px_line_index)    := NULL;
    g_active_date_first_tbl(px_line_index)         := NULL;
    g_active_date_second_tbl(px_line_index)        := NULL;
    g_active_date_second_type_tbl(px_line_index)   := NULL;
    g_processed_flag_tbl(px_line_index)            := qp_preq_grp.g_not_processed;
    g_rounding_flag_tbl(px_line_index)             := 'Y';
    g_rounding_factor_tbl(px_line_index)           := NULL;
    g_processing_order_tbl(px_line_index)          := NULL;
    g_pricing_status_code_tbl(px_line_index)       := qp_preq_grp.g_status_unchanged;
    g_pricing_status_text_tbl(px_line_index)       := NULL;
    g_qualifiers_exist_flag_tbl(px_line_index)     := 'N';
    g_pricing_attrs_exist_flag_tbl(px_line_index)  := 'N';
    g_price_list_id_tbl(px_line_index)             := NULL;
    g_pl_validated_flag_tbl(px_line_index)         := 'N';
    g_usage_pricing_type_tbl(px_line_index)        := 'REGULAR';
    g_upd_adjusted_unit_price_tbl(px_line_index)   := NULL;
    g_line_quantity_tbl(px_line_index)             := NULL;
    g_line_uom_code_tbl(px_line_index)             := NULL;
    g_priced_quantity_tbl(px_line_index)           := NULL;
    g_uom_quantity_tbl(px_line_index)              := NULL;
    g_priced_uom_code_tbl(px_line_index)           := NULL;
    g_unit_price_tbl(px_line_index)                := NULL;
    g_percent_price_tbl(px_line_index)             := NULL;
    g_adjusted_unit_price_tbl(px_line_index)       := NULL;
    g_line_category_tbl(px_line_index)             := NULL;
  END copy_header_to_request;

  PROCEDURE copy_line_to_request(
    p_line_rec                        inv_ic_order_pub.line_rec_type
  , p_pricing_events                  VARCHAR2
  , p_request_type_code               VARCHAR2
  , px_line_index       IN OUT NOCOPY NUMBER
  ) IS
    l_uom_rate NUMBER;
    l_debug    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --bug 6700919
    l_return_Status VARCHAR2(1);
    l_msg_data VARCHAR2(255);
    l_msg_count NUMBER;
  BEGIN
    px_line_index                                  := px_line_index + 1;
    g_request_type_code_tbl(px_line_index)         := p_request_type_code;
    g_price_request_code_tbl(px_line_index)        := p_request_type_code;
    g_line_id_tbl(px_line_index)                   := p_line_rec.line_id;
    g_line_index_tbl(px_line_index)                := mod(p_line_rec.header_id + p_line_rec.line_id, 2147483648);
    /* Added mod function for bug 8534865 */
    g_line_type_code_tbl(px_line_index)            := 'LINE';
    g_line_quantity_tbl(px_line_index)             := p_line_rec.ordered_quantity;
    g_line_uom_code_tbl(px_line_index)             := p_line_rec.order_quantity_uom;
    g_priced_quantity_tbl(px_line_index)           := p_line_rec.pricing_quantity;
    g_priced_uom_code_tbl(px_line_index)           := p_line_rec.pricing_quantity_uom;
    g_currency_code_tbl(px_line_index)             := inv_ic_order_pub.g_hdr.transactional_curr_code;
    g_percent_price_tbl(px_line_index)             := p_line_rec.unit_list_percent;
    g_active_date_first_type_tbl(px_line_index)    := NULL;
    g_active_date_first_tbl(px_line_index)         := NULL;
    g_active_date_second_tbl(px_line_index)        := NULL;
    g_active_date_second_type_tbl(px_line_index)   := NULL;
    g_price_flag_tbl(px_line_index)                := 'Y';
    g_processed_flag_tbl(px_line_index)            := qp_preq_grp.g_not_processed;
    g_rounding_flag_tbl(px_line_index)             := 'Y';
    g_rounding_factor_tbl(px_line_index)           := NULL;
    g_processing_order_tbl(px_line_index)          := NULL;
    g_pricing_status_code_tbl(px_line_index)       := qp_preq_grp.g_status_unchanged;
    g_pricing_status_text_tbl(px_line_index)       := NULL;
    g_qualifiers_exist_flag_tbl(px_line_index)     := 'N';
    g_pricing_attrs_exist_flag_tbl(px_line_index)  := 'N';
    g_pl_validated_flag_tbl(px_line_index)         := 'N';
    g_usage_pricing_type_tbl(px_line_index)        := 'REGULAR';
    g_upd_adjusted_unit_price_tbl(px_line_index)   := NULL;
    --    G_PRICE_LIST_ID_TBL(px_line_index) := 11213; -- p_line_rec.price_list_id;
    g_price_list_id_tbl(px_line_index)             := NULL;

     /* bug 6700919 Calling get_transfer_price_date to retreive the date
         by which price list price will be queried*/
     print_debug('MTL_QP_PRICE.copy_line_to_request: Calling get_transfer_price_date');
     g_pricing_effective_date_tbl(px_line_index) := INV_TRANSACTION_FLOW_PUB.get_transfer_price_date(
                p_call                                         => 'E'
               ,p_order_line_id                       =>  p_line_rec.line_id
               ,p_global_procurement_flag => 'N'
               ,p_transaction_id                     => null
	       ,p_drop_ship_flag                   => 'N'
               ,x_return_status                       => l_return_status
               ,x_msg_data                             => l_msg_data
               ,x_msg_count                           => l_msg_count
               );
     print_debug('MTL_QP_PRICE.copy_line_to_request: Tranfer Price Date ='||  g_pricing_effective_date_tbl(px_line_index));

     if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
        print_debug('MTL_QP_PRICE.copy_line_to_request: Error from get_transfer_price_date');
        raise FND_API.G_EXC_ERROR;
    end if;

/*    IF p_line_rec.pricing_date IS NULL
       OR p_line_rec.pricing_date = fnd_api.g_miss_date THEN
      g_pricing_effective_date_tbl(px_line_index)  := TRUNC(SYSDATE);
    ELSE
      Bug 5211087 - populating truncated value of pricing_date in pricing_effective_date
      g_pricing_effective_date_tbl(px_line_index)  := TRUNC(p_line_rec.pricing_date);
    END IF;
*/
    IF (p_line_rec.service_period = p_line_rec.order_quantity_uom) THEN
      g_uom_quantity_tbl(px_line_index)  := p_line_rec.service_duration;
    ELSE
      inv_convert.inv_um_conversion(
        from_unit                    => p_line_rec.service_period
      , to_unit                      => p_line_rec.order_quantity_uom
      , item_id                      => p_line_rec.inventory_item_id
      , uom_rate                     => l_uom_rate
      );
      g_uom_quantity_tbl(px_line_index)  := p_line_rec.service_duration * l_uom_rate;
    END IF;

    /*
        IF p_Line_rec.unit_list_price_per_pqty <> FND_API.G_MISS_NUM THEN
            G_UNIT_PRICE_TBL(px_line_index) := p_Line_rec.unit_list_price_per_pqty;
        ELSIF p_line_rec.unit_list_price <> FND_API.G_MISS_NUM THEN
            G_UNIT_PRICE_TBL(px_line_index) := p_line_rec.unit_list_price;
        ELSE
            G_UNIT_PRICE_TBL(px_line_index) := Null;
        END IF;
        G_ADJUSTED_UNIT_PRICE_TBL(px_line_index) := p_line_rec.unit_selling_price_per_pqty;
    */
    g_unit_price_tbl(px_line_index)                := NULL;
    g_adjusted_unit_price_tbl(px_line_index)       := NULL;
    g_line_category_tbl(px_line_index)             := NULL;
  END copy_line_to_request;

  PROCEDURE populate_temp_table(x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status      VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_return_status_text VARCHAR2(2000);
    i                    NUMBER         := 0;
    l_debug              NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    FOR i IN g_line_index_tbl.FIRST .. g_line_index_tbl.LAST LOOP
      IF (l_debug = 1) THEN
        print_debug(g_line_type_code_tbl(i));
        print_debug('-----------------------------------------------');
        print_debug('line_index               => ' || TO_CHAR(g_line_index_tbl(i)));
        print_debug('pricing_effective_date   => ' || TO_CHAR(g_pricing_effective_date_tbl(i)));
        print_debug('active_date_first        => ' || TO_CHAR(g_active_date_first_tbl(i)));
        print_debug('active_date_first_type   => ' || g_active_date_first_type_tbl(i));
        print_debug('active_date_second       => ' || TO_CHAR(g_active_date_second_tbl(i)));
        print_debug('active_date_second_type  => ' || g_active_date_second_type_tbl(i));
        print_debug('line_quantity            => ' || TO_CHAR(g_line_quantity_tbl(i)));
        print_debug('line_uom_code            => ' || g_line_uom_code_tbl(i));
        print_debug('request_type_code        => ' || g_request_type_code_tbl(i));
        print_debug('PRICED_QUANTITY          => ' || TO_CHAR(g_priced_quantity_tbl(i)));
        print_debug('PRICED_UOM_CODE          => ' || g_priced_uom_code_tbl(i));
        print_debug('CURRENCY_CODE            => ' || g_currency_code_tbl(i));
        print_debug('UNIT_PRICE               => ' || TO_CHAR(g_unit_price_tbl(i)));
        print_debug('PERCENT_PRICE            => ' || TO_CHAR(g_percent_price_tbl(i)));
        print_debug('UOM_QUANTITY             => ' || TO_CHAR(g_uom_quantity_tbl(i)));
        print_debug('ADJUSTED_UNIT_PRICE      => ' || TO_CHAR(g_adjusted_unit_price_tbl(i)));
        print_debug('UPD_ADJUSTED_UNIT_PRICE  => ' || TO_CHAR(g_upd_adjusted_unit_price_tbl(i)));
        print_debug('PROCESSED_FLAG           => ' || g_processed_flag_tbl(i));
        print_debug('price_flag               => ' || g_price_flag_tbl(i));
        print_debug('LINE_ID                  => ' || TO_CHAR(g_line_id_tbl(i)));
        print_debug('PROCESSING_ORDER         => ' || TO_CHAR(g_processing_order_tbl(i)));
        print_debug('pricing_status_code      => ' || SUBSTR(g_pricing_status_code_tbl(i), 1, 5));
        print_debug('PRICING_STATUS_TEXT      => ' || g_pricing_status_text_tbl(i));
        print_debug('ROUNDING_FLAG            => ' || g_rounding_flag_tbl(i));
        print_debug('ROUNDING_FACTOR          => ' || TO_CHAR(g_rounding_factor_tbl(i)));
        print_debug('QUALIFIERS_EXIST_FLAG    => ' || g_qualifiers_exist_flag_tbl(i));
        print_debug('PRICING_ATTRS_EXIST_FLAG => ' || g_pricing_attrs_exist_flag_tbl(i));
        print_debug('PRICE_LIST_ID            => ' || TO_CHAR(g_price_list_id_tbl(i)));
        print_debug('VALIDATED_FLAG           => ' || g_pl_validated_flag_tbl(i));
        print_debug('PRICE_REQUEST_CODE       => ' || g_price_request_code_tbl(i));
        print_debug('USAGE_PRICING_TYPE       => ' || g_usage_pricing_type_tbl(i));
        print_debug('LINE_CATEGORY            => ' || g_line_category_tbl(i));
      END IF;
    END LOOP;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.Populate_Temp_Table: Calling QP:Bulk insert routine...');
    END IF;

    qp_preq_grp.insert_lines2(
      p_line_index                 => g_line_index_tbl
    , p_line_type_code             => g_line_type_code_tbl
    , p_pricing_effective_date     => g_pricing_effective_date_tbl
    , p_active_date_first          => g_active_date_first_tbl
    , p_active_date_first_type     => g_active_date_first_type_tbl
    , p_active_date_second         => g_active_date_second_tbl
    , p_active_date_second_type    => g_active_date_second_type_tbl
    , p_line_quantity              => g_line_quantity_tbl
    , p_line_uom_code              => g_line_uom_code_tbl
    , p_request_type_code          => g_request_type_code_tbl
    , p_priced_quantity            => g_priced_quantity_tbl
    , p_priced_uom_code            => g_priced_uom_code_tbl
    , p_currency_code              => g_currency_code_tbl
    , p_unit_price                 => g_unit_price_tbl
    , p_percent_price              => g_percent_price_tbl
    , p_uom_quantity               => g_uom_quantity_tbl
    , p_adjusted_unit_price        => g_adjusted_unit_price_tbl
    , p_upd_adjusted_unit_price    => g_upd_adjusted_unit_price_tbl
    , p_processed_flag             => g_processed_flag_tbl
    , p_price_flag                 => g_price_flag_tbl
    , p_line_id                    => g_line_id_tbl
    , p_processing_order           => g_processing_order_tbl
    , p_pricing_status_code        => g_pricing_status_code_tbl
    , p_pricing_status_text        => g_pricing_status_text_tbl
    , p_rounding_flag              => g_rounding_flag_tbl
    , p_rounding_factor            => g_rounding_factor_tbl
    , p_qualifiers_exist_flag      => g_qualifiers_exist_flag_tbl
    , p_pricing_attrs_exist_flag   => g_pricing_attrs_exist_flag_tbl
    , p_price_list_id              => g_price_list_id_tbl
    , p_validated_flag             => g_pl_validated_flag_tbl
    , p_price_request_code         => g_price_request_code_tbl
    , p_usage_pricing_type         => g_usage_pricing_type_tbl
    , p_line_category              => g_line_category_tbl
    , x_status_code                => l_return_status
    , x_status_text                => l_return_status_text
    );

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.Populate_Temp_Table: QP_PREQ_GRP.INSERT_LINES2 error ');
        print_debug('MTL_QP_PRICE.Populate_Temp_Table: x_return_status_text=' || l_return_status_text);
      END IF;

      x_return_status  := l_return_status;
      fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
      fnd_message.set_token('ENTITY1', 'QP_PREQ_GRP.INSERT_LINES2');
      fnd_message.set_token('ENTITY2', SUBSTR(l_return_status_text, 1, 150));
      RAISE fnd_api.g_exc_error;
    END IF;

    SELECT COUNT(*)
      INTO i
      FROM qp_preq_lines_tmp;

    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.Populate_Temp_Table: No. of records inserted in QP_PREQ_LINES_TMP=' || TO_CHAR(i));
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.Populate_Temp_Table: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;
  END populate_temp_table;

  PROCEDURE populate_results(p_line_index NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
    i       NUMBER := 0;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    FOR i IN g_line_index_tbl.FIRST .. g_line_index_tbl.LAST LOOP
    BEGIN
        /* OPM bug 4875081*/
 	IF (gml_process_flags.process_orgn = 1
 	AND gml_process_flags.opmitem_flag = 1)
 	AND (g_priced_uom_code_tbl(i) <> g_line_uom_code_tbl(i)) THEN
 	    SELECT lines.order_uom_selling_price
 	         , lines.unit_price
 	         , lines.order_uom_selling_price
 	         , lines.unit_price
 	         , lines.priced_quantity
 	         , lines.priced_uom_code
 	         , lines.price_list_header_id
 	         , NVL(lines.percent_price, NULL)
 	         , NVL(lines.parent_price, NULL)
 	         , DECODE(lines.parent_price, NULL, 0, 0, 0, lines.adjusted_unit_price / lines.parent_price)
 	         , lines.currency_code
 	         , lines.pricing_status_code
 	         , lines.pricing_status_text
 	      INTO g_unit_selling_price_tbl(i)
 	         , g_unit_list_price_tbl(i)
 	         , g_unit_sell_price_per_pqty_tbl(i)
 	         , g_unit_list_price_per_pqty_tbl(i)
 	         , g_pricing_quantity_tbl(i)
 	         , g_priced_uom_code_tbl(i)
 	         , g_price_list_id_tbl(i)
 	         , g_unit_list_percent_tbl(i)
 	         , g_unit_percent_base_price_tbl(i)
 	         , g_unit_selling_percent_tbl(i)
 	         , g_currency_code_tbl(i)
 	         , g_pricing_status_code_tbl(i)
 	         , g_pricing_status_text_tbl(i)
 	      FROM qp_preq_lines_tmp lines
 	     WHERE lines.line_id = g_line_id_tbl(i)
 	       AND lines.line_type_code = g_line_type_code_tbl(i);   /* For bug 4335863 */
 	          /* End OPM bug 4875081*/
 	ELSE
            SELECT lines.adjusted_unit_price
                 , lines.unit_price
                 , lines.adjusted_unit_price
                 , lines.unit_price
                 , lines.priced_quantity
                 , lines.priced_uom_code
                 , lines.price_list_header_id
                 , NVL(lines.percent_price, NULL)
                 , NVL(lines.parent_price, NULL)
                 , DECODE(lines.parent_price, NULL, 0, 0, 0, lines.adjusted_unit_price / lines.parent_price)
                 , lines.currency_code
                 , lines.pricing_status_code
                 , lines.pricing_status_text
              INTO g_unit_selling_price_tbl(i)
                 , g_unit_list_price_tbl(i)
                 , g_unit_sell_price_per_pqty_tbl(i)
                 , g_unit_list_price_per_pqty_tbl(i)
                 , g_pricing_quantity_tbl(i)
                 , g_priced_uom_code_tbl(i)
                 , g_price_list_id_tbl(i)
                 , g_unit_list_percent_tbl(i)
                 , g_unit_percent_base_price_tbl(i)
                 , g_unit_selling_percent_tbl(i)
                 , g_currency_code_tbl(i)
                 , g_pricing_status_code_tbl(i)
                 , g_pricing_status_text_tbl(i)
              FROM qp_preq_lines_tmp lines
             WHERE lines.line_id = g_line_id_tbl(i)
               AND lines.line_type_code = g_line_type_code_tbl(i);   /* For bug 4335863 */
      END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF g_line_type_code_tbl(i) = 'LINE' THEN
            x_return_status  := fnd_api.g_ret_sts_error;

            IF (l_debug = 1) THEN
              print_debug('MTL_QP_PRICE.Populate_Results: UNIT PRICE NOT POPULATED');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              print_debug('MTL_QP_PRICE.Populate_Results: ' || g_line_type_code_tbl(i) || ' NO_DATA_FOUND');
            END IF;
          END IF;
        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.Populate_Results: ' || SQLERRM);
          END IF;
      END;

      IF g_line_type_code_tbl(i) = 'LINE' THEN
        IF g_pricing_status_code_tbl(i) = qp_preq_grp.g_status_updated THEN
          IF (l_debug = 1) THEN
            print_debug('MTL_QP_PRICE.Populate_Results: Unit_Price=' || g_unit_selling_price_tbl(i));
          END IF;
        ELSE
          x_return_status  := fnd_api.g_ret_sts_error;

          IF (l_debug = 1) THEN
            print_debug(
              'MTL_QP_PRICE.Populate_Results: Status_Code=' || g_pricing_status_code_tbl(i) || ' Status_Text='
              || g_pricing_status_text_tbl(i)
            );
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    FOR i IN g_line_index_tbl.FIRST .. g_line_index_tbl.LAST LOOP
      IF (l_debug = 1) THEN
        print_debug(g_line_type_code_tbl(i));
        print_debug('-----------------------------------------------');
        print_debug('PRICING_STATUS_CODE      => ' || g_unit_selling_percent_tbl(i));
        print_debug('UNIT_SELLING_PRICE       => ' || TO_CHAR(g_unit_selling_price_tbl(i)));
        print_debug('UNIT_LIST_PRICE          => ' || TO_CHAR(g_unit_list_price_tbl(i)));
        print_debug('UNIT_SELL_PRICE_PER_PQTY => ' || TO_CHAR(g_unit_sell_price_per_pqty_tbl(i)));
        print_debug('UNIT_LIST_PRICE_PER_PQTY => ' || TO_CHAR(g_unit_list_price_per_pqty_tbl(i)));
        print_debug('PRICING_QUANTITY         => ' || TO_CHAR(g_pricing_quantity_tbl(i)));
        print_debug('PRICING_QUANTITY_UOM     => ' || g_priced_uom_code_tbl(i));
        print_debug('PRICE_LIST_ID            => ' || TO_CHAR(g_price_list_id_tbl(i)));
        print_debug('UNIT_LIST_PERCENT        => ' || TO_CHAR(g_unit_list_percent_tbl(i)));
        print_debug('UNIT_PERCENT_BASE_PRICE  => ' || TO_CHAR(g_unit_percent_base_price_tbl(i)));
        print_debug('UNIT_SELLING_PERCENT     => ' || TO_CHAR(g_unit_selling_percent_tbl(i)));
        print_debug('CURRENCY_CODE            => ' || g_currency_code_tbl(i));
      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.Populate_Results: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END populate_results;

  PROCEDURE print_debug(p_message IN VARCHAR2) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --     dbms_output.put_line(p_message);
    IF (l_debug = 1) THEN
      inv_log_util.TRACE(p_message, 'INV_INTERCOMPANY_INVOICING', 4);
    END IF;
  END print_debug;

  /** J development project - Enhance drop ship project ------------**/
  PROCEDURE copy_proc_header_to_request(
    p_header_rec                      inv_ic_order_pub.proc_header_rec_type
  , p_request_type_code               VARCHAR2
  , px_line_index       IN OUT NOCOPY NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_debug('Start Copy_Proc_Header_To_Request');
    print_debug('p_request_type_code = ' || p_request_type_code);
    print_debug('px_line_index = ' || px_line_index);
    px_line_index                                  := px_line_index + 1;
    g_request_type_code_tbl(px_line_index)         := p_request_type_code;
    g_price_request_code_tbl(px_line_index)        := p_request_type_code;
    g_line_index_tbl(px_line_index)                := p_header_rec.po_header_id;
    g_line_type_code_tbl(px_line_index)            := 'ORDER';
    --  Hold the header_id in line_id for 'HEADER' Records
    g_line_id_tbl(px_line_index)                   := p_header_rec.po_header_id;
    g_pricing_effective_date_tbl(px_line_index)    := TRUNC(SYSDATE);
    g_currency_code_tbl(px_line_index)             := p_header_rec.currency_code;
    g_price_flag_tbl(px_line_index)                := 'Y';
    g_active_date_first_type_tbl(px_line_index)    := NULL;
    g_active_date_first_tbl(px_line_index)         := NULL;
    g_active_date_second_tbl(px_line_index)        := NULL;
    g_active_date_second_type_tbl(px_line_index)   := NULL;
    g_processed_flag_tbl(px_line_index)            := qp_preq_grp.g_not_processed;
    g_rounding_flag_tbl(px_line_index)             := 'Y';
    g_rounding_factor_tbl(px_line_index)           := NULL;
    g_processing_order_tbl(px_line_index)          := NULL;
    g_pricing_status_code_tbl(px_line_index)       := qp_preq_grp.g_status_unchanged;
    g_pricing_status_text_tbl(px_line_index)       := NULL;
    g_qualifiers_exist_flag_tbl(px_line_index)     := 'N';
    g_pricing_attrs_exist_flag_tbl(px_line_index)  := 'N';
    g_price_list_id_tbl(px_line_index)             := NULL;
    g_pl_validated_flag_tbl(px_line_index)         := 'N';
    g_usage_pricing_type_tbl(px_line_index)        := 'REGULAR';
    g_upd_adjusted_unit_price_tbl(px_line_index)   := NULL;
    g_line_quantity_tbl(px_line_index)             := NULL;
    g_line_uom_code_tbl(px_line_index)             := NULL;
    g_priced_quantity_tbl(px_line_index)           := NULL;
    g_uom_quantity_tbl(px_line_index)              := NULL;
    g_priced_uom_code_tbl(px_line_index)           := NULL;
    g_unit_price_tbl(px_line_index)                := NULL;
    g_percent_price_tbl(px_line_index)             := NULL;
    g_adjusted_unit_price_tbl(px_line_index)       := NULL;
    g_line_category_tbl(px_line_index)             := NULL;
    print_debug('END Copy_Proc_Header_To_Request px_line_index = ' || px_line_index);
  END copy_proc_header_to_request;

  PROCEDURE copy_proc_line_to_request(
    p_line_rec                        inv_ic_order_pub.proc_line_rec_type
  , p_pricing_events                  VARCHAR2
  , p_request_type_code               VARCHAR2
  , px_line_index       IN OUT NOCOPY NUMBER
  ) IS
    l_uom_rate NUMBER;
    l_debug    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --bug 6700919
    l_return_Status VARCHAR2(1);
    l_msg_data VARCHAR2(255);
    l_msg_count NUMBER;
  BEGIN
    print_debug('START Copy_Proc_Line_to_Request');
    print_debug('p_pricing_events = ' || p_pricing_events);
    print_debug('p_requst_type_code = ' || p_request_type_code);
    print_debug('px_line_index = ' || px_line_index);
    px_line_index                                  := px_line_index + 1;
    g_request_type_code_tbl(px_line_index)         := p_request_type_code;
    g_price_request_code_tbl(px_line_index)        := p_request_type_code;
    g_line_id_tbl(px_line_index)                   := p_line_rec.po_line_id;
    g_line_index_tbl(px_line_index)                := p_line_rec.po_header_id + p_line_rec.po_line_id;
    g_line_type_code_tbl(px_line_index)            := 'LINE';
    g_line_quantity_tbl(px_line_index)             := p_line_rec.quantity;

    SELECT uom_code
      INTO g_line_uom_code_tbl(px_line_index)
      FROM mtl_units_of_measure
     WHERE unit_of_measure = p_line_rec.unit_meas_lookup_code;

    /* Bug Fix: 4324982*/
    /* Commenting out the below assignment since it is just populated correctly by the above SQL */
    --  G_LINE_UOM_CODE_TBL(px_line_index) := p_Line_rec.primary_uom;
    g_priced_quantity_tbl(px_line_index)           := NULL;
    g_priced_uom_code_tbl(px_line_index)           := g_line_uom_code_tbl(px_line_index);
    g_currency_code_tbl(px_line_index)             := inv_ic_order_pub.g_proc_hdr.currency_code;
    g_percent_price_tbl(px_line_index)             := NULL;
    g_active_date_first_type_tbl(px_line_index)    := NULL;
    g_active_date_first_tbl(px_line_index)         := NULL;
    g_active_date_second_tbl(px_line_index)        := NULL;
    g_active_date_second_type_tbl(px_line_index)   := NULL;
    g_price_flag_tbl(px_line_index)                := 'Y';
    g_processed_flag_tbl(px_line_index)            := qp_preq_grp.g_not_processed;
    g_rounding_flag_tbl(px_line_index)             := 'Y';
    g_rounding_factor_tbl(px_line_index)           := NULL;
    g_processing_order_tbl(px_line_index)          := NULL;
    g_pricing_status_code_tbl(px_line_index)       := qp_preq_grp.g_status_unchanged;
    g_pricing_status_text_tbl(px_line_index)       := NULL;
    g_qualifiers_exist_flag_tbl(px_line_index)     := 'N';
    g_pricing_attrs_exist_flag_tbl(px_line_index)  := 'N';
    g_pl_validated_flag_tbl(px_line_index)         := 'N';
    g_usage_pricing_type_tbl(px_line_index)        := 'REGULAR';
    g_upd_adjusted_unit_price_tbl(px_line_index)   := NULL;
    g_price_list_id_tbl(px_line_index)             := NULL;

     /* bug 6700919 Calling get_transfer_price_date to retreive the date
        by which price list price will be queried*/
     print_debug('MTL_QP_PRICE.copy_proc_line_to_request: Calling get_transfer_price_date');
     g_pricing_effective_date_tbl(px_line_index) := INV_TRANSACTION_FLOW_PUB.get_transfer_price_date(
                p_call                                         => 'E'
               ,p_order_line_id                       =>  p_line_rec.po_line_id
               ,p_global_procurement_flag => 'Y'
               ,p_transaction_id                     => null
	       ,p_drop_ship_flag                   => 'N'
               ,x_return_status                       => l_return_status
               ,x_msg_data                             => l_msg_data
               ,x_msg_count                           => l_msg_count
               );
     print_debug('MTL_QP_PRICE.copy_proc_line_to_request: Tranfer Price Date ='||  g_pricing_effective_date_tbl(px_line_index));

     if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
        print_debug('MTL_QP_PRICE.copy_line_to_request: Error from get_transfer_price_date');
        raise FND_API.G_EXC_ERROR;
    end if;

/*    --IF p_Line_rec.pricing_date IS NULL OR p_Line_rec.pricing_date = fnd_api.g_miss_date THEN
    g_pricing_effective_date_tbl(px_line_index)    := TRUNC(SYSDATE);
    --ELSE
    --    G_PRICING_EFFECTIVE_DATE_TBL(px_line_index) := p_Line_rec.pricing_date;

    --END IF;
*/
    /*IF (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) THEN
        G_UOM_QUANTITY_TBL(px_line_index) := p_Line_rec.service_duration;
    ELSE
        INV_CONVERT.INV_UM_CONVERSION ( From_Unit => p_Line_rec.service_period
                                        , To_Unit => p_Line_rec.Order_quantity_uom
                                        , Item_ID => p_Line_rec.Inventory_item_id
                                        , Uom_Rate => l_Uom_rate);
        G_UOM_QUANTITY_TBL(px_line_index) := p_Line_rec.service_duration * l_uom_rate;

    END IF;*/
    g_uom_quantity_tbl(px_line_index)              := NULL;
    g_unit_price_tbl(px_line_index)                := p_line_rec.unit_price;
    g_adjusted_unit_price_tbl(px_line_index)       := NULL;
    g_line_category_tbl(px_line_index)             := NULL;
  END copy_proc_line_to_request;

  FUNCTION get_transfer_price_ds(
    p_transaction_id    IN            NUMBER
  , p_sell_ou_id        IN            NUMBER
  , p_ship_ou_id        IN            NUMBER
  , p_flow_type         IN            NUMBER
  , p_order_line_id     IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  , p_organization_id   IN            NUMBER
  , p_uom_code          IN            VARCHAR2
  , p_cto_item_flag     IN            VARCHAR2 DEFAULT 'N'
  , p_incr_code         IN            NUMBER
  , p_incrcurrency      IN            VARCHAR2
  , x_currency_code     OUT NOCOPY    VARCHAR2
  , x_tfrpricecode      OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  )
    RETURN NUMBER IS
    l_header_id          NUMBER;
    l_line_id            NUMBER;
    l_inventory_item_id  NUMBER;
    l_organization_id    NUMBER;
    l_transaction_uom    VARCHAR2(3);
    l_primary_uom        VARCHAR2(3);
    l_control_rec        qp_preq_grp.control_record_type;
    l_pricing_event      VARCHAR2(30)                    DEFAULT 'ICBATCH';
    l_request_type_code  VARCHAR2(30)                    DEFAULT 'IC';
    l_line_index         NUMBER                          := 0;
    l_return_status_text VARCHAR2(2000);
    l_version            VARCHAR2(240);
    l_dir                VARCHAR2(2000);
    l_tfrprice           NUMBER;
    l_uom_rate           NUMBER;
    l_doc_type           VARCHAR2(4);   /* OPM Bug 2865040 */
    l_progress           NUMBER;
    l_debug              NUMBER                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    x_currency_code  := ' ';
    x_tfrpricecode   := 1;
    x_msg_count      := 0;
    x_msg_data       := ' ';
    l_tfrprice       := -1;
    print_debug('START MTL_QP_PRICE.Get_Transfer_Price_DS ');
    print_debug('Input Parameters are ');
    print_debug('p_transaction_id = ' || p_transaction_id);
    print_debug('p_sell_ou_id = ' || p_sell_ou_id || ' p_ship_ou_id = ' || p_ship_ou_id);
    print_debug('p_flow_type = ' || p_flow_type);

    IF (p_flow_type = 1) THEN
      print_debug('Calling get_transfer_price for shipping flow ');
      RETURN get_transfer_price(
              p_transaction_id
            , p_sell_ou_id
            , p_ship_ou_id
            , p_order_line_id
            , p_inventory_item_id
            , p_organization_id
            , p_uom_code
            , p_cto_item_flag
            , p_incr_code
            , p_incrcurrency
            , l_request_type_code  -- OPM INVCONV  umoogala
            , l_pricing_event      -- OPM INVCONV  umoogala
            , x_currency_code
            , x_tfrpricecode
            , x_return_status
            , x_msg_count
            , x_msg_data
            );
    ELSE
      -- get po necessary info
      l_progress                                := 1;
      print_debug('Selecting po_line_id, po_header_id, item_id, organization_id and uom_code');
      l_inventory_item_id                       := p_inventory_item_id;
      l_organization_id                         := p_organization_id;
      l_transaction_uom                         := p_uom_code;

      SELECT rcv.po_line_id
           , rcv.po_header_id
        INTO l_line_id
           , l_header_id
        FROM rcv_transactions rcv, po_lines_all pol, mtl_units_of_measure um
       WHERE rcv.transaction_id = p_transaction_id
         AND rcv.po_line_id = pol.po_line_id
         AND rcv.unit_of_measure = um.unit_of_measure;

      IF (l_debug = 1) THEN
        print_debug('l_line_id = ' || l_line_id || ' l_header_id = ' || l_header_id);
        print_debug('MTL_QP_PRICE.get_transfer_price: Selecting Primary UOM...');
      END IF;

      SELECT primary_uom_code
        INTO l_primary_uom
        FROM mtl_system_items
       WHERE inventory_item_id = l_inventory_item_id
         AND organization_id = l_organization_id;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Building Global Structure...');
      END IF;

      g_proc_hdr_initialize(l_header_id, p_incr_code, p_incrcurrency, x_return_status);

      -- Bug 9012871
      -- Made the 2 assignments below based on the suggestion from QP team for the price list selection to go thru.
      inv_ic_order_pub.g_line.ic_selling_org_id               := p_sell_ou_id;
      inv_ic_order_pub.g_line.ic_shipping_org_id              := p_ship_ou_id;

      Print_debug('inv_ic_order_pub.g_line.ic_selling_org_id is:' ||inv_ic_order_pub.g_line.ic_selling_org_id );
      Print_debug('inv_ic_order_pub.g_line.ic_shipping_org_id is:' ||inv_ic_order_pub.g_line.ic_shipping_org_id );

      print_debug('Calling G_PROC_Line_Initialize');
      /* Bug Fix: 4324982*/
      /* Interchanged the order of passing p_ship_ou_id, p_sell_ou_id in the below call to g_proc_line_initialize */
      g_proc_line_initialize(l_line_id, p_ship_ou_id, p_sell_ou_id, l_primary_uom, p_inventory_item_id, p_cto_item_flag, x_return_status);
      qp_price_request_context.set_request_id;
      print_debug('copy_proc_header_to_request');
      copy_proc_header_to_request(p_header_rec => inv_ic_order_pub.g_proc_hdr, p_request_type_code => l_request_type_code
      , px_line_index                => l_line_index);

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Build Context for header...');
      END IF;

      qp_attr_mapping_pub.build_contexts(p_request_type_code => l_request_type_code, p_pricing_type_code => 'H'
      , p_line_index                 => inv_ic_order_pub.g_proc_hdr.po_header_id);
      print_debug('calling copy_proc_line_to_request');
      copy_proc_line_to_request(
        p_line_rec                   => inv_ic_order_pub.g_proc_line
      , p_pricing_events             => l_pricing_event
      , p_request_type_code          => l_request_type_code
      , px_line_index                => l_line_index
      );
      inv_ic_order_pub.g_proc_line.primary_uom  := l_primary_uom;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Build Context for line...');
      END IF;

      qp_attr_mapping_pub.build_contexts(
        p_request_type_code          => l_request_type_code
      , p_pricing_type_code          => 'L'
      , p_line_index                 => inv_ic_order_pub.g_proc_line.po_header_id + inv_ic_order_pub.g_proc_line.po_line_id
      );

      IF l_line_index > 0 THEN
        IF (l_debug = 1) THEN
          print_debug('MTL_QP_PRICE.get_transfer_price: Populating Lines temp table...');
        END IF;

        populate_temp_table(x_return_status);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Initializing control record...');
      END IF;

      l_control_rec.pricing_event               := l_pricing_event;
      l_control_rec.calculate_flag              := qp_preq_grp.g_search_n_calculate;
      l_control_rec.temp_table_insert_flag      := 'N';
      l_control_rec.request_type_code           := l_request_type_code;
      l_control_rec.rounding_flag               := 'Y';
      -- Bug 3070474 (Porting from  Bug 3027452 ): added the following statement
      l_control_rec.use_multi_currency          := 'Y';

      print_debug('MTL_QP_PRICE.get_transfer_price: Assigning value of org_id to l_control_rec...'||p_ship_ou_id);
      --MOAC Changes: Passing the Shipping Operating unit to QP API.
      l_control_rec.org_id      := p_ship_ou_id;
      print_debug('MTL_QP_PRICE.get_transfer_price: After assigning the value of org_id to l_control_rec...'||l_control_rec.org_id);

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Calling QP:Price Request routine ...');
      END IF;

      qp_preq_pub.price_request(p_control_rec => l_control_rec, x_return_status => x_return_status
      , x_return_status_text         => l_return_status_text);

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          print_debug('MTL_QP_PRICE.get_transfer_price: QP_PREQ_PUB.PRICE_REQUEST error ');
          print_debug('MTL_QP_PRICE.get_transfer_price: x_return_status_text=' || l_return_status_text);
        END IF;

        fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
        fnd_message.set_token('ENTITY1', 'QP_PREQ_PUB.PRICE_REQUEST');
        fnd_message.set_token('ENTITY2', SUBSTR(l_return_status_text, 1, 150));
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: Populating QP results ...');
      END IF;

      populate_results(l_line_index, x_return_status);
      x_currency_code                           := g_currency_code_tbl(l_line_index);
      l_tfrprice                                := g_unit_selling_price_tbl(l_line_index);

      IF g_priced_uom_code_tbl(l_line_index) = l_transaction_uom THEN
        x_tfrpricecode  := 1;
      ELSIF g_priced_uom_code_tbl(l_line_index) = l_primary_uom THEN
        x_tfrpricecode  := 2;
      ELSE
        x_tfrpricecode  := 1;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('New Price=' || TO_CHAR(l_tfrprice));
        print_debug('UOM=' || l_transaction_uom);
      END IF;

      RETURN(l_tfrprice);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP NO_DATA_FOUND ');
        print_debug('l_progress = ' || l_progress);
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      x_currency_code  := NULL;
      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP G_EXC_ERROR ');
        print_debug('l_progress = ' || l_progress);
      END IF;

      x_currency_code  := NULL;
      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP G_EXC_UNEXPECTED_ERROR ');
        print_debug('l_progress = ' || l_progress);
      END IF;

      x_currency_code  := NULL;
      RETURN(g_unit_selling_price_tbl(l_line_index));
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.get_transfer_price: EXCEP UNEXP OTHERS - ' || SQLERRM);
        print_debug('l_progress = ' || l_progress);
      END IF;

      x_currency_code  := NULL;
      RETURN(g_unit_selling_price_tbl(l_line_index));
  END get_transfer_price_ds;

  PROCEDURE g_proc_hdr_initialize(
    p_header_id     IN            NUMBER
  , p_incr_code     IN            NUMBER
  , p_incrcurrency  IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    --  Header population
    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Proc_Hdr_Initialize: Populating G_PROC_HDR...  ');
    END IF;

    SELECT po_header_id
         , agent_id
         , type_lookup_code
         , segment1
         , summary_flag
         , enabled_flag
         , segment2
         , segment3
         , segment4
         , segment5
         , start_date_active
         , end_date_active
         , vendor_id
         , vendor_site_id
         , vendor_contact_id
         , ship_to_location_id
         , bill_to_location_id
         , terms_id
         , ship_via_lookup_code
         , fob_lookup_code
         , freight_terms_lookup_code
         , status_lookup_code
         , DECODE(NVL(p_incr_code, 1), 3, currency_code, p_incrcurrency)
         , rate_type
         , rate_date
         , rate
         , from_header_id
         , from_type_lookup_code
         , start_date
         , end_date
         , blanket_total_amount
         , authorization_status
         , revision_num
         , revised_date
         , approved_flag
         , approved_date
         , amount_limit
         , min_release_amount
         , note_to_authorizer
         , note_to_vendor
         , note_to_receiver
         , print_count
         , printed_date
         , vendor_order_num
         , confirming_order_flag
         , comments
         , reply_date
         , reply_method_lookup_code
         , rfq_close_date
         , quote_type_lookup_code
         , quotation_class_code
         , quote_warning_delay_unit
         , quote_warning_delay
         , quote_vendor_quote_number
         , acceptance_required_flag
         , acceptance_due_date
         , closed_date
         , user_hold_flag
         , approval_required_flag
         , cancel_flag
         , firm_status_lookup_code
         , firm_date
         , frozen_flag
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
         , closed_code
         , ussgl_transaction_code
         , government_context
         , org_id
         , supply_agreement_flag
         , edi_processed_flag
         , edi_processed_status
         , global_attribute_category
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , interface_source_code
         , reference_num
         , wf_item_type
         , wf_item_key
         , mrc_rate_type
         , mrc_rate_date
         , mrc_rate
         , pcard_id
         , price_update_tolerance
         , pay_on_code
         , xml_flag
         , xml_send_date
         , xml_change_send_date
         , global_agreement_flag
      INTO inv_ic_order_pub.g_proc_hdr.po_header_id
         , inv_ic_order_pub.g_proc_hdr.agent_id
         , inv_ic_order_pub.g_proc_hdr.type_lookup_code
         , inv_ic_order_pub.g_proc_hdr.segment1
         , inv_ic_order_pub.g_proc_hdr.summary_flag
         , inv_ic_order_pub.g_proc_hdr.enabled_flag
         , inv_ic_order_pub.g_proc_hdr.segment2
         , inv_ic_order_pub.g_proc_hdr.segment3
         , inv_ic_order_pub.g_proc_hdr.segment4
         , inv_ic_order_pub.g_proc_hdr.segment5
         , inv_ic_order_pub.g_proc_hdr.start_date_active
         , inv_ic_order_pub.g_proc_hdr.end_date_active
         , inv_ic_order_pub.g_proc_hdr.vendor_id
         , inv_ic_order_pub.g_proc_hdr.vendor_site_id
         , inv_ic_order_pub.g_proc_hdr.vendor_contact_id
         , inv_ic_order_pub.g_proc_hdr.ship_to_location_id
         , inv_ic_order_pub.g_proc_hdr.bill_to_location_id
         , inv_ic_order_pub.g_proc_hdr.terms_id
         , inv_ic_order_pub.g_proc_hdr.ship_via_lookup_code
         , inv_ic_order_pub.g_proc_hdr.fob_lookup_code
         , inv_ic_order_pub.g_proc_hdr.freight_terms_lookup_code
         , inv_ic_order_pub.g_proc_hdr.status_lookup_code
         , inv_ic_order_pub.g_proc_hdr.currency_code
         , inv_ic_order_pub.g_proc_hdr.rate_type
         , inv_ic_order_pub.g_proc_hdr.rate_date
         , inv_ic_order_pub.g_proc_hdr.rate
         , inv_ic_order_pub.g_proc_hdr.from_header_id
         , inv_ic_order_pub.g_proc_hdr.from_type_lookup_code
         , inv_ic_order_pub.g_proc_hdr.start_date
         , inv_ic_order_pub.g_proc_hdr.end_date
         , inv_ic_order_pub.g_proc_hdr.blanket_total_amount
         , inv_ic_order_pub.g_proc_hdr.authorization_status
         , inv_ic_order_pub.g_proc_hdr.revision_num
         , inv_ic_order_pub.g_proc_hdr.revised_date
         , inv_ic_order_pub.g_proc_hdr.approved_flag
         , inv_ic_order_pub.g_proc_hdr.approved_date
         , inv_ic_order_pub.g_proc_hdr.amount_limit
         , inv_ic_order_pub.g_proc_hdr.min_release_amount
         , inv_ic_order_pub.g_proc_hdr.note_to_authorizer
         , inv_ic_order_pub.g_proc_hdr.note_to_vendor
         , inv_ic_order_pub.g_proc_hdr.note_to_receiver
         , inv_ic_order_pub.g_proc_hdr.print_count
         , inv_ic_order_pub.g_proc_hdr.printed_date
         , inv_ic_order_pub.g_proc_hdr.vendor_order_num
         , inv_ic_order_pub.g_proc_hdr.confirming_order_flag
         , inv_ic_order_pub.g_proc_hdr.comments
         , inv_ic_order_pub.g_proc_hdr.reply_date
         , inv_ic_order_pub.g_proc_hdr.reply_method_lookup_code
         , inv_ic_order_pub.g_proc_hdr.rfq_close_date
         , inv_ic_order_pub.g_proc_hdr.quote_type_lookup_code
         , inv_ic_order_pub.g_proc_hdr.quotation_class_code
         , inv_ic_order_pub.g_proc_hdr.quote_warning_delay_unit
         , inv_ic_order_pub.g_proc_hdr.quote_warning_delay
         , inv_ic_order_pub.g_proc_hdr.quote_vendor_quote_number
         , inv_ic_order_pub.g_proc_hdr.acceptance_required_flag
         , inv_ic_order_pub.g_proc_hdr.acceptance_due_date
         , inv_ic_order_pub.g_proc_hdr.closed_date
         , inv_ic_order_pub.g_proc_hdr.user_hold_flag
         , inv_ic_order_pub.g_proc_hdr.approval_required_flag
         , inv_ic_order_pub.g_proc_hdr.cancel_flag
         , inv_ic_order_pub.g_proc_hdr.firm_status_lookup_code
         , inv_ic_order_pub.g_proc_hdr.firm_date
         , inv_ic_order_pub.g_proc_hdr.frozen_flag
         , inv_ic_order_pub.g_proc_hdr.attribute_category
         , inv_ic_order_pub.g_proc_hdr.attribute1
         , inv_ic_order_pub.g_proc_hdr.attribute2
         , inv_ic_order_pub.g_proc_hdr.attribute3
         , inv_ic_order_pub.g_proc_hdr.attribute4
         , inv_ic_order_pub.g_proc_hdr.attribute5
         , inv_ic_order_pub.g_proc_hdr.attribute6
         , inv_ic_order_pub.g_proc_hdr.attribute7
         , inv_ic_order_pub.g_proc_hdr.attribute8
         , inv_ic_order_pub.g_proc_hdr.attribute9
         , inv_ic_order_pub.g_proc_hdr.attribute10
         , inv_ic_order_pub.g_proc_hdr.attribute11
         , inv_ic_order_pub.g_proc_hdr.attribute12
         , inv_ic_order_pub.g_proc_hdr.attribute13
         , inv_ic_order_pub.g_proc_hdr.attribute14
         , inv_ic_order_pub.g_proc_hdr.attribute15
         , inv_ic_order_pub.g_proc_hdr.closed_code
         , inv_ic_order_pub.g_proc_hdr.ussgl_transaction_code
         , inv_ic_order_pub.g_proc_hdr.government_context
         , inv_ic_order_pub.g_proc_hdr.org_id
         , inv_ic_order_pub.g_proc_hdr.supply_agreement_flag
         , inv_ic_order_pub.g_proc_hdr.edi_processed_flag
         , inv_ic_order_pub.g_proc_hdr.edi_processed_status
         , inv_ic_order_pub.g_proc_hdr.global_attribute_category
         , inv_ic_order_pub.g_proc_hdr.global_attribute1
         , inv_ic_order_pub.g_proc_hdr.global_attribute2
         , inv_ic_order_pub.g_proc_hdr.global_attribute3
         , inv_ic_order_pub.g_proc_hdr.global_attribute4
         , inv_ic_order_pub.g_proc_hdr.global_attribute5
         , inv_ic_order_pub.g_proc_hdr.global_attribute6
         , inv_ic_order_pub.g_proc_hdr.global_attribute7
         , inv_ic_order_pub.g_proc_hdr.global_attribute8
         , inv_ic_order_pub.g_proc_hdr.global_attribute9
         , inv_ic_order_pub.g_proc_hdr.global_attribute10
         , inv_ic_order_pub.g_proc_hdr.global_attribute11
         , inv_ic_order_pub.g_proc_hdr.global_attribute12
         , inv_ic_order_pub.g_proc_hdr.global_attribute13
         , inv_ic_order_pub.g_proc_hdr.global_attribute14
         , inv_ic_order_pub.g_proc_hdr.global_attribute15
         , inv_ic_order_pub.g_proc_hdr.global_attribute16
         , inv_ic_order_pub.g_proc_hdr.global_attribute17
         , inv_ic_order_pub.g_proc_hdr.global_attribute18
         , inv_ic_order_pub.g_proc_hdr.global_attribute19
         , inv_ic_order_pub.g_proc_hdr.global_attribute20
         , inv_ic_order_pub.g_proc_hdr.interface_source_code
         , inv_ic_order_pub.g_proc_hdr.reference_num
         , inv_ic_order_pub.g_proc_hdr.wf_item_type
         , inv_ic_order_pub.g_proc_hdr.wf_item_key
         , inv_ic_order_pub.g_proc_hdr.mrc_rate_type
         , inv_ic_order_pub.g_proc_hdr.mrc_rate_date
         , inv_ic_order_pub.g_proc_hdr.mrc_rate
         , inv_ic_order_pub.g_proc_hdr.pcard_id
         , inv_ic_order_pub.g_proc_hdr.price_update_tolerance
         , inv_ic_order_pub.g_proc_hdr.pay_on_code
         , inv_ic_order_pub.g_proc_hdr.xml_flag
         , inv_ic_order_pub.g_proc_hdr.xml_send_date
         , inv_ic_order_pub.g_proc_hdr.xml_change_send_date
         , inv_ic_order_pub.g_proc_hdr.global_agreement_flag
      FROM po_headers_all
     WHERE po_header_id = p_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Proc_Hdr_Initialize: EXCEP NO_DATA_FOUND ');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Proc_Hdr_Initialize: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END g_proc_hdr_initialize;

  PROCEDURE g_proc_line_initialize(
    p_line_id           IN            NUMBER
  , p_from_org_id       IN            NUMBER
  , p_to_org_id         IN            NUMBER
  , p_primary_uom       IN            VARCHAR2
  , p_inventory_item_id IN            NUMBER
  , p_cto_item_flag     IN            VARCHAR2
  , x_return_status     OUT NOCOPY    VARCHAR2
  ) IS
    l_debug       NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_primary_uom VARCHAR2(3);
  BEGIN
    x_return_status                                   := fnd_api.g_ret_sts_success;

    --  Intercompany fields population
    IF (l_debug = 1) THEN
      print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: Populating IC fields...');
      print_debug('p_to_org_id = ' || p_to_org_id || ' p_from_org_id = ' || p_from_org_id);
      print_debug('p_line_id  = ' || p_line_id || ' p_primary_uom = ' || p_primary_uom);
      print_debug('p_inventory_item_id  = ' || p_inventory_item_id || ' p_cto_item_flag = ' || p_cto_item_flag);
    END IF;

    BEGIN
      SELECT customer_id
           , address_id
           , customer_site_id
           , cust_trx_type_id
           , vendor_id
           , vendor_site_id
           , revalue_average_flag
           , freight_code_combination_id
           , flow_type
           , inventory_accrual_account_id
           , intercompany_cogs_account_id
           , expense_accrual_account_id
        INTO inv_ic_order_pub.g_proc_line.ic_customer_id
           , inv_ic_order_pub.g_proc_line.ic_address_id
           , inv_ic_order_pub.g_proc_line.ic_customer_site_id
           , inv_ic_order_pub.g_proc_line.ic_cust_trx_type_id
           , inv_ic_order_pub.g_proc_line.ic_vendor_id
           , inv_ic_order_pub.g_proc_line.ic_vendor_site_id
           , inv_ic_order_pub.g_proc_line.ic_revalue_average_flag
           , inv_ic_order_pub.g_proc_line.ic_freight_code_combination_id
           , inv_ic_order_pub.g_proc_line.ic_flow_type
           , inv_ic_order_pub.g_proc_line.ic_inventory_accrual_acct_id
           , inv_ic_order_pub.g_proc_line.ic_intercompany_cogs_acct_id
           , inv_ic_order_pub.g_proc_line.ic_expense_accrual_acct_id
        FROM mtl_intercompany_parameters
       WHERE sell_organization_id = p_to_org_id
         AND ship_organization_id = NVL(p_from_org_id, ship_organization_id)
         AND flow_type = 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status  := fnd_api.g_ret_sts_error;

        IF (l_debug = 1) THEN
          print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: IC fields NO_DATA_FOUND...');
        END IF;
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        IF (l_debug = 1) THEN
          print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: IC fields EXCEP UNEXP OTHERS - ' || SQLERRM);
        END IF;
    END;

    print_debug('after getting information from mtl_intercompany_parameters');

    SELECT po_line_id
         , po_header_id
         , line_type_id
         , line_num
         , DECODE(NVL(p_cto_item_flag, 'N'), 'N', item_id, p_inventory_item_id)
         , item_revision
         , category_id
         , item_description
         , unit_meas_lookup_code
         , quantity_committed
         , committed_amount
         , allow_price_override_flag
         , not_to_exceed_price
         , list_price_per_unit
         , unit_price
         , quantity
         , un_number_id
         , hazard_class_id
         , note_to_vendor
         , from_header_id
         , from_line_id
         , min_order_quantity
         , max_order_quantity
         , qty_rcv_tolerance
         , over_tolerance_error_flag
         , market_price
         , unordered_flag
         , closed_flag
         , user_hold_flag
         , cancel_flag
         , cancelled_by
         , cancel_date
         , cancel_reason
         , firm_status_lookup_code
         , firm_date
         , vendor_product_num
         , contract_num
         , taxable_flag
         , tax_name
         , type_1099
         , capital_expense_flag
         , negotiated_by_preparer_flag
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
         , reference_num
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , min_release_amount
         , price_type_lookup_code
         , closed_code
         , price_break_lookup_code
         , ussgl_transaction_code
         , government_context
         , closed_date
         , closed_reason
         , closed_by
         , transaction_reason_code
         , org_id
         , qc_grade
         , base_uom
         , base_qty
         , secondary_uom
         , secondary_qty
         , global_attribute_category
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , line_reference_num
         , project_id
         , task_id
         , expiration_date
         , tax_code_id
         , oke_contract_header_id
         , oke_contract_version_id
         , secondary_quantity
         , secondary_unit_of_measure
         , preferred_grade
         , auction_header_id
         , auction_display_number
         , auction_line_number
         , bid_number
         , bid_line_number
      INTO inv_ic_order_pub.g_proc_line.po_line_id
         , inv_ic_order_pub.g_proc_line.po_header_id
         , inv_ic_order_pub.g_proc_line.line_type_id
         , inv_ic_order_pub.g_proc_line.line_num
         , inv_ic_order_pub.g_proc_line.item_id
         , inv_ic_order_pub.g_proc_line.item_revision
         , inv_ic_order_pub.g_proc_line.category_id
         , inv_ic_order_pub.g_proc_line.item_description
         , inv_ic_order_pub.g_proc_line.unit_meas_lookup_code
         , inv_ic_order_pub.g_proc_line.quantity_committed
         , inv_ic_order_pub.g_proc_line.committed_amount
         , inv_ic_order_pub.g_proc_line.allow_price_override_flag
         , inv_ic_order_pub.g_proc_line.not_to_exceed_price
         , inv_ic_order_pub.g_proc_line.list_price_per_unit
         , inv_ic_order_pub.g_proc_line.unit_price
         , inv_ic_order_pub.g_proc_line.quantity
         , inv_ic_order_pub.g_proc_line.un_number_id
         , inv_ic_order_pub.g_proc_line.hazard_class_id
         , inv_ic_order_pub.g_proc_line.note_to_vendor
         , inv_ic_order_pub.g_proc_line.from_header_id
         , inv_ic_order_pub.g_proc_line.from_line_id
         , inv_ic_order_pub.g_proc_line.min_order_quantity
         , inv_ic_order_pub.g_proc_line.max_order_quantity
         , inv_ic_order_pub.g_proc_line.qty_rcv_tolerance
         , inv_ic_order_pub.g_proc_line.over_tolerance_error_flag
         , inv_ic_order_pub.g_proc_line.market_price
         , inv_ic_order_pub.g_proc_line.unordered_flag
         , inv_ic_order_pub.g_proc_line.closed_flag
         , inv_ic_order_pub.g_proc_line.user_hold_flag
         , inv_ic_order_pub.g_proc_line.cancel_flag
         , inv_ic_order_pub.g_proc_line.cancelled_by
         , inv_ic_order_pub.g_proc_line.cancel_date
         , inv_ic_order_pub.g_proc_line.cancel_reason
         , inv_ic_order_pub.g_proc_line.firm_status_lookup_code
         , inv_ic_order_pub.g_proc_line.firm_date
         , inv_ic_order_pub.g_proc_line.vendor_product_num
         , inv_ic_order_pub.g_proc_line.contract_num
         , inv_ic_order_pub.g_proc_line.taxable_flag
         , inv_ic_order_pub.g_proc_line.tax_name
         , inv_ic_order_pub.g_proc_line.type_1099
         , inv_ic_order_pub.g_proc_line.capital_expense_flag
         , inv_ic_order_pub.g_proc_line.negotiated_by_preparer_flag
         , inv_ic_order_pub.g_proc_line.attribute_category
         , inv_ic_order_pub.g_proc_line.attribute1
         , inv_ic_order_pub.g_proc_line.attribute2
         , inv_ic_order_pub.g_proc_line.attribute3
         , inv_ic_order_pub.g_proc_line.attribute4
         , inv_ic_order_pub.g_proc_line.attribute5
         , inv_ic_order_pub.g_proc_line.attribute6
         , inv_ic_order_pub.g_proc_line.attribute7
         , inv_ic_order_pub.g_proc_line.attribute8
         , inv_ic_order_pub.g_proc_line.attribute9
         , inv_ic_order_pub.g_proc_line.attribute10
         , inv_ic_order_pub.g_proc_line.reference_num
         , inv_ic_order_pub.g_proc_line.attribute11
         , inv_ic_order_pub.g_proc_line.attribute12
         , inv_ic_order_pub.g_proc_line.attribute13
         , inv_ic_order_pub.g_proc_line.attribute14
         , inv_ic_order_pub.g_proc_line.attribute15
         , inv_ic_order_pub.g_proc_line.min_release_amount
         , inv_ic_order_pub.g_proc_line.price_type_lookup_code
         , inv_ic_order_pub.g_proc_line.closed_code
         , inv_ic_order_pub.g_proc_line.price_break_lookup_code
         , inv_ic_order_pub.g_proc_line.ussgl_transaction_code
         , inv_ic_order_pub.g_proc_line.government_context
         , inv_ic_order_pub.g_proc_line.closed_date
         , inv_ic_order_pub.g_proc_line.closed_reason
         , inv_ic_order_pub.g_proc_line.closed_by
         , inv_ic_order_pub.g_proc_line.transaction_reason_code
         , inv_ic_order_pub.g_proc_line.org_id
         , inv_ic_order_pub.g_proc_line.qc_grade
         , inv_ic_order_pub.g_proc_line.base_uom
         , inv_ic_order_pub.g_proc_line.base_qty
         , inv_ic_order_pub.g_proc_line.secondary_uom
         , inv_ic_order_pub.g_proc_line.secondary_qty
         , inv_ic_order_pub.g_proc_line.global_attribute_category
         , inv_ic_order_pub.g_proc_line.global_attribute1
         , inv_ic_order_pub.g_proc_line.global_attribute2
         , inv_ic_order_pub.g_proc_line.global_attribute3
         , inv_ic_order_pub.g_proc_line.global_attribute4
         , inv_ic_order_pub.g_proc_line.global_attribute5
         , inv_ic_order_pub.g_proc_line.global_attribute6
         , inv_ic_order_pub.g_proc_line.global_attribute7
         , inv_ic_order_pub.g_proc_line.global_attribute8
         , inv_ic_order_pub.g_proc_line.global_attribute9
         , inv_ic_order_pub.g_proc_line.global_attribute10
         , inv_ic_order_pub.g_proc_line.global_attribute11
         , inv_ic_order_pub.g_proc_line.global_attribute12
         , inv_ic_order_pub.g_proc_line.global_attribute13
         , inv_ic_order_pub.g_proc_line.global_attribute14
         , inv_ic_order_pub.g_proc_line.global_attribute15
         , inv_ic_order_pub.g_proc_line.global_attribute16
         , inv_ic_order_pub.g_proc_line.global_attribute17
         , inv_ic_order_pub.g_proc_line.global_attribute18
         , inv_ic_order_pub.g_proc_line.global_attribute19
         , inv_ic_order_pub.g_proc_line.global_attribute20
         , inv_ic_order_pub.g_proc_line.line_reference_num
         , inv_ic_order_pub.g_proc_line.project_id
         , inv_ic_order_pub.g_proc_line.task_id
         , inv_ic_order_pub.g_proc_line.expiration_date
         , inv_ic_order_pub.g_proc_line.tax_code_id
         , inv_ic_order_pub.g_proc_line.oke_contract_header_id
         , inv_ic_order_pub.g_proc_line.oke_contract_version_id
         , inv_ic_order_pub.g_proc_line.secondary_quantity
         , inv_ic_order_pub.g_proc_line.secondary_unit_of_measure
         , inv_ic_order_pub.g_proc_line.preferred_grade
         , inv_ic_order_pub.g_proc_line.auction_header_id
         , inv_ic_order_pub.g_proc_line.auction_display_number
         , inv_ic_order_pub.g_proc_line.auction_line_number
         , inv_ic_order_pub.g_proc_line.bid_number
         , inv_ic_order_pub.g_proc_line.bid_line_number
      FROM po_lines_all
     WHERE po_line_id = p_line_id;

    print_debug('after selecting from po_lines_all ');
    print_debug('item_id = ' || inv_ic_order_pub.g_proc_line.item_id || ' organization_id = ' || inv_ic_order_pub.g_proc_line.org_id);
    inv_ic_order_pub.g_proc_line.ic_receiving_org_id  := p_to_org_id;
    inv_ic_order_pub.g_proc_line.ic_procuring_org_id  := p_from_org_id;
    /* Bug Fix: 4324982*/
    /* Copied inv_ic_order_pub.g_proc_line.item_id to inv_ic_order_pub.g_line.inventory_item_id
     * since QP looks at the Item Id passed in G_LINE.inventory_item_id */
    inv_ic_order_pub.g_line.inventory_item_id         := inv_ic_order_pub.g_proc_line.item_id;

    --  Line population
    IF (l_debug = 1) THEN
      print_debug
              ('MTL_QP_PRICE.G_Proc_Line_Initialize: Done Populating G_LINE.inventory_Item_Id from inv_ic_order_pub.g_proc_line.item_id..');
      print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: Done Populating G_PROC_LINE structure...');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: EXCEP NO_DATA_FOUND ');
      END IF;

      fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');
      RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('MTL_QP_PRICE.G_Proc_Line_Initialize: EXCEP UNEXP OTHERS - ' || SQLERRM);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END g_proc_line_initialize;
END mtl_qp_price;

/
