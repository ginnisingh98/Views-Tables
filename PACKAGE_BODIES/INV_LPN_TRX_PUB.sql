--------------------------------------------------------
--  DDL for Package Body INV_LPN_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LPN_TRX_PUB" AS
  /* $Header: INVTRXWB.pls 120.46.12010000.69 2013/02/21 07:15:31 ssingams ship $ */

  --      Name: PROCESS_LPN_TRX
  --
  --      Input parameters:
  --
  --      Output parameters:
  --       x_proc_msg         Message from the Process-Manager
  --       return_status      0 on Success, 1 on Error
  --
  --
  --  Global constant holding the package name
  g_pkg_name    CONSTANT VARCHAR2(30)   := 'INV_LPN_TRX_PUB';
  g_pkg_version CONSTANT VARCHAR2(100)  := '$Header: INVTRXWB.pls 120.46.12010000.69 2013/02/21 07:15:31 ssingams ship $';
  ret_status             VARCHAR2(512);
  ret_msgcnt             NUMBER         := 0;
  ret_msgdata            VARCHAR2(1000);
  g_pack        CONSTANT NUMBER         := 1;
  g_unpack      CONSTANT NUMBER         := 2;
  g_adjust      CONSTANT NUMBER         := 3;
  g_unpack_all  CONSTANT NUMBER         := 4;
  g_precision   CONSTANT NUMBER         := 5;
  -- HVERDDIN ERES START
  g_eres_event_name      VARCHAR2(60);

  TYPE eres_rec IS RECORD(
    event_id                   NUMBER
  , transaction_action_id      NUMBER
  , transaction_source_type_id NUMBER
  );

  TYPE eres_tbl IS TABLE OF eres_rec
    INDEX BY BINARY_INTEGER;

  -- HVERDDIN  ERES END

  /******************************************************************************************************************
  -- TRANS_ERES_ENABLED
  -- Validate if this transaction type is being supported.
  -- Only the following are being supported in this release

  -- TRANSACTION_SOURCE_TYPE                                 TRANSACTION_ACTION
  ------------I----------------------------------            ------------------------
  -- G_SOURCETYPE_ACCOUNT           := 3;                    G_ACTION_ISSUE   := 1   G_ACTION_RECEIPT  := 27;
  -- G_SOURCETYPE_ACCOUNTALIAS      := 6;                    G_ACTION_ISSUE   := 1   G_ACTION_RECEIPT  := 27;
  -- G_SOURCETYPE_INVENTORY         := 13;                   G_ACTION_ISSUE   := 1   G_ACTION_RECEIPT  := 27;
  --
  --
  -- Created H.Verdding  - Added to support ERES FDA requirements.
  ******************************************************************************************************************/
  FUNCTION trans_eres_enabled(p_trans_action_id IN NUMBER, p_trans_source_type_id IN NUMBER)
    RETURN BOOLEAN IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('** Trans Eres Enabled trx_action_id = ' || p_trans_action_id, 'INV_LPN_TRX_PUB', 9);
      inv_log_util.TRACE('** Trans Eres Enabled trx_soource_id =' || p_trans_source_type_id, 'INV_LPN_TRX_PUB', 9);
    END IF;

    IF (p_trans_action_id NOT IN(inv_globals.g_action_issue, inv_globals.g_action_receipt,INV_GLOBALS.G_ACTION_SUBXFR,
                                 INV_GLOBALS.G_ACTION_ORGXFR, INV_GLOBALS.G_ACTION_INTRANSITSHIPMENT)) THEN
      inv_log_util.TRACE(
        '** Transactions Not ERES Supported trx_action_id =' || p_trans_action_id || ',trx_source_type_id =' || p_trans_source_type_id
      , 'INV_LPN_TRX_PUB'
      , 9
      );
      RETURN FALSE;
    ELSIF(p_trans_action_id = inv_globals.g_action_issue) THEN
      -- These are Issue trans types
      IF (p_trans_source_type_id = inv_globals.g_sourcetype_account) THEN
        g_eres_event_name  := 'oracle.apps.inv.acctIssue';
      ELSIF(p_trans_source_type_id = inv_globals.g_sourcetype_accountalias) THEN
        g_eres_event_name  := 'oracle.apps.inv.acctAliasIssue';
      ELSIF(p_trans_source_type_id = inv_globals.g_sourcetype_inventory) THEN
        g_eres_event_name  := 'oracle.apps.inv.miscIssue';
      ELSE
        RETURN FALSE;
      END IF;
    ELSIF(p_trans_action_id = inv_globals.g_action_receipt) THEN
      -- These are Reciept trans types
      IF (p_trans_source_type_id = inv_globals.g_sourcetype_account) THEN
        g_eres_event_name  := 'oracle.apps.inv.acctReceipt';
      ELSIF(p_trans_source_type_id = inv_globals.g_sourcetype_accountalias) THEN
        g_eres_event_name  := 'oracle.apps.inv.acctAliasReceipt';
      ELSIF(p_trans_source_type_id = inv_globals.g_sourcetype_inventory) THEN
        g_eres_event_name  := 'oracle.apps.inv.miscReceipt';
      ELSE
        RETURN FALSE;
      END IF;
    -- fabdi invconv start
	 ELSIF (p_trans_action_id = INV_GLOBALS.G_ACTION_SUBXFR) THEN
       -- These are Inter-Org Transfers trans types
       IF (p_trans_source_type_id = INV_GLOBALS.G_SOURCETYPE_INVENTORY) THEN
            g_eres_event_name := 'oracle.apps.inv.subinvTransfer';
       ELSE
            RETURN FALSE;
       END IF;
     ELSIF (p_trans_action_id in (INV_GLOBALS.G_ACTION_ORGXFR, INV_GLOBALS.G_ACTION_INTRANSITSHIPMENT)) THEN
       -- These are Subinventory Transfers trans types
       IF (p_trans_source_type_id = INV_GLOBALS.G_SOURCETYPE_INVENTORY) THEN
            g_eres_event_name := 'oracle.apps.inv.interorgTransfer';
       ELSE
            RETURN FALSE;
       END IF;
	-- fabdi invconv end
    ELSE
      RETURN FALSE;
    END IF;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('**  ERES EVENT  = ' || g_eres_event_name, 'INV_LPN_TRX_PUB', 9);
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('** Function TRANS_ERES_ENABLED - raised when Others', 'INV_LPN_TRX_PUB', 9);
      END IF;

      fnd_message.set_name('INV', 'INV_ERES_ENABLED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN FALSE;
  END trans_eres_enabled;

--3978111 CHANGES START
/********************************************************************
* Code to insert in cst_comp_snap_temp in case of WIP LPN completion
* and complete LPN putaway
*******************************************************************/
procedure create_snapshot(p_temp_id NUMBER, p_org_id NUMBER)
IS
    l_errNum                       NUMBER;
    l_errCode                      VARCHAR2(1);
    l_errMsg                       VARCHAR2(241);
    l_cst_ret                      NUMBER(1):=0;
    l_primary_cost_method          NUMBER;
    l_debug			   NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
	select primary_cost_method
	into   l_primary_cost_method
	from   mtl_parameters
	where  organization_id = p_org_id;

	IF (l_debug = 1) THEN
		inv_log_util.TRACE('INVTRXWB: cost method of org'||p_org_id||' is '||l_primary_cost_method,'INVTRXWB',1);
	END IF;

	IF l_primary_cost_method in (2,5,6) THEN
		IF (l_debug = 1) THEN
			inv_log_util.TRACE('PRIMARY COST METHOD IS AVG OR FIFO OR LIFO CALLING CSTACOSN.op_snapshot'||p_temp_id,'INVTRXWB',1);
		END IF;

		l_cst_ret := CSTACOSN.op_snapshot(i_txn_temp_id => p_temp_id,
						err_num => l_errNum,
						err_code => l_errCode,
						err_msg => l_errMsg);
		IF(l_cst_ret <> 1) THEN
			fnd_message.set_name('BOM', 'CST_SNAPSHOT_FAILED');
			fnd_msg_pub.ADD;
			IF (l_debug = 1) THEN
				inv_log_util.TRACE('INVTRXWB: Error from CSTACOSN.op_snapshot ','INVTRXWB',1);
			END IF;
			raise fnd_api.g_exc_unexpected_error;
		ELSE
			inv_log_util.TRACE('INVTRXWB: CALL TO CSTACOSN.op_snapshot SUCCESSFULL','INVTRXWB',1);
		END IF;

	END IF;
END create_snapshot;
--3978111 CHANGES END

  /********************************************************************
   * Insert a row into MTL_MATERIAL_TRANSACTION_TEMP
   *  If the transaction is an InterOrg transfer type, call the CostGroup
   *  API to determine cost groups.
   *******************************************************************/
  PROCEDURE insert_line_trx(
    curlpnrec                     wms_container_pub.wms_container_content_rec_type
  , v_trxtempid                   NUMBER
  , v_trxaction                   NUMBER
  , v_orgid                       NUMBER
  , v_subinv                      VARCHAR2
  , v_locatorid                   NUMBER
  , v_trxqty                      NUMBER
  , v_cost_group_id               NUMBER := NULL
  , v_mmtt_rec      IN OUT NOCOPY mtl_material_transactions_temp%ROWTYPE
  , x_trxtempid     OUT NOCOPY    NUMBER
  , v_sectrxqty                   NUMBER := NULL --INVCONV kkillams
  ) IS
    l_cst_grp_id     NUMBER;
    l_xfr_cst_grp_id NUMBER     := v_cost_group_id;
    l_temp_uom_code  VARCHAR(3);
    l_debug          NUMBER     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_sign	     NUMBER     := 1; --Added bug3984746

    --Bug 10158934
    l_api_name                VARCHAR2(30) := 'INSERT_LINE_TRX';
    x_transfer_price          NUMBER;
    x_currency_code           VARCHAR2(31);
    x_transfer_price_priuom   NUMBER;
    x_incr_transfer_price     NUMBER;
    x_incr_currency_code      VARCHAR2(31);
    x_return_status           VARCHAR2(1);
    x_msg_data                VARCHAR2(2000);
    x_msg_count               NUMBER;
    p_from_opm_org            VARCHAR2(1);
    p_to_opm_org              VARCHAR2(1);

    l_wlc_prim_qty  NUMBER; --13591755
	l_wlc_trx_qty   NUMBER;

  BEGIN
    SELECT mtl_material_transactions_s.NEXTVAL
      INTO x_trxtempid
      FROM DUAL;

    v_mmtt_rec.transaction_temp_id   := x_trxtempid;
    v_mmtt_rec.subinventory_code     := v_subinv;
    v_mmtt_rec.locator_id            := v_locatorid;
    v_mmtt_rec.inventory_item_id     := curlpnrec.content_item_id;
    v_mmtt_rec.content_lpn_id        := NVL(curlpnrec.parent_lpn_id, v_mmtt_rec.content_lpn_id);
    v_mmtt_rec.transaction_quantity  := v_trxqty;
    v_mmtt_rec.transaction_uom       := curlpnrec.uom;
    v_mmtt_rec.secondary_transaction_quantity  := v_sectrxqty;      --INVCONV kkillams
    v_mmtt_rec.secondary_uom_code              := curlpnrec.sec_uom;--INVCONV kkillams
    v_mmtt_rec.lot_number          :=curlpnrec.lot_number;  --bug 8526601

    SELECT primary_uom_code
      INTO l_temp_uom_code
      FROM mtl_system_items
     WHERE inventory_item_id = v_mmtt_rec.inventory_item_id
       AND organization_id = v_mmtt_rec.organization_id;

	SELECT sum(primary_quantity) , sum(quantity)
	INTO l_wlc_prim_qty  , l_wlc_trx_qty
	FROM wms_lpn_contents
	where parent_lpn_id = v_mmtt_rec.content_lpn_id
	and lot_number = v_mmtt_rec.lot_number
	and inventory_item_id = v_mmtt_rec.inventory_item_id
        and organization_id = v_mmtt_rec.organization_id
		and revision = v_mmtt_rec.revision
		and uom_code = v_mmtt_rec.TRANSACTION_UOM;

   IF v_mmtt_rec.transaction_uom <> l_temp_uom_code THEN  --Added bug 3984746
    IF v_mmtt_rec.primary_quantity < 0 THEN
    	l_sign := -1;
    END IF;   --End of bug fix3984746
    ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
	IF (v_mmtt_rec.transaction_quantity = l_wlc_trx_qty) THEN
		v_mmtt_rec.primary_quantity      := l_wlc_prim_qty;
	ELSE
    v_mmtt_rec.primary_quantity      :=
      inv_convert.inv_um_convert(v_mmtt_rec.inventory_item_id,v_mmtt_rec.lot_number,v_mmtt_rec.organization_id,5, abs(v_mmtt_rec.transaction_quantity), v_mmtt_rec.transaction_uom
      , l_temp_uom_code, NULL, NULL);
	END IF;

    IF (v_mmtt_rec.primary_quantity = -99999) THEN  --Changed from '<=' bug 3984746
      fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
      fnd_message.set_token('uom1', v_mmtt_rec.transaction_uom);
      fnd_message.set_token('uom2', l_temp_uom_code);
      fnd_message.set_token('module', 'INSERT_LINE_TRX');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    v_mmtt_rec.primary_quantity := v_mmtt_rec.primary_quantity * l_sign;  --Added bug3984746
    ELSE
    v_mmtt_rec.primary_quantity := v_mmtt_rec.transaction_quantity; --Added bug 4080241
    END IF;

    v_mmtt_rec.revision              := curlpnrec.revision;
    v_mmtt_rec.cost_group_id         := NVL(v_cost_group_id, v_mmtt_rec.cost_group_id);

    -- If the transaction action is OrgXfr, IntrShipment or IntrRcpt
    -- then set the cost_group_id to null. The CostGroup API will
    -- determine the cost-group-id in this case. Insert into MMTT using
    -- the passed MMTT_Record type.
    IF (v_trxaction = inv_globals.g_action_orgxfr)
       OR(v_trxaction = inv_globals.g_action_intransitshipment)
       OR(v_trxaction = inv_globals.g_action_intransitreceipt) THEN
      l_xfr_cst_grp_id  := NULL;
    END IF;

     -- Start Bug 10158934
     -- Call GMF_get_transfer_price_PUB.get_transfer_price API if either from or to org is process enabled.
     IF ( inv_cache.set_org_rec(v_mmtt_rec.organization_id ) ) THEN
         IF ( NVL(inv_cache.org_rec.process_enabled_flag,'N') = 'Y') THEN
                     p_from_opm_org := 'Y';
                     inv_log_util.trace('p_from_opm_org is:' ||p_from_opm_org, g_pkg_name || '.' || l_api_name, 5);

         END IF;
     END IF;

     IF ( inv_cache.set_org_rec(v_mmtt_rec.transfer_organization ) ) THEN
         IF ( NVL(inv_cache.org_rec.process_enabled_flag,'N') = 'Y') THEN
                     p_to_opm_org := 'Y';
                     inv_log_util.trace('p_to_opm_org is:' ||p_to_opm_org, g_pkg_name || '.' || l_api_name, 5);
         END IF;
     END IF;

     IF (p_from_opm_org = 'Y' OR  p_to_opm_org = 'Y') THEN
         inv_log_util.trace('Calling GMF_get_transfer_price_PUB.get_transfer_price', g_pkg_name || '.' || l_api_name, 5);
         inv_log_util.trace('v_mmtt_rec.inventory_item_id is:' || v_mmtt_rec.inventory_item_id, g_pkg_name || '.' || l_api_name, 5);
         inv_log_util.trace('v_mmtt_rec.transaction_quantity is:' || v_mmtt_rec.transaction_quantity, g_pkg_name || '.' || l_api_name, 5);
         inv_log_util.trace('v_mmtt_rec.transaction_uom is:' ||v_mmtt_rec.transaction_uom, g_pkg_name || '.' || l_api_name, 5);
         inv_log_util.trace('v_mmtt_rec.organization_id is:' ||v_mmtt_rec.organization_id, g_pkg_name || '.' || l_api_name, 5);
         inv_log_util.trace('v_mmtt_rec.transfer_organization is:' ||v_mmtt_rec.transfer_organization, g_pkg_name || '.' || l_api_name, 5);

         GMF_get_transfer_price_PUB.get_transfer_price (
           p_api_version             => 1.0
         , p_init_msg_list           => 'F'

         , p_inventory_item_id       => v_mmtt_rec.inventory_item_id
         , p_transaction_qty         => v_mmtt_rec.transaction_quantity
         , p_transaction_uom         => v_mmtt_rec.transaction_uom

         , p_transaction_id          => NULL -- mtl_trx_line.transaction_id  ***
         , p_global_procurement_flag => 'N'
         , p_drop_ship_flag          => 'N'

         , p_from_organization_id    => v_mmtt_rec.organization_id
         , p_from_ou                 => 1 -- Passing dummy value as this is fetched again in GMF.
         , p_to_organization_id      => v_mmtt_rec.transfer_organization
         , p_to_ou                   => 1 -- Passing dummy value as this is fetched again in GMF.

         , p_transfer_type           => 'INTORG'
         , p_transfer_source         => 'INTORG'

         , x_return_status           => x_return_status
         , x_msg_data                => x_msg_data
         , x_msg_count               => x_msg_count

         , x_transfer_price          => x_transfer_price
         , x_transfer_price_priuom   => x_transfer_price_priuom	/* Store Transfer Price in pri uom */
         , x_currency_code           => x_currency_code
         , x_incr_transfer_price     => x_incr_transfer_price
         , x_incr_currency_code      => x_incr_currency_code
         );

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    	THEN
      		inv_log_util.trace('X_return status is <> S',g_pkg_name || '.' || l_api_name, 5);
  		x_transfer_price  := 0;
    	END IF;

        inv_log_util.trace('x_transfer_price is:' || x_transfer_price, g_pkg_name || '.' || l_api_name, 5);
        inv_log_util.trace('x_currency_code is :' || x_currency_code, g_pkg_name || '.' || l_api_name, 5);
     END IF;

    -- End Bug 10158934
	--BUG13657375 Begin
       inv_log_util.trace('v_trxtempid is:' || v_trxtempid, g_pkg_name || '.' || l_api_name, 5);
       inv_log_util.trace('v_orgid is :' || v_orgid, g_pkg_name || '.' || l_api_name, 5);
       inv_log_util.trace('v_mmtt_rec.transaction_reference is :' || v_mmtt_rec.transaction_reference, g_pkg_name || '.' || l_api_name, 5);

	BEGIN
		select transaction_reference into v_mmtt_rec.transaction_reference
		from mtl_material_transactions_temp
		where transaction_temp_id = v_trxtempid
		and organization_id = v_orgid;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
				IF (l_debug = 1) THEN
				inv_log_util.TRACE('no data found insert_line_trx', 'INV_LPN_TRX_PUB', 1);
				END IF;
	END;
	--BUG13657375 end

    -- Added two columns to MMTT for International drop shipments -
    -- trx_flow_header_id and logical_trx_type_code
    -- Added original_transaction_temp_id to MMTT as part of ERES changes
    -- Added source_line_id and source_code for bug 4931515
    -- Added SOURCE_PROJECT_ID and SOURCE_TASK_ID for bug#5224902
    INSERT INTO mtl_material_transactions_temp
                (
                 transaction_header_id
               , transaction_temp_id
	       , source_code
	       , source_line_id
               , process_flag
               , creation_date
               , created_by
               , last_update_date
               , last_updated_by
               , last_update_login
               , inventory_item_id
               , organization_id
               , subinventory_code
               , locator_id
               , transfer_to_location
               , transaction_quantity
               , primary_quantity
               , transaction_uom
			   , transaction_source_name --16100381
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_date
               , acct_period_id
               , transfer_organization
               , transfer_subinventory
               , reason_id
               , shipment_number
               , distribution_account_id
               , waybill_airbill
               , expected_arrival_date
               , freight_code
               , revision
               , lpn_id
               , content_lpn_id
               , transfer_lpn_id
               , cost_group_id
               , transaction_source_id
               , trx_source_line_id
               , demand_source_header_id
               , demand_source_line
               , posting_flag
               , pick_rule_id
               , pick_strategy_id
               , put_away_rule_id
               , put_away_strategy_id
               , move_order_line_id
               , pick_slip_number
               , reservation_id
               , transaction_status
               , standard_operation_id
               , task_priority
               , wms_task_type
               , transfer_cost_group_id
               , wip_entity_type
               , repetitive_line_id
               , operation_seq_num
               , department_id
               , department_code
               , lock_flag
               , primary_switch
               , wip_supply_type
               , negative_req_flag
               , required_flag
               , completion_transaction_id
               , flow_schedule
               , transaction_batch_id
               , transaction_batch_seq
               , transaction_mode
               , owning_organization_id
               , owning_tp_type
               , xfr_owning_organization_id
               , transfer_owning_tp_type
               , planning_organization_id
               , planning_tp_type
               , xfr_planning_organization_id
               , transfer_planning_tp_type
               , fob_point
               , intransit_account
               , trx_flow_header_id
               , logical_trx_type_code
               , original_transaction_temp_id
               , secondary_uom_code             --kkillams
               , secondary_transaction_quantity --kkillams
               , ship_to_location --eIB Build; Bug# 4348541
               , relieve_reservations_flag      /*** {{ R12 Enhanced reservations code changes ***/
               , relieve_high_level_rsv_flag    /*** {{ R12 Enhanced reservations code changes ***/
               , cycle_count_id                 -- bug 5060715
			   , physical_adjustment_id    	-- Changes for Phy Inv ER - bug 13865417
	       , source_project_id              -- bug 5224902
	       , source_task_id
               , MATERIAL_ALLOCATION_TEMP_ID  -- Added for bug # 5689491
               , transfer_price		  -- Bug 10158934
               , ATTRIBUTE_CATEGORY --bug for 12876009  from
               , ATTRIBUTE1
               , ATTRIBUTE2
               , ATTRIBUTE3
               , ATTRIBUTE4
               , ATTRIBUTE5
               , ATTRIBUTE6
               , ATTRIBUTE7
               , ATTRIBUTE8
               , ATTRIBUTE9
               , ATTRIBUTE10
               , ATTRIBUTE11
               , ATTRIBUTE12
               , ATTRIBUTE13
               , ATTRIBUTE14
               , ATTRIBUTE15  --bug for 12876009  end
               , transaction_reference -- bug 13657375
                )
         VALUES (
                 v_mmtt_rec.transaction_header_id
               , v_mmtt_rec.transaction_temp_id
	       , v_mmtt_rec.source_code
	       , v_mmtt_rec.source_line_id
               , v_mmtt_rec.process_flag
               , v_mmtt_rec.creation_date
               , v_mmtt_rec.created_by
               , v_mmtt_rec.last_update_date
               , v_mmtt_rec.last_updated_by
               , v_mmtt_rec.last_update_login
               , v_mmtt_rec.inventory_item_id
               , v_mmtt_rec.organization_id
               , v_mmtt_rec.subinventory_code
               , v_mmtt_rec.locator_id
               , v_mmtt_rec.transfer_to_location
               , v_mmtt_rec.transaction_quantity
               , v_mmtt_rec.primary_quantity
               , v_mmtt_rec.transaction_uom
			   , v_mmtt_rec.transaction_source_name --16100381
               , v_mmtt_rec.transaction_type_id
               , v_mmtt_rec.transaction_action_id
               , v_mmtt_rec.transaction_source_type_id
               , v_mmtt_rec.transaction_date
               , v_mmtt_rec.acct_period_id
               , v_mmtt_rec.transfer_organization
               , v_mmtt_rec.transfer_subinventory
               , v_mmtt_rec.reason_id
               , v_mmtt_rec.shipment_number
               , v_mmtt_rec.distribution_account_id
               , v_mmtt_rec.waybill_airbill
               , v_mmtt_rec.expected_arrival_date
               , v_mmtt_rec.freight_code
               , v_mmtt_rec.revision
               , v_mmtt_rec.lpn_id
               , v_mmtt_rec.content_lpn_id
               , v_mmtt_rec.transfer_lpn_id
               , NVL(v_cost_group_id, v_mmtt_rec.cost_group_id)
               , v_mmtt_rec.transaction_source_id
               , v_mmtt_rec.trx_source_line_id
               , v_mmtt_rec.demand_source_header_id
               , v_mmtt_rec.demand_source_line
               , v_mmtt_rec.posting_flag
               , v_mmtt_rec.pick_rule_id
               , v_mmtt_rec.pick_strategy_id
               , v_mmtt_rec.put_away_rule_id
               , v_mmtt_rec.put_away_strategy_id
               , v_mmtt_rec.move_order_line_id
               , v_mmtt_rec.pick_slip_number
               , v_mmtt_rec.reservation_id
               , v_mmtt_rec.transaction_status
               , v_mmtt_rec.standard_operation_id
               , v_mmtt_rec.task_priority
               , v_mmtt_rec.wms_task_type
               , l_xfr_cst_grp_id
               , v_mmtt_rec.wip_entity_type
               , v_mmtt_rec.repetitive_line_id
               , v_mmtt_rec.operation_seq_num
               , v_mmtt_rec.department_id
               , v_mmtt_rec.department_code
               , v_mmtt_rec.lock_flag
               , v_mmtt_rec.primary_switch
               , v_mmtt_rec.wip_supply_type
               , v_mmtt_rec.negative_req_flag
               , v_mmtt_rec.required_flag
               , v_mmtt_rec.completion_transaction_id
               , v_mmtt_rec.flow_schedule
               , v_mmtt_rec.transaction_batch_id
               , v_mmtt_rec.transaction_batch_seq
               , v_mmtt_rec.transaction_mode
               , v_mmtt_rec.owning_organization_id
               , v_mmtt_rec.owning_tp_type
               , v_mmtt_rec.xfr_owning_organization_id
               , v_mmtt_rec.transfer_owning_tp_type
               , v_mmtt_rec.planning_organization_id
               , v_mmtt_rec.planning_tp_type
               , v_mmtt_rec.xfr_planning_organization_id
               , v_mmtt_rec.transfer_planning_tp_type
               , v_mmtt_rec.fob_point
               , v_mmtt_rec.intransit_account
               , v_mmtt_rec.trx_flow_header_id
               , v_mmtt_rec.logical_trx_type_code
               , v_mmtt_rec.original_transaction_temp_id
               , v_mmtt_rec.secondary_uom_code             --kkillams
               , v_mmtt_rec.secondary_transaction_quantity --kkillams
               , v_mmtt_rec.ship_to_location --eIB Build; Bug# 4348541
               , v_mmtt_rec.relieve_reservations_flag      /*** {{ R12 Enhanced reservations code changes ***/
               , v_mmtt_rec.relieve_high_level_rsv_flag    /*** {{ R12 Enhanced reservations code changes ***/
               , v_mmtt_rec.cycle_count_id                 --bug 5060715
			   , v_mmtt_rec.physical_adjustment_id        -- Changes for Phy Inv ER - bug 13865417
	       , v_mmtt_rec.source_project_id              --bug 5224902
	       , v_mmtt_rec.source_task_id
               , v_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID  -- Added for bug # 5689491
               , x_transfer_price		  -- Bug 10158934
               , v_mmtt_rec.ATTRIBUTE_CATEGORY --bug for 12876009 from
               , v_mmtt_rec.ATTRIBUTE1
               , v_mmtt_rec.ATTRIBUTE2
               , v_mmtt_rec.ATTRIBUTE3
               , v_mmtt_rec.ATTRIBUTE4
               , v_mmtt_rec.ATTRIBUTE5
               , v_mmtt_rec.ATTRIBUTE6
               , v_mmtt_rec.ATTRIBUTE7
               , v_mmtt_rec.ATTRIBUTE8
               , v_mmtt_rec.ATTRIBUTE9
               , v_mmtt_rec.ATTRIBUTE10
               , v_mmtt_rec.ATTRIBUTE11
               , v_mmtt_rec.ATTRIBUTE12
               , v_mmtt_rec.ATTRIBUTE13
               , v_mmtt_rec.ATTRIBUTE14
               , v_mmtt_rec.ATTRIBUTE15 --bug for 12876009  end
	       , v_mmtt_rec.transaction_reference -- bug 13657375
                );

--Added bug 3978111
		IF v_mmtt_rec.content_lpn_id is not null
		AND v_mmtt_rec.transaction_action_id=31
		AND v_mmtt_rec.transaction_type_id=44 THEN
			create_snapshot(x_trxtempid,v_mmtt_rec.organization_id);
		END IF;
--Added bug 3978111
  END;

  /********************************************************************
   * Insert a row into MTL_TRANSACTION_LOTS_TEMP
   *******************************************************************/
  FUNCTION insert_lot_trx(curlpnrec wms_container_pub.wms_container_content_rec_type, trxtmpid NUMBER)
    RETURN NUMBER IS
    lotobjid      NUMBER;
    sertrxid      NUMBER;
    retval        NUMBER;
    l_exp_date    DATE;
    l_primary_uom VARCHAR2(3);
    l_primary_qty NUMBER;
    l_debug       NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
	l_parent_lot_number MTL_LOT_NUMBERS.PARENT_LOT_NUMBER%TYPE := NULL; --12949776
  BEGIN
    -- retrieve the expiration-date for the lot number
    -- being inserted
    BEGIN
	/*12949776
	  Added parent_lot_number to fetch from MLN and pass to insert api.
	*/
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Fetching the Exp Date and Parent Lot Number', 'INV_LPN_TRX_PUB', 1);
      END IF;

      SELECT expiration_date, parent_lot_number
        INTO l_exp_date, l_parent_lot_number
        FROM mtl_lot_numbers
       WHERE organization_id = curlpnrec.organization_id
         AND inventory_item_id = curlpnrec.content_item_id
         AND lot_number = curlpnrec.lot_number;
    EXCEPTION
      WHEN OTHERS THEN
        l_exp_date  := NULL;
		l_parent_lot_number  := NULL; --12949776
    END;
--12949776
      IF (l_debug = 1) THEN
        inv_log_util.TRACE(' After Fetching the Exp Date and Parent Lot Number - exp_date : ParentLot' ||l_exp_date||' : '||l_parent_lot_number , 'INV_LPN_TRX_PUB', 1);
      END IF;

    SELECT primary_uom_code
      INTO l_primary_uom
      FROM mtl_system_items
     WHERE inventory_item_id = curlpnrec.content_item_id
       AND organization_id = curlpnrec.organization_id;

--bug 8526601 added lot number and org id to make the inv_convert call lot specific
    l_primary_qty  := inv_convert.inv_um_convert(curlpnrec.content_item_id,curlpnrec.lot_number,curlpnrec.organization_id,5, curlpnrec.quantity, curlpnrec.uom, l_primary_uom, NULL, NULL);

    IF (l_primary_qty <= -99999) THEN
      fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
      fnd_message.set_token('uom1', curlpnrec.uom);
      fnd_message.set_token('uom2', l_primary_uom);
      fnd_message.set_token('module', 'INSERT_LOT_TRX');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    retval         :=
      inv_trx_util_pub.insert_lot_trx(
        p_trx_tmp_id                 => trxtmpid
      , p_user_id                    => 1
      , p_lot_number                 => curlpnrec.lot_number
      , p_trx_qty                    => curlpnrec.quantity
      , p_pri_qty                    => l_primary_qty
      , p_secondary_qty              => curlpnrec.sec_quantity --INVCONV kkillams
      , p_secondary_uom              => curlpnrec.sec_uom      --INVCONV kkillams
      , x_ser_trx_id                 => sertrxid
      , x_proc_msg                   => ret_msgdata
      , p_exp_date                   => l_exp_date
      , p_parent_lot_number          => l_parent_lot_number /*12949776*/
      );

    IF (retval <> 0) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('**Error from insertLot :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
      END IF;

      fnd_message.set_name('INV', 'INV_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('*Inserted Lot :' || curlpnrec.lot_number, 'INV_LPN_TRX_PUB', 9);
    END IF;

    RETURN sertrxid;
  END;

  /********************************************************************
   * Insert a row into MTL_SERIAL_NUMBERS_TEMP
   *******************************************************************/
  FUNCTION insert_ser_trx(p_ser_number VARCHAR2, p_sertrxid NUMBER)
    RETURN NUMBER IS
    retval  NUMBER;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    retval  :=
      inv_trx_util_pub.insert_ser_trx(p_trx_tmp_id => p_sertrxid, p_user_id => 1, p_fm_ser_num => p_ser_number
      , p_to_ser_num                 => p_ser_number, x_proc_msg => ret_msgdata);

    IF (retval <> 0) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('**Error from insertSerial :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
      END IF;

      fnd_message.set_name('INV', 'INV_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('*Inserted Serial:' || p_ser_number || ',trxid=' || p_sertrxid, 'INV_LPN_TRX_PUB', 9);
    END IF;

    RETURN 0;
  END;
  /*  Bug#5486052. Added the below function. This function takes itemID, quantity and 2 UOM codes as input parameters.
   *  It returns the quantity, which was expressed in the 1st UOM, converted to the 2nd UOM.*/
 ----bug 8526601   added lot number and org id  as IN parameters to make the inv_convert call lot specific
  FUNCTION get_converted_qty(p_inventory_item_id NUMBER,p_lot_number VARCHAR2,p_organization_id NUMBER, p_qty NUMBER, p_uom1 VARCHAR2, p_uom2 VARCHAR2)
  RETURN NUMBER IS
    l_converted_qty NUMBER;
  BEGIN
   ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
    l_converted_qty := inv_convert.inv_um_convert(   p_inventory_item_id
                                                   ,p_lot_number
                                                   ,p_organization_id
                                                   , 6
                                                   , p_qty
                                                   , p_uom1
                                                   , p_uom2
                                                   , NULL
                                                   , NULL);
    IF ( l_converted_qty = -99999 ) THEN
      fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
      fnd_message.set_token('uom1', p_uom1);
      fnd_message.set_token('uom2', p_uom2);
      fnd_message.set_token('module', 'GET_CONVERTED_QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    RETURN l_converted_qty;
  END;

  /********************************************************************
   * Explode the contents of the lpn and insert into MMTT, MSNT and MTLT
   *******************************************************************/
  FUNCTION explode_and_insert(p_lpn_id NUMBER, p_hdr_id NUMBER, p_mmtt IN OUT NOCOPY mtl_material_transactions_temp%ROWTYPE)
    RETURN NUMBER IS
    tb_lpn_cnts           wms_container_pub.wms_container_tbl_type;
    lpnitndx              NUMBER;
    curlpnrec             wms_container_pub.wms_container_content_rec_type;
    insrowcnt             NUMBER                                           := 0;
    trxtmpid              NUMBER;
    sertrxid              NUMBER;
    l_pre_sertrxid        NUMBER;
    retval                NUMBER;
    itemqty               NUMBER;
    itemsecqty            NUMBER;  --INVCONV kkillams
    orgid                 NUMBER;
    subinv                VARCHAR2(32);
    locatorid             NUMBER;
    lastitemid            NUMBER                                           := NULL;
    lastrevison           VARCHAR2(3);
    lastcostgroupid       NUMBER                                           := NULL;
    lastparentlpnid       NUMBER                                           := NULL;
    lotexpdate            DATE;
    lotobjid              NUMBER;
    v_lasttrxtmpid        NUMBER;
    v_lastitemqty         NUMBER;
    v_lastitemsecqty      NUMBER;  ---INVCONV KKILLAMS
    lastlotnum            mtl_transaction_lots_temp.lot_number%TYPE;
    itemqtychanged        BOOLEAN                                          := FALSE;
    lotqtychanged         BOOLEAN                                          := FALSE;
    lotqty                NUMBER;
    lotsecqty             NUMBER;  --invconv kkillams
    l_lpn_subinv          VARCHAR2(32)                                     := p_mmtt.subinventory_code;
    l_lpn_locator_id      NUMBER                                           := p_mmtt.locator_id;
    l_cst_grp_id          NUMBER;
    l_xfr_cst_grp_id      NUMBER;
    l_debug               NUMBER                                           := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    /* Bug 2712046, add cost group comingle check if the transfer location is non-LPN controlled
       new variable to check LPN controlled flag of the transfer subinventory */
    l_skip_comingle_check NUMBER                                           := 0;
    --l_lpn_controlled_flag number := 0;
    ret_status            VARCHAR2(10);
    ret_msgcnt            NUMBER;
    ret_msgdata           VARCHAR2(2000);
    l_comingling_occurs   VARCHAR2(1);
    l_count               NUMBER;
    l_cst_grp             VARCHAR2(30);
    lastuom               VARCHAR2(3); /*Bug#5486052*/
    l_conv_fact           NUMBER                                           := 1; /*Bug#5486052*/
    l_primary_uom         VARCHAR2(3); /*Bug#5486052*/
    l_converted_qty       NUMBER; /*Bug#5486052*/
  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('** exploding lpn_id =' || p_lpn_id || ',qty=' || p_mmtt.primary_quantity, 'INV_LPN_TRX_PUB', 9);
    END IF;

    -- Bug 5103408 Add check for explode_lpn failure status.
    -- Transaction should not continue if an error occurs during explosion
    WMS_Container_PVT.Explode_LPN(1.0, fnd_api.g_false, fnd_api.g_false, ret_status, ret_msgcnt, ret_msgdata, p_lpn_id, 0, tb_lpn_cnts);

    IF ( ret_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('**Error: Failed in wms_container_pub.explode_lpn API :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- Retrieve LPN's SUB and Locator
    SELECT subinventory_code
         , locator_id
      INTO l_lpn_subinv
         , l_lpn_locator_id
      FROM wms_license_plate_numbers
     WHERE lpn_id = p_lpn_id;

    -- If No Subinventory associated with LPN, then pick sub and locator from MMT
    IF (l_lpn_subinv IS NULL) THEN
      l_lpn_subinv      := p_mmtt.subinventory_code;
      l_lpn_locator_id  := p_mmtt.locator_id;
    END IF;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('LPN sub : ' || l_lpn_subinv || ',loc=' || l_lpn_locator_id, 'INV_LPN_TRX_PUB', 9);
    END IF;

    --Check for batch ID and batch sequence.  If they do not exist, populate them
    --Also set inventory_item_id to -1 to ensure this record is processed first
    --in the batch
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('batch id=' || p_mmtt.transaction_batch_id || 'seq_id =' || p_mmtt.transaction_batch_seq, 'INV_LPN_TRX_PUB', 9);
    END IF;

    IF (p_mmtt.transaction_batch_id IS NULL OR p_mmtt.transaction_batch_seq IS NULL) THEN
      -- Batch id and sequence pair should be unique for this header_id.
      -- Going to used the transaction_temp_id for the batch and 1 for the sequence.
      p_mmtt.transaction_batch_id  := NVL(p_mmtt.transaction_batch_id, p_mmtt.transaction_temp_id);
      p_mmtt.transaction_batch_seq := NVL(p_mmtt.transaction_batch_seq, 1);

      UPDATE mtl_material_transactions_temp
         SET inventory_item_id = -1
           , transaction_batch_id = p_mmtt.transaction_batch_id
           , transaction_batch_seq = p_mmtt.transaction_batch_seq
           , subinventory_code = NVL(subinventory_code, l_lpn_subinv)
           , locator_id = NVL(locator_id, l_lpn_locator_id)
       WHERE transaction_temp_id = p_mmtt.transaction_temp_id;

      --  If transaction came from MTI, need to also update MTI with
      -- the same batch and sequence so java tm can update delete MTIs
      IF ( p_mmtt.transaction_mode = inv_txn_manager_pub.proc_mode_mti ) THEN
        UPDATE mtl_transactions_interface
           SET transaction_batch_id = p_mmtt.transaction_batch_id
             , transaction_batch_seq = p_mmtt.transaction_batch_seq
         WHERE transaction_interface_id = p_mmtt.transaction_temp_id;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('From MTI, try update MTI batch and seq rowcount='||sql%rowcount, 'INV_LPN_TRX_PUB', 9);
        END IF;

        IF ( sql%rowcount = 0 ) THEN
          fnd_message.set_name('INV', 'INV_NO_RECORDS');
          fnd_message.set_token('ENTITY', 'MTL_TRANSACTIONS_INTERFACE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    ELSIF(p_mmtt.inventory_item_id <> -1) THEN
      UPDATE mtl_material_transactions_temp
         SET inventory_item_id = -1
       WHERE transaction_temp_id = p_mmtt.transaction_temp_id;
    END IF;

    -- Bug 2712046, add cost group comingle check if transfer location is non-LPN controlled
    -- Set value for l_check_cg_comingle, this only need to be checked once before the Loop
    IF (p_mmtt.transaction_action_id <> inv_globals.g_action_orgxfr)
       AND(p_mmtt.transaction_action_id <> inv_globals.g_action_intransitshipment)
       AND(p_mmtt.transaction_action_id <> inv_globals.g_action_intransitreceipt)
       AND(NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code) IS NOT NULL) THEN
      SELECT NVL(lpn_controlled_flag, 2)
        INTO l_skip_comingle_check
        FROM mtl_secondary_inventories
       WHERE organization_id = NVL(p_mmtt.transfer_organization, p_mmtt.organization_id)
         AND secondary_inventory_name = NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code);

      IF SQL%NOTFOUND THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('No sub found when checking lpn_controlled_flag', 'INV_LPN_TRX_PUB', 5);
        END IF;

        fnd_message.set_name('INV', 'INV_INT_XSUBCODE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE(
             'Checked lpn_controlled_flag for txnAction '
          || p_mmtt.transaction_action_id
          || ' and Sub '
          || NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
          || ', result='
          || l_skip_comingle_check
        , 'INV_LPN_TRX_PUB'
        , 9
        );
      END IF;

      -- If sub in not subinventory controlled check locator to see if is
      -- a pjm locator.  If it is no comingle check is requires since the
      -- locators will be changed anyway.
      IF (l_skip_comingle_check = 2) THEN
        BEGIN
          SELECT 1
            INTO l_skip_comingle_check
            FROM mtl_item_locations
           WHERE project_id IS NOT NULL
             AND inventory_location_id = NVL(p_mmtt.transfer_to_location, p_mmtt.locator_id)
             AND subinventory_code = NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
             AND organization_id = NVL(p_mmtt.transfer_organization, p_mmtt.organization_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_skip_comingle_check  := 2;
            inv_log_util.TRACE('NOTFOUND l_skip_comingle_check=' || l_skip_comingle_check, 'INV_LPN_TRX_PUB', 5);
        END;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Checked if is a pjm locator l_skip_comingle_check=' || l_skip_comingle_check, 'INV_LPN_TRX_PUB', 5);
        END IF;
      END IF;
    ELSE
      l_skip_comingle_check  := 1;
    END IF;

    -- Loop and Insert all the LPN contents into MMTT
    lpnitndx  := tb_lpn_cnts.FIRST;

    LOOP
      curlpnrec  := tb_lpn_cnts(lpnitndx);

      IF (l_debug = 1) THEN
        inv_log_util.TRACE(
             ' cntlpnid = '
          || curlpnrec.content_lpn_id
          || ',par lpnid='
          || curlpnrec.parent_lpn_id
          || ', item_id='
          || curlpnrec.content_item_id
          || ',qty='
          || curlpnrec.quantity
          || ',sec_qty='
          || curlpnrec.sec_quantity
          || ',rev='
          || curlpnrec.revision
        , 'INV_LPN_TRX_PUB'
        , 9
        );
      END IF;

      -- We need to pupulate new MMTTs only for items within LPN. We need to
      -- weed-out the curlpnrec which stands for these cases :
      --  *  LPN inside another LPN
      --  *  LPN which has item associated with it
      --  *  LPN which has no item inside it
      IF (curlpnrec.content_item_id IS NOT NULL)
         AND(curlpnrec.content_lpn_id IS NULL) THEN
        insrowcnt        := insrowcnt + 1;

        -- Check if itemid and revision is same as last processed record.
        -- If it is, then this is for a Lot or Serial attribute
        IF (
            curlpnrec.content_item_id = lastitemid
            AND curlpnrec.parent_lpn_id = lastparentlpnid
            AND curlpnrec.cost_group_id = lastcostgroupid
            AND NVL(curlpnrec.revision, '@@') = NVL(lastrevison, '@@')
			AND lastuom = curlpnrec.uom  --15837832
           ) THEN
          sertrxid        := v_lasttrxtmpid;
          itemqtychanged  := TRUE;
          /*Bug#5486052. If the UOM of the current record is not same as that of the last record,
            then convert the qty of the current record into the UOM of the last record.*/
          IF ( lastuom <> curlpnrec.uom ) THEN
 ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
            l_converted_qty := get_converted_qty(  curlpnrec.content_item_id
                                                 ,curlpnrec.lot_number
                                                 ,curlpnrec.organization_id
                                                 , curlpnrec.quantity
                                                 , curlpnrec.uom
                                                 , lastuom);
            curlpnrec.quantity := l_converted_qty;
            curlpnrec.uom := lastuom;
          END IF;
          /*Bug#5486052. End*/
          v_lastitemqty   := v_lastitemqty + curlpnrec.quantity;
          v_lastitemsecqty := NVL(v_lastitemsecqty,0) + NVL(curlpnrec.sec_quantity,0);   --INVCONV kkillams
          --Check Lot number
          IF (curlpnrec.lot_number IS NOT NULL) THEN
            IF (curlpnrec.lot_number <> lastlotnum) THEN
              IF (lotqtychanged) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('** Going to update last Lot rec1 qty = ' || lotqty, 'INV_LPN_TRX_PUB', 9);
                END IF;

                UPDATE mtl_transaction_lots_temp
                   SET transaction_quantity = lotqty
                     , primary_quantity = lotqty * l_conv_fact /*Bug#5486052.*/
                     , secondary_quantity   = lotsecqty  --INVCONV kkillams
                 WHERE transaction_temp_id = v_lasttrxtmpid
                   AND lot_number = lastlotnum;

                lotqtychanged  := FALSE;
              END IF;

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('** Inserting Lot Number ' || curlpnrec.lot_number, 'INV_LPN_TRX_PUB', 9);
              END IF;

              -- Bug 2795134/2712046 Comingle check failed when sub-transfer LPN to non-LPN controlled sub
              -- Need to add check here as well for same item but different lot numbers
              -- Bug 2795042, add condition of curlpnrec.cost_group_id IS NOT NULL
              -- because for WIP putaway where cost group will be derived later, so
              -- comingle_check will fail if cost_group_id is NULL
              -- Bug 2886342. Add Or condition of p_mmtt.cost_group_id IS NOT NULL
              --  This is the cases when cost group suggestion has been stamped on MMTT
              --  which will be transferred to MOQD or WMS_LPN_CONTENTS later.
              --  assign_cost_group will not be called, so need to do the comingling check here
              IF (l_skip_comingle_check = 2)
                 AND((curlpnrec.cost_group_id IS NOT NULL)
                     OR(p_mmtt.cost_group_id IS NOT NULL)) THEN
                -- Non LPN Controlled, check cost group comingle
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(
                       'Transfer to non-LPN controlled location, calling comingle_check with '
                    || 'p_org_id='
                    || NVL(p_mmtt.transfer_organization, p_mmtt.organization_id)
                    || ',p_item_id='
                    || curlpnrec.content_item_id
                    || ',p_rev='
                    || curlpnrec.revision
                    || ',p_lot='
                    || curlpnrec.lot_number
                    || ',sub='
                    || NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
                    || ',p_loc='
                    || NVL(p_mmtt.transfer_to_location, p_mmtt.locator_id)
                    || ',p_cg_id='
                    || NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id)
                  , 'INV_LPN_TRX_PUB'
                  , 9
                  );
                END IF;

                l_comingling_occurs  := 'N';
                inv_comingling_utils.comingle_check(
                  x_return_status              => ret_status
                , x_msg_count                  => ret_msgcnt
                , x_msg_data                   => ret_msgdata
                , x_comingling_occurs          => l_comingling_occurs
                , x_count                      => l_count
                , p_organization_id            => NVL(p_mmtt.transfer_organization, p_mmtt.organization_id)
                , p_inventory_item_id          => curlpnrec.content_item_id
                , p_revision                   => curlpnrec.revision
                , p_lot_number                 => curlpnrec.lot_number
                , p_subinventory_code          => NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
                , p_locator_id                 => NVL(p_mmtt.transfer_to_location, p_mmtt.locator_id)
                , p_lpn_id                     => NULL
                , p_cost_group_id              => NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id)
                );

                IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                  IF (l_debug = 1) THEN
                    inv_log_util.TRACE('**Error: Failed in comingling_check API :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
                  END IF;

                  RAISE fnd_api.g_exc_error;
                END IF;

                IF (l_comingling_occurs = 'Y') THEN
                  IF (l_debug = 1) THEN
                    inv_log_util.TRACE('**Error: Transaction results in co-mingling :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
                  END IF;

                  SELECT cost_group
                    INTO l_cst_grp
                    FROM cst_cost_groups
                   WHERE cost_group_id = NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id);

                  fnd_message.set_name('INV', 'INV_COMINGLE_FAIL');
                  fnd_message.set_token('CG', l_cst_grp);
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF;

              sertrxid    := insert_lot_trx(curlpnrec, v_lasttrxtmpid);
              lastlotnum  := curlpnrec.lot_number;
              lotqty      := curlpnrec.quantity;
              lotsecqty   := curlpnrec.sec_quantity; --INVCONV kkillams
            ELSE
              -- Item and LotNumber same as previous. Use the transactionId
              -- used by the last serial insertions.
              sertrxid       := l_pre_sertrxid;
              lotqty         := lotqty + curlpnrec.quantity;
              lotsecqty      := NVL(lotsecqty,0) + NVL(curlpnrec.sec_quantity,0);  --INVCONV kkillams
              lotqtychanged  := TRUE;
            END IF;
          ELSE
            IF (lotqtychanged) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('** Going to update last Lot rec2 qty = ' || lotqty, 'INV_LPN_TRX_PUB', 9);
              END IF;

              UPDATE mtl_transaction_lots_temp
                 SET transaction_quantity = lotqty
                   , primary_quantity = lotqty * l_conv_fact /*Bug#5486052.*/
                   , secondary_quantity   = lotsecqty  --INVCONV kkillams
               WHERE transaction_temp_id = v_lasttrxtmpid
                 AND lot_number = lastlotnum;

              lotqtychanged  := FALSE;
            END IF;
          END IF;

          IF (curlpnrec.serial_number IS NOT NULL) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** Inserting Serial Number ' || curlpnrec.serial_number, 'INV_LPN_TRX_PUB', 9);
            END IF;

            retval          := insert_ser_trx(curlpnrec.serial_number, sertrxid);
            l_pre_sertrxid  := sertrxid;
          END IF;
        ELSE   -- New item record
                -- Bug 2712046 Need to check cost group comingling if the transfer location
                -- is non-LPN controlled.
                -- Bug 2795042, add condition of curlpnrec.cost_group_id IS NOT NULL
		          -- because for WIP putaway where cost group will be derived later, so
                -- comingle_check will fail if cost_group_id is NULL
                -- Bug 2886342. Add Or condition of p_mmtt.cost_group_id IS NOT NULL
                --  This is the cases when cost group suggestion has been stamped on MMTT
                --  which will be transferred to MOQD or WMS_LPN_CONTENTS later.
                --  assign_cost_group will not be called, so need to do the comingling check here

          IF (l_skip_comingle_check = 2)
             AND((curlpnrec.cost_group_id IS NOT NULL)
                 OR(p_mmtt.cost_group_id IS NOT NULL)) THEN
            -- Non LPN Controlled, check cost group comingle
            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                   'Transfer to non-LPN controlled location, calling comingle_check with '
                || 'p_org_id='
                || NVL(p_mmtt.transfer_organization, p_mmtt.organization_id)
                || ',p_item_id='
                || curlpnrec.content_item_id
                || ',p_rev='
                || curlpnrec.revision
                || ',p_lot='
                || curlpnrec.lot_number
                || ',sub='
                || NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
                || ',p_loc='
                || NVL(p_mmtt.transfer_to_location, p_mmtt.locator_id)
                || ',p_cg_id='
                || NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id)
              , 'INV_LPN_TRX_PUB'
              , 9
              );
            END IF;

            inv_comingling_utils.comingle_check(
              x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , x_comingling_occurs          => l_comingling_occurs
            , x_count                      => l_count
            , p_organization_id            => NVL(p_mmtt.transfer_organization, p_mmtt.organization_id)
            , p_inventory_item_id          => curlpnrec.content_item_id
            , p_revision                   => curlpnrec.revision
            , p_lot_number                 => curlpnrec.lot_number
            , p_subinventory_code          => NVL(p_mmtt.transfer_subinventory, p_mmtt.subinventory_code)
            , p_locator_id                 => NVL(p_mmtt.transfer_to_location, p_mmtt.locator_id)
            , p_lpn_id                     => NULL
            , p_cost_group_id              => NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id)
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Error: Failed in comingling_check API :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_comingling_occurs = 'Y') THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Error: Transaction results in co-mingling :' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
              END IF;

              SELECT cost_group
                INTO l_cst_grp
                FROM cst_cost_groups
               WHERE cost_group_id = NVL(curlpnrec.cost_group_id, p_mmtt.cost_group_id);

              fnd_message.set_name('INV', 'INV_COMINGLE_FAIL');
              fnd_message.set_token('CG', l_cst_grp);
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          -- End Bug 2712046

          -- if the previous item's qty was changed, then update record
          IF (itemqtychanged) THEN
            IF (p_mmtt.transaction_action_id = inv_globals.g_action_issue)
               OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment) THEN
              v_lastitemqty  := -1 * v_lastitemqty;

              IF v_lastitemsecqty <> 0 THEN -- INVCONV KKILLAMS
                v_lastitemsecqty  := -1 * v_lastitemsecqty;
              END IF;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** Going to upd lst rec1. qty = ' || v_lastitemqty, 'INV_LPN_TRX_PUB', 9);
            END IF;

            UPDATE mtl_material_transactions_temp
               SET transaction_quantity = v_lastitemqty
                 , primary_quantity = v_lastitemqty * l_conv_fact /*Bug#5486052.*/
                 , secondary_transaction_quantity   =  CASE WHEN v_lastitemsecqty <> 0 THEN v_lastitemsecqty ELSE secondary_transaction_quantity END --INVCONV kkillams
             WHERE transaction_temp_id = v_lasttrxtmpid;

            itemqtychanged               := FALSE;
            p_mmtt.transaction_quantity  := v_lastitemqty;
            p_mmtt.primary_quantity      := v_lastitemqty;
            p_mmtt.secondary_transaction_quantity  := CASE WHEN v_lastitemsecqty <> 0 THEN v_lastitemsecqty ELSE p_mmtt.secondary_transaction_quantity END; --INVCONV kkillams

            IF (lotqtychanged) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('** Going to upd lst lot3. qty = ' || lotqty, 'INV_LPN_TRX_PUB', 9);
              END IF;

              UPDATE mtl_transaction_lots_temp
                 SET transaction_quantity = lotqty
                     , primary_quantity = lotqty * l_conv_fact /*Bug#5486052.*/
                     , secondary_quantity   = lotsecqty  --INVCONV kkillams
               WHERE transaction_temp_id = v_lasttrxtmpid
                 AND lot_number = lastlotnum;
            END IF;
          END IF;

          -- If this an InterOrg Xfer transaction, then call the CostGroup API
          -- for the previously entered content Item. At this stage all the
          -- rows for this item would have been entered to the temp tables.
          IF (lastitemid IS NOT NULL) THEN
            IF (p_mmtt.transaction_action_id = inv_globals.g_action_orgxfr)
               OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
               OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitreceipt)
               OR
                 -- Bug 2712046 Cost group and comingling check is not executed when putaway a whole LPN for WIP
                 -- Changed to add the condition that if cost group ID is null then also need to call cost group API
               (  p_mmtt.cost_group_id IS NULL) THEN
              inv_cost_group_pvt.assign_cost_group(
                x_return_status              => ret_status
              , x_msg_count                  => ret_msgcnt
              , x_msg_data                   => ret_msgdata
              , p_organization_id            => p_mmtt.organization_id
              , p_mmtt_rec                   => p_mmtt
              , p_fob_point                  => NULL
              , p_line_id                    => p_mmtt.transaction_temp_id
              , p_input_type                 => inv_cost_group_pub.g_input_mmtt
              , x_cost_group_id              => l_cst_grp_id
              , x_transfer_cost_group_id     => l_xfr_cst_grp_id
              );

              IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(' Error from CostGrpAPI:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_COST_GROUP_FAILURE');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            -- If this is for an OrgXfr transaction, update the cost_group_id
            -- of the content item for this LPN as this could have been
            -- changed by the CG API.
            END IF;
          END IF;

          itemqtychanged  := FALSE;
          lotqtychanged   := FALSE;
          lotqty          := 0;
          lotsecqty           := 0;  --INVCONV kkillams
          v_lastitemqty   := curlpnrec.quantity;
          v_lastitemsecqty    := curlpnrec.sec_quantity; --INVCONV kkillams

          -- insert a record into MMTT.
          IF (p_mmtt.transaction_action_id = inv_globals.g_action_issue)
             OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
             OR((p_mmtt.transaction_action_id = inv_globals.g_action_inv_lot_translate)
                AND(p_mmtt.transaction_quantity < 0)) THEN
            itemqty  := -1 * curlpnrec.quantity;
            itemsecqty := -1 * curlpnrec.sec_quantity; --INVCONV kkillams
          ELSE
            itemqty  := curlpnrec.quantity;
            itemsecqty := -1 * curlpnrec.sec_quantity;  --INVCONV kkillams
          END IF;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE(
              '** inserting into MMTT. Mode-Normal. Qty=' || itemqty || ',sub=' || l_lpn_subinv || ',loc=' || l_lpn_locator_id
            , 'INV_LPN_TRX_PUB'
            , 9
            );
          END IF;

          insert_line_trx(
            curlpnrec
          , p_mmtt.transaction_temp_id
          , p_mmtt.transaction_action_id
          , p_mmtt.organization_id
          , l_lpn_subinv
          , l_lpn_locator_id
          , itemqty
          , curlpnrec.cost_group_id
          , p_mmtt
          , v_lasttrxtmpid
          , itemsecqty    --INCONV kkillams
          );
          sertrxid        := v_lasttrxtmpid;

          /*Bug#5486052. Added the below code to get the primary UOM code and the conversion factor
            between the primary UOM and current U0M for the current item.*/
          BEGIN
            SELECT primary_uom_code
            INTO l_primary_uom
            FROM mtl_system_items_b
            WHERE inventory_item_id = curlpnrec.content_item_id
              AND organization_id = curlpnrec.organization_id;
          EXCEPTION WHEN OTHERS THEN
              NULL;
          END;
          If ( curlpnrec.uom <> l_primary_uom ) THEN
 ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
            l_conv_fact := get_converted_qty(  curlpnrec.content_item_id
                                             ,curlpnrec.lot_number
                                             ,curlpnrec.organization_id
                                             , 1
                                             , curlpnrec.uom
                                             , l_primary_uom);
          ELSE
            l_conv_fact := 1;
          END IF;
          /*Bug#5486052. End.*/


          IF (l_debug = 1) THEN
            inv_log_util.TRACE('MMTT.retval=' || retval || ',lasttrxtmpid=' || v_lasttrxtmpid, 'INV_LPN_TRX_PUB', 9);
          END IF;

          IF (curlpnrec.lot_number IS NOT NULL) THEN
            sertrxid    := insert_lot_trx(curlpnrec, v_lasttrxtmpid);
            lastlotnum  := curlpnrec.lot_number;
            lotqty      := v_lastitemqty;
            lotsecqty   := v_lastitemsecqty;  --INVCONV kkillams
          END IF;

          IF (curlpnrec.serial_number IS NOT NULL) THEN
            retval          := insert_ser_trx(curlpnrec.serial_number, sertrxid);
            l_pre_sertrxid  := sertrxid;
          END IF;
        END IF;

        lastitemid       := curlpnrec.content_item_id;
        lastrevison      := curlpnrec.revision;
        lastcostgroupid  := curlpnrec.cost_group_id;
        lastparentlpnid  := curlpnrec.parent_lpn_id;
	lastuom          := curlpnrec.uom; /*Bug#5486052.*/
      END IF;   -- curlpnrec.content_item_id is not null

      EXIT WHEN lpnitndx = tb_lpn_cnts.LAST;
      lpnitndx   := tb_lpn_cnts.NEXT(lpnitndx);
    END LOOP;

    -- Any item or lot qty need to be updated ??
    IF (itemqtychanged) THEN
      IF (p_mmtt.transaction_action_id = inv_globals.g_action_issue)
         OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
         OR((p_mmtt.transaction_action_id = inv_globals.g_action_inv_lot_translate)
            AND(p_mmtt.transaction_quantity < 0)) THEN
        v_lastitemqty  := -1 * v_lastitemqty;
        IF v_lastitemsecqty IS NOT NULL THEN
           v_lastitemsecqty  := -1 * v_lastitemsecqty;  --INVCONV kkillams
        END IF;
      END IF;


      UPDATE mtl_material_transactions_temp
         SET transaction_quantity = v_lastitemqty
           , primary_quantity = v_lastitemqty * l_conv_fact /*Bug#5486052.*/
-- nsinghi bug#5553546 v_lastitemsecqty is being wrongly assigned as v_lastitemqty in THEN part. change it to v_lastitemsecqty
--	   , secondary_transaction_quantity    = CASE WHEN v_lastitemsecqty <> 0 THEN v_lastitemqty ELSE secondary_transaction_quantity END
           , secondary_transaction_quantity    = CASE WHEN v_lastitemsecqty <> 0 THEN v_lastitemsecqty ELSE secondary_transaction_quantity END
       WHERE transaction_temp_id = v_lasttrxtmpid;

      p_mmtt.transaction_quantity  := v_lastitemqty;
      p_mmtt.primary_quantity      := v_lastitemqty;
      p_mmtt.secondary_transaction_quantity  := CASE WHEN v_lastitemsecqty <> 0 THEN v_lastitemsecqty ELSE p_mmtt.secondary_transaction_quantity END; --INVCONV kkillams
      itemqtychanged               := FALSE;

      IF (lotqtychanged) THEN
        UPDATE mtl_transaction_lots_temp
           SET transaction_quantity = lotqty
             , primary_quantity = lotqty * l_conv_fact /*Bug#5486052.*/
             , secondary_quantity     = lotsecqty  --INVCONV kkillams
         WHERE transaction_temp_id = v_lasttrxtmpid
           AND lot_number = lastlotnum;
      END IF;
    END IF;

    -- If this an InterOrg Xfer transaction, then call the CostGroup API
    -- for the previously entered content Item. At this stage all the
    -- rows for this item would have been entered to the temp tables.
    IF (p_mmtt.transaction_action_id = inv_globals.g_action_orgxfr)
       OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
       OR(p_mmtt.transaction_action_id = inv_globals.g_action_intransitreceipt)
       OR
         -- Bug 2712046 Cost group and comingling check is not executed when putaway a whole LPN for WIP
         -- Changed to add the condition that if cost group ID is null then also need to call cost group API
       (  p_mmtt.cost_group_id IS NULL) THEN
      inv_cost_group_pvt.assign_cost_group(
        x_return_status              => ret_status
      , x_msg_count                  => ret_msgcnt
      , x_msg_data                   => ret_msgdata
      , p_organization_id            => p_mmtt.organization_id
      , p_mmtt_rec                   => p_mmtt
      , p_fob_point                  => NULL
      , p_line_id                    => p_mmtt.transaction_temp_id
      , p_input_type                 => inv_cost_group_pub.g_input_mmtt
      , x_cost_group_id              => l_cst_grp_id
      , x_transfer_cost_group_id     => l_xfr_cst_grp_id
      );

      IF (ret_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Error from CostGrpAPI:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
        END IF;

        fnd_message.set_name('INV', 'INV_COST_GROUP_FAILURE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    -- If this is for an OrgXfr transaction, update the cost_group_id
    -- of the content item for this LPN as this could have been
    -- changed by the CG API.
    END IF;

    RETURN insrowcnt;
  END;

  --FOB changes. Patchset J. This API is only called wif PO pathset J is installed
  -- We track the FOB info in MMTT + MMT.
  PROCEDURE update_fob_point(
    v_mmtt          IN OUT NOCOPY mtl_material_transactions_temp%ROWTYPE
  , x_return_status IN OUT NOCOPY VARCHAR2
  , x_msg_data      IN OUT NOCOPY VARCHAR2
  , x_msg_count     IN OUT NOCOPY NUMBER
  ) IS
    l_fob_point               NUMBER;
    l_intransit_inv_account   NUMBER;
    l_transfer_transaction_id NUMBER;
    l_shipment_line_id        NUMBER;
    l_mmt_transaction_id      NUMBER;
    l_debug                   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('PO J installed', 'INV_LPN_TRX_PUB', 1);
      inv_log_util.TRACE('Updating FOB_POINT', 'INV_LPN_TRX_PUB', 1);
      inv_log_util.TRACE('organization_id' || v_mmtt.organization_id, 'INV_LPN_TRX_PUB', 1);
      inv_log_util.TRACE('xfr_organization_id' || v_mmtt.transfer_organization, 'INV_LPN_TRX_PUB', 1);
      inv_log_util.TRACE('trx_action_id' || v_mmtt.transaction_action_id, 'INV_LPN_TRX_PUB', 1);
      inv_log_util.TRACE('trx_temp_id' || v_mmtt.transaction_temp_id, 'INV_LPN_TRX_PUB', 1);
    END IF;

    IF (v_mmtt.transaction_temp_id IS NULL) THEN
      x_msg_data  := 'Trx_temp_id is null return success';

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Trx_temp_id is null return success', 'INV_LPN_TRX_PUB', 1);
      END IF;

      RETURN;
    END IF;

    IF (v_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment) THEN
      BEGIN
        SELECT fob_point
             , intransit_inv_account
          INTO l_fob_point
             , l_intransit_inv_account
          FROM mtl_interorg_parameters
         WHERE from_organization_id = v_mmtt.organization_id
           AND to_organization_id = v_mmtt.transfer_organization;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('no data found INV_FOB_NOT_DEFINED', 'INV_LPN_TRX_PUB', 1);
          END IF;

          fnd_message.set_name('INV', 'INV_FOB_NOT_DEFINED');
          fnd_message.set_token('ENTITY1', v_mmtt.organization_id);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;

      UPDATE mtl_material_transactions_temp
         SET fob_point = l_fob_point
           , intransit_account = l_intransit_inv_account
       WHERE transaction_temp_id = v_mmtt.transaction_temp_id;

      /**bug 3371548 assign values to the cursor*/
      v_mmtt.fob_point          := l_fob_point;
      v_mmtt.intransit_account  := l_intransit_inv_account;
    ELSIF(v_mmtt.transaction_action_id = inv_globals.g_action_intransitreceipt) THEN
      BEGIN
        SELECT shipment_line_id
          INTO l_shipment_line_id
          FROM rcv_transactions
         WHERE transaction_id =v_mmtt.rcv_transaction_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('no data found rcv_transactions', 'INV_LPN_TRX_PUB', 1);
          END IF;

          RAISE fnd_api.g_exc_error;
      END;

        SELECT Nvl(mmt_transaction_id,-1)
          INTO l_mmt_transaction_id
          FROM rcv_shipment_lines
         WHERE shipment_line_id = l_shipment_line_id;

      IF (l_mmt_transaction_id = -1) then
	  /**bug 3527331
	  we have an issue on FOB point backward
	  compatibility when deliver a shipment created before FOB point
	    feature was enabled. Inv trxn mgr should take care of this
	    corner case.
	  In case rcv record does not have the reference to the
	  correspoding shipment transaction, we shoudl populate the
	  rcpt transaction with the fob_point by running a fresh query
	  int mtl_interorg parameters*/
	    BEGIN
	       SELECT fob_point
		 , intransit_inv_account
		 INTO l_fob_point
		 , l_intransit_inv_account
		 FROM mtl_interorg_parameters
		 WHERE from_organization_id = v_mmtt.transfer_organization
		 AND to_organization_id = v_mmtt.organization_id;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  IF (l_debug = 1) THEN
		     inv_log_util.TRACE('no data found INV_FOB_NOT_DEFINED', 'INV_LPN_TRX_PUB', 1);
		  END IF;
		  fnd_message.set_name('INV', 'INV_FOB_NOT_DEFINED');
		  fnd_message.set_token('ENTITY1', v_mmtt.organization_id);
		  fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END;
       else
      BEGIN
	 SELECT fob_point
	   , intransit_account
	   INTO l_fob_point
	   , l_intransit_inv_account
	   FROM mtl_material_transactions
	   WHERE transaction_id = l_mmt_transaction_id;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    IF (l_debug = 1) THEN
	       inv_log_util.TRACE('no data found mtl_material_transactions', 'INV_LPN_TRX_PUB', 1);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;
      END IF;
      UPDATE mtl_material_transactions_temp
	SET fob_point = l_fob_point
	, intransit_account = l_intransit_inv_account
	WHERE transaction_temp_id = v_mmtt.transaction_temp_id;

      /**bug 3371548 assign values to the cursor*/
      v_mmtt.fob_point          := l_fob_point;
      v_mmtt.intransit_account  := l_intransit_inv_account;
    END IF;   -- intransit Rcpt
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END update_fob_point;

  /********************************************************************
   * Pack or Unpack item/lpn. If lot or serial controlled, then
   *  query corresponding lot or serial records
   *******************************************************************/
  PROCEDURE Call_Pack_Unpack (
    p_tempid           NUMBER
  , p_content_lpn      NUMBER
  , p_lpn              NUMBER
  , p_item_rec         inv_validate.item
  , p_revision         VARCHAR2
  , p_primary_qty      NUMBER
  , p_qty              NUMBER
  , p_uom              VARCHAR2
  , p_org_id           NUMBER
  , p_subinv           VARCHAR2
  , p_locator          NUMBER
  , p_operation        NUMBER
  , p_cost_grp_id      NUMBER
  , p_trx_action       NUMBER
  , p_source_header_id NUMBER
  , p_source_name      VARCHAR2
  , p_source_type_id   NUMBER   --bug 3158847
  , p_sec_qty          NUMBER   --INVCONV kkillams
  , p_sec_uom          VARCHAR2 --INVCONV kkillams
  , p_source_trx_id    NUMBER
  ) IS
    v_sertrxid  NUMBER;
    v_lotfound  BOOLEAN      := FALSE;
    v_serfound  BOOLEAN      := FALSE;
    item_id     NUMBER       := NULL;
    v_lotnum    mtl_transaction_lots_temp.lot_number%TYPE;
    v_lotqty    NUMBER;
    v_lotsecqty    NUMBER;
    v_serqty    NUMBER;
    l_operation NUMBER       := p_operation;
    l_ignore_item_controls NUMBER;

    CURSOR c_sertmp IS
      SELECT fm_serial_number
           , to_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = v_sertrxid;

    CURSOR c_lottmp IS
      SELECT lot_number
           , primary_quantity
           , transaction_quantity
           , secondary_quantity
           , serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_tempid;

    l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF ( p_operation = g_unpack AND p_content_lpn IS NULL
         AND ( (p_source_type_id = inv_globals.g_sourcetype_purchaseorder AND p_trx_action = inv_globals.g_action_receipt)
            OR (p_source_type_id = inv_globals.g_sourcetype_rma AND p_trx_action = inv_globals.g_action_receipt)
            OR (p_source_type_id = inv_globals.g_sourcetype_intreq AND p_trx_action = inv_globals.g_action_intransitreceipt)
            OR (p_source_type_id = inv_globals.g_sourcetype_inventory AND p_trx_action = inv_globals.g_action_intransitreceipt)))
    THEN
      -- For the above types ignore the item controls
      l_ignore_item_controls := 1;
    ELSE
      -- Enforce item controls
      l_ignore_item_controls := 2;
    END IF;

    /*IF ( l_lpn.lpn_context = 4 AND p_trx_action_id = 8 ) THEN
      -- Change operation to new Adjust type
      l_operation := g_adjust;
    END IF;*/

    IF (p_content_lpn IS NOT NULL) THEN
      -- If content_lpn_id column has value then discard the item_id
      -- If content_lpn_id is Not NULL then we are packing/unpacking a
      -- whole LPN to/from another LPN, so no need to consider Lots and Serials
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('** pack/unpack of whole LPN **', 'INV_LPN_TRX_PUB', 9);
      END IF;

      WMS_Container_PVT.PackUnpack_Container(
        p_api_version           => 1.0
      , p_init_msg_list         => fnd_api.g_false
      , p_validation_level      => fnd_api.g_valid_level_none
      , x_return_status         => ret_status
      , x_msg_count             => ret_msgcnt
      , x_msg_data              => ret_msgdata
      , p_caller                => 'INV_TRNSACTION'
      , p_lpn_id                => p_lpn
      , p_content_lpn_id        => p_content_lpn
      , p_content_item_id       => item_id
      , p_revision              => p_revision
      , p_primary_quantity      => ABS(p_primary_qty)
      , p_quantity              => ABS(p_qty)
      , p_uom                   => p_uom
      , p_sec_quantity          => ABS(p_sec_qty)  --INVCONV kkillams
      , p_sec_uom               => p_sec_uom       --INVCONV kkillams
      , p_organization_id       => p_org_id
      , p_subinventory          => p_subinv
      , p_locator_id            => p_locator
      , p_operation             => l_operation
      , p_cost_group_id         => p_cost_grp_id
      , p_source_header_id      => p_source_header_id
      , p_source_name           => p_source_name
      , p_source_transaction_id => p_source_trx_id
      );

      IF (ret_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('**Error from LPN pack/unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
          inv_log_util.TRACE(
               '**p_lpn='
            || p_lpn
            || ',p_content_lpn='
            || p_content_lpn
            || ',item_id='
            || item_id
            || ',p_revision='
            || p_revision
            || ',p_org_id='
            || p_org_id
          , 'INV_LPN_TRX_PUB'
          , 1
          );
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE(
            ',p_subinv=' || p_subinv || ',p_locator=' || p_locator || ',p_operation=' || p_operation || ',p_cost_grp_id=' || p_cost_grp_id
          , 'INV_LPN_TRX_PUB'
          , 1
          );
        END IF;

        fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- We are packing/unpacking an Item. Check for Lot and Serials
      item_id := p_item_rec.inventory_item_id;

      -- retrieve corresponding lot numbers
      FOR v_lottmp IN c_lottmp LOOP
        v_lotfound  := TRUE;
        v_sertrxid  := v_lottmp.serial_transaction_temp_id;
        v_lotnum    := v_lottmp.lot_number;
        v_lotqty    := v_lottmp.primary_quantity;
        v_lotsecqty := v_lottmp.secondary_quantity; --INVCONV kkillams
        v_serfound  := FALSE;

        FOR v_sertmp IN c_sertmp LOOP
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('** Lot and Serial controlled**', 'INV_LPN_TRX_PUB', 9);
          END IF;

          v_serfound  := TRUE;

          IF (v_sertmp.to_serial_number IS NULL)
             OR(v_sertmp.fm_serial_number = v_sertmp.to_serial_number) THEN
            v_serqty  := 1;
          ELSE
            v_serqty  := inv_serial_number_pub.get_serial_diff(v_sertmp.fm_serial_number, v_sertmp.to_serial_number);
          END IF;

          /*3158847*/
          IF (
              p_item_rec.serial_number_control_code = 6 /*so issue*/
              AND p_source_type_id = 12 /*rma*/
              AND p_trx_action = 27 /*receipt*/
              AND p_operation = 1 /*pack*/
             ) THEN   /*pack as vanilla*/
            inv_log_util.TRACE('** Packing rma so issue serial as vanilla for receipt**', 'INV_LPN_TRX_PUB', 9);
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , x_return_status         => ret_status
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn
            , p_content_lpn_id        => p_content_lpn
            , p_content_item_id       => item_id
            , p_revision              => p_revision
            , p_lot_number            => v_lotnum
            , p_from_serial_number    => NULL --3158847
            , p_to_serial_number      => NULL --3158847v_sertmp.to_serial_number
            , p_primary_quantity      => v_serqty
            , p_quantity              => v_serqty
            , p_uom                   => p_item_rec.primary_uom_code
            , p_organization_id       => p_org_id
            , p_subinventory          => p_subinv
            , p_locator_id            => p_locator
            , p_operation             => l_operation
            , p_cost_group_id         => p_cost_grp_id
            , p_source_header_id      => p_source_header_id
            , p_source_name           => p_source_name
            , p_source_transaction_id => p_source_trx_id
            );
          ELSE
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , x_return_status         => ret_status
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn
            , p_content_lpn_id        => p_content_lpn
            , p_content_item_id       => item_id
            , p_revision              => p_revision
            , p_lot_number            => v_lotnum
            , p_from_serial_number    => v_sertmp.fm_serial_number
            , p_to_serial_number      => v_sertmp.to_serial_number
            , p_primary_quantity      => v_serqty
            , p_quantity              => v_serqty
            , p_uom                   => p_item_rec.primary_uom_code
            , p_organization_id       => p_org_id
            , p_subinventory          => p_subinv
            , p_locator_id            => p_locator
            , p_operation             => l_operation
            , p_cost_group_id         => p_cost_grp_id
            , p_source_header_id      => p_source_header_id
            , p_source_name           => p_source_name
            , p_source_transaction_id => p_source_trx_id
            );
          END IF;   /*end of 3158847*/

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('**Error from pack/unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(
                   '**p_lpn='
                || p_lpn
                || ',p_content_lpn='
                || p_content_lpn
                || ',item_id='
                || item_id
                || ',p_revision='
                || p_revision
                || ',v_lotnum='
                || v_lotnum
                || ',ser='
                || v_sertmp.fm_serial_number
              , 'INV_LPN_TRX_PUB'
              , 1
              );
              inv_log_util.TRACE(
                   ',p_org_id='
                || p_org_id
                || ',p_subinv='
                || p_subinv
                || ',p_locator='
                || p_locator
                || ',p_operation='
                || p_operation
                || ',p_cost_grp_id='
                || p_cost_grp_id
              , 'INV_LPN_TRX_PUB'
              , 1
              );
            END IF;

            fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;

        IF (NOT v_serfound) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('**** Lot controlled **', 'INV_LPN_TRX_PUB', 9);
          END IF;

          WMS_Container_PVT.PackUnpack_Container (
            p_api_version           => 1.0
          , p_init_msg_list         => fnd_api.g_false
          , p_validation_level      => fnd_api.g_valid_level_none
          , x_return_status         => ret_status
          , x_msg_count             => ret_msgcnt
          , x_msg_data              => ret_msgdata
          , p_caller                => 'INV_TRNSACTION'
          , p_lpn_id                => p_lpn
          , p_content_lpn_id        => p_content_lpn
          , p_content_item_id       => item_id
          , p_revision              => p_revision
          , p_lot_number            => v_lotnum
          , p_primary_quantity      => ABS(v_lottmp.primary_quantity)
          , p_quantity              => ABS(v_lottmp.transaction_quantity)
          , p_uom                   => p_uom
          , p_sec_quantity          => ABS(v_lotsecqty)              --INVCONV kkillams
          , p_sec_uom               => p_item_rec.secondary_uom_code --INVCONV kkillams
          , p_organization_id       => p_org_id
          , p_subinventory          => p_subinv
          , p_locator_id            => p_locator
          , p_operation             => l_operation
          , p_cost_group_id         => p_cost_grp_id
          , p_source_header_id      => p_source_header_id
          , p_source_name           => p_source_name
          , p_source_transaction_id => p_source_trx_id
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('**Error from pack/unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(
                   '**p_lpn='
                || p_lpn
                || ',p_content_lpn='
                || p_content_lpn
                || ',item_id='
                || item_id
                || ',p_revision='
                || p_revision
                || 'lot='
                || v_lotnum
                || ',p_org_id='
                || p_org_id
              , 'INV_LPN_TRX_PUB'
              , 1
              );
              inv_log_util.TRACE(
                ',p_subinv=' || p_subinv || ',p_locator=' || p_locator || ',p_operation=' || p_operation || ',p_cost_grp_id='
                || p_cost_grp_id
              , 'INV_LPN_TRX_PUB'
              , 1
              );
            END IF;

            fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END LOOP;

      IF (NOT v_lotfound) THEN
        v_sertrxid  := p_tempid;
        v_serfound  := FALSE;

        FOR v_sertmp IN c_sertmp LOOP
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('** Serial controlled**.fmser=' || v_sertmp.fm_serial_number || ', toser=' || v_sertmp.to_serial_number
            , 'INV_LPN_TRX_PUB', 9);
          END IF;

          v_serfound  := TRUE;

          IF (v_sertmp.to_serial_number IS NULL)
             OR(v_sertmp.fm_serial_number = v_sertmp.to_serial_number) THEN
            v_serqty  := 1;
          ELSE
            v_serqty  := inv_serial_number_pub.get_serial_diff(v_sertmp.fm_serial_number, v_sertmp.to_serial_number);
          END IF;

          /*3158847*/
          IF (
              p_item_rec.serial_number_control_code = 6 /*so issue*/
              AND p_source_type_id = 12 /*rma*/
              AND p_trx_action = 27 /*receipt*/
              AND p_operation = 1 /*pack*/
             ) THEN   /*pack as vanilla*/
            inv_log_util.TRACE('** Packing rma so issue serial as vanilla for receipt**', 'INV_LPN_TRX_PUB', 9);
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , x_return_status         => ret_status
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn
            , p_content_lpn_id        => p_content_lpn
            , p_content_item_id       => item_id
            , p_revision              => p_revision
            , p_lot_number            => v_lotnum
            , p_from_serial_number    => NULL --3158847
            , p_to_serial_number      => NULL --3158847v_sertmp.to_serial_number
            , p_primary_quantity      => v_serqty
            , p_quantity              => v_serqty
            , p_uom                   => p_item_rec.primary_uom_code
            , p_organization_id       => p_org_id
            , p_subinventory          => p_subinv
            , p_locator_id            => p_locator
            , p_operation             => l_operation
            , p_cost_group_id         => p_cost_grp_id
            , p_source_header_id      => p_source_header_id
            , p_source_name           => p_source_name
            , p_source_transaction_id => p_source_trx_id
            );
          ELSE
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , x_return_status         => ret_status
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_validation_level      => fnd_api.g_valid_level_none
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn
            , p_content_lpn_id        => p_content_lpn
            , p_content_item_id       => item_id
            , p_revision              => p_revision
            , p_from_serial_number    => v_sertmp.fm_serial_number
            , p_to_serial_number      => v_sertmp.to_serial_number
            , p_primary_quantity      => v_serqty
            , p_quantity              => v_serqty
            , p_uom                   => p_item_rec.primary_uom_code
            , p_organization_id       => p_org_id
            , p_subinventory          => p_subinv
            , p_locator_id            => p_locator
            , p_operation             => l_operation
            , p_cost_group_id         => p_cost_grp_id
            , p_source_header_id      => p_source_header_id
            , p_source_name           => p_source_name
            , p_source_transaction_id => p_source_trx_id
            );
          END IF;   /*3158847*/

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                   '**Error from pack/unpack :'
                || ret_status
                || ',p_lpn='
                || p_lpn
                || ',p_content_lpn='
                || p_content_lpn
                || ',item_id='
                || item_id
                || ',fmser='
                || v_sertmp.fm_serial_number
              , 'INV_LPN_TRX_PUB'
              , 1
              );
              inv_log_util.TRACE(
                'toser=' || v_sertmp.to_serial_number || ',org=' || p_org_id || ',p_subinv=' || p_subinv || ',p_locator=' || p_locator
              , 'INV_LPN_TRX_PUB'
              , 9
              );
            END IF;

            fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;

        IF (NOT v_serfound) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('** NOT Lot OR Serial controlled**', 'INV_LPN_TRX_PUB', 9);
          END IF;

          WMS_Container_PVT.PackUnpack_Container (
            p_api_version           => 1.0
          , p_init_msg_list         => fnd_api.g_false
          , x_return_status         => ret_status
          , x_msg_count             => ret_msgcnt
          , x_msg_data              => ret_msgdata
          , p_caller                => 'INV_TRNSACTION'
          , p_lpn_id                => p_lpn
          , p_validation_level      => fnd_api.g_valid_level_none
          , p_content_lpn_id        => p_content_lpn
          , p_content_item_id       => item_id
          , p_revision              => p_revision
          , p_primary_quantity      => ABS(p_primary_qty)
          , p_quantity              => ABS(p_qty)
          , p_uom                   => p_uom
          , p_sec_quantity          => ABS(p_sec_qty)                --INVCONV kkillams
          , p_sec_uom               => p_item_rec.secondary_uom_code --INVCONV kkillams
          , p_organization_id       => p_org_id
          , p_subinventory          => p_subinv
          , p_locator_id            => p_locator
          , p_operation             => l_operation
          , p_cost_group_id         => p_cost_grp_id
          , p_source_header_id      => p_source_header_id
          , p_source_name           => p_source_name
          , p_source_transaction_id => p_source_trx_id
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('**Error from pack/unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(
                   '**p_lpn='
                || p_lpn
                || ',p_content_lpn='
                || p_content_lpn
                || ',item_id='
                || item_id
                || ',p_revision='
                || p_revision
                || ',p_org_id='
                || p_org_id
              , 'INV_LPN_TRX_PUB'
              , 1
              );
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                ',p_subinv=' || p_subinv || ',p_locator=' || p_locator || ',p_operation=' || p_operation || ',p_cost_grp_id='
                || p_cost_grp_id
              , 'INV_LPN_TRX_PUB'
              , 1
              );
            END IF;

            fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF; -- p_content_lpn is NULL

    IF (p_operation = g_pack) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('** Pack OK', 'INV_LPN_TRX_PUB', 9);
      END IF;
    ELSIF(p_operation = g_unpack) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('** Unpack OK', 'INV_LPN_TRX_PUB', 9);
      END IF;
    END IF;
  END;

  /********************************************************************
   * Update the status of the LPN
   *******************************************************************/
  PROCEDURE update_lpn_status(v_lpn wms_container_pub.lpn) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    WMS_Container_PVT.Modify_LPN (
      p_api_version      => 1.0
    , p_init_msg_list    => fnd_api.g_true
    , p_commit           => fnd_api.g_false
    , p_validation_level => fnd_api.g_valid_level_none
    , x_return_status    => ret_status
    , x_msg_count        => ret_msgcnt
    , x_msg_data         => ret_msgdata
    , p_caller           => 'INV_TRNSACTION'
    , p_lpn              => v_lpn
    );

    IF (ret_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Error from modify_lpn :' || ret_status, 'INV_LPN_TRX_PUB', 1);
        inv_log_util.TRACE('Error msg :' || ret_msgdata || 'msgcnt=' || ret_msgcnt, 'INV_LPN_TRX_PUB', 1);
      END IF;

      fnd_message.set_name('INV', 'INV_LPN_UPDATE_FAILURE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  END;

  /********************************************************************
   * Insert a row into MTL_SERIAL_NUMBERS_TEMP which is a copy of another msnt row
   *******************************************************************/
  PROCEDURE copy_msnt(p_source_row_id ROWID, p_new_sertrxid NUMBER, p_new_fm_serial VARCHAR2, p_new_to_serial VARCHAR2) IS
    l_api_name    CONSTANT VARCHAR2(30)                      := 'COPY_MSNT';
    l_api_version CONSTANT NUMBER                            := 1.0;
    l_debug                NUMBER                            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_sertmp_rec           mtl_serial_numbers_temp%ROWTYPE;
  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('Call to Copy_MSNT rowid=' || p_source_row_id, 'INV_LPN_TRX_PUB', 9);
      inv_log_util.TRACE('newsertrxid=' || p_new_sertrxid || ' newfsn=' || p_new_fm_serial || ' newtsn=' || p_new_to_serial
      , 'INV_LPN_TRX_PUB', 9);
    END IF;

    SELECT *
      INTO l_sertmp_rec
      FROM mtl_serial_numbers_temp
     WHERE ROWID = p_source_row_id;

    --Insert new record for split serials
    INSERT INTO mtl_serial_numbers_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , vendor_serial_number
               , vendor_lot_number
               , fm_serial_number
               , to_serial_number
               , serial_prefix
               , ERROR_CODE
               , group_header_id
               , parent_serial_number
               , end_item_unit_number
               , serial_attribute_category
               , origination_date
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , status_id
               , territory_code
               , time_since_new
               , cycles_since_new
               , time_since_overhaul
               , cycles_since_overhaul
               , time_since_repair
               , cycles_since_repair
               , time_since_visit
               , cycles_since_visit
               , time_since_mark
               , cycles_since_mark
               , number_of_repairs
                )
         VALUES (
                 p_new_sertrxid
               , SYSDATE
               , l_sertmp_rec.last_updated_by
               , SYSDATE
               , l_sertmp_rec.created_by
               , l_sertmp_rec.last_update_login
               , l_sertmp_rec.request_id
               , l_sertmp_rec.program_application_id
               , l_sertmp_rec.program_id
               , l_sertmp_rec.program_update_date
               , l_sertmp_rec.vendor_serial_number
               , l_sertmp_rec.vendor_lot_number
               , p_new_fm_serial
               , p_new_to_serial
               , l_sertmp_rec.serial_prefix
               , l_sertmp_rec.ERROR_CODE
               , l_sertmp_rec.group_header_id
               , l_sertmp_rec.parent_serial_number
               , l_sertmp_rec.end_item_unit_number
               , l_sertmp_rec.serial_attribute_category
               , l_sertmp_rec.origination_date
               , l_sertmp_rec.c_attribute1
               , l_sertmp_rec.c_attribute2
               , l_sertmp_rec.c_attribute3
               , l_sertmp_rec.c_attribute4
               , l_sertmp_rec.c_attribute5
               , l_sertmp_rec.c_attribute6
               , l_sertmp_rec.c_attribute7
               , l_sertmp_rec.c_attribute8
               , l_sertmp_rec.c_attribute9
               , l_sertmp_rec.c_attribute10
               , l_sertmp_rec.c_attribute11
               , l_sertmp_rec.c_attribute12
               , l_sertmp_rec.c_attribute13
               , l_sertmp_rec.c_attribute14
               , l_sertmp_rec.c_attribute15
               , l_sertmp_rec.c_attribute16
               , l_sertmp_rec.c_attribute17
               , l_sertmp_rec.c_attribute18
               , l_sertmp_rec.c_attribute19
               , l_sertmp_rec.c_attribute20
               , l_sertmp_rec.d_attribute1
               , l_sertmp_rec.d_attribute2
               , l_sertmp_rec.d_attribute3
               , l_sertmp_rec.d_attribute4
               , l_sertmp_rec.d_attribute5
               , l_sertmp_rec.d_attribute6
               , l_sertmp_rec.d_attribute7
               , l_sertmp_rec.d_attribute8
               , l_sertmp_rec.d_attribute9
               , l_sertmp_rec.d_attribute10
               , l_sertmp_rec.n_attribute1
               , l_sertmp_rec.n_attribute2
               , l_sertmp_rec.n_attribute3
               , l_sertmp_rec.n_attribute4
               , l_sertmp_rec.n_attribute5
               , l_sertmp_rec.n_attribute6
               , l_sertmp_rec.n_attribute7
               , l_sertmp_rec.n_attribute8
               , l_sertmp_rec.n_attribute9
               , l_sertmp_rec.n_attribute10
               , l_sertmp_rec.status_id
               , l_sertmp_rec.territory_code
               , l_sertmp_rec.time_since_new
               , l_sertmp_rec.cycles_since_new
               , l_sertmp_rec.time_since_overhaul
               , l_sertmp_rec.cycles_since_overhaul
               , l_sertmp_rec.time_since_repair
               , l_sertmp_rec.cycles_since_repair
               , l_sertmp_rec.time_since_visit
               , l_sertmp_rec.cycles_since_visit
               , l_sertmp_rec.time_since_mark
               , l_sertmp_rec.cycles_since_mark
               , l_sertmp_rec.number_of_repairs
                );
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE(l_api_name || ' Error', l_api_name, 1);

        IF (SQLCODE IS NOT NULL) THEN
          inv_log_util.TRACE('SQL error: ' || SQLERRM(SQLCODE), l_api_name, 1);
        END IF;
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END copy_msnt;

  /********************************************************************
   *  Split Delivery Details. If serial controlled, then
   *  query corresponding lot or serial records
   *******************************************************************/
  PROCEDURE split_delivery_details(
    p_organization_id        NUMBER
  , p_lpn_id                 NUMBER
  , p_xfr_lpn_id             NUMBER
  , p_item_rec               inv_validate.item
  , p_revision               VARCHAR2
  , p_lot_number             VARCHAR2
  , p_quantity               NUMBER
  , p_uom_code               VARCHAR2
  , p_secondary_trx_quantity NUMBER := NULL
  , p_secondary_uom_code     VARCHAR2 := NULL
  , p_serial_trx_temp_id     NUMBER
  , p_subinventory_code      VARCHAR2
  , p_locator_id             NUMBER
  , p_xfr_subinventory       VARCHAR2 := NULL
  , p_xfr_to_location        NUMBER := NULL
  , p_transaction_source_id  NUMBER := NULL
  , p_trx_source_line_id     NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)  := 'Split_Delivery_Details';
    l_debug                NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress             VARCHAR2(500) := '0';

    -- Vaiables for call to Update_Shipping_Attributes
    l_shipping_attr        wsh_interface.changedattributetabtype;
    l_invpcinrectype       wsh_integration.invpcinrectype;

    -- Types needed for WSH_WMS_LPN_GRP.Delivery_Detail_Action
    l_wsh_lpn_id_tbl     wsh_util_core.id_tab_type;
    l_wsh_del_det_id_tbl wsh_util_core.id_tab_type;
    l_wsh_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_wsh_defaults       WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
    l_wsh_action_out_rec WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

    -- New shipping API table types for Create_Update_Delivery_Detail
    l_del_det_attr         wsh_interface_ext_grp.delivery_details_attr_tbl_type;
    l_del_det_in_rec       wsh_interface_ext_grp.detailinrectype;
    l_del_det_out_rec      wsh_interface_ext_grp.detailoutrectype;
    l_dd_ct                NUMBER                                               := 1;
    l_msg_details          VARCHAR2(3000);

    -- New shipping API table types for New Delivery_Detail_Action
    l_detail_id_tab        wsh_util_core.id_tab_type;
    l_action_prms          wsh_interface_ext_grp.det_action_parameters_rec_type;
    l_action_out_rec       wsh_interface_ext_grp.det_action_out_rec_type;

    CURSOR delivery_detail_cursor(lot VARCHAR2) IS
         /*Bug 7037834: Replaced the NVL statements with their equivalents in the where clause of below query for performance*/
     /* SELECT wdd2.delivery_detail_id
           , wdd2.src_requested_quantity_uom
           , NVL(wdd2.picked_quantity, wdd2.requested_quantity) requested_quantity
           , wdd2.requested_quantity_uom
           , wdd1.delivery_detail_id lpn_detail_id
           , wdd2.picked_quantity2
           , wdd2.requested_quantity_uom2
           , wdd2.transaction_temp_id
           , wdd2.serial_number
           , wdd2.source_header_id
           , wdd2.source_line_id
        FROM wsh_delivery_details wdd1, wsh_delivery_details wdd2, wsh_delivery_assignments_v wda
       WHERE wdd1.organization_id = p_organization_id
         AND wdd1.lpn_id = p_lpn_id
	 AND wdd1.released_status = 'X'  -- For LPN reuse ER : 6845650
         AND wda.parent_delivery_detail_id = wdd1.delivery_detail_id
         AND wdd2.delivery_detail_id = wda.delivery_detail_id
         AND wdd2.inventory_item_id = p_item_rec.inventory_item_id
         AND NVL(wdd2.revision, '@') = NVL(p_revision, '@')
         AND NVL(wdd2.lot_number, -999) = NVL(lot, -999)
         AND wdd2.source_header_id = NVL(p_transaction_source_id, wdd2.source_header_id)
         AND wdd2.source_line_id = NVL(p_trx_source_line_id, wdd2.source_line_id); */

	  SELECT wdd2.delivery_detail_id
           , wdd2.src_requested_quantity_uom
           , NVL(wdd2.picked_quantity, wdd2.requested_quantity) requested_quantity
           , wdd2.requested_quantity_uom
           , wdd1.delivery_detail_id lpn_detail_id
           , wdd2.picked_quantity2
           , wdd2.requested_quantity_uom2
           , wdd2.transaction_temp_id
           , wdd2.serial_number
           , wdd2.source_header_id
           , wdd2.source_line_id
		   , wdd2.source_code  --16197273
       FROM wsh_delivery_details wdd1, wsh_delivery_details wdd2, wsh_delivery_assignments wda
       WHERE wdd1.organization_id = p_organization_id
         AND wdd1.lpn_id = p_lpn_id
         AND wda.parent_delivery_detail_id = wdd1.delivery_detail_id
         AND wdd2.delivery_detail_id = wda.delivery_detail_id
         AND wdd2.inventory_item_id = p_item_rec.inventory_item_id
	 AND ((WDD2.REVISION IS NULL AND p_revision IS NULL ) OR WDD2.REVISION = p_revision )

         --AND NVL(wdd2.revision, '@') = NVL(p_revision, '@')
	   AND ((WDD2.LOT_NUMBER IS NULL AND lot IS null) OR  WDD2.LOT_NUMBER =lot )

         --AND NVL(wdd2.lot_number, -999) = NVL(lot, -999)
	   AND ((p_transaction_source_id IS NULL AND WDD2.SOURCE_HEADER_ID=wdd2.source_header_id) OR  WDD2.SOURCE_HEADER_ID=p_transaction_source_id)

         --AND wdd2.source_header_id = NVL(p_transaction_source_id, wdd2.source_header_id)
           AND ((p_trx_source_line_id IS NULL AND WDD2.SOURCE_LINE_ID =wdd2.source_line_id)  OR WDD2.SOURCE_LINE_ID=p_trx_source_line_id );

	 --AND wdd2.source_line_id = NVL(p_trx_source_line_id, wdd2.source_line_id);

 -- Bug 7037834

    l_dd_rec               delivery_detail_cursor%ROWTYPE;

    CURSOR del_serial_cursor(p_wdd_trx_tmp_id NUMBER) IS
      SELECT DISTINCT msn.serial_number
                 FROM mtl_serial_numbers msn, mtl_serial_numbers_temp wddmsnt, mtl_serial_numbers_temp trxmsnt
                WHERE msn.current_organization_id = p_organization_id
                  AND msn.inventory_item_id = p_item_rec.inventory_item_id
                  AND wddmsnt.transaction_temp_id = p_wdd_trx_tmp_id
                  AND LENGTH(msn.serial_number) = LENGTH(wddmsnt.fm_serial_number)
                  AND msn.serial_number BETWEEN wddmsnt.fm_serial_number AND NVL(wddmsnt.to_serial_number, wddmsnt.fm_serial_number)
                  AND trxmsnt.transaction_temp_id = p_serial_trx_temp_id
                  AND LENGTH(msn.serial_number) = LENGTH(trxmsnt.fm_serial_number)
                  AND msn.serial_number BETWEEN trxmsnt.fm_serial_number AND NVL(trxmsnt.to_serial_number, trxmsnt.fm_serial_number)
             ORDER BY serial_number;

    TYPE delserialtabtype IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

    ser_tbl                delserialtabtype;
    l_tbl_cnt              NUMBER;

    CURSOR wdd_ser_cur(p_wdd_trx_tmp_id NUMBER, p_start_serial VARCHAR2) IS
      SELECT DISTINCT ROWID
                    , fm_serial_number
                    , to_serial_number
                 FROM mtl_serial_numbers_temp msnt
                WHERE transaction_temp_id = p_wdd_trx_tmp_id
                  AND fm_serial_number >= p_start_serial
                  AND LENGTH(p_start_serial) = LENGTH(fm_serial_number)
             ORDER BY fm_serial_number;

    -- Variables for call to Inv_Serial_Info
    l_serial_def_flag      BOOLEAN;
    l_new_to_serial        VARCHAR2(30);
    l_new_fm_serial        VARCHAR2(30);
    l_serial_prefix        VARCHAR2(30);
    l_fm_serial_suffix     NUMBER;
    l_to_serial_suffix     NUMBER;
    l_serial_suffix_length NUMBER                                               := 0;
    x_error_code           NUMBER;
    l_temp_num             NUMBER;
    l_current_serial       VARCHAR2(30);
    l_split_quantity       NUMBER;
    l_split_quantity2      NUMBER                                               := NULL;
    l_remaining_quantity   NUMBER                                               := p_quantity;
    l_remaining_qty_uom    VARCHAR2(3)                                          := p_uom_code;
    l_remaining_quantity2  NUMBER                                               := p_secondary_trx_quantity;
    l_total_split_qty2     NUMBER                                               := 0;
    qty2_remainder         NUMBER                                               := 0;
    l_done_with_range      BOOLEAN                                              := FALSE;
    l_loop_counter         NUMBER := 0;
	l_demand_source_name           NUMBER := NULL;      --RTV 16197273
    l_demand_source_line_id        NUMBER ;             --RTV 16197273

  BEGIN
    --initalizing l_InvPCInRecType to use for updating wdd with transaction_temp_id
    l_invpcinrectype.transaction_id       := NULL;
    l_invpcinrectype.transaction_temp_id  := NULL;
    l_invpcinrectype.source_code          := 'INV';
    l_invpcinrectype.api_version_number   := 1.0;
    --initalizing params for Delivery_Detail_Action
    l_action_prms.caller                  := 'WMS';
    l_action_prms.action_code             := 'SPLIT-LINE';
    --initalizing params for Update_Shipping_Attributes
    l_shipping_attr(1).transfer_lpn_id    := p_xfr_lpn_id;
    l_shipping_attr(1).action_flag        := 'U';

    IF (l_debug = 1) THEN
      inv_log_util.TRACE(l_api_name || ' Entered ' || g_pkg_version, l_api_name, 1);
      inv_log_util.TRACE('orgid='||p_organization_id||' lpn='||p_lpn_id||' xfrlpn='||p_xfr_lpn_id||' item='||p_item_rec.inventory_item_id||' rev='||p_revision||' lot='||p_lot_number, l_api_name, 9);
      inv_log_util.TRACE('sctl='||p_item_rec.serial_number_control_code||' qty='||p_quantity||' uom='||p_uom_code||' qty2='||p_secondary_trx_quantity||' uom2='||p_secondary_uom_code||' strxtmp='||p_serial_trx_temp_id, l_api_name, 4);
      inv_log_util.TRACE('xfrsub='||p_xfr_subinventory||' xfrloc='||p_xfr_to_location||' srcid='||p_transaction_source_id||' srcln='||p_trx_source_line_id, l_api_name, 4);
    END IF;

    FOR dd_rec IN delivery_detail_cursor(p_lot_number) LOOP
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Got WDD: dd_id='||dd_rec.delivery_detail_id||' pckqty='||dd_rec.requested_quantity||' requom='||dd_rec.requested_quantity_uom||' sn='||dd_rec.serial_number||' trxtmpid='|| dd_rec.transaction_temp_id, l_api_name, 9);
        inv_log_util.TRACE('lpnddid='||dd_rec.lpn_detail_id||' pckqty2='||dd_rec.picked_quantity2||' requom2='||dd_rec.requested_quantity_uom2||' shdrid='||dd_rec.source_header_id||' slnid='||dd_rec.source_line_id, l_api_name, 9);
        inv_log_util.TRACE('remqty='||l_remaining_quantity||' remuom='||l_remaining_qty_uom, l_api_name, 9);
      END IF;

      -- Check to see if there needs to be any serial handling
      IF (dd_rec.serial_number IS NOT NULL) THEN
        -- Only one serial in this line check to see if it is part of split.
        BEGIN
          SELECT 1
            INTO l_split_quantity
            FROM mtl_serial_numbers_temp
           WHERE transaction_temp_id = p_serial_trx_temp_id
             AND dd_rec.serial_number BETWEEN fm_serial_number AND NVL(to_serial_number, fm_serial_number)
             AND LENGTH(fm_serial_number) = LENGTH(dd_rec.serial_number)
             AND ROWNUM < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_split_quantity  := 0;
        END;
      ELSIF(dd_rec.transaction_temp_id IS NOT NULL) THEN
        -- WDD lines have serials need to find the number of serial that need to be split
        OPEN del_serial_cursor(dd_rec.transaction_temp_id);

        FETCH del_serial_cursor
        BULK COLLECT INTO ser_tbl;

        l_split_quantity  := ser_tbl.COUNT;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('ser_tbl.COUNT=' || l_split_quantity, l_api_name, 9);
        END IF;

        -- Is some split serials were found for this WDD. Otherwise bypass
        -- If not all serials in this detail are part of split. no need to split ranges
        IF (l_split_quantity > 0
            AND l_split_quantity < dd_rec.requested_quantity) THEN

            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_invpcinrectype.transaction_temp_id
              FROM DUAL;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Created new trxtmpid=' || l_invpcinrectype.transaction_temp_id || ' ser_tbl.count=' || l_split_quantity
              , l_api_name, 9);
            END IF;

            l_shipping_attr(1).serial_number  := NULL;


          l_new_fm_serial  := ser_tbl(1);
          l_new_to_serial  := ser_tbl(1);
          l_tbl_cnt        := 1;

          FOR wdd_ser_rec IN wdd_ser_cur(dd_rec.transaction_temp_id, l_new_fm_serial) LOOP
            -- If a serial exists in this range of serials from WDD
            -- Go through each SN until it is beyond the rec range or not contiguous
            IF (l_new_fm_serial <= wdd_ser_rec.to_serial_number) THEN
              LOOP
                l_tbl_cnt  := l_tbl_cnt + 1;

                IF (l_tbl_cnt <= ser_tbl.COUNT) THEN
                  l_current_serial  := ser_tbl(l_tbl_cnt);
                END IF;

                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Got new sn='||l_current_serial||' nfmsn='||l_new_fm_serial||' ntosn='||l_new_to_serial||' wfmsn='||wdd_ser_rec.fm_serial_number||' wtosn='||wdd_ser_rec.to_serial_number, l_api_name, 9);
                END IF;

                -- If the the to and from serials consume the whole range from MSNT
                -- or the current serial is outside the range, We are done with the MSNT
                -- line and can bypass parsing the serials
                IF (
                    l_current_serial > wdd_ser_rec.to_serial_number
                    OR(l_new_fm_serial = wdd_ser_rec.fm_serial_number
                       AND l_new_to_serial = wdd_ser_rec.to_serial_number)
                   ) THEN
                  -- Current serial is not in the this MSNT line
                  l_done_with_range  := TRUE;
                ELSE   -- Serial still within serial range. See if it is contiguous
                  IF (l_serial_prefix IS NULL) THEN
                    l_serial_def_flag       :=
                      mtl_serial_check.inv_serial_info(l_new_fm_serial, l_new_fm_serial, l_serial_prefix, l_temp_num, l_fm_serial_suffix
                      , l_to_serial_suffix, x_error_code);

                    IF (x_error_code <> 0) THEN
                      IF (l_debug = 1) THEN
                        inv_log_util.TRACE('Failed MTL_SERIAL_CHECK.Inv_Serial_Info', l_api_name, 1);
                      END IF;

                      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    -- calculate the length of the serial number suffix
                    --l_serial_suffix_length := LENGTH(l_new_fm_serial) - LENGTH(l_serial_prefix);
                    l_serial_suffix_length  := LENGTH(l_new_fm_serial) - NVL(LENGTH(l_serial_prefix), 0);
                    /* 3406810 */
                    l_to_serial_suffix      := l_to_serial_suffix + 1;

                    IF (l_debug = 1) THEN
                      inv_log_util.TRACE('New prefix='||l_serial_prefix||' suffix='||l_fm_serial_suffix||' sfxlgth='||l_serial_suffix_length, l_api_name, 1);
                    END IF;
                  END IF;

                  -- Check if Serial is contiguous. If so, make current serial the new to_serial
                  IF (l_current_serial = l_serial_prefix || LPAD(TO_CHAR(l_to_serial_suffix), l_serial_suffix_length, '0')) THEN
                    l_to_serial_suffix  := l_to_serial_suffix + 1;
                    l_new_to_serial     := l_current_serial;
                  ELSE   -- Serial is not contiguous.  Range is done.
                    l_done_with_range  := TRUE;
                  END IF;
                END IF;

                IF (l_done_with_range) THEN
                  -- If we are done with the range separate it from the rest
                  IF (l_new_fm_serial = wdd_ser_rec.fm_serial_number
                      AND l_new_to_serial = wdd_ser_rec.to_serial_number) THEN
                    -- Whole serial range in wdd is part of split.
                    IF (l_invpcinrectype.transaction_temp_id IS NOT NULL) THEN
                      -- More than one serial to be put new temp id on it
                      UPDATE mtl_serial_numbers_temp
                         SET transaction_temp_id = l_invpcinrectype.transaction_temp_id
                       WHERE ROWID = wdd_ser_rec.ROWID;
                    ELSE
                      -- Single serial being split, remove record from MSNT
                      DELETE FROM mtl_serial_numbers_temp
                            WHERE ROWID = wdd_ser_rec.ROWID;
                    END IF;
                  ELSE   -- Create records for the new serial sub ranges
                    -- If not a single serial being split, create an new MSNT line for new split WDD line
                    IF (l_invpcinrectype.transaction_temp_id IS NOT NULL) THEN
                      copy_msnt(
                        p_source_row_id              => wdd_ser_rec.ROWID
                      , p_new_sertrxid               => l_invpcinrectype.transaction_temp_id
                      , p_new_fm_serial              => l_new_fm_serial
                      , p_new_to_serial              => l_new_to_serial
                      );
                    END IF;

                    --Update the delivery's msnt line with the non split ranges
                    IF (l_new_fm_serial > wdd_ser_rec.fm_serial_number) THEN
                      --If split serial range came from the middle of the delivery range,
                      --a new msnt line needs to be created to represent the second half
                      -- of the unsplit wdd serials.
                      IF (l_new_to_serial < wdd_ser_rec.to_serial_number) THEN
                        copy_msnt(
                          p_source_row_id              => wdd_ser_rec.ROWID
                        , p_new_sertrxid               => dd_rec.transaction_temp_id
                        , p_new_fm_serial              => l_serial_prefix || LPAD(l_to_serial_suffix, l_serial_suffix_length, '0')
                        , p_new_to_serial              => wdd_ser_rec.to_serial_number
                        );
                      END IF;

                      --Update the to serial one less than the beginning of the split serial range
                      wdd_ser_rec.to_serial_number  := l_serial_prefix || LPAD(l_fm_serial_suffix - 1, l_serial_suffix_length, '0');

                      UPDATE mtl_serial_numbers_temp
                         SET to_serial_number = wdd_ser_rec.to_serial_number
                       WHERE ROWID = wdd_ser_rec.ROWID;
                    ELSIF(l_new_to_serial < wdd_ser_rec.to_serial_number) THEN
                      --Update the from serial one greater than the end of the split serial range
                      wdd_ser_rec.fm_serial_number  := l_serial_prefix || LPAD(l_to_serial_suffix, l_serial_suffix_length, '0');

                      UPDATE mtl_serial_numbers_temp
                         SET fm_serial_number = wdd_ser_rec.fm_serial_number
                       WHERE ROWID = wdd_ser_rec.ROWID;
                    END IF;
                  END IF;

                  -- Finished processing range, reset params
                  l_new_fm_serial    := l_current_serial;
                  l_new_to_serial    := l_current_serial;
                  l_serial_prefix    := NULL;
                  l_done_with_range  := FALSE;
                END IF;

                EXIT WHEN l_tbl_cnt > ser_tbl.COUNT
                      OR l_current_serial > wdd_ser_rec.to_serial_number;
              END LOOP;
            END IF;   -- Done finding all the serials for this WDD-MSNT line

            EXIT WHEN l_tbl_cnt > ser_tbl.COUNT;
          END LOOP;

          --Call shipping api to set transaction_temp_id global variable
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Calling Set_Inv_PC_Attributes transaction_temp_id=' || l_invpcinrectype.transaction_temp_id, l_api_name);
          END IF;

          wsh_integration.set_inv_pc_attributes(p_in_attributes => l_invpcinrectype, x_return_status => ret_status
          , x_msg_count                  => ret_msgcnt, x_msg_data => ret_msgdata);

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('return error from Set_Inv_PC_Attributes', l_api_name);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- End of serial number handling code
        CLOSE del_serial_cursor;

        -- Convert split quantity from primary UOM into the UOM of the WDD line if different
        IF (p_uom_code <> dd_rec.requested_quantity_uom) THEN
        ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
          l_split_quantity  :=
            inv_convert.inv_um_convert(p_item_rec.inventory_item_id,p_lot_number,p_organization_id, 5, l_split_quantity, p_uom_code, dd_rec.requested_quantity_uom, NULL
            , NULL);

          IF (l_remaining_quantity < 0) THEN
            fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
            fnd_message.set_token('uom1', p_uom_code);
            fnd_message.set_token('uom2', dd_rec.requested_quantity_uom);
            fnd_message.set_token('module', l_api_name);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      ELSE   -- Not serial controlled
        l_split_quantity  := dd_rec.requested_quantity;
      END IF;

      IF (l_split_quantity > 0) THEN
        IF (l_remaining_qty_uom <> dd_rec.requested_quantity_uom) THEN
          -- convert remaining quantity into the UOM of the WDD line
          ----bug 8526601   added lot number and org id to make the inv_convert call lot specific
          l_remaining_quantity  :=
            inv_convert.inv_um_convert(p_item_rec.inventory_item_id,p_lot_number,p_organization_id, 5, l_remaining_quantity, l_remaining_qty_uom
            , dd_rec.requested_quantity_uom, NULL, NULL);

          IF (l_remaining_quantity < 0) THEN
            fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
            fnd_message.set_token('uom1', l_remaining_qty_uom);
            fnd_message.set_token('uom2', dd_rec.requested_quantity_uom);
            fnd_message.set_token('module', l_api_name);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          l_remaining_qty_uom   := dd_rec.requested_quantity_uom;
        END IF;

		--12432643
		IF (l_debug = 1) THEN
            inv_log_util.TRACE('l_split_quantity: '||l_split_quantity, l_api_name);
			inv_log_util.TRACE('l_remaining_quantity: '||l_remaining_quantity, l_api_name);
        END IF;
		--12432643


        IF ((l_remaining_quantity < dd_rec.requested_quantity) AND dd_rec.transaction_temp_id IS NULL ) THEN   --12432643
          l_split_quantity  := ROUND(l_remaining_quantity, g_precision);
        ELSE   -- need to round split qty
          l_split_quantity  := ROUND(l_split_quantity, g_precision);
        END IF;
		--12432643
		IF (l_debug = 1) THEN
            inv_log_util.TRACE('l_split_quantity: '||l_split_quantity, l_api_name);
        END IF;
		--12432643

        IF (l_remaining_quantity2 > 0) THEN
          IF (dd_rec.picked_quantity2 IS NULL) THEN
            -- If the from lpn has items without catch weights defined, must null
            -- secondary quantity and uom for all WDD records for this lpn
            l_remaining_quantity2  := 0;
          ELSIF(dd_rec.requested_quantity_uom2 <> p_secondary_uom_code) THEN
            -- Sanity check to make sure that we are transacting in the same UOM
            fnd_message.set_name('WMS', 'WMS_SEC_UOM_MISMATCH_ERROR');
            fnd_message.set_token('UOM1', p_secondary_uom_code);
            fnd_message.set_token('UOM2', dd_rec.requested_quantity_uom2);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSE
            -- Everything checks out determine the amount of qty2 to split
            -- Calculate the theoretical proportionate quantity2 to be split
            --l_split_quantity2 := p_secondary_trx_quantity*dd_rec.requested_quantity/p_quantity;
            l_split_quantity2      := l_remaining_quantity2 * l_split_quantity / l_remaining_quantity;
            l_remaining_quantity2  := l_remaining_quantity2 - l_split_quantity2;
            -- Keep track of the total quantity2 removed from soruce LPN
            l_total_split_qty2     := l_total_split_qty2 + LEAST(dd_rec.picked_quantity2, l_split_quantity2);

            IF (l_split_quantity = dd_rec.requested_quantity) THEN
              -- Whole WDD line will be split. Add record to table type to update catch weights
              l_del_det_attr(l_dd_ct).delivery_detail_id       := dd_rec.delivery_detail_id;
              l_del_det_attr(l_dd_ct).picked_quantity2         := l_split_quantity2;
              l_del_det_attr(l_dd_ct).requested_quantity_uom2  := p_secondary_uom_code;
              l_dd_ct                                          := l_dd_ct + 1;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                'new split_qty2=' || l_split_quantity2 || ' rem_qty2=' || l_remaining_quantity2 || ' splitfmqty=' || l_total_split_qty2
              , l_api_name
              , 9
              );
            END IF;
          END IF;
        END IF;

        IF (l_split_quantity = ROUND(dd_rec.requested_quantity, g_precision)) THEN
          -- Disassociate existing delivery line with old lpn
          l_shipping_attr(1).delivery_detail_id  := dd_rec.delivery_detail_id;
        ELSIF(l_split_quantity < dd_rec.requested_quantity) THEN
          -- We need only part of this WDD line need to split it
          l_detail_id_tab(1)                     := dd_rec.delivery_detail_id;
          l_action_prms.split_quantity           := l_split_quantity;
          l_action_prms.split_quantity2          := LEAST(dd_rec.picked_quantity2, l_split_quantity2);

          -- Call new Shipping API to split line
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Calling Delivery_Detail_Action ddid='||l_detail_id_tab(1)||' qty='||l_action_prms.split_quantity||' qty2='||l_action_prms.split_quantity2, l_api_name, 1);
          END IF;

          wsh_interface_ext_grp.delivery_detail_action(
            p_api_version_number         => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , x_return_status              => ret_status
          , x_msg_count                  => ret_msgcnt
          , x_msg_data                   => ret_msgdata
          , p_detail_id_tab              => l_detail_id_tab
          , p_action_prms                => l_action_prms
          , x_action_out_rec             => l_action_out_rec
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('**Error Delivery_Detail_Action: ' || ret_msgdata, l_api_name, 1);
            END IF;

            fnd_message.set_name('INV', 'INV_SPLIT_LINE_FAILURE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          l_shipping_attr(1).delivery_detail_id := l_action_out_rec.result_id_tab(1);

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Created new delivery line: dd_id=' || l_shipping_attr(1).delivery_detail_id, l_api_name, 9);
          END IF;
        ELSE   -- Split qty is > dd_rec.delivery_detail_id logic error;
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Split qty ' || l_split_quantity || ' is greater than what is available on WDD '
              || dd_rec.delivery_detail_id, l_api_name, 9);
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Call to WSH Delivery_Detail_Action unassign delivery from lpn', l_api_name, 4);
        END IF;

        l_wsh_action_prms.caller      := 'WMS';
        l_wsh_action_prms.action_code := 'UNPACK';
        l_wsh_del_det_id_tbl(1)       := l_shipping_attr(1).delivery_detail_id;

        WSH_WMS_LPN_GRP.Delivery_Detail_Action (
          p_api_version_number => 1.0
        , p_init_msg_list      => fnd_api.g_false
        , p_commit             => fnd_api.g_false
        , x_return_status      => ret_status
        , x_msg_count          => ret_msgcnt
        , x_msg_data           => ret_msgdata
        , p_lpn_id_tbl         => l_wsh_lpn_id_tbl
        , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
        , p_action_prms        => l_wsh_action_prms
        , x_defaults           => l_wsh_defaults
        , x_action_out_rec     => l_wsh_action_out_rec );

        IF (ret_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Error WSH_WMS_LPN_GRP.Delivery_Detail_Action' || ret_status, l_api_name, 1);
          END IF;

          fnd_message.set_name('INV', 'INV_UNASSIGN_DEL_FAILURE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_debug = 1) THEN
          inv_log_util.TRACE('Done with call to WSH Create_Update_Containers', l_api_name, 4);
        END IF;

        --Associate New Delivery Line with transfer LPN
        IF (p_xfr_subinventory IS NOT NULL) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Replacing sub: ' || l_shipping_attr(1).subinventory || ' with xfr sub: ' || p_xfr_subinventory, l_api_name
            , 9);
          END IF;

          l_shipping_attr(1).subinventory  := p_xfr_subinventory;
        END IF;

        IF (p_xfr_to_location <> 0) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Replacing loc: ' || l_shipping_attr(1).locator_id || ' with xfr loc: ' || p_xfr_to_location, l_api_name, 9);
          END IF;

          l_shipping_attr(1).locator_id  := p_xfr_to_location;
        END IF;

        -- Bug 3386829: Need to repopualte the picked quantity for shipping api
        l_shipping_attr(1).picked_quantity   := l_split_quantity;
        l_shipping_attr(1).picked_quantity2  := l_split_quantity2;
        wsh_interface.update_shipping_attributes(p_source_code => 'INV', p_changed_attributes => l_shipping_attr
        , x_return_status              => ret_status);

        IF (ret_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('***Error in update shipping attribures for split trx', l_api_name, 9);
          END IF;

          fnd_message.set_name('WMS', 'WMS_TD_UPD_SHP_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Need to also to transfer the item reservation
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Calling Upd_Reservation_PUP_New qty='||l_split_quantity||' uom='||dd_rec.requested_quantity_uom, l_api_name, 9);
        END IF;
        l_loop_counter := l_loop_counter + 1;

		--16197273
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('RTV ER Changes:Passing demand source name to fetch MR for Return order::'||dd_rec.source_header_id, l_api_name, 9);
        END IF;

        IF (dd_rec.source_code = 'RTV') THEN

        l_demand_source_name :=  dd_rec.source_header_id ;
        l_demand_source_line_id := NULL ;

        ELSE

        l_demand_source_line_id := dd_rec.source_line_id ;

        END IF ;

        --16197273

        INV_RESERVATION_PVT.Upd_Reservation_PUP_New (
          x_return_status           => ret_status
        , x_msg_count               => ret_msgcnt
        , x_msg_data                => ret_msgdata
        , p_organization_id         => p_organization_id
        , p_demand_source_header_id => dd_rec.source_header_id
        , p_demand_source_line_id   => l_demand_source_line_id
        , p_from_subinventory_code  => p_subinventory_code
        , p_from_locator_id         => p_locator_id
        , p_to_subinventory_code    => NVL(p_xfr_subinventory, p_subinventory_code)
        , p_to_locator_id           => NVL(p_xfr_to_location, p_locator_id)
        , p_inventory_item_id       => p_item_rec.inventory_item_id
        , p_revision                => p_revision
        , p_lot_number              => p_lot_number
        , p_quantity                => l_split_quantity
        , p_uom                     => dd_rec.requested_quantity_uom
        , p_lpn_id                  => p_xfr_lpn_id
        , p_force_reservation_flag  => fnd_api.g_true
        , p_requirement_date        => (Sysdate + l_loop_counter/(24*3600))
        , p_source_lpn_id           => p_lpn_id
		,p_demand_source_name       => l_demand_source_name);

        IF ( ret_status <> fnd_api.g_ret_sts_success ) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('upd_reservation_pup failed '||ret_msgdata, l_api_name, 1);
          END IF;
          fnd_message.set_name('WMS', 'UPD_RESERVATION_PUP_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
        l_progress := 'Done with call to Upd_Reservation_PUP_New';

        -- Subtract the split quantity from the remaining quantity
        l_remaining_quantity                 := l_remaining_quantity - l_split_quantity;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE(
            'Assoc new line remqty=' || l_remaining_quantity || ' remqty2=' || l_remaining_quantity2 || ' tsplt2=' || l_total_split_qty2
          , l_api_name
          , 9
          );
        END IF;
      END IF;   -- l_split_quantity > 0

      EXIT WHEN ROUND(l_remaining_quantity, g_precision) <= 0;
    END LOOP;

    IF (l_remaining_quantity > 0) THEN
      inv_log_util.TRACE('***Error while splittng delivery not enough quantity found in wdd', l_api_name, 1);
      fnd_message.set_name('WMS', 'INV_INSUFFICIENT_WDD_QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_secondary_trx_quantity IS NOT NULL) THEN
      -- We have consumed all of the primary quantity.  Calculate the amount of qty2
      -- That needs to be added back or removed from soruce LPN.
      qty2_remainder  := p_secondary_trx_quantity - l_total_split_qty2;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('qty2_remainder=' || qty2_remainder, l_api_name, 9);
      END IF;

      IF (qty2_remainder <> 0) THEN
        OPEN delivery_detail_cursor(p_lot_number);

        FETCH delivery_detail_cursor
         INTO l_dd_rec;

        IF (delivery_detail_cursor%FOUND
            AND l_dd_rec.picked_quantity2 IS NOT NULL) THEN
          WHILE(delivery_detail_cursor%FOUND) LOOP
            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                   'Got WDD: dd_id='
                || l_dd_rec.delivery_detail_id
                || ' pkqty='
                || l_dd_rec.requested_quantity
                || ' requom='
                || l_dd_rec.requested_quantity_uom
                || ' sn='
                || l_dd_rec.serial_number
                || ' txtmpid='
                || l_dd_rec.transaction_temp_id
              , l_api_name
              , 9
              );
              inv_log_util.TRACE(
                   'lpnddid='
                || l_dd_rec.lpn_detail_id
                || ' pckqty2='
                || l_dd_rec.picked_quantity2
                || ' requom2='
                || l_dd_rec.requested_quantity_uom2
                || ' remqty='
                || l_remaining_quantity
                || ' remuom='
                || l_remaining_qty_uom
              , l_api_name
              , 9
              );
            END IF;

            IF (l_dd_rec.requested_quantity_uom2 <> p_secondary_uom_code) THEN
              -- Sanity check to make sure that we are transacting in the same UOM
              fnd_message.set_name('WMS', 'WMS_SEC_UOM_MISMATCH_ERROR');
              fnd_message.set_token('UOM1', p_secondary_uom_code);
              fnd_message.set_token('UOM2', l_dd_rec.requested_quantity_uom2);
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF(l_dd_rec.picked_quantity2 > qty2_remainder) THEN
              -- This WDD record can consume the entire remaining qty.  subtract that
              -- amount from the line and set remaining to zero
              l_del_det_attr(l_dd_ct).picked_quantity2         := l_dd_rec.picked_quantity2 - qty2_remainder;
              l_del_det_attr(l_dd_ct).delivery_detail_id       := l_dd_rec.delivery_detail_id;
              l_del_det_attr(l_dd_ct).requested_quantity_uom2  := p_secondary_uom_code;
              l_dd_ct                                          := l_dd_ct + 1;
              qty2_remainder                                   := 0;
            ELSIF(l_dd_rec.picked_quantity2 <> 0) THEN
              -- This WDD record cannot consume the entire remaining qty. consume all
              -- of the qty2 and subtract the amount from the total remaining
              l_del_det_attr(l_dd_ct).picked_quantity2         := 0;
              l_del_det_attr(l_dd_ct).delivery_detail_id       := l_dd_rec.delivery_detail_id;
              l_del_det_attr(l_dd_ct).requested_quantity_uom2  := p_secondary_uom_code;
              l_dd_ct                                          := l_dd_ct + 1;
              qty2_remainder                                   := qty2_remainder - l_dd_rec.picked_quantity2;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('new qty2_remainder=' || qty2_remainder, l_api_name, 9);
            END IF;

            FETCH delivery_detail_cursor
             INTO l_dd_rec;
          END LOOP;

          IF (qty2_remainder <> 0) THEN
            inv_log_util.TRACE('***Error while splittng delivery not enough quantity2 found in wdd', l_api_name, 9);
            fnd_message.set_name('WMS', 'INV_INSUFFICIENT_WDD_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSIF(l_debug = 1) THEN
          inv_log_util.TRACE('no WDD rows left in source lpn...ok', l_api_name, 9);
        END IF;

        CLOSE delivery_detail_cursor;
      END IF;
    END IF;

    -- For catch weights update delivery lines with
    IF (l_del_det_attr.COUNT > 0) THEN
      l_del_det_in_rec.caller       := 'WMS';
      l_del_det_in_rec.action_code  := 'UPDATE';

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Calling Create_Update_Delivery_Detail count=' || l_del_det_attr.COUNT, l_api_name, 9);
      END IF;

      wsh_interface_ext_grp.create_update_delivery_detail(
        p_api_version_number         => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => ret_status
      , x_msg_count                  => ret_msgcnt
      , x_msg_data                   => ret_msgdata
      , p_detail_info_tab            => l_del_det_attr
      , p_in_rec                     => l_del_det_in_rec
      , x_out_rec                    => l_del_det_out_rec
      );

      IF (ret_status <> fnd_api.g_ret_sts_success) THEN
        --Get error messages from shipping
        wsh_util_core.get_messages('Y', ret_msgdata, l_msg_details, ret_msgcnt);

        IF (ret_msgcnt > 1) THEN
          ret_msgdata  := ret_msgdata || l_msg_details;
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Error calling Create_Update_Delivery_Detail: ' || ret_msgdata, l_api_name, 1);
        END IF;

        fnd_message.set_name('WMS', 'WMS_UPD_DELIVERY_ERROR');
        fnd_message.set_token('MSG1', ret_msgdata);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  END split_delivery_details;

  PROCEDURE split_delivery(
    p_tempid                 NUMBER
  , p_lpn_id                 NUMBER
  , p_xfr_lpn_id             NUMBER
  , p_item_rec               inv_validate.item
  , p_revision               VARCHAR2
  , p_qty                    NUMBER
  , p_uom                    VARCHAR2
  , p_secondary_trx_quantity NUMBER := NULL
  , p_secondary_uom_code     VARCHAR2 := NULL
  , p_org_id                 NUMBER
  , p_subinventory_code      VARCHAR2
  , p_locator_id             NUMBER
  , p_xfr_subinventory       VARCHAR2 := NULL
  , p_xfr_to_location        NUMBER := NULL
  , p_transaction_source_id  NUMBER := NULL
  , p_trx_source_line_id     NUMBER := NULL
  ) IS
    l_api_name      CONSTANT VARCHAR2(30)                         := 'Split_Delivery';
    l_api_version   CONSTANT NUMBER                               := 1.0;
    l_debug                  NUMBER                               := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress               VARCHAR2(10)                         := '0';
    l_lotfound               BOOLEAN                              := FALSE;
    l_prev_lot               VARCHAR2(30)                         := -999;
    l_secondary_trx_quantity NUMBER                               := p_secondary_trx_quantity;
    l_secondary_uom_code     VARCHAR2(3)                          := p_secondary_uom_code;
    l_pricing_ind            VARCHAR2(30);
    l_valid_sec_qty_split    NUMBER;

    CURSOR lottmp_cur IS
      SELECT   lot_number
             , primary_quantity
             , serial_transaction_temp_id
             , secondary_quantity
             , secondary_unit_of_measure
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_tempid
      ORDER BY lot_number;
  BEGIN
    -- Check if pricing is tracked by secondary qty
    l_pricing_ind  :=
      wms_catch_weight_pvt.get_ont_pricing_qty_source(
        p_api_version                => 1.0
      , x_return_status              => ret_status
      , x_msg_count                  => ret_msgcnt
      , x_msg_data                   => ret_msgdata
      , p_organization_id            => p_org_id
      , p_inventory_item_id          => p_item_rec.inventory_item_id
      );

    IF (ret_status <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('INV', 'WMS_GET_CATCH_WEIGHT_ATT_FAIL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- retrieve corresponding lot numbers
    FOR lottmp_rec IN lottmp_cur LOOP
      l_lotfound  := TRUE;

      IF (l_pricing_ind = wms_catch_weight_pvt.g_price_secondary) THEN
        IF (l_prev_lot <> lottmp_rec.lot_number) THEN
          l_prev_lot  := lottmp_rec.lot_number;
          wms_catch_weight_pvt.show_ct_wt_for_split(
            x_return_status              => ret_status
          , x_msg_data                   => ret_msgcnt
          , x_msg_count                  => ret_msgdata
          , p_org_id                     => p_org_id
          , p_from_lpn_id                => p_lpn_id
          , p_from_item_id               => p_item_rec.inventory_item_id
          , p_from_item_revision         => p_revision
          , p_from_item_lot_number       => lottmp_rec.lot_number
          , p_to_lpn_id                  => p_xfr_lpn_id
          , x_show_ct_wt                 => l_valid_sec_qty_split
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('INV', 'WMS_GET_CATCH_WEIGHT_ATT_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('l_valid_sec_qty_split=' || l_valid_sec_qty_split, l_api_name, 9);
          END IF;

          IF (l_valid_sec_qty_split <> 1) THEN
            --Clear the secondary quantity fields for the from LPN
            wms_catch_weight_pvt.update_lpn_secondary_quantity(
              p_api_version                => 1.0
            , x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , p_record_source              => 'WDD'
            , p_organization_id            => p_org_id
            , p_lpn_id                     => p_lpn_id
            , p_inventory_item_id          => p_item_rec.inventory_item_id
            , p_revision                   => p_revision
            , p_lot_number                 => lottmp_rec.lot_number
            , p_quantity                   => NULL
            , p_uom_code                   => NULL
            , p_secondary_quantity         => NULL
            , p_secondary_uom_code         => NULL
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Error calling Update_LPN_Secondary_Quantity: ' || ret_msgdata, l_api_name, 1);
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            --Clear the secondary quantity fields for the to LPN
            wms_catch_weight_pvt.update_lpn_secondary_quantity(
              p_api_version                => 1.0
            , x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , p_record_source              => 'WDD'
            , p_organization_id            => p_org_id
            , p_lpn_id                     => p_xfr_lpn_id
            , p_inventory_item_id          => p_item_rec.inventory_item_id
            , p_revision                   => p_revision
            , p_lot_number                 => lottmp_rec.lot_number
            , p_quantity                   => NULL
            , p_uom_code                   => NULL
            , p_secondary_quantity         => NULL
            , p_secondary_uom_code         => NULL
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Error calling Update_LPN_Secondary_Quantity: ' || ret_msgdata, l_api_name, 1);
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
        END IF;

        -- Secondary quantities are not allowed do not pass it to
        -- the Split_Delivery_Details API
        IF (l_valid_sec_qty_split <> 1) THEN
          lottmp_rec.secondary_quantity         := NULL;
          lottmp_rec.secondary_unit_of_measure  := NULL;
        END IF;
      ELSIF(lottmp_rec.secondary_quantity IS NOT NULL) THEN
        -- secondary qty populated even though item is not catch weight
        -- enabled.  Do not pass values to split delivery details api
        lottmp_rec.secondary_quantity         := NULL;
        lottmp_rec.secondary_unit_of_measure  := NULL;
      END IF;

      -- Call Split_Delivery_Details API for each lot
      split_delivery_details(
        p_organization_id            => p_org_id
      , p_lpn_id                     => p_lpn_id
      , p_xfr_lpn_id                 => p_xfr_lpn_id
      , p_item_rec                   => p_item_rec
      , p_revision                   => p_revision
      , p_lot_number                 => lottmp_rec.lot_number
      , p_quantity                   => lottmp_rec.primary_quantity
      , p_uom_code                   => p_uom
      , p_secondary_trx_quantity     => ABS(lottmp_rec.secondary_quantity)
      , p_secondary_uom_code         => lottmp_rec.secondary_unit_of_measure
      , p_serial_trx_temp_id         => lottmp_rec.serial_transaction_temp_id
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_xfr_subinventory           => p_xfr_subinventory
      , p_xfr_to_location            => p_xfr_to_location
      , p_transaction_source_id      => p_transaction_source_id
      , p_trx_source_line_id         => p_trx_source_line_id
      );
    END LOOP;

    IF (NOT l_lotfound) THEN
      IF (l_pricing_ind = wms_catch_weight_pvt.g_price_secondary) THEN
        wms_catch_weight_pvt.show_ct_wt_for_split(
          x_return_status              => ret_status
        , x_msg_data                   => ret_msgcnt
        , x_msg_count                  => ret_msgdata
        , p_org_id                     => p_org_id
        , p_from_lpn_id                => p_lpn_id
        , p_from_item_id               => p_item_rec.inventory_item_id
        , p_from_item_revision         => p_revision
        , p_from_item_lot_number       => NULL
        , p_to_lpn_id                  => p_xfr_lpn_id
        , x_show_ct_wt                 => l_valid_sec_qty_split
        );

        IF (ret_status <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('INV', 'WMS_GET_CATCH_WEIGHT_ATT_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('l_valid_sec_qty_split=' || l_valid_sec_qty_split, l_api_name, 9);
        END IF;

        -- Secondary quantities are not allowed do not pass it to
        -- the Split_Delivery_Details API
        IF (l_valid_sec_qty_split <> 1) THEN
          l_secondary_trx_quantity  := NULL;
          l_secondary_uom_code      := NULL;
          --Clear the secondary quantity fields for the from LPN
          wms_catch_weight_pvt.update_lpn_secondary_quantity(
            p_api_version                => 1.0
          , x_return_status              => ret_status
          , x_msg_count                  => ret_msgcnt
          , x_msg_data                   => ret_msgdata
          , p_record_source              => 'WDD'
          , p_organization_id            => p_org_id
          , p_lpn_id                     => p_lpn_id
          , p_inventory_item_id          => p_item_rec.inventory_item_id
          , p_revision                   => p_revision
          , p_quantity                   => NULL
          , p_uom_code                   => NULL
          , p_secondary_quantity         => NULL
          , p_secondary_uom_code         => NULL
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error calling Update_LPN_Secondary_Quantity: ' || ret_msgdata, l_api_name, 1);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --Clear the secondary quantity fields for the to LPN
          wms_catch_weight_pvt.update_lpn_secondary_quantity(
            p_api_version                => 1.0
          , x_return_status              => ret_status
          , x_msg_count                  => ret_msgcnt
          , x_msg_data                   => ret_msgdata
          , p_record_source              => 'WDD'
          , p_organization_id            => p_org_id
          , p_lpn_id                     => p_xfr_lpn_id
          , p_inventory_item_id          => p_item_rec.inventory_item_id
          , p_revision                   => p_revision
          , p_quantity                   => NULL
          , p_uom_code                   => NULL
          , p_secondary_quantity         => NULL
          , p_secondary_uom_code         => NULL
          );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error calling Update_LPN_Secondary_Quantity: ' || ret_msgdata, l_api_name, 1);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      ELSIF(l_secondary_trx_quantity IS NOT NULL) THEN
        -- secondary qty populated even though item is not catch weight
        -- enabled.  Do not pass values to split delivery details api
        l_secondary_trx_quantity  := NULL;
        l_secondary_uom_code      := NULL;
      END IF;

      -- Call Split_Delivery_Details API once for the MMTT record
      split_delivery_details(
        p_organization_id            => p_org_id
      , p_lpn_id                     => p_lpn_id
      , p_xfr_lpn_id                 => p_xfr_lpn_id
      , p_item_rec                   => p_item_rec
      , p_revision                   => p_revision
      , p_lot_number                 => NULL
      , p_quantity                   => p_qty
      , p_uom_code                   => p_uom
      , p_secondary_trx_quantity     => ABS(l_secondary_trx_quantity)
      , p_secondary_uom_code         => l_secondary_uom_code
      , p_serial_trx_temp_id         => p_tempid
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_xfr_subinventory           => p_xfr_subinventory
      , p_xfr_to_location            => p_xfr_to_location
      , p_transaction_source_id      => p_transaction_source_id
      , p_trx_source_line_id         => p_trx_source_line_id
      );
    END IF;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('** Split Delivery OK', l_api_name, 1);
    END IF;
  END split_delivery;


   /********************************************************************
   *
   * Transaction Manager Wrapper
   * This function does the LPN-related processing and then calls the
   * Java Transaction manager (replacement of inltpu) based on the
   * parameter p_process_trx
   *
   *******************************************************************/

   FUNCTION process_lpn_trx(
     p_trx_hdr_id         IN            NUMBER
   , p_commit             IN            VARCHAR2 := fnd_api.g_false
   , x_proc_msg           OUT NOCOPY    VARCHAR2
   , p_proc_mode          IN            NUMBER := NULL
   , p_process_trx        IN            VARCHAR2 := fnd_api.g_true
   , p_atomic             IN            VARCHAR2 := fnd_api.g_false
   , p_business_flow_code IN            NUMBER := NULL
   )
     RETURN NUMBER IS
   BEGIN
     RETURN process_lpn_trx(p_trx_hdr_id, p_commit, x_proc_msg, p_proc_mode, p_process_trx, p_atomic, p_business_flow_code, TRUE);
   END process_lpn_trx;



  /********************************************************************
   *
   * Transaction Manager Wrapper
   * This function does the LPN-related processing and then calls the
   * Java Transaction manager (replacement of inltpu) based on the
   * parameter p_process_trx
   * The message stack is initialized only if the new parameter
   * p_init_msg_list is true.
   *
   *******************************************************************/
  FUNCTION process_lpn_trx(
    p_trx_hdr_id         IN            NUMBER
  , p_commit             IN            VARCHAR2 := fnd_api.g_false
  , x_proc_msg           OUT NOCOPY    VARCHAR2
  , p_proc_mode          IN            NUMBER := NULL
  , p_process_trx        IN            VARCHAR2 := fnd_api.g_true
  , p_atomic             IN            VARCHAR2 := fnd_api.g_false
  , p_business_flow_code IN            NUMBER := NULL
  , p_init_msg_list      IN            BOOLEAN
  )
    RETURN NUMBER IS

    -- Bug# 7435480 Added trasanction_batch_seq in the order by clause
    CURSOR c_mmtt IS
      SELECT   *
          FROM mtl_material_transactions_temp
         WHERE transaction_header_id = p_trx_hdr_id
           AND NVL(transaction_status, 1) <> 2   -- don't consider suggestions
           AND process_flag = 'Y'
      ORDER BY transaction_batch_id,transaction_batch_seq;

    /* Jalaj Srivastava Bug 4634410
       Added cursor c_mtlt */
    /* Jalaj Srivastava Bug 5446542
       Cursor c_mtlt is no longer used */
    /* *****************************************************
    CURSOR c_mtlt (p_transaction_temp_id NUMBER) IS
      SELECT  lot_number
             ,primary_quantity
      FROM    mtl_transaction_lots_temp
      WHERE   transaction_temp_id = p_transaction_temp_id;
       *****************************************************


     /* Jalaj Srivastava
       Cursor to select transactions
       for which OPM-QM workflow event will be raised */
    CURSOR cur_get_txn_for_opm_qm IS
      SELECT  mmt.transaction_id
             ,mmt.transaction_action_id
             ,mmt.transaction_source_type_id
      FROM    mtl_material_transactions mmt
      WHERE   mmt.transaction_set_id   = p_trx_hdr_id
      AND     mmt.transaction_quantity > 0
      AND     exists (select 1
                      from   mtl_parameters mp
                      where  mp.organization_id   = mmt.organization_id
                      and    process_enabled_flag = 'Y')
      AND     exists (select 1
                      from   mtl_system_items_b msib
                      where  msib.inventory_item_id            = mmt.inventory_item_id
                      and    msib.organization_id              = mmt.organization_id
                      and    msib.process_quality_enabled_flag = 'Y')
      AND     (      (     (    (     (mmt.transaction_action_id IN ( inv_globals.g_action_issue
                                                          ,inv_globals.g_action_receipt
                                                          ,inv_globals.g_action_subxfr
                                                          ,inv_globals.g_action_orgxfr
                                                          ,inv_globals.g_action_intransitshipment
                                                          ,inv_globals.g_action_intransitreceipt))
                                  --Bug#6509707.Included Account Alias Receipt.
                                  AND (mmt.transaction_source_type_id IN (inv_globals.g_sourcetype_inventory,inv_globals.g_sourcetype_accountalias)
                               ) )
                             -- Pawan Kumar added bug 5533472
                             OR (
                                   (mmt.transaction_action_id         = inv_globals.g_action_assycomplete)
                               AND (mmt.transaction_source_type_id    = inv_globals.g_sourcetype_wip)
                                 )
                             OR (
                                      (mmt.transaction_action_id      = inv_globals.g_action_cyclecountadj)
                                  AND (mmt.transaction_source_type_id = inv_globals.g_sourcetype_cyclecount)
                                )
                             OR (
                                      (mmt.transaction_action_id      = inv_globals.g_action_physicalcountadj)
                                  AND (mmt.transaction_source_type_id = inv_globals.g_sourcetype_physicalcount)
                                )

                           )
                       AND (exists (select gisv.spec_id
                                    from   gmd_inventory_spec_vrs gisv, gmd_specifications_b gsb
                                    where  gsb.inventory_item_id =  mmt.inventory_item_id
                                    and    gsb.spec_status       in (400,700)
                                    and    gsb.delete_mark       =  0
                                    and    gisv.spec_id          = gsb.spec_id
                                    and    gisv.delete_mark      = 0
                                    and    (gisv.organization_id is null OR gisv.organization_id = mmt.organization_id)))
                     )
                 OR  (     (mmt.transaction_action_id      =  inv_globals.g_action_receipt)
                       AND (mmt.transaction_source_type_id in ( inv_globals.g_sourcetype_purchaseorder
                                                               ,inv_globals.g_sourcetype_rma
                                                               ,inv_globals.g_sourcetype_intreq))
                       AND (     (exists (select gssv.spec_id
                                          from   gmd_supplier_spec_vrs gssv, gmd_specifications_b gsb
                                          where  gsb.inventory_item_id =  mmt.inventory_item_id
                                          and    gsb.spec_status       in (400,700)
                                          and    gsb.delete_mark       =  0
                                          and    gssv.spec_id          = gsb.spec_id
                                          and    gssv.delete_mark      = 0
                                          and    (gssv.organization_id is null OR gssv.organization_id = mmt.organization_id)))
                             OR  (exists (select gisv.spec_id
                                          from   gmd_inventory_spec_vrs gisv, gmd_specifications_b gsb
                                          where  gsb.inventory_item_id =  mmt.inventory_item_id
                                          and    gsb.spec_status       in (400,700)
                                          and    gsb.delete_mark       =  0
                                          and    gisv.spec_id          = gsb.spec_id
                                          and    gisv.delete_mark      = 0
                                          and    (gisv.organization_id is null OR gisv.organization_id = mmt.organization_id)))

                           )
                     )
              );
   /* BUG 5361705 - raise opm qm event for every distinct lot */
   Cursor cr_get_distinct_lots(l_txn_id NUMBER) IS
   select  distinct mtln.product_transaction_id,mln.gen_object_id
   from    mtl_transaction_lot_numbers mtln,mtl_lot_numbers mln
   where   transaction_id = l_txn_id
   and     mln.lot_number = mtln.lot_number
   and     mln.inventory_item_id = mtln.inventory_item_id
   and     mln.organization_id = mtln.organization_id;

    i  NUMBER := 0; -- 13557341

    l_trx_temp_id          NUMBER;
    l_lotfound             BOOLEAN                                  := FALSE;
    insrowcnt              NUMBER                                   := 0;
    failedrowcnt           NUMBER                                   := 0;
    expldrowcnt            NUMBER                                   := 0;
    retval                 NUMBER                                   := 0;
    v_mmtt                 mtl_material_transactions_temp%ROWTYPE;
    v_lpn                  wms_container_pub.lpn;
    v_deleterow            BOOLEAN                                  := FALSE;   -- Should the original row in MMTT be deleted ?
    l_cst_grp              VARCHAR2(30);
    l_req_id               NUMBER;
    l_proc_mode            NUMBER                                   := p_proc_mode;
    l_process_trx          VARCHAR2(1)                              := p_process_trx;
    l_atomic               NUMBER                                   := 0;   -- Do not treat all rows with same HdrId as one unit.
    l_commit               NUMBER                                   := 0;   -- Do not commit yet
    l_comingling_occurs    VARCHAR2(1);
    l_count                NUMBER;
    l_wms_org_flag         BOOLEAN;
    l_comingle_sub         VARCHAR2(64);
    l_comingle_loc         NUMBER;
    l_comingle_org         NUMBER;
    l_comingle_cg          NUMBER;
    label_status           VARCHAR2(512);
    --l_call_tm              BOOLEAN                                  := FALSE;
    l_wms_installed        BOOLEAN                                  := FALSE;
    l_org                  NUMBER;
    l_containers           NUMBER;
    l_is_cartonization     NUMBER;
    l_prev_trx_batch_id    NUMBER;
    l_current_group_status VARCHAR2(512);
    l_error_code           VARCHAR2(256);
    l_num_ret_rows         NUMBER;
    l_is_from_mti          NUMBER;
    l_err_msg              VARCHAR2(2000)                           := NULL;
    l_cst_grp_id           NUMBER;
    l_xfr_cst_grp_id       NUMBER;
    -- for bug 2726323
    l_return_status        BOOLEAN                                  := FALSE;
    --fob enhencement for J
    l_fob_ret_sts          VARCHAR2(1);
    l_fob_ret_msg          VARCHAR2(2000);
    l_fob_msg_count        NUMBER;
    l_debug                NUMBER                                   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    -- Nested lpn changes
    l_putway_explode_req   VARCHAR2(1)                              := 'N';
    -- HVERDDIN ERES START
    l_erecord_id           NUMBER;
    l_trans_status         VARCHAR2(30)                             := 'SUCCESS';
    l_eres_enabled         VARCHAR2(3)                              := NVL(fnd_profile.VALUE('EDR_ERES_ENABLED'), 'N');
    tbl_index              BINARY_INTEGER                           := 1;
    l_eres_tbl             eres_tbl;
  -- HVERDDIN ERES END
    l_process              NUMBER                                   := 0;
    l_dcp_profile	   NUMBER;
    l_dcp_return_status    VARCHAR2(1);
    l_lot_indiv_trx_valid  boolean;
    l_secondary_txn_quantity number;
     l_gen_object_id NUMBER := 0;  --   9756188
	 l_wms_enabled_org	VARCHAR2(1) ;-- Bug 14341547

    /*Bug14298387,populate the physical locator to resolve the corrupted logic locator*/
    l_project_ref_enabled NUMBER := 0;
    l_phy_result  BOOLEAN      := TRUE;
    --Bug14298387 end

  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE(
        'Call to PROCESS_LPN_TRX trxhdr=' || p_trx_hdr_id || ',procmode=' || p_proc_mode || ',bflow=' || p_business_flow_code
      , 'INV_LPN_TRX_PUB'
      , 9
      );
    END IF;

    --Bug 4338316
    --Setting the local variable l_commit to honor the p_commit, if passed as true.
    IF fnd_api.to_boolean(p_commit) THEN
 	    l_commit := 1;
 	  END IF;

    -- Release 12 - Call to Enhanced Diagnostics Check Implemented
    -- Enhanced Diagnostics Check API is called if Profile is set.
    -- Errors are ignored since this should not stop the txn flow.
   BEGIN   --{
    l_dcp_profile := INV_DCP_PVT.G_CHECK_DCP;
    IF l_dcp_profile IS NULL THEN
       l_dcp_profile := inv_dcp_pvt.is_dcp_enabled;
    END IF;
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('l_dcp_profile :'||l_dcp_profile,'INV_LPN_TRX_PUB',9);
    END IF;
    IF (l_dcp_profile =1) then
     INV_DCP_PVT.validate_data(
                        p_dcp_event       => 'Validate MMTT',
                        p_trx_hdr_id      => p_trx_hdr_id,
                        p_temp_id         => Null,
		        p_batch_id        => Null,
                        p_raise_exception => 'N',
		 	x_return_status   => l_dcp_return_status);
    END IF;
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('After DCP Call -'||l_dcp_return_status,'INV_LPN_TRX_PUB',9);
    END IF;
   EXCEPTION
    WHEN OTHERS THEN
     IF (l_debug = 1) THEN
      inv_log_util.TRACE('DCP Error :'||substr(sqlerrm,1,240),'INV_LPN_TRX_PUB',9);
     END IF;
   END; ---}


    -- For BUG 2919763, initializing the message stack only if the new parameter
    -- p_init_msg_list is true.
    IF (p_init_msg_list = TRUE) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Initializing the message list', 'INV_LPN_TRX_PUB', 9);
      END IF;
      fnd_msg_pub.initialize;
    END IF;



    -- Set a save point. In case of error, rollback to this point
    -- we would still have the exploded contents in MMTT
    SAVEPOINT process_lpn_trx;

    -- If l_proc_mode is not filled, then check mode from profile
    IF (l_proc_mode IS NULL) THEN
      l_proc_mode  := fnd_profile.VALUE('TRANSACTION_PROCESS_MODE');

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('TRANSACTION_PROCESS_MODE for ProcMode= ' || l_proc_mode, 'INV_LPN_TRX_PUB', 9);
      END IF;

      -- if trx_process_mode is set for control at form level, then query
      -- form level profiles
      IF (l_proc_mode = 4) THEN
        l_proc_mode  := NULL;
      END IF;
    END IF;



      -- for bug 2726323 : Calling this funtion so as the variable
    --  WMS_INSTALL.G_WMS_INSTALLATION_STATUS gets set properly.
    l_return_status  :=
      wms_install.check_install(x_return_status => ret_status, x_msg_count => ret_msgcnt, x_msg_data => ret_msgdata
      , p_organization_id            => NULL);



    -- Check if WMS is installed, if so check for cartonization transaction
    IF (wms_install.g_wms_installation_status = 'I') THEN
      BEGIN
        SELECT 1
          INTO l_is_cartonization
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM mtl_material_transactions_temp
                  WHERE transaction_action_id = inv_globals.g_action_containerpack
                    AND transfer_lpn_id IS NULL
                    AND transaction_header_id = p_trx_hdr_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_is_cartonization  := 0;
      END;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('l_is_cartonization=' || l_is_cartonization, 'INV_LPN_TRX_PUB', 9);
      END IF;

      IF (l_is_cartonization = 1) THEN
        -- Cartonization request call cartonization process
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('**** Cartonization transaction', 'INV_LPN_TRX_PUB', 9);
        END IF;

        -- Retrieve level and organization information for cartonization
        -- If there is a mix of contaner levels, take the maxium level.  If
        -- all levels are null, cartonize until end.
        BEGIN
          SELECT   organization_id
                 , MAX(containers)
              INTO l_org
                 , l_containers
              FROM mtl_material_transactions_temp
             WHERE transaction_header_id = p_trx_hdr_id
               AND NVL(transaction_status, 1) <> 2
               AND process_flag = 'Y'
           GROUP BY organization_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('no rows retrieve when finding org and level for Cartonization', 'INV_LPN_TRX_PUB', 1);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Unexpected error when finding org and level for Cartonization', 'INV_LPN_TRX_PUB', 1);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
        END;

        wms_cartnzn_wrap.cartonize(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        ,
          --p_validation_level      => ,
          x_return_status              => ret_status
        , x_msg_count                  => ret_msgcnt
        , x_msg_data                   => ret_msgdata
        ,
          --p_out_bound             => ,
          p_org_id                     => l_org
        ,
          --p_move_order_header_id    => ,
          --p_disable_cartonization    => ,
          p_transaction_header_id      => p_trx_hdr_id
        , p_stop_level                 => l_containers
        , p_packaging_mode             => 2
        );

        IF (ret_status = fnd_api.g_ret_sts_error) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Error in calling Cartonization', 'INV_LPN_TRX_PUB', 1);
          END IF;

          RAISE fnd_api.g_exc_error;
        ELSIF(ret_status = fnd_api.g_ret_sts_unexp_error) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Unexpectied error in calling Cartonization', 'INV_LPN_TRX_PUB', 1);
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF(ret_status <> fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Undefined error in calling Cartonization', 'INV_LPN_TRX_PUB', 1);
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Done with call to Cartonization', 'INV_LPN_TRX_PUB', 9);
        END IF;

        --Need to transfer cartonization_id to transfer_lpn_id to pack into
        --suggested LPN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Transfering Cartonization suggestions', 'INV_LPN_TRX_PUB', 9);
        END IF;

        UPDATE mtl_material_transactions_temp
           SET transfer_lpn_id = cartonization_id
         WHERE transaction_header_id = p_trx_hdr_id;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Done transfering Cartonization suggestions', 'INV_LPN_TRX_PUB', 9);
        END IF;
      END IF;
    END IF;



    -- For atomic transactions create a single savepoint for the batch
    IF fnd_api.to_boolean(p_atomic) THEN
      SAVEPOINT group_savepoint;
    END IF;

    l_process := 0;

    --************* Open cursor into MMTT  *************
    FOR v_mmtt IN c_mmtt LOOP
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('trxtempid='||v_mmtt.transaction_temp_id||'srctypeid='||v_mmtt.transaction_source_type_id||'actid='||v_mmtt.transaction_action_id||',batchid='||v_mmtt.transaction_batch_id, 'INV_LPN_TRX_PUB', 9);
        inv_log_util.TRACE('seqid='||v_mmtt.transaction_sequence_id||',lpnid='||v_mmtt.lpn_id||',cntlpnid='||v_mmtt.content_lpn_id||'xfrlpnid='||v_mmtt.transfer_lpn_id, 'INV_LPN_TRX_PUB', 9);
        inv_log_util.TRACE('item_id='||v_mmtt.inventory_item_id||'qty='||v_mmtt.transaction_quantity||'uom='||v_mmtt.transaction_uom||'CG='||v_mmtt.cost_group_id||',XCG='||v_mmtt.transfer_cost_group_id, 'INV_LPN_TRX_PUB', 9);
        inv_log_util.TRACE('ccid='||v_mmtt.cycle_count_id, 'INV_LPN_TRX_PUB', 9);
      END IF;

      BEGIN
        /* Jalaj Srivastava Bug 4634410
           Check lot indivisibility.
           check is needed here since same lot could be
           created in two locations within the same session.
           quantity tree built/updated in forms session was not getting
           picked up in pl/sql layer which would
           have enabled to catch the error earlier than this point */
           --Jalaj Srivastava Bug 5515181
           --pass primary_quantity instead of txn qty
        /* Jalaj Srivastava Bug 5446542
           Lot indivisibility check will not be done
           here. it will be done through the forms
           or by the txn group layer */
        /* ********************************************************************
        IF (v_mmtt.lot_number IS NOT NULL) THEN
          l_lot_indiv_trx_valid := INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE
            ( p_api_version          => 1.0
            , p_init_msg_list        => fnd_api.g_false
            , p_transaction_type_id  => v_mmtt.transaction_type_id
            , p_organization_id      => v_mmtt.organization_id
            , p_inventory_item_id    => v_mmtt.inventory_item_id
            , p_revision             => v_mmtt.revision
            , p_subinventory_code    => v_mmtt.subinventory_code
            , p_locator_id           => v_mmtt.locator_id
            , p_lot_number           => v_mmtt.lot_number
            , p_primary_quantity     => v_mmtt.primary_quantity
            , p_qoh                  => NULL
            , p_atr                  => NULL
            , x_return_status        => ret_status
            , x_msg_count            => ret_msgcnt
            , x_msg_data             => ret_msgdata);

          IF (NOT l_lot_indiv_trx_valid) THEN
          -- the transaction is not valid regarding lot indivisible:
            IF (l_debug = 1) THEN
              inv_log_util.trace('in proc process_lpn_trx. lot indivisibility error', 'INV_LPN_TRX_PUB', 9);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          FOR v_mtlt in c_mtlt(v_mmtt.transaction_temp_id) LOOP
            l_lot_indiv_trx_valid := INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE
              ( p_api_version          => 1.0
              , p_init_msg_list        => fnd_api.g_false
              , p_transaction_type_id  => v_mmtt.transaction_type_id
              , p_organization_id      => v_mmtt.organization_id
              , p_inventory_item_id    => v_mmtt.inventory_item_id
              , p_revision             => v_mmtt.revision
              , p_subinventory_code    => v_mmtt.subinventory_code
              , p_locator_id           => v_mmtt.locator_id
              , p_lot_number           => v_mtlt.lot_number
              , p_primary_quantity     => v_mtlt.primary_quantity
              , p_qoh                  => NULL
              , p_atr                  => NULL
              , x_return_status        => ret_status
              , x_msg_count            => ret_msgcnt
              , x_msg_data             => ret_msgdata);

            IF (NOT l_lot_indiv_trx_valid) THEN
            -- the transaction is not valid regarding lot indivisible:
              IF (l_debug = 1) THEN
                inv_log_util.trace('in proc process_lpn_trx. lot indivisibility error', 'INV_LPN_TRX_PUB', 9);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END LOOP;
        END IF;
        ******************************************************************** */

        /* HVERDDIN ADDED Following code to support ERES */
        /* Only execute code if ERES enabled */
        IF l_eres_enabled <> 'N' THEN
          l_eres_tbl(tbl_index).event_id                    := v_mmtt.original_transaction_temp_id;
          l_eres_tbl(tbl_index).transaction_action_id       := v_mmtt.transaction_action_id;
          l_eres_tbl(tbl_index).transaction_source_type_id  := v_mmtt.transaction_source_type_id;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('ERES event id               => ' || l_eres_tbl(tbl_index).event_id, 'INV_LPN_TRX_PUB', 9);
            inv_log_util.TRACE('Transaction Action  Id      => ' || l_eres_tbl(tbl_index).transaction_action_id, 'INV_LPN_TRX_PUB', 9);
            inv_log_util.TRACE('Transaction Source Type Id  => ' || l_eres_tbl(tbl_index).transaction_source_type_id, 'INV_LPN_TRX_PUB', 9);
          END IF;
        END IF;

        /*------------------------------------------------------+
        | Validate Logical Transactions.
        |========================================================
        | Add a check to prevent processing logical transactions
        | that are populated directly to the transactions table.
        | No new logical transactions should go through MMTT.
        | Opened up the logical po receipt and logical delivery
        | adjustment to go through TM for lot serial support
        +------------------------------------------------------*/
        IF (
            (
             v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_inventory
             AND v_mmtt.transaction_action_id IN
                  (
                   inv_globals.g_action_logicalissue
                 , inv_globals.g_action_logicalicsales
                 , inv_globals.g_action_logicalicreceipt
                 , inv_globals.g_action_logicalicrcptreturn
                 , inv_globals.g_action_logicalicsalesreturn
                 , inv_globals.g_action_logicalreceipt
                  )
            )
            OR(
               v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_rma
               AND v_mmtt.transaction_action_id = inv_globals.g_action_logicalreceipt
              )
            OR(
               v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
               AND v_mmtt.transaction_action_id IN(inv_globals.g_action_logicalissue,
                                                                                     --     inv_globals.G_action_logicaldeladj,
                                                                                     --     inv_globals.G_action_logicalreceipt,
                                                                                     inv_globals.g_action_retropriceupdate)
              )
            OR(
               v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_rma
               AND v_mmtt.transaction_action_id = inv_globals.g_action_logicalreceipt
              )
            OR(
               v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_intreq
               AND v_mmtt.transaction_action_id = inv_globals.g_action_logicalexpreqreceipt
              )
            OR(
               v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
               AND v_mmtt.transaction_action_id = inv_globals.g_action_logicalissue
              )
           ) THEN
          fnd_message.set_name('INV', 'INV_INT_TRXACTCODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- For new or null transaction groups that are non atomic, create a new savepoint
        IF (NVL(v_mmtt.transaction_batch_id, -88) <> NVL(l_prev_trx_batch_id, -99)
            AND NOT fnd_api.to_boolean(p_atomic)) THEN
          SAVEPOINT group_savepoint;
          l_prev_trx_batch_id     := v_mmtt.transaction_batch_id;
          l_current_group_status  := fnd_api.g_ret_sts_success;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('new group savepoint prevbatchid=' || l_prev_trx_batch_id, 'INV_LPN_TRX_PUB', 9);
          END IF;
        END IF;

        -- Skip records that are of the same trx group where a record has failed
        -- Else run records normally
        IF NOT(
               v_mmtt.transaction_batch_id = l_prev_trx_batch_id
               AND NVL(l_current_group_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success
              ) THEN
          insrowcnt    := insrowcnt + 1;

          --For planning xfr and consigned xfr transactions, make sure the
          --transactions are always processed in online mode. bug 3453619
	  --For any transaction in mmtt which is an explicit transaction,
	  --implying that the owning_org or planning_org is populated in
	  --mmtt make sure the transactions are alwaya processed in online
	  -- mode bug 3691234
          IF ((v_mmtt.transaction_action_id = inv_globals.g_action_planxfr)
              OR(v_mmtt.transaction_action_id = inv_globals.g_action_ownxfr)
	      OR (Nvl(v_mmtt.owning_organization_id,v_mmtt.organization_id)
		      <> v_mmtt.organization_id)
		  OR (Nvl(v_mmtt.planning_organization_id,v_mmtt.organization_id)
		      <> v_mmtt.organization_id)) THEN
            l_proc_mode  := 1;
          END IF;

          -- If l_proc_mode is not set at this stage, it means control is at
          -- Forms-level Transaction-process profiles based on Transaction
          IF (l_proc_mode IS NULL) THEN
            IF (
                (v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_inventory)
                AND(v_mmtt.transaction_action_id = inv_globals.g_action_subxfr)
               ) THEN
              l_proc_mode  := fnd_profile.VALUE('SUBINV_TRANS_TXN');

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Using SUBINV_TRANS_TXN to set process_mode. ProcMode=' || l_proc_mode, 'INV_LPN_TRX_PUB', 9);
              END IF;
            ELSIF(
                  (
                   (v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_inventory)
                   OR(v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_account)
                  )
                  AND(
                      (v_mmtt.transaction_action_id = inv_globals.g_action_issue)
                      OR(v_mmtt.transaction_action_id = inv_globals.g_action_receipt)
                     )
                 ) THEN
              l_proc_mode  := fnd_profile.VALUE('ACCOUNT_ISSUE_TXN');

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Using ACCOUNT_ISSUE_TXN to set process_mode. ProcMode = ' || l_proc_mode, 'INV_LPN_TRX_PUB', 9);
              END IF;
            ELSIF(
                  (v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_moveorder)
                  AND(
                      (v_mmtt.transaction_action_id = inv_globals.g_action_receipt)
                      OR(v_mmtt.transaction_action_id = inv_globals.g_action_issue)
                     )
                 ) THEN
              l_proc_mode  := fnd_profile.VALUE('TRANSFER_ORDER_TXN');

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Using TRANSFER_ORDER_TXN to set process_mode. ProcMode = ' || l_proc_mode, 'INV_LPN_TRX_PUB', 9);
              END IF;
            ELSIF(
                  (v_mmtt.transaction_source_type_id = inv_globals.g_sourcetype_inventory)
                  AND(
                      (v_mmtt.transaction_action_id = inv_globals.g_action_orgxfr)
                      OR(v_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
                     )
                 ) THEN
              l_proc_mode  := fnd_profile.VALUE('INTER_ORG_SHIP_TXN');

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Using INTER_ORG_SHIP_TXN to set process_mode. ProcMode = ' || l_proc_mode, 'INV_LPN_TRX_PUB', 9);
              END IF;
            END IF;
          END IF;

          -- Sanity check. If the transaction-process mode is still Not set, then
          -- perform an online transaction
          IF (l_proc_mode IS NULL) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Warning: TrxProcess profile not set ', 'INV_LPN_TRX_PUB', 2);
            END IF;

            l_proc_mode  := 1;
          END IF;

          -- If this transaction involves any LPN based processing, then
          -- should ensure that the process-mode is not 'background'
          -- This is because pending LPN transactions in MMTT
          -- are currently not handled properly. Check bug 3027283 for details.
          -- For this case, change the process_mode to asynchronous .
          IF ((v_mmtt.lpn_id IS NOT NULL)
              OR(v_mmtt.content_lpn_id IS NOT NULL)
              OR(v_mmtt.transfer_lpn_id IS NOT NULL))
             AND(l_proc_mode = inv_txn_manager_pub.proc_mode_mmtt_bgrnd) THEN
            l_proc_mode  := inv_txn_manager_pub.proc_mode_mmtt_async;
          END IF;

          -- Changes added to Patchet J. This is only to be done if PO pathset J
          -- is installed. API update_fob_point, will derive and update
          -- mmtt record with the fob_point and inv_intransit_account in
          -- case of an intransit Rcpt or intransit Shipment transaction
          IF (po_code_release_grp.current_release >= po_code_release_grp.prc_11i_family_pack_j) THEN
            IF (
                (v_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
                OR(v_mmtt.transaction_action_id = inv_globals.g_action_intransitreceipt)
               ) THEN
              update_fob_point(v_mmtt        => v_mmtt, x_return_status => l_fob_ret_sts, x_msg_data => l_fob_ret_msg
              , x_msg_count                  => l_fob_msg_count);

              IF (l_fob_ret_sts <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(' Error from update_fob_point:' || l_fob_ret_msg, 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_FOB_NOT_DEFINED');
                fnd_message.set_token('ENTITY1', v_mmtt.organization_id);
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;   --(PO pathset J installed)

          --Changes made for WIP TM Integration: Patchet J.
          --We call a WIP API which tells us wether to update the mmtt
          --record, With the MATERIAL_ALLOCATION_TEMP_ID with the next
          -- sequence. This will only be done in case of WIP.J being
          --installed.
          IF (v_mmtt.transaction_source_type_id = 5
              AND wip_constants.dmf_patchset_level >= wip_constants.dmf_patchset_j_value) THEN
            IF (wip_mtltempproc_grp.istxnidrequired(v_mmtt.transaction_temp_id)) THEN
              inv_log_util.TRACE('Going to update mmtt with material_allocation_temp_id', 'INV_LPN_TRX_PUB', 1);

              UPDATE mtl_material_transactions_temp
                 SET material_allocation_temp_id = mtl_material_transactions_s.NEXTVAL
               WHERE transaction_temp_id = v_mmtt.transaction_temp_id;
            END IF;
          END IF;

          --End patchset J changes for WIP.

          -- Call the CostGroup API for this line
          -- Call CostGroupAPI which will update the cost_group_id and
          -- xfr_cost_group_id in MMTT for this record.
          -- Note: This API could create additional rows into MMTT if lots/serials
          --  are specified which have different cost-groups., that is why our
          -- MMTT  cursor (c_mmtt) is being opened after calling this API

          -- Call CG API for all cases except when content_lpn_id is not null AND transaction_type
          -- is neither S.O nor I.O

		    -- Bug 14341547 added for project contracts type .

		   IF (inv_cache.set_org_rec(v_mmtt.organization_id)) THEN
                   l_wms_enabled_org :=  inv_cache.org_rec.WMS_ENABLED_FLAG;
           END IF;

		  inv_log_util.TRACE('Wms_enabled_flag: '||l_wms_enabled_org, 'INV_LPN_TRX_PUB', 1);
          IF NOT(
                 (v_mmtt.content_lpn_id IS NOT NULL)
                 AND
                     v_mmtt.transaction_source_type_id <> inv_globals.g_sourcetype_intorder
                 AND
                     v_mmtt.transaction_source_type_id <> inv_globals.g_sourcetype_salesorder
				AND  -- Bug 14341547 added the project contratcs type also.
				    ( l_wms_enabled_org='Y' OR v_mmtt.transaction_source_type_id <> inv_globals.G_SOURCETYPE_PRJCONTRACTS )
                ) THEN
            inv_cost_group_pvt.assign_cost_group(
              x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , p_organization_id            => v_mmtt.organization_id
            , p_mmtt_rec                   => v_mmtt
            , p_fob_point                  => NULL
            , p_line_id                    => v_mmtt.transaction_temp_id
            , p_input_type                 => inv_cost_group_pub.g_input_mmtt
            , x_cost_group_id              => l_cst_grp_id
            , x_transfer_cost_group_id     => l_xfr_cst_grp_id
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE(' Error from CostGrpAPI:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
              END IF;
	      --Bug 3804314: The message from the cost group API is
	      --overwritten by INV_COST_GROUP_FAILURE. Commenting the message.
              --fnd_message.set_name('INV', 'INV_COST_GROUP_FAILURE');
              --fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          -- Continue with the process based on the value of l_proc_mode
          IF l_proc_mode = 2 THEN   --  Concurrent Mode
            -- Concurrent request. Submit request and return to caller
            UPDATE mtl_material_transactions_temp
               SET transaction_mode = inv_txn_manager_pub.proc_mode_mmtt_async
             WHERE transaction_header_id = p_trx_hdr_id;

            l_req_id  := fnd_request.submit_request(application => 'INV', program => 'INVMBTRX', argument1 => p_trx_hdr_id);
            COMMIT;   -- Need to commit for the request to be submitted

            IF (l_req_id = 0) THEN
              -- display error message
              fnd_message.set_name(application => 'INV', NAME => 'INV_SUBMIT_FAIL');
              fnd_message.set_token(token => 'TOKEN', VALUE => TO_CHAR(p_trx_hdr_id), TRANSLATE => FALSE);
              fnd_msg_pub.ADD;
              x_proc_msg  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');
              RETURN -1;
            ELSE
              -- display request ID
              fnd_message.set_name(application => 'INV', NAME => 'INV_CONC_TRANSACT');
              fnd_message.set_token(token => 'REQUEST_ID', VALUE => TO_CHAR(l_req_id), TRANSLATE => FALSE);
              fnd_msg_pub.ADD;
              x_proc_msg  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Concurrent Req. submitted: ' || l_req_id, 'INV_LPN_TRX_PUB', 9);
              END IF;

              RETURN 0;
            END IF;
          ELSIF l_proc_mode = 3 THEN   -- Background mode
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** Background request submitted **', 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- In this case, the background transaction manager would pick
            -- up this row from MMTT. Update transaction_mode and return to caller
            UPDATE mtl_material_transactions_temp
               SET transaction_mode = inv_txn_manager_pub.proc_mode_mmtt_bgrnd
             WHERE transaction_header_id = p_trx_hdr_id;

            fnd_message.set_name('INV', 'INV_TXN_REQ_QUEUED');
            fnd_msg_pub.ADD;
            x_proc_msg  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');

            IF fnd_api.to_boolean(p_commit) THEN
              COMMIT WORK;
            END IF;

            RETURN 0;
          END IF;

          -- If here, it means that this transaction is to be processed 'on-line'
          v_deleterow  := FALSE;

          -- If the transaction action is either Issue or Intransit Shipment, and
          -- the sign of quantity is not -ve, make it -ve.
          -- Bug 3736797, added update to MMTT, since MMTT was never getting updated with sign changed.
          IF (
              (
               (v_mmtt.transaction_action_id = inv_globals.g_action_issue)
               OR(v_mmtt.transaction_action_id = inv_globals.g_action_intransitshipment)
               --Bug 12534588 Adding the updation of MMTT for assembly return action also.
               OR(v_mmtt.transaction_action_id = inv_globals.g_action_assyreturn)
              )
              AND(v_mmtt.primary_quantity > 0)
             ) THEN

            IF (l_debug = 1) THEN
              inv_log_util.trace('sign of quantity is not -ve for temp_id '||v_mmtt.transaction_temp_id, 'INV_LPN_TRX_PUB',9);
            END IF;

            v_mmtt.primary_quantity  := -1 * v_mmtt.primary_quantity;
            v_mmtt.transaction_quantity := -1 * ABS(v_mmtt.transaction_quantity);
            --INVCONV kkillams
             IF v_mmtt.secondary_transaction_quantity IS NOT NULL THEN
                --Jalaj Srivastava Bug 5138445
                --get -ve of absolute
                v_mmtt.secondary_transaction_quantity  := -1 * abs(v_mmtt.secondary_transaction_quantity);
             END IF;
            --END INVCONV kkillams
            UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
            SET PRIMARY_QUANTITY = v_mmtt.primary_quantity,
                TRANSACTION_QUANTITY            = v_mmtt.transaction_quantity,
                SECONDARY_TRANSACTION_QUANTITY  = CASE WHEN v_mmtt.secondary_uom_code IS NOT NULL THEN v_mmtt.secondary_transaction_quantity
                                                                                                  ELSE SECONDARY_TRANSACTION_QUANTITY
                                                                                                  END --INVCONV kkillams
            WHERE TRANSACTION_TEMP_ID = v_mmtt.transaction_temp_id
            AND   PRIMARY_QUANTITY > 0;

            IF (l_debug = 1) THEN
              inv_log_util.trace('Made the sign -ve for temp_id '||v_mmtt.transaction_temp_id, 'INV_LPN_TRX_PUB',9);
            END IF;

          END IF;

          IF (wms_control.get_current_release_level >= inv_release.get_j_release_level) THEN
            BEGIN
              SELECT 'Y'
                INTO l_putway_explode_req
                FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
               WHERE v_mmtt.move_order_line_id IS NOT NULL
                 AND mtrl.line_id = v_mmtt.move_order_line_id
                 AND mtrh.header_id = mtrl.header_id
                 AND v_mmtt.transaction_source_type_id IN(4, 5)
                 AND mtrh.move_order_type = 6
                 AND ROWNUM < 2;

              inv_log_util.TRACE(' Patchset J code. Do not explode LPN for Putaway ', 'INV_LPN_TRX_PUB', 1);
            EXCEPTION
              WHEN OTHERS THEN
                inv_log_util.TRACE(' Exception while exploding ', 'INV_LPN_TRX_PUB', 1);
                l_putway_explode_req  := 'N';
            END;
          END IF;

          -- If contentLPN is not NULL, then need to explode and insert contents
          -- into MMTT , unless this is a Pack/Unpack/split/SO/IO Transaction.
          -- Note: For SO and IO  transactions, there is no need
          --  to explode the LPN as there will be a seperate MMTT  line for each
          --  item inside the LPN

		   inv_log_util.TRACE('Wms_enabled_flag: '||l_wms_enabled_org, 'INV_LPN_TRX_PUB', 1);
          IF (v_mmtt.content_lpn_id IS NOT NULL) THEN
            IF ( v_mmtt.transaction_action_id <> inv_globals.g_action_containerpack AND
                 v_mmtt.transaction_action_id <> inv_globals.g_action_containerunpack AND
                 v_mmtt.transaction_action_id <> inv_globals.g_action_containersplit AND
                 v_mmtt.transaction_source_type_id <> inv_globals.g_sourcetype_intorder AND
                 v_mmtt.transaction_source_type_id <> inv_globals.g_sourcetype_salesorder AND
				 -- Bug 14341547 added the project contratcs type also.
				 (l_wms_enabled_org='Y' OR v_mmtt.transaction_source_type_id <> inv_globals.G_SOURCETYPE_PRJCONTRACTS) AND
                 l_putway_explode_req = 'N' )
            THEN
              expldrowcnt  := explode_and_insert(v_mmtt.content_lpn_id, p_trx_hdr_id, v_mmtt);

              IF (expldrowcnt = -1) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(' Failed in EXPLODE_AND_INSERT!!', 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_FAILED');
                fnd_msg_pub.ADD;
                x_proc_msg  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');
                RETURN -1;
              END IF;

              insrowcnt := insrowcnt + expldrowcnt;

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Done exploding new lpn expldrowcnt=' || expldrowcnt || ' insrowcnt=' || insrowcnt, 'INV_LPN_TRX_PUB', 9);
              END IF;
            ELSIF ( l_putway_explode_req = 'Y' AND v_mmtt.cost_group_id IS NULL ) THEN
            	-- bug4475607 For WIP putaway transactions contents are not exploded, but the
            	-- cost group id may not exist on the record.  Call cost group api
              inv_cost_group_pvt.assign_cost_group(
                x_return_status              => ret_status
              , x_msg_count                  => ret_msgcnt
              , x_msg_data                   => ret_msgdata
              , p_organization_id            => v_mmtt.organization_id
              , p_mmtt_rec                   => v_mmtt
              , p_fob_point                  => NULL
              , p_line_id                    => v_mmtt.transaction_temp_id
              , p_input_type                 => inv_cost_group_pub.g_input_mmtt
              , x_cost_group_id              => l_cst_grp_id
              , x_transfer_cost_group_id     => l_xfr_cst_grp_id );

              IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(' Error from CostGrpAPI:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;  -- content_lpn_id populated

          -- Logic to determine whether JavaTM is to be called. We don't need to
          -- call the JavaTM if this batch in MMTT contained no records OR if
          -- contained only one record which was later removed by EXPLODE API
          -- because it had no contents.
          /** bug 3618385, don't use l_call_tm because it doesn't determine correctly whether JavaTM
              needs to be called.
          IF (NOT l_call_tm) THEN
            IF (insrowcnt > 0) THEN
              l_call_tm  := TRUE;
            END IF;
          END IF;
          **/
        END IF;   -- not same or failed transactions group


      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE(
              '***Error g_exec in c_mmtt loop trxtmpid=' || v_mmtt.transaction_temp_id || ',Sqlerrm:' || SUBSTR(SQLERRM, 1, 100)
            , 'INV_LPN_TRX_PUB'
            , 1
            );
          END IF;

          l_current_group_status  := fnd_api.g_ret_sts_error;
          l_error_code            := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');
          x_proc_msg              := fnd_msg_pub.get(fnd_msg_pub.g_previous, 'F');
          failedrowcnt            := failedrowcnt + 1;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('failedrowcnt=' || failedrowcnt || ' msg=' || x_proc_msg, 'INV_LPN_TRX_PUB', 1);
          END IF;

          ROLLBACK TO group_savepoint;

          IF fnd_api.to_boolean(p_atomic) THEN
	     --Set message in MMTT line based in header id
	     -- Bug 3804314: Changed the where clause to transaction_header_id
            BEGIN
              -- Update MMTT records with error message and set status to error
              UPDATE mtl_material_transactions_temp
                 SET ERROR_CODE = l_error_code
                   , error_explanation = x_proc_msg
                   , process_flag = 'E'
                   , lock_flag = 'N'
               WHERE transaction_header_id = p_trx_hdr_id;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Error in updating MMTT for trxhdrid=' || p_trx_hdr_id, 1);
                END IF;
            END;

            -- Batch Failed exit from loop
            EXIT;
          ELSIF(v_mmtt.transaction_mode = inv_txn_manager_pub.proc_mode_mti) THEN
            BEGIN
              IF (v_mmtt.transaction_batch_id IS NOT NULL) THEN
                -- This record was part of a batch and it originated from MTI
                -- Update MTI records with error message and set status to error
                -- and delete all rows belonging to this group from MMTT/MTLT/MSNT
                UPDATE mtl_transactions_interface
                   SET ERROR_CODE = substrb(l_error_code,1,240)/*added substrb for 3632722*/
                     , error_explanation = substrb(x_proc_msg,1,240)/*added substrb for 3632722*/
                     , process_flag = 3
                     , lock_flag = 2
                 WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
                 and transaction_batch_id = v_mmtt.transaction_batch_id;

                l_num_ret_rows  := SQL%ROWCOUNT;

                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Updated error msg for ' || l_num_ret_rows || ' rows form MTI with txnbatchid='
                    || v_mmtt.transaction_batch_id, 1);
                END IF;

                -- Remove from MSNT rows with same MMTT transaction_temp_id
                DELETE FROM mtl_serial_numbers_temp
                      WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                                     FROM mtl_material_transactions_temp
                                                    WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
                                                    AND transaction_batch_id = v_mmtt.transaction_batch_id);

                -- Remove from MSNT rows with same MTNT transaction_temp_id
                DELETE FROM mtl_serial_numbers_temp
                      WHERE transaction_temp_id IN(SELECT serial_transaction_temp_id
                                                     FROM mtl_transaction_lots_temp
                                                    WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                                                                   FROM mtl_material_transactions_temp
                                                                                  WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
                                                                                  AND transaction_batch_id = v_mmtt.transaction_batch_id));

                -- Remove from MTLT rows with same MMTT transaction_temp_id
                DELETE FROM mtl_transaction_lots_temp
                      WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                                     FROM mtl_material_transactions_temp
                                                    WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
                                                    AND transaction_batch_id = v_mmtt.transaction_batch_id);

                -- Remove from MMTT rows with same transaction group id
                DELETE FROM mtl_material_transactions_temp
                WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
                AND transaction_batch_id = v_mmtt.transaction_batch_id;

              ELSE   -- IF v_mmtt.transaction_batch_id IS NULL
                -- This record was not part of a batch and it originated from MTI
                -- Update MTI record with error message and set status to error
                -- and delete the corresponding record from MMTT/MTLT/MSNT
                UPDATE mtl_transactions_interface
                   SET ERROR_CODE = substrb(l_error_code,1,240)/*added substrb for 3632722*/
                     , error_explanation = substrb(x_proc_msg,1,240)/*added substrb for 3632722*/
                     , process_flag = 3
                     , lock_flag = 2
                 WHERE transaction_interface_id = v_mmtt.transaction_temp_id;

                l_num_ret_rows  := SQL%ROWCOUNT;

                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Updated error msg for ' || l_num_ret_rows || ' rows form MTI with txntempid='
                    || v_mmtt.transaction_temp_id, 1);
                END IF;

                -- Remove from MSNT rows with same MMTT transaction_temp_id
                DELETE FROM mtl_serial_numbers_temp
                      WHERE transaction_temp_id = v_mmtt.transaction_temp_id;

                -- Remove from MSNT rows with same MTNT transaction_temp_id
                DELETE FROM mtl_serial_numbers_temp
                      WHERE transaction_temp_id IN(SELECT serial_transaction_temp_id
                                                     FROM mtl_transaction_lots_temp
                                                    WHERE transaction_temp_id = v_mmtt.transaction_temp_id);

                -- Remove from MTLT rows with same MMTT transaction_temp_id
                DELETE FROM mtl_transaction_lots_temp
                      WHERE transaction_temp_id = v_mmtt.transaction_temp_id;

                -- Remove from MMTT rows with same transaction group id
                DELETE FROM mtl_material_transactions_temp
                      WHERE transaction_temp_id = v_mmtt.transaction_temp_id;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Error in updating MTI or deleting MMTT for trxbatchid=' || v_mmtt.transaction_batch_id, 1);
                END IF;
            END;
          ELSE   -- record originated in MMTT
            IF (v_mmtt.transaction_batch_id IS NOT NULL) THEN
              -- This record belongs to a batch. Fail all records of this batch
              -- stamp error-explanation only on the row that caused error
              UPDATE mtl_material_transactions_temp
                 SET ERROR_CODE = l_error_code
                   , error_explanation = x_proc_msg
                   , process_flag = 'E'
                   , lock_flag = 'N'
               WHERE transaction_temp_id = v_mmtt.transaction_temp_id;

              -- stamp error-code on all records of the batch
              UPDATE mtl_material_transactions_temp
                 SET ERROR_CODE = l_error_code
                   , process_flag = 'E'
                   , lock_flag = 'N'
               WHERE transaction_header_id = p_trx_hdr_id -- Bug 5748351
               AND transaction_batch_id = v_mmtt.transaction_batch_id;
            ELSE
              -- This record does not belong to a batch.
               -- Update MMTT records with error message and set status to error
              UPDATE mtl_material_transactions_temp
                 SET ERROR_CODE = l_error_code
                   , error_explanation = x_proc_msg
                   , process_flag = 'E'
                   , lock_flag = 'N'
               WHERE transaction_temp_id = v_mmtt.transaction_temp_id;
            END IF;
          END IF;
      END;   -- WHEN OTHERS THEN

      -- HVERDDIN ERES START
      tbl_index  := tbl_index + 1;
    -- HVERDDIN ERES END
      --Jalaj Srivastava Bug 5138445
      --update secondary transaction quantity with the sign of transaction quantity
      l_secondary_txn_quantity := v_mmtt.secondary_transaction_quantity;

   /* Begin of Bug 9569657 */
      IF v_mmtt.transaction_source_type_id = 9 AND v_mmtt.transaction_type_id = 4 AND v_mmtt.transaction_action_id = 4 THEN
         NULL;
      ELSE
   /* End of Bug 9569657 */
         IF    (v_mmtt.secondary_transaction_quantity IS NOT NULL)
           AND (v_mmtt.secondary_transaction_quantity <> 0)
           AND (sign(v_mmtt.secondary_transaction_quantity) <> sign(v_mmtt.transaction_quantity))
           AND (v_mmtt.transaction_type_id not in (1004, 97))  /* Fix for 13435268 and 13536869. Do not update secondary transaction for lot uom decrease and increase txn */
           --Bug# 5453879 - if trx qty is 0 leave the sec qty as it is.
           AND (v_mmtt.transaction_quantity <> 0)  THEN
           l_secondary_txn_quantity := sign(v_mmtt.transaction_quantity) * abs(v_mmtt.secondary_transaction_quantity);
           update mtl_material_transactions_temp
           set    secondary_transaction_quantity = l_secondary_txn_quantity
           where  transaction_temp_id = v_mmtt.transaction_temp_id;
         END IF;
      END IF; -- Bug 9569657

       IF (v_mmtt.move_order_line_id IS NOT null ) THEN   --Bug15837987 begin for those allocation type mmtt records.
             IF (l_debug = 1) THEN
                inv_log_util.TRACE('Update WHO Columns for allocation type.','INV_LPN_TRX_PUB', 1);
             END IF;
               update mtl_material_transactions_temp
                set last_update_date = SYSDATE,
                    last_updated_by = FND_PROFILE.VALUE('USER_ID'),
                    last_update_login = FND_PROFILE.VALUE('LOGIN_ID'),
                    CREATED_BY = FND_PROFILE.VALUE('USER_ID')
                where transaction_temp_id = v_mmtt.transaction_temp_id;
       END IF;  --Bug15837987 End

      IF (l_debug = 1) THEN
        inv_log_util.trace('before calling java TM transaction quantity='||v_mmtt.transaction_quantity, 'INV_LPN_TRX_PUB',9);
        inv_log_util.trace('before calling java TM secondary transaction quantity='||l_secondary_txn_quantity, 'INV_LPN_TRX_PUB',9);
        inv_log_util.trace('before calling java TM primary quantity='||v_mmtt.primary_quantity, 'INV_LPN_TRX_PUB',9);
      END IF;
      /*Bug14298387,added the validation on logic locator to call pjm api GET_PHYSICAL_LOCATION*/
      BEGIN
         SELECT DECODE(NVL(PROJECT_REFERENCE_ENABLED, 2),1,1,0)
         INTO l_project_ref_enabled
         FROM MTL_PARAMETERS
         WHERE ORGANIZATION_ID = v_mmtt.organization_id ;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_project_ref_enabled := 0;
      END;
      IF l_project_ref_enabled = 1 AND nvl(v_mmtt.locator_id,-1) <> -1 THEN
		     l_phy_result  := inv_projectlocator_pub.GET_PHYSICAL_LOCATION(
		        P_ORGANIZATION_ID          => v_mmtt.organization_id
		      , P_LOCATOR_ID               => v_mmtt.locator_id
		      );
         IF (l_phy_result = FALSE) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Calling inv_projectlocator_pub.GET_PHYSICAL_LOCATION returned with error for locator_id'||v_mmtt.locator_id, 'INV_LPN_TRX_PUB', 9);
            END IF;
            fnd_message.set_name('INV', 'INV_INT_LOCEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
      --for move order/direct org xfer/sub xfer,we need also check the transfer location
      IF(v_mmtt.transaction_source_type_id=4) then--move order
        IF l_project_ref_enabled = 1 AND nvl(v_mmtt.transfer_to_location,-1) <> -1 THEN
		     l_phy_result  := inv_projectlocator_pub.GET_PHYSICAL_LOCATION(
		        P_ORGANIZATION_ID          => v_mmtt.organization_id
		      , P_LOCATOR_ID               => v_mmtt.transfer_to_location
		      );
          IF (l_phy_result = FALSE) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Calling inv_projectlocator_pub.GET_PHYSICAL_LOCATION returned with error for transfer_to_location'||v_mmtt.transfer_to_location, 'INV_LPN_TRX_PUB', 9);
            END IF;
            fnd_message.set_name('INV', 'INV_INT_LOCEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      ELSIF(v_mmtt.transaction_source_type_id=13 AND v_mmtt.transaction_action_id=2) THEN --sub xfer
        IF l_project_ref_enabled = 1 AND nvl(v_mmtt.transfer_to_location,-1) <> -1 THEN
		     l_phy_result  := inv_projectlocator_pub.GET_PHYSICAL_LOCATION(
		        P_ORGANIZATION_ID          => v_mmtt.organization_id
		      , P_LOCATOR_ID               => v_mmtt.transfer_to_location
		      );
          IF (l_phy_result = FALSE) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Calling inv_projectlocator_pub.GET_PHYSICAL_LOCATION returned with error for transfer_to_location'||v_mmtt.transfer_to_location, 'INV_LPN_TRX_PUB', 9);
            END IF;
            fnd_message.set_name('INV', 'INV_INT_LOCEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      ELSIF(v_mmtt.transaction_source_type_id=13 AND v_mmtt.transaction_action_id=3)THEN --org direct xfer
        BEGIN
         SELECT DECODE(NVL(PROJECT_REFERENCE_ENABLED, 2),1,1,0)
         INTO l_project_ref_enabled
         FROM MTL_PARAMETERS
         WHERE ORGANIZATION_ID = v_mmtt.transfer_organization ;
	EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_project_ref_enabled := 0;
        END;
        IF l_project_ref_enabled = 1 AND nvl(v_mmtt.transfer_to_location,-1) <> -1 THEN
		      l_phy_result  := inv_projectlocator_pub.GET_PHYSICAL_LOCATION(
		        P_ORGANIZATION_ID          => v_mmtt.transfer_organization
		      , P_LOCATOR_ID               => v_mmtt.transfer_to_location
		      );
          IF (l_phy_result = FALSE) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Calling inv_projectlocator_pub.GET_PHYSICAL_LOCATION returned with error for transfer_to_location'||v_mmtt.transfer_to_location, 'INV_LPN_TRX_PUB', 9);
            END IF;
            fnd_message.set_name('INV', 'INV_INT_LOCEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
      --Bug14298387 end
    END LOOP;

    --************* Close cursor loop into MMTT  *************
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('Done with MMTT cursor insrowcnt=' || insrowcnt || ' failedrowcnt=' || failedrowcnt, 'INV_LPN_TRX_PUB', 9);
    END IF;

    -- Bug 3618385
    -- For a transaction_header_id, when there's only one batch and a record is failed in the batch
    -- the whole batch should fail and should not call the java TM, but l_call_tm is not set probably
    -- to check if we need to call the java TM. We'll call the java TM only if there's any record
    -- exist for the transaction_header_id in MMTT.
    -- Bug 3804314: Included process_flag = 'Y' as the rows in MMTT are not
    -- deleted for transactions coming thorugh MMTT. We will have to check
    -- by process code also. Otherwise, we will still call the TM.
    BEGIN
       SELECT COUNT(1)
	 INTO   l_process
	 FROM   mtl_material_transactions_temp
	 WHERE  transaction_header_id = p_trx_hdr_id
	 AND process_flag = 'Y'
	 AND    ROWNUM < 2;
       IF (l_debug = 1) THEN
          inv_log_util.TRACE('l_process: ' || l_process, 'INV_LPN_TRX_PUB', 9);
       END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               inv_log_util.TRACE('No records in MMTT for trx_header_id: ' || p_trx_hdr_id || ' ,will not call JAVATM', 'INV_LPN_TRX_PUB', 9);
            END IF;
            l_process := 0;
    END;


    -- All preprocessing done. Call the Inventory Transactions Manager
    IF (fnd_api.to_boolean(l_process_trx))
      AND (l_process <> 0) THEN
      -- AND(l_call_tm) THEN
      -- Should all the rows in MMTT with the specified TrxHdrId be considered
      -- as one unit
      IF fnd_api.to_boolean(p_atomic) THEN
        l_atomic  := 1;
      END IF;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('***Calling TM **', 'INV_LPN_TRX_PUB', 9);
      END IF;

      retval  := inv_trx_mgr.process_trx_batch(p_trx_hdr_id, l_commit, l_atomic, NVL(p_business_flow_code, 0), ret_msgdata);

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('retval=' || retval || ', regmsg=' || ret_msgdata, 'INV_LPN_TRX_PUB', 9);
      END IF;
      --------------------
      -- Bug no 3540288
      -- Adding call to clear picked quantity.
      --------------------
      IF (l_debug = 1) THEN
          inv_log_util.trace('calling API to clear the picked quantity', 'INV_LPN_TRX_PUB',9);
      END IF;
      BEGIN
          inv_transfer_order_pvt.clear_picked_quantity;
      END;
      IF (l_debug = 1) THEN
          inv_log_util.trace('API call to clear picked quantity successful', 'INV_LPN_TRX_PUB',9);
      END IF;
    END IF;

    IF (retval <> 0) THEN
      x_proc_msg  := ret_msgdata;

      IF (failedrowcnt > 0) THEN
        RETURN -1 * failedrowcnt;
      ELSE
        RETURN -1;
      END IF;
    END IF;

    -- If cartonization was called make call to print
    -- cartonzation flow labels
    IF (l_is_cartonization = 1) THEN
      inv_label.print_label(
        x_return_status              => ret_status
      , x_msg_count                  => ret_msgcnt
      , x_msg_data                   => ret_msgdata
      , x_label_status               => label_status
      , p_api_version                => 1.0
      , p_print_mode                 => 1
      , p_business_flow_code         => 22
      , p_transaction_id             => wms_cartnzn_wrap.get_lpns_generated_tb
      );

      IF (ret_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('**Error Label Printing :' || ret_status, 'INV_LPN_TRX_PUB', 1);
        END IF;
      END IF;
    END IF;

    -- If any of the rows in MMTT fail return number of failed rows.
    IF (failedrowcnt > 0) THEN
      x_proc_msg  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');
      RETURN -1 * failedrowcnt;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    --
    -- HVERDDIN START OF ERES CHANGES
    --
    IF l_eres_enabled <> 'N' THEN
      -- ERES is Enabled, Verify if Transaction type is supported
      IF l_eres_tbl.COUNT > 0 THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('TBL COUNT =' || l_eres_tbl.COUNT, 'INV_LPN_TRX_PUB', 9);
        END IF;

        FOR tbl_index IN 1 .. l_eres_tbl.COUNT LOOP
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('counter =' || tbl_index, 'INV_LPN_TRX_PUB', 9);
          END IF;

          IF (
              trans_eres_enabled(
                p_trans_action_id            => l_eres_tbl(tbl_index).transaction_action_id
              , p_trans_source_type_id       => l_eres_tbl(tbl_index).transaction_source_type_id
              )
             ) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('This is an ERES enabled Event', 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(' EVENT_NAME => ' || g_eres_event_name, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(' EVENT_ID => ' || l_eres_tbl(tbl_index).event_id, 'INV_LPN_TRX_PUB', 1);
            END IF;

            -- Get Erecord Id
            qa_edr_standard.get_erecord_id(
              p_api_version                => 1.0
            , p_init_msg_list              => 'F'
            , p_event_name                 => g_eres_event_name
            , p_event_key                  => l_eres_tbl(tbl_index).event_id
            , x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , x_erecord_id                 => l_erecord_id
            );

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Status of Get_Erecord_Id => ' || ret_status, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE(' Return Message => ' || ret_status, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE('ERECORD  => ' || ret_status, 'INV_LPN_TRX_PUB', 1);
            END IF;

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE(' ERROR generated from getErecordIdAPI:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_ERECORD_INVALID');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            /* If an eRecord exists, then acknowledge it
            ===========================================*/
            IF l_erecord_id IS NOT NULL THEN
              qa_edr_standard.send_ackn(
                p_api_version                => 1.0
              , p_init_msg_list              => 'F'
              , p_event_name                 => g_eres_event_name
              , p_event_key                  => l_eres_tbl(tbl_index).event_id
              , p_erecord_id                 => l_erecord_id
              , p_trans_status               => l_trans_status
              , p_ackn_by                    => 'Inventory Transaction Manager'
              , p_ackn_note                  => 'SERVER SIDE'
              , p_autonomous_commit          => 'F'
              , x_return_status              => ret_status
              , x_msg_count                  => ret_msgcnt
              , x_msg_data                   => ret_msgdata
              );

              IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE(' Error from Send ERES ACKNOWLEDGE API:' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_ERECORD_INVALID');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;   /* IF ERECORD ID not NULL */
          END IF;   /* IF TRANS NOT ERES SUPPORTED */
        END LOOP;   /* LOOP THROUGH ALL ERECORDS in TBL*/
      END IF;   /* IF ERES TBL has more than 1 row*/
    END IF;   /* IF ERES NOT SUPPORTED */

-- bug 9756188  restructured the OPM code here so that for batch creation and PO receipt creation for material transactions ,
--    multiple lots will each generate a workflow notification for event oracle.apps.gmi.inventory.created    for which gen_object_id is passed to AME
--    as well as event oracle.apps.gmi.inv.po.receipt  with  gen_object_id representing the lot number.
-- SO commented block out below and replaced by code underneath it.

    /* Jalaj Srivastava
       Raise workflow event for OPM-QM */
  /*  FOR c1_rec IN cur_get_txn_for_opm_qm
    LOOP
      wf_event.raise2( p_event_name => 'oracle.apps.gmi.inventory.created'
                      ,p_event_key  =>  c1_rec.transaction_id);
      IF c1_rec.transaction_source_type_id in ( inv_globals.g_sourcetype_purchaseorder
                                               ,inv_globals.g_sourcetype_rma
                                               ,inv_globals.g_sourcetype_intreq) THEN
         -- Bug 5361705 - Raise the opm qm quality event for every distinct lot
         FOR c2_rec IN cr_get_distinct_lots(c1_rec.transaction_id)
         LOOP

            wf_event.raise2( p_event_name => 'oracle.apps.gmi.inv.po.receipt'
                            ,p_event_key  =>  to_char(c2_rec.product_transaction_id)||'-'||to_Char(c2_rec.gen_object_id));
         END LOOP;

      END IF;
    END LOOP; */


    /* Jalaj Srivastava

       Raise workflow event for OPM-QM */

    inv_log_util.TRACE(' OPM part ', 'INV_LPN_TRX_PUB', 1);
    FOR c1_rec IN cur_get_txn_for_opm_qm
    LOOP

       inv_log_util.TRACE('in cur_get_txn_for_opm_qm - c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
       inv_log_util.TRACE('in cur_get_txn_for_opm_qm - c1_rec.transaction_source_type_id = ' || c1_rec.transaction_source_type_id, 'INV_LPN_TRX_PUB', 1);
       IF c1_rec.transaction_source_type_id <> inv_globals.G_SOURCETYPE_WIP  then     -- --  9756188
          inv_log_util.TRACE('about to raise event oracle.apps.gmi.inventory.created  for NON    G_SOURCETYPE_WIP    for c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
       		inv_log_util.TRACE('                              gen_object_id = ' || l_gen_object_id, 'INV_LPN_TRX_PUB', 1);
       		wf_event.raise2( p_event_name => 'oracle.apps.gmi.inventory.created'
                      --,p_event_key  =>  c1_rec.transaction_id);
                       ,p_event_key  =>  to_char(c1_rec.transaction_id)||'-'||to_Char(l_gen_object_id)); -- pass a dummy gen_object_id as there is no lot for this pass
       end if;
      IF c1_rec.transaction_source_type_id in ( inv_globals.g_sourcetype_purchaseorder
                                               ,inv_globals.g_sourcetype_rma
                                               ,inv_globals.G_SOURCETYPE_WIP  --  9756188
                                               ,inv_globals.g_sourcetype_intreq) THEN
         -- Bug 5361705 - Raise the opm qm quality event for every distinct lot
         inv_log_util.TRACE('about to get into  cr_get_distinct_lots - c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
         i := 0; -- 13557341
         FOR c2_rec IN cr_get_distinct_lots(c1_rec.transaction_id)
         LOOP
            IF c1_rec.transaction_source_type_id = inv_globals.G_SOURCETYPE_WIP THEN  -- 9756188
                  inv_log_util.TRACE(' about to raise event oracle.apps.gmi.inventory.created  for G_SOURCETYPE_WIP    for c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
                  inv_log_util.TRACE(' G_SOURCETYPE_WIP    gen_object_id =                                                                         ' || c2_rec.gen_object_id , 'INV_LPN_TRX_PUB', 1);
            	 	  wf_event.raise2( p_event_name => 'oracle.apps.gmi.inventory.created'
                      --,p_event_key  =>  c1_rec.transaction_id);
                         ,p_event_key  =>  to_char(c1_rec.transaction_id)||'-'||to_Char(c2_rec.gen_object_id)); --  pass lot number as gen_object_id
            ELSE
                  inv_log_util.TRACE(' about to raise event oracle.apps.gmi.inv.po.receipt for c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
                  inv_log_util.TRACE('                                                                 gen_object_id = ' || c2_rec.gen_object_id , 'INV_LPN_TRX_PUB', 1);
              		wf_event.raise2( p_event_name => 'oracle.apps.gmi.inv.po.receipt'
     							,p_event_key  =>to_char(c2_rec.product_transaction_id)||'-'||to_Char(c2_rec.gen_object_id));
            END IF;
            i := i + 1; -- 13557341

         END LOOP;

          --13557341  start   if no lots found then raise event event oracle.apps.gmi.inventory.created  for G_SOURCETYPE_WIP  with not lot
         IF i = 0 then
		          inv_log_util.TRACE('cursor cr_get_distinct_lots  returns zero rows for  c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);

		          IF c1_rec.transaction_source_type_id <> inv_globals.G_SOURCETYPE_WIP  then      -- 13686877  start added if
		              inv_log_util.TRACE(' about to raise event oracle.apps.gmi.inv.po.receipt for c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
                  inv_log_util.TRACE('  dummy gen_object_id as there is no lot for this pass   gen_object_id = ' || l_gen_object_id, 'INV_LPN_TRX_PUB', 1);
              		wf_event.raise2( p_event_name => 'oracle.apps.gmi.inv.po.receipt'
     															,p_event_key  =>to_char(c1_rec.transaction_id)||'-'||to_Char(l_gen_object_id));  -- pass a dummy gen_object_id as there is no lot for this pass


		          ELSE
				          inv_log_util.TRACE('SO about to raise event oracle.apps.gmi.inventory.created  for G_SOURCETYPE_WIP    for c1_rec.transaction_id = ' || c1_rec.transaction_id, 'INV_LPN_TRX_PUB', 1);
				       		inv_log_util.TRACE('  dummy gen_object_id as there is no lot for this pass   gen_object_id = ' || l_gen_object_id, 'INV_LPN_TRX_PUB', 1);
				       		wf_event.raise2( p_event_name => 'oracle.apps.gmi.inventory.created'
				                          ,p_event_key  =>  to_char(c1_rec.transaction_id)||'-'||to_Char(l_gen_object_id)); -- pass a dummy gen_object_id as there is no lot for this pass

		          END IF;      -- 13686877  end


         end if ;  --  IF i = o then
         -- 13557341 end

        END IF; --  IF c1_rec.transaction_source_type_id in ( inv_globals.g_sourcetype_purchaseorder
    END LOOP;  -- FOR c1_rec IN cur_get_txn_for_opm_qm
    inv_log_util.TRACE(' @@@@@@@@@@@@@@@@@@  OPM part end @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 'INV_LPN_TRX_PUB', 1);

    -- HVERDDIN END OF ERES CHANGES
    --

    fnd_message.set_name('WMS', 'WMS_TXN_SUCCESS');
    fnd_msg_pub.ADD;
    x_proc_msg       := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      -- rollback to the savepoint
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('ERROR : Code' || SQLCODE || ',Msg:' || SUBSTR(SQLERRM, 1, 100), 'INV_LPN_TRX_PUB', 1);
      END IF;

      ROLLBACK TO process_lpn_trx;
      --bug 2894323 fix made changes to return all the messages in the
      --stack in x_proc_msg out variable
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => ret_msgcnt, p_data => x_proc_msg);

      IF ret_msgcnt IS NULL THEN
        ret_msgcnt  := 0;
      END IF;

      FOR x IN 1 .. ret_msgcnt LOOP
        ret_msgdata  := SUBSTR(fnd_msg_pub.get(ret_msgcnt - x + 1, 'F'), 0, 200);

        IF (l_debug = 1) THEN
          inv_log_util.TRACE(x || ':' || ret_msgdata, 'INV_LPN_TRX_PUB', 1);
        END IF;

        IF x <> 1 THEN
          ret_msgdata  := ' | ' || ret_msgdata;
        END IF;

        l_err_msg    := SUBSTR(l_err_msg || ret_msgdata, 1, 2000);
      END LOOP;

      x_proc_msg    := SUBSTR(l_err_msg, 1, 170);
      -- Update MMTT with error_code
      fnd_message.set_name('INV', 'INV_INT_PROCCODE');
      fnd_msg_pub.ADD;
      l_error_code  := fnd_msg_pub.get(fnd_msg_pub.g_last, 'F');

      BEGIN
        SELECT 1
          INTO l_is_from_mti
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM mtl_material_transactions_temp
                       WHERE transaction_header_id = p_trx_hdr_id
                         AND transaction_mode = inv_txn_manager_pub.proc_mode_mti);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('no record found in mmtt', 'INV_LPN_TRX_PUB', 1);
          END IF;
      END;

      IF (l_is_from_mti = 1) THEN
        -- record originated from MTI. Update all records in MTI for this batch
        -- Delete from MMTT, MTLT and MSNT. Records from MTI get copied to MMTT
        -- in tmpinsert() in INV_TXN_MANAGER_PUB
        UPDATE mtl_transactions_interface
           SET ERROR_CODE = substrb(l_error_code,1,240)/*added substrb for 3632722*/
             , error_explanation = substrb(x_proc_msg,1,240)/*added substrb for 3632722*/
             , process_flag = 3
             , lock_flag = 2
         WHERE transaction_header_id = p_trx_hdr_id;

        -- Remove from MSNT rows with same MMTT Transaction_header_id
        DELETE FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                             FROM mtl_material_transactions_temp
                                            WHERE transaction_header_id = p_trx_hdr_id);

        -- Remove from MSNT rows with same MTNT Transaction_header_id
        DELETE FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id IN(SELECT serial_transaction_temp_id
                                             FROM mtl_transaction_lots_temp
                                            WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                                                           FROM mtl_material_transactions_temp
                                                                          WHERE transaction_header_id = p_trx_hdr_id));

        -- Remove from MTLT rows with same MMTT Transaction_header_id
        DELETE FROM mtl_transaction_lots_temp
              WHERE transaction_temp_id IN(SELECT transaction_temp_id
                                             FROM mtl_material_transactions_temp
                                            WHERE transaction_header_id = p_trx_hdr_id);

        -- Remove from MMTT rows with same Transaction_header_id
        DELETE FROM mtl_material_transactions_temp
              WHERE transaction_header_id = p_trx_hdr_id;
      ELSE
        UPDATE mtl_material_transactions_temp
           SET ERROR_CODE = l_error_code
             , error_explanation = x_proc_msg
             , process_flag = 'E'
             , lock_flag = 'N'
         WHERE transaction_header_id = p_trx_hdr_id;
      END IF;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('Exiting PROCESS_LPN_TRX with exception from_mti=' || l_is_from_mti || ' trx_hdr_id=' || p_trx_hdr_id
        , 'INV_LPN_TRX_PUB', 1);
      END IF;

      RETURN -1;
  END process_lpn_trx;

  /********************************************************************
   *
   * PROCESS_LPN_TRX_LINE
   * This procedure does all the LPN related processing on an MMTT record.
   * The logic in this API is based on the transaction_action and the contents
   * of columns LPN_ID, CONTENT_LPN_ID, and TRANSFER_LPN_ID
   *  LPN_ID : LPN from where item/other-LPN should be unpacked
   *  CONTENT_LPN : If the transaction is based on a whole LPN
   *  TRANSFER_LPN : LPN to which item/other-LPN is to be packed
   *******************************************************************/
  PROCEDURE process_lpn_trx_line(
    x_return_status              OUT NOCOPY    VARCHAR2
  , x_proc_msg                   OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id        IN            NUMBER
  , p_business_flow_code         IN            NUMBER := NULL
  , p_transaction_source_type_id IN            NUMBER
  , p_transaction_action_id      IN            NUMBER
  , p_lpn_id                     IN            NUMBER := NULL
  , p_content_lpn_id             IN            NUMBER := NULL
  , p_transfer_lpn_id            IN            NUMBER := NULL
  , p_organization_id            IN            NUMBER
  , p_subinventory_code          IN            VARCHAR2
  , p_locator_id                 IN            NUMBER := NULL
  , p_transfer_organization      IN            NUMBER := NULL
  , p_transfer_subinventory      IN            VARCHAR2 := NULL
  , p_transfer_to_location       IN            NUMBER := NULL
  , p_primary_quantity           IN            NUMBER
  , p_primary_uom                IN            VARCHAR2 := NULL
  , p_transaction_quantity       IN            NUMBER
  , p_transaction_uom            IN            VARCHAR2
  , p_secondary_trx_quantity     IN            NUMBER := NULL
  , p_secondary_uom_code         IN            VARCHAR2 := NULL
  , p_inventory_item_id          IN            NUMBER
  , p_revision                   IN            VARCHAR2 := NULL
  , p_lot_number                 IN            VARCHAR2 := NULL
  , p_cost_group_id              IN            NUMBER
  , p_transfer_cost_group_id     IN            NUMBER := NULL
  , p_rcv_transaction_id         IN            NUMBER := NULL
  , p_shipment_number            IN            VARCHAR2 := NULL
  , p_transaction_source_id      IN            NUMBER := NULL
  , p_trx_source_line_id         IN            NUMBER := NULL
  , p_serial_control_code        IN            NUMBER := NULL
  , p_po_dest_expense            IN            NUMBER := NULL
  , p_manual_receipt_expense     IN            VARCHAR2 := NULL
  , p_source_transaction_id      IN            NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)          := 'Process_LPN_Trx_Line';
    l_api_version CONSTANT NUMBER                := 1.0;
    l_debug                NUMBER                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress             VARCHAR2(500)         := '0';
    l_msgdata              VARCHAR2(1000);
    l_item_rec             inv_validate.item;
    v_lpn                  wms_container_pub.lpn;
    v_lpn_ctx              NUMBER;
    v_cnt_lpn_ctx          NUMBER;
    v_xfrlpn_ctx           NUMBER;
    v_autounpack           NUMBER                := 1;
    v_xfr_org              NUMBER;
    l_primary_quantity     NUMBER                := p_primary_quantity;
    l_transaction_quantity NUMBER                := p_transaction_quantity;
    l_secondary_trx_quantity NUMBER                := p_secondary_trx_quantity;  --INVCONV kkillams
    l_xfr_sub              VARCHAR2(64);
    l_xfr_loc              NUMBER;
    l_temp_num             NUMBER;
    l_rcv_interface_txn_id NUMBER;
    l_rcv_txn_type         VARCHAR2(64);
    label_status           VARCHAR2(512);
    l_system_task_type     NUMBER;   -- bug 2879208
    l_ret_bool             BOOLEAN;
    --Start of fix for Bug 4891916
    --Added the following variables to check for the profile value and
    --to pass the transaction_identifer to the label label printing api
    l_print_label   NUMBER := NVL(FND_PROFILE.VALUE('WMS_LABEL_FOR_CYCLE_COUNT'),2);
    l_transaction_identifier NUMBER := NULL ;
    --End of fix for Bug 4891916

    l_cyclpn_id NUMBER := NULL;  --Bug#6043776
    l_lpn_ctx_tmp            NUMBER ; --Bug 6007873

    --Bug 6374764
    l_sub  VARCHAR2(30);
    l_loc_id number;

	--BUG13578531 Begin
	l_wlpn_sub 		VARCHAR2(30);
    l_wlpn_loc_id 	NUMBER;
	--BUG13578531 End
    --Bug 9740452
    l_transaction_type_id NUMBER;
    l_business_flow_code NUMBER;
    l_reservation_id     NUMBER; --9869993

    l_loaded_tasks_count NUMBER := 0;  -- Added for bug 7010169
    l_trx_hdr_id         NUMBER := 0;  -- Added for bug 7010169

 -- Start of bug 7226314, 7355087

      l_lpn_name VARCHAR2(30);
      l_status_code VARCHAR2(1);
      l_delivery_id NUMBER;
      l_xfrlpn_ctx NUMBER;
      l_delivery_detail_id NUMBER;
      l_container_name     wsh_delivery_details.container_name%TYPE;
      l_container_new_name wsh_delivery_details.container_name%TYPE;
      l_container_flag     wsh_delivery_details.container_flag%TYPE;
      l_container_rec      wsh_container_grp.changedattributetabtype;

      l_rtv_transaction_id NUMBER ;--RTV Change 16197273
      l_source_header_id NUMBER  :=NULL ;
      l_source_name  VARCHAR2(100) := NULL ;

      CURSOR c_wdd_exists(p_transfer_lpn_id NUMBER,p_organization_id NUMBER) is
      SELECT distinct wda.delivery_id,wdd.delivery_detail_id,wdd.released_status
      FROM wsh_delivery_details wdd, wsh_delivery_assignments wda
      WHERE wdd.lpn_id IN (select lpn_id from wms_license_plate_numbers
                        where organization_id = p_organization_id
                        and (lpn_id = p_transfer_lpn_id
                        or parent_lpn_id = p_transfer_lpn_id
                        or outermost_lpn_id = p_transfer_lpn_id))
      AND wda.parent_delivery_detail_id = wdd.delivery_detail_id;

      -- End of bug 7226314,7355087

      CURSOR c_rtv_exists (p_lpn_id NUMBER ,p_organization_id NUMBER )  IS --RTV Change 16197273
      SELECT interface_transaction_id FROM rcv_transactions_interface rti,wms_lpn_contents wlc
             WHERE  rti.interface_transaction_id =  wlc.source_header_id
                    AND rti.processing_status_code = 'WSH_INTERFACED'
                    AND rti.to_organization_id = wlc.organization_id
                    AND wlc.parent_lpn_id =  p_lpn_id
		    AND ROWNUM < 2 ;


  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.TRACE(
           'Call to PROCESS_LPN_TRX_LINE trxtmpid='
        || p_transaction_temp_id
        || ' flwcode='
        || p_business_flow_code
        || ' srctype='
        || p_transaction_source_type_id
        || ' actid='
        || p_transaction_action_id
      , 'INV_LPN_TRX_PUB'
      , 9
      );
      inv_log_util.TRACE(
           'lpn='
        || p_lpn_id
        || ' cntlpn='
        || p_content_lpn_id
        || ' xfrlpn='
        || p_transfer_lpn_id
        || ' orgid='
        || p_organization_id
        || ' sub='
        || p_subinventory_code
        || ' loc='
        || p_locator_id
      , 'INV_LPN_TRX_PUB'
      , 9
      );
      inv_log_util.TRACE(
           'xfrorg='
        || p_transfer_organization
        || ' xfrsub='
        || p_transfer_subinventory
        || ' xfrloc='
        || p_transfer_to_location
        || ' priqty='
        || p_primary_quantity
        || ' trxqty='
        || p_transaction_quantity
        || ' uom='
        || p_transaction_uom
      , 'INV_LPN_TRX_PUB'
      , 9
      );
      inv_log_util.TRACE(
           'item='
        || p_inventory_item_id
        || ' rev='
        || p_revision
        || ' lot='
        || p_lot_number
        || ' cg='
        || p_cost_group_id
        || ' rcvtrxid='
        || p_rcv_transaction_id
        || ' shipnum='
        || p_shipment_number
      , 'INV_LPN_TRX_PUB'
      , 9
      );
      inv_log_util.TRACE(
           'srcid='
        || p_transaction_source_id
        || ' slnid='
        || p_trx_source_line_id
        || ' qty2='
        || p_secondary_trx_quantity
        || ' uom2='
        || p_secondary_uom_code
        || ' podst='
        || p_po_dest_expense
        || ' rcptex='
        || p_manual_receipt_expense
        || ' strxid='
        || p_source_transaction_id
      , 'INV_LPN_TRX_PUB'
      , 9
      );
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    --SAVEPOINT PROCESS_LPN_TRX_LINE;

    -- Continue with this record ONLY if atleast one of the field
    -- lpn_id, content_lpn_id, transfer_lpn_id is NOT NULL
    IF NOT((p_lpn_id IS NULL)
           AND(p_content_lpn_id IS NULL)
           AND(p_transfer_lpn_id IS NULL)) THEN
      -- Retrieve item properties if not passed by TM: used by bug 3158847 as well
      IF (p_inventory_item_id > 0) THEN
        IF (p_primary_uom IS NULL
            OR p_serial_control_code IS NULL) THEN
          l_progress  := 'Calling INV_CACHE.Set_Item_Rec to get item values';
          l_ret_bool  := inv_cache.set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id);

          IF (l_ret_bool) THEN
            l_progress  := 'Found item assigning it to l_item_rec';
            l_item_rec  := inv_cache.item_rec;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                'Got item properties puom=' || l_item_rec.primary_uom_code || ' sctl=' || l_item_rec.serial_number_control_code
              , 'INV_LPN_TRX_PUB'
              , 9
              );
            END IF;
          ELSE   --failed to get item info
            l_progress  := 'Error calling INV_CACHE.Set_Item_Rec to get item info';
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE   --Values already passed, assign to item rec type
          l_item_rec.organization_id             := p_organization_id;
          l_item_rec.inventory_item_id           := p_inventory_item_id;
          l_item_rec.primary_uom_code            := p_primary_uom;
          l_item_rec.serial_number_control_code  := p_serial_control_code;
          l_item_rec.secondary_uom_code          := p_secondary_uom_code; -- INVCONV kkillams
        END IF;
      END IF;

      -- If the transaction action is either Issue or Intransit Shipment, and
      -- the sign of quantity is not -ve, make it -ve.
      IF (
          (
           (p_transaction_action_id = inv_globals.g_action_issue)
           OR(p_transaction_action_id = inv_globals.g_action_intransitshipment)
           OR(p_transaction_action_id = inv_globals.g_action_intransitshipment)
           OR(p_transaction_action_id = inv_globals.g_action_intransitshipment)
           OR(p_transaction_action_id = inv_globals.g_action_intransitshipment)
          )
          AND(p_primary_quantity > 0)
         ) THEN
        l_primary_quantity      := -1 * p_primary_quantity;
        l_transaction_quantity  := -1 * p_transaction_quantity;
        l_secondary_trx_quantity := CASE WHEN l_secondary_trx_quantity IS NOT NULL THEN  -1 * l_secondary_trx_quantity
                                                                                    ELSE l_secondary_trx_quantity
                                                                                    END;  --INVCONV kkillams
      END IF;

      IF (
          (
           (p_transaction_action_id = inv_globals.g_action_subxfr)
           OR(p_transaction_action_id = inv_globals.g_action_orgxfr)
           OR(p_transaction_action_id = inv_globals.g_action_stgxfr)
           OR(p_transaction_action_id = inv_globals.g_action_costgroupxfr)
           OR(p_transaction_action_id = inv_globals.g_action_planxfr)
           OR(p_transaction_action_id = inv_globals.g_action_containerpack)
           OR(p_transaction_action_id = inv_globals.g_action_containerunpack)
           OR(p_transaction_action_id = inv_globals.g_action_containersplit)
          )
          AND(p_primary_quantity < 0)
         ) THEN
        l_primary_quantity      := -1 * p_primary_quantity;
        l_transaction_quantity  := -1 * p_transaction_quantity;
        l_secondary_trx_quantity := CASE WHEN l_secondary_trx_quantity IS NOT NULL THEN  -1 * l_secondary_trx_quantity
                                                                                    ELSE l_secondary_trx_quantity
                                                                                    END;  --INVCONV kkillams
      END IF;

      -- WMS Correction changes.
      -- MMTT will have a transaction_action_id of
      -- G_Action_DeliveryAdj for a source type of PO or RMA
      -- IDS: Logical Transactions for lot and serials - Opened up TM to
      --  handle logical receipts and logical corrections.
      IF (
          (
           p_transaction_action_id = inv_globals.g_action_deliveryadj
           AND(
               p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
               OR p_transaction_source_type_id = inv_globals.g_sourcetype_rma
              )
          )
          OR(
             p_transaction_action_id = inv_globals.g_action_logicaldeladj
             AND p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
            )
         ) THEN
        -- Corrections.  Need to retrieve interface_transaction_id and transaction_type
        BEGIN
          SELECT interface_transaction_id
               , transaction_type
            INTO l_rcv_interface_txn_id
               , l_rcv_txn_type
            FROM rcv_transactions
           WHERE transaction_id = p_rcv_transaction_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_rcv_interface_txn_id  := NULL;
            l_rcv_txn_type          := NULL;
        END;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('** transaction_type=' || l_rcv_txn_type, 'INV_LPN_TRX_PUB', 9);
        END IF;

        IF (l_rcv_txn_type = 'CORRECT') THEN
          IF (l_primary_quantity < 0) THEN   -- -ve correction on delivery
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** -ve correction on delivery unpacking', 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- Unpack items from lpn
          --  IF p_transfer_lpn_id IS NOT NULL THEN
		   IF (p_transfer_lpn_id IS NOT NULL) AND((NVL(p_lpn_id, 0) <> p_transfer_lpn_id)) THEN --14547482


              -- delivery could have been done as loose
              Call_Pack_Unpack (
                 p_tempid           => p_transaction_temp_id
               , p_content_lpn      => p_content_lpn_id
               , p_lpn              => p_transfer_lpn_id
               , p_item_rec         => l_item_rec
               , p_revision         => p_revision
               , p_primary_qty      => ABS(l_primary_quantity)
               , p_qty              => ABS(l_transaction_quantity)
               , p_uom              => p_transaction_uom
               , p_org_id           => p_organization_id
               , p_subinv           => p_subinventory_code
               , p_locator          => p_locator_id
               , p_operation        => g_unpack
               , p_cost_grp_id      => p_cost_group_id
               , p_trx_action       => p_transaction_action_id
               , p_source_header_id => NULL
               , p_source_name      => NULL
               , p_source_type_id   => NULL
               , p_sec_qty          => ABS(l_secondary_trx_quantity) --INVCONV kkillams
               , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
               , p_source_trx_id    => p_source_transaction_id
              );
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** -ve correction on delivery packing', 'INV_LPN_TRX_PUB', 9);
            END IF;


           IF ((NVL(p_lpn_id, 0) <> NVL(p_transfer_lpn_id,0))) THEN 	----14547482
            -- Repack items into transfer lpn nulling cost group,sub and locator
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => NULL
            , p_locator          => NULL
            , p_operation        => g_pack
            , p_cost_grp_id      => NULL
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => NULL
            , p_source_name      => NULL
            , p_source_type_id   => NULL
            , p_sec_qty          => ABS(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );

			 END IF;

            -- Update the context of lpn to resides in receiving
            -- if it's a adj of whole lpn. lpn_id = transfer_lpn_id
            IF (p_lpn_id = p_transfer_lpn_id) THEN
              UPDATE wms_license_plate_numbers
                 SET lpn_context = wms_container_pub.lpn_context_rcv
               WHERE lpn_id = p_lpn_id;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** +ve correction on delivery', 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- Unpack items from lpn with null sub, locator and cost group
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => NULL
            , p_locator          => NULL
            , p_operation        => g_unpack
            , p_cost_grp_id      => NULL
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => NULL
            , p_source_name      => NULL
            , p_source_type_id   => NULL
            , p_sec_qty          => ABS(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** +ve correction on delivery packing', 'INV_LPN_TRX_PUB', 9);
            END IF;

            IF p_transfer_lpn_id IS NOT NULL THEN
              -- Repack items into transfer lpn if it is not null
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_transfer_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => p_subinventory_code
              , p_locator          => p_locator_id
              , p_operation        => g_pack
              , p_cost_grp_id      => p_cost_group_id
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => NULL
              , p_source_name      => NULL
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams.
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );
            END IF;
          END IF;
        END IF;
      END IF;

      /***** ISSUE/LotSplit/LotMerge/Cycle,PhysicalCnt/IntransitShipment trx  ****/
      IF (p_transaction_action_id = inv_globals.g_action_issue)
         OR((p_transaction_action_id = inv_globals.g_action_inv_lot_split)
            AND(l_primary_quantity < 0))
         OR((p_transaction_action_id = inv_globals.g_action_inv_lot_translate)
            AND(l_primary_quantity < 0))
         OR((p_transaction_action_id = inv_globals.g_action_inv_lot_merge)
            AND(l_primary_quantity < 0))
         OR(p_transaction_action_id = inv_globals.g_action_intransitshipment)
         OR((p_transaction_action_id = inv_globals.g_action_cyclecountadj)
            AND l_primary_quantity < 0)
	 OR ((p_transaction_action_id = inv_globals.g_action_assyreturn)
            AND l_primary_quantity < 0) --bug#9223918
         OR((p_transaction_action_id = inv_globals.g_action_physicalcountadj)
            AND l_primary_quantity < 0) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = Issue, lpn=' || p_lpn_id || ',qty=' || l_primary_quantity, 'INV_LPN_TRX_PUB', 9);
        END IF;

        IF (p_content_lpn_id IS NOT NULL) THEN
          -- This is an Issue of LPN from system
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('** content_lpn_id Not null:' || p_content_lpn_id, 'INV_LPN_TRX_PUB', 9);
          END IF;

          v_lpn.lpn_id             := p_content_lpn_id;

          IF (
              p_transaction_action_id = inv_globals.g_action_intransitshipment
              OR(p_transaction_action_id = inv_globals.g_action_issue
                 AND p_transaction_source_type_id = inv_globals.g_sourcetype_intorder)
             ) THEN
            IF (p_po_dest_expense = 1 AND (nvl(p_manual_receipt_expense,'N') <> 'Y')) THEN -- 8491908
            	-- Bug4663000 instead of unpacking expense contents.
            	-- Change context of LPN to issued out of stores, but only if the
            	-- context for the LPN is not already "intransit".  Assuming that if
            	-- LPN is in intransit state, that the LPN has non expense items in them
            	IF ( v_cnt_lpn_ctx IS NULL ) THEN
                SELECT lpn_context
                  INTO v_cnt_lpn_ctx
                  FROM wms_license_plate_numbers
                 WHERE lpn_id = p_content_lpn_id;

                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('Got v_cnt_lpn_ctx='||v_cnt_lpn_ctx, 'INV_LPN_TRX_PUB', 9);
                END IF;
              END IF;

            	IF ( v_cnt_lpn_ctx <> wms_container_pub.lpn_context_intransit ) THEN
            	  v_lpn.lpn_context := wms_container_pub.lpn_context_stores;
            	END IF;
            ELSE
              -- For manual rcpt, both Inventory and Expense Internal orders lpns context
              -- should be marked as intransit for recieving
              v_lpn.lpn_context := wms_container_pub.lpn_context_intransit;
            END IF;
          ELSIF(p_transaction_action_id = inv_globals.g_action_issue
                AND p_transaction_source_type_id = inv_globals.g_sourcetype_wip) THEN
            -- For WIP Issues the LPN set to be defined but not used
            v_lpn.lpn_context  := wms_container_pub.lpn_context_pregenerated;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('WIP Issue, unpack all items', 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- LPN must be unpacked into the current sub
            WMS_Container_PVT.PackUnpack_Container(
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , p_commit                => fnd_api.g_false
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_return_status         => ret_status
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_content_lpn_id
            , p_organization_id       => p_organization_id
            , p_subinventory          => p_subinventory_code
            , p_locator_id            => p_locator_id
            , p_operation             => g_unpack_all
            , p_source_transaction_id => p_source_transaction_id );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Error Full unpack for wip issue:' || ret_status, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
		--13884722
		  ELSIF(p_transaction_action_id = inv_globals.g_action_issue
                AND p_transaction_source_type_id= inv_globals.g_sourcetype_moveorder
				AND p_lpn_id IS NOT NULL AND p_lpn_id <> NVL(p_transfer_lpn_id,-9999)) THEN
            v_lpn.lpn_context  := wms_container_pub.lpn_context_stores;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('MO Issue, unpack the content LPN', 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- LPN must be unpacked from the current parent LPN
            WMS_Container_PVT.PackUnpack_Container(
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , p_commit                => fnd_api.g_false
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_return_status         => ret_status
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn_id
            , p_content_lpn_id        => p_content_lpn_id
            , p_organization_id       => p_organization_id
            , p_subinventory          => p_subinventory_code
            , p_locator_id            => p_locator_id
            , p_operation             => g_unpack
            , p_source_transaction_id => p_source_transaction_id );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Error During unpacking Content LPN for MO issue:' || ret_status, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
		--13884722
          ELSE
            v_lpn.lpn_context  := wms_container_pub.lpn_context_stores;   --ISSUED OUT
          END IF;

          -- For an Intransit Shipment, update the LPN with the shipmentNumber
          -- so that this LPN can be tracked during the corresponding receipt
          IF (p_transaction_action_id = inv_globals.g_action_intransitshipment) THEN
            v_lpn.source_name  := p_shipment_number;
          END IF;

          inv_log_util.TRACE('** 3361969 setting lpn org id to : ' || p_organization_id, 'INV_LPN_TRX_PUB', 9);
          v_lpn.organization_id    := p_organization_id;
          v_lpn.subinventory_code  := NULL;
          v_lpn.locator_id         := NULL;
          v_lpn.inventory_item_id  := NULL;
          update_lpn_status(v_lpn);

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('*** Issued out LPN :' || p_content_lpn_id, 'INV_LPN_TRX_PUB', 9);
          END IF;
        ELSIF(
              p_transaction_action_id = inv_globals.g_action_issue
              AND(
                  p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
                  OR p_transaction_source_type_id = inv_globals.g_sourcetype_rma
                 )
             ) THEN
          -- Return or corrections.  Need to retrieve interface_transaction_id and transaction_type
          BEGIN
            SELECT interface_transaction_id
                 , transaction_type
              INTO l_rcv_interface_txn_id
                 , l_rcv_txn_type
              FROM (SELECT   interface_transaction_id
                           , transaction_type
                           , creation_date
                        FROM rcv_transactions
                       WHERE interface_transaction_id = (SELECT interface_transaction_id
                                                           FROM rcv_transactions
                                                          WHERE transaction_id = p_rcv_transaction_id)
                    ORDER BY transaction_id DESC)
             WHERE ROWNUM < 2;
          --SELECT interface_transaction_id, transaction_type
          --INTO l_rcv_interface_txn_id, l_rcv_txn_type
          --FROM rcv_transactions
          --WHERE transaction_id = p_rcv_transaction_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_rcv_interface_txn_id  := NULL;
              l_rcv_txn_type          := NULL;
          END;

          IF (l_rcv_txn_type = 'RETURN TO RECEIVING') THEN
	      --6374764:While returning to receiving, stamp lpn with the sub and loc
	    --stamped on the corresponding RT record.
	    --p_rcv_transaction_id corresponds to the Return transaction.
    	    select subinventory,locator_id
	    into l_sub,l_loc_id
	    from rcv_transactions
	    where transaction_id = p_rcv_transaction_id;

            IF (p_lpn_id IS NULL
                AND p_transfer_lpn_id IS NOT NULL) THEN
              -- Change context of transfer lpn to recieving
              UPDATE wms_license_plate_numbers
                 SET lpn_context = wms_container_pub.lpn_context_rcv
                   , subinventory_code = nvl(l_sub,subinventory_code) --6374764
                   , locator_id = nvl(l_loc_id,locator_id)	      --6374764
               WHERE lpn_id = p_transfer_lpn_id;

              -- Pack items into transfer lpn
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_transfer_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => NULL
              , p_locator          => NULL
              , p_operation        => g_pack
              , p_cost_grp_id      => NULL
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => NULL
              , p_source_name      => NULL
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );
            ELSIF(p_lpn_id <> p_transfer_lpn_id) THEN
              -- Unpack items from lpn with appropriate source name and trx action id
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => p_subinventory_code
              , p_locator          => p_locator_id
              , p_operation        => g_unpack
              , p_cost_grp_id      => p_cost_group_id
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => l_rcv_interface_txn_id
              , p_source_name      => l_rcv_txn_type
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );

              -- Change context of transfer lpn to recieving
              UPDATE wms_license_plate_numbers
                 SET lpn_context = wms_container_pub.lpn_context_rcv
                   , subinventory_code = nvl(l_sub,subinventory_code) --6374764
                   , locator_id = nvl(l_loc_id,locator_id)            --6374764
               WHERE lpn_id = p_transfer_lpn_id;

              -- Repack items into transfer lpn
              -- changing source name, souce header, and cost group id to null
              -- Also changing the sub AND locator
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_transfer_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => NULL
              , p_locator          => NULL
              , p_operation        => g_pack
              , p_cost_grp_id      => NULL
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => NULL
              , p_source_name      => NULL
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );
            ELSE
              --lpn is same as transfer lpn just need to null the source name,
              --source header id and cost group columns for all items inside
              --that lpn.
              UPDATE wms_lpn_contents
                 SET source_name = NULL
                   , source_header_id = NULL
                   , cost_group_id = NULL
               WHERE parent_lpn_id = p_lpn_id;

              -- Change context of transfer lpn to recieving
              UPDATE wms_license_plate_numbers
                 SET lpn_context = wms_container_pub.lpn_context_rcv
                   , subinventory_code = nvl(l_sub,subinventory_code) --6374764
                   , locator_id = nvl(l_loc_id,locator_id)	      --6374764
               WHERE lpn_id = p_lpn_id;

              --Same needs to be done in the serial numbers table
              UPDATE mtl_serial_numbers
                 SET cost_group_id = NULL
               WHERE lpn_id = p_lpn_id;
            END IF;
          ELSIF(l_rcv_txn_type = 'RETURN TO VENDOR'
                OR l_rcv_txn_type = 'RETURN TO CUSTOMER') THEN
            -- Unpack items from lpn with appropriate source name and trx action id
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => p_subinventory_code
            , p_locator          => p_locator_id
            , p_operation        => g_unpack
            , p_cost_grp_id      => p_cost_group_id
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => l_rcv_interface_txn_id
            , p_source_name      => l_rcv_txn_type
            , p_source_type_id   => NULL
            , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );
          ELSIF(l_rcv_txn_type = 'CORRECT') THEN
            IF (p_lpn_id <> p_transfer_lpn_id) THEN
              -- Unpack items from lpn with null source name and trx action id
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => p_subinventory_code
              , p_locator          => p_locator_id
              , p_operation        => g_unpack
              , p_cost_grp_id      => p_cost_group_id
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => NULL
              , p_source_name      => NULL
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );
              -- Repack items into transfer lpn nulling cost group column
              Call_Pack_Unpack (
                p_tempid           => p_transaction_temp_id
              , p_content_lpn      => p_content_lpn_id
              , p_lpn              => p_transfer_lpn_id
              , p_item_rec         => l_item_rec
              , p_revision         => p_revision
              , p_primary_qty      => ABS(l_primary_quantity)
              , p_qty              => ABS(l_transaction_quantity)
              , p_uom              => p_transaction_uom
              , p_org_id           => p_organization_id
              , p_subinv           => p_subinventory_code
              , p_locator          => p_locator_id
              , p_operation        => g_pack
              , p_cost_grp_id      => NULL
              , p_trx_action       => p_transaction_action_id
              , p_source_header_id => NULL
              , p_source_name      => NULL
              , p_source_type_id   => NULL
              , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
              , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
              , p_source_trx_id    => p_source_transaction_id
              );
            ELSE
              --lpn is same as transfer lpn just need to null the cost group column
              --for all items inside that lpn.
              UPDATE wms_lpn_contents
                 SET cost_group_id = NULL
               WHERE parent_lpn_id = p_lpn_id;

              --Same needs to be done in the serial numbers table
              UPDATE mtl_serial_numbers
                 SET cost_group_id = NULL
               WHERE lpn_id = p_lpn_id;

              -- Since correction is in same lpn, need to change context
              -- of lpn to recieving
              -- Change context of transfer lpn to recieving
              UPDATE wms_license_plate_numbers
                 SET lpn_context = wms_container_pub.lpn_context_rcv
               WHERE lpn_id = p_lpn_id;
            END IF;
          ELSE
            -- Default Action
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => p_subinventory_code
            , p_locator          => p_locator_id
            , p_operation        => g_unpack
            , p_cost_grp_id      => p_cost_group_id
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => NULL
            , p_source_name      => NULL
            , p_source_type_id   => NULL
            , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );
          END IF;
		--Added code to handle issue for bug 12714013
		  ELSIF (p_transfer_lpn_id = p_lpn_id
               AND p_transaction_action_id = inv_globals.g_action_issue
               AND p_transaction_source_type_id= inv_globals.G_SOURCETYPE_MOVEORDER) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('** p_lpn_id = p_transfer_lpn_id *** :' , 'INV_LPN_TRX_PUB', 9);
              inv_log_util.TRACE('** Updating lpn to issued out :' || p_lpn_id, 'INV_LPN_TRX_PUB', 9);
            END IF;

                v_lpn.lpn_id             := p_lpn_id;
                v_lpn.lpn_context        := wms_container_pub.lpn_context_stores;
                v_lpn.organization_id    := p_organization_id;
                v_lpn.subinventory_code  := NULL;
                v_lpn.locator_id         := NULL;
                v_lpn.inventory_item_id  := NULL;
                update_lpn_status(v_lpn);
        ELSIF(p_lpn_id IS NOT NULL) THEN
          -- this is an Issue of Item from LPN. Collect all the lot and
          -- serial records associated with this item and call packAPI
          Call_Pack_Unpack (
            p_tempid           => p_transaction_temp_id
          , p_content_lpn      => p_content_lpn_id
          , p_lpn              => p_lpn_id
          , p_item_rec         => l_item_rec
          , p_revision         => p_revision
          , p_primary_qty      => ABS(l_primary_quantity)
          , p_qty              => ABS(l_transaction_quantity)
          , p_uom              => p_transaction_uom
          , p_org_id           => p_organization_id
          , p_subinv           => p_subinventory_code
          , p_locator          => p_locator_id
          , p_operation        => g_unpack
          , p_cost_grp_id      => p_cost_group_id
          , p_trx_action       => p_transaction_action_id
          , p_source_header_id => NULL
          , p_source_name      => NULL
          , p_source_type_id   => NULL
          , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
          , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
          , p_source_trx_id    => p_source_transaction_id
          );

		-- Adding for Case lpn_id and transfer_lpn_id are stamped and content_lpn_id is null
		-- for MO issue, if the x_match is 4 and content_lpn_id is
		-- not stamped
		-- 12714013
         IF (p_transfer_lpn_id IS NOT NULL) THEN

			select subinventory_code,locator_id
			into l_wlpn_sub,l_wlpn_loc_id
			from wms_license_plate_numbers
			where lpn_id = p_transfer_lpn_id
			and organization_id = p_organization_id;

			IF (l_debug = 1) THEN
				inv_log_util.TRACE('** p_transfer_lpn_id Not null :' || p_transfer_lpn_id, 'INV_LPN_TRX_PUB', 9);
				inv_log_util.TRACE('** Calling Pack unpack with action Pack for lpn_id :' || p_transfer_lpn_id, 'INV_LPN_TRX_PUB', 9);
				inv_log_util.TRACE('Value of subinventory_code on WLPN :' || l_wlpn_sub, 'INV_LPN_TRX_PUB', 9);
				inv_log_util.TRACE('Value of locator_id on WLPN :' || l_wlpn_loc_id, 'INV_LPN_TRX_PUB', 9);
				inv_log_util.TRACE('Value of p_subinventory_code:' || p_subinventory_code, 'INV_LPN_TRX_PUB', 9);
				inv_log_util.TRACE('Value of p_locator_id       :' || p_locator_id, 'INV_LPN_TRX_PUB', 9);
			END IF;

            Call_Pack_Unpack (
            p_tempid           => p_transaction_temp_id
          , p_content_lpn      => p_content_lpn_id
          , p_lpn              => p_transfer_lpn_id
          , p_item_rec         => l_item_rec
          , p_revision         => p_revision
          , p_primary_qty      => ABS(l_primary_quantity)
          , p_qty              => ABS(l_transaction_quantity)
          , p_uom              => p_transaction_uom
          , p_org_id           => p_organization_id
          , p_subinv           => NVL(l_wlpn_sub, p_subinventory_code) --BUG13578531
          , p_locator          => NVL(l_wlpn_loc_id, p_locator_id) --BUG13578531
          , p_operation        => g_pack
          , p_cost_grp_id      => p_cost_group_id
          , p_trx_action       => p_transaction_action_id
          , p_source_header_id => NULL
          , p_source_name      => NULL
          , p_source_type_id   => NULL
          , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
          , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
          , p_source_trx_id    => p_source_transaction_id
          );
         END IF;
		--12714013 End

        END IF;
      /***** RECEIPT/LotSplit/LotMerge/Cycle/PhysicalCount/IntransitRcpt trx ****/
      ELSIF (p_transaction_action_id = inv_globals.g_action_receipt)
            OR(p_transaction_action_id = inv_globals.g_action_inv_lot_split)
            OR((p_transaction_action_id = inv_globals.g_action_inv_lot_translate)
               AND(l_primary_quantity > 0))
            OR(p_transaction_action_id = inv_globals.g_action_inv_lot_merge)
            OR(p_transaction_action_id = inv_globals.g_action_intransitreceipt)
            OR(p_transaction_action_id = inv_globals.g_action_assycomplete)
            OR((p_transaction_action_id = inv_globals.g_action_cyclecountadj)
               AND l_primary_quantity > 0)
            OR((p_transaction_action_id = inv_globals.g_action_physicalcountadj)
               AND l_primary_quantity > 0)
            OR(p_transaction_action_id = inv_globals.g_action_logicalreceipt)
                                                                             -- IDS: Logical Transactions for lot serial support
                                                                             -- IDS: Logical Transactions for lot and serials - Opened up TM to
                                                                             --  handle logical receipts and logical corrections.
      THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = Receipt', 'INV_LPN_TRX_PUB', 9);
        END IF;
		--BUG13656377 begin
		IF(p_transaction_action_id = inv_globals.g_action_assycomplete
			AND p_transaction_source_type_id = inv_globals.G_SOURCETYPE_WIP
			AND (p_content_lpn_id IS NOT NULL OR p_lpn_id = p_transfer_lpn_id))THEN

			IF (l_debug = 1) THEN
			inv_log_util.TRACE('It is WIP LPN completion and content LPN is not null or txfer LPN equals LPN id', 'INV_LPN_TRX_PUB', 9);
			inv_log_util.TRACE('Updating WLC to make source_type_id null', 'INV_LPN_TRX_PUB', 9);
			END IF;

				UPDATE wms_lpn_contents
                 SET source_type_id = NULL
                WHERE parent_lpn_id = NVL(p_content_lpn_id, p_lpn_id);
		END IF;
		--BUG13656377 end
        -- Check if a receipt with PO or RMA source types check to see if it is a correction
        IF (
            p_transaction_action_id = inv_globals.g_action_receipt
            AND(
                p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
                OR p_transaction_source_type_id = inv_globals.g_sourcetype_rma
               )
           )
           OR(
              p_transaction_action_id = inv_globals.g_action_logicalreceipt
              AND p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
             )
              --  IDS:Logical Transaction lot serial support
              -- IDS: Logical Transactions for lot and serials - Opened up TM to
              --  handle logical receipts and logical corrections.
        THEN
          BEGIN
            SELECT transaction_type
              INTO l_rcv_txn_type
              FROM rcv_transactions
             WHERE transaction_id = p_rcv_transaction_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_rcv_txn_type  := NULL;
          END;
        END IF;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Got l_rcv_txn_typ=' || l_rcv_txn_type, 'INV_LPN_TRX_PUB', 9);
        END IF;

        -- If receipt is a correction, then special logic is needed
        -- otherwise use default behavior
        IF (
            (
             (
              p_transaction_action_id = inv_globals.g_action_receipt
              AND(
                  p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
                  OR p_transaction_source_type_id = inv_globals.g_sourcetype_rma
                 )
             )
             OR(
                p_transaction_action_id = inv_globals.g_action_logicalreceipt
                AND p_transaction_source_type_id = inv_globals.g_sourcetype_purchaseorder
               )
            )
            -- IDS: Logical Transactions for lot and serials - Opened up TM to
            --  handle logical receipts and logical corrections.
            AND l_rcv_txn_type = 'CORRECT'
           ) THEN
          -- Unpack items from lpn with null source name and trx action id
          Call_Pack_Unpack (
            p_tempid           => p_transaction_temp_id
          , p_content_lpn      => p_content_lpn_id
          , p_lpn              => p_lpn_id
          , p_item_rec         => l_item_rec
          , p_revision         => p_revision
          , p_primary_qty      => ABS(l_primary_quantity)
          , p_qty              => ABS(l_transaction_quantity)
          , p_uom              => p_transaction_uom
          , p_org_id           => p_organization_id
          , p_subinv           => p_subinventory_code
          , p_locator          => p_locator_id
          , p_operation        => g_unpack
          , p_cost_grp_id      => p_cost_group_id
          , p_trx_action       => p_transaction_action_id
          , p_source_header_id => NULL
          , p_source_name      => NULL
          , p_source_type_id   => p_transaction_source_type_id
          , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
          , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
          , p_source_trx_id    => p_source_transaction_id
          );
          -- Repack items into transfer lpn with null source name and trx action id
          Call_Pack_Unpack (
            p_tempid           => p_transaction_temp_id
          , p_content_lpn      => p_content_lpn_id
          , p_lpn              => p_transfer_lpn_id
          , p_item_rec         => l_item_rec
          , p_revision         => p_revision
          , p_primary_qty      => ABS(l_primary_quantity)
          , p_qty              => ABS(l_transaction_quantity)
          , p_uom              => p_transaction_uom
          , p_org_id           => p_organization_id
          , p_subinv           => p_subinventory_code
          , p_locator          => p_locator_id
          , p_operation        => g_pack
          , p_cost_grp_id      => p_cost_group_id
          , p_trx_action       => p_transaction_action_id
          , p_source_header_id => NULL
          , p_source_name      => NULL
          , p_source_type_id   => NULL
          , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
          , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
          , p_source_trx_id    => p_source_transaction_id
          );
        ELSE
          -- Do an unpack if (from)LPN_ID column is not null and (from)LPN_ID
          -- is not equal to Xfr_LPN_ID
          -- also need to unpack if its receipt of RMA so issue
          IF (p_lpn_id IS NOT NULL)
             AND(
                 (p_lpn_id <> NVL(p_transfer_lpn_id, 0))
                 OR
                   /*added for 3158847*/
                 (  l_item_rec.serial_number_control_code = 6
                    AND p_transaction_action_id = 27
                    AND p_transaction_source_type_id = 12)
                ) THEN
            -- Do an unpack of the item/LPN. Disregard the cost group.
            -- This is because when the item was prepacked, it could n't
            -- have had a cost group
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => p_subinventory_code
            , p_locator          => p_locator_id
            , p_operation        => g_unpack
            , p_cost_grp_id      => NULL
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => /*3158847*/NULL
            , p_source_name      => /*3158847*/NULL
            , p_source_type_id   => /*3158847*/p_transaction_source_type_id
            , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );
          END IF;

          IF (p_transfer_lpn_id IS NOT NULL)
             AND(
                 (NVL(p_lpn_id, 0) <> p_transfer_lpn_id)
                 OR
                   /*added for 3158847*/
                 (  l_item_rec.serial_number_control_code = 6
                    AND p_transaction_action_id = 27
                    AND p_transaction_source_type_id = 12)
                ) THEN
            --  Transfering to an existing LPN. need to do a pack operation here
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_transfer_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => p_organization_id
            , p_subinv           => p_subinventory_code
            , p_locator          => p_locator_id
            , p_operation        => g_pack
            , p_cost_grp_id      => p_cost_group_id
            , p_trx_action       => p_transaction_action_id
            , p_source_header_id => /*3158847*/NULL
            , p_source_name      => /*3158847*/NULL
            , p_source_type_id   => /*3158847*/p_transaction_source_type_id
            , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );
          END IF;

          -- For the case where the from_lpn_id = to_lpn_id, then need
          -- to manually update COST_GROUP_ID, as we are not calling Pack in this case
          IF (p_lpn_id = p_transfer_lpn_id) THEN

	     -- 6733277
             --for intransit shipments, update the wlc's serial summary entry to 2 if the
             --serial_control_code is 6.
             --Also null out the LPN_id and cost group  from MSN.
             IF (l_debug = 1) THEN
               inv_log_util.TRACE('p_action is:'||p_transaction_action_id ,'INV_LPN_TRX_PUB', 9);
               inv_log_util.TRACE('p_sr_Code  is:'||p_serial_control_code ,'INV_LPN_TRX_PUB', 9);
             END IF;
             IF (p_transaction_action_id = inv_globals.g_action_intransitreceipt AND
                 p_serial_control_code = 6 ) THEN
                 UPDATE wms_lpn_contents
                 SET    serial_summary_entry = 2
                 WHERE  parent_lpn_id = p_lpn_id
                 AND    organization_id = p_organization_id
                 AND    inventory_item_id = p_inventory_item_id
                 AND    serial_summary_entry <> 2 ;
             END IF;

            UPDATE wms_lpn_contents
               SET cost_group_id = p_cost_group_id
             WHERE organization_id = p_organization_id
               AND inventory_item_id = p_inventory_item_id
               AND parent_lpn_id = p_lpn_id
               AND SERIAL_SUMMARY_ENTRY=2 ;
           /* Bug 3910656- Added the last condition to the query to update only those
                           records with the serial_summary_entry as 2. */

            -- If this item is Serial controlled, set cost_group_id for Serials
           --bug# 9651496,9764650
           IF (p_transaction_action_id = inv_globals.g_action_intransitreceipt) THEN
            UPDATE mtl_serial_numbers
               SET cost_group_id = p_cost_group_id
             WHERE inventory_item_id = p_inventory_item_id
               AND lpn_id = p_lpn_id
               AND serial_number IN ( SELECT fm_serial_number
	                              FROM mtl_serial_numbers_temp
                                      WHERE transaction_temp_id = p_transaction_temp_id);
           ELSE
              UPDATE mtl_serial_numbers
               SET cost_group_id = p_cost_group_id
             WHERE inventory_item_id = p_inventory_item_id
               AND lpn_id = p_lpn_id;
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Updated WMS_Contents cost_grp_id for lpn=' || p_lpn_id || ' and cg=' || p_cost_group_id, 'INV_LPN_TRX_PUB', 9);
              END IF;
	   END IF;
 --End of bug# 9651496,9764650
          END IF;

          -- Update the status of the received LPN, or the LPN to which the item
          -- is received
          IF (p_content_lpn_id IS NOT NULL)
             OR(p_transfer_lpn_id IS NOT NULL) THEN
            IF (p_content_lpn_id IS NOT NULL) THEN
              -- If receiving a complete LPN, then check for the autoUnpack
              -- status of the subinventory to which it is received
              SELECT lpn_controlled_flag
                INTO v_autounpack
                FROM mtl_secondary_inventories
               WHERE organization_id = p_organization_id
                 AND secondary_inventory_name = p_subinventory_code;

              v_lpn.lpn_id  := p_content_lpn_id;
            ELSE
              v_lpn.lpn_id  := p_transfer_lpn_id;
            END IF;

            -- Update the LPN status and location
            SELECT lpn_context
              INTO v_lpn_ctx
              FROM wms_license_plate_numbers
             WHERE lpn_id = v_lpn.lpn_id;

            IF (v_lpn_ctx <> wms_container_pub.lpn_context_picked) THEN
              v_lpn.lpn_context  := wms_container_pub.lpn_context_inv;
            ELSE
              v_lpn.lpn_context  := wms_container_pub.lpn_context_picked;
            END IF;

            v_lpn.organization_id    := p_organization_id;
            v_lpn.subinventory_code  := p_subinventory_code;
            v_lpn.locator_id         := p_locator_id;

	    IF (l_rcv_txn_type = 'DELIVER')  THEN --Bug 8295406
	    BEGIN
	    v_lpn.source_name := FND_API.G_MISS_CHAR;
	    v_lpn.source_header_id := FND_API.G_MISS_NUM;
	    END;

	    END IF;

            update_lpn_status(v_lpn);

            -- If the autounpack is set for the receiving sub, then unpack the
            -- contents of the LPN.
            IF (v_autounpack = 2) THEN
              WMS_Container_PVT.PackUnpack_Container (
                p_api_version           => 1.0
              , p_init_msg_list         => fnd_api.g_false
              , p_commit                => fnd_api.g_false
              , p_validation_level      => fnd_api.g_valid_level_none
              , x_return_status         => ret_status
              , x_msg_count             => ret_msgcnt
              , x_msg_data              => ret_msgdata
              , p_caller                => 'INV_TRNSACTION'
              , p_lpn_id                => p_content_lpn_id
              , p_organization_id       => p_organization_id
              , p_subinventory          => p_subinventory_code
              , p_locator_id            => p_locator_id
              , p_operation             => g_unpack_all
              , p_source_transaction_id => p_source_transaction_id );

              IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('**Error Full unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;
        END IF;
      /***** Actions for SUBXFR / ORGXFR / STGXFR transactions ****/
      ELSIF (p_transaction_action_id = inv_globals.g_action_subxfr)
            OR(p_transaction_action_id = inv_globals.g_action_planxfr)
            OR(p_transaction_action_id = inv_globals.g_action_orgxfr)
            OR(p_transaction_action_id = inv_globals.g_action_stgxfr)
            OR(p_transaction_action_id = inv_globals.g_action_costgroupxfr) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = SubXfr/OrgXfr/StgXfr/CGXfr', 'INV_LPN_TRX_PUB', 9);
        END IF;

        -- sanity check. If CostGroupXfr, then both cost_group_id and
        -- xfr_cost_group_id should be filled
        IF (p_transaction_action_id = inv_globals.g_action_costgroupxfr) THEN
          IF (p_cost_group_id IS NULL)
             OR(p_transfer_cost_group_id IS NULL) THEN
            x_proc_msg  := 'Error. Cost Groups not specified. CG=' || p_cost_group_id || ',XfrCG=' || p_transfer_cost_group_id;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error. Cost Groups not specified. CG=' || p_cost_group_id || ',XfrCG=' || p_transfer_cost_group_id
              , 'INV_LPN_TRX_PUB', 1);
            END IF;

            fnd_message.set_name('INV', 'BAD_INPUT_ARGUMENTS');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- If transaction is subtransfer
        IF ( p_transaction_action_id = inv_globals.g_action_subxfr OR
             p_transaction_action_id = inv_globals.g_action_planxfr )
        THEN
          IF(p_transfer_lpn_id IS NOT NULL AND p_lpn_id IS NOT NULL) THEN
          	 IF ( v_lpn_ctx IS NULL ) THEN
          	   SELECT lpn_context
               INTO   v_lpn_ctx
               FROM   wms_license_plate_numbers
               WHERE  lpn_id = p_lpn_id;
             END IF;

             IF (l_debug = 1) THEN
               inv_log_util.TRACE('SUBXFER from LPN context=' || v_lpn_ctx, 'INV_LPN_TRX_PUB', 9);
             END IF;

             IF (v_lpn_ctx = wms_container_pub.lpn_context_picked) THEN
               split_delivery(
                 p_tempid                     => p_transaction_temp_id
               , p_lpn_id                     => p_lpn_id
               , p_xfr_lpn_id                 => p_transfer_lpn_id
               , p_item_rec                   => l_item_rec
               , p_revision                   => p_revision
               , p_qty                        => l_primary_quantity
               , p_uom                        => l_item_rec.primary_uom_code
               , p_secondary_trx_quantity     => l_secondary_trx_quantity  --INVCONV kkillams
               , p_secondary_uom_code         => p_secondary_uom_code
               , p_org_id                     => p_organization_id
               , p_subinventory_code          => p_subinventory_code
               , p_locator_id                 => p_locator_id
               , p_xfr_subinventory           => p_transfer_subinventory
               , p_xfr_to_location            => p_transfer_to_location
               , p_transaction_source_id      => p_transaction_source_id
               , p_trx_source_line_id         => p_trx_source_line_id );
             END IF;
           END IF;
         END IF;

        -- If the (from)_lpn_id is not NULL, then unpack the item/lpn from the
        -- this LPN, but only if not packing back to the same LPN,
        -- unless this is a CostGroup Transfer transaction
        IF (p_lpn_id IS NOT NULL)
           AND((p_lpn_id <> NVL(p_transfer_lpn_id, 0))
               OR(p_transaction_action_id = inv_globals.g_action_costgroupxfr)) THEN
          -- Verify that the context of this LPN is 'Resides in Inventory'
          SELECT lpn_context, subinventory_code, locator_id /*14189803 Fetching LPN Sub/Loc */
            INTO v_lpn_ctx, l_wlpn_sub, l_wlpn_loc_id
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_lpn_id;
        --14189803
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('LPN Sub:             '||l_wlpn_sub , 'INV_LPN_TRX_PUB', 1);
            inv_log_util.TRACE('LPN Loc:             '||l_wlpn_loc_id, 'INV_LPN_TRX_PUB', 1);
            inv_log_util.TRACE('p_subinventory_code: '||p_subinventory_code, 'INV_LPN_TRX_PUB', 1);
            inv_log_util.TRACE('p_locator_id:        '||p_locator_id, 'INV_LPN_TRX_PUB', 1);
          END IF;
        --14189803
          IF  (v_lpn_ctx = wms_container_pub.lpn_context_packing
			  AND p_transaction_action_id  IN (inv_globals.g_action_stgxfr,inv_globals.g_action_subxfr)) THEN --   12736705

		   IF (l_debug = 1) THEN
              inv_log_util.TRACE('LPN Packing context and transaction is staging xfer/sub xfer:' || v_lpn_ctx, 'INV_LPN_TRX_PUB', 1);
           END IF;

          ELSIF (v_lpn_ctx <> wms_container_pub.lpn_context_inv
              AND v_lpn_ctx <> wms_container_pub.lpn_context_picked

			  ) THEN
            x_proc_msg  := 'Error. Invalid LPN context for Transfer Trx:' || v_lpn_ctx;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error. Invalid LPN context for Transfer Trx:' || v_lpn_ctx, 'INV_LPN_TRX_PUB', 1);
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- An item or LPN is being unpacked from this LPN.
          Call_Pack_Unpack (
            p_tempid           => p_transaction_temp_id
          , p_content_lpn      => p_content_lpn_id
          , p_lpn              => p_lpn_id
          , p_item_rec         => l_item_rec
          , p_revision         => p_revision
          , p_primary_qty      => ABS(l_primary_quantity)
          , p_qty              => ABS(l_transaction_quantity)
          , p_uom              => p_transaction_uom
          , p_org_id           => p_organization_id
          , p_subinv           => Nvl(l_wlpn_sub, p_subinventory_code)--14189803
          , p_locator          => Nvl(l_wlpn_loc_id, p_locator_id)--14189803
          , p_operation        => g_unpack
          , p_cost_grp_id      => p_cost_group_id
          , p_trx_action       => NULL
          , p_source_header_id => NULL
          , p_source_name      => NULL
          , p_source_type_id   => NULL
          , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
          , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
          , p_source_trx_id    => p_source_transaction_id
          );

          --bug2747049
          IF (p_transaction_action_id = inv_globals.g_action_costgroupxfr) THEN
            UPDATE wms_license_plate_numbers
               SET lpn_context = v_lpn_ctx
                 , subinventory_code = p_subinventory_code
                 , locator_id = p_locator_id
             WHERE lpn_id = p_lpn_id
               AND lpn_context = wms_container_pub.lpn_context_pregenerated;
          END IF;
        END IF;

        IF (p_transaction_action_id = inv_globals.g_action_orgxfr) THEN
          v_xfr_org  := p_transfer_organization;
        ELSE
          v_xfr_org  := p_organization_id;
        END IF;

        IF (p_transaction_action_id <> inv_globals.g_action_costgroupxfr) THEN
          -- Check transfer org to see if it is wms enabled
          IF (
              wms_install.check_install(x_return_status => ret_status, x_msg_count => ret_msgcnt, x_msg_data => ret_msgdata
              , p_organization_id            => v_xfr_org)
             ) THEN
            -- Get the LPN_CONTROLLED_FLAG status of the transfer subinventory
            SELECT lpn_controlled_flag
              INTO v_autounpack
              FROM mtl_secondary_inventories
             WHERE organization_id = v_xfr_org
               AND secondary_inventory_name = p_transfer_subinventory;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE(
                'orgid=' || v_xfr_org || ' sub=' || p_transfer_subinventory || ' lpn_controlled_flag=' || v_autounpack
              , 'INV_LPN_TRX_PUB'
              , 9
              );
            END IF;
          ELSE   -- Not a WMS organization unpack all lpns
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('orgid=' || v_xfr_org || ' not wms enabled unpacking all', 'INV_LPN_TRX_PUB', 9);
            END IF;

            v_autounpack  := 2;
            -- Also need to prevent the LPN from being assigned to a non wms org
            v_xfr_org := p_organization_id;
          END IF;
        END IF;

        -- bug 2879208
        SELECT wms_task_type, reservation_id , transaction_header_id    --9869993,fetching reservation_id   -- Modified for bug 7010169
          INTO l_system_task_type , l_reservation_id, l_trx_hdr_id  -- Modified for bug 7010169
          FROM mtl_material_transactions_temp
         WHERE transaction_temp_id = p_transaction_temp_id;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('l_system_task_type = ' || l_system_task_type, 'INV_LPN_TRX_PUB', 9);
          inv_log_util.TRACE('l_reservation_id = ' || l_reservation_id , 'INV_LPN_TRX_PUB', 9);
		  inv_log_util.TRACE('l_trx_hdr_id = ' || l_trx_hdr_id, 'INV_LPN_TRX_PUB', 9);  -- Added for bug 7010169
        END IF;

        -- bug 2879208

	--Bug 6007873
	IF (p_lpn_id IS NOT NULL) THEN

	 SELECT lpn_context
            INTO l_lpn_ctx_tmp
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_lpn_id;

          -- For Sub transfers reservations should be transfered
          -- for content lpn of who's context is not picked
          IF (p_transaction_action_id = inv_globals.g_action_subxfr
              AND(l_lpn_ctx_tmp <> wms_container_pub.lpn_context_picked
              AND ((NVL(l_system_task_type, -1) <> 7) AND (NVL(l_system_task_type, -1) <> 5))) -- Added for Bug 14741165
              AND l_reservation_id IS NULL --9869993
             ) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Sub Xfer of LPN, calling Transfer_LPN_Reservations ', 'INV_LPN_TRX_PUB', 9);
            END IF;

          IF p_transfer_lpn_id = p_lpn_id THEN  --For bug 14778937
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('p_transfer_lpn_id = p_lpn_id ', 'INV_LPN_TRX_PUB', 9);
            END IF;
            inv_lpn_reservations_pvt.transfer_lpn_reservations(
              x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , p_organization_id            => p_organization_id
            , p_lpn_id                     => p_lpn_id
            , p_to_subinventory_code       => p_transfer_subinventory
            , p_to_locator_id              => p_transfer_to_location
			      , p_system_task_type           => l_system_task_type  --9794776
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Undefined error in calling Transfer_LPN_Reservations', 'INV_LPN_TRX_PUB', 1);
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Done with call to Transfer_LPN_Reservations', 'INV_LPN_TRX_PUB', 9);
            END IF;
          ELSE --p_transfer_lpn_id <> p_lpn_id  For bug 14778937
             IF (l_debug = 1) THEN
		          inv_log_util.TRACE('transfer_reserved_lpn_contents p_lpn_id :' || p_lpn_id, 'INV_LPN_TRX_PUB', 1);
		          inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_lpn_id :' || p_transfer_lpn_id, 'INV_LPN_TRX_PUB', 1);
		          inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_subinventory :' || p_transfer_subinventory, 'INV_LPN_TRX_PUB', 1);
		          inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_to_location :' ||p_transfer_to_location , 'INV_LPN_TRX_PUB', 1);
		          inv_log_util.TRACE('transfer_reserved_lpn_contents p_inventory_item_id :' || p_inventory_item_id , 'INV_LPN_TRX_PUB', 1);
	           END IF;

		        inv_lpn_reservations_pvt.transfer_reserved_lpn_contents(
		          x_return_status              => ret_status
		        , x_msg_count                  => ret_msgcnt
		        , x_msg_data                   => ret_msgdata
		        , p_organization_id            => p_organization_id
                       , p_inventory_item_id          => p_inventory_item_id
		        , p_lpn_id                     => p_lpn_id
		        , p_transfer_lpn_id            => p_transfer_lpn_id
		        , p_to_subinventory_code       => p_transfer_subinventory
		        , p_to_locator_id              => p_transfer_to_location
		        , p_system_task_type           => l_system_task_type

		        );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Undefined error in calling transfer_reserved_lpn_contents', 'INV_LPN_TRX_PUB', 1);
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Done with call to transfer_reserved_lpn_contents', 'INV_LPN_TRX_PUB', 9);
            END IF;
          END IF; --end transfer_lpn_id = p_lpn_id  For bug 14778937
          END IF;
	END IF;
	 -- bug 6007873

        -- Is this is a transfer of a complete LPN
        IF (p_content_lpn_id IS NOT NULL) THEN
          -- Update the LPN status and location
          SELECT lpn_context
            INTO v_cnt_lpn_ctx
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_content_lpn_id;


	   -- Bug 6733277 :Update WLC's serial_summary entry to 2 is serial control is 6 and transaction in intransit receipt
           IF (p_transaction_action_id = inv_globals.g_action_intransitreceipt  AND p_serial_control_code = 6 ) THEN
              UPDATE wms_lpn_contents
              SET serial_summary_entry = 2
              WHERE parent_lpn_id = p_content_lpn_id
              AND organization_id = p_organization_id
              AND inventory_item_id = p_inventory_item_id
              AND serial_summary_entry <> 2;
           END IF;

          -- For Sub transfers reservations should be transfered
          -- for content lpn of who's context is not picked
          IF (
              p_transaction_action_id = inv_globals.g_action_subxfr
              AND(v_cnt_lpn_ctx <> wms_container_pub.lpn_context_picked
                  AND NVL(l_system_task_type, -1) <> 7)
              AND l_reservation_id IS NULL --9869993
             )   -- bug 2879208 added nv for 3240617
              THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Sub Xfer of LPN, calling Transfer_LPN_Reservations', 'INV_LPN_TRX_PUB', 9);
            END IF;

         /*Added for Bug#6043776*/
            l_cyclpn_id:=p_content_lpn_id;
                /*if the transaction is cyclecount use outer LPN to update reservations*/
                IF(p_transaction_source_type_id=inv_globals.G_SOURCETYPE_CYCLECOUNT) THEN
                  IF (l_debug = 1) THEN
                        inv_log_util.TRACE('entered here cyclecount.. ','INV_LPN_TRX_PUB', 9);
                  END IF;
                  SELECT OUTERMOST_LPN_ID into l_cyclpn_id
                  from wms_license_plate_numbers
                  where lpn_id=p_content_lpn_id;
                END IF;
            /*End of Bug#6043776*/

            inv_lpn_reservations_pvt.transfer_lpn_reservations(
              x_return_status              => ret_status
            , x_msg_count                  => ret_msgcnt
            , x_msg_data                   => ret_msgdata
            , p_organization_id            => p_organization_id
--          , p_lpn_id                     => p_content_lpn_id    commented for Bug 6043776
            , p_lpn_id                     => l_cyclpn_id --Bug # 6043776
            , p_to_subinventory_code       => p_transfer_subinventory
            , p_to_locator_id              => p_transfer_to_location
			, p_system_task_type           => l_system_task_type  --9794776
            );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Undefined error in calling Transfer_LPN_Reservations', 'INV_LPN_TRX_PUB', 1);
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Done with call to Transfer_LPN_Reservations', 'INV_LPN_TRX_PUB', 9);
            END IF;
          END IF;

          /*if ( v_lpn_ctx <> WMS_Container_PUB.LPN_CONTEXT_PICKED ) then
            v_lpn.lpn_context := WMS_Container_PUB.LPN_CONTEXT_INV;
          else
            v_lpn.lpn_context := WMS_Container_PUB.LPN_CONTEXT_PICKED;
          end if;
          */
          v_lpn.lpn_id           := p_content_lpn_id;
          v_lpn.organization_id  := v_xfr_org;

          --v_lpn.SUBINVENTORY_CODE := p_transfer_subinventory;
          --v_lpn.LOCATOR_ID := p_transfer_to_location;
          --UPDATE_LPN_STATUS(v_lpn);

          -- If the autounpack is set for the transfer sub, then unpack the
          -- contents of the LPN.
          IF (v_autounpack = 2) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('**Calling fullunpack lpn:' || p_content_lpn_id, 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- bug 5531237 LPN org has not changed yet need to use original org not xfer org
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , p_commit                => fnd_api.g_false
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_return_status         => ret_status
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_content_lpn_id
            , p_organization_id       => p_organization_id
            , p_subinventory          => NULL
            , p_locator_id            => NULL
            , p_operation             => g_unpack_all
            , p_source_transaction_id => p_source_transaction_id );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('**Error Full unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            IF ( l_system_task_type = 7 AND
                 v_cnt_lpn_ctx = wms_container_pub.lpn_loaded_in_stage )
            THEN
              -- Bug 4247497 Staging Move. Context should be changed to pick
              v_lpn.lpn_context  := wms_container_pub.lpn_context_picked;
            ELSIF (v_cnt_lpn_ctx <> wms_container_pub.lpn_context_picked) THEN
              v_lpn.lpn_context  := wms_container_pub.lpn_context_inv;
            ELSE
	      --Bug 5509764
	      --For direct org transfer against an internal req, set the lpn_context
              --to "In Inventory" from Picked to reflect the correct status
              IF ( p_transaction_source_type_id = inv_globals.G_SOURCETYPE_INTORDER AND
                   p_transaction_action_id IN (inv_globals.G_ACTION_ORGXFR,inv_globals.G_ACTION_SUBXFR) --8395505.Added SUBXFR
                 ) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.trace('int req direct org/sub xfr. setting lpn_ctxt to in inventory','INV_LPN_TRX_PUB',1);
                END IF;
                v_lpn.lpn_context := wms_container_pub.lpn_context_inv;
	      ELSE
                v_lpn.lpn_context  := wms_container_pub.lpn_context_picked;
              END IF; --END IF check txn_source_type intorder and action direct org xfr
            END IF; --END IF LPN context is picked

            v_lpn.subinventory_code  := p_transfer_subinventory;
            v_lpn.locator_id         := p_transfer_to_location;
          END IF;

          -- Bug 4247497 Moving update of context to TM. If this is a stagexfr transaction
          -- then lpn-context should be updated to 'picked'
          IF ( p_transaction_action_id = inv_globals.G_ACTION_STGXFR ) THEN
            v_lpn.lpn_context := wms_container_pub.LPN_CONTEXT_PICKED;
          END IF;

          /** moved update here to fix bug3299521, this way we would avoid updating
              the parent_lpn context for unpacked inner lpns**/
          update_lpn_status(v_lpn);
        END IF;

        -- If the transfer_lpn_id is not NULL, then pack the item/LPN to
        -- this LPN, but only if not unpacked from the same LPN,
        -- unless this is a CostGroup Transfer transaction
        IF (p_transfer_lpn_id IS NOT NULL)
           AND((NVL(p_lpn_id, 0) <> p_transfer_lpn_id)
               OR(p_transaction_action_id = inv_globals.g_action_costgroupxfr)) THEN
          SELECT lpn_context
            INTO v_xfrlpn_ctx
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_transfer_lpn_id;

          -- If the item/lpn is transfered to another LPN, then update the
          -- status of that LPN, provided the context is 2, 3, or 8
          -- and xfr sub is not non-LPN controlled sub
          IF (
              (v_xfrlpn_ctx = wms_container_pub.lpn_context_wip)
              OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_rcv)
              OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_packing)
              OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_pregenerated)
             )
             AND(v_autounpack <> 2) THEN
            -- If context is pre-generated, then inherit the context of the contentLPN or fromLPN
            --  if that context is INV or PICKED
            IF (v_xfrlpn_ctx = wms_container_pub.lpn_context_pregenerated)
               AND NVL(v_cnt_lpn_ctx, v_lpn_ctx) NOT IN
                    (
                     wms_container_pub.lpn_context_wip
                   , wms_container_pub.lpn_context_rcv
                   , wms_container_pub.lpn_context_packing
                   , wms_container_pub.lpn_context_vendor
                    ) THEN
              v_lpn.lpn_context  := NVL(v_cnt_lpn_ctx, v_lpn_ctx);

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Changing context of xfrlpn cntlpnctx=' || v_cnt_lpn_ctx || ' lpnctx=' || v_lpn_ctx, 'INV_LPN_TRX_PUB'
                , 9);
              END IF;
            ELSE
              -- Bug 4247497 Moving update of context to TM
              IF ( p_transaction_action_id = inv_globals.g_action_stgxfr ) THEN
                v_lpn.lpn_context := wms_container_pub.lpn_context_picked;
              ELSE
                v_lpn.lpn_context := wms_container_pub.lpn_context_inv;
              END IF;
            END IF;

            v_lpn.lpn_id             := p_transfer_lpn_id;
            v_lpn.organization_id    := v_xfr_org;
            v_lpn.subinventory_code  := p_transfer_subinventory;
            v_lpn.locator_id         := p_transfer_to_location;
	    v_xfrlpn_ctx             := v_lpn.lpn_context;  --BUG13810580
            update_lpn_status(v_lpn);
          ELSIF(
                v_xfrlpn_ctx <> wms_container_pub.lpn_context_inv
                AND v_xfrlpn_ctx <> wms_container_pub.lpn_context_picked
                AND v_xfrlpn_ctx <> wms_container_pub.lpn_context_pregenerated
                AND v_xfrlpn_ctx <> wms_container_pub.lpn_context_packing /*added for 3160462*/
               ) THEN
            -- Verify that the context of this LPN is 'Resides in Inventory'
            x_proc_msg  := 'Error. Invalid LPN context for XFR_LPN:' || v_xfrlpn_ctx;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error. Invalid LPN context for XFR_LPN :' || v_xfrlpn_ctx, 'INV_LPN_TRX_PUB', 1);
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

  	        IF (l_debug = 1) THEN
		    inv_log_util.TRACE(' p_lpn_id :' || p_lpn_id, 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE(' p_transfer_lpn_id :' || p_transfer_lpn_id, 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE(' v_xfrlpn_ctx      :' || v_xfrlpn_ctx, 'INV_LPN_TRX_PUB', 1);
		END IF;
          -- For CostGroupTransfer transactions, use the xfr_cost_group_id
          -- column from MMTT. For all other transactions, use the cost_group_id
          -- For CostGrpTrx, sub and location are same as that of source side.
          IF (p_transaction_action_id = inv_globals.g_action_costgroupxfr) THEN
            l_xfr_sub  := p_subinventory_code;
            l_xfr_loc  := p_locator_id;
          ELSE
            l_xfr_sub  := p_transfer_subinventory;
            l_xfr_loc  := p_transfer_to_location;
          END IF;

          /*We should do transfer reservation only for subxfer actions*/
          IF (    p_transaction_action_id = inv_globals.g_action_subxfr
              AND l_reservation_id IS NULL --9869993
			  AND NOT(v_xfrlpn_ctx = wms_container_pub.lpn_context_picked  --BUG13810580
			  AND NVL(l_system_task_type, -1) <> 7
			  AND p_lpn_id <> p_transfer_lpn_id)
			  AND NVL(l_system_task_type, -1) <> 5 -- Added for Bug 14741165
             ) THEN --Bug7692251
	   -- ER 7307189 changes start
	    IF (l_debug = 1) THEN
		    inv_log_util.TRACE('transfer_reserved_lpn_contents p_lpn_id :' || p_lpn_id, 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_lpn_id :' || p_transfer_lpn_id, 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_subinventory :' || p_transfer_subinventory, 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE('transfer_reserved_lpn_contents p_transfer_to_location :' ||p_transfer_to_location , 'INV_LPN_TRX_PUB', 1);
		    inv_log_util.TRACE('transfer_reserved_lpn_contents p_inventory_item_id :' || p_inventory_item_id , 'INV_LPN_TRX_PUB', 1);
	    END IF;



		  inv_lpn_reservations_pvt.transfer_reserved_lpn_contents(
		    x_return_status              => ret_status
		  , x_msg_count                  => ret_msgcnt
		  , x_msg_data                   => ret_msgdata
		  , p_organization_id            => p_organization_id
                  , p_inventory_item_id          => p_inventory_item_id
		  , p_lpn_id                     => p_lpn_id
		  , p_transfer_lpn_id            => p_transfer_lpn_id
		  , p_to_subinventory_code       => p_transfer_subinventory
		  , p_to_locator_id              => p_transfer_to_location
		  , p_system_task_type           => l_system_task_type  --9794776

		  );

          IF (ret_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Undefined error in calling transfer_reserved_lpn_contents', 'INV_LPN_TRX_PUB', 1);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Done with call to transfer_reserved_lpn_contents', 'INV_LPN_TRX_PUB', 9);
          END IF;

          -- ER 7307189 changes end
         END IF;
          -- Because if the Destination Sub Inventory is not LPN controlled we would skip the call to pack_unpack....bug # 1869761
          IF (v_autounpack <> 2) THEN
            -- An item or LPN is being packed to another LPN.
            Call_Pack_Unpack (
              p_tempid           => p_transaction_temp_id
            , p_content_lpn      => p_content_lpn_id
            , p_lpn              => p_transfer_lpn_id
            , p_item_rec         => l_item_rec
            , p_revision         => p_revision
            , p_primary_qty      => ABS(l_primary_quantity)
            , p_qty              => ABS(l_transaction_quantity)
            , p_uom              => p_transaction_uom
            , p_org_id           => v_xfr_org
            , p_subinv           => l_xfr_sub
            , p_locator          => l_xfr_loc
            , p_operation        => g_pack
            , p_cost_grp_id      => NVL(p_transfer_cost_group_id, p_cost_group_id)
            , p_trx_action       => NULL
            , p_source_header_id => NULL
            , p_source_name      => NULL
            , p_source_type_id   => NULL
            , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
            , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
            , p_source_trx_id    => p_source_transaction_id
            );
          ELSIF(v_xfrlpn_ctx = wms_container_pub.lpn_context_packing) THEN
            -- Since the transfer sub is non lpn controlled, change xfer lpn
            -- is not packed into and should become defined but not used again.

            --Bug#7010169,We need to chekc for other tasks loaded into same LPN.
		    SELECT count(transaction_temp_id)
			  INTO l_loaded_tasks_count
			  FROM mtl_material_transactions_temp mmtt
			 WHERE transfer_lpn_id = p_transfer_lpn_id
			   AND transaction_header_id <> l_trx_hdr_id ;

            IF (l_debug = 1) THEN
				inv_log_util.TRACE('Count of other tasks loaded to this LPN='||l_loaded_tasks_count,'INV_LPN_TRX_PUB', 5);
            END IF;

			IF (l_loaded_tasks_count = 0 ) THEN

				v_lpn.organization_id  := v_xfr_org;
				v_lpn.lpn_id           := p_transfer_lpn_id;
				v_lpn.lpn_context      := wms_container_pub.lpn_context_pregenerated;
				update_lpn_status(v_lpn);
            END IF;
		  END IF;
        END IF;

        -- For cases of bulk picking the lpn_id and xfr_lpn_id will be same
        -- need to change the sub and locator information to the xfer location
        IF /*(p_transaction_action_id = inv_globals.g_action_stgxfr
            AND  Removing this Condition for Bug#12595055*/
			(p_lpn_id = p_transfer_lpn_id) THEN
          SELECT lpn_context
            INTO v_xfrlpn_ctx
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_transfer_lpn_id;

					-- bug 5620764: add debug
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Got xfrlpn ctx=' || v_xfrlpn_ctx, 'INV_LPN_TRX_PUB', 5);
          END IF;

          -- If the lpn is transfered update the status of that LPN
          -- provided the context is 2, 3, or 8
          IF (p_transaction_source_type_id <> inv_globals.g_sourcetype_salesorder)
             AND(
                 (v_xfrlpn_ctx = wms_container_pub.lpn_context_wip)
                 OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_rcv)
                 OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_packing)
                 OR(v_xfrlpn_ctx = wms_container_pub.lpn_context_pregenerated)
                ) THEN
            v_lpn.lpn_context  := wms_container_pub.lpn_context_inv;
          ELSE
          	IF (p_transaction_action_id = inv_globals.g_action_stgxfr) THEN --15851366 start

                -- bug 5620764
          	-- For staging transfer transactions change context to picked
                v_lpn.lpn_context := wms_container_pub.lpn_context_picked;
               --v_lpn.lpn_context  := NULL;
               END IF; --15851366 end

            -- Verify that the context of this LPN is 'Resides in Inventory'
            IF (
                v_xfrlpn_ctx <> wms_container_pub.lpn_context_inv
                AND v_xfrlpn_ctx <> wms_container_pub.lpn_context_picked
                AND v_xfrlpn_ctx <> wms_container_pub.lpn_context_packing
               ) THEN
              x_proc_msg  := 'Error. Invalid LPN context for XFR_LPN:' || v_xfrlpn_ctx;

              IF (l_debug = 1) THEN
                inv_log_util.TRACE('Error. Invalid LPN context for XFR_LPN :' || v_xfrlpn_ctx, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Updating lpn=' || p_transfer_lpn_id || ' ctx=' || v_lpn.lpn_context || ' org=' || v_xfr_org
            , 'INV_LPN_TRX_PUB', 1);
          END IF;
--12595055 Begin
          IF (v_autounpack = 2) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('*** Added to handle non LPN control sub Calling fullunpack lpn:' || p_content_lpn_id, 'INV_LPN_TRX_PUB', 9);
            END IF;

            -- bug 5531237 LPN org has not changed yet need to use original org not xfer org
            WMS_Container_PVT.PackUnpack_Container (
              p_api_version           => 1.0
            , p_init_msg_list         => fnd_api.g_false
            , p_commit                => fnd_api.g_false
            , p_validation_level      => fnd_api.g_valid_level_none
            , x_return_status         => ret_status
            , x_msg_count             => ret_msgcnt
            , x_msg_data              => ret_msgdata
            , p_caller                => 'INV_TRNSACTION'
            , p_lpn_id                => p_lpn_id
            , p_organization_id       => p_organization_id
            , p_subinventory          => NULL
            , p_locator_id            => NULL
            , p_operation             => g_unpack_all
            , p_source_transaction_id => p_source_transaction_id );

            IF (ret_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                inv_log_util.TRACE('****Error Full unpack :' || ret_status, 'INV_LPN_TRX_PUB', 1);
              END IF;

              fnd_message.set_name('INV', 'INV_PACKUNPACK_FAILURE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('*** Coming to else portion ie LPN controlled sub' || p_content_lpn_id, 'INV_LPN_TRX_PUB', 9);
            END IF;
          v_lpn.lpn_id             := p_transfer_lpn_id;
          v_lpn.organization_id    := v_xfr_org;
          v_lpn.subinventory_code  := p_transfer_subinventory;
          v_lpn.locator_id         := p_transfer_to_location;
          update_lpn_status(v_lpn);

          END IF;
--12595055 END
        END IF;

        -- If transaction is subtransfer
        IF ( p_transaction_action_id = inv_globals.g_action_subxfr OR
             p_transaction_action_id = inv_globals.g_action_planxfr )
        THEN
          IF (p_content_lpn_id IS NOT NULL) THEN
            SELECT lpn_context
              INTO v_cnt_lpn_ctx
              FROM wms_license_plate_numbers
             WHERE lpn_id = p_content_lpn_id;

            IF (l_debug = 1) THEN
              inv_log_util.TRACE('SUBXFER cont LPN context=' || v_cnt_lpn_ctx, 'INV_LPN_TRX_PUB', 9);
            END IF;

            IF  (v_cnt_lpn_ctx = wms_container_pub.lpn_context_picked)
              OR (NVL(l_system_task_type, -1) = 7) THEN  --Bug 3620318
              --A call to transfer the reservation is also needed if LPN is of the picked context
              --Consolidating lpn across subinventories, must transfer reservations
              inv_reservation_pvt.transfer_lpn_trx_reservation(
                x_return_status              => ret_status
              , x_msg_count                  => ret_msgcnt
              , x_msg_data                   => ret_msgdata
              , p_transaction_temp_id        => p_transaction_temp_id
              , p_organization_id            => p_organization_id
              , p_lpn_id                     => p_content_lpn_id
              , p_from_subinventory_code     => p_subinventory_code
              , p_from_locator_id            => p_locator_id
              , p_to_subinventory_code       => p_transfer_subinventory
              , p_to_locator_id              => p_transfer_to_location
              );

              IF (ret_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.TRACE('**Error from transfer_lpn_trx_reservation :' || ret_status, 'INV_LPN_TRX_PUB', 1);
                END IF;

                fnd_message.set_name('INV', 'INV_XFR_RSV_FAILURE');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;
        END IF;
      /***** Actions for PACK transactions  ****/
      ELSIF(p_transaction_action_id = inv_globals.g_action_containerpack) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = Pack', 'INV_LPN_TRX_PUB', 9);
        END IF;

        Call_Pack_Unpack (
          p_tempid           => p_transaction_temp_id
        , p_content_lpn      => p_content_lpn_id
        , p_lpn              => p_transfer_lpn_id
        , p_item_rec         => l_item_rec
        , p_revision         => p_revision
        , p_primary_qty      => ABS(l_primary_quantity)
        , p_qty              => ABS(l_transaction_quantity)
        , p_uom              => p_transaction_uom
        , p_org_id           => p_organization_id
        , p_subinv           => p_subinventory_code
        , p_locator          => p_locator_id
        , p_operation        => g_pack
        , p_cost_grp_id      => p_cost_group_id
        , p_trx_action       => NULL
        , p_source_header_id => NULL
        , p_source_name      => NULL
        , p_source_type_id   => NULL
        , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
        , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
        , p_source_trx_id    => p_source_transaction_id
        );

        -- It is possible that the LPN to which the packing is done could be in
        -- Receiving. However, after packing, the LPN has to be Inventory.
        -- Note: Since only the context of LPN is changed, directly modifying on Table
        -- instead of calling  modify_LPN API except when the context is picking
        UPDATE wms_license_plate_numbers
           SET lpn_context = wms_container_pub.lpn_context_inv
         WHERE lpn_id = p_transfer_lpn_id
           AND lpn_context <> wms_container_pub.lpn_context_picked;
      /***** Actions for UNPACK transactions  ****/
      ELSIF(p_transaction_action_id = inv_globals.g_action_containerunpack) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = UnPack', 'INV_LPN_TRX_PUB', 9);
        END IF;

        Call_Pack_Unpack (
          p_tempid           => p_transaction_temp_id
        , p_content_lpn      => p_content_lpn_id
        , p_lpn              => p_lpn_id
        , p_item_rec         => l_item_rec
        , p_revision         => p_revision
        , p_primary_qty      => ABS(l_primary_quantity)
        , p_qty              => ABS(l_transaction_quantity)
        , p_uom              => p_transaction_uom
        , p_org_id           => p_organization_id
        , p_subinv           => p_subinventory_code
        , p_locator          => p_locator_id
        , p_operation        => g_unpack
        , p_cost_grp_id      => p_cost_group_id
        , p_trx_action       => NULL
        , p_source_header_id => NULL
        , p_source_name      => NULL
        , p_source_type_id   => NULL
        , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
        , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
        , p_source_trx_id    => p_source_transaction_id
        );
      -- If LPN is item-tracked, then need to change container status. TODO

      /***** Actions for SLPIT transactions  ****/
      ELSIF(p_transaction_action_id = inv_globals.g_action_containersplit) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE(' Action = Split, First Unpack', 'INV_LPN_TRX_PUB', 9);
        END IF;

 -- Start of bug 7226314 7355087

       IF (p_transfer_lpn_id IS NOT NULL) THEN

         BEGIN

         SELECT license_plate_number,lpn_context
                           INTO l_lpn_name,l_xfrlpn_ctx
                           FROM wms_license_plate_numbers
                           WHERE organization_id = p_organization_id
                           AND (lpn_id = p_transfer_lpn_id
                           OR parent_lpn_id = p_transfer_lpn_id
                           or outermost_lpn_id = p_transfer_lpn_id)
						   AND rownum<2; --Added for bug13629931

          EXCEPTION
          WHEN No_Data_Found THEN
           IF (l_debug = 1) THEN
              inv_log_util.trace('no data found', 'INV_LPN_TRX_PUB', 9);
           END IF;
         END;

         IF(l_xfrlpn_ctx = wms_container_pub.lpn_context_pregenerated)THEN
            OPEN c_wdd_exists(p_transfer_lpn_id,p_organization_id);
	              FETCH c_wdd_exists into l_delivery_id,l_delivery_detail_id,l_status_code;
	          IF c_wdd_exists%NOTFOUND THEN
	            CLOSE c_wdd_exists;
	       ELSE
              BEGIN
                   IF(l_delivery_id IS NOT NULL AND l_status_code = 'C') THEN

                          l_container_new_name := wms_shipping_transaction_pub.get_container_name(l_lpn_name);
                          l_container_rec(1).container_name := l_container_new_name;
                          l_container_rec(1).delivery_detail_id  := l_delivery_detail_id;
                          l_container_rec(1).lpn_id              := NULL;
                          l_container_rec(1).container_flag      := 'Y';

                          wsh_container_grp.update_container(
                               p_api_version                => 1.0
                             , p_init_msg_list              => fnd_api.g_false
                             , p_commit                     => fnd_api.g_false
                             , p_validation_level           => fnd_api.g_valid_level_full
                             , x_return_status              => ret_status
                             , x_msg_count                  => ret_msgcnt
                             , x_msg_data                   => ret_msgdata
                             , p_container_rec              => l_container_rec
                                );

			        IF ret_status = fnd_api.g_ret_sts_unexp_error
		            	    OR ret_status = fnd_api.g_ret_sts_error THEN
			            RAISE fnd_api.g_exc_error;
			        END IF;
                   ELSE
                          fnd_message.set_name('WMS','WMS_INVALID_PACK_DELIVERY');
			                    fnd_msg_pub.ADD;
	                        RAISE fnd_api.g_exc_error;
                   END IF;
		          END;

        	  CLOSE c_wdd_exists;
         END IF;
        END IF;
       END IF;

       -- End of bug 7226314,7355087



        IF (p_content_lpn_id IS NULL) THEN
          SELECT lpn_context
            INTO v_lpn_ctx
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_lpn_id;

          IF (v_lpn_ctx = wms_container_pub.lpn_context_picked) THEN
            split_delivery(
              p_tempid                     => p_transaction_temp_id
            , p_lpn_id                     => p_lpn_id
            , p_xfr_lpn_id                 => p_transfer_lpn_id
            , p_item_rec                   => l_item_rec
            , p_revision                   => p_revision
            , p_qty                        => l_primary_quantity
            , p_uom                        => l_item_rec.primary_uom_code
            , p_secondary_trx_quantity     => l_secondary_trx_quantity  --INVCONV kkillams
            , p_secondary_uom_code         => p_secondary_uom_code
            , p_org_id                     => p_organization_id
            , p_subinventory_code          => p_subinventory_code
            , p_locator_id                 => p_locator_id
            , p_transaction_source_id      => p_transaction_source_id
            , p_trx_source_line_id         => p_trx_source_line_id
            );
          END IF;

          -- It is possible that the LPN to which the packing is done could be in
          -- Receiving. However, after packing, the LPN has to be Inventory.
          -- Note: Since only the context of LPN is changed, directly modifying on Table
          -- instead of calling  modify_LPN API
          SELECT lpn_context
            INTO v_xfrlpn_ctx
            FROM wms_license_plate_numbers
           WHERE lpn_id = p_transfer_lpn_id;

          -- If context is pre-generated, then inherit the context of the contentLPN or fromLPN
          -- If that context is INV or PICKED
          IF (
              v_xfrlpn_ctx = wms_container_pub.lpn_context_pregenerated
              AND v_lpn_ctx NOT IN
                   (
                    wms_container_pub.lpn_context_wip
                  , wms_container_pub.lpn_context_rcv
                  , wms_container_pub.lpn_context_packing
                  , wms_container_pub.lpn_context_vendor
                   )
             ) THEN
            v_lpn.lpn_id       := p_transfer_lpn_id;
            v_lpn.lpn_context  := v_lpn_ctx;
            update_lpn_status(v_lpn);
          END IF;
        END IF;

	 OPEN c_rtv_exists(p_lpn_id,p_organization_id); --RTV Change 16197273

	          FETCH c_rtv_exists
                  INTO  l_rtv_transaction_id;
                  CLOSE c_rtv_exists;


           IF (l_debug = 1) THEN
              inv_log_util.trace('RTV ER Split' || l_rtv_transaction_id , 'INV_LPN_TRX_PUB', 9);
           END IF;


         IF (l_rtv_transaction_id IS NOT NULL )THEN  --RTV Change 16197273

           l_source_header_id := l_rtv_transaction_id;
           l_source_name := 'RETURN TO VENDOR';

           inv_log_util.TRACE('Calling split delivery for RTV ER '|| p_transaction_temp_id, 'INV_LPN_TRX_PUB', 1);

            split_delivery(
              p_tempid                     => p_transaction_temp_id
            , p_lpn_id                     => p_lpn_id
            , p_xfr_lpn_id                 => p_transfer_lpn_id
            , p_item_rec                   => l_item_rec
            , p_revision                   => p_revision
            , p_qty                        => l_primary_quantity
            , p_uom                        => l_item_rec.primary_uom_code
            , p_secondary_trx_quantity     => l_secondary_trx_quantity  --INVCONV kkillams
            , p_secondary_uom_code         => p_secondary_uom_code
            , p_org_id                     => p_organization_id
            , p_subinventory_code          => p_subinventory_code
            , p_locator_id                 => p_locator_id
            , p_transaction_source_id      => p_transaction_source_id
            , p_trx_source_line_id         => p_trx_source_line_id
            );



         END IF ;

          IF (l_debug = 1) THEN
              inv_log_util.TRACE('RTV ER Split: l_source_header_id '|| l_source_header_id, 'INV_LPN_TRX_PUB', 1);
              inv_log_util.TRACE('RTV ER Split: l_source_name'|| l_source_name, 'INV_LPN_TRX_PUB', 1);
          END IF;


        Call_Pack_Unpack (
          p_tempid           => p_transaction_temp_id
        , p_content_lpn      => p_content_lpn_id
        , p_lpn              => p_lpn_id
        , p_item_rec         => l_item_rec
        , p_revision         => p_revision
        , p_primary_qty      => ABS(l_primary_quantity)
        , p_qty              => ABS(l_transaction_quantity)
        , p_uom              => p_transaction_uom
        , p_org_id           => p_organization_id
        , p_subinv           => p_subinventory_code
        , p_locator          => p_locator_id
        , p_operation        => g_unpack
        , p_cost_grp_id      => p_cost_group_id
        , p_trx_action       => NULL
        , p_source_header_id => l_source_header_id   --RTV Change 16197273
        , p_source_name      => l_source_name        ----RTV Change 16197273
        , p_source_type_id   => NULL
        , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
        , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
        , p_source_trx_id    => p_source_transaction_id
        );
        Call_Pack_Unpack (
          p_tempid           => p_transaction_temp_id
        , p_content_lpn      => p_content_lpn_id
        , p_lpn              => p_transfer_lpn_id
        , p_item_rec         => l_item_rec
        , p_revision         => p_revision
        , p_primary_qty      => ABS(l_primary_quantity)
        , p_qty              => ABS(l_transaction_quantity)
        , p_uom              => p_transaction_uom
        , p_org_id           => p_organization_id
        , p_subinv           => p_subinventory_code
        , p_locator          => p_locator_id
        , p_operation        => g_pack
        , p_cost_grp_id      => p_cost_group_id
        , p_trx_action       => NULL
        , p_source_header_id => l_source_header_id   --RTV Change 16197273
        , p_source_name      => l_source_name        ----RTV Change 16197273
        , p_source_type_id   => NULL
        , p_sec_qty          => abs(l_secondary_trx_quantity) --INVCONV kkillams
        , p_sec_uom          => p_secondary_uom_code --INVCONV kkillams
        , p_source_trx_id    => p_source_transaction_id
        );

        /* 8579396  :start */
      ELSIF ( p_transaction_action_id      = inv_globals.G_ACTION_ASSYRETURN AND
              p_transaction_source_type_id = inv_globals.G_SOURCETYPE_WIP AND
         NVL(p_lpn_id,-1) > 0
        ) THEN
       IF ( inv_cache.set_org_rec(p_organization_id) ) THEN
         IF ( NVL(inv_cache.org_rec.process_enabled_flag,'N') = 'Y') THEN --We will do this only for OPM

          Call_Pack_Unpack (
        p_tempid           => p_transaction_temp_id
           , p_content_lpn      => NULL
           , p_lpn              => p_lpn_id
           , p_item_rec         => l_item_rec
           , p_revision         => p_revision
           , p_primary_qty      => ABS(l_primary_quantity)
           , p_qty              => ABS(l_transaction_quantity)
           , p_uom              => p_transaction_uom
           , p_org_id           => p_organization_id
           , p_subinv           => p_subinventory_code
           , p_locator          => p_locator_id
           , p_operation        => g_unpack
           , p_cost_grp_id      => p_cost_group_id
           , p_trx_action       => p_transaction_action_id
           , p_source_header_id => NULL
           , p_source_name      => NULL
           , p_source_type_id   => p_transaction_source_type_id
           , p_sec_qty          => abs(l_secondary_trx_quantity)
           , p_sec_uom          => p_secondary_uom_code
           , p_source_trx_id    => p_source_transaction_id
      );
      IF (l_debug = 1) THEN
                 inv_log_util.TRACE('Done with unpack for OPM return transaction from LPN :'|| p_lpn_id, 'INV_LPN_TRX_PUB', 1);
                END IF;
         END IF;
       ELSE
            IF (l_debug = 1) THEN
                inv_log_util.TRACE('Error. While getting org parameters :' , 'INV_LPN_TRX_PUB', 1);
              END IF;
              RAISE fnd_api.g_exc_error;
       END IF;
          /* 8579396  :End */
      END IF;   -- end of if loop based on transaction_type
     -- Bug 2392622 removed for now cannot be updated before TM call should be done in MMT
     -- If Sales Order Issue or Int.Order Issue/SubXfr/Intransit Shipment
     -- need to popluate the content_lpn in MMTT with the outermost lpn
     -- for shipping
     /*if p_content_lpn_id is not NULL AND
      ((p_transaction_source_type_id = inv_globals.G_SourceType_SalesOrder AND
       p_transaction_action_id = inv_globals.G_Action_Issue) OR
      (p_transaction_source_type_id = inv_globals.G_SourceType_IntOrder AND
      (p_transaction_action_id = inv_globals.G_Action_Issue OR
       p_transaction_action_id =
       inv_globals.G_Action_Subxfr OR
     p_transaction_action_id = inv_globals.G_Action_Planxfr OR
     p_transaction_action_id = inv_globals.G_Action_Orgxfr OR
    p_transaction_action_id = inv_globals.G_Action_IntransitShipment))) then
     BEGIN
         UPDATE mtl_material_transactions_temp
         SET content_lpn_id = (SELECT outermost_lpn_id
                   FROM wms_license_plate_numbers
                   WHERE lpn_id = p_content_lpn_id
                   AND rownum < 2)
         WHERE transaction_temp_id = p_transaction_temp_id;
     EXCEPTION
      when others then
           IF (l_debug = 1) THEN
              inv_log_util.trace('Error updating content_lpn_id in MMTT line ttid='||p_transaction_temp_id, 'INV_LPN_TRX_PUB', 9);
           END IF;
         END;
     end if;*/
    END IF;   --lpn_id = null AND content_lpn_id = null and xfr_lpn_id = null

    -- Start 9740452

    IF (NOT inv_cache.Set_org_rec(p_organization_id => p_organization_id)) THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE(l_api_name||' : '||p_organization_id||' is an invalid organization id', 'INV_LPN_TRX_PUB', 1);
      END IF;
      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF NVL(inv_cache.org_rec.PROCESS_ENABLED_FLAG,'N') = 'Y' then

			-- Start 8379698
			SELECT transaction_type_id INTO l_transaction_type_id
			FROM mtl_material_transactions_temp
			WHERE transaction_temp_id = p_transaction_temp_id;

		  IF (l_transaction_type_id = 44 AND p_transaction_action_id = 31 AND p_transaction_source_type_id = 5) THEN
					l_business_flow_code := 26;
			ELSE
				 l_business_flow_code:= p_business_flow_code;
			END IF;
			-- End 8379698

    ELSE
			l_business_flow_code:= p_business_flow_code;
		END IF;

    -- End 9740452

    l_progress := 'Call to Label Printing API if l_business_flow_code is passed';
    IF (NVL(l_business_flow_code, 0) <> 0) THEN  -- Bug # 9740452

    -- Start of fix for Bug: 4891916
    IF (l_debug = 1) THEN
       inv_log_util.TRACE('Value of Business flow:'|| l_business_flow_code || 'l_print_label:'
                                                   || l_print_label, 'INV_LPN_TRX_PUB', 1);   -- Bug # 9740452
    END IF;
    -- Checking for the business flow and the value of the profile
    -- and setting the value of the transaction identifier accordingly.

    IF ((l_business_flow_code = 8) AND (l_print_label IN (2,3))) THEN   -- Bug # 9740452
         l_transaction_identifier:= 5;
    END IF;

    -- End of fix for Bug: 4891916

    /* Calling with the value of p_transaction_identifier as 5. In the label printing code,
       this value will indicate that the call is at the time of approving the cycle count
       entry. The value of p_transaction_identifier 4 in the label printing api indicates
       that the call is at the time of performing the cycle count entry.*/

      inv_label.print_label_wrap(
        x_return_status              => ret_status
      , x_msg_count                  => ret_msgcnt
      , x_msg_data                   => ret_msgdata
      , x_label_status               => label_status
      , p_business_flow_code         => l_business_flow_code   -- Bug # 9740452
      , p_transaction_id             => p_transaction_temp_id
      , p_transaction_identifier     => l_transaction_identifier  --Added for Bug 4891916
      );

      IF (ret_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('**Error Label Printing :' || ret_status, 'INV_LPN_TRX_PUB', 1);
        END IF;
      --RAISE FND_API.G_EXC_ERROR; Since TM should not fail, even if
      --this call fails bug#2555226
      END IF;
    END IF;

    -- Bug 2767841. Pick Drop is causing delivery lines to split.
    --  The reason is that after the content LPN is exploded, the original MMTT line
    --  is not deleted, so finalize_pick_confirm counts it with the child record so
    --  the requested quantity doubled and then causing the delivery line to split
    --  After all the LPN related txn is done, delete the original MMTT record that
    --  has inventory_item_id = -1
    IF p_inventory_item_id = -1 THEN
      IF (l_debug = 1) THEN
        inv_log_util.TRACE('* Done with process_lpn_trx_line, deleting MMTT record for tmpID=' || p_transaction_temp_id, 'INV_LPN_TRX_PUB'
        , 1);
      END IF;

      DELETE FROM mtl_serial_numbers_temp
            WHERE transaction_temp_id = (SELECT transaction_temp_id
                                           FROM mtl_material_transactions_temp
                                          WHERE transaction_temp_id = p_transaction_temp_id
                                            AND inventory_item_id = -1);

      IF SQL%ROWCOUNT = 0 THEN
        DELETE FROM mtl_serial_numbers_temp
              WHERE transaction_temp_id IN(
                                   SELECT serial_transaction_temp_id
                                     FROM mtl_transaction_lots_temp
                                    WHERE transaction_temp_id =
                                                               (SELECT transaction_temp_id
                                                                  FROM mtl_material_transactions_temp
                                                                 WHERE transaction_temp_id = p_transaction_temp_id
                                                                   AND inventory_item_id = -1));
      END IF;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('* No of MSNT records deleted =' || SQL%ROWCOUNT, 'INV_LPN_TRX_PUB', 1);
      END IF;

      DELETE FROM mtl_transaction_lots_temp
            WHERE transaction_temp_id = (SELECT transaction_temp_id
                                           FROM mtl_material_transactions_temp
                                          WHERE transaction_temp_id = p_transaction_temp_id
                                            AND inventory_item_id = -1);

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('* No of MTLT records deleted =' || SQL%ROWCOUNT, 'INV_LPN_TRX_PUB', 1);
      END IF;

      DELETE FROM mtl_material_transactions_temp
            WHERE transaction_temp_id = p_transaction_temp_id
              AND inventory_item_id = -1;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('* No. of MMTT record deleted ' || SQL%ROWCOUNT, 'INV_LPN_TRX_PUB', 1);
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_proc_msg       := fnd_msg_pub.get(fnd_msg_pub.g_previous, 'F');

      IF (l_debug = 1) THEN
        inv_log_util.TRACE(l_api_name || ' Exc err prog=' || l_progress || ' SQL err: ' || SQLERRM(SQLCODE), l_api_name, 1);
        fnd_msg_pub.count_and_get(p_count => ret_msgcnt, p_data => ret_msgdata);

        FOR i IN 1 .. ret_msgcnt LOOP
          l_msgdata  := SUBSTR(l_msgdata || ' | ' || SUBSTR(fnd_msg_pub.get(ret_msgcnt - i + 1, 'F'), 0, 200), 1, 2000);
        END LOOP;

        inv_log_util.TRACE('msg: ' || l_msgdata, l_api_name, 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_proc_msg       := fnd_msg_pub.get(fnd_msg_pub.g_previous, 'F');

      IF (l_debug = 1) THEN
        inv_log_util.TRACE(l_api_name || ' Unexp err prog=' || l_progress || ' SQL err: ' || SQLERRM(SQLCODE), l_api_name, 1);
        inv_log_util.TRACE('msg=' || x_proc_msg, l_api_name, 1);
      END IF;
  END process_lpn_trx_line;

END inv_lpn_trx_pub;

/
