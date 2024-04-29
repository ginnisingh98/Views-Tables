--------------------------------------------------------
--  DDL for Package Body CSI_INV_TXNSTUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_TXNSTUB_PKG" AS
-- $Header: csiinvhb.pls 120.7.12010000.5 2009/01/23 19:43:11 fli ship $

l_debug NUMBER := csi_t_gen_utility_pvt.g_debug_level;

PROCEDURE debug(
  p_message   IN varchar2)
IS
BEGIN
  IF l_debug > 0 THEN
    csi_t_gen_utility_pvt.add(p_message);
  END IF;
END debug;

PROCEDURE execute_trx_dpl(p_transaction_type    IN VARCHAR2,
                          p_transaction_id      IN NUMBER,
                          x_trx_return_status   OUT NOCOPY VARCHAR2,
                          x_trx_error_rec       IN OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)

IS
l_api_name          VARCHAR2(100)    := 'CSI_INV_TXNSTUB_PUB.EXECUTE_TRX_DPL';
l_api_version       NUMBER           := 1.0;
l_commit            VARCHAR2(1)      := FND_API.G_FALSE;
l_init_msg_list     VARCHAR2(1)      := FND_API.G_TRUE;
l_validation_level  NUMBER           := FND_API.G_VALID_LEVEL_FULL;
l_error_message     VARCHAR2(4000);
l_error_code        VARCHAR2(4000);
l_return_status     VARCHAR2(1);
l_fnd_success       VARCHAR2(1)      := FND_API.G_RET_STS_SUCCESS;
l_fnd_error         VARCHAR2(1)      := FND_API.G_RET_STS_ERROR;
l_mtl_trx_rec       CSI_INV_TRXS_PKG.MTL_TRX_TYPE;
l_trx_error_rec     CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(4000);
l_txn_error_id      NUMBER;
l_file              VARCHAR2(500);
l_xml_string        VARCHAR2(2000);
l_txn_error_rec     CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
l_fnd_unexpected    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
e_dpl_error         EXCEPTION;
csi_txn_exists      EXCEPTION;
l_txn_type_id       NUMBER := NULL;
l_use_parallel_mode  VARCHAR2(1) := 'N';                 --Code added for MACD enhancement
l_order_line_rec    csi_order_ship_pub.order_line_rec;   --Code added for MACD enhancement
l_item_control_rec  csi_order_ship_pub.item_control_rec; --Code added for MACD enhancement
l_exists	    NUMBER;                              --Code added for MACD enhancement
l_link_to_line_id   NUMBER;                              --Code added for MACD enhancement

CURSOR c_csi_inv_exist_txns (pc_transaction_id IN NUMBER) is
  SELECT transaction_id
  FROM csi_transactions
  WHERE inv_material_transaction_id = pc_transaction_id;

r_csi_inv_exist_txns    c_csi_inv_exist_txns%rowtype;

CURSOR c_csi_inv_exist_txns_and_items (pc_transaction_id IN NUMBER) IS
  SELECT instance_id FROM csi_item_instances WHERE instance_id IN
  (SELECT instance_id FROM csi_item_instances_h WHERE transaction_id IN
  (SELECT transaction_id FROM csi_transactions WHERE inv_material_transaction_id = pc_transaction_id))
  AND inventory_item_id IN
  (SELECT inventory_item_id FROM mtl_material_transactions WHERE transaction_id = pc_transaction_id)
  AND ROWNUM = 1;

r_csi_inv_exist_txns_and_items    c_csi_inv_exist_txns_and_items%rowtype;

--modified for bug 7623208
CURSOR c_csi_soful_exist_txns (pc_transaction_id IN NUMBER) IS
  SELECT transaction_id
  FROM csi_transactions
  WHERE source_line_ref_id = pc_transaction_id
  AND transaction_type_id in (51,54,401)
  AND source_header_ref IN
  (SELECT order_number FROM oe_order_headers_all WHERE header_id IN
  (SELECT header_id FROM oe_order_lines_all WHERE line_id = pc_transaction_id));

r_csi_soful_exist_txns     c_csi_soful_exist_txns%rowtype;

BEGIN

  l_error_message  := NULL;
  l_return_status  := l_fnd_success;
  l_trx_error_rec  := x_trx_error_rec;

  -- Set error rec for the MTL Transaction ID in case of unexp error
  l_trx_error_rec.source_id := p_transaction_id;
  l_trx_error_rec.inv_material_transaction_id := p_transaction_id;
  l_trx_error_rec.source_type := p_transaction_type;

  IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.build_file_name(p_file_segment1 => lower(p_transaction_type),
                                             p_file_segment2 => p_transaction_id);
  END IF;

  -- Added for Cursor Optimization on CSI_INSTALL_PARAMETERS
  IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
    csi_gen_utility_pvt.populate_install_param_rec;
  END IF;

  savepoint one;

  debug('-------');
  debug('In execute_trx_dpl for Transaction:'||p_transaction_type);
  debug('In execute_trx_dpl for MTL Transaction ID:'||p_transaction_id);
  debug('-------');

  debug('Install Parameter Datastructure Populated');
  debug('    Ownership Override: '||csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn);
  debug('    SFM Flag: '||csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag);

  -- Check to see if any CSI Transactions Exist. If it does then just exit if there is not
  -- then process as normal

  IF p_transaction_type in ('CSISOFUL','CSIRMAFL') THEN

    OPEN c_csi_soful_exist_txns (p_transaction_id);
    FETCH c_csi_soful_exist_txns into r_csi_soful_exist_txns;

    IF c_csi_soful_exist_txns%FOUND THEN
      csi_t_gen_utility_pvt.add('CSI Transaction Exists: '||r_csi_soful_exist_txns.transaction_id);
      csi_t_gen_utility_pvt.add('Call exception to exit execute_trx_dpl');
      RAISE csi_txn_exists;
    ELSE
      csi_t_gen_utility_pvt.add('No CSI Transaction Exists so Continue Processing');
    END IF;
    CLOSE c_csi_soful_exist_txns;

  ELSE
    OPEN c_csi_inv_exist_txns (p_transaction_id);
    FETCH c_csi_inv_exist_txns into r_csi_inv_exist_txns;

    IF c_csi_inv_exist_txns%FOUND THEN
      OPEN c_csi_inv_exist_txns_and_items (p_transaction_id);
      FETCH c_csi_inv_exist_txns_and_items into r_csi_inv_exist_txns_and_items;

      IF c_csi_inv_exist_txns_and_items%FOUND THEN
        csi_t_gen_utility_pvt.add('CSI Transaction Exists: '||r_csi_inv_exist_txns.transaction_id);
        csi_t_gen_utility_pvt.add('Call exception to exit execute_trx_dpl');
        RAISE csi_txn_exists;
      ELSE
        csi_t_gen_utility_pvt.add('No CSI Transaction for the same Inventory Item Exists so Continue Processing');
      END IF;
      CLOSE c_csi_inv_exist_txns_and_items;
    ELSE
      csi_t_gen_utility_pvt.add('No CSI Transaction Exists so Continue Processing');
    END IF;
    CLOSE c_csi_inv_exist_txns;

  END IF;

  IF p_transaction_type = 'CSIISUPT' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 113;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('MOVE_ORDER_ISSUE_TO_PROJECT','INV');
    csi_inv_project_pkg.issue_to_project (p_transaction_id,
                                          NULL,
                                          l_return_status,
                                          l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSIPT' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 121;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE_TO_PROJECT','INV');
    csi_inv_project_pkg.misc_issue_projtask (p_transaction_id,
                                             NULL,
                                             l_return_status,
                                             l_trx_error_rec);
    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSISUBTR' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 114;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('SUBINVENTORY_TRANSFER','INV');
    csi_inv_transfer_pkg.subinv_transfer (p_transaction_id,
                                          NULL,
                                          l_return_status,
                                          l_trx_error_rec);
    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIORGTR' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 144;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('INTERORG_TRANS_RECEIPT','INV');
    csi_inv_interorg_pkg.intransit_receipt (p_transaction_id,
                                            NULL,
                                            l_return_status,
                                            l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIORGTS' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 145;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('INTERORG_TRANS_SHIPMENT','INV');
    csi_inv_interorg_pkg.intransit_shipment (p_transaction_id,
                                             NULL,
                                             l_return_status,
                                             l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIORGDS' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 143;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('INTERORG_DIRECT_SHIP','INV');
    csi_inv_interorg_pkg.direct_shipment (p_transaction_id,
                                          NULL,
                                          l_return_status,
                                          l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIINTSS' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 130;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('ISO_SHIPMENT','INV');
    csi_inv_iso_pkg.iso_shipment(p_transaction_id,
                                 NULL,
                                 l_return_status,
                                 l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIINTSR' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 131;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('ISO_REQUISITION_RECEIPT','INV');
    csi_inv_iso_pkg.iso_receipt(p_transaction_id,
                                NULL,
                                l_return_status,
                                l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIINTDS' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 142;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('ISO_DIRECT_SHIP','INV');
    csi_inv_iso_pkg.iso_direct(p_transaction_id,
                               NULL,
                               l_return_status,
                               l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIPOINV' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 112;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('PO_RECEIPT_INTO_INVENTORY','INV');
    csi_inv_trxs_pkg.receipt_inventory (p_transaction_id,
                                        NULL,
                                        l_return_status,
                                        l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSICYCNT' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 119;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('CYCLE_COUNT','INV');
    csi_inv_trxs_pkg.cycle_count (p_transaction_id,
                                  NULL,
                                  l_return_status,
                                  l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIPHYIN' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 118;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('PHYSICAL_INVENTORY','INV');
    csi_inv_trxs_pkg.physical_inventory (p_transaction_id,
                                         NULL,
                                         l_return_status,
                                         l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSRCV' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 117;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT','INV');
    csi_inv_trxs_pkg.misc_receipt (p_transaction_id,
                                   NULL,
                                   l_return_status,
                                   l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSISU' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 116;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE','INV');
    csi_inv_trxs_pkg.misc_issue (p_transaction_id,
                                 NULL,
                                 l_return_status,
                                 l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSRPT' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 120;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT_FROM_PROJECT','INV');
    csi_inv_project_pkg.misc_receipt_projtask (p_transaction_id,
                                               NULL,
                                               l_return_status,
                                               l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIISUHZ' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 132;
    l_trx_error_rec.transaction_type_id :=  csi_inv_trxs_pkg.get_txn_type_id('ISSUE_TO_HZ_LOC','INV');
    csi_inv_hz_pkg.issue_to_hz_loc (p_transaction_id,
                                    NULL,
                                    l_return_status,
                                    l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSIHZ' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 133;
    l_trx_error_rec.transaction_type_id :=  csi_inv_trxs_pkg.get_txn_type_id('MISC_ISSUE_HZ_LOC','INV');
    csi_inv_hz_pkg.misc_issue_hz_loc (p_transaction_id,
                                      NULL,
                                      l_return_status,
                                      l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIMSRHZ' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 134;
    l_trx_error_rec.transaction_type_id :=  csi_inv_trxs_pkg.get_txn_type_id('MISC_RECEIPT_HZ_LOC','INV');
    csi_inv_hz_pkg.misc_receipt_hz_loc (p_transaction_id,
                                        NULL,
                                        l_return_status,
                                        l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSISOFUL' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 51;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('OM_SHIPMENT','ONT');
    l_trx_error_rec.inv_material_transaction_id := null;

      csi_order_fulfill_pub.order_fulfillment(
        p_order_line_id => p_transaction_id,
        p_message_id    => NULL,
        x_return_status => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    savepoint one;

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIRMAFL' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 54;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('RMA_FULFILL','CSI');
    l_trx_error_rec.inv_material_transaction_id := null;
      csi_rma_fulfill_pub.rma_fulfillment(
        p_rma_line_id   => p_transaction_id,
        p_message_id    => NULL,
        x_return_status => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSISOSHP' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 51;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('OM_SHIPMENT','ONT');

    l_use_parallel_mode := NVL(fnd_profile.value('CSI_TXN_PARALLEL_MODE'), 'N');  --Code Added for MACD Enhancement

    if (l_use_parallel_mode = 'N') then              --Code Added for MACD Enhancement

	      csi_order_ship_pub.order_shipment(
	      p_mtl_transaction_id => p_transaction_id,
	      p_message_id         => NULL,
	      x_return_status      => l_return_status,
	      px_trx_error_rec => l_trx_error_rec);

    else

        --Code Added for MACD Enhancement starts here
            -- Get the order line details
		csi_utl_pkg.get_order_line_dtls(
		      p_mtl_transaction_id => p_transaction_id,
		      x_order_line_rec     => l_order_line_rec,
		      x_return_status      => l_return_status);

		-- get item details
		csi_utl_pkg.get_item_control_rec(
		      p_mtl_txn_id        => p_transaction_id,
		      x_item_control_rec  => l_item_control_rec,
      		x_return_status     => l_return_status);

      		-- check if the order is linked to any other line
		select link_to_line_id
		into l_link_to_line_id
		from oe_order_lines_all
		where line_id = l_order_line_rec.order_line_id;

		if (l_link_to_line_id is not null) then
			begin
				-- check rows being processed currently within order
				select count(1)
				into l_exists
				from csi_batch_txn_lines
				where order_header_id = l_order_line_rec.header_id
				and (processed_flag = 1 or processed_flag = 2);
			exception
				when no_data_found then
					l_exists := 0;
			end;

			if (l_exists = 1) then
				insert into CSI_BATCH_TXN_LINES
						(
						  BATCH_ID,
						  PROCESSED_FLAG,
						  ORDER_HEADER_ID,
						  ORDER_LINE_ID,
						  --ORGANIZATION_ID,
						  --INVENTORY_ITEM_ID,
						  TRANSACTION_TYPE,
						  TRANSACTION_TYPE_ID,
						  TRANSACTION_ID
						  --INSTANCE_ID,
						  --SERIAL_NUMBER
						  ,CREATION_DATE
						  ,CREATED_BY
						  ,LAST_UPDATE_DATE
						  ,LAST_UPDATED_BY
						) VALUES
						(
						  -1,
						  0,
						  l_order_line_rec.header_id,
						  l_order_line_rec.order_line_id,
						  --NULL,
						  --l_item_control_rec.inventory_item_id,
						  p_transaction_type,
						  51,
						  p_transaction_id
						  --NULL,
						  --NULL
						  ,sysdate
						  ,fnd_global.user_id
						  ,sysdate
						  ,fnd_global.user_id
						);

			else
				csi_order_ship_pub.order_shipment(
					p_mtl_transaction_id => p_transaction_id,
					p_message_id         => NULL,
					x_return_status      => l_return_status,
					px_trx_error_rec => l_trx_error_rec);

					debug('After Transaction If for: '||p_transaction_type);

				IF NOT l_return_status = l_fnd_success THEN
					RAISE e_dpl_error;
    				END IF;

			end if;
		else
			csi_order_ship_pub.order_shipment(
				p_mtl_transaction_id => p_transaction_id,
				p_message_id         => NULL,
				x_return_status      => l_return_status,
				px_trx_error_rec => l_trx_error_rec);

			IF NOT l_return_status = l_fnd_success THEN
				RAISE e_dpl_error;
    			END IF;

		end if;


        --Code Added for MACD Enhancement ends here
     end if;


    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIINTIS' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 126;
      l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('ISO_ISSUE','ONT');
      csi_order_ship_pub.order_shipment(
        p_mtl_transaction_id => p_transaction_id,
        p_message_id         => NULL,
        x_return_status      => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSILOSHP' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 51;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('OM_SHIPMENT','ONT');
      csi_order_fulfill_pub.logical_drop_ship(
        p_mtl_txn_id =>      p_transaction_id,
        p_message_id         => NULL,
        x_return_status      => l_return_status,
        px_trx_error_rec     => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIOKSHP' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 326;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('PROJECT_CONTRACT_SHIPMENT','OKE');
      csi_order_ship_pub.oke_shipment(
        p_mtl_txn_id        => p_transaction_id,
        x_return_status     => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIRMARC' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 53;
      l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('RMA_RECEIPT','ONT');
      csi_rma_receipt_pub.rma_receipt(
        p_mtl_txn_id    => p_transaction_id,
        p_message_id    => null,
        x_return_status => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIWIPCI'  THEN

    l_trx_error_rec.transaction_type_id := 71;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_ISSUE','INV');

    csi_wip_trxs_pkg.wip_comp_issue(
      p_transaction_id => p_transaction_id,
      p_message_id     => NULL,
      x_return_status  => l_return_status,
      px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIWIPNR' THEN

    l_trx_error_rec.transaction_type_id := 71;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_ISSUE','INV');

    csi_wip_trxs_pkg.wip_neg_comp_return(
      p_transaction_id => p_transaction_id,
      p_message_id     => NULL,
      x_return_status  => l_return_status,
      px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIWIPAR'  THEN

    l_trx_error_rec.transaction_type_id := 74;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_ASSEMBLY_RETURN','INV');

    csi_wip_trxs_pkg.wip_assy_return(
      p_transaction_id => p_transaction_id,
      p_message_id     => NULL,
      x_return_status  => l_return_status,
      px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

 --R12 Changes for OPM
  ELSIF p_transaction_type = 'CSIWIPBR'  THEN

    l_trx_error_rec.transaction_type_id := 76;
    l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_BYPRODUCT_RETURN','INV');

    csi_wip_trxs_pkg.wip_byproduct_return(
      p_transaction_id => p_transaction_id,
      p_message_id     => NULL,
      x_return_status  => l_return_status,
      px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;


  ELSIF ( p_transaction_type = 'CSIWIPCR' OR
          p_transaction_type = 'CSIWIPNI' ) THEN
    l_trx_error_rec.transaction_type_id := 72;
      l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_RECEIPT','INV');
      csi_wip_trxs_pkg.wip_comp_receipt (
        p_transaction_id => p_transaction_id,
        p_message_id     => NULL,
        x_return_status  => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

  ELSIF p_transaction_type = 'CSIWIPAC' THEN
    debug('Before Transaction If for: '||p_transaction_type);
    l_trx_error_rec.transaction_type_id := 73;
	 l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_ASSEMBLY_COMPLETION','INV');
      csi_wip_trxs_pkg.wip_assy_completion(
        p_transaction_id => p_transaction_id,
        p_message_id     => null,
        x_return_status  => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE e_dpl_error;
    END IF;

   --bnarayan added for OPM Changes
   ELSIF p_transaction_type = 'CSIWIPBC' THEN    --WIP By Product Completion
   debug('Before Transaction If for: '||p_transaction_type);
   l_trx_error_rec.transaction_type_id := 75;
   l_trx_error_rec.transaction_type_id := csi_inv_trxs_pkg.get_txn_type_id('WIP_BYPRODUCT_COMPLETION ','INV');
     csi_wip_trxs_pkg.wip_byproduct_completion(
        p_transaction_id => p_transaction_id,
        p_message_id     => null,
        x_return_status  => l_return_status,
        px_trx_error_rec => l_trx_error_rec);

    debug('After Transaction If for: '||p_transaction_type);

	    IF NOT l_return_status = l_fnd_success THEN
	      RAISE e_dpl_error;
	    END IF;

  ELSE -- Not a valid type so retain existing CSI Error
    debug('No Transaction Type was found so retain error that exists');
    l_trx_error_rec.error_text := FND_API.G_MISS_CHAR;
    l_return_status            := l_fnd_error;
    RAISE e_dpl_error;
  END IF;

  x_trx_error_rec     := l_trx_error_rec;
  x_trx_return_status := l_return_status;

EXCEPTION
 WHEN csi_txn_exists THEN
    IF (l_debug > 0) THEN
       csi_t_gen_utility_pvt.add('In CSI_TXN_EXISTS in CSIINVHB - CSI Transaction Exists so Just
exit doing nothing');
    END IF;
    x_trx_return_status := l_fnd_success;
    x_trx_error_rec.error_text := NULL;

  WHEN e_dpl_error THEN
    rollback to one;
    debug('In e_dpl_error in CSIINVHB - Check CSI_TXN_ERRORS for Details');

    x_trx_error_rec     := l_trx_error_rec;
    x_trx_return_status := l_return_status;

  WHEN OTHERS THEN
    rollback to one;
    debug('In OTHERS in CSIINVHB - Check CSI_TXN_ERRORS for Details');

    fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
    fnd_message.set_token('API_NAME',l_api_name);
    fnd_message.set_token('SQL_ERROR',SQLERRM);

    x_trx_error_rec := l_trx_error_rec;
    x_trx_error_rec.error_text           := fnd_message.get;
    x_trx_error_rec.transaction_id       := NULL;
    x_trx_error_rec.transaction_type_id  := l_trx_error_rec.transaction_type_id;
    x_trx_error_rec.source_type          := p_transaction_type;
    x_trx_error_rec.source_id            := p_transaction_id;
    IF p_transaction_type IN ('CSISOFUL', 'CSIRMAFL') THEN
      x_trx_error_rec.inv_material_transaction_id := null;
    ELSE
      x_trx_error_rec.inv_material_transaction_id := p_transaction_id;
    END IF;
    x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
    x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

    x_trx_return_status := l_fnd_unexpected;

END execute_trx_dpl;

END CSI_INV_TXNSTUB_PKG;

/
