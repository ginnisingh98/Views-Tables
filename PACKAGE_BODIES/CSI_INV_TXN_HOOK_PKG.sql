--------------------------------------------------------
--  DDL for Package Body CSI_INV_TXN_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_TXN_HOOK_PKG" AS
/* $Header: csiinvtb.pls 120.9 2006/06/19 17:42:17 jpwilson noship $  */

l_debug NUMBER := csi_t_gen_utility_pvt.g_debug_level;

PROCEDURE debug(
  p_message IN varchar2)
IS
BEGIN
  csi_t_gen_utility_pvt.add(p_message);
EXCEPTION
  WHEN others THEN
    null;
END debug;

PROCEDURE postTransaction(
  p_header_id       IN NUMBER,
  p_transaction_id  IN NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2)
IS
  l_api_version             NUMBER := 1.0;
  l_commit                  VARCHAR2(1) := FND_API.G_FALSE;
  l_init_msg_list           VARCHAR2(1) := FND_API.G_FALSE;
  l_validation_level        NUMBER      := FND_API.G_VALID_LEVEL_FULL;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_txn_error_id            NUMBER;
  l_trx_error_rec           CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
  l_logical_trx_attr_values INV_DROPSHIP_GLOBALS.logical_trx_attr_tbl;
  l_csi_trackable           VARCHAR2(10);
  l_file		    VARCHAR2(500);
  l_error_message           VARCHAR2(2000) :=  NULL ;
  l_trx_return_status       VARCHAR2(1) :=  NULL ;
  l_bypass                  VARCHAR2(1) :=  NULL ;
  l_error_code              NUMBER ;
  l_message_id              NUMBER;
  l_return_status           VARCHAR2(30);
  l_ds_return_status        VARCHAR2(30);
  l_xml_string              VARCHAR2(2000);
  l_type_id                 NUMBER;
  l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_csi_txn_name            csi_txn_types.source_transaction_type%type := NULL;
  l_source_type             VARCHAR2(50):= NULL;
  hook_error                EXCEPTION;
  bypass_error              EXCEPTION;
  no_mmt_rec_exists	    EXCEPTION;
  l_log_trx_action_id       NUMBER := NULL;
  l_log_trx_source_type_id  NUMBER := NULL;
  l_log_trx_type_code       NUMBER := NULL;
  l_log_trx_id              NUMBER := NULL;
  l_ds_log_trx_id           NUMBER := NULL;
  j                         PLS_INTEGER := 0;
  l_log_rec_count           NUMBER := 0;
  l_master_org_id           NUMBER;
  l_parent_org              NUMBER;

  CURSOR c_mtl_data is
    SELECT inventory_item_id,
           transaction_quantity,
           source_code,
           transaction_action_id,
           transaction_type_id,
           transaction_source_type_id,
           ship_to_location_id,
           organization_id,
	   transaction_id,
	   parent_transaction_id
    FROM mtl_material_transactions
    WHERE transaction_id = p_transaction_id;

  r_mtl_data     c_mtl_data%rowtype;

  CURSOR c_type_class (pc_transaction_type_id NUMBER) is
    SELECT type_class,
           transaction_source_type_id,
           nvl(location_required_flag,'N') location_required_flag
    FROM mtl_trx_types_view
    WHERE transaction_type_id = pc_transaction_type_id;

CURSOR c_wip_entity_type is
SELECT entity_type
FROM  wip_entities we,
      mtl_material_transactions mmt
WHERE mmt.transaction_source_id=we.wip_entity_id
AND   mmt.transaction_id=  p_transaction_id;

  r_type_class      c_type_class%rowtype;
  l_wip_entity_type  wip_entities.entity_type%type;

  CURSOR c_parent_org (pc_par_txn_id IN NUMBER) is
    SELECT organization_id
    FROM mtl_material_transactions
    WHERE transaction_id = pc_par_txn_id;

  CURSOR c_ic_shipment (pc_parent_org IN NUMBER,pc_transaction_id IN NUMBER) is
    SELECT transaction_id
    FROM mtl_material_transactions
    WHERE transaction_id = pc_transaction_id
    AND   organization_id = pc_parent_org;

BEGIN

  -- Get CSI Txn Name for Error
  l_csi_txn_name := csi_inv_trxs_pkg.get_inv_name(p_transaction_id);

  -- Initialize to Success so Oracle Inventory processing will not error
  x_return_status := l_fnd_success;

  csi_t_gen_utility_pvt.build_file_name(
    p_file_segment1 => 'csiinv',
    p_file_segment2 => 'hook');

  debug('***** start of ib hook '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')||' *****');

  -- Get all Inventory Data. Making this into a cursor so any future problems
  -- with no data found can be eliminated.

  OPEN c_mtl_data;
  FETCH c_mtl_data into r_mtl_data;
  CLOSE c_mtl_data;

  IF r_mtl_data.transaction_id IS NULL THEN
    debug('mtl_transaction_id : '||p_transaction_id || ' does not exist in mmt table');
  END IF;

  -- Get Master Org to Check If Item is Trackable
  SELECT master_organization_id
  INTO l_master_org_id
  FROM mtl_parameters
  WHERE organization_id = r_mtl_data.organization_id;

  --Check if item is CSI trackable
  IF csi_item_instance_vld_pvt.is_trackable(
                     p_inv_item_id    => r_mtl_data.inventory_item_id,
                     p_stack_err_msg  => FALSE,
                     p_org_id         => l_master_org_id) THEN
    l_csi_trackable := 'TRUE';
  ELSE
    l_csi_trackable := 'FALSE';
  END IF;

  debug('  mtl_transaction_id          : '||p_transaction_id);
  debug('  mtl_parent_transaction_id   : '||r_mtl_data.parent_transaction_id);
  debug('  mtl_txn_type_id             : '||r_mtl_data.transaction_type_id);
  debug('  mtl_txn_action_id           : '||r_mtl_data.transaction_action_id);
  debug('  mtl_txn_src_type_id         : '||r_mtl_data.transaction_source_type_id);
  debug('  inventory_item_id           : '||r_mtl_data.inventory_item_id);
  debug('  csi_transaction_name        : '||l_csi_txn_name);
  debug('  is_item_trackable           : '||l_csi_trackable);

  IF (l_csi_trackable = 'TRUE') THEN

    -- Get Type Class Code
    OPEN c_type_class(r_mtl_data.transaction_type_id);
    FETCH c_type_class into r_type_class;
    CLOSE c_type_class;

    debug('  mtl_type_class       : '||r_type_class.type_class);
    debug('  location_required_flag : '||r_type_class.location_required_flag);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_bypass := nvl(csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag,'N');

    debug('  sfm_bypass_flag      : '||l_bypass);

    IF r_mtl_data.parent_transaction_id IS NOT NULL then

      debug('  Parent Transction ID is not null so call INV API      : '||r_mtl_data.parent_transaction_id);

      inv_ds_logical_trx_info_pub.get_logical_attr_values(
        l_ds_return_status,
        l_msg_count,
        l_msg_data,
        l_logical_trx_attr_values,
        l_api_version,
        l_init_msg_list,
        p_transaction_id);

      l_log_rec_count := l_logical_trx_attr_values.count;

      debug('  ds return status     : '||l_ds_return_status);
      debug('  logical records      : '||l_log_rec_count);

      IF l_ds_return_status = l_fnd_success AND l_logical_trx_attr_values.count > 0 THEN

        -- Get the Org ID for the Parent

        OPEN c_parent_org(l_logical_trx_attr_values(1).parent_transaction_id);
        FETCH c_parent_org into l_parent_org;
        CLOSE c_parent_org;

        debug('  Parent Transaction ID Organization     : '||l_parent_org);

        FOR j in l_logical_trx_attr_values.first .. l_logical_trx_attr_values.last LOOP

          IF (l_logical_trx_attr_values(j).transaction_action_id = 7 AND
              l_logical_trx_attr_values(j).transaction_source_type_id = 2 AND
              l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

            debug('Action is 7, Source is 2 and Logical Txn Type is 2');

            l_log_trx_action_id       := l_logical_trx_attr_values(j).transaction_action_id;
            l_log_trx_source_type_id  := l_logical_trx_attr_values(j).transaction_source_type_id;
            l_log_trx_type_code       := l_logical_trx_attr_values(j).logical_trx_type_code;
            l_ds_log_trx_id           := l_logical_trx_attr_values(j).transaction_id;

            debug('Found Record for Sales Order Issue Transaction now find the I/C Shipment: '||l_logical_trx_attr_values(j).transaction_id);

            IF l_logical_trx_attr_values.count > 2 THEN

              FOR j in l_logical_trx_attr_values.first .. l_logical_trx_attr_values.last LOOP

                IF (l_logical_trx_attr_values(j).transaction_action_id = 9 AND
                    l_logical_trx_attr_values(j).transaction_source_type_id = 13 AND
                    l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

                  debug('Found Record for I/C Shipment see if this should be used for Processing: '||l_logical_trx_attr_values(j).transaction_id);

                  -- For Each I/C Shipment find the one that has the same org as the parent transaction id

                  OPEN c_ic_shipment (l_parent_org,l_logical_trx_attr_values(j).transaction_id);
                  FETCH c_ic_shipment into l_log_trx_id;
                  CLOSE c_ic_shipment;

                 IF l_log_trx_id is not null THEN
                   debug('Exiting Loop to find I/C Shipment .. Using '||l_log_trx_id||' for processing');
                   EXIT;
                 END IF;

                END IF;
              END LOOP;

            ELSIF l_logical_trx_attr_values.count = 2 THEN
              FOR j in l_logical_trx_attr_values.first .. l_logical_trx_attr_values.last LOOP

                IF (l_logical_trx_attr_values(j).transaction_action_id = 26 AND
                  l_logical_trx_attr_values(j).transaction_source_type_id = 1 AND
                  l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

                  debug('Found Record for PO Receipt this is a Regular Drop Ship but in Logical Mode');
                  debug('Get the Logical Sales Order Issue and use for Processing: '||l_ds_log_trx_id);
                  l_log_trx_id              := l_ds_log_trx_id;

                END IF;
              END LOOP;
            END IF;

          ELSIF (l_logical_trx_attr_values(j).transaction_action_id = 11 AND
              l_logical_trx_attr_values(j).transaction_source_type_id = 1 AND
              l_logical_trx_attr_values(j).logical_trx_type_code = 2) THEN

            debug('Found Record for PO Adjustment: '||l_logical_trx_attr_values(j).transaction_id);

            l_log_trx_action_id       := l_logical_trx_attr_values(j).transaction_action_id;
            l_log_trx_source_type_id  := l_logical_trx_attr_values(j).transaction_source_type_id;
            l_log_trx_type_code       := l_logical_trx_attr_values(j).logical_trx_type_code;
            l_log_trx_id              := l_logical_trx_attr_values(j).transaction_id;

          END IF;
        END LOOP;

        debug('  logical_txn_id       : '||l_log_trx_id);
        debug('  logical_action_id    : '||l_log_trx_action_id);
        debug('  logical_src_type_id  : '||l_log_trx_source_type_id);
        debug('  logical_txn_type_code: '||l_log_trx_type_code);

      END IF;
    ELSE
      debug('  Parent Transction ID is null so do not call the INV API');
    END IF;  -- parent_transaction_id check

    debug('  deciding which transaction to publish based on action and source :- ');
    -- Begin of IF statement to decide what Transaction to Publish

    IF (r_mtl_data.transaction_action_id = 1 AND
	r_mtl_data.transaction_source_type_id = 4 AND
	r_mtl_data.transaction_type_id NOT IN (33,122,35,37,93)  AND
	r_type_class.location_required_flag = 'Y' AND
       (r_type_class.type_class is null OR r_type_class.type_class <> 1)) THEN

      l_type_id     := 132;
      l_type_id     := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'ISSUE_TO_HZ_LOC'),'INV');
      l_source_type := 'CSIISUHZ';

      IF (l_bypass = 'N') THEN

        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);

        -- Issue to HZ Location
        savepoint CSIISUHZ;

        XNP_CSIISUHZ_U.publish(
          xnp$mtl_transaction_id => p_transaction_id,
          xnp$inventory_item_id => r_mtl_data.inventory_item_id,
          xnp$organization_id => r_mtl_data.organization_id,
          x_message_id    => l_message_id,        -- out parameter
          x_error_code    => l_error_code,        -- out parameter
          x_error_message => l_error_message);

        IF (l_error_message is not null) THEN
          rollback to CSIISUHZ;
          debug('Failed to publish event CSIISUHZ: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIISUHZ');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
        END IF;
      ELSE
        debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);

        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIISUHZ',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

        IF NOT l_trx_return_status = l_fnd_success THEN
          raise BYPASS_ERROR;
        END IF;
      END IF;

    ELSIF (r_mtl_data.transaction_action_id = 27 AND
	   r_mtl_data.transaction_source_type_id in (13,6,3) AND
	   r_mtl_data.transaction_type_id NOT IN (15,123,43,94) AND
	   r_type_class.location_required_flag = 'Y' AND
	  (r_type_class.type_class is null OR r_type_class.type_class <> 1)) THEN


     l_type_id := 134;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_RECEIPT_HZ_LOC'),'INV');
     l_source_type := 'CSIMSRHZ';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Misc Receipt from HZ Location

      savepoint CSIMSRHZ;

      XNP_CSIMSRHZ_U.publish(
                   xnp$mtl_transaction_id => p_transaction_id,
                   xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                   xnp$organization_id => r_mtl_data.organization_id,
                   x_message_id => l_message_id,        -- out parameter
                   x_error_code => l_error_code,        -- out parameter
                   x_error_message => l_error_message   -- out parameter
                  );

      if (l_error_message is not null) then
         rollback to CSIMSRHZ;
         debug('Failed to publish event CSIMSRHZ: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIMSRHZ');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
      end if;
    ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
      CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSRHZ',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;
    END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
	 r_mtl_data.transaction_source_type_id in (13,6,3) AND
	 r_mtl_data.transaction_type_id NOT IN (33,122,35,37,93)  AND
	 r_type_class.location_required_flag = 'Y' AND
	(r_type_class.type_class is null OR r_type_class.type_class <> 1))THEN

     l_type_id := 133;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_ISSUE_HZ_LOC'),'INV');
     l_source_type := 'CSIMSIHZ';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Misc Receipt from HZ Location

      savepoint CSIMSIHZ;

      XNP_CSIMSIHZ_U.publish(
                   xnp$mtl_transaction_id => p_transaction_id,
                   xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                   xnp$organization_id => r_mtl_data.organization_id,
                   x_message_id => l_message_id,        -- out parameter
                   x_error_code => l_error_code,        -- out parameter
                   x_error_message => l_error_message   -- out parameter
                  );

      if (l_error_message is not null) then
         rollback to CSIMSIHZ;
         debug('Failed to publish event CSIMSIHZ: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIMSIHZ');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
      end if;
    ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
      CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSIHZ',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;
    END IF;

  ELSIF (l_log_trx_action_id  = 7 AND
         l_log_trx_source_type_id = 2 AND
         l_log_trx_id IS NOT NULL)
  THEN
	---Transactions fall in this category are :
	---  Type                          Action ID     Txn Type ID
	-----------------------          -------------   ------------
	--1. Logical Sales Order Issue        7              30

    l_type_id := 51;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'OM_SHIPMENT'),'ONT');
    l_source_type := 'CSILOSHP';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||l_log_trx_id);
       debug('Transaction ID used to get data 2,7: '||p_transaction_id);
        -- Logical Sales Order Issue

        savepoint CSILOSHP;

        XNP_CSILOSHP_U.publish(
                     xnp$mtl_transaction_id => l_log_trx_id,
                     xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                     xnp$organization_id => r_mtl_data.organization_id,
                     x_message_id => l_message_id,        -- out parameter
                     x_error_code => l_error_code,        -- out parameter
                     x_error_message => l_error_message   -- out parameter
                     );

         if (l_error_message is not null) then
            rollback to CSILOSHP;
            debug('Failed to publish event CSILOSHP: ' || l_error_message);
            fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
            fnd_message.set_token('EVENT','CSILOSHP');
            fnd_message.set_token('ERROR_MESSAGE',l_error_message);
            l_error_message := fnd_message.get;
            raise HOOK_ERROR;
         end if;
      ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||l_log_trx_id);
        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSILOSHP',
                                            l_log_trx_id,
                                            l_trx_return_status,
                                            l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;


  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 4 AND
         r_type_class.type_class = 1) -- Issue to Project
  THEN
     l_type_id := 113;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MOVE_ORDER_ISSUE_TO_PROJECT'),'INV');
     l_source_type := 'CSIISUPT';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Issue to Project Move Order

      savepoint CSIISUPT;

      XNP_CSIISUPT_U.publish(
                   xnp$mtl_transaction_id => p_transaction_id,
                   xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                   xnp$organization_id => r_mtl_data.organization_id,
                   x_message_id => l_message_id,        -- out parameter
                   x_error_code => l_error_code,        -- out parameter
                   x_error_message => l_error_message   -- out parameter
                  );

      if (l_error_message is not null) then
         rollback to CSIISUPT;
         debug('Failed to publish event CSIISUPT: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIISUPT');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
      end if;
    ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
      CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIISUPT',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND  -- Misc. Issue to Project
										 -- Acct/Acct Alias, Inv
         r_mtl_data.transaction_source_type_id in (3,6,13) AND
         r_type_class.type_class = 1)
  THEN
     l_type_id := 121;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_ISSUE_TO_PROJECT'),'INV');
     l_source_type := 'CSIMSIPT';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Miscellaneous Issue to Project

      savepoint CSIMSIPT;

      XNP_CSIMSIPT_U.publish(
                   xnp$mtl_transaction_id => p_transaction_id,
                   xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                   xnp$organization_id => r_mtl_data.organization_id,
                   x_message_id => l_message_id,        -- out parameter
                   x_error_code => l_error_code,        -- out parameter
                   x_error_message => l_error_message   -- out parameter
                  );

      if (l_error_message is not null) then
         rollback to CSIMSIPT;
         debug('Failed to publish event CSIMSIPT: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIMSIPT');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
      end if;
    ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
      CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSIPT',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

   ELSIF (r_mtl_data.transaction_action_id = 27 AND
          r_mtl_data.transaction_source_type_id in (3,6,13) AND
          r_type_class.type_class = 1)  -- Misc Receipt from Project
							     -- Acct/Acct Alias, Inv
   THEN
     l_type_id := 120;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_RECEIPT_FROM_PROJECT'),'INV');
     l_source_type := 'CSIMSRPT';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- Miscellaneous Receipt from Project/Task

       savepoint CSIMSRPT;

       XNP_CSIMSRPT_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIMSRPT;
          debug('Failed to publish event CSIMSRPT: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIMSRPT');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSRPT',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 16)

  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Project Contract Issue   	  1              77

    l_type_id := 326;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'PROJECT_CONTRACT_SHIPMENT'),'OKE');
     l_source_type := 'CSIOKSHP';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
        -- Project Contract Issues

        savepoint CSIOKSHP;

        XNP_CSIOKSHP_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                     x_message_id => l_message_id,        -- out parameter
                     x_error_code => l_error_code,        -- out parameter
                     x_error_message => l_error_message   -- out parameter
                     );

         if (l_error_message is not null) then
            rollback to CSIOKSHP;
            debug('Failed to publish event CSIOKSHP: ' || l_error_message);
            fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
            fnd_message.set_token('EVENT','CSIOKSHP');
            fnd_message.set_token('ERROR_MESSAGE',l_error_message);
            l_error_message := fnd_message.get;
            raise HOOK_ERROR;
         end if;
      ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIOKSHP',
                                            p_transaction_id,
                                            l_trx_return_status,
                                            l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 2)
	    -- Changed to 2 from Txn Type ID 33
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Sales Order Issue        	  1              33

    l_type_id := 51;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'OM_SHIPMENT'),'ONT');
     l_source_type := 'CSISOSHP';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
        -- Sales Order Shipments

        savepoint CSISOSHP;

        XNP_CSISOSHP_U.publish(
                     xnp$mtl_transaction_id => p_transaction_id,
                     xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                     xnp$organization_id => r_mtl_data.organization_id,
                     x_message_id => l_message_id,        -- out parameter
                     x_error_code => l_error_code,        -- out parameter
                     x_error_message => l_error_message   -- out parameter
                     );

         if (l_error_message is not null) then
            rollback to CSISOSHP;
            debug('Failed to publish event CSISOSHP: ' || l_error_message);
            fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
            fnd_message.set_token('EVENT','CSISOSHP');
            fnd_message.set_token('ERROR_MESSAGE',l_error_message);
            l_error_message := fnd_message.get;
            raise HOOK_ERROR;
         end if;
      ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSISOSHP',
                                            p_transaction_id,
                                            l_trx_return_status,
                                            l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

  ELSIF (r_mtl_data.transaction_action_id = 1 AND
         r_mtl_data.transaction_source_type_id = 8)
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Intrnl Ord Issue(Ship Conf)  1              34

    l_type_id := 126;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'ISO_ISSUE'),'ONT');
     l_source_type := 'CSIINTIS';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
        -- Internal Order Issue

        savepoint CSIINTIS;

        XNP_CSIINTIS_U.publish(
                     xnp$mtl_transaction_id => p_transaction_id,
                     xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                     xnp$organization_id => r_mtl_data.organization_id,
                     x_message_id => l_message_id,        -- out parameter
                     x_error_code => l_error_code,        -- out parameter
                     x_error_message => l_error_message   -- out parameter
                     );

         if (l_error_message is not null) then
            rollback to CSIINTIS;
            debug('Failed to publish event CSIINTIS: ' || l_error_message);
            fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
            fnd_message.set_token('EVENT','CSIINTIS');
            fnd_message.set_token('ERROR_MESSAGE',l_error_message);
            l_error_message := fnd_message.get;
            raise HOOK_ERROR;
         end if;
      ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIINTIS',
                                            p_transaction_id,
                                            l_trx_return_status,
                                            l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

  ELSIF (r_mtl_data.transaction_action_id = 27 AND
         r_mtl_data.transaction_source_type_id = 12)
	     -- Changed to 12 from Txn Type ID 15
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. RMA Receipt              	  27             15

    l_type_id := 53;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'RMA_SHIPMENT'),'ONT');
     l_source_type := 'CSIRMARC';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
        -- Return Material Authorization

        savepoint CSIRMARC;

        XNP_CSIRMARC_U.publish(
                     xnp$mtl_transaction_id => p_transaction_id,
                     xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                     xnp$organization_id => r_mtl_data.organization_id,
                     x_message_id => l_message_id,        -- out parameter
                     x_error_code => l_error_code,        -- out parameter
                     x_error_message => l_error_message   -- out parameter
                    );

        if (l_error_message is not null) then
           rollback to CSIRMARC;
           debug('Failed to publish event CSIRMARC: ' || l_error_message);
           fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
           fnd_message.set_token('EVENT','CSIRMARC');
           fnd_message.set_token('ERROR_MESSAGE',l_error_message);
           l_error_message := fnd_message.get;
           raise HOOK_ERROR;
        end if;
      ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
        CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIRMARC',
                                            p_transaction_id,
                                            l_trx_return_status,
                                            l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

  ELSIF (r_mtl_data.transaction_quantity > 0 AND    -- Subinventory Transfer
         r_mtl_data.transaction_action_id = 2)
  OR    (r_mtl_data.transaction_action_id = 28 AND  -- Sales Order Staging
         r_mtl_data.transaction_source_type_id = 2 AND
 	   -- Changed to 2 from Txn ID 52
         r_mtl_data.transaction_quantity > 0)
  OR    (r_mtl_data.transaction_action_id = 28 AND  -- Intrnl SaleOrd Staging
         r_mtl_data.transaction_source_type_id = 8 AND
         r_mtl_data.transaction_quantity > 0)
	   -- Changed to 8 from Txn ID 53
	   -- changed this to > for bug 2384317
  THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Subinventory Transfer        2              2
	--2. Cycle Count SubInv Xfer      2              5
	--3. Physical Inv Xfer            2              9
	--4. Internal Order Xfer          2              50
	--5. Backflush Xfer               2              51
	--6. Internal Order Pick          28             53
	--7. Sales Order Pick             28             52
	--8. Move Order Transfer          2              64
	--9. Project Borrow               2              66
	--10. Project Transfer            2              67
	--11. Project Payback             2              68

    l_type_id := 114;
    l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'SUBINVENTORY_TRANSFER'),'INV');
     l_source_type := 'CSISUBTR';
    IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Subinventory Transfer and Sales Order Stanging

      savepoint CSISUBTR;

      XNP_CSISUBTR_U.publish(
                   xnp$mtl_transaction_id => p_transaction_id,
                   xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                   xnp$organization_id => r_mtl_data.organization_id,
                   x_message_id => l_message_id,        -- out parameter
                   x_error_code => l_error_code,        -- out parameter
                   x_error_message => l_error_message   -- out parameter
                  );

      if (l_error_message is not null) then
        rollback to CSISUBTR;
        debug('Failed to publish event CSISUBTR: ' || l_error_message);
        fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
        fnd_message.set_token('EVENT','CSISUBTR');
        fnd_message.set_token('ERROR_MESSAGE',l_error_message);
        l_error_message := fnd_message.get;
        raise HOOK_ERROR;
     end if;
    ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
      CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSISUBTR',
                                          p_transaction_id,
                                          l_trx_return_status,
                                          l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

    END IF;

    ELSIF (r_mtl_data.transaction_action_id = 12 AND  -- Interorg Receipt
            r_mtl_data.transaction_source_type_id = 13)
		  -- Changed to 13 from Txn ID 12

   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. InTransit Receipt            12             12

     l_type_id := 144;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'INTERORG_TRANS_RECEIPT'),'INV');
     l_source_type := 'CSIORGTR';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- InterOrg In Transit Receipt Transaction

       savepoint CSIORGTR;

       XNP_CSIORGTR_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIORGTR;
         debug('Failed to publish event CSIORGTR: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIORGTR');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIORGTR',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

    ELSIF (r_mtl_data.transaction_action_id = 21 AND
            r_mtl_data.transaction_source_type_id = 13)  -- Interorg Shipment
		  -- Changed to 13 from Txn ID 21

   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. InTransit Shipment           21             21

     l_type_id := 145;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'INTERORG_TRANS_SHIPMENT'),'INV');
     l_source_type := 'CSIORGTS';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- InterOrg In Transit Receipt Transaction

       savepoint CSIORGTS;

       XNP_CSIORGTS_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIORGTS;
         debug('Failed to publish event CSIORGTS: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIORGTS');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIORGTS',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF  (r_mtl_data.transaction_action_id = 3 AND  -- Direct Org Transfer
            r_mtl_data.transaction_source_type_id = 13 AND
            r_mtl_data.transaction_quantity > 0)
            -- Changed to 13 from Txn ID 3
   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Direct Org Transfer          3              3

     l_type_id := 143;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'INTERORG_DIRECT_SHIP'),'INV');
     l_source_type := 'CSIORGDS';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- InterOrg Direct Shipment Transaction

       savepoint CSIORGDS;

       XNP_CSIORGDS_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIORGDS;
         debug('Failed to publish event CSIORGDS: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIORGDS');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIORGDS',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF  (r_mtl_data.transaction_action_id = 12 AND  -- Int So In Trans Receipt
           r_mtl_data.transaction_source_type_id = 7)
   THEN
   	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Req Intr Rcpt            12             61

     l_type_id := 131;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'ISO_REQUISITION_RECEIPT'),'INV');
     l_source_type := 'CSIINTSR';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Internal Sales Order Receipt Transaction

       savepoint CSIINTSR;

       XNP_CSIINTSR_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIINTSR;
         debug('Failed to publish event CSIINTSR: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIINTSR');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIINTSR',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 21 AND  -- Int So In Trans Ship
          r_mtl_data.transaction_source_type_id = 8)

   THEN
    ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Order Intr Ship          21             62

     l_type_id := 130;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'ISO_SHIPMENT'),'INV');
     l_source_type := 'CSIINTSS';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Internal Sales Order Shipment Transaction

       savepoint CSIINTSS;

       XNP_CSIINTSS_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIINTSS;
         debug('Failed to publish event CSIINTSS: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIINTSS');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIINTSS',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF  (r_mtl_data.transaction_action_id = 3 AND -- ISO Direct Shipment
	   r_mtl_data.transaction_source_type_id in (7,8) AND
	   r_mtl_data.transaction_quantity > 0)

   THEN
        ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Int Order Direct Ship        3              54

     l_type_id := 142;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'ISO_DIRECT_SHIP'),'INV');
     l_source_type := 'CSIINTDS';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Internal Sales Order Direct Shipment Transaction

       savepoint CSIINTDS;

       XNP_CSIINTDS_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
         rollback to CSIINTDS;
         debug('Failed to publish event CSIINTDS: ' || l_error_message);
         fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
         fnd_message.set_token('EVENT','CSIINTSS');
         fnd_message.set_token('ERROR_MESSAGE',l_error_message);
         l_error_message := fnd_message.get;
         raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIINTDS',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

  ELSIF  r_mtl_data.transaction_action_id = 27 AND
         r_mtl_data.transaction_source_type_id = 1
	     -- Changed to 1 from Txn Type ID 18

        ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. PO Receipt                   27             18

  THEN
     l_type_id := 112;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'PO_RECEIPT_INTO_INVENTORY'),'INV');
     l_source_type := 'CSIPOINV';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- PO Receipt into Inventory

       savepoint CSIPOINV;

       XNP_CSIPOINV_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIPOINV;
          debug('Failed to publish event CSIPOINV: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIPOINV');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIPOINV',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF r_mtl_data.transaction_action_id = 4

    ---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Cycle Count Adjust (-/+)      4             4

   THEN
     l_type_id := 119;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'CYCLE_COUNT'),'INV');
     l_source_type := 'CSICYCNT';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Cycle Count

       savepoint CSICYCNT;

       XNP_CSICYCNT_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSICYCNT;
          debug('Failed to publish event CSICYCNT: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSICYCNT');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSICYCNT',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF r_mtl_data.transaction_action_id = 8

    ---Transactions fall in this category are :
	---  Type                     Action ID     Txn Type ID
	-----------------------     -------------   ------------
	--1. Physical Inv Adjust(-/+)      8              8

   THEN
     l_type_id := 118;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'PHYSICAL_INVENTORY'),'INV');
     l_source_type := 'CSIPHYIN';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
      -- Physical Inventory

       savepoint CSIPHYIN;

       XNP_CSIPHYIN_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIPHYIN;
          debug('Failed to publish event CSIPHYIN: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIPHYIN');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;

     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIPHYIN',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 27 AND
          r_mtl_data.transaction_source_type_id in (4,13,6,3) AND
          r_mtl_data.transaction_type_id NOT IN (15,123,43,94) AND
         (r_type_class.type_class is null OR r_type_class.type_class <> 1)) OR
         (r_mtl_data.transaction_action_id = 29 AND
          r_mtl_data.transaction_quantity > 0 AND
          r_mtl_data.transaction_source_type_id = 1) OR  -- + Int Adjustment
                                                         -- + PO Adjustment
                                                         -- + Ship Adjustment
         (l_log_trx_action_id = 11 AND
          r_mtl_data.transaction_quantity > 0 AND
          l_log_trx_source_type_id  = 1 AND
          l_log_trx_type_code = 2)  -- (+) Logical PO Adjustment
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Account Receipt              27             40
	--2. Account Alias receipt        27             41
	--3. Miscellaneous Receipt        27             42
        --4. + PO Adjustment              29             71
        --5. + Int Req Adjust             29             72
        --6. + Shipment Rcpt Adjust       29             70

     l_type_id := 117;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_RECEIPT'),'INV');
     l_source_type := 'CSIMSRCV';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- Miscellaneous Receipt

       savepoint CSIMSRCV;

       XNP_CSIMSRCV_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIMSRCV;
          debug('Failed to publish event CSIMSRCV: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIMSRCV');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;

     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSRCV',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;


   ELSIF (r_mtl_data.transaction_action_id = 1 AND
          r_mtl_data.transaction_source_type_id in (4,13,6,3) AND
          r_mtl_data.transaction_type_id NOT IN (33,122,35,37,93)  AND
          (r_type_class.type_class is null OR r_type_class.type_class <> 1)) OR
          (r_mtl_data.transaction_action_id = 29 AND
           r_mtl_data.transaction_quantity < 0 AND
           r_mtl_data.transaction_source_type_id = 1) OR -- (-) PO Adjustment
          (r_mtl_data.transaction_action_id = 1 AND
           r_mtl_data.transaction_quantity < 0 AND
           r_mtl_data.transaction_source_type_id = 1) OR -- (-) Return to Vendor
         (l_log_trx_action_id = 11 AND
          r_mtl_data.transaction_quantity < 0 AND
          l_log_trx_source_type_id  = 1 AND
          l_log_trx_type_code = 2)  -- (-) Logical PO Adjustment
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. Account Alias Issue          1              31
	--2. Miscellaneous Issue          1              32
	--4. Return to Vendor (PO)        1              36
	--5. Account Issue                1              1
        --6. (-) PO Adjustment            29             71
        --7. (-) Int Req Adjust           29             72
        --8. (-) Shipment Rcp Adjust      29             70
        --9. Move Order Issue             1              63 (recheck)

        --EXCLUDED TRANSACTIONS ARE
        -- 33	Sales order issue
        -- 35	WIP component issue
        -- 37	RMA Return
        -- 93	Field Service Usage
        -- 122	Issue to (User Defined Seeded)


     l_type_id := 116;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'MISC_ISSUE'),'INV');
     l_source_type := 'CSIMSISU';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- Miscellaneous Issue

       savepoint CSIMSISU;

       XNP_CSIMSISU_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIMSISU;
          debug('Failed to publish event CSIMSISU: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIMSISU');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;

       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIMSISU',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 32 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 17
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Assembly Return          32             17

    OPEN c_wip_entity_type;
    FETCH c_wip_entity_type into l_wip_entity_type;
    CLOSE c_wip_entity_type;


	IF l_wip_entity_type =10  AND r_mtl_data.transaction_type_id =1003 THEN
	   l_type_id := 76; --new transaction type to support WIP_ByProduct Return
	   l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_BYPRODUCT_RETURN'),'INV');
	   l_source_type := 'CSIWIPBR';

         IF (l_bypass = 'N') THEN
	        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
	       -- WIP By Product return  Return
	       savepoint CSIWIPBR;
	       XNP_CSIWIPBR_U.publish(   ----New message to be published
	                    xnp$mtl_transaction_id => p_transaction_id,
                            xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                            xnp$organization_id => r_mtl_data.organization_id,
	                    x_message_id => l_message_id,        -- out parameter
	                    x_error_code => l_error_code,        -- out parameter
	                    x_error_message => l_error_message   -- out parameter
	                   );

	       if (l_error_message is not null) then
	          rollback to CSIWIPBR;
	          debug('Failed to publish event CSIWIPBR: ' || l_error_message);
	          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
	          fnd_message.set_token('EVENT','CSIWIPBR');
	          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
	          l_error_message := fnd_message.get;
	          raise HOOK_ERROR;
	       end if;
	     ELSE
	      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
	       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPBR',
	                                           p_transaction_id,
	                                           l_trx_return_status,
	                                           l_trx_error_rec);

	      IF NOT l_trx_return_status = l_fnd_success THEN
	        raise BYPASS_ERROR;
	      END IF;

	 END IF;


  ELSE

     l_type_id := 74;
     l_source_type := 'CSIWIPAR';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Assembly Return

       savepoint CSIWIPAR;

       XNP_CSIWIPAR_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPAR;
          debug('Failed to publish event CSIWIPAR: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPAR');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPAR',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;
     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 1 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 35
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Component Issue          1              35

     l_type_id := 71;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_ISSUE'),'INV');
     l_source_type := 'CSIWIPCI';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Component Issue

       savepoint CSIWIPCI;

       XNP_CSIWIPCI_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPCI;
          debug('Failed to publish event CSIWIPCI: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPCI');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPCI',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 33 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 38
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Neg Comp Issue           33             38

     l_type_id := 72;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_RECEIPT'),'INV');
     l_source_type := 'CSIWIPNI';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Negative Component Issue

       savepoint CSIWIPNI;

       XNP_CSIWIPNI_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPNI;
          debug('Failed to publish event CSIWIPNI: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPNI');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPNI',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 27 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 43
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Component Return         27             43

     l_type_id := 72;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_RECEIPT'),'INV');
     l_source_type := 'CSIWIPCR';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Component Return

       savepoint CSIWIPCR;

       XNP_CSIWIPCR_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPCR;
          debug('Failed to publish event CSIWIPCR: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPCR');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPCR',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 31 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 44
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Assy Completion          31             44

    OPEN c_wip_entity_type;
    FETCH c_wip_entity_type into l_wip_entity_type;
    CLOSE c_wip_entity_type;

    IF l_wip_entity_type =10 AND r_mtl_data.transaction_type_id =1002 THEN

           l_type_id := 75; --new transaction type to support WIP By Product Completion
	   l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name, 'WIP_BYPRODUCT_COMPLETION '),'INV');
	   l_source_type := 'CSIWIPBC ';
	   IF (l_bypass = 'N') THEN
	      debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
	      -- WIP By Product Completion
	      savepoint CSIWIPBC;

           XNP_CSIWIPBC_U.publish(     --New message to be published
	                    xnp$mtl_transaction_id => p_transaction_id,
                            xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                            xnp$organization_id => r_mtl_data.organization_id,
	                    x_message_id => l_message_id,        -- out parameter
	                    x_error_code => l_error_code,        -- out parameter
	                    x_error_message => l_error_message   -- out parameter
	                   );

	       if (l_error_message is not null) then
	          rollback to CSIWIPBC;
	          debug('Failed to publish event CSIWIPBC: ' || l_error_message);
	          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
	          fnd_message.set_token('EVENT','CSIWIPBC');
	          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
	          l_error_message := fnd_message.get;
	          raise HOOK_ERROR;
	       end if;
	     ELSE
	      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
	       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPBC',
	                                           p_transaction_id,
	                                           l_trx_return_status,
	                                           l_trx_error_rec);

	      IF NOT l_trx_return_status = l_fnd_success THEN
	        raise BYPASS_ERROR;
	      END IF;

         END IF;

     ELSE
     l_type_id := 73;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_ASSEMBLY_COMPLETION'),'INV');
     l_source_type := 'CSIWIPAC';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Assembly Completion

       savepoint CSIWIPAC;

       XNP_CSIWIPAC_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPAC;
          debug('Failed to publish event CSIWIPAC: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPAC');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPAC',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

     END IF;

   ELSIF (r_mtl_data.transaction_action_id = 34 AND
          r_mtl_data.transaction_source_type_id = 5)
	     -- Changed to 5 from Txn Type ID 48
   THEN
	---Transactions fall in this category are :
	---  Type                      Action ID     Txn Type ID
	-----------------------      -------------   ------------
	--1. WIP Neg Comp Return          34             48

     l_type_id := 71;
     l_type_id := csi_inv_trxs_pkg.get_txn_type_id(nvl(l_csi_txn_name,'WIP_ISSUE'),'INV');
     l_source_type := 'CSIWIPNR';
     IF (l_bypass = 'N') THEN
        debug('  publishing '||l_source_type||' for transaction_id : '||p_transaction_id);
       -- WIP Negative Component Return

       savepoint CSIWIPNR;

       XNP_CSIWIPNR_U.publish(
                    xnp$mtl_transaction_id => p_transaction_id,
                    xnp$inventory_item_id => r_mtl_data.inventory_item_id,
                    xnp$organization_id => r_mtl_data.organization_id,
                    x_message_id => l_message_id,        -- out parameter
                    x_error_code => l_error_code,        -- out parameter
                    x_error_message => l_error_message   -- out parameter
                   );

       if (l_error_message is not null) then
          rollback to CSIWIPNR;
          debug('Failed to publish event CSIWIPNR: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_EVT_ERR');
          fnd_message.set_token('EVENT','CSIWIPNR');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
       end if;
     ELSE
      debug('  bypassing the SFM queue '||l_source_type||' for transaction_id : '||p_transaction_id);
       CSI_INV_TXNSTUB_PKG.execute_trx_dpl('CSIWIPNR',
                                           p_transaction_id,
                                           l_trx_return_status,
                                           l_trx_error_rec);

      IF NOT l_trx_return_status = l_fnd_success THEN
        raise BYPASS_ERROR;
      END IF;

     END IF;

    ELSE
        debug('  publishing non eib transaction : '||p_transaction_id);
      -- Not a core EIB trackable transaction.
      -- Call client extension to check against additional transaction types.

       csi_client_ext_pub.mtl_post_transaction(
                          p_transaction_id => p_transaction_id,
                          x_return_status  => l_return_status,
                          x_error_message  => l_error_message
                         );

       if (l_return_status <> l_fnd_success) then
             debug('Error occurred in MTL Post Transaction Client Extension: ' || l_error_message);
          fnd_message.set_name('CSI','CSI_INV_HOOK_CLIENT_EXT');
          fnd_message.set_token('ERROR_MESSAGE',l_error_message);
          l_error_message := fnd_message.get;
          raise HOOK_ERROR;
          x_return_status := l_fnd_success;
       end if;

    END IF;

    -- EIB will handle all event errors internally, so return successful status
    x_return_status := l_fnd_success;
  END IF; -- if trackable item

  x_return_status := l_fnd_success;

  csi_t_gen_utility_pvt.build_file_name(
    p_file_segment1 => 'csiinv',
    p_file_segment2 => 'hook');

  debug('***** end of ib hook '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')||' *****');

EXCEPTION
  WHEN HOOK_ERROR THEN
    debug('Raising HOOK_ERROR');
    debug('You have encountered an error in the CSI_INV_TXN_HOOK_PKG Procedure for Transaction: '||p_transaction_id);
    debug('Error Message: '||l_error_message);

    csi_inv_trxs_pkg.build_error_string(l_xml_string,'MTL_TRANSACTION_ID',p_transaction_id);

    l_trx_error_rec                      := csi_inv_trxs_pkg.Init_Txn_Error_Rec;
    l_trx_error_rec.transaction_id       := NULL;
    l_trx_error_rec.message_id           := l_message_id;
    l_trx_error_rec.error_text           := l_error_message;
    l_trx_error_rec.source_type          := l_source_type;
    l_trx_error_rec.source_id            := p_transaction_id;
    l_trx_error_rec.message_string       := l_xml_string;
    l_trx_error_rec.transaction_type_id  := l_type_id;
    l_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
    l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

    csi_inv_trxs_pkg.log_csi_error(l_trx_error_rec);

    x_return_status := l_fnd_success;

  WHEN BYPASS_ERROR THEN
    debug('Raising BYPASS_ERROR');
    debug('You have encountered an error in the CSI_INV_TXN_HOOK_PKG Procedure for Transaction: '||p_transaction_id);
    debug('Error Message: '||l_trx_error_rec.error_text);
    csi_inv_trxs_pkg.build_error_string(l_xml_string,'MTL_TRANSACTION_ID',p_transaction_id);

    l_trx_error_rec.transaction_id       := NULL;
    l_trx_error_rec.message_id           := NULL;
    l_trx_error_rec.source_type          := l_source_type;
    l_trx_error_rec.source_id            := l_trx_error_rec.source_id;
    l_trx_Error_Rec.processed_flag       := CSI_INV_TRXS_PKG.G_TXN_ERROR;
    l_trx_error_rec.message_string       := l_xml_string;
    l_trx_error_rec.transaction_type_id  := l_type_id;
    l_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
    l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

    csi_inv_trxs_pkg.log_csi_error(l_trx_error_rec);

    x_return_status := l_fnd_success;

  WHEN OTHERS THEN
    x_return_status := l_fnd_success;
    fnd_message.set_name('CSI', 'CSI_INV_POST_TXN_EXCEPTION');
    fnd_message.set_token('SQL_ERROR', SQLERRM);
    l_error_message := fnd_message.get;
    debug('Raising OTHERS');
    debug('You have encountered an error in the CSI_INV_TXN_HOOK_PKG Procedure for Transaction: '||p_transaction_id);
    debug('Error Message: '||l_error_message);

    csi_inv_trxs_pkg.build_error_string(l_xml_string,'MTL_TRANSACTION_ID',p_transaction_id);
    l_trx_error_rec                      := csi_inv_trxs_pkg.Init_Txn_Error_Rec;
    l_trx_error_rec.transaction_id       := NULL;
    l_trx_error_rec.message_id           := NULL;
    l_trx_error_rec.error_text           := l_error_message;
    l_trx_error_rec.source_type          := l_source_type;
    l_trx_error_rec.source_id            := p_transaction_id;
    l_trx_error_rec.message_string       := l_xml_string;
    l_trx_error_rec.transaction_type_id  := l_type_id;
    l_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
    l_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

    csi_inv_trxs_pkg.log_csi_error(l_trx_error_rec);

    x_return_status := l_fnd_success;

END postTransaction;

END CSI_INV_TXN_HOOK_PKG;

/
