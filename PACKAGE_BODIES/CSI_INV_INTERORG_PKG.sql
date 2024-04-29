--------------------------------------------------------
--  DDL for Package Body CSI_INV_INTERORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INV_INTERORG_PKG" as
-- $Header: csiorgtb.pls 120.3.12000000.5 2007/07/06 15:31:23 ngoutam ship $

   PROCEDURE debug(p_message IN varchar2) IS

   BEGIN
     csi_t_gen_utility_pvt.add(p_message);
   EXCEPTION
     WHEN others THEN
       null;
   END debug;

   PROCEDURE intransit_shipment(p_transaction_id     IN  NUMBER,
                                p_message_id         IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_INTERORG_PKG.INTRANSIT_SHIPMENT';
   l_api_version                NUMBER          := 1.0;
   l_commit                     VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list              VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only       VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only     VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id             NUMBER          := NULL;
   l_resolve_id_columns         VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number      NUMBER          := 1;
   l_sysdate                    DATE            := SYSDATE;
   l_master_organization_id     NUMBER;
   l_depreciable                VARCHAR2(1);
   l_txn_error_rec              CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
   l_instance_query_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_dest_instance_query_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                    CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status              VARCHAR2(1);
   l_error_code                 VARCHAR2(50);
   l_error_message              VARCHAR2(4000);
   l_instance_id_lst            CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec            CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec          CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_instance_header_tbl        CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_src_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl      CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl                  CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl                CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl         CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl        CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl       CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_sub_inventory              VARCHAR2(10);
   l_location_type              VARCHAR2(20);
   l_trx_action_type            VARCHAR2(50);
   l_fnd_success                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                VARCHAR2(1) := 'W';
   l_fnd_error                  VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected             VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_fnd_g_num                  NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char                 VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date                 DATE        := FND_API.G_MISS_DATE;
   l_in_inventory               VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_transit                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_returned                   VARCHAR2(25) := 'RETURNED';
   l_out_of_enterprise          VARCHAR2(25) := 'OUT_OF_ENTERPRISE';
   l_instance_usage_code        VARCHAR2(25);
   l_organization_id            NUMBER;
   l_subinventory_name          VARCHAR2(10);
   l_locator_id                 NUMBER;
   l_transaction_error_id       NUMBER;
   l_trx_type_id                NUMBER;
   l_mfg_serial_flag            VARCHAR2(1);
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER;
   i                            PLS_INTEGER :=1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_redeploy_flag              VARCHAR2(1);
   l_upd_error_instance_id      NUMBER := NULL;
   l_mfg_flag                   VARCHAR2(1)  := NULL;
   l_serial_number              VARCHAR2(30) := NULL;
   l_quantity                   NUMBER := 0;
   l_def_in_transit_loc_id      NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   CURSOR c_item_control (pc_item_id in number,
                          pc_org_id in number) is
     SELECT serial_number_control_code,
            lot_control_code,
            revision_qty_control_code,
            location_control_code,
            comms_nl_trackable_flag
     FROM mtl_system_items_b
     WHERE inventory_item_id = pc_item_id
     AND organization_id = pc_org_id;

   r_item_control     c_item_control%rowtype;

   BEGIN

     x_return_status := l_fnd_success;
     l_error_message := NULL;

     debug('******Start of csi_inv_interorg_pkg.intransit_shipment Transaction procedure******');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiorgtb.pls 115.23');
     debug('Transaction ID with is: '||p_transaction_id);

     -- Get the default in transit location id
     l_def_in_transit_loc_id := csi_datastructures_pub.g_install_param_rec.in_transit_location_id;

     debug('Default In Transit Loc IDs: '||l_def_in_transit_loc_id);

     -- This procedure queries all of the Inventory Transaction Records and
     -- returns them as a table.

     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;

     debug('Inventory Records Found: '||l_tbl_count);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     debug('Transaction Action ID: '||l_mtl_item_tbl(i).transaction_action_id);
     debug('Transaction Source Type ID: '||l_mtl_item_tbl(i).transaction_source_type_id);
     debug('Transaction Quantity: '||l_mtl_item_tbl(i).transaction_quantity);

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       debug('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
     END IF;

     debug('The Employee that is processing this Transaction is: '||l_employee_id);

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                            l_depreciable);

    debug('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);

    -- Get the Negative Receipt Code to see if this org allows Negative
    -- Quantity Records 1 = Yes, 2 = No

    l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
                                        l_mtl_item_tbl(i).organization_id);

    IF l_neg_code = 1 AND l_mtl_item_tbl(i).serial_number_control_code in (1,6) THEN
      l_instance_status := FND_API.G_FALSE;
    ELSE
      l_instance_status := FND_API.G_TRUE;
    END IF;

    debug('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);

    -- Determine Transaction Type for this

    l_trans_type_code := 'INTERORG_TRANS_SHIPMENT';
    l_trans_app_code := 'INV';

    debug('Trans Type Code: '||l_trans_type_code);
    debug('Trans App Code: '||l_trans_app_code);

     -- Initialize Transaction Record
     l_txn_rec                          := csi_inv_trxs_pkg.init_txn_rec;

     -- Set Status based on redeployment
     IF l_depreciable = 'N' THEN
       IF l_mtl_item_tbl(i).serial_number is NOT NULL THEN
         csi_inv_trxs_pkg.get_redeploy_flag(l_mtl_item_tbl(i).inventory_item_id,
                                            l_mtl_item_tbl(i).serial_number,
                                            l_sysdate,
                                            l_redeploy_flag,
                                            l_return_status,
                                            l_error_message);
       END IF;
       IF l_redeploy_flag = 'Y' THEN
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
       ELSE
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_complete;
       END IF;
     ELSE
       l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       debug('Redeploy Flag: '||l_redeploy_flag);
       debug('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       RAISE fnd_api.g_exc_error;
     END IF;

     debug('Redeploy Flag: '||l_redeploy_flag);
     debug('Trans Status Code: '||l_txn_rec.transaction_status_code);

    -- Create CSI Transaction to be used
    l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
    l_txn_rec.transaction_date         := l_sysdate;
    l_txn_rec.transaction_type_id      :=
         csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
    l_txn_rec.transaction_quantity     :=
         l_mtl_item_tbl(i).transaction_quantity;
    l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
    l_txn_rec.transacted_by            :=  l_employee_id;
    l_txn_rec.transaction_action_code  :=  NULL;
    l_txn_rec.message_id               :=  p_message_id;
    l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
    l_txn_rec.object_version_number    :=  l_object_version_number;
    l_txn_rec.source_line_ref          :=  l_mtl_item_tbl(i).shipment_number;

    csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                    l_error_message,
                                    l_return_status);

    debug('CSI Transaction Created: '||l_txn_rec.transaction_id);

    IF NOT l_return_status = l_fnd_success THEN
      debug('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Now loop through the PL/SQL Table.
    j := 1;

    debug('Starting to loop through Material Transaction Records');

    -- Get Default Profile Instance Status
    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    debug('Default Profile Status: '||r_id.instance_status_id);

    FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

     -- Get Receiving Organization Item Master Control Codes
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                          l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     debug('Serial Number : '||l_mtl_item_tbl(j).serial_number);
     debug('Shipping Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
     debug('Receiving Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
     debug('Shipping Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
     debug('Receiving Org Lot Control Code: '||r_item_control.lot_control_code);
     debug('Shipping Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
     debug('Receiving Org Location Control Code: '||r_item_control.location_control_code);
     debug('Shipping Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
     debug('Receiving Org Revision Control Code: '||r_item_control.revision_qty_control_code);
     debug('Receiving Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);
     debug('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
     debug('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
     debug('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
     debug('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
     debug('Organization ID: '||l_mtl_item_tbl(j).organization_id);
     debug('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);

      l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
      l_instance_usage_code                                :=  l_fnd_g_char;

      IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN
        --In Transit Shipment
        l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
        l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
        l_instance_query_rec.serial_number                   :=  NULL;
        l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
        l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
        l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
        l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
        l_instance_query_rec.instance_usage_code             :=  l_in_inventory;
        l_sub_inventory   :=  NULL;
        l_trx_action_type := 'IN_TRANSIT_SHIPMENT';
        l_instance_usage_code := l_instance_query_rec.instance_usage_code;

        debug('Set Serial Number to NULL');

      ELSIF l_mtl_item_tbl(j).serial_number_control_code in (2,5) THEN
              --In Transit Shipment
        l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
        l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
        l_sub_inventory   :=  NULL;
        l_trx_action_type := 'IN_TRANSIT_SHIPMENT';
        l_instance_usage_code := l_instance_query_rec.instance_usage_code;

        debug('Set Serial Number to: '||l_instance_query_rec.serial_number);

      END IF;

      debug('Transaction Action Type:'|| l_trx_action_type);
      debug('Before Get Item Instance - 1');

      csi_item_instance_pub.get_item_instances(l_api_version,
                                               l_commit,
                                               l_init_msg_list,
                                               l_validation_level,
                                               l_instance_query_rec,
                                               l_party_query_rec,
                                               l_account_query_rec,
                                               l_transaction_id,
                                               l_resolve_id_columns,
                                               l_instance_status,
                                               l_src_instance_header_tbl,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data);

      debug('After Get Item Instance - 2');

      l_tbl_count := 0;
      l_tbl_count := l_src_instance_header_tbl.count;

      debug('Source Records Found: '||l_tbl_count);

      -- Check for any errors and add them to the message stack to pass out to be put into the  error log table.
      IF NOT l_return_status = l_fnd_success then
        debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
        l_msg_index := 1;
          WHILE l_msg_count > 0 loop
	    l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	    l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
  	  END LOOP;
	  RAISE fnd_api.g_exc_error;
       END IF;

       debug('Before checking to see if Source records Exist - 3');

       IF l_mtl_item_tbl(j).serial_number_control_code in (2,5) THEN
         IF l_src_instance_header_tbl.count = 1 THEN

         IF r_item_control.serial_number_control_code <> 1 THEN -- Do Regular Processing

         IF l_src_instance_header_tbl(i).instance_usage_code IN (l_in_transit,l_in_inventory,l_returned) THEN

           debug('Updating Serialized Instance: '||l_mtl_item_tbl(j).serial_number);
           debug('Shipping Serial Code is 2,5');

           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.inv_subinventory_name        :=  NULL;
           l_update_instance_rec.inv_locator_id               :=  NULL;
	   -- Added for Bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.location_id                  := nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_update_instance_rec.instance_usage_code          :=  l_in_transit;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Instance Status - 4: '||l_update_instance_rec.instance_status_id);
           debug('After you initialize the Transaction Record Values- 4');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 5');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 6');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
             WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

           ELSE -- No Serialized Instances found so Error.

             debug('No Records were found in Install Base - 7');

             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;
           END IF; -- End of Usage Code Check

         ELSE -- -- Serial Control is 1 ( No Control ) so set to Out Of Enterprise

         IF l_src_instance_header_tbl(i).instance_usage_code IN (l_in_transit,l_in_inventory,l_returned) THEN

           debug('Updating Serialized Instance to Out of Enterprise: '||l_mtl_item_tbl(j).serial_number);
           debug('Shipping Serial Code is 2,5 and Receiving is 1');

           l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
           l_update_instance_rec.inv_subinventory_name        :=  NULL;
           l_update_instance_rec.inv_locator_id               :=  NULL;
	   -- Added for Bug 5975739
	   l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_update_instance_rec.inv_organization_id          :=  NULL;
           l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_update_instance_rec.location_id                  :=  l_def_in_transit_loc_id;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('hz_locations');
           l_update_instance_rec.active_end_date              :=  l_sysdate;
           l_update_instance_rec.instance_usage_code          :=  l_out_of_enterprise;
           l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

           l_update_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Instance Status - 8: '||l_update_instance_rec.instance_status_id);
           debug('After you initialize the Transaction Record Values- 8');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 9');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 10');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
             WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

         IF j = 1 THEN -- Look for IN Transit Non Serial If not there create or Update only 1 time
           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
           l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.serial_number                 :=  NULL;
           l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.in_transit_order_line_id      :=  NULL;
           l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_instance_query_rec.instance_usage_code           :=  l_in_transit;

	   -- 5639896 next 3 lines
	   l_instance_query_rec.inv_subinventory_name         :=  NULL;
	   l_instance_query_rec.inv_organization_id           :=  NULL;
	   l_instance_query_rec.location_type_code            :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');

	   l_instance_usage_code                              :=  l_in_transit;
           l_subinventory_name                                :=  NULL;
           l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
           l_locator_id                                       :=  NULL;

           l_mfg_flag := NULL;
           l_serial_number := NULL;
           l_quantity := abs(l_mtl_item_tbl(j).transaction_quantity);

           debug('Since the Shipping Code is 2 or 5 and the Receiving is 1 Look for Non Serial In Transit');
           csi_t_gen_utility_pvt.dump_instance_query_rec(l_instance_query_rec);

           debug('Before Get Item Instance for Dest Non Serialized Instance-11');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance-12');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
            END IF;

           IF l_dest_instance_header_tbl.count < 1 THEN  -- Installed Base Destination Records are not found so create a new record

             debug('Creating New Dest dest Instance-13');

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  l_mfg_flag;
             l_new_dest_instance_rec.serial_number                :=  l_serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  l_quantity;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           --  l_new_dest_instance_rec.location_id                  :=  l_def_in_transit_loc_id;
             l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             --l_new_dest_instance_rec.in_transit_order_line_id     :=  r_so_info.line_id;
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             debug('Before Create Item Instance-14');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Item Instance-15');
             debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

            debug('Instance Usage Code: '||l_dest_instance_header_tbl(i).instance_usage_code);
            debug('Item ID: '||l_dest_instance_header_tbl(i).inventory_item_id);
            debug('Instance ID: '||l_dest_instance_header_tbl(i).instance_id);

            l_update_dest_instance_rec                          :=  csi_inv_trxs_pkg.init_instance_update_rec;
            l_update_dest_instance_rec.instance_id              :=  l_dest_instance_header_tbl(i).instance_id;
            l_update_dest_instance_rec.quantity                 :=  l_dest_instance_header_tbl(i).quantity + l_quantity;
            --l_update_dest_instance_rec.location_id              :=  l_def_in_transit_loc_id;
            l_update_dest_instance_rec.location_id              :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
            l_update_dest_instance_rec.location_type_code       :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
            --l_update_dest_instance_rec.in_transit_order_line_id :=  r_so_info.line_id;
	    -- Added for Bug 5975739
	    l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
            l_update_dest_instance_rec.inv_organization_id      :=  NULL;
            l_update_dest_instance_rec.inv_subinventory_name    :=  l_subinventory_name;
            l_update_dest_instance_rec.inv_locator_id           :=  l_locator_id;
            l_update_dest_instance_rec.instance_usage_code      :=  l_in_transit;
            l_update_dest_instance_rec.active_end_date          :=  NULL;
            l_update_dest_instance_rec.active_end_date          :=  NULL;
            l_update_dest_instance_rec.object_version_number    :=  l_dest_instance_header_tbl(i).object_version_number;

            l_party_tbl.delete;
            l_account_tbl.delete;
            l_pricing_attrib_tbl.delete;
            l_org_assignments_tbl.delete;
            l_asset_assignment_tbl.delete;

               l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Before Update Item Instance-16');
               debug('Instance Status-11: '||l_update_dest_instance_rec.instance_status_id);

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance-17');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- Error No dest non serial recs round
            debug('No Records were found in Install Base but the usage is not correct-14, The Usage is: '||l_dest_instance_header_tbl(i).instance_usage_code);
            fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
            fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
            fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;
          END IF;    -- End of Destination Record If

         END IF; -- End of j=1 for Control Code 1

         ELSE -- No Serialized Instances found so Error.
           debug('No Records were found in Install Base - 18');

           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;
           END IF; -- End of Usage Code Check if Ship is 2,5 and Rec is 1

         END IF; -- End of If for Rec Serial Code Check


         ELSE -- No Serialized Instances found so Error.
           debug('No Records were found in Install Base - 19');

           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

         END IF;  -- End of 2,5 Serial Control

       ELSIF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN
         IF l_src_instance_header_tbl.count = 0 THEN
           IF l_neg_code = 1 THEN -- Negative Records Allowed so Create/Update

             debug('No records were found and Inventory Allows Negative Quantities so create a new Source Instance Record - 8');

             l_new_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_src_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_src_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_src_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_src_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_src_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_src_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
             l_new_src_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_src_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_src_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_new_src_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_new_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
             l_new_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
             l_new_src_instance_rec.customer_view_flag           :=  'N';
             l_new_src_instance_rec.merchant_view_flag           :=  'Y';
             l_new_src_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_src_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_src_instance_rec.active_start_date            :=  l_sysdate;
             l_new_src_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                             :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                         :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                       :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                               :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                              :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             debug('Before Create Source Item Instance - 9');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_src_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Source Item Instance - 10');
             debug('You are Creating Instance: '||l_new_src_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the  error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	       RAISE fnd_api.g_exc_error;
             END IF;

           ELSE -- Neg Code is <> 1 so Neg Qtys are not allowed so error
             debug('No Records were found in Install Base - 11');

             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;

           END IF;  -- End of Neg Qty If

         ELSIF l_src_instance_header_tbl.count = 1 THEN

             debug('You will update instance: '||l_src_instance_header_tbl(i).instance_id);

             l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
             l_upd_src_dest_instance_rec.active_end_date        :=  NULL;
             l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
             l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             debug('Before Update Source Item Instance - 13');

             l_upd_src_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_upd_src_dest_instance_rec.instance_status_id);

             csi_item_instance_pub.update_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_upd_src_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_instance_id_lst,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_upd_src_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 14');
             debug('You are updating Instance: '||l_upd_src_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	       RAISE fnd_api.g_exc_error;
             END IF;

         ELSIF l_src_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
         END IF;  -- End of If for Source Count

	 -- Get Destination Records

         debug('Before Getting Dest Instances - 16 ');

         l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.serial_number                 :=  NULL;
         l_instance_query_rec.instance_usage_code           :=  l_in_transit;
         l_instance_query_rec.inv_subinventory_name         :=  NULL;

-- Bug 5639896
         l_instance_query_rec.inv_organization_id           :=  NULL;

         l_instance_query_rec.location_type_code            :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_instance_query_rec.in_transit_order_line_id      :=  NULL;
--JPW JUNE21
         --l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id; --fix for bug5704500/bug6036067
         l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;

         l_subinventory_name                                :=  NULL;
--JPW JUNE21
         l_organization_id                                  :=  NULL;
         --l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
         l_locator_id                                       :=  NULL;

         debug('Before Get Item Instance - 17');

         csi_item_instance_pub.get_item_instances(l_api_version,
                                                  l_commit,
                                                  l_init_msg_list,
                                                  l_validation_level,
                                                  l_instance_query_rec,
                                                  l_party_query_rec,
                                                  l_account_query_rec,
                                                  l_transaction_id,
                                                  l_resolve_id_columns,
                                                  l_inactive_instance_only,
                                                  l_dest_instance_header_tbl,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

         debug('After Get Item Instance - 18');

         l_tbl_count := 0;
         l_tbl_count :=  l_dest_instance_header_tbl.count;
         debug('Source Records Found: '||l_tbl_count);

         -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
         IF NOT l_return_status = l_fnd_success then
           debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
           l_msg_index := 1;
	     WHILE l_msg_count > 0 loop
	       l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	       l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	     END LOOP;
         RAISE fnd_api.g_exc_error;
         END IF;

         IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

           debug('Creating New Dest dest Instance - 19');

           l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
           l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
           l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
           l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
           l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_new_dest_instance_rec.location_type_code           := csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
           l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
           l_new_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
           l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
           l_new_dest_instance_rec.customer_view_flag           :=  'N';
           l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
           l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
           l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
           l_new_dest_instance_rec.active_end_date              :=  NULL;

           l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           debug('Before Create Item Instance - 20');

           csi_item_instance_pub.create_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_new_dest_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           debug('After Create Item Instance - 21');
           debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	     RAISE fnd_api.g_exc_error;
           END IF;

         ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

             l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
             l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_dest_instance_rec.active_end_date         :=  NULL;
             l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

             l_party_tbl.delete;
             l_account_tbl.delete;
             l_pricing_attrib_tbl.delete;
             l_org_assignments_tbl.delete;
             l_asset_assignment_tbl.delete;

             l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
             debug('Before Update Item Instance - 23');

             csi_item_instance_pub.update_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_update_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_instance_id_lst,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 24');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	     RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

         END IF;    -- End of Destination Record If
       END IF;      -- End of Serial Control If
     END LOOP;      -- End of For Loop

     debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('******End of csi_inv_interorg_pkg.intransit_shipment Transaction******');

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception in the Inter-Organization Transaction - In Transit Shipment');
       x_return_status := l_fnd_error;

       IF l_mtl_item_tbl.count > 0 THEN
         x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
         x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
         x_trx_error_rec.instance_id := l_upd_error_instance_id;
         x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
         x_trx_error_rec.src_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
         x_trx_error_rec.src_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
         x_trx_error_rec.src_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
         x_trx_error_rec.src_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
         x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
         x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
         x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
         x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIORGTS';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;

        debug('You have encountered a "when others" exception in the Inter-Organization Transaction - In Transit Shipment');
        debug('SQL Error: '||l_sql_error);

        fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
        fnd_message.set_token('API_NAME',l_api_name);
        fnd_message.set_token('SQL_ERROR',SQLERRM);
        x_return_status := l_fnd_unexpected;

        IF l_mtl_item_tbl.count > 0 THEN
          x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
          x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
          x_trx_error_rec.instance_id := l_upd_error_instance_id;
          x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
          x_trx_error_rec.src_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
          x_trx_error_rec.src_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
          x_trx_error_rec.src_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
          x_trx_error_rec.src_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
          x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
          x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
          x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
          x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
          x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
          x_trx_error_rec.transaction_error_date := l_sysdate ;
        END IF;

        x_trx_error_rec.error_text := fnd_message.get;
        x_trx_error_rec.transaction_id       := NULL;
        x_trx_error_rec.source_type          := 'CSIORGTS';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END intransit_shipment;


   PROCEDURE intransit_receipt(p_transaction_id     IN  NUMBER,
                               p_message_id         IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_INTERORG_PKG.INTRANSIT_RECEIPT';
   l_api_version                NUMBER          := 1.0;
   l_commit                     VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list              VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only       VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only     VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id             NUMBER          := NULL;
   l_resolve_id_columns         VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number      NUMBER          := 1;
   l_sysdate                    DATE            := SYSDATE;
   l_master_organization_id     NUMBER;
   l_depreciable                VARCHAR2(1);
   l_txn_error_rec              CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
   l_instance_query_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_dest_instance_query_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                    CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status              VARCHAR2(1);
   l_error_code                 VARCHAR2(50);
   l_error_message              VARCHAR2(4000);
   l_instance_id_lst            CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec            CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec          CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_instance_header_tbl        CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_src_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl      CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl                  CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl                CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl         CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl        CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl       CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_sub_inventory              VARCHAR2(10);
   l_location_type              VARCHAR2(20);
   l_trx_action_type            VARCHAR2(50);
   l_fnd_success                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                VARCHAR2(1) := 'W';
   l_fnd_error                  VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected             VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_fnd_g_num                  NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char                 VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date                 DATE        := FND_API.G_MISS_DATE;
   l_in_inventory               VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_transit                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_out_of_enterprise          VARCHAR2(25) := 'OUT_OF_ENTERPRISE';
   l_returned                   VARCHAR2(25) := 'RETURNED';
   l_instance_usage_code        VARCHAR2(25);
   l_organization_id            NUMBER;
   l_subinventory_name          VARCHAR2(10);
   l_locator_id                 NUMBER;
   l_transaction_error_id       NUMBER;
   l_trx_type_id                NUMBER;
   l_mfg_serial_flag            VARCHAR2(1);
   l_serial_number              VARCHAR2(30);
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER;
   i                            PLS_INTEGER :=1;
   k                            PLS_INTEGER :=1;
   p                            PLS_INTEGER :=1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_inv_org_iso                NUMBER;
   l_sr_control                 NUMBER := 0;
   l_12_loop                    NUMBER := 0;
   l_status                     VARCHAR2(50);
   l_ownership_party            VARCHAR2(1);
   l_redeploy_flag              VARCHAR2(1);
   l_upd_error_instance_id      NUMBER := NULL;

   l_instance_header_rec     csi_datastructures_pub.instance_header_rec;
   l_party_header_tbl        csi_datastructures_pub.party_header_tbl;
   l_account_header_tbl      csi_datastructures_pub.party_account_header_tbl;
   l_org_header_tbl          csi_datastructures_pub.org_units_header_tbl;
   l_pricing_header_tbl      csi_datastructures_pub.pricing_attribs_tbl;
   l_ext_attrib_header_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
   l_ext_attrib_def_tbl      csi_datastructures_pub.extend_attrib_tbl;
   l_asset_header_tbl        csi_datastructures_pub.instance_asset_header_tbl;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   CURSOR c_item_control (pc_item_id in number,
                          pc_org_id in number) is
     SELECT serial_number_control_code,
            lot_control_code,
            revision_qty_control_code,
            location_control_code,
            comms_nl_trackable_flag
     FROM mtl_system_items_b
     WHERE inventory_item_id = pc_item_id
     AND organization_id = pc_org_id;

   r_item_control     c_item_control%rowtype;

   BEGIN

     x_return_status := l_fnd_success;
     l_error_message := NULL;

     debug('******Start of csi_inv_interorg_pkg.intransit_receipt Transaction procedure******');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiorgtb.pls 115.23');
     debug('Transaction ID with is: '||p_transaction_id);

     -- This procedure queries all of the Inventory Transaction Records and
     -- returns them as a table.

     csi_inv_trxs_pkg.get_transaction_recs(p_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;

     debug('Inventory Records Found: '||l_tbl_count);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||p_transaction_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     debug('Transaction Action ID: '||l_mtl_item_tbl(i).transaction_action_id);
     debug('Transaction Source Type ID: '||l_mtl_item_tbl(i).transaction_source_type_id);
     debug('Transaction Quantity: '||l_mtl_item_tbl(i).transaction_quantity);

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
         debug('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
          debug('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
     END IF;

     debug('The Employee that is processing this Transaction is: '||l_employee_id);

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                               l_depreciable);

     debug('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);

     -- Get Party ownership Flag
     l_ownership_party := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

     debug('Ownership Party FLag is: '||l_ownership_party)
;

     -- Determine Transaction Type for this

     l_trans_type_code := 'INTERORG_TRANS_RECEIPT';
     l_trans_app_code := 'INV';

     debug('Trans Type Code: '||l_trans_type_code);
     debug('Trans App Code: '||l_trans_app_code);

     -- Initialize Transaction Record
     l_txn_rec                          := csi_inv_trxs_pkg.init_txn_rec;

     -- Set Status based on redeployment
     IF l_depreciable = 'N' THEN
       IF l_mtl_item_tbl(i).serial_number is NOT NULL THEN
         csi_inv_trxs_pkg.get_redeploy_flag(l_mtl_item_tbl(i).inventory_item_id,
                                            l_mtl_item_tbl(i).serial_number,
                                            l_sysdate,
                                            l_redeploy_flag,
                                            l_return_status,
                                            l_error_message);
       END IF;
       IF l_redeploy_flag = 'Y' THEN
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
       ELSE
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_complete;
       END IF;
     ELSE
       l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       debug('Redeploy Flag: '||l_redeploy_flag);
       debug('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       RAISE fnd_api.g_exc_error;
     END IF;

    debug('Redeploy Flag: '||l_redeploy_flag);
    debug('Trans Status Code: '||l_txn_rec.transaction_status_code);

    -- Create CSI Transaction to be used
    l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
    l_txn_rec.transaction_date         := l_sysdate;
    l_txn_rec.transaction_type_id      :=
         csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
    l_txn_rec.transaction_quantity     :=
         l_mtl_item_tbl(i).transaction_quantity;
    l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
    l_txn_rec.transacted_by            :=  l_employee_id;
    l_txn_rec.transaction_action_code  :=  NULL;
    l_txn_rec.message_id               :=  p_message_id;
    l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
    l_txn_rec.object_version_number    :=  l_object_version_number;
    l_txn_rec.source_line_ref          :=  l_mtl_item_tbl(i).shipment_number;

    csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                    l_error_message,
                                    l_return_status);

    debug('CSI Transaction Created: '||l_txn_rec.transaction_id);

    IF NOT l_return_status = l_fnd_success THEN
      debug('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
      RAISE fnd_api.g_exc_error;
    END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

    debug('Starting to loop through Material Transaction Records');

    -- Get Default Profile Instance Status

    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    debug('Default Profile Status: '||r_id.instance_status_id);

	l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(l_mtl_item_tbl(i).organization_id); --fix for bug5704500/bug6036067
    debug('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code); --fix for bug6036067

    FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

     IF (l_neg_code = 1 AND l_mtl_item_tbl(j).serial_number_control_code in (1,6)) OR
        (l_mtl_item_tbl(j).serial_number_control_code in (2,5)) THEN
	  l_instance_status := FND_API.G_FALSE;
     ELSE
	  l_instance_status := FND_API.G_TRUE;
     END IF;

     debug('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
     debug('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
     debug('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
     debug('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
     debug('Organization ID: '||l_mtl_item_tbl(j).organization_id);
     debug('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);

     -- Get Shipping Organization Item Master Controls
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                          l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     l_sr_control := r_item_control.serial_number_control_code;

     debug('Serial Number : '||l_mtl_item_tbl(j).serial_number);
     debug('l_sr_control is: '||l_sr_control);
     debug('Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
     debug('Receiving Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
     debug('Shipping Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
     debug('Receiving Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
     debug('Shipping Org Lot Control Code: '||r_item_control.lot_control_code);
     debug('Receiving Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
     debug('Shipping Org Location Control Code: '||r_item_control.location_control_code);
     debug('Receiving Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
     debug('Shipping Org Revision Control Code: '||r_item_control.revision_qty_control_code);
     debug('Shipping Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);
     debug('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);

     l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
     l_instance_usage_code                                :=  l_fnd_g_char;

       IF (l_mtl_item_tbl(j).serial_number_control_code = 6 AND
           l_sr_control in (2,5)) THEN
         --In Transit Receipt
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         --l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).transfer_organization_id;
         l_instance_query_rec.serial_number                   :=  l_fnd_g_char;
         l_instance_query_rec.location_type_code              :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.instance_usage_code             :=  l_in_transit;
         l_trx_action_type := 'IN_TRANSIT_RECEIPT';
         l_instance_usage_code := l_instance_query_rec.instance_usage_code;

         debug('Set Serial Number to G MISS');

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 1 AND
              l_sr_control in (2,5)) OR
             (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
              l_sr_control in (6,1)) THEN
         --In Transit Receipt
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         --l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         --l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).transfer_organization_id;
         l_instance_query_rec.inv_organization_id             :=  NULL;
         l_instance_query_rec.location_type_code              :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_instance_query_rec.in_transit_order_line_id        :=  NULL;
         l_instance_query_rec.serial_number                   :=  NULL;
         l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.instance_usage_code             :=  l_in_transit;
         l_trx_action_type := 'IN_TRANSIT_RECEIPT';
         l_instance_usage_code := l_instance_query_rec.instance_usage_code;

         debug('Set Serial Number to NULL-1');

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code in (6,1) AND
              l_sr_control in (6,1)) THEN
         --In Transit Receipt
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         --l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         --l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).transfer_organization_id;
         l_instance_query_rec.location_type_code              :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
         l_instance_query_rec.in_transit_order_line_id        :=  NULL;
         l_instance_query_rec.serial_number                   :=  NULL;
         l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.instance_usage_code             :=  l_in_transit;
         l_trx_action_type := 'IN_TRANSIT_RECEIPT';
         l_instance_usage_code := l_instance_query_rec.instance_usage_code;

         debug('Set Serial Number NULL-1.1');

         ELSIF (l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
                l_sr_control in (2,5)) THEN
         --In Transit Receipt
         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
         l_trx_action_type := 'IN_TRANSIT_RECEIPT';
         l_instance_usage_code := l_instance_query_rec.instance_usage_code;

         debug('Set Serial Number to the serial number from Inv');

       END IF;


       debug('l_12_loop is:'|| l_12_loop);
       debug('If Count is 1 then bypass Get Item Instance');

       IF l_12_loop = 0 THEN

       debug('Transaction Action Type:'|| l_trx_action_type);
       debug('Before Get Item Instance - 1');

       csi_item_instance_pub.get_item_instances(l_api_version,
                                                l_commit,
                                                l_init_msg_list,
                                                l_validation_level,
                                                l_instance_query_rec,
                                                l_party_query_rec,
                                                l_account_query_rec,
                                                l_transaction_id,
                                                l_resolve_id_columns,
                                                l_instance_status,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);
       END IF; -- End of l_12_loop IF

       debug('After Get Item Instance - 2');

       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;

       debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
       IF NOT l_return_status = l_fnd_success then
         debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         l_msg_index := 1;
           WHILE l_msg_count > 0 loop
	     l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	     l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
  	   END LOOP;
	   RAISE fnd_api.g_exc_error;
       END IF;

     IF l_src_instance_header_tbl.count > 0 OR
        l_12_loop = 1 THEN -- Installed Base Records Found

        debug('Records exists so now check both Shipping and Rec Serial Control');

      IF l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND
         l_sr_control in (2,5) THEN

             debug('Serial Control at Shipping and Receiving are both 2,5');
             debug('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);

             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
	     -- Added for Bug 5975739
	     l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
             l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
             l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
             l_update_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_update_instance_rec.in_transit_order_line_id     :=  NULL;
             l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;
	      --Code start for bug 6137231--
             IF r_item_control.lot_control_code = 2 AND l_mtl_item_tbl(j).lot_control_code = 1 THEN
               l_update_instance_rec.lot_number                   :=  NULL;
               debug('Lot control 2 and 1');
             ELSIF r_item_control.lot_control_code = 2 AND l_mtl_item_tbl(j).lot_control_code = 2 THEN
               l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
               debug('Lot control 2 and 2');
             ELSIF r_item_control.lot_control_code = 1 AND l_mtl_item_tbl(j).lot_control_code = 2 THEN
               l_update_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
               debug('Lot control 1 and 2');
             END IF;---lot check
	     --Code end for bug 6137231--

             debug('After you initialize the Update Record Values - 2');

             debug('After you initialize the Transaction Record Values - 3');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 4');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 5');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;


      ELSIF l_mtl_item_tbl(j).serial_number_control_code in (2,5)  AND
         l_sr_control in (1,6) THEN

         l_12_loop := 1;

           debug('Setting l_12_loop: '||l_12_loop);
           debug('Serial Control at Shipping is 1,6 and Receiving is 2,5');

          IF j = 1 THEN -- Update Source Since its Non Serialized 1 Time

           debug('Update Source 1 time with Transaction Quantity');
           debug('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 6');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_upd_src_dest_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_upd_src_dest_instance_rec.instance_id;

           debug('After Update Item Instance - 7');
           debug('You are updating Instance: '||l_upd_src_dest_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;
         END IF; -- End of J = 1 If to update Source 1 time

         -- Now Query for Dest Serialized Instances and Update (Unexpire)/ Create Instances
	    -- New Code added JPW
             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             --l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             --l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  l_mtl_item_tbl(j).serial_number;
             --l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             --l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).subinventory_code;
             --l_instance_query_rec.inv_subinventory_name         :=  NULL;
             --l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
             --l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
             l_instance_usage_code                              :=  l_in_inventory;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).subinventory_code;
             l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).locator_id;

             debug('Item ID: '||l_instance_query_rec.inventory_item_id);
             debug('Revision: '||l_instance_query_rec.inventory_revision);
             debug('Lot Number: '||l_instance_query_rec.lot_number);
             debug('Serial Number: '||l_instance_query_rec.serial_number);
             debug('Sub Inv: '||l_instance_query_rec.inv_subinventory_name);
             debug('Org ID: '||l_instance_query_rec.inv_organization_id);
             debug('Locator ID: '||l_instance_query_rec.inv_locator_id);

             debug('Before Get Dest Item Instance - 8');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 9');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count < 1 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'Y';
             l_new_dest_instance_rec.serial_number                :=  l_mtl_item_tbl(j).serial_number;
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  1;
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

		   l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             debug('Before Create Item Instance - 10');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

              debug('After Create Item Instance - 11');
              debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count > 0 THEN
             IF l_dest_instance_header_tbl(i).instance_usage_code in (l_in_inventory,l_in_transit,l_returned) THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  1;
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

-- START OF NEW CODE
        --Added for Bug 5975739
	l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
	l_update_dest_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
	l_update_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
	l_update_dest_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
	l_update_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
	l_update_dest_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
	l_update_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
	l_update_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
	l_update_dest_instance_rec.instance_usage_code          :=  l_in_inventory;

  	debug('Setting In Transit Serialized Instance to be IN INVENTORY usage');
	debug('Usage: '||l_update_dest_instance_rec.instance_usage_code);
	debug('VLD Org: '||l_update_dest_instance_rec.vld_organization_id);
	debug('INV Org: '||l_update_dest_instance_rec.inv_organization_id);
	debug('Subinv Code: '||l_update_dest_instance_rec.inv_subinventory_name);

-- END OF NEW CODE
               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

		     l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 13');

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 14');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

         ELSIF l_dest_instance_header_tbl(i).instance_usage_code = l_out_of_enterprise THEN

            IF l_ownership_party = 'Y' THEN
               debug('Update Serialized Item which is :'||l_dest_instance_header_tbl(i).instance_usage_code);
               debug('Serial Number is: '||l_dest_instance_header_tbl(i).serial_number);

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  1;
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

-- START OF NEW CODE
	-- Added for Bug 5975739
	l_update_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
	l_update_dest_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
	l_update_dest_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
	l_update_dest_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
	l_update_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
	l_update_dest_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
	l_update_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
	l_update_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
	l_update_dest_instance_rec.instance_usage_code          :=  l_in_inventory;

	debug('Setting OUT OF ENTERPRISE Serialized Instance to be IN INVENTORY usage because ownership flag is set to Y');
	debug('Usage: '||l_update_dest_instance_rec.instance_usage_code);
	debug('VLD Org: '||l_update_dest_instance_rec.vld_organization_id);
	debug('INV Org: '||l_update_dest_instance_rec.inv_organization_id);
	debug('Subinv Code: '||l_update_dest_instance_rec.inv_subinventory_name);

-- END OF NEW CODE

	  -- We want to change the party of this back
	  -- to the Internal Party

          debug('Usage is Out of Enterprise So we need to bring this back into Inventory and change the Owner Party back to the Internal Party');

  	   -- Set Instance ID so it will query the child recs for this
	   -- Instance.

	   l_instance_header_rec.instance_id := l_dest_instance_header_tbl(i).instance_id;
	    -- Call details to get Party Information
               csi_item_instance_pub.get_item_instance_details
                                              (l_api_version,
                                              l_commit,
                                              l_init_msg_list,
                                              l_validation_level,
                                              l_instance_header_rec,
                                              fnd_api.g_true,  -- Get Parties
                                              l_party_header_tbl,
                                              fnd_api.g_false,  -- Get Accounts
                                              l_account_header_tbl,
                                              fnd_api.g_false,  -- Get Org Assi.
                                              l_org_header_tbl,
                                              fnd_api.g_false,  -- Get Price Att
                                              l_pricing_header_tbl,
                                              fnd_api.g_false,  -- Get Ext Attr
                                              l_ext_attrib_header_tbl,
                                              l_ext_attrib_def_tbl,
                                              fnd_api.g_false, -- Get Asset Assi
                                              l_asset_header_tbl,
                                              fnd_api.g_false, -- Resolve IDs
                                              NULL,            -- Time Stamp
                                              l_return_status,
                                              l_msg_count,
                                              l_msg_data);

               -- Now create a new owner record that will be used to create
               -- the new owner party and set it back to an internal party owner
	       -- The PL/SQL Table will now be set so that it can be passed into
	       -- the next procedure.

               FOR p in l_party_header_tbl.FIRST .. l_party_header_tbl.LAST LOOP
                 IF l_party_header_tbl(p).relationship_type_code = 'OWNER' THEN

                 debug('Found the OWNER party so updating this back to the Internal Party ID');

                 l_party_tbl                   :=  csi_inv_trxs_pkg.init_party_tbl;
                 l_party_tbl(i).instance_id    :=  l_dest_instance_header_tbl(i).instance_id;
                 l_party_tbl(i).instance_party_id :=  l_party_header_tbl(p).instance_party_id;
                 l_party_tbl(i).object_version_number := l_party_header_tbl(p).object_version_number;

                 debug('After finding the OWNER party and updating this back to the Internal Party ID');

	         END IF;
               END LOOP;

               debug('Inst Party ID :'||l_party_tbl(i).instance_party_id);
               debug('Party Inst ID :'||l_party_tbl(i).instance_id);
               debug('Party Source Table :'||l_party_tbl(i).party_source_table);
               debug('Party ID :'||l_party_tbl(i).party_id);
               debug('Rel Type Code :'||l_party_tbl(i).relationship_type_code);
               debug('Contact Flag :'||l_party_tbl(i).contact_flag);
               debug('Object Version Number:' ||l_party_tbl(i).object_version_number);

           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;


	l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 13');

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After update of Out of Enterprise Item Instance');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('After Update Item Instance - 14');
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;
          ELSE
             l_status := 'In Inventory, Out of Service or Out of Enterprise';
             debug('Serialized Item with Out of Enterprise exists however the ownership_override_at_txn flag is set to N so we will NOT bring this back into inventory');
             debug('Instance Usage Code is: '||l_dest_instance_header_tbl(i).instance_usage_code);
             fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
             fnd_message.set_token('STATUS',l_status);
             l_error_message := fnd_message.get;
             l_return_status := l_fnd_error;
             RAISE fnd_api.g_exc_error;
           END IF;

          ELSE
	    l_status := 'IN_INVENTORY OR IN_TRANSIT';
	    debug('Serialized Item with a usage other then IN INVENTORY or IN TRANSIT exists.');
	    debug('Instance Usage Code is: '||l_dest_instance_header_tbl(i).instance_usage_code);
	    fnd_message.set_name('CSI','CSI_SERIALIZED_ITEM_EXISTS');
	    fnd_message.set_token('STATUS',l_status);
	    l_error_message := fnd_message.get;
	    RAISE fnd_api.g_exc_error;
	  END IF;
           END IF;    -- End of Destination Record If

      ELSIF l_mtl_item_tbl(j).serial_number_control_code = 1 AND
         l_sr_control in (2,5) THEN

             debug('Serial Control at Shipping is 2,5 and Receiving is 1');
             debug('Subtract Trans Qty from Existing Quantity First');
             debug('Instance being updated: '||l_src_instance_header_tbl(k).instance_id);

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.quantity                     :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
             l_update_instance_rec.active_end_date              :=  l_sysdate;
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

             debug('After you initialize the Update Record Values');
             debug('Instance Updated: '||l_update_instance_rec.instance_id);
             debug('End Date Passed in: '||to_char(l_update_instance_rec.active_end_date,'DD-MON-YYYY HH24:MI:SS'));
             debug('Object Version: '||l_update_instance_rec.object_version_number);
             debug('After you initialize the Update Record Values - 19');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 21');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 22');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('You are updating Serial Number: '||l_update_instance_rec.serial_number);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

           -- Now Query for Non Serialized In Inventory Record 1 Time Only
             debug('J is 1 so query for Non Serialized item 1 time - 23');

             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  NULL;
             l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).subinventory_code;
             l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
             l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
             l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).subinventory_code;
             l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).locator_id;

           debug('Before Get Dest Item Instance - 24');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 25');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

	     l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             debug('Before Create Item Instance - 26');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Item Instance - 27');
             debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

	       l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 29');
               debug('Transaction Type ID: '||l_txn_rec.transaction_type_id);

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 30');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

        END IF;    -- End of Destination Record If

      ELSIF l_mtl_item_tbl(j).serial_number_control_code = 6 AND
         l_sr_control in (2,5) THEN

        FOR k in l_src_instance_header_tbl.FIRST .. l_mtl_item_tbl(j).primary_quantity LOOP
             debug('Serial Control at Shipping is 2,5 and Receiving is 1,6');
             debug('Expire The Serialized Instance First');
             debug('Instance being updated: '||l_src_instance_header_tbl(k).instance_id);

             l_update_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_update_rec;
             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(k).instance_id;
             l_update_instance_rec.active_end_date              :=  l_sysdate;
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(k).object_version_number;

             debug('After you initialize the Update Record Values');
             debug('Instance Updated: '||l_update_instance_rec.instance_id);
             debug('End Date Passed in: '||to_char(l_update_instance_rec.active_end_date,'DD-MON-YYYY HH24:MI:SS'));
             debug('Object Version: '||l_update_instance_rec.object_version_number);
             debug('After you initialize the Update Record Values - 19');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 21');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 22');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('You are updating Serial Number: '||l_update_instance_rec.serial_number);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;
           END LOOP;  -- End Header Tbl and Trans Qty Loop

           -- Now Query for Non Serialized In Inventory Record 1 Time Only
           IF j = 1 THEN
             debug('J is 1 so query for Non Serialized item 1 time - 23');

             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  NULL;
             l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).subinventory_code;
             l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
             l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
             l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).subinventory_code;
             l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).locator_id;

             debug('Before Get Dest Item Instance - 24');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 25');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

		   l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             debug('Before Create Item Instance - 26');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Item Instance - 27');
             debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

	       l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 29');
               debug('Transaction Type ID: '||l_txn_rec.transaction_type_id);

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 30');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;

           END IF;    -- End of Destination Record If
         END IF;      -- End of J Index Loop

      ELSIF l_mtl_item_tbl(j).serial_number_control_code in (1,6) AND
         l_sr_control in (1,6) THEN

           debug('Serial Control at Shipping and Receiving are both 1,6');
           debug('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Item Instance - 35');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_upd_src_dest_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_upd_src_dest_instance_rec.instance_id;

           debug('After Update Item Instance - 36');
           debug('You are updating Instance: '||l_upd_src_dest_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

           -- Get Destination Record

             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;
             l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
             l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
             l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.serial_number                 :=  NULL;
             l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).subinventory_code;
             l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).organization_id;
             l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).locator_id;
             l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).subinventory_code;
             l_organization_id                                  :=  l_mtl_item_tbl(j).organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).locator_id;

             debug('Before Get Dest Item Instance - 37');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 38');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

 	     l_new_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

             debug('Instance Status Id: '||l_new_dest_instance_rec.instance_status_id);
             debug('Before Create Item Instance - 39');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

              debug('After Create Item Instance - 40');
              debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

		     l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 42');

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 43');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
       END IF;    -- End of Destination Record If

     ELSE -- No Records Found So throw Error
           debug('No Records were found in Install Base - 48');

           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

     END IF; -- Serial Control IF

   ELSE
     debug('No Records were found in Install Base - 49');

     fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
     fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
     fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
     fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
     fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
     l_error_message := fnd_message.get;
     RAISE fnd_api.g_exc_error;

     END IF; -- End of Main Source Header Tbl IF
     END LOOP;        -- End of For Loop


     debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('******End of csi_inv_interorg_pkg.intransit_receipt Transaction******');

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception in the Inter-Organization Transaction In Transit Receipt');
       x_return_status := l_fnd_error;

       IF l_mtl_item_tbl.count > 0 THEN
         x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
         x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
         x_trx_error_rec.instance_id := l_upd_error_instance_id;
         x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
         x_trx_error_rec.dst_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
         x_trx_error_rec.dst_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
         x_trx_error_rec.dst_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
         x_trx_error_rec.dst_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
         x_trx_error_rec.src_serial_num_ctrl_code := r_item_control.serial_number_control_code;
         x_trx_error_rec.src_location_ctrl_code := r_item_control.location_control_code;
         x_trx_error_rec.src_lot_ctrl_code := r_item_control.lot_control_code;
         x_trx_error_rec.src_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIORGTR';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;
        debug('You have encountered a "when others" exception in the Inter-Organization Transaction In Transit Receipt');
        debug('SQL Error: '||l_sql_error);
        fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
        fnd_message.set_token('API_NAME',l_api_name);
        fnd_message.set_token('SQL_ERROR',SQLERRM);
        x_return_status := l_fnd_unexpected;

        IF l_mtl_item_tbl.count > 0 THEN
          x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
          x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
          x_trx_error_rec.instance_id := l_upd_error_instance_id;
          x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
          x_trx_error_rec.dst_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
          x_trx_error_rec.dst_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
          x_trx_error_rec.dst_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
          x_trx_error_rec.dst_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
          x_trx_error_rec.src_serial_num_ctrl_code := r_item_control.serial_number_control_code;
          x_trx_error_rec.src_location_ctrl_code := r_item_control.location_control_code;
          x_trx_error_rec.src_lot_ctrl_code := r_item_control.lot_control_code;
          x_trx_error_rec.src_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
          x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
          x_trx_error_rec.transaction_error_date := l_sysdate ;
        END IF;

        x_trx_error_rec.error_text := fnd_message.get;
        x_trx_error_rec.transaction_id       := NULL;
        x_trx_error_rec.source_type          := 'CSIORGTR';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

   END intransit_receipt;


   PROCEDURE direct_shipment(p_transaction_id     IN  NUMBER,
                             p_message_id         IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC)
   IS

   l_mtl_item_tbl               CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE;
   l_api_name                   VARCHAR2(100)   := 'CSI_INV_INTERORG_PKG.DIRECT_SHIPMENT';
   l_api_version                NUMBER          := 1.0;
   l_commit                     VARCHAR2(1)     := FND_API.G_FALSE;
   l_init_msg_list              VARCHAR2(1)     := FND_API.G_TRUE;
   l_validation_level           NUMBER          := FND_API.G_VALID_LEVEL_FULL;
   l_active_instance_only       VARCHAR2(10)    := FND_API.G_TRUE;
   l_inactive_instance_only     VARCHAR2(10)    := FND_API.G_FALSE;
   l_transaction_id             NUMBER          := NULL;
   l_resolve_id_columns         VARCHAR2(10)    := FND_API.G_FALSE;
   l_object_version_number      NUMBER          := 1;
   l_sysdate                    DATE            := SYSDATE;
   l_master_organization_id     NUMBER;
   l_depreciable                VARCHAR2(1);
   l_txn_error_rec              CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
   l_instance_query_rec         CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_dest_instance_query_rec    CSI_DATASTRUCTURES_PUB.INSTANCE_QUERY_REC;
   l_update_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_upd_src_dest_instance_rec  CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_update_dest_instance_rec   CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_instance_rec           CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_dest_instance_rec      CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_new_src_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
   l_txn_rec                    CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
   l_return_status              VARCHAR2(1);
   l_error_code                 VARCHAR2(50);
   l_error_message              VARCHAR2(4000);
   l_instance_id_lst            CSI_DATASTRUCTURES_PUB.ID_TBL;
   l_party_query_rec            CSI_DATASTRUCTURES_PUB.PARTY_QUERY_REC;
   l_account_query_rec          CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_QUERY_REC;
   l_instance_header_tbl        CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_src_instance_header_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_dest_instance_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_TBL;
   l_ext_attrib_values_tbl      CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
   l_party_tbl                  CSI_DATASTRUCTURES_PUB.PARTY_TBL;
   l_account_tbl                CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
   l_pricing_attrib_tbl         CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
   l_org_assignments_tbl        CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
   l_asset_assignment_tbl       CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
   l_sub_inventory              VARCHAR2(10);
   l_location_type              VARCHAR2(20);
   l_trx_action_type            VARCHAR2(50);
   l_fnd_success                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_fnd_warning                VARCHAR2(1) := 'W';
   l_fnd_error                  VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_fnd_unexpected             VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   l_in_inventory               VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_INVENTORY;
   l_in_process                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_PROCESS;
   l_out_of_service             VARCHAR2(25) := CSI_INV_TRXS_PKG.G_OUT_OF_SERVICE;
   l_in_service                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_SERVICE;
   l_in_transit                 VARCHAR2(25) := CSI_INV_TRXS_PKG.G_IN_TRANSIT;
   l_installed                  VARCHAR2(25) := CSI_INV_TRXS_PKG.G_INSTALLED;
   l_fnd_g_num                  NUMBER      := FND_API.G_MISS_NUM;
   l_fnd_g_char                 VARCHAR2(1) := FND_API.G_MISS_CHAR;
   l_fnd_g_date                 DATE        := FND_API.G_MISS_DATE;
   l_instance_usage_code        VARCHAR2(25);
   l_organization_id            NUMBER;
   l_subinventory_name          VARCHAR2(10);
   l_locator_id                 NUMBER;
   l_transaction_error_id       NUMBER;
   l_quantity                   NUMBER;
   l_trx_type_id                NUMBER;
   l_mfg_serial_flag            VARCHAR2(1);
   l_serial_number              VARCHAR2(30);
   l_trans_type_code            VARCHAR2(25);
   l_trans_app_code             VARCHAR2(5);
   l_employee_id                NUMBER;
   l_file                       VARCHAR2(500);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_sql_error                  VARCHAR2(2000);
   l_msg_index                  NUMBER;
   j                            PLS_INTEGER;
   k                            PLS_INTEGER := 1;
   i                            PLS_INTEGER :=1;
   l_tbl_count                  NUMBER := 0;
   l_neg_code                   NUMBER := 0;
   l_instance_status            VARCHAR2(1);
   l_sr_control                 NUMBER := 0;
   l_redeploy_flag              VARCHAR2(1);
   l_upd_error_instance_id      NUMBER := NULL;

   cursor c_id is
     SELECT instance_status_id
     FROM   csi_instance_statuses
     WHERE  name = FND_PROFILE.VALUE('CSI_DEFAULT_INSTANCE_STATUS');

   r_id     c_id%rowtype;

   -- Get the Transaction ID for the (-) quantity transaction and pass that
   -- instead of the (+) transaction ID. This is done so that the hook will be
   -- called after the second transaction is processed with the (+) qty and
   -- will prevent any timing issues with the transaction manager

   CURSOR c_mtl is
      SELECT transfer_transaction_id,
             transaction_action_id,
             transaction_type_id,
             transaction_source_type_id,
             transaction_quantity
	 FROM mtl_material_transactions
	 WHERE transaction_id = p_transaction_id;

   r_mtl     c_mtl%rowtype;

   CURSOR c_item_control (pc_item_id in number,
                          pc_org_id in number) is
     SELECT serial_number_control_code,
            lot_control_code,
            revision_qty_control_code,
            location_control_code,
            comms_nl_trackable_flag
     FROM mtl_system_items_b
     WHERE inventory_item_id = pc_item_id
     AND organization_id = pc_org_id;

   r_item_control     c_item_control%rowtype;

   CURSOR c_loc_ids (pc_org_id IN NUMBER,
                     pc_subinv_name IN VARCHAR2) is
    SELECT haou.location_id hr_location_id,
           msi.location_id  subinv_location_id
    FROM hr_all_organization_units haou,
         mtl_secondary_inventories msi
    WHERE haou.organization_id = pc_org_id
    AND msi.organization_id = pc_org_id
    AND msi.secondary_inventory_name = pc_subinv_name;

    r_loc_ids     c_loc_ids%rowtype;

   BEGIN

     x_return_status := l_fnd_success;
     l_error_message := NULL;

     debug('******Start of csi_inv_interorg_pkg.direct_shipment Transaction procedure******');
     debug('Start time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     debug('csiorgtb.pls 115.23');
     debug('Transaction ID with is: '||p_transaction_id);

	-- This will open the cursor and fetch the (-) transaction ID
     OPEN c_mtl;
     FETCH c_mtl into r_mtl;
     CLOSE c_mtl;

     debug('Direct Interorg Transfer using Trasfer Trans ID');
     debug('Transaction ID with (+) is: '||p_transaction_id);
     debug('Transaction ID with (-) is: '||r_mtl.transfer_transaction_id);


     -- This procedure queries all of the Inventory Transaction Records and
	-- returns them as a table.

     csi_inv_trxs_pkg.get_transaction_recs(r_mtl.transfer_transaction_id,
                                           l_mtl_item_tbl,
                                           l_return_status,
                                           l_error_message);

     l_tbl_count := 0;
     l_tbl_count := l_mtl_item_tbl.count;
     debug('Inventory Records Found: '||l_tbl_count);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in CSI_INV_TRXS_PKG.get_transaction_recs, Transaction ID: '||r_mtl.transfer_transaction_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Get the Master Organization ID
     csi_inv_trxs_pkg.get_master_organization(l_mtl_item_tbl(i).organization_id,
                                          l_master_organization_id,
                                          l_return_status,
                                          l_error_message);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in csi_inv_trxs_pkg.get_master_organization, Organization ID: '||l_mtl_item_tbl(i).organization_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Call get_fnd_employee_id and get the employee id
     l_employee_id := csi_inv_trxs_pkg.get_fnd_employee_id(l_mtl_item_tbl(i).last_updated_by);

     IF l_employee_id = -1 THEN
       debug('The person who last updated this record: '||l_mtl_item_tbl(i).last_updated_by||' does not exist as a valid employee');
     END IF;

     debug('The Employee that is processing this Transaction is: '||l_employee_id);

     -- See if this is a depreciable Item to set the status of the transaction record
     csi_inv_trxs_pkg.check_depreciable(l_mtl_item_tbl(i).inventory_item_id,
     	                               l_depreciable);

     debug('Is this Item ID: '||l_mtl_item_tbl(i).inventory_item_id||', Depreciable :'||l_depreciable);

     -- Set the quantity
     IF l_mtl_item_tbl(i).serial_number IS NULL THEN
       l_quantity        := l_mtl_item_tbl(i).transaction_quantity;
     ELSE
       l_quantity        := 1;
     END IF;

	-- Get the Negative Receipt Code to see if this org allows Negative
	-- Quantity Records 1 = Yes, 2 = No

	l_neg_code := csi_inv_trxs_pkg.get_neg_inv_code(
						  l_mtl_item_tbl(i).organization_id);


     debug('Negative Code is - 1 = Yes, 2 = No: '||l_neg_code);

     -- Determine Transaction Type for this

     l_trans_type_code := 'INTERORG_DIRECT_SHIP';
     l_trans_app_code := 'INV';

     debug('Trans Type Code: '||l_trans_type_code);
     debug('Trans App Code: '||l_trans_app_code);

     -- Initialize Transaction Record
     l_txn_rec                          := csi_inv_trxs_pkg.init_txn_rec;

     -- Set Status based on redeployment
     IF l_depreciable = 'N' THEN
       IF l_mtl_item_tbl(i).serial_number is NOT NULL THEN
         csi_inv_trxs_pkg.get_redeploy_flag(l_mtl_item_tbl(i).inventory_item_id,
                                            l_mtl_item_tbl(i).serial_number,
                                            l_sysdate,
                                            l_redeploy_flag,
                                            l_return_status,
                                            l_error_message);
       END IF;
       IF l_redeploy_flag = 'Y' THEN
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
       ELSE
         l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_complete;
       END IF;
     ELSE
       l_txn_rec.transaction_status_code := csi_inv_trxs_pkg.g_pending;
     END IF;

     IF NOT l_return_status = l_fnd_success THEN
       debug('Redeploy Flag: '||l_redeploy_flag);
       debug('You have encountered an error in csi_inv_trxs_pkg.get_redeploy_flag: '||l_error_message);
       RAISE fnd_api.g_exc_error;
     END IF;

    debug('Redeploy Flag: '||l_redeploy_flag);
    debug('Trans Status Code: '||l_txn_rec.transaction_status_code);

    -- Get Default Profile Instance Status
    OPEN c_id;
    FETCH c_id into r_id;
    CLOSE c_id;

    debug('Default Profile Status: '||r_id.instance_status_id);

     -- Create CSI Transaction to be used
     l_txn_rec.source_transaction_date  := l_mtl_item_tbl(i).transaction_date;
     l_txn_rec.transaction_date         := l_sysdate;
     l_txn_rec.transaction_type_id      :=
          csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
     l_txn_rec.transaction_quantity     :=
          l_mtl_item_tbl(i).transaction_quantity;
     l_txn_rec.transaction_uom_code     :=  l_mtl_item_tbl(i).transaction_uom;
     l_txn_rec.transacted_by            :=  l_employee_id;
     l_txn_rec.transaction_action_code  :=  NULL;
     l_txn_rec.message_id               :=  p_message_id;
     l_txn_rec.inv_material_transaction_id  :=  p_transaction_id;
     l_txn_rec.object_version_number        :=  l_object_version_number;

     csi_inv_trxs_pkg.create_csi_txn(l_txn_rec,
                                     l_error_message,
                                     l_return_status);

     debug('CSI Transaction Created: '||l_txn_rec.transaction_id);

     IF NOT l_return_status = l_fnd_success THEN
       debug('You have encountered an error in csi_inv_trxs_pkg.create_csi_txn: '||p_transaction_id);
       RAISE fnd_api.g_exc_error;
     END IF;

     -- Now loop through the PL/SQL Table.
     j := 1;

     debug('Starting to loop through Material Transaction Records');

     FOR j in l_mtl_item_tbl.FIRST .. l_mtl_item_tbl.LAST LOOP

        debug('Primary UOM: '||l_mtl_item_tbl(j).primary_uom_code);
        debug('Primary Qty: '||l_mtl_item_tbl(j).primary_quantity);
        debug('Transaction UOM: '||l_mtl_item_tbl(j).transaction_uom);
        debug('Transaction Qty: '||l_mtl_item_tbl(j).transaction_quantity);
        debug('Organization ID: '||l_mtl_item_tbl(j).organization_id);
        debug('Transfer Org ID: '||l_mtl_item_tbl(j).transfer_organization_id);
        debug('Transfer Subinv: '||l_mtl_item_tbl(j).transfer_subinventory);

     -- Get Receiving Organization Serial Control Code
     OPEN c_item_control (l_mtl_item_tbl(j).inventory_item_id,
                        l_mtl_item_tbl(j).transfer_organization_id);
     FETCH c_item_control into r_item_control;
     CLOSE c_item_control;

     l_sr_control := r_item_control.serial_number_control_code;

     debug('Serial Number : '||l_mtl_item_tbl(j).serial_number);
     debug('l_sr_control is: '||l_sr_control);
     debug('Shipping Org Serial Number Control Code: '||l_mtl_item_tbl(j).serial_number_control_code);
     debug('Receiving Org Serial Number Control Code: '||r_item_control.serial_number_control_code);
     debug('Shipping Org Lot Control Code: '||l_mtl_item_tbl(j).lot_control_code);
     debug('Receiving Org Lot Control Code: '||r_item_control.lot_control_code);
     debug('Shipping Org Loction Control Code: '||l_mtl_item_tbl(j).location_control_code);
     debug('Receiving Org Location Control Code: '||r_item_control.location_control_code);
     debug('Shipping Org Revision Control Code: '||l_mtl_item_tbl(j).revision_qty_control_code);
     debug('Receiving Org Revision Control Code: '||r_item_control.revision_qty_control_code);
     debug('Receiving Org Trackable Flag: '||r_item_control.comms_nl_trackable_flag);

	-- Set Query Instance Status
     IF l_neg_code = 1 AND l_mtl_item_tbl(j).serial_number_control_code in (1,6)  THEN
	 l_instance_status := FND_API.G_FALSE;
     ELSE
	 l_instance_status := FND_API.G_TRUE;
     END IF;

        debug('Query Inst Status : '||l_instance_status);

     -- Get the Location Ids for Receiving Org
     OPEN c_loc_ids (l_mtl_item_tbl(j).transfer_organization_id,
                     l_mtl_item_tbl(j).transfer_subinventory);
     FETCH c_loc_ids into r_loc_ids;
     CLOSE c_loc_ids;

     debug('Transfer Subinv Location: '||r_loc_ids.subinv_location_id);
     debug('Transfer HR Location    : '||r_loc_ids.hr_location_id);

         l_instance_query_rec                                 :=  csi_inv_trxs_pkg.init_instance_query_rec;
         l_instance_usage_code                                :=  l_fnd_g_char;

       --Direct Shipment Item

         l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
         l_instance_query_rec.inv_organization_id             :=  l_mtl_item_tbl(j).organization_id;
         l_instance_query_rec.serial_number                   :=  l_mtl_item_tbl(j).serial_number;
         l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
         l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
         l_instance_query_rec.inv_subinventory_name           :=  l_mtl_item_tbl(j).subinventory_code;
         --l_instance_query_rec.unit_of_measure                 :=  l_mtl_item_tbl(j).transaction_uom;
         l_instance_query_rec.inv_locator_id                  :=  l_mtl_item_tbl(j).locator_id;
         l_instance_query_rec.instance_usage_code             :=  l_in_inventory;
         l_trx_action_type := 'DIRECT_SHIPMENT';
         l_instance_usage_code:= l_instance_query_rec.instance_usage_code;

       --Setting Query for Shipping Org Serial Control
       IF l_mtl_item_tbl(j).serial_number_control_code in (1,6) THEN
         l_instance_query_rec.serial_number := l_fnd_g_char;
         debug('Shipping org is 1,6 so set to NULL');
       END IF;

       debug('Transaction Action Type:'|| l_trx_action_type);
       debug('Before Get Item Instance');

       csi_item_instance_pub.get_item_instances(l_api_version,
                                                l_commit,
                                                l_init_msg_list,
                                                l_validation_level,
                                                l_instance_query_rec,
                                                l_party_query_rec,
                                                l_account_query_rec,
                                                l_transaction_id,
                                                l_resolve_id_columns,
					        l_instance_status,
                                                l_src_instance_header_tbl,
                                                l_return_status,
                                                l_msg_count,
                                                l_msg_data);

       debug('After Get Item Instance');

       l_tbl_count := 0;
       l_tbl_count := l_src_instance_header_tbl.count;

       debug('Source Records Found: '||l_tbl_count);

       -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
       IF NOT l_return_status = l_fnd_success then
         debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
         l_msg_index := 1;
           WHILE l_msg_count > 0 loop
	     l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	     l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
  	   END LOOP;
	   RAISE fnd_api.g_exc_error;
       END IF;

       debug('Before checking to see if Source records Exist - 1');

       IF l_mtl_item_tbl(j).serial_number_control_code in (2,5) AND -- Ship
		l_sr_control in (2,5) THEN       -- Rec
          IF l_src_instance_header_tbl.count > 0 THEN

          debug('Shipping Serial Control is 5 and Rec Serial Control 2,5');
          debug('Updating Serialized Instance: '||l_mtl_item_tbl(j).serial_number);
          debug('After you determine this is a Direct Shipment');
          debug('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);

          l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
	  -- Added for Bug 5975739
	  l_update_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
          l_update_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
          l_update_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).transfer_organization_id;
          l_update_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).transfer_subinventory;
          l_update_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).transfer_locator_id;
          l_update_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
          l_update_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
          l_update_instance_rec.instance_usage_code          :=  l_in_inventory;
          l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

          debug('After you initialize the Transaction Record Values - 2');
          debug('After the update for Direct Shipment is set.');
          debug('Transfer Org: '||l_update_instance_rec.inv_organization_id);
          debug('Source Org: '||l_mtl_item_tbl(j).organization_id);

          l_party_tbl.delete;
          l_account_tbl.delete;
          l_pricing_attrib_tbl.delete;
          l_org_assignments_tbl.delete;
          l_asset_assignment_tbl.delete;

          debug('Before Update Item Instance - 3');

          csi_item_instance_pub.update_item_instance(l_api_version,
                                                     l_commit,
                                                     l_init_msg_list,
                                                     l_validation_level,
                                                     l_update_instance_rec,
                                                     l_ext_attrib_values_tbl,
                                                     l_party_tbl,
                                                     l_account_tbl,
                                                     l_pricing_attrib_tbl,
                                                     l_org_assignments_tbl,
                                                     l_asset_assignment_tbl,
                                                     l_txn_rec,
                                                     l_instance_id_lst,
                                                     l_return_status,
                                                     l_msg_count,
                                                     l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 4');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

	   ELSE -- No Src Records found so error

             debug('No Records were found in Install Base - 5');
             fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
             fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
             fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
             l_error_message := fnd_message.get;
             RAISE fnd_api.g_exc_error;
	   END IF;  -- End of 5 and 2,5 IF

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	      l_sr_control = 6) OR  -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	      l_sr_control = 1) OR  -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 1) THEN  -- Rec

            debug('Shipping and Rec Serial Control are both 1,6');

         IF l_src_instance_header_tbl.count = 0 THEN
           IF l_neg_code = 1 THEN  -- Allow Neg Qtys on NON Serial Items ONLY

           debug('No records were found so create a new Source Instance Record - 6');

           l_new_src_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
           l_new_src_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
           l_new_src_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
           l_new_src_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
           l_new_src_instance_rec.mfg_serial_number_flag       :=  'N';
           l_new_src_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
           l_new_src_instance_rec.quantity                     :=  l_mtl_item_tbl(j).transaction_quantity;
           l_new_src_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
           l_new_src_instance_rec.location_id                  :=  nvl(l_mtl_item_tbl(j).subinv_location_id,l_mtl_item_tbl(j).hr_location_id);
           l_new_src_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
           l_new_src_instance_rec.instance_usage_code          :=  l_instance_usage_code;
           l_new_src_instance_rec.inv_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_src_instance_rec.vld_organization_id          :=  l_mtl_item_tbl(j).organization_id;
           l_new_src_instance_rec.inv_subinventory_name        :=  l_mtl_item_tbl(j).subinventory_code;
           l_new_src_instance_rec.inv_locator_id               :=  l_mtl_item_tbl(j).locator_id;
           l_new_src_instance_rec.customer_view_flag           :=  'N';
           l_new_src_instance_rec.merchant_view_flag           :=  'Y';
           l_new_src_instance_rec.operational_status_code      :=  'NOT_USED';
           l_new_src_instance_rec.object_version_number        :=  l_object_version_number;
           l_new_src_instance_rec.active_start_date            :=  l_sysdate;
           l_new_src_instance_rec.active_end_date              :=  NULL;

           l_ext_attrib_values_tbl  :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
           l_party_tbl              :=  csi_inv_trxs_pkg.init_party_tbl;
           l_account_tbl            :=  csi_inv_trxs_pkg.init_account_tbl;
           l_pricing_attrib_tbl     :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
           l_org_assignments_tbl    :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
           l_asset_assignment_tbl   :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

           debug('Before Create Source Item Instance - 7');

           csi_item_instance_pub.create_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_new_src_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);


             debug('After Create Source Item Instance - 8');
             debug('You are Creating Instance: '||l_new_src_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;
	 ELSE -- Inv Does not allowe neg qty and source is not found
           debug('No Records were found in Install Base - 9');
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;

       END IF; -- End of Neg Qty IF
    ELSIF l_src_instance_header_tbl.count = 1 THEN -- Source Records are found

           debug('Source Recs found so update or unexpire existing Non Serial Instance ');

           -- Source Records are there so update and unexpire

           debug('You will update instance: '||l_src_instance_header_tbl(i).instance_id);

           l_upd_src_dest_instance_rec                        :=  csi_inv_trxs_pkg.init_instance_update_rec;
           l_upd_src_dest_instance_rec.instance_id            :=  l_src_instance_header_tbl(i).instance_id;
           l_upd_src_dest_instance_rec.active_end_date        :=  NULL;
           l_upd_src_dest_instance_rec.quantity               :=  l_src_instance_header_tbl(i).quantity - abs(l_mtl_item_tbl(j).primary_quantity);
           l_upd_src_dest_instance_rec.object_version_number  :=  l_src_instance_header_tbl(i).object_version_number;

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

           debug('Before Update Source Item Instance - 10');
           debug(r_id.instance_status_id);
           debug('Before Update Source Item Instance - 11');

   	   l_upd_src_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

           debug('Before Update Source Item Instance - 11');
           debug(l_upd_src_dest_instance_rec.instance_status_id);

             debug('Instance Status Id: '||l_upd_src_dest_instance_rec.instance_status_id);

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_upd_src_dest_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_upd_src_dest_instance_rec.instance_id;

           debug('After Update Item Instance - 11');
           debug('You are updating Instance: '||l_upd_src_dest_instance_rec.instance_id);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;

          ELSE -- Error No Src Recs and Inv Does not allow neg qtys
           debug('No Records were found in Install Base - 12');
           fnd_message.set_name('CSI','CSI_IB_RECORD_NOTFOUND');
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           fnd_message.set_token('SUBINVENTORY',l_mtl_item_tbl(j).subinventory_code);
           fnd_message.set_token('ORG_ID',l_mtl_item_tbl(j).organization_id);
           fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
           l_error_message := fnd_message.get;
           RAISE fnd_api.g_exc_error;
       END IF;  -- End of If for Main Source

	   -- Get Destination Records

           l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;

           l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
           l_instance_query_rec.inventory_item_id             :=  l_mtl_item_tbl(j).inventory_item_id;
           l_instance_query_rec.inventory_revision            :=  l_mtl_item_tbl(j).revision;
           l_instance_query_rec.lot_number                    :=  l_mtl_item_tbl(j).lot_number;
           l_instance_query_rec.serial_number                 :=  NULL;
           l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).transfer_subinventory;
           l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).transfer_organization_id;
           l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).transfer_locator_id;
           l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
           l_subinventory_name                                :=  l_mtl_item_tbl(j).transfer_subinventory;
           l_organization_id                                  :=  l_mtl_item_tbl(j).transfer_organization_id;
           l_locator_id                                       :=  l_mtl_item_tbl(j).transfer_locator_id;

           debug('Before Get Item Instance - 13');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 14');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             debug('Creating New Dest dest Instance - 15');

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             debug('Before Create Item Instance - 16');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Item Instance - 17');
             debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

	       l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 19');


               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

             l_upd_error_instance_id := NULL;
             l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

             debug('After Update Item Instance - 20');
             debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
             debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
       END IF;    -- End of Destination Record If

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
		l_sr_control = 1) OR   -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
		l_sr_control = 1) THEN -- Rec

            debug('Shipping is 2,5 and and Rec Serial Control is 1');
--HERE TODAY
   --     FOR k in l_src_instance_header_tbl.FIRST .. abs(l_mtl_item_tbl(j).transaction_quantity) LOOP
    --            debug('k is: '||k);
    --            debug('You will loop: '||abs(l_mtl_item_tbl(j).transaction_quantity)||' times');

             debug('Serial Control at Shipping is 2,5 and Receiving is 1,6');
             debug('Expire The Serialized Instance First');
             debug('Instance being updated: '||l_src_instance_header_tbl(i).instance_id);

             l_update_instance_rec.instance_id                  :=  l_src_instance_header_tbl(i).instance_id;
             l_update_instance_rec.active_end_date              :=  l_sysdate;
             l_update_instance_rec.object_version_number        :=  l_src_instance_header_tbl(i).object_version_number;

             debug('After you initialize the Update Record Values');
             debug('After you initialize the Transaction Record Values');

           l_party_tbl.delete;
           l_account_tbl.delete;
           l_pricing_attrib_tbl.delete;
           l_org_assignments_tbl.delete;
           l_asset_assignment_tbl.delete;

              debug('Before Update Item Instance - 25');

           csi_item_instance_pub.update_item_instance(l_api_version,
                                                      l_commit,
                                                      l_init_msg_list,
                                                      l_validation_level,
                                                      l_update_instance_rec,
                                                      l_ext_attrib_values_tbl,
                                                      l_party_tbl,
                                                      l_account_tbl,
                                                      l_pricing_attrib_tbl,
                                                      l_org_assignments_tbl,
                                                      l_asset_assignment_tbl,
                                                      l_txn_rec,
                                                      l_instance_id_lst,
                                                      l_return_status,
                                                      l_msg_count,
                                                      l_msg_data);

           l_upd_error_instance_id := NULL;
           l_upd_error_instance_id := l_update_instance_rec.instance_id;

           debug('After Update Item Instance - 26');
           debug('You are updating Instance: '||l_update_instance_rec.instance_id);
           debug('You are updating Serial Number: '||l_update_instance_rec.serial_number);
           debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
             debug('You encountered an error in the csi_item_instance_pub.update_item_instance API '||l_msg_data);
             l_msg_index := 1;
               WHILE l_msg_count > 0 loop
	         l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	         l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
  	       END LOOP;
	       RAISE fnd_api.g_exc_error;
           END IF;
  --      END LOOP; -- End For Loop for Update of Sr Instances

        -- Now Query for Non Serialized In Inventory Record 1 Time Only
        IF j = 1 THEN

             l_instance_query_rec                               :=  csi_inv_trxs_pkg.init_instance_query_rec;

             l_instance_query_rec.instance_usage_code           :=  l_in_inventory;
             l_instance_query_rec.inventory_item_id               :=  l_mtl_item_tbl(j).inventory_item_id;
             l_instance_query_rec.inventory_revision              :=  l_mtl_item_tbl(j).revision;
             l_instance_query_rec.lot_number                      :=  l_mtl_item_tbl(j).lot_number;
             l_instance_query_rec.inv_subinventory_name         :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_instance_query_rec.inv_organization_id           :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_instance_query_rec.inv_locator_id                :=  l_mtl_item_tbl(j).transfer_locator_id;
             l_instance_usage_code                              :=  l_instance_query_rec.instance_usage_code;
             l_subinventory_name                                :=  l_mtl_item_tbl(j).transfer_subinventory;
             l_organization_id                                  :=  l_mtl_item_tbl(j).transfer_organization_id;
             l_locator_id                                       :=  l_mtl_item_tbl(j).transfer_locator_id;

           debug('Before Get Item Instance - 27');

           csi_item_instance_pub.get_item_instances(l_api_version,
                                                    l_commit,
                                                    l_init_msg_list,
                                                    l_validation_level,
                                                    l_instance_query_rec,
                                                    l_party_query_rec,
                                                    l_account_query_rec,
                                                    l_transaction_id,
                                                    l_resolve_id_columns,
                                                    l_inactive_instance_only,
                                                    l_dest_instance_header_tbl,
                                                    l_return_status,
                                                    l_msg_count,
                                                    l_msg_data);

           debug('After Get Item Instance - 28');

           l_tbl_count := 0;
           l_tbl_count :=  l_dest_instance_header_tbl.count;

           debug('Source Records Found: '||l_tbl_count);

           -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
           IF NOT l_return_status = l_fnd_success then
             debug('You encountered an error in the csi_item_instance_pub.get_item_instance API '||l_msg_data);
             l_msg_index := 1;
	         WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
           END IF;

           IF l_dest_instance_header_tbl.count = 0 THEN  -- Installed Base Destination Records are not found so create a new record

             debug('Creating New Dest dest Instance - 29');

             l_new_dest_instance_rec                              :=  csi_inv_trxs_pkg.init_instance_create_rec;
             l_new_dest_instance_rec.inventory_item_id            :=  l_mtl_item_tbl(j).inventory_item_id;
             l_new_dest_instance_rec.inventory_revision           :=  l_mtl_item_tbl(j).revision;
             l_new_dest_instance_rec.inv_master_organization_id   :=  l_master_organization_id;
             l_new_dest_instance_rec.mfg_serial_number_flag       :=  'N';
             l_new_dest_instance_rec.lot_number                   :=  l_mtl_item_tbl(j).lot_number;
             l_new_dest_instance_rec.quantity                     :=  abs(l_mtl_item_tbl(j).transaction_quantity);
             l_new_dest_instance_rec.unit_of_measure              :=  l_mtl_item_tbl(j).transaction_uom;
             l_new_dest_instance_rec.location_id                  :=  nvl(r_loc_ids.subinv_location_id,r_loc_ids.hr_location_id);
             l_new_dest_instance_rec.location_type_code           :=  csi_inv_trxs_pkg.get_location_type_code('Inventory');
             l_new_dest_instance_rec.instance_usage_code          :=  l_instance_usage_code;
             l_new_dest_instance_rec.inv_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.vld_organization_id          :=  l_organization_id;
             l_new_dest_instance_rec.inv_subinventory_name        :=  l_subinventory_name;
             l_new_dest_instance_rec.inv_locator_id               :=  l_locator_id;
             l_new_dest_instance_rec.customer_view_flag           :=  'N';
             l_new_dest_instance_rec.merchant_view_flag           :=  'Y';
             l_new_dest_instance_rec.operational_status_code      :=  'NOT_USED';
             l_new_dest_instance_rec.object_version_number        :=  l_object_version_number;
             l_new_dest_instance_rec.active_start_date            :=  l_sysdate;
             l_new_dest_instance_rec.active_end_date              :=  NULL;

             l_ext_attrib_values_tbl                              :=  csi_inv_trxs_pkg.init_ext_attrib_values_tbl;
             l_party_tbl                                          :=  csi_inv_trxs_pkg.init_party_tbl;
             l_account_tbl                                        :=  csi_inv_trxs_pkg.init_account_tbl;
             l_pricing_attrib_tbl                                 :=  csi_inv_trxs_pkg.init_pricing_attribs_tbl;
             l_org_assignments_tbl                                :=  csi_inv_trxs_pkg.init_org_assignments_tbl;
             l_asset_assignment_tbl                               :=  csi_inv_trxs_pkg.init_asset_assignment_tbl;

             debug('Before Create Item Instance - 30');

             csi_item_instance_pub.create_item_instance(l_api_version,
                                                        l_commit,
                                                        l_init_msg_list,
                                                        l_validation_level,
                                                        l_new_dest_instance_rec,
                                                        l_ext_attrib_values_tbl,
                                                        l_party_tbl,
                                                        l_account_tbl,
                                                        l_pricing_attrib_tbl,
                                                        l_org_assignments_tbl,
                                                        l_asset_assignment_tbl,
                                                        l_txn_rec,
                                                        l_return_status,
                                                        l_msg_count,
                                                        l_msg_data);

             debug('After Create Item Instance - 31');
             debug('You are Creating Instance: '||l_new_dest_instance_rec.instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.

             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.create_item_instance API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
  	         END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

           ELSIF l_dest_instance_header_tbl.count = 1 THEN -- Installed Base Destination Records Found

               l_update_dest_instance_rec                         :=  csi_inv_trxs_pkg.init_instance_update_rec;
               l_update_dest_instance_rec.instance_id             :=  l_dest_instance_header_tbl(i).instance_id;
               l_update_dest_instance_rec.quantity                :=  l_dest_instance_header_tbl(i).quantity + abs(l_mtl_item_tbl(j).primary_quantity);
               l_update_dest_instance_rec.active_end_date         :=  NULL;
               l_update_dest_instance_rec.object_version_number   :=  l_dest_instance_header_tbl(i).object_version_number;

               l_party_tbl.delete;
               l_account_tbl.delete;
               l_pricing_attrib_tbl.delete;
               l_org_assignments_tbl.delete;
               l_asset_assignment_tbl.delete;

		     l_update_dest_instance_rec.instance_status_id := nvl(csi_inv_trxs_pkg.get_default_status_id(l_txn_rec.transaction_type_id),r_id.instance_status_id);

               debug('Instance Status Id: '||l_update_dest_instance_rec.instance_status_id);
               debug('Before Update Item Instance - 32');

               csi_item_instance_pub.update_item_instance(l_api_version,
                                                          l_commit,
                                                          l_init_msg_list,
                                                          l_validation_level,
                                                          l_update_dest_instance_rec,
                                                          l_ext_attrib_values_tbl,
                                                          l_party_tbl,
                                                          l_account_tbl,
                                                          l_pricing_attrib_tbl,
                                                          l_org_assignments_tbl,
                                                          l_asset_assignment_tbl,
                                                          l_txn_rec,
                                                          l_instance_id_lst,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);

              l_upd_error_instance_id := NULL;
              l_upd_error_instance_id := l_update_dest_instance_rec.instance_id;

              debug('After Update Item Instance - 33');
              debug('You are updating Instance: '||l_update_dest_instance_rec.instance_id);
              debug('l_upd_error_instance_id is: '||l_upd_error_instance_id);

             -- Check for any errors and add them to the message stack to pass out to be put into the error log table.
             IF NOT l_return_status in (l_fnd_success,l_fnd_warning) then
               debug('You encountered an error in the csi_item_instance_pub.c API '||l_msg_data);
               l_msg_index := 1;
                 WHILE l_msg_count > 0 loop
	           l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
                 END LOOP;
	         RAISE fnd_api.g_exc_error;
             END IF;

       ELSIF l_dest_instance_header_tbl.count > 1 THEN
         -- Multiple Instances were found so throw error
         debug('Multiple Instances were Found in Install Base-30');
         fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
         fnd_message.set_token('INV_ITEM_ID',l_mtl_item_tbl(j).inventory_item_id);
         fnd_message.set_token('SUBINV',l_mtl_item_tbl(j).subinventory_code);
         fnd_message.set_token('INV_ORG_ID',l_mtl_item_tbl(j).organization_id);
         fnd_message.set_token('LOCATOR',l_mtl_item_tbl(j).locator_id);
         l_error_message := fnd_message.get;
         RAISE fnd_api.g_exc_error;
       END IF;    -- End of Destination Record If
       END IF;      -- End of J Index Loop

       ELSIF (l_mtl_item_tbl(j).serial_number_control_code = 5 AND -- Ship
	      l_sr_control = 6) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	      l_sr_control = 5) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 2 AND -- Ship
	      l_sr_control = 6) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	      l_sr_control = 5) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 6 AND -- Ship
	      l_sr_control = 2) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 2) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 5) OR    -- Rec
             (l_mtl_item_tbl(j).serial_number_control_code = 1 AND -- Ship
	      l_sr_control = 6) THEN  -- Rec

          debug('This Shipping and Receiving Serial Control combination is not supported');
          debug('Shipping Serial Control is: '||l_mtl_item_tbl(j).serial_number_control_code);
          debug('Receiving Serial Control is: '||l_sr_control);

          debug('This is a NON Supported Transaction Combination in Inventory - 38');
          fnd_message.set_name('CSI','CSI_INV_NOT_SUPPORTED');
          fnd_message.set_token('SHIP_ORG',l_mtl_item_tbl(j).organization_id);
          fnd_message.set_token('SHIP_SC',l_mtl_item_tbl(j).serial_number_control_code);
          fnd_message.set_token('REC_ORG',l_mtl_item_tbl(j).transfer_organization_id);
          fnd_message.set_token('REC_SC',l_sr_control);
          fnd_message.set_token('ITEM',l_mtl_item_tbl(j).inventory_item_id);
          l_error_message := fnd_message.get;
          RAISE fnd_api.g_exc_error;
        END IF;  -- End of Serial Control IF
    END LOOP;   -- End of main For Inv Loop

    debug('End time: '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    debug('******End of csi_inv_interorg_pkg.direct_shipment Transaction******');

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       debug('You have encountered a "fnd_api.g_exc_error" exception in the Direct Inter Org Transaction');
       x_return_status := l_fnd_error;

       IF l_mtl_item_tbl.count > 0 THEN
         x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
         x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
         x_trx_error_rec.instance_id := l_upd_error_instance_id;
         x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
         x_trx_error_rec.src_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
         x_trx_error_rec.src_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
         x_trx_error_rec.src_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
         x_trx_error_rec.src_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
         x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
         x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
         x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
         x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
         x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
         x_trx_error_rec.transaction_error_date := l_sysdate ;
       END IF;

       x_trx_error_rec.error_text := l_error_message;
       x_trx_error_rec.transaction_id       := NULL;
       x_trx_error_rec.source_type          := 'CSIORGDS';
       x_trx_error_rec.source_id            := p_transaction_id;
       x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
       x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
       x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
       x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

     WHEN others THEN
        l_sql_error := SQLERRM;
        debug('You have encountered a "when others" exception in the Direct Inter Org Transaction');
        debug('SQL Error: '||l_sql_error);
        fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
        fnd_message.set_token('API_NAME',l_api_name);
        fnd_message.set_token('SQL_ERROR',SQLERRM);
        x_return_status := l_fnd_unexpected;

        IF l_mtl_item_tbl.count > 0 THEN
          x_trx_error_rec.serial_number := l_mtl_item_tbl(j).serial_number;
          x_trx_error_rec.lot_number := l_mtl_item_tbl(j).lot_number;
          x_trx_error_rec.instance_id := l_upd_error_instance_id;
          x_trx_error_rec.inventory_item_id := l_mtl_item_tbl(j).inventory_item_id;
          x_trx_error_rec.src_serial_num_ctrl_code := l_mtl_item_tbl(j).serial_number_control_code;
          x_trx_error_rec.src_location_ctrl_code := l_mtl_item_tbl(j).location_control_code;
          x_trx_error_rec.src_lot_ctrl_code := l_mtl_item_tbl(j).lot_control_code;
          x_trx_error_rec.src_rev_qty_ctrl_code := l_mtl_item_tbl(j).revision_qty_control_code;
          x_trx_error_rec.dst_serial_num_ctrl_code := r_item_control.serial_number_control_code;
          x_trx_error_rec.dst_location_ctrl_code := r_item_control.location_control_code;
          x_trx_error_rec.dst_lot_ctrl_code := r_item_control.lot_control_code;
          x_trx_error_rec.dst_rev_qty_ctrl_code := r_item_control.revision_qty_control_code;
          x_trx_error_rec.comms_nl_trackable_flag := l_mtl_item_tbl(j).comms_nl_trackable_flag;
          x_trx_error_rec.transaction_error_date := l_sysdate ;
        END IF;

        x_trx_error_rec.error_text := fnd_message.get;
        x_trx_error_rec.transaction_id       := NULL;
        x_trx_error_rec.source_type          := 'CSIORGDS';
        x_trx_error_rec.source_id            := p_transaction_id;
        x_trx_error_rec.processed_flag       := csi_inv_trxs_pkg.g_txn_error;
        x_trx_error_rec.transaction_type_id  := csi_inv_trxs_pkg.get_txn_type_id(l_trans_type_code,l_trans_app_code);
        x_trx_error_rec.inv_material_transaction_id  := p_transaction_id;
        x_trx_error_rec.error_stage          := csi_inv_trxs_pkg.g_ib_update;

  END direct_shipment;


END csi_inv_interorg_pkg;

/
