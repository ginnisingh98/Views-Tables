--------------------------------------------------------
--  DDL for Package Body CSI_RMA_FULFILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_RMA_FULFILL_PUB" AS
/* $Header: csipirfb.pls 120.10 2006/02/08 13:50:59 srramakr noship $ */

  g_pkg_name   varchar2(30) := 'csi_rma_fulfill_pub';

    procedure debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => p_api_name,
      p_pkg_name => 'csi_rma_fulfill_pub');
  END api_log;


  PROCEDURE get_rma_info(
    p_rma_line_id    IN  number,
    x_rma_line_rec   OUT NOCOPY csi_order_ship_pub.mtl_txn_rec,
    x_error_message  OUT NOCOPY varchar2,
    x_return_status  OUT NOCOPY varchar2)
  IS
  BEGIN


    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'get_rma_info',
      p_pkg_name => 'csi_rma_fulfill_pub');

    x_rma_line_rec.source_line_id := p_rma_line_id;

    BEGIN

      SELECT oel.line_number ,
             oel.line_id ,
             oeh.order_number,
             oeh.header_id
      INTO   x_rma_line_rec.source_line_ref,
             x_rma_line_rec.source_line_ref_id,
             x_rma_line_rec.source_header_ref,
             x_rma_line_rec.source_header_ref_id
      FROM   oe_order_lines_all oel ,
             oe_order_headers_all oeh
      WHERE  oeh.header_id = oel.header_id
      AND    oel.line_id   = p_rma_line_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_rma_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_error_message := fnd_msg_pub.get;
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', substr(sqlerrm, 240));
      fnd_msg_pub.add;

      x_error_message := fnd_msg_pub.get;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END get_rma_info;


  /*
  */
  PROCEDURE decode_message(
    p_msg_header     IN  xnp_message.msg_header_rec_type,
    p_msg_text       IN  varchar2,
    x_return_status  OUT NOCOPY varchar2,
    x_error_message  OUT NOCOPY varchar2,
    x_rma_line_rec   OUT NOCOPY csi_order_ship_pub.mtl_txn_rec)
  IS

    l_return_status  varchar2(1)     := fnd_api.g_ret_sts_success;
    l_api_name       varchar2(100)   := 'decode_message';
    l_rma_line_id    number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => 'csi_rma_fulfill_pub');

    xnp_xml_utils.decode(p_msg_text, 'RMA_LINE_ID', l_rma_line_id);

    IF nvl(l_rma_line_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      fnd_message.set_name('CSI','CSI_DECODE_MGS_ERROR');
      fnd_message.set_token('MESSAGE_id', p_msg_header.message_id);
      fnd_message.set_token('MESSAGE_CODE', p_msg_header.message_code);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    get_rma_info(
      p_rma_line_id  => l_rma_line_id,
      x_rma_line_rec => x_rma_line_rec,
      x_error_message  => x_error_message,
      x_return_status  => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('CSI_Rma_Fulfill_Pub.Get_rma_Info Failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('CSI_Rma_Fulfill_Pub.Decode_Message Successful');

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN

       x_error_message := fnd_msg_pub.get;
       x_return_status := fnd_api.g_ret_sts_error;

       debug(x_error_message);

     WHEN others THEN

       fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME', g_pkg_name||'.'||l_api_name);
       fnd_message.set_token('SQL_ERROR', substr(sqlerrm, 1, 255));
       fnd_msg_pub.add;

       x_error_message := fnd_msg_pub.get;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       debug(x_error_message);

  END decode_message;

  PROCEDURE rma_fulfillment(
    p_rma_line_id    IN  number,
    p_message_id     IN  number,
    x_return_status  OUT NOCOPY varchar2,
    px_trx_error_rec IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_api_name             varchar2(30) := 'rma_fulfillment';

    l_txn_line_id          number;
    l_txn_sub_type_id      number ;
    l_src_txn_table        varchar2(30) := 'OE_ORDER_LINES_ALL';
    l_txn_type_id          number := 54;
    l_csi_txn_rec          csi_datastructures_pub.transaction_rec;

    l_g_txn_line_query_rec   csi_t_datastructures_grp.txn_line_query_rec;
    l_g_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_g_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_g_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;
    l_g_csi_ea_tbl           csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl          csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;

    l_party_site_id        number;

    l_rma_line_rec       oe_order_lines_all%rowtype;
    l_rma_header_rec     oe_order_headers_all%rowtype;

    l_processing_status    varchar2(30);

    l_found                boolean := FALSE;
    l_inst_ref_found       boolean := TRUE;
    l_shippable_item_flag  varchar2(1)  := 'N';

    l_debug_level          number;
    l_error_message        varchar2(2000);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(32767);
    l_msg_dummy            varchar2(32767);
    l_msg_count            number;
    do_not_process   exception;

    l_error_rec            csi_datastructures_pub.transaction_error_rec;
    l_orgn_id              number;
    l_tld_quantity         number;
    l_canceled_qty         NUMBER;

  BEGIN

    savepoint rma_fulfillment;

    x_return_status := fnd_api.g_ret_sts_success;
    l_error_rec     := px_trx_error_rec;

    fnd_msg_pub.initialize;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    api_log(l_api_name);

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csirmafl',
      p_file_segment2 => p_rma_line_id);

    debug('  Transaction Time   :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type   : RMA Fulfillment');
    debug('  RMA Order Line ID  :'||p_rma_line_id);

    l_error_rec.source_id       := p_rma_line_id;

    BEGIN

      SELECT oel.line_id, oel.header_id, oeh.order_number,
            nvl(oel.sold_from_org_id, oeh.sold_from_org_id),
            nvl(oel.sold_to_org_id, oeh.sold_to_org_id),
            nvl(oel.ship_from_org_id, oeh.ship_from_org_id),
            nvl(oel.invoice_to_contact_id, oeh.invoice_to_contact_id ),
            nvl(oel.ship_to_contact_id, oeh.ship_to_contact_id ),
            oel.line_number, oel.option_number, oel.shipment_number,
            oel.inventory_item_id, oel.item_type_code, oel.shippable_flag,
            oel.org_id, oel.ordered_quantity, oel.fulfilled_quantity,
            oel.fulfillment_date, oel.line_category_code
      INTO   l_rma_line_rec.line_id, l_rma_line_rec.header_id,
             l_rma_header_rec.order_number, l_rma_line_rec.sold_from_org_id,
             l_rma_line_rec.sold_to_org_id, l_rma_line_rec.ship_from_org_id,
             l_rma_line_rec.invoice_to_contact_id, l_rma_line_rec.ship_to_contact_id,
             l_rma_line_rec.line_number, l_rma_line_rec.option_number,
             l_rma_line_rec.shipment_number, l_rma_line_rec.inventory_item_id,
             l_rma_line_rec.item_type_code, l_rma_line_rec.shippable_flag,
             l_rma_line_rec.org_id, l_rma_line_rec.ordered_quantity,
             l_rma_line_rec.fulfilled_quantity, l_rma_line_rec.fulfillment_date,
             l_rma_line_rec.line_category_code
      FROM   oe_order_lines_all oel, oe_order_headers_all oeh
      WHERE  line_id = p_rma_line_id
      AND    oel.header_id = oeh.header_id;
    EXCEPTION
      WHEN no_data_found THEN
        debug('Invalid RMA Order Line ID');
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_rma_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    l_error_rec.source_line_ref_id   := l_rma_line_rec.line_id;
    l_error_rec.source_line_ref      := l_rma_line_rec.line_number||'.'||
                                        l_rma_line_rec.shipment_number||'.'||
                                        l_rma_line_rec.option_number;
    l_error_rec.source_header_ref_id := l_rma_line_rec.header_id;
    l_error_rec.source_header_ref    := l_rma_header_rec.order_number;

    IF l_rma_line_rec.ship_from_org_id is NULL THEN
     IF l_rma_line_rec.sold_from_org_id is NULL THEN
       Begin
        l_orgn_id := oe_sys_parameters.value(
                       param_name => 'MASTER_ORGANIZATION_ID',
                       p_org_id   => l_rma_line_rec.org_id);
       Exception when others then
        debug('Invalid Order line details - org_id: '||l_rma_line_rec.org_id);
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_rma_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
       End;
     ELSE
        l_orgn_id := l_rma_line_rec.sold_from_org_id;
     END IF;
    ELSE
        l_orgn_id := l_rma_line_rec.ship_from_org_id;
    END IF;
    IF l_orgn_id is not null THEN
     Begin

        SELECT nvl(shippable_item_flag ,'N'),
           serial_number_control_code,
           lot_control_code,
           revision_qty_control_code,
           location_control_code,
           comms_nl_trackable_flag
        INTO l_shippable_item_flag,
           l_error_rec.src_serial_num_ctrl_code,
           l_error_rec.src_lot_ctrl_code ,
           l_error_rec.src_rev_qty_ctrl_code,
           l_error_rec.src_location_ctrl_code,
           l_error_rec.comms_nl_trackable_flag
        FROM   mtl_system_items
        WHERE  inventory_item_id = l_rma_line_rec.inventory_item_id
        AND    organization_id   = l_orgn_id;
     Exception when others then
        fnd_message.set_name('CSI', 'CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID', l_rma_line_rec.inventory_item_id);
        fnd_message.set_token('INV_ORGANZATION_ID', l_orgn_id);
        fnd_msg_pub.add;
     End;
    ELSE
        debug('Invalid Organization ID - l_orgn_id: '||l_orgn_id);
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_rma_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.inventory_item_id        := l_rma_line_rec.inventory_item_id;


    debug('RMA Order Information    :');
    debug('  Order_Number       :'||l_rma_header_rec.order_number);
    debug('  Line_Number        :'||l_rma_line_rec.line_number||'.'||l_rma_line_rec.option_number);
    debug('  Sold_to_org_ID     :'||l_rma_line_rec.sold_to_org_id);
    debug('  Inventory_Item_ID  :'||l_rma_line_rec.inventory_item_id);
    debug('  Shippable_flag     :'||l_shippable_item_flag);
    debug('  Ship_From_Org_ID   :'||l_rma_line_rec.ship_from_org_id);
    debug('  Item_Type_Code     :'||l_rma_line_rec.item_type_code);
    debug('  Ordered_Quantity   :'||l_rma_line_rec.ordered_quantity);
    debug('  Fulfilled_Quantity :'||l_rma_line_rec.fulfilled_quantity);
    debug('  Operating_Unit_ID  :'||l_rma_line_rec.org_id);

    dbms_application_info.set_client_info(l_rma_line_rec.org_id);

    IF l_shippable_item_flag is NULL THEN
      debug('Could not determine if the line item is shippable or not for the RMA Fulfillment Line.');
        fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE','Could not determine if the line item is shippable or not for the RMA Fulfillment Line.');
        fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    ELSIF l_shippable_item_flag = 'Y' THEN
		    IF (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
						      'OEOL'        -- ITEM_TYPE
						      ,to_char(l_rma_line_rec.line_id) -- ITEM_KEY
						      ,'OEOL'        -- ACTIVITY_ITEM_TYPE
						      ,'RMA_RECEIVING_SUB'   -- ACTIVITY
						      )) THEN
		       debug('This Line has Receiving Node. Ignoring this line...');
               raise do_not_process;
		    END IF;
--    ELSIF l_rma_line_rec.line_category_code = 'ORDER' THEN commented for testing
--               raise do_not_process;
    END IF;

    l_rma_line_rec.shippable_flag := l_shippable_item_flag;

    -- check transaction details exist
    l_g_txn_line_rec.source_transaction_table := l_src_txn_table;
    l_g_txn_line_rec.source_transaction_id    := p_rma_line_id;

    l_found := csi_t_txn_details_pvt.check_txn_details_exist(
                p_txn_line_rec => l_g_txn_line_rec);

    l_g_txn_line_rec.source_transaction_type_id := l_txn_type_id;

    IF NOT(l_found) THEN
      debug('Transaction detail is Mandatory for RMA Fulfillment and was NOT found for the line.');
      fnd_message.set_name('CSI', 'CSI_RMA_TXN_DTLS_REQD');
      fnd_message.set_token('SRC_TXN_ID', p_rma_line_id);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    -- call the get api
    ELSE
      debug('Transaction Detail Found for the RMA line.');
      BEGIN
        SELECT processing_status
        INTO   l_processing_status
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_table = l_src_txn_table
        AND    source_transaction_id    = p_rma_line_id;

        IF l_processing_status = 'PROCESSED' THEN
          debug('This transaction detail is already PROCESSED.');
          fnd_message.set_name('CSI', 'CSI_TXN_SRC_ALREADY_PROCESSED');
          fnd_message.set_token('SRC_TBL', l_src_txn_table);
          fnd_message.set_token('SRC_ID', p_rma_line_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        UPDATE csi_t_transaction_lines
        SET    processing_status        = 'IN_PROCESS'
        WHERE  source_transaction_table = l_src_txn_table
        AND    source_transaction_id    = p_rma_line_id;

      END;

      -- build the txn_query_rec

      l_g_txn_line_query_rec.source_transaction_table        := l_src_txn_table;
      l_g_txn_line_query_rec.source_transaction_id           := p_rma_line_id;
      l_g_txn_line_detail_query_rec.source_transaction_flag  := 'Y';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_txn_line_query_rec        => l_g_txn_line_query_rec,
        p_txn_line_detail_query_rec => l_g_txn_line_detail_query_rec,
        x_txn_line_detail_tbl       => l_g_line_dtl_tbl,
        p_get_parties_flag          => fnd_api.g_false,
        x_txn_party_detail_tbl      => l_g_pty_dtl_tbl,
        p_get_pty_accts_flag        => fnd_api.g_false,
        x_txn_pty_acct_detail_tbl   => l_g_pty_acct_tbl,
        p_get_ii_rltns_flag         => fnd_api.g_false,
        x_txn_ii_rltns_tbl          => l_g_ii_rltns_tbl,
        p_get_org_assgns_flag       => fnd_api.g_false,
        x_txn_org_assgn_tbl         => l_g_org_assgn_tbl,
        p_get_ext_attrib_vals_flag  => fnd_api.g_false,
        x_txn_ext_attrib_vals_tbl   => l_g_ext_attrib_tbl,
        p_get_csi_attribs_flag      => fnd_api.g_false,
        x_csi_ext_attribs_tbl       => l_g_csi_ea_tbl,
        p_get_csi_iea_values_flag   => fnd_api.g_false,
        x_csi_iea_values_tbl        => l_g_csi_eav_tbl,
        p_get_txn_systems_flag      => fnd_api.g_false,
        x_txn_systems_tbl           => l_g_txn_systems_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('Get transaction details for the RMA line fulfillment failed.');
        raise fnd_api.g_exc_error;
      END IF;
/*
      SELECT transaction_line_id
      INTO   l_g_txn_line_rec.transaction_line_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table = l_src_txn_table
      AND    source_transaction_id    = p_rma_line_id;
*/

      /* check if instance reference is found in the user created txn details
         this is mandatory for a RMA Fulfillment.
      */

      IF l_g_line_dtl_tbl.COUNT > 0 THEN
        l_tld_quantity := 0;
        FOR l_ind in l_g_line_dtl_tbl.FIRST..l_g_line_dtl_tbl.LAST
        LOOP
          IF l_g_line_dtl_tbl(l_ind).instance_id is NULL THEN
            l_inst_ref_found := FALSE;
            exit;
          END IF;
          IF l_g_line_dtl_tbl(l_ind).source_transaction_flag = 'Y' THEN -- changes for bug 3684010
            l_tld_quantity := l_tld_quantity + ABS(l_g_line_dtl_tbl(l_ind).quantity);
          END IF;
        END LOOP;
      END IF;
     -- changes for bug 3684010.Ensuring that Post de fact sales order Qty changes are taken care of
      IF nvl(l_rma_line_rec.fulfilled_quantity,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
            l_canceled_qty := l_rma_line_rec.fulfilled_quantity;
      ELSE
            l_canceled_qty := l_rma_line_rec.ordered_quantity;
      END IF;

      IF  l_tld_quantity <> l_canceled_qty THEN
       IF l_g_line_dtl_tbl.COUNT > 1  THEN
          fnd_message.set_name('CSI', 'CSI_TXN_LINE_DTL_QTY_INVALID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       ELSE
          debug('Canceled Qty as on the Sales Order: '||l_canceled_qty);
          debug('Total Source Txn Details Qty : '||l_tld_quantity);
          l_g_line_dtl_tbl(1).quantity := -1 * l_canceled_qty;

       END IF;
      END IF;
    END IF;
    IF (l_inst_ref_found) THEN
        debug('Instance reference found. RMA fulfillment.');

    --assign the values for the csi_txn_rec
        debug( 'Creating CSI Transaction for the Fulfill RMA Line.');
        l_csi_txn_rec.source_line_ref_id      := l_rma_line_rec.line_id;
        l_csi_txn_rec.source_line_ref         := l_rma_line_rec.line_number||'.'||
                                                 l_rma_line_rec.shipment_number||'.'||
                                                 l_rma_line_rec.option_number;
        l_csi_txn_rec.source_header_ref_id    := l_rma_line_rec.header_id;
        l_csi_txn_rec.source_header_ref       := l_rma_header_rec.order_number;
        l_csi_txn_rec.transaction_type_id     := l_txn_type_id;
        l_csi_txn_rec.transaction_date        := nvl(l_rma_line_rec.fulfillment_date, sysdate);
        l_csi_txn_rec.source_transaction_date := nvl(l_rma_line_rec.fulfillment_date, sysdate);


        csi_t_gen_utility_pvt.dump_api_info(
          p_api_name => 'create_transaction',
          p_pkg_name => 'csi_transactions_pvt');

        csi_transactions_pvt.create_transaction(
          p_api_version            => 1.0,
          p_commit                 => fnd_api.g_false,
          p_init_msg_list          => fnd_api.g_true,
          p_validation_level       => fnd_api.g_valid_level_full,
          p_success_if_exists_flag => 'Y',
          p_transaction_rec        => l_csi_txn_rec,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Create CSI transaction failed for Fulfill RMA Line.');
          RAISE fnd_api.g_exc_error;
        END IF;

        fulfill_rma_line(
          p_rma_line_rec    => l_rma_line_rec,
          p_csi_txn_rec     => l_csi_txn_rec,
          p_line_dtl_tbl    => l_g_line_dtl_tbl,
          px_trx_error_rec  => l_error_rec,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          x_return_status   => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Fulfill RMA Line routine failed.');
          RAISE fnd_api.g_exc_error;
        END IF;
    ELSE
        debug('Instance reference on the Transaction detail is Mandatory for a RMA Fulfillment and was NOT found for the line.');
        fnd_message.set_name('CSI', 'CSI_RMA_INST_REF_REQD');
        fnd_message.set_token('SRC_TXN_ID', p_rma_line_id);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN do_not_process THEN
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN fnd_api.g_exc_error THEN
      rollback to rma_fulfillment;
      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      l_error_rec.error_text := l_error_message;
      debug('Error :'||l_error_rec.error_text);
      px_trx_error_rec := l_error_rec;

      UPDATE csi_t_transaction_lines
      SET    processing_status = 'ERROR'
      WHERE  source_transaction_id = p_rma_line_id
      AND    source_transaction_table = 'OE_ORDER_LINES_ALL';

      csi_utl_pkg.update_txn_line_dtl (
        p_source_trx_id    => p_rma_line_id,
        p_source_trx_table => 'OE_ORDER_LINES_ALL',
        p_api_name         => l_api_name,
        p_error_message    => l_error_message );

    WHEN others THEN
      rollback to rma_fulfillment;
      fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;

      l_error_rec.error_text := l_error_message;
      debug('Error :'||l_error_rec.error_text);
      px_trx_error_rec := l_error_rec;

      UPDATE csi_t_transaction_lines
      SET    processing_status = 'ERROR'
      WHERE  source_transaction_id = p_rma_line_id
      AND    source_transaction_table = 'OE_ORDER_LINES_ALL';

      csi_utl_pkg.update_txn_line_dtl (
        p_source_trx_id    => p_rma_line_id,
        p_source_trx_table => 'OE_ORDER_LINES_ALL',
        p_api_name         => l_api_name,
        p_error_message    => l_error_message );

  End rma_fulfillment;

  PROCEDURE fulfill_rma_line(
    p_rma_line_rec   IN   oe_order_lines_all%rowtype,
    p_csi_txn_rec    IN   csi_datastructures_pub.transaction_rec,
    p_line_dtl_tbl   IN   csi_t_datastructures_grp.txn_line_detail_tbl,
    px_trx_error_rec IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_msg_count      OUT NOCOPY  number,
    x_msg_data       OUT NOCOPY  varchar2,
    x_return_status  OUT NOCOPY  varchar2)
  IS

    l_api_name               varchar2(30) := 'fulfill_rma_line';
    l_txn_type_id            number := 54;
    l_csi_trxn_rec           csi_datastructures_pub.transaction_rec;
    l_txn_sub_type_rec       csi_order_ship_pub.txn_sub_type_rec;
    l_src_line_rec           csi_order_ship_pub.order_line_rec;

    l_txn_line_query_rec     csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_txn_line_rec           csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_rec       csi_t_datastructures_grp.txn_line_detail_rec; -- Added bug 3230999
    l_line_dtl_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl        csi_t_datastructures_grp.txn_systems_tbl;
    l_csi_ea_tbl             csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl            csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;

    l_instance_rec           csi_datastructures_pub.instance_header_rec;
    l_party_header_tbl       csi_datastructures_pub.party_header_tbl;
    l_account_header_tbl     csi_datastructures_pub.party_account_header_tbl;
    l_org_assignments_tbl    csi_datastructures_pub.org_units_header_tbl;
    l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_ext_attrib_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_ext_attrib_def_tbl     csi_datastructures_pub.extend_attrib_tbl;
    l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_header_tbl;
    l_upd_parties_tbl        csi_datastructures_pub.party_tbl;
    l_upd_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;

    -- update_item_instance variables
    l_u_instance_rec        csi_datastructures_pub.instance_rec;
    l_u_parties_tbl         csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list   csi_datastructures_pub.id_tbl;

    l_u_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_u_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_u_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_u_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_u_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_u_eav_tbl              csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

--Processs txn grp variables

    l_p_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_p_parties_tbl            csi_process_txn_grp.txn_i_parties_tbl;
    l_p_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_p_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_p_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_p_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_p_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_p_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_dest_location_rec        csi_process_txn_grp.dest_location_rec;
    l_api_version              NUMBER       := 1.0;
    l_commit                   VARCHAR2(1)  := fnd_api.g_false;
    l_init_msg_list            VARCHAR2(1)  := fnd_api.g_false;
    l_validation_level         NUMBER       := fnd_api.g_valid_level_full;
    l_validate_only_flag       VARCHAR2(1)  := fnd_api.g_false;
    l_in_out_flag              VARCHAR2(30) := 'NONE';
    l_pty_ind                  binary_integer;
    l_pa_ind                   binary_integer;
    l_oa_ind                   binary_integer;
    l_ea_ind                   binary_integer;

    l_error_message          varchar2(32767);
    l_time_stamp             date;
    l_item_srl_code          number;
    l_td_owner_id            number;
    l_inst_owner_pty_id      number;
    l_inst_owner_acct_id     number;
    l_src_txn_owner_pty_id   number;
    l_internal_party_id      number;
    l_owner_pty_ip_id        number;
    l_owner_pty_obj_ver_num  number;
    l_owner_acct_ipa_id      number;
    l_owner_acct_obj_ver_num number;
    l_inst_owner_acct_a_date date;
    l_curr_object_id         number;
    l_object_inst_id         number;
    l_orig_rma_item_id       number;
    l_orig_rma_owner_id      number;
    l_orig_rma_status        varchar2(30);
    l_orig_rma_ref_valid     varchar2(1):= 'Y';

    l_debug_level            number;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_pty_override_flag      varchar2(1) := 'N';
    l_upd_inst_qty           varchar2(1) := 'Y';
    l_msg_data               varchar2(32767);
    l_msg_count              number;
    l_literal1   	     VARCHAR2(30) ;
    l_literal2    	     VARCHAR2(30) ;

    -- added as part of fix for Bug 2733128
    l_chg_instance_rec          csi_datastructures_pub.instance_rec;
    l_chg_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
    l_chg_ext_attrib_val_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
    l_chg_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_chg_inst_asset_tbl        csi_datastructures_pub.instance_asset_tbl;
    l_chg_inst_id_lst           csi_datastructures_pub.id_tbl;
    -- split item instance variables
    l_split_src_inst_rec     csi_datastructures_pub.instance_rec;
    l_split_new_inst_rec     csi_datastructures_pub.instance_rec;
    l_quantity1              NUMBER;
    l_locked_inst_rev_num    NUMBER;
    l_lock_id                NUMBER;
    l_lock_status            NUMBER;
    l_locked                 BOOLEAN;
    l_unlock_inst_tbl        csi_cz_int.config_tbl;
    l_validation_status      VARCHAR2(1);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    savepoint fulfill_rma_line;
    fnd_msg_pub.initialize;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'fulfill_rma_line',
      p_pkg_name => 'csi_rma_fulfill_pub');

    BEGIN
--commented SQL below to make changes for the bug 4028827
/*
      SELECT internal_party_id, ownership_override_at_txn
      INTO   l_internal_party_id, l_pty_override_flag
      FROM   csi_install_parameters;
*/
      l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
      l_pty_override_flag := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

      SELECT party_id
      INTO   l_src_txn_owner_pty_id
      FROM   hz_cust_accounts_all
      WHERE cust_account_id = p_rma_line_rec.sold_to_org_id;

    EXCEPTION
      WHEN others THEN
        fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    l_csi_trxn_rec := p_csi_txn_rec;

    IF p_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN p_line_dtl_tbl.FIRST ..p_line_dtl_tbl.LAST
      LOOP
        IF p_line_dtl_tbl(l_td_ind).instance_id is NOT NULL THEN

          px_trx_error_rec.instance_id   :=  p_line_dtl_tbl(l_td_ind).instance_id;
          px_trx_error_rec.serial_number :=  p_line_dtl_tbl(l_td_ind).serial_number;
          px_trx_error_rec.lot_number    :=  p_line_dtl_tbl(l_td_ind).lot_number;
          l_txn_line_detail_query_rec.txn_line_detail_id :=
            p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_txn_line_query_rec         => l_txn_line_query_rec,
            p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl        => l_line_dtl_tbl,
            p_get_parties_flag           => fnd_api.g_true,
            x_txn_party_detail_tbl       => l_pty_dtl_tbl,
            p_get_pty_accts_flag         => fnd_api.g_true,
            x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
            p_get_ii_rltns_flag          => fnd_api.g_true,
            x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
            p_get_org_assgns_flag        => fnd_api.g_true,
            x_txn_org_assgn_tbl          => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag   => fnd_api.g_true,
            x_txn_ext_attrib_vals_tbl    => l_txn_ext_attrib_tbl,
            p_get_csi_attribs_flag       => fnd_api.g_false,
            x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
            p_get_csi_iea_values_flag    => fnd_api.g_false,
            x_csi_iea_values_tbl         => l_csi_eav_tbl,
            p_get_txn_systems_flag       => fnd_api.g_false,
            x_txn_systems_tbl            => l_txn_systems_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Get transaction details failed for Fulfill RMA Line.');
            RAISE fnd_api.g_exc_error;
          END IF;

        l_txn_line_dtl_rec  := l_line_dtl_tbl(1);--always one record. Query by TLD ID. bug 3230999. changed all references
        l_txn_line_dtl_rec.quantity := p_line_dtl_tbl(l_td_ind).quantity; -- changes for bug 3684010

        debug('  txn_line_detail_tbl.count     :'||l_line_dtl_tbl.count );
        debug('  txn_party_detail_tbl.count    :'||l_pty_dtl_tbl.count );
        debug('  txn_pty_acct_dtl_tbl.count    :'||l_pty_acct_tbl.count);
        debug('  txn_org_assgn_tbl.count       :'||l_org_assgn_tbl.count);
        debug('  txn_ii_rltns_tbl.count        :'||l_ii_rltns_tbl.count);
        debug('  txn_ext_attrib_vals_tbl.count :'||l_txn_ext_attrib_tbl.count);
        debug('  txn_systems_tbl.count         :'||l_txn_systems_tbl.count);

        IF l_debug_level >= 10 THEN

          debug( 'Dumping all the processing tables...');

          csi_t_gen_utility_pvt.dump_txn_tables(
            p_ids_or_index_based => 'I',
            p_line_detail_tbl    => l_line_dtl_tbl,
            p_party_detail_tbl   => l_pty_dtl_tbl,
            p_pty_acct_tbl       => l_pty_acct_tbl,
            p_ii_rltns_tbl       => l_ii_rltns_tbl,
            p_org_assgn_tbl      => l_org_assgn_tbl,
            p_ea_vals_tbl        => l_txn_ext_attrib_tbl);

        END IF;

    IF l_ii_rltns_tbl.count > 0 THEN
     FOR j in l_ii_rltns_tbl.first..l_ii_rltns_tbl.last LOOP

       debug('Validating txn ii_relationships .. ' );

       IF l_txn_line_dtl_rec.txn_line_detail_id = l_ii_rltns_tbl(j).object_id then
         l_object_inst_id := l_txn_line_dtl_rec.instance_id;
         exit;
       END IF;
     END LOOP;

        Begin
          Select object_id
          Into l_curr_object_id
          from csi_ii_relationships
          Where object_id = l_object_inst_id
          And sysdate between nvl(active_end_date, sysdate) and sysdate+1;
        Exception
            when no_data_found THEN
                l_curr_object_id := -9999;
            when others THEN
      		fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      		fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
      		fnd_msg_pub.add;
           	raise fnd_api.g_exc_error;
        End;
         --Check if the object id is being updated, if so raise error

        IF l_curr_object_id <> -9999 THEN
         IF l_curr_object_id <> l_object_inst_id THEN
           fnd_message.set_name('CSI','CSI_INT_OBJ_ID_NOT_ALLOW_UPD');
           fnd_message.set_token('OBJECT_ID',l_object_inst_id);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         END IF;
        END IF;
    END IF;

    /* Get the sub type information for each TLD */

            csi_utl_pkg.get_sub_type_rec(
              p_sub_type_id        => l_txn_line_dtl_rec.sub_type_id,
              p_trx_type_id        => l_txn_type_id,
              x_trx_sub_type_rec   => l_txn_sub_type_rec,
              x_return_status      => l_return_status) ;

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE','Call to the routine csi_utl_pkg.get_sub_type_rec Failed.');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            END IF;

            debug('  transaction_type_id :'||l_txn_sub_type_rec.trx_type_id );
            debug('  default sub_type_id :'||l_txn_sub_type_rec.sub_type_id );

	    --Fix for bug 4243512
	    IF l_txn_sub_type_rec.src_change_owner = 'Y' THEN
                fnd_message.set_name('CSI','CSI_SUB_TYPE_INVALID');
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END IF;
	    --end of fix.


          IF l_pty_dtl_tbl.COUNT > 0 THEN
            FOR l_ind IN l_pty_dtl_tbl.FIRST..l_pty_dtl_tbl.LAST
            LOOP
              IF l_pty_dtl_tbl(l_ind).relationship_type_code = 'OWNER' THEN
                l_td_owner_id := l_pty_dtl_tbl(l_ind).party_source_id;
                exit;
              END IF;
            END LOOP;
          END IF;

          l_instance_rec.instance_id := l_txn_line_dtl_rec.instance_id;

          csi_item_instance_pub.get_item_instance_details(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_get_parties           => fnd_api.g_true,
            p_party_header_tbl      => l_party_header_tbl,
            p_get_accounts          => fnd_api.g_true,
            p_account_header_tbl    => l_account_header_tbl,
            p_get_org_assignments   => fnd_api.g_false,
            p_org_header_tbl        => l_org_assignments_tbl,
            p_get_pricing_attribs   => fnd_api.g_false,
            p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
            p_get_ext_attribs       => fnd_api.g_false,
            p_ext_attrib_tbl        => l_ext_attrib_tbl,
            p_ext_attrib_def_tbl    => l_ext_attrib_def_tbl,
            p_get_asset_assignments => fnd_api.g_false,
            p_asset_header_tbl      => l_asset_assignment_tbl,
            p_time_stamp            => l_time_stamp,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Get item instance details failed for Fulfill RMA Line.');
            RAISE fnd_api.g_exc_error;
          END IF;

          --Initialize the variable
          l_upd_inst_qty := 'Y';

          IF l_party_header_tbl.COUNT > 0 THEN
            FOR p_ind IN l_party_header_tbl.FIRST..l_party_header_tbl.LAST
            LOOP
              IF l_party_header_tbl(p_ind).relationship_type_code = 'OWNER' THEN
                l_inst_owner_pty_id     := l_party_header_tbl(p_ind).party_id;
                l_owner_pty_ip_id       := l_party_header_tbl(p_ind).instance_party_id;
                l_owner_pty_obj_ver_num := l_party_header_tbl(p_ind).object_version_number;
                exit;
              END IF;
            END LOOP;
          ELSE
            debug('Instance Party not found. Instance:'||l_instance_rec.instance_id);
            fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE','Instance Party not found. Instance:'||l_instance_rec.instance_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;


                          -- Bug  4997771
         IF ( l_instance_rec.location_type_code = 'INVENTORY'
	      AND
	      NVL(l_instance_rec.active_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date )
	 THEN

               IF l_inst_owner_pty_id = l_internal_party_id THEN
	          fnd_message.set_name('CSI','CSI_INT_INST_REF_INVALID');
                  fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
               ELSE
                 debug('Location type code is :'||l_instance_rec.location_type_code);
	         fnd_message.set_name('CSI', 'CSI_NON_RETURNABLE_INSTANCE');
                 fnd_message.set_token('LOC_TYPE_CODE', l_instance_rec.location_type_code);
                 fnd_msg_pub.add;
                 raise fnd_api.g_exc_error;
              END IF;
         END IF;



          IF l_account_header_tbl.COUNT > 0 THEN
            FOR a_ind IN l_account_header_tbl.FIRST..l_account_header_tbl.LAST
            LOOP
              IF l_account_header_tbl(a_ind).relationship_type_code = 'OWNER'
                AND l_account_header_tbl(a_ind).instance_party_id = l_owner_pty_ip_id
              THEN
                l_inst_owner_acct_id     := l_account_header_tbl(a_ind).party_account_id;
                l_owner_acct_ipa_id      := l_account_header_tbl(a_ind).ip_account_id;
                l_owner_acct_obj_ver_num := l_account_header_tbl(a_ind).object_version_number;
                l_inst_owner_acct_a_date := l_account_header_tbl(a_ind).active_end_date;
                exit;
              END IF;
            END LOOP;
          ELSE
            debug('Instance Party Account not found. Instance:'||l_instance_rec.instance_id);
          END IF;

          debug('Instance owner party     : '||l_inst_owner_pty_id);
          debug('Instance owner account   : '||l_inst_owner_acct_id);
          debug('Source Txn. owner party  : '||l_src_txn_owner_pty_id);
          debug('Source Txn. owner account: '||p_rma_line_rec.sold_to_org_id);
          debug('Txn detail owner party   : '||l_td_owner_id);
          debug('Internal party           : '||l_internal_party_id);

          IF l_inst_owner_pty_id = l_internal_party_id THEN
            IF nvl(l_txn_sub_type_rec.src_change_owner, 'N') = 'Y' THEN
                fnd_message.set_name('CSI','CSI_INT_INST_REF_INVALID');
                fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error;
            END IF;
          ELSIF l_inst_owner_pty_id <> l_src_txn_owner_pty_id THEN
            IF l_pty_override_flag = 'Y' THEN

                  l_upd_parties_tbl(1).instance_party_id      := l_owner_pty_ip_id;
                  l_upd_parties_tbl(1).object_version_number  := l_owner_pty_obj_ver_num;


                  l_upd_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
                  l_upd_parties_tbl(1).party_id               := l_src_txn_owner_pty_id;
                  l_upd_parties_tbl(1).relationship_type_code := 'OWNER';
                  l_upd_parties_tbl(1).contact_flag           := 'N';
                  l_upd_parties_tbl(1).call_contracts         := fnd_api.g_false;

                  l_upd_pty_accts_tbl(1).ip_account_id        := l_owner_acct_ipa_id;
                  l_upd_pty_accts_tbl(1).object_version_number:= l_owner_acct_obj_ver_num;
                  l_upd_pty_accts_tbl(1).parent_tbl_index     := 1;
                  l_upd_pty_accts_tbl(1).party_account_id     := p_rma_line_rec.sold_to_org_id; -- bug 3693594
                  l_upd_pty_accts_tbl(1).relationship_type_code := 'OWNER';
                  l_upd_pty_accts_tbl(1).call_contracts       := fnd_api.g_false;

        /* Commented the call as part of fix for Bug 2733128. Added call to Update_Item_Instance instead
                  csi_t_gen_utility_pvt.dump_api_info(
                    p_pkg_name => 'csi_party_relationships_pub',
                    p_api_name => 'update_inst_party_relationship');

                  csi_party_relationships_pub.update_inst_party_relationship (
                    p_api_version           => 1.0,
                    p_commit                => fnd_api.g_false,
                    p_init_msg_list         => fnd_api.g_true,
                    p_validation_level      => fnd_api.g_valid_level_full,
                    p_party_tbl             => l_upd_parties_tbl,
                    p_party_account_tbl     => l_upd_pty_accts_tbl,
                    p_txn_rec               => l_csi_trxn_rec,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data);
        */
              -- Transfer the Ownership first to the new RMA Customer and then process
              -- the RMA as a Normal one.
              -- Begin code fix as part of fix for Bug 2733128.

              l_chg_instance_rec.instance_id              := l_instance_rec.instance_id;
              l_chg_instance_rec.object_version_number    := l_instance_rec.object_version_number;
              l_chg_instance_rec.active_end_date          := NUll;
              -- End code fix as part of fix for Bug 2733128.

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_pub',
                p_api_name => 'update_item_instance');

              csi_item_instance_pub.update_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_chg_instance_rec,
                p_ext_attrib_values_tbl => l_chg_ext_attrib_val_tbl,
                p_party_tbl             => l_upd_parties_tbl,
                p_account_tbl           => l_upd_pty_accts_tbl,
                p_pricing_attrib_tbl    => l_chg_pricing_attribs_tbl,
                p_org_assignments_tbl   => l_chg_org_units_tbl,
                p_txn_rec               => l_csi_trxn_rec,
                p_asset_assignment_tbl  => l_chg_inst_asset_tbl,
                x_instance_id_lst       => l_chg_inst_id_lst,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

                  debug('Ownership Changed Successfully.');
            ELSE
                fnd_message.set_name('CSI','CSI_RMA_OWNER_MISMATCH');
                fnd_message.set_token('INSTANCE_ID', l_instance_rec.instance_id );
                fnd_message.set_token('OLD_PARTY_ID', l_inst_owner_pty_id );
                fnd_message.set_token('NEW_PARTY_ID', l_src_txn_owner_pty_id );
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
/* Bug 3746600. Since Cancellation is always a expiry now, we do not need the code below. commenting.
          ELSE -- inst party = source txn party AND instance is valid - Normal case
            IF ( l_txn_line_dtl_rec.reference_source_id is NOT NULL
               AND l_txn_line_dtl_rec.reference_source_line_id is NOT NULL)
               AND nvl(p_rma_line_rec.shippable_flag, 'N') = 'Y'
            THEN
              Begin
               Select inventory_item_id, flow_status_code, sold_to_org_id
               Into l_orig_rma_item_id, l_orig_rma_status, l_orig_rma_owner_id
               From oe_order_lines_all
               Where line_id = l_txn_line_dtl_rec.reference_source_line_id
               And header_id = l_txn_line_dtl_rec.reference_source_id;
              Exception When others Then
                l_orig_rma_ref_valid := 'N';
              End;

              IF l_orig_rma_ref_valid = 'Y' THEN
               IF ( l_orig_rma_owner_id = l_inst_owner_acct_id)
                AND (l_orig_rma_item_id = l_instance_rec.inventory_item_id)
               THEN
    	        IF (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
			'OEOL'        -- ITEM_TYPE
			,to_char(l_txn_line_dtl_rec.reference_source_line_id) -- ITEM_KEY
			,'OEOL'        -- ACTIVITY_ITEM_TYPE
			,'RMA_RECEIVING_SUB'   -- ACTIVITY
			))
		THEN
                  l_upd_inst_qty := 'N';
    	    	  debug('This Line had a Receiving Node and hence would have had updated IB...');
    	    	  debug('Not updating IB Quantity ...');

		END IF;
               ELSE
  	    	      debug('Ref. RMA attributes do not match. Updating IB anyway ...');
               END IF;
              ELSE
    	          debug('Could not fime Ref. RMA details . Updating IB anyway ...');
              END IF;

              IF NOT (sysdate between nvl(l_instance_rec.active_end_date, sysdate)
               AND sysdate+1) THEN
               IF l_instance_rec.quantity <= 0 THEN
                IF l_instance_rec.quantity = 0 THEN
                  l_u_instance_rec.active_end_date := NULL;
                  l_u_instance_rec.quantity := ABS(l_txn_line_dtl_rec.quantity);
                  Begin
                   SELECT object_version_number
                   INTO   l_u_instance_rec.object_version_number
                   FROM   csi_item_instances
                   WHERE  instance_id = l_instance_rec.instance_id;
                  Exception when others then
    	    	     debug('Fetch instance details failed ...');
      		     fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      		     fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
      		     fnd_msg_pub.add;
                     raise fnd_api.g_exc_unexpected_error;
                  End;

                  csi_t_gen_utility_pvt.dump_api_info(
                      p_pkg_name => 'csi_item_instance_pub',
                      p_api_name => 'update_item_instance');

                  csi_item_instance_pub.update_item_instance(
                      p_api_version           => 1.0,
                      p_commit                => fnd_api.g_false,
                      p_init_msg_list         => fnd_api.g_true,
                      p_validation_level      => fnd_api.g_valid_level_full,
                      p_instance_rec          => l_u_instance_rec,
                      p_party_tbl             => l_u_parties_tbl,
                      p_account_tbl           => l_u_pty_accts_tbl,
                      p_org_assignments_tbl   => l_u_org_units_tbl,
                      p_ext_attrib_values_tbl => l_u_ea_values_tbl,
                      p_pricing_attrib_tbl    => l_u_pricing_tbl,
                      p_asset_assignment_tbl  => l_u_assets_tbl,
                      p_txn_rec               => l_csi_trxn_rec,
                      x_instance_id_lst       => l_u_instance_ids_list,
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;
                ELSE
  	    	  debug('Instance Quantity is -ve already. Error??');
                  l_upd_inst_qty := 'N';
                  --RAISE fnd_api.g_exc_error;
                END IF;
               ELSE --Not sure about the case??
                  l_p_instances_tbl(l_td_ind).active_end_date := NULL;
                  l_upd_inst_qty := 'N';
               END IF;
              END IF; -- end dated instance

            END IF;
          END IF;
    Bug 3746600 Changes End. */

        IF p_rma_line_rec.ship_from_org_id is NOT NULL THEN
            l_dest_location_rec.inv_organization_id := p_rma_line_rec.ship_from_org_id;
        ELSIF p_rma_line_rec.sold_from_org_id is NOT NULL THEN
            l_dest_location_rec.inv_organization_id := p_rma_line_rec.sold_from_org_id;
        ELSIF l_txn_line_dtl_rec.inv_organization_id is NOT NULL THEN
            l_dest_location_rec.inv_organization_id := l_txn_line_dtl_rec.inv_organization_id;
        ELSE
            l_dest_location_rec.inv_organization_id := l_instance_rec.vld_organization_id;
        END IF;

        Begin
            Select serial_number_control_code
            into l_item_srl_code
            from mtl_system_items_b
            where inventory_item_id = l_txn_line_dtl_rec.inventory_item_id
            and organization_id = l_dest_location_rec.inv_organization_id;--l_txn_line_dtl_rec.inv_organization_id;
            -- bug 3230999. since OM is always passing master inv.
         Exception when others Then
            debug('Could not determine serial control policy?');
	    fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      	    fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
      	    fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        End;

          l_p_instances_tbl(l_td_ind).instance_id := l_txn_line_dtl_rec.instance_id;
 	  IF ( nvl(l_instance_rec.active_end_date,fnd_api.g_miss_date) <>  fnd_api.g_miss_date
	        AND l_instance_rec.active_end_date < sysdate ) THEN -- Added this new check, IF as part of 3746600
   	   IF l_instance_rec.instance_usage_code <> 'IN_RELATIONSHIP' THEN
	    -- ONLY excluding Components since they get expired along with their parent in a config cancellation
              fnd_message.set_name('CSI','CSI_TXN_INVALID_INST_REF');
              fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	   END IF;
          ELSIF l_item_srl_code = 1 THEN
	    IF abs(l_txn_line_dtl_rec.quantity) > l_instance_rec.quantity THEN
            -- check if the quantity is greater than the instance quantity
              fnd_message.set_name('CSI','CSI_INT_QTY_CHK_FAILED');
              fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
	    ELSIF l_instance_rec.quantity > abs(l_txn_line_dtl_rec.quantity) THEN -- need to split the source cust prod first
              debug('Original Instance Quantity: '||l_instance_rec.quantity);
               l_quantity1 := l_instance_rec.quantity - abs(l_txn_line_dtl_rec.quantity) ;

               l_split_src_inst_rec.instance_id           := l_instance_rec.instance_id;
               l_csi_trxn_rec.split_reason_code := 'PARTIAL_RETURN';

               csi_t_gen_utility_pvt.dump_api_info(
                   p_pkg_name => 'csi_item_instance_pvt',
                   p_api_name => 'split_item_instance');

               csi_item_instance_pvt.split_item_instance (
                   p_api_version            => 1.0,
                   p_commit                 => fnd_api.g_false,
                   p_init_msg_list          => fnd_api.g_true,
                   p_validation_level       => fnd_api.g_valid_level_full,
                   p_source_instance_rec    => l_split_src_inst_rec,
                   p_quantity1              => l_quantity1,
                   p_quantity2              => abs(l_txn_line_dtl_rec.quantity),
                   p_copy_ext_attribs       => fnd_api.g_true,
                   p_copy_org_assignments   => fnd_api.g_true,
                   p_copy_parties           => fnd_api.g_true,
                   p_copy_accounts          => fnd_api.g_true,
                   p_copy_asset_assignments => fnd_api.g_true,
                   p_copy_pricing_attribs   => fnd_api.g_true,
                   p_txn_rec                => l_csi_trxn_rec,
                   x_new_instance_rec       => l_split_new_inst_rec,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data);

                IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
                   debug('csi_item_instance_pvt.split_item_instance raised errors');
                   raise fnd_api.g_exc_error;
                END IF;

                l_p_instances_tbl(l_td_ind).instance_id  		:= l_split_new_inst_rec.instance_id ;
                l_p_instances_tbl(l_td_ind).object_version_number := l_split_new_inst_rec.object_version_number;
                debug('New Instance ID: '||l_split_new_inst_rec.instance_id
                       ||' New Instance Qty.: '||l_split_new_inst_rec.quantity);
	    ELSE -- bug 3746600
                debug('Complete Cancellation, Expiring: '||l_instance_rec.instance_id);
	    END IF;
          END IF;
          -- update the transaction line detail table with the inprocess status
          l_u_txn_line_rec.transaction_line_id := p_line_dtl_tbl(l_td_ind).transaction_line_id;

          l_u_line_dtl_tbl(l_td_ind).txn_line_detail_id  := p_line_dtl_tbl(l_td_ind).txn_line_detail_id;
          l_u_line_dtl_tbl(l_td_ind).transaction_line_id := p_line_dtl_tbl(l_td_ind).transaction_line_id;
          l_u_line_dtl_tbl(l_td_ind).processing_status   := 'IN_PROCESS';

        END IF; -- l_td.instance_id is not null

    -- Building process txn tables
        l_csi_trxn_rec.txn_sub_type_id     := l_txn_line_dtl_rec.sub_type_id;
        l_p_instances_tbl(l_td_ind).inventory_item_id := l_txn_line_dtl_rec.inventory_item_id;
        l_p_instances_tbl(l_td_ind).vld_organization_id := l_dest_location_rec.inv_organization_id;
        l_p_instances_tbl(l_td_ind).last_oe_rma_line_id := p_rma_line_rec.line_id;

        IF l_txn_line_dtl_rec.source_transaction_flag = 'Y' THEN
            l_p_instances_tbl(l_td_ind).ib_txn_segment_flag := 'S';
            l_p_instances_tbl(l_td_ind).last_txn_line_detail_id := l_txn_line_dtl_rec.txn_line_detail_id;
        ELSE
            l_p_instances_tbl(l_td_ind).ib_txn_segment_flag := 'N';
        END IF;

 	    -- debug('l_upd_inst_qty :'||l_upd_inst_qty); bug 3746600

        IF l_item_srl_code <> 1 THEN
              -- serialized. Not sure of a case of serialized and non shippable item!!
            l_p_instances_tbl(l_td_ind).quantity := 1; -- the quantity is always 1
            l_p_instances_tbl(l_td_ind).active_end_date := sysdate; -- so that the serialized instance is expired
        -- ELSIF l_upd_inst_qty = 'N' THEN bug 3746600
        ELSE
            l_p_instances_tbl(l_td_ind).quantity := 0; -- so that the quantity is not reduced to 0
            l_p_instances_tbl(l_td_ind).active_end_date := sysdate; -- so that the instance is expired
        -- ELSE bug 3746600
        --    l_p_instances_tbl(l_td_ind).quantity := ABS(l_txn_line_dtl_rec.quantity);
        END IF;

     -- this is to make sure RMA fulfillment does NOT ever change the location to INV
        l_p_instances_tbl(l_td_ind).inv_organization_id := NULL;
        l_p_instances_tbl(l_td_ind).inv_subinventory_name := NULL;
        l_p_instances_tbl(l_td_ind).inv_locator_id := NULL;

        l_pty_ind := 1;
        l_pa_ind  := 1;

        IF l_pty_dtl_tbl.COUNT > 0 THEN
          FOR l_pd_ind IN l_pty_dtl_tbl.FIRST .. l_pty_dtl_tbl.LAST
          LOOP
            debug('Building TD party rec '||l_pty_ind||' for process transaction.');

              l_p_parties_tbl(l_pty_ind).parent_tbl_index   := l_td_ind;
              l_p_parties_tbl(l_pty_ind).party_source_table :=
                                         l_pty_dtl_tbl(l_pd_ind).party_source_table;
              l_p_parties_tbl(l_pty_ind).party_id           :=
                                         l_pty_dtl_tbl(l_pd_ind).party_source_id;
              l_p_parties_tbl(l_pty_ind).instance_party_id           :=
                                         l_pty_dtl_tbl(l_pd_ind).instance_party_id;
              l_p_parties_tbl(l_pty_ind).relationship_type_code :=
                                         l_pty_dtl_tbl(l_pd_ind).relationship_type_code;
              l_p_parties_tbl(l_pty_ind).contact_flag       :=
                                         l_pty_dtl_tbl(l_pd_ind).contact_flag;

            IF l_pty_acct_tbl.COUNT > 0 THEN

             FOR l_pad_ind IN l_pty_acct_tbl.FIRST .. l_pty_acct_tbl.LAST
             LOOP
              IF l_pty_acct_tbl(l_pad_ind).txn_party_detail_id = l_pty_dtl_tbl(l_pd_ind).txn_party_detail_id THEN

                    debug('Building TD account rec '||l_pa_ind||' for process transaction.');

                  l_p_ip_accounts_tbl(l_pa_ind).parent_tbl_index       := l_pty_ind;
                  l_p_ip_accounts_tbl(l_pa_ind).party_account_id       := l_pty_acct_tbl(l_pad_ind).account_id;
                  l_p_ip_accounts_tbl(l_pa_ind).ip_account_id       := l_pty_acct_tbl(l_pad_ind).ip_account_id;
                  l_p_ip_accounts_tbl(l_pa_ind).relationship_type_code := l_pty_acct_tbl(l_pad_ind).relationship_type_code;
                  l_p_ip_accounts_tbl(l_pa_ind).bill_to_address       := l_pty_acct_tbl(l_pad_ind).bill_to_address_id;
                  l_p_ip_accounts_tbl(l_pa_ind).ship_to_address       := l_pty_acct_tbl(l_pad_ind).ship_to_address_id;
                  l_p_ip_accounts_tbl(l_pa_ind).active_end_date       := l_pty_acct_tbl(l_pad_ind).active_end_date;

                  l_pa_ind := l_pa_ind + 1;
              END IF;
             END LOOP;  -- pty_acct_tbl loop
            END IF; -- l_pty_acct_tbl.count > 0

            l_pty_ind := l_pty_ind + 1;
          END LOOP; -- pty_dtl_tbl loop
         END IF; -- pty_dtl_tbl.count > 0
      END LOOP; -- td loop

        -- updating txn dtls to IN_PROCESS. moved this code down here from inside the loop
        csi_t_txn_details_grp.update_txn_line_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            p_txn_line_rec             => l_u_txn_line_rec,
            p_txn_line_detail_tbl      => l_u_line_dtl_tbl,
            px_txn_ii_rltns_tbl        => l_u_ii_rltns_tbl,
            px_txn_party_detail_tbl    => l_u_pty_dtl_tbl,
            px_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
            px_txn_org_assgn_tbl       => l_u_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_u_eav_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Update txn line dtls failed for Fulfill RMA Line.');
            RAISE fnd_api.g_exc_error;
        END IF;
        --
        -- srramakr TSO with Equipment
        -- For Shippable Items, if RMA fulfillment is performed then we need to remove the config keys
        -- of the underlying instance
        --
        IF NVL(p_rma_line_rec.shippable_flag,'N') = 'Y' THEN
	   IF l_p_instances_tbl.count > 0 THEN
	      FOR J in l_p_instances_tbl.FIRST .. l_p_instances_tbl.LAST LOOP
		 IF l_p_instances_tbl(J).instance_id IS NOT NULL AND
		    l_p_instances_tbl(J).instance_id <> FND_API.G_MISS_NUM THEN
		    l_lock_id := NULL;
		    l_lock_status := NULL;
		    l_locked_inst_rev_num := NULL;
                    l_p_instances_tbl(J).config_inst_hdr_id := null;
                    l_p_instances_tbl(J).config_inst_item_id := null;
                    l_p_instances_tbl(J).config_inst_rev_num := null;
                    l_locked := FALSE;
                    --
		    Begin
		       select cil.lock_id,cil.lock_status,
			      cil.config_inst_rev_num
		       into l_lock_id,l_lock_status,
			    l_locked_inst_rev_num
		       from CSI_ITEM_INSTANCE_LOCKS cil
		       where cil.instance_id = l_p_instances_tbl(J).instance_id
		       and   cil.lock_status <> 0;
		       --
		       l_locked := TRUE;
		    Exception
		       when no_data_found then
			  l_locked := FALSE;
		    End;
		    --
		    select config_inst_hdr_id,config_inst_item_id,config_inst_rev_num,
                           instance_usage_code,active_end_date
		    into l_p_instances_tbl(J).config_inst_hdr_id,
                         l_p_instances_tbl(J).config_inst_item_id,
			 l_p_instances_tbl(J).config_inst_rev_num,
                         l_p_instances_tbl(J).instance_usage_code,
                         l_p_instances_tbl(J).active_end_date
		    from CSI_ITEM_INSTANCES
		    where instance_id = l_p_instances_tbl(J).instance_id;
		    --
		    IF l_locked = TRUE THEN
		       -- Instance is in Locked Status
		       l_unlock_inst_tbl.DELETE;
                       l_unlock_inst_tbl(1).source_application_id := 542;
		       l_unlock_inst_tbl(1).lock_id := l_lock_id;
		       l_unlock_inst_tbl(1).lock_status := l_lock_status;
		       l_unlock_inst_tbl(1).instance_id := l_p_instances_tbl(J).instance_id;
                       l_unlock_inst_tbl(1).source_txn_header_ref := l_csi_trxn_rec.source_header_ref_id;
                       l_unlock_inst_tbl(1).source_txn_line_ref1 := l_csi_trxn_rec.source_line_ref_id;
		       --
		       debug('Calling Unlock Item Instances for Instance Id '||to_char(l_p_instances_tbl(J).instance_id));
		       CSI_ITEM_INSTANCE_GRP.unlock_item_instances
			   (
			     p_api_version        => 1.0
			    ,p_commit             => l_commit
			    ,p_init_msg_list      => l_init_msg_list
			    ,p_validation_level   => l_validation_level
			    ,p_config_tbl         => l_unlock_inst_tbl
			    ,x_return_status      => l_return_status
			    ,x_msg_count          => l_msg_count
			    ,x_msg_data           => l_msg_data
			   );
		       IF l_return_status <> fnd_api.g_ret_sts_success THEN
			  debug('Unlock Item Instances routine failed.');
			  RAISE fnd_api.g_exc_error;
		       END IF;
		       --
		       -- Update any pending TLD for the same config keys (fetched from lock table)
		       -- with the instance_id so that when regular fulfillment happens for this
		       -- tangible item (DISCONNECT), only the order line_id will be updated in the item instance
		       Update CSI_T_TXN_LINE_DETAILS
		       Set changed_instance_id = l_p_instances_tbl(J).instance_id
		          ,overriding_csi_txn_id = l_csi_trxn_rec.transaction_id
		       Where config_inst_hdr_id = l_p_instances_tbl(J).config_inst_hdr_id
		       and   config_inst_item_id = l_p_instances_tbl(J).config_inst_item_id
		       and   config_inst_rev_num = l_locked_inst_rev_num
		       and   nvl(processing_status,'$#$') = 'SUBMIT';
                    END IF; -- if Locked
		    --
                    IF nvl(l_p_instances_tbl(J).instance_usage_code,'$#$') = 'IN_RELATIONSHIP' AND
                       nvl(l_p_instances_tbl(J).active_end_date,(sysdate+1)) > sysdate AND
                       l_p_instances_tbl(J).config_inst_hdr_id IS NOT NULL AND
                       l_p_instances_tbl(J).config_inst_item_id IS NOT NULL AND
                       l_p_instances_tbl(J).config_inst_rev_num IS NOT NULL THEN
		       -- Call CZ API for Notification
                       debug('Calling CZ_IB_TSO_GRP.Remove_Returned_Config_Item...');
		       CZ_IB_TSO_GRP.Remove_Returned_Config_Item
			  ( p_instance_hdr_id         =>  l_p_instances_tbl(J).config_inst_hdr_id,
			    p_instance_rev_nbr        =>  l_p_instances_tbl(J).config_inst_rev_num,
			    p_returned_config_item_id =>  l_p_instances_tbl(J).config_inst_item_id,
			    p_locked_instance_rev_nbr =>  l_locked_inst_rev_num,
			    p_application_id          =>  542,
			    p_config_eff_date         =>  sysdate,
			    x_validation_status       =>  l_validation_status,
			    x_return_status           =>  l_return_status,
			    x_msg_count               =>  l_msg_count,
			    x_msg_data                =>  l_msg_data
			  );
		       IF l_return_status <> fnd_api.g_ret_sts_success THEN
			  debug('Remove_Returned_Config_Item routine failed.');
			  RAISE fnd_api.g_exc_error;
		       END IF;
                    END IF;
		 END IF;
		 --
		 -- Nullify the Config Keys
		 l_p_instances_tbl(J). CONFIG_INST_HDR_ID := NULL;
		 l_p_instances_tbl(J). CONFIG_INST_REV_NUM := NULL;
		 l_p_instances_tbl(J). CONFIG_INST_ITEM_ID := NULL;
	      END LOOP;
	   END IF;
        END IF; -- End of shippable_flag check
        --
        csi_process_txn_grp.process_transaction (
          p_api_version             => l_api_version,
          p_commit                  => l_commit,
          p_init_msg_list           => l_init_msg_list,
          p_validation_level        => l_validation_level,
          p_validate_only_flag      => l_validate_only_flag,
          p_in_out_flag             => l_in_out_flag,
          p_dest_location_rec       => l_dest_location_rec,
          p_txn_rec                 => l_csi_trxn_rec,
          p_instances_tbl           => l_p_instances_tbl,
          p_i_parties_tbl           => l_p_parties_tbl,
          p_ip_accounts_tbl         => l_p_ip_accounts_tbl,
          p_org_units_tbl           => l_p_org_units_tbl,
          p_ext_attrib_vlaues_tbl   => l_p_ext_attrib_values_tbl,
          p_pricing_attribs_tbl     => l_p_pricing_attribs_tbl,
          p_instance_asset_tbl      => l_p_instance_asset_tbl,
          p_ii_relationships_tbl    => l_p_ii_relationships_tbl,
          px_txn_error_rec          => px_trx_error_rec,
          x_return_status           => l_return_status,
          x_msg_count               => l_msg_count,
          x_msg_data                => l_msg_data );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Process Transaction call failed for Fulfill RMA Line.');
            RAISE fnd_api.g_exc_error;
        END IF;
        Begin

         --Assign the literals.. bug 4311676
         l_literal1 := 'IN_PROCESS';
         l_literal2 := 'OE_ORDER_LINES_ALL';

            UPDATE csi_t_txn_line_details a
            SET error_code = NULL,
               error_explanation = NULL,
               processing_status = 'PROCESSED',
               csi_transaction_id = l_csi_trxn_rec.transaction_id
            WHERE  a.processing_status = l_literal1
            AND a.transaction_line_id in (SELECT b.transaction_line_id
                    FROM csi_t_transaction_lines b
                    WHERE -- a.transaction_line_id = b.transaction_line_id AND -- Commented for Perf Bug 4311676
                    b.source_transaction_id    = p_rma_line_rec.line_id
                    AND  b.source_transaction_table = l_literal2);
         Exception when others Then
            debug('Txn details update failed');
            raise fnd_api.g_exc_unexpected_error;
         End;

    END IF; -- td_tbl count > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to fulfill_rma_line;
      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      debug(l_error_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      rollback to fulfill_rma_line;
      fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      debug(l_error_message);
  END fulfill_rma_line;

END csi_rma_fulfill_pub;

/
