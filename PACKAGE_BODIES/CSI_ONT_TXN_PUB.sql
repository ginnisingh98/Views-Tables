--------------------------------------------------------
--  DDL for Package Body CSI_ONT_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ONT_TXN_PUB" as
/* $Header: csipontb.pls 120.7.12010000.4 2009/12/21 23:46:21 devijay ship $ */

  PROCEDURE debug(
    p_message in varchar2)
  IS
  BEGIN
    IF csi_t_gen_utility_pvt.g_debug_level > 0 THEN
      csi_t_gen_utility_pvt.add(p_message);
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

 /* -- Function added for bug 8651044
  FUNCTION check_if_debrief_txn_src(
    p_order_line_id       IN  NUMBER
  ) RETURN BOOLEAN
  IS
	l_return_status  BOOLEAN := FALSE;
	l_dummy_order_line_id NUMBER;
  BEGIN
	SELECT ORDER_LINE_ID INTO l_dummy_order_line_id
        FROM CS_ESTIMATE_DETAILS,OE_ORDER_LINES_ALL
    WHERE CS_ESTIMATE_DETAILS.incident_ID = OE_ORDER_LINES_ALL.source_document_ID
	AND CS_ESTIMATE_DETAILS.SOURCE_CODE       = 'SD'
	AND OE_ORDER_LINES_ALL.source_document_type_id   = 7
	AND oe_order_lines_all.line_id = p_order_line_id;

	l_return_status := TRUE;
	-- Return TRUE as the order line is debrief order
	RETURN l_return_status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  l_return_status := FALSE;
	  return l_return_status;
	WHEN TOO_MANY_ROWS THEN
      l_return_status := TRUE;
	  return l_return_status;
	WHEN OTHERS THEN
	  l_return_status := FALSE;
	  debug('Error in check_if_debrief_txn_src - ' || SQLERRM);
	  return l_return_status;
  END check_if_debrief_txn_src;
*/


  PROCEDURE PostTransaction(
    p_order_line_id       IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_message_id          OUT NOCOPY NUMBER,
    x_error_code          OUT NOCOPY NUMBER,
    x_error_message       OUT NOCOPY VARCHAR2)
  IS

    l_message_id          number;
    l_transactable_flag   mtl_system_items_b.mtl_transactions_enabled_flag%TYPE; --bug6140021
    l_org_id              number;
    l_order_id            oe_order_lines_all.header_id%TYPE; --Added for MACD Enhancement
    l_vld_organization_id number;
    l_inventory_item_id   number;
    l_line_category_code  oe_order_lines_all.line_category_code%TYPE;
    l_shippable_flag      mtl_system_items_b.shippable_item_flag%TYPE;
    l_ordered_item        varchar2(80);
    l_item_type_code      varchar2(30);
    l_fulfilled_qty       number;
    l_shipped_qty         number;
    l_ato_line_id         number;

    l_receipt_node_found  boolean;
    l_processing_reqd     varchar2(1) := 'Y';
    l_bypass_flag         varchar2(1) := 'N';

    l_use_parallelmode VARCHAR2(1) := 'N';  --Added for MACD Enhancement
    --l_interface_nship_flag VARCHAR2(1) := 'Y';

    l_txn_type_id         number;
    l_txn_type            varchar2(30);

    publish_error         exception;
    bypass_error          exception;
    l_skip_reason         varchar2(80);

    l_return_status       varchar2(1);
    l_error_code          number;
    l_error_message       varchar2(4000);
    l_error_rec           csi_datastructures_pub.transaction_error_rec;

    CURSOR c_xnp_event_mgr_info IS
      SELECT substr( service_parameters, instr(service_parameters, 'XDP_DQ_INIT_NUM_THREADS', 1)) service_parameters,
             nvl(max_processes,-1) max_processes
      FROM   fnd_concurrent_queues
      WHERE concurrent_queue_name = 'XDP_Q_EVENT_SVC'
      AND   application_id = 535;

    l_service_parameters varchar2(2000);
    l_start number;
    l_end number;
    l_num_threads number;
    l_max_processes number;
    l_om_session_key        	csi_utility_grp.config_session_key;      --Added for MACD Enhancement
    l_config_header_id 		oe_order_lines_all.config_header_id%type;--Added for MACD Enhancement
    l_config_rev_nbr 		oe_order_lines_all.config_rev_nbr%type;  --Added for MACD Enhancement
    l_configuration_id		oe_order_lines_all.configuration_id%type;--Added for MACD Enhancement
    l_macd_processing       	boolean     := FALSE;                    --Added for MACD Enhancement

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_use_parallelmode := NVL(fnd_profile.value('CSI_TXN_PARALLEL_MODE'), 'N'); --Added for MACD Enhancement
--  l_use_parallelmode := 'Y';

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiinv',
      p_file_segment2 => 'hook');

      csi_t_gen_utility_pvt.add('*****START ib node from workflow process :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')); --Added for MACD Enhancement

    debug('START ib node from workflow process :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    debug('  order_line_id       : '||p_order_line_id);

/*	-- Bug 8651044
	IF check_if_debrief_txn_src(p_order_line_id) THEN
		debug('Skip posting transaction to avoid duplicate processing by workflow');
		x_return_status := fnd_api.g_ret_sts_success;
		-- Skiping the processing
		l_processing_reqd := 'N';
        l_skip_reason     := 'Fulfilment already processed through debrief';
		--RETURN;
	END IF;
	*/
    -- Check Item trackeable
    BEGIN

      SELECT org_id,
             header_id,          --Added for MACD Enhancement
             inventory_item_id,
             line_category_code,
             ordered_item,
             item_type_code,
             fulfilled_quantity,
             shipped_quantity,
             shippable_flag,
	     config_header_id,   --Added for MACD Enhancement
             config_rev_nbr,     --Added for MACD Enhancement
             configuration_id,   --Added for MACD Enhancement
             ato_line_id
      INTO   l_org_id,
             l_order_id,         --Added for MACD Enhancement
             l_inventory_item_id,
             l_line_category_code,
             l_ordered_item,
             l_item_type_code,
             l_fulfilled_qty,
             l_shipped_qty,
             l_shippable_flag,
	     l_config_header_id,--Added for MACD Enhancement
             l_config_rev_nbr,  --Added for MACD Enhancement
             l_configuration_id,--Added for MACD Enhancement
             l_ato_line_id
      FROM   oe_order_lines_all
      WHERE  line_id = p_order_line_id;

      debug('  inventory_item_id   : '||l_inventory_item_id);

      l_vld_organization_id := oe_sys_parameters.value(
                                 param_name => 'MASTER_ORGANIZATION_ID',
                                 p_org_id   => l_org_id);

      debug('  om_vld_org_id       : '||l_vld_organization_id);

    EXCEPTION
      WHEN no_data_found THEN

        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_order_line_id);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    END;

    IF NOT
       csi_item_instance_vld_pvt.is_trackable(
         p_inv_item_id => l_inventory_item_id,
         p_org_id      => l_vld_organization_id)
    THEN
      debug('  ib_trackable        : FALSE');
      l_processing_reqd := 'N';
      l_skip_reason     := 'non ib trackable';
    END IF;
  /*
    -- Bug 8931748
    -- Introduced a new profile value CSI: Interface Non-Shippable Items to IB
    -- (CSI_INTERFACE_NON_SHIP_ITEMS) to allow users to specify whether to
    -- interface non-shippable items to IB. As a part of this
    -- requirement (as per document) to introduce IB node for
    -- non shippable items in WF should be removed

    debug('  shippable_item_flag : '||l_shippable_flag);
    IF NVL(l_shippable_flag,'N') = 'N' THEN
      -- Get profile value for CSI_INTERFACE_NON_SHIP_ITEMS
      -- If CSI_INTERFACE_NON_SHIP_ITEMS = Y process continues
      -- If CSI_INTERFACE_NON_SHIP_ITEMS = N skip processig
      -- Default value for the flag is to interface
      -- (ie) CSI_INTERFACE_NON_SHIP_ITEMS = Y

      l_interface_nship_flag :=  NVL(fnd_profile.value('CSI_INTERFACE_NON_SHIP_ITEMS'), 'Y');
      debug('  interface non-shippable : '||l_interface_nship_flag);
      IF l_interface_nship_flag = 'N' THEN
        -- Skipping
        x_return_status := fnd_api.g_ret_sts_success;
    		l_processing_reqd := 'N';
        l_skip_reason     := 'CSI: Interface Non-Shippable Items set to N. Skipping Processing';
        debug(l_skip_reason);
      END IF; -- l_interface_nship_flag = N
    END IF; -- NVL(l_shippable_flag,'N') = 'N'
    -- End Bug 8931748

*/
    IF l_processing_reqd = 'Y' THEN

      debug('  ib_trackable        : TRUE');
      debug('  line_category_code  : '||l_line_category_code);
      debug('  item_type_code      : '||l_item_type_code);
      debug('  ordered_item        : '||l_ordered_item);
      debug('  fulfilled_quantity  : '||l_fulfilled_qty);
      debug('  shipped_quantity    : '||l_shipped_qty);
      debug('  shippable_item_flag : '||l_shippable_flag);

      -- Order Line Shippable item flag overrides the MSI - R12
      /*
       OUTBOUND:
         OEL Shippable flag is N
                   -  Regular non-shippable items :: shipped qty is NOT populated
                   -  Shippable as well as non-shippable items in a configuration  :: shipped qty is populated
                      (these shippable items could be option items in an ATO but NOT physically shipped )
         OEL Shippable flag is Y
                   -  Shippable items physically shipped :: shipped qty is populated
       INBOUND:
         OEL Shippable flag is N
                   -  Regular non-shippable but returnable item cancellations :: shipped qty is NOT populated
         OEL Shippable flag is Y
                   -  Shippable items physically returned :: shipped qty is populated
                   -  Regular shippable item but not physically returned :: shipped qty is NOT populated
      */

--Code start for bug 6140021--
       BEGIN
         SELECT nvl(mtl_transactions_enabled_flag,'N')
         INTO   l_transactable_flag
         FROM   mtl_system_items
         WHERE  inventory_item_id = l_inventory_item_id
         AND    organization_id   = l_vld_organization_id;
       EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_INT_ITEM_ID_INVALID');
          fnd_message.set_token('ITEM_ID', l_inventory_item_id);
          fnd_message.set_token('ORGANIZATION_ID',l_vld_organization_id);
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END;
      --Code end for bug 6140021--

      IF l_shippable_flag is null THEN
      -- get the Shippable item flag if order line does not have it already

      -- get the Shippable item flag
       BEGIN
         SELECT nvl(shippable_item_flag,'N')
         INTO   l_shippable_flag
         FROM   mtl_system_items
         WHERE  inventory_item_id = l_inventory_item_id
         AND    organization_id   = l_vld_organization_id;
       EXCEPTION
         WHEN no_data_found THEN
           fnd_message.set_name('CSI','CSI_INT_ITEM_ID_INVALID');
           fnd_message.set_token('ITEM_ID', l_inventory_item_id);
           fnd_message.set_token('ORGANIZATION_ID',l_vld_organization_id);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
       END;
      END IF;

      IF l_shippable_flag = 'N' THEN
        IF l_line_category_code = 'ORDER' THEN
          l_txn_type    := 'CSISOFUL';
          l_txn_type_id := 51;
        ELSIF l_line_category_code = 'RETURN' THEN
          l_txn_type    := 'CSIRMAFL';
          l_txn_type_id := 54;
        END IF;
      ELSIF  l_shippable_flag = 'Y'  THEN

        l_processing_reqd := 'N';
        l_skip_reason     := 'shippable item';
        IF nvl(l_shipped_qty, -999) = -999  THEN
         IF l_line_category_code = 'RETURN' THEN
           /* not required to check the RCV function anymore from R12 since the shippable quantity is going to handle this
               l_receipt_node_found := wf_engine.activity_exist_in_process(
                                    p_item_type          => 'OEOL',
                                    p_item_key           => to_char(p_order_line_id),
                                    p_activity_item_type => 'OEOL',
                                    p_activity_name      => 'RMA_RECEIVING_SUB');
               IF NOT(l_receipt_node_found) THEN
                  l_processing_reqd := 'Y';
                  l_txn_type        := 'CSIRMAFL';
                  l_txn_type_id     := 54;
               END IF;
            */
            l_processing_reqd := 'Y';
            l_txn_type        := 'CSIRMAFL';
            l_txn_type_id     := 54;
         ELSE
           -- Bill Only flows for the Demo / Lease Loan conversions... Bug 4996316
           debug('Customer Product Conversion...');
           l_processing_reqd := 'Y';
           l_txn_type    := 'CSISOFUL';
           l_txn_type_id := 51;
         END IF;
--start for 6140021
	ELSE
          IF l_transactable_flag = 'N' THEN
           debug('Customer Product Conversion...when not transactable');
           l_processing_reqd := 'Y';
           l_txn_type    := 'CSISOFUL';
           l_txn_type_id := 51;
          END IF;
		 --end for 6140021

        END IF;
      END IF;
    END IF;

    IF l_processing_reqd = 'Y' THEN

        -- Bug 4939357 - Added code for Cursor Optimation and also for SFM Thread/Max Processes

--      SELECT nvl(sfm_queue_bypass_flag,'N')
--      INTO   l_bypass_flag
--      FROM   csi_install_parameters;

      IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;

      l_bypass_flag := NVL(csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag,'N');

      debug('  bypass_mode         :'||l_bypass_flag);

      l_error_rec.source_type         := l_txn_type;
      l_error_rec.source_id           := p_order_line_id;
      l_error_rec.transaction_type_id := l_txn_type_id;

      IF l_bypass_flag = 'N' THEN

        debug('publishing the message for event - '||l_txn_type);
        debug('Checking SFM Manager Parameters');

        OPEN c_xnp_event_mgr_info;
        FETCH c_xnp_event_mgr_info INTO l_service_parameters, l_max_processes;
        CLOSE c_xnp_event_mgr_info;

        l_start := instr(l_service_parameters, '=', 1) + 1;
        l_end   := instr(l_service_parameters, ':', 1);

        IF l_end = 0 THEN -- No more delimiters
           l_num_threads := substr(l_service_parameters,l_start);
        ELSE
           l_num_threads := substr(l_service_parameters,l_start,(l_end - l_start));
        END IF;

        debug('SFM Manager Threads: '||l_num_threads);
        debug('SFM Manager Max Processes: '||l_max_processes);

       --Commented the below code  for MACD Enhancement
       /*
	IF (l_num_threads   <> 1) OR
           (l_max_processes <> 1) THEN

          debug('SFM Manager Processes or Threads are not 1 so raising exception and logging error..');
          fnd_message.set_name('CSI','CSI_SFM_THREAD_MP_ERROR');
          l_error_rec.error_text := fnd_message.get;
          RAISE publish_error;
        END IF;
	*/

        IF l_txn_type = 'CSISOFUL' THEN

	   if l_use_parallelmode = 'N' then   --Added for MACD Enhancement

		  XNP_CSISOFUL_U.publish(
		    xnp$order_line_id => p_order_line_id,
		    x_message_id      => l_message_id,
		    x_error_code      => l_error_code,
		    x_error_message   => l_error_message);

		  IF l_error_message is not null THEN
		    RAISE publish_error;
		  END IF;

	    else
	        --Code Added for MACD Enhancement starts here
		-- check for MACD orders
	        l_om_session_key.session_hdr_id  := l_config_header_id;
	        l_om_session_key.session_rev_num := l_config_rev_nbr;
    		l_om_session_key.session_item_id := l_configuration_id;
		l_macd_processing := csi_interface_pkg.check_macd_processing(
                           p_config_session_key => l_om_session_key,
                           x_return_status      => l_return_status);

                if (l_macd_processing) then

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
			)
			VALUES
			(
			  -1,
			  0,
			  L_ORDER_ID,
			  P_ORDER_LINE_ID,
			  --NULL,
			  --l_inventory_item_id,
			  l_txn_type,
			  l_txn_type_id,
			  NULL
			  --NULL,
			  --NULL
			  ,sysdate
			  ,fnd_global.user_id
			  ,sysdate
			  ,fnd_global.user_id
			);
		else
		    XNP_CSISOFUL_U.publish(
		    xnp$order_line_id => p_order_line_id,
		    x_message_id      => l_message_id,
		    x_error_code      => l_error_code,
		    x_error_message   => l_error_message);

		  IF l_error_message is not null THEN
		    RAISE publish_error;
		  END IF;
                end if;
	   end if;

             --Code Added for MACD Enhancement ends here

        ELSIF l_txn_type = 'CSIRMAFL' THEN

          XNP_CSIRMAFL_U.publish(
            xnp$rma_line_id   => p_order_line_id,
            x_message_id      => l_message_id,
            x_error_code      => l_error_code,
            x_error_message   => l_error_message);

          IF l_error_message is not null THEN
            l_error_rec.error_text := l_error_message;
            RAISE publish_error;
          END IF;

        END IF;

      ELSE

        debug('bypassing the sfm queue for - '||l_txn_type);

        csi_inv_txnstub_pkg.execute_trx_dpl(
          p_transaction_type  => l_txn_type,
          p_transaction_id    => p_order_line_id,
          x_trx_return_status => l_return_status,
          x_trx_error_rec     => l_error_rec);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE bypass_error;
        END IF;

      END IF; -- bypass flag

    ELSE
      debug('skip fulfillment process - '||l_skip_reason);
    END IF; -- processing reqd

    debug('END ib node from workflow process :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN bypass_error THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csiinv',
        p_file_segment2 => 'hook');
      l_error_rec.inv_material_transaction_id := null;
      debug('  bypass_error : '||l_error_rec.error_text);
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
    WHEN publish_error THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csiinv',
        p_file_segment2 => 'hook');
      l_error_rec.inv_material_transaction_id := null;
      debug('  publish_error :'||l_error_rec.error_text);
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
    WHEN others THEN
      csi_t_gen_utility_pvt.build_file_name(
        p_file_segment1 => 'csiinv',
        p_file_segment2 => 'hook');
      l_error_rec.inv_material_transaction_id := null;
      l_error_rec.error_text := substr(sqlerrm, 1, 540);
      debug('  other_error :'||l_error_rec.error_text);
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
  END PostTransaction;

END csi_ont_txn_pub;

/
